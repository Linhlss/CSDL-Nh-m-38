-- =====================================================================
-- BTL CSDL Đề tài 17 — tests/seed636_s01_s16_tv3.sql
-- W2-T3-11: TV3 kiểm tra chéo kịch bản S01–S16 trên seed636 của TV2,
-- tập trung vào EXCEPT/INTERSECT, người trùng tên, người không có đợt cư trú.
-- TV3 · 19/11/2026 · PostgreSQL 17, CSDL tạm nạp sql/01_schema.sql + 03_seed.sql
-- (sha256 03_seed.sql = 71f33714…fa0f2, trùng log tuần 1). Ngày tham chiếu d = 2026-11-20.
-- Kết quả lần chạy: 16/16 ca có dữ liệu và cho kết quả đúng; 4 phép EXCEPT/INTERSECT
-- lệch 0 so với dạng NOT EXISTS/EXISTS của QSQL. Ghi chú: S04 ra 4 địa chỉ (47–50),
-- S14b = 0 người (seed636 không có bẫy hai đợt hiệu lực trong cùng hộ). Xem
-- docs/07_ma_tran_truy_van_va_review.md mục 8.
--
-- Chạy (chỉ đọc, dùng VIEW/bảng TEMP, không sửa dữ liệu):
--   psql -U postgres -d <csdl đã nạp seed636> -f tests/seed636_s01_s16_tv3.sql
-- =====================================================================
\set ON_ERROR_STOP on
\pset footer off

-- Mỗi dòng kết quả: ca, mô tả, tập kỳ vọng, tập thực tế (đạt khi hai cột cuối trùng).
CREATE TEMP VIEW qd AS
SELECT * FROM qua_trinh_cu_tru
WHERE ngay_bat_dau <= DATE '2026-11-20'
  AND (ngay_ket_thuc IS NULL OR ngay_ket_thuc >= DATE '2026-11-20');
CREATE TEMP VIEW ho_to AS
SELECT h.ma_ho, d.ma_to FROM ho_cu_tru h JOIN dia_chi d USING (ma_dia_chi);

CREATE TEMP TABLE kq(ca text, mo_ta text, ky_vong text, thuc_te text);

-- QSQL01 / QRA01: tập người Tổ 01 tại d
CREATE TEMP TABLE t01 AS SELECT DISTINCT q.ma_cu_dan FROM qd q JOIN ho_to USING (ma_ho) WHERE ma_to = 1;
CREATE TEMP TABLE t02 AS SELECT DISTINCT q.ma_cu_dan FROM qd q JOIN ho_to USING (ma_ho) WHERE ma_to = 2;

INSERT INTO kq SELECT 'S01','C1-C6 trong Tổ01; C15,C28 đã chuyển khỏi Tổ01 bị loại',
 'in=1,2,3,4,5,6 out=15,28',
 'in=' || (SELECT string_agg(x::text, ',' ORDER BY x) FROM unnest(ARRAY[1,2,3,4,5,6]) x WHERE x IN (SELECT ma_cu_dan FROM t01))
 || ' out=' || coalesce((SELECT string_agg(x::text, ',' ORDER BY x) FROM unnest(ARRAY[15,28]) x WHERE x NOT IN (SELECT ma_cu_dan FROM t01)),'');

INSERT INTO kq SELECT 'S02','C7,C8 tạm trú Tổ02 được lấy; C9,C10 thường trú Tổ02 bị loại',
 'in=7,8 out=9,10',
 'in=' || (SELECT string_agg(x::text, ',' ORDER BY x) FROM unnest(ARRAY[7,8,9,10]) x
           WHERE x IN (SELECT ma_cu_dan FROM qd JOIN ho_to USING (ma_ho) WHERE ma_to=2 AND loai_cu_tru='TAM_TRU'))
 || ' out=' || (SELECT string_agg(x::text, ',' ORDER BY x) FROM unnest(ARRAY[7,8,9,10]) x
           WHERE x NOT IN (SELECT ma_cu_dan FROM qd JOIN ho_to USING (ma_ho) WHERE ma_to=2 AND loai_cu_tru='TAM_TRU'));

