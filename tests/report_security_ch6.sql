-- =====================================================================
-- BTL CSDL Đề tài 17 — Nhóm 38
-- tests/report_security_ch6.sql
--
-- Kiểm chứng các khẳng định ĐANG IN trong Chương 6 (chuong6.tex):
--   E1  Ví dụ 1 (B1) đúng như đoạn mã in: SET ROLE reader/admin.
--   E2  Ví dụ 2 (B2): VIEW trả 8 dòng, Tổ 01 = 34, Tổ 08 = 0; bảng gốc bị chặn.
--   E3  Ví dụ 3 (SQL Injection): hàm ghép chuỗi trả 200 dòng với chuỗi tấn
--       công; hàm viết đúng trả 0 dòng và tìm 'Hùng' ra 8 dòng.
--   E4  Giới hạn quyền csdl17_admin: tai_khoan và UPDATE trên hai bảng lịch sử.
--   E5  X01(b): số biến động theo vai_tro của tài khoản ghi.
--
-- Điều kiện: seed636 dựng mới (01 -> 02 -> 03 -> 06) rồi đã chạy
-- sql/05_security.sql. Chạy bằng chủ sở hữu bảng (postgres). Mọi thứ nằm
-- trong một giao dịch, kết thúc bằng ROLLBACK: không để lại hàm, dữ liệu
-- hay quyền nào. Đây là CSDL thử nghiệm riêng, không chạy trên production.
--   psql -X -v ON_ERROR_STOP=1 -d <db_seed636> -f tests/report_security_ch6.sql
-- =====================================================================

\set ON_ERROR_STOP on
BEGIN;
SET search_path = public;

-- Dùng đúng VIEW hiện tại in trong báo cáo; ROLLBACK khôi phục VIEW kỹ thuật.
CREATE OR REPLACE VIEW vw_thong_ke_cu_dan_theo_to
WITH (security_invoker = false) AS
SELECT t.ma_to,
       t.ten_to,
       COUNT(DISTINCT q.ma_cu_dan) AS so_cu_dan
FROM to_dan_pho t
LEFT JOIN dia_chi d          ON d.ma_to = t.ma_to
LEFT JOIN ho_cu_tru h        ON h.ma_dia_chi = d.ma_dia_chi
LEFT JOIN qua_trinh_cu_tru q ON q.ma_ho = h.ma_ho
                            AND q.ngay_bat_dau <= CURRENT_DATE
                            AND (q.ngay_ket_thuc IS NULL
                                 OR q.ngay_ket_thuc >= CURRENT_DATE)
GROUP BY t.ma_to, t.ten_to;

-- Hàm thử: chạy một lệnh với quyền của role hiện hành (SECURITY INVOKER),
-- in SQLSTATE thực tế. Lệnh chạy được thì bị hoàn tác ngay (trừ khi p_giu).
CREATE FUNCTION pg_temp.thu(p_ma TEXT, p_ky_vong TEXT, p_sql TEXT) RETURNS void
LANGUAGE plpgsql AS $f$
DECLARE s TEXT; m TEXT; n BIGINT; thuc_te TEXT;
BEGIN
    BEGIN
        EXECUTE p_sql;
        GET DIAGNOSTICS n = ROW_COUNT;
        thuc_te := 'OK(' || n || ' dong)';
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '__hoan_tac__';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS s = RETURNED_SQLSTATE, m = MESSAGE_TEXT;
        IF m <> '__hoan_tac__' THEN thuc_te := s || ' ' || m; END IF;
    END;
    RAISE NOTICE '[%] % | ky vong % | thuc te % | %',
        CASE WHEN thuc_te LIKE p_ky_vong || '%' THEN 'PASS' ELSE 'FAIL' END,
        p_ma, p_ky_vong, thuc_te, current_user;
    IF thuc_te NOT LIKE p_ky_vong || '%' THEN RAISE EXCEPTION 'Security example % failed',p_ma; END IF;
END
$f$;

-- ---------------------------------------------------------------------
-- E1. Ví dụ 1 (B1) — đúng các lệnh in trong báo cáo
-- ---------------------------------------------------------------------
SET ROLE csdl17_reader;
SELECT current_user AS role_dang_chay, COUNT(*) AS so_cu_dan FROM cu_dan;   -- báo cáo: 200
SELECT pg_temp.thu('E1-reader-UPDATE', '42501',
    $$UPDATE cu_dan SET ho_ten = 'Thử sửa' WHERE ma_cu_dan = 1$$);
RESET ROLE;
SET ROLE csdl17_admin;
SELECT pg_temp.thu('E1-admin-DELETE-bien_dong', '42501',
    $$DELETE FROM bien_dong_cu_tru WHERE ma_bien_dong = 1$$);
