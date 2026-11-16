# 10 CÂU HỎI VÀ BIỂU THỨC ĐẠI SỐ QUAN HỆ (QRA01–QRA10)

> **Người viết:** TV3 · **Người kiểm tra:** TV1 · **Phiên bản:** v0.2 (nháp, 16/11/2026; viết lại ký hiệu theo cách trình bày trên lớp, khớp Chương 4 của báo cáo; thêm cách viết phép chia cho QRA07. v0.1 ngày 11/11/2026 sửa mục 0.3 theo góp ý RV08 của TV1)
> **Căn cứ:** `sql/01_schema.sql` v1-candidate (cấu trúc giữ nguyên v0) và mục 6 của `docs/01_de_cuong.md`.
> **Lưu ý:** Nếu Gate 1 (15/11) đổi tên bảng hoặc tên cột, phải sửa lại toàn bộ tệp này. Mục (6) "Kết quả mong đợi" sẽ điền sau khi TV2 có dữ liệu giả lập (dự kiến 20/11).

---

## 0. Ký hiệu, quy ước và quan hệ chuẩn bị

### 0.1. Ký hiệu

| Ký hiệu | Phép toán | SQL tương ứng (PostgreSQL) |
|---|---|---|
| `σ điều kiện (R)` | Chọn | `WHERE` |
| `π A, B (R)` | Chiếu (kết quả là **tập**, không lặp) | `SELECT DISTINCT A, B` |
| `R ⋈ S` | Nối tự nhiên, nối theo **các thuộc tính trùng tên** | `JOIN ... USING (...)` |
| `R ⋈(điều kiện) S` | Nối theo điều kiện | `JOIN ... ON ...` |
| `R × S` | Tích Descartes | `CROSS JOIN` |
| `R ∪ S` | Hợp | `UNION` |
| `R ∩ S` | Giao | `INTERSECT` |
| `R − S` | Hiệu | `EXCEPT` |
| `R ÷ S` | Chia | Hai `NOT EXISTS` lồng nhau |
| `ρ S (R)` | Đổi tên R thành S | Bí danh `AS` |
| `R1 = biểu thức` | Đặt tên cho kết quả trung gian | `WITH R1 AS (...)` |

Mười câu dưới đây không dùng phép gom nhóm (đếm, nhóm theo) và không sắp xếp. Các phép `∪`, `∩`, `−` chỉ áp dụng cho hai quan hệ **khả hợp**, tức là cùng số thuộc tính và cùng miền giá trị.

Thuộc tính có tiền tố như `Q1.ma_cu_dan`, sau phép chiếu, được gọi lại theo tên gốc `ma_cu_dan` để nối tiếp với `CU_DAN`.

### 0.2. Lược đồ quan hệ (theo `01_schema.sql` v1-candidate, cấu trúc như v0)

```text
TO_DAN_PHO(ma_to, ten_to, ghi_chu)
DIA_CHI(ma_dia_chi, ma_to, dia_chi_chuan, ghi_chu)
HO_CU_TRU(ma_ho, ma_dia_chi, ngay_lap, ghi_chu)
CU_DAN(ma_cu_dan, ho_ten, ngay_sinh, gioi_tinh, ghi_chu)
QUA_TRINH_CU_TRU(ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau, ngay_ket_thuc)
BIEN_DONG_CU_TRU(ma_bien_dong, loai_bien_dong, ma_qua_trinh_cu, ma_qua_trinh_moi,
                 ngay_bien_dong, ma_tai_khoan, thoi_diem_ghi, ghi_chu)
TAI_KHOAN(ma_tai_khoan, ten_dang_nhap, ten_hien_thi, vai_tro, trang_thai)
```

**Cảnh báo khi dùng kết nối tự nhiên:** cột `ghi_chu` có trong 5 bảng. Nếu nối tự nhiên hai bảng gốc, ví dụ `DIA_CHI ⋈ HO_CU_TRU`, phép nối sẽ so sánh cả `ghi_chu` và cho kết quả sai. Vì vậy, khi hai vế cùng có `ghi_chu`, các biểu thức dưới đây dùng nối theo điều kiện `⋈(...)`, hoặc chiếu lấy cột mã trước rồi mới nối với `CU_DAN`.

**Quan hệ dùng chung `HO_TO`** cho biết mỗi hộ thuộc tổ nào:

```text
HO_TO = π ma_ho, ma_to (HO_CU_TRU ⋈(HO_CU_TRU.ma_dia_chi = DIA_CHI.ma_dia_chi) DIA_CHI)
```

`HO_TO` chỉ có hai thuộc tính `ma_ho` và `ma_to`, nên nối tự nhiên với `Q_d`, `QUA_TRINH_CU_TRU` hay `TO_DAN_PHO` đều chỉ so đúng một thuộc tính khóa. QRA01, 02, 03, 08, 10 dùng lại `HO_TO`.

### 0.3. Ngày tham chiếu và quan hệ chuẩn bị `Q_d`

Ngày tham chiếu cố định: **d = DATE '2026-11-20'**.