INSERT INTO kq SELECT 'S03','QRA03: C1 (đúng ngày cắt), C2 lấy; C3 (sau 1 ngày) loại',
 'in=1,2 out=3',
 'in=' || (SELECT string_agg(x::text, ',' ORDER BY x) FROM unnest(ARRAY[1,2,3]) x
           WHERE x IN (SELECT c.ma_cu_dan FROM cu_dan c JOIN t01 USING (ma_cu_dan) WHERE c.ngay_sinh <= DATE '1966-11-20'))
 || ' out=' || (SELECT string_agg(x::text, ',' ORDER BY x) FROM unnest(ARRAY[1,2,3]) x
           WHERE x NOT IN (SELECT c.ma_cu_dan FROM cu_dan c JOIN t01 USING (ma_cu_dan) WHERE c.ngay_sinh <= DATE '1966-11-20'));

INSERT INTO kq SELECT 'S04','QSQL04 = địa chỉ 47,48,49,50; địa chỉ của hộ 59/60 (hộ rỗng) không lọt',
 '47,48,49,50',
 (SELECT string_agg(ma_dia_chi::text, ',' ORDER BY ma_dia_chi) FROM dia_chi d
  WHERE NOT EXISTS (SELECT 1 FROM ho_cu_tru h WHERE h.ma_dia_chi = d.ma_dia_chi));

INSERT INTO kq SELECT 'S05','Hộ 59,60 có 0 người tại d nhưng từng có người',
 '59:0/1,60:0/1',
 (SELECT string_agg(h.ma_ho || ':' || (SELECT count(*) FROM qd WHERE qd.ma_ho=h.ma_ho)
    || '/' || (SELECT count(*) FROM qua_trinh_cu_tru q WHERE q.ma_ho=h.ma_ho), ',' ORDER BY h.ma_ho)
  FROM ho_cu_tru h WHERE h.ma_ho IN (59,60));

INSERT INTO kq SELECT 'S06','QSQL05: C15 (2 hộ) lấy; C17 (2 đợt cùng 1 hộ) loại',
 'in=15 out=17',
 'in=' || coalesce((SELECT string_agg(x::text, ',') FROM unnest(ARRAY[15,17]) x WHERE x IN
   (SELECT ma_cu_dan FROM qua_trinh_cu_tru GROUP BY ma_cu_dan HAVING count(DISTINCT ma_ho) >= 2)),'')
 || ' out=' || coalesce((SELECT string_agg(x::text, ',') FROM unnest(ARRAY[15,17]) x WHERE x NOT IN
   (SELECT ma_cu_dan FROM qua_trinh_cu_tru GROUP BY ma_cu_dan HAVING count(DISTINCT ma_ho) >= 2)),'');

CREATE TEMP TABLE giao AS
SELECT ma_cu_dan FROM qua_trinh_cu_tru WHERE loai_cu_tru='THUONG_TRU'
INTERSECT
SELECT ma_cu_dan FROM qua_trinh_cu_tru WHERE loai_cu_tru='TAM_TRU';

INSERT INTO kq SELECT 'S07','INTERSECT: C6 (2 loại cùng lúc), C17, C18 (2 loại khác thời kỳ) lấy',
 '6,17,18',
 (SELECT string_agg(x::text, ',' ORDER BY x) FROM unnest(ARRAY[6,17,18]) x WHERE x IN (SELECT ma_cu_dan FROM giao));

INSERT INTO kq SELECT 'S08','INTERSECT: C1,C2 (chỉ thường trú), C7 (chỉ tạm trú) không lọt',
 'out=1,2,7',
 'out=' || (SELECT string_agg(x::text, ',' ORDER BY x) FROM unnest(ARRAY[1,2,7]) x WHERE x NOT IN (SELECT ma_cu_dan FROM giao));