SELECT pg_temp.thu('E1-admin-DELETE-qua_trinh', '42501',
    $$DELETE FROM qua_trinh_cu_tru WHERE ma_qua_trinh = 1$$);
RESET ROLE;

-- ---------------------------------------------------------------------
-- E2. Ví dụ 2 (B2)
-- ---------------------------------------------------------------------
SET ROLE csdl17_report;
SELECT current_user AS role_dang_chay;
SELECT * FROM vw_thong_ke_cu_dan_theo_to ORDER BY ma_to;                     -- báo cáo: 8 dòng, 34 .. 0
SELECT pg_temp.thu('E2-report-SELECT-cu_dan', '42501',
    $$SELECT ho_ten, ngay_sinh FROM cu_dan LIMIT 1$$);
RESET ROLE;

-- ---------------------------------------------------------------------
-- E3. Ví dụ 3 — SQL Injection (tạo hàm trong giao dịch này, bị ROLLBACK)
-- ---------------------------------------------------------------------
CREATE FUNCTION fn_tim_cu_dan_sai(p_ten TEXT)
RETURNS TABLE (ma_cu_dan BIGINT, ho_ten VARCHAR, ngay_sinh DATE)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT ma_cu_dan, ho_ten, ngay_sinh FROM cu_dan WHERE ho_ten LIKE ''%'
        || p_ten || '%''';
END;
$$;

CREATE FUNCTION fn_tim_cu_dan(p_ten TEXT)
RETURNS TABLE (ma_cu_dan BIGINT, ho_ten VARCHAR, ngay_sinh DATE)
LANGUAGE sql STABLE AS $$
    SELECT c.ma_cu_dan, c.ho_ten, c.ngay_sinh
    FROM cu_dan c
    WHERE c.ho_ten LIKE '%' || p_ten || '%';
$$;

REVOKE EXECUTE ON FUNCTION fn_tim_cu_dan(TEXT) FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION fn_tim_cu_dan(TEXT) TO csdl17_reader;

-- Câu lệnh động thực sự được ghép từ chuỗi tấn công
SELECT 'SELECT ma_cu_dan, ho_ten, ngay_sinh FROM cu_dan WHERE ho_ten LIKE ''%'
       || 'x'' OR 1=1 --' || '%''' AS cau_lenh_dong_bi_ghep;

SELECT 'E3-sai-tan-cong'  AS ca, COUNT(*) AS so_dong FROM fn_tim_cu_dan_sai('x'' OR 1=1 --');  -- báo cáo: 200
SELECT 'E3-dung-tan-cong' AS ca, COUNT(*) AS so_dong FROM fn_tim_cu_dan('x'' OR 1=1 --');      -- báo cáo: 0
SELECT 'E3-dung-Hung'     AS ca, COUNT(*) AS so_dong FROM fn_tim_cu_dan('Hùng');               -- báo cáo: 8
SELECT 'E3-doi-chung-Hung' AS ca, COUNT(*) AS so_dong FROM cu_dan WHERE ho_ten LIKE '%Hùng%';

-- Quyền gọi hàm tra cứu
SET ROLE csdl17_reader;
SELECT 'E3-reader-goi-ham-dung' AS ca, COUNT(*) AS so_dong FROM fn_tim_cu_dan('Hùng');
RESET ROLE;
SET ROLE csdl17_report;
SELECT pg_temp.thu('E3-report-goi-ham-dung', '42501', $$SELECT * FROM fn_tim_cu_dan('Hùng')$$);
RESET ROLE;

-- ---------------------------------------------------------------------
-- E4. Giới hạn quyền csdl17_admin
-- ---------------------------------------------------------------------
SELECT p.quyen,
       has_table_privilege('csdl17_admin', 'tai_khoan', p.quyen)        AS tai_khoan,
       has_table_privilege('csdl17_admin', 'qua_trinh_cu_tru', p.quyen) AS qua_trinh_cu_tru,
       has_table_privilege('csdl17_admin', 'bien_dong_cu_tru', p.quyen) AS bien_dong_cu_tru
FROM (VALUES ('SELECT'), ('INSERT'), ('UPDATE'), ('DELETE'), ('TRUNCATE')) AS p(quyen);

SELECT ma_tai_khoan, COUNT(*) AS so_bien_dong_da_ghi
FROM bien_dong_cu_tru GROUP BY ma_tai_khoan ORDER BY ma_tai_khoan;

