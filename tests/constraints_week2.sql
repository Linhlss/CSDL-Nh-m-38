-- Tuan 2 / TV1: kiem thu B06, B08, B09, B10, B11, B14 tren PostgreSQL.
-- Chay SAU 01_schema.sql, 02_constraints.sql, 03_seed.sql.
-- Chay: psql -v ON_ERROR_STOP=1 -f tests/constraints_week2.sql
-- Tat ca fixture dung ID 990xx va duoc ROLLBACK sau khi test.
\set ON_ERROR_STOP on
BEGIN;

CREATE OR REPLACE FUNCTION pg_temp.expect_sqlstate(
    p_test TEXT, p_sql TEXT, p_expected TEXT
) RETURNS void LANGUAGE plpgsql AS $fn$
BEGIN
    EXECUTE p_sql;
    RAISE EXCEPTION 'TEST FAIL [%]: SQL chạy được nhưng phải báo lỗi %', p_test, p_expected
        USING ERRCODE = 'P0001';
EXCEPTION WHEN OTHERS THEN
    IF SQLSTATE <> p_expected THEN
        RAISE EXCEPTION 'TEST FAIL [%]: nhận SQLSTATE %, muốn %; lỗi gốc: %',
            p_test, SQLSTATE, p_expected, SQLERRM;
    END IF;
    RAISE NOTICE '[PASS] % => SQLSTATE % (đúng dự kiến)', p_test, p_expected;
END
$fn$;

-- Chỉ thêm dữ liệu mô phỏng, tránh đụng ID 1..636 của seed.
INSERT INTO to_dan_pho(ma_to, ten_to) VALUES
    (99001, 'TEST Tổ A'), (99002, 'TEST Tổ B');
INSERT INTO dia_chi(ma_dia_chi, ma_to, dia_chi_chuan) VALUES
    (99001,99001,'TEST địa chỉ A'),
    (99002,99002,'TEST địa chỉ B'),
    (99003,99001,'TEST địa chỉ trống');
INSERT INTO ho_cu_tru(ma_ho, ma_dia_chi, ngay_lap) VALUES
    (99001,99001,'2020-01-01'),
    (99002,99002,'2020-01-01'),
    (99003,99001,'2020-01-01');
INSERT INTO cu_dan(ma_cu_dan, ho_ten, ngay_sinh, gioi_tinh) VALUES
    (99001,'TEST Cư dân A','1990-01-01','Nam'),
    (99002,'TEST Cư dân B','1990-01-01','Nu'),
    (99003,'TEST Cư dân C','1990-01-01','Khac');
INSERT INTO tai_khoan(ma_tai_khoan, ten_dang_nhap, ten_hien_thi, vai_tro, trang_thai) VALUES
    (99001,'test_active_99001','TEST cán bộ hoạt động','CAN_BO','HOAT_DONG'),
    (99002,'test_locked_99002','TEST cán bộ khóa','CAN_BO','KHOA');
INSERT INTO qua_trinh_cu_tru(
    ma_qua_trinh,ma_cu_dan,ma_ho,loai_cu_tru,ngay_bat_dau,ngay_ket_thuc
) VALUES
    (99001,99001,99001,'THUONG_TRU','2026-01-01',NULL),
    (99002,99002,99001,'THUONG_TRU','2026-01-01','2026-06-14'),
    (99003,99002,99002,'THUONG_TRU','2026-06-15',NULL),
    (99004,99003,99001,'THUONG_TRU','2026-01-01','2026-01-31'),
    (99005,99003,99002,'THUONG_TRU','2026-02-01',NULL),
    (99006,99003,99001,'TAM_TRU','2026-01-15','2026-02-15'),
    (99007,99001,99002,'TAM_TRU','2026-06-15',NULL),
    (99008,99002,99001,'TAM_TRU','2026-06-15',NULL);

-- D09, D10: khoảng kề nhau cùng loại và hai loại chồng lấn đều hợp lệ.
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM qua_trinh_cu_tru
        WHERE ma_cu_dan = 99003) <> 3 THEN
        RAISE EXCEPTION 'TEST FAIL B06-positive: cần đúng 3 đợt cho C';
    END IF;
    RAISE NOTICE '[PASS] B06-positive: khoảng kề nhau và khác loại hợp lệ';
END
$$;

