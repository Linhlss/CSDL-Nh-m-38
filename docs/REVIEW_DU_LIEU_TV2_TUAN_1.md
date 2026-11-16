# REVIEW DỮ LIỆU TV2 — BÀN GIAO TUẦN 1

**Ngày hoàn thiện:** 16/11/2026. **Mã việc:** W1-T3-13, đối chiếu bàn giao W1-T3-14.
**Thực hiện:** agent hỗ trợ kỹ thuật phần TV3 theo yêu cầu chủ repo. **Người được phân công TV3:** Trần Bùi Tùng Linh, MSSV 20227057. Đây là kết quả review có nguồn và kiểm chứng, không phải lời ký xác nhận mới của thành viên hay biên bản họp ba người. Xác nhận TV3 đã ghi trong PR #2 ngày 13/11 được giữ nguyên tại [phiếu review ERD](REVIEW_TV3_ERD_TUAN_1.md), mục 6–9.

## 1. Đầu vào và phạm vi

- TV2 giao generator, bảy CSV, seed INSERT và QSQL01–10 từ [PR #3 tại 63388b3](https://github.com/Linhlss/CSDL-Nh-m-38/tree/63388b394095da137a460ca2f439082bef2077f5). Quy mô là 636 dòng toàn bộ bảy bảng: 8 tổ, 50 địa chỉ, 60 hộ, 200 cư dân, 250 đợt, 63 sự kiện, 5 tài khoản. Mốc d cố định `2026-11-20`.
- Review ban đầu phát hiện **54/250 đợt vi phạm B15** vì ngày lập hộ sau ngày bắt đầu cư trú. Ví dụ hộ 8 lập 29/01/2024 nhưng đợt 6 bắt đầu 01/05/2022. Bản đầu không có FK mồ côi, giao khoảng cùng người/cùng loại B06, sai hai nhánh B08, sai ngày B09 hoặc lặp vai trò E1 trong kiểm tra dữ liệu.
- TV2 sửa generator/CSV/seed theo B15; không đổi schema, ID hay câu hỏi. Ngày lập hộ phải không muộn hơn ngày bắt đầu sớm nhất của mọi đợt thuộc hộ. Đáp án truy vấn tại d không được đổi chỉ do hiệu chỉnh ngày lập hộ.
- Fixture nhỏ do TV2 thiết kế phải có **29 dòng tổng cả bảy bảng**, kèm đáp án tính tay và tách khỏi seed 636. Bộ `ra_fixture.sql` cũ của TV3 có 40 dòng tổng; “10 cư dân” không được dùng thay cho số dòng tổng để nhận mục 15–30 bản ghi.
- Trạng thái log PostgreSQL của lần tích hợp được ghi ở mục 5 sau khi bộ chạy độc lập hoàn tất; không lấy việc có SQL hoặc psql exit 0 làm bằng chứng đáp án đúng.

## 2. Các tình huống bắt buộc W1-T3-13

| Kịch bản | Điều cần chứng minh | Đối chứng cần loại đúng | Truy vấn/tiêu chí |
|---|---|---|---|
| S04 | Địa chỉ chưa có bất kỳ hộ nào được trả về | Địa chỉ đã có hộ, kể cả hộ không có người, không được lọt | QRA05/QSQL04, so mã và địa chỉ chuẩn |
| S06 | Một người từng ở hai hộ khác nhau được chọn | Hai đợt cùng một hộ không đủ; không dùng COUNT số đợt thay số hộ | QRA04/QSQL05, sau khi bỏ cột so_ho |
| S07 | Người có cả thường trú và tạm trú được chọn, kể cả khác thời kỳ | Người chỉ có một loại bị loại; không dùng điều kiện hai loại trên cùng một dòng | QRA07/QSQL06, so mã cư dân |
| S09 | Người có đợt đã bắt đầu trước d nhưng không còn đợt hiệu lực được chọn | Người chưa có đợt và người chỉ có đợt tương lai bị loại | QRA09/QSQL07; không đồng nhất với QRA06 |
| S10 | Người chưa từng có bất kỳ đợt nào được chọn | Người có đợt tương lai vẫn có bản ghi đợt nên không được chọn | QRA06 và SQL kiểm chứng riêng |
| S13 | Chuyển nội bộ cùng người, khác hộ và khác tổ được lấy | Sự kiện cùng tổ bị loại khỏi câu hỏi; sự kiện cố ý ghép hai người khác nhau bị loại | QRA10; QSQL09 phải chiếu DISTINCT người rồi nối tên trước khi so |

Các ca bổ sung cần có gồm trùng họ tên/khác ID; tuổi đúng/sau ngày cắt một ngày; ngày kết thúc đúng d; bắt đầu sau d; tổ 0 người và tài khoản 0 sự kiện. Dữ liệu cố ý sai chỉ chạy trong transaction có ROLLBACK, không để lại trong seed.

## 3. Đối soát RA/SQL đúng mức hạt

Tập kết quả được so đầy đủ cột cần hiển thị sau khi chuẩn hóa về cùng câu hỏi, cùng tham số và cùng mức hạt. QRA04 ↔ QSQL05 bỏ so_ho; QRA05 ↔ QSQL04; QRA07 ↔ QSQL06; QRA09 ↔ QSQL07. QRA01 ↔ QSQL01 phải bỏ loai_cu_tru rồi DISTINCT. QRA10 ↔ QSQL09 phải chiếu DISTINCT ma_cu_dan rồi nối tên vì phía SQL trả từng sự kiện.

QRA02, QRA03, QRA06 và QRA08 dùng SQL kiểm chứng riêng trong [06a](06a_dai_so_quan_he.md). Không đổi tham số hoặc bỏ qua khác biệt để ép mọi cặp “QRAxx = QSQLxx”. QSQL02/03/08/10 đối chiếu đáp án tính tay; QSQL03 còn phải khớp từng dòng với VIEW thống kê B2, kể cả tổ 0 người.

## 4. Kiểm tra dữ liệu và nhận xét nghiệp vụ

Đối với seed sửa: số dòng/ID/khóa không đổi, FK/B06/B08/B09/E1/B15 phải trả 0 vi phạm. Sinh lại hai lần phải cho cùng nội dung CSV/seed. Nạp bằng INSERT seed là đường chạy chính; CSV là bản xuất để kiểm tra, không nạp thêm lần nữa vào cùng DB. Các sequence phải được đồng bộ sau ID gán tay.

C1 đã được làm rõ trong P3: nhập/hiệu chỉnh lịch sử hoặc hết hạn tạm trú có thể kết thúc không kèm sự kiện; chuyển thực tế vẫn dùng P4/P5. QRA09 chỉ đọc ngày của đợt, không đòi mọi đợt kết thúc phải có CHUYEN_DI; các lần chuyển chỗ ở thực tế vẫn theo P4/P5 và B09/B10. Review dữ liệu không tự bổ sung sự kiện để biến mọi đợt đã đóng thành chuyển đi.

## 5. Bằng chứng và kết luận bàn giao

**Đã có kết quả kiểm chứng độc lập:** [week1_execution_results.json](../tests/week1_execution_results.json), [môi trường](../tests/week1_environment.md), [fixture29](../tests/week1_fixture.sql), [expected tay](../tests/week1_expected.json). Bộ chạy đạt **96/96**, gồm 95 kiểm tra chức năng và 1 tái hiện 54 lỗi B15 của bản gốc. Bản sửa không còn B15 và vượt validator FK/B06/B08/B09/E1; giữ nguyên ID, ngày cư trú/sự kiện và dữ liệu ngoài ngày lập hộ. Hai lần sinh khớp byte và khớp file commit. Seed reset/nạp lại cho cùng đáp án, cả 7 sequence cấp đúng ID tiếp theo.

| Ca | ID tiny29 / expected | Đối chứng và actual |
|---|---|---|
| S04 | Địa chỉ3 | Địa chỉ1 có hộ3 rỗng không lọt; QSQL04/QRA05 khớp |
| S06 | C5, hai hộ | C3 hai đợt cùngH1 bị loại; QSQL05/QRA04 khớp |
| S07 | C3,C5 | C1,C2 một loại bị loại; QSQL06/QRA07 khớp |
| S09 | C7 | Loại C6 chưa có đợt, C80 chỉ tương lai; ca C1 hết hạn không sự kiện cũng đạt |
| S10 | C6 | C80 có đợt tương lai không được coi là chưa có đợt; QRA06 đúng |
| S13 | Sự kiện2/C5/Tổ01→02 | Cùng tổ trong rollback bị loại; chiếu người QSQL09 khớp QRA10 |

Đối chiếu đủ tuple 10 SQL trên tiny29 bằng expected tay, trên seed636 bằng bộ tính Python độc lập; sáu cặp RA/SQL tương thích được so theo đúng mức hạt và bốn QRA còn lại có đáp án tay trên tiny. VIEW khớp đầy đủ từng dòng QSQL03 trên hai DB; B1/B2 thử bằng role đăng nhập trực tiếp. S17–S19 mới là FK/CHECK cơ bản, không chứng minh trigger tuần2. Đây là kết quả của agent hỗ trợ, không gán thành lần chạy hoặc chữ ký của sinh viên.

Các kiểm tra trên đã đạt: W1-T3-13 có đầu ra review kỹ thuật và W1-T3-14 có bộ 06a/06b, ma trận phép toán, biểu thức khó, kế hoạch B1/B2 cùng phiếu review. Ảnh bảo mật chính thức, Chương 4/6 đầy đủ, S17–S21 và nghiệm thu seed cuối là phần tiếp theo theo lịch. Gate 1 chung và xác nhận của người thật được quản lý tại biên bản nhóm, không ký thay trong tài liệu này.
