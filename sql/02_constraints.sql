-- BTL CSDL 17 | TV1 | Rang buoc nghiep vu nang cao (PostgreSQL >= 15).
-- Chay SAU sql/01_schema.sql, TRUOC sql/03_seed.sql.
-- Khong tao bang moi; su dung GiST, trigger va ham giao dich.
-- Tai lap: CREATE EXTENSION/CREATE OR REPLACE/DO kiem tra ten constraint.
-- Chi chay trong database demo. Mot so buoc yeu cau quyen CREATE EXTENSION.

BEGIN;
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- B06: cùng người + cùng loại không được chồng lấn khoảng ngày [start,end].
-- NULL ở ngày kết thúc nghĩa là không có giới hạn trên.
-- daterange(..., '[]') đưa cả ngày kết thúc vào khoảng.
DO $ddl$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ex_qt_cu_tru_khong_chong_lan'
          AND conrelid = 'qua_trinh_cu_tru'::regclass
    ) THEN
        ALTER TABLE qua_trinh_cu_tru
          ADD CONSTRAINT ex_qt_cu_tru_khong_chong_lan
          EXCLUDE USING gist (
            ma_cu_dan WITH =,
            loai_cu_tru WITH =,
            daterange(ngay_bat_dau, ngay_ket_thuc, '[]') WITH &&
          );
    END IF;
END
$ddl$;

-- B08/B09: kiểm tra đầy đủ một sự kiện, có khóa SHARE để đồng bộ
-- với thao tác UPDATE đợt cư trú chạy đồng thời.
CREATE OR REPLACE FUNCTION fn_kiem_tra_su_kien(
    p_loai VARCHAR, p_cu BIGINT, p_moi BIGINT, p_ngay DATE
) RETURNS void LANGUAGE plpgsql AS $fn$
DECLARE
    v_cu qua_trinh_cu_tru%ROWTYPE;
    v_moi qua_trinh_cu_tru%ROWTYPE;
BEGIN
    -- CHECK gốc chạy sau BEFORE trigger: giữ mã lỗi nhất quán cho dạng thiếu FK.
    IF p_loai = 'CHUYEN_NOI_BO' AND (p_cu IS NULL OR p_moi IS NULL) THEN
        RAISE EXCEPTION 'B08: chuyển nội bộ phải có cả đợt cũ và mới'
            USING ERRCODE = '23514';
    END IF;

    IF p_cu IS NOT NULL THEN
        SELECT * INTO v_cu FROM qua_trinh_cu_tru
        WHERE ma_qua_trinh = p_cu FOR SHARE;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'B09: đợt cũ % không tồn tại', p_cu
                USING ERRCODE = '23503';
        END IF;
        IF v_cu.ngay_ket_thuc IS DISTINCT FROM (p_ngay - 1) THEN
            RAISE EXCEPTION 'B09: đợt cũ % phải kết thúc trước ngày chuyển % đúng 1 ngày',
                p_cu, p_ngay USING ERRCODE = '23514';
        END IF;
    END IF;

    IF p_moi IS NOT NULL THEN
        SELECT * INTO v_moi FROM qua_trinh_cu_tru
        WHERE ma_qua_trinh = p_moi FOR SHARE;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'B09: đợt mới % không tồn tại', p_moi
                USING ERRCODE = '23503';
        END IF;
        IF v_moi.ngay_bat_dau IS DISTINCT FROM p_ngay THEN
            RAISE EXCEPTION 'B09: đợt mới % phải bắt đầu đúng ngày chuyển %',
                p_moi, p_ngay USING ERRCODE = '23514';
        END IF;
    END IF;

    IF p_loai = 'CHUYEN_NOI_BO' THEN
        IF v_cu.ma_cu_dan IS DISTINCT FROM v_moi.ma_cu_dan
           OR v_cu.ma_ho IS NOT DISTINCT FROM v_moi.ma_ho THEN
            RAISE EXCEPTION 'B08: chuyển nội bộ phải cùng cư dân, khác hộ'
                USING ERRCODE = '23514';
        END IF;
    END IF;
