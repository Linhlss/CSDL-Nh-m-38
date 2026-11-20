# HỒ SƠ TV1 — HOÀN THIỆN KỸ THUẬT VÀ ĐỀ NGHỊ REVIEW GATE 2

**Ngày chạy:** 20/11/2026. **Owner:** TV1 — Trần Bùi Tùng Linh (20227057).
**Nhánh nghiệm thu:** `fix/tv1-integration-gate2` (chưa merge `main`).
**Lần thực thi PostgreSQL cuối cùng đã kiểm chứng:**
- **Trước Issue #9:** [GitHub Actions run 44654667107](https://github.com/Linhlss/CSDL-Nh-m-38/actions/runs/44654667107), commit `025c64b3`.
- **Sau khi tích hợp PR #8 và xử lý X01–X07:** xem mục 5 và [log kiểm thử từ DB trắng](../tests/week2_tv1_integration_log.md). Log này ghi cả máy local lẫn liên kết CI của commit cuối.

## 1. Nội dung đã thực hiện và bằng chứng

| Hạng mục | File | Kết quả thực tế |
|---|---|---|
| PR #5: parser 11/12 khối SQL | `scripts/ra_sql_blocks.py`, `tests/test_ra_parser.py`, ba script `verify_week1.py` / `verify_week1_runtime.py` / `review_tv3.py` | **6/6 unit tests**, tách riêng `QRA07_DIV`, không sinh `QRA11` |
| RA/SQL PR #5 | `docs/06a_dai_so_quan_he.md`, `tests/ra_fixture.sql`, `tests/seed636_qra02_03_06_08.sql` | Đối chiếu 10 QRA và QRA07 phép chia trên seed636 và fixture RA |
| E1 | `sql/02_constraints.sql`, `sql/06_validation.sql` | Chặn nghiệm thu nếu một đợt xuất hiện nhiều lần trong cùng vai trò cũ/mới; dữ liệu trùng thử phải được phát hiện |
| B15 | `sql/02_constraints.sql`, `tests/constraints_week2.sql` | CHECK trường văn bản không chỉ khoảng trắng; trigger ngày sinh/ngày lập hộ khi thêm/sửa đợt và khi sửa hồ sơ cha |
| Ràng buộc B06, B08–B11, B14, S17–S19 | `tests/constraints_week2.sql` | **40 thông báo PASS** với lỗi SQLSTATE mong đợi và tình huống hợp lệ; fixture thử tự rollback |
| Validation | `sql/06_validation.sql` | **3 thông báo PASS**: B06/08/09, E1, B15; dữ liệu seed hợp lệ |
| Tích hợp RA/SQL/security | `scripts/verify_gate2_integration.py` | **71 kiểm tra PASS** trên hai CSDL độc lập, gồm 10 QSQL, 10 QRA, phép chia, 6 cặp RA↔SQL, VIEW và quyền role |
| Hồ sơ nguồn tuần 1 | `scripts/verify_week1.py` | **14/14 kiểm tra tĩnh PASS** khi CI tái tạo manifest; bằng chứng lịch sử 96/96 giữ nguyên, không viết lại thành kết quả phiên bản mới |
| Hướng dẫn dựng lại | `docs/08_huong_dan_dung_csdl.md` | Chuỗi chạy rõ ràng; seed636 tách khỏi RA fixture; phân biệt `psql` và GUI |
| Chuẩn hóa/3NF | `docs/04_data_dictionary_va_chuan_hoa.md`, Chương 3 | Đề xuất giữ `ngay_bien_dong` là dữ liệu dư thừa có kiểm soát bởi B09; *chưa tự nhận 7 bảng đạt 3NF tuyệt đối theo mọi FD có điều kiện* |

