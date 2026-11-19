# MA TRẬN 20 CÂU HỎI VÀ REVIEW THIẾT KẾ — v1

**Owner kiểm tra mô hình:** TV1. **Ngày:** 11/11/2026. Đây là kiểm tra thiết kế và đọc mã, chưa là biên bản chạy SQL/RA trên seed chính thức. Owner lời giải vẫn là TV2 (SQL) và TV3 (RA).

Ký hiệu: C=`cu_dan`, Q=`qua_trinh_cu_tru`, H=`ho_cu_tru`, D=`dia_chi`, T=`to_dan_pho`, B=`bien_dong_cu_tru`, A=`tai_khoan`. `Q_d` là tập đợt hiệu lực tại d=20/11/2026. Đường địa lý chuẩn: Q→H→D→T. “Toàn bộ” dưới đây là toàn bộ dữ liệu đã lưu, có thể gồm đợt tương lai; không được diễn giải thành lịch sử đã xảy ra tính đến d.

## 1. Đại số quan hệ — owner TV3

| ID | Đầu ra yêu cầu | Quan hệ/đường nối | Điều kiện và phép chính | Dữ liệu kiểm chứng cần có | Kết luận mô hình |
|---|---|---|---|---|---|
| QRA01 | `ma_cu_dan, ho_ten` | C–Q_d–H–D–T | Tổ 01; chọn, chiếu, nối | S01; người đã đi và đợt tương lai bị loại | Đủ trường/FK |
| QRA02 | `ma_cu_dan, ho_ten` | C–Q_d–H–D–T | Tổ 02, TAM_TRU | S02; thường trú cùng tổ không lọt | Đủ trường/FK |
| QRA03 | `ma_cu_dan, ho_ten, ngay_sinh` | C–Q_d–H–D–T | Tổ 01, sinh <=1966-11-20 | S03; đúng ngày cắt, sau ngày cắt một ngày, người cao tuổi tổ khác | Đủ trường/FK |
| QRA04 | `ma_cu_dan, ho_ten` | Q tự nối theo cư dân; C | Hai hộ khác nhau, toàn bộ Q; đổi tên | S06; hai đợt cùng hộ phải bị loại | Đủ, giữ tên khóa cư dân khi tự nối |
| QRA05 | `ma_dia_chi, dia_chi_chuan` | D, H | Mã D trừ mã địa chỉ đã có H; nối lại D | S04; phân biệt S05 có hộ nhưng không người | Đủ; thống nhất mở rộng cột hiển thị từ mã sang mã+địa chỉ |
| QRA06 | `ma_cu_dan, ho_ten` | C, Q | Mã C trừ mọi mã người trong Q | S10; người chỉ có đợt tương lai vẫn có đợt nên không lọt | Đủ |
| QRA07 | `ma_cu_dan, ho_ten` | Q, C | Giao hai tập người theo loại, toàn bộ Q | S07/S08; khác thời kỳ vẫn được chọn | Đủ |
| QRA08 | `ma_cu_dan` | Q_d–H–D–T | Hợp người ở Tổ 01/Tổ 02 | S01/S02; người thuộc hai tổ chỉ một mã | Đủ |
| QRA09 | `ma_cu_dan, ho_ten` | C, Q, Q_d | Người có đợt bắt đầu <=d trừ người còn hiệu lực | S09/S10; người chỉ có đợt tương lai bị loại | Đủ |
| QRA10 | `ma_cu_dan, ho_ten` | B→Q_cũ→H_cũ→D_cũ và B→Q_mới→H_mới→D_mới; C | Nội bộ; cùng cư dân, khác tổ; đổi tên hai nhánh | S13; ca cùng tổ/khác hộ bị loại khỏi câu hỏi | Đủ hai FK riêng |

## 2. SQL — owner TV2