END
$fn$;

-- B14: lúc ghi sự kiện hoặc đổi người ghi phải dùng tài khoản HOAT_DONG.
-- Khóa tài khoản về sau không làm vô hiệu sự kiện lịch sử.
CREATE OR REPLACE FUNCTION fn_truoc_ghi_bien_dong()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE
    v_kiem_tra_tai_khoan BOOLEAN := FALSE;
    v_trang_thai VARCHAR(20);
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_kiem_tra_tai_khoan := TRUE;
    ELSIF NEW.ma_tai_khoan IS DISTINCT FROM OLD.ma_tai_khoan THEN
        v_kiem_tra_tai_khoan := TRUE;
    END IF;

    IF v_kiem_tra_tai_khoan THEN
        SELECT trang_thai INTO v_trang_thai FROM tai_khoan
        WHERE ma_tai_khoan = NEW.ma_tai_khoan FOR SHARE;
        IF v_trang_thai IS DISTINCT FROM 'HOAT_DONG' THEN
            RAISE EXCEPTION 'B14: tài khoản % không ở trạng thái HOAT_DONG', NEW.ma_tai_khoan
                USING ERRCODE = '23514';
        END IF;
    END IF;

    PERFORM fn_kiem_tra_su_kien(
        NEW.loai_bien_dong, NEW.ma_qua_trinh_cu,
        NEW.ma_qua_trinh_moi, NEW.ngay_bien_dong
    );
    RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS trg_bien_dong_hop_le ON bien_dong_cu_tru;
CREATE TRIGGER trg_bien_dong_hop_le
BEFORE INSERT OR UPDATE ON bien_dong_cu_tru
FOR EACH ROW EXECUTE FUNCTION fn_truoc_ghi_bien_dong();

-- B08/B09 chiều ngược: sửa một đợt không được làm hỏng sự kiện cũ.
CREATE OR REPLACE FUNCTION fn_sau_sua_dot_cu_tru()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE
    v_su_kien bien_dong_cu_tru%ROWTYPE;
BEGIN
    IF (NEW.ma_cu_dan, NEW.ma_ho, NEW.ngay_bat_dau, NEW.ngay_ket_thuc)
       IS DISTINCT FROM
       (OLD.ma_cu_dan, OLD.ma_ho, OLD.ngay_bat_dau, OLD.ngay_ket_thuc) THEN
        FOR v_su_kien IN
            SELECT * FROM bien_dong_cu_tru
            WHERE ma_qua_trinh_cu = NEW.ma_qua_trinh
               OR ma_qua_trinh_moi = NEW.ma_qua_trinh
        LOOP
            PERFORM fn_kiem_tra_su_kien(
                v_su_kien.loai_bien_dong,
                v_su_kien.ma_qua_trinh_cu,
                v_su_kien.ma_qua_trinh_moi,
                v_su_kien.ngay_bien_dong
            );
        END LOOP;
    END IF;
    RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS trg_dot_khong_pha_su_kien ON qua_trinh_cu_tru;
CREATE TRIGGER trg_dot_khong_pha_su_kien
AFTER UPDATE OF ma_cu_dan, ma_ho, ngay_bat_dau, ngay_ket_thuc
ON qua_trinh_cu_tru
FOR EACH ROW EXECUTE FUNCTION fn_sau_sua_dot_cu_tru();