SELECT pg_temp.expect_sqlstate('B06_INSERT_overlap',
    $sql$INSERT INTO qua_trinh_cu_tru(ma_cu_dan,ma_ho,loai_cu_tru,ngay_bat_dau,ngay_ket_thuc)
         VALUES (99003,99001,'THUONG_TRU','2026-01-31','2026-02-10')$sql$,
    '23P01');
SELECT pg_temp.expect_sqlstate('B06_UPDATE_overlap',
    $sql$UPDATE qua_trinh_cu_tru SET ngay_ket_thuc='2026-02-01'
         WHERE ma_qua_trinh=99004$sql$,
    '23P01');

-- B08 / B09: mọi FK hợp lệ nhưng logic nghiệp vụ phải được kiểm.
SELECT pg_temp.expect_sqlstate('B08_different_resident',
    $sql$INSERT INTO bien_dong_cu_tru(loai_bien_dong,ma_qua_trinh_cu,ma_qua_trinh_moi,ngay_bien_dong,ma_tai_khoan)
         VALUES ('CHUYEN_NOI_BO',99002,99007,'2026-06-15',99001)$sql$,
    '23514');
SELECT pg_temp.expect_sqlstate('B08_same_household',
    $sql$INSERT INTO bien_dong_cu_tru(loai_bien_dong,ma_qua_trinh_cu,ma_qua_trinh_moi,ngay_bien_dong,ma_tai_khoan)
         VALUES ('CHUYEN_NOI_BO',99002,99008,'2026-06-15',99001)$sql$,
    '23514');
SELECT pg_temp.expect_sqlstate('B09_incorrect_new_start',
    $sql$INSERT INTO bien_dong_cu_tru(loai_bien_dong,ma_qua_trinh_cu,ma_qua_trinh_moi,ngay_bien_dong,ma_tai_khoan)
         VALUES ('CHUYEN_DEN',NULL,99003,'2026-06-16',99001)$sql$,
    '23514');
SELECT pg_temp.expect_sqlstate('B09_incorrect_old_end',
    $sql$INSERT INTO bien_dong_cu_tru(loai_bien_dong,ma_qua_trinh_cu,ma_qua_trinh_moi,ngay_bien_dong,ma_tai_khoan)
         VALUES ('CHUYEN_DI',99002,NULL,'2026-06-16',99001)$sql$,
    '23514');
SELECT pg_temp.expect_sqlstate('B14_locked_writer_insert',
    $sql$INSERT INTO bien_dong_cu_tru(loai_bien_dong,ma_qua_trinh_cu,ma_qua_trinh_moi,ngay_bien_dong,ma_tai_khoan)
         VALUES ('CHUYEN_DEN',NULL,99003,'2026-06-15',99002)$sql$,
    '23514');

-- Sự kiện nội bộ hợp lệ B08/B09.
INSERT INTO bien_dong_cu_tru(
    ma_bien_dong,loai_bien_dong,ma_qua_trinh_cu,
    ma_qua_trinh_moi,ngay_bien_dong,ma_tai_khoan
) VALUES (99001,'CHUYEN_NOI_BO',99002,99003,'2026-06-15',99001);
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM bien_dong_cu_tru WHERE ma_bien_dong = 99001)
    THEN RAISE EXCEPTION 'TEST FAIL B08/B09 positive'; END IF;
    RAISE NOTICE '[PASS] B08/B09: sự kiện chuyển nội bộ hợp lệ';
END $$;

-- D22: sau khi ghi sự kiện, các sửa đổi gây sai đều bị từ chối.
SELECT pg_temp.expect_sqlstate('B08_reverse_update_household',
    $sql$UPDATE qua_trinh_cu_tru SET ma_ho=99001
         WHERE ma_qua_trinh=99003$sql$,
    '23514');
SELECT pg_temp.expect_sqlstate('B09_reverse_update_start',
    $sql$UPDATE qua_trinh_cu_tru SET ngay_bat_dau='2026-06-16'
         WHERE ma_qua_trinh=99003$sql$,
    '23514');
SELECT pg_temp.expect_sqlstate('B09_reverse_update_end',
    $sql$UPDATE qua_trinh_cu_tru SET ngay_ket_thuc='2026-06-13'
         WHERE ma_qua_trinh=99002$sql$,
    '23514');

