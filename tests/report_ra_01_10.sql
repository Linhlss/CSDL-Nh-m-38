-- =====================================================================
-- BTL CSDL Đề tài 17 — Nhóm 38
-- tests/report_ra_01_10.sql
--
-- Đối chiếu 10 biểu thức đại số quan hệ ĐANG IN trong Chương 4 của báo cáo
-- LaTeX (Báo_cáo_CSDL_nhóm_38/chuong4.tex) bằng SQL tương đương.
--
-- Đại số quan hệ dùng ngữ nghĩa TẬP HỢP, nên mỗi câu được dịch theo đúng
-- từng toán tử: sigma -> WHERE, pi -> SELECT DISTINCT, join -> JOIN ... ON,
-- hợp/giao/hiệu -> UNION/INTERSECT/EXCEPT, phép chia -> hai lớp NOT EXISTS
-- (kiểm thêm bằng cách đếm), gamma -> GROUP BY.
--
-- Q_ht là quan hệ đầu vào các đợt còn hiệu lực theo d = 2026-11-20.
-- (B05). Đại số quan hệ cổ điển không có NULL nên Q_ht được coi là quan hệ đã
-- chuẩn bị: lọc bằng SQL có IS NULL, rồi chiếu 5 cột NOT NULL;
-- ngay_ket_thuc không thuộc lược đồ đầu vào Q_ht.
--
-- Đây KHÔNG phải bộ QRA01–QRA10 trong docs/06a_dai_so_quan_he.md (câu hỏi khác).
--
-- Cách chạy (CSDL seed636 dựng mới: 01 -> 02 -> 03 -> 06):
--   psql -X -v ON_ERROR_STOP=1 -d <db_seed636> -f tests/report_ra_01_10.sql
-- Tệp chỉ đọc dữ liệu.
-- =====================================================================

\set ON_ERROR_STOP on
SET search_path = public;
BEGIN READ ONLY;

DO $ra$
DECLARE
    n BIGINT; m BIGINT; v TEXT; w TEXT; ok BOOLEAN; so_fail INT := 0; expected_count BIGINT;
