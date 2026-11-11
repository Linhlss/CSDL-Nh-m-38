# KẾ HOẠCH HOÀN TẤT PHẦN TV1 — TUẦN 1

**Ngày lập:** 11/11/2026. **Tuần được xét:** 10–15/11/2026. **Hạn bàn giao:** 15/11/2026.

**Cập nhật thực hiện:** Sản phẩm kỹ thuật theo kế hoạch này đã được tạo để bàn giao review ngày 11/11; xem [hồ sơ bàn giao](BAN_GIAO_TV1_TUAN_1.md) và [đối chiếu từng mã việc](../meetings/decision_log.md). Các dự kiến bên dưới được giữ để truy vết. Chưa có xác nhận chéo hoặc Gate 1 PASS; không dùng kế hoạch như bằng chứng thay thế sản phẩm.

**Cơ sở đánh giá:** Theo xác nhận của người dùng, toàn bộ phần việc hiện có trong workspace là đóng góp của TV1. Tài liệu này lập kế hoạch hoàn thiện; không xác nhận các đầu việc đã được thực hiện hoặc reviewer đã đồng ý.

## 1. Đánh giá khối lượng và mục tiêu

Phần đã làm gồm đề cương tổng thể, phạm vi, mô hình dữ liệu nháp, định hướng truy vấn và bảo mật, phân công ba thành viên, checklist, bộ khung báo cáo/kiểm thử và DDL 7 bảng. Đây là khối lượng khởi tạo đáng kể. Với yêu cầu đang được ghi nhận trong dự án, quy mô 7 bảng, lịch sử cư trú theo thời gian và nhật ký biến động đã đủ nội dung học thuật; chưa có căn cứ cần mở rộng nghiệp vụ để tăng độ lớn.

Phần cần bổ sung là chiều sâu của thiết kế và sản phẩm bàn giao: đặc tả có điều kiện/lỗi, sơ đồ chính thức, từ điển dữ liệu đầy đủ, phân tích khóa và chuẩn hóa, đối chiếu với DDL và truy vấn, cùng hồ sơ review. Chưa coi bản nháp trong đề cương là bộ thiết kế đã nghiệm thu.

**Đích cuối tuần:** TV2 có thể sinh dữ liệu và viết SQL, TV3 có thể viết/đối chiếu đại số quan hệ và demo bảo mật trên cùng một bộ thiết kế, không phải đoán tên cột, miền giá trị hoặc cách hiểu thời gian.

**Giới hạn tuần 1:** Hoàn tất W1-T1-01 đến W1-T1-20. Tuần 2 vẫn phụ trách triển khai ràng buộc nâng cao, transaction, bộ test thực thi và dữ liệu chính thức. Tuần 1 phải đặc tả được cách thực hiện và cách kiểm chứng các phần đó.

## 2. Phương án thiết kế v1 dùng để chuẩn bị review

Các lựa chọn dưới đây là phương án đề xuất cho Gate 1, chưa thay thế xác nhận thực tế của nhóm:

- Giữ 7 bảng và tên bảng/cột hiện tại; giữ ba loại biến động và sáu nhóm chức năng. Chỉ sửa cấu trúc nếu phát hiện mâu thuẫn nghiệp vụ cụ thể.
- Ngày kết thúc được tính bao gồm ngày đó. Một đợt có hiệu lực tại d khi bắt đầu <= d và kết thúc là NULL hoặc kết thúc >= d. NULL là chưa ghi nhận ngày kết thúc; đợt bắt đầu trong tương lai chưa có hiệu lực.
- Giữ quy tắc cấm chồng lấn theo cùng cư dân + cùng loại cư trú. Hai loại khác nhau có thể đồng thời tồn tại theo quy ước mô phỏng hiện tại; thống kê số người phải tránh đếm trùng.
- Đề xuất thống nhất ngày chuyển là ngày bắt đầu ở nơi mới: chuyển đến có ngày sự kiện = ngày bắt đầu đợt mới; chuyển đi có ngày sự kiện = ngày kết thúc đợt cũ + 1 ngày; chuyển nội bộ đồng thời thỏa hai điều kiện này. Cặp đợt nội bộ phải cùng cư dân, khác hộ. Ghi rõ đây là quy ước mô hình học thuật.
- Giữ mỗi sự kiện có tối đa một đợt cũ và một đợt mới; chưa thêm UNIQUE giới hạn số sự kiện tham chiếu một đợt khi chưa có yêu cầu nghiệp vụ đó.
- Hộ gắn cố định với địa chỉ trong kỳ mô phỏng. Khi chuyển địa chỉ tạo hộ mới; việc sửa liên kết địa chỉ–tổ hoặc hộ–địa chỉ không được dùng để ghi nhận chuyển chỗ ở vì sẽ làm đổi diễn giải lịch sử.
- Dùng ngày tham chiếu 20/11/2026 để đối chiếu các câu hỏi. Phân biệt rõ câu hỏi xét toàn bộ lịch sử với câu hỏi xét đến ngày tham chiếu.

