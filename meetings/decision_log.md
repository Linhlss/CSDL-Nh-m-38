# NHẬT KÝ QUYẾT ĐỊNH, REVIEW VÀ NGHIỆM THU — NHÓM 38

> **Đính chính đánh số thành viên 19/11/2026:** TV1 Trần Bùi Tùng Linh (20227057); TV2 Trần Tuấn Ngọc (20227064); TV3 Dương Ngọc Ninh (20237469). Bảng phân công hiện hành đã được cập nhật. Những dòng nhật ký, tên PR, vai trò TV1/TV3 và nhận xét tại các thời điểm trước đính chính là tư liệu lịch sử; không được diễn giải chúng như việc thay đổi tác giả, người thực hiện hoặc người đã xác nhận trong quá khứ. Hồ sơ đóng góp cuối cùng cần xác minh với từng thành viên.

**Cập nhật:** 16/11/2026. **Lớp 174356 — ThS. Nguyễn Thị Thanh Huyền.** Đề tài 17: quản lý cư dân và biến động cư trú tại một phường mô phỏng.

| Vai trò | Họ tên | MSSV | Phần chính | Dự phòng kỹ thuật |
|---|---|---|---|---|
| TV1 | Trần Bùi Tùng Linh | 20227057 | Thiết kế, nghiệp vụ, tích hợp | TV3 |
| TV2 | Trần Tuấn Ngọc | 20227064 | Dữ liệu, SQL, kiểm thử | TV1 |
| TV3 | Dương Ngọc Ninh | 20237469 | Đại số quan hệ, bảo mật, review | TV2 |

Danh tính và thứ tự TV do chủ repo cung cấp, không suy từ tài khoản GitHub. Phân công dự phòng không thay chữ ký cá nhân. Nhật ký này là nơi duy nhất đối chiếu 53 mã tuần 1 và kết luận các hồ sơ đã gộp. [Checklist](../docs/03_CHECKLIST_DU_AN.md) quản lý 142 mã toàn dự án; [README](../README.md) hướng dẫn bắt đầu.

## 1. Trạng thái hiện hành

- **Kỹ thuật tuần 1: ĐẠT.** Có thiết kế, fixture29, seed636 sửa B15, 10 SQL, 10 RA, bảo mật và review dữ liệu. Bảng tuần 1 có **52/53 mục hoàn thành**: 46 mục đủ sản phẩm/review kỹ thuật hỗ trợ và 6 mục đã có xác nhận chủ repo; **1 mục môi trường cá nhân TV2 hoãn sang tuần 2** (mục 6).
- **Gate 1 chung: PASS — thiết kế v1.** Ngày tiếp nhận 16/11/2026, nguồn là chủ repo xác nhận trong chat rằng cả ba đã đồng ý khóa thiết kế và đã đối chiếu yêu cầu/thời hạn/quy cách in. Đây là xác nhận qua chủ repo, không tạo chữ ký hoặc khẳng định ngày họp.
- Kiểm chứng độc lập do agent hỗ trợ theo yêu cầu chủ repo: **146/146** trước PR #1 (144 chức năng + 2 tái hiện), **96/96** tuần 1 (95 chức năng + 1 tái hiện B15). Phép tái hiện PASS xác nhận lỗi/giới hạn cũ, không có nghĩa lỗi đó hợp lệ.
- PR #1–#4 đã merge. [PR #4](https://github.com/Linhlss/CSDL-Nh-m-38/pull/4) tích hợp nháp Chương 4/6 tại `12994f106ad9993c0ddf0ff9069bf21268352bd8`. Các nhánh phụ đã dọn; hướng dẫn hiện hành dùng `main`.
- Tuần 2 ưu tiên ràng buộc/transaction của TV1, Chương 3.5/5 của TV2 và bốn kết quả RA còn thiếu trên seed636 của TV3. Lịch và người review nằm trong checklist; ảnh chính thức theo lịch 24/11.

## 2. Quyết định kỹ thuật hiện hành

| ID | Chủ đề | Quyết định kỹ thuật đã dùng | Ảnh hưởng / căn cứ |
|---|---|---|---|
| DEC01 | Phạm vi | Một phường mô phỏng; giữ 7 bảng, 3 loại biến động, 6 nhóm chức năng | Theo đề cương và yêu cầu người dùng hoàn tất đúng tuần 1 |
| DEC02 | Phiên bản | Thiết kế `v1`, chốt theo xác nhận chủ repo tiếp nhận 16/11/2026; giữ nguyên cấu trúc SQL v0 | Không đổi cột/JOIN hoặc byte đầu vào kiểm chứng; chú thích ngày 11/11 trong SQL giữ lịch sử bản v1-candidate |
| DEC03 | Thời gian | Ngày cuối bao gồm; NULL chưa có ngày kết thúc; truy vấn hiện lực xét cả đầu và cuối | B04–B05; d=20/11/2026 cho đối chiếu |
| DEC04 | Ngày chuyển | Ngày chuyển t là ngày bắt đầu nơi mới/không còn ở nơi cũ; cũ kết thúc t−1, mới bắt đầu t | B09; ví dụ và ca D17–D20 đã viết |
| DEC05 | Chồng lấn | Cấm cùng người+cùng loại; cho hai loại khác nhau đồng thời theo mô phỏng | B06; COUNT DISTINCT khi thống kê người |
| DEC06 | Nhật ký; trả lời E1 ngày 12/11/2026 | Giữ hai FK riêng và schema hiện hành, không thêm UNIQUE. Một đợt xuất hiện một lần ở vai trò mới rồi một lần ở vai trò cũ là hợp lệ; nhiều sự kiện dùng cùng đợt trong cùng vai trò là cảnh báo phải xử lý trước nghiệm thu | Giữ cardinality DB 0..N để tương thích bộ bàn giao; V_E1_CU/V_E1_MOI trong `sql/06_validation.sql` phải trả 0 dòng. Đây là validation, DB chưa tự ngăn ghi trùng; không tự xóa/gộp sự kiện vì sẽ làm đổi thống kê |
| DEC07 | Địa chỉ lịch sử | Không dùng sửa liên kết hộ–địa chỉ/tổ để ghi chuyển chỗ ở | B11; tạo bản ghi mới để bảo toàn diễn giải lịch sử |
| DEC08 | Ràng buộc tuần 2 | Exclusion GiST + btree_gist cho chồng lấn; trigger sự kiện và chiều sửa đợt; transaction đóng/mở/ghi | Mới là đặc tả, chưa bật trong DB |
| DEC09 | Câu hỏi | Giữ bộ 10 RA/10 SQL; QSQL03 có tổ 0 người; QSQL08 chỉ có nhóm phát sinh | Ma trận 20 câu và hợp đồng cột đầu ra |
| DEC10 | Phạm vi lịch sử | QRA04/07 và QSQL05/06 xét toàn bộ dữ liệu đã ghi nhận; QRA09/QSQL07 có điều kiện đã bắt đầu <=d | Tránh vô tình dùng hai nghĩa thời gian khi đối soát |
| DEC11 | Nơi lưu sản phẩm | Dùng tên file bảng A2 của checklist; tài liệu TV3 hiện có trên PR giữ tên 06a/06b | README và đề cương dẫn về bộ bàn giao này |
| DEC12 | Chuẩn hóa | Hoàn thiện phân tích khóa/FD; công bố riêng điểm dư thừa ngày sự kiện theo B09 | Không tuyên bố tuyệt đối 3NF cho mọi phụ thuộc có điều kiện; reviewer chốt luận chứng cuối tuần 2 |
| DEC13 | C1 / kết thúc đợt, 16/11 | Nhập/hiệu chỉnh lịch sử hoặc hết hạn tạm trú không phát sinh chuyển chỗ có thể kết thúc đợt không CHUYEN_DI; chuyển thực tế vẫn dùng P4/P5 và giữ B08–B09 | QRA09/QSQL07 dựa vào ngày của đợt; các ca C1 trong log tuần1 đã chạy |

