-- =====================================================================
-- BTL CSDL Đề tài 17 — tests/security_login_tv3.sql
-- W2-T3-10 (phần 2/2): thử B1/B2 bằng PHIÊN ĐĂNG NHẬP THẬT của role demo,
-- không dùng SET ROLE từ postgres. Một tệp dùng cho cả hai role; tệp tự
-- nhận role theo session_user.
-- TV3 · 20/11/2026 · PostgreSQL 17. Không sửa dữ liệu: mọi lệnh ghi đều phải
-- bị từ chối; nếu lệnh nào lọt, khối DO ném lỗi và giao dịch ngầm bị hủy.
--
-- Chuẩn bị (ngoài repo, KHÔNG ghi mật khẩu vào tệp):
--   psql -U postgres -c "\password csdl17_reader"   (tương tự csdl17_report)
-- Chạy:
--   psql -X -h localhost -U csdl17_reader -d csdl17_seed636 -f tests/security_login_tv3.sql
--   psql -X -h localhost -U csdl17_report -d csdl17_seed636 -f tests/security_login_tv3.sql
-- Sau khi chạy có thể xóa mật khẩu: ALTER ROLE csdl17_reader PASSWORD NULL;
-- Kết quả: mỗi phép thử in một NOTICE "[PASS]" hoặc "[FAIL]"; dòng cuối đếm tổng.
-- =====================================================================
\set ON_ERROR_STOP on
\pset footer off

-- 1. Danh tính phiên: session_user phải là role demo (đăng nhập thật),
--    trùng current_user, không phải superuser.
SELECT session_user                        AS dang_nhap_bang,
       current_user                        AS quyen_dang_dung,
       current_setting('is_superuser')     AS la_superuser,
       inet_client_addr() IS NOT NULL      AS ket_noi_tcp,
       current_database()                  AS csdl;

SELECT session_user = 'csdl17_reader' AS la_reader,
       session_user = 'csdl17_report' AS la_report
\gset

-- 2. Bộ thử: mỗi dòng (mã, lệnh SQL, kỳ vọng). Kỳ vọng 'OK' = chạy được,
--    hoặc một SQLSTATE: 42501 = insufficient_privilege; 55000 = VIEW không cập nhật được.
\if :la_reader
\echo '== Demo B1, đăng nhập bằng csdl17_reader =='
DO $t$
DECLARE
    ca RECORD; ma_loi TEXT; n BIGINT; dat INT := 0; tong INT := 0;
BEGIN
    IF session_user <> current_user OR current_setting('is_superuser') = 'on' THEN
        RAISE EXCEPTION 'Không phải phiên đăng nhập thật của role demo';
    END IF;
    FOR ca IN SELECT * FROM (VALUES
        ('R01', 'SELECT count(*) FROM cu_dan',                                   'OK'),
        ('R02', 'SELECT count(*) FROM qua_trinh_cu_tru WHERE ngay_ket_thuc IS NULL', 'OK'),
        ('R03', 'UPDATE cu_dan SET ghi_chu = ''reader thu sua'' WHERE ma_cu_dan = 1', '42501'),
        ('R04', 'INSERT INTO to_dan_pho (ten_to) VALUES (''Tổ thử quyền'')',     '42501'),
        ('R05', 'DELETE FROM qua_trinh_cu_tru WHERE ma_qua_trinh = 1',           '42501'),
        ('R06', 'TRUNCATE bien_dong_cu_tru',                                     '42501'),
        ('R07', 'SELECT count(*) FROM tai_khoan',                                '42501'),
        ('R08', 'SELECT count(*) FROM vw_thong_ke_cu_dan_theo_to',               '42501'),
        ('R09', 'SELECT count(*) FROM fn_chuyen_noi_bo(1, 2, ''THUONG_TRU'', DATE ''2026-11-20'', 2)', '42501'),
        ('R10', 'CREATE TABLE public.reader_thu_tao (x int)',                    '42501'),
        ('R11', 'CREATE TEMP TABLE reader_tam (x int)',                          '42501'),
        ('R12', 'SET ROLE csdl17_admin',                                         '42501')
    ) AS v(ma, lenh, ky_vong)
    LOOP
        tong := tong + 1;
        BEGIN
            EXECUTE ca.lenh;
            GET DIAGNOSTICS n = ROW_COUNT;
            ma_loi := 'OK';
        EXCEPTION WHEN OTHERS THEN
            ma_loi := SQLSTATE;
        END;
        IF ma_loi = ca.ky_vong THEN dat := dat + 1; END IF;
        RAISE NOTICE '[%] % | kỳ vọng % | thực tế % | %',
            CASE WHEN ma_loi = ca.ky_vong THEN 'PASS' ELSE 'FAIL' END,
            ca.ma, ca.ky_vong, ma_loi, ca.lenh;
    END LOOP;
    RAISE NOTICE 'TONG csdl17_reader: %/% PASS', dat, tong;
    IF dat <> tong THEN RAISE EXCEPTION 'Có phép thử quyền FAIL'; END IF;
