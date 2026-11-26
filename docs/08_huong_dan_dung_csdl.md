# HƯỚNG DẪN DỰNG VÀ NGHIỆM THU CSDL TỪ ĐẦU — TV1

**Bản dùng để kiểm thử Gate 2/3.** PostgreSQL ≥15, `psql`, Python ≥3.10.
Chỉ dùng database mô phỏng riêng. Dữ liệu seed giả lập 100%. Không commit mật khẩu.
**Phải chạy lệnh từ thư mục gốc repository.**

## 1. Thứ tự chuẩn và hai database độc lập

DB `csdl17_seed636`: 7 bảng / 636 bản ghi, 10 SQL, RA, B1/B2.
DB `csdl17_ra_fixture`: dữ liệu nhỏ 10 cư dân, script RA có `BEGIN...ROLLBACK`;
không chạy script seed636 ở DB này, vì các mã ID cố định sẽ đụng nhau.

```sh
createdb -U postgres csdl17_seed636
createdb -U postgres csdl17_ra_fixture

# DB chính
psql -X -U postgres -d csdl17_seed636 -v ON_ERROR_STOP=1 -f sql/01_schema.sql
psql -X -U postgres -d csdl17_seed636 -v ON_ERROR_STOP=1 -f sql/02_constraints.sql
psql -X -U postgres -d csdl17_seed636 -v ON_ERROR_STOP=1 -f sql/03_seed.sql
psql -X -U postgres -d csdl17_seed636 -v ON_ERROR_STOP=1 -f tests/constraints_week2.sql
psql -X -U postgres -d csdl17_seed636 -v ON_ERROR_STOP=1 -f sql/06_validation.sql
psql -X -U postgres -d csdl17_seed636 -v ON_ERROR_STOP=1 -f sql/04_queries.sql
psql -X -U postgres -d csdl17_seed636 -v ON_ERROR_STOP=1 -f sql/07_queries_bo_sung.sql

# Bảo mật: chạy psql -f, không dùng -1/--single-transaction.
# Script chứa các câu SQL bị từ chối CỐ Ý (bật/tắt ON_ERROR_STOP tại chỗ).
psql -X -U postgres -d csdl17_seed636 -f sql/05_security.sql

# Fixture RA: database độc lập, role PostgreSQL thuộc phạm vi cluster.
psql -X -U postgres -d csdl17_ra_fixture -v ON_ERROR_STOP=1 -f sql/01_schema.sql
psql -X -U postgres -d csdl17_ra_fixture -v ON_ERROR_STOP=1 -f sql/02_constraints.sql
psql -X -U postgres -d csdl17_ra_fixture -f sql/05_security.sql
psql -X -U postgres -d csdl17_ra_fixture -v ON_ERROR_STOP=1 -f tests/ra_fixture.sql

# Đối soát tự động: tự nạp dữ liệu thử vào DB fixture sau lần ROLLBACK.
python3 -m unittest discover -s tests -p 'test_ra_parser.py' -v
python3 scripts/verify_gate2_integration.py \
  --seed-db csdl17_seed636 --fixture-db csdl17_ra_fixture

# S01–S16 (TV3) kèm khẳng định kỳ vọng/thực tế (TV1), cùng một phiên psql
psql -X -U postgres -d csdl17_seed636 -v ON_ERROR_STOP=1 \
  -f tests/seed636_s01_s16_tv3.sql -f tests/assert_s01_s16_tv1.sql

# Bảo mật: catalog C01–C15 (TV3) và ma trận quyền B12 K01–K05 (TV1)
psql -X -U postgres -d csdl17_seed636 -f tests/security_catalog_tv3.sql
psql -X -U postgres -d csdl17_seed636 -v ON_ERROR_STOP=1 -f tests/security_b12_tv1.sql

# Đăng nhập thật qua TCP: đặt mật khẩu TẠM (không ghi vào repo), chạy, rồi xóa
psql -X -U postgres -d csdl17_seed636 -c "\password csdl17_reader" -c "\password csdl17_report"
psql -X -h localhost -U csdl17_reader -d csdl17_seed636 -f tests/security_login_tv3.sql   # kỳ vọng 12/12
psql -X -h localhost -U csdl17_report -d csdl17_seed636 -f tests/security_login_tv3.sql   # kỳ vọng 10/10
psql -X -U postgres -d csdl17_seed636 \
  -c "ALTER ROLE csdl17_reader PASSWORD NULL" -c "ALTER ROLE csdl17_report PASSWORD NULL"
```

