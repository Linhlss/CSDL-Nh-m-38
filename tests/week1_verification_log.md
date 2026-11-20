# BIÊN BẢN KIỂM TRA TỆP DỰ ÁN — 20/11/2026

**Lệnh đã chạy:** `python3 scripts/verify_week1.py --record` từ thư mục gốc.
**Python thực tế:** 3.13.5. **Hệ điều hành:** Darwin 25.6.0.
**Phạm vi:** kiểm tra tệp và đối chiếu cấu trúc/tài liệu, không kết nối PostgreSQL.
**Trạng thái đọc từ nhật ký:** Gate 1 PASS; thiết kế v1. Ngày tiếp nhận: 16/11/2026; nguồn: Chủ repo xác nhận trong chat ngày 16/11/2026.

| Kiểm tra | Kết quả | Bằng chứng / phạm vi |
|---|---|---|
| Required artifacts | PASS | 26 required artifacts exist and are nonempty |
| DDL contract | PASS | 7 tables / 35 columns / 7 PK / 7 FK / 3 UNIQUE / 6 CHECK / 5 indexes |
| Data dictionary | PASS | 35 dictionary rows match DDL names, types, NULL, PK/FK, inline UNIQUE and defaults |
| Editable diagrams | PASS | ERD: 7 entities, 35 attributes, 7 FK roles; function tree: 1 root + 6 groups + 14 leaves |
| PNG exports | PASS | 2 valid 2300×1626 PNGs, A4 landscape proportions, all PNG chunk CRCs valid |
| Question/rule/case coverage | PASS | 10 RA + 10 SQL design mappings; 30 design cases; 18 business rules; 10 review notes |
| Report and task handoff | PASS | Chapters 1–3 filled; all 20 TV1 tasks traced; Gate 1 PASS / v1; confirmation source and DB-test limits explicit |
| Local file links | PASS | 249 local Markdown file links resolve (anchors and external URLs are not network-tested) |
| SQL compatibility | PASS | Executable SQL unchanged from GitHub main d20b394; only comments differ |
| Utility syntax | PASS | Python utility sources parse successfully; no cache files written |
| Week1 task trace | PASS | 142 unique project IDs; shared ledger: 53 week1 IDs, 52 completed, 1 deferred to week2, 0 awaiting confirmation; deferred tasks stay unchecked |
| Recorded runtime evidence | PASS | 96/96 historical PostgreSQL checks; week1 input versions preserved in log; week2 validation/runtime tooling tracked by new manifest and CI (DB not rerun by this script) |
| LF text policy | PASS | LF policy and repository text verified; PNG/binary content unchanged; no unperformed Windows test claimed |

## Kiểm tra trực quan

Lần dựng sơ đồ tuần 1 đã mở và xem cả hai ảnh PNG: tên/thuộc tính đọc được, không cắt bảng hoặc chữ; hai vai trò cũ/mới tách riêng; cây chức năng đủ ba cấp. Lần kiểm tra tệp này kiểm PNG 2300×1626, CRC và XML của SVG/drawio, không tự nhận là một lần review hình ảnh mới hoặc thay review nội dung của TV2/TV3.

## Kiểm tra tương thích

`week1_sql_compatibility.json` lưu URL phiên bản gốc tại d20b394 và SHA-256 SQL chuẩn hóa đã đối chiếu. Lần kiểm tra này bỏ chú thích dòng, gộp khoảng trắng và so với hash đã ghi; không tự nhận đã tải lại nguồn GitHub. Không thay đổi câu lệnh tạo bảng/chỉ mục.

## Những điều chưa được xác nhận

- Lệnh kiểm tra tệp này không chạy DDL hoặc S01–S21 trên PostgreSQL. Nguồn và phạm vi kiểm chứng độc lập nằm trong [nhật ký chung](../meetings/decision_log.md), [log146](tv3_review_results.json) và [log96](week1_execution_results.json); không dùng biên bản tĩnh này làm bằng chứng chạy DB mới.
- Lệnh này không nghiệm thu cơ chế tuần 2 trong constraints/seed/query/security; xem sản phẩm và kết quả của từng owner. Ca D01–D30 là đối chiếu thiết kế với đáp án kỳ vọng, không là kết quả DB PASS.
- Trạng thái Gate 1 ở trên được đọc từ xác nhận đã lưu trong meetings/decision_log.md; script không tạo lời đồng ý hoặc chữ ký của thành viên. Phân tích chuẩn hóa công bố điểm dư thừa ngày sự kiện và phần cần chốt tuần 2.
- Biên bản này chỉ kiểm tra tệp; trạng thái tích hợp PR, commit, bảng53mã và xác nhận còn thiếu tập trung tại meetings/decision_log.md. Merge không thay thế xác nhận Gate 1; lịch tuần 2 nằm trong checklist hiện hành.

## Kiểm tra lại

Nhận bản mới bằng `git pull --ff-only origin main` trên nhánh main, rồi chạy `python3 scripts/verify_week1.py`. Lệnh kiểm tra chỉ đọc, gồm đối chiếu SHA-256 của các tệp trong repository. Sau khi sửa nội dung, review rồi chạy lại --record để tái tạo biên bản và manifest trước commit; không chỉnh log thành PASS bằng tay.
