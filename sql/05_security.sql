-- =====================================================================
-- BTL CSDL Đề tài 17 — 05_security.sql
-- TV3 · cập nhật qua review TV1 13/11/2026 · Reviewer nghiệp vụ: TV2
-- Demo B1: phân quyền (reader được SELECT, bị từ chối UPDATE/INSERT/DELETE).
-- Demo B2: VIEW giới hạn thông tin (report chỉ xem số liệu tổng hợp theo tổ,
--          bị chặn khi đọc bảng gốc cu_dan).
--
-- Yêu cầu:
--   * PostgreSQL >= 15 (dùng tùy chọn security_invoker của VIEW).
--   * Đã chạy 01_schema.sql trên DB csdl17_cu_tru_demo. Nên chạy sau
--     03_seed.sql để VIEW có số liệu; trên bảng rỗng các phép thử quyền
--     vẫn đúng (quyền được kiểm tra trước khi đọc dữ liệu).
--   * Đường chạy chuẩn dùng postgres: cần CREATE ROLE, quyền trên bảng và SET ROLE.
--   * Ba role demo độc lập, LOGIN, không đặc quyền, không sở hữu đối tượng
--     trong database/public và không là thành viên role khác.
--     Chiều ngược (GRANT role_demo TO người_cài_đặt) được phép để thử SET ROLE.
--
-- Cách chạy (psql):
--   psql -U postgres -d csdl17_cu_tru_demo -f sql/05_security.sql
--   Script tự bật ON_ERROR_STOP khi thiết lập; chỉ tắt ở các lệnh bị từ chối cố ý.
--   Không chạy bằng psql --single-transaction vì demo có lỗi quyền cố ý.
-- GUI: bỏ các dòng \set khi chọn SQL thuần. Chọn trọn BEGIN..COMMIT của thiết lập,
-- gồm preflight bên dưới, không bắt đầu giữa tệp ở đoạn CREATE ROLE;
-- nếu bất kỳ lệnh nào lỗi, ROLLBACK và DỪNG. Chỉ chạy từng khối demo sau COMMIT
-- thiết lập thành công. Không gửi nguyên tệp có lệnh psql \set tới SQL editor.
--
-- Bảo mật tệp: KHÔNG ghi mật khẩu vào tệp này. Muốn đăng nhập thật bằng role
-- demo thì đặt mật khẩu trong psql bằng: \password csdl17_reader
-- Dữ liệu: 100% mô phỏng.
-- =====================================================================

\set ON_ERROR_STOP on
BEGIN;
SET search_path = public;

-- Kiểm tra TOÀN BỘ role có sẵn trước CREATE ROLE, VIEW, GRANT hoặc REVOKE.
-- Từ chối thay vì tự hạ quyền/sửa owner/membership của role trên cluster dùng chung.
DO $preflight$
DECLARE
    demo_role RECORD;
    reason TEXT;
BEGIN
    FOR demo_role IN
        SELECT oid, rolname, rolsuper, rolcreatedb, rolcreaterole,
               rolreplication, rolbypassrls, rolcanlogin
        FROM pg_catalog.pg_roles
        WHERE rolname IN ('csdl17_admin', 'csdl17_reader', 'csdl17_report')
        ORDER BY rolname
    LOOP
        reason := NULL;
        IF demo_role.rolsuper OR demo_role.rolcreatedb OR demo_role.rolcreaterole
           OR demo_role.rolreplication OR demo_role.rolbypassrls
           OR NOT demo_role.rolcanlogin THEN
            reason := 'attributes: cần LOGIN, NOSUPERUSER, NOCREATEDB, NOCREATEROLE, NOREPLICATION, NOBYPASSRLS';
        ELSIF EXISTS (
            SELECT 1 FROM pg_catalog.pg_database
            WHERE datname = current_database() AND datdba = demo_role.oid
        ) OR EXISTS (
            SELECT 1 FROM pg_catalog.pg_namespace
            WHERE nspname = 'public' AND nspowner = demo_role.oid
        ) OR EXISTS (
            SELECT 1 FROM pg_catalog.pg_class c
            JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
            WHERE n.nspname = 'public' AND c.relowner = demo_role.oid
        ) THEN
            reason := 'ownership: role demo không được sở hữu database, schema public hoặc quan hệ trong public';
        ELSIF EXISTS (
            SELECT 1 FROM pg_catalog.pg_auth_members
            WHERE member = demo_role.oid
        ) THEN
            reason := 'membership: role demo phải độc lập, không được là thành viên role khác';
        END IF;
        IF reason IS NOT NULL THEN
            RAISE EXCEPTION USING ERRCODE = '42501',
                MESSAGE = format('CSDL17_PREFLIGHT: từ chối role %I (%s)', demo_role.rolname, reason),
                HINT = 'Giữ nguyên role có sẵn. Dùng cluster demo sạch hoặc nhờ quản trị viên xác minh riêng.';
        END IF;
    END LOOP;
END
$preflight$;


