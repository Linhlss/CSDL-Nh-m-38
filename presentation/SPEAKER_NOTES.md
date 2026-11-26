# Lời nhắc diễn giả

Hai trang nhận diện HUST đứng trước bìa và trước khi bắt đầu tính giờ. Khung 20 phút gồm 20 slide nội dung và ba trang phân phần. Mười một phụ lục A01–A11 dùng khi hỏi đáp. Ghi chú cũng có trong Notes của PPTX.

## 01 · Cơ sở dữ liệu quản lý cư dân và biến động cư trú

TV1 · 25 giây / 00:25

Em xin chào cô. Nhóm 38 trình bày đề tài 17 về cơ sở dữ liệu quản lý cư dân và biến động cư trú tại một phường. Em là Linh, phụ trách bài toán và thiết kế. Tiếp theo, Ngọc trình bày dữ liệu và SQL, rồi Ninh trình bày đại số quan hệ và bảo mật.

Thao tác (4 giây) · Chào lớp và dừng để người nghe nhìn tên đề tài.

Nguồn `Báo_cáo_CSDL_nhóm_38/00_bia.tex`, `README.md`.

## Phần 1 · Bài toán và thiết kế CSDL

Trần Bùi Tùng Linh (TV1) · 5 giây / 00:30

Em bắt đầu từ một tình huống chuyển hộ.

Nguồn `Slide/HUST_PPT_template_2022_Blue_16x9.pptx`.

## 02 · Bài toán quản lý cư trú tại phường

TV1 · 45 giây / 01:15

Cán bộ phường cần tra cứu cư dân theo hộ và theo dõi khi họ chuyển chỗ ở. Giả sử một cư dân chuyển từ hộ A sang hộ B. Sau lần chuyển, cán bộ cần biết người này đang ở hộ nào, từng ở hộ A trong khoảng nào và ai đã ghi nhận sự kiện. Nếu hồ sơ chỉ có một ô địa chỉ, cập nhật sang hộ B sẽ làm mất thông tin về thời gian ở hộ A. Đây là bài toán quen thuộc. Mục tiêu của bài tập lớn là thiết kế dữ liệu đủ để trả lời các câu hỏi đó và kiểm tra tính nhất quán của lần chuyển.

Thao tác (5 giây) · Dừng ở tình huống chuyển hộ rồi lần lượt chỉ ba thông tin cán bộ cần tra cứu.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong1.tex`, `docs/03_dac_ta_nghiep_vu.md`.

## 03 · Phạm vi và cách lưu dữ liệu

TV1 · 40 giây / 01:55

Phạm vi đề tài là một phường gồm nhiều tổ dân phố, địa chỉ và hộ cư trú. Với lần chuyển vừa nêu, nhóm kết thúc đợt ở hộ A, mở đợt ở hộ B và lưu một biến động liên kết hai đợt, cùng tài khoản và thời điểm ghi. Nhìn ngày của từng đợt, cán bộ có thể tra cứu nơi ở hiện tại hoặc lịch sử. Cách lưu này cũng hỗ trợ thống kê theo tổ. Trong phạm vi học phần, nhóm tập trung vào thiết kế cơ sở dữ liệu, truy vấn và kiểm tra ràng buộc, quyền truy cập trên PostgreSQL 17.

Thao tác (5 giây) · Chỉ lần lượt đợt ở hộ A, biến động và đợt ở hộ B.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong1.tex`, `Báo_cáo_CSDL_nhóm_38/loimodau.tex`.

## 04 · Sơ đồ phân rã chức năng

TV1 · 65 giây / 03:00

