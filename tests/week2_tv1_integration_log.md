# LOG KIỂM THỬ TỪ DB TRẮNG — TV1, SAU TÍCH HỢP PR #8 (Issue #9)

**Người chạy:** TV1 — Trần Bùi Tùng Linh (20227057). Agent Claude Code hỗ trợ chạy lệnh trên máy TV1.
**Ngày:** 20/11/2026.
**Nhánh:** `fix/tv1-integration-gate2`, gồm PR #7 cộng PR #8 (fast-forward tới `432600e`) và các thay đổi TV1 của Issue #9.
**Phạm vi:** nhật ký này chỉ là bằng chứng kỹ thuật của TV1. Nó **không** là Gate 2, **không** thay review hay chữ ký của TV2/TV3, và **không** chứng minh môi trường Windows của TV2.

## 1. Môi trường

| Mục | Giá trị |
|---|---|
| Hệ điều hành | macOS 26.7.3, arm64 |
| PostgreSQL | 17.12 (Homebrew), cluster **mới** khởi tạo bằng `initdb` (UTF8, locale C, TimeZone Asia/Ho_Chi_Minh) |
| Xác thực | TCP 127.0.0.1:5433. Dòng `pg_hba` riêng cho `postgres` (quản trị test) dùng `trust`; **mọi role khác dùng `scram-sha-256`** |
| Client | `psql` 17.12, Python 3.13.5 |
| Mật khẩu role demo | Sinh ngẫu nhiên bằng `openssl rand -hex 16`, không in ra và không ghi vào repo. Đặt lại `PASSWORD NULL` ngay sau test; đã kiểm `rolpassword IS NULL` cho cả 3 role |
| DB trắng | `csdl17_seed636` và `csdl17_ra_fixture` được tạo mới bằng `createdb`. Các role `csdl17_*` không tồn tại trước khi chạy |

**Phiên bản tệp đã chạy** (SHA-256, 16 ký tự đầu). Dùng để đối chiếu với commit chứa log này:

| Tệp | SHA-256 | Tệp | SHA-256 |
|---|---|---|---|
| `sql/01_schema.sql` | `e3a220c0ea8fbe7a` | `tests/constraints_week2.sql` | `6e024fac9ce4a185` |
| `sql/02_constraints.sql` | `c35d338210c3dc11` | `tests/ra_fixture.sql` | `99b45128d41927b1` |
| `sql/03_seed.sql` | `71f33714b57745bc` (trùng tuần 1) | `tests/seed636_qra02_03_06_08.sql` | `0075e144f94f2e8a` |
| `sql/04_queries.sql` | `043d1a771719f130` | `tests/seed636_s01_s16_tv3.sql` | `5decfd84d14c971c` |
| `sql/05_security.sql` | `f2dbe40ff50696eb` (sau X02) | `tests/security_catalog_tv3.sql` | `e616ddca4a0a057e` |
| `sql/06_validation.sql` | `d7d748c100cc81aa` | `tests/security_login_tv3.sql` | `df97a31fee66b236` |
| `scripts/verify_gate2_integration.py` | `e7eec581683d8859` | `tests/security_b12_tv1.sql` | `45ea0cf9ee2ed761` |
| `scripts/ra_sql_blocks.py` | `7ff762f17370ef39` | `tests/assert_s01_s16_tv1.sql` | `2f9aa675ecad5eea` |

## 2. Trình tự lệnh

Lệnh chạy theo `docs/08_huong_dan_dung_csdl.md`. Mọi bước dùng `-X -v ON_ERROR_STOP=1`, trừ `05_security.sql`: tệp này cố ý có 6 lệnh bị từ chối, nên được đếm riêng.

```text
seed636 : 01_schema → 02_constraints → 03_seed → tests/constraints_week2 → 06_validation → 04_queries
          → md5 dữ liệu (trước) → 05_security (B1/B2)
fixture : 01_schema → 02_constraints → 05_security → tests/ra_fixture
kiểm    : test_ra_parser + ra_sql_blocks → seed636_qra02_03_06_08 → seed636_s01_s16_tv3 + assert_s01_s16_tv1
          → verify_gate2_integration (2 DB) → security_catalog_tv3 → security_b12_tv1
          → đăng nhập thật reader/report (TCP + scram) → thử mật khẩu sai → xóa mật khẩu → md5 dữ liệu (sau)
```

