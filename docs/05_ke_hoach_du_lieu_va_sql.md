# DỮ LIỆU, SQL VÀ KIỂM THỬ — HỒ SƠ KỸ THUẬT

**Nhóm 38, lớp 174356, ThS. Nguyễn Thị Thanh Huyền.** TV1 Trần Bùi Tùng Linh — 20227057; TV2 Trần Tuấn Ngọc — 20227064; TV3 Dương Ngọc Ninh — 20237469.

Hoàn thiện kỹ thuật16/11/2026 bởi agent theo yêu cầu chủ repo, tiếp nối PR #3 tại63388b3. Review hỗ trợ không thay chữ ký, xác nhận máy cá nhân hay cuộc họp của thành viên.

## 1. Môi trường và quy ước

[Môi trường chung](../tests/week1_environment.md): PostgreSQL17.11/psql, Python3.13.5, container biệt lập; [expected/actual và hash](../tests/week1_execution_results.json). Chủ repo xác nhận TV2 dùng Windows ngày16/11; phiên bản PostgreSQL, công cụ quản trị và kết quả kết nối cá nhân chưa có, hoãn từ W1-T2-01 sang W2-T2-01 để bổ sung khi sử dụng.

Giữ7bảng/35cột của [DDL](../sql/01_schema.sql), không đổi khóa/quan hệ. d=`2026-11-20`; ngày cuối bao gồm. Đang ở khi bắt đầu<=d và (kết thúc NULL hoặc>=d); NULL không làm tương lai hiệu lực sớm. QSQL05/06 xét toàn bộ đợt đã ghi nhận; QSQL07 đòi đợt đã bắt đầu trước/đúngd rồi loại người còn đợt hiệu lực. Phân biệt chưa có đợt với chỉ có tương lai. DISTINCT theo mã, không theo họ tên; QSQL01 phân biệt cả loại, COUNT người dùng COUNT DISTINCT mã.

## 2. Ma trận 10 SQL

C=cư dân,Q=đợt,H=hộ,D=địa chỉ,T=tổ,B=biến động,A=tài khoản. JOIN theo FK, trừ chỗ ghi LEFT JOIN. [Mã và tên cột đầy đủ](../sql/04_queries.sql).

| Mã/câu hỏi | Bảng/JOIN | Lọc/nhóm/HAVING/EXISTS/LEFT JOIN | Đầu ra; ORDER BY | Ca/đối chứng |
|---|---|---|---|---|
| QSQL01 Ai đang ở Tổ01? | C–Q–H–D–T | Tên tổ, hai biên ngày, DISTINCT | mã,tên,loại; mã rồi loại | S01/S16; trùng tên và hai loại; loại hết hạn/tương lai |
| QSQL02 Hộ có>=4 người? | H–Q | ngày; GROUP hộ; HAVING COUNT DISTINCT>=4 | hộ,số; số giảm rồi mã | S14: H1=4; loạiH2=1/H3=0 |
| QSQL03 Mỗi tổ có bao nhiêu người? | T LEFT JOIN D–H–Q | ngày trong ON; GROUP mã/tên tổ | tổ,tên,số; mã tổ | tổ0 vẫn có; hai loại cùng tổ đếm1 |
| QSQL04 Địa chỉ chưa có hộ? | D,H | NOT EXISTS hộ | mã,địa chỉ; mã | S04; hộ rỗng không làm địa chỉ lọt |
| QSQL05 Ai từng ở>=2hộ? | C–Q | GROUP người; HAVING COUNT DISTINCT hộ>=2 | mã,tên,sốhộ; số giảm rồi mã | S06; hai đợt cùng hộ bị loại |
| QSQL06 Ai có cả hai loại? | C và hai EXISTS Q | EXISTS từng loại, toàn bộ đợt | mã,tên; mã | S07/S08; khác thời kỳ vẫn đạt |
| QSQL07 Ai từng ở nhưng nay hết hiệu lực? | C,Q | EXISTS đã bắt đầu; NOT EXISTS hiện lực | mã,tên; mã | S09; loại S10/chỉ tương lai; C1 không cần sự kiện |
| QSQL08 Bao nhiêu sự kiện mỗi tháng/loại? | B | GROUP tháng/loại, COUNT sự kiện | tháng,loại,số; tháng rồi loại | S11–13; chỉ nhóm phát sinh |
| QSQL09 Sự kiện nội bộ khác tổ? | B nối đôi Q–H–D cũ/mới | loại nội bộ,cùng người,khác tổ | sựkiện,người,tổcũ/mới,ngày; mã sựkiện | S13; loại cùng tổ/khác người |
| QSQL10 Mỗi tài khoản ghi bao nhiêu? | A LEFT JOIN B | GROUP mã/tên, COUNT mã sự kiện | mã,tênhiểnthị,số; mã | tài khoản0 vẫn có0 |