Một đợt cư trú **có hiệu lực tại ngày d** khi `ngay_bat_dau ≤ d` và (`ngay_ket_thuc` rỗng hoặc `ngay_ket_thuc ≥ d`).

**Vấn đề với giá trị rỗng (NULL).** Đại số quan hệ cổ điển giả định mọi bộ đều có giá trị trên mọi thuộc tính. Cột `ngay_ket_thuc` lại được phép rỗng (đợt chưa kết thúc). Mọi phép so sánh với giá trị rỗng, kể cả `ngay_ket_thuc < d`, đều cần **ngữ nghĩa mở rộng** (logic ba giá trị của SQL: đúng, sai, không xác định). Vì vậy, viết `σ ngay_ket_thuc < d (...)` hay đổi `IS NULL` thành một phép hiệu **không** làm biểu thức trở thành đại số cổ điển thuần: vấn đề NULL vẫn còn, chỉ bị che đi.

**Cách nhóm xử lý:** tách làm hai bước, có ranh giới rõ ràng.

**Bước 1 — chuẩn bị dữ liệu (ngoài đại số quan hệ, làm bằng SQL).** Tạo quan hệ các đợt có hiệu lực tại d. Bước này xử lý NULL theo quy tắc B05 của `docs/03_dac_ta_nghiep_vu.md`, rồi **bỏ cột `ngay_ket_thuc`**:

```text
Q_d = CU_TRU_HIEU_LUC_D(ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau)
```

```sql
-- Bước chuẩn bị Q_d: các đợt cư trú có hiệu lực tại 2026-11-20 (quy tắc B05)
SELECT ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau
FROM qua_trinh_cu_tru
WHERE ngay_bat_dau <= DATE '2026-11-20'
  AND (ngay_ket_thuc IS NULL OR ngay_ket_thuc >= DATE '2026-11-20');
```

**Bước 2 — đại số quan hệ cổ điển.** `Q_d` được coi là một **quan hệ đầu vào đã cho**, giống các bảng gốc. Năm thuộc tính của `Q_d` đều có giá trị trong mọi bộ (`ngay_bat_dau` là `NOT NULL` trong schema), nên mọi biểu thức dùng `Q_d` ở các câu dưới đây chỉ dùng phép toán cổ điển, không còn so sánh nào với giá trị rỗng.

**Ghi chú:**

- `Q_d` **không còn** cùng lược đồ với `QUA_TRINH_CU_TRU` (thiếu `ngay_ket_thuc`). Các câu dùng `Q_d` chỉ lấy `ma_cu_dan`, `ma_ho`, `loai_cu_tru`, nên công thức không đổi.
- Muốn dùng `Q_d` trong phép `∪`, `∩`, `−` với một quan hệ khác thì phải chiếu cả hai vế về cùng thuộc tính trước, ví dụ `π ma_cu_dan (Q_d)` ở QRA09.
- Các câu chỉ xét lịch sử (QRA04, 05, 06, 07, 10) dùng trực tiếp bảng gốc và không đụng tới `ngay_ket_thuc`, nên không cần bước chuẩn bị.
- Các câu QRA01, 02, 03, 08, 09 dùng lại `Q_d`. SQL kiểm chứng của từng câu viết thẳng điều kiện B05 ở trên.

### 0.4. Bảng phủ phép toán

Phép cơ bản: σ, π, ρ, ∪, −, ×. Phép dẫn xuất: ⋈, ∩, ÷. Tích Descartes có mặt gián tiếp qua nối theo điều kiện, vì `R ⋈(điều kiện) S = σ điều kiện (R × S)`.

| Câu | σ | π | ⋈ | ⋈(điều kiện) | ρ | ∪ | ∩ | − | ÷ | Kịch bản |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|---|
| QRA01 | ✓ | ✓ | ✓ | ✓ (qua HO_TO) | | | | | | S01 |
| QRA02 | ✓ | ✓ | ✓ | ✓ (qua HO_TO) | | | | | | S02 |
| QRA03 | ✓ | ✓ | ✓ | ✓ (qua HO_TO) | | | | | | S03 |
| QRA04 | | ✓ | ✓ | ✓ (tự nối) | ✓ | | | | | S06 |
| QRA05 | | ✓ | ✓ | | | | | ✓ | | S04 |
| QRA06 | | ✓ | ✓ | | | | | ✓ | | S10 |
| QRA07 | ✓ | ✓ | ✓ | | | | ✓ | | ✓ (cách 2) | S07, S08 |
| QRA08 | ✓ | ✓ | ✓ | ✓ (qua HO_TO) | | ✓ | | | | S01, S02 |
| QRA09 | ✓ | ✓ | ✓ | | | | | ✓ | | S09 |
| QRA10 | ✓ | ✓ | ✓ | ✓ | ✓ | | | | | S13 |

---

## QRA01 — Cư dân đang cư trú tại Tổ 01 tại ngày d

