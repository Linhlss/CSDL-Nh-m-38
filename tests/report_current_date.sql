-- Boundary checks for CURRENT_DATE queries printed in the report.
-- Fresh seed636 database only. All inserted fixtures and temporary views ROLLBACK.
-- psql -X -v ON_ERROR_STOP=1 -f tests/report_current_date.sql
\set ON_ERROR_STOP on
BEGIN;
SET search_path=public;
CREATE TEMP VIEW report_sql_01 AS
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
CREATE TEMP VIEW report_sql_02 AS
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
CREATE TEMP VIEW report_sql_03 AS
SELECT h.ma_ho, dc.dia_chi_chuan, COUNT(DISTINCT qt.ma_cu_dan) AS so_nhan_khau
FROM ho_cu_tru h
JOIN dia_chi dc          ON dc.ma_dia_chi = h.ma_dia_chi
JOIN qua_trinh_cu_tru qt ON qt.ma_ho = h.ma_ho
WHERE qt.ngay_bat_dau <= CURRENT_DATE
  AND (qt.ngay_ket_thuc IS NULL OR qt.ngay_ket_thuc >= CURRENT_DATE)
GROUP BY h.ma_ho, dc.dia_chi_chuan
HAVING COUNT(DISTINCT qt.ma_cu_dan) >= 3
ORDER BY so_nhan_khau DESC, h.ma_ho;
CREATE TEMP VIEW report_sql_04 AS
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
CREATE TEMP VIEW report_sql_10 AS
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
CREATE TEMP VIEW report_view AS
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
CREATE TEMP TABLE report_before AS SELECT * FROM report_sql_02 WHERE ma_to=1;
INSERT INTO dia_chi(ma_dia_chi,ma_to,dia_chi_chuan) VALUES(999001,1,'DEMO_CURRENT_DATE_BOUNDARY');
INSERT INTO ho_cu_tru(ma_ho,ma_dia_chi,ngay_lap) VALUES(999001,999001,CURRENT_DATE-30);
INSERT INTO cu_dan(ma_cu_dan,ho_ten,ngay_sinh,gioi_tinh)
SELECT 990000+i,'Boundary person '||i,
       CASE WHEN i=5 THEN (CURRENT_DATE-INTERVAL '18 years')::DATE
            WHEN i=6 THEN (CURRENT_DATE-INTERVAL '18 years')::DATE+1
            ELSE (CURRENT_DATE-INTERVAL '40 years')::DATE END,'Nam'
FROM generate_series(1,7) i;
INSERT INTO qua_trinh_cu_tru(ma_qua_trinh,ma_cu_dan,ma_ho,loai_cu_tru,ngay_bat_dau,ngay_ket_thuc) VALUES
(980001,990001,999001,'THUONG_TRU',CURRENT_DATE,NULL),
(980002,990002,999001,'THUONG_TRU',CURRENT_DATE-10,CURRENT_DATE),
(980003,990003,999001,'THUONG_TRU',CURRENT_DATE+1,NULL),
(980004,990004,999001,'THUONG_TRU',CURRENT_DATE-10,CURRENT_DATE-1),
(980005,990005,999001,'THUONG_TRU',CURRENT_DATE,NULL),
(980006,990006,999001,'THUONG_TRU',CURRENT_DATE,NULL),
(980007,990007,999001,'THUONG_TRU',CURRENT_DATE,NULL),
(980008,990007,999001,'TAM_TRU',CURRENT_DATE,NULL);
DO $boundary$
DECLARE ids BIGINT[];n BIGINT;v BIGINT;expected BIGINT;
BEGIN
 SELECT array_agg(ma_cu_dan ORDER BY ma_cu_dan) INTO ids FROM report_sql_01 WHERE ma_cu_dan>=990000;
 IF ids IS DISTINCT FROM ARRAY[990001,990002,990005,990006,990007]::BIGINT[] THEN RAISE EXCEPTION 'C01 active boundary mismatch: %',ids; END IF;
 RAISE NOTICE '[PASS] B01: starts today and ends today included; future/past excluded';
 SELECT array_agg(ma_cu_dan ORDER BY ma_cu_dan) INTO ids FROM report_sql_04 WHERE ma_cu_dan>=990000;
 IF ids IS DISTINCT FROM ARRAY[990004]::BIGINT[] THEN RAISE EXCEPTION 'C04 former boundary mismatch: %',ids; END IF;
 RAISE NOTICE '[PASS] B02: former resident included; never-started person excluded';
 SELECT array_agg(ma_cu_dan ORDER BY ma_cu_dan) INTO ids FROM report_sql_10 WHERE ma_cu_dan>=990000;
 IF ids IS DISTINCT FROM ARRAY[990001,990002,990005,990007]::BIGINT[] THEN RAISE EXCEPTION 'C10 age boundary mismatch: %',ids; END IF;
 RAISE NOTICE '[PASS] B03: eighteenth birthday today included; birthday tomorrow excluded';
 SELECT so_nhan_khau INTO n FROM report_sql_03 WHERE ma_ho=999001;
 IF n IS DISTINCT FROM 5::BIGINT THEN RAISE EXCEPTION 'C03 distinct household count mismatch: %',n; END IF;
 RAISE NOTICE '[PASS] B04: two residence types in one household count a person once';
 SELECT so_thuong_tru INTO n FROM report_sql_02 WHERE ma_to=1;
 SELECT so_thuong_tru+5 INTO expected FROM report_before;
 IF n IS DISTINCT FROM expected THEN RAISE EXCEPTION 'C02 permanent count mismatch'; END IF;
 SELECT so_tam_tru INTO n FROM report_sql_02 WHERE ma_to=1;
 SELECT so_tam_tru+1 INTO expected FROM report_before;
 IF n IS DISTINCT FROM expected THEN RAISE EXCEPTION 'C02 temporary count mismatch'; END IF;
 SELECT tong_so_nguoi INTO n FROM report_sql_02 WHERE ma_to=1;
 SELECT tong_so_nguoi+5 INTO expected FROM report_before;
 IF n IS DISTINCT FROM expected THEN RAISE EXCEPTION 'C02 distinct total mismatch'; END IF;
 RAISE NOTICE '[PASS] B05: grouped permanent/temporary/distinct totals match expected increments';
 SELECT COUNT(*) INTO n FROM report_sql_02 WHERE ma_to=8 AND so_thuong_tru=0 AND so_tam_tru=0 AND tong_so_nguoi=0;
 IF n<>1 THEN RAISE EXCEPTION 'C02 empty group missing'; END IF;
 RAISE NOTICE '[PASS] B06: empty group retained with zero counts';
 SELECT so_cu_dan INTO n FROM report_view WHERE ma_to=1;
 SELECT tong_so_nguoi INTO v FROM report_sql_02 WHERE ma_to=1;
 SELECT COUNT(*) INTO expected FROM report_view;
 IF n IS DISTINCT FROM v OR expected<>8 THEN RAISE EXCEPTION 'Current-date report view mismatch'; END IF;
 RAISE NOTICE '[PASS] B07: current-date report VIEW agrees with SQL and retains all eight groups';
END $boundary$;
ROLLBACK;