BEGIN
    -- Q_ht: dùng CTE trong từng câu (không tạo đối tượng mới trong CSDL).

    -- RA1: pi_{ho_ten, ngay_sinh}(sigma_{gioi_tinh='Nu'}(CD))
    SELECT COUNT(*) INTO n FROM (SELECT DISTINCT ho_ten, ngay_sinh FROM cu_dan WHERE gioi_tinh = 'Nu') q;
    SELECT COUNT(*) INTO m FROM cu_dan WHERE gioi_tinh = 'Nu';
    RAISE NOTICE '[INFO] RA1: so_bo = % (so cu dan nu = %; chenh lech = so cap (ho_ten, ngay_sinh) trung)', n, m;

    -- RA2: pi_{ma_dia_chi, dia_chi_chuan}(sigma_{ten_to='Tổ 01'}(TDP) join_{ma_to} DC)
    SELECT COUNT(*) INTO n FROM (
        SELECT DISTINCT dc.ma_dia_chi, dc.dia_chi_chuan
        FROM (SELECT * FROM to_dan_pho WHERE ten_to = 'Tổ 01') r
        JOIN dia_chi dc ON r.ma_to = dc.ma_to) q;
    SELECT COUNT(*) INTO m FROM dia_chi WHERE ma_to = (SELECT ma_to FROM to_dan_pho WHERE ten_to = 'Tổ 01');
    ok := n = m; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] RA2: so_bo = % ; doi chung COUNT dia_chi cua To 01 = %', CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n, m;

    -- RA3: R1 = sigma_{THUONG_TRU}(Q_ht); R2 = pi_{ma_ho}(HO join sigma_{ma_to=1}(DC));
    --      KQ = pi_{ma_cu_dan, ho_ten}((R1 join R2) join CD)  — đối chiếu SQL câu 1 cùng d = 2026-11-20
    WITH q_ht AS (SELECT DISTINCT ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau
                 FROM qua_trinh_cu_tru
                 WHERE ngay_bat_dau <= DATE '2026-11-20'
                   AND (ngay_ket_thuc IS NULL OR ngay_ket_thuc >= DATE '2026-11-20')),
         r1 AS (SELECT * FROM q_ht WHERE loai_cu_tru = 'THUONG_TRU'),
         r2 AS (SELECT DISTINCT h.ma_ho FROM ho_cu_tru h
                JOIN (SELECT * FROM dia_chi WHERE ma_to = 1) dc ON h.ma_dia_chi = dc.ma_dia_chi),
         ra AS (SELECT DISTINCT cd.ma_cu_dan, cd.ho_ten
                FROM r1 JOIN r2 ON r1.ma_ho = r2.ma_ho
                JOIN cu_dan cd ON r1.ma_cu_dan = cd.ma_cu_dan),
         sq AS (SELECT DISTINCT cd.ma_cu_dan, cd.ho_ten
                FROM cu_dan cd
                JOIN qua_trinh_cu_tru qt ON qt.ma_cu_dan = cd.ma_cu_dan
                JOIN ho_cu_tru h ON h.ma_ho = qt.ma_ho
                JOIN dia_chi dc ON dc.ma_dia_chi = h.ma_dia_chi
                WHERE dc.ma_to = 1 AND qt.loai_cu_tru = 'THUONG_TRU'
                  AND qt.ngay_bat_dau <= DATE '2026-11-20'
                  AND (qt.ngay_ket_thuc IS NULL OR qt.ngay_ket_thuc >= DATE '2026-11-20'))
    SELECT (SELECT COUNT(*) FROM ra),
           (SELECT COUNT(*) FROM ((SELECT * FROM ra EXCEPT SELECT * FROM sq)
                                  UNION ALL (SELECT * FROM sq EXCEPT SELECT * FROM ra)) d)
      INTO n, m;
    ok := m = 0; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] RA3: so_bo = %, lech voi SQL cau 1 = % bo (ky vong lech 0 tai d = 2026-11-20)', CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n, m;

    -- RA4: pi_{ma_cu_dan}(sigma_{ngay_bat_dau<=d}(QT)) - pi_{ma_cu_dan}(Q_ht), rồi join CD
    --      đối chiếu SQL câu 4 cùng d = 2026-11-20
    WITH q_ht AS (SELECT DISTINCT ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau
                 FROM qua_trinh_cu_tru
                 WHERE ngay_bat_dau <= DATE '2026-11-20'
                   AND (ngay_ket_thuc IS NULL OR ngay_ket_thuc >= DATE '2026-11-20')),
         r AS (SELECT ma_cu_dan FROM qua_trinh_cu_tru WHERE ngay_bat_dau <= DATE '2026-11-20'
               EXCEPT SELECT ma_cu_dan FROM q_ht),
         ra AS (SELECT DISTINCT cd.ma_cu_dan, cd.ho_ten FROM r JOIN cu_dan cd USING (ma_cu_dan)),
         sq AS (SELECT cd.ma_cu_dan, cd.ho_ten FROM cu_dan cd
                WHERE EXISTS (SELECT 1 FROM qua_trinh_cu_tru qt WHERE qt.ma_cu_dan = cd.ma_cu_dan
                                AND qt.ngay_bat_dau <= DATE '2026-11-20')
                  AND NOT EXISTS (SELECT 1 FROM qua_trinh_cu_tru qt WHERE qt.ma_cu_dan = cd.ma_cu_dan
                                AND qt.ngay_bat_dau <= DATE '2026-11-20'
                                AND (qt.ngay_ket_thuc IS NULL OR qt.ngay_ket_thuc >= DATE '2026-11-20')))
    SELECT (SELECT COUNT(*) FROM ra),
           (SELECT COUNT(*) FROM ((SELECT * FROM ra EXCEPT SELECT * FROM sq)
                                  UNION ALL (SELECT * FROM sq EXCEPT SELECT * FROM ra)) d)
      INTO n, m;
    ok := m = 0; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] RA4: so_bo = %, lech voi SQL cau 4 = % bo (ky vong lech 0 tai d = 2026-11-20)', CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n, m;

    -- RA5: A ∩ B — đối chiếu SQL câu 9 (31)
    SELECT COUNT(*) INTO n FROM (
        SELECT ma_cu_dan FROM qua_trinh_cu_tru WHERE loai_cu_tru = 'TAM_TRU'
        INTERSECT
        SELECT ma_cu_dan FROM qua_trinh_cu_tru WHERE loai_cu_tru = 'THUONG_TRU') q;
    ok := n = 31; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] RA5: so_bo = % (ky vong 31 = SQL cau 9)', CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n;

    -- RA6: biến động liên quan cư dân 15 (vế cũ ∪ vế mới); đối chứng bằng OR.
    -- Cư dân 15 có 2 đợt (16 ở hộ 22, 17 ở hộ 9), cả hai cùng gắn biến động 2.
    WITH q AS (SELECT ma_qua_trinh FROM qua_trinh_cu_tru WHERE ma_cu_dan = 15),
         ra AS (SELECT bd.ma_bien_dong FROM bien_dong_cu_tru bd JOIN q ON bd.ma_qua_trinh_cu = q.ma_qua_trinh
                UNION
                SELECT bd.ma_bien_dong FROM bien_dong_cu_tru bd JOIN q ON bd.ma_qua_trinh_moi = q.ma_qua_trinh),
         dc AS (SELECT ma_bien_dong FROM bien_dong_cu_tru
                WHERE ma_qua_trinh_cu IN (SELECT ma_qua_trinh FROM q)
                   OR ma_qua_trinh_moi IN (SELECT ma_qua_trinh FROM q))
    SELECT (SELECT COUNT(*) FROM ra),
           (SELECT string_agg(ma_bien_dong::TEXT, ',' ORDER BY ma_bien_dong) FROM ra),
           (SELECT COUNT(*) FROM ((SELECT * FROM ra EXCEPT SELECT * FROM dc)
                                  UNION ALL (SELECT * FROM dc EXCEPT SELECT * FROM ra)) d)
      INTO n, v, m;
    ok := m = 0 AND n = 1 AND v = '2'; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] RA6: so_bo = %, ma_bien_dong = {%}, lech voi cach viet OR = %', CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n, v, m;

    -- RA7: chuyển nội bộ với hộ cũ/mới (dùng hai bản sao QC, QM) — đối chiếu SQL câu 7 (27)
    WITH qc AS (SELECT DISTINCT ma_qua_trinh AS mq_cu, ma_ho AS ho_cu FROM qua_trinh_cu_tru),
         qm AS (SELECT DISTINCT ma_qua_trinh AS mq_moi, ma_ho AS ho_moi, ma_cu_dan FROM qua_trinh_cu_tru),
         r0 AS (SELECT * FROM bien_dong_cu_tru WHERE loai_bien_dong = 'CHUYEN_NOI_BO'),
         r  AS (SELECT r0.ma_bien_dong, qc.ho_cu, qm.ho_moi, qm.ma_cu_dan
                FROM r0 JOIN qc ON r0.ma_qua_trinh_cu = qc.mq_cu
                        JOIN qm ON r0.ma_qua_trinh_moi = qm.mq_moi),
         ra AS (SELECT DISTINCT r.ma_bien_dong, cd.ho_ten, r.ho_cu, r.ho_moi
                FROM r JOIN (SELECT DISTINCT ma_cu_dan, ho_ten FROM cu_dan) cd USING (ma_cu_dan)),
         sq AS (SELECT bd.ma_bien_dong, cd.ho_ten, qc.ma_ho AS ho_cu, qm.ma_ho AS ho_moi
                FROM bien_dong_cu_tru bd
                JOIN qua_trinh_cu_tru qc ON qc.ma_qua_trinh = bd.ma_qua_trinh_cu
                JOIN qua_trinh_cu_tru qm ON qm.ma_qua_trinh = bd.ma_qua_trinh_moi
                JOIN cu_dan cd ON cd.ma_cu_dan = qm.ma_cu_dan
                JOIN tai_khoan tk ON tk.ma_tai_khoan = bd.ma_tai_khoan
                WHERE bd.loai_bien_dong = 'CHUYEN_NOI_BO')
    SELECT (SELECT COUNT(*) FROM ra),
           (SELECT COUNT(*) FROM ((SELECT * FROM ra EXCEPT SELECT * FROM sq)
                                  UNION ALL (SELECT * FROM sq EXCEPT SELECT * FROM ra)) d)
      INTO n, m;
    ok := n = 27 AND m = 0; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] RA7: so_bo = %, lech voi SQL cau 7 (cung 4 cot) = % (ky vong 27, 0)', CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n, m;

    -- RA8: tên hiển thị cán bộ ghi CHUYEN_DI trong tháng 10/2026
    SELECT COUNT(*), string_agg(ten_hien_thi, ', ' ORDER BY ten_hien_thi) INTO n, v FROM (
        SELECT DISTINCT tk.ten_hien_thi
        FROM (SELECT * FROM bien_dong_cu_tru
              WHERE loai_bien_dong = 'CHUYEN_DI'
                AND ngay_bien_dong >= DATE '2026-10-01'
                AND ngay_bien_dong <= DATE '2026-10-31') r
        JOIN tai_khoan tk ON r.ma_tai_khoan = tk.ma_tai_khoan) q;
    SELECT COUNT(*) INTO m FROM bien_dong_cu_tru
    WHERE loai_bien_dong = 'CHUYEN_DI' AND ngay_bien_dong BETWEEN DATE '2026-10-01' AND DATE '2026-10-31';
    RAISE NOTICE '[INFO] RA8: so_bo = % {%} (tu % bien dong CHUYEN_DI thang 10/2026)', n, v, m;

    -- RA9: pi_{ma_tai_khoan, loai}(BD) ÷ pi_{loai}(BD)
    --   (a) hai lớp NOT EXISTS
    SELECT string_agg(ma_tai_khoan::TEXT, ',' ORDER BY ma_tai_khoan) INTO v FROM (
        SELECT DISTINCT x.ma_tai_khoan FROM bien_dong_cu_tru x
        WHERE NOT EXISTS (
            SELECT 1 FROM (SELECT DISTINCT loai_bien_dong FROM bien_dong_cu_tru) s
            WHERE NOT EXISTS (
                SELECT 1 FROM bien_dong_cu_tru y
                WHERE y.ma_tai_khoan = x.ma_tai_khoan
                  AND y.loai_bien_dong = s.loai_bien_dong))) q;
    --   (b) đếm số loại phân biệt
    SELECT string_agg(ma_tai_khoan::TEXT, ',' ORDER BY ma_tai_khoan) INTO w FROM (
        SELECT ma_tai_khoan FROM bien_dong_cu_tru GROUP BY ma_tai_khoan
        HAVING COUNT(DISTINCT loai_bien_dong) =
               (SELECT COUNT(DISTINCT loai_bien_dong) FROM bien_dong_cu_tru)) q;
    SELECT COUNT(DISTINCT loai_bien_dong) INTO n FROM bien_dong_cu_tru;
    SELECT COUNT(*) INTO m FROM bien_dong_cu_tru WHERE ma_tai_khoan = 5;
    ok := v = '1,2,3,4' AND w = v AND n = 3 AND m = 0; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] RA9: NOT EXISTS = {%}, dem = {%}, so loai trong so chia = %, bien dong cua TK5 = % (bao cao: 1,2,3,4; TK5 chua ghi)',
        CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, v, w, n, m;

    -- RA10: gamma_{ma_ho; COUNT(ma_cu_dan)}(pi_{ma_ho, ma_cu_dan}(Q_ht))
    --       đối chiếu chéo: số hộ có >= 3 người phải khớp SQL câu 3 cùng d = 2026-11-20
    WITH q_ht AS (SELECT DISTINCT ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau
                 FROM qua_trinh_cu_tru
                 WHERE ngay_bat_dau <= DATE '2026-11-20'
                   AND (ngay_ket_thuc IS NULL OR ngay_ket_thuc >= DATE '2026-11-20')),
         g AS (SELECT ma_ho, COUNT(ma_cu_dan) AS so_nhan_khau
               FROM (SELECT DISTINCT ma_ho, ma_cu_dan FROM q_ht) p GROUP BY ma_ho)
    SELECT (SELECT COUNT(*) FROM g), (SELECT COUNT(*) FROM g WHERE so_nhan_khau >= 3),
           (SELECT SUM(so_nhan_khau)::TEXT FROM g)
      INTO n, m, v;
    SELECT COUNT(*) INTO expected_count FROM (
        SELECT h.ma_ho FROM ho_cu_tru h JOIN qua_trinh_cu_tru q USING(ma_ho)
        WHERE daterange(q.ngay_bat_dau,q.ngay_ket_thuc,'[]') @> DATE '2026-11-20'
        GROUP BY h.ma_ho HAVING COUNT(DISTINCT q.ma_cu_dan)>=3) x;
    ok := m = expected_count; so_fail := so_fail + (NOT ok)::INT;
    RAISE NOTICE '[%] RA10: so_ho_co_nguoi = %, tong = %, so_ho_>=3 = % (doi chieu SQL cau 3 cung d = 2026-11-20)',
        CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, n, v, m;

    -- RA10 (kiểm tác dụng của phép chiếu trước gamma): nếu không chiếu, có bao nhiêu
    -- hộ bị đếm trùng do một người có cả đợt thường trú và tạm trú trong cùng hộ?
    WITH q_ht AS (SELECT DISTINCT ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau
                 FROM qua_trinh_cu_tru
                 WHERE ngay_bat_dau <= DATE '2026-11-20'
                   AND (ngay_ket_thuc IS NULL OR ngay_ket_thuc >= DATE '2026-11-20'))
    SELECT COUNT(*) INTO n FROM (
        SELECT ma_ho FROM q_ht GROUP BY ma_ho
        HAVING COUNT(*) <> COUNT(DISTINCT ma_cu_dan)) q;
    RAISE NOTICE '[INFO] RA10: so ho se bi dem sai neu bo phep chieu truoc gamma = %', n;

    RAISE NOTICE 'TONG KET RA: % kiem tra FAIL (RA1, RA8 chi ghi nhan)', so_fail;
    IF so_fail > 0 THEN RAISE EXCEPTION 'RA report comparison failed: %',so_fail; END IF;
END
$ra$;

COMMIT;
