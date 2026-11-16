# BTL Cơ sở dữ liệu — Đề tài số 17

**Tên đề tài:** Xây dựng cơ sở dữ liệu quản lý cư dân và biến động cư trú tại một phường mô phỏng.  
**Hạn nộp theo kế hoạch nhóm:** Thứ Sáu 27/11/2026, tiết 3.  
**Nhóm 38 — lớp 174356 — ThS. Nguyễn Thị Thanh Huyền.**

- **TV1:** Dương Ngọc Ninh — 20237469.
- **TV2:** Trần Tuấn Ngọc — 20227064.
- **TV3:** Trần Bùi Tùng Linh — 20227057.

**Bàn giao 16/11/2026:** [Bộ tuần 1 của cả ba thành viên](docs/BAN_GIAO_TUAN_1.md) đã có đầy đủ sản phẩm kỹ thuật, fixture 29, seed 636, 10 SQL và review RA/dữ liệu. PostgreSQL: **96/96** đạt (95 chức năng, 1 tái hiện lỗi cũ). Bảng 53 mã tuần 1 có **46 mục đủ sản phẩm/review kỹ thuật**, 7 mục chờ nguồn hoặc xác nhận cá nhân/nhóm; không tự ký Gate 1 PASS. PR #2 và #3 đã tích hợp vào main.

## Bắt đầu từ bộ bàn giao tuần 1

**Cập nhật 11/11/2026:** Sản phẩm thiết kế TV1 đã hoàn thiện để bàn giao ở phiên bản `v1-candidate`. Gate 1 của cả nhóm còn chờ TV2/TV3 review; chưa hoàn tất toàn bộ đồ án.

**Cập nhật 12/11/2026:** TV1 đã trả lời E1, thêm validation phát hiện trùng sự kiện theo từng vai trò và kiểm tra ngày B09. [Review TV3 chi tiết](docs/REVIEW_TV3_CHI_TIET.md) có kết quả kiểm chứng độc lập PostgreSQL 17.11: 86 kiểm tra chức năng đạt và 3 phép tái hiện lỗi/giới hạn. Fixture sửa ở nhánh `codex/review-tv3`; PR #1 giữ nguyên. Gate 1 chung vẫn chờ xác nhận.

**Cập nhật 13/11/2026:** đã sửa F03 và merge [PR #1](https://github.com/Linhlss/CSDL-Nh-m-38/pull/1) vào main tại [d84571e](https://github.com/Linhlss/CSDL-Nh-m-38/commit/d84571e544b480c9c4ba4a421d5d5435b33faac8). Role có sẵn được kiểm tra trước mọi thay đổi quyền; lỗi thiết lập rollback toàn bộ. Bộ kiểm chứng mới đạt 144 kiểm tra chức năng và 2 phép tái hiện. Gate 1 tiếp tục chờ xác nhận thành viên; kết quả trên seed chính thức chưa được nghiệm thu.

1. Đọc [hướng dẫn bàn giao TV1](docs/BAN_GIAO_TV1_TUAN_1.md) để tiếp tục đúng phần được giao.
2. Dùng [đặc tả nghiệp vụ](docs/03_dac_ta_nghiep_vu.md), [từ điển/chuẩn hóa](docs/04_data_dictionary_va_chuan_hoa.md) và [DDL](sql/01_schema.sql) làm bộ giao diện dữ liệu. SQL giữ cấu trúc v0: 7 bảng, 35 cột.
3. Xem [ERD](diagrams/erd_v1.png), [cây chức năng](diagrams/phan_ra_chuc_nang.png) và [ma trận 20 câu hỏi](docs/07_ma_tran_truy_van_va_review.md). Sơ đồ có nguồn .drawio và bản vector .svg.
4. TV2/TV3 ghi nhận xét vào [hồ sơ quyết định/Gate 1](meetings/decision_log.md), rồi thống nhất phiên bản trước triển khai tuần 2.

## Kiểm tra bộ bàn giao

```sh
python3 scripts/verify_week1.py
```

Lệnh chỉ dùng thư viện chuẩn Python, kiểm tra tệp, cấu trúc DDL và nhất quán tài liệu/sơ đồ. Xem [kết quả tự kiểm tra](tests/week1_verification_log.md). Đây không phải kiểm thử DB. Muốn dựng lại ảnh: Python 3 + Pillow, chạy `python3 scripts/render_week1_diagrams.py`.

## Nhận phần bàn giao qua GitHub

Repository chung: [Linhlss/CSDL-Nh-m-38](https://github.com/Linhlss/CSDL-Nh-m-38). Phần tuần 1 của TV1 được bàn giao trên nhánh `main`. Người 2 cập nhật bản clone của mình khi đang ở nhánh `main`:

```sh
git pull --ff-only origin main
python3 scripts/verify_week1.py
```

Đọc `docs/BAN_GIAO_TV1_TUAN_1.md` rồi tiếp tục phần dữ liệu và SQL. Manifest SHA-256 ở `tests/week1_manifest.json` kiểm tra các tệp nhận từ repository; không bao gồm DB đã dựng sẵn. Sau khi sửa tài liệu/mã trong bộ thiết kế, chạy `python3 scripts/verify_week1.py --record` để cập nhật bằng chứng trước khi commit.

## Tiến độ và phần tiếp theo

- **Tuần 1 (10–15/11, hoàn thiện hồ sơ 16/11):** sản phẩm kỹ thuật đạt; 53 mã có đầy đủ đường dẫn/giới hạn xác nhận. C1 được chốt, B15 đã sửa, môi trường chung và kiểm chứng có log/hash. Xem bàn giao chung cho 7 mục còn chờ nguồn/xác nhận.
- **Tuần 2 (16–22/11):** TV1 thực thi ràng buộc/transaction nâng cao và chốt luận chứng chuẩn hóa; TV2/TV3 tiếp tục nghiệm thu dữ liệu/SQL/RA đã có và phần báo cáo. Script 02 còn TODO theo kế hoạch; seed/10 SQL và bảo mật đã có mã kiểm chứng.
- **Tuần 3 (23–27/11):** rebuild cuối, ảnh, báo cáo, in/nộp. Data đã có; report/evidence cuối và chữ ký vẫn chờ thực hiện.

[Đề cương](docs/01_de_cuong.md) giữ kế hoạch toàn dự án; [checklist](docs/03_CHECKLIST_DU_AN.md) giữ mã việc và trách nhiệm. Khi khác với phần thiết kế khởi tạo trong đề cương, bộ bàn giao v1 là nguồn kỹ thuật hiện hành cho review.

## Quy tắc nhóm

- Mỗi đầu việc có owner và reviewer; không xác nhận thay thành viên khác.
- Dữ liệu giả lập; không dùng thông tin công dân thật hoặc commit mật khẩu.
- Chỉ ghi ảnh/kết quả đã chạy thực tế; tự kiểm tài liệu không thay test PostgreSQL.
- Mọi thay đổi cấu trúc sau khi nhóm duyệt phải ghi ảnh hưởng seed, truy vấn, sơ đồ và báo cáo trong biên bản.