-- B11: không chuyển địa chỉ/tổ "ngầm" trên lịch sử đã có.
CREATE OR REPLACE FUNCTION fn_khoa_dia_chi_lich_su()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
    IF TG_TABLE_NAME = 'ho_cu_tru' THEN
        IF NEW.ma_dia_chi IS DISTINCT FROM OLD.ma_dia_chi
           AND EXISTS (SELECT 1 FROM qua_trinh_cu_tru WHERE ma_ho = OLD.ma_ho) THEN
            RAISE EXCEPTION 'B11: không đổi địa chỉ của hộ % đã có lịch sử', OLD.ma_ho
                USING ERRCODE = '23514';
        END IF;
    ELSIF TG_TABLE_NAME = 'dia_chi' THEN
        IF NEW.ma_to IS DISTINCT FROM OLD.ma_to
           AND EXISTS (
               SELECT 1 FROM ho_cu_tru h
               JOIN qua_trinh_cu_tru q ON q.ma_ho = h.ma_ho
               WHERE h.ma_dia_chi = OLD.ma_dia_chi
           ) THEN
            RAISE EXCEPTION 'B11: không đổi tổ của địa chỉ % đã có lịch sử', OLD.ma_dia_chi
                USING ERRCODE = '23514';
        END IF;
    END IF;
    RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS trg_ho_giu_dia_chi_lich_su ON ho_cu_tru;
CREATE TRIGGER trg_ho_giu_dia_chi_lich_su
BEFORE UPDATE OF ma_dia_chi ON ho_cu_tru
FOR EACH ROW EXECUTE FUNCTION fn_khoa_dia_chi_lich_su();

DROP TRIGGER IF EXISTS trg_dia_chi_giu_to_lich_su ON dia_chi;
CREATE TRIGGER trg_dia_chi_giu_to_lich_su
BEFORE UPDATE OF ma_to ON dia_chi
FOR EACH ROW EXECUTE FUNCTION fn_khoa_dia_chi_lich_su();

-- Ngăn đua tranh giữa thêm lịch sử và đổi liên kết địa lý:
-- FK chỉ giữ KEY SHARE, vì vậy khóa SHARE bổ sung các hàng cha.
CREATE OR REPLACE FUNCTION fn_khoa_vi_tri_khi_ghi_dot()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
    PERFORM 1 FROM ho_cu_tru h
    JOIN dia_chi d ON d.ma_dia_chi = h.ma_dia_chi
    WHERE h.ma_ho = NEW.ma_ho
    FOR SHARE OF h, d;
    RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS trg_dot_khoa_vi_tri ON qua_trinh_cu_tru;
CREATE TRIGGER trg_dot_khoa_vi_tri
AFTER INSERT OR UPDATE OF ma_ho ON qua_trinh_cu_tru
FOR EACH ROW EXECUTE FUNCTION fn_khoa_vi_tri_khi_ghi_dot();

-- B10: một lần gọi hàm được PostgreSQL thực hiện nguyên tử;
-- luôn đặt trong transaction bên ngoài để gom các bước nghiệp vụ khác.
-- Mở/đóng đợt và ghi sự kiện cùng giao dịch, khóa đợt cũ FOR UPDATE.
-- Không thay đổi loại cư trú đợt cũ; loại đợt mới được truyền vào.
CREATE OR REPLACE FUNCTION fn_chuyen_noi_bo(
    p_ma_qua_trinh_cu BIGINT,
    p_ma_ho_moi BIGINT,
    p_loai_moi VARCHAR(20),
    p_ngay_chuyen DATE,
    p_ma_tai_khoan BIGINT
) RETURNS TABLE(ma_dot_moi BIGINT, ma_su_kien BIGINT)
LANGUAGE plpgsql AS $fn$
DECLARE
    v_cu qua_trinh_cu_tru%ROWTYPE;
    v_moi BIGINT;
    v_sk BIGINT;