SET ROLE csdl17_admin;
-- tai_khoan
SELECT pg_temp.thu('E4-xoa-TK2-da-ghi-su-kien', '23503',
    $$DELETE FROM tai_khoan WHERE ma_tai_khoan = 2$$);
SELECT pg_temp.thu('E4-xoa-TK5-chua-ghi', 'OK(1',
    $$DELETE FROM tai_khoan WHERE ma_tai_khoan = 5$$);
SELECT pg_temp.thu('E4-sua-ten_hien_thi-TK2', 'OK(1',
    $$UPDATE tai_khoan SET ten_hien_thi = 'Tên đã đổi' WHERE ma_tai_khoan = 2$$);
SELECT pg_temp.thu('E4-sua-vai_tro-TK4', 'OK(1',
    $$UPDATE tai_khoan SET vai_tro = 'CAN_BO' WHERE ma_tai_khoan = 4$$);
SELECT pg_temp.thu('E4-khoa-TK3', 'OK(1',
    $$UPDATE tai_khoan SET trang_thai = 'KHOA' WHERE ma_tai_khoan = 3$$);
-- Lịch sử: UPDATE được trong phạm vi trigger cho phép
SELECT pg_temp.thu('E4-sua-ghi_chu-bien_dong-1', 'OK(1',
    $$UPDATE bien_dong_cu_tru SET ghi_chu = 'admin sửa ghi chú' WHERE ma_bien_dong = 1$$);
SELECT pg_temp.thu('E4-doi-nguoi-ghi-bien_dong-1-sang-TK1', 'OK(1',
    $$UPDATE bien_dong_cu_tru SET ma_tai_khoan = 1 WHERE ma_bien_dong = 1$$);
SELECT pg_temp.thu('E4-doi-ngay-bien_dong-1', '23514',
    $$UPDATE bien_dong_cu_tru SET ngay_bien_dong = ngay_bien_dong + 1 WHERE ma_bien_dong = 1$$);
SELECT pg_temp.thu('E4-sua-ngay_ket_thuc-dot-16-da-gan-su-kien', '23514',
    $$UPDATE qua_trinh_cu_tru SET ngay_ket_thuc = ngay_ket_thuc - 1 WHERE ma_qua_trinh = 16$$);
SELECT pg_temp.thu('E4-dong-dot-1-chua-gan-su-kien', 'OK(1',
    $$UPDATE qua_trinh_cu_tru SET ngay_ket_thuc = DATE '2026-12-31' WHERE ma_qua_trinh = 1$$);
RESET ROLE;

-- Sau khi mở khóa, tài khoản đã bị khóa lại ghi được (B14 chỉ kiểm tại lúc ghi):
-- khóa TK3 rồi mở lại, sau đó thử đổi người ghi biến động 1 sang TK3.
SET ROLE csdl17_admin;
UPDATE tai_khoan SET trang_thai = 'KHOA' WHERE ma_tai_khoan = 3;
SELECT pg_temp.thu('E4-TK3-dang-KHOA-ghi', '23514',
    $$UPDATE bien_dong_cu_tru SET ma_tai_khoan = 3 WHERE ma_bien_dong = 1$$);
UPDATE tai_khoan SET trang_thai = 'HOAT_DONG' WHERE ma_tai_khoan = 3;
SELECT pg_temp.thu('E4-TK3-mo-khoa-roi-ghi', 'OK(1',
    $$UPDATE bien_dong_cu_tru SET ma_tai_khoan = 3 WHERE ma_bien_dong = 1$$);
RESET ROLE;

-- ---------------------------------------------------------------------
-- E5. X01(b): biến động theo vai_tro của tài khoản ghi (seed636 giữ nguyên)
-- ---------------------------------------------------------------------
SELECT tk.vai_tro, COUNT(*) AS so_bien_dong
FROM bien_dong_cu_tru bd JOIN tai_khoan tk USING (ma_tai_khoan)
GROUP BY tk.vai_tro ORDER BY tk.vai_tro;

ROLLBACK;

-- Sau ROLLBACK: hàm ví dụ không còn tồn tại, dữ liệu không đổi
SELECT to_regprocedure('fn_tim_cu_dan(text)') IS NULL      AS ham_dung_da_huy,
       to_regprocedure('fn_tim_cu_dan_sai(text)') IS NULL  AS ham_sai_da_huy,
       (SELECT ten_hien_thi FROM tai_khoan WHERE ma_tai_khoan = 2) AS ten_tk2,
       (SELECT COUNT(*) FROM tai_khoan) AS so_tai_khoan,
       (SELECT ma_tai_khoan FROM bien_dong_cu_tru WHERE ma_bien_dong = 1) AS nguoi_ghi_bd1;