CREATE TEMP TABLE hieu09 AS
SELECT ma_cu_dan FROM qua_trinh_cu_tru WHERE ngay_bat_dau <= DATE '2026-11-20'
EXCEPT
SELECT ma_cu_dan FROM qd;

INSERT INTO kq SELECT 'S09','EXCEPT QRA09: C19-C22 lấy; C23,C24 (chỉ tương lai), C25 (không đợt) loại',
 'in=19,20,21,22 out=23,24,25',
 'in=' || (SELECT string_agg(x::text, ',' ORDER BY x) FROM unnest(ARRAY[19,20,21,22,23,24,25]) x WHERE x IN (SELECT ma_cu_dan FROM hieu09))
 || ' out=' || (SELECT string_agg(x::text, ',' ORDER BY x) FROM unnest(ARRAY[19,20,21,22,23,24,25]) x WHERE x NOT IN (SELECT ma_cu_dan FROM hieu09));

CREATE TEMP TABLE hieu06 AS
SELECT ma_cu_dan FROM cu_dan EXCEPT SELECT ma_cu_dan FROM qua_trinh_cu_tru;

INSERT INTO kq SELECT 'S10','EXCEPT QRA06 = 25,26,27,196-200; C23,C24 (đợt tương lai) không lọt',
 '25,26,27,196,197,198,199,200',
 (SELECT string_agg(ma_cu_dan::text, ',' ORDER BY ma_cu_dan) FROM hieu06);

INSERT INTO kq SELECT 'S11','CHUYEN_DEN: chỉ FK mới, ngày sự kiện = ngày bắt đầu đợt mới (số dòng sai)',
 '0 sai / có ≥1',
 (SELECT count(*) FILTER (WHERE b.ma_qua_trinh_cu IS NOT NULL OR b.ngay_bien_dong <> q.ngay_bat_dau)
    || ' sai / ' || count(*)
  FROM bien_dong_cu_tru b JOIN qua_trinh_cu_tru q ON q.ma_qua_trinh=b.ma_qua_trinh_moi
  WHERE b.loai_bien_dong='CHUYEN_DEN');

INSERT INTO kq SELECT 'S12','CHUYEN_DI: chỉ FK cũ, ngày sự kiện = ngày kết thúc + 1 (số dòng sai)',
 '0 sai / có ≥1',
 (SELECT count(*) FILTER (WHERE b.ma_qua_trinh_moi IS NOT NULL OR b.ngay_bien_dong <> q.ngay_ket_thuc + 1)
    || ' sai / ' || count(*)
  FROM bien_dong_cu_tru b JOIN qua_trinh_cu_tru q ON q.ma_qua_trinh=b.ma_qua_trinh_cu
  WHERE b.loai_bien_dong='CHUYEN_DI');

CREATE TEMP TABLE nb AS
SELECT b.ma_bien_dong, qc.ma_cu_dan FROM bien_dong_cu_tru b
JOIN qua_trinh_cu_tru qc ON qc.ma_qua_trinh=b.ma_qua_trinh_cu JOIN ho_to tc ON tc.ma_ho=qc.ma_ho
JOIN qua_trinh_cu_tru qm ON qm.ma_qua_trinh=b.ma_qua_trinh_moi JOIN ho_to tm ON tm.ma_ho=qm.ma_ho
WHERE b.loai_bien_dong='CHUYEN_NOI_BO' AND qc.ma_cu_dan=qm.ma_cu_dan AND tc.ma_to<>tm.ma_to;

INSERT INTO kq SELECT 'S13','QSQL09: C15 (Tổ1→Tổ2) lấy; C16 (cùng Tổ02) loại',
 'in=15 out=16',
 'in=' || coalesce((SELECT string_agg(x::text, ',') FROM unnest(ARRAY[15,16]) x WHERE x IN (SELECT ma_cu_dan FROM nb)),'')
 || ' out=' || coalesce((SELECT string_agg(x::text, ',') FROM unnest(ARRAY[15,16]) x WHERE x NOT IN (SELECT ma_cu_dan FROM nb)),'');

