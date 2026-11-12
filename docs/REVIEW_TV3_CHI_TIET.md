# REVIEW CHI TIẾT PHẦN TV3 — CẬP NHẬT 13/11/2026

**Cập nhật mới nhất:** PR #1 đã merge vào main tại `d84571e` ngày 13/11. F03 đã sửa bằng preflight và transaction thiết lập, F05 đã cập nhật mô tả PR; bộ kiểm chứng trước merge đạt **146/146**, gồm 144 kiểm tra chức năng và 2 phép tái hiện. Chi tiết mới ở mục 7, xác nhận merge ở mục 8. Các mục 1–6 lưu kết quả review ngày 12/11 để giữ lịch sử.

**Người thực hiện:** kiểm chứng kỹ thuật hỗ trợ TV1 theo yêu cầu chủ repo. **Đối tượng review ngày 12/11:** [PR #1](https://github.com/Linhlss/CSDL-Nh-m-38/pull/1), nhánh `tv3/dai-so-quan-he-bao-mat`, [commit gốc 7abe4d5](https://github.com/Linhlss/CSDL-Nh-m-38/tree/7abe4d54f7e7cc96ac086b7e1127073493152e24). Khi đó PR chưa merge; không gửi review hoặc ký xác nhận thay thành viên.

**Kết luận:** phần đặc tả tuần 1 của TV3 đủ nội dung để tiếp tục; 10 biểu thức được soát thủ công và 10 SQL kiểm chứng khớp đầy đủ kết quả trên fixture nhỏ cùng các ca biên bổ sung. Hai demo quyền B1/B2 đạt trên cluster sạch. Có một lỗi B09 đã sửa, một giới hạn tái sử dụng role cần TV3 xử lý trước khi dùng trên cluster có sẵn và một tham chiếu PR còn cũ. Chưa nghiệm thu trên seed chính thức, chưa PASS Gate 1 chung.

## 1. Phiên bản, môi trường và bằng chứng

- PostgreSQL **17.11**, Debian, aarch64; Python **3.13.5** trên máy chủ macOS. Phiên bản Python thực tế được lưu trong JSON nếu môi trường chạy lại thay đổi.
- Image chính thức `postgres:17.11`, digest `sha256:ff87138949ad9a46f32ff23bd6852b52ce024a13dffe9b4087be98292cdd3b4f`.
- Container tạm `csdl17-tv3-review-20261112`, mạng `none`, không publish cổng, dữ liệu trên tmpfs. Ba DB riêng `review_original`, `review_fixed`, `review_fixture`; không kết nối DB của nhóm.
- Hoàn tất lần chạy: **12/11/2026 20:56:23 +07:00**. [Bằng chứng lịch sử 89 kiểm tra tại 30f557f](https://github.com/Linhlss/CSDL-Nh-m-38/blob/30f557f3762c43831a5d10b8b11e4acf8f080412/tests/tv3_review_results.json). Kết quả hiện hành 13/11 ở mục 7.
- Fixture đã sửa được commit riêng tại [355aa6e](https://github.com/Linhlss/CSDL-Nh-m-38/commit/355aa6ea588afa0ec1716b144e6baaa81094dd26), trên nhánh `codex/review-tv3`. Lần chạy dùng worktree của `7abe4d5` cộng bản sửa này; hash fixture trong JSON xác định chính xác nội dung đã chạy. Các biểu thức và script bảo mật gốc không bị sửa.
- Báo cáo cũ của TV3 nói 11/11. Lần kiểm chứng này thực hiện độc lập; **89/89 kiểm tra đạt = 86 kiểm tra chức năng + 3 phép tái hiện lỗi/giới hạn**. PASS của phép tái hiện nghĩa là xác nhận được vấn đề, không phải vấn đề đã được sửa.

Lệnh tái lập **phiên bản hiện hành** trên container mới, từ thư mục gốc repo đã tích hợp bản sửa:

```sh
docker run --detach --rm --name csdl17-tv3-merge-20261113 \
  --label csdl17.review=tv3 --network none \
  --tmpfs /var/lib/postgresql/data:rw \
  -e POSTGRES_HOST_AUTH_METHOD=trust postgres:17.11
docker exec csdl17-tv3-merge-20261113 pg_isready -U postgres
python3 scripts/review_tv3.py --container csdl17-tv3-merge-20261113 --tv3-root .
docker rm --force csdl17-tv3-merge-20261113
```

`--tv3-root .` dùng cùng checkout đã tích hợp; cũng có thể trỏ tới checkout nhánh sửa riêng. Script chỉ nhận container có nhãn `csdl17.review=tv3`, đọc SQL từ tài liệu/fixture TV3 và validation trong repo. Chạy một lần trên mỗi container mới, sau khi pg_isready báo sẵn sàng; dùng bốn DB riêng gồm DB guard. Hash trong JSON giúp kiểm tra đúng phiên bản đầu vào. Lệnh trên ghi lại kết quả hiện hành; bằng chứng ngày 12/11 được giữ ở commit lịch sử đã dẫn.

## 2. Phát hiện và hướng xử lý

| Mã | Mức | Bằng chứng / ảnh hưởng ngày 12/11 | Trạng thái ngày 12/11 / người xử lý; cập nhật xem mục 7 |
|---|---|---|---|
| F01 | Vừa — sai dữ liệu nghiệp vụ | [Fixture gốc dòng 54–65](https://github.com/Linhlss/CSDL-Nh-m-38/blob/7abe4d54f7e7cc96ac086b7e1127073493152e24/tests/ra_fixture.sql#L54-L65): đợt 6 kết thúc 30/06/2025 nhưng chuyển đi cũng 30/06. V_B09 phát hiện đúng 1 sự kiện; 10 truy vấn vẫn có thể cho đáp án đúng nên chúng không phát hiện lỗi này | **Đã sửa** ngày chuyển đi thành 01/07/2025 ở `355aa6e`; fixture sửa trả 0 vi phạm B09. TV3 tiếp nhận commit |
| F02 / E1 | Vừa — rủi ro đếm trùng sự kiện | Schema cho ghi trùng cùng FK cũ hoặc mới trong cùng vai trò. Không được dùng COUNT DISTINCT cư dân để che lỗi vì SQL08/10 phải đếm sự kiện | **TV1 đã trả lời** bằng DEC06: giữ schema, validation phải trả 0 dòng trước nghiệm thu. TV2 chạy trên seed; TV1/TV2 xử lý các dòng bị cảnh báo |
| F03 | Vừa, có điều kiện — role có sẵn | [Script dòng 39–50](https://github.com/Linhlss/CSDL-Nh-m-38/blob/7abe4d54f7e7cc96ac086b7e1127073493152e24/sql/05_security.sql#L39-L50) chỉ CREATE nếu chưa tồn tại. Tái hiện: đặt reader thành SUPERUSER rồi chạy lại phần thiết lập, thuộc tính này vẫn còn; REVOKE trên bảng không đủ khôi phục giới hạn demo. Đầu vào đó vi phạm tiền điều kiện role không đặc quyền đã nêu trong tài liệu | **Còn mở, TV3:** thêm kiểm tra dừng sớm nếu role là superuser/owner hoặc có quyền kế thừa vượt mức; không tự hạ quyền role có sẵn trên cluster dùng chung. B1/B2 hiện được xác nhận trên cluster sạch, không khẳng định script chuẩn hóa mọi role có sẵn |
| F04 | Thấp — kiểm thử thủ công dễ bỏ sót | Fixture chỉ in expected rồi SELECT, chưa ASSERT kết quả; psql exit 0 vẫn có thể đi kèm đáp án sai | **Đã có lớp kiểm chứng bổ sung:** `scripts/review_tv3.py` so sánh đầy đủ các cột/tập dòng, dừng nghiệm thu nếu có FAIL. Fixture đứng riêng vẫn là bản in kết quả, không phải bộ assert tự động |
| F05 / RV10 | Thấp — tham chiếu chưa cập nhật | Mô tả PR vẫn dùng `03_relational_algebra.md`, `05_security_plan.md`, nhờ review cách định nghĩa Q_d bằng hiệu cũ. Phiếu TV3 nói đã cập nhật mô tả PR nhưng kiểm tra GitHub 12/11 vẫn thấy nội dung cũ | **Còn mở, TV3:** sửa mô tả PR sang 06a/06b và cách chuẩn bị Q_d hiện hành. Báo cáo này dùng đúng file thật |

Không thêm UNIQUE, đổi cột, tự gộp/xóa sự kiện hoặc thay đổi câu hỏi của TV2. Truy vấn B09 chỉ phát hiện vi phạm ngày; các trigger/ràng buộc xuyên bảng và transaction tuần 2 vẫn cần TV1 triển khai.

## 3. Review từng câu đại số quan hệ

Nguồn: [06a tại commit được review](https://github.com/Linhlss/CSDL-Nh-m-38/blob/7abe4d54f7e7cc96ac086b7e1127073493152e24/docs/06a_dai_so_quan_he.md). Bảng ghi khóa cho dễ đọc; bộ chạy so sánh cả họ tên, ngày sinh hoặc địa chỉ khi có trong đầu ra. Không chỉ đối chiếu số dòng. Kiểm chứng SQL cộng review công thức thủ công không phải một chứng minh hình thức tự động cho mọi dữ liệu.

| Câu | Nội dung soát / kết luận | Khóa expected = actual trên fixture nhỏ | Ca bổ sung đã đạt |
|---|---|---|---|
| QRA01 | Đường nối Q_d → hộ → địa chỉ → tổ đầy đủ; chiếu theo mã người tránh gộp trùng tên | 1, 7, 9, 10 | Bắt đầu đúng d/kết thúc đúng d được lấy; kết thúc d−1 và bắt đầu d+1 bị loại; hai loại cùng tổ không nhân dòng |
| QRA02 | Theta join và lọc TAM_TRU đúng; Q là bí danh Q_d trong quy ước đầu vào | 2 | Người vừa thường trú Tổ 01 vừa tạm trú Tổ 02 vẫn được lấy ở Tổ 02; người thường trú Tổ 02 bị loại |
| QRA03 | So ngày sinh <=20/11/1966 kết hợp hiệu lực/Tổ 01 đúng | 1 | Sinh đúng ngày cắt được lấy; sinh 21/11/1966 bị loại; đủ tuổi tổ khác/đợt hết hạn bị loại |
| QRA04 | Đổi tên mã hộ A/B, tự nối cùng mã cư dân và so hai hộ khác nhau đúng | 4, 9 | Hai đợt cùng hộ của người 7 không đủ điều kiện; hai hộ của người 15/17 được lấy |
| QRA05 | Hiệu hai quan hệ cùng thuộc tính ma_dia_chi, rồi nối lại lấy địa chỉ chuẩn đúng | Địa chỉ 5 | Phân biệt địa chỉ không hộ với hộ không người; hộ 5 rỗng không làm địa chỉ 1 lọt kết quả |
| QRA06 | Hiệu mã cư dân trừ mã người trong mọi đợt đúng | 6 | Người chỉ có đợt tương lai không được coi là chưa từng có bản ghi đợt |
| QRA07 | Giao hai tập ma_cu_dan theo từng loại đúng; không lọc hai loại trên cùng một dòng | 4 | Hai loại khác thời kỳ của người 17 vẫn được lấy; người chỉ một loại bị loại |
| QRA08 | Hợp hai tập khóa cùng miền; Q_d đã lọc thời gian đúng | 1, 2, 3, 7, 9, 10 | Người 15 thuộc cả hai tổ chỉ xuất hiện một lần trong hợp |
| QRA09 | Tập đã bắt đầu <=d trừ tập đang ở, phân biệt rõ với QRA06 | 5 | Người 13/17 đã hết mọi đợt được lấy; người 6 chưa có đợt và người 8/14 chỉ có tương lai bị loại |
| QRA10 | Đổi tên hai vai trò đợt cũ/mới; natural join còn buộc cùng mã cư dân; lọc khác tổ đúng | 4 | Người 9 chuyển cùng tổ bị loại; sự kiện cố tình ghép hai người khác nhau cũng bị loại |

**RV08: đạt sau sửa.** Q_d được chuẩn bị ngoài đại số cổ điển bằng SQL B05 và bỏ `ngay_ket_thuc`. Các phép tập hợp dùng tập khóa tương thích; không tiếp tục khẳng định phép hiệu tự xử lý NULL. Đây là quy ước chuẩn bị dữ liệu công bố rõ, không phải thêm bảng vào schema lõi.

**Natural join:** các phép chiếu trung gian loại các cột mô tả trùng tên như `ghi_chu`; QRA10 giữ `ma_cu_dan` ở hai bản đổi tên để nối cùng người. SQL kiểm chứng trong tài liệu và bản chép ở fixture đều khớp đáp án cho cả 10 câu.

**Q_d:** so đầy đủ 7 bộ, mã đợt 1, 2, 3, 5, 8, 11, 12. **VIEW:** fixture nhỏ cho Tổ 01=4, Tổ 02=2, Tổ 03=1; bộ bổ sung cho 7, 3, 1, 0. Người 12 có hai loại cùng tổ vẫn đếm một; người 15 ở hai tổ được đếm ở mỗi tổ theo B17.

## 4. Review bảo mật B1/B2

Nguồn: [06b](https://github.com/Linhlss/CSDL-Nh-m-38/blob/7abe4d54f7e7cc96ac086b7e1127073493152e24/docs/06b_bao_mat.md), [script bảo mật](https://github.com/Linhlss/CSDL-Nh-m-38/blob/7abe4d54f7e7cc96ac086b7e1127073493152e24/sql/05_security.sql).

| Kiểm tra | SET ROLE | Đăng nhập trực tiếp |
|---|---|---|
| Reader SELECT cư dân | Đạt, đầy đủ dòng expected | Đạt |
| Reader UPDATE/INSERT/DELETE | Đều bị chặn, SQLSTATE 42501 | Đều bị chặn, SQLSTATE 42501 |
| Reader đọc tai_khoan | Bị chặn 42501 | Bị chặn 42501 |
| Report đọc VIEW | Đúng đầy đủ kết quả | Đúng đầy đủ kết quả, cả tổ 0 người |
| Report đọc cu_dan/qua_trinh_cu_tru | Cả hai bị chặn 42501 | Cả hai bị chặn 42501 |

- Kiểm tra danh tính: SET ROLE có `current_user=csdl17_reader`, `session_user=postgres`; phiên đăng nhập trực tiếp có cả hai là reader. Các lệnh bị từ chối cũng in đúng role trước khi thực hiện.
- Đăng nhập trực tiếp dùng `psql -h 127.0.0.1 -U <role>` **bên trong container** với trust auth. Đã kiểm chứng phân quyền của phiên riêng; chưa kiểm chứng mật khẩu, TLS hay cấu hình xác thực triển khai thật.
- Đối chiếu snapshot đầy đủ cả 7 bảng trước/sau các lệnh bị chặn: không đổi. Admin UPDATE được trong transaction và ROLLBACK khôi phục dữ liệu.
- Role mới không superuser/CREATEDB/CREATEROLE, không sở hữu bảng. Script chạy lại trên cùng cấu hình sạch vẫn cho đúng sáu lỗi quyền cố ý và không đổi dữ liệu.
- Mỗi lần chạy script kiểm tra đúng **6 lỗi 42501**, không coi exit code 0 là đủ. Không đưa các lỗi quyền cố ý vào danh sách lỗi cú pháp/thực thi bất ngờ.
- VIEW chỉ có mã tổ, tên tổ, số cư dân; xử lý ngày trong ON của LEFT JOIN và COUNT DISTINCT đúng yêu cầu.
- Hai tầng `tai_khoan.vai_tro` và PostgreSQL role được phân biệt rõ; bảng đối chiếu E2 hợp lý ở mức mô phỏng, không tuyên bố tự đồng bộ quyền.

## 5. Kiểm chứng E1/B09 và giới hạn phạm vi

| Kiểm tra | Expected | Actual |
|---|---|---|
| Dữ liệu sửa sạch, cả bộ nhỏ và bộ biên | 0 dòng ở mỗi V_E1_CU/V_E1_MOI/V_B09 | Đạt |
| Lặp FK cũ cùng vai trò | 1 nhóm, vai trò CU, số lần 2, có các mã sự kiện | Đạt; truy vấn FK mới không nhóm các NULL |
| Lặp FK mới cùng vai trò | 1 nhóm, vai trò MOI, số lần 2, có các mã sự kiện | Đạt; truy vấn FK cũ không nhóm các NULL |
| Một đợt là mới của chuyển đến rồi là cũ của chuyển đi | 0 cảnh báo E1/B09 | Đạt |
| Ngày kết thúc cũ lệch hoặc NULL; ngày bắt đầu mới lệch; hai nhánh nội bộ lệch | Mỗi ca phát hiện đúng 1 sự kiện | Đạt đủ 5 ca |
| Sau các test âm trong transaction | Không còn cảnh báo của dữ liệu cố tình sai | Đạt, đã ROLLBACK |
| Chạy nguyên fixture sửa trên DB rỗng | Chạy hết và cả 7 bảng vẫn rỗng sau ROLLBACK | Đạt |

Phần `02_constraints.sql` của TV1 và seed/10 QSQL của TV2 chưa hoàn thiện. Kiểm tra E1/B09 không tuyên bố đã bật B06, B08, B10, B11, B14 hoặc đạt S01–S21 trên seed chính thức. SQL kiểm chứng RA của TV3 không thay thế 10 SQL nghiệp vụ của TV2. Chưa có ảnh bảo mật chính thức; danh sách 06b có 7 ảnh bắt buộc và 1 ảnh admin tùy chọn.

## 6. Phần việc tiếp nhận sau review ngày 12/11 (lịch sử)

| Người | Làm ngay | Khi có seed/Gate tiếp theo |
|---|---|---|
| TV1 | E1 đã trả lời; giữ validation và báo cáo độc lập trên main | Triển khai ràng buộc xuyên bảng/transaction tuần 2, kiểm tra seed và luận chứng chuẩn hóa |
| TV3 | Tiếp nhận fixture tại `355aa6e`; xử lý F03 về role có sẵn và F05 về mô tả PR; xác nhận tiếp nhận phản hồi E1 | Điền expected/actual chính thức cho 10 QRA, phối hợp TV2 đối soát, chụp ảnh B1/B2 và hoàn thiện Chương 4/6 |
| TV2 | Review schema, chuẩn bị dữ liệu phủ các ca biên được liệt kê | Chạy validation tới 0 cảnh báo, so VIEW với từng dòng QSQL03 cùng ngày, review bảo mật và lưu kết quả thật |

**Trạng thái chốt ngày 12/11:** đủ điều kiện tiếp tục triển khai; F01 đã sửa, E1 đã có quyết định và test; F03/F05 cùng việc tiếp nhận của TV3 còn mở. Gate 1 chung **CHỜ REVIEW**, không ký thay TV2/TV3. Khi đó PR #1 vẫn giữ để tác giả tiếp nhận, chưa merge vào main. Trạng thái mới xem mục 7.

## 7. Kiểm chứng bản sửa trước merge — 13/11/2026

- **F03 đã sửa:** preflight đọc toàn bộ role có sẵn trước thay đổi role/VIEW/ACL, từ chối các thuộc tính nguy hiểm hoặc NOLOGIN, quyền sở hữu trong database/public và mọi membership đi từ role demo sang role khác. Chiều cấp role demo cho người cài đặt vẫn được phép.
- Thiết lập nằm trong transaction, psql bật ON_ERROR_STOP. Lỗi guard hoặc lỗi SQL phía sau đều dừng và rollback; chỉ các lệnh thử quyền cố ý được phép tiếp tục qua lỗi. Hướng dẫn GUI chỉ chạy khối BEGIN..COMMIT đầy đủ trước khi chạy demo, không gửi lệnh psql tới SQL editor.
- Lần chạy **13/11/2026 05:13:44 +07:00**, PostgreSQL 17.11 trên cùng digest image đã nêu, Python 3.13.5. [Bằng chứng mới: expected/actual, hash đầu vào và thống kê](../tests/tv3_review_results.json).
- **146/146 đạt = 144 kiểm tra chức năng + 2 phép tái hiện** (B09 của fixture cũ và việc fixture đứng riêng chưa tự ASSERT). Bộ chạy bổ sung so sánh đầy đủ kết quả nên không dùng exit code của fixture làm tiêu chí duy nhất.
- Đầu vào chạy là worktree nền `7463104` cộng bản sửa code, được lưu ở [commit 52f5c6e](https://github.com/Linhlss/CSDL-Nh-m-38/commit/52f5c6e2514cee19c966ed4451a549fae2c7ceb4). Hash script bảo mật và bộ kiểm chứng trong JSON khớp chính xác nội dung code commit này. Các commit bằng chứng/tài liệu sau đó không đổi code đã chạy.

| Nhóm test mới | Kết quả |
|---|---|
| SUPERUSER, CREATEDB, CREATEROLE, REPLICATION, BYPASSRLS, NOLOGIN trên từng role admin/reader/report | Đủ 18 ca, mỗi ca dừng đúng 42501/CSDL17_PREFLIGHT và trạng thái không đổi |
| Owner database, public schema, bảng, VIEW, sequence trong public | Cả 5 ca bị từ chối, trạng thái không đổi |
| Membership INHERIT TRUE/SET FALSE và INHERIT FALSE/SET TRUE | Cả hai bị từ chối; không dựa vào việc quyền có đang được kế thừa ngay hay không |
| Reader không phù hợp trong khi hai tên role còn lại chưa tồn tại | Dừng trước CREATE ROLE; không tạo thêm role |
| Người cài đặt nhận role reader (chiều ngược) | Thiết lập được; phiên đăng nhập riêng của người cài đặt SET ROLE reader được |
| Gây lỗi chia 0 ngay trước COMMIT sau thay đổi VIEW/ACL | Dừng 22012; rollback khôi phục chính xác trạng thái trước thiết lập |
| Role mới, role an toàn có sẵn, chạy lại và sau các test âm | Thiết lập/demo tiếp tục đúng sáu lỗi quyền cố ý |

So sánh trước/sau bằng SHA-256 của toàn bộ dữ liệu 7 bảng, thuộc tính role, membership, owner/ACL database/schema/quan hệ, định nghĩa VIEW và trạng thái sequence; hash expected/actual nằm trong log. Đây là kiểm soát phạm vi demo, không phải audit mọi đối tượng/quyền trên cluster bất kỳ. E1/schema không đổi; 10 RA, Q_d, VIEW, ca biên, B1/B2 với SET ROLE và đăng nhập trực tiếp đều được chạy lại đạt.

**Trạng thái trước merge:** bản sửa được chuẩn bị trên `codex/review-tv3` để fast-forward nhánh nguồn của PR #1, cập nhật mô tả cũ (F05) rồi merge commit theo HEAD đã kiểm chứng. Kết quả merge thực tế ở mục 8. Gate 1 chung vẫn chờ xác nhận thành viên; chưa nghiệm thu seed chính thức, ảnh và báo cáo cuối.

## 8. Xác nhận tích hợp — 13/11/2026

- GitHub xác nhận [PR #1](https://github.com/Linhlss/CSDL-Nh-m-38/pull/1) **merged/closed** lúc **13/11/2026 05:18:11 +07:00**, bằng merge commit [d84571e544b480c9c4ba4a421d5d5435b33faac8](https://github.com/Linhlss/CSDL-Nh-m-38/commit/d84571e544b480c9c4ba4a421d5d5435b33faac8).
- HEAD PR đã khóa khi merge: `3414131a66bff6f39d7094225bf5a858beb3421f`; nhánh nguồn và nhánh review được push fast-forward, giữ lịch sử tác giả TV3. Mô tả PR đã đổi sang 06a/06b và quy ước Q_d hiện hành: **F05 đã xử lý**. **F03 đã xử lý**, có test đầy đủ ở mục 7.
- Main local đã fast-forward tới merge commit; đối chiếu script bảo mật, fixture và bộ kiểm chứng với HEAD PR không có khác biệt. Kiểm tra tài liệu/sơ đồ/liên kết/manifest sau merge đạt **11/11**. Các cập nhật trạng thái bàn giao sau merge chỉ sửa tài liệu và log kiểm tra tệp, không đổi đầu vào kiểm chứng PostgreSQL.
- Còn lại theo phân công: TV2 xác nhận schema, cung cấp seed chính thức và review bảo mật; TV2/TV3 đối soát trên seed, hoàn thiện expected/actual, ảnh và báo cáo cuối. TV1 tiếp tục ràng buộc/transaction tuần 2. Gate 1 **CHỜ REVIEW** các xác nhận còn thiếu, không tự ký thay thành viên.