**(1) Câu hỏi nghiệp vụ:** Liệt kê mã và họ tên các cư dân đang cư trú tại một địa chỉ thuộc **Tổ 01** vào ngày 20/11/2026.

**(2) Điều kiện thời gian / dữ liệu:** d = 2026-11-20; dùng `Q_d` (mục 0.3). Tên tổ trong dữ liệu là `'Tổ 01'`.

**(3) Quan hệ đầu vào:** `HO_TO` (mục 0.2), `TO_DAN_PHO`, `Q_d`, `CU_DAN`.

**(4) Biểu thức:**

```text
R1 = π ma_ho (HO_TO ⋈ σ ten_to='Tổ 01' (TO_DAN_PHO))
R2 = π ma_cu_dan (Q_d ⋈ R1)
KQ = π ma_cu_dan, ho_ten (CU_DAN ⋈ R2)
```

**(5) Diễn giải:**

- R1: chọn Tổ 01, nối với `HO_TO` theo `ma_to`, chiếu lấy mã các hộ thuộc Tổ 01.
- R2: nối các đợt có hiệu lực tại d với R1 theo `ma_ho`, được mã cư dân đang ở các hộ đó.
- KQ: nối với `CU_DAN` theo `ma_cu_dan` để lấy họ tên. R2 chỉ còn `ma_cu_dan`, nên phép nối không bị vướng cột `ghi_chu`.

**(6) Kết quả mong đợi:** Trả về các cư dân của kịch bản S01. Danh sách mã cụ thể: [CẦN ĐIỀN sau khi có seed].

**(7) SQL kiểm chứng:**

```sql
SELECT DISTINCT c.ma_cu_dan, c.ho_ten
FROM cu_dan c
JOIN qua_trinh_cu_tru q ON q.ma_cu_dan = c.ma_cu_dan
JOIN ho_cu_tru h        ON h.ma_ho = q.ma_ho
JOIN dia_chi d          ON d.ma_dia_chi = h.ma_dia_chi
JOIN to_dan_pho t       ON t.ma_to = d.ma_to
WHERE t.ten_to = 'Tổ 01'
  AND q.ngay_bat_dau <= DATE '2026-11-20'
  AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
ORDER BY c.ma_cu_dan;
```

**(8) Người viết / kiểm tra / trạng thái:** TV3 / TV1 / Nháp v0.

---

## QRA02 — Cư dân đang tạm trú tại Tổ 02 tại ngày d

**(1) Câu hỏi nghiệp vụ:** Liệt kê mã và họ tên cư dân đang **tạm trú** tại Tổ 02 vào ngày 20/11/2026.

**(2) Điều kiện:** d = 2026-11-20; `loai_cu_tru = 'TAM_TRU'`; tên tổ `'Tổ 02'`.

**(3) Quan hệ đầu vào:** `HO_TO` (mục 0.2), `TO_DAN_PHO`, `Q_d`, `CU_DAN`.

**(4) Biểu thức:**

```text
R1 = π ma_ho (HO_TO ⋈ σ ten_to='Tổ 02' (TO_DAN_PHO))
R2 = π ma_cu_dan (σ loai_cu_tru='TAM_TRU' (Q_d) ⋈ R1)
KQ = π ma_cu_dan, ho_ten (CU_DAN ⋈ R2)
```

**(5) Diễn giải:**

- Cấu trúc giống QRA01, chỉ thêm điều kiện loại cư trú.
- Phép chọn `loai_cu_tru='TAM_TRU'` đặt ngay trên `Q_d`, nên người thường trú ở Tổ 02 bị loại trước khi nối, giảm số bộ trung gian.

**(6) Kết quả mong đợi:** Có ít nhất một cư dân tạm trú ở Tổ 02 (kịch bản S02). Cư dân thường trú ở Tổ 01 **không** được xuất hiện. [CẦN ĐIỀN mã cụ thể].

**(7) SQL kiểm chứng:**

```sql
SELECT DISTINCT c.ma_cu_dan, c.ho_ten
FROM cu_dan c
JOIN qua_trinh_cu_tru q ON q.ma_cu_dan = c.ma_cu_dan
JOIN ho_cu_tru h        ON h.ma_ho = q.ma_ho
JOIN dia_chi d          ON d.ma_dia_chi = h.ma_dia_chi
JOIN to_dan_pho t       ON t.ma_to = d.ma_to
WHERE t.ten_to = 'Tổ 02'
  AND q.loai_cu_tru = 'TAM_TRU'
  AND q.ngay_bat_dau <= DATE '2026-11-20'
  AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
ORDER BY c.ma_cu_dan;
```

**(8) Người viết / kiểm tra / trạng thái:** TV3 / TV1 / Nháp v0.

---

## QRA03 — Cư dân từ 60 tuổi trở lên đang cư trú tại Tổ 01

**(1) Câu hỏi nghiệp vụ:** Liệt kê mã, họ tên, ngày sinh của cư dân **sinh từ ngày 20/11/1966 trở về trước** (tức đủ 60 tuổi tại ngày d) và đang cư trú tại Tổ 01 vào ngày 20/11/2026.