Lần chạy đầy đủ chuỗi này trên macOS ngày 20/11/2026 được ghi tại [tests/week2_tv1_integration_log.md](../tests/week2_tv1_integration_log.md). Trong lần chạy đó, `pg_hba` dùng `scram-sha-256` cho kết nối TCP, nên đăng nhập bằng mật khẩu sai bị từ chối.

### Bằng chứng thành công

- `sql/06_validation.sql` phải có PASS cho B06/B08/B09, E1, B15. Hai UNIQUE chặn ghi trùng trong cùng vai trò với mã 23505. Một đợt là đợt mới của sự kiện này và là đợt cũ của sự kiện khác vẫn hợp lệ.
- `tests/constraints_week2.sql` phải có các ca cố ý sai bị từ chối và kiểm tra bộ seed vẫn **636 bản ghi** sau rollback.
- `scripts/verify_gate2_integration.py` phải khớp kết quả **10 QRA**, **QRA07_DIV**, **10 QSQL**, kết quả VIEW và quyền `csdl17_reader`/`csdl17_report`.
- Seed hợp lệ: 8 tổ, 50 địa chỉ, 60 hộ, 200 cư dân, 250 đợt, 63 biến động, 5 tài khoản.
- RA fixture: kiểm thử và rollback, không lưu fixture khi chưa chủ động nạp lại.

## 2. Không được làm

1. Không chạy `sql/03_seed.sql` trong database có dữ liệu cần giữ: seed có TRUNCATE và RESTART IDENTITY.
2. Không chạy `tests/ra_fixture.sql` trong DB seed636: ID trùng, cố ý dành cho database trống.
3. Không chạy `sql/05_security.sql` bằng cách paste nguyên văn vào SQL Editor: `\set` và `\echo` là lệnh của psql.
4. Không coi lỗi quyền `permission denied` trong demo B1/B2 là lỗi triển khai nếu đó là câu bị từ chối theo kịch bản; phải chứng minh role thực sự không có quyền.
5. Không dùng kết quả `python3 scripts/verify_week1.py` để tuyên bố rằng đã chạy PostgreSQL: đó là bộ kiểm tra tệp/hồ sơ tuần 1.

## 3. Tái chạy trên macOS / Windows

macOS: chạy bằng Terminal sau khi đã có `psql`; nếu PostgreSQL chạy ở host khác, đặt `PGHOST`/`PGPORT` và xác thực theo môi trường.

Windows: dùng PowerShell với `psql.exe` trong PATH, thay dấu xuống dòng lệnh Python `\` bằng một dòng liền. Dùng đường dẫn từ thư mục gốc repo, không chạy từ thư mục `sql/`. Nếu dùng pgAdmin/DBeaver, chạy các file chứa SQL thuần riêng; **đối với demo `05_security.sql` và `ra_fixture.sql` nên dùng psql** vì có metacommand.

CI GitHub Actions là một môi trường kiểm chứng bổ sung; kết quả trên máy TV2 phải có log riêng nếu nhóm muốn xác nhận môi trường Windows đã được dựng thành công.

## 4. Vai trò thực hiện và giới hạn

TV1 triển khai ràng buộc, kiểm thử, thiết kế. TV2 xác nhận dữ liệu và SQL, TV3 xác nhận RA và demo. **Chạy PASS ở CI không thay chữ ký review của các thành viên**; Gate 2 phải xác nhận chéo.

Phần B15 được thực thi bằng CHECK tên không rỗng và trigger ngày sinh/ngày lập hộ so với ngày bắt đầu đợt cư trú, ở cả chiều ghi đợt lẫn sửa hồ sơ cha. E1 được thực thi bằng assertion nghiệm thu, **không tự chặn mọi INSERT trong DB**; đây là quyết định phạm vi, xem đặc tả.
