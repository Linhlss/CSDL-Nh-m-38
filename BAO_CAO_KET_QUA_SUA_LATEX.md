# Biên bản sửa và kiểm chứng báo cáo LaTeX — Nhóm 38

## Bộ bàn giao hiện hành

- Báo cáo in: [PDF 71 trang](Báo_cáo_CSDL_nhóm_38/main.pdf). Slide: [PowerPoint 36 trang](presentation/CSDL_Nhom38_HUST_ThuyetTrinh.pptx) và [PDF dự phòng](presentation/CSDL_Nhom38_HUST_ThuyetTrinh.pdf).
- Tiếp nhận từ [PR #13](https://github.com/Linhlss/CSDL-Nh-m-38/pull/13) phần ràng buộc tham gia, thực thể kết hợp, chỉ mục, ba ví dụ DML và phụ lục mã nguồn. Bổ sung A11 về B09 cho phần hỏi đáp.
- Quyết định E1 giữ theo nhật ký, mục 9. Bảng biến động vẫn nêu rõ phần dư thừa có điều kiện. Phần SQL dùng đúng QSQL01–QSQL10; báo cáo chứa mười ảnh của TV2 và bảy ảnh bảo mật của TV3.
- [Kiểm chứng DML](tests/report_dml_minh_hoa_log.txt) trên PostgreSQL 17.12 ghi hai lỗi B09 đúng SQLSTATE 23514 và 636 bản ghi giống hệt trước và sau hoàn tác.
- Trang 71 ghi công việc và sản phẩm của từng thành viên, kèm xếp loại do chủ repo xác nhận. Cột chữ ký để từng thành viên ký tay.
- Bản nháp Markdown đã được dọn khỏi cây tệp hiện hành. Lịch sử PR #10–#13 giữ các bản review và minh chứng đã bàn giao. Báo cáo dùng điều kiện E1 kiểm tra dữ liệu theo quyết định tại mục 9 của [nhật ký nhóm](meetings/decision_log.md).
- Đã rà văn phong, làm rõ cách xét hiệu lực của Chương 4 và Chương 5, đồng bộ tiêu đề câu truy vấn và rút các câu lặp về giới hạn. Kiểm tra lại bố cục A4, ảnh minh chứng, công thức và các đoạn mã sau khi biên dịch.

## Bản lịch sử — truy vấn theo ngày hệ thống

- PDF: `Báo_cáo_CSDL_nhóm_38/main.pdf`, **45 trang**, SHA-256 `f7b641472a903d29a513bc89dc017c79121f918e0b17d45f239b3b2713e2c7d4`.
- Theo yêu cầu chủ repo: bỏ ngày truy cập trong tài liệu tham khảo, bỏ lịch từng lần chạy trong nội dung và bỏ ngày cố định/biến ngày trong các câu hỏi hiện tại. Ngày nghiệp vụ và ngày ban hành/hiệu lực văn bản vẫn giữ đúng ý nghĩa.
- Các câu hỏi hiện tại dùng `CURRENT_DATE`; đại số dùng `Q_ht`/`Q_bd` chuẩn bị từ SQL với năm cột NOT NULL. Số liệu trong bảng là kết quả minh họa, có thể đổi theo ngày chạy. Không đổi điều kiện thành chỉ kiểm tra ngày kết thúc NULL.
- Kiểm chứng bằng PostgreSQL 17.12 trên cụm tạm biệt lập: validation đạt, 10 SQL đạt, tám assertion RA đạt (hai câu ghi nhận), bảy ca biên và ví dụ bảo mật đạt. Hash dữ liệu của bảy bảng trước/sau không đổi. Log hiện hành: `tests/report_current_date_log.txt`; log cũ bên dưới là hồ sơ lịch sử.
- Thêm `tests/report_current_date.sql` với đợt bắt đầu/kết thúc hôm nay, tương lai, quá khứ, đủ tuổi hôm nay/ngày mai, đếm người hai loại và tổ trống; test kết thúc bằng ROLLBACK. CI chạy bốn script báo cáo và dừng nếu kiểm tra sai.
- Đã kiểm tra không còn cụm ngày truy cập/ngày tham chiếu trong PDF, không có tham chiếu chưa xác định hoặc lỗi tràn dòng. Giữ nguyên byte mọi ảnh ERD và lệnh chèn ảnh; xếp loại/chữ ký vẫn do nhóm xác nhận.

## Lịch sử phiên sửa trước

## Cập nhật sau review ngày 22/11/2026

- Bản PDF hiện hành: `Báo_cáo_CSDL_nhóm_38/main.pdf`, **45 trang**, SHA-256 `81930f5d65a6cfed330755703ece8b277e6df5b425643eb5fe03b89aade2ab00`. Nền tích hợp: `main` tại `a6b3d87`.
- Đã sửa: các khẳng định tuyệt đối về lịch sử/bảo mật; định nghĩa hộ, cư dân và chuyển đi/chuyển nội bộ; trạng thái tài khoản tại thời điểm ghi; ý nghĩa phép chia; identity, chỉ mục và cách xưng “nhóm”. Nhận định về sổ sách/Excel được ghi thành giả định mô phỏng.
- Thêm mục 3.4: khóa ứng viên, phụ thuộc hàm, 1NF–3NF và dư thừa có kiểm soát ở ngày biến động; không tuyên bố toàn bộ bảy bảng 3NF nghiêm ngặt khi xét FD có điều kiện và NULL.
- Đầu vào `Q_d` và bốn CTE trong `tests/report_ra_01_10.sql` chỉ giữ năm cột NOT NULL. Chạy lại trên PostgreSQL 17.12, cụm tạm độc lập, seed636 dựng mới: validation đạt; tám câu RA có assertion đạt, RA1/RA8 ghi nhận thủ công, không có kiểm tra FAIL. Log mới: `tests/report_ra_20261122_log.txt`, có phiên bản và SHA-256 đầu vào. Cụm tạm đã dừng. Không chạy lại bảo mật trong lần này; các log 21/11 bên dưới giữ nguyên nội dung lịch sử, chỉ bỏ khoảng trắng cuối dòng để đạt kiểm tra whitespace của Git.
- Biên dịch bằng pdfLaTeX/latexmk, cập nhật mục lục một trang, kiểm tra không có Overfull, tham chiếu/citation chưa xác định. Giữ cảnh báo gói/font của mẫu; kiểm tra bố cục bằng ảnh render.
- Giữ nguyên byte toàn bộ ảnh ERD và lệnh chèn ảnh, không thay đổi `sql/*.sql`, seed hay schema. Trang phân công để nhóm tự điền xếp loại/chữ ký; không tự xác nhận Gate 3/4.
- Bàn giao Git gồm PDF, nguồn LaTeX, ảnh nguồn, script/log tái lập và README. Không đưa cache LaTeX, ZIP, thư mục backup/output cá nhân hoặc tệp chỉ dẫn sửa cho công cụ khác vào commit. Manifest bổ sung nguồn/PDF/ảnh báo cáo và biên bản này; không lấy các tệp build trung gian.

## Hồ sơ lịch sử ngày 21/11/2026

Các thông tin dưới đây mô tả bản và phạm vi kiểm thử ở ngày 21/11, không phải trạng thái PDF hiện hành.

**Ngày:** 21/11/2026 · **Thư mục báo cáo:** `Báo_cáo_CSDL_nhóm_38/` · **PDF tại thời điểm 21/11:** `Báo_cáo_CSDL_nhóm_38/main.pdf` (44 trang, SHA-256 `1b4416ed…ec09f74`)
**Bản trước lần sửa này:** PDF 37 trang, được ghi nhận trong lịch sử chỉnh sửa.

Nguồn đối chiếu: nhánh làm việc `fix/tv1-integration-gate2` @ `4bf6e73`. Thư mục `sql/` và `tests/` của nhánh này **trùng byte với `origin/main`** (`git diff HEAD origin/main` chỉ khác ở `docs/`, `meetings/`, `README.md`, manifest). PR #10 (`fix/bao-cao-review-1-5`) **đang OPEN, chưa merge**, CI FAIL; chỉ trích phần có chứng cứ chạy lại được (giới hạn quyền admin trên `tai_khoan`), không merge, không sửa `docs/02_bao_cao_suon.md` nên **không đụng `tests/week1_manifest.json`**.

## 1. File đã sửa / tạo

| Tệp | Thay đổi |
|---|---|
| `chuong6.tex` | Thay Nghị định 13/2023 bằng Luật 91/2025/QH15 + Nghị định 356/2025/NĐ-CP; ghi rõ Ví dụ 1–2 dùng `SET ROLE` (minh họa rút gọn) và thêm `RESET ROLE`; sửa câu hàm ý lịch sử không thể sửa (admin vẫn có `UPDATE`); ghi rõ hàm của Ví dụ 3 chỉ chạy trong giao dịch `ROLLBACK` trên CSDL thử; **thêm mục 6.4 “Đánh giá kết quả và giới hạn bảo mật”** (bảng kết quả có log, đăng nhập thật vs `SET ROLE`, giới hạn admin/`tai_khoan`, X01(b), giới hạn khác). Giữ nguyên B1, B2, SQL Injection. |
| `tailieuthamkhao.tex` | Bỏ `nd13`; thêm `luat91`, `nd356` có số hiệu, ngày, điều khoản hiệu lực, URL Chính phủ. |
| `ketluan.tex` (mới), `main.tex` | Thêm **KẾT LUẬN** (`\section*` + `\addcontentsline`) sau Chương 6, trước Tài liệu tham khảo. |
| `chuong4.tex` | Thay `HL(d)` dùng `IS NULL` bằng quan hệ đầu vào `Q_d`; giải thích phần NULL là bước SQL; làm rõ số bị chia/số chia ở câu 9; ghi `γ` thuộc đại số quan hệ mở rộng ở câu 10; thêm bảng đối chiếu RA–SQL. **Không đổi 10 câu hỏi.** |
| `chuong5.tex` | Thêm đoạn mở đầu (10 tình huống riêng của báo cáo, khác QSQL01–10); thêm kết quả câu 6 (đã chạy); giải thích 28+14≠41 ở Tổ 05; thêm bảng tóm tắt số dòng/PASS. **Không đổi 10 câu SQL.** |
| `chuong3.tex` | Bảng thử ràng buộc ghi SQLSTATE/ràng buộc thực tế, tách ca `CHUYEN_DEN` có đợt cũ thành 2 biến thể; nói rõ CHECK B15 ở `02_constraints.sql` (tổng 11 CHECK); B12 chỉ chặn xóa của `csdl17_admin`; thêm đoạn giới hạn X06/X07/X01; ghi chú listing DDL. |
| `loimodau.tex` | Thêm câu giới thiệu mục 6.4 và phần Kết luận. |
| `sqllisting.tex` | `columns=fullflexible`, `keepspaces`, `upquote` (dấu `'` thẳng), số dòng `\scriptsize`. Cỡ chữ giữ 10pt (`\footnotesize` của lớp 12pt). |
| `chuong2.tex`, `image/erd_trang_11_vector_crop.pdf` (mới) | ERD: cắt lề trắng bằng `pdfcrop`, đặt `width=\textwidth` thay cho `1.15\textwidth` (hết tràn lề 64pt). Không đổi nội dung/bản số. |
| `README_COMPILE.md` | Thêm `ketluan.tex`, ảnh ERD đang dùng, trỏ tới script tái lập. |
| `tests/report_sql_01_10.sql` (+ `_log.txt`) | 10 SQL **đang in** ở Chương 5, chép nguyên văn + khối tự đối chiếu PASS/FAIL. |
| `tests/report_ra_01_10.sql` (+ `_log.txt`) | Dịch từng biểu thức RA Chương 4 sang SQL ngữ nghĩa tập hợp, so hai chiều với SQL Chương 5. |
| `tests/report_bang_thu_rang_buoc.sql` (+ `_log.txt`) | Tái lập 6 dòng bảng thử ràng buộc Chương 3 (BEGIN…ROLLBACK). |
| `tests/report_security_ch6.sql` (+ `_log.txt`), `tests/report_security_repo_tests_log.txt` | Kiểm chứng Ví dụ 1–3, giới hạn admin, X01; log chạy lại 4 script bảo mật có sẵn. |

Không sửa: template, bìa, GVHD, mã lớp, MSSV, `phancong.tex` (xếp loại/chữ ký vẫn trống), trang 2 trắng, `sql/*.sql`, `docs/*`, manifest.

## 2. Kết quả kiểm thử thực tế (21/11/2026)

Môi trường: PostgreSQL 17.12 (Homebrew, macOS), **cụm tạm riêng** cổng 55432, xác thực `trust` trên localhost; DB `csdl17_seed636` dựng mới: `01_schema` → `02_constraints` → `03_seed` → `06_validation` (3 [PASS]; 8/50/60/200/250/5/63 = 636). Không dùng cụm PostgreSQL đang chạy của máy.

| Hạng mục | Kết quả |
|---|---|
| SQL Chương 5 | 23, 8 (Tổ 05 = 41, Tổ 08 = 0/0/0), 40 (max 7), 17, 3 đợt cư dân 92, **câu 6: 21 dòng / 29 biến động**, 27 (đầu 18/01/2025 Dương Hữu Cường 13→25), 1 dòng TK 2 = 21, 31, 131 (có cư dân 1). **9/9 PASS**, câu 6 ghi nhận. |
| RA Chương 4 | RA3 = SQL1 (23, lệch 0), RA4 = SQL4 (17, lệch 0), RA5 = 31, RA6 = {32}, RA7 = SQL7 (27, lệch 0), RA8 = 2 cán bộ, RA9 = {1,2,3,4} bằng cả NOT EXISTS và đếm, RA10: 56 hộ, 40 hộ ≥3 = SQL3. **0 FAIL.** |
| Bảng thử ràng buộc | 23P01 `ex_qt…`; CHUYEN_DEN+đợt cũ: (a) trigger B09 23514, (b) `ck_bd_hinh_dang` 23514; B11 23514; `ck_qt_ngay` 23514; FK 23503; `ck_b15_ho_ten` 23514. |
| Bảo mật (script có sẵn) | `05_security.sql` thoát 0, đúng 6 lỗi quyền cố ý; catalog **15/15**; B12 **K01–K05 PASS**; đăng nhập `psql -h localhost -U` reader **12/12**, report **10/10**. |
| Ví dụ Chương 6 | reader đếm 200, UPDATE 42501; admin DELETE lịch sử 42501; VIEW 8 dòng (34…0); Injection: hàm sai **200**, hàm đúng **0**, “Hùng” **8**; report gọi hàm 42501. |
| Giới hạn admin (mới đo) | `tai_khoan` S/I/U/D = có; xóa TK2 23503; xóa TK5 OK; sửa tên/vai trò/trạng thái OK; sửa `ghi_chu` biến động OK; **đổi `ma_tai_khoan` của biến động cũ OK**; đổi ngày biến động / ngày kết thúc đợt đã gắn sự kiện → 23514; TK KHOA ghi → 23514, mở khóa rồi ghi OK. Vai trò: CAN_BO 39, THONG_KE 13, QUAN_TRI 11. |

Pháp luật — đã đọc văn bản gốc (PDF scan trên datafiles.chinhphu.vn): Luật 91/2025/QH15 thông qua 26/6/2025 (kỳ họp 9, khóa XV), **Điều 38 k1: hiệu lực 01/01/2026**; NĐ 356/2025/NĐ-CP ban hành 31/12/2025, **Điều 42 k1: hiệu lực 01/01/2026; k2: NĐ 13/2023/NĐ-CP hết hiệu lực**. Trang `chinhphu.vn/?docid=214590…` báo bảo trì; dùng `vanban.chinhphu.vn/?pageid=27160&docid=214590`.

## 3. Build và rà PDF

`latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex` (pdfLaTeX, MacTeX): thoát 0, **0 lỗi, 0 Overfull** (bản cũ có 1 Overfull 64pt ở ERD), không có tham chiếu/trích dẫn chưa định nghĩa; còn 4 Underfull nhẹ có sẵn và 1 cảnh báo thay cỡ font ≤0,5pt. 37 → **44 trang** (thêm 6.4, bảng đối chiếu, Kết luận, listing không còn giãn). Đã render và xem toàn bộ 44 trang: bìa, mục lục (có 6.4, KẾT LUẬN), ERD nằm trong lề, bảng Chương 3, công thức `Q_d`, listing, bảng 6.4, Kết luận, tài liệu tham khảo, trang phân công.

## 4. Còn mở / cần nhóm quyết

- **ERD:** đã hết tràn lề nhưng nhãn còn ~5pt khi in (trước ~5,6pt). Muốn chữ to hơn phải vẽ lại ellipse trong `erd_v1.drawio`/SVG (TV1) — không tự vẽ lại.
- **Ảnh minh chứng** SQL (`evidence/sql/`), bảo mật (`evidence/security/`) và chữ ký Gate 3 vẫn **chưa có**; báo cáo không chèn ảnh nào mới. Xếp loại/chữ ký trang cuối để trống.
- Lần chạy lại đăng nhập 21/11 dùng xác thực `trust` (cụm tạm) — kiểm định danh phiên, **không** kiểm lại SCRAM; SCRAM dựa trên log TV3 ngày 20/11 (`tests/week2_security_login_log.md`).
- PR #10: chưa nhập từ điển 35 cột/P1–P6 vào bản in (Chương 3 đã có bảng cấu trúc từng bảng). TV3 có thể bổ sung phát hiện “admin đổi được `ma_tai_khoan` của biến động cũ” vào PR #10.
- Chưa commit/push gì; các tệp `tests/report_*` và thư mục LaTeX vẫn untracked. Nếu đưa lên repo, cần PR riêng và xin phép chủ repo; kiểm tra `scripts/verify_week1.py` có yêu cầu khai báo tệp mới trong manifest hay không.
- Tệp tạm LaTeX (`*.aux`, `*.log`…) đã được `.gitignore` của thư mục báo cáo bỏ qua.