**(2) Điều kiện:** d = 2026-11-20; ngày cắt `ngay_sinh ≤ DATE '1966-11-20'`. Đại số quan hệ không tính tuổi, nên câu hỏi được diễn đạt bằng **ngày sinh so với một ngày cắt cố định**.

**(3) Quan hệ đầu vào:** như QRA01; dùng lại R2 của QRA01 (mã cư dân đang ở Tổ 01 tại d).

**(4) Biểu thức:**

```text
R3 = σ ngay_sinh ≤ '1966-11-20' (CU_DAN)
KQ = π ma_cu_dan, ho_ten, ngay_sinh (R3 ⋈ R2)        (R2 như QRA01)
```

**(5) Diễn giải:**

- R3: chọn cư dân có ngày sinh không muộn hơn ngày cắt.
- KQ: nối tự nhiên với R2 qua thuộc tính chung duy nhất `ma_cu_dan`, rồi chiếu 3 thuộc tính cần hiển thị. Chỉ giữ người vừa đủ tuổi vừa đang ở Tổ 01.

**(6) Kết quả mong đợi:** Trả về cư dân của kịch bản S03 (ít nhất một người từ 60 tuổi ở Tổ 01). Người 60 tuổi nhưng ở tổ khác, hoặc đã chuyển đi trước d, không được xuất hiện. [CẦN ĐIỀN].

**(7) SQL kiểm chứng:**

```sql
SELECT DISTINCT c.ma_cu_dan, c.ho_ten, c.ngay_sinh
FROM cu_dan c
JOIN qua_trinh_cu_tru q ON q.ma_cu_dan = c.ma_cu_dan
JOIN ho_cu_tru h        ON h.ma_ho = q.ma_ho
JOIN dia_chi d          ON d.ma_dia_chi = h.ma_dia_chi
JOIN to_dan_pho t       ON t.ma_to = d.ma_to
WHERE t.ten_to = 'Tổ 01'
  AND c.ngay_sinh <= DATE '1966-11-20'
  AND q.ngay_bat_dau <= DATE '2026-11-20'
  AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
ORDER BY c.ma_cu_dan;
```

**(8) Người viết / kiểm tra / trạng thái:** TV3 / TV1 / Nháp v0.

---

## QRA04 — Cư dân từng cư trú ở ít nhất hai nhóm hộ khác nhau

**(1) Câu hỏi nghiệp vụ:** Liệt kê mã và họ tên cư dân **từng** có đợt cư trú ở ít nhất hai nhóm hộ khác nhau (trong toàn bộ lịch sử, không cần cùng lúc).

**(2) Điều kiện:** Không giới hạn thời gian. Đây là câu **tự kết nối**: so sánh bảng `QUA_TRINH_CU_TRU` với chính nó.

**(3) Quan hệ đầu vào:** `QUA_TRINH_CU_TRU` (dùng hai lần), `CU_DAN`.

**(4) Biểu thức:**

```text
Q1 = ρ Q1 (QUA_TRINH_CU_TRU)
Q2 = ρ Q2 (QUA_TRINH_CU_TRU)
R1 = π Q1.ma_cu_dan (Q1 ⋈(Q1.ma_cu_dan = Q2.ma_cu_dan ∧ Q1.ma_ho ≠ Q2.ma_ho) Q2)
KQ = π ma_cu_dan, ho_ten (CU_DAN ⋈ R1)
```

**(5) Diễn giải:**

- Hai bản sao của bảng quá trình được **đổi tên** thành Q1 và Q2, để gọi được thuộc tính của từng bản.
- Điều kiện `Q1.ma_cu_dan = Q2.ma_cu_dan` ghép mọi cặp đợt của **cùng một người**; điều kiện `Q1.ma_ho ≠ Q2.ma_ho` chỉ giữ các cặp mà hai đợt thuộc hai hộ khác nhau.
- Chiếu lấy mã cư dân. Phép chiếu loại bộ trùng, nên mỗi người chỉ xuất hiện một lần dù có nhiều cặp thỏa mãn.

**(6) Kết quả mong đợi:** Trả về đúng cư dân của kịch bản S06. Người có hai đợt **trong cùng một hộ** không được trả về. [CẦN ĐIỀN].

**(7) SQL kiểm chứng:**

```sql
SELECT DISTINCT c.ma_cu_dan, c.ho_ten
FROM qua_trinh_cu_tru qa
JOIN qua_trinh_cu_tru qb ON qb.ma_cu_dan = qa.ma_cu_dan
                        AND qb.ma_ho <> qa.ma_ho
JOIN cu_dan c ON c.ma_cu_dan = qa.ma_cu_dan
ORDER BY c.ma_cu_dan;
```

**(8) Người viết / kiểm tra / trạng thái:** TV3 / TV1 / Nháp v0.

---

## QRA05 — Địa chỉ chưa được gán cho nhóm hộ nào

