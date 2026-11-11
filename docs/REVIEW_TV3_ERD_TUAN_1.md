# PHIẾU REVIEW ERD VÀ BỘ BÀN GIAO TUẦN 1 CỦA TV1 — NGƯỜI REVIEW: TV3

**Ngày:** 11/11/2026. **Mã việc:** W1-T3-12 (checklist `docs/03_CHECKLIST_DU_AN.md`).
**Đối tượng review:** `diagrams/erd_v1.png` (bản 11/11/2026), `sql/01_schema.sql` v1-candidate, `docs/03_dac_ta_nghiep_vu.md` (B01–B18), `docs/04_data_dictionary_va_chuan_hoa.md`, `meetings/decision_log.md` (DEC01–DEC12), `docs/07_ma_tran_truy_van_va_review.md` (RV01–RV10).
**Phạm vi:** đọc tài liệu và đối chiếu với DDL. Đã chạy `sql/01_schema.sql` v1-candidate trên một DB trắng tạm thời (PostgreSQL 17.11) để kiểm tra `tests/ra_fixture.sql`; DB tạm đã xóa sau khi chạy.

**Kết luận:** ERD **đủ** để biểu diễn 10 câu QRA01–QRA10 và hai demo bảo mật B1/B2. **Không có lỗi chặn Gate 1.** Có 1 câu hỏi cho TV1 (E1) và 1 việc TV3 tự làm (E2).

---

## 1. Các điểm đã kiểm tra và đạt

| # | Nội dung | Kết quả |
|---|---|---|
| K1 | ERD khớp DDL: 7 bảng, tên cột, kiểu, PK, FK, UNIQUE; cột cho phép NULL (dấu `?`) đúng với cột không có `NOT NULL` trong DDL | Đạt |
| K2 | Bản số `to_dan_pho 1 — 0..N dia_chi`, `dia_chi 1 — 0..N ho_cu_tru` (B01) | Đạt |
| K3 | Quan hệ nhiều–nhiều cư dân–hộ được giải qua `qua_trinh_cu_tru`: `cu_dan 1 — 0..N`, `ho_cu_tru 1 — 0..N` (B02) | Đạt |
| K4 | Hai vai trò FK `ma_qua_trinh_cu` (đợt cũ) và `ma_qua_trinh_moi` (đợt mới) được vẽ thành **hai đường riêng, có nhãn**; phía sự kiện là `0..1` vì mỗi FK được phép NULL | Đạt |
| K5 | Hình dạng sự kiện (đến chỉ có đợt mới, đi chỉ có đợt cũ, nội bộ có cả hai và khác nhau) được chặn bằng `ck_bd_hinh_dang`; chú thích dưới ERD ghi đúng | Đạt |
| K6 | `ngay_bat_dau` là `NOT NULL`, chỉ `ngay_ket_thuc` được NULL. Điều này cho phép tạo quan hệ chuẩn bị `Q_d` không chứa NULL (xử lý RV08, xem mục 3) | Đạt |
| K7 | `tai_khoan` không có cột mật khẩu (B18); bảng này là tài khoản nghiệp vụ mô phỏng, tách biệt với role PostgreSQL (B14) | Đạt, khớp `docs/06b_bao_mat.md` mục 2.4 |
| K8 | VIEW của demo B2 cần đường nối `to_dan_pho → dia_chi → ho_cu_tru → qua_trinh_cu_tru`; ERD có đủ, không cần thêm bảng | Đạt |

## 2. ERD có trả lời đủ 10 câu QRA không

| Câu | Đường nối cần có trên ERD | Đủ? |
|---|---|---|
| QRA01, 02, 03, 08 | `cu_dan — qua_trinh_cu_tru — ho_cu_tru — dia_chi — to_dan_pho`, cùng `loai_cu_tru`, `ngay_sinh` | Đủ |
| QRA04 | Tự nối `qua_trinh_cu_tru` theo `ma_cu_dan`, so `ma_ho` | Đủ |
| QRA05 | `dia_chi` trừ địa chỉ đã có `ho_cu_tru` (phía hộ là `0..N`) | Đủ |
| QRA06 | `cu_dan` trừ cư dân có trong `qua_trinh_cu_tru` (phía đợt là `0..N`) | Đủ |
| QRA07 | Giao hai tập cư dân theo `loai_cu_tru` | Đủ |
| QRA09 | `qua_trinh_cu_tru` (đã bắt đầu ≤ d) trừ `Q_d` | Đủ |
| QRA10 | `bien_dong_cu_tru` nối **hai lần** với `qua_trinh_cu_tru` qua hai FK riêng, mỗi nhánh đi tiếp tới `to_dan_pho` | Đủ |

