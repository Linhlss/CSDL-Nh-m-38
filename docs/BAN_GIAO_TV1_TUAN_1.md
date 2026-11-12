# BÀN GIAO PHẦN TV1 — TUẦN 1

**Ngày:** 11/11/2026. **Bộ thiết kế:** `v1-candidate`. **Điểm dừng:** hoàn thiện sản phẩm TV1 để người tiếp theo review và triển khai đúng kế hoạch; chưa triển khai thay phần tuần 2.

Có đặc tả, sơ đồ chỉnh sửa được, từ điển/chuẩn hóa nháp, DDL đối chiếu, Chương 1–3, ma trận 20 câu hỏi và 30 tình huống thiết kế. **Gate 1 của nhóm:** chờ xác nhận thật của TV2/TV3.

## 1. Người nhận bắt đầu ở đây

Repository chung: [Linhlss/CSDL-Nh-m-38](https://github.com/Linhlss/CSDL-Nh-m-38), nhánh `main`. Trên nhánh main của bản clone đang có, chạy `git pull --ff-only origin main` trước khi đọc và triển khai. Các thay đổi tiếp theo được bàn giao bằng commit/push trên repository.

1. Đọc [đặc tả nghiệp vụ](03_dac_ta_nghiep_vu.md), đặc biệt B04–B17 và P4/P5.
2. Đọc [từ điển và chuẩn hóa](04_data_dictionary_va_chuan_hoa.md). Dùng [DDL](../sql/01_schema.sql) làm nguồn tên/kiểu cột; cấu trúc SQL không đổi so với v0.
3. Xem [ERD](../diagrams/erd_v1.png) và [cây chức năng](../diagrams/phan_ra_chuc_nang.png). Nguồn `.drawio` mở bằng diagrams.net; `.svg` để in rõ, `.png` để chèn báo cáo.
4. Đọc [ma trận 20 câu hỏi và review](07_ma_tran_truy_van_va_review.md), [30 ca thiết kế](../tests/week1_design_cases.md), rồi xem [hồ sơ quyết định/Gate 1](../meetings/decision_log.md).
5. Chạy lệnh dưới đây từ thư mục gốc và xem [biên bản tự kiểm tra](../tests/week1_verification_log.md). Không coi đây là log chạy PostgreSQL.

```sh
python3 scripts/verify_week1.py
```

Khi cần dựng lại ảnh, dùng Python 3 + Pillow, chạy `python3 scripts/render_week1_diagrams.py`. Không cần dựng ảnh lại để đọc hoặc triển khai CSDL.

## 2. Giao diện dữ liệu bàn giao

- Giữ nguyên 7 bảng, 35 cột, 7 PK, 7 FK, 3 UNIQUE nghiệp vụ, 6 CHECK và 5 chỉ mục bổ sung. Không đổi tên/kiểu cột; SQL dựa trên v0 không cần đổi tên vì gói này.
- d=`2026-11-20`; tên tổ là `Tổ 01`, `Tổ 02`. Người/tài khoản dùng mã để định danh, không dùng họ tên.
- Ngày cuối bao gồm; đợt tương lai không hiệu lực sớm dù kết thúc NULL. Ngày chuyển t: cũ kết thúc t−1, mới bắt đầu t.
- Chống chồng lấn theo cùng người+cùng loại; cho hai loại khác nhau đồng thời. Số người trong từng nhóm dùng mã phân biệt; tổng số người các tổ có thể khác số người phân biệt toàn phường.
- Không sửa liên kết hộ–địa chỉ/tổ đã dùng để mô phỏng chuyển chỗ ở. Không UNIQUE hai FK cũ/mới; mỗi sự kiện có tối đa một đợt ở mỗi vai trò.
- E1 đã được TV1 trả lời ngày 12/11: trước nghiệm thu, V_E1_CU/V_E1_MOI trong `sql/06_validation.sql` phải trả 0 dòng. Kiểm riêng mỗi vai trò, bỏ qua NULL; một đợt được dùng lần lượt ở vai trò mới và cũ vẫn hợp lệ. Đây là validation, DB chưa tự chặn ghi trùng. V_B09 phải trả 0 dòng khi đối chiếu ngày chuyển với các đợt liên quan.
- Mọi dữ liệu dân cư giả lập; không lưu mật khẩu hoặc thông tin cư dân thật.

## 3. Người tiếp theo làm gì?

| Người | Việc tiếp nhận trong tuần 1 | Việc tuần 2 |
|---|---|---|
| TV2 | Review ERD/từ điển/DDL, xác nhận đủ cột cho 10 SQL và sinh dữ liệu; chuẩn bị S01–S21 và đáp án dự kiến | Sinh fixture nhỏ rồi dữ liệu nền theo FK; hoàn thiện seed, 10 SQL/kết quả; thêm tổ 0 người, tài khoản 0 sự kiện, tương lai và trùng tên |
| TV3 | Đã review ERD và sửa RV08; PR #1 đã tích hợp sau review kỹ thuật ngày 13/11. Tiếp nhận phản hồi E1 và xác nhận thành viên còn thiếu | Hoàn thiện/đối soát 10 RA, role/VIEW và hai demo trên cùng seed; lưu kết quả thật |
| TV1 — phần tiếp theo đúng lịch | Tiếp nhận phản hồi vào biên bản và chuẩn bị bản được nhóm duyệt | DDL chạy trên DB sạch; ràng buộc/transaction, S17–S19; chốt luận chứng chuẩn hóa; review seed |

Thứ tự sau review: DB sạch → `01_schema.sql` → triển khai/chạy `02_constraints.sql` → seed → validation → SQL/RA đối soát → bảo mật. Constraints, seed và queries vẫn còn TODO đúng kế hoạch. Security đã có mã chạy trên fixture nhỏ, thêm preflight role và transaction qua review 13/11; chưa thay việc nghiệm thu trên seed chính thức. Không coi việc chạy qua file chỉ chứa chú thích là hoàn thành chức năng.

Nếu nhập ID gán tay rồi tiếp tục dùng ID tự sinh, đồng bộ sequence. Không nạp cả CSV và INSERT cho cùng dataset. Test âm dùng transaction rollback.

## 4. Giới hạn và việc cần xác nhận

| Nội dung | Trạng thái / người tiếp nhận |
|---|---|
| Review chéo/Gate 1 | TV3 đã xác nhận khả năng biểu diễn 10 RA/B1/B2 tại `7abe4d5`; TV1 đã trả lời E1 ngày 12/11. Chờ TV2 và TV3 tiếp nhận phản hồi cuối; chưa PASS |
| Thông báo gốc, mã lớp, họ tên/MSSV, giảng viên | Nhóm bổ sung thông tin thật; không suy đoán từ tên repo |
| Ngày sự kiện và chuẩn hóa | Đã phân tích FD và công bố dư thừa có điều kiện do B09; TV1 + reviewer chốt luận chứng cuối tuần 2, xem từ điển mục 5 |
| RA với NULL | TV3 đã sửa RV08 tại `7abe4d5`: chuẩn bị Q_d bằng SQL, bỏ cột kết thúc trước phần đại số cổ điển; xem review độc lập bên dưới |
| Ràng buộc xuyên bảng | Đã đặc tả, chưa thực thi; tuần 2 kiểm cả sửa sự kiện và sửa đợt |
| PostgreSQL | Lần bàn giao 11/11 chưa chạy PostgreSQL. Kết quả kiểm chứng độc lập mới được ghi riêng trong [review TV3 chi tiết](REVIEW_TV3_CHI_TIET.md); kiểm tra tệp không thay test DB hoặc seed chính thức |
| GitHub | PR #1 đã merge vào main tại `d84571e` ngày 13/11/2026, gồm fixture sửa B09 và preflight role. Xem báo cáo review cho kết quả thực tế; merge không thay xác nhận Gate 1 |

## 5. Sản phẩm và kiểm chứng

- Nghiệp vụ: `03_dac_ta_nghiep_vu.md` gồm thuật ngữ, tác nhân, P1–P6, B01–B18 và bảng chức năng đọc/ghi.
- Thiết kế: `04_data_dictionary_va_chuan_hoa.md` gồm 35 cột, khóa, ánh xạ, bản số, FD/chuẩn hóa nháp và phương án ràng buộc.
- Sơ đồ: hai bộ `.drawio`, `.png`, `.svg` trong `diagrams/`.
- Báo cáo: [Mở đầu và Chương 1–3](02_bao_cao_suon.md); phần người khác/tuần sau ghi đúng trạng thái đang chờ.
- Review/tiếp nối: ma trận 20 câu, RV01–RV10, 30 ca thiết kế, biên bản và bảng đối chiếu W1-T1-01…20.
- Kiểm chứng: script kiểm nhất quán, biên bản kết quả và manifest SHA-256 trong `tests/week1_manifest.json`; lịch sử commit trên main xác định phiên bản bàn giao.

TV2/TV3 ghi phản hồi và xác nhận thực tế trong biên bản, xử lý mâu thuẫn ảnh hưởng thiết kế rồi mới gọi đây là schema v1 đã được cả nhóm duyệt. Người nhận có thể đọc, review và chuẩn bị phần mình ngay trên ứng viên này.