**(1) Câu hỏi nghiệp vụ:** Liệt kê mã và địa chỉ chuẩn của những địa chỉ **chưa có bất kỳ** nhóm hộ nào trong dữ liệu.

**(2) Điều kiện:** Không giới hạn thời gian (xét toàn bộ bảng `HO_CU_TRU`).

**(3) Quan hệ đầu vào:** `DIA_CHI`, `HO_CU_TRU`.

**(4) Biểu thức:**

```text
R1 = π ma_dia_chi (DIA_CHI) − π ma_dia_chi (HO_CU_TRU)
KQ = π ma_dia_chi, dia_chi_chuan (DIA_CHI ⋈ R1)
```

**(5) Diễn giải:**

- Lấy toàn bộ mã địa chỉ, trừ đi tập mã địa chỉ đã xuất hiện trong bảng nhóm hộ. Hai vế đều có một thuộc tính `ma_dia_chi` cùng miền giá trị, nên khả hợp.
- Nối lại với `DIA_CHI` (thuộc tính chung duy nhất là `ma_dia_chi`) để hiển thị địa chỉ chuẩn.

**(6) Kết quả mong đợi:** Trả về địa chỉ của kịch bản S04. Địa chỉ của S05 (có hộ nhưng hiện không ai ở) **không** được trả về, vì địa chỉ đó vẫn có trong `HO_CU_TRU`. [CẦN ĐIỀN].

**(7) SQL kiểm chứng:**

```sql
SELECT d.ma_dia_chi, d.dia_chi_chuan
FROM dia_chi d
WHERE d.ma_dia_chi IN (
    SELECT ma_dia_chi FROM dia_chi
    EXCEPT
    SELECT ma_dia_chi FROM ho_cu_tru
)
ORDER BY d.ma_dia_chi;
```

**(8) Người viết / kiểm tra / trạng thái:** TV3 / TV1 / Nháp v0.

---

## QRA06 — Cư dân có hồ sơ nhưng chưa từng có đợt cư trú

**(1) Câu hỏi nghiệp vụ:** Liệt kê mã và họ tên cư dân **đã có hồ sơ** nhưng **chưa từng có** đợt cư trú nào.

**(2) Điều kiện:** Không giới hạn thời gian.

**(3) Quan hệ đầu vào:** `CU_DAN`, `QUA_TRINH_CU_TRU`.

**(4) Biểu thức:**

```text
R1 = π ma_cu_dan (CU_DAN) − π ma_cu_dan (QUA_TRINH_CU_TRU)
KQ = π ma_cu_dan, ho_ten (CU_DAN ⋈ R1)
```

**(5) Diễn giải:** Tập mọi mã cư dân, trừ tập mã cư dân đã xuất hiện trong ít nhất một đợt cư trú. Sau đó nối với `CU_DAN` để lấy họ tên. So sánh theo **mã** chứ không theo họ tên, nên hai người trùng tên (S16) không bị gộp nhầm.

**(6) Kết quả mong đợi:** Trả về cư dân của kịch bản S10. [CẦN ĐIỀN].

**(7) SQL kiểm chứng:**

```sql
SELECT c.ma_cu_dan, c.ho_ten
FROM cu_dan c
WHERE c.ma_cu_dan IN (
    SELECT ma_cu_dan FROM cu_dan
    EXCEPT
    SELECT ma_cu_dan FROM qua_trinh_cu_tru
)
ORDER BY c.ma_cu_dan;
```

**(8) Người viết / kiểm tra / trạng thái:** TV3 / TV1 / Nháp v0.

---

## QRA07 — Cư dân từng có cả thường trú và tạm trú

**(1) Câu hỏi nghiệp vụ:** Liệt kê mã và họ tên cư dân trong lịch sử **từng có cả** đợt thường trú **và** đợt tạm trú (không nhất thiết cùng lúc).

**(2) Điều kiện:** Không giới hạn thời gian.

**(3) Quan hệ đầu vào:** `QUA_TRINH_CU_TRU`, `CU_DAN`.

**(4) Biểu thức.** Cách 1, dùng phép giao:

```text
R1 = π ma_cu_dan (σ loai_cu_tru='THUONG_TRU' (QUA_TRINH_CU_TRU))
R2 = π ma_cu_dan (σ loai_cu_tru='TAM_TRU' (QUA_TRINH_CU_TRU))
R3 = R1 ∩ R2
KQ = π ma_cu_dan, ho_ten (CU_DAN ⋈ R3)
```

Cách 2, dùng phép chia:

```text
LOAI = {('THUONG_TRU'), ('TAM_TRU')}                  (quan hệ một thuộc tính loai_cu_tru)
R3   = π ma_cu_dan, loai_cu_tru (QUA_TRINH_CU_TRU) ÷ LOAI
KQ   = π ma_cu_dan, ho_ten (CU_DAN ⋈ R3)
```

**(5) Diễn giải:**