## 3. Sáu gói công việc và lịch thực hiện

Thời lượng là ước lượng thời gian làm tập trung, đã tính việc tái sử dụng nội dung hiện có; tổng khoảng **17–23 giờ**, cộng thời gian chờ phản hồi của nhóm.

| Gói / Ngày | Mã checklist TV1 | Việc phải làm | Đầu ra và điều kiện bàn giao | Ước lượng |
|---|---|---|---|---|
| A — 11/11 | 01–07 | Hoàn thiện phạm vi, thuật ngữ, tác nhân, P1–P6; ghi quy tắc quan hệ, thời gian và biến động | Đặc tả đọc độc lập được; mỗi P có đầu vào, tiền điều kiện, xử lý, bảng đọc/ghi, đầu ra và lỗi | 3–4 giờ |
| B — 12/11 | 08–11 | Vẽ cây chức năng và ERD từ bản Mermaid; thể hiện đủ thuộc tính, khóa, bản số, tính tùy chọn và hai vai trò cũ/mới | Hai sơ đồ có nguồn chỉnh sửa được và ảnh xuất rõ; đưa bản nháp cho TV2/TV3 review ngay trong ngày | 4–5 giờ |
| C — 13/11 | 12–14 | Viết ánh xạ ER → quan hệ, từ điển mọi cột và chuẩn hóa từng bảng | Tên/kiểu/NULL/khóa/miền/default khớp DDL; có khóa ứng viên, phụ thuộc hàm và lý giải 1NF–3NF | 4–5 giờ |
| D — 14/11 | 15–17 | Đối chiếu ERD–từ điển–DDL; đặc tả ràng buộc nâng cao; kiểm tra khả năng trả lời 10 RA + 10 SQL | Ma trận 20 câu hỏi → bảng/quan hệ/điều kiện/dữ liệu cần có; danh sách lỗi và phản hồi review có trạng thái | 3–4 giờ |
| E — 14–15/11 | 18 | Biên tập Chương 1–3 từ A–D; chèn sơ đồ, bảng và giải thích lựa chọn thiết kế | Bản nháp báo cáo có nội dung thực; phần dữ liệu của TV2 và kết quả thực thi tuần 2 được ghi rõ là đang chờ | 2–3 giờ |
| F — 15/11 | 19–20 | Xử lý phản hồi cuối, tổ chức Gate 1 và chuẩn bị bàn giao schema v1 | Có quyết định, reviewer, lỗi còn mở và phiên bản bàn giao; chỉ phát hành v1 đã duyệt khi nhóm xác nhận | 1–2 giờ |

### Nội dung cần làm rõ trong từng gói

**Gói A:** Tách chuyển đi và chuyển nội bộ thành hai nhánh trong P5 để không bỏ sót điều kiện. Bổ sung bảng chức năng → dữ liệu đọc/ghi. Dùng ví dụ nhỏ để giải thích khác nhau giữa hồ sơ cư dân, hộ cư trú, đợt cư trú và sự kiện; không đồng nhất hộ cư trú với quan hệ huyết thống.

