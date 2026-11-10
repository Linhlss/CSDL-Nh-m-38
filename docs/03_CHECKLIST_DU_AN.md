# CHECKLIST ĐIỀU HÀNH TOÀN BỘ BTL CƠ SỞ DỮ LIỆU — ĐỀ TÀI 17

> **Tên:** Xây dựng cơ sở dữ liệu quản lý cư dân và biến động cư trú tại một phường (mô phỏng).  
> **Nhóm:** [STT nhóm] — **Mã lớp:** [Mã lớp] — **GV:** [Họ tên giảng viên].  
> **TV1:** [Họ tên – MSSV] (Trưởng nhóm, phân tích, thiết kế, tích hợp).  
> **TV2:** [Họ tên – MSSV] (Dữ liệu giả lập, SQL, kiểm thử).  
> **TV3:** [Họ tên – MSSV] (Đại số quan hệ, bảo mật, kiểm chứng).  
> **Thời gian:** 10–27/11/2026 · **Hạn nộp:** Thứ Sáu 27/11/2026, tiết 3 (theo ảnh thông báo của giảng viên).  
> **Ngày tham chiếu cố định để so sánh kết quả truy vấn:** `2026-11-20`.  
> **Dự kiến:** PostgreSQL >= 15, mô hình 7 bảng, dữ liệu giả lập 100%, khoảng 643 bản ghi (không phải yêu cầu bắt buộc của cô).  
> **Vị trí đề xuất trong repository:** `docs/07_checklist_toan_du_an.md`.  
> **Phiên bản:** 1.0 — lập 10/11/2026. Đây là **checklist kế hoạch**, không tự xác nhận công việc kỹ thuật đã hoàn thành.

---

## A. HƯỚNG DẪN SỬ DỤNG — QUY ƯỚC HOÀN THÀNH

- Dấu `[ ]`: CHƯA được nghiệm thu; `[x]`: **có file/commit thực tế, kiểm tra đạt và reviewer xác nhận**. Không tích vì chỉ có tên file hoặc nội dung TODO.
- Mã công việc có dạng `W1-T1-01` = tuần 1, thành viên 1, việc 01. **Owner** là người làm và sửa lỗi; **Reviewer** được ghi theo cụm công việc; làm xong phải gửi đường dẫn commit/PR hoặc file và kết quả kiểm tra.
- Trạng thái nên ghi tại GitHub Issues/PR: `TODO → DOING → REVIEW → DONE`, hoặc ghi trong `meetings/decision_log.md`. Checklist này vẫn dùng `[ ] / [x]` để hoạt động ngay trên GitHub.
- **Mỗi người tự viết phần báo cáo của mình**, TV1 kiểm tra định dạng và tích hợp; không đẩy phần viết chương 4–6 sang TV1.
- Tên bảng/cột trong SQL dùng **chữ thường snake_case**, nhất quán với `sql/01_schema.sql`. Chỉ thay schema khi có biên bản quyết định và thông báo cho cả 3.
- Mọi bản ghi dân cư đều giả lập; **không dùng thông tin định danh, địa chỉ cá nhân hoặc mật khẩu thật**.
- **Tối thiểu phải hoàn thành**: bài toán + chức năng + ERD + lược đồ quan hệ/ràng buộc + 10 đại số quan hệ + 10 SQL + 2 ví dụ bảo mật + báo cáo đúng quy định + bản mềm/bản in. Giao diện web, ứng dụng và AI **không** thuộc phạm vi.
- Mọi bài kiểm thử âm (dự kiến lỗi) phải chạy trong `ROLLBACK` hoặc transaction riêng để không làm bẩn CSDL.

### A1. Những thứ ĐÃ CÓ trong bộ khung, nhưng chưa được tính là nghiệm thu chuyên môn

- [x] Chọn chủ đề số 17, tên đề tài và giới hạn **một phường mô phỏng**.
- [x] Thống nhất dữ liệu được **giả lập 100%**.
- [x] Lập kế hoạch 3 tuần và chia ba vai trò chính.
- [x] Khởi tạo GitHub repository và có các tài liệu `README.md`, `docs/01_de_cuong.md`, `docs/02_bao_cao_suon.md`, `docs/06_phan_cong_tien_do.md`.
- [x] Có bản **DDL dự thảo v0** `sql/01_schema.sql` cho 7 bảng; đây KHÔNG phải schema đã khóa/đã kiểm thử.
- [x] Có danh sách **10 câu RA** trong đề cương, **10 slot SQL** trong `sql/04_queries.sql`, khung **21 test S01–S21** và kế hoạch **2 demo bảo mật**; chưa có nghĩa đã viết/chạy xong.

> Các mục `[x]` trên chỉ xác nhận **sự tồn tại của đầu vào/bản nháp** theo trao đổi và bộ khung; các mục tuần 1–3 bên dưới vẫn để `[ ]` cho đến khi **thành viên rà soát và nghiệm thu**. Nếu nhánh GitHub khác bản dự thảo, cập nhật theo bản thực tế sau khi kiểm tra.

### A2. Nơi lưu sản phẩm — tránh đặt trùng/tên không nhất quán

| Đường dẫn đề nghị | Owner | Nội dung bắt buộc |
|---|---|---|
| `docs/03_dac_ta_nghiep_vu.md` | TV1 | Bài toán, phạm vi, tác nhân, P1–P6, quy tắc nghiệp vụ |
| `diagrams/phan_ra_chuc_nang.drawio` và `.png` | TV1 | Sơ đồ phân rã chức năng chính thức |
| `diagrams/erd_v1.drawio` và `.png` | TV1 | Mô hình ER chính thức, 7 thực thể/quan hệ |
| `docs/04_data_dictionary_va_chuan_hoa.md` | TV1 | 7 bảng, thuộc tính, PK/FK/CK, ánh xạ, phụ thuộc hàm, 3NF |
| `sql/01_schema.sql` | TV1 | CREATE TABLE bản đã duyệt |
| `sql/02_constraints.sql` | TV1 | Ràng buộc liên bảng và thời gian, kèm giải thích/SQL kiểm thử |
| `docs/05_ke_hoach_du_lieu_va_sql.md` | TV2 | 10 câu SQL, dữ liệu cần cho từng câu, kịch bản sinh dữ liệu |
| `scripts/generate_data.py` | TV2 | Sinh dữ liệu giả lập có seed cố định và kiểm tra quan hệ |
| `data/generated/` | TV2 | CSV giả lập, không chứa thông tin thật |
| `sql/03_seed.sql` | TV2 | Nạp dữ liệu hoặc chỉ dẫn nạp CSV tái tạo được, không nạp trùng |
| `sql/04_queries.sql` | TV2 | 10 truy vấn SQL chạy được |
| `docs/06_dai_so_quan_he_va_bao_mat.md` | TV3 | 10 bài RA và kế hoạch bảo mật, có thể tách hai file nếu quá dài |
| `sql/05_security.sql` | TV3 | Roles, quyền, VIEW và 2 ca demo bảo mật |
| `sql/06_validation.sql` | TV1 chính; TV2/TV3 góp | Test tính toàn vẹn và kiểm tra số bản ghi, kết quả |
| `tests/test_scenarios.md` | TV2 chính; TV1/TV3 góp | 21 tình huống có dữ liệu, kết quả, reviewer |
| `tests/final_test_log.md` | TV2 chính | Nhật ký chạy thật, lỗi/khắc phục, commit và môi trường |
| `evidence/sql/` và `evidence/security/` | TV2 / TV3 | Ảnh hoặc file kết quả rõ nội dung, không minh họa giả |
| `meetings/decision_log.md` | TV1 | Các quyết định, thay đổi schema, duyệt Gate 1–4 |
| `report/` | TV1 tích hợp | Bản báo cáo nguồn và PDF cuối cùng |

**Lưu ý:** Các file `docs/03...`, `04...`, `05...`, `06...` bên trên là **đề xuất tạo mới**; không tự thay thế/ghi đè `docs/01_de_cuong.md` và `docs/02_bao_cao_suon.md` đang có. Nếu nhóm đổi tên, sửa tất cả đường dẫn trong checklist.

### A3. Hạn nội bộ và điều kiện đi tiếp

