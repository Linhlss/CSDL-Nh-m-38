# MÔI TRƯỜNG KIỂM CHỨNG CHUNG — TUẦN 1

Ngày bàn giao theo phiên người dùng: **16/11/2026**. Thực hiện bởi agent theo yêu cầu chủ repo, không phải xác nhận cài đặt trên máy cá nhân.

PostgreSQL17.11/psql, image `postgres:17.11`, Python3.13.5 trên macOS arm64. Container tạm nhãn `csdl17.review=tv3`, network none, không publish cổng, dữ liệu tmpfs; hai DB w1_tiny/w1_seed. SELECT version(), thời điểm thực tế, commit nền, hash/expected/actual nằm trong [log](week1_execution_results.json). Quyền trực tiếp thử bằng TCP loopback/trust auth trong container, không phải kiểm chứng mật khẩu/TLS.

```sh
docker run --detach --rm --name csdl17-week1-test --label csdl17.review=tv3 \
  --network none --tmpfs /var/lib/postgresql/data:rw \
  -e POSTGRES_HOST_AUTH_METHOD=trust postgres:17.11
docker exec csdl17-week1-test pg_isready -U postgres
# Chỉ tiếp tục khi pg_isready đã báo sẵn sàng:
python3 scripts/verify_week1_runtime.py --container csdl17-week1-test --client-date 2026-11-16
docker rm --force csdl17-week1-test
```

Chạy một lần trên mỗi container mới. Kết quả hiện tại **96/96 đạt**, gồm95kiểm tra chức năng và1tái hiện B15 bản cũ. Bộ chạy so generator2lần theo byte, tiny29/expectedtay, seed636/oraclePython độc lập, reload/sequence, RA/SQL, C1, quyền và FK/CHECK cơ bản. Chưa nghiệm thu nâng cao hay toàn đồ án. TV2 cần bổ sung OS/công cụ/SELECT version từ máy cá nhân nếu nhóm dùng làm tiêu chí xác nhận; không điền giả phần đó.
