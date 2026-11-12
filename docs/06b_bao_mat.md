# KẾ HOẠCH BẢO MẬT CSDL VÀ KỊCH BẢN DEMO B1, B2

> **Người viết:** TV3 · **Reviewer nghiệp vụ:** TV2 · **Phiên bản:** v0.2 (13/11/2026, bổ sung kiểm tra role có sẵn qua review TV1)
> **Script đi kèm:** `sql/05_security.sql`
> **Căn cứ:** mục 8 của `docs/01_de_cuong.md`, schema `sql/01_schema.sql` v1-candidate (cấu trúc giữ nguyên v0).
> Tệp này là nguồn để viết **Chương 6 – Bảo mật CSDL** của báo cáo.

---

## 1. Mục tiêu và phạm vi

- Trình bày ngắn gọn lý thuyết bảo mật CSDL áp dụng cho đề tài.
- Chạy **ít nhất 2 minh họa thật** trên chính CSDL `csdl17_cu_tru_demo`:
  - **B1 – Phân quyền:** tài khoản chỉ đọc tra cứu được nhưng bị từ chối khi sửa dữ liệu.
  - **B2 – VIEW giới hạn thông tin:** tài khoản báo cáo chỉ xem được số liệu tổng hợp, bị chặn khi đọc bảng gốc có họ tên, ngày sinh.
- Mỗi demo có: mã tạo role và cấp quyền, mã thử, ảnh kết quả (cả trường hợp được phép và bị từ chối), và giải thích.
- **Không thuộc phạm vi:** mã hóa dữ liệu, bảo mật hàng (Row-Level Security), kiểm toán nâng cao, cấu hình mạng. Có thể nhắc tới ở phần hướng mở rộng.

---

## 2. Lý thuyết (nội dung cho mục 6.1–6.2 của báo cáo)

### 2.1. Vì sao cần bảo mật dù dữ liệu là giả lập

CSDL quản lý cư dân trong thực tế chứa **thông tin cá nhân**: họ tên, ngày sinh, giới tính, nơi ở theo thời gian. Lộ những dữ liệu này có thể giúp kẻ xấu xác định nơi ở của một người, hoặc biết ai vừa chuyển đi khỏi một địa chỉ. Đồ án dùng dữ liệu 100% mô phỏng, nhưng thiết kế phân quyền phải làm như với dữ liệu thật, vì mục tiêu là học cách bảo vệ loại dữ liệu này.

### 2.2. Ba mục tiêu bảo mật (mô hình CIA)

| Mục tiêu | Ý nghĩa | Ví dụ trong đề tài | Biện pháp trong đồ án |
|---|---|---|---|
| **Bí mật** (Confidentiality) | Chỉ người được phép mới đọc được dữ liệu | Cán bộ tổng hợp chỉ cần biết số người mỗi tổ, không cần biết họ tên từng người | VIEW tổng hợp + chỉ cấp quyền trên VIEW (Demo B2) |
| **Toàn vẹn** (Integrity) | Dữ liệu không bị sửa sai hoặc sửa trái phép | Cán bộ tra cứu không được tự sửa ngày kết thúc cư trú của ai đó | Chỉ cấp SELECT, không cấp UPDATE/INSERT/DELETE (Demo B1); thêm PK/FK/CHECK và transaction |
| **Sẵn sàng** (Availability) | Người được phép truy cập được khi cần, dữ liệu không bị mất | Cán bộ cần tra cứu lịch sử cư trú bất kỳ lúc nào | Sao lưu `pg_dump`/khôi phục `pg_restore`; không cấp quyền TRUNCATE/DROP cho role nghiệp vụ |

### 2.3. Nguyên tắc quyền tối thiểu (least privilege)

Mỗi tài khoản chỉ được cấp **đúng những quyền cần cho công việc**, không hơn. Áp dụng trong đồ án:

- Mỗi vai trò có **một role riêng**. Không dùng chung tài khoản `postgres` (superuser) cho công việc hằng ngày.
- Role nghiệp vụ **không phải chủ sở hữu bảng**. Chủ sở hữu luôn có toàn quyền trên bảng của mình, nên nếu role demo là owner thì phép thử quyền mất ý nghĩa.
- Thu hồi quyền mặc định của `PUBLIC` rồi mới cấp cho từng role.
- Role tra cứu không được đọc bảng `tai_khoan`, vì công việc tra cứu cư dân không cần thông tin đó.

