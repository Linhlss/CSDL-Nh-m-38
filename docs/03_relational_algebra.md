# 10 CÂU HỎI VÀ BIỂU THỨC ĐẠI SỐ QUAN HỆ (QRA01–QRA10)

> **Người viết:** TV3 · **Người kiểm tra:** TV1 · **Phiên bản:** v0 (nháp, 10/11/2026)
> **Căn cứ:** `sql/01_schema.sql` v0 và mục 6 của `docs/01_de_cuong.md`.
> **Lưu ý:** Nếu Gate 1 (15/11) đổi tên bảng hoặc tên cột, phải sửa lại toàn bộ tệp này. Mục (6) "Kết quả mong đợi" sẽ điền sau khi TV2 có dữ liệu giả lập (dự kiến 20/11).

---

## 0. Ký hiệu, quy ước và quan hệ chuẩn bị

### 0.1. Ký hiệu

| Ký hiệu | Phép toán | SQL tương ứng (PostgreSQL) |
|---|---|---|
| `σ_{điều kiện}(R)` | Chọn | `WHERE` |
| `π_{A, B}(R)` | Chiếu (kết quả là **tập**, không lặp) | `SELECT DISTINCT A, B` |
| `R ⋈ S` | Kết nối tự nhiên, nối theo **các thuộc tính trùng tên** | `JOIN ... USING (...)` |
| `R ⋈_{điều kiện} S` | Kết nối theta / kết nối bằng | `JOIN ... ON ...` |
| `R × S` | Tích Descartes | `CROSS JOIN` |
| `R ∪ S` | Hợp | `UNION` |
| `R ∩ S` | Giao | `INTERSECT` |
| `R − S` | Hiệu | `EXCEPT` |
| `ρ_{S(A1, A2, ...)}(R)` | Đổi tên quan hệ và thuộc tính | Bí danh `AS` |
| `X ← biểu thức` | Gán kết quả trung gian cho tên X | `WITH X AS (...)` |

Đại số quan hệ cổ điển **không dùng** `COUNT`, `GROUP BY`, `ORDER BY`. Các phép `∪`, `∩`, `−` chỉ áp dụng cho hai quan hệ **khả hợp**, tức là cùng số thuộc tính và cùng miền giá trị.

### 0.2. Lược đồ quan hệ (theo `01_schema.sql` v0)

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

**Cảnh báo khi dùng kết nối tự nhiên:** cột `ghi_chu` có trong 5 bảng. Nếu nối tự nhiên hai bảng gốc, ví dụ `DIA_CHI ⋈ HO_CU_TRU`, phép nối sẽ so sánh cả `ghi_chu` và cho kết quả sai. Vì vậy mọi biểu thức dưới đây đều **chiếu bớt thuộc tính trước khi nối**, để hai vế chỉ còn đúng một thuộc tính chung là khóa cần nối.

### 0.3. Ngày tham chiếu và quan hệ chuẩn bị `Q_d`

Ngày tham chiếu cố định: **d = DATE '2026-11-20'**.

Một đợt cư trú **có hiệu lực tại ngày d** khi `ngay_bat_dau ≤ d` và (`ngay_ket_thuc` rỗng hoặc `ngay_ket_thuc ≥ d`).

Để giữ đúng đại số quan hệ cổ điển, nhóm **không dùng toán tử `IS NULL`** trong biểu thức. Thay vào đó, định nghĩa `Q_d` bằng phép chọn và phép hiệu:

```text
Q_d ← σ_{ngay_bat_dau ≤ d}(QUA_TRINH_CU_TRU) − σ_{ngay_ket_thuc < d}(QUA_TRINH_CU_TRU)
```

**Giải thích:**

- Vế trái lấy mọi đợt đã bắt đầu trước hoặc đúng ngày d.
- Vế phải lấy các đợt **đã kết thúc trước ngày d**. Một đợt có `ngay_ket_thuc` rỗng không thỏa điều kiện `ngay_ket_thuc < d` (so sánh với giá trị rỗng không cho kết quả đúng), nên không bị lấy vào vế phải.
- Lấy hiệu hai vế, ta còn các đợt đã bắt đầu và chưa kết thúc tại ngày d, gồm cả đợt chưa có ngày kết thúc. Đúng với định nghĩa ở trên.
- Hai vế cùng lược đồ `QUA_TRINH_CU_TRU` nên khả hợp.

`Q_d` có cùng lược đồ với `QUA_TRINH_CU_TRU`. Các câu QRA01, 02, 03, 08, 09 dùng lại `Q_d`.

SQL tương đương (dùng để kiểm chứng; có thể tạo thành view nếu nhóm muốn):

