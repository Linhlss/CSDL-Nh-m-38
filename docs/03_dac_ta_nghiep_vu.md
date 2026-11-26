# ĐẶC TẢ NGHIỆP VỤ — BỘ BÀN GIAO THIẾT KẾ v1

**Đề tài 17:** Xây dựng cơ sở dữ liệu quản lý cư dân và biến động cư trú tại một phường mô phỏng.  
**Owner:** TV1. **Ngày:** 11/11/2026. **Trạng thái hiện hành:** thiết kế v1, Gate 1 PASS theo xác nhận chủ repo tiếp nhận 16/11/2026; [nguồn xác nhận](../meetings/decision_log.md#gate1).
**Cấu trúc dữ liệu:** `sql/01_schema.sql`. **Từ điển và chuẩn hóa:** `04_data_dictionary_va_chuan_hoa.md`.

**Làm rõ C1 ngày 15/11/2026:** agent hỗ trợ TV1 cập nhật phạm vi chức năng 3.2/P3 theo yêu cầu chủ repo; giữ nguyên schema. Đây là nội dung kỹ thuật để nhóm tiếp nhận, không phải xác nhận hoặc chữ ký Gate 1 thay thành viên.

## 1. Bài toán, mục tiêu và ranh giới

Một phường giả lập được chia thành nhiều tổ dân phố. Mỗi tổ quản lý các địa chỉ, mỗi địa chỉ có thể chứa nhiều nhóm hộ. Cán bộ cần quản lý hồ sơ cư dân, truy được nơi cư trú ở một ngày cụ thể và theo dõi chuyển đến, chuyển đi hoặc chuyển giữa các hộ trong phường. Nếu chỉ ghi địa chỉ hiện tại trong hồ sơ cư dân, việc đổi địa chỉ sẽ làm mất thông tin quá khứ. Vì vậy mô hình tách hồ sơ người, vị trí địa lý, các đợt cư trú và nhật ký sự kiện.

Sản phẩm học thuật phải có phân tích chức năng, ERD, ánh xạ quan hệ và ràng buộc, 10 biểu thức đại số quan hệ, 10 SQL, hai minh họa bảo mật và báo cáo có minh chứng. Bản thiết kế tuần 1 cung cấp nền tảng chung cho những phần triển khai này. Quy mô dữ liệu gợi ý là 643 bản ghi, không phải điều kiện để công nhận thiết kế đúng.

Phạm vi chỉ gồm một phường mô phỏng, dữ liệu giả lập, PostgreSQL từ phiên bản 15 và công cụ quản trị CSDL. Không xây website, đăng nhập ứng dụng, thủ tục pháp lý, tích hợp VNeID, khai sinh/tử vong hay cơ sở dữ liệu dân cư thật. Mô hình không tuyên bố phản ánh đầy đủ quy định pháp luật về cư trú.

## 2. Thuật ngữ thống nhất

| Thuật ngữ | Định nghĩa và cách nhận diện |
|---|---|
| Cư dân | Hồ sơ nhân vật giả lập trong `cu_dan`, định danh bằng `ma_cu_dan`; hai người trùng tên vẫn là hai hồ sơ |
| Tổ dân phố | Đơn vị phân chia địa bàn bên trong phường; không cần bảng phường vì chỉ mô hình hóa một phường |
| Địa chỉ | Vị trí mô phỏng thuộc đúng một tổ; duy nhất theo cặp tổ và chuỗi địa chỉ chuẩn |
| Nhóm hộ cư trú | Đơn vị tập hợp cư dân tại một địa chỉ; không khẳng định quan hệ huyết thống, không lưu chủ hộ pháp lý |
| Đợt cư trú | Một người ở một hộ theo một loại cư trú trong khoảng ngày; lưu tại `qua_trinh_cu_tru` |
| Loại cư trú | Hai giá trị mô phỏng `THUONG_TRU` và `TAM_TRU` |
| Biến động | Sự kiện `CHUYEN_DEN`, `CHUYEN_DI` hoặc `CHUYEN_NOI_BO`, tham chiếu các đợt liên quan |
| Ngày chuyển | Ngày người bắt đầu cư trú ở nơi mới hoặc bắt đầu không còn cư trú ở nơi cũ |
| Ngày tham chiếu d | Mốc dùng để xác định hiệu lực; mặc định cho đối chiếu bài tập là `2026-11-20` |
| Tài khoản nghiệp vụ | Danh mục người ghi nhận, vai trò và trạng thái mô phỏng trong `tai_khoan`; không thực thi quyền DB |
| Role PostgreSQL | Đối tượng quyền thật do TV3 thiết lập khi triển khai bảo mật; độc lập với các dòng `tai_khoan` |

## 3. Tác nhân và quyền ở mức nghiệp vụ

| Tác nhân | Nhu cầu | Giới hạn |
|---|---|---|
| Cán bộ quản lý cư dân | Quản lý địa bàn/hộ/hồ sơ; mở, đóng đợt và ghi biến động; tra cứu lịch sử | Không tự sửa cấu trúc hoặc cấp quyền DB |
| Cán bộ tổng hợp | Tra cứu, thống kê theo tổ, loại và thời gian | Không sửa dữ liệu gốc; chỉ xem cột hoặc VIEW được cấp quyền (thực thi bằng role `csdl17_report`, không bằng cột `vai_tro`; xem quyết định X01 bên dưới) |
| Quản trị CSDL | Tạo bảng, duy trì ràng buộc, cấp/thu hồi quyền và hỗ trợ kiểm thử | Không dùng quyền quản trị để đóng vai role chỉ đọc trong minh họa bảo mật |

Đây là phân công chức năng. Việc các quyền được PostgreSQL thực thi thuộc script bảo mật tuần 2, chưa được suy ra từ cột `vai_tro`.

**Quyết định X01 — phương án (b), 20/11/2026.** TV1 chọn phương án (b), TV3 đã đồng thuận trong review W3-T3-08; **TV1 thông báo ngày 20/11/2026 rằng TV2 và TV3 đã thống nhất**. Gate 2 được ghi nhận trong [nhật ký quyết định mục 10](../meetings/decision_log.md#gate2) dựa trên nguồn TV1 báo lại (không thay cho comment review/chữ ký độc lập).

- **Bản chất của `vai_tro`:** cột `tai_khoan.vai_tro` (`QUAN_TRI`, `CAN_BO`, `THONG_KE`) là thuộc tính nghiệp vụ mô tả người ghi nhận. Nó **không** là cơ chế phân quyền. Không trigger hay CHECK nào dùng cột này để chặn ghi; B14 chỉ yêu cầu tài khoản tồn tại và ở trạng thái `HOAT_DONG`.
- **Quyền thật:** PostgreSQL thực thi qua các role `csdl17_admin`, `csdl17_reader` và `csdl17_report` trong `sql/05_security.sql`. Role `csdl17_report` (vai trò thống kê ở mức CSDL) chỉ đọc VIEW tổng hợp và bị từ chối mọi lệnh ghi.
- **Hệ quả công bố:** trong seed636 có 13/63 sự kiện do `thongke_01` (`THONG_KE`) ghi và 11/63 do `admin_demo` (`QUAN_TRI`) ghi. Đây là dữ liệu mô phỏng hợp lệ theo lược đồ hiện tại. Không được diễn giải số liệu này thành "cán bộ thống kê đã bị CSDL ngăn ghi".
- **Phạm vi:** ràng buộc "chỉ tài khoản `CAN_BO` được ghi biến động" nằm ngoài thiết kế v1 (xem mục giới hạn ở Chương 3). Nếu nhóm muốn thực thi ràng buộc này, phải làm theo phương án (a): thêm trigger kiểm `vai_tro` và tái sinh seed. Việc đó kéo theo cập nhật QSQL10, manifest và log.

## 4. Phân rã chức năng và dữ liệu đọc/ghi

![Sơ đồ phân rã chức năng](../diagrams/phan_ra_chuc_nang.png)

| Nhóm cấp 1 | Chức năng cấp 2 | Dữ liệu đọc | Dữ liệu ghi |
|---|---|---|---|
| 1. Quản lý địa bàn | 1.1 Tổ dân phố; 1.2 Địa chỉ | `to_dan_pho`, `dia_chi` | Hai bảng tương ứng |
| 2. Quản lý hộ và cư dân | 2.1 Nhóm hộ; 2.2 Hồ sơ cư dân | `dia_chi`, `ho_cu_tru`, `cu_dan` | `ho_cu_tru`, `cu_dan` |
| 3. Quản lý quá trình cư trú | 3.1 Mở đợt; 3.2 Kết thúc đợt | `cu_dan`, `ho_cu_tru`, `qua_trinh_cu_tru` | `qua_trinh_cu_tru` |
| 4. Ghi nhận biến động | 4.1 Chuyển đến; 4.2 Chuyển đi; 4.3 Chuyển nội bộ | Đợt, hộ, cư dân và `tai_khoan` | `qua_trinh_cu_tru`, `bien_dong_cu_tru` |
| 5. Tra cứu và thống kê | 5.1 Hiện tại; 5.2 Lịch sử; 5.3 Thống kê | Bảy bảng hoặc VIEW được phép | Không ghi dữ liệu nghiệp vụ |
| 6. Quản trị và bảo mật | 6.1 Vai trò; 6.2 Giới hạn truy cập | Danh mục role/quyền của PostgreSQL | Đối tượng role, quyền, VIEW; không tự ghi `tai_khoan` để cấp quyền |

Các đường nối trên sơ đồ thể hiện phân rã chức năng, không thể hiện trình tự xử lý hoặc luồng dữ liệu.

## 5. Quy tắc thiết kế và nghiệp vụ

| Mã | Quy tắc thống nhất |
|---|---|
| B01 | Tổ có 0..N địa chỉ; địa chỉ thuộc đúng một tổ. Địa chỉ có 0..N hộ; hộ thuộc đúng một địa chỉ |
| B02 | Mỗi đợt thuộc đúng một cư dân và một hộ; cư dân/hộ có thể chưa có đợt nào. Quan hệ cư dân–hộ nhiều–nhiều được giải qua đợt |
| B03 | Mã định danh là khóa; tên cư dân không duy nhất. Tên tổ và tên đăng nhập duy nhất, cặp `(ma_to, dia_chi_chuan)` duy nhất |
| B04 | Ngày bắt đầu và các ngày sự kiện bắt buộc; ngày kết thúc có thể NULL, nếu có phải >= ngày bắt đầu. Đợt chỉ một ngày là hợp lệ |
| B05 | Đợt hiệu lực tại d khi `ngay_bat_dau <= d AND (ngay_ket_thuc IS NULL OR ngay_ket_thuc >= d)`; ngày cuối được tính bao gồm |
| B06 | Không cho hai khoảng ngày giao nhau khi cùng cư dân và cùng loại cư trú. Hai loại khác nhau đồng thời được cho phép trong mô hình mô phỏng này |
| B07 | Chuyển đến chỉ có đợt mới; chuyển đi chỉ có đợt cũ; chuyển nội bộ có hai đợt khác nhau. Ngoài ba loại này là không hợp lệ |
| B08 | Hai đợt của chuyển nội bộ phải cùng cư dân và khác hộ; khác hộ nhưng cùng địa chỉ hoặc cùng tổ vẫn là chuyển nội bộ hợp lệ |
| B09 | Với ngày chuyển t: chuyển đến có `moi.ngay_bat_dau = t`; chuyển đi có `cu.ngay_ket_thuc = t - 1 ngày`; nội bộ thỏa cả hai. Đợt cũ phải đã đóng |
| B10 | Đóng đợt cũ, mở đợt mới và ghi sự kiện là một giao dịch; lỗi một bước phải hủy toàn bộ |
| B11 | Hộ giữ địa chỉ ổn định; không đổi liên kết hộ–địa chỉ hoặc địa chỉ–tổ đã được dùng trong lịch sử để mô phỏng chuyển chỗ ở. Tạo bản ghi mới khi cần |
| B12 | Không xóa vật lý hồ sơ/đợt đang được tham chiếu; không xóa lịch sử để biểu diễn chuyển đi. DDL dùng FK không cascade |
| B13 | `qua_trinh_cu_tru` là nguồn sự thật theo thời gian. Biến động chỉ ghi sự kiện, ngày, các mã đợt và người ghi; không sao chép tên hay địa chỉ. Đợt nhập/hiệu chỉnh lịch sử hoặc tạm trú hết hạn có thể không có sự kiện theo phạm vi C1/P3 |
| B14 | Tài khoản ghi nhận phải tồn tại; quy trình ghi mới dùng tài khoản `HOAT_DONG`. Việc khóa tài khoản không làm mất nhật ký cũ hoặc thu hồi role PostgreSQL tự động |
| B15 | Bộ dữ liệu có ngày sinh <= ngày bắt đầu cư trú và ngày lập hộ <= ngày bắt đầu. Cấm chuỗi tên/địa chỉ rỗng hoặc chỉ khoảng trắng khi chuẩn bị dữ liệu. Trong DDL cơ bản v1 chưa có; tại `02_constraints.sql` đã bổ sung CHECK tên/địa chỉ rỗng và trigger ngày hai chiều |
| B16 | Các câu “đang” dùng d. QRA09/QSQL07 chỉ coi người đã từng cư trú khi có đợt bắt đầu <= d. QRA04/QRA07/QSQL05/QSQL06 xét toàn bộ đợt đã lưu; nếu có đợt tương lai, phải ghi rõ đó là toàn bộ dữ liệu đã ghi nhận |
| B17 | Số người trong mỗi hộ/tổ là số mã cư dân phân biệt. Một người có thể thuộc hai tổ theo hai loại; tổng số người của các tổ không luôn bằng số người phân biệt toàn phường |
| B18 | Mọi dữ liệu dân cư và địa chỉ là giả lập; không có CCCD/số điện thoại thật. Mật khẩu không được lưu trong danh mục tài khoản hoặc mã nguồn |

Mỗi đợt gắn tối đa một biến động trong từng vai trò cũ hoặc mới. Hai ràng buộc UNIQUE của `sql/02_constraints.sql` chặn trùng cùng vai trò ngay khi ghi (23505). Quy tắc E1 vẫn được đối chiếu bằng `sql/06_validation.sql`. [Thiết kế X07](../meetings/decision_log.md#review-x07)

**Quyết định lịch sử ngày 12/11/2026 (trước X07):** Giữ khả năng lưu 0..N tham chiếu ở mức schema để tương thích bộ bàn giao, nhưng nhiều sự kiện dùng cùng đợt trong **cùng vai trò** là cảnh báo ghi trùng phải xử lý trước nghiệm thu. Chạy riêng V_E1_CU và V_E1_MOI trong `sql/06_validation.sql`, yêu cầu cả hai trả 0 dòng. Một đợt là đợt mới của sự kiện đến, rồi là đợt cũ của sự kiện đi/nội bộ, không bị coi là trùng. Validation gọi `fn_assert_e1()` để báo lỗi và làm FAIL đợt nghiệm thu khi có trùng; không tự chặn thao tác INSERT trước thời điểm validation, không tự xóa hoặc gộp nhật ký. Quyết định này không thay thế các ràng buộc xuyên bảng tuần 2.

## 6. Đặc tả sáu quy trình

### P1 — Thiết lập địa bàn và hộ cư trú

- **Đầu vào:** tên tổ; mã tổ và địa chỉ chuẩn; mã địa chỉ và ngày lập hộ khi tạo nhóm hộ.
- **Điều kiện:** đầu vào giả lập, tên/địa chỉ không rỗng; tổ tồn tại trước địa chỉ, địa chỉ tồn tại trước hộ; không trùng khóa nghiệp vụ B03.
- **Xử lý:** chuẩn hóa khoảng trắng; tra cứu bản ghi cha; tạo tổ, địa chỉ hoặc hộ theo tác vụ được chọn. Một địa chỉ được phép có nhiều hộ, kể cả hộ chưa có cư dân.
- **Đọc/ghi:** đọc `to_dan_pho`, `dia_chi`; ghi bảng được tạo trong ba bảng địa bàn/hộ.
- **Đầu ra:** mã bản ghi và thông tin đã lưu. **Lỗi:** tổ/địa chỉ cha không tồn tại, tên tổ/cặp địa chỉ bị trùng, thiếu ngày lập. Không đổi quan hệ địa lý đã có lịch sử (B11).

### P2 — Thêm và hiệu chỉnh hồ sơ cư dân

- **Đầu vào:** họ tên, ngày sinh, giới tính; ghi chú tùy chọn; mã cư dân khi hiệu chỉnh.
- **Điều kiện:** họ tên không rỗng, ngày sinh hợp lệ; giới tính thuộc `Nam`, `Nu`, `Khac`. Khi hiệu chỉnh phải tìm thấy mã và giữ tương thích với các đợt đã lưu.
- **Xử lý:** kiểm tra đầu vào; tạo hồ sơ hoặc sửa thuộc tính mô tả. Không dùng họ tên làm khóa và không gắn hộ/địa chỉ hiện tại trực tiếp vào hồ sơ.
- **Đọc/ghi:** `cu_dan`; đọc đợt cư trú khi kiểm tra hiệu chỉnh ngày sinh. **Đầu ra:** hồ sơ theo mã. **Lỗi:** thiếu trường, sai miền giới tính, mã không tồn tại hoặc ngày sinh mâu thuẫn lịch sử.
- **Giới hạn X06 (chốt 20/11/2026):** B15 chỉ so `ngay_sinh` và `ngay_lap` với **ngày bắt đầu các đợt cư trú**, theo hai chiều: khi ghi đợt và khi sửa ngày của người/hộ đã có đợt. Với cư dân hoặc hộ **chưa có đợt nào**, CSDL không có mốc để so, nên vẫn nhập được ngày sinh hoặc ngày lập hộ ở tương lai. `tests/constraints_week2.sql` chứng minh điều này bằng cư dân và hộ 99011 có ngày `2027-01-01`. Trường hợp này nằm **ngoài phạm vi B15 hiện tại** và được ghi vào giới hạn ở Chương 3. Nhóm không thêm CHECK so với `CURRENT_DATE` vì ràng buộc phụ thuộc thời điểm chạy sẽ làm kiểm thử không tái lập được. Khi người hoặc hộ đó được mở đợt đầu tiên, B15 sẽ chặn nếu ngày bắt đầu đợt sớm hơn ngày sinh hoặc ngày lập hộ.

### P3 — Mở và quản lý đợt cư trú

- **Đầu vào:** mã cư dân, mã hộ, loại, ngày bắt đầu, ngày kết thúc tùy chọn.
- **Điều kiện:** người/hộ tồn tại; thỏa B04, B06, B15. Đợt tương lai được phép lưu nhưng không thuộc tập hiệu lực trước ngày bắt đầu.
- **Xử lý:** kiểm tra quan hệ, ngày và các khoảng cùng người/cùng loại; tạo hoặc hiệu chỉnh đợt. Nhập lịch sử ban đầu được phép không có nhật ký sự kiện. Khi thay đổi đợt đã có sự kiện, phải kiểm tra lại các sự kiện tham chiếu theo B08–B09.
- **Đọc/ghi:** đọc `cu_dan`, `ho_cu_tru`, `qua_trinh_cu_tru`, các sự kiện liên quan; ghi `qua_trinh_cu_tru`.
- **Đầu ra:** mã đợt. **Lỗi:** FK sai, loại sai, ngày đảo, chồng lấn, ngày sinh/ngày lập hộ không phù hợp. Các thao tác chuyển thực tế trong mô hình thực hiện bằng P4/P5 để giữ nhật ký nhất quán.

**Phạm vi chức năng 3.2 — Kết thúc đợt (C1):** được ghi hoặc hiệu chỉnh ngày kết thúc khi nhập/sửa lịch sử, hoặc khi đợt tạm trú hết hạn mà không phát sinh hành vi chuyển chỗ ở. Những trường hợp này không bắt buộc tạo `CHUYEN_DI`; không tạo sự kiện giả chỉ để mọi đợt đều có nhật ký. Chuyển đến, chuyển đi hoặc chuyển nội bộ thực tế vẫn phải dùng P4/P5 và ghi sự kiện trong cùng giao dịch. Quyết định C1 không cho phép bỏ nhật ký của P4/P5 hoặc làm sai B08–B09 ở sự kiện đã tham chiếu đợt.

### P4 — Ghi nhận chuyển đến

- **Đầu vào:** thông tin đợt mới, ngày chuyển t, tài khoản ghi nhận và ghi chú tùy chọn.
- **Điều kiện:** P3 hợp lệ; tài khoản tồn tại và đang hoạt động; ngày bắt đầu mới = t.
- **Ngày hiệu lực và thời điểm ghi (X05, chốt 20/11/2026):**
  - `ngay_bien_dong` = t là **ngày hiệu lực** của biến động. `thoi_diem_ghi` là **thời điểm hệ thống ghi nhận** sự kiện. Hai giá trị độc lập với nhau.
  - Được phép ghi nhận trước một biến động có hiệu lực trong tương lai (đăng ký trước), nên trường hợp `ngay_bien_dong > thoi_diem_ghi::date` là hợp lệ. Giống P3, đợt tương lai không thuộc tập hiệu lực trước ngày t.
  - Không có ràng buộc so sánh hai cột này, và không ràng buộc nào dùng `CURRENT_DATE`, để kiểm thử tái lập được.
  - Lưu ý về dữ liệu: seed636 không nạp giá trị `thoi_diem_ghi`, nên cột nhận `DEFAULT CURRENT_TIMESTAMP` lúc nạp. Vì vậy số dòng có `ngay_bien_dong > thoi_diem_ghi::date` phụ thuộc ngày nạp và không phải dữ liệu nghiệp vụ cố định. Ví dụ nạp ngày 20/11/2026 thì có 2 sự kiện như vậy, với ngày hiệu lực 25/11 và 01/12/2026.
- **Xử lý:** bắt đầu giao dịch → tạo đợt mới → tạo `CHUYEN_DEN` chỉ tham chiếu đợt mới → commit. Nếu lỗi, rollback cả hai bước ghi.
- **Đọc/ghi:** đọc người/hộ/tài khoản/đợt; ghi đợt và biến động. **Đầu ra:** hai mã liên kết. **Lỗi:** mọi lỗi P3, tài khoản khóa, hình dạng sự kiện hoặc ngày không khớp.

### P5 — Chuyển đi hoặc chuyển nội bộ

- **Đầu vào chung:** mã đợt cũ, ngày chuyển t, tài khoản; với nội bộ có thêm hộ mới và loại cư trú mới.
- **Điều kiện chung:** đợt cũ tồn tại, đang mở và đã bắt đầu trước t; người ghi hoạt động; ngày đóng dự kiến t−1 không trước ngày bắt đầu. Đợt đã đóng chỉ được hiệu chỉnh qua quy trình sửa có kiểm tra lịch sử, không đóng lặp như một chuyển mới.
- **Nhánh chuyển đi:** trong một giao dịch, khóa/kiểm tra đợt cũ → đặt kết thúc = t−1 → ghi `CHUYEN_DI` chỉ có đợt cũ → commit.
- **Nhánh nội bộ:** thêm điều kiện hộ mới tồn tại và khác hộ cũ. Trong một giao dịch, đóng đợt cũ tại t−1 → tạo đợt mới cùng cư dân từ t → ghi `CHUYEN_NOI_BO` tham chiếu cả hai → commit. Kiểm tra chồng lấn sau thay đổi.
- **Đọc/ghi:** đọc người/hộ/đợt/tài khoản; cập nhật đợt cũ, thêm đợt mới nếu có và thêm sự kiện.
- **Đầu ra:** lịch sử và nhật ký khớp nhau. **Lỗi:** khác cư dân, cùng hộ, sai thứ tự ngày, chồng lấn, tài khoản khóa hoặc bước ghi thất bại; tất cả đều rollback. Cách khóa và kiểm thử đồng thời được triển khai tuần 2.

### P6 — Tra cứu và thống kê

- **Đầu vào:** d, tổ/địa chỉ/hộ, loại cư trú, khoảng tháng và loại sự kiện tùy câu hỏi; vai trò thực thi.
- **Điều kiện:** tham số có kiểu hợp lệ; người gọi được cấp quyền tương ứng. Ngày đối chiếu cố định là 20/11/2026; kỳ thống kê tháng dùng khoảng nửa mở từ đầu tháng đến trước đầu tháng sau.
- **Xử lý:** nối qua đợt → hộ → địa chỉ → tổ; áp dụng đúng thời gian; lấy mã phân biệt khi thống kê người. Dùng LEFT JOIN giữ tổ/tài khoản không phát sinh và đặt bộ lọc đợt phù hợp trong ON.
- **Đọc/ghi:** chỉ đọc bảng/VIEW được phép. **Đầu ra:** tập danh sách hoặc thống kê có khóa và cột đã quy định trong ma trận câu hỏi. **Lỗi:** tham số sai, thiếu quyền; kết quả rỗng đúng điều kiện không phải lỗi.

## 7. Ví dụ quy ước thời gian

Nhân vật mô phỏng CD-A ở H-A từ 01/11/2026 đến hết 14/11/2026, chuyển sang H-B từ 15/11/2026. Sự kiện nội bộ có ngày 15/11, đợt cũ kết thúc 14/11, đợt mới bắt đầu 15/11. Ở ngày 14/11 người thuộc H-A; ngày 15/11 thuộc H-B. Hai đợt cùng loại không giao nhau.

Một đợt bắt đầu 25/11 và kết thúc NULL không có hiệu lực vào 20/11. Một đợt kết thúc 20/11 vẫn có hiệu lực vào 20/11. Nếu người chỉ có đợt tương lai thì không thuộc QRA09/QSQL07; nếu chưa có bất kỳ đợt nào thì thuộc QRA06. Đây là ví dụ thiết kế, không phải dữ liệu đã được nạp.

Ví dụ C1: một người chỉ có đợt tạm trú 01/11–19/11/2026, hết hạn và không có `CHUYEN_DI`. Ngày 19/11 người đó còn đợt hiệu lực; ngày 20/11 người đó thuộc QRA09/QSQL07 vì đã từng cư trú và không còn đợt hiệu lực. Người chưa có đợt hoặc chỉ có đợt tương lai không thuộc kết quả này. Các truy vấn dựa vào khoảng ngày của đợt, không lấy sự tồn tại của `CHUYEN_DI` làm điều kiện thay thế.

## 8. Liên kết bàn giao

- `04_data_dictionary_va_chuan_hoa.md`: giao diện dữ liệu và ràng buộc.
- `07_ma_tran_truy_van_va_review.md`: đủ 20 câu hỏi và review tài liệu hiện có.
- `../tests/week1_design_cases.md`: các tình huống thiết kế với đáp án kỳ vọng.
- `../meetings/decision_log.md`: quyết định thiết kế và trạng thái Gate 1.
- [Checklist tuần 2](03_CHECKLIST_DU_AN.md#tuan-2-hien-hanh): việc tiếp theo của từng người.