-- B11: liên kết đã có lịch sử không được đổi; bản ghi chưa có lịch sử được.
SELECT pg_temp.expect_sqlstate('B11_household_address_history',
    $sql$UPDATE ho_cu_tru SET ma_dia_chi=99002 WHERE ma_ho=99001$sql$,
    '23514');
SELECT pg_temp.expect_sqlstate('B11_address_to_history',
    $sql$UPDATE dia_chi SET ma_to=99002 WHERE ma_dia_chi=99001$sql$,
    '23514');
UPDATE ho_cu_tru SET ma_dia_chi=99002 WHERE ma_ho=99003;
UPDATE dia_chi SET ma_to=99002 WHERE ma_dia_chi=99003;
DO $$
BEGIN
    IF (SELECT ma_dia_chi FROM ho_cu_tru WHERE ma_ho=99003) <> 99002
       OR (SELECT ma_to FROM dia_chi WHERE ma_dia_chi=99003) <> 99002
    THEN RAISE EXCEPTION 'TEST FAIL B11 unused record'; END IF;
    RAISE NOTICE '[PASS] B11-positive: chỉ liên kết chưa có lịch sử được đổi';
END $$;

-- B10: lỗi FK xuất hiện SAU khi đã đóng đợt cũ trong hàm.
-- expect_sqlstate bắt ngoại lệ trong subtransaction, nên UPDATE đợt phải rollback.
SELECT pg_temp.expect_sqlstate('B10_rollback_after_partial_update',
    $sql$SELECT * FROM fn_chuyen_noi_bo(
         99001, 999999, 'THUONG_TRU', DATE '2026-06-15', 99001)$sql$,
    '23503');
DO $$
BEGIN
    IF (SELECT ngay_ket_thuc FROM qua_trinh_cu_tru WHERE ma_qua_trinh=99001) IS NOT NULL
    THEN RAISE EXCEPTION 'TEST FAIL B10: đợt cũ bị đóng sau lỗi'; END IF;
    IF (SELECT COUNT(*) FROM qua_trinh_cu_tru WHERE ma_cu_dan=99001) <> 2
       OR (SELECT COUNT(*) FROM bien_dong_cu_tru WHERE ma_qua_trinh_cu=99001) <> 0
    THEN RAISE EXCEPTION 'TEST FAIL B10: còn dữ liệu dở dang'; END IF;
    RAISE NOTICE '[PASS] B10: rollback toàn bộ sau lỗi giữa giao dịch';
END $$;

-- Trường hợp B10 thành công: đóng cũ, mở mới và ghi sự kiện trọn vẹn.
SELECT * FROM fn_chuyen_noi_bo(99001,99002,'THUONG_TRU',DATE '2026-06-15',99001);
DO $$
BEGIN
    IF (SELECT ngay_ket_thuc FROM qua_trinh_cu_tru WHERE ma_qua_trinh=99001)
        IS DISTINCT FROM DATE '2026-06-14'
       OR NOT EXISTS (
           SELECT 1 FROM bien_dong_cu_tru b
           JOIN qua_trinh_cu_tru q ON q.ma_qua_trinh=b.ma_qua_trinh_moi
           WHERE b.ma_qua_trinh_cu=99001 AND b.loai_bien_dong='CHUYEN_NOI_BO'
             AND b.ngay_bien_dong='2026-06-15'
             AND q.ma_cu_dan=99001 AND q.ma_ho=99002
             AND q.ngay_bat_dau='2026-06-15')
    THEN RAISE EXCEPTION 'TEST FAIL B10 successful transaction'; END IF;
    RAISE NOTICE '[PASS] B10-positive: 3 bước ghi thành công nhất quán';
END $$;

-- B10 cho chuyển đi và chuyển đến (fn_chuyen_di, fn_chuyen_den, 26/11/2026).
-- Chạy trong savepoint rồi hoàn tác để không ảnh hưởng các phép thử sau.
SAVEPOINT b10_di_den;
-- Lỗi B14 xuất hiện SAU khi đã đóng đợt: cả hàm phải bị hủy.
SELECT pg_temp.expect_sqlstate('B10_chuyen_di_rollback',
    $sql$SELECT fn_chuyen_di(99005, DATE '2026-07-01', 99002)$sql$,
    '23514');
