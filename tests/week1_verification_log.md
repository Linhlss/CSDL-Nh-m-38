# BIÊN BẢN TỰ KIỂM TRA BỘ BÀN GIAO TV1 — 11/11/2026

**Lệnh đã chạy:** `python3 scripts/verify_week1.py --record` từ thư mục gốc.  
**Python thực tế:** 3.13.5. **Hệ điều hành:** Darwin 25.0.0.  
**Phạm vi:** kiểm tra tệp và đối chiếu cấu trúc/tài liệu, không kết nối PostgreSQL.

| Kiểm tra | Kết quả | Bằng chứng / phạm vi |
|---|---|---|
| Required artifacts | PASS | 20 required artifacts exist and are nonempty |
| DDL contract | PASS | 7 tables / 35 columns / 7 PK / 7 FK / 3 UNIQUE / 6 CHECK / 5 indexes |
| Data dictionary | PASS | 35 dictionary rows match DDL names, types, NULL, PK/FK, inline UNIQUE and defaults |
| Editable diagrams | PASS | ERD: 7 entities, 35 attributes, 7 FK roles; function tree: 1 root + 6 groups + 14 leaves |
| PNG exports | PASS | 2 valid 2300×1626 PNGs, A4 landscape proportions, all PNG chunk CRCs valid |
| Question/rule/case coverage | PASS | 10 RA + 10 SQL design mappings; 30 design cases; 18 business rules; 10 review notes |
| Report and task handoff | PASS | Chapters 1–3 filled; all 20 TV1 tasks traced; peer-review and DB-test limits explicit |
| Local file links | PASS | 40 local Markdown file links resolve (anchors and external URLs are not network-tested) |
| SQL compatibility | PASS | Executable SQL unchanged from GitHub main d20b394; only comments differ |
| Utility syntax | PASS | Python utility sources parse successfully; no cache files written |

## Kiểm tra trực quan

Đã mở và xem cả hai ảnh PNG sau khi dựng: tên/thuộc tính đọc được, không cắt bảng hoặc chữ; hai vai trò cũ/mới tách riêng; cây chức năng đủ ba cấp. PNG là 2300×1626, tỷ lệ A4 ngang. SVG và drawio được kiểm XML; việc xem ảnh không thay việc TV2/TV3 review nội dung.

## Kiểm tra tương thích

`week1_sql_compatibility.json` lưu URL phiên bản gốc và SHA-256 SQL chuẩn hóa. Đã đọc bản GitHub tại d20b394, bỏ chú thích dòng và gộp khoảng trắng để so với local; không thay đổi câu lệnh tạo bảng/chỉ mục.

## Những điều chưa được xác nhận

- Chưa chạy DDL hoặc S01–S21 trên PostgreSQL. psql không có trên PATH; Docker daemon không hoạt động khi kiểm tra môi trường.
- Chưa triển khai cơ chế tuần 2 trong constraints/seed/query/security. Ca D01–D30 là đối chiếu thiết kế với đáp án kỳ vọng, không là kết quả DB PASS.
- Chưa có review/xác nhận TV2/TV3 hoặc Gate 1 PASS. Phân tích chuẩn hóa công bố điểm dư thừa ngày sự kiện và phần cần chốt tuần 2.
- Biên bản này chỉ kiểm tra tệp; commit và trạng thái phát hành xem lịch sử main trên GitHub. Chưa gửi review hoặc merge PR của TV3.

## Kiểm tra lại

Nhận bản mới bằng `git pull --ff-only origin main` trên nhánh main, rồi chạy `python3 scripts/verify_week1.py`. Lệnh kiểm tra chỉ đọc, gồm đối chiếu SHA-256 của các tệp trong repository. Sau khi sửa nội dung, review rồi chạy lại --record để tái tạo biên bản và manifest trước commit; không chỉnh log thành PASS bằng tay.
