# Kiến trúc (Architecture)

Sản phẩm Harness upstream được triển khai dưới dạng một Rust workspace với CLI và tầng bền vững SQLite (SQLite durable layer). Mã nguồn chính nằm tại `crates/harness-cli/`, được tổ chức thành các module domain, application, infrastructure và interface. Các migration schema nằm trong `scripts/schema/`, trong khi các trình cài đặt (installers) và script xác thực (validation scripts) tạo thành ranh giới phân phối (distribution boundary).

Template tái sử dụng không lựa chọn ngăn xếp ứng dụng (application stack) cho dự án consumer. Hướng dẫn khám phá bên dưới dành cho ứng dụng consumer đó sau khi đã có đặc tả do người dùng cung cấp và quyết định về stack công nghệ; nó không mô tả Harness CLI upstream là chưa được triển khai.

## Khám phá trước khi Định hình (Discovery Before Shape)

Trước khi đề xuất hình thái triển khai (implementation shape), hãy xác định:

- Các bề mặt sản phẩm (Product surfaces): trình duyệt (browser), ứng dụng di động (mobile), máy tính (desktop), CLI, API, worker hoặc dịch vụ (service).
- Ngăn xếp runtime (Runtime stack): ngôn ngữ, framework, cơ sở dữ liệu, hàng đợi (queues), nhà cung cấp (providers) và hosting.
- Các miền lõi (Core domains): các khái niệm sản phẩm xứng đáng có tên gọi và giao ước ổn định.
- Các đầu vào ranh giới (Boundary inputs): đầu vào của người dùng, các yêu cầu API (API requests), webhooks, tác vụ (jobs), file, thông tin xác thực (credentials), dữ liệu phản hồi từ nhà cung cấp (provider payloads) và cấu hình môi trường.
- Nấc thang xác thực (Validation ladder): các bước kiểm tra nhỏ nhất có thể chứng minh stack công nghệ được chọn hoạt động chính xác.

Ghi lại các lựa chọn stack công nghệ trong thư mục `harness-docs/decisions/` khi chúng giới hạn một cách có ý nghĩa các công việc trong tương lai.

## Phân lớp Mặc định (Default Layering)

```text
domain (miền lõi)
  <- application (ứng dụng)
      <- infrastructure (hạ tầng)
          <- interface (giao diện)
              <- app surfaces (bề mặt ứng dụng)
```

## Cấu trúc Ứng viên Consumer (Consumer Candidate Structure)

```text
app/
  domain/
    entities/
    value-objects/
    repositories/
    services/

  application/
    commands/
    queries/
    handlers/

  infrastructure/
    database/
    logging/
    notifications/

  interface/
    controllers/
    dto/
    presenters/
    routes/
    middlewares/

surfaces/
  browser/
  mobile/
  desktop/
  cli/
```

Đây là một khuôn mẫu tư duy (thinking template), không phải là cấu trúc thư mục được tạo sẵn. Chỉ tạo các thư mục thực tế khi một story bắt đầu triển khai và stack công nghệ được chọn yêu cầu chúng.

## Quy tắc Phụ thuộc (Dependency Rule)

Các lớp bên trong không được phụ thuộc vào các lớp bên ngoài.

| Phân lớp (Layer) | Có thể phụ thuộc vào | Không được phép phụ thuộc vào |
| --- | --- | --- |
| domain | không có gì ngoài các thư viện tiện ích thuần túy (pure utilities) siêu nhỏ | framework, cơ sở dữ liệu, UI, provider, tiến trình/biến môi trường |
| application | domain | framework, UI, provider, các client cơ sở dữ liệu cụ thể |
| infrastructure | domain, application | các controller của interface hoặc UI |
| interface | tất cả các lớp backend bên dưới | trạng thái UI hoặc các giả định về shell nền tảng |
| app surfaces | các contract API và client hướng ứng dụng | trực tiếp vào phần nội bộ của domain (domain internals) |

## Quy tắc Ranh giới Ưu tiên Phân tích (Parse-First Boundary Rule)

Dữ liệu chưa xác định phải được phân tích (parse) tại các ranh giới trước khi đi vào mã nguồn bên trong.

Các ranh giới bao gồm:

- Body, tham số (params) và query string của HTTP request.
- Dữ liệu session và các khai báo định danh (identity claims).
- Các biến môi trường.
- Các dòng cơ sở dữ liệu trả về từ các client bên ngoài.
- Dữ liệu từ shell nền tảng (platform shell).
- Các deep link, token và signed URL.
- Webhook, sự kiện (events) và dữ liệu bất đồng bộ từ nhà cung cấp (provider payloads).

Luồng xử lý mục tiêu:

```text
đầu vào chưa xác định (unknown input)
  -> bộ phân tích (parser)
  -> DTO đã định kiểu hoặc command (typed DTO/command)
  -> ca sử dụng ứng dụng (application use case)
  -> thực thể domain / value object (domain object/value object)
```

Các lớp bên trong nên làm việc với các kiểu dữ liệu sản phẩm có ý nghĩa như `UserId`, `AccountId`, `WorkspaceId`, `Role`, `DateRange` hoặc các ID đặc thù của domain, thay vì liên tục xác thực lại các chuỗi thô (raw strings).

## Ranh giới Lệnh/Truy vấn (Command/Query Boundary)

Nếu sản phẩm có cả thao tác đọc và ghi, hãy giữ sự tách biệt lệnh/truy vấn (command/query separation) rõ ràng ở cấp độ code ngay cả khi lớp lưu trữ rất đơn giản:

- Lệnh (Commands) thay đổi trạng thái và sở hữu các tác vụ ghi log kiểm toán (audit log).
- Truy vấn (Queries) đọc trạng thái và định dạng cho bên tiêu thụ.
- Các quy tắc domain dùng chung nằm ở lớp domain/application, không nằm ở các controller.

## Ràng buộc về Khả năng Quan sát (Observability Contract)

Máy chủ trong tương lai nên xuất ra một dòng log JSON chuẩn hóa cho mỗi request chứa:

- timestamp (nhãn thời gian)
- level (mức độ log)
- request_id (ID của request)
- user_id (ID người dùng khi đã xác định)
- action (hành động)
- duration_ms (thời gian xử lý tính bằng mili giây)
- status_code (mã trạng thái HTTP)
- message (thông điệp)

Log kiểm toán (audit log) là bản ghi của sản phẩm. Log ứng dụng (application log) là bản ghi vận hành. Không sử dụng loại log này để thay thế cho loại log kia.
