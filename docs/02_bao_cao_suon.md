# BÁO CÁO BTL MÔN CƠ SỞ DỮ LIỆU — BẢN NHÁP TÍCH HỢP

**Chủ đề số 17** — Xây dựng cơ sở dữ liệu quản lý cư dân và biến động cư trú tại một phường.

> TV1 đã viết nội dung thiết kế Chương 1–3 và mở đầu ngày 11/11/2026; bản nháp Chương 4 và 6 của TV3 được tích hợp ngày 16/11/2026. Thông tin bìa đã điền theo chủ repo cung cấp. Chưa là báo cáo cuối: Chương 5, ảnh minh chứng, nghiệm thu tuần 2–3 và xác nhận của nhóm còn theo kế hoạch.

> Cập nhật 15/11/2026 bởi agent hỗ trợ TV1: làm rõ C1 ở P3/chức năng 3.2, đồng bộ ý nghĩa đợt–sự kiện và phạm vi chuẩn hóa nháp. Giữ nguyên schema; không thay lời xác nhận hoặc chữ ký của thành viên.

> Thiết kế v1/Gate 1 PASS theo xác nhận chủ repo tiếp nhận16/11/2026; [nguồn xác nhận](../meetings/decision_log.md#gate1). Đây là chốt thiết kế, các chương/kết quả/ảnh và chữ ký báo cáo cuối tiếp tục theo tuần 2–3.

## TRANG BÌA

- Mã lớp: 174356
- Số thứ tự nhóm: 38
- Giảng viên: ThS. Nguyễn Thị Thanh Huyền
- Thành viên: TV1 Trần Bùi Tùng Linh — 20227057; TV2 Trần Tuấn Ngọc — 20227064; TV3 Dương Ngọc Ninh — 20237469
- Ngày nộp: 27/11/2026

## MỤC LỤC

[TODO: tạo tự động khi chuyển sang công cụ biên tập chính]

## MỞ ĐẦU

Quản lý cư dân cần trả lời được một người cư trú ở đâu tại một thời điểm, đã thay đổi nơi ở ra sao và ai ghi nhận biến động đó. Lưu duy nhất địa chỉ hiện tại sẽ không đáp ứng được câu hỏi lịch sử. Đề tài xây dựng mô hình quan hệ tách hồ sơ cư dân, vị trí cư trú, khoảng thời gian và nhật ký sự kiện để bảo toàn những thông tin này.

Mục tiêu là phân tích nghiệp vụ, thiết kế ERD, ánh xạ quan hệ, phân tích chuẩn hóa, triển khai ràng buộc và kiểm chứng truy vấn/bảo mật trên PostgreSQL. Trong tuần 1, nhóm chuẩn bị bộ thiết kế để các thành viên triển khai thống nhất; việc tạo dữ liệu chính thức, 10 SQL, 10 biểu thức đại số quan hệ và hai demo là sản phẩm tiếp theo.

Mọi nhân vật và địa chỉ đều là dữ liệu mô phỏng. Đề tài giới hạn một phường giả lập, không có giá trị pháp lý, không kết nối dữ liệu dân cư thật và không xây dựng ứng dụng web/mobile.

## CHƯƠNG 1 — PHÂN TÍCH BÀI TOÁN VÀ CHỨC NĂNG

### 1.1. Bài toán thực tiễn

Địa bàn gồm tổ dân phố, địa chỉ và nhóm hộ. Một địa chỉ có thể có nhiều hộ và một người có thể ở nhiều hộ qua các thời kỳ. Hệ thống phải lưu được hồ sơ người chưa có đợt cư trú, hộ chưa có người, người chuyển đi và người quay lại. Đợt cư trú là nguồn thông tin về vị trí theo thời gian; nhật ký biến động trả lời câu hỏi sự kiện nào được ai ghi nhận.

### 1.2. Tác nhân và phạm vi

Cán bộ quản lý cập nhật danh mục, hồ sơ, đợt và sự kiện. Cán bộ tổng hợp tra cứu và thống kê theo quyền. Quản trị CSDL quản lý cấu trúc và quyền PostgreSQL. Vai trò ghi trong bảng tài khoản là dữ liệu nghiệp vụ; quyền DB thực tế được thiết lập riêng trong phần bảo mật. Nhóm hộ không được tự hiểu là một gia đình có quan hệ huyết thống.

### 1.3. Quy trình nghiệp vụ

| Quy trình | Xử lý và đầu ra chính | Ràng buộc cần chú ý |
|---|---|---|
| P1 — Địa bàn và hộ | Tạo tổ, địa chỉ và nhóm hộ theo đúng bản ghi cha | Không trùng tên tổ/cặp tổ+địa chỉ; hộ có địa chỉ cố định |
| P2 — Hồ sơ cư dân | Tạo/sửa họ tên, ngày sinh, giới tính theo mã người | Trùng họ tên được phép; không lưu địa chỉ hiện tại ở hồ sơ |
| P3 — Đợt cư trú | Tạo/hiệu chỉnh đợt người–hộ–loại–khoảng ngày; ghi kết thúc theo C1 | FK hợp lệ, ngày đúng, không chồng cùng loại; nhập/sửa lịch sử hoặc hết hạn tạm trú có thể không có nhật ký; giữ B08–B09 nếu đã có sự kiện tham chiếu |
| P4 — Chuyển đến | Tạo đợt mới và sự kiện chỉ tham chiếu đợt mới | Ngày bắt đầu mới bằng ngày sự kiện; một giao dịch |
| P5 — Chuyển đi/nội bộ | Đóng đợt cũ; nếu nội bộ tạo đợt mới; ghi sự kiện | Nội bộ cùng người/khác hộ; cũ kết thúc trước ngày chuyển một ngày; rollback khi lỗi |
| P6 — Tra cứu/thống kê | Danh sách theo ngày và thống kê người/sự kiện | Đúng ngày tham chiếu, đếm mã người phân biệt, giữ nhóm 0 khi câu hỏi yêu cầu |

Đặc tả đầu vào, tiền điều kiện, bước xử lý, bảng đọc/ghi và lỗi của từng quy trình được trình bày đầy đủ trong [đặc tả nghiệp vụ](03_dac_ta_nghiep_vu.md). P5 có hai nhánh riêng; không dùng một thao tác xóa lịch sử để biểu diễn chuyển đi.

### 1.4. Sơ đồ phân rã chức năng

![Hình 1 — Phân rã chức năng cấp 0–1–2](../diagrams/phan_ra_chuc_nang.png)

Sơ đồ có sáu nhóm chức năng và 14 chức năng cấp 2. Quan hệ nối thể hiện chức năng con thuộc chức năng cha; không thể hiện trình tự thực hiện. Bảng chức năng → dữ liệu đọc/ghi nằm trong mục 4 của đặc tả nghiệp vụ, giúp đối chiếu mỗi chức năng với dữ liệu được mô hình hóa.

Chức năng **3.2 Kết thúc đợt** dùng cho nhập/hiệu chỉnh lịch sử hoặc hết hạn tạm trú không phát sinh hành vi chuyển chỗ ở; khi đó không bắt buộc tạo `CHUYEN_DI` (C1). Các chuyển đến/đi/nội bộ thực tế vẫn do nhóm chức năng 4 và P4/P5 ghi sự kiện trong cùng giao dịch. C1 phân định phạm vi hai nhóm chức năng, không cho phép bỏ nhật ký của thao tác chuyển thực tế.

### 1.5. Quy tắc nghiệp vụ trọng tâm

Một đợt có hiệu lực tại d khi đã bắt đầu và chưa kết thúc trước d. Ngày kết thúc được tính bao gồm; NULL là chưa ghi nhận ngày kết thúc. Vì vậy đợt tương lai với kết thúc NULL vẫn chưa có hiệu lực. Hai đợt cùng người/cùng loại không được giao nhau; hai loại khác nhau đồng thời được cho phép trong phạm vi mô phỏng và thống kê phải tránh đếm trùng.

Với ngày chuyển t, đợt cũ kết thúc t−1, đợt mới bắt đầu t. Sự kiện đến chỉ có đợt mới; đi chỉ có đợt cũ; nội bộ có hai đợt của cùng cư dân và khác hộ. Ví dụ cũ ở H-A tới hết 14/11, mới ở H-B từ 15/11 thì sự kiện chuyển ghi ngày 15/11. Nhiều thao tác phải cùng một giao dịch để không xuất hiện lịch sử đã đóng nhưng thiếu nơi mới hoặc thiếu sự kiện.

Không đổi liên kết hộ–địa chỉ/tổ đã được lịch sử dùng để biểu diễn chuyển nơi ở. Nhật ký không sao chép tên người hoặc địa chỉ. Quy tắc B01–B18 và các giới hạn thực thi hiện tại được công bố trong đặc tả; chưa coi các trigger/transaction dự kiến là đã chạy.

Một người chỉ có đợt tạm trú 01/11–19/11/2026 đã hết hạn, không có `CHUYEN_DI`, vẫn thuộc QRA09/QSQL07 tại ngày 20/11; ngày 19/11 đợt còn hiệu lực nên người đó không thuộc kết quả này. Điều kiện truy vấn dựa vào khoảng ngày, không bắt buộc có sự kiện chuyển đi. Người chưa có đợt hoặc chỉ có đợt tương lai vẫn bị loại đúng theo B16.

## CHƯƠNG 2 — MÔ HÌNH THỰC THỂ LIÊN KẾT

### 2.1. Thực thể và thuộc tính

| Thực thể | Vai trò | Thuộc tính phân biệt chính |
|---|---|---|
| `to_dan_pho` | Danh mục tổ | Mã tổ, tên tổ duy nhất |
| `dia_chi` | Địa chỉ thuộc tổ | Mã địa chỉ, mã tổ, chuỗi chuẩn |
| `ho_cu_tru` | Nhóm hộ tại địa chỉ | Mã hộ, mã địa chỉ, ngày lập |
| `cu_dan` | Hồ sơ nhân vật | Mã cư dân, họ tên, ngày sinh, giới tính |
| `qua_trinh_cu_tru` | Thực thể kết hợp theo thời gian | Mã đợt, cư dân, hộ, loại, bắt đầu/kết thúc |
| `tai_khoan` | Danh mục người ghi nhận | Mã tài khoản, tên đăng nhập, vai trò, trạng thái |
| `bien_dong_cu_tru` | Sự kiện cư trú | Mã sự kiện, loại, đợt cũ/mới, ngày, người ghi, thời điểm ghi |

### 2.2. Quan hệ và bản số

Tổ–địa chỉ, địa chỉ–hộ, cư dân–đợt, hộ–đợt và tài khoản–sự kiện là các quan hệ 1–N. Phía cha có thể chưa có con; mỗi con có đúng một cha tương ứng vì FK NOT NULL. Quan hệ cư dân–hộ N–N được giải bằng thực thể đợt cư trú thay vì danh sách mã trong một ô.

Một sự kiện có tối đa một đợt cũ và tối đa một đợt mới; từng FK được phép NULL theo loại. Một đợt có thể chưa tham gia sự kiện nào hoặc được nhiều sự kiện tham chiếu. Hai vai trò cũ/mới phải có tên riêng trên ERD; CHECK kiểm phối hợp hai FK, không biến chúng thành một quan hệ N–N không xác định.

### 2.3. ERD

![Hình 2 — ERD của bộ bàn giao v1](../diagrams/erd_v1.png)

ERD thể hiện đủ 35 cột và 7 FK. Ký hiệu ? là cột cho phép NULL. Tính duy nhất ghép của địa chỉ là `(ma_to, dia_chi_chuan)`, không phải từng cột riêng. Bản nguồn `.drawio` và bản vector `.svg` được lưu cùng ảnh để chỉnh sửa hoặc in rõ hơn.

### 2.4. Giải thích thiết kế lịch sử

Nếu đặt hộ hiện tại trong `cu_dan`, mỗi lần chuyển phải ghi đè giá trị cũ, khiến câu hỏi “người này ở đâu ngày 14/11?” không trả lời được. `qua_trinh_cu_tru` lưu từng khoảng riêng, cho phép trở lại cùng hộ sau một thời gian. Địa chỉ được suy ra qua đợt → hộ → địa chỉ → tổ.

`bien_dong_cu_tru` có mục đích khác: lưu sự kiện và người ghi nhận. Đợt nhập/hiệu chỉnh lịch sử hoặc tạm trú hết hạn không mặc nhiên phải có nhật ký theo C1. Khi sửa đợt đã được nhật ký tham chiếu, phải kiểm lại B08–B09; khi chuyển cả hộ, mô hình dùng hộ mới thay vì thay địa chỉ của hộ cũ. Cardinality DB 0..N giữ nguyên; validation E1 yêu cầu xử lý các sự kiện trùng cùng vai trò trước nghiệm thu.

## CHƯƠNG 3 — THIẾT KẾ CSDL QUAN HỆ

### 3.1. Ánh xạ ER → mô hình quan hệ

Mỗi thực thể trở thành một bảng. PK được sinh bằng BIGINT IDENTITY; quan hệ 1–N đặt FK ở phía N; quan hệ cư dân–hộ có thuộc tính thời gian trở thành bảng đợt với mã riêng. Hai FK cũ/mới cùng trỏ đến bảng đợt nhưng không được gộp thành một cột.

```text
to_dan_pho(ma_to PK, ten_to UQ, ghi_chu)
dia_chi(ma_dia_chi PK, ma_to FK, dia_chi_chuan, ghi_chu, UQ(ma_to,dia_chi_chuan))
ho_cu_tru(ma_ho PK, ma_dia_chi FK, ngay_lap, ghi_chu)
cu_dan(ma_cu_dan PK, ho_ten, ngay_sinh, gioi_tinh, ghi_chu)
qua_trinh_cu_tru(ma_qua_trinh PK, ma_cu_dan FK, ma_ho FK, loai_cu_tru,
                ngay_bat_dau, ngay_ket_thuc)
tai_khoan(ma_tai_khoan PK, ten_dang_nhap UQ, ten_hien_thi, vai_tro, trang_thai)
bien_dong_cu_tru(ma_bien_dong PK, loai_bien_dong, ma_qua_trinh_cu FK nullable,
                 ma_qua_trinh_moi FK nullable, ngay_bien_dong, ma_tai_khoan FK,
                 thoi_diem_ghi, ghi_chu)
```

### 3.2. Cấu trúc và từ điển dữ liệu

Bảy bảng có lần lượt 3, 4, 4, 5, 6, 5 và 8 cột theo thứ tự trong lược đồ trên, tổng 35 cột. Tên dùng VARCHAR có giới hạn; ghi chú dùng TEXT; các ngày nghiệp vụ dùng DATE; thời điểm ghi sự kiện dùng TIMESTAMPTZ. Khóa mã dùng BIGINT. Mọi cột bắt buộc được NOT NULL; các ghi chú, kết thúc đợt và hai FK điều kiện là nullable.

Các miền giá trị gồm giới tính `Nam/Nu/Khac`, loại cư trú `THUONG_TRU/TAM_TRU`, vai trò `QUAN_TRI/CAN_BO/THONG_KE`, trạng thái `HOAT_DONG/KHOA` và ba loại biến động. Default nghiệp vụ duy nhất là tài khoản hoạt động và thời điểm ghi CURRENT_TIMESTAMP; mã được sinh IDENTITY. Từ điển đầy đủ từng cột, kiểu, NULL, default, PK/FK/UNIQUE/CHECK và ý nghĩa nằm trong [tài liệu dữ liệu, mục 3](04_data_dictionary_va_chuan_hoa.md#3-từ-điển-dữ-liệu-đầy-đủ), là phụ lục kỹ thuật của bản nháp này.

### 3.3. Khóa, ràng buộc và giới hạn thực thi

Lược đồ cơ bản trong `sql/01_schema.sql` có 7 PK, 7 FK, 3 UNIQUE nghiệp vụ, 6 CHECK và 5 chỉ mục. Các ràng buộc một hàng này không đủ kiểm tra chồng lấn giữa nhiều đợt hoặc sự kiện tham chiếu sang hai đợt. Vì vậy nhóm tách **ràng buộc toàn vẹn nghiệp vụ** sang `sql/02_constraints.sql`, chạy sau schema và trước seed:

| Quy tắc | Cơ chế PostgreSQL đã viết | Hành vi mong đợi |
|---|---|---|
| B06 | `EXCLUDE USING gist` với `btree_gist` và `daterange(..., '[]')` | Từ chối hai đợt **cùng người, cùng loại** giao nhau; NULL kết thúc = không giới hạn; khác loại hoặc liền ngày không giao được phép |
| B08 | Trigger trên sự kiện và trigger kiểm ngược khi sửa đợt | Nội bộ phải cùng cư dân, khác hộ, kể cả khi hai đợt đã có FK hợp lệ |
| B09 | Trigger so ngày sự kiện với biên của đợt | Đợt cũ kết thúc ở **t−1**, đợt mới bắt đầu **t**; sửa đợt cũ/mới không được phá nhật ký |
| B10 | Hàm `fn_chuyen_noi_bo` và transaction | Khóa đợt cũ, đóng đợt, mở đợt mới, ghi sự kiện nguyên tử; lỗi giữa các bước làm rollback |
| B11 | Trigger bảo vệ FK địa chỉ/tổ đã có đợt lịch sử | Không thể đổi hộ sang địa chỉ khác hoặc đổi tổ của địa chỉ đã tham gia lịch sử |
| B14 | Trigger trạng thái tài khoản khi tạo sự kiện/đổi người ghi | Tài khoản phải `HOAT_DONG`; khóa tài khoản sau đó không vô hiệu hóa sự kiện lịch sử |

**Phân biệt cơ chế:** FK/CHECK bảo đảm cấu trúc và miền dữ liệu; GiST exclusion ràng buộc **giữa nhiều dòng**; trigger bảo vệ **liên bảng và chiều cập nhật ngược**; transaction bảo đảm tính nguyên tử của thao tác nhiều bước. `01_schema.sql` không có các cơ chế sau, nên chỉ chạy file đầu sẽ chưa thực thi được B06, B08–B11, B14.

**Giới hạn:** B15 (tên không rỗng, ngày sinh/ngày lập hộ hợp lệ so với ngày bắt đầu) hiện kiểm bằng bộ sinh dữ liệu và đầu vào, chưa được tất cả các dạng UPDATE trên CSDL bảo vệ. B11 chỉ khóa **liên kết địa lý đã có lịch sử**, không cấm sửa ghi chú hay các liên kết chưa sử dụng. B10 là một đường thao tác có hỗ trợ; quyền ghi SQL trực tiếp vẫn phải được quản lý và ứng dụng phải dùng giao dịch đúng quy trình. Không khẳng định đã kiểm chứng concurrency đa kết nối ngoài các ca thực tế có trong biên bản.

Bộ kiểm thử tích hợp `tests/constraints_week2.sql` được thiết kế chạy trên database có seed trong một `BEGIN…ROLLBACK` riêng; gồm ca hợp lệ và lỗi `23P01` (exclusion), `23514` (vi phạm nghiệp vụ) và `23503` (FK). Log CI/psql của lần chạy thật là căn cứ để ghi PASS, không phải sự tồn tại của file SQL. `sql/06_validation.sql` bổ sung kiểm tra không còn vi phạm trong dữ liệu đã nạp.

### 3.4. Chuẩn hóa

1NF được thể hiện bằng các giá trị nguyên tử và tách nhiều đợt thành nhiều dòng. Khi kiểm 2NF phải xét cả khóa thay thế: địa chỉ có khóa ghép tổ+chuỗi, các thuộc tính còn lại không được quy định phụ thuộc vào riêng một phần của khóa đó. Cư dân, hộ và đợt không sao chép thông tin thuộc thực thể khác.

| Quan hệ | Khóa ứng viên và phụ thuộc chính |
|---|---|
| Tổ | Mã tổ hoặc tên tổ → các thuộc tính còn lại |
| Địa chỉ | Mã địa chỉ hoặc cặp tổ+chuỗi → các thuộc tính còn lại |
| Hộ | Mã hộ → địa chỉ, ngày lập, ghi chú |
| Cư dân | Mã cư dân → tên, sinh, giới tính, ghi chú |
| Đợt | Mã đợt → cư dân, hộ, loại và hai ngày; sau khi B06 được bảo đảm còn có khóa logic người+loại+bắt đầu |
| Tài khoản | Mã tài khoản hoặc tên đăng nhập → các thuộc tính còn lại |
| Sự kiện | Mã sự kiện → loại, hai đợt, ngày, người và thời điểm ghi, ghi chú |

Với tập phụ thuộc đã công bố, sáu bảng danh mục/hồ sơ/lịch sử không có phụ thuộc bắc cầu giữa các thuộc tính không khóa và đáp ứng phân tích 3NF. Tách tên tổ khỏi địa chỉ, địa chỉ khỏi đợt và tên người khỏi nhật ký tránh cập nhật cùng thông tin ở nhiều nơi.

Riêng ngày biến động có thể suy ra từ biên ngày của đợt theo quy tắc đã chọn. Khi FK nullable và một đợt được nhiều sự kiện tham chiếu, xuất hiện phụ thuộc có điều kiện trên các tập con. Bản nháp ghi nhận đây là điểm dư thừa có kiểm soát cần review; không khẳng định toàn bộ mô hình đạt 3NF tuyệt đối chỉ dựa trên PK. Phân tích đầy đủ, phạm vi kết luận và việc chốt tuần 2 được ghi ở mục 5 của tài liệu chuẩn hóa.

Quyết định C1 không đổi tập khóa/FD đã công bố và không làm đợt–sự kiện thành quan hệ bắt buộc một–một. Bản nháp tuần 1 đã có nội dung phân tích để review; luận chứng chuẩn hóa cuối theo DEC12 và cơ chế ràng buộc xuyên bảng vẫn là phần hoàn thiện tuần 2.

### 3.5. Kế hoạch dữ liệu và kiểm tra

**Phạm vi bàn giao tuần 1:** TV2 chuẩn bị kế hoạch dữ liệu/SQL, fixture nhỏ có đáp án tay và ma trận kịch bản; việc nghiệm thu bộ dữ liệu lớn là bước riêng của tuần 2. Quy mô tham khảo gồm 8 tổ, 50 địa chỉ, 60 hộ, 200 cư dân, khoảng 250 đợt, 70 sự kiện và 5 tài khoản; có thể điều chỉnh theo độ phủ kiểm thử. Nạp theo thứ tự FK, dùng seed cố định và ghi số liệu thực tế trong log của lần chạy. Không ghi các con số mục tiêu thành số liệu đã nạp.

TV1 đã chuẩn bị 30 tình huống kiểm tra thiết kế với đầu ra kỳ vọng trong `tests/week1_design_cases.md` và ma trận 20 câu hỏi. Kết quả thực thi PostgreSQL, S01–S21, ảnh SQL và kiểm chứng dữ liệu chính thức sẽ được bổ sung sau; tự kiểm tra tài liệu không thay thế kiểm thử DB.

### 3.6. Kiểm thử ràng buộc nâng cao và giao dịch

**Môi trường áp dụng:** PostgreSQL ≥15, bật `btree_gist`. Thứ tự tái lập: `01_schema.sql` → `02_constraints.sql` → `03_seed.sql` → `tests/constraints_week2.sql` → `06_validation.sql`. Ca thử âm phải có lỗi mong đợi và được rollback; dataset 636 bản ghi không được thay đổi. Hai loại dữ liệu được phân biệt: dữ liệu mô phỏng chính thức và fixture 990xx chỉ tồn tại trong transaction kiểm thử.

| Tình huống kiểm thử | Expected | Cơ chế |
|---|---|---|
| Hai đợt cùng loại giao ngày; cả INSERT và UPDATE | Lỗi `23P01` | B06 |
| Hai đợt liền ngày, hoặc cùng người nhưng khác loại | Chấp nhận | B06 |
| Chuyển nội bộ giữa hai cư dân hoặc cùng hộ | Lỗi `23514` | B08 |
| Chuyển sai ngày, sửa ngược đợt làm sai sự kiện | Lỗi `23514` | B09 |
| Di chuyển địa chỉ/tổ đã có lịch sử | Lỗi `23514` | B11 |
| Ghi biến động bằng tài khoản khóa | Lỗi `23514` | B14 |
| Chuyển nội bộ lỗi ở bước tạo đợt mới | Lỗi `23503`, đợt cũ và sự kiện không bị đổi | B10 |
| Chuyển nội bộ hợp lệ | Đóng cũ, tạo mới và lưu nhật ký khớp | B10 |

**Kiểm chứng ngày 19/11:** Workflow PostgreSQL 17 tại [run 44533515990](https://github.com/Linhlss/CSDL-Nh-m-38/actions/runs/44533515990) đã thành công: 20 thông báo PASS của fixture, 1 PASS validation, không có lỗi PostgreSQL bất ngờ; chuỗi SQL01–10 thực thi thành công. Log này là kết quả kỹ thuật tuần 2, chưa thay thế biên bản Gate 3.

**Minh chứng nghiệm thu:** Lưu log PostgreSQL thực thi từ CSDL trắng và kết quả `06_validation.sql` vào `tests/final_test_log.md`, kèm ảnh các ca tiêu biểu trong `evidence/sql/`. Không sử dụng log kiểm tra tệp tuần 1 để thay thế kiểm thử ràng buộc tuần 2.

## CHƯƠNG 4 — ĐẠI SỐ QUAN HỆ (10 CÂU)

> Người viết: TV3. Reviewer được phân công: TV1. Nháp ngày 16/11/2026. PR #3 đã merge; seed hiện hành có 636 dòng. Kết quả bên dưới trích từ [log kiểm chứng tuần 1](../tests/week1_execution_results.json), không phải một lần chạy mới hay xác nhận nghiệm thu của thành viên. Bốn QRA chưa có log trên seed lớn vẫn được ghi rõ ở mục 4.12. SQL kiểm chứng của từng câu nằm trong [06a_dai_so_quan_he.md](06a_dai_so_quan_he.md).

### 4.1. Ký hiệu và quy ước

| Ký hiệu | Phép toán | SQL tương ứng |
|---|---|---|
| `σ_{điều kiện}(R)` | Chọn | `WHERE` |
| `π_{A, B}(R)` | Chiếu, kết quả là tập (không lặp) | `SELECT DISTINCT A, B` |
| `R ⋈ S` | Kết nối tự nhiên theo các thuộc tính trùng tên | `JOIN ... USING (...)` |
| `R ⋈_{điều kiện} S` | Kết nối theta | `JOIN ... ON ...` |
| `R ∪ S`, `R ∩ S`, `R − S` | Hợp, giao, hiệu | `UNION`, `INTERSECT`, `EXCEPT` |
| `ρ_{S(A1, A2, ...)}(R)` | Đổi tên quan hệ và thuộc tính | Bí danh `AS` |
| `X ← biểu thức` | Gán kết quả trung gian | `WITH X AS (...)` |

Nhóm thống nhất các quy ước sau.

1. Đại số quan hệ làm việc trên tập, nên phép chiếu tự loại bộ trùng. SQL làm việc trên đa tập, vì vậy SQL kiểm chứng dùng `DISTINCT` hoặc phép tập hợp khi cần loại trùng. Hai bên được đối chiếu đầy đủ các thuộc tính đầu ra sau khi đưa về cùng mức hạt; số dòng chỉ là thông tin tóm tắt.
2. Hai vế của `∪`, `∩`, `−` phải khả hợp, tức là cùng số thuộc tính và cùng miền. Mọi phép tập hợp trong chương này so trên `ma_cu_dan` hoặc `ma_dia_chi`. Hai người trùng họ tên vẫn là hai phần tử khác nhau.
3. Cột `ghi_chu` có mặt ở năm bảng. Nối tự nhiên hai bảng gốc sẽ so cả `ghi_chu` và cho kết quả sai, nên mọi biểu thức đều chiếu bớt thuộc tính trước khi nối, để hai vế chỉ còn chung đúng thuộc tính khóa.
4. Ngày tham chiếu là d = 20/11/2026. Theo quy tắc B05, một đợt có hiệu lực tại d khi `ngay_bat_dau ≤ d` và `ngay_ket_thuc` rỗng hoặc `ngay_ket_thuc ≥ d`. Cột `ngay_ket_thuc` được phép NULL, mà so sánh với NULL cần logic ba giá trị của SQL, nằm ngoài đại số quan hệ cổ điển. Nhóm tách việc này thành hai bước:
   - Bước chuẩn bị bằng SQL: lấy các đợt có hiệu lực tại d theo B05 rồi bỏ cột `ngay_ket_thuc`, được
     `Q_d(ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau)`.
   - Bước đại số: dùng `Q_d` như một quan hệ đầu vào. Mọi thuộc tính của `Q_d` đều có giá trị, nên các biểu thức chỉ dùng phép toán cổ điển.
5. QRA01, 02, 03, 08 xét tại d qua `Q_d`. QRA09 coi một người là đã từng cư trú khi người đó có đợt bắt đầu ≤ d. QRA04, 05, 06, 07, 10 xét toàn bộ dữ liệu đã ghi nhận (quy tắc B16).

Lược đồ dùng trong chương (theo `sql/01_schema.sql`):

```text
TO_DAN_PHO(ma_to, ten_to, ghi_chu)
DIA_CHI(ma_dia_chi, ma_to, dia_chi_chuan, ghi_chu)
HO_CU_TRU(ma_ho, ma_dia_chi, ngay_lap, ghi_chu)
CU_DAN(ma_cu_dan, ho_ten, ngay_sinh, gioi_tinh, ghi_chu)
QUA_TRINH_CU_TRU(ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau, ngay_ket_thuc)
BIEN_DONG_CU_TRU(ma_bien_dong, loai_bien_dong, ma_qua_trinh_cu, ma_qua_trinh_moi,
                 ngay_bien_dong, ma_tai_khoan, thoi_diem_ghi, ghi_chu)
```

### 4.2. QRA01: Cư dân đang cư trú tại Tổ 01 tại ngày d

Câu hỏi: liệt kê mã và họ tên cư dân đang cư trú tại một địa chỉ thuộc Tổ 01 vào ngày 20/11/2026.

```text
R1 ← π_{ma_to}(σ_{ten_to = 'Tổ 01'}(TO_DAN_PHO))
R2 ← π_{ma_dia_chi}(π_{ma_dia_chi, ma_to}(DIA_CHI) ⋈ R1)
R3 ← π_{ma_ho}(π_{ma_ho, ma_dia_chi}(HO_CU_TRU) ⋈ R2)
R4 ← π_{ma_cu_dan}(π_{ma_cu_dan, ma_ho}(Q_d) ⋈ R3)
KQ ← π_{ma_cu_dan, ho_ten}(CU_DAN ⋈ R4)
```

Biểu thức đi từ tổ xuống địa chỉ, hộ, rồi tới các đợt còn hiệu lực; mỗi bước nối chỉ có chung một thuộc tính khóa. R4 là tập mã cư dân, nối với `CU_DAN` để lấy họ tên. Hai người trùng tên vẫn cho hai bộ vì khác `ma_cu_dan`.

Kết quả trên seed636: **34 bộ**, trích kiểm tra `QRA01` ở mục 4.12; tập kết quả đầy đủ có trong log tuần 1.

### 4.3. QRA02: Cư dân đang tạm trú tại Tổ 02 tại ngày d

Câu hỏi: liệt kê mã và họ tên cư dân đang tạm trú tại Tổ 02 vào ngày 20/11/2026.

```text
KQ ← π_{C.ma_cu_dan, C.ho_ten}(
        σ_{T.ten_to = 'Tổ 02' ∧ Q.loai_cu_tru = 'TAM_TRU'}(
            C ⋈_{C.ma_cu_dan = Q.ma_cu_dan} Q_d
              ⋈_{Q.ma_ho = H.ma_ho} H
              ⋈_{H.ma_dia_chi = D.ma_dia_chi} D
              ⋈_{D.ma_to = T.ma_to} T ))
```

với C = `CU_DAN`, Q = `Q_d`, H = `HO_CU_TRU`, D = `DIA_CHI`, T = `TO_DAN_PHO`.

Câu này dùng kết nối theta để minh họa cách viết thứ hai. Điều kiện nối nêu rõ cặp thuộc tính được so, nên cột `ghi_chu` trùng tên không ảnh hưởng. Mỗi `⋈_{điều kiện}` tương đương `σ_{điều kiện}(R × S)`. Có thể đẩy phép chọn vào trong, ví dụ `σ_{ten_to = 'Tổ 02'}(T)`, để giảm số bộ trung gian mà kết quả không đổi.

Kết quả: đã khớp đáp án tay trên tiny29; chờ ghi tập kết quả trên seed636 cho bản báo cáo cuối (mục 4.12).

### 4.4. QRA03: Cư dân từ 60 tuổi trở lên đang cư trú tại Tổ 01

Câu hỏi: liệt kê mã, họ tên, ngày sinh của cư dân đủ 60 tuổi tại ngày d (sinh từ 20/11/1966 trở về trước) và đang cư trú tại Tổ 01.

```text
CAO_TUOI ← π_{ma_cu_dan, ho_ten, ngay_sinh}(σ_{ngay_sinh ≤ '1966-11-20'}(CU_DAN))
KQ       ← CAO_TUOI ⋈ R4          (R4 như QRA01)
```

Đại số quan hệ không có hàm tính tuổi, nên điều kiện tuổi được viết thành so sánh ngày sinh với một ngày cắt cố định. Phép nối tự nhiên qua thuộc tính chung `ma_cu_dan` giữ lại người vừa đủ tuổi vừa đang ở Tổ 01.

Kết quả: đã khớp đáp án tay trên tiny29; chờ ghi tập kết quả trên seed636 cho bản báo cáo cuối (mục 4.12).

### 4.5. QRA04: Cư dân từng cư trú ở ít nhất hai nhóm hộ khác nhau

Câu hỏi: liệt kê mã và họ tên cư dân từng có đợt cư trú ở ít nhất hai nhóm hộ khác nhau, xét toàn bộ lịch sử.

```text
QA ← ρ_{QA(ma_cu_dan, ma_ho_a)}(π_{ma_cu_dan, ma_ho}(QUA_TRINH_CU_TRU))
QB ← ρ_{QB(ma_cu_dan, ma_ho_b)}(π_{ma_cu_dan, ma_ho}(QUA_TRINH_CU_TRU))
R  ← π_{ma_cu_dan}(σ_{ma_ho_a ≠ ma_ho_b}(QA ⋈ QB))
KQ ← π_{ma_cu_dan, ho_ten}(CU_DAN ⋈ R)
```

Đây là câu tự kết nối. Hai bản sao của cùng một quan hệ được đổi tên cột hộ thành `ma_ho_a`, `ma_ho_b` và giữ nguyên `ma_cu_dan`, nên `QA ⋈ QB` ghép mọi cặp đợt của cùng một người. Phép chọn giữ các cặp thuộc hai hộ khác nhau, vì vậy người có hai đợt trong cùng một hộ bị loại.

Kết quả trên seed636: **54 bộ**, trích kiểm tra `QRA04` ở mục 4.12; tập kết quả đầy đủ có trong log tuần 1.

### 4.6. QRA05: Địa chỉ chưa được gán cho nhóm hộ nào

Câu hỏi: liệt kê mã và địa chỉ chuẩn của các địa chỉ chưa có nhóm hộ nào.

```text
R  ← π_{ma_dia_chi}(DIA_CHI) − π_{ma_dia_chi}(HO_CU_TRU)
KQ ← π_{ma_dia_chi, dia_chi_chuan}(DIA_CHI ⋈ R)
```

Phép hiệu lấy tập mọi mã địa chỉ trừ tập mã địa chỉ đã có hộ. Hai vế cùng một thuộc tính `ma_dia_chi` nên khả hợp. Địa chỉ có hộ mà hộ không có người ở (S05) vẫn xuất hiện trong `HO_CU_TRU`, nên không thuộc kết quả.

Kết quả trên seed636: **4 bộ**, trích kiểm tra `QRA05` ở mục 4.12; tập kết quả đầy đủ có trong log tuần 1.

### 4.7. QRA06: Cư dân có hồ sơ nhưng chưa từng có đợt cư trú

Câu hỏi: liệt kê mã và họ tên cư dân đã có hồ sơ nhưng chưa từng có đợt cư trú nào.

```text
R  ← π_{ma_cu_dan}(CU_DAN) − π_{ma_cu_dan}(QUA_TRINH_CU_TRU)
KQ ← π_{ma_cu_dan, ho_ten}(CU_DAN ⋈ R)
```

Phép hiệu lấy trên toàn tập cư dân. Người chỉ có đợt tương lai vẫn có bản ghi trong `QUA_TRINH_CU_TRU`, nên không thuộc kết quả.

Kết quả: đã khớp đáp án tay trên tiny29; chờ ghi tập kết quả trên seed636 cho bản báo cáo cuối (mục 4.12).

### 4.8. QRA07: Cư dân từng có cả thường trú và tạm trú

Câu hỏi: liệt kê mã và họ tên cư dân từng có cả đợt thường trú và đợt tạm trú, không nhất thiết cùng lúc.

```text
A  ← π_{ma_cu_dan}(σ_{loai_cu_tru = 'THUONG_TRU'}(QUA_TRINH_CU_TRU))
B  ← π_{ma_cu_dan}(σ_{loai_cu_tru = 'TAM_TRU'}(QUA_TRINH_CU_TRU))
KQ ← π_{ma_cu_dan, ho_ten}(CU_DAN ⋈ (A ∩ B))
```

Câu này dùng phép giao hai tập người. Một phép chọn với điều kiện `loai_cu_tru = 'THUONG_TRU' ∧ loai_cu_tru = 'TAM_TRU'` sẽ luôn cho kết quả rỗng, vì mỗi bộ chỉ có một giá trị loại cư trú.

Kết quả trên seed636: **31 bộ**, trích kiểm tra `QRA07` ở mục 4.12; tập kết quả đầy đủ có trong log tuần 1.

### 4.9. QRA08: Cư dân đang cư trú tại Tổ 01 hoặc Tổ 02 tại ngày d

Câu hỏi: liệt kê mã cư dân đang cư trú tại Tổ 01 hoặc Tổ 02 vào ngày 20/11/2026.

```text
HO_TO ← π_{ma_ho, ma_to}(π_{ma_ho, ma_dia_chi}(HO_CU_TRU) ⋈ π_{ma_dia_chi, ma_to}(DIA_CHI))
CD_TO ← π_{ma_cu_dan, ma_to}(π_{ma_cu_dan, ma_ho}(Q_d) ⋈ HO_TO)
T1    ← π_{ma_cu_dan}(CD_TO ⋈ π_{ma_to}(σ_{ten_to = 'Tổ 01'}(TO_DAN_PHO)))
T2    ← π_{ma_cu_dan}(CD_TO ⋈ π_{ma_to}(σ_{ten_to = 'Tổ 02'}(TO_DAN_PHO)))
KQ    ← T1 ∪ T2
```

Phép hợp gộp hai tập mã cư dân. Một người ở cả hai tổ, ví dụ thường trú ở tổ này và tạm trú ở tổ kia, chỉ xuất hiện một lần. Câu này có thể viết bằng một phép chọn với điều kiện "hoặc"; nhóm dùng `∪` để minh họa phép hợp.

Kết quả: đã khớp đáp án tay trên tiny29; chờ ghi tập kết quả trên seed636 cho bản báo cáo cuối (mục 4.12).

### 4.10. QRA09: Cư dân đã từng cư trú nhưng không còn đợt hiệu lực tại d

Câu hỏi: liệt kê mã và họ tên cư dân đã từng cư trú (có đợt bắt đầu ≤ d) nhưng không có đợt nào còn hiệu lực vào ngày 20/11/2026.

```text
DA_TUNG ← π_{ma_cu_dan}(σ_{ngay_bat_dau ≤ '2026-11-20'}(QUA_TRINH_CU_TRU))
DANG_O  ← π_{ma_cu_dan}(Q_d)
KQ      ← π_{ma_cu_dan, ho_ten}(CU_DAN ⋈ (DA_TUNG − DANG_O))
```

Cột `ngay_bat_dau` là `NOT NULL`, nên phép chọn của DA_TUNG không gặp NULL. Phép hiệu cho ra người từng ở nhưng tại d không còn đợt nào hiệu lực. Người chưa từng có đợt (kết quả của QRA06) và người chỉ có đợt tương lai đều không thuộc DA_TUNG, nên không xuất hiện ở đây.

Kết quả trên seed636: **17 bộ**, trích kiểm tra `QRA09` ở mục 4.12; tập kết quả đầy đủ có trong log tuần 1.

### 4.11. QRA10: Cư dân chuyển nội bộ giữa hai tổ dân phố khác nhau

Câu hỏi: liệt kê mã và họ tên cư dân có sự kiện chuyển nội bộ từ một hộ thuộc tổ này sang một hộ thuộc tổ khác.

```text
HO_TO ← π_{ma_ho, ma_to}(π_{ma_ho, ma_dia_chi}(HO_CU_TRU) ⋈ π_{ma_dia_chi, ma_to}(DIA_CHI))
QT_TO ← π_{ma_qua_trinh, ma_cu_dan, ma_to}(π_{ma_qua_trinh, ma_cu_dan, ma_ho}(QUA_TRINH_CU_TRU) ⋈ HO_TO)
CU    ← ρ_{CU(ma_qua_trinh_cu, ma_cu_dan, ma_to_cu)}(QT_TO)
MOI   ← ρ_{MOI(ma_qua_trinh_moi, ma_cu_dan, ma_to_moi)}(QT_TO)
NB    ← π_{ma_bien_dong, ma_qua_trinh_cu, ma_qua_trinh_moi}(
             σ_{loai_bien_dong = 'CHUYEN_NOI_BO'}(BIEN_DONG_CU_TRU))
R     ← π_{ma_cu_dan}(σ_{ma_to_cu ≠ ma_to_moi}(NB ⋈ CU ⋈ MOI))
KQ    ← π_{ma_cu_dan, ho_ten}(CU_DAN ⋈ R)
```

Bảng biến động có hai khóa ngoại cùng trỏ tới `QUA_TRINH_CU_TRU`: đợt cũ và đợt mới. Phép đổi tên tạo hai bản QT_TO có tên thuộc tính trùng với hai cột khóa ngoại, nhờ đó `NB ⋈ CU ⋈ MOI` đi theo hai nhánh nối riêng. CU và MOI cùng giữ `ma_cu_dan`, nên phép nối tự nhiên còn buộc đợt cũ và đợt mới thuộc cùng một người (quy tắc B08); sự kiện vi phạm điều này tự bị loại. Phép chọn cuối giữ sự kiện có tổ cũ khác tổ mới, nên chuyển nội bộ giữa hai hộ cùng tổ bị loại.

Kết quả trên seed636: **22 bộ**, trích kiểm tra `QRA10` ở mục 4.12; tập kết quả đầy đủ có trong log tuần 1.

### 4.12. Nhận xét

Mười câu dùng đủ bảy phép cơ bản của đại số quan hệ:

| Câu | σ | π | ⋈ tự nhiên | ⋈ theta | ρ | ∪ | ∩ | − |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| QRA01 | ✓ | ✓ | ✓ | | | | | |
| QRA02 | ✓ | ✓ | | ✓ | | | | |
| QRA03 | ✓ | ✓ | ✓ | | | | | |
| QRA04 | ✓ | ✓ | ✓ (tự nối) | | ✓ | | | |
| QRA05 | | ✓ | ✓ | | | | | ✓ |
| QRA06 | | ✓ | ✓ | | | | | ✓ |
| QRA07 | ✓ | ✓ | ✓ | | | | ✓ | |
| QRA08 | ✓ | ✓ | ✓ | | | ✓ | | |
| QRA09 | ✓ | ✓ | ✓ | | | | | ✓ |
| QRA10 | ✓ | ✓ | ✓ | | ✓ | | | |

Mỗi câu có một SQL kiểm chứng viết riêng, khác với 10 câu SQL nghiệp vụ ở Chương 5. Trên bộ dữ liệu thử nhỏ đã biết đáp án (`tests/ra_fixture.sql`), cả 10 câu cho đúng đáp án tính tay. Lần review kỹ thuật độc lập hỗ trợ TV1 đạt **146/146**, gồm 144 kiểm tra chức năng và 2 phép tái hiện; không phải 146 phép thử riêng cho đại số quan hệ. Xem [review TV3 trong nhật ký](../meetings/decision_log.md#review-tv3).

Lần kiểm chứng tuần 1 ngày 16/11 đạt **96/96**, gồm 95 kiểm tra chức năng và 1 tái hiện B15 bản cũ. [Log đầy đủ](../tests/week1_execution_results.json) lưu expected/actual và hash đầu vào; [môi trường](../tests/week1_environment.md) nêu giới hạn lần chạy. Sáu cặp RA/SQL đã khớp đầy đủ các thuộc tính sau khi chuẩn hóa mức hạt trên seed636. QRA02/03/06/08 đã khớp đáp án tay trên tiny29; log này chưa lưu kết quả bốn câu đó trên seed636. Bảng đối soát trên seed hiện hành:

| Câu | Số bộ kết quả | Câu SQL đối chiếu | Kết quả ở cùng mức hạt |
|---|---|---|---|
| QRA01 | 34 | QSQL01 | Khớp |
| QRA02 | Chờ ghi kết quả seed636 | SQL riêng trong 06a | Đã khớp đáp án tay tiny29 |
| QRA03 | Chờ ghi kết quả seed636 | SQL riêng trong 06a | Đã khớp đáp án tay tiny29 |
| QRA04 | 54 | QSQL05 | Khớp |
| QRA05 | 4 | QSQL04 | Khớp |
| QRA06 | Chờ ghi kết quả seed636 | SQL riêng trong 06a | Đã khớp đáp án tay tiny29 |
| QRA07 | 31 | QSQL06 | Khớp |
| QRA08 | Chờ ghi kết quả seed636 | SQL riêng trong 06a | Đã khớp đáp án tay tiny29 |
| QRA09 | 17 | QSQL07 | Khớp |
| QRA10 | 22 | QSQL09 | Khớp |

Khi đối soát, cần xử lý các khác biệt sau:

- Đại số loại bộ trùng, SQL thì không. QSQL01 trả thêm cột `loai_cu_tru`, nên người có hai loại cư trú xuất hiện hai dòng, trong khi QRA01 cho mỗi người một bộ. Vì vậy phải chiếu mã, tên và loại trùng trước khi so tập kết quả.
- QSQL09 trả từng sự kiện; khi so QRA10 phải chiếu `DISTINCT ma_cu_dan` rồi nối tên cư dân. Số sự kiện không được dùng thay số người.
- Đại số cổ điển không có NULL. Nhóm xử lý cột `ngay_ket_thuc` bằng bước chuẩn bị `Q_d` ở mục 4.1.
- Đại số cổ điển không có `COUNT` hay `GROUP BY`. Các câu thống kê (số người mỗi tổ, số sự kiện mỗi tháng) chỉ có ở Chương 5 và trong VIEW của Chương 6.

## CHƯƠNG 5 — SQL (10 CÂU)

5.1. Hệ quản trị và cách tạo dữ liệu [TODO – TV2]  
5.2–5.11. QSQL01–QSQL10: câu hỏi, SQL, ảnh, kết quả, nhận xét [TODO – TV2]  
5.12. Tổng hợp kiểm thử [TODO – TV2]

## CHƯƠNG 6 — BẢO MẬT CSDL

> Người viết: TV3. Reviewer được phân công: TV2. Nháp ngày 16/11/2026. Bằng chứng kỹ thuật do agent hỗ trợ ghi: [review TV3 trong nhật ký](../meetings/decision_log.md#review-tv3) và [log tuần 1 ngày 16/11](../tests/week1_execution_results.json) trên PostgreSQL 17.11, tiny29 và seed636 hiện hành. Đây không phải chữ ký review của TV2. Ảnh minh chứng sẽ chụp trên seed đã merge, hạn 24/11. Script: [sql/05_security.sql](../sql/05_security.sql). Kế hoạch chi tiết: [06b_bao_mat.md](06b_bao_mat.md).

### 6.1. Khái quát và các rủi ro

CSDL quản lý cư dân chứa thông tin cá nhân: họ tên, ngày sinh, giới tính và nơi ở theo thời gian. Ghép các thông tin này lại có thể biết một người đang sống ở đâu hoặc vừa rời khỏi địa chỉ nào. Dữ liệu của đồ án là giả lập 100%, nhưng phần bảo mật được thiết kế như khi làm với dữ liệu thật.

Ba mục tiêu bảo mật của mô hình CIA áp dụng vào đề tài như sau:

| Mục tiêu | Rủi ro trong đề tài | Biện pháp trong đồ án |
|---|---|---|
| Bí mật | Cán bộ chỉ cần số liệu tổng hợp lại đọc được họ tên, ngày sinh từng người | VIEW tổng hợp; chỉ cấp quyền trên VIEW (demo B2) |
| Toàn vẹn | Người chỉ có nhiệm vụ tra cứu tự sửa ngày kết thúc cư trú hoặc xóa sự kiện | Chỉ cấp `SELECT` (demo B1); PK, FK, CHECK; giao dịch khi ghi biến động |
| Sẵn sàng | Mất dữ liệu do xóa nhầm bảng hoặc hỏng máy | Không cấp `TRUNCATE`, `DROP` cho role nghiệp vụ; sao lưu bằng `pg_dump` |

Hai demo tập trung vào hai rủi ro đầu: lộ hồ sơ cư dân cho người không cần biết, và sửa dữ liệu trái phép. Cả hai đều dễ xảy ra hơn khi mọi người dùng chung một tài khoản quản trị.

### 6.2. Nguyên tắc phân quyền

Đồ án áp dụng nguyên tắc quyền tối thiểu: mỗi tài khoản chỉ có những quyền cần cho công việc của mình. Cụ thể:

- Mỗi vai trò có một role PostgreSQL riêng; công việc hằng ngày không dùng tài khoản `postgres`.
- Role nghiệp vụ không sở hữu bảng. Chủ sở hữu luôn có toàn quyền trên bảng của mình, nên nếu role demo là chủ sở hữu thì phép thử quyền mất ý nghĩa.
- Script thu hồi quyền mặc định của nhóm `PUBLIC` (nhóm ngầm định chứa mọi role) trước, rồi mới cấp quyền cho từng role.

Xác thực trả lời câu hỏi "bạn là ai", ví dụ đăng nhập bằng tên role và mật khẩu. Phân quyền trả lời câu hỏi "bạn được làm gì" trên từng đối tượng, bằng `GRANT` và `REVOKE`. Để đọc một bảng, role cần đủ ba tầng quyền: `CONNECT` trên database, `USAGE` trên schema và quyền tương ứng trên bảng.

Đồ án có hai thứ cùng gọi là "tài khoản". Bảng `tai_khoan` là tài khoản nghiệp vụ mô phỏng, chỉ ghi lại ai đã ghi nhận một biến động; nó không cấp hay chặn quyền nào. Role PostgreSQL là tầng quyền thật, được hệ quản trị kiểm tra trên mọi câu lệnh. Hai tầng độc lập với nhau: khóa một dòng trong `tai_khoan` không tự thu hồi role nào.

Ràng buộc toàn vẹn (PK, FK, CHECK) giữ cho dữ liệu đúng và áp dụng cho mọi người, kể cả quản trị. Ai được đọc hay sửa bảng nào thì do `GRANT` và `REVOKE` quyết định.

Mô hình phân quyền của đồ án:

| Role | Tác nhân (đặc tả mục 3) | 6 bảng nghiệp vụ | `tai_khoan` | VIEW thống kê |
|---|---|---|---|---|
| `postgres` | Quản trị CSDL: tạo bảng, role, cấp quyền | Chủ sở hữu | Chủ sở hữu | Chủ sở hữu |
| `csdl17_admin` | Cán bộ quản lý cư dân | SELECT, INSERT, UPDATE, DELETE | SELECT, INSERT, UPDATE, DELETE | SELECT |
| `csdl17_reader` | Cán bộ tổng hợp, mức tra cứu chi tiết | Chỉ SELECT | Không | Không |
| `csdl17_report` | Cán bộ tổng hợp, mức chỉ xem số liệu tổng hợp | Không | Không | Chỉ SELECT |

Role `reader` minh họa việc giới hạn thao tác (demo B1), còn role `report` minh họa việc giới hạn dữ liệu nhìn thấy (demo B2).

### 6.3. Demo B1: GRANT/REVOKE cho tài khoản chỉ đọc

Mục tiêu: cho thấy `csdl17_reader` tra cứu được nhưng không sửa được dữ liệu, và dữ liệu không đổi sau khi role này thử sửa.

Trích đoạn minh họa quyền dưới `postgres`, **không chạy riêng khối này**. Khi thực thi, dùng đầy đủ [05_security.sql](../sql/05_security.sql), gồm preflight trước mọi thay đổi và transaction thiết lập. Với psql, script tự bật `ON_ERROR_STOP`; với GUI, chạy trọn khối thiết lập và chỉ tiếp tục khi đã COMMIT thành công:

```sql
CREATE ROLE csdl17_reader LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO csdl17_reader;
GRANT SELECT ON to_dan_pho, dia_chi, ho_cu_tru, cu_dan,
                qua_trinh_cu_tru, bien_dong_cu_tru TO csdl17_reader;
```

Trước khi tạo role, script kiểm tra các role đã có sẵn. Nếu một role demo đã tồn tại với quyền quá cao (superuser, sở hữu bảng, là thành viên role khác…), script dừng và rollback toàn bộ phần thiết lập.

| Bước | Lệnh (chạy dưới `csdl17_reader`) | Kết quả mong đợi | Ảnh |
|---|---|---|---|
| 1 | `SELECT current_user;` | `csdl17_reader` | `SEC_B1_select_ok.png` |
| 2 | `SELECT ma_cu_dan, ho_ten, ngay_sinh, gioi_tinh FROM cu_dan ... LIMIT 5;` | Trả về dữ liệu | `SEC_B1_select_ok.png` |
| 3 | `UPDATE cu_dan SET ghi_chu = ... WHERE ma_cu_dan = 1;` | `ERROR: permission denied for table cu_dan` | `SEC_B1_denied.png` |
| 4 | `INSERT INTO to_dan_pho ...;` và `DELETE FROM qua_trinh_cu_tru ...;` | `permission denied` cho từng bảng | `SEC_B1_denied.png` |
| 5 | `SELECT * FROM tai_khoan;` | `permission denied for table tai_khoan` | `SEC_B1_denied.png` |
| 6 | (dưới `postgres`) xem lại dòng `ma_cu_dan = 1` | Giống hệt trước bước 3 | `SEC_B1_unchanged.png` |

[ẢNH B1: chụp trên seed chính thức, hạn 24/11]

PostgreSQL kiểm tra quyền trước khi thực hiện câu lệnh. `csdl17_reader` chỉ có `SELECT`, nên mọi lệnh ghi bị từ chối và không dòng nào thay đổi. Để đối chứng, cùng lệnh `UPDATE` đó chạy dưới `csdl17_admin` trong một giao dịch rồi `ROLLBACK` thì thành công. Lệnh đúng cú pháp và thỏa ràng buộc; nó bị chặn chỉ vì thiếu quyền.

### 6.4. Demo B2: VIEW giới hạn dữ liệu

Mục tiêu: cho thấy `csdl17_report` xem được số cư dân theo tổ qua VIEW nhưng không đọc được các bảng gốc chứa họ tên và ngày sinh.

Trích đoạn VIEW/quyền dưới `postgres`, **không phải khối thiết lập độc lập**. Chạy đầy đủ [05_security.sql](../sql/05_security.sql) để kiểm tra role và cấp đủ quyền database/schema trước demo:

```sql
CREATE OR REPLACE VIEW vw_thong_ke_cu_dan_theo_to
WITH (security_invoker = false) AS
SELECT t.ma_to, t.ten_to, COUNT(DISTINCT q.ma_cu_dan) AS so_cu_dan
FROM to_dan_pho t
LEFT JOIN dia_chi d          ON d.ma_to = t.ma_to
LEFT JOIN ho_cu_tru h        ON h.ma_dia_chi = d.ma_dia_chi
LEFT JOIN qua_trinh_cu_tru q ON q.ma_ho = h.ma_ho
                            AND q.ngay_bat_dau <= DATE '2026-11-20'
                            AND (q.ngay_ket_thuc IS NULL
                                 OR q.ngay_ket_thuc >= DATE '2026-11-20')
GROUP BY t.ma_to, t.ten_to;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM csdl17_report;
GRANT SELECT ON vw_thong_ke_cu_dan_theo_to TO csdl17_report;
```

| Bước | Lệnh (chạy dưới `csdl17_report`) | Kết quả mong đợi | Ảnh |
|---|---|---|---|
| 1 | (dưới `postgres`) `pg_get_viewdef(...)` | VIEW chỉ có `ma_to`, `ten_to`, `so_cu_dan` | `SEC_B2_viewdef.png` |
| 2 | `SELECT current_user;` | `csdl17_report` | `SEC_B2_view_ok.png` |
| 3 | `SELECT * FROM vw_thong_ke_cu_dan_theo_to;` | Mỗi tổ một dòng, kể cả tổ 0 người | `SEC_B2_view_ok.png` |
| 4 | `SELECT ho_ten, ngay_sinh FROM cu_dan;` | `ERROR: permission denied for table cu_dan` | `SEC_B2_denied.png` |
| 5 | `SELECT * FROM qua_trinh_cu_tru;` | `permission denied for table qua_trinh_cu_tru` | `SEC_B2_denied.png` |

[ẢNH B2: chụp trên seed chính thức, hạn 24/11]

VIEW do chủ sở hữu bảng tạo, ở chế độ mặc định `security_invoker = false`, nên VIEW đọc bảng nền bằng quyền của chủ sở hữu VIEW. `csdl17_report` chỉ có quyền trên VIEW, vì vậy nhận được số liệu tổng hợp mà không xem được họ tên hay ngày sinh của ai. Nếu đặt `security_invoker = true` (có từ PostgreSQL 15), VIEW sẽ kiểm tra quyền của người gọi trên bảng nền, và role report bị từ chối cả khi đọc VIEW.

Kết quả VIEW trùng từng dòng với QSQL03 cho cùng ngày 20/11/2026 trong kiểm tra `w1_seed/VIEW-vs-QSQL03` của [log tuần 1](../tests/week1_execution_results.json). Seed636 hiện hành cho số người ở Tổ 01–08 lần lượt **34, 29, 21, 33, 41, 30, 11, 0**; Tổ 08 vẫn có một dòng dù không có người. Đây là số người phân biệt trong từng tổ; không cộng các tổ để suy ra tổng người duy nhất toàn phường.

### 6.5. Đánh giá

Cả hai demo chạy bằng role thật. Khi chạy toàn bộ script có đúng 6 lỗi `permission denied` cố ý và không lỗi nào khác. TV1 đã kiểm chứng hai cách chạy, chuyển role bằng `SET ROLE` và đăng nhập trực tiếp bằng role; dữ liệu của 7 bảng không đổi sau các lệnh bị từ chối. Script chạy lại được an toàn vì có bước kiểm tra role có sẵn, và toàn bộ phần thiết lập nằm trong một giao dịch nên lỗi ở đâu cũng rollback hết.

Các hạn chế:

- Số liệu tổng hợp vẫn có thể lộ thông tin khi nhóm quá nhỏ. Nếu một tổ chỉ có 1 người, con số kết hợp với hiểu biết bên ngoài có thể giúp đoán ra người đó. Có thể khắc phục bằng cách chỉ hiển thị tổ có từ k người trở lên.
- VIEW dùng ngày tham chiếu cố định 20/11/2026 để kết quả tái lập được. Khi dùng thật sẽ thay bằng `CURRENT_DATE`.
- Đồ án chưa demo bảo mật mức dòng (Row-Level Security), ví dụ mỗi cán bộ chỉ xem cư dân thuộc tổ mình phụ trách.
- Đồ án chưa cấu hình xác thực thật (mật khẩu mạnh, `pg_hba.conf`, mã hóa kết nối TLS) và chưa bật ghi nhật ký truy cập. Các bước này cần khi triển khai thật và nằm ngoài phạm vi bài tập.

Hướng mở rộng gồm Row-Level Security theo tổ, ngưỡng k cho VIEW tổng hợp, ghi nhật ký truy cập bằng `log_statement` và `log_connections`, và sao lưu định kỳ bằng `pg_dump` kèm thử khôi phục bằng `pg_restore`.

## KẾT LUẬN

- Các yêu cầu đã thực hiện, hạn chế và hướng mở rộng [TODO – TV1]

## TÀI LIỆU THAM KHẢO

- PostgreSQL 17 Documentation — [Constraints](https://www.postgresql.org/docs/17/ddl-constraints.html).
- PostgreSQL 17 Documentation — [Range Types](https://www.postgresql.org/docs/17/rangetypes.html).
- [Đặc tả nghiệp vụ của nhóm](03_dac_ta_nghiep_vu.md), bản bàn giao 11/11/2026.
- [Từ điển dữ liệu và chuẩn hóa](04_data_dictionary_va_chuan_hoa.md), bản bàn giao 11/11/2026.
- PostgreSQL 17 Documentation — [Privileges](https://www.postgresql.org/docs/17/ddl-priv.html), [GRANT](https://www.postgresql.org/docs/17/sql-grant.html), [REVOKE](https://www.postgresql.org/docs/17/sql-revoke.html) (Chương 6).
- PostgreSQL 17 Documentation — [CREATE VIEW](https://www.postgresql.org/docs/17/sql-createview.html), tùy chọn `security_invoker` (Chương 6).
- PostgreSQL 17 Documentation — [Database Roles](https://www.postgresql.org/docs/17/user-manag.html), [Role Membership](https://www.postgresql.org/docs/17/role-membership.html) (Chương 6).
- [Đại số quan hệ QRA01–QRA10](06a_dai_so_quan_he.md) và [kế hoạch bảo mật](06b_bao_mat.md) của nhóm (Chương 4, 6).
- Giáo trình học phần: chờ nhóm bổ sung đúng tài liệu thực sự sử dụng.

## PHỤ LỤC

- Từ điển dữ liệu; mã DDL/seed/query; bảng kiểm thử [TODO]

## TRANG CUỐI: PHÂN CÔNG, ĐÁNH GIÁ VÀ CHỮ KÝ

| STT | Họ tên | MSSV | Công việc thực tế | Xếp loại A/B/C... | Chữ ký |
|---|---|---|---|---|---|
| 1 | Trần Bùi Tùng Linh | 20227057 | Theo hồ sơ bàn giao tuần 1; cập nhật cuối kỳ | Chờ nhóm đánh giá | Chờ ký |
| 2 | Trần Tuấn Ngọc | 20227064 | Theo hồ sơ bàn giao tuần 1; cập nhật cuối kỳ | Chờ nhóm đánh giá | Chờ ký |
| 3 | Dương Ngọc Ninh | 20237469 | Theo hồ sơ bàn giao tuần 1; cập nhật cuối kỳ | Chờ nhóm đánh giá | Chờ ký |