| Gate | Thời hạn | Phải có trước khi đi tiếp | Người duyệt |
|---|---|---|---|
| **G0 – Kickoff** | 10/11 | Tên đề tài, vai trò, repo, quy tắc làm việc | TV1 + TV2 + TV3 |
| **G1 – Khóa thiết kế** | **15/11** | Đặc tả nghiệp vụ, sơ đồ chức năng, ERD, data dictionary, danh sách 10 RA + 10 SQL khả thi, schema v1 | Cả 3 |
| **G2 – Hoàn thành nội dung kỹ thuật** | **22/11** | DDL/ràng buộc, dữ liệu, 10 SQL, 10 RA, 2 bản demo bảo mật chạy thử | Cả 3 |
| **G3 – Nghiệm thu kỹ thuật** | **24/11** | Chạy từ DB sạch, đối soát, demo bảo mật bằng role thật, test log, minh chứng | Cả 3 |
| **G4 – Sẵn sàng nộp** | **26/11** | Báo cáo đã soát, PDF hoàn chỉnh, bản in hợp lệ, phân công + chữ ký, tập dượt | Cả 3 |
| **Nộp & báo cáo** | **27/11, tiết 3** | Bản mềm trên Assignment và bản cứng; báo cáo theo lịch giảng viên | TV1 điều phối |

---

# TUẦN 1 — 10–15/11: ĐẶC TẢ, THIẾT KẾ VÀ KHÓA SCHEMA (G1)

**Trọng tâm:** Chưa lao vào sinh 643 bản ghi hoặc viết 20 lời giải khi chưa khóa thiết kế. Mỗi việc phải có **tài liệu/sơ đồ cụ thể**, không chỉ trao đổi miệng.

## W1 / TV1 — Trưởng nhóm, nghiệp vụ, ERD, lược đồ quan hệ

**Reviewer chính: TV2 kiểm tra tính khả thi SQL/dữ liệu; TV3 kiểm tra quan hệ, đại số và bảo mật.**

- [ ] **W1-T1-01 · 10/11 · Xác nhận đầu vào:** Đọc thông báo cô, đối chiếu 6 yêu cầu chuyên môn và hình thức; ghi rõ **không bắt buộc website/dataset thực**, không bỏ sót 10 RA, 10 SQL, 2 bảo mật. **Bàn giao:** phần phạm vi/mục tiêu trong `docs/03_dac_ta_nghiep_vu.md`.
- [ ] **W1-T1-02 · 10/11 · Chốt thuật ngữ:** Định nghĩa “cư dân”, “nhóm hộ cư trú”, “địa chỉ”, “tổ dân phố”, “đợt cư trú”, “biến động”, “ngày tham chiếu”; phân biệt **nhóm hộ** với quan hệ huyết thống. **Đạt:** không dùng cùng một thuật ngữ với hai nghĩa.
- [ ] **W1-T1-03 · 10–11/11 · Mô tả bối cảnh và tác nhân:** Viết bài toán thực tế, mục tiêu, người sử dụng (cán bộ nhập, thống kê, quản trị), các tác vụ được phép; liệt kê rõ phạm vi loại trừ. **Đạt:** đọc độc lập hiểu hệ thống làm gì/không làm gì.
- [ ] **W1-T1-04 · 11/11 · Đặc tả P1–P6:** Với mỗi quy trình quản lý địa bàn, thêm cư dân, mở đợt, chuyển đến, chuyển đi/chuyển nội bộ, tra cứu/thống kê, mô tả **đầu vào → điều kiện → xử lý → đầu ra → bảng đọc/ghi → lỗi có thể gặp**. **Bàn giao:** bảng 6 quy trình.
- [ ] **W1-T1-05 · 11/11 · Quy tắc nghiệp vụ 1–N:** Xác định 1 tổ có nhiều địa chỉ; 1 địa chỉ có nhiều nhóm hộ; 1 người có nhiều đợt cư trú; mỗi đợt thuộc một người và một hộ; ghi ngoại lệ nếu có. **Đạt:** nhất quán với PK/FK.
- [ ] **W1-T1-06 · 11–12/11 · Quy tắc thời gian:** Chốt `ngay_bat_dau`, `ngay_ket_thuc` (bao gồm ngày kết thúc), `NULL` nghĩa là chưa biết ngày kết thúc; xác định đợt đang hiệu lực tại ngày `d` bằng `bat_dau <= d AND (ket_thuc IS NULL OR ket_thuc >= d)`.
- [ ] **W1-T1-07 · 11–12/11 · Quy tắc biến động:** Quy định điều kiện ba loại `CHUYEN_DEN` (chỉ đợt mới), `CHUYEN_DI` (chỉ đợt cũ), `CHUYEN_NOI_BO` (cả hai); cũ/mới của cùng cư dân, khác hộ, thứ tự ngày hợp lệ; lưu nhật ký sự kiện nhưng không lặp tên/địa chỉ.
- [ ] **W1-T1-08 · 12/11 · Vẽ cây chức năng:** 1 nút cấp 0; 6 nhóm chức năng cấp 1; chức năng con cấp 2 tương ứng nghiệp vụ; xuất cả `.drawio` và `.png`; tên sơ đồ phải là **phân rã chức năng**, không nhầm với flowchart/ERD. **Review:** TV3.
- [ ] **W1-T1-09 · 12/11 · Liệt kê đủ 7 thực thể:** `to_dan_pho`, `dia_chi`, `ho_cu_tru`, `cu_dan`, `qua_trinh_cu_tru`, `bien_dong_cu_tru`, `tai_khoan`; ghi mục đích, lý do tồn tại, thuộc tính cốt lõi. **Đạt:** mỗi thực thể gắn với ít nhất một nghiệp vụ.
- [ ] **W1-T1-10 · 12–13/11 · Vẽ ERD chuẩn:** Bổ sung thuộc tính, PK, FK, bản số (1–N, 0–N), tính bắt buộc/tùy chọn; quan hệ cư dân–hộ được biểu diễn qua `qua_trinh_cu_tru` có khoảng thời gian. **Bàn giao:** `.drawio` + `.png` đủ rõ để in A4.
- [ ] **W1-T1-11 · 12–13/11 · Soát 2 liên kết đặc biệt:** `bien_dong_cu_tru.ma_qua_trinh_cu` và `.ma_qua_trinh_moi` là **hai FK riêng đến cùng bảng**; nhãn vai trò cũ/mới rõ, mỗi sự kiện có tối đa một đợt cũ/mới, không vẽ nhầm thành N–N.
- [ ] **W1-T1-12 · 13/11 · Ánh xạ ER → quan hệ:** Viết lược đồ từng bảng, chỉ ra PK/FK, cách ánh xạ 1–N và quan hệ cư dân–hộ theo thời gian; kiểm tra không có quan hệ vẽ trên ERD mà thiếu cột FK. **Bàn giao:** phần ánh xạ trong data dictionary.
- [ ] **W1-T1-13 · 13/11 · Từ điển dữ liệu:** Liệt kê **từng cột của cả 7 bảng**: tên, kiểu PostgreSQL, bắt buộc/null, PK/FK/UNIQUE/CHECK/DEFAULT, mô tả, miền giá trị, bảng tham chiếu. **Đạt:** TV2 có thể sinh dữ liệu mà không phải đoán kiểu hay ý nghĩa cột.
- [ ] **W1-T1-14 · 13/11 · Phụ thuộc hàm và 3NF:** Xác định khóa ứng viên, phụ thuộc hàm từ khóa tới thuộc tính; chỉ ra vì sao đạt 1NF/2NF/3NF hoặc sửa mô hình nếu chưa đạt; tránh khẳng định 3NF chỉ vì có PK. **Bàn giao:** mục chuẩn hóa riêng.
- [ ] **W1-T1-15 · 13–14/11 · Soát DDL v0:** Đối chiếu `sql/01_schema.sql` với ERD/data dictionary từng bảng; thống nhất tên cột, miền giá trị, khóa ngoại, chỉ mục; chỉnh dự thảo và ghi thay đổi, **chưa tự ý khóa schema**.
- [ ] **W1-T1-16 · 14/11 · Kiểm tra các ràng buộc còn thiếu:** Lập danh sách việc phải làm ở `02_constraints.sql`: chống khoảng chồng lấn cùng loại, cùng cư dân ở sự kiện nội bộ, ngày biến động phù hợp, transaction; ghi phương án khả thi (exclusion constraint/trigger + test) và giới hạn.
- [ ] **W1-T1-17 · 14/11 · Đối chiếu truy vấn:** Nhờ TV2 và TV3 chỉ rõ 10 SQL/10 RA có thiếu trường, thiếu quan hệ, thiếu trường hợp kiểm thử hay không; xử lý phản hồi **trước khi sinh dữ liệu**.
- [ ] **W1-T1-18 · 14–15/11 · Hoàn thiện Chương 1–3 dạng bản nháp:** Chương 1 (nghiệp vụ/chức năng), Chương 2 (ERD), Chương 3 (ánh xạ/bảng/ràng buộc/3NF); gắn TODO rõ cho phần dữ liệu do TV2 làm sau.
- [ ] **W1-T1-19 · 15/11 · Tổ chức Gate 1:** Họp 3 người, chốt quyết định về quy tắc thời gian, sơ đồ, tên bảng/cột và 10+10 câu hỏi; ghi `meetings/decision_log.md` kèm reviewer, ngày, file/commit.
- [ ] **W1-T1-20 · 15/11 · Phát hành schema v1:** Gắn nhãn `schema v1` trong tài liệu/commit và thông báo TV2/TV3; từ đây mọi đổi khóa/cột phải có đồng ý chung. **Đạt:** TV2/TV3 xác nhận có thể triển khai trên v1.

