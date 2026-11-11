-- =====================================================================
-- BTL CSDL Đề tài 17 — tests/ra_fixture.sql
-- Bộ dữ liệu thử NHỎ, ĐÃ BIẾT ĐÁP ÁN, để kiểm chứng 10 câu đại số quan hệ
-- (docs/06a_dai_so_quan_he.md) và VIEW của Demo B2 (sql/05_security.sql).
-- TV3 · 10/11/2026 · Đã chạy trên PostgreSQL 17.11: 11/11 kết quả khớp đáp án.
-- Chạy lại 11/11/2026 trên DB trắng với 01_schema.sql v1-candidate + 05_security.sql,
-- sau khi sửa Q_d theo RV08: 11/11 kết quả khớp (Q_d, QRA01–10, VIEW dưới role report).
--
-- Chạy:  psql -U postgres -d csdl17_cu_tru_demo -f tests/ra_fixture.sql
-- Yêu cầu: 7 bảng ĐANG RỖNG (dùng mã cố định 1, 2, 3...); đã chạy 05_security.sql
--          nếu muốn kiểm tra VIEW dưới role report.
-- Toàn bộ chạy trong 1 transaction và ROLLBACK ở cuối: KHÔNG để lại dữ liệu.
-- Các câu SQL dưới đây được chép nguyên văn từ mục (7) của tệp đại số quan hệ;
-- nếu sửa tệp đó, chép lại vào đây.
--
-- Ý nghĩa dữ liệu (ngày tham chiếu d = 2026-11-20; dữ liệu 100% mô phỏng):
--   Tổ 01: địa chỉ 1, 2   | Tổ 02: địa chỉ 3, 5 | Tổ 03: địa chỉ 4
--   Hộ 1, 5 @ địa chỉ 1; hộ 2 @ đc 2; hộ 3 @ đc 3; hộ 4 @ đc 4; đc 5 không có hộ (S04)
--   Hộ 5 có nhưng không ai ở (S05)
--   CD1  1950, thường trú hộ 1, đang ở                    -> 60+ ở Tổ 01 (S03)
--   CD2  tạm trú hộ 3 (Tổ 02), đang ở; có CHUYEN_DEN       (S02, S11)
--   CD3  1960, thường trú hộ 3 (Tổ 02), đang ở             -> 60+ nhưng khác tổ
--   CD4  thường trú hộ 2 (Tổ 01) đến 2020, rồi tạm trú hộ 4 (Tổ 03);
--        CHUYEN_NOI_BO khác tổ                             (S06, S07, S13)
--   CD5  thường trú hộ 1 đến 2025-06-30; CHUYEN_DI         (S09, S12)
--   CD6  chưa từng có đợt                                  (S10)
--   CD7  2 đợt thường trú cùng hộ 1                         (S08, bẫy QRA04)
--   CD8  chỉ có đợt bắt đầu 2027-01-01                     (bẫy QRA09)
--   CD9  hộ 1 -> hộ 2, cùng Tổ 01; CHUYEN_NOI_BO cùng tổ   (bẫy QRA10)
--   CD10 trùng họ tên với CD1, tạm trú hộ 2                 (S16)
-- =====================================================================

\set ON_ERROR_STOP 1
BEGIN;

-- ----- DỮ LIỆU THỬ -----
INSERT INTO to_dan_pho(ma_to, ten_to) VALUES (1,'Tổ 01'),(2,'Tổ 02'),(3,'Tổ 03');
INSERT INTO dia_chi(ma_dia_chi, ma_to, dia_chi_chuan) VALUES
 (1,1,'So 1 ngo A'),(2,1,'So 2 ngo A'),(3,2,'So 3 ngo B'),(4,3,'So 4 ngo C'),(5,2,'So 5 ngo B (chua co ho)');
INSERT INTO ho_cu_tru(ma_ho, ma_dia_chi, ngay_lap) VALUES
 (1,1,'2005-01-01'),(2,2,'2005-01-01'),(3,3,'2005-01-01'),(4,4,'2005-01-01'),(5,1,'2005-01-01');
