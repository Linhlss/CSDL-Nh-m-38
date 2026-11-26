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
| `phuluc.tex` | Phụ lục A, mã nguồn các trigger và hàm B08–B11, B14 và B15 |
| `phuluc_sql.tex` và `image/qsql/` | 10 minh chứng QSQL gốc từ pgAdmin |
| `phuluc_baomat.tex` và `image/security/` | Ảnh bổ trợ bảo mật và 7 ảnh gốc dùng trong Chương 6 hoặc phụ lục |
| `phancong.tex` | Trang cuối: phân công công việc, xếp loại đóng góp, chữ ký |
| `setuppackages.tex` | Cấu hình gói, header, thụt đầu dòng 1 cm và nhãn “Đoạn mã” |
| `sqllisting.tex` | Kiểu hiển thị mã SQL có tiếng Việt, được `setuppackages.tex` nạp vào |
| `image/` | `hust.png` (logo bìa), `erd_trang_11_vector_crop.pdf` (ERD vector đang dùng, cắt lề trắng từ `erd_trang_11_vector.pdf` bằng `pdfcrop --margins 4`), `phan_ra_chuc_nang.png` (sơ đồ phân rã chức năng); `erd.png`, `erd_trang_11_vector.pdf/.svg` là bản gốc giữ lại |

Chương 5 lấy câu lệnh từ [QSQL01–QSQL10](../sql/04_queries.sql). Kết quả đối chiếu lại và liên kết đến mười ảnh xem ở [nhật ký kiểm thử](../tests/final_test_log.md#qsql-report-evidence). Chương 4 dùng bộ [đại số quan hệ của báo cáo](../tests/report_ra_01_10.sql).

## Quy ước của bản báo cáo hiện hành

- QSQL01, 02, 03 và 07 giữ giá trị ngày trong mã để tái lập đúng các ảnh. Đại số quan hệ và VIEW ở Chương 6 dùng `CURRENT_DATE` của phiên PostgreSQL.
- Đại số quan hệ dùng đầu vào `Q_ht` và `Q_bd`, chỉ giữ năm cột NOT NULL sau bước chuẩn bị SQL. Các truy vấn đối chứng của Chương 4 được trình bày độc lập với danh mục QSQL của Chương 5.
- Log `tests/report_current_date_log.txt` ghi kết quả của bản ngày 22/11. Phần kiểm chứng RA và bảo mật vẫn có giá trị trong phạm vi log. Phần SQL ngày 22/11 và bảy ca biên theo ngày hệ thống thuộc bản trước khi đổi Chương 5 sang QSQL.
- Mười ảnh SQL đặt trong phụ lục trước trang phân công. Cắt mép trong LaTeX để ưu tiên câu lệnh và bảng kết quả. Tệp PNG vẫn là ảnh gốc.
- Bốn ảnh đăng nhập độc lập nằm trong Ví dụ 1 và 2 của Chương 6, ba ảnh còn lại nằm trong phụ lục bảo mật. Cả bảy ảnh lấy từ [commit d33ff07 của TV3](https://github.com/Linhlss/CSDL-Nh-m-38/commit/d33ff07ea01d42ea46980b08061dd98bcb88837c).
- Bảng tham gia của các liên kết, chỉ mục, ba ví dụ DML và phụ lục mã nguồn được tiếp nhận từ [PR #13](https://github.com/Linhlss/CSDL-Nh-m-38/pull/13) và đối chiếu với thiết kế E1 hiện hành. [Log DML](../tests/report_dml_minh_hoa_log.txt) ghi kết quả chạy trên PostgreSQL 17.12 và đối chiếu 636 bản ghi trước, sau khi hoàn tác.

## Lịch sử sửa nội dung

- Sửa các diễn đạt tuyệt đối về lịch sử, bảo mật, identity và chỉ mục; thống nhất cách xưng “nhóm” và nêu rõ phạm vi quản lý cư trú tại một phường.
- Thêm mục 3.4 về khóa ứng viên, phụ thuộc hàm, 1NF–3NF và dư thừa có kiểm soát ở `ngay_bien_dong`. Các mục ràng buộc và DDL lần lượt chuyển thành 3.5 và 3.6.
- Đầu vào `Q_d` chỉ giữ năm cột NOT NULL; đã chạy lại trên seed636 dựng mới bằng PostgreSQL 17.12. Log `tests/report_ra_20261122_log.txt` có hash script và kết quả; lần này không chạy lại kiểm thử bảo mật.
- Giữ nguyên toàn bộ tài sản ảnh ERD và lệnh chèn ảnh.

## Lưu ý khi sửa

- Mã SQL trong báo cáo có ký tự tiếng Việt. Nếu thêm khối mã có chữ tiếng Việt mới mà chưa có trong danh sách `literate` của `sqllisting.tex`, hãy bổ sung ký tự đó theo cùng cách (định nghĩa lấy từ `t5enc.dfu`).
- Trang cuối ghi chi tiết công việc, sản phẩm và xếp loại. Từng thành viên điền chữ ký sau khi in.