**Bộ bàn giao tuần 1 của TV1:** `docs/03_dac_ta_nghiep_vu.md`, `diagrams/phan_ra_chuc_nang.*`, `diagrams/erd_v1.*`, `docs/04_data_dictionary_va_chuan_hoa.md`, `sql/01_schema.sql` (v1), phần Chương 1–3 bản nháp, biên bản Gate 1.

## W1 / TV2 — Dữ liệu mô phỏng, SQL và kiểm thử: chuẩn bị trước khi triển khai

**Reviewer chính: TV1 kiểm tra thống nhất schema; TV3 soát bao phủ câu hỏi và test.**

- [ ] **W1-T2-01 · 10–11/11 · Thiết lập máy:** Cài PostgreSQL >= 15 và pgAdmin/DBeaver (hoặc CLI); ghi hệ điều hành, bản PostgreSQL, công cụ quản trị; xác nhận kết nối DB thử và chạy `SELECT version();`.
- [ ] **W1-T2-02 · 11/11 · Đọc schema v0:** Kiểm tra 7 bảng, khóa PK/FK, miền giá trị, `CHECK`; liệt kê cột nào cần TV1 giải thích trước khi sinh dữ liệu; không tự sửa quan hệ trong repo.
- [ ] **W1-T2-03 · 11/11 · Chốt danh sách QSQL01–10:** Với từng câu, viết **câu hỏi tiếng Việt có ý nghĩa nghiệp vụ**, bảng sử dụng, thuộc tính hiển thị, tiêu chí lọc, thứ tự kết quả nếu cần; không chỉ ghi tên kỹ thuật SQL.
- [ ] **W1-T2-04 · 11–12/11 · Ma trận truy vấn–bảng:** Tạo bảng 10 hàng cho QSQL01–10, cột `bảng`, `JOIN`, `WHERE`, `GROUP BY/HAVING`, `EXISTS`, `LEFT JOIN`, dữ liệu bắt buộc; phát hiện câu nào trùng ý nghĩa hoặc quá đơn giản.
- [ ] **W1-T2-05 · 12/11 · Quy ước ngày và kết quả:** Dùng `2026-11-20` làm ngày so sánh cố định; quy định tính “đang ở” theo cả bắt đầu/kết thúc; quyết định các trường xuất hiện trong kết quả cho từng truy vấn.
- [ ] **W1-T2-06 · 12/11 · Chống trùng bản ghi:** Phân biệt `DISTINCT` theo **mã cư dân** chứ không theo họ tên; dự tính `COUNT(DISTINCT ma_cu_dan)` khi join có thể lặp dòng.
- [ ] **W1-T2-07 · 12–13/11 · Kế hoạch sinh dữ liệu:** Phân bổ quy mô tham khảo: 8 tổ, 50 địa chỉ, 60 nhóm hộ, 200 cư dân, 250 đợt, 70 sự kiện, 5 tài khoản; nêu lý do dữ liệu đủ phủ kiểm thử, không coi số bản ghi là mục tiêu tự thân.
- [ ] **W1-T2-08 · 13/11 · Thứ tự sinh/nạp:** Vạch quy trình phụ thuộc FK: tổ → địa chỉ → hộ; cư dân và tài khoản → đợt cư trú → biến động; quyết định một cách nạp duy nhất (CSV + `\copy` **hoặc** INSERT SQL) để tránh nạp hai lần.
- [ ] **W1-T2-09 · 13/11 · Sinh dữ liệu tái lập:** Chốt `random.seed(20261110)` hoặc số cố định, mã ID duy nhất, nguồn tên/địa chỉ giả; thống nhất không tạo CCCD/số điện thoại thật.
- [ ] **W1-T2-10 · 13–14/11 · Bộ dữ liệu kiểm chứng nhỏ:** Thiết kế **15–30 bản ghi có đáp án tính tay** cho những tình huống cốt lõi (địa chỉ trống, người ở nhiều hộ, trùng tên, cư trú đã kết thúc, người không có đợt), **chưa cần hoàn thành dữ liệu lớn**.
- [ ] **W1-T2-11 · 13–14/11 · Ma trận S01–S16:** Với mỗi kịch bản dương, xác định ID test, điều kiện đầu vào, dữ liệu cần có, kết quả dự kiến, QSQL/QRA được kiểm chứng; điền rõ trong `tests/test_scenarios.md` hoặc tài liệu riêng.
- [ ] **W1-T2-12 · 14/11 · Lập kế hoạch test S17–S21:** Tách trách nhiệm: S17–S19 kiểm tra lỗi toàn vẹn TV1 chủ trì; S20–S21 là bảo mật TV3; TV2 hỗ trợ ghi kết quả kiểm thử.
- [ ] **W1-T2-13 · 14/11 · Review ERD với TV1:** Soát `JOIN` từ cư dân đến tổ dân phố, kết nối đôi của sự kiện nội bộ, yêu cầu nhóm hộ không có ai và địa chỉ không có hộ; lập danh sách lỗi/đề nghị sửa có dẫn chứng.
- [ ] **W1-T2-14 · 15/11 · Bàn giao kế hoạch:** Nộp `docs/05_ke_hoach_du_lieu_va_sql.md` gồm QSQL01–10, ma trận test, hướng sinh dữ liệu, cách nạp; xác nhận schema v1 đủ điều kiện code.

**Bộ bàn giao tuần 1 của TV2:** Xác nhận môi trường, `docs/05_ke_hoach_du_lieu_va_sql.md`, ma trận QSQL–S01…S21, nhận xét ERD, xác nhận Gate 1. **Chưa yêu cầu TV2 viết xong 10 SQL hoặc 643 bản ghi trong tuần 1.**

## W1 / TV3 — Đại số quan hệ, bảo mật: lập đặc tả và kiểm tra thiết kế

**Reviewer chính: TV1 kiểm tra biểu thức và tính khả thi trên ERD; TV2 góp ý dữ liệu kiểm chứng.**

- [ ] **W1-T3-01 · 10–11/11 · Đọc đề bài và schema:** Nắm rõ 7 thực thể, khóa, 6 yêu cầu cô; xác định những quan hệ phải kết nối để trả lời câu hỏi bằng đại số quan hệ.
- [ ] **W1-T3-02 · 11/11 · Chốt QRA01–10:** Đảm bảo 10 câu hỏi có ý nghĩa thực tiễn; không làm 10 câu chỉ là chọn/chiếu đơn giản; giữ đúng danh sách đã chốt trong đề cương hoặc ghi thay đổi.
- [ ] **W1-T3-03 · 11–12/11 · Ma trận toán tử:** Đánh dấu mỗi QRA dùng `σ` chọn, `π` chiếu, `⋈` kết nối, `ρ` đổi tên/tự kết nối, `∪` hợp, `∩` giao, `−` hiệu; có **ít nhất** nối, chọn, chiếu và độ đa dạng đầy đủ như cô yêu cầu.
- [ ] **W1-T3-04 · 12/11 · Kiểm tra kiểu tập hợp:** Với hợp/giao/hiệu, hai đầu vào phải cùng thuộc tính/miền tương ứng; dùng **mã cư dân**, không gộp hai người trùng tên.
- [ ] **W1-T3-05 · 12/11 · Quy ước thời gian cho RA:** Xác định câu nào là “đang” tại `d = 2026-11-20` và câu nào xét lịch sử; đảm bảo QRA01/02/08/09 không nhầm `ngay_ket_thuc IS NULL` với đợt đang hiệu lực.
- [ ] **W1-T3-06 · 12–13/11 · Làm thử 2 câu khó:** Viết biểu thức nháp đầy đủ cho **QRA04** (tự nối người ở hai hộ) và **QRA09** (từng cư trú nhưng không còn hiệu lực); soát tương thích thuộc tính/đổi tên.
- [ ] **W1-T3-07 · 13/11 · Rà soát câu QRA10:** Xác nhận mô hình truy được tổ dân phố của **đợt cũ và đợt mới** bằng hai nhánh JOIN; nếu không, phản hồi TV1 trước khi khóa schema.
- [ ] **W1-T3-08 · 13/11 · Lý thuyết bảo mật trọng tâm:** Liệt kê rủi ro lộ hồ sơ cư dân, sửa trái phép, lạm quyền; phân biệt **bảng `tai_khoan` nghiệp vụ** và **role PostgreSQL** thực thi quyền thật.
- [ ] **W1-T3-09 · 13–14/11 · Kịch bản B1:** Thiết kế `role` chỉ được `SELECT`, thử `SELECT` thành công và `UPDATE` thất bại; xác định user thử **không sở hữu bảng**, không có quyền đặc biệt.
- [ ] **W1-T3-10 · 13–14/11 · Kịch bản B2:** Thiết kế VIEW tổng hợp số dân theo tổ, không lộ tên/ngày sinh; role báo cáo chỉ được SELECT VIEW, SELECT bảng gốc bị từ chối; lập danh sách ảnh cần chụp.
- [ ] **W1-T3-11 · 14/11 · Xác minh tính khả thi PG:** Đọc tài liệu PostgreSQL về `CREATE ROLE`, `GRANT`, `REVOKE`, `CREATE VIEW`, quyền schema và view; ghi link tài liệu thực sự đã xem, không cần chạy demo hoàn chỉnh tuần này.
- [ ] **W1-T3-12 · 14/11 · Review ERD độc lập:** Kiểm tra PK/FK, bội số và tính tùy chọn, logic hai FK cũ/mới, loại sự kiện, khoảng ngày, khả năng biểu diễn đủ các QRA; gửi lỗi cụ thể cho TV1.
- [ ] **W1-T3-13 · 14–15/11 · Review test dữ liệu TV2:** Kiểm tra các tình huống S04/S06/S07/S09/S10/S13 có dữ liệu dương và âm cần thiết, không làm phép toán cho kết quả rỗng vô nghĩa.
- [ ] **W1-T3-14 · 15/11 · Bàn giao đặc tả:** Tạo `docs/06_dai_so_quan_he_va_bao_mat.md` gồm QRA01–10, ma trận toán tử, 2 câu nháp, kế hoạch B1/B2; xác nhận Gate 1 sau khi TV1 sửa nhận xét.

