-- =====================================================================
-- BTL CSDL Đề tài 17 — Nhóm 38
-- tests/report_sql_01_10.sql
--
-- 10 câu SQL ĐANG IN trong Chương 5 của báo cáo LaTeX
-- (Báo_cáo_CSDL_nhóm_38/chuong5.tex), chép nguyên văn để tái lập.
--
-- LƯU Ý: đây KHÔNG phải bộ kiểm thử kỹ thuật QSQL01–QSQL10 trong
-- sql/04_queries.sql. Hai bộ có câu hỏi khác nhau; tệp này không thay thế
-- và không sửa sql/04_queries.sql.
--
-- Các truy vấn về hiện tại dùng CURRENT_DATE của phiên PostgreSQL.
--
-- Cơ sở dữ liệu cần có (dựng mới, theo đúng thứ tự):
--   sql/01_schema.sql -> sql/02_constraints.sql -> sql/03_seed.sql
--   -> sql/06_validation.sql  (seed636: 8 + 50 + 60 + 200 + 250 + 5 + 63)
--
-- Cách chạy:
--   psql -X -v ON_ERROR_STOP=1 -d <db_seed636> -f tests/report_sql_01_10.sql
--
-- Tệp chỉ đọc dữ liệu (chỉ có SELECT và một khối DO chỉ đọc), không ghi gì
-- vào cơ sở dữ liệu. Câu phụ thuộc ngày dùng oracle độc lập cùng CURRENT_DATE;
-- các câu lịch sử giữ kiểm tra trên seed. Có FAIL thì dừng với lỗi.
-- =====================================================================

\set ON_ERROR_STOP on
\pset footer on
SET search_path = public;
BEGIN READ ONLY;

\echo '=== Câu 1. Cư dân đang thường trú tại tổ 1 hiện tại'
SELECT cd.ma_cu_dan, cd.ho_ten, h.ma_ho, dc.dia_chi_chuan
FROM cu_dan cd
JOIN qua_trinh_cu_tru qt ON qt.ma_cu_dan = cd.ma_cu_dan
JOIN ho_cu_tru h         ON h.ma_ho = qt.ma_ho
JOIN dia_chi dc          ON dc.ma_dia_chi = h.ma_dia_chi
WHERE dc.ma_to = 1
  AND qt.loai_cu_tru = 'THUONG_TRU'
  AND qt.ngay_bat_dau <= CURRENT_DATE
  AND (qt.ngay_ket_thuc IS NULL OR qt.ngay_ket_thuc >= CURRENT_DATE)
ORDER BY dc.dia_chi_chuan, cd.ho_ten;

\echo '=== Câu 2. Thống kê thường trú / tạm trú / tổng theo tổ'
SELECT t.ma_to, t.ten_to,
       COUNT(DISTINCT qt.ma_cu_dan) FILTER (WHERE qt.loai_cu_tru = 'THUONG_TRU') AS so_thuong_tru,
       COUNT(DISTINCT qt.ma_cu_dan) FILTER (WHERE qt.loai_cu_tru = 'TAM_TRU')    AS so_tam_tru,
       COUNT(DISTINCT qt.ma_cu_dan) AS tong_so_nguoi
FROM to_dan_pho t
LEFT JOIN dia_chi dc          ON dc.ma_to = t.ma_to
LEFT JOIN ho_cu_tru h         ON h.ma_dia_chi = dc.ma_dia_chi
LEFT JOIN qua_trinh_cu_tru qt ON qt.ma_ho = h.ma_ho
                             AND qt.ngay_bat_dau <= CURRENT_DATE
                             AND (qt.ngay_ket_thuc IS NULL OR qt.ngay_ket_thuc >= CURRENT_DATE)
GROUP BY t.ma_to, t.ten_to
ORDER BY tong_so_nguoi DESC, t.ma_to;

