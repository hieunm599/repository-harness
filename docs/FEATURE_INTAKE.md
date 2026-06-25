# Feature Intake

Mọi prompt triển khai đi qua cổng intake trước khi thay đổi mã. Một spec dự án
mới cũng đi qua cổng này trước khi trở thành tài liệu sản phẩm, story hoặc công
việc triển khai.

Con người không cần tự phân loại rủi ro. Harness làm việc đó.

## Luồng Intake

```text
User prompt
    |
    v
Classify input type
    |
    v
Restate as work item
    |
    v
Find affected product docs and stories
    |
    v
Run risk checklist
    |
    v
Choose lane: tiny, normal, or high-risk
```

## Loại Input

Dùng loại input để quyết định công việc nên nằm ở đâu trước khi chọn risk lane.

| Type | Use when | Typical artifact |
| --- | --- | --- |
| New spec | Biến spec dự án do người dùng cung cấp thành tài liệu sẵn sàng cho harness | Tài liệu sản phẩm, epic ứng viên, quyết định |
| Spec slice | Triển khai hành vi đã chọn từ một spec được chấp nhận | Story packet |
| Change request | Thay đổi, sửa hoặc tinh chỉnh hành vi đã chấp nhận | Story packet hoặc bản vá trực tiếp |
| New initiative | Thêm một vùng sản phẩm lớn hơn cần nhiều story | Initiative note cộng với story packet |
| Maintenance request | Thay đổi hành vi kỹ thuật, vận hành hoặc dependency | Story packet, validation report hoặc quyết định |
| Harness improvement | Cải thiện cách con người và agent cộng tác | Cập nhật tài liệu trực tiếp hoặc `scripts/bin/harness-cli backlog add` |

Đừng mặc định tạo hoặc mở rộng một spec nguyên khối sau intake. Dùng tài liệu
sản phẩm, story, quyết định và initiative note làm bề mặt sống.

## Lane

### Tiny

Dùng cho tài liệu, copy, tên gọi hoặc chỉnh sửa hẹp có rủi ro thấp.

Cũng dùng cho thiết lập dự án ban đầu khi công việc chỉ giới hạn ở cài
dependency đã khai báo, nối entrypoint server, thêm health/smoke endpoint hoặc
mở kết nối database phát triển cục bộ mà không tạo schema domain, hành vi CRUD,
auth, authorization, tích hợp provider hoặc migration dữ liệu. Một health
endpoint trong benchmark mới hoặc dự án scaffold là bằng chứng smoke, không tự
nó nâng cấp thành public contract.

Yêu cầu:

- Ghi row intake trước khi triển khai; tiny work bỏ qua overhead story packet,
  không bỏ qua phân loại task bền vững.
- Vá trực tiếp.
- Giữ tài liệu bị ảnh hưởng cập nhật.
- Chạy các kiểm tra nhanh có sẵn.
- Chỉ cập nhật harness nếu phát hiện friction.

### Normal

Dùng cho hành vi cỡ story với blast radius có giới hạn.

Yêu cầu:

- Tạo hoặc cập nhật một story file từ `docs/templates/story.md`.
- Liên kết tài liệu sản phẩm liên quan.
- Thêm hoặc cập nhật kỳ vọng xác thực.
- Triển khai lát cắt dọc nhỏ nhất khi đã có implementation.
- Ghi hoặc cập nhật trạng thái bằng chứng bằng `scripts/bin/harness-cli story add`
  và `scripts/bin/harness-cli story update`.

### High-Risk

Dùng khi công việc có thể ảnh hưởng bảo mật, dữ liệu, phạm vi, contract hoặc
nhiều vai trò/nền tảng.

Yêu cầu:

- Tạo một story folder bằng `docs/templates/high-risk-story/`.
- Điền `execplan.md`, `overview.md`, `design.md`, và `validation.md`.
- Hỏi xác nhận từ con người trước khi triển khai nếu hướng đi còn mơ hồ.
- Ghi một durable decision khi hành vi, kiến trúc, authorization, quyền sở hữu
  dữ liệu, hình dạng API hoặc yêu cầu xác thực thay đổi đáng kể. Dùng file
  `docs/decisions/NNNN-*.md` từ `docs/templates/decision.md`, rồi thêm hoặc làm
  mới row bền vững bằng `scripts/bin/harness-cli decision add`. Nội dung quyết
  định trong trace không phải một durable decision record.

## Checklist Rủi Ro

Đánh dấu một flag cho từng mục áp dụng:

| Risk flag | Applies when the work touches |
| --- | --- |
| Auth | login, logout, sessions, JWT, password, refresh token |
| Authorization | roles, permissions, tenant or company scope |
| Data model | schema, migrations, uniqueness, deletion, retention |
| Audit/security | audit logs, privacy, sensitive data, access logs |
| External systems | email, payments, cloud services, provider SDKs, queues, webhooks |
| Public contracts | API shape, response envelope, client-visible behavior |
| Cross-platform | desktop/mobile/browser split, native shell behavior, deep links |
| Existing behavior | already implemented or test-covered behavior changes |
| Weak proof | unclear or missing tests around the affected area |
| Multi-domain | more than one product domain changes at once |

## Phân Loại

```text
0-1 flags:
  tiny or normal, based on code impact

2-3 flags:
  normal with stronger validation

4+ flags:
  high-risk

Any hard gate:
  high-risk unless the human explicitly narrows scope
```

Hard gate:

- Auth.
- Authorization.
- Data loss hoặc migration.
- Audit/security.
- Hành vi external provider.
- Loại bỏ hoặc làm yếu yêu cầu xác thực.

## Đầu Ra

Cuối intake, agent nên có thể nói:

```text
Lane: normal
Reason: touches authorization, API contract, and audit behavior.
Docs: permissions, account-settings, audit-log.
Story: docs/stories/epics/E02-access-control/US-014-manager-updates-role.md.
Validation: unit, integration, E2E.
```