INSERT INTO kq SELECT 'S14a','Hộ đếm theo COUNT DISTINCT: hộ C1 =5 (≥4), hộ C11 =3, hộ C14 =1',
 '5,3,1',
 (SELECT string_agg(n::text, ',' ORDER BY ord) FROM (
   SELECT ord, (SELECT count(DISTINCT qd.ma_cu_dan) FROM qd WHERE qd.ma_ho =
      (SELECT ma_ho FROM qd WHERE ma_cu_dan = c LIMIT 1)) AS n
   FROM unnest(ARRAY[1,11,14]) WITH ORDINALITY AS u(c, ord)) s);

INSERT INTO kq SELECT 'S14b','Seed636 chưa có ca COUNT(*) khác COUNT DISTINCT trong cùng hộ; đối chứng ở fixture RA',
 '0 người',
 (SELECT count(*) || ' người' FROM (SELECT ma_ho, ma_cu_dan FROM qd GROUP BY 1,2 HAVING count(*) >= 2) s);

INSERT INTO kq SELECT 'S15a','QSQL03: Tổ 08 xuất hiện với 0 người',
 'Tổ 08:0',
 (SELECT string_agg(t.ten_to || ':' || (SELECT count(DISTINCT qd.ma_cu_dan) FROM qd JOIN ho_to h USING (ma_ho) WHERE h.ma_to=t.ma_to), ',')
  FROM to_dan_pho t WHERE (SELECT count(DISTINCT qd.ma_cu_dan) FROM qd JOIN ho_to h USING (ma_ho) WHERE h.ma_to=t.ma_to) = 0);

INSERT INTO kq SELECT 'S15b','QSQL08: không có nhóm tháng/loại nào đếm = 0',
 '0 nhóm',
 (SELECT count(*) || ' nhóm' FROM (SELECT 1 FROM bien_dong_cu_tru GROUP BY date_trunc('month', ngay_bien_dong), loai_bien_dong HAVING count(*)=0) s);

INSERT INTO kq SELECT 'S16a','C4,C5 cùng tên, cả hai có trong Tổ01, giữ 2 mã',
 '2 mã: 4,5',
 (SELECT count(*) || ' mã: ' || string_agg(c.ma_cu_dan::text, ',' ORDER BY c.ma_cu_dan)
  FROM cu_dan c JOIN t01 USING (ma_cu_dan) WHERE c.ho_ten = (SELECT ho_ten FROM cu_dan WHERE ma_cu_dan=4));

INSERT INTO kq SELECT 'S16b','Bẫy EXCEPT/INTERSECT chiếu theo ho_ten: số tên bị trùng trong cu_dan',
 'chỉ thông tin',
 (SELECT count(*) || ' tên trùng, ' || coalesce(sum(n),0) || ' người' FROM (SELECT ho_ten, count(*) n FROM cu_dan GROUP BY 1 HAVING count(*)>1) s);

INSERT INTO kq SELECT 'S16c','Nếu QRA09 làm EXCEPT trên ho_ten thay vì ma_cu_dan, số người kết quả lệch bao nhiêu',
 'chỉ thông tin',
 (SELECT (SELECT count(*) FROM hieu09) || ' theo mã vs ' ||
   (SELECT count(*) FROM (SELECT c.ho_ten FROM cu_dan c JOIN qua_trinh_cu_tru q USING (ma_cu_dan) WHERE q.ngay_bat_dau <= DATE '2026-11-20'
                          EXCEPT SELECT c.ho_ten FROM cu_dan c JOIN qd USING (ma_cu_dan)) s) || ' theo tên');

SELECT ca, mo_ta, ky_vong, thuc_te FROM kq ORDER BY ca;