Sơ đồ có sáu nhánh lớn và mười bốn ô chức năng trực tiếp bên dưới. Hai nhánh đầu là quản lý địa bàn và quản lý hộ, cư dân. Đây là dữ liệu nền để một đợt cư trú liên kết được người với hộ ở đúng địa chỉ. Nhánh thứ ba mở và kết thúc đợt. Nhánh thứ tư ghi nhận chuyển đến, chuyển đi và chuyển nội bộ. Chuyển nội bộ là ca đáng chú ý vì phải tác động lên cả đợt cũ lẫn đợt mới. Nhánh thứ năm dùng các dữ liệu này để tra cứu hiện tại, lịch sử và thống kê. Cuối cùng, nhóm quản trị xác định phạm vi truy cập của từng vai trò. Các nhánh được thể hiện ở mức dữ liệu và nghiệp vụ. Phần thiết kế tiếp theo làm rõ các đối tượng mà những chức năng đó đọc hay cập nhật.

Thao tác (18 giây) · Dò qua sáu nhánh. Dừng ở ba ô quản lý đợt, biến động, tra cứu.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong1.tex`, `Báo_cáo_CSDL_nhóm_38/image/phan_ra_chuc_nang.png`.

## 05 · Bảy thực thể của mô hình

TV1 · 40 giây / 03:40

Có bảy thực thể. Tổ dân phố, địa chỉ, hộ và cư dân tạo thành nhóm thông tin địa bàn và hồ sơ. Ba thực thể còn lại là quá trình cư trú, biến động cư trú và tài khoản. Hãy nhìn vào quá trình cư trú ở giữa. Một dòng trả lời cư dân nào ở hộ nào, theo diện gì và trong khoảng thời gian nào. Người có nhiều lần đổi chỗ ở có thể có nhiều đợt. Mỗi biến động tham chiếu những đợt có liên quan và tài khoản ghi. Cách tách này cho phép cùng một mô hình phục vụ cả tra cứu hiện tại và lịch sử.

Thao tác (1 giây) · Chỉ hộp Quá trình cư trú.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong2.tex`, `sql/01_schema.sql`.

## 06 · Sơ đồ thực thể liên kết

TV1 · 85 giây / 05:05

Đây là ERD dùng ký hiệu Chen. Hình chữ nhật là thực thể, hình thoi là liên kết và hình elip là thuộc tính. Bắt đầu từ góc trên, một tổ quản lý nhiều địa chỉ và một địa chỉ có thể có nhiều hộ. Về phía cư dân, một người có thể có nhiều đợt. Mỗi đợt gắn đúng một người và một hộ. Vì thế quan hệ nhiều nhiều giữa cư dân với hộ theo thời gian được biểu diễn qua thực thể đợt. Ở góc dưới, biến động nối tới đợt với hai vai trò độc lập. Chuyển đến có đợt mới, chuyển đi có đợt cũ, còn chuyển nội bộ có cả hai và cùng cư dân. Mỗi biến động cũng tham chiếu tài khoản ghi nhận. Điều kiện tài khoản đang hoạt động được xét lúc ghi. Các số một và N trên hình cho biết bản số. Riêng đợt cũ và đợt mới là liên kết một một, vì một đợt chỉ bị một biến động kết thúc và chỉ được một biến động mở. Hai vai trò này sẽ thành hai khóa ngoại riêng trong lược đồ SQL.

Thao tác (25 giây) · Lần theo ba vùng của ERD. Dừng ở hai hình thoi Đợt cũ và Đợt mới.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong2.tex`, `erd.png`, `docs/03_dac_ta_nghiep_vu.md`.

## 07 · Từ liên kết đến khóa ngoại

TV1 · 55 giây / 06:00

Khi ánh xạ một liên kết một nhiều, nhóm đặt khóa ngoại ở bảng phía nhiều. Ví dụ, địa chỉ mang mã tổ và hộ mang mã địa chỉ. Bảng quá trình có khóa riêng và tham chiếu cư dân cùng hộ. Bảng biến động có ba khóa ngoại. Một khóa chỉ người ghi, hai khóa còn lại cùng trỏ bảng quá trình nhưng tên cột khác nhau để chỉ đợt cũ và đợt mới. Hai cột này cho phép NULL tùy loại biến động, và mỗi cột có ràng buộc UNIQUE riêng để giữ liên kết một một. Những khóa ngoại khác là bắt buộc. Lược đồ có bảy bảng, ba mươi lăm cột, bảy khóa chính, bảy khóa ngoại và năm ràng buộc UNIQUE. Cách đặt khóa giúp lần theo từ biến động đến những đợt đã lưu và nơi ở tương ứng.

Thao tác (11 giây) · Chỉ đường tổ, địa chỉ, hộ và hai FK về bảng đợt.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong3.tex`, `diagrams/erd_v1.png`, `sql/01_schema.sql`.