| ID | Đầu ra yêu cầu | Quan hệ/đường nối | Điều kiện và kỹ thuật | Dữ liệu kiểm chứng cần có | Kết luận mô hình |
|---|---|---|---|---|---|
| QSQL01 | `ma_cu_dan, ho_ten, loai_cu_tru` | C–Q_d–H–D–T | Tổ X, DISTINCT theo cả ba cột | S01/S02; cùng người hai loại có thể hai dòng | Đủ |
| QSQL02 | `ma_ho, so_cu_dan` | H–Q_d | COUNT DISTINCT cư dân >=4 | S14; hộ 4 người được chọn, hộ 3 người bị loại | Đủ |
| QSQL03 | `ma_to, ten_to, so_cu_dan` | T LEFT JOIN D–H–Q_d | Từng tổ, kể cả tổ 0 người; bộ lọc thời gian trong ON | Có tổ không người, người cùng tổ hai loại chỉ đếm một | Đủ; S15 riêng lẻ chưa đảm bảo tổ 0 người |
| QSQL04 | `ma_dia_chi, dia_chi_chuan` | D, H | NOT EXISTS hộ | S04; S05 không lọt | Đủ |
| QSQL05 | `ma_cu_dan, ho_ten, so_ho` | C–Q | Toàn bộ Q, COUNT DISTINCT hộ >=2 | S06; nhiều đợt cùng hộ không đủ | Đủ |
| QSQL06 | `ma_cu_dan, ho_ten` | C, Q | Có cả hai loại trong toàn bộ Q; EXISTS/INTERSECT | S07/S08 | Đủ |
| QSQL07 | `ma_cu_dan, ho_ten` | C, Q | Có đợt bắt đầu <=d, NOT EXISTS đợt còn hiệu lực | S09; loại S10 và người chỉ có đợt tương lai | Đủ |
| QSQL08 | `thang, loai_bien_dong, so_su_kien` | B | Nhóm tháng và loại; đếm sự kiện, không đếm người | S11–S13; hai sự kiện cùng người tính hai | Đủ; chỉ trả nhóm phát sinh, không yêu cầu lưới tháng/loại 0 |
| QSQL09 | `ma_bien_dong, ma_cu_dan, ma_to_cu, ma_to_moi, ngay_bien_dong` | Hai nhánh như QRA10 | Nội bộ, cùng người, khác tổ | S13 khác tổ; đối chứng nội bộ cùng tổ | Đủ |
| QSQL10 | `ma_tai_khoan, ten_hien_thi, so_su_kien` | A LEFT JOIN B | COUNT mã sự kiện, kể cả tài khoản 0 | Một tài khoản không sự kiện; không dùng COUNT(*) cho phía NULL | Đủ |

Đã thống nhất ở mức đặc tả: QSQL03 bao gồm tổ 0 người; QSQL08 chỉ gồm nhóm phát sinh. Đây là hợp đồng đầu ra để triển khai, chưa phải lời giải SQL hoàn chỉnh.

## 3. Review tài liệu RA hiện có trên GitHub

