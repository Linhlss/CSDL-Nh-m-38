# PHIẾU REVIEW ERD VÀ BỘ BÀN GIAO TUẦN 1 CỦA TV1 — NGƯỜI REVIEW: TV3

**Ngày:** 11/11/2026. **Mã việc:** W1-T3-12 (checklist `docs/03_CHECKLIST_DU_AN.md`).
**Đối tượng review:** `diagrams/erd_v1.png` (bản 11/11/2026), `sql/01_schema.sql` v1-candidate, `docs/03_dac_ta_nghiep_vu.md` (B01–B18), `docs/04_data_dictionary_va_chuan_hoa.md`, `meetings/decision_log.md` (DEC01–DEC12), `docs/07_ma_tran_truy_van_va_review.md` (RV01–RV10).
**Phạm vi:** đọc tài liệu và đối chiếu với DDL. Đã chạy `sql/01_schema.sql` v1-candidate trên một DB trắng tạm thời (PostgreSQL 17.11) để kiểm tra `tests/ra_fixture.sql`; DB tạm đã xóa sau khi chạy.

**Kết luận:** ERD **đủ** để biểu diễn 10 câu QRA01–QRA10 và hai demo bảo mật B1/B2. **Không có lỗi chặn Gate 1.** Có 1 câu hỏi cho TV1 (E1) và 1 việc TV3 tự làm (E2).

---

## 1. Các điểm đã kiểm tra và đạt

| # | Nội dung | Kết quả |
|---|---|---|
| K1 | ERD khớp DDL: 7 bảng, tên cột, kiểu, PK, FK, UNIQUE; cột cho phép NULL (dấu `?`) đúng với cột không có `NOT NULL` trong DDL | Đạt |
| K2 | Bản số `to_dan_pho 1 — 0..N dia_chi`, `dia_chi 1 — 0..N ho_cu_tru` (B01) | Đạt |
| K3 | Quan hệ nhiều–nhiều cư dân–hộ được giải qua `qua_trinh_cu_tru`: `cu_dan 1 — 0..N`, `ho_cu_tru 1 — 0..N` (B02) | Đạt |
| K4 | Hai vai trò FK `ma_qua_trinh_cu` (đợt cũ) và `ma_qua_trinh_moi` (đợt mới) được vẽ thành **hai đường riêng, có nhãn**; phía sự kiện là `0..1` vì mỗi FK được phép NULL | Đạt |
| K5 | Hình dạng sự kiện (đến chỉ có đợt mới, đi chỉ có đợt cũ, nội bộ có cả hai và khác nhau) được chặn bằng `ck_bd_hinh_dang`; chú thích dưới ERD ghi đúng | Đạt |
| K6 | `ngay_bat_dau` là `NOT NULL`, chỉ `ngay_ket_thuc` được NULL. Điều này cho phép tạo quan hệ chuẩn bị `Q_d` không chứa NULL (xử lý RV08, xem mục 3) | Đạt |
| K7 | `tai_khoan` không có cột mật khẩu (B18); bảng này là tài khoản nghiệp vụ mô phỏng, tách biệt với role PostgreSQL (B14) | Đạt, khớp `docs/06b_bao_mat.md` mục 2.4 |
| K8 | VIEW của demo B2 cần đường nối `to_dan_pho → dia_chi → ho_cu_tru → qua_trinh_cu_tru`; ERD có đủ, không cần thêm bảng | Đạt |

## 2. ERD có trả lời đủ 10 câu QRA không

| Câu | Đường nối cần có trên ERD | Đủ? |
|---|---|---|
| QRA01, 02, 03, 08 | `cu_dan — qua_trinh_cu_tru — ho_cu_tru — dia_chi — to_dan_pho`, cùng `loai_cu_tru`, `ngay_sinh` | Đủ |
| QRA04 | Tự nối `qua_trinh_cu_tru` theo `ma_cu_dan`, so `ma_ho` | Đủ |
| QRA05 | `dia_chi` trừ địa chỉ đã có `ho_cu_tru` (phía hộ là `0..N`) | Đủ |
| QRA06 | `cu_dan` trừ cư dân có trong `qua_trinh_cu_tru` (phía đợt là `0..N`) | Đủ |
| QRA07 | Giao hai tập cư dân theo `loai_cu_tru` | Đủ |
| QRA09 | `qua_trinh_cu_tru` (đã bắt đầu ≤ d) trừ `Q_d` | Đủ |
| QRA10 | `bien_dong_cu_tru` nối **hai lần** với `qua_trinh_cu_tru` qua hai FK riêng, mỗi nhánh đi tiếp tới `to_dan_pho` | Đủ |

