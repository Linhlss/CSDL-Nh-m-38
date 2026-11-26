# QA bộ slide CSDL Nhóm 38

Hai tệp có **36 trang**, gồm hai trang nhận diện HUST, 20 slide nội dung, ba trang phân phần và 11 slide hỏi đáp A01–A11. Có ghi chú cho 34 trang kể từ bìa đề tài. Khung **20 phút** bắt đầu ở trang 3.

| Hạng mục | Kết quả và bằng chứng |
|---|---|
| Mẫu HUST | Dùng `Slide/HUST_PPT_template_2022_Blue_16x9.pptx`. Hai trang mở đầu khớp nguyên byte với XML trang và các tệp quan hệ trong mẫu. Kích thước 12.192.000 × 6.858.000 EMU, tỷ lệ 16:9. Ba trang phân phần 4, 13 và 19 dùng bố cục HUST xanh bên trái từ layout 11. Bên phải có số phần và chủ đề. Kiểm byte 44 thành phần gốc thuộc master, layout, theme và media. |
| Chỉnh sửa | Tiêu đề, nội dung, công thức, mã SQL và các sơ đồ minh họa của bản trình bày dùng đối tượng chỉnh sửa được. 14 slide có bảng PowerPoint. Ba ảnh sơ đồ là ảnh nhúng có SHA-256 khớp tệp nguồn. |
| Ảnh sơ đồ | Cây phân rã chức năng dùng `Báo_cáo_CSDL_nhóm_38/image/phan_ra_chuc_nang.png` ở trang 7. ERD Chen dùng `erd.png` ở trang 9. Lược đồ bảy bảng dùng `diagrams/erd_v1.png` ở trang 10. Hai ảnh sau được cắt lề trắng bằng thiết lập hiển thị trong slide. |
| Nội dung và số liệu | Các bảng QSQL lấy từ tập kết quả đã lưu và được đối chiếu lại trên CSDL dựng mới bằng PostgreSQL 17.12. Cả 13 câu (QSQL01–QSQL13) khớp giá trị và thứ tự. Seed gồm 8 + 50 + 60 + 200 + 5 + 250 + 63 = 636. |
| RA và SQL | Phần RA theo Chương 4 và log ngày 22/11. Phần SQL dùng QSQL01–QSQL13 của Chương 5: mười câu chính có ảnh pgAdmin, ba câu bổ sung QSQL11–13 theo `sql/07_queries_bo_sung.sql`. A06/A07 chứa toàn bộ mã QSQL03/QSQL09, khớp mã trong báo cáo sau khi chuẩn hóa khoảng trắng. |
| Bảo mật | Trang 23–24 nhúng bốn ảnh đăng nhập trực tiếp từ commit d33ff07 của TV3. Ảnh B1 cho thấy số đếm 200 và các lỗi quyền của reader. Ảnh B2 cho thấy VIEW ba cột, tám tổ và hai lỗi khi đọc bảng gốc. Định nghĩa VIEW trong ảnh phụ lục báo cáo dùng CURRENT_DATE. |
| Render và chỉnh bố cục | Lần sửa ngày 26/11 đồng bộ với báo cáo: sửa trực tiếp các trang 12, 15, 18, 22, 30, 33, 35 trong PPTX, xuất PDF và ảnh duyệt bằng Microsoft PowerPoint, giữ nguyên byte các thành phần mẫu HUST. `check_deck.py` chạy đạt trên cặp PPTX/PDF. |
| Thời lượng | Khung 20 phút chia thành ba lượt. Linh 7 phút 40 giây, Ngọc 4 phút 55 giây và Ninh 7 phút 25 giây, đã tính ba trang phân phần. |
| Phạm vi cập nhật | A11 giải thích B09 theo Phụ lục A của báo cáo. Phần chính giữ 10 truy vấn Ngọc đã chạy, thêm dòng nhắc QSQL11–13, và hai cặp ảnh B1/B2. A08 thêm ca X07 (23505). |

## Bản xem trước

- [Trang 01–06](preview/01-06.jpg)
- [Trang 07–12](preview/07-12.jpg)
- [Trang 13–18](preview/13-18.jpg)
- [Trang 19–24](preview/19-24.jpg)
- [Trang 25–30](preview/25-30.jpg)
- [Trang 31–36](preview/31-36.jpg)

Các bảng kết quả được chép từ log PostgreSQL. Nhãn thuộc tính trong các sơ đồ gốc có cỡ chữ nhỏ khi chiếu xa. Mỗi trang sơ đồ có chú giải riêng để hỗ trợ trình bày. PDF dự phòng có font nhúng. Bản trước xuất bằng LibreOffice; bản hiện tại mở và xuất bằng Microsoft PowerPoint. Máy chiếu của lớp chưa được kiểm tra. Các mốc được phân bổ theo kịch bản, chưa đo trên phần nói của ba thành viên.

## Đối chiếu từng trang

