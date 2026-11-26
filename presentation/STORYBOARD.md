# Storyboard thuyết trình đề tài 17

Hai trang nhận diện HUST đứng trước bìa và trước khi bắt đầu tính giờ. Khung 20 phút gồm 20 slide nội dung và ba trang phân phần. Mười phụ lục dùng khi hỏi đáp.

| Trang PDF | Mục | Tiêu đề | Thông điệp | Thành phần hình ảnh | Người nói | Thời lượng / lũy kế | Nguồn chính |
|---:|---|---|---|---|---|---|---|
| 3 | 01 | Cơ sở dữ liệu quản lý cư dân và biến động cư trú | Giới thiệu đề tài 17 của nhóm 38 và ba phần trình bày. | Bìa HUST, tên đề tài và danh sách nhóm | TV1 | 25 giây / 00:25 | `Báo_cáo_CSDL_nhóm_38/00_bia.tex` |
| 4 | Phần 1 | Bài toán và thiết kế CSDL | Mở đầu phần trình bày của Trần Bùi Tùng Linh. | Bố cục HUST xanh trái, số phần và chủ đề bên phải | Trần Bùi Tùng Linh (TV1) | 5 giây / 00:30 | `Slide/HUST_PPT_template_2022_Blue_16x9.pptx` |
| 5 | 02 | Bài toán quản lý cư trú tại phường | Một lần chuyển hộ đặt ra ba câu hỏi về nơi ở hiện tại, lịch sử và người ghi nhận. | Một tình huống chuyển hộ và ba câu hỏi nghiệp vụ | TV1 | 45 giây / 01:15 | `Báo_cáo_CSDL_nhóm_38/chuong1.tex` |
| 6 | 03 | Phạm vi và cách lưu dữ liệu | Giữ cả hai đợt theo thời gian và liên kết chúng bằng một biến động. | Sơ đồ hai đợt và một biến động | TV1 | 40 giây / 01:55 | `Báo_cáo_CSDL_nhóm_38/chuong1.tex` |
| 7 | 04 | Sơ đồ phân rã chức năng | Sáu nhóm bao phủ 14 chức năng cấp 2. | Sơ đồ phân rã của báo cáo, toàn chiều rộng | TV1 | 65 giây / 03:00 | `Báo_cáo_CSDL_nhóm_38/chuong1.tex` |
| 8 | 05 | Bảy thực thể của mô hình | Quá trình cư trú nối cư dân với hộ theo khoảng thời gian. | Hai nhóm thực thể và chuỗi nối người, đợt, hộ | TV1 | 40 giây / 03:40 | `Báo_cáo_CSDL_nhóm_38/chuong2.tex` |
| 9 | 06 | Sơ đồ thực thể liên kết | Năm liên kết 1–N và hai liên kết 1–1 đợt cũ, đợt mới. | Ảnh ERD Chen gốc, kèm ba điểm dẫn khi thuyết trình | TV1 | 85 giây / 05:05 | `Báo_cáo_CSDL_nhóm_38/chuong2.tex` |
| 10 | 07 | Từ liên kết đến khóa ngoại | FK nằm ở bảng phía N; hai FK về đợt có thêm UNIQUE cho liên kết 1–1. | Ảnh lược đồ 7 bảng và chú giải khóa | TV1 | 55 giây / 06:00 | `Báo_cáo_CSDL_nhóm_38/chuong3.tex` |
| 11 | 08 | Chuẩn hóa và dữ liệu lịch sử | Tách dữ liệu theo phụ thuộc hàm, giữ ngày biến động với ràng buộc B09. | Đối chiếu bảng gộp và bốn bảng tách | TV1 | 45 giây / 06:45 | `Báo_cáo_CSDL_nhóm_38/chuong3.tex` |
| 12 | 09 | Ba ràng buộc chi phối một lần chuyển | PostgreSQL kiểm tra thời gian và giữ ba bước chuyển nội bộ trong một giao dịch. | Ba sơ đồ nhỏ về B06, B09 và B10 | TV1 | 55 giây / 07:40 | `Báo_cáo_CSDL_nhóm_38/chuong3.tex` |
| 13 | Phần 2 | Dữ liệu, SQL và kiểm thử | Mở đầu phần trình bày của Trần Tuấn Ngọc. | Bố cục HUST xanh trái, số phần và chủ đề bên phải | Trần Tuấn Ngọc (TV2) | 5 giây / 07:45 | `Slide/HUST_PPT_template_2022_Blue_16x9.pptx` |
| 14 | 10 | 636 bản ghi kiểm thử | Bộ dữ liệu nạp đủ cả bảy bảng để kiểm chứng. | Bảng gốc theo từng bảng và tổng 636 | TV2 | 20 giây / 08:05 | `sql/03_seed.sql` |
| 15 | 11 | Danh mục QSQL01–QSQL10 | Mười câu trong báo cáo theo đúng thứ tự của bộ ảnh thực thi. | Hai cột, mỗi cột năm câu và kỹ thuật chính | TV2 | 40 giây / 08:45 | `Báo_cáo_CSDL_nhóm_38/chuong5.tex` |
| 16 | 12 | QSQL03 · Thống kê cư trú theo tổ | LEFT JOIN giữ tổ trống, COUNT DISTINCT đếm mỗi cư dân một lần trong tổ. | Đoạn điều kiện ON và bảng kết quả đủ 8 tổ | TV2 | 95 giây / 10:20 | `Báo_cáo_CSDL_nhóm_38/chuong5.tex` |
| 17 | 13 | QSQL09 · Chuyển nội bộ giữa hai tổ | Lọc các lần chuyển nội bộ của cùng cư dân mà tổ cũ khác tổ mới. | Sơ đồ các bảng cần nối, điều kiện lọc và ba dòng đầu | TV2 | 100 giây / 12:00 | `Báo_cáo_CSDL_nhóm_38/chuong5.tex` |
| 18 | 14 | Kiểm thử dữ liệu và truy vấn SQL | Mười truy vấn khớp toàn bộ kết quả đối chiếu trên dữ liệu dựng mới. | Kết quả kiểm tra dữ liệu và ba trường hợp nghiệp vụ | TV2 | 35 giây / 12:35 | `Báo_cáo_CSDL_nhóm_38/chuong3.tex` |
| 19 | Phần 3 | Đại số quan hệ và bảo mật | Mở đầu phần trình bày của Dương Ngọc Ninh. | Bố cục HUST xanh trái, số phần và chủ đề bên phải | Dương Ngọc Ninh (TV3) | 5 giây / 12:40 | `Slide/HUST_PPT_template_2022_Blue_16x9.pptx` |
| 20 | 15 | Mười câu đại số quan hệ | Danh mục đúng thứ tự Chương 4, với phép chia ở câu 9. | Hai cột, mỗi cột năm câu và ký hiệu phép chính | TV3 | 40 giây / 13:20 | `Báo_cáo_CSDL_nhóm_38/chuong4.tex` |
| 21 | 16 | RA 3 · Thường trú tại Tổ 01 | Lọc đợt còn hiệu lực, nối hộ theo tổ rồi chiếu mã và tên. | Biểu thức theo bước và đầu ra kiểm chứng | TV3 | 90 giây / 14:50 | `Báo_cáo_CSDL_nhóm_38/chuong4.tex` |
| 22 | 17 | RA 9 · Tài khoản ghi đủ loại biến động | Phép chia trả tập tài khoản có đủ mọi loại xuất hiện trong dữ liệu. | Biểu thức chia và ma trận tài khoản × loại | TV3 | 105 giây / 16:35 | `Báo_cáo_CSDL_nhóm_38/chuong4.tex` |
| 23 | 18 | B1 · Phân quyền bằng PostgreSQL role | Reader đếm được 200 cư dân. PostgreSQL từ chối ghi và đọc bảng tài khoản. | Hai ảnh phiên đăng nhập trực tiếp bằng reader | TV3 | 95 giây / 18:10 | `Báo_cáo_CSDL_nhóm_38/chuong6.tex` |
| 24 | 19 | B2 · Báo cáo qua VIEW tổng hợp | Role báo cáo đọc được VIEW theo tổ. PostgreSQL từ chối đọc trực tiếp hai bảng gốc. | Hai ảnh phiên đăng nhập trực tiếp bằng report | TV3 | 85 giây / 19:35 | `Báo_cáo_CSDL_nhóm_38/chuong6.tex` |
| 25 | 20 | Kết luận và cảm ơn | Nhóm đã dựng mô hình, truy vấn và kiểm chứng trên cùng CSDL. | Layout kết thúc HUST và ba kết quả | TV3 | 25 giây / 20:00 | `Báo_cáo_CSDL_nhóm_38/ketluan.tex` |
| 26 | A01 | Danh mục 10 câu đại số quan hệ | Đề bài, phép toán chính và số bộ minh họa. | Bảng 10 dòng chỉnh sửa được | TV3 | Hỏi đáp | `Báo_cáo_CSDL_nhóm_38/chuong4.tex` |
| 27 | A02 | RA 3 · Các bước trung gian | Giữ đủ bốn biểu thức như Chương 4 và nêu lược đồ Q_ht. | Công thức và lược đồ đầu vào đọc ngang | TV3 | Hỏi đáp | `Báo_cáo_CSDL_nhóm_38/chuong4.tex` |
| 28 | A03 | RA 9 · Ngữ nghĩa phép chia | Chứng minh điều kiện với mọi loại và nêu trường hợp miền loại cố định. | Hai quan hệ chiếu, công thức và tập trả về | TV3 | Hỏi đáp | `Báo_cáo_CSDL_nhóm_38/chuong4.tex` |
| 29 | A04 | RA 4–6 · Hiệu, giao và hợp | Ba phép tập hợp theo mã cư dân hoặc mã biến động. | Ba biểu thức rút gọn cùng cách đặt tập trung gian | TV3 | Hỏi đáp | `Báo_cáo_CSDL_nhóm_38/chuong4.tex` |
| 30 | A05 | Danh mục QSQL01–QSQL10 | Mã câu, nội dung, kỹ thuật và số dòng trên bộ 636 bản ghi. | Bảng 10 dòng chỉnh sửa được | TV2 | Hỏi đáp | `Báo_cáo_CSDL_nhóm_38/chuong5.tex` |
| 31 | A06 | QSQL03 · Truy vấn đầy đủ | Điều kiện hiệu lực nằm trong ON để giữ tổ không có người. | SQL nguyên văn và bảng đủ 8 tổ | TV2 | Hỏi đáp | `Báo_cáo_CSDL_nhóm_38/chuong5.tex` |
| 32 | A07 | QSQL09 · Truy vấn đầy đủ | Hai nhánh nối lấy mã tổ cũ và mã tổ mới từ địa chỉ. | SQL nguyên văn và 3 dòng đầu của 22 kết quả | TV2 | Hỏi đáp | `Báo_cáo_CSDL_nhóm_38/chuong5.tex` |
| 33 | A08 | B06, B09 và B10 · Các ca kiểm tra | Phân biệt ràng buộc loại trừ, trigger và hoàn tác trong giao dịch. | Bảng cơ chế, ca lỗi và SQLSTATE | TV1 | Hỏi đáp | `sql/02_constraints.sql` |
| 34 | A09 | B1/B2 · Ma trận quyền và đăng nhập | Kết quả catalog và phiên đăng nhập độc lập chứng thực phạm vi quyền. | Ma trận quyền và kết quả thật, trích log dạng văn bản | TV3 | Hỏi đáp | `Báo_cáo_CSDL_nhóm_38/chuong6.tex` |
| 35 | A10 | Seed, kết quả và hướng mở rộng | Phạm vi kiểm chứng, minh họa phòng ngừa injection và giới hạn kỹ thuật. | Bảng số bản ghi, bằng chứng B3 và giới hạn | TV1 / TV3 | Hỏi đáp | `Báo_cáo_CSDL_nhóm_38/chuong6.tex` |
| 36 | A11 | B09 · Trigger kiểm tra ngày chuyển | Đợt cũ kết thúc ngày t − 1, đợt mới bắt đầu ngày t. | Mã kiểm tra ngày và bảng hai chiều trigger | TV1 / TV3 | Hỏi đáp | `sql/02_constraints.sql` |