```sql
-- Q_d: các đợt cư trú có hiệu lực tại 2026-11-20
SELECT * FROM qua_trinh_cu_tru WHERE ngay_bat_dau <= DATE '2026-11-20'
EXCEPT
SELECT * FROM qua_trinh_cu_tru WHERE ngay_ket_thuc < DATE '2026-11-20';
-- Tương đương với:
-- WHERE ngay_bat_dau <= DATE '2026-11-20'
--   AND (ngay_ket_thuc IS NULL OR ngay_ket_thuc >= DATE '2026-11-20')
```

### 0.4. Bảng phủ phép toán

| Câu | σ | π | ⋈ tự nhiên | ⋈ theta | ρ | ∪ | ∩ | − | Kịch bản |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|---|
| QRA01 | ✓ | ✓ | ✓ | | | | | (qua Q_d) | S01 |
| QRA02 | ✓ | ✓ | | ✓ | | | | (qua Q_d) | S02 |
| QRA03 | ✓ | ✓ | ✓ | | | | | (qua Q_d) | S03 |
| QRA04 | ✓ | ✓ | ✓ (tự kết nối) | | ✓ | | | | S06 |
| QRA05 | | ✓ | ✓ | | | | | ✓ | S04 |
| QRA06 | | ✓ | ✓ | | | | | ✓ | S10 |
| QRA07 | ✓ | ✓ | ✓ | | | | ✓ | | S07, S08 |
| QRA08 | ✓ | ✓ | ✓ | | | ✓ | | (qua Q_d) | S01, S02 |
| QRA09 | ✓ | ✓ | ✓ | | | | | ✓ | S09 |
| QRA10 | ✓ | ✓ | ✓ | | ✓ | | | | S13 |

---

## QRA01 — Cư dân đang cư trú tại Tổ 01 tại ngày d

**(1) Câu hỏi nghiệp vụ:** Liệt kê mã và họ tên các cư dân đang cư trú tại một địa chỉ thuộc **Tổ 01** vào ngày 20/11/2026.

**(2) Điều kiện thời gian / dữ liệu:** d = 2026-11-20; dùng `Q_d` (mục 0.3). Tên tổ trong dữ liệu là `'Tổ 01'`.

**(3) Quan hệ đầu vào:** `TO_DAN_PHO`, `DIA_CHI`, `HO_CU_TRU`, `Q_d`, `CU_DAN`.

**(4) Biểu thức:**

```text
R1 ← π_{ma_to}(σ_{ten_to = 'Tổ 01'}(TO_DAN_PHO))
R2 ← π_{ma_dia_chi}(π_{ma_dia_chi, ma_to}(DIA_CHI) ⋈ R1)
R3 ← π_{ma_ho}(π_{ma_ho, ma_dia_chi}(HO_CU_TRU) ⋈ R2)
R4 ← π_{ma_cu_dan}(π_{ma_cu_dan, ma_ho}(Q_d) ⋈ R3)
KQ ← π_{ma_cu_dan, ho_ten}(CU_DAN ⋈ R4)
```

**(5) Diễn giải:**

- R1: chọn tổ có tên `'Tổ 01'` rồi chiếu lấy mã tổ.
- R2: nối địa chỉ với R1 theo `ma_to`, được các địa chỉ thuộc Tổ 01.
- R3: nối nhóm hộ với R2 theo `ma_dia_chi`, được các hộ ở những địa chỉ đó.
- R4: nối các đợt có hiệu lực tại d với R3 theo `ma_ho`, được mã cư dân đang ở các hộ đó.
- KQ: nối với `CU_DAN` theo `ma_cu_dan` để lấy họ tên. Thuộc tính chung duy nhất của `CU_DAN` và R4 là `ma_cu_dan`.

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

**(3) Quan hệ đầu vào:** `CU_DAN` (bí danh C), `Q_d` (Q), `HO_CU_TRU` (H), `DIA_CHI` (D), `TO_DAN_PHO` (T).

**(4) Biểu thức** (viết bằng **kết nối theta** để thể hiện cách thứ hai, khác QRA01):

```text
KQ ← π_{C.ma_cu_dan, C.ho_ten}(
        σ_{T.ten_to = 'Tổ 02' ∧ Q.loai_cu_tru = 'TAM_TRU'}(
            C ⋈_{C.ma_cu_dan = Q.ma_cu_dan} Q_d
              ⋈_{Q.ma_ho = H.ma_ho} H
              ⋈_{H.ma_dia_chi = D.ma_dia_chi} D
              ⋈_{D.ma_to = T.ma_to} T ))
```

**(5) Diễn giải:**

