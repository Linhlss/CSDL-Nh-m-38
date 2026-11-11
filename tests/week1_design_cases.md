# TÌNH HUỐNG KIỂM TRA THIẾT KẾ TUẦN 1

**Mốc:** d=20/11/2026. **Thực hiện:** TV1, 11/11/2026. Đây là đối chiếu mô hình và đáp án trên giấy; không ghi nhận là test DB đã chạy. A/B, H1/H2 là mã tượng trưng cho nhân vật/hộ giả lập.

| ID | Đầu vào / tình huống | Kết quả thiết kế kỳ vọng | Cơ chế hiện tại / nơi thực hiện tiếp |
|---|---|---|---|
| D01 | Một tổ chưa có địa chỉ, một địa chỉ chưa có hộ | Được phép; QRA05/QSQL04 lấy đúng địa chỉ chưa có hộ | B01; FK chỉ ràng buộc phía con |
| D02 | Hộ có địa chỉ nhưng không có đợt cư trú | Được phép; không coi là địa chỉ chưa có hộ | B01–B02; QSQL03 vẫn giữ tổ khi số người=0 |
| D03 | Hai cư dân cùng họ tên, mã khác | Giữ hai người | PK cư dân; phép tập hợp và đếm theo mã |
| D04 | Đợt 20/11–20/11 | Hợp lệ và hiệu lực tại d | CHECK ngày; B04–B05 |
| D05 | Đợt 01/11–20/11 | Hiệu lực tại d | So sánh kết thúc >=d |
| D06 | Đợt 01/11–19/11 | Không hiệu lực tại d | B05; không chỉ kiểm NULL |
| D07 | Đợt 25/11–NULL | Không hiệu lực tại d; không thuộc QRA09/QSQL07 nếu đây là đợt duy nhất | B05, B16 |
| D08 | A thường trú 01/11–20/11 và thường trú 20/11–NULL | Không hợp lệ: trùng ngày 20/11 | B06; exclusion constraint tuần 2 |
| D09 | A thường trú 01/11–19/11 và thường trú 20/11–NULL | Hợp lệ: hai đợt kề nhau không giao | B06; kiểm biên tuần 2 |
| D10 | A thường trú và tạm trú cùng hiệu lực | Được phép theo mô hình; đếm một người trong một nhóm | B06, B17; COUNT DISTINCT |
| D11 | Kết thúc trước bắt đầu | Không hợp lệ | `ck_qt_ngay`; S18 chạy tuần 2 |
| D12 | Chuyển đến có đợt cũ hoặc không có đợt mới | Không hợp lệ | `ck_bd_hinh_dang` |
| D13 | Chuyển đi có đợt mới hoặc không có đợt cũ | Không hợp lệ | `ck_bd_hinh_dang` |
| D14 | Nội bộ thiếu một FK, hoặc hai FK là cùng một mã đợt | Không hợp lệ | `ck_bd_hinh_dang`; S19 và ca cùng mã tuần 2 |
| D15 | Nội bộ: đợt cũ của A, đợt mới của B | Không hợp lệ dù hai FK tồn tại | B08; trigger cả sự kiện và sửa đợt, tuần 2 |
| D16 | Nội bộ: cùng người, cùng hộ, hai mã đợt khác nhau | Không hợp lệ | B08; trigger tuần 2 |
| D17 | Nội bộ: cùng người, hai hộ cùng tổ; ngày chuyển 15/11, cũ kết thúc 14/11, mới bắt đầu 15/11 | Hợp lệ về nghiệp vụ; bị loại khỏi QRA10/QSQL09 vì cùng tổ | B08–B09; ca đối chứng S13 |
| D18 | Nội bộ khác tổ, cùng người, ngày như D17 | Hợp lệ và thỏa QRA10/QSQL09 | Đủ hai đường FK Q→H→D→T |
| D19 | Sự kiện ngày 15/11 nhưng đợt mới bắt đầu 16/11 hoặc đợt cũ chưa đóng | Không hợp lệ | B09; trigger tuần 2 |
| D20 | Ghi chuyển đến ngày 15/11 và đợt mới bắt đầu 15/11; ghi chuyển đi ngày 21/11 và cũ kết thúc 20/11 | Hai ví dụ hợp lệ | B09; kiểm cả ba loại tuần 2 |
| D21 | Đóng đợt cũ thành công nhưng tạo đợt mới lỗi | Phải rollback; đợt cũ vẫn ở trạng thái trước giao dịch | B10; test transaction tuần 2 |
| D22 | Sửa hộ của đợt đã được sự kiện tham chiếu làm hai đợt cùng hộ | Phải bị từ chối hoặc sửa đồng bộ trong giao dịch hợp lệ | B08/B10; kiểm chiều cập nhật ngược tuần 2 |
| D23 | Đổi địa chỉ của hộ đã có lịch sử để biểu diễn chuyển cả hộ | Không thực hiện; tạo hộ mới và các đợt/sự kiện tương ứng | B11; bảo vệ liên kết lịch sử tuần 2 |
| D24 | Xóa cư dân/hộ/đợt đang có FK tham chiếu | Bị từ chối; không cascade lịch sử | FK mặc định NO ACTION; test âm tuần 2 |
| D25 | QRA03: sinh 20/11/1966; sinh 21/11/1966 | Người thứ nhất đủ điều kiện tuổi, người thứ hai không; cả hai còn phải ở Tổ 01 tại d | Cột ngày sinh và đường nối đầy đủ |
| D26 | Hai đợt của A nhưng đều thuộc H1 | Không thỏa QRA04/QSQL05 | Phân biệt số đợt với số hộ |
| D27 | Hồ sơ A chưa có đợt; B chỉ có đợt tương lai; C đã kết thúc mọi đợt trước d | QRA06 lấy A; QRA09/QSQL07 lấy C; B không thuộc hai kết quả | B16; các tập dùng khóa cư dân |
| D28 | Một tổ 0 cư dân và một tài khoản 0 sự kiện | QSQL03/QSQL10 phải có dòng số lượng 0 | LEFT JOIN; COUNT đúng cột phải |
| D29 | Hai tên tổ giống nhau hoặc hai địa chỉ cùng tổ và cùng chuỗi chuẩn | Bị từ chối; cùng chuỗi địa chỉ ở hai tổ khác nhau được phép | UNIQUE đúng miền nghiệp vụ |
| D30 | Ngày sinh hoặc ngày lập hộ sau ngày bắt đầu cư trú; tên chỉ khoảng trắng | Dataset chính thức không chấp nhận | B15; kiểm đầu vào/seed tuần 2, DDL v1 chưa tự chặn |

**Kết quả tự đối chiếu:** 30 tình huống có quy tắc, đầu ra kỳ vọng và nơi kiểm soát rõ. Các tình huống không đòi thêm bảng/cột. Mục có cơ chế “tuần 2” chưa được thực thi, cần owner tuần 2 viết test dương/âm tương ứng và lưu expected/actual thật. Reviewer chéo: chờ TV2/TV3.