**Bộ bàn giao tuần 1 của TV3:** Đề bài 10 QRA + toán tử, 2 biểu thức nháp, kế hoạch B1/B2, phiếu review ERD, xác nhận Gate 1.

## W1 / Cả nhóm — họp và nghiệm thu ngày 15/11

- [ ] **W1-G-01 · G0:** Điền tên, MSSV 3 thành viên, mã lớp, **số thứ tự nhóm thực tế** vào các vị trí `[TODO]`; lập người phụ trách dự phòng.
- [ ] **W1-G-02:** Tạo GitHub quyền cộng tác cho cả 3; các thư mục `.gitkeep` có thể thay bằng file thật khi làm; thống nhất đặt tên branch/commit, không ghi đè bản đang review.
- [ ] **W1-G-03:** Họp kiểm tra xung đột: 10 QRA/10 SQL có thực hiện được trên cùng schema và dữ liệu dự kiến không? Nếu thiếu, sửa ERD và DDL trước khi khóa.
- [ ] **W1-G-04:** Chốt và lưu **biên bản Gate 1** gồm 5 mục: đặc tả, cây chức năng, ERD, data dictionary + 3NF, schema v1 và 10+10 câu hỏi đã duyệt.
- [ ] **W1-G-05:** TV1 bàn giao schema cho TV2/TV3, ghi rõ tên bảng/cột, kiểu, ngày tham chiếu, bộ kịch bản; không có thay đổi thầm lặng sau 15/11.

---

# TUẦN 2 — 16–22/11: TRIỂN KHAI CSDL, DỮ LIỆU, 20 TRUY VẤN VÀ BẢO MẬT SƠ BỘ (G2)

## W2 / TV1 — DDL, ràng buộc nâng cao và kiểm soát chất lượng thiết kế

**Reviewer chính: TV2 kiểm chứng nạp dữ liệu; TV3 kiểm tra tính đúng nghiệp vụ.**

- [ ] **W2-T1-01 · 16/11:** Tạo database mới `csdl17_cu_tru_demo`, ghi rõ phiên bản PostgreSQL và cách tạo từ đầu; không làm việc trực tiếp trên database chứa kết quả minh chứng cuối.
- [ ] **W2-T1-02 · 16–17/11:** Chạy `sql/01_schema.sql` từ DB trắng, kiểm tra đủ 7 bảng và thứ tự FK; chạy lại có hành vi dự kiến; chụp/trích kết quả `\dt` hoặc danh sách bảng.
- [ ] **W2-T1-03 · 17/11:** Kiểm thử PK, FK, UNIQUE, NOT NULL, CHECK cơ bản bằng trường hợp hợp lệ và vi phạm (transaction rollback), ghi đầu ra lỗi thật.
- [ ] **W2-T1-04 · 17–18/11:** Hoàn thiện `02_constraints.sql` để ngăn **hai đợt cùng loại của cùng cư dân chồng lấn**; lựa chọn `EXCLUDE USING gist`/trigger hoặc cơ chế khác phù hợp, giải thích vì sao `CHECK` một hàng không đủ.
- [ ] **W2-T1-05 · 18/11:** Ràng buộc `CHUYEN_NOI_BO`: hai FK tồn tại, thuộc cùng người, khác hộ; kiểm tra loại sự kiện/hình dạng hai FK đã có trong DDL; bổ sung test âm cho trường hợp sai.
- [ ] **W2-T1-06 · 18–19/11:** Kiểm tra thứ tự thời gian: sự kiện chuyển đến/đi/nội bộ và đợt cũ/mới không mâu thuẫn theo quy tắc nhóm đã chốt; nếu có quy tắc chỉ kiểm bằng transaction/thủ tục, ghi rõ giới hạn.
- [ ] **W2-T1-07 · 19/11:** Viết ví dụ transaction `BEGIN…COMMIT` cho chuyển nội bộ gồm đóng đợt cũ, tạo đợt mới, ghi biến động; kiểm tra khi lỗi thì rollback, tránh trạng thái nửa vời.
- [ ] **W2-T1-08 · 19/11:** Soát trường hợp đặc biệt: cư dân sinh sau ngày bắt đầu (nếu nhóm chốt cấm), ngày `NULL`, ngày bắt đầu tương lai, trùng tên/khác ID, hộ gắn địa chỉ lịch sử; xử lý trong schema/test hoặc ghi lý do loại khỏi phạm vi.
- [ ] **W2-T1-09 · 19–20/11:** Viết `sql/06_validation.sql` kiểm tra vi phạm FK, chồng lấn, biến động tham chiếu sai, ngày sai; phối hợp TV2 bổ sung kiểm tra số bản ghi/case rỗng.
- [ ] **W2-T1-10 · 20/11:** Review bộ dữ liệu sinh của TV2: số bản ghi, FK, mốc ngày, có S01–S16; yêu cầu sửa dữ liệu nếu truy vấn ra kết quả không đáng tin.
- [ ] **W2-T1-11 · 20–21/11:** Chạy kiểm thử **S17/S18/S19** trong DB test: FK không tồn tại, ngày kết thúc nhỏ hơn bắt đầu, sự kiện có hai FK `NULL`; lưu kết quả PostgreSQL từ chối đúng.
- [ ] **W2-T1-12 · 21/11:** Kiểm thử bổ sung ràng buộc xuyên bảng và rollback chuyển nội bộ: ít nhất một ca đúng, một ca cố ý sai; ghi expected/actual và sửa lỗi.
- [ ] **W2-T1-13 · 21/11:** Hoàn thành phần phụ thuộc hàm, chứng minh 3NF và bản giải thích lựa chọn 7 bảng; soát tên cột khớp code và ERD.
- [ ] **W2-T1-14 · 21–22/11:** Hoàn thiện **Chương 1–3** (trừ bảng/ảnh dữ liệu TV2 phụ trách), nhận xét của TV2/TV3 phải được xử lý và đánh dấu.
- [ ] **W2-T1-15 · 22/11:** Kiểm tra G2 theo ma trận yêu cầu của cô: không thiếu 10 RA, 10 SQL, 2 demo, phần ràng buộc; lập danh sách lỗi còn lại có owner và hạn sửa trước 24/11.

## W2 / TV2 — Sinh dữ liệu, 10 SQL, kết quả kiểm thử

**Reviewer chính: TV3 đối soát tập kết quả; TV1 duyệt dữ liệu và sự nhất quán với schema.**