**Nguồn kiểm chứng:** [Workflow và log run 44654667107](https://github.com/Linhlss/CSDL-Nh-m-38/actions/runs/44654667107). PostgreSQL của runner: `postgres:17`; môi trường xác thực nội bộ CI không chứng minh cấu hình password/TLS thực tế. Các case âm cố ý báo lỗi 23P01/23514/23503/23505/23502 là kết quả hợp lệ của thử nghiệm.

## 2. S04, S14b và phạm vi đánh giá

- **S04:** Kết quả đúng trên seed636 gồm bốn địa chỉ chưa có hộ **47, 48, 49, 50**. PR #5 từng ghi expected chỉ 49–50; TV1 sửa kỳ vọng phù hợp dữ liệu, **không sửa seed**.
- **S14b:** Seed636 chưa có cư dân có hai đợt *đồng thời khác loại trong cùng hộ* để làm bẫy `COUNT(*)` vs `COUNT(DISTINCT)`. Kiểm thử tích hợp tạo một đợt tạm thời hợp lệ trên fixture, kiểm thấy số đợt lớn hơn số người và `ROLLBACK`; fixture/seed không bị thay đổi sau test.
- **E1:** Không tạo UNIQUE ngay trên cột sự kiện, vì đặc tả chưa chốt hạn chế tham chiếu bằng cấu trúc bảng. `fn_assert_e1()` tạo **cổng nghiệm thu**; không phải cơ chế ngăn tất cả lệnh INSERT trực tiếp trước khi chạy validation.
- **B15:** Hai chiều dữ liệu được kiểm thử trong PostgreSQL. Chưa kiểm thử áp lực đồng thời đa kết nối, hoặc mọi đường ghi gián tiếp trong một sản phẩm doanh nghiệp.

## 3. Phân công review chéo trước khi merge / Gate 2

**TV2 — Trần Tuấn Ngọc (20227064):**
- Dựng seed636 theo `docs/08_huong_dan_dung_csdl.md` trên máy Windows, ghi phiên bản PostgreSQL và kết quả.
- Xác nhận 10 SQL, kết quả S01–S16, nhất là `QSQL02` / `COUNT(DISTINCT)` và `QSQL04` = địa chỉ 47–50.
- Hoàn thiện Chương 3.5, Chương 5 và ảnh/minh chứng SQL trong báo cáo.

**TV3 — Dương Ngọc Ninh (20237469):**
- Xác nhận PR #5 được đưa vào nhánh tích hợp **chỉ phần Chương 4, 06a và file test RA**, không phải merge PR #5 nguyên trạng.
- Review bộ parser, ký hiệu RA, QRA07 phép chia và 10 cặp kết quả.
- Kiểm tra 2 demo B1/B2 dưới role thật; hoàn thiện Chương 4 và Chương 6, ảnh minh chứng.

**TV1:** Sau review, xử lý góp ý, so ERD và DDL, đóng kết quả test, hoàn thiện Chương 1–3 (các đoạn ảnh/dữ liệu từ TV2 vẫn cần), bìa/báo cáo và nghiệm thu cuối.

Không được tự gán chữ ký TV2/TV3, không đánh dấu Gate 2 đã được cả nhóm duyệt khi chưa có phản hồi thật.

## 4. Trạng thái còn mở

- PR #5 của TV3 **đã đóng, không merge** (20/11). Nội dung cần thiết nằm trong nhánh `fix/tv1-integration-gate2` (PR #7). PR #8 đã được gộp vào nhánh này bằng fast-forward (mục 5). Chưa có gì merge vào `main`.
- Review chuyên môn của TV2/TV3, Gate 2 xác nhận cả nhóm và Gate 3 chạy/bằng chứng ảnh trên môi trường nộp bài vẫn phải thực hiện.
- Báo cáo cuối còn các phần TODO từ TV2 ở Chương 5, ảnh SQL/bảo mật, kết luận, trang cuối và chữ ký.
- Môi trường Windows TV2 chưa được xác nhận từ log CI.
- Bản phân tích 3NF ghi nhận một điểm dư thừa có điều kiện ở bảng sự kiện. TV3 đã đồng ý giữ `ngay_bien_dong` (W3-T3-08); quyết định vẫn chờ TV2 review. Không phát biểu rằng "3NF tuyệt đối" đã được chứng minh.

**Kết luận kỹ thuật TV1:** 5 nhóm việc PR5 parser, E1/B15, tích hợp RA/SQL/bảo mật, hướng dẫn dựng DB và phân tích chuẩn hóa đã có **mã + test + báo cáo đề xuất**. Nghiệm thu nhóm/nộp bài là một mốc riêng.

## 5. Issue #9 — tích hợp PR #8, xử lý X01–X07, kiểm thử lại (20/11/2026)

### 5.1. Review PR #8 (P0-A1)

| Mục kiểm | Kết luận TV1 | Bằng chứng |
|---|---|---|
| `sql/05_security.sql` B12: `REVOKE DELETE ON qua_trinh_cu_tru, bien_dong_cu_tru FROM csdl17_admin` | **Đúng.** Lệnh chạy sau `GRANT … ON ALL TABLES` nên chạy lại vẫn an toàn. Không role nào còn quyền `DELETE`/`TRUNCATE` trên hai bảng lịch sử. PUBLIC đã bị thu hồi quyền, và preflight chặn mọi membership | K01: ma trận 120 ô (3 role × 8 đối tượng × 5 quyền) khớp thiết kế, có 34 quyền được cấp. C15 đạt |
| `fn_chuyen_noi_bo` sau REVOKE | **Vẫn chạy được.** Hàm là SECURITY INVOKER và chỉ dùng `SELECT … FOR UPDATE`, `UPDATE` và hai `INSERT`, không có `DELETE` | K05: admin gọi thành công trong giao dịch rồi ROLLBACK; không có lỗi `42501` |
| Admin xóa hoặc truncate lịch sử | **Bị chặn** | K02, K03, K04: kết quả `42501` |
| VIEW không cập nhật được (`55000`) và lỗi quyền (`42501`) | **Không bị nhầm lẫn.** P06 kỳ vọng `55000`. Quyền ghi VIEW được kiểm riêng bằng ACL ở C12 và K01 | `tests/security_login_tv3.sql` dòng 98–101; C12 và K01 đạt |
| `scripts/verify_week1.py` thêm `sql/05_security.sql` vào `week2_evolved` | **Chấp nhận.** Tệp thay đổi có chủ đích theo X02. Phần kiểm chứng bị bỏ khỏi đây được bù bằng catalog C01–C15 và K01–K05 trong CI | Workflow có thêm bước "Security catalog C01-C15 and B12 privilege matrix" |
| Đăng nhập thật B1/B2 | **Đạt** trên PostgreSQL 17.12 macOS: TCP, scram-sha-256, mật khẩu tạm được xóa ngay sau khi chạy; mật khẩu sai bị từ chối | Reader đạt 12/12, report đạt 10/10 |

**Phát hiện thêm, không chặn merge:**
1. Admin vẫn có `UPDATE` trên hai bảng lịch sử, nằm trong giới hạn của trigger B08–B09. Điều này đã ghi vào giới hạn ở Chương 3.
2. Tệp `security_login_tv3.sql` thoát với mã 0 nếu đăng nhập nhầm role. CI bù lại bằng cách khẳng định đúng dòng `TONG … PASS`.
3. `security_catalog_tv3.sql` không có mã thoát lỗi. CI bù lại bằng cách đếm đủ 15 PASS và không có FAIL.
4. `seed636_s01_s16_tv3.sql` chỉ in kết quả. TV1 thêm `tests/assert_s01_s16_tv1.sql` để khẳng định kết quả mà không sửa kỳ vọng của TV3.
5. `tests/week2_security_login_log.md` dẫn số dòng 207–209, 212, 253, 254 của `05_security.sql`. Sau khi sửa X02, các dòng thực tế là 211–213, 216, 257, 258. Đây là ghi chú để TV3 cập nhật khi chụp ảnh Gate 3.

### 5.2. Tích hợp (P0-A8)

`git merge --ff-only origin/tv3/gate2-w2-t3` đã đưa nhánh từ `52eb8d9` lên `432600e`, gồm 15 commit của PR #8, không xung đột. Không force-push, không merge PR #5, không đụng `main`. PR #6 của TV2 cũng không bị đụng tới.

### 5.3. X01–X07 (P0-A2, A3; P1-A4…A7)

Xem bảng [docs/07 mục 10.1](07_ma_tran_truy_van_va_review.md) và [nhật ký quyết định mục 9](../meetings/decision_log.md#issue9). Tóm tắt:
- **X01:** chọn phương án (b); **TV1 báo nhóm đã thống nhất ngày 20/11** (xem nhật ký Gate 2; không phải comment review cá nhân).
- **X02:** đã review và chấp nhận.
- **X03–X06:** đã sửa tài liệu và ERD.
- **X07:** giữ quyết định E1 là assertion; test âm được gia cố.

### 5.4. Kiểm thử từ DB trắng (P0-A9)

Chi tiết lệnh, expected/actual/SQLSTATE và md5 nằm ở [tests/week2_tv1_integration_log.md](../tests/week2_tv1_integration_log.md).

### 5.5. Đã làm / chưa làm / cần review

- **Đã làm (TV1):** A1, A2 (đề xuất b), A3–A8, A9 (local và CI), A10 (tài liệu và bằng chứng).
- **Chưa làm:**
  - Merge `main` (B4).
  - Gate 2 (B3).
  - Ảnh chụp và chữ ký (B5).
  - Kiểm thử trên Windows của TV2.
- **Cần review:**
  - **TV2:** xác nhận X01(b); review seed636, QSQL01–10, S01–S16 và Chương 5; dựng DB trên Windows.
  - **TV3:** review bản tích hợp, B12/K01–K05, QRA01–10, QRA07 phép chia, và quyết định X03–X07.


## 6. Chốt Gate 2 theo xác nhận chủ repo — 20/11/2026

- **PASS phần kỹ thuật và nội dung:** theo TV1 báo lại TV2 và TV3 đã đồng ý, bao gồm X01(b) và bản tích hợp sáu chương. Nguồn: [`meetings/decision_log.md` mục 10](../meetings/decision_log.md#gate2). **Không tạo giả review hoặc chữ ký cá nhân.**
- Đối chứng kỹ thuật trước chốt: commit `4bf6e738`, [CI `44670911673`](https://github.com/Linhlss/CSDL-Nh-m-38/actions/runs/44670911673) PASS; dữ liệu mô phỏng không đổi. Khi PR #7 về main, cần ghi lại SHA và kết quả CI trên main trong bình luận PR/Issue, không suy ra CI cũ là CI sau merge.
- Chưa hoàn tất: ảnh QSQL/SEC, xác nhận Windows của TV2, nguồn giáo trình, PDF cuối, phân công xếp loại/chữ ký, Gate 3/4 và nộp.