## 3. Kết quả expected / actual

| Bộ kiểm | Expected | Actual | Kết luận |
|---|---|---|---|
| Parser RA 11/12 khối | 6 unit test; 12 khối tên `Q_d`, `QRA01`–`QRA10`, `QRA07_DIV` | 6/6 OK; parse đúng 12 khối | PASS |
| Nạp seed636 | 8/50/60/200/250/63/5 | to_dan_pho=8, dia_chi=50, ho_cu_tru=60, cu_dan=200, qua_trinh_cu_tru=250, bien_dong_cu_tru=63, tai_khoan=5 | PASS |
| `tests/constraints_week2.sql` | Mọi ca âm trả đúng SQLSTATE; ca dương được ghi; seed 636 còn nguyên | 40 `[PASS]`, 0 `[FAIL]`. Xem mục 3.1 | PASS |
| `sql/06_validation.sql` | B06/B08/B09, E1, B15 không vi phạm | 3 `[PASS]` | PASS |
| `sql/04_queries.sql` | 10 QSQL chạy không lỗi | Thoát 0 | PASS |
| B1/B2 (`05_security.sql`) | Đúng 6 lỗi quyền cố ý, không lỗi khác | 6 `permission denied`, ở các dòng 211, 212, 213, 216, 257, 258 | PASS |
| Fixture RA | Dựng và nạp fixture không lỗi | Thoát 0 | PASS |
| `seed636_qra02_03_06_08.sql` | Chạy không lỗi; số lệch EXCEPT/INTERSECT = 0 | Thoát 0 | PASS |
| S01–S16 (`assert_s01_s16_tv1.sql`) | Thực tế trùng kỳ vọng; S11, S12 có dạng `0 sai / n≥1` | **18/18 ca có chấm điểm PASS**; S16b, S16c chỉ để thông tin (6 tên trùng, 15 người; 17 người theo mã so với 16 theo tên) | PASS |
| `verify_gate2_integration.py` | 10 QRA, QRA07_DIV, 10 QSQL, 6 cặp RA↔SQL, VIEW = QSQL03, role, S14b trên 2 DB | `RESULT: 71 checks PASS` | PASS |
| Catalog C01–C15 | 15 PASS | 15 PASS, 0 FAIL | PASS |
| B12 K01 (ma trận quyền) | 3 role × 8 đối tượng × 5 quyền khớp thiết kế | 120 ô, 34 quyền được cấp, không lệch | PASS |
| B12 K02/K03/K04 | admin `DELETE` `qua_trinh_cu_tru`, `DELETE` `bien_dong_cu_tru`, `TRUNCATE` hai bảng → `42501` | `42501`, `42501`, `42501` | PASS |
| B12 K05 | admin gọi `fn_chuyen_noi_bo` thành công, không lỗi `42501` | Thành công ở lần thử đầu (đợt 1 → hộ 2, ngày 2026-11-21); ROLLBACK | PASS |
| Đăng nhập thật `csdl17_reader` | `session_user` = reader, không superuser, qua TCP; R01–R12 | `csdl17_reader / off / tcp=t`; **12/12 PASS** | PASS |
| Đăng nhập thật `csdl17_report` | P01–P10; P06 = `55000` (VIEW có GROUP BY) | **10/10 PASS** | PASS |
| Mật khẩu sai | Bị từ chối | `FATAL: password authentication failed for user "csdl17_reader"` | PASS |
| Giữ dữ liệu gốc | md5 dữ liệu 7 bảng trước và sau mọi test rollback/đăng nhập bằng nhau | `59d7ca1b5f14788ee35a84cdd6d228d9` = `59d7ca1b5f14788ee35a84cdd6d228d9` | PASS |
| `scripts/verify_week1.py` | 14/14 sau khi ghi lại manifest (`--record` chỉ chạy sau khi mọi test DB PASS) | Xem mục 4 | PASS |