-- =====================================================================
-- PHẦN 0. TẠO ROLE (chạy lại nhiều lần không lỗi)
-- =====================================================================
-- csdl17_admin  : quản trị demo, được đọc/ghi dữ liệu nghiệp vụ.
-- csdl17_reader : cán bộ tra cứu, CHỈ ĐỌC các bảng nghiệp vụ.
-- csdl17_report : cán bộ tổng hợp, CHỈ ĐỌC VIEW thống kê.
-- Không role nào là SUPERUSER hay chủ sở hữu bảng (nếu là owner, phép thử
-- quyền sẽ không còn ý nghĩa).

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'csdl17_admin') THEN
        CREATE ROLE csdl17_admin  LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'csdl17_reader') THEN
        CREATE ROLE csdl17_reader LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'csdl17_report') THEN
        CREATE ROLE csdl17_report LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE;
    END IF;
END
$$;


-- =====================================================================
-- PHẦN 1. VIEW THỐNG KÊ (dùng cho Demo B2)
-- =====================================================================
-- Số cư dân đang cư trú theo từng tổ tại ngày tham chiếu cố định 2026-11-20.
-- Chỉ trả về ma_to, ten_to, so_cu_dan: KHÔNG có họ tên, ngày sinh, mã cư dân.
-- LEFT JOIN và điều kiện thời gian đặt trong ON để giữ cả tổ có 0 người.
-- security_invoker = false (mặc định): view đọc bảng nền bằng quyền của
-- CHỦ SỞ HỮU VIEW, nên role report không cần quyền trên bảng nền.

CREATE OR REPLACE VIEW vw_thong_ke_cu_dan_theo_to
WITH (security_invoker = false) AS
SELECT t.ma_to,
       t.ten_to,
       COUNT(DISTINCT q.ma_cu_dan) AS so_cu_dan
FROM to_dan_pho t
LEFT JOIN dia_chi d          ON d.ma_to = t.ma_to
LEFT JOIN ho_cu_tru h        ON h.ma_dia_chi = d.ma_dia_chi
LEFT JOIN qua_trinh_cu_tru q ON q.ma_ho = h.ma_ho
                            AND q.ngay_bat_dau <= DATE '2026-11-20'
                            AND (q.ngay_ket_thuc IS NULL
                                 OR q.ngay_ket_thuc >= DATE '2026-11-20')
GROUP BY t.ma_to, t.ten_to;

COMMENT ON VIEW vw_thong_ke_cu_dan_theo_to IS
    'Demo B2: số cư dân đang cư trú theo tổ tại 2026-11-20; không chứa dữ liệu nhận diện cá nhân.';


-- =====================================================================
-- PHẦN 2. CẤP VÀ THU HỒI QUYỀN (nguyên tắc quyền tối thiểu)
-- =====================================================================

-- 2.1. Đóng quyền mặc định của PUBLIC (mọi role đều thuộc PUBLIC).
DO $$
BEGIN
    EXECUTE format('REVOKE ALL ON DATABASE %I FROM PUBLIC', current_database());
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO csdl17_admin, csdl17_reader, csdl17_report',
                   current_database());
END
$$;

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO csdl17_admin, csdl17_reader, csdl17_report;

-- 2.2. Admin demo: đọc/ghi dữ liệu, KHÔNG được xóa/sửa cấu trúc bảng
--      (không có quyền TRUNCATE, không phải owner nên không DROP/ALTER được).
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO csdl17_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO csdl17_admin;
-- "ALL TABLES" gồm cả VIEW; VIEW tổng hợp không ghi được nên chỉ để SELECT.
REVOKE INSERT, UPDATE, DELETE ON vw_thong_ke_cu_dan_theo_to FROM csdl17_admin;

-- 2.3. Reader (Demo B1): chỉ SELECT 6 bảng nghiệp vụ.
--      Không cấp tai_khoan vì tra cứu cư dân không cần thông tin tài khoản.
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM csdl17_reader;
GRANT SELECT ON to_dan_pho, dia_chi, ho_cu_tru, cu_dan,
                qua_trinh_cu_tru, bien_dong_cu_tru
    TO csdl17_reader;

-- 2.4. Report (Demo B2): chỉ SELECT VIEW thống kê, không có quyền bảng gốc.
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM csdl17_report;
GRANT SELECT ON vw_thong_ke_cu_dan_theo_to TO csdl17_report;

-- 2.5. Ảnh minh chứng cấu hình quyền: bảng quyền hiện có của 3 role.
SELECT grantee AS role,
       table_name AS bang_hoac_view,
       string_agg(privilege_type, ', ' ORDER BY privilege_type) AS quyen
FROM information_schema.role_table_grants
WHERE grantee IN ('csdl17_admin', 'csdl17_reader', 'csdl17_report')
GROUP BY grantee, table_name
ORDER BY grantee, table_name;

COMMIT;


-- =====================================================================
-- PHẦN 3. DEMO B1 — PHÂN QUYỀN: SELECT ĐƯỢC, SỬA BỊ TỪ CHỐI
-- Ảnh cần chụp: SEC_B1_select_ok.png, SEC_B1_denied.png, SEC_B1_unchanged.png
-- =====================================================================

