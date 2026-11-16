# BTL Cơ sở dữ liệu — Đề tài 17

Xây dựng CSDL quản lý cư dân và biến động cư trú tại một phường mô phỏng.

**Nhóm 38 — lớp 174356 — ThS. Nguyễn Thị Thanh Huyền.** Hạn nộp theo kế hoạch nhóm: 27/11/2026, tiết 3.

| Thành viên | Họ tên | MSSV | Trách nhiệm |
|---|---|---|---|
| TV1 | Dương Ngọc Ninh | 20237469 | Nghiệp vụ, thiết kế, ràng buộc, tích hợp |
| TV2 | Trần Tuấn Ngọc | 20227064 | Dữ liệu, SQL, kiểm thử |
| TV3 | Trần Bùi Tùng Linh | 20227057 | Đại số quan hệ, bảo mật, review |

## Hiện trạng và việc tiếp theo

**Kỹ thuật tuần 1 đã hoàn thiện.** Repo có schema 7 bảng/35 cột, fixture29, seed636, 10 SQL, 10 RA và B1/B2; nháp Chương 4/6 đã merge. Log tuần 1 đạt 96/96 (95 kiểm tra chức năng + 1 tái hiện B15 cũ). **Gate 1 PASS, thiết kế v1** theo xác nhận chủ repo tiếp nhận 16/11/2026: cả ba đã đồng ý thiết kế và đã đối chiếu yêu cầu/thời hạn/quy cách in. **52/53 mục tuần 1 hoàn thành, 1 mục môi trường cá nhân TV2 hoãn sang W2-T2-01**; TV2 dùng Windows, phiên bản PostgreSQL/công cụ/kết quả kết nối chưa có. [Nguồn xác nhận và phần hoãn](meetings/decision_log.md#gate1).

**Tuần 2 — 16–22/11:**

- **TV1:** triển khai ràng buộc/transaction trong `sql/02_constraints.sql` đang TODO; kiểm thử, chốt chuẩn hóa và Chương 1–3.
- **TV2:** kiểm thử dữ liệu/10 SQL cùng ràng buộc mới, ghi expected/actual; viết Chương 3.5 và Chương 5.
- **TV3:** bổ sung kết quả QRA02/03/06/08 trên seed636, hoàn thiện đối soát và Chương 4/6; chuẩn bị ảnh B1/B2 ngày 24/11.

[Checklist và lịch phối hợp](docs/03_CHECKLIST_DU_AN.md#tuan-2-hien-hanh) giữ đầy đủ 142 mã việc và reviewer. Gate 2 ngày 22/11 chốt nội dung kỹ thuật; tuần 3 (23–27/11) dành cho rebuild cuối, minh chứng, báo cáo, in/nộp.

## Đọc và làm việc

| Nội dung | Nguồn chính |
|---|---|
| Yêu cầu và kế hoạch tổng thể | [Đề cương](docs/01_de_cuong.md) |
| Quy trình, thuật ngữ, B01–B18 | [Đặc tả nghiệp vụ](docs/03_dac_ta_nghiep_vu.md) |
| Cột/khóa, chuẩn hóa, cơ chế ràng buộc | [Từ điển dữ liệu](docs/04_data_dictionary_va_chuan_hoa.md) |
| Dữ liệu, nạp/reset, 10 SQL và test | [Hồ sơ dữ liệu/SQL](docs/05_ke_hoach_du_lieu_va_sql.md), [cách nạp](data/README.md) |
| 10 RA, SQL kiểm chứng và B1/B2 | [Đại số quan hệ](docs/06a_dai_so_quan_he.md), [bảo mật](docs/06b_bao_mat.md) |
| Kết quả, quyết định và xác nhận | [Nhật ký chung](meetings/decision_log.md), [ma trận câu hỏi](docs/07_ma_tran_truy_van_va_review.md) |
| Báo cáo đang biên tập | [Bản nháp tích hợp](docs/02_bao_cao_suon.md) |

Nhận bản mới trên nhánh main từ [repo GitHub](https://github.com/Linhlss/CSDL-Nh-m-38), rồi kiểm tra tệp:

```sh
git pull --ff-only origin main
python3 scripts/verify_week1.py
```

Lệnh Python chỉ dùng thư viện chuẩn: kiểm tra tài liệu/sơ đồ, liên kết, mã việc, hash đầu vào runtime đã ghi và manifest; không chạy PostgreSQL. Khi sửa nội dung, review rồi dùng `python3 scripts/verify_week1.py --record` để cập nhật [biên bản](tests/week1_verification_log.md) và [manifest](tests/week1_manifest.json) trước commit.

Log DB và lệnh tái lập nằm ở [môi trường kiểm chứng](tests/week1_environment.md) và nhật ký chung. Dựng lại ảnh sơ đồ bằng `python3 scripts/render_week1_diagrams.py` (Python + Pillow); nguồn chỉnh sửa ở `diagrams/`.

Dữ liệu giả lập 100%; không commit mật khẩu. Mỗi việc có owner/reviewer; thay đổi cấu trúc cần ghi ảnh hưởng dữ liệu, truy vấn, sơ đồ và báo cáo vào nhật ký. Chỉ ghi kết quả đã chạy, không xác nhận thay thành viên khác.