### 3.1. Chi tiết SQLSTATE của `tests/constraints_week2.sql`

| Nhóm | Ca | SQLSTATE expected = actual |
|---|---|---|
| B06 | INSERT và UPDATE chồng lấn | `23P01`, `23P01`; ca dương (kề ngày, khác loại) được ghi |
| B08 | Khác cư dân, cùng hộ, UPDATE ngược hộ | `23514` × 3 |
| B09 | Sai ngày bắt đầu mới, sai ngày kết thúc cũ, UPDATE ngược hai chiều | `23514` × 4 |
| B10 | Lỗi giữa giao dịch | `23503`, toàn bộ bị rollback; ca dương ghi 3 bước nhất quán |
| B11 | Đổi địa chỉ của hộ, đổi tổ của địa chỉ đã có lịch sử | `23514` × 2; ca dương đổi liên kết chưa có lịch sử |
| B14 | Ghi bằng tài khoản khóa; đổi người ghi sang tài khoản khóa | `23514` × 2; khóa tài khoản không hủy sự kiện cũ |
| E1 (X07) | INSERT trùng vai trò cũ và vai trò mới **được ghi** (đợt 99002 là đợt cũ 2 lần; đợt 99003 là đợt mới 2 lần), sau đó `fn_assert_e1` báo lỗi | `23514` × 2, rồi hoàn tác INSERT thử; ca dương: một đợt làm "mới" rồi làm "cũ" hợp lệ |
| B15 | Tên, địa chỉ, tên đăng nhập chỉ có khoảng trắng; ngày sinh hoặc ngày lập hộ sau ngày bắt đầu; sửa ngược hai chiều | `23514` × 7; ca dương được ghi |
| S17–S19, PK/UNIQUE/NOT NULL/CHECK | FK sai; ngày kết thúc trước ngày bắt đầu; nội bộ không có đợt; trùng PK; trùng UNIQUE đơn và ghép; thiếu tên; sai giới tính | `23503`, `23514`, `23514`, `23505` × 3, `23502`, `23514` |

### 3.2. Số liệu phục vụ X01, X05

- **X01:** số sự kiện theo người ghi là `QUAN_TRI/admin_demo` 11, `CAN_BO/canbo_01` 21, `CAN_BO/canbo_02` 18, `THONG_KE/thongke_01` 13. `canbo_duphong` có 0 sự kiện. Tổng 63 sự kiện.
- **X05:** có 2 sự kiện thỏa `ngay_bien_dong > thoi_diem_ghi::date` khi seed được nạp ngày 2026-11-20. Lý do: `thoi_diem_ghi` nhận giá trị DEFAULT lúc nạp. Nếu nạp ngày khác, con số này có thể khác.

## 4. Manifest

`python3 scripts/verify_week1.py --record` chỉ được chạy **sau khi** toàn bộ test DB ở mục 3 đã PASS. Lệnh chạy trên checkout LF của macOS (`core.autocrlf` không đặt). Sau đó, chạy lại `python3 scripts/verify_week1.py` không kèm `--record` cho kết quả 14/14 PASS. Hash lịch sử tuần 1 (`tests/week1_execution_results.json`, 96/96) không bị sửa. `sql/03_seed.sql` giữ hash `71f33714…` của tuần 1.

## 5. CI

CI GitHub Actions trên commit tích hợp cuối được liên kết trong mô tả PR #7 và bình luận Issue #9. Log không thể tự chứa hash của chính commit chứa nó. Workflow có thêm bốn kiểm tra: catalog C01–C15, B12 K01–K05, đăng nhập thật bằng mật khẩu scram tạm, và khẳng định S01–S16. B1/B2 được đếm đúng 6 lỗi từ chối.

## 6. Giới hạn của lần chạy

- Đây là macOS và Homebrew PostgreSQL 17.12, không phải máy Windows của TV2. TV2 vẫn phải dựng lại trên máy của mình và ghi log riêng.
- Không kiểm thử concurrency nhiều kết nối, TLS hay chính sách mật khẩu production.
- Đây không phải ảnh chụp Gate 3. Ảnh B1/B2 chính thức thuộc T3-04 (TV3, 24/11).