- Kết nối theta nêu rõ cặp thuộc tính được so sánh, nên không bị ảnh hưởng bởi cột `ghi_chu` trùng tên (thuộc tính được gọi kèm tên quan hệ, ví dụ `C.ghi_chu`, `H.ghi_chu`).
- Mỗi phép `⋈_{điều kiện}` tương đương `σ_{điều kiện}(R × S)`.
- Phép chọn ngoài cùng lọc tổ và loại cư trú. Có thể đẩy phép chọn vào trước khi nối, ví dụ `σ_{ten_to = 'Tổ 02'}(T)`, để giảm số bộ trung gian. Kết quả không đổi.

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

**(3) Quan hệ đầu vào:** như QRA01; dùng lại R4 của QRA01 (mã cư dân đang ở Tổ 01 tại d).

**(4) Biểu thức:**

```text
R4 ← (như QRA01: mã cư dân đang cư trú tại Tổ 01 tại ngày d)
CAO_TUOI ← π_{ma_cu_dan, ho_ten, ngay_sinh}(σ_{ngay_sinh ≤ '1966-11-20'}(CU_DAN))
KQ ← CAO_TUOI ⋈ R4
```

**(5) Diễn giải:**

- CAO_TUOI: chọn cư dân có ngày sinh không muộn hơn ngày cắt, chiếu lấy 3 thuộc tính cần hiển thị.
- KQ: kết nối tự nhiên với R4 qua thuộc tính chung duy nhất `ma_cu_dan`. Chỉ giữ người vừa đủ tuổi vừa đang ở Tổ 01.

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
QA ← ρ_{QA(ma_cu_dan, ma_ho_a)}(π_{ma_cu_dan, ma_ho}(QUA_TRINH_CU_TRU))
QB ← ρ_{QB(ma_cu_dan, ma_ho_b)}(π_{ma_cu_dan, ma_ho}(QUA_TRINH_CU_TRU))
R  ← π_{ma_cu_dan}(σ_{ma_ho_a ≠ ma_ho_b}(QA ⋈ QB))
KQ ← π_{ma_cu_dan, ho_ten}(CU_DAN ⋈ R)
```

**(5) Diễn giải:**

- Hai bản sao của bảng quá trình được **đổi tên** cột hộ thành `ma_ho_a` và `ma_ho_b`. Cột `ma_cu_dan` giữ nguyên tên.
- `QA ⋈ QB` là kết nối tự nhiên theo `ma_cu_dan`: ghép mọi cặp đợt của **cùng một người**.
- `σ_{ma_ho_a ≠ ma_ho_b}` chỉ giữ các cặp mà hai đợt thuộc hai hộ khác nhau.
- Chiếu lấy `ma_cu_dan`. Phép chiếu loại bộ trùng, nên mỗi người chỉ xuất hiện một lần dù có nhiều cặp thỏa mãn.

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
R  ← π_{ma_dia_chi}(DIA_CHI) − π_{ma_dia_chi}(HO_CU_TRU)
KQ ← π_{ma_dia_chi, dia_chi_chuan}(DIA_CHI ⋈ R)
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
R  ← π_{ma_cu_dan}(CU_DAN) − π_{ma_cu_dan}(QUA_TRINH_CU_TRU)
KQ ← π_{ma_cu_dan, ho_ten}(CU_DAN ⋈ R)
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

**(4) Biểu thức:**

```text
A  ← π_{ma_cu_dan}(σ_{loai_cu_tru = 'THUONG_TRU'}(QUA_TRINH_CU_TRU))
B  ← π_{ma_cu_dan}(σ_{loai_cu_tru = 'TAM_TRU'}(QUA_TRINH_CU_TRU))
KQ ← π_{ma_cu_dan, ho_ten}(CU_DAN ⋈ (A ∩ B))
```

**(5) Diễn giải:**

- A: tập người từng thường trú. B: tập người từng tạm trú.
- `A ∩ B`: người thuộc cả hai tập. Hai vế cùng có một thuộc tính `ma_cu_dan`, nên khả hợp.
- **Không** thể viết thành `σ_{loai_cu_tru = 'THUONG_TRU' ∧ loai_cu_tru = 'TAM_TRU'}(...)`. Một bộ (một đợt) chỉ có một giá trị `loai_cu_tru`, nên điều kiện đó luôn sai và kết quả luôn rỗng. Phải lấy giao của **hai tập người**.

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

**(8) Người viết / kiểm tra / trạng thái:** TV3 / TV1 / Nháp v0.

---

## QRA08 — Cư dân đang cư trú tại Tổ 01 hoặc Tổ 02 tại ngày d

**(1) Câu hỏi nghiệp vụ:** Liệt kê mã cư dân đang cư trú tại **Tổ 01 hoặc Tổ 02** vào ngày 20/11/2026.

**(2) Điều kiện:** d = 2026-11-20; dùng `Q_d`.

**(3) Quan hệ đầu vào:** `TO_DAN_PHO`, `DIA_CHI`, `HO_CU_TRU`, `Q_d`.

**(4) Biểu thức:**

```text
HO_TO ← π_{ma_ho, ma_to}(π_{ma_ho, ma_dia_chi}(HO_CU_TRU) ⋈ π_{ma_dia_chi, ma_to}(DIA_CHI))
CD_TO ← π_{ma_cu_dan, ma_to}(π_{ma_cu_dan, ma_ho}(Q_d) ⋈ HO_TO)