BEGIN
    SELECT * INTO v_cu FROM qua_trinh_cu_tru
    WHERE ma_qua_trinh = p_ma_qua_trinh_cu FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'B10: đợt cũ % không tồn tại', p_ma_qua_trinh_cu
            USING ERRCODE = '23503';
    END IF;
    IF v_cu.ngay_ket_thuc IS NOT NULL OR p_ngay_chuyen <= v_cu.ngay_bat_dau THEN
        RAISE EXCEPTION 'B10: đợt cũ phải đang mở và bắt đầu trước ngày chuyển'
            USING ERRCODE = '23514';
    END IF;
    IF p_ma_ho_moi = v_cu.ma_ho THEN
        RAISE EXCEPTION 'B08: hộ mới phải khác hộ cũ'
            USING ERRCODE = '23514';
    END IF;

    UPDATE qua_trinh_cu_tru
    SET ngay_ket_thuc = p_ngay_chuyen - 1
    WHERE ma_qua_trinh = p_ma_qua_trinh_cu;

    INSERT INTO qua_trinh_cu_tru (
        ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau, ngay_ket_thuc
    ) VALUES (v_cu.ma_cu_dan, p_ma_ho_moi, p_loai_moi, p_ngay_chuyen, NULL)
    RETURNING ma_qua_trinh INTO v_moi;

    INSERT INTO bien_dong_cu_tru (
        loai_bien_dong, ma_qua_trinh_cu, ma_qua_trinh_moi,
        ngay_bien_dong, ma_tai_khoan
    ) VALUES (
        'CHUYEN_NOI_BO', p_ma_qua_trinh_cu, v_moi,
        p_ngay_chuyen, p_ma_tai_khoan
    ) RETURNING ma_bien_dong INTO v_sk;

    RETURN QUERY SELECT v_moi, v_sk;
END
$fn$;
-- E1: assertion CHỈ dùng khi validation, không đặt UNIQUE lên lịch sử.
-- Một đợt có thể xuất hiện một lần mỗi vai trò (mới rồi cũ), nhưng không
-- được xuất hiện nhiều lần TRONG CÙNG MỘT VAI TRÒ ở bộ dữ liệu nghiệm thu.
CREATE OR REPLACE FUNCTION fn_assert_e1()
RETURNS void LANGUAGE plpgsql AS $fn$
BEGIN
    IF EXISTS (
        SELECT 1 FROM bien_dong_cu_tru
        WHERE ma_qua_trinh_cu IS NOT NULL
        GROUP BY ma_qua_trinh_cu HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'E1: trùng đợt trong vai trò CU'
            USING ERRCODE = '23514';
    END IF;
    IF EXISTS (
        SELECT 1 FROM bien_dong_cu_tru
        WHERE ma_qua_trinh_moi IS NOT NULL
        GROUP BY ma_qua_trinh_moi HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'E1: trùng đợt trong vai trò MOI'
            USING ERRCODE = '23514';
    END IF;
END
$fn$;

-- B15: tên không rỗng sau khi bỏ khoảng trắng.
DO $ddl$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='ck_b15_ten_to'
       AND conrelid='to_dan_pho'::regclass) THEN
        ALTER TABLE to_dan_pho ADD CONSTRAINT ck_b15_ten_to
            CHECK (LENGTH(BTRIM(ten_to)) > 0);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='ck_b15_dia_chi'
       AND conrelid='dia_chi'::regclass) THEN
        ALTER TABLE dia_chi ADD CONSTRAINT ck_b15_dia_chi
            CHECK (LENGTH(BTRIM(dia_chi_chuan)) > 0);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='ck_b15_ho_ten'
       AND conrelid='cu_dan'::regclass) THEN
        ALTER TABLE cu_dan ADD CONSTRAINT ck_b15_ho_ten
            CHECK (LENGTH(BTRIM(ho_ten)) > 0);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='ck_b15_ten_dang_nhap'
       AND conrelid='tai_khoan'::regclass) THEN
        ALTER TABLE tai_khoan ADD CONSTRAINT ck_b15_ten_dang_nhap
            CHECK (LENGTH(BTRIM(ten_dang_nhap)) > 0);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='ck_b15_ten_hien_thi'
       AND conrelid='tai_khoan'::regclass) THEN
        ALTER TABLE tai_khoan ADD CONSTRAINT ck_b15_ten_hien_thi
            CHECK (LENGTH(BTRIM(ten_hien_thi)) > 0);
    END IF;
