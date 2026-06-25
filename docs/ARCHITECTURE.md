# Kiến Trúc

Chưa có application stack nào được chọn.

Chưa có mã ứng dụng nào tồn tại. Tài liệu này định nghĩa các câu hỏi kiến trúc
chung và quy tắc ranh giới mà triển khai tương lai nên điều chỉnh sau khi có
spec do người dùng cung cấp và quyết định stack.

## Khám Phá Trước Khi Định Hình

Trước khi đề xuất hình dạng triển khai, hãy xác định:

- Product surface: browser, mobile, desktop, CLI, API, worker hoặc service.
- Runtime stack: ngôn ngữ, framework, database, queue, provider và hosting.
- Core domain: các khái niệm sản phẩm xứng đáng có tên và contract ổn định.
- Boundary input: input người dùng, API request, webhook, job, file,
  credential, payload provider và cấu hình môi trường.
- Validation ladder: các kiểm tra nhỏ nhất có thể chứng minh stack đã chọn.

Ghi lựa chọn stack trong `docs/decisions/` khi chúng ràng buộc đáng kể công
việc tương lai.

## Layering Mặc Định

```text
domain
  <- application
      <- infrastructure
          <- interface
              <- app surfaces
```

## Cấu Trúc Ứng Viên

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

Đây là template để suy nghĩ, không phải scaffold. Chỉ tạo folder thật khi một
story đi vào triển khai và stack đã chọn cần chúng.

## Quy Tắc Dependency

Layer bên trong không được phụ thuộc vào layer bên ngoài.

| Layer | May depend on | Must not depend on |
| --- | --- | --- |
| domain | không có gì bên ngoài dự án ngoài tiện ích thuần nhỏ | framework, database, UI, provider, process/env |
| application | domain | framework, UI, provider, database concrete clients |
| infrastructure | domain, application | interface controllers hoặc UI |
| interface | mọi backend layer | UI state hoặc giả định platform shell |
| app surfaces | API contract và app-facing client | domain internals trực tiếp |

## Quy Tắc Ranh Giới Parse-First

Dữ liệu chưa biết phải được parse tại ranh giới trước khi đi vào mã bên trong.

Ranh giới bao gồm:

- HTTP request body, param và query string.
- Session payload và identity claim.
- Environment variable.
- Database row trả về từ external client.
- Platform shell payload.
- Deep link, token và signed URL.
- Provider webhook, event và async payload.

Luồng mục tiêu:

```text
unknown input
  -> parser
  -> typed DTO or command
  -> application use case
  -> domain object/value object
```

Layer bên trong nên làm việc với các kiểu sản phẩm có nghĩa như `UserId`,
`AccountId`, `WorkspaceId`, `Role`, `DateRange`, hoặc ID riêng của domain, thay
vì liên tục xác thực chuỗi thô.

## Ranh Giới Command/Query

Nếu sản phẩm có cả read và write, hãy giữ tách biệt command/query rõ ràng ở cấp
mã, kể cả khi storage layer đơn giản:

- Command mutate state và sở hữu audit side effect.
- Query đọc state và format cho consumer.
- Quy tắc domain dùng chung nằm trong domain/application, không nằm trong
  controller.

## Observability Contract

Server tương lai nên phát một dòng log JSON chuẩn cho mỗi request với:

- timestamp
- level
- request_id
- user_id khi biết được
- action
- duration_ms
- status_code
- message

Audit log là bản ghi sản phẩm. Application log là bản ghi vận hành. Đừng dùng
cái này thay cho cái kia.
