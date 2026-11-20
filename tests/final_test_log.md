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
