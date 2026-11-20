-- Validation dữ liệu: TV1 bổ sung E1/B09 ngày 12/11/2026; TV2 chạy sau seed.
-- Chỉ đọc, không sửa dữ liệu và không tự chặn INSERT/UPDATE.
-- Điều kiện nghiệm thu E1/B09: cả ba truy vấn V_E1_CU, V_E1_MOI, V_B09 trả 0 dòng.
-- Số bản ghi từng bảng:
SELECT 'to_dan_pho' AS ten_bang, COUNT(*) AS so_ban_ghi FROM to_dan_pho
UNION ALL SELECT 'dia_chi', COUNT(*) FROM dia_chi
UNION ALL SELECT 'ho_cu_tru', COUNT(*) FROM ho_cu_tru
UNION ALL SELECT 'cu_dan', COUNT(*) FROM cu_dan
UNION ALL SELECT 'qua_trinh_cu_tru', COUNT(*) FROM qua_trinh_cu_tru
UNION ALL SELECT 'bien_dong_cu_tru', COUNT(*) FROM bien_dong_cu_tru
UNION ALL SELECT 'tai_khoan', COUNT(*) FROM tai_khoan;

-- Bất hợp lệ ngày (mong đợi 0; CHECK đã ngăn nạp dữ liệu sai):
SELECT COUNT(*) AS so_dot_sai_ngay
FROM qua_trinh_cu_tru
WHERE ngay_ket_thuc < ngay_bat_dau;

-- V_E1_CU: một đợt bị nhiều sự kiện dùng làm đợt cũ (mong đợi 0 dòng).
-- Hai vai trò được kiểm riêng: một đợt từng là mới rồi là cũ là hợp lệ.
SELECT ma_qua_trinh_cu AS ma_qua_trinh,
       'CU' AS vai_tro,
       COUNT(*) AS so_lan,
       ARRAY_AGG(ma_bien_dong ORDER BY ma_bien_dong) AS cac_ma_bien_dong
FROM bien_dong_cu_tru
WHERE ma_qua_trinh_cu IS NOT NULL
GROUP BY ma_qua_trinh_cu
HAVING COUNT(*) > 1
ORDER BY ma_qua_trinh_cu;

-- V_E1_MOI: một đợt bị nhiều sự kiện dùng làm đợt mới (mong đợi 0 dòng).
SELECT ma_qua_trinh_moi AS ma_qua_trinh,
       'MOI' AS vai_tro,
       COUNT(*) AS so_lan,
       ARRAY_AGG(ma_bien_dong ORDER BY ma_bien_dong) AS cac_ma_bien_dong
FROM bien_dong_cu_tru
WHERE ma_qua_trinh_moi IS NOT NULL
GROUP BY ma_qua_trinh_moi
HAVING COUNT(*) > 1
ORDER BY ma_qua_trinh_moi;

-- V_B09: ngày chuyển t phải bằng ngày bắt đầu mới và bằng ngày kết thúc cũ + 1.
-- IS DISTINCT FROM còn phát hiện đợt cũ chưa đóng (NULL); mong đợi 0 dòng.
SELECT b.ma_bien_dong, b.loai_bien_dong, b.ngay_bien_dong,
       b.ma_qua_trinh_cu, cu.ngay_ket_thuc AS ngay_ket_thuc_cu,
       b.ma_qua_trinh_moi, moi.ngay_bat_dau AS ngay_bat_dau_moi
FROM bien_dong_cu_tru b
LEFT JOIN qua_trinh_cu_tru cu ON cu.ma_qua_trinh = b.ma_qua_trinh_cu
LEFT JOIN qua_trinh_cu_tru moi ON moi.ma_qua_trinh = b.ma_qua_trinh_moi
WHERE (b.ma_qua_trinh_cu IS NOT NULL
       AND cu.ngay_ket_thuc IS DISTINCT FROM b.ngay_bien_dong - 1)
   OR (b.ma_qua_trinh_moi IS NOT NULL
       AND moi.ngay_bat_dau IS DISTINCT FROM b.ngay_bien_dong)
ORDER BY b.ma_bien_dong;



-- ===== KIEM TRA TUAN 2 (TV1): phat hien du lieu vuot qua rang buoc =====
-- B06: hai dot cung nguoi, cung loai, giao nhau (mong doi 0 dong).
SELECT a.ma_qua_trinh AS dot_a, b.ma_qua_trinh AS dot_b,
       a.ma_cu_dan, a.loai_cu_tru
FROM qua_trinh_cu_tru a
JOIN qua_trinh_cu_tru b
  ON a.ma_cu_dan = b.ma_cu_dan
 AND a.loai_cu_tru = b.loai_cu_tru
 AND a.ma_qua_trinh < b.ma_qua_trinh
WHERE daterange(a.ngay_bat_dau, a.ngay_ket_thuc, '[]')
   && daterange(b.ngay_bat_dau, b.ngay_ket_thuc, '[]');

-- B08/B09: su kien sai nguoi/ho/ngay (mong doi 0 dong).
SELECT b.ma_bien_dong, b.loai_bien_dong,
       cu.ma_cu_dan AS nguoi_cu, moi.ma_cu_dan AS nguoi_moi,
       cu.ma_ho AS ho_cu, moi.ma_ho AS ho_moi