END
$ddl$;

-- B15: kiểm tra cả chiều INSERT/UPDATE đợt và sửa hồ sơ cha.
CREATE OR REPLACE FUNCTION fn_b15_kiem_tra_dot()
RETURNS trigger LANGUAGE plpgsql AS $fn$
DECLARE
    v_ngay_sinh DATE;
    v_ngay_lap DATE;
BEGIN
    SELECT ngay_sinh INTO v_ngay_sinh FROM cu_dan
    WHERE ma_cu_dan = NEW.ma_cu_dan FOR SHARE;
    SELECT ngay_lap INTO v_ngay_lap FROM ho_cu_tru
    WHERE ma_ho = NEW.ma_ho FOR SHARE;

    -- FK còn bảo vệ trường hợp mã cư dân / mã hộ không tồn tại.
    IF v_ngay_sinh > NEW.ngay_bat_dau
       OR v_ngay_lap > NEW.ngay_bat_dau THEN
        RAISE EXCEPTION 'B15: ngày sinh hoặc ngày lập hộ sau ngày bắt đầu cư trú'
            USING ERRCODE = '23514';
    END IF;
    RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS trg_b15_dot ON qua_trinh_cu_tru;
CREATE TRIGGER trg_b15_dot
BEFORE INSERT OR UPDATE OF ma_cu_dan, ma_ho, ngay_bat_dau
ON qua_trinh_cu_tru
FOR EACH ROW EXECUTE FUNCTION fn_b15_kiem_tra_dot();

CREATE OR REPLACE FUNCTION fn_b15_kiem_tra_cha()
RETURNS trigger LANGUAGE plpgsql AS $fn$
BEGIN
    IF TG_TABLE_NAME = 'cu_dan' THEN
        IF EXISTS (
            SELECT 1 FROM qua_trinh_cu_tru
            WHERE ma_cu_dan = NEW.ma_cu_dan
              AND ngay_bat_dau < NEW.ngay_sinh
        ) THEN
            RAISE EXCEPTION 'B15: sửa ngày sinh mâu thuẫn lịch sử cư trú'
                USING ERRCODE = '23514';
        END IF;
    ELSIF TG_TABLE_NAME = 'ho_cu_tru' THEN
        IF EXISTS (
            SELECT 1 FROM qua_trinh_cu_tru
            WHERE ma_ho = NEW.ma_ho
              AND ngay_bat_dau < NEW.ngay_lap
        ) THEN
            RAISE EXCEPTION 'B15: sửa ngày lập hộ mâu thuẫn lịch sử cư trú'
                USING ERRCODE = '23514';
        END IF;
    END IF;
    RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS trg_b15_ngay_sinh ON cu_dan;
CREATE TRIGGER trg_b15_ngay_sinh
BEFORE UPDATE OF ngay_sinh ON cu_dan
FOR EACH ROW EXECUTE FUNCTION fn_b15_kiem_tra_cha();

DROP TRIGGER IF EXISTS trg_b15_ngay_lap_ho ON ho_cu_tru;
CREATE TRIGGER trg_b15_ngay_lap_ho
BEFORE UPDATE OF ngay_lap ON ho_cu_tru
FOR EACH ROW EXECUTE FUNCTION fn_b15_kiem_tra_cha();


COMMIT;

-- Mẫu sử dụng (không tự chạy):
-- BEGIN;
-- SELECT * FROM fn_chuyen_noi_bo(1, 2, 'THUONG_TRU', DATE '2026-11-20', 1);
-- COMMIT;
-- Nếu bất kỳ bước nào lỗi, ROLLBACK toàn bộ giao dịch.