-- Chuyển đến chồng lấn đợt thường trú đang mở của cư dân A: B06 chặn.
SELECT pg_temp.expect_sqlstate('B10_chuyen_den_overlap',
    $sql$SELECT * FROM fn_chuyen_den(99001, 99003, 'THUONG_TRU', DATE '2026-07-01', 99001)$sql$,
    '23P01');
DO $$
BEGIN
    IF (SELECT ngay_ket_thuc FROM qua_trinh_cu_tru WHERE ma_qua_trinh=99005) IS NOT NULL
       OR EXISTS (SELECT 1 FROM bien_dong_cu_tru WHERE ma_qua_trinh_cu=99005)
       OR EXISTS (SELECT 1 FROM qua_trinh_cu_tru WHERE ma_cu_dan=99001 AND ma_ho=99003)
    THEN RAISE EXCEPTION 'TEST FAIL B10 đi/đến: còn dữ liệu dở dang'; END IF;
    RAISE NOTICE '[PASS] B10-di-den: lỗi giữa hàm hủy toàn bộ thay đổi';
END $$;
SELECT fn_chuyen_di(99005, DATE '2026-07-01', 99001);
SELECT * FROM fn_chuyen_den(99003, 99003, 'TAM_TRU', DATE '2026-07-01', 99001);
DO $$
BEGIN
    IF (SELECT ngay_ket_thuc FROM qua_trinh_cu_tru WHERE ma_qua_trinh=99005)
           IS DISTINCT FROM DATE '2026-06-30'
       OR NOT EXISTS (SELECT 1 FROM bien_dong_cu_tru
                      WHERE loai_bien_dong='CHUYEN_DI' AND ma_qua_trinh_cu=99005
                        AND ma_qua_trinh_moi IS NULL AND ngay_bien_dong='2026-07-01')
       OR NOT EXISTS (SELECT 1 FROM bien_dong_cu_tru b
                      JOIN qua_trinh_cu_tru q ON q.ma_qua_trinh=b.ma_qua_trinh_moi
                      WHERE b.loai_bien_dong='CHUYEN_DEN' AND b.ma_qua_trinh_cu IS NULL
                        AND q.ma_cu_dan=99003 AND q.ma_ho=99003
                        AND q.loai_cu_tru='TAM_TRU' AND q.ngay_bat_dau='2026-07-01'
                        AND q.ngay_ket_thuc IS NULL AND b.ngay_bien_dong='2026-07-01')
    THEN RAISE EXCEPTION 'TEST FAIL B10 đi/đến thành công'; END IF;
    RAISE NOTICE '[PASS] B10-di-den-positive: mỗi hàm ghi đợt và biến động nhất quán';
END $$;
ROLLBACK TO SAVEPOINT b10_di_den;


-- X07 (sửa 26/11/2026): UNIQUE uq_bd_dot_cu / uq_bd_dot_moi chặn ngay lúc
-- INSERT việc một đợt xuất hiện nhiều lần trong cùng vai trò (23505).
-- Hai lệnh dưới đều hợp lệ theo B07/B08/B09, chỉ UNIQUE từ chối.
SELECT pg_temp.expect_sqlstate('X07_UNIQUE_dot_cu',
    $sql$INSERT INTO bien_dong_cu_tru(
           loai_bien_dong,ma_qua_trinh_cu,ma_qua_trinh_moi,ngay_bien_dong,ma_tai_khoan
         ) VALUES ('CHUYEN_DI',99002,NULL,'2026-06-15',99001)$sql$,
    '23505');
SELECT pg_temp.expect_sqlstate('X07_UNIQUE_dot_moi',
    $sql$INSERT INTO bien_dong_cu_tru(
           loai_bien_dong,ma_qua_trinh_cu,ma_qua_trinh_moi,ngay_bien_dong,ma_tai_khoan
         ) VALUES ('CHUYEN_DEN',NULL,99003,'2026-06-15',99001)$sql$,
    '23505');
DO $x07$
BEGIN
    IF (SELECT count(*) FROM bien_dong_cu_tru WHERE ma_qua_trinh_cu = 99002) <> 1
       OR (SELECT count(*) FROM bien_dong_cu_tru WHERE ma_qua_trinh_moi = 99003) <> 1 THEN
        RAISE EXCEPTION 'TEST FAIL X07: bản ghi trùng vẫn còn';
    END IF;
    PERFORM fn_assert_e1();
    RAISE NOTICE '[PASS] E1: không có đợt trùng vai trò; fn_assert_e1 không báo lỗi';
