-- Kiểm chứng QSQL11-QSQL13 (sql/07_queries_bo_sung.sql) in ở Chương 5 báo cáo.
-- Chạy trên CSDL seed636 dựng mới: 01 -> 02 -> 03.
--   psql -X -v ON_ERROR_STOP=1 -d <db_seed636> -f tests/report_sql_bo_sung.sql
-- Mỗi câu được đối chiếu với một cách viết khác không dùng kỹ thuật đang minh họa.
\set ON_ERROR_STOP on
BEGIN READ ONLY;

DO $bs$
DECLARE n BIGINT; m BIGINT; v TEXT; w TEXT; so_fail INT := 0; ok BOOLEAN;
BEGIN
    -- QSQL11: hộ đông nhất mỗi tổ, đối chứng bằng MAX trong truy vấn con tương quan.
    WITH s AS (
        SELECT d.ma_to, q.ma_ho, COUNT(DISTINCT q.ma_cu_dan) AS so_cu_dan
        FROM qua_trinh_cu_tru q JOIN ho_cu_tru h USING (ma_ho) JOIN dia_chi d USING (ma_dia_chi)
        WHERE q.ngay_bat_dau <= DATE '2026-11-20'
          AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
        GROUP BY d.ma_to, q.ma_ho),
    ra AS (SELECT ma_to, ma_ho, so_cu_dan FROM (
             SELECT s.*, RANK() OVER (PARTITION BY ma_to ORDER BY so_cu_dan DESC) AS hang FROM s) x
           WHERE hang = 1),
    dc AS (SELECT ma_to, ma_ho, so_cu_dan FROM s
           WHERE so_cu_dan = (SELECT MAX(s2.so_cu_dan) FROM s s2 WHERE s2.ma_to = s.ma_to))
    SELECT (SELECT COUNT(*) FROM ra),
           (SELECT COUNT(*) FROM ((SELECT * FROM ra EXCEPT SELECT * FROM dc)
                                  UNION ALL (SELECT * FROM dc EXCEPT SELECT * FROM ra)) d)
      INTO n, m;
    ok := n = 14 AND m = 0; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] QSQL11: so_dong = % (ky vong 14), lech voi cach viet MAX = %',
        CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n, m;

    -- QSQL12: tổ trên mức trung bình, đối chứng bằng AVG tính riêng.
    WITH t AS (
        SELECT t.ma_to, COUNT(DISTINCT q.ma_cu_dan) AS so_cu_dan
        FROM to_dan_pho t
        LEFT JOIN dia_chi d ON d.ma_to = t.ma_to
        LEFT JOIN ho_cu_tru h ON h.ma_dia_chi = d.ma_dia_chi
        LEFT JOIN qua_trinh_cu_tru q ON q.ma_ho = h.ma_ho
             AND q.ngay_bat_dau <= DATE '2026-11-20'
             AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
        GROUP BY t.ma_to)
    SELECT COUNT(*), string_agg(ma_to::TEXT, ',' ORDER BY ma_to) INTO n, v
    FROM t WHERE so_cu_dan > (SELECT AVG(so_cu_dan) FROM t);
    ok := n = 5 AND v = '1,2,4,5,6'; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] QSQL12: so_dong = %, ma_to = {%} (ky vong 5 to: 1,2,4,5,6)',
        CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n, v;

    -- QSQL13: phép chia bằng NOT EXISTS, đối chứng bằng đếm số loại phân biệt.
    SELECT string_agg(ma_tai_khoan::TEXT, ',' ORDER BY ma_tai_khoan) INTO v
    FROM tai_khoan a
    WHERE NOT EXISTS (
        SELECT 1 FROM (SELECT DISTINCT loai_bien_dong FROM bien_dong_cu_tru) l
        WHERE NOT EXISTS (SELECT 1 FROM bien_dong_cu_tru b
                          WHERE b.ma_tai_khoan = a.ma_tai_khoan
                            AND b.loai_bien_dong = l.loai_bien_dong));
    SELECT string_agg(ma_tai_khoan::TEXT, ',' ORDER BY ma_tai_khoan) INTO w
    FROM (SELECT ma_tai_khoan FROM bien_dong_cu_tru GROUP BY ma_tai_khoan
          HAVING COUNT(DISTINCT loai_bien_dong) =
                 (SELECT COUNT(DISTINCT loai_bien_dong) FROM bien_dong_cu_tru)) d;
    ok := v = '1,2,3,4' AND w = v; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] QSQL13: tai khoan = {%} (ky vong 1,2,3,4; NOT EXISTS = cach dem)',
        CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, v;

    RAISE NOTICE 'TONG KET SQL BO SUNG: 3 kiem tra, % FAIL', so_fail;
    IF so_fail > 0 THEN
        RAISE EXCEPTION 'QSQL11-QSQL13: % kiem tra FAIL', so_fail;
    END IF;
END
$bs$;

ROLLBACK;
