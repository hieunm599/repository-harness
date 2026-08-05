# Tiếp nhận Tính năng (Feature Intake)

> **Tài liệu tương thích (Compatibility reference) — không thuộc luồng công việc mặc định.** Công việc mới sử dụng `harness-docs/WORKFLOW.md`: các thay đổi nhỏ không cần bản ghi intake, trong khi công việc phức tạp sử dụng một kế hoạch thực thi dạng Git-native. Chỉ sử dụng tài liệu này cho trạng thái lịch sử, bảo trì CLI hoặc một runner điều phối bên ngoài yêu cầu rõ ràng các làn intake.

Cổng tiếp nhận (intake gate) này áp dụng cho các yêu cầu thay đổi (change), xây dựng (build) và sửa lỗi (fix) trước khi có bất kỳ thay đổi mã nguồn hoặc trạng thái bền vững (durable state) của Harness. Một đặc tả dự án mới (project spec) cũng đi qua cổng này trước khi trở thành tài liệu sản phẩm, các story hoặc công việc triển khai thực tế.

Các yêu cầu trả lời, giải thích, đánh giá, chẩn đoán, lập kế hoạch và báo cáo trạng thái được giữ ở chế độ chỉ đọc (read-only). Chúng không bootstrap hoặc khởi tạo Harness, không ghi nhận intake, không cập nhật story hoặc mục backlog, và không ghi trace. Nếu người dùng sau đó yêu cầu triển khai một thay đổi được đề xuất, yêu cầu thay đổi mới đó sẽ đi qua cổng này.

Con người không cần phải phân loại rủi ro. Hệ thống harness sẽ làm việc đó.

## Luồng Tiếp nhận (Intake Flow)

```text
Prompt của người dùng
    |
    v
Phân loại loại đầu vào (input type)
    |
    v
Phát biểu lại dưới dạng mục công việc (work item)
    |
    v
Tìm tài liệu sản phẩm và story bị ảnh hưởng
    |
    v
Chạy danh sách kiểm tra rủi ro (risk checklist)
    |
    v
Chọn làn rủi ro: nhỏ (tiny), bình thường (normal) hoặc rủi ro cao (high-risk)
```

## Các Loại Đầu vào (Input Types)

Sử dụng loại đầu vào để quyết định xem công việc nên được đặt ở đâu trước khi chọn làn rủi ro.

| Loại đầu vào | Sử dụng khi | Artifact điển hình |
| --- | --- | --- |
| Đặc tả mới (New spec) | Chuyển đổi spec dự án do người dùng cung cấp thành tài liệu sẵn sàng cho harness | Tài liệu sản phẩm, epic ứng viên, quyết định kỹ thuật |
| Lát cắt đặc tả (Spec slice) | Triển khai hành vi được chọn từ một đặc tả đã được chấp nhận | Gói story packet |
| Yêu cầu thay đổi (Change request) | Thay đổi, sửa lỗi hoặc tinh chỉnh hành vi đã được chấp nhận | Gói story packet hoặc bản vá trực tiếp |
| Sáng kiến mới (New initiative) | Thêm một vùng sản phẩm lớn hơn cần nhiều story | Ghi chú sáng kiến kèm theo các gói story packet |
| Yêu cầu bảo trì (Maintenance request) | Thay đổi hành vi kỹ thuật, vận hành hoặc phụ thuộc | Gói story packet, báo cáo xác thực hoặc quyết định kỹ thuật |
| Cải tiến Harness (Harness improvement) | Cải thiện cách con người và agent cộng tác | Cập nhật trực tiếp tài liệu hoặc lệnh `scripts/bin/harness-cli backlog add` |

Theo mặc định, không tạo hoặc mở rộng một tài liệu đặc tả nguyên khối (monolithic spec) sau khi tiếp nhận. Hãy sử dụng tài liệu sản phẩm, story, quyết định kỹ thuật và ghi chú sáng kiến làm bề mặt tài liệu sống (living surface).

## Các Làn Rủi ro (Lanes)

### Nhỏ (Tiny)

Sử dụng cho các chỉnh sửa tài liệu rủi ro thấp, chỉnh sửa văn bản, thay đổi tên gọi hoặc chỉnh sửa mã nguồn có phạm vi hẹp.

Cũng sử dụng cho thiết lập dự án ban đầu khi công việc chỉ giới hạn ở việc cài đặt các dependency được khai báo, kết nối điểm vào máy chủ (server entrypoint), thêm endpoint kiểm tra sức khỏe hệ thống (health/smoke endpoint) hoặc mở kết nối cơ sở dữ liệu phát triển cục bộ mà không tạo lược đồ miền (domain schema), hành vi CRUD, xác thực (auth), phân quyền (authorization), tích hợp nhà cung cấp hoặc di chuyển dữ liệu (data migration). Một endpoint kiểm tra sức khỏe trong một dự án benchmark mới hoặc dự án scaffold chỉ là bằng chứng smoke test, bản thân nó không làm leo thang contract công khai.

Yêu cầu:

