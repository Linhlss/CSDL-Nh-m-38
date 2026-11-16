-- Bộ 10 câu truy vấn SQL chính thức (TV2) — PostgreSQL >= 15.
-- Ngày tham chiếu cố định để đối soát với 10 câu RA và ma trận thiết kế: DATE '2026-11-20'.
-- Hợp đồng cột đầu ra theo docs/07_ma_tran_truy_van_va_review.md.

-- QSQL01. Danh sách cư dân đang cư trú tại Tổ 01 vào ngày d = 2026-11-20
-- Đầu ra: ma_cu_dan, ho_ten, loai_cu_tru
SELECT DISTINCT
    c.ma_cu_dan,
    c.ho_ten,
    q.loai_cu_tru
FROM cu_dan AS c
JOIN qua_trinh_cu_tru AS q ON q.ma_cu_dan = c.ma_cu_dan
JOIN ho_cu_tru AS h        ON h.ma_ho = q.ma_ho
JOIN dia_chi AS d          ON d.ma_dia_chi = h.ma_dia_chi
JOIN to_dan_pho AS t       ON t.ma_to = d.ma_to
WHERE t.ten_to = 'Tổ 01'
  AND q.ngay_bat_dau <= DATE '2026-11-20'
  AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
ORDER BY c.ma_cu_dan, q.loai_cu_tru;

-- QSQL02. Danh sách các hộ đang có ít nhất 4 cư dân tại ngày d = 2026-11-20
-- Đầu ra: ma_ho, so_cu_dan
SELECT
    h.ma_ho,
    COUNT(DISTINCT q.ma_cu_dan) AS so_cu_dan
FROM ho_cu_tru AS h
JOIN qua_trinh_cu_tru AS q ON q.ma_ho = h.ma_ho
WHERE q.ngay_bat_dau <= DATE '2026-11-20'
  AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
GROUP BY h.ma_ho
HAVING COUNT(DISTINCT q.ma_cu_dan) >= 4
ORDER BY so_cu_dan DESC, h.ma_ho;

-- QSQL03. Thống kê số cư dân đang cư trú theo từng tổ dân phố tại ngày d = 2026-11-20 (kể cả tổ 0 người)
-- Đầu ra: ma_to, ten_to, so_cu_dan
SELECT
    t.ma_to,
    t.ten_to,
    COUNT(DISTINCT q.ma_cu_dan) AS so_cu_dan
FROM to_dan_pho AS t
LEFT JOIN dia_chi AS d          ON d.ma_to = t.ma_to
LEFT JOIN ho_cu_tru AS h        ON h.ma_dia_chi = d.ma_dia_chi
LEFT JOIN qua_trinh_cu_tru AS q ON q.ma_ho = h.ma_ho
                               AND q.ngay_bat_dau <= DATE '2026-11-20'
                               AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
GROUP BY t.ma_to, t.ten_to
ORDER BY t.ma_to;

-- QSQL04. Danh sách địa chỉ chưa có nhóm hộ nào
-- Đầu ra: ma_dia_chi, dia_chi_chuan
SELECT
    d.ma_dia_chi,
    d.dia_chi_chuan
FROM dia_chi AS d
WHERE NOT EXISTS (
    SELECT 1
    FROM ho_cu_tru AS h
    WHERE h.ma_dia_chi = d.ma_dia_chi
)
ORDER BY d.ma_dia_chi;

-- QSQL05. Danh sách cư dân từng cư trú ở ít nhất 2 nhóm hộ khác nhau (toàn bộ quá trình đã ghi nhận)
-- Đầu ra: ma_cu_dan, ho_ten, so_ho
SELECT
    c.ma_cu_dan,
    c.ho_ten,
    COUNT(DISTINCT q.ma_ho) AS so_ho
FROM cu_dan AS c
JOIN qua_trinh_cu_tru AS q ON q.ma_cu_dan = c.ma_cu_dan
GROUP BY c.ma_cu_dan, c.ho_ten
HAVING COUNT(DISTINCT q.ma_ho) >= 2
ORDER BY so_ho DESC, c.ma_cu_dan;

-- QSQL06. Danh sách cư dân có cả lịch sử thường trú và tạm trú (toàn bộ quá trình đã ghi nhận)
-- Đầu ra: ma_cu_dan, ho_ten
SELECT
    c.ma_cu_dan,
    c.ho_ten