## 08 · Chuẩn hóa và dữ liệu lịch sử

TV1 · 45 giây / 06:45

Nếu gộp họ tên, nơi ở, ngày cư trú và người ghi vào một bảng, họ tên sẽ lặp theo mỗi lần chuyển. Trong lược đồ hiện tại, mã cư dân xác định hồ sơ và mã đợt xác định khoảng thời gian. Cặp mã tổ và địa chỉ chuẩn là khóa ứng viên của địa chỉ. Báo cáo phân tích chuẩn hóa theo các phụ thuộc hàm đã công bố. Ở cả bảy bảng, vế trái của mọi phụ thuộc hàm đều là khóa, nên cả bảy bảng đạt BCNF. Ngày biến động trùng với ngày của đợt theo B09, nhưng đây là dữ liệu lặp giữa hai bảng, không phải phụ thuộc trong một bảng; trigger kiểm tra để hai bảng luôn khớp.

Thao tác (4 giây) · Đối chiếu ví dụ bảng gộp với hai hàng hồ sơ và đợt.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong3.tex`, `docs/04_data_dictionary_va_chuan_hoa.md`.

## 09 · Ba ràng buộc chi phối một lần chuyển

TV1 · 55 giây / 07:40

B06 dùng ràng buộc loại trừ GiST để hai đợt của cùng người và cùng loại không chồng ngày. Một đợt thường trú và một đợt tạm trú có thể đồng thời tồn tại. B09 dùng trigger kiểm tra ở cả hai chiều. Khi chuyển vào ngày t, đợt cũ kết thúc vào t trừ một ngày và đợt mới bắt đầu vào ngày t. Nếu sửa lại mốc một đợt đã liên kết, trigger cũng kiểm tra sự nhất quán. B10 là tính nguyên tử của nghiệp vụ: ba hàm chuyển nội bộ, chuyển đi và chuyển đến đóng hoặc mở đợt và ghi biến động trong cùng giao dịch. Nếu một bước lỗi, cả chuỗi được hoàn tác. Các ca hợp lệ và vi phạm nằm trong bộ kiểm thử ràng buộc. Em mời Ngọc trình bày dữ liệu và truy vấn SQL.

Thao tác (10 giây) · Chỉ đường biên t và ba bước trong giao dịch. Mời Ngọc vào phần 2.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong3.tex`, `sql/02_constraints.sql`, `tests/constraints_week2.sql`, `tests/week2_tv1_integration_log.md`.

## Phần 2 · Dữ liệu, SQL và kiểm thử

Trần Tuấn Ngọc (TV2) · 5 giây / 07:45

Em trình bày bộ dữ liệu, truy vấn SQL và kết quả kiểm thử.

Nguồn `Slide/HUST_PPT_template_2022_Blue_16x9.pptx`.

## 10 · 636 bản ghi kiểm thử

TV2 · 20 giây / 08:05

Bộ dữ liệu có sáu trăm ba mươi sáu bản ghi trên bảy bảng. Hai nhóm lớn nhất là hai trăm cư dân và hai trăm năm mươi đợt cư trú. Sáu mươi ba biến động tạo dữ liệu cho các truy vấn nối đợt.

Thao tác (2 giây) · Chỉ tổng số bản ghi và hai bảng có nhiều dòng nhất.

Nguồn `sql/03_seed.sql`, `tests/final_test_log.md`.

## 11 · Danh mục QSQL01–QSQL13

TV2 · 40 giây / 08:45