END
$t$;

-- Minh họa trực tiếp cho ảnh chụp (lỗi cố ý, không dừng script):
SELECT ma_cu_dan, ho_ten, ngay_sinh FROM cu_dan ORDER BY ma_cu_dan LIMIT 3;
\set ON_ERROR_STOP off
UPDATE cu_dan SET ghi_chu = 'reader thu sua' WHERE ma_cu_dan = 1;
\set ON_ERROR_STOP on
\endif

\if :la_report
\echo '== Demo B2, đăng nhập bằng csdl17_report =='
DO $t$
DECLARE
    ca RECORD; ma_loi TEXT; n BIGINT; dat INT := 0; tong INT := 0;
BEGIN
    IF session_user <> current_user OR current_setting('is_superuser') = 'on' THEN
        RAISE EXCEPTION 'Không phải phiên đăng nhập thật của role demo';
    END IF;
    FOR ca IN SELECT * FROM (VALUES
        ('P01', 'SELECT count(*) FROM vw_thong_ke_cu_dan_theo_to',                'OK'),
        ('P02', 'SELECT count(*) FROM cu_dan',                                    '42501'),
        ('P03', 'SELECT count(*) FROM qua_trinh_cu_tru',                          '42501'),
        ('P04', 'SELECT count(*) FROM ho_cu_tru',                                 '42501'),
        ('P05', 'SELECT count(*) FROM tai_khoan',                                 '42501'),
        -- P06: VIEW có GROUP BY nên không tự cập nhật được; PostgreSQL báo 55000
        -- (object_not_in_prerequisite_state) TRƯỚC khi xét quyền. Việc report
        -- không có quyền INSERT/UPDATE/DELETE trên VIEW được kiểm ở C12 (catalog).
        ('P06', 'UPDATE vw_thong_ke_cu_dan_theo_to SET so_cu_dan = 0',            '55000'),
        ('P07', 'SELECT count(*) FROM fn_chuyen_noi_bo(1, 2, ''THUONG_TRU'', DATE ''2026-11-20'', 2)', '42501'),
        ('P08', 'CREATE TABLE public.report_thu_tao (x int)',                     '42501'),
        ('P09', 'CREATE TEMP TABLE report_tam (x int)',                           '42501'),
        ('P10', 'SET ROLE csdl17_reader',                                         '42501')
    ) AS v(ma, lenh, ky_vong)
    LOOP
        tong := tong + 1;
        BEGIN
            EXECUTE ca.lenh;
            ma_loi := 'OK';
        EXCEPTION WHEN OTHERS THEN
            ma_loi := SQLSTATE;
        END;
        IF ma_loi = ca.ky_vong THEN dat := dat + 1; END IF;
        RAISE NOTICE '[%] % | kỳ vọng % | thực tế % | %',
            CASE WHEN ma_loi = ca.ky_vong THEN 'PASS' ELSE 'FAIL' END,
            ca.ma, ca.ky_vong, ma_loi, ca.lenh;
    END LOOP;
    RAISE NOTICE 'TONG csdl17_report: %/% PASS', dat, tong;
    IF dat <> tong THEN RAISE EXCEPTION 'Có phép thử quyền FAIL'; END IF;
END
$t$;

-- Minh họa trực tiếp cho ảnh chụp (lỗi cố ý, không dừng script):
SELECT ma_to, ten_to, so_cu_dan FROM vw_thong_ke_cu_dan_theo_to ORDER BY ma_to;
\set ON_ERROR_STOP off
SELECT ho_ten, ngay_sinh FROM cu_dan LIMIT 3;
\set ON_ERROR_STOP on
\endif
