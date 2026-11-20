-- =====================================================================
-- BTL CSDL Đề tài 17 — tests/seed636_qra02_03_06_08.sql
-- Chạy SQL kiểm chứng của QRA02, QRA03, QRA06, QRA08 trên seed636 và đối chiếu chéo.
-- Bốn câu này chưa có trong tests/week1_execution_results.json.
-- TV3 · 16/11/2026 · PostgreSQL 17, CSDL tạm nạp sql/01_schema.sql, 02_constraints.sql,
-- 03_seed.sql (sha256 03_seed.sql = 71f33714…fa0f2, trùng log tuần 1).
-- Kết quả lần chạy: QRA02 = 10, QRA03 = 2, QRA06 = 8, QRA08 = 61 bộ; mọi dòng đối chiếu chéo lệch 0.
--
-- Chạy (chỉ đọc, dùng bảng TEMP, không sửa dữ liệu):
--   psql -U postgres -d <csdl đã nạp seed636> -f tests/seed636_qra02_03_06_08.sql
-- =====================================================================
-- SQL kiểm chứng chép nguyên văn từ docs/06a_dai_so_quan_he.md (mục 7), lưu vào bảng tạm.
\set ON_ERROR_STOP 1
\pset footer off

CREATE TEMP TABLE r02 AS
SELECT DISTINCT c.ma_cu_dan, c.ho_ten
FROM cu_dan c
JOIN qua_trinh_cu_tru q ON q.ma_cu_dan = c.ma_cu_dan
JOIN ho_cu_tru h        ON h.ma_ho = q.ma_ho
JOIN dia_chi d          ON d.ma_dia_chi = h.ma_dia_chi
JOIN to_dan_pho t       ON t.ma_to = d.ma_to
WHERE t.ten_to = 'Tổ 02'
  AND q.loai_cu_tru = 'TAM_TRU'
  AND q.ngay_bat_dau <= DATE '2026-11-20'
  AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20');

CREATE TEMP TABLE r03 AS
SELECT DISTINCT c.ma_cu_dan, c.ho_ten, c.ngay_sinh
FROM cu_dan c
JOIN qua_trinh_cu_tru q ON q.ma_cu_dan = c.ma_cu_dan
JOIN ho_cu_tru h        ON h.ma_ho = q.ma_ho
JOIN dia_chi d          ON d.ma_dia_chi = h.ma_dia_chi
JOIN to_dan_pho t       ON t.ma_to = d.ma_to
WHERE t.ten_to = 'Tổ 01'
  AND c.ngay_sinh <= DATE '1966-11-20'
  AND q.ngay_bat_dau <= DATE '2026-11-20'
  AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20');

CREATE TEMP TABLE r06 AS
SELECT c.ma_cu_dan, c.ho_ten
FROM cu_dan c
WHERE c.ma_cu_dan IN (
    SELECT ma_cu_dan FROM cu_dan
    EXCEPT
    SELECT ma_cu_dan FROM qua_trinh_cu_tru
);

CREATE TEMP TABLE r08 AS
WITH cd_to AS (
    SELECT q.ma_cu_dan, t.ten_to
    FROM qua_trinh_cu_tru q
    JOIN ho_cu_tru h  ON h.ma_ho = q.ma_ho
    JOIN dia_chi d    ON d.ma_dia_chi = h.ma_dia_chi
    JOIN to_dan_pho t ON t.ma_to = d.ma_to
    WHERE q.ngay_bat_dau <= DATE '2026-11-20'
      AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
)
SELECT ma_cu_dan FROM cd_to WHERE ten_to = 'Tổ 01'
UNION
SELECT ma_cu_dan FROM cd_to WHERE ten_to = 'Tổ 02';

-- Tập phụ trợ để đối chiếu chéo: người đang ở từng tổ tại d (B05)
CREATE TEMP TABLE dang_o AS
SELECT DISTINCT q.ma_cu_dan, d.ma_to, q.loai_cu_tru
FROM qua_trinh_cu_tru q
JOIN ho_cu_tru h ON h.ma_ho = q.ma_ho
JOIN dia_chi d   ON d.ma_dia_chi = h.ma_dia_chi
WHERE q.ngay_bat_dau <= DATE '2026-11-20'
  AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20');

\echo '===== SO BO'
SELECT (SELECT count(*) FROM r02) AS qra02, (SELECT count(*) FROM r03) AS qra03,
       (SELECT count(*) FROM r06) AS qra06, (SELECT count(*) FROM r08) AS qra08,
       (SELECT count(DISTINCT ma_cu_dan) FROM dang_o WHERE ma_to = 1) AS to01,
       (SELECT count(DISTINCT ma_cu_dan) FROM dang_o WHERE ma_to = 2) AS to02;