Báo cáo có mười ba truy vấn. Mười câu đầu em đã chạy và chụp trong pgAdmin. Câu một tìm người đang cư trú tại Tổ 01. Câu hai tìm hộ có từ bốn người, còn câu ba đếm theo tổ. Các câu bốn đến bảy tra địa chỉ và lịch sử cư trú. Ba câu cuối thống kê biến động theo tháng, tìm những lần chuyển khác tổ và đếm theo tài khoản. Em chọn câu ba để giải thích tổ có số không và câu chín để giải thích hai nhánh nối từ đợt cũ và đợt mới. Ba câu bổ sung ở dòng cuối dùng CTE với RANK, truy vấn con trong FROM và phép chia; chi tiết ở phụ lục A05.

Thao tác (6 giây) · Chỉ vị trí QSQL03 và QSQL09 trong danh mục.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong5.tex`, `sql/04_queries.sql`, `sql/07_queries_bo_sung.sql`, `tests/final_test_log.md`.

## 12 · QSQL03 · Thống kê cư trú theo tổ

TV2 · 95 giây / 10:20

Câu ba cần trả đủ các tổ và số cư dân còn đợt hiệu lực ở từng tổ. Em bắt đầu từ bảng tổ dân phố, rồi nối trái lần lượt qua địa chỉ, hộ và đợt cư trú. Trong câu em đã chạy, ngày bắt đầu phải không sau ngày hai mươi tháng mười một năm hai nghìn không trăm hai mươi sáu. Ngày kết thúc có thể trống hoặc không trước ngày đó. Em đặt cả hai điều kiện trong ON của phép nối cuối. Khi không có đợt phù hợp, dòng của tổ vẫn còn và mã cư dân ở phần nối là NULL. COUNT DISTINCT bỏ qua NULL và đếm mỗi mã cư dân một lần trong một tổ. Bảng trên slide có đúng ba cột của truy vấn là mã tổ, tên tổ và số cư dân. Kết quả trả tám dòng, trong đó Tổ 05 có bốn mươi mốt người và Tổ 08 có không người. Em đã đối chiếu bảng này với kết quả trên pgAdmin. Phụ lục có mã đầy đủ của truy vấn.

Thao tác (24 giây) · Chỉ điều kiện ON, hàng Tổ 05, sau đó dừng ở hàng 0 của Tổ 08.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong5.tex`, `sql/04_queries.sql`, `tests/week1_execution_results.json`, `tests/final_test_log.md`.

## 13 · QSQL09 · Chuyển nội bộ giữa hai tổ

TV2 · 100 giây / 12:00

Câu chín tìm các lần chuyển chỗ ở giữa hai tổ khác nhau trong cùng phường. Em bắt đầu từ bảng biến động. Nhánh cũ đi theo mã đợt cũ rồi nối qua hộ và địa chỉ để lấy mã tổ cũ. Nhánh mới đi theo mã đợt mới và cũng qua hộ, địa chỉ để lấy mã tổ mới. Cùng một bảng quá trình cư trú xuất hiện hai lần, với bí danh q_cu và q_moi. Điều kiện WHERE giữ biến động chuyển nội bộ và kiểm tra hai đợt thuộc cùng một cư dân. Điều kiện cuối so sánh mã tổ cũ với mã tổ mới. Nhờ đó một lần chuyển sang hộ khác trong cùng tổ sẽ bị loại. Kết quả sắp theo mã biến động và có hai mươi hai dòng. Bảng trên slide trích ba dòng đầu theo đúng thứ tự đó. Ví dụ, biến động mã hai của cư dân mã mười lăm chuyển từ Tổ 01 sang Tổ 02 ngày mười lăm tháng mười năm hai nghìn không trăm hai mươi sáu. Khi cần xem toàn bộ câu lệnh, em mở phần phụ lục.

