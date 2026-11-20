# Biên bản kiểm thử quyền bằng phiên đăng nhập thật — 20/11/2026 (W2-T3-10)

**Phạm vi:** B1/B2 trên bản tích hợp có `02_constraints.sql`; quyền `USAGE` schema, quyền mặc định của PUBLIC, owner và role thực tế. Không thay cho ảnh chính thức Gate 3 (24/11) hoặc chữ ký thành viên.

- Người chạy: TV3, máy cá nhân Windows 11, **PostgreSQL 17.11** (x86_64-windows), `psql`, kết nối TCP `localhost`, xác thực `scram-sha-256`.
- Mã nguồn: nhánh `tv3/gate2-w2-t3`, dựng trên `fix/tv1-integration-gate2` @ `025c64b` (đã gồm toàn bộ PR #5).
- DB `csdl17_seed636` tạo mới, nạp theo [docs/08](../docs/08_huong_dan_dung_csdl.md): `01_schema` → `02_constraints` → `03_seed` → `tests/constraints_week2.sql` → `06_validation` → `04_queries` (cả 6 bước `ON_ERROR_STOP` thành công; validation PASS B06/B08/B09, E1, B15) → `05_security`.
- `05_security.sql`: thoát 0, đúng **6 lỗi `permission denied` cố ý** (dòng 207, 208, 209, 212, 253, 254), không có lỗi ngoài kịch bản.

## 1. Soát catalog — [tests/security_catalog_tv3.sql](security_catalog_tv3.sql), chạy bằng `postgres`

**14/14 PASS** ở lần chạy đầu; **15/15 PASS** sau khi bổ sung C15 (mục 4).

| Mã | Nội dung | Kết quả thực tế |
|---|---|---|
| C01–C03 | 3 role demo đều LOGIN; không SUPERUSER/CREATEDB/CREATEROLE/REPLICATION/BYPASSRLS; không là thành viên role nào | PASS; 0 vi phạm, 0 membership |
| C04 | Role demo không sở hữu database, schema `public`, bảng/VIEW hay hàm | PASS; mọi bảng/VIEW thuộc `postgres` |
| C05 | PUBLIC không có CONNECT/TEMP/CREATE trên DB demo | PASS; `{postgres=CTc, csdl17_admin=c, csdl17_reader=c, csdl17_report=c}` |
| C06–C07 | PUBLIC không có CREATE trên schema `public`; 3 role demo có USAGE | PASS; xem ghi chú (a) |
| C08–C10 | Không quyền bảng/VIEW/sequence cho PUBLIC; không `pg_default_acl`; không quyền theo cột | PASS; 0 / 0 / 0 |
| C11 | reader SELECT đúng 6 bảng nghiệp vụ, không ghi, không đọc `tai_khoan`/VIEW | PASS |
| C12 | report chỉ SELECT VIEW, không ghi VIEW, không quyền nào trên 7 bảng gốc | PASS |
| C13 | VIEW chỉ có `ma_to, ten_to, so_cu_dan` | PASS |
| C14 | 9 hàm `fn_*` của `02_constraints` đều SECURITY INVOKER | PASS; PUBLIC được EXECUTE cả 9 hàm, xem ghi chú (b) |
| C15 | admin INSERT/UPDATE được nhưng không DELETE `qua_trinh_cu_tru`, `bien_dong_cu_tru` (B12) | PASS (thêm ở mục 4) |

## 2. Đăng nhập thật — [tests/security_login_tv3.sql](security_login_tv3.sql)

Mỗi role đăng nhập bằng `psql -h localhost -U <role>` với mật khẩu tạm sinh ngẫu nhiên, chỉ nằm trong biến môi trường của phiên chạy; mật khẩu đã xóa (`PASSWORD NULL`) ngay sau khi chạy, **không ghi vào repo**. Dòng đầu mỗi log: `session_user = current_user = <role>`, `is_superuser = off`, kết nối TCP, tức là **không dùng `SET ROLE`**.

| Role | Kết quả | Chi tiết |
|---|---|---|
| `csdl17_reader` (B1) | **12/12 PASS**, thoát 0 | R01–R02 SELECT được; R03–R06 UPDATE/INSERT/DELETE/TRUNCATE `42501`; R07 `tai_khoan` `42501`; R08 VIEW B2 `42501`; R09 gọi `fn_chuyen_noi_bo` `42501`; R10 CREATE TABLE `42501`; R11 CREATE TEMP TABLE `42501`; R12 `SET ROLE csdl17_admin` `42501` |
| `csdl17_report` (B2) | **10/10 PASS**, thoát 0 | P01 SELECT VIEW được, 8 tổ (Tổ 01 = 34 … Tổ 08 = 0, khớp QSQL03); P02–P05 `cu_dan`, `qua_trinh_cu_tru`, `ho_cu_tru`, `tai_khoan` đều `42501`; P06 UPDATE VIEW `55000`, xem ghi chú (c); P07–P10 hàm/CREATE/TEMP/SET ROLE `42501` |

Dữ liệu không đổi: md5 của `cu_dan`, `qua_trinh_cu_tru`, `bien_dong_cu_tru`, `to_dan_pho` trước và sau hai phiên đều `cfeb74f6f8de46c1d00ab235a0478916`.

## 3. Ghi chú và giới hạn

- **(a)** Schema `public` vẫn giữ `=U` (USAGE cho PUBLIC) theo mặc định PostgreSQL ≥15. Không gây lộ dữ liệu vì PUBLIC không còn CONNECT vào DB demo (C05) và không có quyền trên bảng nào (C08). Giữ nguyên để không lệch với `05_security.sql` đã review.
- **(b)** PostgreSQL mặc định cho PUBLIC EXECUTE trên hàm mới. Vì 9 hàm `fn_*` là SECURITY INVOKER, gọi hàm vẫn phải có quyền trên bảng: R09/P07 bị chặn `42501`. Nếu sau này đổi hàm nào sang SECURITY DEFINER thì phải `REVOKE EXECUTE ... FROM PUBLIC`.
- **(c)** `vw_thong_ke_cu_dan_theo_to` có `GROUP BY` nên PostgreSQL báo `55000` (VIEW không tự cập nhật được) **trước** khi xét quyền. Việc report không có quyền ghi VIEW được chứng minh riêng ở C12.
- Role là đối tượng cấp cluster: database `postgres` mặc định vẫn cho PUBLIC CONNECT, nên role demo kết nối được vào đó nhưng không thấy bảng nghiệp vụ nào. Đây là cấu hình mặc định của cluster, ngoài phạm vi demo.
- Ảnh chính thức `B1_select_ok.png`, `B1_update_denied.png`, `B2_view_ok.png`, `B2_table_denied.png` vẫn chụp theo W3-T3-05 ngày 24/11, từ chính hai phiên đăng nhập này.

## 4. Bổ sung 20/11/2026: thu hồi DELETE bảng lịch sử khỏi admin (X02)

Review W3-T3-08 (mục 10, [docs/07](../docs/07_ma_tran_truy_van_va_review.md)) phát hiện `csdl17_admin` xóa được nhật ký biến động và đợt cư trú không bị tham chiếu, trái B12. `05_security.sql` thêm `REVOKE DELETE ON qua_trinh_cu_tru, bien_dong_cu_tru FROM csdl17_admin`. DB `csdl17_seed636` được dựng lại từ đầu theo cùng thứ tự rồi chạy lại:

| Kiểm tra | Kết quả |
|---|---|
| `05_security.sql` | Thoát 0, vẫn đúng 6 lỗi `permission denied` cố ý |
| Catalog | **15/15 PASS**; C15: `DELETE qua_trinh=false, DELETE bien_dong=false`, INSERT/UPDATE vẫn có |
| `csdl17_admin` (SET ROLE, trong ROLLBACK) | DELETE `bien_dong_cu_tru`, `qua_trinh_cu_tru`: `permission denied`; `fn_chuyen_noi_bo` vẫn thành công; DELETE cư dân chưa có lịch sử (mã 200) vẫn được, đúng B12 |
| Đăng nhập thật reader / report | 12/12, 10/10 PASS; mật khẩu tạm đã xóa |
