-- Fixture tuần 1: 29 bản ghi TỔNG trên 7 bảng, dữ liệu hoàn toàn giả lập.
-- 3 tổ + 3 địa chỉ + 3 hộ + 7 cư dân + 8 đợt + 2 tài khoản + 3 sự kiện.
-- Chạy trên DB đã có 01_schema.sql và 7 bảng rỗng:
-- psql -U postgres -d <db_test> -f tests/week1_fixture.sql
-- Đáp án tính tay đầy đủ: tests/week1_expected.json. Cuối tệp ROLLBACK.
\set ON_ERROR_STOP on
BEGIN;
-- BEGIN_FIXTURE_DATA
INSERT INTO to_dan_pho(ma_to,ten_to) VALUES (1,'Tổ 01'),(2,'Tổ 02'),(3,'Tổ 03');
INSERT INTO dia_chi(ma_dia_chi,ma_to,dia_chi_chuan) VALUES
 (1,1,'Địa chỉ thử 01'),(2,2,'Địa chỉ thử 02'),(3,3,'Địa chỉ thử 03');
INSERT INTO ho_cu_tru(ma_ho,ma_dia_chi,ngay_lap) VALUES
 (1,1,'2019-01-01'),(2,2,'2019-01-01'),(3,1,'2019-01-01');
INSERT INTO cu_dan(ma_cu_dan,ho_ten,ngay_sinh,gioi_tinh) VALUES
 (1,'Nguyễn Văn An','1966-11-20','Nam'),
 (2,'Nguyễn Văn An','1966-11-21','Nam'),
 (3,'Lê Thị Bình','1990-01-01','Nu'),
 (4,'Phạm Văn Chiến','1988-01-01','Nam'),
 (5,'Trần Thị Dung','1985-01-01','Nu'),
 (6,'Đỗ Văn Em','1995-01-01','Nam'),
 (7,'Vũ Thị Hà','1970-01-01','Nu');
INSERT INTO tai_khoan(ma_tai_khoan,ten_dang_nhap,ten_hien_thi,vai_tro) VALUES
 (1,'canbo_fixture','Cán bộ thử','CAN_BO'),(2,'baocao_fixture','Báo cáo thử','THONG_KE');
INSERT INTO qua_trinh_cu_tru(ma_qua_trinh,ma_cu_dan,ma_ho,loai_cu_tru,ngay_bat_dau,ngay_ket_thuc) VALUES
 (1,1,1,'THUONG_TRU','2020-01-01',NULL),
 (2,2,1,'THUONG_TRU','2020-01-01',NULL),
 (3,3,1,'THUONG_TRU','2021-01-01',NULL),
 (4,4,1,'THUONG_TRU','2026-11-01',NULL),
 (5,5,1,'THUONG_TRU','2021-01-01','2026-11-14'),
 (6,5,2,'TAM_TRU','2026-11-15',NULL),
 (7,7,2,'TAM_TRU','2026-01-01','2026-11-05'),
 (8,3,1,'TAM_TRU','2026-10-01',NULL);
INSERT INTO bien_dong_cu_tru(ma_bien_dong,loai_bien_dong,ma_qua_trinh_cu,ma_qua_trinh_moi,ngay_bien_dong,ma_tai_khoan) VALUES
 (1,'CHUYEN_DEN',NULL,4,'2026-11-01',1),
 (2,'CHUYEN_NOI_BO',5,6,'2026-11-15',1),
 (3,'CHUYEN_DI',7,NULL,'2026-11-06',1);
-- END_FIXTURE_DATA
\ir ../sql/04_queries.sql
ROLLBACK;