Thao tác (24 giây) · Dò hai nhánh nối và chỉ biến động 2 chuyển từ Tổ 01 sang Tổ 02.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong5.tex`, `sql/04_queries.sql`, `tests/week1_execution_results.json`, `tests/final_test_log.md`.

## 14 · Kiểm thử dữ liệu và truy vấn SQL

TV2 · 35 giây / 12:35

Nhóm dựng lại cơ sở dữ liệu, nạp đủ sáu trăm ba mươi sáu bản ghi rồi chạy bước kiểm tra dữ liệu. Cả mười ba câu đều khớp toàn bộ kết quả đã lưu. Câu hai trả hai mươi bốn hộ có ít nhất bốn người. Tổ 08 ở câu ba vẫn có mặt và mang số không. Tài khoản dự phòng mã năm ở câu mười cũng xuất hiện với số không. Ảnh chạy QSQL01 đến QSQL10 nằm trong phụ lục báo cáo. Em mời Ninh trình bày đại số quan hệ và bảo mật.

Thao tác (5 giây) · Chỉ kết quả đối chiếu, ngưỡng bốn người và hai số đếm bằng không. Mời Ninh vào phần 3.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong3.tex`, `Báo_cáo_CSDL_nhóm_38/chuong5.tex`, `tests/final_test_log.md`.

## Phần 3 · Đại số quan hệ và bảo mật

Dương Ngọc Ninh (TV3) · 5 giây / 12:40

Em trình bày đại số quan hệ và kiểm tra quyền truy cập.

Nguồn `Slide/HUST_PPT_template_2022_Blue_16x9.pptx`.

## 15 · Mười câu đại số quan hệ

TV3 · 40 giây / 13:20

Đây là mười câu đại số quan hệ trong báo cáo. Câu một và hai thể hiện chọn, chiếu và kết nối trên hồ sơ hoặc địa chỉ. Câu ba đến sáu phân biệt hiện tại, quá khứ và các phép toán tập hợp. Câu bảy dùng phép đổi tên vì bảng đợt xuất hiện hai lần. Câu tám lọc loại và thời điểm biến động. Câu chín dùng phép chia cho yêu cầu đủ mọi loại đã xuất hiện. Câu mười dùng gom nhóm trong đại số mở rộng. Em sẽ giải thích kỹ câu ba và câu chín vì hai câu làm rõ cách đưa nghiệp vụ vào biểu thức.

Thao tác (8 giây) · Lướt hai cột. Dừng ở RA 3 và RA 9 trước khi chuyển.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong4.tex`, `tests/report_ra_01_10.sql`, `tests/report_current_date_log.txt`.

## 16 · RA 3 · Thường trú tại Tổ 01

TV3 · 90 giây / 14:50

Câu ba tìm mã và họ tên những người đang thường trú tại Tổ 01. Chữ đang cần xử lý cả ngày bắt đầu lẫn ngày kết thúc có thể trống. Trước khi làm đại số, SQL xét hiệu lực theo ngày hiện tại của PostgreSQL rồi chiếu năm cột có giá trị bắt buộc thành Q hiện tại. Như vậy biểu thức cổ điển không phải thao tác trực tiếp với NULL. Bước một chọn từ Q hiện tại những đợt có loại thường trú. Song song, từ các địa chỉ của Tổ 01, em nối sang hộ và chỉ giữ mã hộ. Bước hai ghép hai kết quả trên mã hộ, vì cả hai cùng liên quan đến nơi cư trú. Cuối cùng nối cư dân trên mã cư dân rồi chiếu mã và họ tên. Việc giữ mã rất quan trọng vì tên có thể trùng. Bộ đối chiếu dịch biểu thức sang SQL và so sánh hai chiều với truy vấn đối chứng riêng trên mã và họ tên. Kết quả mẫu có hai mươi ba bộ, không có bộ nào lệch giữa hai cách. Con số có thể đổi khi ngày chạy đổi.

Thao tác (19 giây) · Chỉ ba bước và hai cột kết quả. Dừng để đọc một dòng mẫu.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong4.tex`, `tests/report_ra_01_10.sql`, `tests/report_current_date_log.txt`.

## 17 · RA 9 · Tài khoản ghi đủ loại biến động

TV3 · 105 giây / 16:35

