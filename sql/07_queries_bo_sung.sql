-- Ba truy vấn SQL bổ sung (QSQL11-QSQL13), thêm ngày 26/11/2026 theo review.
-- Mục đích: trình bày các kỹ thuật chưa có trong QSQL01-QSQL10:
--   QSQL11  CTE (WITH) và hàm cửa sổ RANK() OVER (PARTITION BY ...)
--   QSQL12  truy vấn con trong FROM (bảng dẫn xuất) kết hợp AVG() OVER ()
--   QSQL13  phép chia viết bằng hai lớp NOT EXISTS (Câu 9, Chương 4)
-- Ngày tham chiếu cố định như QSQL01-QSQL03: DATE '2026-11-20'.
-- Chạy trên CSDL seed636 dựng mới: 01 -> 02 -> 03. Tệp chỉ đọc dữ liệu.
-- Tách riêng khỏi 04_queries.sql để không đổi bản QSQL01-QSQL10 đã kiểm thử.

-- QSQL11. Hộ đông người nhất trong mỗi tổ tại ngày d = 2026-11-20
-- Đầu ra: ma_to, ten_to, ma_ho, so_cu_dan (hộ đồng hạng được giữ cả)
WITH so_nguoi AS (
    SELECT d.ma_to,
           q.ma_ho,
           COUNT(DISTINCT q.ma_cu_dan) AS so_cu_dan
    FROM qua_trinh_cu_tru AS q
    JOIN ho_cu_tru AS h ON h.ma_ho = q.ma_ho
    JOIN dia_chi AS d   ON d.ma_dia_chi = h.ma_dia_chi
    WHERE q.ngay_bat_dau <= DATE '2026-11-20'
      AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
    GROUP BY d.ma_to, q.ma_ho
),
xep_hang AS (
    SELECT s.*,
           RANK() OVER (PARTITION BY s.ma_to ORDER BY s.so_cu_dan DESC) AS hang
    FROM so_nguoi AS s
)
SELECT x.ma_to, t.ten_to, x.ma_ho, x.so_cu_dan
FROM xep_hang AS x
JOIN to_dan_pho AS t ON t.ma_to = x.ma_to
WHERE x.hang = 1
ORDER BY x.ma_to, x.ma_ho;

-- QSQL12. Tổ có số cư dân đang cư trú cao hơn mức trung bình của các tổ (d = 2026-11-20)
-- Đầu ra: ma_to, ten_to, so_cu_dan, trung_binh
SELECT s.ma_to, s.ten_to, s.so_cu_dan, ROUND(s.trung_binh, 2) AS trung_binh
FROM (
    SELECT t.ma_to,
           t.ten_to,
           COUNT(DISTINCT q.ma_cu_dan) AS so_cu_dan,
           AVG(COUNT(DISTINCT q.ma_cu_dan)) OVER () AS trung_binh
    FROM to_dan_pho AS t
    LEFT JOIN dia_chi AS d          ON d.ma_to = t.ma_to
    LEFT JOIN ho_cu_tru AS h        ON h.ma_dia_chi = d.ma_dia_chi
    LEFT JOIN qua_trinh_cu_tru AS q ON q.ma_ho = h.ma_ho
                                   AND q.ngay_bat_dau <= DATE '2026-11-20'
                                   AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
    GROUP BY t.ma_to, t.ten_to
) AS s
WHERE s.so_cu_dan > s.trung_binh
ORDER BY s.so_cu_dan DESC, s.ma_to;

-- QSQL13. Tài khoản đã ghi đủ mọi loại biến động có trong dữ liệu (phép chia)
-- Đầu ra: ma_tai_khoan, ten_hien_thi
SELECT a.ma_tai_khoan, a.ten_hien_thi
FROM tai_khoan AS a
WHERE NOT EXISTS (
    SELECT 1
    FROM (SELECT DISTINCT loai_bien_dong FROM bien_dong_cu_tru) AS l
    WHERE NOT EXISTS (
        SELECT 1
        FROM bien_dong_cu_tru AS b
        WHERE b.ma_tai_khoan = a.ma_tai_khoan
          AND b.loai_bien_dong = l.loai_bien_dong
    )
)
ORDER BY a.ma_tai_khoan;