**Ghi chú QRA10 và B08:** DDL tuần 1 chưa chặn trường hợp đợt cũ và đợt mới của một sự kiện nội bộ thuộc **hai cư dân khác nhau** (B08 là việc tuần 2). Biểu thức QRA10 vẫn an toàn: phép nối tự nhiên `NB ⋈ CU ⋈ MOI` nối theo `ma_cu_dan`, nên chỉ giữ sự kiện mà hai đợt cùng một người. Không cần đổi schema vì điểm này.

## 3. Phản hồi các góp ý RV01–RV10 của TV1 về phần RA

| Mã | Phản hồi của TV3 |
|---|---|
| RV01–RV07, RV09 | Đồng ý, giữ nguyên cách làm. |
| **RV08** | **Đã sửa.** `docs/06a_dai_so_quan_he.md` mục 0.3 (v0.1): bỏ khẳng định "đại số cổ điển thuần". Tách thành hai bước. Bước 1 chuẩn bị dữ liệu bằng SQL theo B05, tạo `Q_d = CU_TRU_HIEU_LUC_D(ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau)` và bỏ `ngay_ket_thuc`. Bước 2 dùng `Q_d` như quan hệ đầu vào trong đại số cổ điển. Các công thức QRA01, 02, 03, 08, 09 không đổi vì chỉ dùng `ma_cu_dan`, `ma_ho`, `loai_cu_tru`. Đã cập nhật câu `Q_d` trong `tests/ra_fixture.sql` theo lược đồ mới. |
| RV10 | Đồng ý. Mô tả PR #1 đã dùng tên 06a/06b. |

## 4. Vấn đề còn mở

| Mã | Mức | Nội dung | Đề nghị | Người xử lý |
|---|---|---|---|---|
| **E1** | Câu hỏi, không chặn | DEC06 cho phép **một đợt được nhiều sự kiện tham chiếu cùng vai trò**, ví dụ hai sự kiện `CHUYEN_DI` cùng đóng một đợt cũ. Theo B09, hai sự kiện đó buộc phải có cùng ngày, nên thực chất là ghi trùng một sự kiện. Kết quả 10 câu RA **không bị ảnh hưởng** (phép chiếu trả về tập), nhưng có thể làm sai số đếm sự kiện trong câu SQL thống kê của TV2. | TV1 xác nhận lý do giữ DEC06. Nếu giữ, đề nghị thêm vào `sql/06_validation.sql` một truy vấn phát hiện đợt bị tham chiếu từ 2 lần trở lên trong cùng vai trò. Nếu đổi, có thể thêm `UNIQUE(ma_qua_trinh_cu)` và `UNIQUE(ma_qua_trinh_moi)`; PostgreSQL cho phép nhiều giá trị NULL trong cột UNIQUE nên không ảnh hưởng hình dạng sự kiện. | TV1 quyết định |
| E2 | Nhỏ | Cột `tai_khoan.vai_tro` (`QUAN_TRI`, `CAN_BO`, `THONG_KE`) chưa được đối chiếu với 3 role PostgreSQL của demo bảo mật. | TV3 đã thêm bảng đối chiếu vào `docs/06b_bao_mat.md` mục 3, ghi rõ hai tầng này độc lập, không tự đồng bộ. | TV3 (đã xong) |

## 5. Xác nhận của TV3 cho Gate 1

- ERD và DDL v1-candidate biểu diễn đúng 10 câu RA: **xác nhận**.
- Tiếp nhận RV08: **đã sửa** (mục 3).
- Hai demo bảo mật B1/B2 khả thi trên schema hiện tại, không cần đổi bảng lõi: **xác nhận**.
- Gate 1 của TV3 **chưa ký PASS**: còn chờ TV1 trả lời E1. `tests/ra_fixture.sql` đã chạy lại trên DB trắng với schema v1-candidate: 11/11 kết quả khớp.

---

# PHẦN BỔ SUNG NGÀY 13/11/2026

## 6. Review sơ đồ phân rã chức năng (review của W1-T1-08)

**Đối tượng:** `diagrams/phan_ra_chuc_nang.png`, `.drawio`, `.svg` (bản 11/11/2026); `docs/03_dac_ta_nghiep_vu.md` mục 3, 4, 6 (tác nhân, bảng đọc/ghi, P1–P6).

