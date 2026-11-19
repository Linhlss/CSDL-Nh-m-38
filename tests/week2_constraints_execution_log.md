# Biên bản kiểm thử ràng buộc nâng cao — 19/11/2026

**Phạm vi:** B06, B08, B09, B10, B11 và B14; không thay cho biên bản nghiệm thu Gate 3 hoặc chữ ký thành viên.

- Repo: `Linhlss/CSDL-Nh-m-38`, nhánh `main`.
- Môi trường thực chạy: GitHub Actions, PostgreSQL 17 (service `postgres:17`), `psql`.
- Lần kiểm chứng sau khi sửa trigger: [run 44533515990 — success](https://github.com/Linhlss/CSDL-Nh-m-38/actions/runs/44533515990), commit `80ce1709`.
- Kịch bản: `sql/01_schema.sql` → `sql/02_constraints.sql` → `sql/03_seed.sql` → `tests/constraints_week2.sql` → `sql/06_validation.sql` → `sql/04_queries.sql`.
- Result trên run nêu trên: **20 thông báo PASS của các ca kiểm thử** + **1 PASS kiểm tra dữ liệu**, tất cả bước trong workflow `success`, không có lỗi PostgreSQL ngoài mong đợi.

| Mã kiểm thử | Expected | Actual đã ghi trong log |
|---|---|---|
| B06-positive | Hai đợt liền ngày / khác loại hợp lệ | PASS |
| B06_INSERT_overlap | `23P01` | `23P01` — PASS |
| B06_UPDATE_overlap | `23P01` | `23P01` — PASS |
| B08_different_resident | `23514` | `23514` — PASS |
| B08_same_household | `23514` | `23514` — PASS |
| B09_incorrect_new_start | `23514` | `23514` — PASS |
| B09_incorrect_old_end | `23514` | `23514` — PASS |
| B14_locked_writer_insert | `23514` | `23514` — PASS |
| B08/B09-positive | Sự kiện chuyển nội bộ hợp lệ | PASS |
| B08_reverse_update_household | `23514` | `23514` — PASS |
| B09_reverse_update_start | `23514` | `23514` — PASS |
| B09_reverse_update_end | `23514` | `23514` — PASS |
| B11_household_address_history | `23514` | `23514` — PASS |
| B11_address_to_history | `23514` | `23514` — PASS |
| B11-positive | Được sửa liên kết chưa có lịch sử | PASS |
| B10_rollback_after_partial_update | `23503` | `23503` — PASS |
| B10-rollback-state | Đợt cũ và nhật ký không đổi | PASS |
| B10-positive | Đóng cũ + tạo mới + nhật ký nhất quán | PASS |
| B14_change_writer_to_locked | `23514` | `23514` — PASS |
| B14-historical | Khóa tài khoản không hủy sự kiện cũ | PASS |
| Validation B06/B08/B09 | 0 dữ liệu mâu thuẫn | PASS |

**Giải thích:** `23P01` = exclusion violation; `23514` = check_violation hoặc quy tắc nghiệp vụ chủ động báo SQLSTATE; `23503` = foreign_key_violation. Các lỗi này là **kết quả âm mong đợi**, không phải lỗi của workflow.

### Sau khi bổ sung assertion seed

Tệp `tests/constraints_week2.sql` đã được mở rộng để kiểm tra tổng seed còn **636 bản ghi** sau `ROLLBACK`. Kết quả của assertion mới phải lấy từ lượt CI **sau** commit chứa thay đổi đó; không dùng run `44533515990` để khẳng định một phép thử chưa tồn tại lúc chạy.

### Giới hạn và việc tiếp theo

1. Đây là kiểm thử tuần 2 trên GitHub Actions, không phải kiểm chứng cài PostgreSQL trên Windows của TV2.
2. Chưa có phép thử áp lực đồng thời đa kết nối hoặc chứng minh đầy đủ hành vi phân quyền/chống SQL Injection; không tuyên bố mức production.
3. B15 hiện mới được kiểm ở bộ sinh dữ liệu/đầu vào, chưa chặn mọi trường hợp cập nhật trực tiếp; cần mô tả trong báo cáo.
4. Gate 2 ngày 22/11, Gate 3 chạy từ DB trắng ngày 24/11 và ảnh minh chứng trình bày cuối vẫn phải được nhóm xác nhận riêng.