INSERT INTO cu_dan(ma_cu_dan, ho_ten, ngay_sinh, gioi_tinh) VALUES
 (1,'Nguyen Van An','1950-01-01','Nam'),(2,'Tran Thi Binh','1990-01-01','Nu'),
 (3,'Le Thi Chi','1960-01-01','Nu'),(4,'Pham Van Dung','1985-01-01','Nam'),
 (5,'Hoang Van Em','1995-01-01','Nam'),(6,'Vu Van Phuc','2000-01-01','Nam'),
 (7,'Do Thi Giang','1980-01-01','Nu'),(8,'Bui Thi Ha','1975-01-01','Nu'),
 (9,'Ngo Van Khoa','1970-01-01','Nam'),(10,'Nguyen Van An','1992-01-01','Nam');
INSERT INTO qua_trinh_cu_tru(ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau, ngay_ket_thuc) VALUES
 (1,1,1,'THUONG_TRU','2010-01-01',NULL),
 (2,2,3,'TAM_TRU','2024-03-01',NULL),
 (3,3,3,'THUONG_TRU','2008-01-01',NULL),
 (4,4,2,'THUONG_TRU','2015-01-01','2020-12-31'),
 (5,4,4,'TAM_TRU','2021-01-01',NULL),
 (6,5,1,'THUONG_TRU','2018-01-01','2025-06-30'),
 (7,7,1,'THUONG_TRU','2010-01-01','2015-12-31'),
 (8,7,1,'THUONG_TRU','2016-01-01',NULL),
 (9,8,2,'THUONG_TRU','2027-01-01',NULL),
 (10,9,1,'THUONG_TRU','2012-01-01','2022-05-31'),
 (11,9,2,'THUONG_TRU','2022-06-01',NULL),
 (12,10,2,'TAM_TRU','2023-01-01',NULL);
INSERT INTO tai_khoan(ma_tai_khoan, ten_dang_nhap, ten_hien_thi, vai_tro) VALUES (1,'canbo01','Can bo 01','CAN_BO');
INSERT INTO bien_dong_cu_tru(loai_bien_dong, ma_qua_trinh_cu, ma_qua_trinh_moi, ngay_bien_dong, ma_tai_khoan) VALUES
 ('CHUYEN_NOI_BO',4,5,'2021-01-01',1),
 ('CHUYEN_NOI_BO',10,11,'2022-06-01',1),
 ('CHUYEN_DI',6,NULL,'2025-06-30',1),
 ('CHUYEN_DEN',NULL,2,'2024-03-01',1);

-- ----- Q_d · MONG ĐỢI: 7 dòng: ma_qua_trinh 1, 2, 3, 5, 8, 11, 12
\echo '===== Q_d | mong doi: 7 dòng: ma_qua_trinh 1, 2, 3, 5, 8, 11, 12'
-- Bước chuẩn bị Q_d (06a mục 0.3, quy tắc B05): đợt có hiệu lực tại 2026-11-20,
-- bỏ cột ngay_ket_thuc để phần đại số không còn giá trị rỗng.
SELECT ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau
FROM qua_trinh_cu_tru
WHERE ngay_bat_dau <= DATE '2026-11-20'
  AND (ngay_ket_thuc IS NULL OR ngay_ket_thuc >= DATE '2026-11-20')
ORDER BY ma_qua_trinh;

-- ----- QRA01 · MONG ĐỢI: ma_cu_dan 1, 7, 9, 10 (1 và 10 trùng họ tên, phải là 2 dòng)
\echo '===== QRA01 | mong doi: ma_cu_dan 1, 7, 9, 10 (1 và 10 trùng họ tên, phải là 2 dòng)'
SELECT DISTINCT c.ma_cu_dan, c.ho_ten
FROM cu_dan c
JOIN qua_trinh_cu_tru q ON q.ma_cu_dan = c.ma_cu_dan
JOIN ho_cu_tru h        ON h.ma_ho = q.ma_ho
JOIN dia_chi d          ON d.ma_dia_chi = h.ma_dia_chi
JOIN to_dan_pho t       ON t.ma_to = d.ma_to
WHERE t.ten_to = 'Tổ 01'
  AND q.ngay_bat_dau <= DATE '2026-11-20'
  AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