**Kết luận:** sơ đồ **đạt** tiêu chí của W1-T1-08. Không có lỗi chặn Gate 1. Có 1 câu hỏi cho TV1 (C1) và 1 điểm TV3 tự sửa ở tài liệu của mình (C2).

### 6.1. Đối chiếu tiêu chí W1-T1-08

| Tiêu chí | Kết quả |
|---|---|
| 1 nút cấp 0 | Đạt: "Quản lý cư dân và biến động cư trú" |
| 6 nhóm chức năng cấp 1 | Đạt: Địa bàn, Hộ và cư dân, Quá trình cư trú, Biến động, Tra cứu và thống kê, Quản trị và bảo mật |
| Chức năng cấp 2 tương ứng nghiệp vụ | Đạt: 14 chức năng (2 + 2 + 2 + 3 + 3 + 2), khớp chú thích dưới sơ đồ và bảng mục 4 của đặc tả |
| Có cả `.drawio` và `.png` | Đạt, có thêm `.svg` |
| Tên đúng là **phân rã chức năng**, không nhầm với flowchart hay ERD | Đạt. Chú thích ghi rõ đường nối là quan hệ phân rã, không phải trình tự xử lý hay luồng dữ liệu |

### 6.2. Đối chiếu chức năng với quy trình, câu hỏi và demo

| Nhóm cấp 1 | Quy trình P | Phần của TV3 dùng tới |
|---|---|---|
| 1. Quản lý địa bàn | P1 | QRA05 (địa chỉ chưa có hộ) |
| 2. Quản lý hộ và cư dân | P1 (2.1), P2 (2.2) | QRA06 (cư dân chưa có đợt) |
| 3. Quản lý quá trình cư trú | P3 | `Q_d`, QRA04, QRA07, QRA09 |
| 4. Ghi nhận biến động | P4 (4.1), P5 (4.2, 4.3) | QRA10 (4.3 chuyển nội bộ) |
| 5. Tra cứu và thống kê | P6 | 5.1 Hiện tại: QRA01, 02, 03, 08, 09. 5.2 Lịch sử: QRA04, 05, 06, 07, 10. 5.3 Thống kê: VIEW của demo B2 |
| 6. Quản trị và bảo mật | Không có P riêng; bảng mục 4 của đặc tả đã ghi đọc/ghi | 6.1 Vai trò: demo B1 (role, GRANT/REVOKE). 6.2 Giới hạn truy cập: demo B2 (VIEW) |

Cả 10 câu QRA và hai demo B1/B2 đều có chức năng tương ứng trên sơ đồ. Bảng đọc/ghi mục 4 nhất quán với ERD: nhóm 5 chỉ đọc; nhóm 6 ghi role, quyền và VIEW, **không** ghi `tai_khoan` để cấp quyền. Điều này khớp với `docs/06b_bao_mat.md` mục 2.4.

### 6.3. Vấn đề còn mở

| Mã | Mức | Nội dung | Đề nghị | Người xử lý |
|---|---|---|---|---|
| **C1** | Câu hỏi, không chặn | Chức năng **3.2 Kết thúc đợt** chưa rõ phạm vi. P3 ghi "các thao tác chuyển thực tế thực hiện bằng P4/P5", còn P5 đã đóng đợt cũ khi chuyển đi hoặc chuyển nội bộ. Vậy 3.2 dùng cho trường hợp nào: chỉ để hiệu chỉnh khi nhập lịch sử ban đầu, hay cả trường hợp đợt tạm trú hết hạn mà không có sự kiện `CHUYEN_DI`? Điều này ảnh hưởng tới việc TV2 sinh dữ liệu cho QRA09 (người từng cư trú nhưng không còn đợt hiệu lực) và S09. | TV1 ghi một câu trong P3 về các trường hợp được đóng đợt không kèm sự kiện. Kết quả QRA09 không phụ thuộc vào cách chọn, vì QRA09 chỉ dựa vào ngày của đợt. | TV1 |
| C2 | Nhỏ | `docs/06b_bao_mat.md` gọi người dùng role `csdl17_reader` là "cán bộ tra cứu". Đặc tả mục 3 chỉ có 3 tác nhân, không có tác nhân này. | Đã sửa 06b: `csdl17_reader` và `csdl17_report` cùng phục vụ tác nhân **Cán bộ tổng hợp** ở hai mức (tra cứu chi tiết chỉ đọc, và chỉ xem số liệu tổng hợp). Đặc tả mục 3 đã cho phép "chỉ xem cột hoặc VIEW được cấp quyền" nên không cần đổi đặc tả. Chú thích dòng 87 của `sql/05_security.sql` vẫn ghi "cán bộ tra cứu"; TV3 cố ý chưa sửa để không làm lệch mã hash script trong `tests/tv3_review_results.json`, sẽ sửa cùng lần cập nhật script tuần 2. | TV3 (đã sửa 06b) |

