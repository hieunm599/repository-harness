# Kiến trúc (Architecture)

`repository-harness` chứa một file thực thi (binary) Rust duy nhất, `harness`, cùng các script khởi tạo mỏng bằng Bash và PowerShell.

## Ranh giới Sản phẩm (Product Boundary)

```text
nguồn sự thật của repository đích (consumer repository truth)
  <- giao thức repository đã cài đặt
  <- được bảo trì an toàn bởi harness
```

Harness cài đặt khả năng điều hướng, cấu trúc bộ nhớ làm việc và ranh giới quyết định. Harness không sở hữu sản phẩm, môi trường thực thi, luồng điều phối, chứng thư, log, fixture hoặc các lệnh xác thực của repository đích.

## Hướng Phụ thuộc trong Rust (Rust Dependency Direction)

```text
domain <- application <- infrastructure
                    <- interface

main.rs kết nối interface và infrastructure
```

- Các kiểu dữ liệu **Domain** đại diện cho đường dẫn, mã băm, nguồn gốc (provenance), kết quả hợp nhất và các báo cáo mà không phụ thuộc vào hệ thống file, tiến trình, tuần tự hóa hoặc CLI.
- Các trường hợp sử dụng **Application** phụ thuộc vào cổng (ports) và sở hữu chính sách cài đặt, cập nhật, trạng thái (status), chẩn đoán (doctor), tự cập nhật (self-update), phiên bản, xung đột và phục hồi.
- **Infrastructure** triển khai nội dung phát hành nhúng, tính toán mã băm, khóa tiến trình, giao dịch file system, hợp nhất 3 chiều với Git, tải file ứng viên, kiểm tra mã băm và thay thế file thực thi.
- **Interface** phân tích cú pháp các lệnh và hiển thị báo cáo.
- `main.rs` là gốc cấu hình và kết nối (composition root).

Các bài kiểm tra kiến trúc sẽ từ chối các phụ thuộc hướng ra ngoài từ các lớp bên trong.

## Trạng thái Cài đặt (Installation State)

```text
.harness-core/
  manifest.json
  baseline/
  update/          (chỉ xuất hiện khi có xung đột cập nhật đang chờ xử lý)
  update-candidate/(chỉ xuất hiện khi có bản cập nhật đang chờ xử lý)
```

- `manifest.json` ghi lại phiên bản core được cài đặt, phiên bản schema và các file được quản lý.
- `baseline/` lưu trữ bản sao của phiên bản core được cài đặt ban đầu để hỗ trợ hợp nhất 3 chiều với thay đổi của người dùng.
- `update/` lưu trữ thông tin phiên cập nhật đang chờ xử lý và các thay đổi đã được giải quyết khi xảy ra xung đột.
- `update-candidate/` tạm thời lưu trữ file thực thi ứng viên cho các quy trình cập nhật hai bước.

## Tự cập nhật File Thực thi (Executable Self-Update)

```text
harness update
  -> tải xuống bản phát hành mới nhất / ứng viên
  -> xác minh chữ ký mã băm
  -> chạy ứng viên với tham số --candidate
  -> hợp nhất 3 chiều các thay đổi
  -> thay thế file thực thi nếu cập nhật thành công
```

File thực thi mới nhất luôn tự cập nhật bản thân và các file core một cách an toàn mà không làm mất các tùy chỉnh dự án của người dùng.