### 2.4. Xác thực và phân quyền

- **Xác thực** (authentication): kiểm tra "bạn là ai", ví dụ đăng nhập bằng tên role và mật khẩu. Cấu hình trong `pg_hba.conf` và bằng thuộc tính `LOGIN`, `PASSWORD` của role.
- **Phân quyền** (authorization): kiểm tra "bạn được làm gì" trên từng đối tượng. Dùng `GRANT` và `REVOKE`.
- Đồ án có **hai tầng quyền**, cần phân biệt rõ trong báo cáo:
  - Bảng `TAI_KHOAN` là tài khoản **nghiệp vụ mô phỏng**: ghi lại ai đã ghi nhận một biến động. Bảng này **không** cấp hay chặn quyền gì.
  - **PostgreSQL role** là tầng quyền thật, do hệ quản trị kiểm tra trên mọi câu lệnh. Hai demo B1, B2 dùng tầng này.

### 2.5. GRANT và REVOKE

- `GRANT <quyền> ON <đối tượng> TO <role>`: cấp quyền. Quyền trên bảng gồm `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`, `REFERENCES`, `TRIGGER`.
- `REVOKE <quyền> ON <đối tượng> FROM <role>`: thu hồi quyền.
- Muốn truy cập một bảng, role cần đủ **3 tầng quyền**: `CONNECT` trên database, `USAGE` trên schema, và quyền tương ứng trên bảng.
- `PUBLIC` là nhóm ngầm định chứa mọi role. Quyền cấp cho `PUBLIC` thì ai cũng có. Vì vậy script thu hồi quyền của `PUBLIC` trước.
- Khi bị thiếu quyền, PostgreSQL báo lỗi `permission denied for table <tên bảng>` và **không thực hiện** câu lệnh.

### 2.6. VIEW như một cơ chế bảo mật

- VIEW là một truy vấn được đặt tên. Người dùng truy vấn VIEW giống như một bảng.
- Mặc định (`security_invoker = false`), VIEW đọc bảng nền bằng **quyền của chủ sở hữu VIEW**. Do đó có thể cấp `SELECT` trên VIEW cho một role mà **không** cấp quyền trên bảng nền. Role đó chỉ thấy đúng các cột và các dòng mà VIEW trả về.
- Nếu đặt `security_invoker = true` (từ PostgreSQL 15), VIEW kiểm tra quyền của **người gọi** trên bảng nền. Khi đó role report bị từ chối cả khi đọc VIEW. Demo B2 cố ý dùng chế độ mặc định và ghi rõ trong định nghĩa VIEW.
- VIEW tổng hợp giúp **giảm dữ liệu lộ ra**: chỉ trả số lượng theo tổ, không trả mã cư dân, họ tên, ngày sinh.

### 2.7. Phân biệt ràng buộc toàn vẹn và phân quyền

`PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `NOT NULL` bảo vệ **tính đúng** của dữ liệu: không cho nhập ngày kết thúc trước ngày bắt đầu, không cho tham chiếu tới hộ không tồn tại. Các ràng buộc này áp dụng cho **mọi người**, kể cả quản trị. Chúng **không** quyết định ai được đọc hay sửa. Việc đó do `GRANT`/`REVOKE` đảm nhận. Hai cơ chế bổ sung cho nhau, không thay thế nhau.

### 2.8. Các biện pháp khác (nêu ngắn, không demo bắt buộc)

- **Sao lưu và khôi phục:** `pg_dump -Fc csdl17_cu_tru_demo > backup.dump`, `pg_restore -d <db_moi> backup.dump`.
- **Ghi nhật ký:** tham số `log_statement`, `log_connections` của PostgreSQL. Trong mô hình dữ liệu, bảng `bien_dong_cu_tru` có `ma_tai_khoan` và `thoi_diem_ghi` để biết ai ghi nhận sự kiện, lúc nào.
- **Transaction:** các thao tác đóng đợt cũ, mở đợt mới, ghi sự kiện chạy trong một giao dịch để không để lại dữ liệu nửa vời.

---

## 3. Mô hình phân quyền của đồ án

| Role | Ai dùng (tác nhân ở mục 3.1 đề cương) | Database | Schema `public` | 6 bảng nghiệp vụ | `tai_khoan` | `vw_thong_ke_cu_dan_theo_to` |
|---|---|---|---|---|---|---|
| `postgres` (superuser) | Người cài đặt, chạy script | Toàn quyền | Toàn quyền | Chủ sở hữu | Chủ sở hữu | Chủ sở hữu |
| `csdl17_admin` | Quản trị demo / cán bộ quản lý cư dân | CONNECT | USAGE | SELECT, INSERT, UPDATE, DELETE | SELECT, INSERT, UPDATE, DELETE | SELECT |
| `csdl17_reader` | Cán bộ tra cứu | CONNECT | USAGE | **Chỉ SELECT** | Không có | Không có |
| `csdl17_report` | Cán bộ tổng hợp | CONNECT | USAGE | **Không có** | Không có | **Chỉ SELECT** |
| `PUBLIC` | Mọi role khác | Bị thu hồi | Không có CREATE | Không có | Không có | Không có |

"6 bảng nghiệp vụ" là `to_dan_pho`, `dia_chi`, `ho_cu_tru`, `cu_dan`, `qua_trinh_cu_tru`, `bien_dong_cu_tru`.

**Đối chiếu với cột `tai_khoan.vai_tro`** (bổ sung 11/11/2026, mục E2 trong `docs/REVIEW_TV3_ERD_TUAN_1.md`):

| `vai_tro` trong bảng `tai_khoan` (tầng nghiệp vụ mô phỏng) | Role PostgreSQL tương ứng trong demo (tầng quyền thật) |
|---|---|
| `QUAN_TRI` | `csdl17_admin` |
| `CAN_BO` (người ghi nhận biến động) | `csdl17_admin` |
| Không có (cán bộ chỉ tra cứu, không ghi sự kiện nên không cần tài khoản ghi nhận) | `csdl17_reader` |
| `THONG_KE` | `csdl17_report` |

Bảng trên chỉ là **tương ứng gợi ý** để giải thích trong báo cáo. Hai tầng **độc lập**: đổi `vai_tro` hoặc khóa một tài khoản (`trang_thai = 'KHOA'`) **không** tự cấp hay thu hồi role PostgreSQL nào (B14). Muốn chặn một người thật thì quản trị viên phải `REVOKE` hoặc `ALTER ROLE ... NOLOGIN`.

---

## 4. Thứ tự chạy

1. Tạo database `csdl17_cu_tru_demo` (UTF-8), chạy `01_schema.sql`.
2. (Nên có) chạy `03_seed.sql` để có dữ liệu. Nếu chưa có seed, các phép thử quyền vẫn đúng, nhưng VIEW trả toàn số 0 và ảnh B2 kém thuyết phục.
3. Chạy `05_security.sql` bằng tài khoản `postgres`:

   ```text
   psql -U postgres -d csdl17_cu_tru_demo -f sql/05_security.sql
   ```

   Script tự bật `ON_ERROR_STOP` và dùng transaction cho toàn bộ thiết lập. Chỉ tắt dừng ở các lệnh bị từ chối cố ý trong B1/B2, rồi bật lại. Không dùng `--single-transaction` bao cả tệp vì demo có lỗi quyền cố ý.

   **Kiểm tra role có sẵn (F03):** trước CREATE ROLE/VIEW/GRANT/REVOKE, kiểm tra cả ba tên role. Dừng với `CSDL17_PREFLIGHT` nếu role có SUPERUSER, CREATEDB, CREATEROLE, REPLICATION, BYPASSRLS; không LOGIN; sở hữu database hiện tại/schema public/quan hệ trong public; hoặc là thành viên của bất kỳ role khác. Ba role demo phải độc lập. Chiều ngược `GRANT csdl17_reader TO <người cài đặt>` được phép để thử SET ROLE. Không tự hạ quyền, đổi owner hoặc xóa membership của role có sẵn.

   Nếu dùng pgAdmin/DBeaver: **không gửi nguyên tệp có lệnh psql `\set` tới SQL editor**. Chọn trọn khối thiết lập từ `BEGIN` đầu tiên tới `COMMIT` đầu tiên, gồm preflight trước đoạn CREATE ROLE, và bỏ các dòng `\set`. Nếu khối thiết lập lỗi, ROLLBACK và dừng. Chỉ sau COMMIT thành công mới chạy từng khối demo; lỗi 42501 ở các lệnh thử từ chối là mong đợi.
4. Chụp ảnh theo danh sách ở mục 7.

**Đăng nhập thật thay cho `SET ROLE`** (đề cương khuyến khích làm ít nhất một lần cho mỗi demo):

```text
-- Trong psql dưới postgres, đặt mật khẩu tạm (không lưu vào Git, không đưa vào báo cáo):
\password csdl17_reader
-- Mở cửa sổ khác và đăng nhập bằng role đó:
psql -U csdl17_reader -d csdl17_cu_tru_demo
```

Sau đó chạy lại các câu ở PHẦN 3.4–3.6 (bỏ `SET ROLE` / `RESET ROLE`).

---

## 5. Kịch bản Demo B1 – Phân quyền SELECT / UPDATE

**Mục tiêu:** chứng minh `csdl17_reader` tra cứu được nhưng **không** sửa được dữ liệu, và dữ liệu không đổi sau khi thử sửa.

| Bước | Thao tác (PHẦN trong script) | Chạy dưới role | Kết quả mong đợi | Ảnh |
|---|---|---|---|---|
| 1 | Tạo role, cấp quyền (PHẦN 0, 2) | postgres | Không lỗi | — |
| 2 | Xem bảng quyền (2.5) | postgres | `csdl17_reader` chỉ có `SELECT` trên 6 bảng | `SEC_B1_grants.png` |
| 3 | `has_table_privilege` (3.1) | postgres | `true, false, false, false` | (gộp ảnh 2) |
| 4 | Xem dòng `ma_cu_dan = 1` trước khi thử (3.2) | postgres | Ghi lại giá trị `ghi_chu` | `SEC_B1_unchanged.png` (phần trước) |
| 5 | `SET ROLE csdl17_reader`; `SELECT current_user` (3.3) | reader | `csdl17_reader` | `SEC_B1_select_ok.png` |
| 6 | `SELECT ... FROM cu_dan` (3.4) | reader | Trả về dữ liệu | `SEC_B1_select_ok.png` |
| 7 | `UPDATE cu_dan ...`, `INSERT`, `DELETE` (3.5) | reader | `ERROR: permission denied for table cu_dan` (tương tự với `to_dan_pho`, `qua_trinh_cu_tru`) | `SEC_B1_denied.png` |
| 8 | `SELECT * FROM tai_khoan` (3.6) | reader | `ERROR: permission denied for table tai_khoan` | `SEC_B1_denied.png` |
| 9 | `RESET ROLE`; xem lại dòng `ma_cu_dan = 1` (3.7) | postgres | Giống hệt bước 4 | `SEC_B1_unchanged.png` (phần sau) |
| 10 | Đối chứng: admin `UPDATE` trong `BEGIN ... ROLLBACK` (3.8) | admin | `UPDATE 1`, sau đó rollback | `SEC_B1_admin_ok.png` (tùy chọn) |

**Giải thích cho báo cáo:** PostgreSQL kiểm tra quyền **trước khi** thực hiện câu lệnh. `csdl17_reader` chỉ được cấp `SELECT`, nên mọi lệnh ghi bị từ chối và không dòng nào thay đổi. Bước 10 cho thấy lệnh `UPDATE` đó hoàn toàn hợp lệ về cú pháp và ràng buộc; nó bị chặn **chỉ vì quyền**.

---

## 6. Kịch bản Demo B2 – VIEW giới hạn thông tin

**Mục tiêu:** chứng minh `csdl17_report` xem được số cư dân theo tổ qua VIEW, nhưng **không** đọc được bảng `cu_dan` và `qua_trinh_cu_tru`.

| Bước | Thao tác (PHẦN trong script) | Chạy dưới role | Kết quả mong đợi | Ảnh |
|---|---|---|---|---|
| 1 | Tạo VIEW (PHẦN 1), cấp quyền (2.4) | postgres | Không lỗi | — |
| 2 | `pg_get_viewdef` (4.1) | postgres | Định nghĩa VIEW chỉ có `ma_to`, `ten_to`, `so_cu_dan` | `SEC_B2_viewdef.png` |
| 3 | `has_table_privilege` (4.2) | postgres | `true, false, false` | (gộp ảnh 2) |
| 4 | `SET ROLE csdl17_report` (4.3) | report | `csdl17_report` | `SEC_B2_view_ok.png` |
| 5 | `SELECT * FROM vw_thong_ke_cu_dan_theo_to` (4.4) | report | Mỗi tổ một dòng, kể cả tổ có 0 người | `SEC_B2_view_ok.png` |
| 6 | `SELECT ho_ten, ngay_sinh FROM cu_dan` (4.5) | report | `ERROR: permission denied for table cu_dan` | `SEC_B2_denied.png` |
| 7 | `SELECT * FROM qua_trinh_cu_tru` (4.5) | report | `ERROR: permission denied for table qua_trinh_cu_tru` | `SEC_B2_denied.png` |

**Giải thích cho báo cáo:** VIEW được tạo bởi chủ sở hữu bảng và dùng chế độ mặc định `security_invoker = false`, nên VIEW đọc bảng nền bằng quyền của chủ sở hữu. `csdl17_report` chỉ có quyền `SELECT` trên VIEW. Vì vậy nó nhận được con số tổng hợp mà không thể xem họ tên hay ngày sinh của bất kỳ ai.

**Kiểm tra chéo với dữ liệu:** tổng cột `so_cu_dan` của VIEW phải bằng kết quả QSQL03 (TV2) với cùng ngày 20/11/2026. Nếu khác, kiểm tra lại điều kiện thời gian hoặc LEFT JOIN.

---

## 7. Danh sách ảnh minh chứng (lưu tại `evidence/security/`)

| Tên tệp | Nội dung | Demo |
|---|---|---|
| `SEC_B1_grants.png` | Bảng quyền 3 role + `has_table_privilege` | B1 |
| `SEC_B1_select_ok.png` | `current_user = csdl17_reader` và SELECT thành công | B1 |
| `SEC_B1_denied.png` | UPDATE/INSERT/DELETE/đọc `tai_khoan` bị từ chối | B1 |
| `SEC_B1_unchanged.png` | Dòng `ma_cu_dan = 1` trước và sau giống nhau | B1 |
| `SEC_B1_admin_ok.png` | (Tùy chọn) Admin UPDATE thành công rồi ROLLBACK | B1 |
| `SEC_B2_viewdef.png` | Định nghĩa VIEW + `has_table_privilege` | B2 |
| `SEC_B2_view_ok.png` | `current_user = csdl17_report` và kết quả VIEW | B2 |
| `SEC_B2_denied.png` | Đọc `cu_dan`, `qua_trinh_cu_tru` bị từ chối | B2 |

Mỗi ảnh phải thấy rõ **câu lệnh**, **role đang chạy** và **kết quả hoặc thông báo lỗi**. Không dùng ảnh chỉ có lý thuyết.

---

## 8. Lỗi thường gặp và cách xử lý

| Hiện tượng | Nguyên nhân thường gặp | Cách xử lý |
|---|---|---|
| Reader vẫn `UPDATE` được | Đang chạy dưới superuser (quên `SET ROLE`), hoặc reader là owner bảng, hoặc `PUBLIC` còn quyền | Kiểm tra `SELECT current_user`; kiểm tra owner bằng `\dt`; chạy lại PHẦN 2 |
| `CSDL17_PREFLIGHT: từ chối role ...` | Role có sẵn vi phạm một điều kiện độc lập/LOGIN/đặc quyền/quyền sở hữu | Dừng, giữ nguyên role đó; dùng cluster demo sạch hoặc nhờ quản trị viên xác minh riêng. Không bỏ qua preflight để chạy demo |
| `ERROR: permission denied to set role` | Tài khoản đang chạy không phải superuser và không là thành viên của role đó | Chạy bằng `postgres`, hoặc `GRANT csdl17_reader TO <tài khoản đang chạy>` |
| Report bị từ chối cả khi đọc VIEW | VIEW đặt `security_invoker = true`, hoặc chưa `GRANT SELECT` trên VIEW | Kiểm tra PHẦN 1 và 2.4 |
| `ERROR: unrecognized parameter "security_invoker"` | PostgreSQL dưới bản 15 | Cài bản 15 trở lên, hoặc bỏ mệnh đề `WITH (...)` (khi đó mặc định vẫn là quyền của owner) |
| Thành viên khác không kết nối được DB | Script đã thu hồi `CONNECT` của `PUBLIC` | Kết nối bằng `postgres`, hoặc `GRANT CONNECT ON DATABASE csdl17_cu_tru_demo TO <role>` |
| pgAdmin dừng ở lỗi đầu tiên | Công cụ chạy cả script như một khối | Chạy từng khối lệnh riêng |
| VIEW trả toàn số 0 | Chưa có seed, hoặc tên tổ / ngày không khớp | Chạy `03_seed.sql`; đối chiếu với QSQL03 |

---

## 9. Hạn chế cần nêu trong mục 6.5 (Đánh giá)

- **Số nhỏ vẫn có thể lộ thông tin:** nếu một tổ chỉ có 1 người, con số tổng hợp cộng với hiểu biết bên ngoài có thể giúp đoán ra người đó. Hướng khắc phục: chỉ hiển thị tổ có từ k người trở lên (ví dụ `HAVING COUNT(...) >= 5`).
- VIEW dùng **ngày tham chiếu cố định** 20/11/2026 để kết quả tái lập được. Bản dùng thực tế sẽ thay bằng `CURRENT_DATE`.
- Demo dùng `SET ROLE` cho nhanh. Ít nhất một lần nên đăng nhập thật bằng role demo (mục 4).
- Chưa demo bảo mật mức dòng (Row-Level Security), ví dụ mỗi cán bộ chỉ xem cư dân thuộc tổ mình phụ trách. Có thể nêu ở hướng mở rộng.

---

## 10. Tiến độ và phụ thuộc

| Việc | Phụ thuộc | Hạn |
|---|---|---|
| Kế hoạch này + script nháp | Schema v0 (đã có) | 15/11 |
| Chạy thử trên bảng rỗng | TV3 cài PostgreSQL ≥ 15 và chạy `01_schema.sql` | 15/11 |
| Cập nhật theo schema chốt | Gate 1 (cả nhóm) | 16–18/11 |
| Chạy với dữ liệu, đối chiếu VIEW với QSQL03 | Seed của TV2 | 20–22/11 |
| Chụp ảnh chính thức, viết Chương 6 | Gate 2 | 24/11 |

**Checklist nghiệm thu:**

- [ ] Script chạy từ DB sạch không lỗi ngoài các lỗi cố ý.
- [ ] Role có sẵn không phù hợp bị từ chối trước khi thay đổi dữ liệu, ACL, VIEW hoặc role; lỗi thiết lập rollback toàn bộ.
- [ ] B1: reader SELECT được; UPDATE/INSERT/DELETE bị từ chối; dữ liệu không đổi.
- [ ] B2: report đọc được VIEW; đọc `cu_dan` bị từ chối.
- [ ] Đủ 7 ảnh bắt buộc ở mục 7 (ảnh admin thứ 8 tùy chọn).
- [ ] Không có mật khẩu trong Git hay trong báo cáo.
- [ ] TV2 đã review.

---

## 11. Tài liệu tham khảo (đã dùng khi viết tệp này)

- PostgreSQL Documentation – *Privileges*: https://www.postgresql.org/docs/current/ddl-priv.html
- PostgreSQL Documentation – *GRANT*: https://www.postgresql.org/docs/current/sql-grant.html
- PostgreSQL Documentation – *REVOKE*: https://www.postgresql.org/docs/current/sql-revoke.html
- PostgreSQL Documentation – *CREATE VIEW* (tùy chọn `security_invoker`): https://www.postgresql.org/docs/current/sql-createview.html
- PostgreSQL Documentation – *Database Roles*: https://www.postgresql.org/docs/current/user-manag.html
- PostgreSQL 17 – *Role Membership*: https://www.postgresql.org/docs/17/role-membership.html
- PostgreSQL 17 – *psql*, `ON_ERROR_STOP`: https://www.postgresql.org/docs/17/app-psql.html
- [CẦN ĐIỀN: giáo trình môn Cơ sở dữ liệu của lớp, chương về bảo mật và an toàn dữ liệu]
