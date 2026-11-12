# HỒ SƠ QUYẾT ĐỊNH VÀ GATE 1 — BỘ BÀN GIAO TV1

**Ngày chuẩn bị:** 11/11/2026. **Mốc Gate 1 theo kế hoạch:** 15/11/2026.  
Đây là hồ sơ kỹ thuật TV1 chuẩn bị để người tiếp theo review, không phải biên bản giả định một cuộc họp đã diễn ra. Chưa có xác nhận hoặc chữ ký thay TV2/TV3.

## 1. Quyết định áp dụng cho bộ bàn giao local

| ID | Chủ đề | Quyết định kỹ thuật đã dùng | Ảnh hưởng / căn cứ |
|---|---|---|---|
| DEC01 | Phạm vi | Một phường mô phỏng; giữ 7 bảng, 3 loại biến động, 6 nhóm chức năng | Theo đề cương và yêu cầu người dùng hoàn tất đúng tuần 1 |
| DEC02 | Phiên bản | `v1-candidate`; giữ nguyên cấu trúc SQL v0, chỉ bổ sung chú thích bàn giao | Không buộc TV2/TV3 đổi cột hoặc viết lại JOIN |
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

Các quyết định là phương án TV1 đã hiện thực trong tài liệu local để bàn giao. Nhóm có thể yêu cầu điều chỉnh khi review; chưa ghi là cả ba đã đồng ý. Thông tin mã lớp, họ tên/MSSV, giảng viên và thông báo gốc còn chờ nhóm cung cấp; không ngăn việc đọc/triển khai kỹ thuật theo ứng viên v1.

## 2. Ma trận khả năng đáp ứng câu hỏi và review

Đã tự đối chiếu 20/20 câu hỏi với trường dữ liệu và FK trong `../docs/07_ma_tran_truy_van_va_review.md`. Đã đọc tài liệu RA của PR #1 tại commit c0f3580 và lưu RV01–RV10; không nhận xét thay rằng phần RA đã được duyệt cuối hoặc chạy lại DB thành công. RV08 về NULL/đại số cổ điển là nội dung TV3 cần xử lý tiếp; không đòi đổi schema.

## 3. Đối chiếu đủ 20 mã việc của TV1

“Sẵn sàng review” nghĩa là phần sản phẩm của TV1 đã có và đã tự kiểm tra, chưa tương đương checkbox nghiệm thu có reviewer ở checklist gốc.

| Mã | Đầu ra đã chuẩn bị | Trạng thái bàn giao |
|---|---|---|
| W1-T1-01 | Phạm vi và đối chiếu yêu cầu học thuật trong đặc tả mục 1 | Sẵn sàng review; yêu cầu chính thức hiện dựa trên đề cương, thông báo gốc chưa có trong workspace |
| W1-T1-02 | Bảng thuật ngữ, đặc tả mục 2 | Sẵn sàng review |
| W1-T1-03 | Bài toán, giới hạn, tác nhân, đặc tả mục 1/3 | Sẵn sàng review |
| W1-T1-04 | P1–P6 có đầu vào/điều kiện/xử lý/đọc ghi/đầu ra/lỗi, mục 6 | Sẵn sàng review |
| W1-T1-05 | B01–B03, bảng cardinality trong từ điển | Sẵn sàng review |
| W1-T1-06 | B04–B06, ví dụ và D04–D10 | Sẵn sàng review |
| W1-T1-07 | B07–B10, P4/P5 và D12–D22 | Sẵn sàng review |
| W1-T1-08 | Sơ đồ chức năng .drawio/.png/.svg | Sẵn sàng review; đã xem ảnh xuất |
| W1-T1-09 | Bảng 7 thực thể Chương 2 và ERD | Sẵn sàng review |
| W1-T1-10 | ERD đủ thuộc tính, khóa, cardinality và tính tùy chọn | Sẵn sàng review; đã xem ảnh xuất |
| W1-T1-11 | Hai FK vai trò cũ/mới và D12–D18 | Sẵn sàng review |
| W1-T1-12 | Ánh xạ 7 quan hệ, từ điển mục 2 | Sẵn sàng review |
| W1-T1-13 | 35 cột đầy đủ kiểu, NULL, khóa, miền, default và mô tả | Sẵn sàng review |
| W1-T1-14 | Khóa ứng viên, FD, phân tích 1NF–3NF và giới hạn kết luận | Bản nháp tuần 1 sẵn sàng review; điểm ngày sự kiện đã công bố, cần chốt luận chứng tuần 2 |
| W1-T1-15 | DDL đối chiếu ERD/từ điển; cấu trúc giữ nguyên v0 | Sẵn sàng review; chưa là log chạy PostgreSQL |
| W1-T1-16 | Ma trận cơ chế ràng buộc và ca thiết kế | Sẵn sàng triển khai tuần 2 |
| W1-T1-17 | Ma trận 20 câu hỏi; RV01–RV10 từ đọc tài liệu RA | Tự đối chiếu xong; chờ TV2/TV3 phản hồi bộ thiết kế |
| W1-T1-18 | Mở đầu và Chương 1–3 trong bản báo cáo nháp | Sẵn sàng review; phần dữ liệu TV2 vẫn được ghi đang chờ |
| W1-T1-19 | Hồ sơ quyết định, tiêu chí và phiếu Gate 1 | Đã chuẩn bị cho bàn giao; chờ cuộc review/xác nhận thật của nhóm |
| W1-T1-20 | Gói `v1-candidate`, hướng dẫn bàn giao và manifest | Đã chuẩn bị ứng viên; chưa gắn trạng thái schema v1 đã được cả nhóm duyệt |

