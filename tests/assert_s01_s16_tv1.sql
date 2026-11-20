-- =====================================================================
-- BTL CSDL Đề tài 17 — tests/assert_s01_s16_tv1.sql
-- TV1 · 20/11/2026 · Issue #9 P0-A9. Biến bảng kết quả TEMP `kq` của
-- tests/seed636_s01_s16_tv3.sql (TV3, chỉ in) thành phép khẳng định có
-- mã thoát, KHÔNG sửa kỳ vọng của TV3. Phải chạy CÙNG PHIÊN, ngay sau tệp TV3:
--   psql -X -v ON_ERROR_STOP=1 -d csdl17_seed636 \
--        -f tests/seed636_s01_s16_tv3.sql -f tests/assert_s01_s16_tv1.sql
-- Quy tắc so khớp:
--   * ky_vong = 'chỉ thông tin'     -> ca thông tin (S16b, S16c), không chấm.
--   * ky_vong = '0 sai / có ≥1'     -> thực tế phải là '0 sai / n' với n ≥ 1 (S11, S12).
--   * còn lại                        -> thực tế phải trùng khít kỳ vọng.
-- =====================================================================
\set ON_ERROR_STOP on
DO $a$
DECLARE
    r RECORD; cham INT := 0; dat INT := 0; thong_tin INT := 0; ok BOOLEAN;
BEGIN
    FOR r IN SELECT * FROM kq ORDER BY ca LOOP
        IF r.ky_vong = 'chỉ thông tin' THEN
            thong_tin := thong_tin + 1;
            RAISE NOTICE '[INFO] % | %', r.ca, r.thuc_te;
            CONTINUE;
        END IF;
        cham := cham + 1;
        IF r.ky_vong = '0 sai / có ≥1' THEN
            ok := r.thuc_te ~ '^0 sai / [1-9][0-9]*$';
        ELSE
            ok := r.thuc_te IS NOT DISTINCT FROM r.ky_vong;
        END IF;
        IF ok THEN dat := dat + 1; END IF;
        RAISE NOTICE '[%] % | kỳ vọng % | thực tế %',
            CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END, r.ca, r.ky_vong, r.thuc_te;
    END LOOP;
    RAISE NOTICE 'TONG S01-S16: %/% ca chấm PASS, % ca thông tin', dat, cham, thong_tin;
    IF cham = 0 OR dat <> cham THEN
        RAISE EXCEPTION 'S01-S16: % ca chấm FAIL', cham - dat;
    END IF;
END
$a$;