\echo '=== Câu 3. Hộ có từ 3 nhân khẩu trở lên hiện tại'
SELECT h.ma_ho, dc.dia_chi_chuan, COUNT(DISTINCT qt.ma_cu_dan) AS so_nhan_khau
FROM ho_cu_tru h
JOIN dia_chi dc          ON dc.ma_dia_chi = h.ma_dia_chi
JOIN qua_trinh_cu_tru qt ON qt.ma_ho = h.ma_ho
WHERE qt.ngay_bat_dau <= CURRENT_DATE
  AND (qt.ngay_ket_thuc IS NULL OR qt.ngay_ket_thuc >= CURRENT_DATE)
GROUP BY h.ma_ho, dc.dia_chi_chuan
HAVING COUNT(DISTINCT qt.ma_cu_dan) >= 3
ORDER BY so_nhan_khau DESC, h.ma_ho;

\echo '=== Câu 4. Đã từng cư trú nhưng không còn đợt hiệu lực hiện tại'
SELECT cd.ma_cu_dan, cd.ho_ten
FROM cu_dan cd
WHERE EXISTS (
        SELECT 1 FROM qua_trinh_cu_tru qt
        WHERE qt.ma_cu_dan = cd.ma_cu_dan
          AND qt.ngay_bat_dau <= CURRENT_DATE)
  AND NOT EXISTS (
        SELECT 1 FROM qua_trinh_cu_tru qt
        WHERE qt.ma_cu_dan = cd.ma_cu_dan
          AND qt.ngay_bat_dau <= CURRENT_DATE
          AND (qt.ngay_ket_thuc IS NULL OR qt.ngay_ket_thuc >= CURRENT_DATE))
ORDER BY cd.ma_cu_dan;

\echo '=== Câu 5. Lịch sử cư trú của cư dân 92 (báo cáo: 3 đợt — hộ 56, 15, 20)'
SELECT qt.ma_qua_trinh, qt.loai_cu_tru, qt.ngay_bat_dau, qt.ngay_ket_thuc,
       h.ma_ho, dc.dia_chi_chuan
FROM qua_trinh_cu_tru qt
JOIN ho_cu_tru h ON h.ma_ho = qt.ma_ho
JOIN dia_chi dc  ON dc.ma_dia_chi = h.ma_dia_chi
WHERE qt.ma_cu_dan = 92
ORDER BY qt.ngay_bat_dau;

\echo '=== Câu 6. Số biến động theo tháng và loại trong năm 2026 (đối chiếu dữ liệu mẫu)'
SELECT EXTRACT(MONTH FROM ngay_bien_dong)::INT AS thang, loai_bien_dong,
       COUNT(*) AS so_bien_dong
FROM bien_dong_cu_tru
WHERE ngay_bien_dong >= DATE '2026-01-01' AND ngay_bien_dong < DATE '2027-01-01'
GROUP BY thang, loai_bien_dong
ORDER BY thang, loai_bien_dong;

\echo '=== Câu 7. Các lần chuyển nội bộ (báo cáo: 27 dòng, sớm nhất 18/01/2025, hộ 13 -> 25)'
SELECT bd.ma_bien_dong, bd.ngay_bien_dong, cd.ho_ten,
       qc.ma_ho AS ho_cu, qm.ma_ho AS ho_moi, tk.ten_hien_thi AS nguoi_ghi_nhan
FROM bien_dong_cu_tru bd
JOIN qua_trinh_cu_tru qc ON qc.ma_qua_trinh = bd.ma_qua_trinh_cu
JOIN qua_trinh_cu_tru qm ON qm.ma_qua_trinh = bd.ma_qua_trinh_moi
JOIN cu_dan cd           ON cd.ma_cu_dan = qm.ma_cu_dan
JOIN tai_khoan tk        ON tk.ma_tai_khoan = bd.ma_tai_khoan
WHERE bd.loai_bien_dong = 'CHUYEN_NOI_BO'
ORDER BY bd.ngay_bien_dong, bd.ma_bien_dong;

