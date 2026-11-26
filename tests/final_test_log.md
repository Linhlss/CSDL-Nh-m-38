# Biên bản chạy kiểm chứng từ CSDL trắng — Cập nhật Tuần 2 (19/11/2026)

> **Lưu ý nghiệm thu:** Các kết quả bên dưới tổng hợp từ các lượt chạy thực tế trên PostgreSQL 17 đã ghi nhận trong repo ([tests/week1_execution_results.json](week1_execution_results.json) ngày 16/11 và GitHub Actions CI [run 44533515990](https://github.com/Linhlss/CSDL-Nh-m-38/actions/runs/44533515990) ngày 19/11, chi tiết tại [tests/week2_constraints_execution_log.md](week2_constraints_execution_log.md)). Đây là bản ghi kiểm thử kỹ thuật Tuần 2 của TV2, **chưa thay thế** lượt chạy chốt Gate 3 (24/11) hoặc ảnh chụp minh chứng cá nhân.

## 1. Môi trường kiểm chứng đã ghi nhận

- **Môi trường CI / container:** PostgreSQL 17 (`postgres:17` trên GitHub Actions và PostgreSQL 17.11 trên container kiểm chứng tuần 1), `psql`, Python 3.13.
- **Môi trường cá nhân TV2 (`W2-T2-01`):** Hệ điều hành Windows; *chờ TV2 bổ sung phiên bản PostgreSQL cục bộ, công cụ quản trị (pgAdmin/DBeaver/psql) và kết quả `SELECT version();` khi cài đặt/sử dụng trên máy cá nhân*.

## 2. Kết quả chạy tuần tự từ CSDL trắng (`csdl17_cu_tru_demo`)

| Bước | Lệnh / tệp | Expected | Actual đã ghi nhận (PostgreSQL 17) | PASS / FAIL | Ảnh minh chứng (Gate 3) |
|---:|---|---|---|---|---|
| 1 | `sql/01_schema.sql` | Tạo 7 bảng, 35 cột, 7 PK, 7 FK, 3 UNIQUE, 6 CHECK, 5 chỉ mục | Chạy thành công không lỗi trên DB trắng (`run 44533515990`) | PASS | *Chờ chụp Gate 3* |
| 2 | `sql/02_constraints.sql` | Bật `btree_gist`, exclusion B06 và trigger B08–B11, B14 | Chạy thành công; `tests/constraints_week2.sql` đạt 20/20 ca dương/âm + rollback | PASS | *Chờ chụp Gate 3* |
| 3 | `sql/03_seed.sql` | Nạp 636 bản ghi hợp lệ theo thứ tự FK và đồng bộ 7 sequence | Nạp thành công 636 bản ghi; tái nạp (reload) cho kết quả đồng nhất | PASS | *Chờ chụp Gate 3* |
| 4 | `sql/06_validation.sql` | `so_dot_sai_ngay = 0`, `V_E1_CU = 0`, `V_E1_MOI = 0`, `V_B09 = 0` | 0 dòng lỗi trên toàn bộ truy vấn kiểm tra (`1 PASS kiểm tra dữ liệu`) | PASS | *Chờ chụp Gate 3* |
| 5 | `sql/04_queries.sql` | 10 truy vấn `QSQL01–QSQL10` chạy đúng hợp đồng đầu ra | Chạy không lỗi; khớp đủ tuple và 6 cặp đối soát RA + VIEW (`week1_execution_results.json`) | PASS | *Chờ chụp `evidence/sql/QSQL01..10_result.png`* |
| 6 | `sql/05_security.sql` | 2 demo bảo mật B1 (`GRANT/REVOKE`) và B2 (`VIEW`) hoạt động đúng | Đạt trên `fixture29` và `seed636` ở `week1_execution_results.json` (TV3 chủ trì ảnh cuối) | PASS (kỹ thuật) | *Chờ chụp `evidence/security/` (TV3)* |

## 3. Thống kê số bản ghi từng bảng sau `sql/03_seed.sql` (`seed636`)

| Bảng | Số bản ghi thực tế |
|---|---:|
| `to_dan_pho` | 8 |
| `dia_chi` | 50 |
| `ho_cu_tru` | 60 |
| `cu_dan` | 200 |
| `tai_khoan` | 5 |
| `qua_trinh_cu_tru` | 250 |
| `bien_dong_cu_tru` | 63 |
| **Tổng cộng** | **636** |

## 4. Tóm tắt số dòng đầu ra `QSQL01–QSQL10` (`d = 2026-11-20`)

| Mã câu | `fixture29` (dòng) | `seed636` (dòng) | Đối soát chéo |
|---|---:|---:|---|
| `QSQL01` | 5 | 36 | Khớp `QRA01 = 34` cư dân phân biệt |
| `QSQL02` | 1 | 24 | Loại hộ 3 người, 1 người, hộ trống S05 |
| `QSQL03` | 3 | 8 | Khớp `vw_thong_ke_cu_dan_theo_to` (`Tổ 08 = 0`) |
| `QSQL04` | 1 | 4 | Khớp `QRA05 = 4` |
| `QSQL05` | 1 | 54 | Khớp `QRA04 = 54` |
| `QSQL06` | 2 | 31 | Khớp `QRA07 = 31` |
| `QSQL07` | 1 | 17 | Khớp `QRA09 = 17` |
| `QSQL08` | 3 | 45 | Tổng `63` sự kiện khớp `bien_dong_cu_tru` |
| `QSQL09` | 1 | 22 | Khớp `QRA10 = 22` cư dân |
| `QSQL10` | 2 | 5 | Tổng `63` sự kiện; `ma_tai_khoan = 5` có `0` sự kiện |

## 5. Hạng mục còn mở trước Gate 3 (24/11/2026)

- [ ] TV2 bổ sung thông tin PostgreSQL/công cụ cá nhân trên Windows và kết quả `SELECT version();` (`W2-T2-01`).
- [ ] TV2 chụp và lưu 10 ảnh kết quả `evidence/sql/QSQL01_result.png` … `QSQL10_result.png`.
- [ ] TV3 chụp và lưu ảnh 2 demo bảo mật vào `evidence/security/`.
- [ ] Cả nhóm chạy lại end-to-end từ CSDL trắng và ký xác nhận Gate 3.

## 6. Cập nhật tích hợp của TV1 — 20/11/2026 (không thay thế mục 1–5 của TV2)

Mục 1–5 ở trên là bản TV2 ngày 19/11 (PR #6), được giữ nguyên. TV1 chỉ sửa tên VIEW thành `vw_thong_ke_cu_dan_theo_to`. Mục này ghi các kết quả **mới hơn**, chạy trên nhánh tích hợp sau khi đã gộp PR #8 và Chương 5. Chi tiết lệnh, SHA-256, expected/actual và SQLSTATE nằm ở [tests/week2_tv1_integration_log.md](week2_tv1_integration_log.md).

| Bước | Expected | Actual 20/11 (PostgreSQL 17.12, DB trắng) | PASS / FAIL |
|---|---|---|---|
| `tests/constraints_week2.sql` | Ca âm đúng SQLSTATE, ca dương được ghi, seed còn nguyên | 40 `[PASS]`, gồm E1 đã gia cố, B15, S17–S19 | PASS |
| `sql/06_validation.sql` | B06/B08/B09, E1, B15 không vi phạm | 3 `[PASS]` | PASS |
| `QSQL01–QSQL10` trên seed636 và fixture29 | Số dòng như bảng mục 4 | Khớp cả 20 con số và các bảng trích ở Chương 5 | PASS |
| `scripts/verify_gate2_integration.py` | RA↔SQL↔VIEW↔role trên 2 DB | 71 kiểm tra PASS | PASS |
| S01–S16 (`assert_s01_s16_tv1.sql`) | Kỳ vọng trùng thực tế | 18/18 ca có chấm điểm, 2 ca thông tin | PASS |
| B1/B2, catalog, B12, đăng nhập thật | 6 lỗi từ chối cố ý; C01–C15; K01–K05; reader 12/12; report 10/10 | Đúng như expected | PASS |
| Giữ dữ liệu gốc | md5 seed636 không đổi | Không đổi | PASS |

**Vẫn mở:** các mục ở phần 5 (Windows của TV2, ảnh SQL, ảnh bảo mật, chạy lại và ký Gate 3).

<a id="qsql-report-evidence"></a>

## 7. Đối chiếu bộ QSQL dùng trong báo cáo và slide ngày 24/11/2026

Ảnh gốc của TV2 ghi lại lần chạy bằng pgAdmin. Lượt đối chiếu riêng dùng PostgreSQL 17.12 (Homebrew, macOS), một cụm tạm qua Unix socket và seed636 dựng từ `01_schema.sql` → `02_constraints.sql` → `03_seed.sql` → `06_validation.sql`. Cụm đã dừng sau khi kiểm tra.

Ba kiểm tra tổng hợp B06/B08/B09, E1 và B15 đều đạt. Đã chạy từng câu của `sql/04_queries.sql`, so toàn bộ bộ giá trị với tập kỳ vọng và so thứ tự với đầu ra đã lưu ở các mục `w1_seed/QSQLnn/full-tuples` trong [log kỹ thuật](week1_execution_results.json).

| Mã | Số dòng trong ảnh | Số dòng tái lập | Đối chiếu | Ảnh gốc |
|---|---:|---:|---|---|
| QSQL01 | 36 | 36 | PASS | [Ảnh QSQL01](../Báo_cáo_CSDL_nhóm_38/image/qsql/QSQL01_result.png) |
| QSQL02 | 24 | 24 | PASS | [Ảnh QSQL02](../Báo_cáo_CSDL_nhóm_38/image/qsql/QSQL02_result.png) |
| QSQL03 | 8 | 8 | PASS | [Ảnh QSQL03](../Báo_cáo_CSDL_nhóm_38/image/qsql/QSQL03_result.png) |
| QSQL04 | 4 | 4 | PASS | [Ảnh QSQL04](../Báo_cáo_CSDL_nhóm_38/image/qsql/QSQL04_result.png) |
| QSQL05 | 54 | 54 | PASS | [Ảnh QSQL05](../Báo_cáo_CSDL_nhóm_38/image/qsql/QSQL05_result.png) |
| QSQL06 | 31 | 31 | PASS | [Ảnh QSQL06](../Báo_cáo_CSDL_nhóm_38/image/qsql/QSQL06_result.png) |
| QSQL07 | 17 | 17 | PASS | [Ảnh QSQL07](../Báo_cáo_CSDL_nhóm_38/image/qsql/QSQL07_result.png) |
| QSQL08 | 45 | 45 | PASS | [Ảnh QSQL08](../Báo_cáo_CSDL_nhóm_38/image/qsql/QSQL08_result.png) |
| QSQL09 | 22 | 22 | PASS | [Ảnh QSQL09](../Báo_cáo_CSDL_nhóm_38/image/qsql/QSQL09_result.png) |
| QSQL10 | 5 | 5 | PASS | [Ảnh QSQL10](../Báo_cáo_CSDL_nhóm_38/image/qsql/QSQL10_result.png) |

Đối chiếu riêng cho thấy QSQL02 trả các hộ có từ 4 cư dân, QSQL03 giữ Tổ 08 với số 0, QSQL09 chỉ trả lần chuyển khác tổ và QSQL10 giữ tài khoản 5 với số 0. Cả QSQL08 và QSQL10 cộng ra 63 biến động. QSQL06 khớp đủ 31 mã cư dân với phép giao ở Câu 5 Chương 4.

Dấu vết đầu vào của lượt chạy:

```text
01_schema.sql SHA-256 e3a220c0ea8fbe7ad4475c0ede3201d25573a1007c5b4e0b26f698df2607f6f5
02_constraints.sql SHA-256 c35d338210c3dc113a09c654685c6bf66d7f9827656c385ce64b8f43be37dd2a
03_seed.sql SHA-256 71f33714b57745bce1069cc4212f69f2382829817334d6fe252c0ba77e7fa0f2
06_validation.sql SHA-256 d7d748c100cc81aa258cac92cbfa8fe9dcea85c02e2eaa2b1cf8d82ca9e66440
04_queries.sql SHA-256 043d1a771719f1304a9b03134269862b33811343a1d5422fd56ef72e26b8487b
```

Lượt đối chiếu này xác nhận bộ QSQL và bổ sung liên kết ảnh của TV2.

**Máy Windows của TV2.** Ngọc ghi nhận dùng PostgreSQL 19 (x64) và pgAdmin 4 trong [PR #11](https://github.com/Linhlss/CSDL-Nh-m-38/pull/11). Mười ảnh cho thấy kết nối và thực thi từng QSQL trong pgAdmin. Kết quả tái lập đủ 10 truy vấn bằng PostgreSQL 17.12 được ghi riêng ở trên. Xác nhận Gate 3 vẫn cần biên bản của nhóm.
