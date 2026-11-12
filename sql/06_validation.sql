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

-- TODO: kiểm tra cặp đợt cùng cư dân cùng loại chồng lấn.
-- TODO: kiểm tra cặp đợt cũ/mới của sự kiện chuyển nội bộ cùng cư dân.
-- TODO: kiểm tra số kịch bản S01–S21 và query expected.
