-- Kiểm chứng ba câu DML minh họa ở mục "Câu lệnh DML minh họa" (Chương 3 báo cáo).
-- Chạy trên DB dựng mới: 01_schema.sql -> 02_constraints.sql -> 03_seed.sql.
--   psql -X -d <db_seed636> -f tests/report_dml_minh_hoa.sql
-- Mỗi ví dụ chạy trong một giao dịch rồi ROLLBACK, dữ liệu mẫu không đổi.
-- Hai lỗi B09 cố ý được kiểm tra riêng. Các lỗi khác dừng script.
\set ON_ERROR_STOP on

\echo '=== DML 1: fn_chuyen_noi_bo, đợt 44 (cư dân 40, hộ 21) sang hộ 2 ==='
BEGIN;
SELECT * FROM fn_chuyen_noi_bo(44, 2, 'THUONG_TRU', CURRENT_DATE, 2);
SELECT ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau, ngay_ket_thuc
FROM qua_trinh_cu_tru WHERE ma_cu_dan = 40 ORDER BY ngay_bat_dau;
SELECT ma_bien_dong, loai_bien_dong, ma_qua_trinh_cu, ma_qua_trinh_moi, ngay_bien_dong
FROM bien_dong_cu_tru WHERE ma_qua_trinh_cu = 44;
ROLLBACK;

\echo '=== DML 2: ghi chuyển đi cho đợt 50 (cư dân 44, hộ 16) ==='
BEGIN;
UPDATE qua_trinh_cu_tru
SET ngay_ket_thuc = CURRENT_DATE - 1
WHERE ma_qua_trinh = 50;
INSERT INTO bien_dong_cu_tru (loai_bien_dong, ma_qua_trinh_cu, ma_qua_trinh_moi,
                              ngay_bien_dong, ma_tai_khoan)
VALUES ('CHUYEN_DI', 50, NULL, CURRENT_DATE, 2)
RETURNING ma_bien_dong, loai_bien_dong, ma_qua_trinh_cu, ngay_bien_dong;
ROLLBACK;

\echo '=== DML 2b (đối chứng): ghi CHUYEN_DI khi đợt 50 chưa kết thúc, mong đợi B09 chặn ==='
BEGIN;
\set ON_ERROR_STOP off
\set VERBOSITY verbose
INSERT INTO bien_dong_cu_tru (loai_bien_dong, ma_qua_trinh_cu, ma_qua_trinh_moi,
                              ngay_bien_dong, ma_tai_khoan)
VALUES ('CHUYEN_DI', 50, NULL, CURRENT_DATE, 2);
\set dml_sqlstate :SQLSTATE
\set ON_ERROR_STOP on
ROLLBACK;
SELECT 1 / (:'dml_sqlstate' = '23514')::int AS b09_kiem_tra_chieu_thuan;

\echo '=== DML 3: dời ngày bắt đầu đợt 17 (đợt mới của biến động 2), mong đợi B09 chặn ==='
BEGIN;
\set ON_ERROR_STOP off
UPDATE qua_trinh_cu_tru
SET ngay_bat_dau = DATE '2026-10-20'
WHERE ma_qua_trinh = 17;
\set dml_sqlstate :SQLSTATE
\set ON_ERROR_STOP on
ROLLBACK;
SELECT 1 / (:'dml_sqlstate' = '23514')::int AS b09_kiem_tra_chieu_nguoc;
\set VERBOSITY default