- [ ] **W2-T2-01 · 16/11:** Chốt môi trường chạy, xuất hướng dẫn ngắn trong `data/README.md` về PostgreSQL/Python, thứ tự nạp và lệnh kiểm tra; không đưa thông tin đăng nhập vào GitHub public.
- [ ] **W2-T2-02 · 16–17/11:** Viết `scripts/generate_data.py` với seed cố định, định dạng CSV UTF-8, ID nhất quán và tham chiếu FK có tồn tại.
- [ ] **W2-T2-03 · 17/11:** Sinh **bộ kịch bản 15–30 bản ghi kiểm chứng bằng tay** trước; viết bảng người/hộ/tổ/ngày và kết quả mong đợi cho RA/SQL tiêu biểu.
- [ ] **W2-T2-04 · 17–18/11:** Sinh 7 tập dữ liệu mô phỏng đủ S01–S16, mục tiêu ~643 bản ghi khi cần; bảo đảm không làm mất các case âm/dương do nạp random.
- [ ] **W2-T2-05 · 18/11:** Hoàn thiện `sql/03_seed.sql` hoặc lệnh `\copy`/script nạp CSV, thống nhất không nạp dữ liệu hai lần; nêu cách reset DB và chạy lại.
- [ ] **W2-T2-06 · 18/11:** Chạy kiểm tra số bản ghi từng bảng; kiểm tra không có FK mồ côi, ngày không hợp lệ, ID trùng; lưu output vào `tests/final_test_log.md`.
- [ ] **W2-T2-07 · 18–19/11:** Hoàn thiện **QSQL01–QSQL03**: danh sách hiện tại theo tổ, hộ có >=4 người, thống kê theo tổ; kiểm tra `COUNT(DISTINCT)` và ngày tham chiếu.
- [ ] **W2-T2-08 · 19/11:** Hoàn thiện **QSQL04–QSQL05**: địa chỉ chưa có hộ, cư dân từng cư trú >=2 hộ; có ca dữ liệu cụ thể và giải thích `NOT EXISTS`/`HAVING`.
- [ ] **W2-T2-09 · 19–20/11:** Hoàn thiện **QSQL06–QSQL07**: người có hai loại cư trú trong lịch sử, từng cư trú nhưng hiện không còn đợt hiệu lực; đối chiếu người chưa từng có đợt để không gộp sai.
- [ ] **W2-T2-10 · 20/11:** Hoàn thiện **QSQL08–QSQL10**: sự kiện theo tháng/loại, chuyển nội bộ giữa hai tổ, sự kiện theo tài khoản kể cả tài khoản chưa ghi sự kiện.
- [ ] **W2-T2-11 · 20–21/11:** Với **mỗi** QSQL: thêm comment câu hỏi, mã truy vấn, cột đầu ra, điều kiện thời gian, câu SQL đầy đủ; chạy ra kết quả thực, không để `TODO`.
- [ ] **W2-T2-12 · 20–21/11:** Xây dựng bảng `QSQLxx → Sxx → expected → actual`, kiểm tra kết quả bằng tay trên bộ nhỏ; lưu ít nhất 1 ca bị loại đúng để tránh truy vấn “ra nhiều dòng là đúng”.
- [ ] **W2-T2-13 · 21/11:** Soát thứ tự join, khả năng nhân bản ghi, alias khi JOIN nhiều lần, `NULL`, `DISTINCT`, `GROUP BY`; tránh phụ thuộc vào thứ tự row nếu không `ORDER BY`.
- [ ] **W2-T2-14 · 21/11:** Chạy đối soát sơ bộ với TV3 cho các câu liên quan đại số quan hệ; nếu kết quả khác, phân biệt khác nhau do **tập hợp vs multiset**, `NULL`, bộ lọc ngày hay lỗi join.
- [ ] **W2-T2-15 · 21–22/11:** Viết **Chương 3.5** (dữ liệu mô phỏng) và **Chương 5** (10 câu SQL), đủ câu hỏi, truy vấn, kết quả/nhận xét; bàn giao file nguồn để TV1 tích hợp.
- [ ] **W2-T2-16 · 22/11:** Dọn dữ liệu test âm khỏi DB chính, khóa bộ CSV/seed, QSQL01–10 phiên bản duyệt; ghi rõ các lỗi chưa sửa và người xử lý ở Gate 2.

## W2 / TV3 — Hoàn thiện 10 đại số quan hệ và chạy thử 2 demo bảo mật

**Reviewer chính: TV1 soát phép toán/schema; TV2 so sánh kết quả với dữ liệu.**

- [ ] **W2-T3-01 · 16/11:** Ghi quy ước ký hiệu RA, tập thuộc tính, phép đổi tên, `d = 2026-11-20`; thống nhất câu “đã từng” và “đang” theo logic ngày.
- [ ] **W2-T3-02 · 16–17/11:** Hoàn thiện **QRA01–QRA03**: lọc/chiếu/nối theo tổ, loại cư trú, ngày sinh; kiểm tra đầy đủ JOIN liên hệ cư dân–đợt–hộ–địa chỉ–tổ.
- [ ] **W2-T3-03 · 17–18/11:** Hoàn thiện **QRA04–QRA06**: tự nối hai nhóm hộ khác nhau, phép hiệu địa chỉ không có hộ, phép hiệu cư dân chưa từng có đợt; dùng `ρ` tránh nhập nhằng.
- [ ] **W2-T3-04 · 18–19/11:** Hoàn thiện **QRA07–QRA09**: phép giao hai loại cư trú, phép hợp cư dân tổ 1/2, phép hiệu người từng cư trú nhưng không còn hiệu lực; kiểm tra hai toán hạng đồng cấu trúc.
- [ ] **W2-T3-05 · 19–20/11:** Hoàn thiện **QRA10**: sự kiện chuyển nội bộ có đợt cũ/mới thuộc hai tổ khác nhau; biểu diễn rõ đường nối riêng cho mỗi đợt.
- [ ] **W2-T3-06 · 20/11:** Với mỗi QRA thêm 8 mục: câu hỏi, thời điểm, đầu vào/thuộc tính, biểu thức, diễn giải từng phép, kết quả kỳ vọng, SQL kiểm chứng, người kiểm tra; trình bày công thức đọc được trên bản PDF.
- [ ] **W2-T3-07 · 20–21/11:** Viết 10 câu SQL **kiểm chứng tương đương** RA (không thay cho 10 câu SQL của TV2); so sánh theo tập mã khóa và `DISTINCT`, lưu bảng đối soát đúng/sai.
- [ ] **W2-T3-08 · 20/11:** Hoàn thiện script B1 tạo role báo cáo/thống kê chỉ đọc (không là owner/superuser), `GRANT SELECT`, thử `SELECT` thành công và `UPDATE` thất bại bằng đúng role.
- [ ] **W2-T3-09 · 20–21/11:** Hoàn thiện B2 tạo VIEW tổng hợp theo tổ (không lộ tên/ngày sinh); `GRANT SELECT` trên view, **không** cấp SELECT bảng gốc, thử xem VIEW thành công và bảng gốc bị chặn.
- [ ] **W2-T3-10 · 21/11:** Kiểm tra quyền `USAGE` schema, quyền mặc định/public, owner và role thực tế; tránh demo giả bằng cách chỉ viết code mà không đổi phiên đăng nhập.
- [ ] **W2-T3-11 · 21/11:** Kiểm tra chéo S01–S16 của TV2, đặc biệt `EXCEPT`/`INTERSECT`, người trùng tên, người không có đợt; phản hồi các tình huống thiếu dữ liệu.
- [ ] **W2-T3-12 · 21–22/11:** Viết **Chương 4** (RA) và bản nháp **Chương 6** (rủi ro, phân quyền, VIEW, hạn chế), chuẩn bị trích dẫn thật từ giáo trình/docs PostgreSQL.
- [ ] **W2-T3-13 · 22/11:** Giao `sql/05_security.sql`, 10 biểu thức RA + báo cáo đối soát, xác nhận demo B1/B2 ít nhất đã chạy thử; liệt kê vấn đề cần sửa trước 24/11.

## W2 / Cả nhóm — Gate 2 (22/11)

- [ ] **W2-G-01:** Chạy và kiểm tra ít nhất một lần DDL → nạp dữ liệu → QSQL → RA đối soát → demo bảo mật, ghi mọi lỗi bằng ID/owner/hạn.
- [ ] **W2-G-02:** 10 SQL + 10 RA phải có **lời giải đầy đủ**, không chỉ 10 tiêu đề; hai demo bảo mật có **script thực thi**.
- [ ] **W2-G-03:** TV1 xác nhận DDL/ERD/data dictionary thống nhất, TV2 xác nhận dữ liệu/10 SQL, TV3 xác nhận 10 RA/demo; ghi biên bản Gate 2.

---

# TUẦN 3 — 23–27/11: KIỂM THỬ, MINH CHỨNG, BÁO CÁO, NỘP VÀ BẢO VỆ (G3–G4)

## W3 / TV1 — Nghiệm thu hệ thống, tổng hợp báo cáo và nộp

**Reviewer: TV2 soát SQL/dữ liệu; TV3 soát RA/bảo mật và bố cục.**