- Cách 1: R1 là tập người từng thường trú, R2 là tập người từng tạm trú. `R1 ∩ R2` là người thuộc cả hai tập. Hai vế cùng có một thuộc tính `ma_cu_dan`, nên khả hợp.
- Cách 2: số bị chia gồm các cặp (người, loại cư trú từng có). Phép chia giữ người có **đủ mọi** loại trong LOAI.
- LOAI là quan hệ hằng gồm hai bộ, **không** lấy bằng `π loai_cu_tru (QUA_TRINH_CU_TRU)`. Nếu lấy từ dữ liệu mà dữ liệu chỉ có một loại, số chia thiếu một loại và phép chia trả về cả người chỉ có loại đó.
- **Không** thể viết thành `σ loai_cu_tru='THUONG_TRU' ∧ loai_cu_tru='TAM_TRU' (...)`. Một bộ (một đợt) chỉ có một giá trị `loai_cu_tru`, nên điều kiện đó luôn sai và kết quả luôn rỗng.
- Hai cách cho cùng kết quả trên bộ dữ liệu thử (`tests/ra_fixture.sql`).

**(6) Kết quả mong đợi:** Trả về cư dân của S07. Cư dân của S08 (chỉ có một loại cư trú) bị loại. [CẦN ĐIỀN].

**(7) SQL kiểm chứng:**

```sql
SELECT c.ma_cu_dan, c.ho_ten
FROM cu_dan c
WHERE c.ma_cu_dan IN (
    SELECT ma_cu_dan FROM qua_trinh_cu_tru WHERE loai_cu_tru = 'THUONG_TRU'
    INTERSECT
    SELECT ma_cu_dan FROM qua_trinh_cu_tru WHERE loai_cu_tru = 'TAM_TRU'
)
ORDER BY c.ma_cu_dan;
```

SQL kiểm chứng cách 2 (phép chia viết bằng hai `NOT EXISTS`: không có loại nào trong LOAI mà người đó thiếu):

```sql
SELECT c.ma_cu_dan, c.ho_ten
FROM cu_dan c
WHERE NOT EXISTS (
    SELECT 1
    FROM (VALUES ('THUONG_TRU'), ('TAM_TRU')) AS loai(loai_cu_tru)
    WHERE NOT EXISTS (
        SELECT 1 FROM qua_trinh_cu_tru q
        WHERE q.ma_cu_dan = c.ma_cu_dan
          AND q.loai_cu_tru = loai.loai_cu_tru
    )
)
ORDER BY c.ma_cu_dan;
```

**(8) Người viết / kiểm tra / trạng thái:** TV3 / TV1 / Nháp v0.

---

## QRA08 — Cư dân đang cư trú tại Tổ 01 hoặc Tổ 02 tại ngày d

**(1) Câu hỏi nghiệp vụ:** Liệt kê mã cư dân đang cư trú tại **Tổ 01 hoặc Tổ 02** vào ngày 20/11/2026.

**(2) Điều kiện:** d = 2026-11-20; dùng `Q_d`.

**(3) Quan hệ đầu vào:** `HO_TO` (mục 0.2), `TO_DAN_PHO`, `Q_d`.

**(4) Biểu thức:**

```text
R1 = π ma_cu_dan (Q_d ⋈ HO_TO ⋈ σ ten_to='Tổ 01' (TO_DAN_PHO))
R2 = π ma_cu_dan (Q_d ⋈ HO_TO ⋈ σ ten_to='Tổ 02' (TO_DAN_PHO))
KQ = R1 ∪ R2
```

**(5) Diễn giải:**

- `Q_d ⋈ HO_TO` nối theo `ma_ho`, cho biết mỗi đợt đang hiệu lực thuộc tổ nào; nối tiếp với tổ đã chọn theo `ma_to`. `Q_d` và `HO_TO` không có `ghi_chu`, nên nối tự nhiên an toàn.
- R1, R2: tập mã cư dân ở Tổ 01 và ở Tổ 02.
- `R1 ∪ R2`: hợp hai tập, loại phần tử trùng. Một người thuộc cả hai tập (nếu có, ví dụ thường trú ở Tổ 01 và tạm trú ở Tổ 02) chỉ xuất hiện một lần.
- Có thể viết gọn bằng một phép chọn với điều kiện `ten_to = 'Tổ 01' ∨ ten_to = 'Tổ 02'`. Ở đây cố ý dùng `∪` để minh họa phép hợp.

**(6) Kết quả mong đợi:** Bằng hợp của kết quả QRA01 (phần mã cư dân) và tập cư dân Tổ 02 tại d (cả thường trú lẫn tạm trú). [CẦN ĐIỀN].

**(7) SQL kiểm chứng:**

```sql
WITH cd_to AS (
    SELECT q.ma_cu_dan, t.ten_to
    FROM qua_trinh_cu_tru q
    JOIN ho_cu_tru h  ON h.ma_ho = q.ma_ho
    JOIN dia_chi d    ON d.ma_dia_chi = h.ma_dia_chi
    JOIN to_dan_pho t ON t.ma_to = d.ma_to
    WHERE q.ngay_bat_dau <= DATE '2026-11-20'
      AND (q.ngay_ket_thuc IS NULL OR q.ngay_ket_thuc >= DATE '2026-11-20')
)
SELECT ma_cu_dan FROM cd_to WHERE ten_to = 'Tổ 01'
UNION
SELECT ma_cu_dan FROM cd_to WHERE ten_to = 'Tổ 02'
ORDER BY ma_cu_dan;
```

