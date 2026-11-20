-- =====================================================================
-- BTL CSDL Đề tài 17 — tests/security_b12_tv1.sql
-- TV1 · 20/11/2026 · PostgreSQL 17. Review PR #8 (X02/B12), Issue #9 P0-A1.
-- Bổ sung cho tests/security_catalog_tv3.sql (C15) và security_login_tv3.sql:
--   K01  Ma trận quyền bảng/VIEW của 3 role khớp CHÍNH XÁC thiết kế
--        (SELECT/INSERT/UPDATE/DELETE/TRUNCATE, kiểm từng quyền riêng lẻ).
--   K02  csdl17_admin DELETE qua_trinh_cu_tru  -> 42501 (B12).
--   K03  csdl17_admin DELETE bien_dong_cu_tru  -> 42501 (B12).
--   K04  csdl17_admin TRUNCATE hai bảng lịch sử -> 42501.
--   K05  csdl17_admin vẫn chạy được fn_chuyen_noi_bo (UPDATE + 2 INSERT,
--        không cần DELETE) trên một đợt hợp lệ; mọi thay đổi bị ROLLBACK.
-- Lỗi VIEW không cập nhật được (55000) KHÔNG được tính là lỗi quyền:
-- quyền trên VIEW chỉ kiểm bằng ACL (has_table_privilege) ở K01.
--
-- Chạy bằng tài khoản quản trị SAU 05_security.sql (đổi role bằng SET ROLE
-- trong giao dịch, kết thúc bằng ROLLBACK nên không sửa dữ liệu):
--   psql -X -v ON_ERROR_STOP=1 -U postgres -d csdl17_seed636 -f tests/security_b12_tv1.sql
-- Thoát mã khác 0 nếu có ca FAIL.
-- =====================================================================
\set ON_ERROR_STOP on
\pset footer off

-- K01: ma trận quyền thực tế so với kỳ vọng (chỉ đọc catalog).
WITH vai(role) AS (VALUES ('csdl17_admin'), ('csdl17_reader'), ('csdl17_report')),
bang(obj) AS (VALUES ('to_dan_pho'), ('dia_chi'), ('ho_cu_tru'), ('cu_dan'),
                     ('qua_trinh_cu_tru'), ('tai_khoan'), ('bien_dong_cu_tru'),
                     ('vw_thong_ke_cu_dan_theo_to')),
quyen(priv) AS (VALUES ('SELECT'), ('INSERT'), ('UPDATE'), ('DELETE'), ('TRUNCATE')),
thuc_te AS (
    SELECT role, obj, priv, has_table_privilege(role, obj, priv) AS co
    FROM vai, bang, quyen
),
ky_vong AS (
    SELECT role, obj, priv,
        CASE
            WHEN role = 'csdl17_admin' AND obj = 'vw_thong_ke_cu_dan_theo_to' THEN priv = 'SELECT'
            WHEN role = 'csdl17_admin' AND obj IN ('qua_trinh_cu_tru', 'bien_dong_cu_tru')
                THEN priv IN ('SELECT', 'INSERT', 'UPDATE')
            WHEN role = 'csdl17_admin' THEN priv IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE')
            WHEN role = 'csdl17_reader' THEN priv = 'SELECT'
                 AND obj NOT IN ('tai_khoan', 'vw_thong_ke_cu_dan_theo_to')
            WHEN role = 'csdl17_report' THEN priv = 'SELECT' AND obj = 'vw_thong_ke_cu_dan_theo_to'
        END AS co
    FROM vai, bang, quyen
)
SELECT 'K01' AS ma,
       CASE WHEN count(*) FILTER (WHERE t.co <> k.co) = 0 THEN 'PASS' ELSE 'FAIL' END AS ket_qua,
       count(*) AS so_o_kiem,
       count(*) FILTER (WHERE t.co) AS so_quyen_co,
       coalesce(string_agg(t.role || ':' || t.obj || ':' || t.priv || '=' || t.co, '; ')
                FILTER (WHERE t.co <> k.co), 'không lệch') AS chi_tiet_lech
FROM thuc_te t JOIN ky_vong k USING (role, obj, priv)
\gset k01_
\echo '[' :k01_ket_qua '] K01 ma trận quyền 3 role x 8 đối tượng x 5 quyền:' :k01_so_o_kiem 'ô,' :k01_so_quyen_co 'quyền được cấp;' :k01_chi_tiet_lech