| Trang | Kiểm tra nội dung và ảnh render |
|---|---|
| Mở đầu 1 | Trang nhận diện, logo và khẩu hiệu HUST nguyên gốc. |
| Mở đầu 2 | Trang nền chuyển tiếp nguyên gốc của mẫu. |
| 01 | Bìa đúng tên đề tài, lớp, giảng viên và ba sinh viên. |
| Phần 1 | Chủ đề Bài toán và thiết kế CSDL. |
| 02 | Tình huống chuyển hộ, ba câu hỏi nghiệp vụ và hệ quả khi chỉ lưu một địa chỉ. |
| 03 | Phạm vi một phường, luồng hai đợt và một biến động, PostgreSQL 17. |
| 04 | Ảnh cây phân rã gốc, đủ 6 nhóm và 14 chức năng. |
| 05 | Đủ bảy thực thể, làm rõ vai trò của quá trình cư trú. |
| 06 | Ảnh ERD Chen từ `erd.png` với chú giải các liên kết chính. |
| 07 | Ảnh lược đồ `diagrams/erd_v1.png`, có chú giải 7 bảng, 35 cột, 7 PK, 7 FK và hai FK đợt có thể NULL tùy loại biến động. |
| 08 | Tách bảng theo FD, kết luận cả bảy bảng đạt BCNF. |
| 09 | B06, B09 và B10 có sơ đồ riêng trong cùng trang. B10 nêu ba hàm chuyển nội bộ, chuyển đi, chuyển đến. |
| Phần 2 | Chủ đề Dữ liệu, SQL và kiểm thử. |
| 10 | Tổng từ bảy bảng bằng 636. |
| 11 | Danh mục QSQL01–QSQL13: mười câu chính và một dòng nêu ba câu bổ sung. QSQL02 dùng ngưỡng bốn cư dân. |
| 12 | QSQL03 giữ đủ tám tổ. Tổ 08 có số đếm bằng 0. |
| 13 | QSQL09 trình bày hai nhánh nối và ba dòng đầu của 22 lần chuyển giữa hai tổ. |
| 14 | Đối chiếu toàn bộ kết quả của 13 truy vấn trên bộ 636 bản ghi. |
| Phần 3 | Chủ đề Đại số quan hệ và bảo mật. |
| 15 | Danh mục RA 1–10 đúng LaTeX. |
| 16 | RA 3 dùng đầu vào 5 cột, có 23 bộ và khớp với SQL đối chứng riêng theo log Chương 4. |
| 17 | RA 9 xác nhận tài khoản 1–4 đủ ba loại. Tài khoản 5 chưa ghi. QSQL13 là cách viết SQL bằng hai lớp NOT EXISTS. |
| 18 | Hai ảnh B1 xác nhận đăng nhập bằng reader, đếm được 200 cư dân và bị từ chối quyền ghi, đọc bảng tài khoản. |
| 19 | Hai ảnh B2 xác nhận đăng nhập bằng report, đọc được VIEW và bị từ chối đọc trực tiếp hai bảng gốc. |
| 20 | Bố cục kết thúc theo template, kết luận và hỏi đáp. |
| A01 | 10 câu RA, phép toán và số bộ minh họa. |
| A02 | Bốn bước RA 3 đọc được bằng chỉ số gạch dưới. |
| A03 | Công thức chia và ý nghĩa từng quan hệ chiếu. |
| A04 | Phép hiệu, giao và hợp đúng câu 4–6. |
| A05 | Mã, yêu cầu nghiệp vụ, kỹ thuật và số dòng của QSQL01–QSQL13 (QSQL11–13: 14, 5, 4 dòng). |
| A06 | Câu QSQL03 đầy đủ và bảng tám tổ. |
| A07 | Câu QSQL09 đầy đủ và ba dòng đầu của kết quả. |
| A08 | B06: 23P01. B09: 23514. B10: 23503 và hoàn tác; ba hàm chuyển chạy hợp lệ. X07: UNIQUE `uq_bd_dot_cu` trả 23505. |
| A09 | Catalog 15/15, reader 12/12, report 10/10 và B12 K01–K05. |
| A10 | Seed636, 13 QSQL khớp, 10 câu RA có SQL đối chứng, kết quả B3 200/0/8 và giới hạn. |
| A11 | B09 dùng ngày t−1 cho kết thúc đợt cũ, ngày t cho đợt mới và trả 23514 khi ngày lệch. Bảng nêu hai trigger và thao tác kích hoạt. |

## Dấu vết tệp

| Tệp | SHA-256 |
|---|---|
| PPTX | `f2fee22ed0948013cfa43ef20405a3f7d98418d980c809bd667febf422a9a69f` |
| PDF dự phòng | `a9f3470f5bf4df615e1cae51298978477dd9adac49a8ab7c7910579120fc6394` |
| Template HUST | `0bc59aff84b8df880709d6d0f86633d85635fe22d4000ac783593d3e218426fa` |
| PDF báo cáo hiện hành | `36a7a7d64517bd625e95b7b6345ce6c35743edd7dbea66f829b967dd14ed1000` |

Nguồn từng slide xem [SOURCE_MAP.md](SOURCE_MAP.md). Mốc thời lượng và lời chuyển xem [SPEAKER_NOTES.md](SPEAKER_NOTES.md). Cách sửa bằng PowerPoint và tái tạo xem [README.md](README.md).
