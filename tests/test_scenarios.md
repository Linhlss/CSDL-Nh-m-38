# MA TRẬN S01–S21 — HỒ SƠ TUẦN 1

**Nhóm 38, lớp 174356; cập nhật 16/11/2026 bởi agent hỗ trợ theo yêu cầu chủ repo.** TV1 Trần Bùi Tùng Linh — 20227057; TV2 Trần Tuấn Ngọc — 20227064; TV3 Dương Ngọc Ninh — 20237469.

ID trong bảng mặc định thuộc [fixture29](week1_fixture.sql); bộ đầy đủ dùng seed636. [Expected tính tay](week1_expected.json), [expected/actual PostgreSQL](week1_execution_results.json) ghi đủ tuple/hash. “Đạt” là kiểm chứng kỹ thuật trên DB tạm, không phải chữ ký thành viên hay nghiệm thu toàn dự án.

| ID | Dữ liệu / expected / đối chứng | Test hoặc truy vấn trong log | Actual / owner |
|---|---|---|---|
| S01 | Tổ01 có C1–C4; C5 đã chuyển sangTổ02 bị loại | QSQL01/QRA01 | Đạt cơ bản; TV2 |
| S02 | C5 tạm trú Tổ02; thường trú Tổ01 bị loại | tiny/QRA02/hand-answer | Đạt cơ bản; TV2/TV3 |
| S03 | C1 sinh20/11/1966 được lấy; C2 sinh21/11 bị loại | tiny/QRA03/hand-answer | Đạt cơ bản; TV2/TV3 |
| S04 | Địa chỉ3 không hộ được lấy; địa chỉ1 có hộ rỗng không lọt | QSQL04/QRA05 | Đạt cơ bản; TV2 |
| S05 | Hộ3 không người; địa chỉ1 vẫn có hộ | QSQL02 loạiH3; QSQL04 loạiđịa chỉ1 | Đạt cơ bản; TV2 |
| S06 | C5 có hai hộ; C3 hai đợt cùngH1 không đủ | QSQL05/QRA04 | Đạt cơ bản; TV2/TV3 |
| S07 | C3,C5 có hai loại; C5 khác thời kỳ vẫn đạt | QSQL06/QRA07 | Đạt cơ bản; TV2/TV3 |
| S08 | C1,C2 một loại, không lọt tập giao | QSQL06/QRA07 | Đạt cơ bản; TV2 |
| S09 | C7 đã hết mọi đợt; loại C6 và chỉ tương lai C80 | QSQL07/QRA09; C1/expired-without-event | Đạt cơ bản; TV2/TV3 |
| S10 | C6 chưa có đợt; C80 có đợt tương lai không được lấy | QRA06; edge/future-not-never | Đạt cơ bản; TV2/TV3 |
| S11 | Sự kiện1 chuyển đến chỉ FK mới4 | QSQL08; V_B09; validator | Đạt cơ bản; TV2 |
| S12 | Sự kiện3 chuyển đi chỉ FK cũ7,06/11 sau kết thúc05/11 | QSQL08; V_B09 | Đạt cơ bản; TV2 |
| S13 | Sự kiện2/C5 khác tổ; đối chứng đổiH2 về cùng tổ trong rollback bị loại | QSQL09/QRA10; edge/same-org-move-excluded | Đạt cơ bản; TV2,TV1 soát |
| S14 | H1 có4 người dù C3 hai loại; H2=1,H3=0 bị loại | QSQL02; QSQL03/VIEW | Đạt cơ bản; TV2 |
| S15 | Tổ03 rỗng, không có sự kiện; không tự thêm nhóm tháng/loại0 | QSQL03 T3=0; QSQL08 đúng3nhóm | Đạt cơ bản; TV2 |
| S16 | C1/C2 cùng tên nhưng giữ hai mã | QSQL01 đủ5tuple; QRA01 đủ4người | Đạt cơ bản; TV2 |
| S17 | Cư dân9999 không tồn tại bị chặn23503 | tiny/S17/SQLSTATE | Đạt cơ bản; TV1,TV2 hỗ trợ |
| S18 | Kết thúc01/01 trước bắt đầu02/01 bị chặn23514 | tiny/S18/SQLSTATE | Đạt cơ bản; TV1 |
| S19 | Nội bộ thiếu cả FK cũ/mới bị chặn23514 | tiny/S19/SQLSTATE | Đạt cơ bản; TV1 |
| S20 | Reader đăng nhập trực tiếp UPDATE bị chặn42501, dữ liệu không đổi | S20-reader-update; permission-data-unchanged | Đạt cơ bản; TV3,TV2 hỗ trợ |
| S21 | Report xem VIEW được, đọc cu_dan bị chặn42501 | VIEW-vs-QSQL03; S21-report-base-table | Đạt cơ bản; TV3 |

S17–S19 chưa chứng minh chống chồng lấn/trigger xuyên bảng; S20/S21 chưa có ảnh chính thức hoặc kiểm chứng mật khẩu. Nâng cao, rebuild cuối và ảnh/báo cáo theo tuần 2–3. Giữ nguyên [D01–D30](week1_design_cases.md); không biến ca thiết kế chưa chạy thành DB PASS. Không dùng bảng này để tự ký Gate 1.