ORDER BY c.ma_cu_dan;

-- ----- QRA02 · MONG ĐỢI: ma_cu_dan 2
\echo '===== QRA02 | mong doi: ma_cu_dan 2'
SELECT DISTINCT c.ma_cu_dan, c.ho_ten
FROM cu_dan c
JOIN qua_trinh_cu_tru q ON q.ma_cu_dan = c.ma_cu_dan
JOIN ho_cu_tru h        ON h.ma_ho = q.ma_ho
JOIN dia_chi d          ON d.ma_dia_chi = h.ma_dia_chi
JOIN to_dan_pho t       ON t.ma_to = d.ma_to
WHERE t.ten_to = 'Tổ 02'
  AND q.loai_cu_tru = 'TAM_TRU'
  AND q.ngay_bat_dau <= DATE '2026-11-20'
  AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
ORDER BY c.ma_cu_dan;

-- ----- QRA03 · MONG ĐỢI: ma_cu_dan 1 (cư dân 3 đủ 60 tuổi nhưng ở Tổ 02 nên bị loại)
\echo '===== QRA03 | mong doi: ma_cu_dan 1 (cư dân 3 đủ 60 tuổi nhưng ở Tổ 02 nên bị loại)'
SELECT DISTINCT c.ma_cu_dan, c.ho_ten, c.ngay_sinh
FROM cu_dan c
JOIN qua_trinh_cu_tru q ON q.ma_cu_dan = c.ma_cu_dan
JOIN ho_cu_tru h        ON h.ma_ho = q.ma_ho
JOIN dia_chi d          ON d.ma_dia_chi = h.ma_dia_chi
JOIN to_dan_pho t       ON t.ma_to = d.ma_to
WHERE t.ten_to = 'Tổ 01'
  AND c.ngay_sinh <= DATE '1966-11-20'
  AND q.ngay_bat_dau <= DATE '2026-11-20'
  AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
ORDER BY c.ma_cu_dan;

-- ----- QRA04 · MONG ĐỢI: ma_cu_dan 4, 9 (cư dân 7 có 2 đợt cùng hộ 1 nên bị loại)
\echo '===== QRA04 | mong doi: ma_cu_dan 4, 9 (cư dân 7 có 2 đợt cùng hộ 1 nên bị loại)'
SELECT DISTINCT c.ma_cu_dan, c.ho_ten
FROM qua_trinh_cu_tru qa
JOIN qua_trinh_cu_tru qb ON qb.ma_cu_dan = qa.ma_cu_dan
                        AND qb.ma_ho <> qa.ma_ho
JOIN cu_dan c ON c.ma_cu_dan = qa.ma_cu_dan
ORDER BY c.ma_cu_dan;

-- ----- QRA05 · MONG ĐỢI: ma_dia_chi 5 (hộ 5 không có người ở nhưng địa chỉ 1 vẫn có hộ)
\echo '===== QRA05 | mong doi: ma_dia_chi 5 (hộ 5 không có người ở nhưng địa chỉ 1 vẫn có hộ)'
SELECT d.ma_dia_chi, d.dia_chi_chuan
FROM dia_chi d
WHERE d.ma_dia_chi IN (
    SELECT ma_dia_chi FROM dia_chi
    EXCEPT
    SELECT ma_dia_chi FROM ho_cu_tru
)
ORDER BY d.ma_dia_chi;

-- ----- QRA06 · MONG ĐỢI: ma_cu_dan 6
\echo '===== QRA06 | mong doi: ma_cu_dan 6'
SELECT c.ma_cu_dan, c.ho_ten
FROM cu_dan c
WHERE c.ma_cu_dan IN (
    SELECT ma_cu_dan FROM cu_dan
    EXCEPT
    SELECT ma_cu_dan FROM qua_trinh_cu_tru
)
ORDER BY c.ma_cu_dan;