-- K02–K05: thực thi thật dưới role admin, rồi hoàn tác toàn bộ.
BEGIN;
SET LOCAL ROLE csdl17_admin;
DO $t$
DECLARE
    ca RECORD; ma_loi TEXT; dat INT := 0; tong INT := 0;
    v_dot RECORD; v_ho BIGINT; v_kq RECORD; thanh_cong BOOLEAN := false;
    loi_quyen INT := 0; so_thu INT := 0;
BEGIN
    IF current_user <> 'csdl17_admin' THEN
        RAISE EXCEPTION 'Phải chạy dưới role csdl17_admin, đang là %', current_user;
    END IF;

    FOR ca IN SELECT * FROM (VALUES
        ('K02', 'DELETE FROM qua_trinh_cu_tru WHERE ma_qua_trinh = (SELECT min(ma_qua_trinh) FROM qua_trinh_cu_tru)', '42501'),
        ('K03', 'DELETE FROM bien_dong_cu_tru WHERE ma_bien_dong = (SELECT min(ma_bien_dong) FROM bien_dong_cu_tru)', '42501'),
        ('K04', 'TRUNCATE qua_trinh_cu_tru, bien_dong_cu_tru', '42501')
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

    -- K05: thử fn_chuyen_noi_bo trên các đợt đang mở; ngày chuyển cố định
    -- 2026-11-21 để tái lập (không dùng CURRENT_DATE). Ca đạt khi có ít nhất
    -- một lần gọi thành công và KHÔNG lần nào bị từ chối quyền (42501);
    -- các lần bị ràng buộc nghiệp vụ chặn (23xxx) chỉ là chọn ứng viên.
    tong := tong + 1;
    FOR v_dot IN
        SELECT q.ma_qua_trinh, q.ma_ho, q.loai_cu_tru
        FROM qua_trinh_cu_tru q
        WHERE q.ngay_ket_thuc IS NULL AND q.ngay_bat_dau < DATE '2026-11-21'
        ORDER BY q.ma_qua_trinh
        LIMIT 20
    LOOP
        FOR v_ho IN
            SELECT h.ma_ho FROM ho_cu_tru h
            WHERE h.ma_ho <> v_dot.ma_ho AND h.ngay_lap <= DATE '2026-11-21'
            ORDER BY h.ma_ho LIMIT 5
        LOOP
            so_thu := so_thu + 1;
            BEGIN
                SELECT * INTO v_kq FROM fn_chuyen_noi_bo(
                    v_dot.ma_qua_trinh, v_ho, v_dot.loai_cu_tru, DATE '2026-11-21',
                    (SELECT min(ma_tai_khoan) FROM tai_khoan WHERE trang_thai = 'HOAT_DONG'));
                thanh_cong := true;
                RAISE NOTICE 'K05 thử %: đợt % -> hộ % thành công (đợt mới %, sự kiện %)',
                    so_thu, v_dot.ma_qua_trinh, v_ho, v_kq.ma_dot_moi, v_kq.ma_su_kien;
            EXCEPTION WHEN insufficient_privilege THEN
                loi_quyen := loi_quyen + 1;
                RAISE NOTICE 'K05 thử %: đợt % -> hộ % bị từ chối quyền 42501: %',
                    so_thu, v_dot.ma_qua_trinh, v_ho, SQLERRM;
            WHEN OTHERS THEN
                NULL;  -- ràng buộc nghiệp vụ chặn ứng viên này; thử ứng viên khác
            END;
            EXIT WHEN thanh_cong;
        END LOOP;
        EXIT WHEN thanh_cong;
    END LOOP;
    IF thanh_cong AND loi_quyen = 0 THEN dat := dat + 1; END IF;
    RAISE NOTICE '[%] K05 | admin gọi fn_chuyen_noi_bo sau REVOKE DELETE | % lần thử, thành công=%, lỗi quyền=%',
        CASE WHEN thanh_cong AND loi_quyen = 0 THEN 'PASS' ELSE 'FAIL' END,
        so_thu, thanh_cong, loi_quyen;

    RAISE NOTICE 'TONG K02-K05 csdl17_admin: %/% PASS', dat, tong;
    IF dat <> tong THEN RAISE EXCEPTION 'Có ca B12 FAIL'; END IF;
END
$t$;
ROLLBACK;

\if :{?k01_ket_qua}
SELECT :'k01_ket_qua' = 'PASS' AS k01_dat \gset
\if :k01_dat
\echo 'TONG security_b12_tv1: K01-K05 PASS'
\else
\echo 'K01 FAIL: ma trận quyền lệch thiết kế'
SELECT 1/0 AS k01_fail;
\endif
\endif