FROM cu_dan AS c
WHERE EXISTS (
    SELECT 1
    FROM qua_trinh_cu_tru AS q1
    WHERE q1.ma_cu_dan = c.ma_cu_dan
      AND q1.loai_cu_tru = 'THUONG_TRU'
)
  AND EXISTS (
    SELECT 1
    FROM qua_trinh_cu_tru AS q2
    WHERE q2.ma_cu_dan = c.ma_cu_dan
      AND q2.loai_cu_tru = 'TAM_TRU'
)
ORDER BY c.ma_cu_dan;

-- QSQL07. Danh sách cư dân từng cư trú (đã bắt đầu <= d) nhưng không còn đợt nào hiệu lực tại ngày d = 2026-11-20
-- Đầu ra: ma_cu_dan, ho_ten
SELECT
    c.ma_cu_dan,
    c.ho_ten
FROM cu_dan AS c
WHERE EXISTS (
    SELECT 1
    FROM qua_trinh_cu_tru AS q_past
    WHERE q_past.ma_cu_dan = c.ma_cu_dan
      AND q_past.ngay_bat_dau <= DATE '2026-11-20'
)
  AND NOT EXISTS (
    SELECT 1
    FROM qua_trinh_cu_tru AS q_cur
    WHERE q_cur.ma_cu_dan = c.ma_cu_dan
      AND q_cur.ngay_bat_dau <= DATE '2026-11-20'
      AND (q_cur.ngay_ket_thuc IS NULL OR q_cur.ngay_ket_thuc >= DATE '2026-11-20')
)
ORDER BY c.ma_cu_dan;

-- QSQL08. Thống kê số sự kiện biến động theo tháng và loại biến động
-- Đầu ra: thang, loai_bien_dong, so_su_kien
SELECT
    TO_CHAR(DATE_TRUNC('month', b.ngay_bien_dong), 'YYYY-MM') AS thang,
    b.loai_bien_dong,
    COUNT(*) AS so_su_kien
FROM bien_dong_cu_tru AS b
GROUP BY DATE_TRUNC('month', b.ngay_bien_dong), b.loai_bien_dong
ORDER BY thang, b.loai_bien_dong;

-- QSQL09. Danh sách các sự kiện chuyển nội bộ giữa hai tổ khác nhau
-- Đầu ra: ma_bien_dong, ma_cu_dan, ma_to_cu, ma_to_moi, ngay_bien_dong
SELECT
    b.ma_bien_dong,
    q_cu.ma_cu_dan,
    d_cu.ma_to AS ma_to_cu,
    d_moi.ma_to AS ma_to_moi,
    b.ngay_bien_dong
FROM bien_dong_cu_tru AS b
JOIN qua_trinh_cu_tru AS q_cu  ON q_cu.ma_qua_trinh = b.ma_qua_trinh_cu
JOIN ho_cu_tru AS h_cu         ON h_cu.ma_ho = q_cu.ma_ho
JOIN dia_chi AS d_cu           ON d_cu.ma_dia_chi = h_cu.ma_dia_chi
JOIN qua_trinh_cu_tru AS q_moi ON q_moi.ma_qua_trinh = b.ma_qua_trinh_moi
JOIN ho_cu_tru AS h_moi        ON h_moi.ma_ho = q_moi.ma_ho
JOIN dia_chi AS d_moi          ON d_moi.ma_dia_chi = h_moi.ma_dia_chi
WHERE b.loai_bien_dong = 'CHUYEN_NOI_BO'
  AND q_cu.ma_cu_dan = q_moi.ma_cu_dan
  AND d_cu.ma_to <> d_moi.ma_to
ORDER BY b.ma_bien_dong;

-- QSQL10. Thống kê số sự kiện được ghi bởi mỗi tài khoản, kể cả tài khoản chưa ghi sự kiện nào
-- Đầu ra: ma_tai_khoan, ten_hien_thi, so_su_kien
SELECT
    a.ma_tai_khoan,
    a.ten_hien_thi,
    COUNT(b.ma_bien_dong) AS so_su_kien
FROM tai_khoan AS a
LEFT JOIN bien_dong_cu_tru AS b ON b.ma_tai_khoan = a.ma_tai_khoan
GROUP BY a.ma_tai_khoan, a.ten_hien_thi
ORDER BY a.ma_tai_khoan;
