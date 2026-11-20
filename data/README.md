# Dữ liệu giả lập — nhóm 38, lớp 174356

Seed cố định **20261110**, 7 CSV UTF-8/LF, tổng **636 bản ghi**: 8 tổ, 50 địa chỉ, 60 hộ, 200 cư dân, 250 đợt, 63 sự kiện, 5 tài khoản. Dùng dữ liệu mô phỏng học thuật, không có CCCD/SĐT hoặc mật khẩu thật.

**Đường nạp duy nhất là INSERT trong [03_seed.sql](../sql/03_seed.sql).** CSV chỉ để đối chiếu; không nạp thêm CSV vào DB đã seed.

```sh
python3 scripts/generate_data.py
psql -U postgres -d csdl17_cu_tru_demo -v ON_ERROR_STOP=1 -f sql/01_schema.sql
psql -U postgres -d csdl17_cu_tru_demo -v ON_ERROR_STOP=1 -f sql/02_constraints.sql
psql -U postgres -d csdl17_cu_tru_demo -v ON_ERROR_STOP=1 -f sql/03_seed.sql
psql -U postgres -d csdl17_cu_tru_demo -v ON_ERROR_STOP=1 -f sql/06_validation.sql
```

Seed reset 7 bảng và đồng bộ sequence; chỉ dùng DB mô phỏng riêng. Generator kiểm dữ liệu trước ghi và hỗ trợ `--output-root /tmp/csdl17-generated`. Sửa B15 chỉ hiệu chỉnh ngày lập hộ để không muộn hơn các đợt thuộc hộ; giữ ID/ngày cư trú/ngày sự kiện. Thứ tự FK: tổ → địa chỉ → hộ; cư dân/tài khoản → đợt → biến động.

Ngày đối chiếu d=20/11/2026, ngày cuối bao gồm. Xem [kế hoạch](../docs/05_ke_hoach_du_lieu_va_sql.md), [fixture29](../tests/week1_fixture.sql), [expected](../tests/week1_expected.json), [ma trận](../tests/test_scenarios.md), [log PostgreSQL](../tests/week1_execution_results.json). TV1 đã bổ sung constraint/trigger E1/B15 tại `02_constraints.sql`; hướng dẫn dựng đầy đủ, kiểm RA và bảo mật xem [docs/08_huong_dan_dung_csdl.md](../docs/08_huong_dan_dung_csdl.md).

**Đối chứng S04/S14b:** Seed636 có 4 địa chỉ không có hộ (47–50), không phải chỉ 49–50. Ở seed636 không có cư dân có hai đợt hiệu lực đồng thời trong cùng một hộ; fixture nhỏ tại `tests/ra_fixture.sql` có tình huống đó để đối chiếu `COUNT(*)` với `COUNT(DISTINCT)`. Không sửa seed hoặc kỳ vọng chỉ để đạt PASS.
