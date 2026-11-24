# Biên dịch báo cáo BTL Cơ sở dữ liệu — Nhóm 38

Mở `main.tex` và biên dịch bằng **pdfLaTeX**. Dự án giữ nguyên lớp `article`, bộ font tiếng Việt, lề, header/footer và trang bìa của mẫu LaTeX cũ.

Với MacTeX/TeX Live, chạy trong thư mục này:

```bash
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
```

Lệnh tạo `main.pdf` và tự chạy đủ số lượt để cập nhật mục lục, danh sách hình và trích dẫn. Trên Overleaf, tải cả thư mục, chọn `main.tex` làm Main document và Compiler là pdfLaTeX.

## Cấu trúc

| Tệp | Nội dung |
|---|---|
| `00_bia.tex` | Trang bìa: đề tài 17, mã lớp 174356, nhóm 38, GVHD, danh sách sinh viên |
| `00_loicamon.tex`, `00_viettat.tex`, `loimodau.tex` | Lời cảm ơn, danh mục viết tắt, lời mở đầu |
| `chuong1.tex` … `chuong6.tex` | Sáu chương theo yêu cầu bài tập lớn |
| `ketluan.tex` | Kết luận (mục không đánh số, sau Chương 6, trước Tài liệu tham khảo) |
| `tailieuthamkhao.tex` | Tài liệu tham khảo |
| `phuluc.tex` | Phụ lục A, sau Tài liệu tham khảo: mã nguồn trigger và hàm B08, B09 (hai chiều), B10, B11, B14, B15, chép nguyên văn từ `sql/02_constraints.sql`. Sửa tệp SQL thì cập nhật lại phụ lục |
| `phancong.tex` | Trang cuối: phân công công việc, xếp loại đóng góp, chữ ký |
| `setuppackages.tex` | Cấu hình gói của mẫu. Các chỗ đã đổi: chữ header thành Cơ sở dữ liệu / Nhóm 38; thụt đầu dòng 1 cm cho mọi đoạn văn (gói `indentfirst`); chú thích mã nguồn ghi “Đoạn mã” thay cho “Listing”. Trang bìa tự tắt thụt đầu dòng trong `00_bia.tex` |
| `sqllisting.tex` | Kiểu hiển thị mã SQL có tiếng Việt, được `setuppackages.tex` nạp vào |
| `image/` | `hust.png` (logo bìa), `erd_trang_11_vector_crop.pdf` (ERD vector đang dùng, cắt lề trắng từ `erd_trang_11_vector.pdf` bằng `pdfcrop --margins 4`), `phan_ra_chuc_nang.png` (sơ đồ phân rã chức năng); `erd.png`, `erd_trang_11_vector.pdf/.svg` là bản gốc giữ lại |

Các con số kết quả trong Chương 3–6 được tái lập bằng các script `tests/report_*.sql` của repository (xem `BAO_CAO_KET_QUA_SUA_LATEX.md` ở thư mục gốc dự án). Bộ câu hỏi trong PDF khác bộ QRA/QSQL trong hồ sơ kỹ thuật; dùng đúng các script `report_*` để đối chiếu.

## Quy ước của bản báo cáo hiện hành

- Không ghi ngày truy cập trong tài liệu tham khảo và không kể lịch sử từng lần chạy trong phần nội dung.
- Các truy vấn “đang cư trú” và VIEW minh họa dùng `CURRENT_DATE` của phiên PostgreSQL; không dùng ngày cố định hoặc biến ngày do người đọc phải nhập.
- Đại số quan hệ dùng đầu vào `Q_ht` (đợt hiện tại) và `Q_bd` (đợt đã bắt đầu), định nghĩa ngay trong đại số quan hệ từ QT bằng phép chọn (có điều kiện `ngay_ket_thuc IS NULL`) rồi chiếu năm cột NOT NULL.
- Số dòng trong bảng kết quả là minh họa tại thời điểm thực nghiệm; truy vấn phụ thuộc ngày được kiểm chứng bằng oracle cùng ngày hệ thống. `tests/report_current_date.sql` kiểm tra bảy ca biên bằng đúng các truy vấn trong báo cáo, gồm đợt hôm nay/tương lai, tuổi và đếm người phân biệt; fixture được ROLLBACK.
- Log của bản hiện hành: `tests/report_current_date_log.txt`. Các log có ngày trong tên tệp bên dưới là hồ sơ lịch sử, không dùng để khẳng định kết quả của bản truy vấn hiện tại.

## Lịch sử sửa nội dung

- Sửa các diễn đạt tuyệt đối về lịch sử, bảo mật, identity và chỉ mục; thống nhất cách xưng “nhóm” và nêu rõ phạm vi mô phỏng.
- Thêm mục 3.4 về khóa ứng viên, phụ thuộc hàm, 1NF–3NF và dư thừa có kiểm soát ở `ngay_bien_dong`. Các mục ràng buộc và DDL lần lượt chuyển thành 3.5 và 3.6.
- Đầu vào `Q_d` chỉ giữ năm cột NOT NULL; đã chạy lại trên seed636 dựng mới bằng PostgreSQL 17.12. Log `tests/report_ra_20261122_log.txt` có hash script và kết quả; lần này không chạy lại kiểm thử bảo mật.
- Giữ nguyên toàn bộ tài sản ảnh ERD và lệnh chèn ảnh. Mục lục dùng cỡ 12 pt để nằm trọn một trang.
- Trang phân công ghi rõ xếp loại/chữ ký đang chờ nhóm tự điền và xác nhận; không tự đánh giá đóng góp hoặc tạo chữ ký.
- Viết lại văn xuôi Lời mở đầu, Chương 1–6 và Kết luận cho dễ đọc: bỏ chữ hoa giữa câu (tên thực thể, liên kết viết thường; chỉ giữ hoa cho tên riêng và tham chiếu có số như “Chương 5”, “Hình 1”), thay từ quá học thuật bằng từ thông dụng, thống nhất “khóa dự tuyển”. Không đổi số liệu, mã SQL, công thức hay nhãn tham chiếu.

## Lưu ý khi sửa

- Mã SQL trong báo cáo có ký tự tiếng Việt. Nếu thêm khối mã có chữ tiếng Việt mới mà chưa có trong danh sách `literate` của `sqllisting.tex`, hãy bổ sung ký tự đó theo cùng cách (định nghĩa lấy từ `t5enc.dfu`).
- Cột xếp loại và chữ ký ở trang cuối để trống cho nhóm điền tay sau khi in.