T1 ← π_{ma_cu_dan}(CD_TO ⋈ π_{ma_to}(σ_{ten_to = 'Tổ 01'}(TO_DAN_PHO)))
T2 ← π_{ma_cu_dan}(CD_TO ⋈ π_{ma_to}(σ_{ten_to = 'Tổ 02'}(TO_DAN_PHO)))
KQ ← T1 ∪ T2
```

**(5) Diễn giải:**

- HO_TO: mỗi hộ thuộc tổ nào (nối hộ với địa chỉ qua `ma_dia_chi`).
- CD_TO: mỗi cư dân đang ở tại d thuộc tổ nào (nối qua `ma_ho`).
- T1, T2: tập mã cư dân ở Tổ 01 và ở Tổ 02.
- `T1 ∪ T2`: hợp hai tập, loại phần tử trùng. Một người thuộc cả hai tập (nếu có, ví dụ thường trú ở Tổ 01 và tạm trú ở Tổ 02) chỉ xuất hiện một lần.
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
DA_TUNG  ← π_{ma_cu_dan}(σ_{ngay_bat_dau ≤ d}(QUA_TRINH_CU_TRU))
DANG_O   ← π_{ma_cu_dan}(Q_d)
R        ← DA_TUNG − DANG_O
KQ       ← π_{ma_cu_dan, ho_ten}(CU_DAN ⋈ R)
```

**(5) Diễn giải:**

- DA_TUNG: người có ít nhất một đợt đã bắt đầu trước hoặc đúng ngày d.
- DANG_O: người có ít nhất một đợt còn hiệu lực tại d.
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

**(3) Quan hệ đầu vào:** `BIEN_DONG_CU_TRU`, `QUA_TRINH_CU_TRU`, `HO_CU_TRU`, `DIA_CHI`, `CU_DAN`.

**(4) Biểu thức:**

```text
HO_TO  ← π_{ma_ho, ma_to}(π_{ma_ho, ma_dia_chi}(HO_CU_TRU) ⋈ π_{ma_dia_chi, ma_to}(DIA_CHI))
QT_TO  ← π_{ma_qua_trinh, ma_cu_dan, ma_to}(
              π_{ma_qua_trinh, ma_cu_dan, ma_ho}(QUA_TRINH_CU_TRU) ⋈ HO_TO)

CU     ← ρ_{CU(ma_qua_trinh_cu, ma_cu_dan, ma_to_cu)}(QT_TO)
MOI    ← ρ_{MOI(ma_qua_trinh_moi, ma_cu_dan, ma_to_moi)}(QT_TO)

NB     ← π_{ma_bien_dong, ma_qua_trinh_cu, ma_qua_trinh_moi}(
              σ_{loai_bien_dong = 'CHUYEN_NOI_BO'}(BIEN_DONG_CU_TRU))

R      ← π_{ma_cu_dan}(σ_{ma_to_cu ≠ ma_to_moi}(NB ⋈ CU ⋈ MOI))
KQ     ← π_{ma_cu_dan, ho_ten}(CU_DAN ⋈ R)
```

**(5) Diễn giải:**

- HO_TO, QT_TO: gắn mỗi đợt cư trú với cư dân và tổ dân phố của hộ.
- Đổi tên QT_TO thành hai bản: CU (vai trò đợt cũ) và MOI (vai trò đợt mới). Mã đợt được đổi tên thành `ma_qua_trinh_cu` và `ma_qua_trinh_moi`, trùng với tên cột trong `BIEN_DONG_CU_TRU`.
- `NB ⋈ CU` nối theo `ma_qua_trinh_cu`; tiếp `⋈ MOI` nối theo `ma_qua_trinh_moi` **và** `ma_cu_dan`. Vì cả CU và MOI đều giữ tên `ma_cu_dan`, kết nối tự nhiên **tự động bắt buộc đợt cũ và đợt mới thuộc cùng một người**. Đây là quy tắc nghiệp vụ số 7. Nếu dữ liệu vi phạm quy tắc này, sự kiện đó bị loại khỏi kết quả.
- `σ_{ma_to_cu ≠ ma_to_moi}`: chỉ giữ sự kiện mà tổ cũ khác tổ mới.
- Đây là câu dùng nhiều phép nhất: chọn, chiếu, kết nối nhiều lần và đổi tên để dùng một quan hệ ở hai vai trò.

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