- [ ] **W3-T1-01 · 23/11:** Thu đủ sản phẩm, PR và chương báo cáo từ TV2/TV3; mỗi file có version/owner, không còn phần mâu thuẫn schema.
- [ ] **W3-T1-02 · 23/11:** Chạy lại `01_schema.sql` và `02_constraints.sql` trên DB mới; kiểm tra ràng buộc S17–S19, ca chồng lấn/sự kiện khác người, rollback giao dịch.
- [ ] **W3-T1-03 · 23–24/11:** Chủ trì buổi chạy **end-to-end trên DB trắng**: tạo DB → schema → constraints → seed → validation → 10 SQL → 2 bảo mật; không chấp nhận chỉ chạy trên DB cũ đã chỉnh tay.
- [ ] **W3-T1-04 · 24/11:** Rà lại ERD với DDL cuối: mọi tên, kiểu cột, khóa, bản số, NULL/NOT NULL khớp; không để ảnh sơ đồ phiên bản cũ trong báo cáo.
- [ ] **W3-T1-05 · 24/11:** Rà lại chuẩn hóa 3NF, ràng buộc liên bảng, dữ liệu ở mỗi loại sự kiện và `NULL` trước tương tác ra SQL; ghi các giới hạn còn lại trung thực.
- [ ] **W3-T1-06 · 24/11:** Chủ trì Gate 3, ký xác nhận kỹ thuật: **10 SQL đúng, 10 RA đã đối soát, 2 demo bảo mật thật, 21 kịch bản được xử lý**, không có lỗi nghiêm trọng mở.
- [ ] **W3-T1-07 · 24–25/11:** Hoàn thiện Chương 1–3, kết luận, mở đầu, phạm vi; tích hợp Chương 4 từ TV3, 5 từ TV2, 6 từ TV3.
- [ ] **W3-T1-08 · 25/11:** Chuẩn hóa văn bản: cách đặt tên bảng/cột, số chương/mục, bảng/hình, caption, mục lục, danh sách bảng/hình nếu dùng, nhất quán phông/tiêu đề, không có `[TODO]`/đoạn mẫu.
- [ ] **W3-T1-09 · 25/11:** Kiểm tra từng ảnh minh chứng SQL/bảo mật có câu hỏi, code thực thi, kết quả/hình rõ; tránh chụp ảnh thiếu ngữ cảnh hoặc quá bé khi in A4.
- [ ] **W3-T1-10 · 25/11:** Hoàn thành bìa: trường, môn, tên đề tài, **mã lớp**, **STT NHÓM**, danh sách 3 thành viên MSSV/họ tên, tên giảng viên; kiểm tra chính tả.
- [ ] **W3-T1-11 · 25–26/11:** Hoàn thành **TRANG CUỐI** báo cáo: bảng phân công chi tiết theo sản phẩm, đánh giá mức đóng góp/xếp loại A, B, C… và **chữ ký của từng người**; không nhầm trang cuối với phụ lục.
- [ ] **W3-T1-12 · 25–26/11:** Kết xuất PDF báo cáo, rà soát trực quan từng trang (mục lục, ERD, công thức RA, bảng dài, chú thích); lưu bản nguồn + bản PDF duy nhất trong `report/`.
- [ ] **W3-T1-13 · 26/11:** Chuẩn bị bản in **A4, in 2 mặt, đóng quyển, KHÔNG bìa cứng, KHÔNG bìa mica**, tờ bìa bằng A4 thông thường; kiểm tra bản in trước nộp.
- [ ] **W3-T1-14 · 26/11:** Kiểm tra gói bàn giao: báo cáo PDF, các file nguồn, SQL, CSV/seed, hướng dẫn chạy, ảnh minh chứng; lưu phiên bản cuối và backup khác máy.
- [ ] **W3-T1-15 · 27/11:** Nộp bản mềm lên **Assignment**, giao bản cứng theo hướng dẫn trước tiết 3; lưu xác nhận nộp. Phối hợp cả nhóm báo cáo từ ngày 27/11 theo thứ tự cô công bố.

## W3 / TV2 — Test từ DB trắng, chụp SQL và viết báo cáo phần mình

- [ ] **W3-T2-01 · 23/11:** Clone/copy repo vào thư mục mới, dựng DB từ đầu theo README, không lấy DB đã nạp sẵn; báo lỗi bước nào chưa tái tạo được.
- [ ] **W3-T2-02 · 23/11:** Chạy lại seed cố định; đối chiếu số bản ghi từng bảng, S01–S16, FK, ngày, dữ liệu trùng tên; lưu kết quả ra log.
- [ ] **W3-T2-03 · 23–24/11:** Chạy lần lượt QSQL01–10, mỗi câu có kết quả thực, số bản ghi, ngày tham chiếu, so với đáp án dự kiến; sửa câu sai trước Gate 3.
- [ ] **W3-T2-04 · 24/11:** Chụp **10 minh chứng SQL** đặt tên `QSQL01_result.png` … `QSQL10_result.png` (hoặc thay bằng bảng xuất thực kiểm thử theo yêu cầu báo cáo); phải nhìn rõ câu lệnh, kết quả và công cụ.
- [ ] **W3-T2-05 · 24/11:** Hoàn thiện `tests/final_test_log.md`: phiên bản PostgreSQL, ngày test, script chạy, ID test, expected/actual, pass/fail, link evidence, lỗi/commit sửa.
- [ ] **W3-T2-06 · 24/11:** Xác nhận test `NOT EXISTS`, `HAVING`, `LEFT JOIN`, `DISTINCT`, trường hợp kết quả rỗng và trùng tên; không bỏ qua vì một vài truy vấn đã có số dòng trả về.
- [ ] **W3-T2-07 · 24–25/11:** Chốt Chương 3 phần dữ liệu và Chương 5 SQL, chèn bảng/ảnh/nhận xét, gửi TV1 bản không còn TODO.
- [ ] **W3-T2-08 · 25/11:** Soát chéo phần RA của TV3 bằng 2–3 cặp dữ liệu/SQL đại diện; góp ý kết quả không đúng theo tập hợp.
- [ ] **W3-T2-09 · 25/11:** Soát báo cáo tổng thể về kết quả SQL và số bản ghi (không chỗ 643, chỗ 600 nếu data thực khác); đồng ý bản PDF cuối.
- [ ] **W3-T2-10 · 26/11:** Tập dượt giải thích tự viết 10 SQL, mối quan hệ khóa và bộ dữ liệu; chuẩn bị trả lời ít nhất 1 câu JOIN, 1 câu thống kê, 1 câu NOT EXISTS.
- [ ] **W3-T2-11 · 26–27/11:** Ký trang cuối, xác nhận phần đóng góp thực tế, hỗ trợ TV1 nộp/bảo vệ; không thay đổi SQL sau khi khóa trừ lỗi nghiêm trọng có biên bản.

## W3 / TV3 — Đối soát RA, bảo mật thực tế, báo cáo và bảo vệ

- [ ] **W3-T3-01 · 23/11:** Soát 10 biểu thức RA với DDL cuối, kiểm tra tên thuộc tính, điều kiện ngày, tập hợp đồng cấu trúc của `∪`, `∩`, `−`, phép đổi tên khi tự nối.
- [ ] **W3-T3-02 · 23–24/11:** Chạy SQL kiểm chứng 10 RA trên bộ dữ liệu cố định; đối chiếu theo tập ID và ghi pass/fail, không chỉ đối chiếu số dòng.
- [ ] **W3-T3-03 · 24/11:** Chạy B1 bằng role thật: SELECT được phép; UPDATE bị chặn; nếu role còn quyền ngoài ý muốn thì chỉnh lại quyền và chạy lại.
- [ ] **W3-T3-04 · 24/11:** Chạy B2 bằng role thật: SELECT VIEW tổng hợp thành công; SELECT bảng `cu_dan` gốc bị chặn; đảm bảo VIEW không hiển thị thông tin nhận diện.
- [ ] **W3-T3-05 · 24/11:** Lưu code và ảnh rõ `B1_select_ok.png`, `B1_update_denied.png`, `B2_view_ok.png`, `B2_table_denied.png`; ghi role thực hiện và lý do đúng/sai.
- [ ] **W3-T3-06 · 24/11:** Ghi lại kết quả S20/S21 trong test log, kiểm tra tên/tài khoản nghiệp vụ khác với role thực PostgreSQL; không commit mật khẩu thật.
- [ ] **W3-T3-07 · 24–25/11:** Hoàn thiện Chương 4 RA và Chương 6 bảo mật, gồm lý thuyết ngắn, 10 biểu thức, kết quả kiểm chứng, 2 demo/ảnh, nhận xét và nguồn tài liệu.
- [ ] **W3-T3-08 · 25/11:** Kiểm tra chéo toàn bộ schema/ERD của TV1 về quan hệ, NULL và ràng buộc thời gian; đánh dấu các lỗi đã được xử lý.
- [ ] **W3-T3-09 · 25/11:** Soát nguồn tham khảo dùng thật (giáo trình, tài liệu PostgreSQL); thống nhất định dạng với TV1, không dẫn nguồn không sử dụng.
- [ ] **W3-T3-10 · 26/11:** Tập dượt giải thích ít nhất 1 phép giao/hiệu, 1 tự nối, mô hình 2 FK cũ/mới, nguyên lý role/VIEW; có thể chạy lại 2 demo khi cô hỏi.
- [ ] **W3-T3-11 · 26–27/11:** Ký trang cuối, xác nhận đóng góp, đồng ý PDF cuối và tham gia buổi báo cáo theo lịch cô.

