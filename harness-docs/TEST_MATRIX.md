# Ma trận Kiểm thử (Test Matrix)

File này bảo tồn từ vựng bằng chứng (proof vocabulary) và hình thức nhập dữ liệu brownfield được sử dụng bởi các consumer của Harness. Ma trận vận hành chính thức (authoritative operational matrix) được lưu trong SQLite và truy vấn bằng:

```bash
scripts/bin/harness-cli query matrix --active --summary
```

Repository Harness upstream có hành vi đã triển khai và bằng chứng thực thi được (executable proof). Một consumer được cài đặt bắt đầu mà không có các hàng sản phẩm consumer và chỉ thêm chúng khi công việc thực tế được chấp nhận. Không được đánh dấu một dòng là `implemented` cho đến khi có các bài kiểm thử hoặc bằng chứng xác thực khác.

## Các Giá trị Trạng thái (Status Values)

| Trạng thái | Ý nghĩa |
| --- | --- |
| planned | Được chấp nhận như một hành vi dự kiến, chưa triển khai |
| in_progress | Đang được tích cực xây dựng |
| implemented | Đã triển khai và có bằng chứng xác thực |
| changed | Đặc tả sản phẩm (contract) đã thay đổi sau lần triển khai trước đó |
| retired | Không còn là một phần của đặc tả sản phẩm nữa |

## Ma trận (Matrix)

Không có các hàng sản phẩm tĩnh nào được cung cấp trong chế độ xem di sản (legacy view) này. Sử dụng `story add` và `story update` cho các bản ghi vận hành (operational records). Các repository brownfield có thể thêm các hàng tại đây trước khi nhập trạng thái hiện có của chúng.

## Các Quy tắc về Bằng chứng (Evidence Rules)

- Bằng chứng kiểm thử đơn vị (Unit proof) bao gồm các quy tắc thuần túy của domain và lớp application.
- Bằng chứng tích hợp (Integration proof) bao gồm việc thực thi backend, tính toàn vẹn dữ liệu, hành vi của nhà cung cấp (provider), các tác vụ (jobs) hoặc các API/service contract.
- Bằng chứng E2E (E2E proof) bao gồm các luồng xử lý trên trình duyệt hiển thị với người dùng.
- Bằng chứng nền tảng (Platform proof) chỉ bao gồm hành vi shell, triển khai (deployment), ứng dụng di động, máy tính hoặc runtime không thể kiểm chứng ở các lớp thấp hơn.
- Một story có thể được triển khai mà không cần đầy đủ các cột bằng chứng nếu gói story packet giải thích rõ lý do.