FROM bien_dong_cu_tru b
LEFT JOIN qua_trinh_cu_tru cu ON cu.ma_qua_trinh = b.ma_qua_trinh_cu
LEFT JOIN qua_trinh_cu_tru moi ON moi.ma_qua_trinh = b.ma_qua_trinh_moi
WHERE (b.ma_qua_trinh_cu IS NOT NULL
        AND cu.ngay_ket_thuc IS DISTINCT FROM b.ngay_bien_dong - 1)
   OR (b.ma_qua_trinh_moi IS NOT NULL
        AND moi.ngay_bat_dau IS DISTINCT FROM b.ngay_bien_dong)
   OR (b.loai_bien_dong = 'CHUYEN_NOI_BO'
        AND (cu.ma_cu_dan IS DISTINCT FROM moi.ma_cu_dan
             OR cu.ma_ho IS NOT DISTINCT FROM moi.ma_ho));

-- Assertion tren bo du lieu da nap: neu vi pham, psql ON_ERROR_STOP=1 se dung.
DO $assert$
BEGIN
    IF EXISTS (
        SELECT 1 FROM qua_trinh_cu_tru a
        JOIN qua_trinh_cu_tru b
          ON a.ma_qua_trinh < b.ma_qua_trinh
         AND a.ma_cu_dan = b.ma_cu_dan
         AND a.loai_cu_tru = b.loai_cu_tru
        WHERE daterange(a.ngay_bat_dau, a.ngay_ket_thuc, '[]')
           && daterange(b.ngay_bat_dau, b.ngay_ket_thuc, '[]')
    ) THEN
        RAISE EXCEPTION 'B06 validation FAIL: còn đợt chồng lấn';
    END IF;
    IF EXISTS (
        SELECT 1 FROM bien_dong_cu_tru b
        LEFT JOIN qua_trinh_cu_tru cu ON cu.ma_qua_trinh = b.ma_qua_trinh_cu
        LEFT JOIN qua_trinh_cu_tru moi ON moi.ma_qua_trinh = b.ma_qua_trinh_moi
        WHERE (b.ma_qua_trinh_cu IS NOT NULL AND
               cu.ngay_ket_thuc IS DISTINCT FROM b.ngay_bien_dong - 1)
           OR (b.ma_qua_trinh_moi IS NOT NULL AND
               moi.ngay_bat_dau IS DISTINCT FROM b.ngay_bien_dong)
           OR (b.loai_bien_dong = 'CHUYEN_NOI_BO'
               AND (cu.ma_cu_dan IS DISTINCT FROM moi.ma_cu_dan
                    OR cu.ma_ho IS NOT DISTINCT FROM moi.ma_ho))
    ) THEN
        RAISE EXCEPTION 'B08/B09 validation FAIL: sự kiện mâu thuẫn đợt';
    END IF;
    RAISE NOTICE '[PASS] B06, B08, B09: dữ liệu đang nạp không có vi phạm';
END
$assert$;

-- Đối soát expected/actual S01–S21 và 10 truy vấn: tests/ và Gate 3.



-- E1: kiểm tra lỗi ghi trùng trong CÙNG vai trò (cũ/mới).
-- Hai SELECT phía trên vẫn phục vụ phần báo cáo; câu lệnh này phải FAIL nếu
-- kết quả V_E1_CU hoặc V_E1_MOI có bất kỳ dòng nào.
DO $assert_e1$
BEGIN
    PERFORM fn_assert_e1();
    RAISE NOTICE '[PASS] E1: không trùng đợt trong cùng vai trò cũ/mới';
END
$assert_e1$;

-- B15: ngày sinh và ngày lập hộ không muộn hơn ngày bắt đầu cư trú.
-- Các CHECK tên rỗng ở 02_constraints.sql đã bảo vệ khi INSERT/UPDATE.
DO $assert_b15$
BEGIN
    IF EXISTS (
        SELECT 1 FROM qua_trinh_cu_tru q
        JOIN cu_dan c ON c.ma_cu_dan = q.ma_cu_dan
        JOIN ho_cu_tru h ON h.ma_ho = q.ma_ho
        WHERE c.ngay_sinh > q.ngay_bat_dau
           OR h.ngay_lap > q.ngay_bat_dau
    ) THEN
        RAISE EXCEPTION 'B15 validation FAIL: có ngày sinh/ngày lập hộ sau ngày cư trú';
    END IF;
    IF EXISTS (SELECT 1 FROM cu_dan WHERE LENGTH(BTRIM(ho_ten)) = 0)
        OR EXISTS (SELECT 1 FROM to_dan_pho WHERE LENGTH(BTRIM(ten_to)) = 0)
        OR EXISTS (SELECT 1 FROM dia_chi WHERE LENGTH(BTRIM(dia_chi_chuan)) = 0)
        OR EXISTS (SELECT 1 FROM tai_khoan
                   WHERE LENGTH(BTRIM(ten_dang_nhap)) = 0
                      OR LENGTH(BTRIM(ten_hien_thi)) = 0)
    THEN
        RAISE EXCEPTION 'B15 validation FAIL: tên/địa chỉ rỗng';
    END IF;
    RAISE NOTICE '[PASS] B15: ngày và tên/địa chỉ hợp lệ trên bộ seed';
END
$assert_b15$;