## 4. Phiếu Gate 1

| Hạng mục | Tự kiểm tra của TV1 | Xác nhận chéo |
|---|---|---|
| Đặc tả và cây chức năng | Có sản phẩm | Chờ TV3 |
| ERD, lược đồ, từ điển, chuẩn hóa nháp | Có sản phẩm; công bố điểm chuẩn hóa cần chốt tiếp | Chờ TV2/TV3 |
| Khả năng đáp ứng 10 RA + 10 SQL | Đã đối chiếu thiết kế 20 câu | Chờ owner hai phần xác nhận |
| Phương án 2 demo bảo mật | Đã có yêu cầu role/VIEW trong kế hoạch; không cần đổi bảng lõi | Chờ TV3 xác nhận triển khai |
| DDL, sơ đồ và tài liệu thống nhất | Chạy bộ tự kiểm tra ở `tests/week1_verification_log.md` | Chờ TV2 |
| Quyết định / phiên bản chung | Ứng viên v1 sẵn sàng | Chưa có đồng ý của cả ba |

**Trạng thái:** SẢN PHẨM TV1 SẴN SÀNG BÀN GIAO REVIEW. **Gate 1 của cả nhóm:** CHỜ REVIEW, chưa PASS. Không điền ngày họp, chữ ký hoặc lời xác nhận thay người khác.

## 5. Phiếu cho người nhận tiếp tục

| Người / thời điểm | Nội dung cần xác nhận | Kết quả |
|---|---|---|
| TV2 — sau khi đọc bộ bàn giao | Đủ cột/miền/quan hệ để sinh dữ liệu và viết 10 SQL; phản hồi câu hỏi còn mơ hồ | Chờ người nhận ghi |
| TV3 — sau khi đọc bộ bàn giao | ERD biểu diễn đúng 10 RA; tiếp nhận RV08; hai demo bảo mật khả thi | 11/11/2026, TV3: xác nhận cả ba điểm; RV08 đã sửa trong `docs/06a_dai_so_quan_he.md` v0.1. Còn mở E1 (DEC06, chờ TV1 trả lời). `tests/ra_fixture.sql` chạy lại trên v1-candidate: 11/11 khớp. Chi tiết: `docs/REVIEW_TV3_ERD_TUAN_1.md`. Chưa ký PASS Gate 1 |
| Cả nhóm — Gate 1 dự kiến 15/11 | Đồng ý hoặc yêu cầu sửa DEC01–DEC12; ghi phiên bản và lỗi còn mở | Chờ xác nhận thật |

Các Gate 2 (22/11), Gate 3 (24/11), Gate 4 (26/11) chưa được thực hiện trong gói tuần 1.

## 6. Tiếp nhận review TV3 — 12/11/2026

- TV1 đã đọc phiếu TV3 tại PR #1, commit `7abe4d5`: xác nhận đủ đường nối 10 RA/B1/B2 và tiếp nhận bản sửa RV08. Đây là lời xác nhận của TV3 trong nhánh của họ; giữ nguyên tác giả và không ký thay.
- **E1: TV1 đã trả lời bằng DEC06 cập nhật.** Giữ schema để TV2/TV3 tiếp tục dùng giao diện đã bàn giao; không coi ghi trùng là hợp lệ về nghiệp vụ. Validation liệt kê đầy đủ các mã sự kiện trùng theo từng vai trò; TV2/TV1 xử lý nguồn nhập hoặc hiệu chỉnh trước nghiệm thu, rồi chạy lại tới 0 dòng.
- B09 có truy vấn đối chiếu ngày và bộ test riêng; không thay thế trigger/transaction tuần 2.
- Báo cáo độc lập và trạng thái từng phát hiện: [review TV3 chi tiết](../docs/REVIEW_TV3_CHI_TIET.md).
- Gate 1 của cả nhóm **CHỜ REVIEW**: còn cần TV2 xác nhận và TV3 tiếp nhận phản hồi cuối; giải quyết E1 không tự tạo chữ ký PASS.

## 7. Tích hợp kỹ thuật TV3 — 13/11/2026

- Theo yêu cầu chủ repo, đã sửa F03 bằng preflight cho cả ba role có sẵn và transaction thiết lập; giữ nguyên schema/DEC06. F05 đã cập nhật mô tả PR sang đúng file và quy ước Q_d.
- Kiểm chứng trước merge: 146/146 đạt, gồm 144 kiểm tra chức năng và 2 phép tái hiện; log/hash trong `tests/tv3_review_results.json`. Kiểm tra tệp sau merge 11/11 đạt.
- PR #1 đã merge bằng merge commit `d84571e544b480c9c4ba4a421d5d5435b33faac8`, HEAD nguồn `3414131a66bff6f39d7094225bf5a858beb3421f`. Lịch sử TV3 được giữ; main đã chứa bộ RA/bảo mật cùng bản sửa.
- Đây là tích hợp mã và tài liệu, không phải biên bản họp hay chữ ký nghiệm thu. Gate 1 **CHỜ REVIEW** những xác nhận còn thiếu; TV2/TV3 tiếp tục seed chính thức, đối soát, ảnh và báo cáo theo phân công.