**Ghi chú QRA10 và B08:** DDL tuần 1 chưa chặn trường hợp đợt cũ và đợt mới của một sự kiện nội bộ thuộc **hai cư dân khác nhau** (B08 là việc tuần 2). Biểu thức QRA10 vẫn an toàn: phép nối tự nhiên `NB ⋈ CU ⋈ MOI` nối theo `ma_cu_dan`, nên chỉ giữ sự kiện mà hai đợt cùng một người. Không cần đổi schema vì điểm này.

## 3. Phản hồi các góp ý RV01–RV10 của TV1 về phần RA

| Mã | Phản hồi của TV3 |
|---|---|
| RV01–RV07, RV09 | Đồng ý, giữ nguyên cách làm. |
| **RV08** | **Đã sửa.** `docs/06a_dai_so_quan_he.md` mục 0.3 (v0.1): bỏ khẳng định "đại số cổ điển thuần". Tách thành hai bước. Bước 1 chuẩn bị dữ liệu bằng SQL theo B05, tạo `Q_d = CU_TRU_HIEU_LUC_D(ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau)` và bỏ `ngay_ket_thuc`. Bước 2 dùng `Q_d` như quan hệ đầu vào trong đại số cổ điển. Các công thức QRA01, 02, 03, 08, 09 không đổi vì chỉ dùng `ma_cu_dan`, `ma_ho`, `loai_cu_tru`. Đã cập nhật câu `Q_d` trong `tests/ra_fixture.sql` theo lược đồ mới. |
| RV10 | Đồng ý. Mô tả PR #1 đã dùng tên 06a/06b. |

## 4. Vấn đề còn mở

| Mã | Mức | Nội dung | Đề nghị | Người xử lý |
|---|---|---|---|---|
| **E1** | Câu hỏi, không chặn | DEC06 cho phép **một đợt được nhiều sự kiện tham chiếu cùng vai trò**, ví dụ hai sự kiện `CHUYEN_DI` cùng đóng một đợt cũ. Theo B09, hai sự kiện đó buộc phải có cùng ngày, nên thực chất là ghi trùng một sự kiện. Kết quả 10 câu RA **không bị ảnh hưởng** (phép chiếu trả về tập), nhưng có thể làm sai số đếm sự kiện trong câu SQL thống kê của TV2. | TV1 xác nhận lý do giữ DEC06. Nếu giữ, đề nghị thêm vào `sql/06_validation.sql` một truy vấn phát hiện đợt bị tham chiếu từ 2 lần trở lên trong cùng vai trò. Nếu đổi, có thể thêm `UNIQUE(ma_qua_trinh_cu)` và `UNIQUE(ma_qua_trinh_moi)`; PostgreSQL cho phép nhiều giá trị NULL trong cột UNIQUE nên không ảnh hưởng hình dạng sự kiện. | TV1 quyết định |
| E2 | Nhỏ | Cột `tai_khoan.vai_tro` (`QUAN_TRI`, `CAN_BO`, `THONG_KE`) chưa được đối chiếu với 3 role PostgreSQL của demo bảo mật. | TV3 đã thêm bảng đối chiếu vào `docs/06b_bao_mat.md` mục 3, ghi rõ hai tầng này độc lập, không tự đồng bộ. | TV3 (đã xong) |

## 5. Xác nhận của TV3 cho Gate 1

- ERD và DDL v1-candidate biểu diễn đúng 10 câu RA: **xác nhận**.
- Tiếp nhận RV08: **đã sửa** (mục 3).
- Hai demo bảo mật B1/B2 khả thi trên schema hiện tại, không cần đổi bảng lõi: **xác nhận**.
- Gate 1 của TV3 **chưa ký PASS**: còn chờ TV1 trả lời E1. `tests/ra_fixture.sql` đã chạy lại trên DB trắng với schema v1-candidate: 11/11 kết quả khớp.