END
$x07$;

-- Một đợt là "mới" của chuyển đến và "cũ" của chuyển đi được phép.
INSERT INTO bien_dong_cu_tru(
    loai_bien_dong,ma_qua_trinh_cu,ma_qua_trinh_moi,ngay_bien_dong,ma_tai_khoan
) VALUES ('CHUYEN_DEN',NULL,99002,'2026-01-01',99001);
SELECT fn_assert_e1();
DO $positive$
BEGIN
    RAISE NOTICE '[PASS] E1-positive: đợt được dùng ở hai vai trò khác nhau';
END $positive$;

-- B15: tên/địa chỉ rỗng bị từ chối bởi CHECK.
SELECT pg_temp.expect_sqlstate('B15_whitespace_person',
    $sql$INSERT INTO cu_dan(ho_ten,ngay_sinh,gioi_tinh)
         VALUES ('    ','1990-01-01','Nam')$sql$, '23514');
SELECT pg_temp.expect_sqlstate('B15_whitespace_address',
    $sql$INSERT INTO dia_chi(ma_to,dia_chi_chuan)
         VALUES (99001,'   ')$sql$, '23514');
SELECT pg_temp.expect_sqlstate('B15_whitespace_login',
    $sql$INSERT INTO tai_khoan(ten_dang_nhap,ten_hien_thi,vai_tro)
         VALUES ('   ','A','CAN_BO')$sql$, '23514');

INSERT INTO cu_dan(ma_cu_dan,ho_ten,ngay_sinh,gioi_tinh) VALUES
    (99011,'B15 Sinh muộn','2027-01-01','Nam'),
    (99012,'B15 Hộ lập muộn','1990-01-01','Nam'),
    (99013,'B15 Hợp lệ','1990-01-01','Nam');
INSERT INTO ho_cu_tru(ma_ho,ma_dia_chi,ngay_lap) VALUES
    (99011,99002,'2027-01-01'),
    (99012,99001,'2020-01-01');

SELECT pg_temp.expect_sqlstate('B15_birth_after_start',
    $sql$INSERT INTO qua_trinh_cu_tru(ma_cu_dan,ma_ho,loai_cu_tru,ngay_bat_dau)
         VALUES (99011,99002,'THUONG_TRU','2026-06-01')$sql$, '23514');
SELECT pg_temp.expect_sqlstate('B15_house_open_after_start',
    $sql$INSERT INTO qua_trinh_cu_tru(ma_cu_dan,ma_ho,loai_cu_tru,ngay_bat_dau)
         VALUES (99012,99011,'THUONG_TRU','2026-06-01')$sql$, '23514');
SELECT pg_temp.expect_sqlstate('B15_reverse_birth_change',
    $sql$UPDATE cu_dan SET ngay_sinh='2027-01-01'
         WHERE ma_cu_dan=99003$sql$, '23514');
SELECT pg_temp.expect_sqlstate('B15_reverse_house_open',
    $sql$UPDATE ho_cu_tru SET ngay_lap='2027-01-01'
         WHERE ma_ho=99001$sql$, '23514');

-- Dương tính: cư dân và hộ đã được lập trước ngày cư trú.
INSERT INTO qua_trinh_cu_tru(
    ma_cu_dan,ma_ho,loai_cu_tru,ngay_bat_dau
) VALUES (99013,99012,'TAM_TRU','2026-08-01');
DO $positive$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM qua_trinh_cu_tru
      WHERE ma_cu_dan=99013 AND ma_ho=99012 AND ngay_bat_dau='2026-08-01')
    THEN RAISE EXCEPTION 'B15 positive test failed'; END IF;
    RAISE NOTICE '[PASS] B15-positive: bộ cư trú hợp lệ được ghi';
END $positive$;

-- S17–S19 và các ràng buộc cấu trúc: thử dữ liệu sai, phải bị từ chối.
SELECT pg_temp.expect_sqlstate('S17_foreign_key',
    $sql$INSERT INTO qua_trinh_cu_tru(ma_cu_dan,ma_ho,loai_cu_tru,ngay_bat_dau)
         VALUES (999999,99001,'THUONG_TRU','2026-01-01')$sql$,'23503');
