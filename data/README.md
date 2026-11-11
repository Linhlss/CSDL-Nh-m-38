# Dữ liệu giả lập

**Đầu vào tuần 1 cho TV2:** đọc [bộ bàn giao TV1](../docs/BAN_GIAO_TV1_TUAN_1.md), từ điển đầy đủ và [ma trận câu hỏi](../docs/07_ma_tran_truy_van_va_review.md) trước khi sinh dữ liệu. Ngày chuyển t có đợt cũ kết thúc t−1, đợt mới bắt đầu t; ngày cuối được tính bao gồm. DDL giữ nguyên tên/cột v0, ràng buộc nâng cao còn chờ tuần 2.

- Toàn bộ dữ liệu là mô phỏng 100% và chỉ dùng cho bài tập học thuật.
- Cần bảo đảm S01–S21 trong `../docs/01_de_cuong.md`.
- Sinh theo thứ tự khóa ngoại: tổ → địa chỉ → hộ → cư dân/tài khoản → đợt cư trú → biến động.
- Dùng seed ngẫu nhiên cố định, tạo test fixture có kết quả tính tay.
- Không dùng dữ liệu cá nhân thật; không tạo CCCD giống thật.
- `generated/` dùng lưu CSV kết quả sau khi sinh; hiện chưa có tệp dữ liệu.
