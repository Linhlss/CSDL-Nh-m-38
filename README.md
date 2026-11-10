# BTL Cơ sở dữ liệu — Đề tài số 17

**Tên đề tài:** Xây dựng cơ sở dữ liệu quản lý cư dân và biến động cư trú tại một phường (mô phỏng).  
**Hạn nộp:** Thứ Sáu 27/11/2026, tiết 3.  
**Nhóm:** [STT nhóm] – [Mã lớp].  
**Thành viên:** TV1 [Họ tên – MSSV], TV2 [...], TV3 [...].

## Bắt đầu từ đâu?

1. **Đọc `docs/01_de_cuong.md` trước** — tài liệu đầy đủ ~17 mục, gồm mô hình, nhiệm vụ, lịch tuần và checklist nghiệm thu.
2. **10–15/11:** Chốt nghiệp vụ, ERD và thiết kế bảng (TV1 chính, TV2/TV3 review).
3. **16–22/11:** Dùng `sql/01_schema.sql` làm **bản nháp DDL**, chỉ chốt sau khi cả nhóm review; điền seed, constraints, queries và security theo yêu cầu.
4. **23–26/11:** Kiểm thử end-to-end, điền báo cáo, kiểm tra hình thức và nộp.

## File có sẵn và file chưa hoàn thành

- `docs/01_de_cuong.md`: **đề cương và kế hoạch chi tiết đã viết**.
- `docs/02_bao_cao_suon.md`: **mục lục/chỗ trống**, chưa phải báo cáo nộp cô.
- `docs/06_phan_cong_tien_do.md`: **bảng theo dõi cá nhân và mốc tuần**.
- `sql/01_schema.sql`: **DDL dự thảo có thể dùng làm điểm bắt đầu**, chưa thay thế review nghiệp vụ và kiểm thử.
- `sql/02_constraints.sql`: TODO quy tắc chồng lấn/nghiệp vụ xuyên bảng.
- `sql/03_seed.sql`: TODO seed dữ liệu mô phỏng.
- `sql/04_queries.sql`: 10 slot SQL TODO.
- `sql/05_security.sql`: 2 slot demo bảo mật TODO.
- `sql/06_validation.sql`: vài mẫu kiểm tra + TODO.
- `tests/test_scenarios.md`: checklist tình huống cần có.

**Các thư mục trống** (`evidence`, `diagrams`, `report`, `generated`) được giữ bằng `.gitkeep`; cần điền sản phẩm thực tế. Gói này chỉ là **bộ khung khởi tạo**, không tuyên bố hoàn tất đồ án.

## Quy tắc nhóm

- Mỗi đầu việc một owner, một reviewer. Một tệp `FINAL` duy nhất.
- Không dùng thông tin công dân thật. Dataset mô phỏng 100%.
- Ghi câu lệnh và kết quả đã chạy thực tế; không bịa ảnh minh chứng.
- Không cam kết mức điểm cụ thể; ưu tiên đúng 6 yêu cầu bắt buộc của cô.