## W3 / Cả nhóm — kiểm soát nộp và bảo vệ

- [ ] **W3-G-01 · 24/11:** Gate 3 đạt: SQL (10/10); đại số (10/10); demo bảo mật (2/2); tình huống test (21/21 có kết quả hoặc giải thích xử lý cụ thể); rebuild sạch PASS.
- [ ] **W3-G-02 · 25/11:** Tất cả bảng/ảnh/công thức trong báo cáo đúng phiên bản code cuối; không có TODO/mẫu sai hoặc mô tả kết quả chưa chạy.
- [ ] **W3-G-03 · 26/11:** Gate 4 đạt: PDF đọc được, đúng quy cách bản in, bìa/trang cuối có đủ thông tin và chữ ký; tên file nộp đã thống nhất.
- [ ] **W3-G-04 · 26/11:** Mỗi thành viên tự trình bày 3–5 phút phần của mình; tất cả hiểu ERD, luồng từ bảng cư dân đến tổ và cách xác định đợt hiện hành.
- [ ] **W3-G-05 · 27/11:** Có bằng chứng bản mềm đã nộp, bản cứng đã giao, 3 thành viên sẵn sàng tham gia báo cáo; ghi nhận việc phát sinh nếu có.

---

## B. BẢNG KIỂM 20 CÂU TRUY VẤN (BẮT BUỘC)

**Với từng câu, chỉ tích khi có câu hỏi rõ, biểu thức/SQL hoàn chỉnh, trường hợp kiểm chứng và người soát.**

| Câu | Chủ đề / yêu cầu | Owner | Kiểm chứng |
|---|---|---|---|
| [ ] QRA01 | Cư dân đang cư trú tại Tổ 01 ngày d: chọn, chiếu, nối | TV3 | S01 |
| [ ] QRA02 | Cư dân đang tạm trú Tổ 02 ngày d | TV3 | S02 |
| [ ] QRA03 | Cư dân sinh trước ngày cắt và đang ở Tổ 01 | TV3 | S03 |
| [ ] QRA04 | Người từng ở ít nhất 2 hộ: tự nối, đổi tên | TV3 | S06 |
| [ ] QRA05 | Địa chỉ chưa có hộ: phép hiệu | TV3 | S04 |
| [ ] QRA06 | Người chưa từng có đợt cư trú: phép hiệu | TV3 | S10 |
| [ ] QRA07 | Người từng thường trú và tạm trú: phép giao | TV3 | S07, S08 |
| [ ] QRA08 | Người đang cư trú Tổ 01 hoặc Tổ 02: phép hợp | TV3 | S01, S02 |
| [ ] QRA09 | Người từng cư trú nhưng hiện không còn đợt hiệu lực | TV3 | S09 |
| [ ] QRA10 | Chuyển nội bộ giữa hai tổ: 2 nhánh nối cũ/mới | TV3 | S13 |
| [ ] QSQL01 | Cư dân đang cư trú tại một tổ ngày d | TV2 | S01, S02 |
| [ ] QSQL02 | Hộ có ít nhất 4 cư dân đang ở | TV2 | S14 |
| [ ] QSQL03 | Thống kê cư dân theo tổ, kể cả tổ không có người nếu yêu cầu | TV2 | S01, S15 |
| [ ] QSQL04 | Địa chỉ chưa có nhóm hộ | TV2 | S04 |
| [ ] QSQL05 | Người từng cư trú ít nhất 2 hộ | TV2 | S06 |
| [ ] QSQL06 | Người từng có cả thường trú và tạm trú | TV2 | S07, S08 |
| [ ] QSQL07 | Người từng cư trú nhưng hiện không còn hiệu lực | TV2 | S09 |
| [ ] QSQL08 | Sự kiện biến động theo tháng và loại | TV2 | S11–S13 |
| [ ] QSQL09 | Chuyển nội bộ giữa hai tổ khác nhau | TV2 | S13 |
| [ ] QSQL10 | Số sự kiện theo từng tài khoản, kể cả 0 sự kiện | TV2 | Số liệu demo + LEFT JOIN |

## C. 21 KỊCH BẢN KIỂM THỬ PHẢI CÓ BẰNG CHỨNG

**Ở mỗi ID phải có:** dữ liệu đầu vào/ca test, kết quả dự kiến, cách chạy, kết quả thực tế, PASS/FAIL, reviewer và liên kết ảnh/log.

| ID | Kịch bản | Chủ trì |
|---|---|---|
| [ ] S01 | Tổ 01 có người đang cư trú tại ngày d | TV2 |
| [ ] S02 | Tổ 02 có tạm trú và Tổ 01 có thường trú | TV2 |
| [ ] S03 | Có cư dân đạt điều kiện tuổi/ngày sinh | TV2 |
| [ ] S04 | Có địa chỉ chưa gán hộ nào | TV2 |
| [ ] S05 | Có hộ nhưng không có cư dân đang ở | TV2 |
| [ ] S06 | Có người từng ở 2 hộ trong 2 thời kỳ | TV2 |
| [ ] S07 | Có người từng có cả thường trú và tạm trú | TV2 |
| [ ] S08 | Có người chỉ thuộc 1 loại, không lọt tập giao | TV2 |
| [ ] S09 | Có người từng cư trú, hiện không còn đợt hiệu lực | TV2 |
| [ ] S10 | Có cư dân chưa từng có đợt cư trú | TV2 |
| [ ] S11 | Biến động `CHUYEN_DEN` đúng hình dạng FK | TV2 |
| [ ] S12 | Biến động `CHUYEN_DI` đúng hình dạng FK | TV2 |
| [ ] S13 | `CHUYEN_NOI_BO` cùng cư dân, hai hộ khác nhau | TV2; TV1 kiểm |
| [ ] S14 | Có hộ >=4 người và có hộ ít người | TV2 |
| [ ] S15 | Có tổ không phát sinh biến động trong tháng | TV2 |
| [ ] S16 | Hai cư dân trùng họ tên nhưng mã khác nhau | TV2 |
| [ ] S17 | FK không tồn tại → bị từ chối | TV1 |
| [ ] S18 | Kết thúc trước bắt đầu → bị từ chối | TV1 |
| [ ] S19 | Sự kiện có cả đợt cũ và mới NULL → bị từ chối | TV1 |
| [ ] S20 | Role chỉ đọc thử UPDATE → bị từ chối | TV3 |
| [ ] S21 | Role báo cáo xem VIEW được, không xem bảng gốc | TV3 |

**Kiểm thử nâng cao khuyến nghị:** cặp đợt cùng loại chồng lấn, cặp sự kiện cũ/mới khác cư dân, sự kiện sai ngày, chuyển nội bộ rollback khi lỗi. Những ca này rất quan trọng để chứng minh thiết kế chặt chẽ dù chưa có ID S22–S25 trong bản cũ.

---

## D. PHÂN CÔNG CÔNG BẰNG VÀ QUY TẮC REVIEW

| Hạng mục lớn | Owner | Reviewer | Sản phẩm cuối |
|---|---|---|---|
| Bài toán + chức năng + sơ đồ | TV1 | TV3 | Chương 1 + cây chức năng |
| ERD + ánh xạ + từ điển + 3NF | TV1 | TV2/TV3 | Chương 2, phần lớn Chương 3 |
| DDL + ràng buộc phức tạp | TV1 | TV2 | 01_schema + 02_constraints + test âm |
| Tạo dữ liệu + độ phủ test | TV2 | TV1/TV3 | CSV/seed + test S01–S16 |
| 10 SQL + ảnh + kết quả | TV2 | TV3 | 04_queries + Chương 5 |
| 10 RA + SQL đối soát | TV3 | TV1/TV2 | Chương 4 |
| 2 demo bảo mật + ảnh | TV3 | TV2 | 05_security + Chương 6 |
| Tổng hợp/sửa mẫu báo cáo/nộp | TV1 | TV2 + TV3 | PDF, bản cứng, xác nhận nộp |

