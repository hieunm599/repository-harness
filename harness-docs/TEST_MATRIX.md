# Ma trận Kiểm thử (Test Matrix)

File này ánh xạ các hành vi của sản phẩm với bằng chứng xác thực (proof).

Chưa có hành vi sản phẩm nào được định nghĩa hoặc triển khai thực tế. Không được đánh dấu một dòng là `implemented` cho đến khi có các bài kiểm thử hoặc bằng chứng xác thực thực tế.

## Các Giá trị Trạng thái (Status Values)

| Trạng thái | Ý nghĩa |
| --- | --- |
| planned | Được chấp nhận như một hành vi dự kiến, chưa triển khai |
| in_progress | Đang được tích cực xây dựng |
| implemented | Đã triển khai và có bằng chứng xác thực |
| changed | Đặc tả sản phẩm (contract) đã thay đổi sau lần triển khai trước đó |
| retired | Không còn là một phần của đặc tả sản phẩm nữa |

## Ma trận (Matrix)

| Story | Đặc tả (Contract) | Unit | Integration | E2E | Platform | Trạng thái (Status) | Bằng chứng (Evidence) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TBD | Thêm các dòng khi các gói story packet được tạo | no | no | no | no | planned | none |

## Các Quy tắc về Bằng chứng (Evidence Rules)

- Bằng chứng kiểm thử đơn vị (Unit proof) bao gồm các quy tắc thuần túy của domain và lớp application.
- Bằng chứng tích hợp (Integration proof) bao gồm việc thực thi backend, tính toàn vẹn dữ liệu, hành vi của nhà cung cấp (provider), các tác vụ (jobs) hoặc các API/service contract.
- Bằng chứng E2E (E2E proof) bao gồm các luồng xử lý trên trình duyệt hiển thị với người dùng.
- Bằng chứng nền tảng (Platform proof) chỉ bao gồm hành vi shell, triển khai (deployment), ứng dụng di động, máy tính hoặc runtime không thể kiểm chứng ở các lớp thấp hơn.
- Một story có thể được triển khai mà không cần đầy đủ các cột bằng chứng nếu gói story packet giải thích rõ lý do.