**Gói B:** Cây chức năng có một nút gốc, sáu nhóm cấp 1 và chức năng cấp 2. ERD phải thể hiện quan hệ cư dân–hộ qua đợt cư trú; hai FK đợt cũ/mới có nhãn riêng và nullable theo loại sự kiện. Xuất cả `.drawio` và `.png`; kiểm tra chữ và quan hệ đọc được trên khổ A4.

**Gói C:** Với từng bảng, ghi đủ cột, kiểu PostgreSQL, bắt buộc/NULL, PK/FK/UNIQUE/CHECK/DEFAULT, miền giá trị và ý nghĩa. Xét cả khóa thay thế như tên tổ, tên đăng nhập và cặp tổ + địa chỉ chuẩn; không kết luận chuẩn hóa chỉ vì đã có khóa số tự tăng. Giải thích vì sao hồ sơ cư dân không lưu địa chỉ hiện tại và vì sao lịch sử cư trú khác nhật ký biến động.

**Gói D:** Đối chiếu từng cột, FK, miền giá trị và tính tùy chọn giữa ba biểu diễn. Lập bảng quy tắc → nơi kiểm soát → ca hợp lệ/không hợp lệ: PK/FK/CHECK hiện có; chống chồng lấn, cùng cư dân/khác hộ, ngày sự kiện, cập nhật bản ghi đã được sự kiện tham chiếu và transaction cần thực hiện tuần 2. Phương án đề xuất: exclusion constraint dùng GiST + `btree_gist` để cấm khoảng ngày chồng lấn khi cùng cư dân và cùng loại; trigger kiểm tra sự kiện và việc sửa đợt được tham chiếu; transaction cho chuỗi đóng đợt–mở đợt–ghi biến động. Tuần 1 ghi đặc tả và yêu cầu môi trường; tuần 2 mới triển khai và kiểm thử. Không ghi các quy tắc chỉ được mô tả là đã được DB thực thi. Cơ sở cho phương án chống chồng lấn: tài liệu PostgreSQL về [ràng buộc khoảng](https://www.postgresql.org/docs/17/rangetypes.html#RANGETYPES-CONSTRAINT) và [btree_gist](https://www.postgresql.org/docs/17/btree-gist.html).

Với 20 câu hỏi, review đầu ra, đường nối bảng, phạm vi thời gian và tình huống dữ liệu cần có; không yêu cầu TV1 viết hộ toàn bộ lời giải của TV2/TV3. Nếu dùng PR hiện có làm tài liệu đầu vào, ghi nhận xét và việc cần sửa trong hồ sơ review nội bộ; việc đăng review hoặc gửi thông báo lên GitHub là bước riêng, không được coi là đã làm chỉ vì có kế hoạch này.

**Gói E:** Hoàn thiện Chương 1 về nghiệp vụ; Chương 2 về ERD; Chương 3 về ánh xạ, từ điển, ràng buộc và chuẩn hóa. Giữ phần dữ liệu/ảnh/kết quả thực thi đang chờ đúng người phụ trách; không điền kết quả giả. Cập nhật các đường dẫn cũ trong tài liệu để người đọc tìm đúng sản phẩm mới.

**Gói F:** Dành buổi sáng hoàn tất sửa lỗi, buổi chiều review Gate 1. Nếu chưa nhận phản hồi, bàn giao bản “ứng viên v1 — chờ review”, ghi rõ người và nội dung đang chờ; không tự xác nhận thay TV2/TV3.

## 4. Bộ sản phẩm cuối tuần

Tất cả đường dẫn bên dưới tính từ thư mục dự án `/Users/thao/Documents/CSDL_DE_TAI_17`.

| Sản phẩm | Nơi lưu | Người kiểm tra |
|---|---|---|
| Đặc tả nghiệp vụ độc lập | `docs/03_dac_ta_nghiep_vu.md` | TV3; TV2 góp ý tính khả thi dữ liệu |
| Cây chức năng có nguồn và ảnh | `diagrams/phan_ra_chuc_nang.drawio`, `diagrams/phan_ra_chuc_nang.png` | TV3 |
| ERD có nguồn và ảnh | `diagrams/erd_v1.drawio`, `diagrams/erd_v1.png` | TV2 + TV3 |
| Ánh xạ, từ điển dữ liệu, chuẩn hóa và ma trận kiểm soát ràng buộc | `docs/04_data_dictionary_va_chuan_hoa.md` | TV2 + TV3 |
| DDL thống nhất với thiết kế | `sql/01_schema.sql` | TV2 |
| Chương 1–3 có nội dung thực | `docs/02_bao_cao_suon.md` | TV2 + TV3 |
| Ma trận 20 câu hỏi, nhận xét review, quyết định và bàn giao Gate 1 | `meetings/decision_log.md` | Cả ba xác nhận |

Giữ đề cương làm tài liệu định hướng và dẫn đến các sản phẩm trên. Dùng tên tệp trong checklist hiện tại làm chuẩn; cập nhật tham chiếu cũ thay vì tạo nhiều bản có cùng chức năng.

## 5. Kiểm tra và điều kiện nghiệm thu

### Kiểm tra bắt buộc trong tuần 1

1. **Nhất quán thiết kế:** Đủ 7 bảng; mọi cột, khóa, miền giá trị và NULL trong ERD/từ điển/DDL khớp nhau; hai FK đợt cũ/mới không bị nhầm vai trò.
2. **Kiểm tra tình huống trên giấy:** Có lời giải thích đúng cho đợt một ngày, ngày kết thúc đúng d, đợt kết thúc trước d, bắt đầu sau d nhưng kết thúc NULL, hai đợt cùng loại chồng lấn, và hai loại khác nhau cùng hiệu lực.
3. **Kiểm tra biến động trên giấy:** Có ví dụ đúng/sai cho ba loại sự kiện; nội bộ khác cư dân hoặc cùng hộ phải bị coi là không hợp lệ; ngày đóng/mở khớp quy ước. Phân biệt rõ ràng buộc đã có trong DDL với ràng buộc chờ triển khai.
4. **Khả năng đáp ứng truy vấn:** Đủ 20 hàng trong ma trận; mô hình có đường nối và trường dữ liệu để trả lời từng câu; không thiếu trường cho hai nhánh tổ cũ/tổ mới, hộ trống, địa chỉ chưa có hộ và cư dân chưa có đợt.
5. **Chất lượng báo cáo:** Chương 1–3 đọc liên tục được; sơ đồ rõ ở A4; tên và quy tắc thống nhất; mọi phần đang chờ tuần 2 hoặc người khác đều được ghi đúng trạng thái.

Tuần 1 chưa yêu cầu kết quả PASS của bộ test PostgreSQL thuộc tuần 2. Không tích hoàn thành kiểm thử thực thi chỉ dựa trên kiểm tra tài liệu.

### Gate 1 chỉ được ghi PASS khi

- Các sản phẩm của TV1 đã tồn tại, mở được và đạt các kiểm tra trên.
- TV2/TV3 đã phản hồi về thiết kế và khả năng đáp ứng truy vấn; mọi lỗi ảnh hưởng khóa, quan hệ hoặc cách hiểu thời gian đã được xử lý.
- Quyết định thời gian, phạm vi, tên bảng/cột, phương án kiểm soát ràng buộc và phiên bản môi trường được ghi trong biên bản.
- Có bản schema v1 được nhóm xác nhận và hồ sơ bàn giao; những việc thuộc tuần 2 được liệt kê riêng với owner và hạn.
- Checklist chỉ đánh dấu các mã có đầu ra tương ứng và review thực tế. Nếu còn thiếu tên/MSSV/mã lớp, ghi là thông tin hành chính chờ bổ sung, không tự suy đoán.

**Nếu bị thiếu thời gian:** Giảm thời gian trang trí và rút gọn diễn giải lặp lại; ưu tiên đặc tả, hai sơ đồ, từ điển/chuẩn hóa, đối chiếu thiết kế và review. Nếu thiếu xác nhận của nhóm, báo trạng thái chờ review cùng nguyên nhân cụ thể; không ghi Gate 1 đã đạt.