RA không đồng nhất theo số thứ tự SQL. QRA01 phải bỏ loại rồi DISTINCT; QRA04 bỏ so_ho của QSQL05; QRA10 cần chiếu người từ QSQL09 vì SQL trả sự kiện. QRA06 chưa từng có đợt khác QSQL07 từng ở nhưng không còn hiệu lực.

## 3. Sinh, nạp và tái lập

**636 dòng**=8tổ+50địa chỉ+60hộ+200cư dân+250đợt+63sự kiện+5tài khoản. ~643 chỉ là gợi ý, không tạo sự kiện vô nghĩa để đủ số. Seed `random.Random(20261110)`. Có tổ/hộ/tài khoản0, địa chỉ chưa hộ, trùng tên và ngày biên.

Sửa B15 bằng ngày lập hộ=min(ngày đã sinh, ngày bắt đầu sớm nhất của các đợt thuộc hộ), sau sinh đủ đợt và trước export. Giữ RNG,ID,ngày cư trú/sự kiện và đáp án truy vấn. Validator trước mọi ghi tệp kiểm PK/FK,miền,ngày,B06/B08/B09/E1/B15,chuỗi; sai gây ValueError, không phụ thuộc assert.

```sh
python3 scripts/generate_data.py
python3 scripts/generate_data.py --output-root /tmp/csdl17-generated
psql -U postgres -d csdl17_cu_tru_demo -v ON_ERROR_STOP=1 -f sql/01_schema.sql
psql -U postgres -d csdl17_cu_tru_demo -v ON_ERROR_STOP=1 -f sql/03_seed.sql
psql -U postgres -d csdl17_cu_tru_demo -v ON_ERROR_STOP=1 -f sql/06_validation.sql
psql -U postgres -d csdl17_cu_tru_demo -v ON_ERROR_STOP=1 -f sql/04_queries.sql
```

**Chỉ nạp INSERT seed**; CSV UTF-8/LF để đối chiếu, không nạp thêm CSV vào DB đã seed. Seed reset7bảng bằng TRUNCATE RESTART IDENTITY trong transaction, chỉ dùng DB mô phỏng riêng. Nạp tổ→địa chỉ→hộ; cư dân/tài khoản→đợt→sự kiện; đồng bộ7sequence. Log đã kiểm chạy lại/nextID.

## 4. Fixture và test

[Fixture29](../tests/week1_fixture.sql) có **29 dòng tổng trên7bảng**:3tổ+3địa chỉ+3hộ+7người+8đợt+2tài khoản+3sự kiện. Có DB rỗng/DDL trước, tệp chạy10SQL rồi ROLLBACK. [Expected đầy đủ tuple](../tests/week1_expected.json) tính tay độc lập DB.

C1/C2 trùng tên và sinh đúng/sau ngày cắt tuổi; H1 có C1–C4, C3 có2loại. C5 chuyển H1/T1→H2/T2 ngày15/11, C6 chưa đợt,C7 đi06/11. H3rỗng,địa chỉ3 không hộ,T3rỗng,TK2 không sự kiện. Q1=5tuple;Q2 H1=4;Q3 T1=4/T2=1/T3=0;Q4 địa chỉ3;Q5 C5/sốhộ2;Q6 C3,C5;Q7 C7;Q8 ba loại tháng11 mỗi loại1;Q9 sự kiện2/C5;Q10 TK1=3/TK2=0. Future-only/cùng tổ/hết hạn không sự kiện thử thêm trong transaction rollback, không tăng baseline29.

[Ma trận S01–S21](../tests/test_scenarios.md) ghi ID/expected/actual/đối chứng. TV1 chủ trì17–19; TV3 chủ trì20–21; TV2 hỗ trợ dữ liệu/log. Test cơ bản không chứng minh trigger/transaction nâng cao tuần 2 đã hoàn tất.

Review kỹ thuật hỗ trợ TV2: C→Q→H→D→T, hai nhánh cũ/mới, hộ rỗng và địa chỉ không hộ đều biểu diễn được; không thiếu cột cho10SQL. Giữ E1/schema, validation0 dòng; C1 dùng ngày kết thúc làm nguồn sự thật. Gate 1 và thiết kế v1 đã được cả nhóm đồng ý theo xác nhận chủ repo tiếp nhận16/11; nguồn ở [nhật ký](../meetings/decision_log.md#gate1), tách khỏi kết quả chạy của agent.

## 5. Tiến độ và bàn giao

Bảng đối chiếu 14 mã TV2 nằm trong [ledger chung tuần 1](../meetings/decision_log.md#week1-ledger); không duy trì một bản trạng thái thứ hai. [Checklist tuần 2](03_CHECKLIST_DU_AN.md#tuan-2-hien-hanh) ghi việc còn lại: kiểm thử cùng ràng buộc mới, Chương 3.5/5 và phiên bản dữ liệu/SQL cho Gate 2.