Các quyết định trên là cơ sở thiết kế v1 được cả nhóm đồng ý theo xác nhận chủ repo tiếp nhận ngày 16/11/2026. Phê duyệt Gate 1 không nghiệm thu thay phần ràng buộc nâng cao, seed cuối hoặc báo cáo tuần 2–3. Quy tắc và tên cột chi tiết nằm ở [đặc tả](../docs/03_dac_ta_nghiep_vu.md), [từ điển/chuẩn hóa](../docs/04_data_dictionary_va_chuan_hoa.md) và [ma trận 20 câu hỏi](../docs/07_ma_tran_truy_van_va_review.md).

<a id="week1-ledger"></a>

## 3. Đối chiếu đủ 53 mã tuần 1

Mỗi mã chỉ có một dòng. Reviewer kỹ thuật hỗ trợ là agent, xác nhận thật của TV3 truy được qua PR #2; sáu mục xác nhận bổ sung đóng theo lời chủ repo tiếp nhận 16/11/2026. Mục máy cá nhân TV2 được ghi riêng là hoãn sang W2-T2-01. Checkbox tuần 1 ở checklist phản ánh các dòng bắt đầu bằng “Đạt”; không tự thay lời phê duyệt của thành viên.

| Mã | Người phụ trách | Nội dung | Sản phẩm / bằng chứng | Trạng thái |
|---|---|---|---|---|
| W1-T1-01 | TV1 | 10/11 · Xác nhận đầu vào | [01_de_cuong.md](../docs/01_de_cuong.md); [03_dac_ta_nghiep_vu.md](../docs/03_dac_ta_nghiep_vu.md) | Đạt đối chiếu thông báo gốc theo xác nhận chủ repo trong chat, tiếp nhận 16/11/2026; bản thông báo chưa lưu trong repo |
| W1-T1-02 | TV1 | 10/11 · Chốt thuật ngữ | [03_dac_ta_nghiep_vu.md](../docs/03_dac_ta_nghiep_vu.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-03 | TV1 | 10–11/11 · Mô tả bối cảnh và tác nhân | [03_dac_ta_nghiep_vu.md](../docs/03_dac_ta_nghiep_vu.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-04 | TV1 | 11/11 · Đặc tả P1–P6 | [03_dac_ta_nghiep_vu.md](../docs/03_dac_ta_nghiep_vu.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-05 | TV1 | 11/11 · Quy tắc nghiệp vụ 1–N | [03_dac_ta_nghiep_vu.md](../docs/03_dac_ta_nghiep_vu.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-06 | TV1 | 11–12/11 · Quy tắc thời gian | [03_dac_ta_nghiep_vu.md](../docs/03_dac_ta_nghiep_vu.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-07 | TV1 | 11–12/11 · Quy tắc biến động | [03_dac_ta_nghiep_vu.md](../docs/03_dac_ta_nghiep_vu.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-08 | TV1 | 12/11 · Vẽ cây chức năng | [phan_ra_chuc_nang.png](../diagrams/phan_ra_chuc_nang.png); [review TV3](decision_log.md#review-tv3) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-09 | TV1 | 12/11 · Liệt kê đủ 7 thực thể | [erd_v1.png](../diagrams/erd_v1.png); [04_data_dictionary_va_chuan_hoa.md](../docs/04_data_dictionary_va_chuan_hoa.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-10 | TV1 | 12–13/11 · Vẽ ERD chuẩn | [erd_v1.png](../diagrams/erd_v1.png); [04_data_dictionary_va_chuan_hoa.md](../docs/04_data_dictionary_va_chuan_hoa.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-11 | TV1 | 12–13/11 · Soát 2 liên kết đặc biệt | [erd_v1.png](../diagrams/erd_v1.png); [04_data_dictionary_va_chuan_hoa.md](../docs/04_data_dictionary_va_chuan_hoa.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-12 | TV1 | 13/11 · Ánh xạ ER → quan hệ | [04_data_dictionary_va_chuan_hoa.md](../docs/04_data_dictionary_va_chuan_hoa.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-13 | TV1 | 13/11 · Từ điển dữ liệu | [04_data_dictionary_va_chuan_hoa.md](../docs/04_data_dictionary_va_chuan_hoa.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-14 | TV1 | 13/11 · Phụ thuộc hàm và 3NF | [04_data_dictionary_va_chuan_hoa.md](../docs/04_data_dictionary_va_chuan_hoa.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-15 | TV1 | 13–14/11 · Soát DDL v0 | [01_schema.sql](../sql/01_schema.sql); [week1_sql_compatibility.json](../tests/week1_sql_compatibility.json) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-16 | TV1 | 14/11 · Kiểm tra các ràng buộc còn thiếu | [02_constraints.sql](../sql/02_constraints.sql); [week1_design_cases.md](../tests/week1_design_cases.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-17 | TV1 | 14/11 · Đối chiếu truy vấn | [07_ma_tran_truy_van_va_review.md](../docs/07_ma_tran_truy_van_va_review.md); [05_ke_hoach_du_lieu_va_sql.md](../docs/05_ke_hoach_du_lieu_va_sql.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-18 | TV1 | 14–15/11 · Hoàn thiện Chương 1–3 dạng bản nháp | [02_bao_cao_suon.md](../docs/02_bao_cao_suon.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-19 | TV1 | 15/11 · Tổ chức Gate 1 | [decision_log.md](../meetings/decision_log.md) | Đạt review Gate 1 theo chủ repo xác nhận cả ba đã đồng ý, tiếp nhận 16/11/2026; không ghi ngày họp hoặc chữ ký giả |
| W1-T1-20 | TV1 | 15/11 · Phát hành schema v1 | [phiên bản và Gate 1](decision_log.md#gate1) | Đạt phát hành thiết kế v1 theo xác nhận chủ repo tiếp nhận 16/11/2026; giữ nguyên schema |
| W1-T2-01 | TV2 | 10–11/11 · Thiết lập máy | [week1_environment.md](../tests/week1_environment.md); [week1_execution_results.json](../tests/week1_execution_results.json) | Hoãn theo yêu cầu chủ repo 16/11/2026 sang W2-T2-01; TV2 dùng Windows, chưa rõ PostgreSQL/công cụ/kết quả kết nối cá nhân |
| W1-T2-02 | TV2 | 11/11 · Đọc schema v0 | [05_ke_hoach_du_lieu_va_sql.md](../docs/05_ke_hoach_du_lieu_va_sql.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T2-03 | TV2 | 11/11 · Chốt danh sách QSQL01–10 | [05_ke_hoach_du_lieu_va_sql.md](../docs/05_ke_hoach_du_lieu_va_sql.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T2-04 | TV2 | 11–12/11 · Ma trận truy vấn–bảng | [05_ke_hoach_du_lieu_va_sql.md](../docs/05_ke_hoach_du_lieu_va_sql.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T2-05 | TV2 | 12/11 · Quy ước ngày và kết quả | [05_ke_hoach_du_lieu_va_sql.md](../docs/05_ke_hoach_du_lieu_va_sql.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T2-06 | TV2 | 12/11 · Chống trùng bản ghi | [05_ke_hoach_du_lieu_va_sql.md](../docs/05_ke_hoach_du_lieu_va_sql.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T2-07 | TV2 | 12–13/11 · Kế hoạch sinh dữ liệu | [05_ke_hoach_du_lieu_va_sql.md](../docs/05_ke_hoach_du_lieu_va_sql.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T2-08 | TV2 | 13/11 · Thứ tự sinh/nạp | [03_seed.sql](../sql/03_seed.sql); [README.md](../data/README.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T2-09 | TV2 | 13/11 · Sinh dữ liệu tái lập | [generate_data.py](../scripts/generate_data.py); [week1_execution_results.json](../tests/week1_execution_results.json) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T2-10 | TV2 | 13–14/11 · Bộ dữ liệu kiểm chứng nhỏ | [week1_fixture.sql](../tests/week1_fixture.sql); [week1_expected.json](../tests/week1_expected.json) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T2-11 | TV2 | 13–14/11 · Ma trận S01–S16 | [test_scenarios.md](../tests/test_scenarios.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T2-12 | TV2 | 14/11 · Lập kế hoạch test S17–S21 | [test_scenarios.md](../tests/test_scenarios.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T2-13 | TV2 | 14/11 · Review ERD với TV1 | [05_ke_hoach_du_lieu_va_sql.md](../docs/05_ke_hoach_du_lieu_va_sql.md); [review dữ liệu](decision_log.md#review-data) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T2-14 | TV2 | 15/11 · Bàn giao kế hoạch | [05_ke_hoach_du_lieu_va_sql.md](../docs/05_ke_hoach_du_lieu_va_sql.md) | Đạt bộ bàn giao và xác nhận đồng ý thiết kế của cả nhóm qua chủ repo, tiếp nhận 16/11/2026 |
| W1-T3-01 | TV3 | 10–11/11 · Đọc đề bài và schema | [06a_dai_so_quan_he.md](../docs/06a_dai_so_quan_he.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T3-02 | TV3 | 11/11 · Chốt QRA01–10 | [06a_dai_so_quan_he.md](../docs/06a_dai_so_quan_he.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T3-03 | TV3 | 11–12/11 · Ma trận toán tử | [06a_dai_so_quan_he.md](../docs/06a_dai_so_quan_he.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T3-04 | TV3 | 12/11 · Kiểm tra kiểu tập hợp | [06a_dai_so_quan_he.md](../docs/06a_dai_so_quan_he.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T3-05 | TV3 | 12/11 · Quy ước thời gian cho RA | [06a_dai_so_quan_he.md](../docs/06a_dai_so_quan_he.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T3-06 | TV3 | 12–13/11 · Làm thử 2 câu khó | [06a_dai_so_quan_he.md](../docs/06a_dai_so_quan_he.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T3-07 | TV3 | 13/11 · Rà soát câu QRA10 | [06a_dai_so_quan_he.md](../docs/06a_dai_so_quan_he.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T3-08 | TV3 | 13/11 · Lý thuyết bảo mật trọng tâm | [06b_bao_mat.md](../docs/06b_bao_mat.md); [05_security.sql](../sql/05_security.sql) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T3-09 | TV3 | 13–14/11 · Kịch bản B1 | [06b_bao_mat.md](../docs/06b_bao_mat.md); [05_security.sql](../sql/05_security.sql) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T3-10 | TV3 | 13–14/11 · Kịch bản B2 | [06b_bao_mat.md](../docs/06b_bao_mat.md); [05_security.sql](../sql/05_security.sql) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T3-11 | TV3 | 14/11 · Xác minh tính khả thi PG | [06b_bao_mat.md](../docs/06b_bao_mat.md); [05_security.sql](../sql/05_security.sql) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T3-12 | TV3 | 14/11 · Review ERD độc lập | [review TV3](decision_log.md#review-tv3) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T3-13 | TV3 | 14–15/11 · Review test dữ liệu TV2 | [review dữ liệu](decision_log.md#review-data); [week1_execution_results.json](../tests/week1_execution_results.json) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T3-14 | TV3 | 15/11 · Bàn giao đặc tả | [06a_dai_so_quan_he.md](../docs/06a_dai_so_quan_he.md); [06b_bao_mat.md](../docs/06b_bao_mat.md); [review TV3](decision_log.md#review-tv3) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-G-01 | Cả nhóm | Kickoff, vai trò và thông tin nhóm | [02_bao_cao_suon.md](../docs/02_bao_cao_suon.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-G-02 | Cả nhóm | Repo và quyền cộng tác | [README.md](../README.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-G-03 | Cả nhóm | Đối soát chung 10 RA/10 SQL | [week1_execution_results.json](../tests/week1_execution_results.json); [decision_log.md](../meetings/decision_log.md) | Đạt đối soát kỹ thuật; nhóm đồng ý thiết kế theo xác nhận chủ repo tiếp nhận 16/11/2026 |
| W1-G-04 | Cả nhóm | Biên bản Gate 1 | [decision_log.md](../meetings/decision_log.md) | Đạt Gate 1 theo xác nhận chủ repo trong chat, tiếp nhận 16/11/2026; không tạo ngày họp hoặc chữ ký |
| W1-G-05 | Cả nhóm | Bàn giao giao diện dữ liệu | [phiên bản và Gate 1](decision_log.md#gate1); [05_ke_hoach_du_lieu_va_sql.md](../docs/05_ke_hoach_du_lieu_va_sql.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |

<a id="review-tv3"></a>

## 4. Kết luận review TV3 và lịch sử tiếp nhận

### 4.1. Xác nhận do TV3 ghi

Nguồn: [PR #2](https://github.com/Linhlss/CSDL-Nh-m-38/pull/2), commit `a5fd76dd3dc2b6520fa2948b2375e1cfda2a231f`, merge `2f46a0f81e24760239659c7833a4a6f865c7f2ae`. Đây là lời xác nhận của TV3 ngày 11–13/11, tách khỏi kiểm tra mới do agent thực hiện ngày 16/11.

- TV3 xác nhận ERD/lược đồ đáp ứng 10 QRA, hai FK cũ/mới đúng vai trò; cây chức năng có 1 gốc, 6 nhóm, 14 chức năng cấp 2 và đủ nguồn/ảnh. Không cần thêm bảng lõi cho RA/B1/B2.
- TV3 tiếp nhận F01–F05, câu trả lời E1, RV08 và triển khai B1/B2 theo script đã merge. TV3 báo cáo đã chạy lại tại `fa6c055`: fixture khớp lần 11/11 và security có đúng sáu lỗi quyền cố ý. Đây là kết quả thành viên báo cáo, không ghi thành lần chạy độc lập của agent.
- Phía TV3 không còn điều kiện chặn Gate 1; chưa phải chữ ký của cả nhóm. C1 được TV1 giải quyết ngày 16/11 theo DEC13, không cần đổi schema.

### 4.2. Phát hiện và trạng thái cuối

| Mã | Phát hiện / quyết định | Kết quả và phần tiếp theo |
|---|---|---|
| F01 / B09 | Fixture đợt 6 kết thúc 30/06/2025 nhưng chuyển đi cùng ngày | Đã sửa ngày chuyển thành 01/07/2025 tại `355aa6e`; V_B09 trả 0. Cả 10 truy vấn đúng chưa đủ phát hiện lỗi ngày nên giữ validation riêng. |
| F02 / E1 | Trùng FK đợt trong cùng vai trò có thể làm sai đếm sự kiện | DEC06 giữ schema, không thêm UNIQUE; V_E1_CU/V_E1_MOI phải 0 trước nghiệm thu. Một đợt dùng một lần ở mỗi vai trò hợp lệ; DB vẫn có thể nhận trùng. Không dùng DISTINCT cư dân để che lỗi sự kiện. TV1/TV2 xử lý nếu phát sinh. |
| F03 | Role demo có sẵn có thể vượt quyền mong đợi | Đã sửa preflight trước mọi thay đổi role/VIEW/ACL: từ chối đặc quyền, NOLOGIN, ownership trong database/public và membership sang role khác. Cho phép chiều người cài đặt nhận role demo. Thiết lập transaction, psql ON_ERROR_STOP; lỗi dừng và rollback. GUI chạy trọn BEGIN..COMMIT trước demo. |
| F04 | Fixture chỉ in kết quả, psql exit 0 chưa chứng minh đáp án đúng | Giữ giới hạn fixture; bộ `review_tv3.py` ASSERT đầy đủ tập dòng/cột và ca biên. Không dùng riêng exit code làm nghiệm thu. |
| F05 / RV10 | Tên file và quy ước Q_d trong mô tả PR cũ | Đã cập nhật PR #1 sang 06a/06b và Q_d hiện hành trước merge. |
| RV08 | NULL không thuộc đại số quan hệ cổ điển | Đã sửa: SQL chuẩn bị đợt hiệu lực theo B05, bỏ ngay_ket_thuc rồi dùng Q_d trong các biểu thức. Không thêm bảng lõi; không coi phép hiệu là cách tự loại NULL. |
| E2 | Tài khoản nghiệp vụ và role PostgreSQL dễ bị hiểu là đồng bộ | Đã làm rõ hai tầng độc lập trong 06b; sửa trạng thái tai_khoan không tự đổi quyền DB. |
| C1 | Chưa rõ khi nào kết thúc đợt không có CHUYEN_DI | Đã chốt DEC13/P3; lịch sử/hết hạn tạm trú không chuyển chỗ có thể không có sự kiện, chuyển thực tế vẫn P4/P5 và B08–B09. |
| C2 | Tên tác nhân ở 06b chưa khớp đặc tả | Đã sửa: reader/report phục vụ Cán bộ tổng hợp ở hai mức; postgres là quản trị. Chú thích “cán bộ tra cứu” còn trong SQL cũ không ảnh hưởng thực thi, giữ nguyên byte để bảo toàn bằng chứng và rà lại cùng đợt sửa SQL tuần 2. |

### 4.3. Đối chiếu 10 QRA trên fixture TV3

Nguồn ban đầu `7abe4d54f7e7cc96ac086b7e1127073493152e24`; fixture đã sửa F01 tại `355aa6e`. Bảng dưới giữ kết luận review và tập khóa tóm tắt. Bộ chạy thực tế so đầy đủ cột; không phải chứng minh hình thức biểu thức đúng trên mọi dữ liệu. RV01–RV07/RV09 đã soát; RV08/RV10 đã xử lý như trên.

| Câu | Nội dung soát / kết luận | Khóa expected = actual trên fixture nhỏ | Ca bổ sung đã đạt |
|---|---|---|---|
| QRA01 | Đường nối Q_d → hộ → địa chỉ → tổ đầy đủ; chiếu theo mã người tránh gộp trùng tên | 1, 7, 9, 10 | Bắt đầu đúng d/kết thúc đúng d được lấy; kết thúc d−1 và bắt đầu d+1 bị loại; hai loại cùng tổ không nhân dòng |
| QRA02 | Theta join và lọc TAM_TRU đúng; Q là bí danh Q_d trong quy ước đầu vào | 2 | Người vừa thường trú Tổ 01 vừa tạm trú Tổ 02 vẫn được lấy ở Tổ 02; người thường trú Tổ 02 bị loại |
| QRA03 | So ngày sinh <=20/11/1966 kết hợp hiệu lực/Tổ 01 đúng | 1 | Sinh đúng ngày cắt được lấy; sinh 21/11/1966 bị loại; đủ tuổi tổ khác/đợt hết hạn bị loại |
| QRA04 | Đổi tên mã hộ A/B, tự nối cùng mã cư dân và so hai hộ khác nhau đúng | 4, 9 | Hai đợt cùng hộ của người 7 không đủ điều kiện; hai hộ của người 15/17 được lấy |
| QRA05 | Hiệu hai quan hệ cùng thuộc tính ma_dia_chi, rồi nối lại lấy địa chỉ chuẩn đúng | Địa chỉ 5 | Phân biệt địa chỉ không hộ với hộ không người; hộ 5 rỗng không làm địa chỉ 1 lọt kết quả |
| QRA06 | Hiệu mã cư dân trừ mã người trong mọi đợt đúng | 6 | Người chỉ có đợt tương lai không được coi là chưa từng có bản ghi đợt |
| QRA07 | Giao hai tập ma_cu_dan theo từng loại đúng; không lọc hai loại trên cùng một dòng | 4 | Hai loại khác thời kỳ của người 17 vẫn được lấy; người chỉ một loại bị loại |
| QRA08 | Hợp hai tập khóa cùng miền; Q_d đã lọc thời gian đúng | 1, 2, 3, 7, 9, 10 | Người 15 thuộc cả hai tổ chỉ xuất hiện một lần trong hợp |
| QRA09 | Tập đã bắt đầu <=d trừ tập đang ở, phân biệt rõ với QRA06 | 5 | Người 13/17 đã hết mọi đợt được lấy; người 6 chưa có đợt và người 8/14 chỉ có tương lai bị loại |
| QRA10 | Đổi tên hai vai trò đợt cũ/mới; natural join còn buộc cùng mã cư dân; lọc khác tổ đúng | 4 | Người 9 chuyển cùng tổ bị loại; sự kiện cố tình ghép hai người khác nhau cũng bị loại |

Q_d fixture có bảy đợt 1,2,3,5,8,11,12. VIEW trên fixture cho Tổ01/02/03 = 4/2/1; ca bổ sung = 7/3/1/0. Người cùng tổ có hai loại đếm một; người ở hai tổ đếm ở từng tổ. B1/B2 đạt bằng SET ROLE và đăng nhập trực tiếp: reader SELECT được, ghi và đọc tai_khoan bị chặn; report đọc VIEW được, đọc bảng gốc bị chặn đúng SQLSTATE 42501; admin đối chứng ghi trong ROLLBACK; dữ liệu 7 bảng không đổi.

### 4.4. Phạm vi kiểm tra preflight và rollback trước PR #1

Đầu vào kiểm chứng được lưu tại [52f5c6e](https://github.com/Linhlss/CSDL-Nh-m-38/commit/52f5c6e2514cee19c966ed4451a549fae2c7ceb4); log có commit nền và hash byte đầu vào. PR #1 merge `d84571e544b480c9c4ba4a421d5d5435b33faac8`, HEAD nguồn `3414131a66bff6f39d7094225bf5a858beb3421f`. 146 kiểm tra bao gồm 2 tái hiện: B09 fixture cũ và fixture đứng riêng chưa ASSERT.

| Nhóm test mới | Kết quả |
|---|---|
| SUPERUSER, CREATEDB, CREATEROLE, REPLICATION, BYPASSRLS, NOLOGIN trên từng role admin/reader/report | Đủ 18 ca, mỗi ca dừng đúng 42501/CSDL17_PREFLIGHT và trạng thái không đổi |
| Owner database, public schema, bảng, VIEW, sequence trong public | Cả 5 ca bị từ chối, trạng thái không đổi |
| Membership INHERIT TRUE/SET FALSE và INHERIT FALSE/SET TRUE | Cả hai bị từ chối; không dựa vào việc quyền có đang được kế thừa ngay hay không |
| Reader không phù hợp trong khi hai tên role còn lại chưa tồn tại | Dừng trước CREATE ROLE; không tạo thêm role |
| Người cài đặt nhận role reader (chiều ngược) | Thiết lập được; phiên đăng nhập riêng của người cài đặt SET ROLE reader được |
| Gây lỗi chia 0 ngay trước COMMIT sau thay đổi VIEW/ACL | Dừng 22012; rollback khôi phục chính xác trạng thái trước thiết lập |
| Role mới, role an toàn có sẵn, chạy lại và sau các test âm | Thiết lập/demo tiếp tục đúng sáu lỗi quyền cố ý |

Expected/actual gồm hash dữ liệu 7 bảng, role/membership, owner/ACL database/schema/quan hệ, định nghĩa VIEW và sequence; xem [log 146](../tests/tv3_review_results.json). Đây là kiểm soát phạm vi demo, không phải audit toàn cluster. Kết quả cũ ngày 12/11 là 89/89 (86 chức năng + 3 tái hiện), còn trong [lịch sử 30f557f](https://github.com/Linhlss/CSDL-Nh-m-38/tree/30f557f3762c43831a5d10b8b11e4acf8f080412).

<a id="review-data"></a>

## 5. Review dữ liệu TV2 và bằng chứng kiểm chứng

Đầu vào TV2 ở [PR #3](https://github.com/Linhlss/CSDL-Nh-m-38/pull/3), nền `63388b394095da137a460ca2f439082bef2077f5`; bản sửa đã merge tại `921b18a5c8d55231bf2d83e72d5d01e264c99340`. Tìm thấy 54/250 đợt vi phạm B15 do lập hộ sau ngày bắt đầu cư trú; sửa ngày lập hộ thành min(ngày gốc, ngày bắt đầu sớm nhất). Giữ RNG, ID, ngày cư trú/sự kiện và dữ liệu khác. Bộ sinh từ chối dữ liệu lỗi trước ghi file; sinh hai lần khớp byte, seed nạp lại giữ đáp án và 7 sequence đúng ID tiếp theo.

Seed có **636 dòng**: 8 tổ + 50 địa chỉ + 60 hộ + 200 người + 250 đợt + 63 sự kiện + 5 tài khoản. Fixture29 có 3 tổ + 3 địa chỉ + 3 hộ + 7 người + 8 đợt + 2 tài khoản + 3 sự kiện; fixture RA cũ có 40 dòng tổng, không dùng “10 cư dân” thay tiêu chí 15–30 bản ghi.

| Ca | ID tiny29 / expected | Đối chứng và actual |
|---|---|---|
| S04 | Địa chỉ3 | Địa chỉ1 có hộ3 rỗng không lọt; QSQL04/QRA05 khớp |
| S06 | C5, hai hộ | C3 hai đợt cùngH1 bị loại; QSQL05/QRA04 khớp |
| S07 | C3,C5 | C1,C2 một loại bị loại; QSQL06/QRA07 khớp |
| S09 | C7 | Loại C6 chưa có đợt, C80 chỉ tương lai; ca C1 hết hạn không sự kiện cũng đạt |
| S10 | C6 | C80 có đợt tương lai không được coi là chưa có đợt; QRA06 đúng |
| S13 | Sự kiện2/C5/Tổ01→02 | Cùng tổ trong rollback bị loại; chiếu người QSQL09 khớp QRA10 |

10 SQL khớp đầy đủ tuple trên tiny29 với đáp án tay và trên seed636 với bộ tính Python độc lập. Sáu cặp QRA01/04/05/07/09/10 khớp SQL ở cùng mức hạt; QRA02/03/06/08 khớp đáp án tay tiny29, còn phải ghi đủ kết quả seed636 trong tuần 2. Quy tắc chiếu/DISTINCT theo từng cặp ở [06a](../docs/06a_dai_so_quan_he.md). VIEW khớp QSQL03 trên hai DB, có tổ 0 người. Các ca trùng tên, sát ngày sinh, ngày cuối, tương lai và C1 không sự kiện được kiểm tra; không biến kết thúc đợt thành sự kiện chuyển đi giả.

- [Log 96 expected/actual](../tests/week1_execution_results.json), [fixture29](../tests/week1_fixture.sql), [đáp án tay](../tests/week1_expected.json), [môi trường và lệnh tái lập](../tests/week1_environment.md). 95 kiểm tra chức năng + 1 tái hiện 54 lỗi B15 cũ; hash xác định đầu vào chính xác, git_head là commit nền. S17–S19 ở đây chỉ chứng minh FK/CHECK cơ bản, chưa chứng minh trigger/transaction tuần 2.
- [Log 146](../tests/tv3_review_results.json) kiểm tra RA/Q_d/VIEW, ca biên, E1/B09, role mới/có sẵn và quyền SET ROLE/đăng nhập trực tiếp. PostgreSQL17.11, Python3.13.5/macOS arm64, image postgres:17.11 digest `sha256:ff87138949ad9a46f32ff23bd6852b52ce024a13dffe9b4087be98292cdd3b4f` ở lần chạy lịch sử.
- [Log kiểm tra tệp](../tests/week1_verification_log.md) và [manifest](../tests/week1_manifest.json) là kiểm tra tĩnh: **kiểm tra tệp không thay test DB**. Đợt dọn tài liệu không chạy lại PostgreSQL, không gán kết quả agent thành lần chạy của sinh viên.

Tái lập bộ review146 trong container mới, riêng biệt; đợi pg_isready thành công rồi chạy Python (một lần mỗi container):

```sh
docker run --detach --rm --name csdl17-tv3-review --label csdl17.review=tv3 \
  --network none --tmpfs /var/lib/postgresql/data:rw \
  -e POSTGRES_HOST_AUTH_METHOD=trust postgres:17.11
docker exec csdl17-tv3-review pg_isready -U postgres
python3 scripts/review_tv3.py --container csdl17-tv3-review --tv3-root .
docker rm --force csdl17-tv3-review
```

Container không publish cổng, dữ liệu tmpfs; bốn DB review riêng, chỉ nhận nhãn csdl17.review=tv3. Đăng nhập TCP loopback/trust bên trong container chứng minh phân quyền, không chứng minh mật khẩu/TLS. Lệnh Python ghi lại log nên chỉ chạy khi chủ động kiểm chứng, không dùng như kiểm tra tệp chỉ đọc. Không dùng dữ liệu hay DB hiện hữu của nhóm.

<a id="gate1"></a>

## 6. Xác nhận Gate 1 và phần chuyển sang tuần 2

Bảng trạng thái hiện hành dưới đây là nguồn cho script kiểm tra và manifest; các đoạn review ngày 11–13/11 phía trên giữ lịch sử, không dùng để suy ngược trạng thái mới.

| Trường | Giá trị |
|---|---|
| Gate 1 | PASS |
| Phiên bản thiết kế | v1 |
| Ngày tiếp nhận | 16/11/2026 |
| Nguồn xác nhận | Chủ repo xác nhận trong chat ngày 16/11/2026 |
| Thành viên đồng ý | TV1, TV2, TV3 — theo xác nhận chủ repo |

Chủ repo trả lời “có” cho việc cả ba đã đồng ý bộ thiết kế/khóa v1, và “có” cho việc nhóm đã đối chiếu thông báo gốc, yêu cầu, hạn nộp 27/11/2026 tiết 3 và quy cách in hiện ghi trong repo. Ngày 16/11 là ngày tiếp nhận xác nhận, không suy ra đó là ngày nhóm họp. Bản thông báo gốc chưa lưu trong repo; không coi ảnh danh sách nhóm là thông báo yêu cầu. Không tạo chữ ký cá nhân, điểm đánh giá hoặc xác nhận nghiệm thu tuần 2–3.

Sáu mục đã đóng: `W1-T1-01`, `W1-T1-19`, `W1-T1-20`, `W1-T2-14`, `W1-G-03`, `W1-G-04`. Kết quả là **52/53 mục tuần 1 hoàn thành, 1 mục hoãn**; Gate 1 được chốt theo xác nhận thiết kế, phần hoãn được chuyển rõ sang tuần 2.

| Mục hoãn | Thông tin đã biết | Phần cần bổ sung | Tiếp nhận |
|---|---|---|---|
| `W1-T2-01` | Windows, do chủ repo cung cấp 16/11/2026 | Phiên bản PostgreSQL, công cụ quản trị, kết quả kết nối/SELECT version() từ máy TV2 chưa có | `W2-T2-01`, TV2 bổ sung khi sử dụng theo yêu cầu chủ repo |

Lời chủ repo về môi trường: “windows, phiên bản không biết, khi nào dùng thì sửa sau”. Mục này giữ checkbox chưa hoàn thành; không ghi rằng TV2 đã cài/kết nối thành công. [Môi trường chung PostgreSQL17.11](../tests/week1_environment.md) là kết quả kỹ thuật riêng, không gán thành phiên bản trên máy Windows TV2. Luận chứng chuẩn hóa cuối và cơ chế xuyên bảng tiếp tục tuần 2 theo DEC12.

| Gate | Hạn | Sản phẩm và người xác nhận |
|---|---|---|
| G2 | 22/11 | Ràng buộc/transaction, dữ liệu, 10 SQL, 10 RA, B1/B2 và lỗi còn lại có owner/hạn; cả ba xác nhận. |
| G3 | 24/11 | Rebuild DB sạch, đối soát, demo quyền thật, log và ảnh minh chứng. |
| G4 | 26/11 | Báo cáo/PDF/bản in, đánh giá/chữ ký và tập dượt. |
| Nộp | 27/11, tiết 3 | TV1 điều phối; yêu cầu/thời hạn đã được chủ repo xác nhận nhóm đối chiếu ngày16/11. |

Quyền repo kiểm tra 16/11: Linhlss admin, Ngocdeezet write, ninhdn07 write. Chỉ giữ main sau tích hợp; không đếm nhiều nhánh chứa cùng commit thành đóng góp mới. Toàn bộ hồ sơ trước khi gộp có trong [lịch sử tại 12994f1](https://github.com/Linhlss/CSDL-Nh-m-38/tree/12994f106ad9993c0ddf0ff9069bf21268352bd8). Nhật ký giữ kết luận/nguồn và trạng thái; công thức, SQL, dữ liệu, fixture, log gốc và sơ đồ tiếp tục là sản phẩm kỹ thuật chính.


## 7. Kiểm thử ràng buộc nâng cao tuần 2 — 19/11/2026

**Nguồn GitHub Actions PostgreSQL 17:** [lần chạy 80ce1709 thành công](https://github.com/Linhlss/CSDL-Nh-m-38/actions/runs/44533515990). Bài kiểm thử kiểm lần lượt schema, constraints, nạp seed636, ca B06/B08/B09/B10/B11/B14, validation và 10 câu SQL. Log có 20 thông báo PASS trong fixture và 1 PASS ở validation, không có lỗi bất ngờ; dữ liệu test được ROLLBACK. Bản test về sau còn thêm assertion tổng số seed 636 sau rollback nên cần kiểm tra lại ở CI khi cập nhật.

- TV1 đã hoàn thiện mã và test cho W2-T1-04/05/06/07/09/12. Kết quả máy CI là bằng chứng kỹ thuật; không tự nhận thay review của TV2/TV3.
- Việc B15 (đầu vào ngày sinh/ngày lập hộ/tên), chứng minh chuẩn hóa cuối, ảnh demo và Gate 2 ngày 22/11 vẫn chờ thực hiện/duyệt.
- Không thay đổi ERD/7 bảng lõi, lược đồ khóa, 10 câu SQL, 10 RA hoặc seed636; chỉ bổ sung loại constraint/index GiST, trigger, hàm và test.
- [Chi tiết expected/actual và mã SQLSTATE](../tests/week2_constraints_execution_log.md).



## 8. TV1 bàn giao kỹ thuật ngày 20/11/2026 — chờ review chính thức

TV1 hoàn thành bản ứng viên tại nhánh `fix/tv1-integration-gate2`; **không sửa main, không merge PR #5**. [Hồ sơ TV1](../docs/09_ho_so_tv1_gate2.md) trình bày mã, expected/actual, những hạn chế và người review.

**Bằng chứng:** [CI PostgreSQL 17 run 44654667107](https://github.com/Linhlss/CSDL-Nh-m-38/actions/runs/44654667107) — 6 unit parser, 14/14 kiểm tra tệp, 40 trường hợp ràng buộc/rollback, 3 validation và 71 đối soát tích hợp đều PASS. Seed636 không đổi. Lỗi quyền ở B1/B2 là kết quả kiểm thử âm mong đợi.

E1: assertion chỉ dùng ở khâu nghiệm thu, chưa chống ghi trùng ngay lúc INSERT. B15: CHECK và trigger trên hai chiều ghi dữ liệu. S04: 47–50; S14b: bẫy COUNT DISTINCT tạm trên fixture và rollback, không thay đổi seed.

**Đề xuất TV1 về 3NF:** giữ `ngay_bien_dong` là dư thừa có kiểm soát bởi trigger B09; không khẳng định 7 bảng đều tuyệt đối 3NF theo mọi phụ thuộc hàm có điều kiện. Cần TV2/TV3 review. Gate 2 cả nhóm, môi trường Windows TV2, hình chứng minh và báo cáo nộp cuối vẫn chờ nghiệm thu.

**Cập nhật trạng thái mục 8 (20/11/2026):** PR #5 **đã đóng, không merge**. Nội dung cần thiết của PR #5 nằm trong PR #7.

<a id="issue9"></a>

## 9. Tích hợp PR #8 và xử lý X01–X07 — TV1, 20/11/2026 (Issue #9)

**Trạng thái:** đây là quyết định kỹ thuật do TV1 đề xuất, **chưa phải Gate 2 của cả nhóm**. Không có chữ ký hay review thay TV2/TV3.

**Tích hợp:**
- PR #8 (`tv3/gate2-w2-t3` @ `432600e`) có base là nhánh PR #7. Nhánh này là hậu duệ trực tiếp của `52eb8d9`, nên được gộp vào `fix/tv1-integration-gate2` bằng `git merge --ff-only`: không xung đột, không force-push, không merge thẳng vào `main`.
- PR #6 (TV2 → `main`) không bị đụng tới. Sau khi PR #7 vào `main`, TV2 cần cập nhật nhánh và ghi lại manifest (T3-07).

**Các quyết định:**

| ID | Quyết định | Người đề xuất / đồng ý | Chờ |
|---|---|---|---|
| X01 | Phương án (b): `tai_khoan.vai_tro` chỉ là thuộc tính mô tả và không thực thi quyền ghi; quyền thật do role PostgreSQL thực thi. Giữ nguyên seed636 (13/63 sự kiện do `THONG_KE` ghi, 11/63 do `QUAN_TRI` ghi) và công bố là giới hạn. Không sửa seed, expected hay hash | TV1 đề xuất; TV3 nghiêng về (b) trong W3-T3-08 | **TV2 xác nhận** |
| X02 | Chấp nhận `REVOKE DELETE` (B12) và việc đưa `05_security.sql` vào `week2_evolved`. Phần kiểm chứng bù cho điều này là catalog C15 và K01–K05, chạy trong CI | TV3 sửa; TV1 đã review | — |
| X03 | Từ điển dữ liệu: các câu "chưa có trigger/B06" chỉ mang nghĩa tuần 1. Chuẩn hóa: 3NF có điều kiện, không khẳng định tuyệt đối | TV1; TV3 đồng ý về `ngay_bien_dong` | TV2 review |
| X04 | Phụ đề ERD là "Thiết kế v1 — Gate 1 PASS 16/11/2026"; ảnh được sinh lại từ nguồn | TV1 | — |
| X05 | Cho phép ghi nhận trước biến động có hiệu lực trong tương lai; `thoi_diem_ghi` khác `ngay_bien_dong` | TV1 | — |
| X06 | Ngày sinh hoặc ngày lập hộ ở tương lai khi chưa có đợt nằm ngoài phạm vi B15; không thêm ràng buộc phụ thuộc `CURRENT_DATE` | TV1 | — |
| X07 | Giữ E1 là assertion. Test âm được gia cố để chứng minh INSERT trùng đã được ghi trước khi assertion báo lỗi | TV1 | — |

**Bằng chứng:** [log kiểm thử từ DB trắng](../tests/week2_tv1_integration_log.md) và CI trên commit tích hợp cuối, liên kết ghi trong log.


<a id="gate2"></a>
## 10. Chốt Gate 2 — 20/11/2026 (xác nhận do TV1 báo lại từ nhóm)

| Trường | Giá trị / phạm vi |
|---|---|
| **Gate 2** | **PASS — phần kỹ thuật và nội dung sáu chương** |
| Ngày tiếp nhận xác nhận | **20/11/2026** (ngày chủ repo thông báo trong cuộc trò chuyện; không suy diễn ngày/giờ họp) |
| TV1, TV2, TV3 | **Theo TV1, cả ba đã đồng ý bản tích hợp**. Chưa có review riêng trực tiếp của TV2/TV3 trên GitHub; đây là **xác nhận gián tiếp từ trưởng nhóm**, không phải chữ ký hoặc comment cá nhân của hai người. |
| X01 | **Chọn (b)**: `tai_khoan.vai_tro` chỉ mang tính mô tả; quyền ghi thực tế do PostgreSQL role. **Giữ nguyên seed636**, gồm 13/63 sự kiện gắn `THONG_KE`; không đổi QSQL10/expected. Đây là giới hạn được công bố, không khẳng định kiểm soát vai trò nghiệp vụ. |
| Phần được duyệt | 7 bảng/ERD, B06–B15 và E1; dữ liệu seed636; Chương 1–6 (Chương 3.5/5 của TV2, Chương 4/6 của TV3); 10 SQL, 10 RA và QRA07 phép chia; 2 demo bảo mật B1/B2 và B12. |
| Bằng chứng thực thi trước khi chốt | [CI push](https://github.com/Linhlss/CSDL-Nh-m-38/actions/runs/44670909035), [CI PR](https://github.com/Linhlss/CSDL-Nh-m-38/actions/runs/44670911673) trên `4bf6e738`: PASS; 40 ca ràng buộc, 3 validation, 71 đối soát, S01–S16 18/18, catalog 15/15, reader 12/12, report 10/10. |
| Việc chưa nằm trong Gate 2 | 10 ảnh SQL, ảnh B1/B2, bản PDF chính thức, review hình thức, môi trường Windows TV2, nguồn giáo trình, xếp loại/chữ ký và nghiệm thu Gate 3/4. Người phụ trách và hạn nằm trong `docs/10_ban_giao_tv2_tv3.md`. |

**Quy tắc lưu vết:** Đây là ghi nhận lời xác nhận của trưởng nhóm, **không mạo danh review của TV2/TV3**. Khi có xác nhận trực tiếp trên PR, có thể bổ sung liên kết. Các log tuần 1 và các trạng thái "chờ review" trong phần nhật ký lịch sử trước ngày chốt được giữ lại để truy vết. Sau khi merge PR #7 lên `main`, phải chạy CI lại trên commit `main` thực tế. Không đánh dấu Gate 3/4 hoặc nộp báo cáo hoàn thành.

## 11. Sửa X07: E1 chuyển thành UNIQUE — TV3 đề xuất, 24/11/2026 (chờ TV1 xác nhận)

| Trường | Nội dung |
|---|---|
| Thay đổi | Thêm `uq_bd_qua_trinh_cu UNIQUE (ma_qua_trinh_cu)` và `uq_bd_qua_trinh_moi UNIQUE (ma_qua_trinh_moi)` vào `sql/02_constraints.sql` (khối `DO`, chạy lại được). `01_schema.sql` không đổi nên hợp đồng DDL tuần 1 giữ nguyên. `fn_assert_e1` vẫn giữ cho bước validation. |
| Thay cho | Quyết định X07 ở mục 9 (E1 chỉ là assertion, không chặn INSERT tức thì). |
| Lý do | Chặn ngay lúc ghi việc một đợt bị dùng lại trong cùng vai trò, thay vì chỉ phát hiện ở validation. Mỗi mã đợt khác NULL chỉ có ở một dòng của `bien_dong_cu_tru`, nên phụ thuộc mã đợt → ngày biến động không còn gây lặp giữa các dòng; phần lặp còn lại là giữa hai bảng, do trigger B09 kiểm soát. |
| Test | Hai test âm E1 trong `tests/constraints_week2.sql` đổi kỳ vọng: INSERT trùng phải bị từ chối `23505` với đúng tên ràng buộc. Thêm ca 7 vào `tests/report_bang_thu_rang_buoc.sql` (dùng lại đợt cũ 16 → `23505`, `uq_bd_qua_trinh_cu`). |
| Kết quả chạy lại (TV3, PostgreSQL 17.11, Windows, hai DB tạo mới) | Seed636 nạp được; 06_validation PASS (B06/B08/B09, E1, B15); toàn bộ `[PASS]` của `constraints_week2.sql` gồm E1_CU, E1_MOI 23505; B1/B2 đúng 6 lệnh bị từ chối; S01–S16 18/18; `verify_gate2_integration.py` 71 PASS; catalog 15/15; B12 K01–K05; report SQL/RA 0 FAIL; CURRENT_DATE 7/7. Chưa chạy bước đăng nhập TCP bằng mật khẩu tạm ở máy local (không liên quan UNIQUE); CI trên PR sẽ chạy bước này. |
| Báo cáo / slide | Chương 3 mục 3.4–3.5 (kết luận 3NF, ràng buộc E1, bỏ hạn chế X07, bảng thử vi phạm thêm ca 7, bảng cấu trúc và listing), Kết luận; slide 11. |
| Trạng thái | **Chờ TV1 xác nhận trên PR.** Không sửa seed, expected hay hash dữ liệu. |