**(8) Người viết / kiểm tra / trạng thái:** TV3 / TV1 / Nháp v0.

---

## QRA09 — Cư dân đã từng cư trú nhưng không còn đợt hiệu lực tại ngày d

**(1) Câu hỏi nghiệp vụ:** Liệt kê mã và họ tên cư dân **đã từng cư trú** (có đợt bắt đầu từ ngày d trở về trước) nhưng **không có đợt nào còn hiệu lực** vào ngày 20/11/2026.

**(2) Điều kiện:** d = 2026-11-20. "Đã từng cư trú" nghĩa là có đợt với `ngay_bat_dau ≤ d`. Người chỉ có đợt bắt đầu **sau** ngày d chưa được coi là đã từng cư trú, nên không thuộc kết quả.

**(3) Quan hệ đầu vào:** `QUA_TRINH_CU_TRU`, `Q_d`, `CU_DAN`.

**(4) Biểu thức:**

```text
R1 = π ma_cu_dan (σ ngay_bat_dau ≤ '2026-11-20' (QUA_TRINH_CU_TRU))
R2 = π ma_cu_dan (Q_d)
R3 = R1 − R2
KQ = π ma_cu_dan, ho_ten (CU_DAN ⋈ R3)
```

**(5) Diễn giải:**

- R1: người có ít nhất một đợt đã bắt đầu trước hoặc đúng ngày d. Cột `ngay_bat_dau` là `NOT NULL`, nên phép chọn không gặp giá trị rỗng.
- R2: người có ít nhất một đợt còn hiệu lực tại d.
- Phép hiệu cho ra người đã từng ở nhưng tại d không còn đợt nào hiệu lực (đã chuyển đi hoặc mọi đợt đã kết thúc).
- So với QRA06: QRA06 là người **chưa từng** có đợt nào; QRA09 là người **từng có** nhưng nay không còn.

**(6) Kết quả mong đợi:** Trả về cư dân của S09 (ví dụ người có sự kiện `CHUYEN_DI` trước d). Không trả về người của S10. [CẦN ĐIỀN].

**(7) SQL kiểm chứng:**

```sql
SELECT c.ma_cu_dan, c.ho_ten
FROM cu_dan c
WHERE c.ma_cu_dan IN (
    SELECT ma_cu_dan FROM qua_trinh_cu_tru
    WHERE ngay_bat_dau <= DATE '2026-11-20'
    EXCEPT
    SELECT ma_cu_dan FROM qua_trinh_cu_tru
    WHERE ngay_bat_dau <= DATE '2026-11-20'
      AND (ngay_ket_thuc IS NULL OR ngay_ket_thuc >= DATE '2026-11-20')
)
ORDER BY c.ma_cu_dan;
```

**(8) Người viết / kiểm tra / trạng thái:** TV3 / TV1 / Nháp v0.

---

## QRA10 — Cư dân chuyển nội bộ giữa hai tổ dân phố khác nhau

**(1) Câu hỏi nghiệp vụ:** Liệt kê mã và họ tên cư dân có sự kiện **chuyển nội bộ** (`CHUYEN_NOI_BO`) từ một nhóm hộ thuộc tổ này sang một nhóm hộ thuộc **tổ khác**.

**(2) Điều kiện:** Không giới hạn thời gian. Chỉ xét sự kiện loại `CHUYEN_NOI_BO`. Mỗi sự kiện này có đúng một đợt cũ và một đợt mới (CHECK `ck_bd_hinh_dang` trong schema).

**(3) Quan hệ đầu vào:** `BIEN_DONG_CU_TRU`, `QUA_TRINH_CU_TRU`, `HO_TO` (mục 0.2), `CU_DAN`.

**(4) Biểu thức:**

```text
B   = σ loai_bien_dong='CHUYEN_NOI_BO' (BIEN_DONG_CU_TRU)
QT  = π ma_qua_trinh, ma_cu_dan, ma_to (QUA_TRINH_CU_TRU ⋈ HO_TO)
CU  = ρ CU (QT)
MOI = ρ MOI (QT)
R1  = B ⋈(B.ma_qua_trinh_cu = CU.ma_qua_trinh) CU
        ⋈(B.ma_qua_trinh_moi = MOI.ma_qua_trinh ∧ CU.ma_cu_dan = MOI.ma_cu_dan ∧ CU.ma_to ≠ MOI.ma_to) MOI
R2  = π CU.ma_cu_dan (R1)
KQ  = π ma_cu_dan, ho_ten (CU_DAN ⋈ R2)
```

**(5) Diễn giải:**