Câu chín có chữ đủ, nên điều kiện phải đúng với mọi loại trong tập xét. Đầu tiên, chiếu bảng biến động lên cặp mã tài khoản và loại biến động. Khi một cán bộ ghi nhiều biến động cùng loại, phép chiếu theo ngữ nghĩa tập hợp chỉ giữ một cặp. Sau đó chiếu riêng cột loại để được tập chia. Bộ dữ liệu kiểm thử có đủ ba loại biến động là chuyển đến, chuyển đi và chuyển nội bộ. Đọc ma trận từ trái sang phải. Một tài khoản được giữ khi cả ba cột đều có cặp tương ứng. Tài khoản 1 đến 4 thỏa và tài khoản 5 chưa ghi biến động. Kỹ thuật SQL thứ nhất dùng hai lớp NOT EXISTS, chính là QSQL13 trong báo cáo. Nó rà xem có loại nào còn thiếu đối với tài khoản đang xét. Kỹ thuật thứ hai đếm loại phân biệt theo tài khoản và so với số loại phân biệt toàn bảng. Hai cách cho cùng tập bốn mã. Nếu cơ sở dữ liệu chỉ từng ghi hai loại, mẫu số của chính câu này sẽ có hai loại. Muốn bắt buộc mọi loại mà quy tắc cho phép, mẫu số phải là danh mục cố định theo miền nghiệp vụ. Ở đây câu hỏi và kết quả dùng đúng tập loại xuất hiện.

Thao tác (26 giây) · Chỉ mẫu số. Đọc một hàng đủ ba loại và hàng tài khoản 5.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong4.tex`, `tests/report_ra_01_10.sql`, `tests/report_current_date_log.txt`.

## 18 · B1 · Phân quyền bằng PostgreSQL role

TV3 · 95 giây / 18:10

Bảo mật truy cập bắt đầu từ các vai trò PostgreSQL. Admin có quyền đọc và cập nhật theo ràng buộc, đồng thời bị thu hồi quyền DELETE trên hai bảng lịch sử. Reader được SELECT sáu bảng nghiệp vụ. Report đọc được khung nhìn tổng hợp. Vai trò ghi trong bảng tài khoản để mô tả công việc của người ghi. Quyền truy cập khi kết nối do role PostgreSQL quyết định. Nhìn hai ảnh. Cả session user và current user đều là csdl17 reader, và superuser đang tắt. Bên trái, câu SELECT đếm được hai trăm cư dân. Bên phải, PostgreSQL từ chối sửa, thêm và xóa dữ liệu, đồng thời từ chối đọc bảng tài khoản. Nhật ký kiểm thử lưu mã lỗi quyền bốn hai năm không một. Bảng quyền và phép so bản ghi trước, sau nằm trong phụ lục báo cáo. Một giới hạn là admin vẫn có thể cập nhật lịch sử trong phạm vi trigger cho phép.

Thao tác (16 giây) · Chỉ role của phiên, số 200 và các lỗi quyền trong hai ảnh.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong6.tex`, `Báo_cáo_CSDL_nhóm_38/image/security/SEC_B1_select_ok.png`, `Báo_cáo_CSDL_nhóm_38/image/security/SEC_B1_denied.png`, `tests/security_login_tv3.sql`, `tests/report_security_repo_tests_log.txt`.

## 19 · B2 · Báo cáo qua VIEW tổng hợp

TV3 · 85 giây / 19:35

B2 là trường hợp người tổng hợp chỉ cần số cư dân theo tổ. Trong hai ảnh, phiên đăng nhập dùng csdl17 report. Bên trái, VIEW trả ba cột là mã tổ, tên tổ và số cư dân. Có tám dòng, Tổ 01 có ba mươi bốn người và Tổ 08 có số không. Định nghĩa trong ảnh bổ trợ dùng CURRENT DATE để xét hiệu lực của đợt. Bên phải, hai lệnh đọc trực tiếp bảng cư dân và bảng quá trình cư trú đều bị từ chối. Cách cấp quyền này cho phép dùng báo cáo tổng hợp trong phạm vi công việc. Số đếm nhỏ vẫn có nguy cơ suy luận. Ví dụ bổ sung B3 trình bày cách truyền đầu vào tra cứu dưới dạng tham số để giữ nó tách khỏi câu lệnh. Nhóm đã lưu kết quả riêng của B3 trong log thử nghiệm.