## 7. Tiếp nhận phản hồi review của TV1 (`docs/REVIEW_TV3_CHI_TIET.md`)

TV3 đã đọc báo cáo review chi tiết và **tiếp nhận** các nội dung sau:

| Mã | Nội dung TV1 sửa hoặc trả lời | Ý kiến của TV3 |
|---|---|---|
| F01 | Ngày `CHUYEN_DI` của đợt 6 trong `tests/ra_fixture.sql` đổi từ 30/06/2025 thành 01/07/2025 cho khớp B09 | Đồng ý. Lỗi dữ liệu thử do TV3 viết sai quy tắc B09. Đáp án 10 câu QRA không đổi |
| F02 / E1 | Giữ schema theo DEC06; `V_E1_CU`, `V_E1_MOI` trong `sql/06_validation.sql` phải trả 0 dòng trước nghiệm thu | Đồng ý, E1 đóng. Khi đối soát trên seed chính thức, TV3 sẽ chạy hai truy vấn này cùng TV2 |
| F03 | Thêm kiểm tra role có sẵn trước khi thiết lập, đặt thiết lập trong transaction | Đồng ý. Đây là trường hợp TV3 chưa lường trước |
| F04 | Thêm `scripts/review_tv3.py` so sánh tự động kết quả | Đồng ý. `tests/ra_fixture.sql` vẫn là bản in để minh họa trong báo cáo |
| F05 | Sửa mô tả PR #1 sang tên file 06a/06b | Đồng ý |

**TV3 chạy lại trên máy của mình ngày 13/11/2026** (Windows, PostgreSQL 17.11, DB trắng tạm thời, đã xóa sau khi chạy), dùng `main` tại `fa6c055`:

- `sql/01_schema.sql` rồi `sql/05_security.sql`: bước kiểm tra trước chấp nhận 3 role demo đã có sẵn trên cluster (không superuser); có đúng **6 lỗi `permission denied` cố ý**, không có lỗi nào khác.
- `tests/ra_fixture.sql` (bản đã sửa F01): `Q_d`, QRA01–10 và VIEW dưới role report cho **kết quả giống hệt** lần chạy 11/11; 7 bảng rỗng sau ROLLBACK.

## 8. Xác nhận phương án 2 demo bảo mật

TV3 xác nhận **triển khai** demo B1 (GRANT/REVOKE, role `csdl17_reader`) và B2 (VIEW `vw_thong_ke_cu_dan_theo_to`, role `csdl17_report`) theo `sql/05_security.sql` và `docs/06b_bao_mat.md` hiện có trên `main`:

- Schema v1-candidate đủ cho cả hai demo, không cần đổi bảng lõi.
- Hai demo đã chạy được trên DB trắng (mục 7), cả khi TV1 kiểm chứng bằng `SET ROLE` lẫn đăng nhập trực tiếp bằng role.
- **Chưa xong** (theo kế hoạch tuần 2–3): chạy trên seed chính thức của TV2, chụp ảnh vào `evidence/security/`, ghi kết quả S20/S21.

## 9. Trạng thái xác nhận Gate 1 của TV3 (13/11/2026)

| Hạng mục trong phiếu Gate 1 | Ý kiến TV3 |
|---|---|
| Đặc tả và cây chức năng | **Đồng ý**, còn câu hỏi C1 không chặn |
| ERD, lược đồ, từ điển, chuẩn hóa nháp | **Đồng ý** phần ERD và lược đồ (mục 1–2). Phần chuẩn hóa (DEC12) để TV2 và TV1 chốt trong tuần 2 |
| Khả năng đáp ứng 10 RA | **Đồng ý** |
| Phương án 2 demo bảo mật | **Đồng ý triển khai** (mục 8) |

Phía TV3 **không còn điều kiện chặn** Gate 1. Đây là ý kiến của TV3 trong tài liệu, chưa phải chữ ký biên bản họp. Gate 1 chung còn chờ TV2 xác nhận.