\echo '=== Câu 8. Cán bộ ghi nhiều biến động nhất (báo cáo: tài khoản 2, 21 biến động)'
SELECT tk.ma_tai_khoan, tk.ten_hien_thi, COUNT(*) AS so_bien_dong
FROM tai_khoan tk
JOIN bien_dong_cu_tru bd ON bd.ma_tai_khoan = tk.ma_tai_khoan
GROUP BY tk.ma_tai_khoan, tk.ten_hien_thi
HAVING COUNT(*) = (
    SELECT MAX(so_luong)
    FROM (SELECT COUNT(*) AS so_luong
          FROM bien_dong_cu_tru
          GROUP BY ma_tai_khoan) AS thong_ke
);

\echo '=== Câu 9. Từng tạm trú và từng thường trú (báo cáo: 31 dòng)'
SELECT cd.ma_cu_dan, cd.ho_ten
FROM cu_dan cd
WHERE cd.ma_cu_dan IN (
    SELECT ma_cu_dan FROM qua_trinh_cu_tru WHERE loai_cu_tru = 'TAM_TRU'
    INTERSECT
    SELECT ma_cu_dan FROM qua_trinh_cu_tru WHERE loai_cu_tru = 'THUONG_TRU'
)
ORDER BY cd.ma_cu_dan;

\echo '=== Câu 10. Cư dân từ 18 tuổi đang thường trú hiện tại'
SELECT cd.ma_cu_dan, cd.ho_ten, cd.ngay_sinh, dc.dia_chi_chuan
FROM cu_dan cd
JOIN qua_trinh_cu_tru qt ON qt.ma_cu_dan = cd.ma_cu_dan
JOIN ho_cu_tru h         ON h.ma_ho = qt.ma_ho
JOIN dia_chi dc          ON dc.ma_dia_chi = h.ma_dia_chi
WHERE qt.loai_cu_tru = 'THUONG_TRU'
  AND qt.ngay_bat_dau <= CURRENT_DATE
  AND (qt.ngay_ket_thuc IS NULL OR qt.ngay_ket_thuc >= CURRENT_DATE)
  AND cd.ngay_sinh <= CURRENT_DATE - INTERVAL '18 years'
ORDER BY dc.dia_chi_chuan, cd.ho_ten;

-- =====================================================================
-- ĐỐI CHIẾU NGỮ NGHĨA TRUY VẤN VÀ DỮ LIỆU MẪU
-- Mỗi kiểm tra chạy lại đúng câu truy vấn ở trên (bọc trong COUNT/điều kiện)
-- và in [PASS] hoặc [FAIL] cùng giá trị thực tế.
-- =====================================================================
\echo '=== Đối chiếu con số đang in trong báo cáo'
DO $chk$
DECLARE
    n BIGINT; m BIGINT; v TEXT; w TEXT; ok BOOLEAN; so_fail INT := 0;