- QT: gắn mỗi đợt cư trú với cư dân và tổ dân phố của hộ (nối với `HO_TO` theo `ma_ho`).
- Bảng biến động có hai khóa ngoại cùng trỏ tới `QUA_TRINH_CU_TRU`, nên QT được **đổi tên** thành hai bản: CU (vai trò đợt cũ) và MOI (vai trò đợt mới).
- Nối B với CU theo đợt cũ, rồi với MOI theo đợt mới. Điều kiện `CU.ma_cu_dan = MOI.ma_cu_dan` **bắt buộc đợt cũ và đợt mới thuộc cùng một người** (quy tắc B08); sự kiện vi phạm bị loại khỏi kết quả.
- Điều kiện `CU.ma_to ≠ MOI.ma_to`: chỉ giữ sự kiện mà tổ cũ khác tổ mới.
- Đây là câu dùng nhiều phép nhất: chọn, chiếu, nối nhiều lần và đổi tên để dùng một quan hệ ở hai vai trò.

**(6) Kết quả mong đợi:** Trả về cư dân của S13 nếu sự kiện S13 được thiết kế là chuyển **khác tổ**. Đề nghị TV2 tạo ít nhất một sự kiện chuyển nội bộ khác tổ và một sự kiện **cùng tổ, khác hộ**, để chứng minh phép chọn `≠` hoạt động. [CẦN ĐIỀN].

**(7) SQL kiểm chứng:**

```sql
SELECT DISTINCT c.ma_cu_dan, c.ho_ten
FROM bien_dong_cu_tru b
JOIN qua_trinh_cu_tru q_cu  ON q_cu.ma_qua_trinh  = b.ma_qua_trinh_cu
JOIN ho_cu_tru h_cu         ON h_cu.ma_ho         = q_cu.ma_ho
JOIN dia_chi d_cu           ON d_cu.ma_dia_chi    = h_cu.ma_dia_chi
JOIN qua_trinh_cu_tru q_moi ON q_moi.ma_qua_trinh = b.ma_qua_trinh_moi
JOIN ho_cu_tru h_moi        ON h_moi.ma_ho        = q_moi.ma_ho
JOIN dia_chi d_moi          ON d_moi.ma_dia_chi   = h_moi.ma_dia_chi
JOIN cu_dan c               ON c.ma_cu_dan        = q_cu.ma_cu_dan
WHERE b.loai_bien_dong = 'CHUYEN_NOI_BO'
  AND q_moi.ma_cu_dan = q_cu.ma_cu_dan
  AND d_cu.ma_to <> d_moi.ma_to
ORDER BY c.ma_cu_dan;
```

**(8) Người viết / kiểm tra / trạng thái:** TV3 / TV1 / Nháp v0.

---

## Phụ lục — Phiếu đối chiếu đại số quan hệ với SQL (điền sau khi có seed)

So sánh **tập khóa** kết quả (`ma_cu_dan` hoặc `ma_dia_chi`), không so theo họ tên.

**Đã kiểm chứng sơ bộ (10/11/2026, PostgreSQL 17.11):** `tests/ra_fixture.sql` là bộ dữ liệu thử 10 cư dân đã biết đáp án. Cả 10 câu SQL kiểm chứng và VIEW của Demo B2 đều trả đúng đáp án tính tay. Bảng dưới vẫn phải điền lại trên **seed chính thức** của TV2.

| Câu | Số bộ kết quả theo đại số (tính tay trên bộ kịch bản) | Số dòng SQL kiểm chứng | Khớp? | Người đối chiếu | Ngày |
|---|---|---|---|---|---|
| QRA01 | ... | ... | [ ] | ... | ... |
| QRA02 | ... | ... | [ ] | ... | ... |
| QRA03 | ... | ... | [ ] | ... | ... |
| QRA04 | ... | ... | [ ] | ... | ... |
| QRA05 | ... | ... | [ ] | ... | ... |
| QRA06 | ... | ... | [ ] | ... | ... |
| QRA07 | ... | ... | [ ] | ... | ... |
| QRA08 | ... | ... | [ ] | ... | ... |
| QRA09 | ... | ... | [ ] | ... | ... |
| QRA10 | ... | ... | [ ] | ... | ... |

## Đề nghị gửi TV2 khi sinh dữ liệu

Để các câu trên cho kết quả **khác rỗng** và có thể phân biệt đúng/sai, bộ kịch bản cần có thêm:

1. Một người **60 tuổi trở lên ở tổ khác Tổ 01**: QRA03 phải loại người này.
2. Một người có **hai đợt trong cùng một hộ**: QRA04 phải loại người này.
3. Một người **chỉ có đợt bắt đầu sau 20/11/2026**: QRA09 phải loại người này.
4. Một sự kiện chuyển nội bộ **cùng tổ, khác hộ**: QRA10 phải loại sự kiện này.
5. Tên tổ trong dữ liệu đúng chính xác `'Tổ 01'`, `'Tổ 02'` (có dấu, có số 0 ở đầu). Nếu đổi cách đặt tên thì báo TV3 sửa biểu thức.
