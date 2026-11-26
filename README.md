# BTL Cơ sở dữ liệu — Đề tài 17

Xây dựng CSDL quản lý cư dân và biến động cư trú tại một phường.

**Nhóm 38 — lớp 174356 — ThS. Nguyễn Thị Thanh Huyền.** Hạn nộp theo kế hoạch nhóm: 27/11/2026, tiết 3.

| Thành viên | Họ tên | MSSV | Trách nhiệm |
|---|---|---|---|
| TV1 | Trần Bùi Tùng Linh | 20227057 | Nghiệp vụ, thiết kế, ràng buộc, tích hợp |
| TV2 | Trần Tuấn Ngọc | 20227064 | Dữ liệu, SQL, kiểm thử |
| TV3 | Dương Ngọc Ninh | 20237469 | Đại số quan hệ, bảo mật, review |

> **Đính chính số thứ tự thành viên (19/11/2026):** TV1 = Trần Bùi Tùng Linh (20227057), TV2 = Trần Tuấn Ngọc (20227064), TV3 = Dương Ngọc Ninh (20237469). Đính chính này không sửa tác giả commit/PR hoặc tự gán lại đóng góp lịch sử; bảng phân công trang cuối phải phản ánh công việc thực tế.

## Báo cáo và slide hiện hành