BEGIN
    -- Câu 1: số dòng theo hiện tại, đối chiếu oracle EXISTS + daterange
    SELECT COUNT(*) INTO n FROM (
        SELECT cd.ma_cu_dan FROM cu_dan cd
        JOIN qua_trinh_cu_tru qt ON qt.ma_cu_dan = cd.ma_cu_dan
        JOIN ho_cu_tru h ON h.ma_ho = qt.ma_ho
        JOIN dia_chi dc ON dc.ma_dia_chi = h.ma_dia_chi
        WHERE dc.ma_to = 1 AND qt.loai_cu_tru = 'THUONG_TRU'
          AND qt.ngay_bat_dau <= CURRENT_DATE
          AND (qt.ngay_ket_thuc IS NULL OR qt.ngay_ket_thuc >= CURRENT_DATE)) q;
    SELECT COUNT(*) INTO m FROM cu_dan c WHERE EXISTS (
        SELECT 1 FROM qua_trinh_cu_tru q JOIN ho_cu_tru h USING (ma_ho)
        JOIN dia_chi d USING (ma_dia_chi)
        WHERE q.ma_cu_dan=c.ma_cu_dan AND q.loai_cu_tru='THUONG_TRU' AND d.ma_to=1
          AND daterange(q.ngay_bat_dau,q.ngay_ket_thuc,'[]') @> CURRENT_DATE);
    ok := n = m; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] SQL-C1: so_dong = % (doi chieu doc lap theo CURRENT_DATE)', CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n;

    -- Câu 2: đối chiếu đủ thống kê từng tổ với các phép đếm tương quan
    SELECT string_agg(format('%s:%s/%s/%s', ten_to, tt, tm, tong), '; ' ORDER BY tong DESC, ma_to)
      INTO v
    FROM (
        SELECT t.ma_to, t.ten_to,
               COUNT(DISTINCT qt.ma_cu_dan) FILTER (WHERE qt.loai_cu_tru = 'THUONG_TRU') AS tt,
               COUNT(DISTINCT qt.ma_cu_dan) FILTER (WHERE qt.loai_cu_tru = 'TAM_TRU') AS tm,
               COUNT(DISTINCT qt.ma_cu_dan) AS tong
        FROM to_dan_pho t
        LEFT JOIN dia_chi dc ON dc.ma_to = t.ma_to
        LEFT JOIN ho_cu_tru h ON h.ma_dia_chi = dc.ma_dia_chi
        LEFT JOIN qua_trinh_cu_tru qt ON qt.ma_ho = h.ma_ho
             AND qt.ngay_bat_dau <= CURRENT_DATE
             AND (qt.ngay_ket_thuc IS NULL OR qt.ngay_ket_thuc >= CURRENT_DATE)
        GROUP BY t.ma_to, t.ten_to) q;
    SELECT string_agg(format('%s:%s/%s/%s',t.ten_to,c.tt,c.tm,c.tong),'; ' ORDER BY c.tong DESC,t.ma_to)
      INTO w FROM to_dan_pho t CROSS JOIN LATERAL (
        SELECT COUNT(DISTINCT q.ma_cu_dan) FILTER(WHERE q.loai_cu_tru='THUONG_TRU') tt,
               COUNT(DISTINCT q.ma_cu_dan) FILTER(WHERE q.loai_cu_tru='TAM_TRU') tm,
               COUNT(DISTINCT q.ma_cu_dan) tong
        FROM qua_trinh_cu_tru q JOIN ho_cu_tru h USING(ma_ho) JOIN dia_chi d USING(ma_dia_chi)
        WHERE d.ma_to=t.ma_to AND daterange(q.ngay_bat_dau,q.ngay_ket_thuc,'[]') @> CURRENT_DATE) c;
    ok := v IS NOT DISTINCT FROM w;
    so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] SQL-C2: % (doi chieu doc lap du ca 3 cot cua moi to)',
        CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, v;

    -- Câu 3: đối chiếu phép đếm theo hộ với truy vấn tương quan
    SELECT COUNT(*), MAX(so) INTO n, v FROM (
        SELECT h.ma_ho, COUNT(DISTINCT qt.ma_cu_dan) AS so
        FROM ho_cu_tru h
        JOIN dia_chi dc ON dc.ma_dia_chi = h.ma_dia_chi
        JOIN qua_trinh_cu_tru qt ON qt.ma_ho = h.ma_ho
        WHERE qt.ngay_bat_dau <= CURRENT_DATE
          AND (qt.ngay_ket_thuc IS NULL OR qt.ngay_ket_thuc >= CURRENT_DATE)
        GROUP BY h.ma_ho, dc.dia_chi_chuan
        HAVING COUNT(DISTINCT qt.ma_cu_dan) >= 3) q;
    SELECT COUNT(*), MAX(so)::TEXT INTO m,w FROM (
        SELECT h.ma_ho,(SELECT COUNT(DISTINCT q.ma_cu_dan) FROM qua_trinh_cu_tru q
                        WHERE q.ma_ho=h.ma_ho AND daterange(q.ngay_bat_dau,q.ngay_ket_thuc,'[]') @> CURRENT_DATE) so
        FROM ho_cu_tru h) x WHERE so>=3;
    ok := n = m AND v IS NOT DISTINCT FROM w; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] SQL-C3: so_ho = %, max_nhan_khau = % (doi chieu doc lap theo CURRENT_DATE)',
        CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n, v;

    -- Câu 4: đối chiếu NOT EXISTS với phép hiệu tập hợp
    SELECT COUNT(*) INTO n FROM cu_dan cd
    WHERE EXISTS (SELECT 1 FROM qua_trinh_cu_tru qt WHERE qt.ma_cu_dan = cd.ma_cu_dan
                    AND qt.ngay_bat_dau <= CURRENT_DATE)
      AND NOT EXISTS (SELECT 1 FROM qua_trinh_cu_tru qt WHERE qt.ma_cu_dan = cd.ma_cu_dan
                    AND qt.ngay_bat_dau <= CURRENT_DATE
                    AND (qt.ngay_ket_thuc IS NULL OR qt.ngay_ket_thuc >= CURRENT_DATE));
    SELECT COUNT(*) INTO m FROM (
        SELECT ma_cu_dan FROM qua_trinh_cu_tru WHERE ngay_bat_dau <= CURRENT_DATE
        EXCEPT SELECT ma_cu_dan FROM qua_trinh_cu_tru
        WHERE daterange(ngay_bat_dau,ngay_ket_thuc,'[]') @> CURRENT_DATE) x;
    ok := n = m; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] SQL-C4: so_dong = % (doi chieu phep hieu tap hop)', CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n;

    -- Câu 5: 3 đợt theo thứ tự thời gian
    SELECT string_agg(format('%s@ho%s[%s..%s]', loai_cu_tru, ma_ho, ngay_bat_dau,
                             COALESCE(ngay_ket_thuc::TEXT, 'NULL')), ' ; ' ORDER BY ngay_bat_dau)
      INTO v
    FROM qua_trinh_cu_tru WHERE ma_cu_dan = 92;
    ok := v = 'THUONG_TRU@ho56[2022-08-01..2026-07-01] ; TAM_TRU@ho15[2025-08-11..NULL] ; THUONG_TRU@ho20[2026-07-02..NULL]';
    so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] SQL-C5: %', CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, v;

    -- Câu 6: số nhóm và tổng biến động năm 2026 trên seed
    SELECT COUNT(*), SUM(so) INTO n, v FROM (
        SELECT EXTRACT(MONTH FROM ngay_bien_dong)::INT AS thang, loai_bien_dong, COUNT(*) AS so
        FROM bien_dong_cu_tru
        WHERE ngay_bien_dong >= DATE '2026-01-01' AND ngay_bien_dong < DATE '2027-01-01'
        GROUP BY thang, loai_bien_dong) q;
    ok := n = 21 AND v = '29'; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] SQL-C6: so_nhom (thang, loai) = %, tong_bien_dong_2026 = %', CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n, v;

    -- Câu 7: 27 dòng; dòng đầu 2025-01-18, Dương Hữu Cường, hộ 13 -> 25
    SELECT COUNT(*) INTO n FROM bien_dong_cu_tru WHERE loai_bien_dong = 'CHUYEN_NOI_BO';
    SELECT format('%s|%s|%s->%s', bd.ngay_bien_dong, cd.ho_ten, qc.ma_ho, qm.ma_ho) INTO v
    FROM bien_dong_cu_tru bd
    JOIN qua_trinh_cu_tru qc ON qc.ma_qua_trinh = bd.ma_qua_trinh_cu
    JOIN qua_trinh_cu_tru qm ON qm.ma_qua_trinh = bd.ma_qua_trinh_moi
    JOIN cu_dan cd ON cd.ma_cu_dan = qm.ma_cu_dan
    JOIN tai_khoan tk ON tk.ma_tai_khoan = bd.ma_tai_khoan
    WHERE bd.loai_bien_dong = 'CHUYEN_NOI_BO'
    ORDER BY bd.ngay_bien_dong, bd.ma_bien_dong LIMIT 1;
    ok := n = 27 AND v = '2025-01-18|Dương Hữu Cường|13->25'; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] SQL-C7: so_dong = %, dong_dau = % (bao cao: 27; 2025-01-18 Duong Huu Cuong 13->25)',
        CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n, v;

    -- Câu 8: đúng 1 dòng — tài khoản 2, Cán bộ Cư trú 01, 21
    SELECT COUNT(*), string_agg(format('%s|%s|%s', ma_tai_khoan, ten_hien_thi, so), ';') INTO n, v
    FROM (
        SELECT tk.ma_tai_khoan, tk.ten_hien_thi, COUNT(*) AS so
        FROM tai_khoan tk JOIN bien_dong_cu_tru bd ON bd.ma_tai_khoan = tk.ma_tai_khoan
        GROUP BY tk.ma_tai_khoan, tk.ten_hien_thi
        HAVING COUNT(*) = (SELECT MAX(so_luong) FROM (SELECT COUNT(*) AS so_luong
                           FROM bien_dong_cu_tru GROUP BY ma_tai_khoan) tk2)) q;
    ok := n = 1 AND v = '2|Cán bộ Cư trú 01|21'; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] SQL-C8: so_dong = %, ket_qua = % (bao cao: 2 | Can bo Cu tru 01 | 21)',
        CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n, v;

    -- Câu 9: 31 dòng
    SELECT COUNT(*) INTO n FROM cu_dan cd WHERE cd.ma_cu_dan IN (
        SELECT ma_cu_dan FROM qua_trinh_cu_tru WHERE loai_cu_tru = 'TAM_TRU'
        INTERSECT
        SELECT ma_cu_dan FROM qua_trinh_cu_tru WHERE loai_cu_tru = 'THUONG_TRU');
    ok := n = 31; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] SQL-C9: so_dong = % (bao cao: 31)', CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n;

    -- Câu 10: so điều kiện đủ tuổi với age() và hiệu lực với daterange
    SELECT COUNT(*), bool_or(cd.ma_cu_dan = 1 AND cd.ngay_sinh = DATE '1966-11-20')::TEXT INTO n, v
    FROM cu_dan cd
    JOIN qua_trinh_cu_tru qt ON qt.ma_cu_dan = cd.ma_cu_dan
    JOIN ho_cu_tru h ON h.ma_ho = qt.ma_ho
    JOIN dia_chi dc ON dc.ma_dia_chi = h.ma_dia_chi
    WHERE qt.loai_cu_tru = 'THUONG_TRU'
      AND qt.ngay_bat_dau <= CURRENT_DATE
      AND (qt.ngay_ket_thuc IS NULL OR qt.ngay_ket_thuc >= CURRENT_DATE)
      AND cd.ngay_sinh <= CURRENT_DATE - INTERVAL '18 years';
    SELECT COUNT(*) INTO m FROM cu_dan c
    WHERE EXTRACT(YEAR FROM age(CURRENT_DATE,c.ngay_sinh)) >= 18 AND EXISTS (
      SELECT 1 FROM qua_trinh_cu_tru q WHERE q.ma_cu_dan=c.ma_cu_dan AND q.loai_cu_tru='THUONG_TRU'
        AND daterange(q.ngay_bat_dau,q.ngay_ket_thuc,'[]') @> CURRENT_DATE);
    ok := n = m; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] SQL-C10: so_dong = %, co_cu_dan_1_sinh_1966_11_20 = % (doi chieu doc lap tuoi va dot con hieu luc)',
        CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n, v;

    RAISE NOTICE 'TONG KET SQL: 10 kiem tra, % FAIL; ket qua phu thuoc ngay dung oracle cung CURRENT_DATE', so_fail;
    IF so_fail > 0 THEN RAISE EXCEPTION 'SQL report comparison failed: %',so_fail; END IF;
END
$chk$;

COMMIT;