- Ghi lại dòng tiếp nhận (intake row) trước khi triển khai; công việc nhỏ bỏ qua chi phí tạo gói story packet nhưng không bỏ qua việc phân loại tác vụ lâu dài.
- Áp dụng bản vá trực tiếp.
- Giữ cho tài liệu bị ảnh hưởng luôn được cập nhật.
- Chạy các kiểm tra nhanh có sẵn.
- Chỉ cập nhật harness nếu phát hiện thấy độ ma sát (friction).

### Bình thường (Normal)

Sử dụng cho hành vi có kích thước phù hợp với story với bán kính ảnh hưởng có giới hạn.

Yêu cầu:

- Tạo hoặc cập nhật một file story từ template `harness-docs/templates/story.md`.
- Liên kết với các tài liệu sản phẩm liên quan.
- Thêm hoặc cập nhật các kỳ vọng xác thực.
- Triển khai lát cắt dọc (vertical slice) nhỏ nhất khi quá trình triển khai tồn tại.
- Ghi lại hoặc cập nhật trạng thái bằng chứng xác thực bằng lệnh `scripts/bin/harness-cli story add` và `scripts/bin/harness-cli story update`.

### Rủi ro cao (High-Risk)

Sử dụng khi công việc có thể ảnh hưởng đến bảo mật, dữ liệu, phạm vi, các contract hoặc nhiều vai trò/nền tảng.

Yêu cầu:

- Tạo một thư mục story sử dụng cấu trúc `harness-docs/templates/high-risk-story/`.
- Điền đầy đủ thông tin vào các file `execplan.md`, `overview.md`, `design.md` và `validation.md`.
- Yêu cầu xác nhận từ con người trước khi triển khai nếu hướng đi mơ hồ.
- Ghi lại một quyết định kỹ thuật lâu dài khi hành vi, kiến trúc, phân quyền, quyền sở hữu dữ liệu, cấu trúc API hoặc các yêu cầu xác thực thay đổi một cách có ý nghĩa. Sử dụng một file dạng `harness-docs/decisions/NNNN-*.md` từ template `harness-docs/templates/decision.md`, sau đó thêm hoặc làm mới quyết định bằng lệnh `scripts/bin/harness-cli decision add`. Nội dung quyết định được viết trong trace không được coi là một bản ghi quyết định kỹ thuật lâu dài.

## Danh sách Kiểm tra Rủi ro (Risk Checklist)

Đánh dấu một cờ cho mỗi mục áp dụng:

| Cờ rủi ro | Áp dụng khi công việc chạm đến |
| --- | --- |
| Auth (Xác thực) | đăng nhập, đăng xuất, phiên làm việc (sessions), JWT, mật khẩu, refresh token |
| Authorization (Phân quyền) | vai trò (roles), quyền hạn (permissions), phạm vi tenant hoặc công ty |
| Data model (Mô hình dữ liệu) | lược đồ (schema), migration, tính duy nhất, xóa dữ liệu, giữ lại dữ liệu |
| Audit/security (Kiểm toán/bảo mật) | log kiểm toán, quyền riêng tư, dữ liệu nhạy cảm, log truy cập |
| External systems (Hệ thống bên ngoài) | email, thanh toán, dịch vụ đám mây, SDK nhà cung cấp, hàng đợi, webhook |
| Public contracts (Contract công khai) | cấu trúc API, response envelope, hành vi hiển thị phía client |
| Cross-platform (Đa nền tảng) | phân chia desktop/mobile/trình duyệt, hành vi native shell, deep link |
| Existing behavior (Hành vi hiện tại) | thay đổi hành vi đã được triển khai hoặc đã có kiểm thử bao phủ |
| Weak proof (Chứng thực yếu) | kiểm thử xung quanh khu vực bị ảnh hưởng chưa rõ ràng hoặc còn thiếu |
| Multi-domain (Đa miền) | thay đổi nhiều hơn một miền sản phẩm cùng một lúc |

## Phân loại (Classification)

```text
Có 0-1 cờ rủi ro:
  nhỏ hoặc bình thường, dựa trên tác động của code

Có 2-3 cờ rủi ro:
  bình thường với yêu cầu xác thực mạnh mẽ hơn

Có từ 4 cờ rủi ro trở lên:
  rủi ro cao

Bất kỳ chốt chặn cứng (hard gate) nào:
  rủi ro cao trừ khi con người thu hẹp phạm vi một cách rõ ràng
```

Các chốt chặn cứng (Hard gates):

- Xác thực (Auth).
- Phân quyền (Authorization).
- Mất mát hoặc di chuyển dữ liệu (Data loss/migration).
- Kiểm toán/bảo mật.
- Hành vi của nhà cung cấp bên ngoài (External provider).
- Loại bỏ hoặc giảm bớt các yêu cầu xác thực.

## Đầu ra (Output)

Tại thời điểm kết thúc quy trình tiếp nhận (intake), agent phải có khả năng mô tả như sau:

```text
Lane (Làn): bình thường
Reason (Lý do): chạm đến phân quyền, contract API và hành vi kiểm toán.
Docs (Tài liệu): permissions, account-settings, audit-log.
Story (Nhiệm vụ): harness-docs/stories/epics/E02-access-control/US-014-manager-updates-role.md.
Validation (Xác thực): unit, integration, E2E.
```
