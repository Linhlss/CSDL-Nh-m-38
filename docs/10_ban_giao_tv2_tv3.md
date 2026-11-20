# HỒ SƠ BÀN GIAO TV1 → TV2, TV3 — BẢN TÍCH HỢP TRƯỚC GATE 2

**Người bàn giao:** TV1 — Trần Bùi Tùng Linh (20227057). **Ngày:** 20/11/2026.
**Nhánh ứng viên duy nhất:** `fix/tv1-integration-gate2`, tức [PR #7](https://github.com/Linhlss/CSDL-Nh-m-38/pull/7) vào `main`.
**Commit bàn giao:** commit HEAD của nhánh trên tại thời điểm TV1 bình luận "bàn giao" trong [Issue #9](https://github.com/Linhlss/CSDL-Nh-m-38/issues/9). Bình luận đó ghi đúng SHA và liên kết CI. Tệp này không tự ghi được SHA của chính commit chứa nó.
**Trạng thái cập nhật 20/11:** bản ứng viên kỹ thuật đã **Gate 2 PASS theo xác nhận nhóm do TV1 báo lại**, chưa có review GitHub độc lập hoặc chữ ký. Lịch sử PR và trạng thái merge xem GitHub; Gate 3/4, ảnh, PDF và ký nhận còn mở. [Nguồn](../meetings/decision_log.md#gate2).

## 1. Lấy bản bàn giao và dựng lại

```sh
git fetch origin
git switch fix/tv1-integration-gate2      # hoặc: git switch -c fix/tv1-integration-gate2 --track origin/fix/tv1-integration-gate2
git pull --ff-only
```

- **Dựng hai DB trắng và chạy toàn bộ kiểm thử:** làm theo [docs/08_huong_dan_dung_csdl.md](08_huong_dan_dung_csdl.md). Hướng dẫn này gồm catalog, B12, S01–S16 và đăng nhập thật.
- **Đối chiếu kết quả:** so với [tests/week2_tv1_integration_log.md](../tests/week2_tv1_integration_log.md) và [tests/final_test_log.md](../tests/final_test_log.md) mục 6.
- **Lưu ý khi dùng Windows:**
  - Đặt `git config core.autocrlf false` trước khi checkout. Nếu không, `verify_week1.py` sẽ báo FAIL dòng LF (T3-07).
  - Chạy `05_security.sql` và `ra_fixture.sql` bằng `psql`, không chạy qua GUI.

## 2. Những gì TV1 đã hoàn thành (không giao lại)

| Hạng mục | Kết quả | Nơi kiểm tra |
|---|---|---|
| Tích hợp PR #5 | Parser 11/12 khối, RA/fixture vào nhánh; PR #5 đã đóng, không merge | PR #7, `docs/09` |
| Tích hợp PR #8 (TV3) | Fast-forward `432600e`; review B12 có kiểm chứng K01–K05 | `docs/09` mục 5, comment PR #8 |
| Tích hợp PR #6 (TV2) | Merge Chương 3.5, Chương 5 và `final_test_log` (giữ commit của Ngocdeezet); chạy lại 10 QSQL trên seed636 và fixture29, mọi số liệu khớp; sửa tên VIEW và lệnh `psql -d` | Commit merge "Tích hợp Chương 3.5, Chương 5…", ghi chú đầu Chương 5 |
| X01–X07 | X01 (b) chờ TV2; X02 chấp nhận; X03–X06 đã sửa; X07 giữ E1, test được gia cố | `docs/07` mục 10.1, `decision_log` mục 9 |
| Chương 1–3 | Cập nhật ràng buộc hiện hành (B06–B15, E1, B12), bảng giới hạn X01–X07, chuẩn hóa 3NF có điều kiện | `docs/02` Chương 1–3 |
| Phần báo cáo của TV1 | Bìa (trừ tên trường/khoa), mục lục, Mở đầu, phạm vi, cấu trúc báo cáo, Kết luận, Tài liệu tham khảo (đánh số), Phụ lục A–E, trang cuối (công việc thực tế; trống xếp loại/chữ ký) | `docs/02` |
| Quy ước ảnh | Ảnh bảo mật dùng bộ tên `SEC_B1_*`/`SEC_B2_*`; ảnh SQL dùng `QSQLxx_result.png`; vị trí chèn và caption mẫu đã định | `docs/02` Phụ lục E |
| CI | Thêm catalog C01–C15, B12, đăng nhập thật, khẳng định S01–S16, đếm 6 lệnh bị từ chối của B1/B2; chạy cả trên PR vào `fix/**` | `.github/workflows/csdl-constraints.yml` |
| Kiểm thử từ DB trắng | PostgreSQL 17.12, scram, trên commit cuối. Kết quả: 40 + 3 PASS, 71 đối soát, S01–S16 18/18, catalog 15/15, K01–K05, reader 12/12, report 10/10, seed636 không đổi, `verify_week1` 14/14 | `tests/week2_tv1_integration_log.md` mục 7 |
| PDF nháp | Bản HTML → PDF A4 (49 trang) để soát trình bày. Mục lục, bảng, khối SQL/RA và hai hình hiển thị đủ; công thức dài tự xuống dòng. Không đưa vào repo vì chưa là bản nộp | Gửi riêng cho nhóm |

## 3. Việc của TV2 — Trần Tuấn Ngọc

| # | Việc | Đầu ra | Cách kiểm chứng | Hạn | Reviewer |
|---|---|---|---|---|---|
| T2-1 | Review Chương 3.5 và Chương 5 đã tích hợp, gồm hai chỗ TV1 sửa: tên VIEW `vw_…` và `psql -d` | Comment trên PR #7: đồng ý hoặc yêu cầu sửa | So diff của commit merge với PR #6 | 21/11 | TV1 |
| T2-2 | **Đã có xác nhận qua TV1**: phương án X01(b), giữ seed636 | TV1 đã báo cả nhóm đồng ý ngày 20/11; TV2 có thể bổ sung comment trực tiếp để lưu vết | Không đổi seed/QSQL10; nguồn Gate 2 tại nhật ký mục 10 | Đã ghi nhận Gate 2 | TV1, TV3 |
| T2-3 | Review chuẩn hóa (`docs/04` mục 5, Chương 3.4) và Chương 6 (T3-02) | Comment review | — | 22/11 | TV1 / TV3 |
| T2-4 | Dựng DB trên **Windows** theo `docs/08`; lưu `SELECT version();` và log | Cập nhật `tests/final_test_log.md` mục 1 (W2-T2-01) | 40 + 3 PASS, 71 PASS, S01–S16 18/18 như log TV1 | 22/11 | TV1 |
| T2-5 | Chụp 10 ảnh `evidence/sql/QSQL01_result.png` … `QSQL10_result.png` từ seed636 | 10 tệp PNG; thay dòng "Chờ bổ sung" ở mục 5.2–5.11 | Số dòng khớp bảng 5.12 | 24/11 | TV3 |
| T2-6 | Đóng PR #6 sau khi xác nhận T2-1 (nội dung đã nằm trong PR #7), tránh merge hai lần | PR #6 đóng, có ghi chú | — | Sau T2-1 | TV1 |
| T2-7 | Kiểm tra dòng công việc của mình ở trang cuối; xác nhận Gate 2/3 | Sửa dòng TV2 nếu cần | — | 22/11, 24/11 | Cả nhóm |

## 4. Việc của TV3 — Dương Ngọc Ninh

| # | Việc | Đầu ra | Cách kiểm chứng | Hạn | Reviewer |
|---|---|---|---|---|---|
| T3-A | Review bản tích hợp: PR #8 đã nằm trong nhánh TV1; review X03–X07 (`docs/07` mục 10.1) | Comment trên PR #7 | — | 21/11 | TV1 |
| T3-B | Review `tests/security_b12_tv1.sql` (K01–K05) và các bước CI bảo mật mới | Comment | CI xanh; chạy được trên máy TV3 | 21/11 | TV1 |
| T3-C | Xác nhận Chương 4, 10 RA, QRA07 phép chia và số liệu Phụ lục C (QRA02 = 10, QRA03 = 2, QRA08 = 61…) | Comment; đổi "Nháp v0" ở 06a mục (8) cùng TV1 (T3-01) | `verify_gate2_integration.py` 71 PASS | 22/11 | TV1 |
| T3-D | Chốt bộ tên ảnh `SEC_*` (T3-03; TV1 đã đề xuất ở Phụ lục E và checklist W3-T3-05) | Đồng ý hoặc sửa | — | 23/11 | TV1 |
| T3-E | Chụp ảnh B1/B2 từ phiên đăng nhập thật vào `evidence/security/` (T3-04); cập nhật số dòng 211–213, 216, 257, 258 trong `tests/week2_security_login_log.md` | 7 ảnh bắt buộc + 1 tùy chọn | Ảnh khớp bảng Chương 6 | 24/11 | TV2 |
| T3-F | Bổ sung giáo trình/bài giảng thực sự dùng cho Chương 4, 6 (T3-05) | Mục A của Tài liệu tham khảo | Không có nguồn chưa dùng | 25/11 | TV1 |
| T3-G | Rà công thức RA khi in A4: hai dòng dài hơn 100 ký tự (QRA04 phép nối tự thân, QRA10 nối với `MOI`) | Xuống dòng hợp lý nếu PDF bị tràn | Xem PDF nháp | 25/11 | TV1 |
| T3-H | Tự tick các ô checklist của mình (W2-T3-10..13, W3-T3-08 đã có sản phẩm); xác nhận Gate 2/3 | Checklist cập nhật | — | 22/11 | Cả nhóm |

## 5. Việc còn lại của TV1 sau phản hồi (giai đoạn C)

1. X01(b) đã được nhóm đồng ý theo lời TV1 báo lại. Giữ seed636 và QSQL10; chỉ thay đổi phương án nếu cả nhóm ra quyết định mới có ghi nhận. Xử lý góp ý phát sinh từ Gate 3 trên PR/main.
2. **Gate 2: PASS theo báo cáo TV1 ngày 20/11** (xem nhật ký quyết định mục 10); chưa có comment GitHub cá nhân của TV2/TV3.
3. Merge PR #7 vào `main` sau khi review đạt. Đóng PR #6 (đã nằm trong #7). PR #8 đã được gộp. Chạy CI trên `main` sau merge.
4. **Gate 3 (24/11):** rebuild cuối, chèn ảnh, điền tên trường/khoa trên bìa.
5. Xuất PDF cuối, rà từng trang, in A4 hai mặt (26/11). Nộp 27/11, tiết 3.

## 6. Lỗi mở và người xử lý

| Mã | Mô tả | Mức | Owner | Hạn |
|---|---|---|---|---|
| X01 | **Đóng ở Gate 2:** chọn (b), giữ seed, giới hạn được công bố | Đã quyết định | TV1 báo nhóm đã đồng ý | 20/11 |
| T3-01 | 06a mục (8) còn ghi "Nháp v0" | Thấp | TV3 + TV1 | 22/11 |
| T3-03 | Chốt tên ảnh `SEC_*` | Thấp | TV3 | 23/11 |
| T3-04 | Ảnh B1/B2 | Gate 3 | TV3 | 24/11 |
| W2-T2-01 | Môi trường Windows của TV2 | Gate 3 | TV2 | 22/11 |
| ẢNH-SQL | 10 ảnh `QSQLxx_result.png` | Gate 3 | TV2 | 24/11 |
| T3-05 | Nguồn giáo trình | Gate 4 | TV3 + TV1 | 25/11 |
| BÌA | Tên trường/khoa theo mẫu bìa | Gate 4 | TV1 | 26/11 |

Không có lỗi kỹ thuật nghiêm trọng nào chưa có người xử lý. Mọi kiểm thử bắt buộc đều PASS trên commit bàn giao: xem log mục 7 và liên kết CI trong Issue #9.


> **Ghi chú sau Gate 2:** các mục T2-1/T2-3, T3-A/B/C nếu đã được thành viên trao đổi trực tiếp thì TV1 ghi nhận nhóm đã đồng ý về nội dung chung; các minh chứng review cá nhân chưa được lưu trên GitHub nên vẫn có thể bổ sung. Các mục môi trường Windows, ảnh SQL/SEC, nguồn giáo trình, PDF và chữ ký không vì vậy mà được coi là hoàn tất.