- **Không chia đều theo số file hoặc số dòng code**: TV1 có khối lượng thiết kế/tích hợp, TV2 có khối lượng sinh dữ liệu/SQL và chạy thử, TV3 có lý thuyết RA khó + bảo mật thực thi + đối soát.
- Mỗi người nộp **đúng phần nội dung báo cáo do mình phụ trách**. TV1 chỉ chuẩn hóa định dạng và logic, không viết hộ toàn bộ phần của người khác.
- Nếu task trễ **quá 24 giờ**, owner thông báo ngay trên nhóm/GitHub, đề xuất người hỗ trợ và cập nhật deadline. Nếu ảnh hưởng schema, quyết định phải có ý kiến cả 3.
- Đánh giá đóng góp **cuối kỳ dựa trên đầu ra được nghiệm thu và sự phối hợp thực tế**, không mặc định ba người bằng nhau nếu thực tế khác; trang cuối phải có phân công, mức đóng góp/xếp loại và chữ ký thật.

### Mẫu cập nhật tiến độ hằng ngày (sao chép vào nhóm/GitHub)

```text
[Ngày: dd/mm/2026] [TV1/TV2/TV3]
Đã hoàn thành (mã việc): ...
Link file/commit/PR: ...
Reviewer: ...  |  Kết quả: TODO / DOING / REVIEW / DONE
Việc đang làm: ...
Lỗi/nguy cơ chặn công việc: ...
Hạn xử lý tiếp theo: ...
```

### Mẫu biên bản nghiệm thu Gate

```text
Gate: G1 / G2 / G3 / G4   | Ngày: ...
Sản phẩm cần đạt: ...
Link ERD / schema / seed / query / test / report: ...
Lỗi chưa khắc phục (ID, người sửa, hạn): ...
TV1 xác nhận: ...
TV2 xác nhận: ...
TV3 xác nhận: ...
Quyết định: PASS / PASS CÓ ĐIỀU KIỆN / FAIL
```

---

## E. ĐÁNH GIÁ ĐỘ PHỨC TẠP: ĐÃ ĐỦ CHƯA, CẦN TĂNG GÌ?

**Kết luận: ĐỦ và phù hợp cho bài tập lớn CSDL ở quy mô nhóm 3 người, nếu làm đúng các mục bắt buộc.** Không cần thêm bảng chỉ để tăng con số. Nhóm đã có:

1. **7 thực thể liên kết**, các quan hệ 1–N và quan hệ cư dân–hộ nhiều–nhiều được hiện thực qua `qua_trinh_cu_tru` có **thời gian**.
2. Cấu trúc phân cấp **tổ dân phố → địa chỉ → nhóm hộ**, cần phép nối nhiều bảng khi tra cứu cư dân.
3. **Nhật ký biến động** với hai vai trò FK **đợt cũ/đợt mới** và ba loại sự kiện; biểu diễn NULL có điều kiện.
4. **Ràng buộc đơn bảng** (PK, FK, NOT NULL, UNIQUE, CHECK) và **ràng buộc liên bảng/giữa nhiều dòng** (chồng lấn thời gian, cùng cư dân, thứ tự sự kiện).
5. **20 câu truy vấn học thuật**, trong đó có tự nối, tập hợp, truy vấn phủ định, tổng hợp, kiểm soát trùng.
6. **Hai cơ chế bảo mật thật trên PostgreSQL**: role/quyền và view hạn chế dữ liệu.

### Các điểm phải giải quyết để biến “đủ phức tạp” thành “thiết kế tốt”

- [ ] **C1 – Time semantics:** Tại ngày `d`, đợt “đang cư trú” có `ngay_bat_dau <= d` và (`ngay_ket_thuc IS NULL` hoặc `ngay_ket_thuc >= d`). Không chỉ lọc `ngay_ket_thuc IS NULL`.
- [ ] **C2 – No-overlap:** Chặn hai đợt cư trú *cùng loại* của một cư dân có khoảng thời gian giao nhau; nếu cho phép hai loại khác nhau đồng thời, phải nói rõ đây là quy ước mô phỏng và hệ quả.
- [ ] **C3 – Referential-event logic:** `CHUYEN_NOI_BO` phải tham chiếu hai đợt của cùng cư dân, khác hộ, đúng trật tự thời gian; `CHECK` đơn giản chỉ đảm bảo hình dạng cặp FK, chưa đủ kiểm liên bảng.
- [ ] **C4 – Transaction:** Các bước đóng đợt cũ, mở đợt mới và ghi biến động phải nhất quán; chứng minh rollback khi một bước lỗi.
- [ ] **C5 – Normalization:** Chứng minh 1NF–3NF bằng khóa, thuộc tính và phụ thuộc hàm; không lặp `ten_to`/`dia_chi_chuan` ở bảng lịch sử và biến động.
- [ ] **C6 – Data coverage:** Không chạy 10 truy vấn trên dữ liệu ngẫu nhiên cho ra kết quả rỗng; có bộ dữ liệu nhỏ với đáp án kiểm tay và các case âm/dương.
- [ ] **C7 – Security realism:** Dùng PostgreSQL role thật để kiểm `GRANT`, `REVOKE`, VIEW; đừng nhầm bảng `tai_khoan` mô phỏng với hệ thống cấp quyền database.
- [ ] **C8 – Evidence and report:** Đủ 10+10 câu, 2 demo, ảnh/code/result ăn khớp, nộp đủ hai hình thức và trang cuối chữ ký.

### Những thứ KHÔNG nên thêm trước khi hoàn thành C1–C8

- [ ] Không tự mở rộng ra quản lý khai sinh/tử vong, giấy phép, hộ khẩu pháp lý hoặc tích hợp cơ sở dữ liệu quốc gia.
- [ ] Không làm web/mobile, API, chatbot, OCR, machine learning nếu giảng viên không yêu cầu.
- [ ] Không thêm 3–5 bảng phụ chỉ để báo cáo nhìn “nhiều bảng” hoặc sinh hàng chục nghìn bản ghi khi chưa kiểm được tính đúng.

**Quy tắc dừng:** Khi Gate 3 đã PASS và Gate 4 sẵn sàng, chỉ sửa lỗi/thiếu minh chứng/hình thức. Không mở rộng chức năng mới sát ngày nộp.

---

## F. BẢNG TỔNG KẾT NGHIỆM THU CUỐI CÙNG

- [ ] Y1 — Trình bày bài toán thực tiễn, chức năng, sơ đồ phân rã chức năng.
- [ ] Y2 — ERD đủ thực thể, quan hệ, thuộc tính, cardinality/optionality.
- [ ] Y3 — Ánh xạ ER → quan hệ, 7 bảng mô tả đầy đủ, PK/FK/ràng buộc và chuẩn hóa.
- [ ] Y4 — **10/10** câu hỏi + biểu thức **đại số quan hệ** đúng, đa dạng toán tử và được kiểm chứng.
- [ ] Y5 — **10/10** câu hỏi + câu **SQL** đúng, đủ JOIN/WHERE/SELECT và phép mở rộng, có kết quả thật.
- [ ] Y6 — Lý thuyết bảo mật và **ít nhất 2 ví dụ thực thi trên chính CSDL**.
- [ ] Y7 — Báo cáo bìa đủ mã lớp, số thứ tự nhóm, họ tên/MSSV 3 người; trang cuối phân công, xếp loại, chữ ký.
- [ ] Y8 — Nộp bản mềm Assignment và bản cứng A4 hai mặt, đóng quyển, không bìa cứng/mica, đúng hạn tiết 3 ngày 27/11/2026.
- [ ] Y9 — Repo có hướng dẫn dựng DB sạch, script/dữ liệu/kiểm thử có thể tái tạo, không có dữ liệu cá nhân thật/mật khẩu.
- [ ] Y10 — Cả 3 thành viên trình bày được phần mình và hiểu sơ đồ/luồng dữ liệu chung.

**Sau khi hoàn tất:** Điền tên người thực hiện, ngày nghiệm thu, link commit/PR/ảnh cho các mục ở bảng trên rồi khóa tag/commit bản nộp cuối.

---

### Tài liệu nguồn cần đối chiếu khi có thay đổi

- Đề cương nội bộ: `docs/01_de_cuong.md` (phạm vi, mô hình, bộ 10 RA/SQL, S01–S21).
- Sườn báo cáo: `docs/02_bao_cao_suon.md`.
- Giao việc ban đầu: `docs/06_phan_cong_tien_do.md`.
- DDL hiện có: `sql/01_schema.sql`; các phần còn TODO: `sql/02_constraints.sql`, `sql/03_seed.sql`, `sql/04_queries.sql`, `sql/05_security.sql`.
- Yêu cầu chính thức về bài tập lớn, bản in và thời hạn: **ảnh thông báo giảng viên do nhóm cung cấp**. Nếu cô cập nhật yêu cầu, ưu tiên thông báo mới nhất.
