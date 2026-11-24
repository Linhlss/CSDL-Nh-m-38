# Bộ thuyết trình CSDL Nhóm 38

Mở `CSDL_Nhom38_HUST_ThuyetTrinh.pptx` bằng PowerPoint. Các tiêu đề, đoạn văn, biểu thức, mã SQL, bảng dữ liệu và sơ đồ minh họa do nhóm trình bày có thể chỉnh sửa bằng công cụ thông thường. Cây phân rã chức năng, ERD Chen và lược đồ bảy bảng dùng trực tiếp ảnh nguồn nhúng. Thay hình qua **Picture Format → Change Picture** nếu nhóm cập nhật tài sản nguồn. Chế độ **View → Slide Master** dùng để xem các bố cục HUST gốc.

Trong **View → Notes** hoặc **Presenter View**, các trang trình bày có người nói, thời lượng, lời nói và nguồn. Bắt đầu tính 20 phút từ bìa đề tài, ở trang 3 của tệp. Ba trang phân phần HUST ở trang 4, 13 và 19. Linh nói từ 00:00–07:40, Ngọc từ 07:40–12:35, Ninh từ 12:35–20:00. A01–A11 dùng khi hỏi đáp. PDF có 36 trang và có thể dùng để trình chiếu khi máy thiếu font. PowerPoint dùng Lato cho phần nội dung, Arial cho ký hiệu công thức và Courier New cho mã SQL.

## Tái tạo bản sinh tự động

`story.mjs` chứa kịch bản, timeline và danh mục. `build.mjs` tạo các đối tượng PowerPoint bằng Artifact Tool. `apply_template.py` chuyển các đối tượng và notes vào package HUST, giữ nguyên master, layout, theme và hình gốc. Các bảng SQL lấy từ log kiểm chứng trong repo. Hai truy vấn đầy đủ lấy nguyên văn từ LaTeX, với ngắt dòng để trình chiếu.

Cần runtime Node có `@oai/artifact-tool`, Python có `lxml` và `pypdf`, và LibreOffice (`soffice`). Đặt `RUNTIME_NODE`, `RUNTIME_NODE_MODULES` theo runtime của workspace. Có thể đặt `RUNTIME_PYTHON` và `SOFFICE` nếu cần chọn bản riêng.

```sh
bash presentation/rebuild.sh
node presentation/storyboard.mjs
```

Bản build được xuất trong thư mục tạm và in đường dẫn khi kiểm tra xong. Cách này giữ lại các sửa đổi đã thực hiện bằng PowerPoint trên file bàn giao. `STORYBOARD.md` mô tả mạch trình bày. `SOURCE_MAP.md` ghi nguồn từng slide. `SPEAKER_NOTES.md` là bản đọc ngoài. `SLIDE_QA.md` và các ảnh duyệt bố cục ghi kết quả kiểm tra của bản bàn giao.