Thao tác (14 giây) · Chỉ ba cột của VIEW, dòng Tổ 08 và hai lỗi khi đọc bảng gốc.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong6.tex`, `Báo_cáo_CSDL_nhóm_38/image/security/SEC_B2_view_ok.png`, `Báo_cáo_CSDL_nhóm_38/image/security/SEC_B2_denied.png`, `Báo_cáo_CSDL_nhóm_38/image/security/SEC_B2_viewdef.png`, `tests/report_current_date_log.txt`.

## 20 · Kết luận và cảm ơn

TV3 · 25 giây / 20:00

Nhóm đã thiết kế một cơ sở dữ liệu giữ các đợt cư trú theo thời gian, cài đặt ràng buộc trên PostgreSQL và kiểm chứng kết quả truy vấn và quyền truy cập trên bộ dữ liệu kiểm thử. Em cảm ơn cô đã lắng nghe. Nhóm sẵn sàng trả lời câu hỏi về lược đồ, truy vấn và kết quả kiểm thử.

Thao tác (2 giây) · Dừng ở slide cảm ơn trước khi vào hỏi đáp.

Nguồn `Báo_cáo_CSDL_nhóm_38/ketluan.tex`, `tests/report_current_date_log.txt`.

## A01 · Danh mục 10 câu đại số quan hệ

TV3 · Hỏi đáp

Dùng khi cần tra một câu RA. Câu 1 và 8 ghi nhận kết quả. Tám câu còn lại có kiểm tra tự động. Số bộ của câu 3, 4 và 10 có thể thay đổi theo ngày hệ thống.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong4.tex`, `tests/report_current_date_log.txt`.

## A02 · RA 3 · Các bước trung gian

TV3 · Hỏi đáp

Giải thích đầu vào năm cột NOT NULL và điều kiện B05. Một phép chiếu cuối trả mã và họ tên. So sánh tập kết quả theo cả hai chiều với truy vấn SQL đối chứng của Chương 4.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong4.tex`, `tests/report_ra_01_10.sql`, `tests/report_current_date_log.txt`.

## A03 · RA 9 · Ngữ nghĩa phép chia

TV3 · Hỏi đáp

Chỉ đưa tài khoản vào kết quả khi từng loại trong số chia đều đi cùng tài khoản đó trong quan hệ bị chia. Mẫu có cả ba loại. Hai cách kiểm chứng là NOT EXISTS lồng và đếm loại phân biệt.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong4.tex`, `tests/report_ra_01_10.sql`, `tests/report_current_date_log.txt`.

## A04 · RA 4–6 · Hiệu, giao và hợp

TV3 · Hỏi đáp

Câu 4 loại người còn đợt hiệu lực khỏi những người có đợt đã bắt đầu. Câu 5 lấy phần mã cư dân chung của hai tập loại. Câu 6 dùng hợp trên mã biến động, do một lần chuyển nội bộ có thể xuất hiện ở cả vế cũ và mới.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong4.tex`, `tests/report_current_date_log.txt`.

## A05 · Danh mục QSQL01–QSQL13

TV2 · Hỏi đáp

Danh mục theo mã câu trong báo cáo và trong ảnh. QSQL02 dùng ngưỡng bốn cư dân. QSQL08 gom tất cả biến động đã ghi theo tháng và loại. QSQL10 giữ cả tài khoản chưa ghi biến động. QSQL11 đến QSQL13 là ba câu bổ sung: CTE với RANK xếp hạng hộ trong từng tổ, truy vấn con trong FROM so với mức trung bình 24,88 người, và phép chia bằng hai lớp NOT EXISTS cho cùng kết quả với RA 9.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong5.tex`, `sql/04_queries.sql`, `tests/week1_execution_results.json`, `tests/final_test_log.md`, `sql/07_queries_bo_sung.sql`, `tests/report_sql_bo_sung_log.txt`.

## A06 · QSQL03 · Truy vấn đầy đủ

TV2 · Hỏi đáp

