-- =====================================================================
-- BTL CSDL Đề tài 17 — tests/security_catalog_tv3.sql
-- W2-T3-10 (phần 1/2): soát quyền USAGE schema, quyền mặc định/PUBLIC,
-- owner và thuộc tính role thực tế trong catalog, SAU KHI đã chạy
-- 01_schema → 02_constraints → 03_seed → 05_security.
-- TV3 · 20/11/2026 · PostgreSQL 17. Chỉ đọc catalog, không sửa gì.
--
-- Chạy bằng tài khoản quản trị (chỉ đọc pg_roles, pg_class, pg_proc, information_schema):
--   psql -X -U postgres -d csdl17_seed636 -f tests/security_catalog_tv3.sql
-- Mỗi dòng: ma, mo_ta, ket_qua (PASS/FAIL), chi_tiet.
-- Phần 2/2 (đăng nhập thật bằng role): tests/security_login_tv3.sql.
-- =====================================================================
\set ON_ERROR_STOP on
\pset footer off

WITH demo AS (
    SELECT oid, rolname, rolsuper, rolcreatedb, rolcreaterole, rolreplication,
           rolbypassrls, rolcanlogin, rolinherit
    FROM pg_roles WHERE rolname IN ('csdl17_admin', 'csdl17_reader', 'csdl17_report')
), rel AS (
    SELECT c.oid, c.relname, c.relkind, c.relacl, pg_get_userbyid(c.relowner) AS owner
    FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relkind IN ('r', 'v', 'S', 'm', 'p')
), fn AS (
    SELECT p.oid, p.proname, p.prosecdef, p.proacl
    FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public' AND p.proname LIKE 'fn\_%'   -- bỏ qua hàm gbt_* của btree_gist
), kq(ma, mo_ta, dat, chi_tiet) AS (
    SELECT 'C01', 'Đủ 3 role demo, đều LOGIN',
           count(*) = 3 AND bool_and(rolcanlogin),
           string_agg(rolname, ', ' ORDER BY rolname)
    FROM demo
    UNION ALL
    SELECT 'C02', 'Role demo không SUPERUSER/CREATEDB/CREATEROLE/REPLICATION/BYPASSRLS',
           NOT bool_or(rolsuper OR rolcreatedb OR rolcreaterole OR rolreplication OR rolbypassrls),
           count(*) FILTER (WHERE rolsuper OR rolcreatedb OR rolcreaterole OR rolreplication OR rolbypassrls) || ' role vi phạm'
    FROM demo
    UNION ALL
    SELECT 'C03', 'Role demo không là thành viên role nào (không SET ROLE leo quyền được)',
           NOT EXISTS (SELECT 1 FROM pg_auth_members m JOIN demo ON demo.oid = m.member),
           (SELECT count(*) FROM pg_auth_members m JOIN demo ON demo.oid = m.member) || ' membership'
    UNION ALL
    SELECT 'C04', 'Không role demo nào sở hữu database, schema public hay quan hệ/hàm trong public',
           NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = current_database() AND datdba IN (SELECT oid FROM demo))
       AND NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'public' AND nspowner IN (SELECT oid FROM demo))
       AND NOT EXISTS (SELECT 1 FROM rel WHERE owner IN (SELECT rolname FROM demo))
       AND NOT EXISTS (SELECT 1 FROM fn JOIN pg_proc p ON p.oid = fn.oid WHERE p.proowner IN (SELECT oid FROM demo)),
           'owner bảng/view: ' || (SELECT string_agg(DISTINCT owner, ', ') FROM rel)
    UNION ALL
    SELECT 'C05', 'PUBLIC không có CONNECT/TEMP/CREATE trên database demo',
           NOT has_database_privilege('public', current_database(), 'CONNECT')
       AND NOT has_database_privilege('public', current_database(), 'TEMP')
       AND NOT has_database_privilege('public', current_database(), 'CREATE'),
           (SELECT datacl::text FROM pg_database WHERE datname = current_database())
    UNION ALL
    SELECT 'C06', 'PUBLIC không có CREATE trên schema public',
           NOT has_schema_privilege('public', 'public', 'CREATE'),
           (SELECT nspacl::text FROM pg_namespace WHERE nspname = 'public')
    UNION ALL
    SELECT 'C07', '3 role demo có USAGE trên schema public',
           bool_and(has_schema_privilege(rolname, 'public', 'USAGE')),
           string_agg(rolname || '=' || has_schema_privilege(rolname, 'public', 'USAGE'), ', ' ORDER BY rolname)
    FROM demo
    UNION ALL
    SELECT 'C08', 'Không bảng/view/sequence nào trong public cấp quyền cho PUBLIC',
           -- relacl NULL = mặc định, chỉ owner có quyền; grantee 0 = PUBLIC
           NOT EXISTS (SELECT 1 FROM rel, aclexplode(rel.relacl) a WHERE a.grantee = 0),
           (SELECT count(*) FROM rel, aclexplode(rel.relacl) a WHERE a.grantee = 0) || ' quyền PUBLIC'
    UNION ALL
    SELECT 'C09', 'Không có quyền mặc định (ALTER DEFAULT PRIVILEGES) tự cấp cho đối tượng mới',
           NOT EXISTS (SELECT 1 FROM pg_default_acl),
           (SELECT count(*) FROM pg_default_acl) || ' dòng pg_default_acl'
    UNION ALL
    SELECT 'C10', 'Không có quyền cấp theo cột (cột lẻ) cho role demo',
           NOT EXISTS (SELECT 1 FROM information_schema.column_privileges
                       WHERE grantee IN ('csdl17_admin', 'csdl17_reader', 'csdl17_report')
                         AND table_schema = 'public'
                         AND NOT has_table_privilege(grantee, quote_ident(table_name), privilege_type)),
           'chỉ có quyền mức bảng'
    UNION ALL
    SELECT 'C11', 'reader: SELECT đúng 6 bảng nghiệp vụ, không ghi, không đọc tai_khoan/VIEW',
           (SELECT count(*) FROM rel WHERE relkind = 'r' AND has_table_privilege('csdl17_reader', oid, 'SELECT')) = 6
       AND NOT has_table_privilege('csdl17_reader', 'tai_khoan', 'SELECT')
       AND NOT has_table_privilege('csdl17_reader', 'vw_thong_ke_cu_dan_theo_to', 'SELECT')
       AND NOT EXISTS (SELECT 1 FROM rel WHERE has_table_privilege('csdl17_reader', oid, 'INSERT,UPDATE,DELETE,TRUNCATE')),
           (SELECT string_agg(relname, ', ' ORDER BY relname) FROM rel WHERE has_table_privilege('csdl17_reader', oid, 'SELECT'))
    UNION ALL
    SELECT 'C12', 'report: chỉ SELECT VIEW thống kê (không ghi VIEW), không quyền nào trên 7 bảng gốc',
           has_table_privilege('csdl17_report', 'vw_thong_ke_cu_dan_theo_to', 'SELECT')
       AND NOT has_table_privilege('csdl17_report', 'vw_thong_ke_cu_dan_theo_to', 'INSERT,UPDATE,DELETE,TRUNCATE')
       AND NOT EXISTS (SELECT 1 FROM rel WHERE relkind = 'r'
                       AND has_table_privilege('csdl17_report', oid, 'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')),
           (SELECT string_agg(relname, ', ' ORDER BY relname) FROM rel WHERE has_table_privilege('csdl17_report', oid, 'SELECT'))
    UNION ALL
    SELECT 'C13', 'VIEW B2 không có cột nhận diện (ho_ten, ngay_sinh, ma_cu_dan)',
           NOT EXISTS (SELECT 1 FROM information_schema.columns
                       WHERE table_name = 'vw_thong_ke_cu_dan_theo_to' AND column_name IN ('ho_ten', 'ngay_sinh', 'ma_cu_dan')),
           (SELECT string_agg(column_name, ', ' ORDER BY ordinal_position) FROM information_schema.columns
            WHERE table_name = 'vw_thong_ke_cu_dan_theo_to')
    UNION ALL
    SELECT 'C14', 'Hàm fn_* của 02_constraints đều SECURITY INVOKER (EXECUTE của PUBLIC không vượt quyền bảng)',
           NOT bool_or(prosecdef),
           count(*) || ' hàm, ' || count(*) FILTER (WHERE has_function_privilege('public', oid, 'EXECUTE')) || ' hàm PUBLIC được EXECUTE'
    FROM fn
)
SELECT ma, mo_ta, CASE WHEN dat THEN 'PASS' ELSE 'FAIL' END AS ket_qua, chi_tiet
FROM kq ORDER BY ma;