- [Bản PDF để rà soát và in](Báo_cáo_CSDL_nhóm_38/main.pdf), [nguồn LaTeX](Báo_cáo_CSDL_nhóm_38/main.tex) và [cách biên dịch](Báo_cáo_CSDL_nhóm_38/README_COMPILE.md).
- [PowerPoint thuyết trình](presentation/CSDL_Nhom38_HUST_ThuyetTrinh.pptx), [PDF dự phòng](presentation/CSDL_Nhom38_HUST_ThuyetTrinh.pdf) và [kịch bản 20 phút](presentation/SPEAKER_NOTES.md).
- Chương 5 và phần SQL trên slide dùng [QSQL01–QSQL10](sql/04_queries.sql), cùng các câu TV2 thực thi trong pgAdmin. Mười ảnh nằm trong phụ lục báo cáo. [QSQL11–QSQL13](sql/07_queries_bo_sung.sql) nằm ở Phụ lục A.8. Chương 4, QSQL11–12 và VIEW xét hiệu lực theo ngày hệ thống. Xem [kết quả đối chiếu lại](tests/final_test_log.md#qsql-report-evidence) trên CSDL dựng mới.
- Chương 4 giữ bộ đại số quan hệ trong báo cáo. Tái lập bằng [script RA](tests/report_ra_01_10.sql), [thử ràng buộc](tests/report_bang_thu_rang_buoc.sql) và [ví dụ bảo mật](tests/report_security_ch6.sql). [Kết quả rà soát bản nộp](tests/final_test_log.md#report-submission-audit) ghi kết quả ở phiên bản hiện hành. Các log ngày 22/11 lưu kết quả của bản trước.
- Chương 2–3 có bảng ràng buộc tham gia, chỉ mục và [ví dụ DML](tests/report_dml_minh_hoa_log.txt). Hai ràng buộc UNIQUE chặn trùng đợt ngay khi ghi theo X07. E1 vẫn đối chiếu lại khi kiểm tra dữ liệu. [Nhật ký thiết kế](meetings/decision_log.md#review-x07)

## Hiện trạng và việc tiếp theo

**Kỹ thuật tuần 1 đã hoàn thiện.** Repo có schema 7 bảng/35 cột, fixture29, seed636, 10 SQL, 10 RA và B1/B2; nháp Chương 4/6 đã merge. Log tuần 1 đạt 96/96 (95 kiểm tra chức năng + 1 tái hiện B15 cũ). **Gate 1 PASS, thiết kế v1** theo xác nhận chủ repo tiếp nhận 16/11/2026: cả ba đã đồng ý thiết kế và đã đối chiếu yêu cầu/thời hạn/quy cách in. **52/53 mục tuần 1 hoàn thành, 1 mục môi trường cá nhân TV2 hoãn sang W2-T2-01**; TV2 dùng Windows, phiên bản PostgreSQL/công cụ/kết quả kết nối chưa có. [Nguồn xác nhận và phần hoãn](meetings/decision_log.md#gate1).

**Tuần 2 — 16–22/11:**

- **TV1:** đã triển khai B06/B08–B11/B14 và bổ sung B15/E1 trong nhánh tích hợp Gate 2; kiểm thử từ DB sạch, chốt báo cáo, bàn giao review TV2/TV3.
- **TV2:** kiểm thử dữ liệu/10 SQL cùng ràng buộc mới, ghi expected/actual; viết Chương 3.5 và Chương 5.
- **TV3:** đã có QRA07 bằng phép chia, kết quả seed636 của QRA02/03/06/08, kiểm thử đăng nhập thật và sửa X02. Nội dung PR #5 đã vào nhánh tích hợp; PR #5 đã đóng, không merge. PR #8 đã được gộp (fast-forward) vào nhánh TV1. Việc còn lại: review bản tích hợp, chốt Chương 4/6, chụp B1/B2 ngày 24/11.

[Checklist và lịch phối hợp](docs/03_CHECKLIST_DU_AN.md#tuan-2-hien-hanh) giữ đầy đủ 142 mã việc và reviewer. **Gate 2 PASS** theo xác nhận nhóm do TV1 báo lại ngày 20/11. Báo cáo và slide hiện hành đã đưa vào bằng chứng SQL và bảo mật. Trang cuối báo cáo đã ghi công việc và xếp loại đóng góp. Từng thành viên ký trên bản in trước khi nộp. [Biên bản chốt Gate 2](meetings/decision_log.md#gate2).

## Kiểm thử ràng buộc nâng cao (TV1 — tuần 2)

B06 (chống chồng lấn), B08–B09 (sự kiện và ngày), B10 (ba hàm chuyển nguyên tử), B11 (địa chỉ lịch sử), B14 (tài khoản hoạt động), B15 (ngày và tên) và X07/E1 (UNIQUE và đối chiếu dữ liệu) được triển khai tại `sql/02_constraints.sql` trên nhánh tích hợp Gate 2.

Dựng lại trên **PostgreSQL ≥15** với quyền bật extension `btree_gist`:

```sh
psql -v ON_ERROR_STOP=1 -f sql/01_schema.sql
psql -v ON_ERROR_STOP=1 -f sql/02_constraints.sql
psql -v ON_ERROR_STOP=1 -f sql/03_seed.sql
psql -v ON_ERROR_STOP=1 -f tests/constraints_week2.sql
psql -v ON_ERROR_STOP=1 -f sql/06_validation.sql
```

Tệp `tests/constraints_week2.sql` chạy ca dương/âm trong transaction và `ROLLBACK` để giữ seed. Kết quả đã kiểm chứng tại [GitHub Actions 19/11/2026](https://github.com/Linhlss/CSDL-Nh-m-38/actions/runs/44533515990); nhật ký ở [tests/week2_constraints_execution_log.md](tests/week2_constraints_execution_log.md). Log này **chưa phải** biên bản nghiệm thu cuối Gate 3/4.

Xem **[Hướng dẫn dựng CSDL thống nhất](docs/08_huong_dan_dung_csdl.md)** để chạy hai DB riêng (seed636 và fixture RA), hai demo bảo mật và bộ đối soát tích hợp.

## Hồ sơ TV1 Gate 2 — nhánh ứng viên

- [Dựng từ CSDL trắng](docs/08_huong_dan_dung_csdl.md), chia DB seed636 và fixture RA.
- [Hồ sơ TV1, kết quả CI và vấn đề chờ review](docs/09_ho_so_tv1_gate2.md).
- **[Hồ sơ bàn giao TV1 → TV2, TV3 (20/11/2026)](docs/10_ban_giao_tv2_tv3.md):** bản tích hợp đủ sáu chương (gồm Chương 5 của TV2 từ PR #6), việc đã xong, việc còn lại theo người, hạn và reviewer.
- [Kiểm thử PostgreSQL 17: run 44654667107](https://github.com/Linhlss/CSDL-Nh-m-38/actions/runs/44654667107): 6 unit parser, 14/14 kiểm tra tệp, 40 PASS ràng buộc, 3 PASS validation, 71 đối soát tích hợp; giữ seed636.
- [Kiểm thử từ DB trắng ngày 20/11 sau tích hợp PR #8](tests/week2_tv1_integration_log.md): PostgreSQL 17.12 có đăng nhập scram. Kết quả: catalog đạt 15/15, B12 K01–K05 đạt, reader đạt 12/12, report đạt 10/10, S01–S16 đạt 18/18.
- PR #5 đã đóng không merge riêng; PR #8 (TV3) và nội dung PR #6 (TV2) đã được tích hợp vào PR #7 (TV1). **PR #7 là đầu mối hợp nhất về `main` theo biên bản Gate 2**; trạng thái merge cuối xem [PR #7](https://github.com/Linhlss/CSDL-Nh-m-38/pull/7). Kết quả CI không thay ảnh hay chữ ký Gate 3/4.

## Đọc và làm việc

| Nội dung | Nguồn chính |
|---|---|
| Yêu cầu và kế hoạch tổng thể | [Đề cương](docs/01_de_cuong.md) |
| Quy trình, thuật ngữ, B01–B18 | [Đặc tả nghiệp vụ](docs/03_dac_ta_nghiep_vu.md) |
| Cột/khóa, chuẩn hóa, cơ chế ràng buộc | [Từ điển dữ liệu](docs/04_data_dictionary_va_chuan_hoa.md) |
| Dữ liệu, nạp/reset, 10 SQL và test | [Hồ sơ dữ liệu/SQL](docs/05_ke_hoach_du_lieu_va_sql.md), [cách nạp](data/README.md) |
| 10 RA, SQL kiểm chứng và B1/B2 | [Đại số quan hệ](docs/06a_dai_so_quan_he.md), [bảo mật](docs/06b_bao_mat.md) |
| Kết quả, quyết định và xác nhận | [Nhật ký chung](meetings/decision_log.md), [ma trận câu hỏi](docs/07_ma_tran_truy_van_va_review.md) |
| Báo cáo chính để in | [PDF](Báo_cáo_CSDL_nhóm_38/main.pdf), [nguồn và cách biên dịch](Báo_cáo_CSDL_nhóm_38/README_COMPILE.md) |

Nhận bản mới trên nhánh main từ [repo GitHub](https://github.com/Linhlss/CSDL-Nh-m-38), rồi kiểm tra tệp:

```sh
git pull --ff-only origin main
python3 scripts/verify_week1.py
```

Lệnh Python chỉ dùng thư viện chuẩn: kiểm tra tài liệu/sơ đồ, liên kết, mã việc, hash đầu vào runtime đã ghi và manifest; không chạy PostgreSQL. Khi sửa nội dung, review rồi dùng `python3 scripts/verify_week1.py --record` để cập nhật [biên bản](tests/week1_verification_log.md) và [manifest](tests/week1_manifest.json) trước commit.

Log DB và lệnh tái lập nằm ở [môi trường kiểm chứng](tests/week1_environment.md) và nhật ký chung. Dựng lại ảnh sơ đồ bằng `python3 scripts/render_week1_diagrams.py` (Python + Pillow); nguồn chỉnh sửa ở `diagrams/`.

Dữ liệu giả lập 100%; không commit mật khẩu. Mỗi việc có owner/reviewer; thay đổi cấu trúc cần ghi ảnh hưởng dữ liệu, truy vấn, sơ đồ và báo cáo vào nhật ký. Chỉ ghi kết quả đã chạy, không xác nhận thay thành viên khác.
