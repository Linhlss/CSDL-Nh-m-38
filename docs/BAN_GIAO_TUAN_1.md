# BÀN GIAO CHUNG TUẦN 1 — TV1, TV2, TV3

**Ngày hoàn thiện:** 16/11/2026. **Nhóm 38 — lớp 174356 — ThS. Nguyễn Thị Thanh Huyền.** Đề tài17, quản lý cư dân và biến động cư trú mô phỏng.

| Vai trò | Họ tên | MSSV | Phần chính | Dự phòng kỹ thuật |
|---|---|---|---|---|
| TV1 | Dương Ngọc Ninh | 20237469 | Thiết kế, nghiệp vụ, tích hợp | TV3 |
| TV2 | Trần Tuấn Ngọc | 20227064 | Dữ liệu, SQL, kiểm thử | TV1 |
| TV3 | Trần Bùi Tùng Linh | 20227057 | Đại số quan hệ, bảo mật, review | TV2 |

Danh tính/thứ tự TV theo ảnh danh sách và lời nhắn chủ repo (đọc từ dưới lên), lớp/giảng viên do chủ repo cung cấp. Phân công dự phòng là phương án kỹ thuật để bàn giao; không thay chữ ký cá nhân. Tác giả commit/PR giữ nguyên theo GitHub, không suy từ tên tài khoản để đảo thứ tự TV đã được chủ repo chốt. Không đưa email trong ảnh vào repo.

## 1. Kết quả kỹ thuật và giới hạn xác nhận

Đã hoàn thiện sản phẩm kỹ thuật tuần 1: nghiệp vụ/C1, ERD/từ điển/chuẩn hóa nháp, hồ sơ TV2 và ma trận10SQL, fixture29, dữ liệu636 sửa B15, review dữ liệu TV3 và kế hoạch S01–S21. Checklist hiện có **46 mục đã đủ sản phẩm/kiểm chứng/review kỹ thuật hỗ trợ**; **7 mục còn chờ nguồn hoặc xác nhận người thật** ở bảng dưới. Không đánh dấu Gate1 chung PASS khi hồ sơ xác nhận chưa đầy đủ.

Kết quả [PostgreSQL tuần 1](../tests/week1_execution_results.json): **96/96 đạt**, gồm95 kiểm tra chức năng và1tái hiện B15 cũ. Tiny29 khớp đáp án tay; seed636 khớp bộ tính Python độc lập; generator tái lập, reload/7sequence, đối soát RA/SQL, VIEW, C1 và quyền/FK/CHECK cơ bản đạt. [Môi trường và cách tái lập](../tests/week1_environment.md). Kiểm tra tệp/manifest là bước riêng, không tự chạy DB hoặc ký thay thành viên.

PR #2 tiếp nhận xác nhận TV3 ngày13/11 đã merge tại `2f46a0f`; PR #3 dữ liệu/hồ sơ TV2 đã merge tại `921b18a`. Review hỗ trợ sau đó do agent theo yêu cầu chủ repo, không giả là cuộc họp hoặc lần chạy trên máy sinh viên.

Quyền repo đã kiểm tra16/11: Linhlss=admin; Ngocdeezet=write; ninhdn07=write. Quy tắc dùng branch/commit, push không force và merge có kiểm chứng được giữ. Schema vẫn7bảng/35cột, không đổi giao diện; v1-candidate chờ đồng ý chung để gọi là v1 được cả nhóm khóa.

## 2. Đối chiếu đủ 53 mã tuần 1

Reviewer kỹ thuật cho các cập nhật hỗ trợ là agent thực hiện theo yêu cầu chủ repo; xác nhận thật của tác giả TV3 giữ trong PR #2 và phiếu review. Mỗi dòng dẫn tới sản phẩm hoặc bằng chứng, không đếm nhánh trùng như đóng góp mới.