-- ----- QRA07 · MONG ĐỢI: ma_cu_dan 4 (cư dân 7, 9 chỉ có thường trú nên bị loại)
\echo '===== QRA07 | mong doi: ma_cu_dan 4 (cư dân 7, 9 chỉ có thường trú nên bị loại)'
SELECT c.ma_cu_dan, c.ho_ten
FROM cu_dan c
WHERE c.ma_cu_dan IN (
    SELECT ma_cu_dan FROM qua_trinh_cu_tru WHERE loai_cu_tru = 'THUONG_TRU'
    INTERSECT
    SELECT ma_cu_dan FROM qua_trinh_cu_tru WHERE loai_cu_tru = 'TAM_TRU'
)
ORDER BY c.ma_cu_dan;

-- ----- QRA08 · MONG ĐỢI: ma_cu_dan 1, 2, 3, 7, 9, 10
\echo '===== QRA08 | mong doi: ma_cu_dan 1, 2, 3, 7, 9, 10'
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
SELECT ma_cu_dan FROM cd_to WHERE ten_to = 'Tổ 02'
ORDER BY ma_cu_dan;

-- ----- QRA09 · MONG ĐỢI: ma_cu_dan 5 (cư dân 8 chỉ có đợt bắt đầu 2027-01-01 nên bị loại)
\echo '===== QRA09 | mong doi: ma_cu_dan 5 (cư dân 8 chỉ có đợt bắt đầu 2027-01-01 nên bị loại)'
SELECT c.ma_cu_dan, c.ho_ten
FROM cu_dan c
WHERE c.ma_cu_dan IN (
    SELECT ma_cu_dan FROM qua_trinh_cu_tru
    WHERE ngay_bat_dau <= DATE '2026-11-20'
    EXCEPT
    SELECT ma_cu_dan FROM qua_trinh_cu_tru
    WHERE ngay_bat_dau <= DATE '2026-11-20'
      AND (ngay_ket_thuc IS NULL OR ngay_ket_thuc >= DATE '2026-11-20')
)
ORDER BY c.ma_cu_dan;

-- ----- QRA10 · MONG ĐỢI: ma_cu_dan 4 (cư dân 9 chuyển nội bộ hộ 1 -> hộ 2 cùng Tổ 01 nên bị loại)
\echo '===== QRA10 | mong doi: ma_cu_dan 4 (cư dân 9 chuyển nội bộ hộ 1 -> hộ 2 cùng Tổ 01 nên bị loại)'
SELECT DISTINCT c.ma_cu_dan, c.ho_ten
FROM bien_dong_cu_tru b
JOIN qua_trinh_cu_tru q_cu  ON q_cu.ma_qua_trinh  = b.ma_qua_trinh_cu
JOIN ho_cu_tru h_cu         ON h_cu.ma_ho         = q_cu.ma_ho
JOIN dia_chi d_cu           ON d_cu.ma_dia_chi    = h_cu.ma_dia_chi
JOIN qua_trinh_cu_tru q_moi ON q_moi.ma_qua_trinh = b.ma_qua_trinh_moi
JOIN ho_cu_tru h_moi        ON h_moi.ma_ho        = q_moi.ma_ho
JOIN dia_chi d_moi          ON d_moi.ma_dia_chi   = h_moi.ma_dia_chi
JOIN cu_dan c               ON c.ma_cu_dan        = q_cu.ma_cu_dan
WHERE b.loai_bien_dong = 'CHUYEN_NOI_BO'
  AND q_moi.ma_cu_dan = q_cu.ma_cu_dan
  AND d_cu.ma_to <> d_moi.ma_to
ORDER BY c.ma_cu_dan;

-- ----- VIEW dưới role report · MONG ĐỢI: Tổ 01 = 4, Tổ 02 = 2, Tổ 03 = 1
\echo '===== VIEW (role report) | mong doi: To 01 = 4, To 02 = 2, To 03 = 1'
SET ROLE csdl17_report;
SELECT * FROM vw_thong_ke_cu_dan_theo_to ORDER BY ma_to;
RESET ROLE;

ROLLBACK;
