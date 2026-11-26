# Nguồn nội dung theo slide

Hai trang nhận diện và ba trang phân phần dùng bố cục gốc của mẫu PowerPoint HUST. Nội dung chuyên môn dựa trên báo cáo LaTeX hiện hành. Phép chia dùng RA 9 của báo cáo. Phần SQL theo mã QSQL01–QSQL13 (mười câu chính và ba câu bổ sung). Hai câu trình bày chính là QSQL03 và QSQL09.

| Mục | Nội dung đối chiếu | Nguồn | Trạng thái |
|---|---|---|---|
| 01 | Giới thiệu đề tài 17 của nhóm 38 và ba phần trình bày. | `Báo_cáo_CSDL_nhóm_38/00_bia.tex`, `README.md` | Đối chiếu báo cáo và nguồn thiết kế |
| Phần 1 | Mở đầu phần trình bày của Trần Bùi Tùng Linh. | `Slide/HUST_PPT_template_2022_Blue_16x9.pptx` | Bố cục gốc trong mẫu HUST |
| 02 | Một lần chuyển hộ đặt ra ba câu hỏi về nơi ở hiện tại, lịch sử và người ghi nhận. | `Báo_cáo_CSDL_nhóm_38/chuong1.tex`, `docs/03_dac_ta_nghiep_vu.md` | Đối chiếu báo cáo và nguồn thiết kế |
| 03 | Giữ cả hai đợt theo thời gian và liên kết chúng bằng một biến động. | `Báo_cáo_CSDL_nhóm_38/chuong1.tex`, `Báo_cáo_CSDL_nhóm_38/loimodau.tex` | Đối chiếu báo cáo và nguồn thiết kế |
| 04 | Sáu nhóm bao phủ 14 chức năng cấp 2. | `Báo_cáo_CSDL_nhóm_38/chuong1.tex`, `Báo_cáo_CSDL_nhóm_38/image/phan_ra_chuc_nang.png` | Đối chiếu báo cáo và nguồn thiết kế |
| 05 | Quá trình cư trú nối cư dân với hộ theo khoảng thời gian. | `Báo_cáo_CSDL_nhóm_38/chuong2.tex`, `sql/01_schema.sql` | Đối chiếu báo cáo và nguồn thiết kế |
| 06 | Năm liên kết 1–N và hai liên kết 1–1 đợt cũ, đợt mới. | `Báo_cáo_CSDL_nhóm_38/chuong2.tex`, `erd.png`, `docs/03_dac_ta_nghiep_vu.md` | Đối chiếu báo cáo và nguồn thiết kế |
| 07 | FK nằm ở bảng phía N; hai FK về đợt có thêm UNIQUE cho liên kết 1–1. | `Báo_cáo_CSDL_nhóm_38/chuong3.tex`, `diagrams/erd_v1.png`, `sql/01_schema.sql` | Đối chiếu báo cáo và nguồn thiết kế |
| 08 | Tách dữ liệu theo phụ thuộc hàm, giữ ngày biến động với ràng buộc B09. | `Báo_cáo_CSDL_nhóm_38/chuong3.tex`, `docs/04_data_dictionary_va_chuan_hoa.md` | Đối chiếu báo cáo và nguồn thiết kế |
| 09 | PostgreSQL kiểm tra thời gian; ba hàm chuyển nội bộ, chuyển đi, chuyển đến giữ mỗi lần chuyển trong một giao dịch. | `Báo_cáo_CSDL_nhóm_38/chuong3.tex`, `sql/02_constraints.sql`, `tests/constraints_week2.sql`, `tests/week2_tv1_integration_log.md` | Đối chiếu log PostgreSQL và báo cáo |
| Phần 2 | Mở đầu phần trình bày của Trần Tuấn Ngọc. | `Slide/HUST_PPT_template_2022_Blue_16x9.pptx` | Bố cục gốc trong mẫu HUST |
| 10 | Bộ dữ liệu nạp đủ cả bảy bảng để kiểm chứng. | `sql/03_seed.sql`, `tests/final_test_log.md` | Đối chiếu log PostgreSQL và báo cáo |
| 11 | Mười câu chính theo thứ tự bộ ảnh thực thi, thêm ba câu bổ sung QSQL11–13. | `Báo_cáo_CSDL_nhóm_38/chuong5.tex`, `sql/04_queries.sql`, `sql/07_queries_bo_sung.sql`, `tests/final_test_log.md` | Đối chiếu log PostgreSQL và báo cáo |
| 12 | LEFT JOIN giữ tổ trống, COUNT DISTINCT đếm mỗi cư dân một lần trong tổ. | `Báo_cáo_CSDL_nhóm_38/chuong5.tex`, `sql/04_queries.sql`, `tests/week1_execution_results.json`, `tests/final_test_log.md` | Đối chiếu log PostgreSQL và báo cáo |
| 13 | Lọc các lần chuyển nội bộ của cùng cư dân mà tổ cũ khác tổ mới. | `Báo_cáo_CSDL_nhóm_38/chuong5.tex`, `sql/04_queries.sql`, `tests/week1_execution_results.json`, `tests/final_test_log.md` | Đối chiếu log PostgreSQL và báo cáo |
| 14 | Mười ba truy vấn khớp toàn bộ kết quả đối chiếu trên dữ liệu dựng mới. | `Báo_cáo_CSDL_nhóm_38/chuong3.tex`, `Báo_cáo_CSDL_nhóm_38/chuong5.tex`, `tests/final_test_log.md` | Đối chiếu log PostgreSQL và báo cáo |
| Phần 3 | Mở đầu phần trình bày của Dương Ngọc Ninh. | `Slide/HUST_PPT_template_2022_Blue_16x9.pptx` | Bố cục gốc trong mẫu HUST |
| 15 | Danh mục đúng thứ tự Chương 4, với phép chia ở câu 9. | `Báo_cáo_CSDL_nhóm_38/chuong4.tex`, `tests/report_ra_01_10.sql`, `tests/report_current_date_log.txt` | Danh mục đối chiếu với LaTeX và bảng đối chiếu Chương 4. |
| 16 | Lọc đợt còn hiệu lực, nối hộ theo tổ rồi chiếu mã và tên. | `Báo_cáo_CSDL_nhóm_38/chuong4.tex`, `tests/report_ra_01_10.sql`, `tests/report_current_date_log.txt` | Đối chiếu log PostgreSQL và báo cáo |
| 17 | Phép chia trả tập tài khoản có đủ mọi loại xuất hiện trong dữ liệu. | `Báo_cáo_CSDL_nhóm_38/chuong4.tex`, `tests/report_ra_01_10.sql`, `tests/report_current_date_log.txt` | Đối chiếu log PostgreSQL và báo cáo |
| 18 | Reader đếm được 200 cư dân. PostgreSQL từ chối ghi và đọc bảng tài khoản. | `Báo_cáo_CSDL_nhóm_38/chuong6.tex`, `Báo_cáo_CSDL_nhóm_38/image/security/SEC_B1_select_ok.png`, `Báo_cáo_CSDL_nhóm_38/image/security/SEC_B1_denied.png`, `tests/security_login_tv3.sql`, `tests/report_security_repo_tests_log.txt` | Đối chiếu log PostgreSQL và báo cáo |
| 19 | Role báo cáo đọc được VIEW theo tổ. PostgreSQL từ chối đọc trực tiếp hai bảng gốc. | `Báo_cáo_CSDL_nhóm_38/chuong6.tex`, `Báo_cáo_CSDL_nhóm_38/image/security/SEC_B2_view_ok.png`, `Báo_cáo_CSDL_nhóm_38/image/security/SEC_B2_denied.png`, `Báo_cáo_CSDL_nhóm_38/image/security/SEC_B2_viewdef.png`, `tests/report_current_date_log.txt` | Đối chiếu log PostgreSQL và báo cáo |
| 20 | Nhóm đã dựng mô hình, truy vấn và kiểm chứng trên cùng CSDL. | `Báo_cáo_CSDL_nhóm_38/ketluan.tex`, `tests/report_current_date_log.txt` | Đối chiếu log PostgreSQL và báo cáo |
| A01 | Đề bài, phép toán chính và số bộ minh họa. | `Báo_cáo_CSDL_nhóm_38/chuong4.tex`, `tests/report_current_date_log.txt` | Danh mục đối chiếu với LaTeX và bảng đối chiếu Chương 4. |
| A02 | Giữ đủ bốn biểu thức như Chương 4 và nêu lược đồ Q_ht. | `Báo_cáo_CSDL_nhóm_38/chuong4.tex`, `tests/report_ra_01_10.sql`, `tests/report_current_date_log.txt` | Đối chiếu log PostgreSQL và báo cáo |
| A03 | Chứng minh điều kiện với mọi loại và nêu trường hợp miền loại cố định. | `Báo_cáo_CSDL_nhóm_38/chuong4.tex`, `tests/report_ra_01_10.sql`, `tests/report_current_date_log.txt` | Đối chiếu log PostgreSQL và báo cáo |
| A04 | Ba phép tập hợp theo mã cư dân hoặc mã biến động. | `Báo_cáo_CSDL_nhóm_38/chuong4.tex`, `tests/report_current_date_log.txt` | Đối chiếu log PostgreSQL và báo cáo |
| A05 | Mã câu, nội dung, kỹ thuật và số dòng trên bộ 636 bản ghi. | `Báo_cáo_CSDL_nhóm_38/chuong5.tex`, `sql/04_queries.sql`, `tests/week1_execution_results.json`, `tests/final_test_log.md`, `sql/07_queries_bo_sung.sql`, `tests/report_sql_bo_sung_log.txt` | Đối chiếu log PostgreSQL và báo cáo |
| A06 | Điều kiện hiệu lực nằm trong ON để giữ tổ không có người. | `Báo_cáo_CSDL_nhóm_38/chuong5.tex`, `sql/04_queries.sql`, `tests/week1_execution_results.json`, `tests/final_test_log.md` | Đối chiếu log PostgreSQL và báo cáo |
| A07 | Hai nhánh nối lấy mã tổ cũ và mã tổ mới từ địa chỉ. | `Báo_cáo_CSDL_nhóm_38/chuong5.tex`, `sql/04_queries.sql`, `tests/week1_execution_results.json`, `tests/final_test_log.md` | Đối chiếu log PostgreSQL và báo cáo |
| A08 | Phân biệt ràng buộc loại trừ, trigger, hoàn tác trong giao dịch và UNIQUE của liên kết 1–1. | `sql/02_constraints.sql`, `tests/constraints_week2.sql`, `tests/week2_tv1_integration_log.md`, `tests/report_bang_thu_rang_buoc_log.txt` | Đối chiếu log PostgreSQL và báo cáo |
| A09 | Kết quả catalog và phiên đăng nhập độc lập chứng thực phạm vi quyền. | `Báo_cáo_CSDL_nhóm_38/chuong6.tex`, `sql/05_security.sql`, `tests/report_security_repo_tests_log.txt`, `tests/week2_security_login_log.md`, `tests/week2_tv1_integration_log.md` | Đối chiếu log PostgreSQL và báo cáo |
| A10 | Phạm vi kiểm chứng, minh họa phòng ngừa injection và giới hạn kỹ thuật. | `Báo_cáo_CSDL_nhóm_38/chuong6.tex`, `Báo_cáo_CSDL_nhóm_38/ketluan.tex`, `sql/03_seed.sql`, `tests/final_test_log.md`, `tests/report_current_date_log.txt`, `tests/report_security_ch6_log.txt` | Đối chiếu log PostgreSQL và báo cáo |
| A11 | Đợt cũ kết thúc ngày t − 1, đợt mới bắt đầu ngày t. | `sql/02_constraints.sql`, `Báo_cáo_CSDL_nhóm_38/phuluc.tex`, `tests/report_dml_minh_hoa_log.txt` | Đối chiếu log PostgreSQL và báo cáo |