| Mã | Người phụ trách | Nội dung | Sản phẩm / bằng chứng | Trạng thái |
|---|---|---|---|---|
| W1-T1-01 | TV1 | 10/11 · Xác nhận đầu vào | [01_de_cuong.md](../docs/01_de_cuong.md); [03_dac_ta_nghiep_vu.md](../docs/03_dac_ta_nghiep_vu.md) | Chờ đối chiếu thông báo gốc; đề cương và phạm vi đã có |
| W1-T1-02 | TV1 | 10/11 · Chốt thuật ngữ | [03_dac_ta_nghiep_vu.md](../docs/03_dac_ta_nghiep_vu.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-03 | TV1 | 10–11/11 · Mô tả bối cảnh và tác nhân | [03_dac_ta_nghiep_vu.md](../docs/03_dac_ta_nghiep_vu.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-04 | TV1 | 11/11 · Đặc tả P1–P6 | [03_dac_ta_nghiep_vu.md](../docs/03_dac_ta_nghiep_vu.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-05 | TV1 | 11/11 · Quy tắc nghiệp vụ 1–N | [03_dac_ta_nghiep_vu.md](../docs/03_dac_ta_nghiep_vu.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-06 | TV1 | 11–12/11 · Quy tắc thời gian | [03_dac_ta_nghiep_vu.md](../docs/03_dac_ta_nghiep_vu.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-07 | TV1 | 11–12/11 · Quy tắc biến động | [03_dac_ta_nghiep_vu.md](../docs/03_dac_ta_nghiep_vu.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T1-08 | TV1 | 12/11 · Vẽ cây chức năng | [phan_ra_chuc_nang.png](../diagrams/phan_ra_chuc_nang.png); [REVIEW_TV3_ERD_TUAN_1.md](../docs/REVIEW_TV3_ERD_TUAN_1.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
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
| W1-T1-19 | TV1 | 15/11 · Tổ chức Gate 1 | [decision_log.md](../meetings/decision_log.md) | Hồ sơ họp đã chuẩn bị; chờ biên bản/xác nhận thực tế |
| W1-T1-20 | TV1 | 15/11 · Phát hành schema v1 | [BAN_GIAO_TV1_TUAN_1.md](../docs/BAN_GIAO_TV1_TUAN_1.md) | Bộ v1-candidate sẵn sàng; chờ đồng ý chung để khóa v1 |
| W1-T2-01 | TV2 | 10–11/11 · Thiết lập máy | [week1_environment.md](../tests/week1_environment.md); [week1_execution_results.json](../tests/week1_execution_results.json) | Môi trường chung đã đạt; chờ xác nhận máy cá nhân TV2 |
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
| W1-T2-13 | TV2 | 14/11 · Review ERD với TV1 | [05_ke_hoach_du_lieu_va_sql.md](../docs/05_ke_hoach_du_lieu_va_sql.md); [REVIEW_DU_LIEU_TV2_TUAN_1.md](../docs/REVIEW_DU_LIEU_TV2_TUAN_1.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T2-14 | TV2 | 15/11 · Bàn giao kế hoạch | [05_ke_hoach_du_lieu_va_sql.md](../docs/05_ke_hoach_du_lieu_va_sql.md) | Đủ bộ bàn giao; chờ xác nhận cá nhân TV2/Gate1 |
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
| W1-T3-12 | TV3 | 14/11 · Review ERD độc lập | [REVIEW_TV3_ERD_TUAN_1.md](../docs/REVIEW_TV3_ERD_TUAN_1.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T3-13 | TV3 | 14–15/11 · Review test dữ liệu TV2 | [REVIEW_DU_LIEU_TV2_TUAN_1.md](../docs/REVIEW_DU_LIEU_TV2_TUAN_1.md); [week1_execution_results.json](../tests/week1_execution_results.json) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-T3-14 | TV3 | 15/11 · Bàn giao đặc tả | [06a_dai_so_quan_he.md](../docs/06a_dai_so_quan_he.md); [06b_bao_mat.md](../docs/06b_bao_mat.md); [REVIEW_TV3_ERD_TUAN_1.md](../docs/REVIEW_TV3_ERD_TUAN_1.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-G-01 | Cả nhóm | G0 | [02_bao_cao_suon.md](../docs/02_bao_cao_suon.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-G-02 | Cả nhóm |  | [README.md](../README.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |
| W1-G-03 | Cả nhóm |  | [week1_execution_results.json](../tests/week1_execution_results.json); [decision_log.md](../meetings/decision_log.md) | Đối soát kỹ thuật đạt; chờ xác nhận cuộc review chung |
| W1-G-04 | Cả nhóm |  | [decision_log.md](../meetings/decision_log.md) | Biên bản kỹ thuật sẵn sàng; chờ phê duyệt Gate1 thật |
| W1-G-05 | Cả nhóm |  | [BAN_GIAO_TV1_TUAN_1.md](../docs/BAN_GIAO_TV1_TUAN_1.md); [05_ke_hoach_du_lieu_va_sql.md](../docs/05_ke_hoach_du_lieu_va_sql.md) | Đạt sản phẩm và review kỹ thuật hỗ trợ |

## 3. Các phần cần nguồn/xác nhận thật

- Thông báo yêu cầu gốc chưa được lưu để đối chiếu trực tiếp; ảnh danh sách nhóm chỉ chứng minh danh tính/nhóm/đề tài.
- OS/công cụ/SELECT version từ máy cá nhân TV2 chưa có trong repo. Kết quả Docker chung đã có, ghi đúng người thực hiện.
- Cuộc họp hoặc xác nhận chung, ngày/người phê duyệt và khóa schema v1 cần biên bản thật. Không điền giả lời đồng ý, điểm đánh giá hoặc chữ ký.

## 4. Bước tiếp theo đúng tuần 2–3

TV1 thực thi chống chồng lấn, ràng buộc xuyên bảng/transaction và chốt luận chứng chuẩn hóa; TV2/TV3 tiếp tục nghiệm thu seed/SQL/RA cuối, ảnh và Chương3.5/4/5/6; TV1 tích hợp báo cáo và nộp. S17–S19 đã thử FK/CHECK cơ bản, chưa là bằng chứng trigger nâng cao đã làm. Giữ nguyên30mã D01–D30 và142mã toàn dự án. Không dùng kết quả tuần 1 để đánh dấu tuần 2–3 hoàn thành.
