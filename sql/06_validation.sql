-- TODO – TV2 chủ trì, TV1 và TV3 review; chạy sau khi đã seed.
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

-- TODO: kiểm tra cặp đợt cùng cư dân cùng loại chồng lấn.
-- TODO: kiểm tra cặp đợt cũ/mới của sự kiện chuyển nội bộ cùng cư dân.
-- TODO: kiểm tra số kịch bản S01–S21 và query expected.