Nguồn đã đọc: [PR #1](https://github.com/Linhlss/CSDL-Nh-m-38/pull/1), tệp [06a_dai_so_quan_he.md tại c0f3580](https://github.com/Linhlss/CSDL-Nh-m-38/blob/c0f35807869b37ff0b421dfe0ae45b34e561179c/docs/06a_dai_so_quan_he.md). PR đang mở tại thời điểm kiểm tra. Nhận xét được lưu nội bộ; chưa gửi review hay thay đổi PR trên GitHub. Kết quả kiểm thử PostgreSQL do PR mô tả là lời báo cáo của tác giả, không phải lần chạy lại trong workspace này.

| Mã | Nội dung đã kiểm tra | Kết luận / hành động tiếp theo |
|---|---|---|
| RV01 | Tên bảng/cột và đường nối của QRA01–10 | Tương thích DDL v1 bàn giao; không đổi cấu trúc so với v0 |
| RV02 | Tự nối QRA04, đổi tên `ma_ho_a/ma_ho_b` | Giữ `ma_cu_dan` làm thuộc tính chung và so hai hộ khác nhau là đúng hướng; ca hai đợt cùng hộ cần có trong seed |
| RV03 | Hợp/giao/hiệu theo mã | Các tập khóa có miền tương thích; không dùng họ tên làm căn cứ đồng nhất |
| RV04 | QRA03 và ngày cắt | Chấp nhận điều kiện sinh <=20/11/1966 cho “đủ 60 tuổi tại 20/11/2026”; thêm hai ca sát ngày cắt |
| RV05 | QRA09 | Chấp nhận tập đã bắt đầu <=d trừ tập hiệu lực; cách này phân biệt người chưa từng có đợt và người chỉ có đợt tương lai |
| RV06 | QRA10 | Hai nhánh đợt cũ/mới và điều kiện cùng cư dân, khác tổ đáp ứng câu hỏi. SQL kiểm chứng cũng có cùng người; chưa thay thế ràng buộc DB |
| RV07 | Nối tự nhiên khi nhiều bảng có `ghi_chu` | Các bước chiếu bỏ cột không cần thiết trong tài liệu giúp tránh nối nhầm; duy trì cách này khi sửa |
| RV08 | Khẳng định `Q_d` “thuần đại số quan hệ cổ điển” chỉ bằng phép hiệu | Cần TV3 sửa diễn giải: so sánh với giá trị NULL vẫn dựa trên ngữ nghĩa mở rộng. Chuẩn bị quan hệ hiệu lực không NULL trước, sau đó dùng trong công thức cổ điển; không khẳng định đổi IS NULL thành hiệu tự loại bỏ vấn đề NULL |
| RV09 | “Toàn bộ lịch sử” ở QRA04/07 và câu hỏi SQL tương ứng | Giữ toàn bộ dữ liệu đã ghi nhận theo đặc tả B16. Nếu seed có tương lai, chú thích phạm vi; không âm thầm thêm bộ lọc chỉ ở một vế đối soát |
| RV10 | Tên file trong mô tả PR khác file thật | Cập nhật tham chiếu tới `06a_dai_so_quan_he.md` và `06b_bao_mat.md` khi tích hợp; không sao chép lời giải sang bộ TV1 |

Với RV08, quan hệ chuẩn bị tối thiểu có thể là `CU_TRU_HIEU_LUC_D(ma_qua_trinh, ma_cu_dan, ma_ho, loai_cu_tru, ngay_bat_dau)` lấy từ SQL theo B05, bỏ `ngay_ket_thuc` sau khi xác định hiệu lực. TV3 cập nhật công thức dùng đúng lược đồ đó. Đây là gợi ý sửa ở ranh giới chuẩn bị dữ liệu, không yêu cầu thêm bảng lõi.

## 4. Checklist nhận review chéo

- TV2 kiểm tra từ điển, miền giá trị, thứ tự nạp và các ca seed cần thêm: tổ 0 người, tài khoản 0 sự kiện, đợt tương lai, hai đợt cùng hộ, hai người trùng tên, nội bộ cùng tổ.
- TV3 kiểm tra hai vai trò FK trên ERD, bản số/NULL, mô hình đủ biểu diễn 10 câu; xử lý RV08 và thống nhất lược đồ `Q_d`.
- Hai thành viên ghi phản hồi, tệp/phiên bản và ngày trong `../meetings/decision_log.md`. TV3 đã xác nhận 10 RA/B1/B2 tại commit `7abe4d5`; ngày16/11 chủ repo xác nhận cả ba đồng ý thiết kế, nguồn tại [Gate 1](../meetings/decision_log.md#gate1).

## 5. Lịch sử review ngày 12/11/2026

RV01–RV07 và RV09 được kiểm tra lại trên `7abe4d5`; 10 SQL kiểm chứng khớp đầy đủ kết quả trên fixture nhỏ và các ca biên. **RV08 đã sửa đạt:** Q_d chuẩn bị bằng SQL, bỏ cột kết thúc trước khi dùng đại số cổ điển. **Tại ngày 12/11, RV10 còn mở:** mô tả PR dùng tên cũ; đã xử lý ngày 13/11 ở mục 6. E1 có quyết định giữ schema và bổ sung validation theo vai trò ở DEC06. Xem [review TV3 trong nhật ký](../meetings/decision_log.md#review-tv3) cho lệnh chạy, expected/actual, lỗi đã sửa và giới hạn role có sẵn. Không dùng kết quả fixture thay nghiệm thu seed chính thức.

## 6. Cập nhật tích hợp ngày 13/11/2026

PR #1 đã merge tại `d84571e` sau khi khóa HEAD `3414131`. **RV10/F05 đã xử lý:** mô tả PR dùng đúng 06a/06b và cách chuẩn bị Q_d. **F03 đã xử lý:** kiểm tra role có sẵn và transaction thiết lập, kiểm chứng đầy đủ điều kiện từ chối/rollback. Bộ kiểm chứng mới đạt 146/146 (144 chức năng, 2 tái hiện); cấu trúc và 20 câu hỏi giữ nguyên. Gate 1 vẫn chờ các xác nhận thành viên và lần đối soát seed chính thức là bước riêng. Xem [nhật ký review](../meetings/decision_log.md#review-tv3) và log146 để truy commit, expected/actual và phạm vi kiểm chứng.

## 7. Chốt thiết kế ngày tiếp nhận 16/11/2026

Gate 1 PASS, thiết kế v1 theo chủ repo xác nhận trong chat rằng cả ba đã đồng ý và đã đối chiếu thông báo gốc. Các đoạn review ngày11–13/11 phía trên giữ trạng thái lịch sử. Môi trường cá nhân TV2 (Windows, phiên bản/công cụ/kết nối chưa có) hoãn sang W2-T2-01; [nhật ký](../meetings/decision_log.md#gate1) giữ nguồn và phạm vi phê duyệt.

## 8. Review chéo S01–S16 trên seed636 — TV3, 19/11/2026 (W2-T3-11)

Chạy [tests/seed636_s01_s16_tv3.sql](../tests/seed636_s01_s16_tv3.sql) trên CSDL tạm PostgreSQL 17 nạp `01_schema.sql` + `03_seed.sql` (sha256 `71f33714…fa0f2`, 200 cư dân / 250 đợt / 63 sự kiện), d = `2026-11-20`. Mỗi ca so **tập mã** kỳ vọng với tập mã thực tế, không chỉ so số dòng.

| Ca | Dữ liệu seed636 dùng để kiểm | Kết quả |
|---|---|---|
| S01 | C1–C6 đang ở Tổ 01; C15, C28 đã chuyển khỏi Tổ 01 | Đạt |
| S02 | C7, C8 tạm trú Tổ 02 được lấy; C9, C10 thường trú bị loại | Đạt |
| S03 | C1 sinh đúng 20/11/1966 và C2 được lấy; C3 sinh 21/11/1966 bị loại | Đạt |
| S04 | QSQL04/QRA05 ra **47, 48, 49, 50**; địa chỉ của hộ rỗng 59/60 không lọt | Đạt, xem ghi chú 1 |
| S05 | Hộ 59, 60: 0 người tại d, mỗi hộ từng có 1 đợt | Đạt |
| S06 | C15 hai hộ được lấy; C17 hai đợt cùng một hộ bị loại | Đạt |
| S07 | `INTERSECT` lấy C6 (hai loại cùng lúc), C17, C18 (hai loại khác thời kỳ) | Đạt |
| S08 | C1, C2 chỉ thường trú, C7 chỉ tạm trú không lọt tập giao | Đạt |
| S09 | `EXCEPT` QRA09 lấy C19–C22; loại C23, C24 (chỉ đợt tương lai) và C25 (không có đợt) | Đạt |
| S10 | `EXCEPT` QRA06 = 25, 26, 27, 196–200; C23, C24 có đợt tương lai không lọt | Đạt |
| S11 | 19 sự kiện CHUYEN_DEN, 0 dòng sai hình dạng FK hoặc ngày | Đạt |
| S12 | 17 sự kiện CHUYEN_DI, 0 dòng sai hình dạng FK hoặc ngày | Đạt |
| S13 | QSQL09 lấy C15 (Tổ 01 → Tổ 02); loại C16 (cùng Tổ 02) | Đạt |
| S14 | Hộ của C1 = 5 người, của C11 = 3, của C14 = 1 | Đạt, xem ghi chú 2 |
| S15 | QSQL03 có Tổ 08 = 0 người; QSQL08 không sinh nhóm tháng/loại đếm 0 | Đạt |
| S16 | C4, C5 cùng tên "Nguyễn Văn An", cả hai có trong Tổ 01 với hai mã riêng | Đạt, xem ghi chú 3 |

Đối chiếu bốn phép tập hợp với dạng `NOT EXISTS`/`EXISTS` của QSQL theo tập mã: QRA05 (4 bộ), QRA06 (8), QRA07 (31), QRA09 (17) đều **lệch 0**.

**Ghi chú gửi TV2 (không chặn Gate 2):**

1. **S04:** generator và cột `ghi_chu` chỉ đánh dấu địa chỉ 49, 50 là S04, nhưng địa chỉ 47, 48 (Tổ 08) cũng chưa có hộ nên kết quả đúng là 4 địa chỉ. 06a đã ghi 4 bộ. Đề nghị thêm ghi chú cho 47, 48 hoặc sửa chú thích trong `generate_data.py` để Chương 5 không viết "2 địa chỉ".
2. **S14:** seed636 không có người nào có hai đợt hiệu lực trong **cùng một hộ** tại d, nên bẫy `COUNT(*)` so với `COUNT(DISTINCT)` của QSQL02 chỉ được kiểm trên fixture29 (C3 hai loại trong H1). Ở mức tổ, bẫy này vẫn có trên seed636: C6 có hai đợt hiệu lực ở hai hộ thuộc Tổ 01. Có thể giữ nguyên và ghi rõ trong Chương 5, hoặc thêm một ca vào seed nếu muốn seed tự kiểm.
3. **S16:** seed636 có 6 họ tên bị trùng (15 người). Nếu viết `EXCEPT` trên `ho_ten` thay vì `ma_cu_dan`, QRA09 ra 16 người thay vì 17. Đây là ví dụ thật để Chương 4/5 giải thích vì sao phép hiệu/giao phải chiếu theo khóa.