Ba cột trả về là mã tổ, tên tổ và số cư dân phân biệt. Kết quả sắp theo mã tổ. Điều kiện hiệu lực đặt trong ON để phép nối trái giữ tổ không có đợt nào thỏa điều kiện.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong5.tex`, `sql/04_queries.sql`, `tests/week1_execution_results.json`, `tests/final_test_log.md`.

## A07 · QSQL09 · Truy vấn đầy đủ

TV2 · Hỏi đáp

Lọc biến động chuyển nội bộ, cùng mã cư dân và khác mã tổ. ORDER BY sắp theo mã biến động. Dòng đầu là biến động 2, cư dân 15, từ Tổ 01 sang Tổ 02.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong5.tex`, `sql/04_queries.sql`, `tests/week1_execution_results.json`, `tests/final_test_log.md`.

## A08 · B06, B09, B10 và X07 · Các ca kiểm tra

TV1 · Hỏi đáp

B06 phát hiện giao khoảng với mã 23P01. B09 kiểm biên ngày đợt và báo 23514. Ca B10 minh họa lỗi 23503 khi cập nhật theo chuỗi và kiểm tra toàn bộ chuỗi được hoàn tác. Ba hàm fn_chuyen_noi_bo, fn_chuyen_di và fn_chuyen_den đều chạy hợp lệ. X07: ghi thêm một biến động chuyển đi cho đợt 16, vốn đã là đợt cũ của biến động 2, bị UNIQUE uq_bd_dot_cu từ chối với 23505.

Nguồn `sql/02_constraints.sql`, `tests/constraints_week2.sql`, `tests/week2_tv1_integration_log.md`, `tests/report_bang_thu_rang_buoc_log.txt`.

## A09 · B1/B2 · Ma trận quyền và đăng nhập

TV3 · Hỏi đáp

Catalog kiểm tra 15 mục. Test đăng nhập reader đạt 12 trên 12 và report đạt 10 trên 10. B12 K01 đến K05 kiểm tra ma trận, DELETE và TRUNCATE lịch sử cùng ca gọi hàm hợp lệ của admin.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong6.tex`, `sql/05_security.sql`, `tests/report_security_repo_tests_log.txt`, `tests/week2_security_login_log.md`, `tests/week2_tv1_integration_log.md`.

## A10 · Seed, kết quả và hướng mở rộng

TV1 / TV3 · Hỏi đáp

Hai ràng buộc UNIQUE chặn ngay việc một đợt bị dùng lặp trong cùng vai trò; E1 kiểm tra lại ở bước kiểm tra dữ liệu. B3 thử hai cách tra cứu trên cụm cô lập và kết thúc bằng ROLLBACK. Theo log, cách sử dụng tham số trả 0 dòng với đầu vào thử và 8 dòng cho từ khóa thông thường. Những việc mở rộng là kiểm toán sửa lịch sử, phân quyền theo tổ và chính sách công bố nhóm nhỏ.

Nguồn `Báo_cáo_CSDL_nhóm_38/chuong6.tex`, `Báo_cáo_CSDL_nhóm_38/ketluan.tex`, `sql/03_seed.sql`, `tests/final_test_log.md`, `tests/report_current_date_log.txt`, `tests/report_security_ch6_log.txt`.

## A11 · B09 · Trigger kiểm tra ngày chuyển

TV1 / TV3 · Hỏi đáp

Dùng khi được hỏi về B09. Đợt cũ phải kết thúc đúng một ngày trước ngày chuyển, đợt mới bắt đầu đúng ngày chuyển. Sai ngày trả SQLSTATE 23514. Chiều thuận kiểm tra khi ghi biến động; chiều ngược kiểm tra lại khi sửa ngày của đợt. Đoạn trích chỉ hiện phần kiểm tra ngày. Mã nguồn đầy đủ nằm ở Phụ lục A của báo cáo.

Nguồn `sql/02_constraints.sql`, `Báo_cáo_CSDL_nhóm_38/phuluc.tex`, `tests/report_dml_minh_hoa_log.txt`.