-- Đối chiếu EXCEPT/INTERSECT với dạng NOT EXISTS/EXISTS của QSQL (theo tập mã)
SELECT 'QRA06 EXCEPT vs NOT EXISTS' AS phep,
  (SELECT count(*) FROM (SELECT ma_cu_dan FROM hieu06 EXCEPT SELECT ma_cu_dan FROM cu_dan c WHERE NOT EXISTS (SELECT 1 FROM qua_trinh_cu_tru q WHERE q.ma_cu_dan=c.ma_cu_dan)) a)
 + (SELECT count(*) FROM (SELECT ma_cu_dan FROM cu_dan c WHERE NOT EXISTS (SELECT 1 FROM qua_trinh_cu_tru q WHERE q.ma_cu_dan=c.ma_cu_dan) EXCEPT SELECT ma_cu_dan FROM hieu06) b) AS so_lech,
  (SELECT count(*) FROM hieu06) AS so_bo
UNION ALL
SELECT 'QRA07 INTERSECT vs QSQL06',
  (SELECT count(*) FROM (SELECT ma_cu_dan FROM giao EXCEPT SELECT c.ma_cu_dan FROM cu_dan c WHERE EXISTS (SELECT 1 FROM qua_trinh_cu_tru q WHERE q.ma_cu_dan=c.ma_cu_dan AND q.loai_cu_tru='THUONG_TRU') AND EXISTS (SELECT 1 FROM qua_trinh_cu_tru q WHERE q.ma_cu_dan=c.ma_cu_dan AND q.loai_cu_tru='TAM_TRU')) a)
 + (SELECT count(*) FROM (SELECT c.ma_cu_dan FROM cu_dan c WHERE EXISTS (SELECT 1 FROM qua_trinh_cu_tru q WHERE q.ma_cu_dan=c.ma_cu_dan AND q.loai_cu_tru='THUONG_TRU') AND EXISTS (SELECT 1 FROM qua_trinh_cu_tru q WHERE q.ma_cu_dan=c.ma_cu_dan AND q.loai_cu_tru='TAM_TRU') EXCEPT SELECT ma_cu_dan FROM giao) b),
  (SELECT count(*) FROM giao)
UNION ALL
SELECT 'QRA09 EXCEPT vs QSQL07',
  (SELECT count(*) FROM (SELECT ma_cu_dan FROM hieu09 EXCEPT SELECT c.ma_cu_dan FROM cu_dan c WHERE EXISTS (SELECT 1 FROM qua_trinh_cu_tru q WHERE q.ma_cu_dan=c.ma_cu_dan AND q.ngay_bat_dau <= DATE '2026-11-20') AND NOT EXISTS (SELECT 1 FROM qd WHERE qd.ma_cu_dan=c.ma_cu_dan)) a)
 + (SELECT count(*) FROM (SELECT c.ma_cu_dan FROM cu_dan c WHERE EXISTS (SELECT 1 FROM qua_trinh_cu_tru q WHERE q.ma_cu_dan=c.ma_cu_dan AND q.ngay_bat_dau <= DATE '2026-11-20') AND NOT EXISTS (SELECT 1 FROM qd WHERE qd.ma_cu_dan=c.ma_cu_dan) EXCEPT SELECT ma_cu_dan FROM hieu09) b),
  (SELECT count(*) FROM hieu09)
UNION ALL
SELECT 'QRA05 EXCEPT vs QSQL04',
  (SELECT count(*) FROM ((SELECT ma_dia_chi FROM dia_chi EXCEPT SELECT ma_dia_chi FROM ho_cu_tru)
     EXCEPT SELECT d.ma_dia_chi FROM dia_chi d WHERE NOT EXISTS (SELECT 1 FROM ho_cu_tru h WHERE h.ma_dia_chi=d.ma_dia_chi)) a)
 + (SELECT count(*) FROM (SELECT d.ma_dia_chi FROM dia_chi d WHERE NOT EXISTS (SELECT 1 FROM ho_cu_tru h WHERE h.ma_dia_chi=d.ma_dia_chi)
     EXCEPT (SELECT ma_dia_chi FROM dia_chi EXCEPT SELECT ma_dia_chi FROM ho_cu_tru)) b),
  (SELECT count(*) FROM (SELECT ma_dia_chi FROM dia_chi EXCEPT SELECT ma_dia_chi FROM ho_cu_tru) c);

