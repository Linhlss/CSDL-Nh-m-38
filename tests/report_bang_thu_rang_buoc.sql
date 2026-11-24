-- =====================================================================
-- BTL CSDL Đề tài 17 — Nhóm 38
-- tests/report_bang_thu_rang_buoc.sql
--
-- Tái lập 7 thao tác vi phạm ràng buộc ở bảng "Kết quả thử các câu lệnh vi
-- phạm ràng buộc" (Chương 3, chuong3.tex, label tab:thurangbuoc) và ghi lại
-- SQLSTATE, tên ràng buộc, thông báo THỰC TẾ của PostgreSQL.
--
-- Ca 2 (CHUYEN_DEN có cả đợt cũ) chạy hai biến thể để thấy quy tắc nào chặn
-- trước: trigger BEFORE (B09) chạy trước CHECK của bảng (ck_bd_hinh_dang, B07).
--
-- Chạy bằng chủ sở hữu bảng (postgres) trên seed636 dựng mới
-- (01 -> 02 -> 03 -> 06). Toàn bộ nằm trong BEGIN ... ROLLBACK: không đổi dữ liệu.
--   psql -X -v ON_ERROR_STOP=1 -d <db_seed636> -f tests/report_bang_thu_rang_buoc.sql
-- =====================================================================

\set ON_ERROR_STOP on
BEGIN;
SET search_path = public;

CREATE TEMP TABLE kq_thu (stt TEXT, thao_tac TEXT, sqlstate TEXT, rang_buoc TEXT, thong_bao TEXT)
    ON COMMIT DROP;

CREATE FUNCTION pg_temp.thu(p_stt TEXT, p_mo_ta TEXT, p_sql TEXT) RETURNS void
LANGUAGE plpgsql AS $f$
DECLARE s TEXT; c TEXT; m TEXT;
BEGIN
    BEGIN
        EXECUTE p_sql;
        INSERT INTO kq_thu VALUES (p_stt, p_mo_ta, 'OK (không bị chặn)', NULL, NULL);
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '__hoan_tac__';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS s = RETURNED_SQLSTATE, c = CONSTRAINT_NAME, m = MESSAGE_TEXT;
        IF m <> '__hoan_tac__' THEN
            INSERT INTO kq_thu VALUES (p_stt, p_mo_ta, s, NULLIF(c, ''), m);
        END IF;
    END;
END
$f$;

-- 1. Đợt THUONG_TRU thứ hai cho cư dân 1, chồng với đợt 1 (bắt đầu 2023-01-10, đang mở)
SELECT pg_temp.thu('1', 'Thêm đợt THUONG_TRU cho cư dân 1 trùng thời gian đợt đang có',
  $$INSERT INTO qua_trinh_cu_tru (ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau)
    VALUES (1, 1, 'THUONG_TRU', DATE '2026-11-01')$$);

-- 2a. CHUYEN_DEN kèm đợt cũ là đợt 1 (đang mở, không kết thúc ngày t-1)
SELECT pg_temp.thu('2a', 'CHUYEN_DEN có cả đợt cũ (đợt 1 đang mở), đợt mới 17, ngày 2026-10-15',
  $$INSERT INTO bien_dong_cu_tru (loai_bien_dong, ma_qua_trinh_cu, ma_qua_trinh_moi, ngay_bien_dong, ma_tai_khoan)
    VALUES ('CHUYEN_DEN', 1, 17, DATE '2026-10-15', 2)$$);

-- 2b. CHUYEN_DEN kèm đợt cũ có ngày khớp B09 (lấy cặp đợt 16 -> 17 của biến động 2)
SELECT pg_temp.thu('2b', 'CHUYEN_DEN có cả đợt cũ 16 (kết thúc đúng t-1) và đợt mới 17 (bắt đầu t)',
  $$INSERT INTO bien_dong_cu_tru (loai_bien_dong, ma_qua_trinh_cu, ma_qua_trinh_moi, ngay_bien_dong, ma_tai_khoan)
    VALUES ('CHUYEN_DEN', 16, 17, DATE '2026-10-15', 2)$$);

-- 3. Đổi địa chỉ của hộ 1 (đã có lịch sử cư trú)
SELECT pg_temp.thu('3', 'Đổi địa chỉ của hộ 1 đã có lịch sử',
  $$UPDATE ho_cu_tru SET ma_dia_chi = 2 WHERE ma_ho = 1$$);

-- 4. Đợt có ngày kết thúc trước ngày bắt đầu
SELECT pg_temp.thu('4', 'Đợt TAM_TRU của cư dân 1 có ngày kết thúc 2026-01-01 trước ngày bắt đầu 2026-01-02',
  $$INSERT INTO qua_trinh_cu_tru (ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau, ngay_ket_thuc)
    VALUES (1, 1, 'TAM_TRU', DATE '2026-01-02', DATE '2026-01-01')$$);

-- 5. Xóa cư dân 1 đang có đợt cư trú
SELECT pg_temp.thu('5', 'Xóa cư dân 1 đang có đợt cư trú',
  $$DELETE FROM cu_dan WHERE ma_cu_dan = 1$$);

-- 6. Họ tên chỉ gồm khoảng trắng
SELECT pg_temp.thu('6', 'Thêm cư dân có họ tên chỉ gồm khoảng trắng',
  $$INSERT INTO cu_dan (ho_ten, ngay_sinh, gioi_tinh) VALUES ('   ', DATE '2000-01-01', 'Nam')$$);

-- 7. E1 (sửa X07, 24/11): dùng lại đợt 16, đã là đợt cũ của biến động 2.
-- Ngày 2026-10-15 khớp B09 nên trigger cho qua; UNIQUE uq_bd_qua_trinh_cu chặn.
SELECT pg_temp.thu('7', 'CHUYEN_DI dùng lại đợt cũ 16 đã có biến động 2, ngày 2026-10-15',
  $$INSERT INTO bien_dong_cu_tru (loai_bien_dong, ma_qua_trinh_cu, ma_qua_trinh_moi, ngay_bien_dong, ma_tai_khoan)
    VALUES ('CHUYEN_DI', 16, NULL, DATE '2026-10-15', 2)$$);

\pset footer on
SELECT stt, thao_tac, sqlstate, rang_buoc, thong_bao FROM kq_thu ORDER BY stt;

ROLLBACK;
