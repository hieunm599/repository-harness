# Test Matrix

File này ánh xạ hành vi sản phẩm tới bằng chứng.

Chưa có hành vi sản phẩm nào được định nghĩa hoặc triển khai. Đừng đánh dấu một
row là implemented cho tới khi test hoặc bằng chứng xác thực tồn tại.

## Giá Trị Status

| Status | Meaning |
| --- | --- |
| planned | Được chấp nhận như hành vi dự định, chưa triển khai |
| in_progress | Đang được xây dựng |
| implemented | Đã triển khai và có bằng chứng |
| changed | Contract đã thay đổi sau implementation trước đó |
| retired | Không còn là một phần của hợp đồng sản phẩm |

## Matrix

| Story | Contract | Unit | Integration | E2E | Platform | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TBD | Thêm row khi story packet được tạo | no | no | no | no | planned | none |

## Quy Tắc Evidence

- Unit proof bao phủ quy tắc domain và application thuần.
- Integration proof bao phủ backend enforcement, data integrity, hành vi
  provider, job hoặc service contract.
- E2E proof bao phủ luồng browser nhìn thấy bởi người dùng.
- Platform proof chỉ bao phủ shell, deployment, mobile, desktop hoặc hành vi
  runtime không thể chứng minh ở layer thấp hơn.
- Một story có thể được implemented mà không có mọi cột proof nếu story packet
  giải thích lý do.
