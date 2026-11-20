# HỒ SƠ TV1 — HOÀN THIỆN KỸ THUẬT VÀ ĐỀ NGHỊ REVIEW GATE 2

**Ngày chạy:** 20/11/2026. **Owner:** TV1 — Trần Bùi Tùng Linh (20227057).
**Nhánh nghiệm thu:** `fix/tv1-integration-gate2` (chưa merge `main`).
**Lần thực thi PostgreSQL cuối cùng đã kiểm chứng:** [GitHub Actions run 44654667107](https://github.com/Linhlss/CSDL-Nh-m-38/actions/runs/44654667107), commit `025c64b3`.

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

- PR #5 của TV3 vẫn **mở**; nhánh `fix/tv1-integration-gate2` là tích hợp thử, không phải merge hai PR độc lập vào main.
- Review chuyên môn của TV2/TV3, Gate 2 xác nhận cả nhóm và Gate 3 chạy/bằng chứng ảnh trên môi trường nộp bài vẫn phải thực hiện.
- Báo cáo cuối còn các phần TODO từ TV2 ở Chương 5, ảnh SQL/bảo mật, kết luận, trang cuối và chữ ký.
- Môi trường Windows TV2 chưa được xác nhận từ log CI.
- Bản phân tích 3NF ghi nhận một điểm dư thừa có điều kiện ở bảng sự kiện; quyết định thiết kế chờ TV2/TV3 review, không phát biểu rằng “3NF tuyệt đối” đã được chứng minh.

**Kết luận kỹ thuật TV1:** 5 nhóm việc PR5 parser, E1/B15, tích hợp RA/SQL/bảo mật, hướng dẫn dựng DB và phân tích chuẩn hóa đã có **mã + test + báo cáo đề xuất**. Nghiệm thu nhóm/nộp bài là một mốc riêng.