\echo '===== MA KET QUA'
SELECT 'QRA02' AS cau, string_agg(ma_cu_dan::text, ', ' ORDER BY ma_cu_dan) FROM r02
UNION ALL SELECT 'QRA03', string_agg(ma_cu_dan::text, ', ' ORDER BY ma_cu_dan) FROM r03
UNION ALL SELECT 'QRA06', string_agg(ma_cu_dan::text, ', ' ORDER BY ma_cu_dan) FROM r06
UNION ALL SELECT 'QRA08', string_agg(ma_cu_dan::text, ', ' ORDER BY ma_cu_dan) FROM r08;

\echo '===== DOI CHIEU CHEO (moi dong lech phai = 0)'
-- QRA02: viết độc lập bằng EXISTS trên tập dang_o
SELECT 'QRA02 vs EXISTS' AS kiem_tra, count(*) AS lech FROM (
  (SELECT ma_cu_dan FROM r02
   EXCEPT SELECT ma_cu_dan FROM cu_dan c WHERE EXISTS (SELECT 1 FROM dang_o o WHERE o.ma_cu_dan = c.ma_cu_dan AND o.ma_to = 2 AND o.loai_cu_tru = 'TAM_TRU'))
  UNION ALL
  (SELECT ma_cu_dan FROM cu_dan c WHERE EXISTS (SELECT 1 FROM dang_o o WHERE o.ma_cu_dan = c.ma_cu_dan AND o.ma_to = 2 AND o.loai_cu_tru = 'TAM_TRU')
   EXCEPT SELECT ma_cu_dan FROM r02)) x
UNION ALL
-- QRA03 = (người đang ở Tổ 01) lọc theo ngày sinh
SELECT 'QRA03 vs To01 + ngay sinh', count(*) FROM (
  (SELECT ma_cu_dan FROM r03
   EXCEPT SELECT o.ma_cu_dan FROM dang_o o JOIN cu_dan c USING (ma_cu_dan) WHERE o.ma_to = 1 AND c.ngay_sinh <= DATE '1966-11-20')
  UNION ALL
  (SELECT o.ma_cu_dan FROM dang_o o JOIN cu_dan c USING (ma_cu_dan) WHERE o.ma_to = 1 AND c.ngay_sinh <= DATE '1966-11-20'
   EXCEPT SELECT ma_cu_dan FROM r03)) x
UNION ALL
-- QRA06 viết bằng NOT EXISTS
SELECT 'QRA06 vs NOT EXISTS', count(*) FROM (
  (SELECT ma_cu_dan FROM r06
   EXCEPT SELECT ma_cu_dan FROM cu_dan c WHERE NOT EXISTS (SELECT 1 FROM qua_trinh_cu_tru q WHERE q.ma_cu_dan = c.ma_cu_dan))
  UNION ALL
  (SELECT ma_cu_dan FROM cu_dan c WHERE NOT EXISTS (SELECT 1 FROM qua_trinh_cu_tru q WHERE q.ma_cu_dan = c.ma_cu_dan)
   EXCEPT SELECT ma_cu_dan FROM r06)) x
UNION ALL
-- QRA08 viết bằng một phép chọn "hoặc"
SELECT 'QRA08 vs dieu kien hoac', count(*) FROM (
  (SELECT ma_cu_dan FROM r08 EXCEPT SELECT ma_cu_dan FROM dang_o WHERE ma_to = 1 OR ma_to = 2)
  UNION ALL
  (SELECT ma_cu_dan FROM dang_o WHERE ma_to = 1 OR ma_to = 2 EXCEPT SELECT ma_cu_dan FROM r08)) x;

\echo '===== QRA08: |To01| + |To02| - |giao| phai bang so bo QRA08'
SELECT a.n AS to01, b.n AS to02, g.n AS giao, a.n + b.n - g.n AS tong
FROM (SELECT count(DISTINCT ma_cu_dan) n FROM dang_o WHERE ma_to = 1) a,
     (SELECT count(DISTINCT ma_cu_dan) n FROM dang_o WHERE ma_to = 2) b,
     (SELECT count(*) n FROM (SELECT ma_cu_dan FROM dang_o WHERE ma_to = 1 INTERSECT SELECT ma_cu_dan FROM dang_o WHERE ma_to = 2) z) g;