-- 3.1. Kiểm tra quyền bằng hàm hệ thống (mong đợi: true, false, false, false)
SELECT has_table_privilege('csdl17_reader', 'cu_dan', 'SELECT') AS reader_select,
       has_table_privilege('csdl17_reader', 'cu_dan', 'UPDATE') AS reader_update,
       has_table_privilege('csdl17_reader', 'cu_dan', 'INSERT') AS reader_insert,
       has_table_privilege('csdl17_reader', 'cu_dan', 'DELETE') AS reader_delete;

-- 3.2. Dữ liệu TRƯỚC khi thử sửa (ghi lại để so sánh)
SELECT ma_cu_dan, ho_ten, ghi_chu FROM cu_dan WHERE ma_cu_dan = 1;

-- 3.3. Chuyển sang role reader
SET ROLE csdl17_reader;
SELECT current_user AS dang_chay_voi_role;          -- mong đợi: csdl17_reader

-- 3.4. ĐƯỢC PHÉP: tra cứu
SELECT ma_cu_dan, ho_ten, ngay_sinh, gioi_tinh
FROM cu_dan
ORDER BY ma_cu_dan
LIMIT 5;

-- 3.5. BỊ TỪ CHỐI (cố ý). Mong đợi: ERROR: permission denied for table ...
\set ON_ERROR_STOP off
UPDATE cu_dan SET ghi_chu = 'reader thu sua' WHERE ma_cu_dan = 1;
INSERT INTO to_dan_pho (ten_to) VALUES ('Tổ thử quyền');
DELETE FROM qua_trinh_cu_tru WHERE ma_qua_trinh = 1;

-- 3.6. BỊ TỪ CHỐI: bảng không được cấp. Mong đợi: permission denied for table tai_khoan
SELECT * FROM tai_khoan LIMIT 1;

\set ON_ERROR_STOP on
RESET ROLE;
SELECT current_user AS da_tro_ve_role;

-- 3.7. Dữ liệu SAU khi thử sửa: phải giống hệt 3.2
SELECT ma_cu_dan, ho_ten, ghi_chu FROM cu_dan WHERE ma_cu_dan = 1;

-- 3.8. Đối chứng: admin được sửa. Chạy trong giao dịch rồi ROLLBACK để giữ DB sạch.
SET ROLE csdl17_admin;
BEGIN;
UPDATE cu_dan SET ghi_chu = 'admin thu sua' WHERE ma_cu_dan = 1;   -- mong đợi: UPDATE 1 (UPDATE 0 nếu chưa có seed)
ROLLBACK;
RESET ROLE;


-- =====================================================================
-- PHẦN 4. DEMO B2 — VIEW GIỚI HẠN THÔNG TIN
-- Ảnh cần chụp: SEC_B2_viewdef.png, SEC_B2_view_ok.png, SEC_B2_denied.png
-- =====================================================================

-- 4.1. Nội dung VIEW (chứng minh view không lấy cột nhận diện cá nhân)
SELECT pg_get_viewdef('vw_thong_ke_cu_dan_theo_to'::regclass, true) AS dinh_nghia_view;

-- 4.2. Kiểm tra quyền (mong đợi: true, false, false)
SELECT has_table_privilege('csdl17_report', 'vw_thong_ke_cu_dan_theo_to', 'SELECT') AS report_xem_view,
       has_table_privilege('csdl17_report', 'cu_dan', 'SELECT')                     AS report_xem_cu_dan,
       has_table_privilege('csdl17_report', 'qua_trinh_cu_tru', 'SELECT')           AS report_xem_qua_trinh;

-- 4.3. Chuyển sang role report
SET ROLE csdl17_report;
SELECT current_user AS dang_chay_voi_role;          -- mong đợi: csdl17_report

-- 4.4. ĐƯỢC PHÉP: xem số liệu tổng hợp
SELECT ma_to, ten_to, so_cu_dan
FROM vw_thong_ke_cu_dan_theo_to
ORDER BY ma_to;

-- 4.5. BỊ TỪ CHỐI (cố ý): đọc trực tiếp bảng gốc
\set ON_ERROR_STOP off
SELECT ho_ten, ngay_sinh FROM cu_dan LIMIT 5;        -- permission denied for table cu_dan
SELECT * FROM qua_trinh_cu_tru LIMIT 5;              -- permission denied for table qua_trinh_cu_tru

\set ON_ERROR_STOP on
RESET ROLE;


-- =====================================================================
-- PHẦN 5. DỌN DẸP (chỉ chạy khi muốn làm lại demo từ đầu; đang để chú thích)
-- =====================================================================
-- DROP OWNED BY thu hồi mọi quyền đã cấp cho role trong DB hiện tại
-- (kể cả quyền CONNECT trên database). Các role demo không sở hữu đối tượng nào.
--
-- DROP OWNED BY csdl17_admin, csdl17_reader, csdl17_report;
-- DROP ROLE IF EXISTS csdl17_admin, csdl17_reader, csdl17_report;
-- DROP VIEW IF EXISTS vw_thong_ke_cu_dan_theo_to;