SELECT pg_temp.expect_sqlstate('S18_end_before_start',
    $sql$INSERT INTO qua_trinh_cu_tru(ma_cu_dan,ma_ho,loai_cu_tru,ngay_bat_dau,ngay_ket_thuc)
         VALUES (99003,99002,'THUONG_TRU','2026-03-01','2026-02-28')$sql$,'23514');
SELECT pg_temp.expect_sqlstate('S19_internal_without_episodes',
    $sql$INSERT INTO bien_dong_cu_tru(loai_bien_dong,ngay_bien_dong,ma_tai_khoan)
         VALUES ('CHUYEN_NOI_BO','2026-06-15',99001)$sql$,'23514');
SELECT pg_temp.expect_sqlstate('PK_duplicate_primary_key',
    $sql$INSERT INTO to_dan_pho(ma_to,ten_to) VALUES (99001,'TEST duplicate id')$sql$,'23505');
SELECT pg_temp.expect_sqlstate('UNIQUE_duplicate_business_key',
    $sql$INSERT INTO to_dan_pho(ten_to) VALUES ('TEST Tổ A')$sql$,'23505');
SELECT pg_temp.expect_sqlstate('UNIQUE_duplicate_composite_address',
    $sql$INSERT INTO dia_chi(ma_to,dia_chi_chuan)
         VALUES (99001,'TEST địa chỉ A')$sql$,'23505');
SELECT pg_temp.expect_sqlstate('NOT_NULL_missing_person_name',
    $sql$INSERT INTO cu_dan(ho_ten,ngay_sinh,gioi_tinh)
         VALUES (NULL,'1990-01-01','Nam')$sql$,'23502');
SELECT pg_temp.expect_sqlstate('CHECK_invalid_gender',
    $sql$INSERT INTO cu_dan(ho_ten,ngay_sinh,gioi_tinh)
         VALUES ('TEST Invalid Gender','1990-01-01','Other')$sql$,'23514');

-- B14: khóa tài khoản không làm mất nhật ký trước đó.
UPDATE tai_khoan SET trang_thai='KHOA' WHERE ma_tai_khoan=99001;
UPDATE bien_dong_cu_tru SET ghi_chu='sự kiện lịch sử vẫn được phép ghi chú'
WHERE ma_bien_dong=99001;
SELECT pg_temp.expect_sqlstate('B14_change_writer_to_locked',
    $sql$UPDATE bien_dong_cu_tru SET ma_tai_khoan=99002
         WHERE ma_bien_dong=99001$sql$,
    '23514');
DO $$
BEGIN
    IF (SELECT ghi_chu FROM bien_dong_cu_tru WHERE ma_bien_dong=99001)
       IS DISTINCT FROM 'sự kiện lịch sử vẫn được phép ghi chú'
    THEN RAISE EXCEPTION 'TEST FAIL B14 historical record'; END IF;
    RAISE NOTICE '[PASS] B14: khóa tài khoản không hủy sự kiện đã ghi';
END $$;

-- Không thay đổi seed / dữ liệu gốc. Kết quả PASS nằm ở PostgreSQL NOTICE/log.
ROLLBACK;

-- Xác nhận nguyên trạng 636 bản ghi sau ROLLBACK.
DO $assert_seed$
DECLARE v_total INTEGER;
BEGIN
    SELECT
        (SELECT COUNT(*) FROM to_dan_pho)
      + (SELECT COUNT(*) FROM dia_chi)
      + (SELECT COUNT(*) FROM ho_cu_tru)
      + (SELECT COUNT(*) FROM cu_dan)
      + (SELECT COUNT(*) FROM qua_trinh_cu_tru)
      + (SELECT COUNT(*) FROM bien_dong_cu_tru)
      + (SELECT COUNT(*) FROM tai_khoan)
    INTO v_total;
    IF v_total <> 636 THEN
        RAISE EXCEPTION 'TEST FAIL: sau ROLLBACK tổng seed %, mong đợi 636', v_total;
    END IF;
    IF EXISTS (
        SELECT 1 FROM cu_dan WHERE ma_cu_dan IN (99001,99002,99003)
    ) THEN
        RAISE EXCEPTION 'TEST FAIL: fixture còn trong DB';
    END IF;
    RAISE NOTICE '[PASS] Seed gốc 636 bản ghi được giữ nguyên sau test';
END
$assert_seed$;
