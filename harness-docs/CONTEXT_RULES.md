# Các Quy tắc Truy xuất Ngữ cảnh (Context Retrieval Rules)

Các agent cần một bản đồ, không phải là một cuốn hướng dẫn nạp sẵn. Bắt đầu từ `AGENTS.md`, làm theo chỉ mục liên quan gần nhất và chỉ truy xuất vừa đủ sự thật về sản phẩm, thiết kế, kế hoạch, mã nguồn và xác thực để hành động an toàn.

Luồng công việc chuẩn mực là `harness-docs/WORKFLOW.md`.

## Thẩm quyền Trước khi Truy xuất (Authority Before Retrieval)

| Kết quả được yêu cầu | Thẩm quyền thay đổi | Ngữ cảnh bắt đầu |
| --- | --- | --- |
| Câu trả lời, giải thích, đánh giá, chẩn đoán, kế hoạch hoặc báo cáo trạng thái | Chỉ đọc (Read-only) | `AGENTS.md`, các tài liệu được chỉ định, sau đó là nguồn bằng chứng nhỏ nhất cần thiết để trả lời. |
| Thay đổi có giới hạn (Bounded change) | Thay đổi repository trong phạm vi yêu cầu | `AGENTS.md`, `harness-docs/WORKFLOW.md`, tài liệu sản phẩm/thiết kế bị ảnh hưởng, triển khai và bằng chứng hiện có. |
| Thay đổi lâu dài theo kế hoạch (Durable planned change) | Thay đổi repository trong phạm vi yêu cầu cộng với một kế hoạch đang hoạt động | Ngữ cảnh thay đổi có giới hạn cộng với kế hoạch đang hoạt động và các quyết định lâu dài liên quan. |

Khám phá không mở rộng thẩm quyền. Phát hiện lỗi trong đợt đánh giá không đồng nghĩa với việc tự ý sửa lỗi đó.

## Tiết lộ Tăng dần (Progressive Disclosure)

### Hiểu Kết quả (Understand The Outcome)

Đọc:

- yêu cầu của người dùng;
- đặc tả sản phẩm gần nhất hoặc mô tả hành vi hiện tại;
- mã nguồn hoặc bề mặt có thể quan sát bị ảnh hưởng; và
- các bài kiểm thử hoặc lệnh xác thực hiện có.

Dừng lại khi kết quả mong muốn, ranh giới bị ảnh hưởng và bằng chứng khả thi đã rõ ràng. Không đọc các story lịch sử không liên quan hoặc tài liệu phase cũ.

### Lập Kế hoạch Thay đổi (Plan The Change)

- Đối với các thay đổi nhỏ, ngắn hạn: theo dõi mục đích sản phẩm, mã nguồn bị ảnh hưởng và bài kiểm thử trong phiên hiện tại.
- Đối với công việc kéo dài qua nhiều phiên hoặc cần phối hợp: tạo một file dưới `harness-docs/plans/active/<slug>.md` trước khi tiến hành chỉnh sửa diện rộng.

### Xác thực và Báo cáo (Validate And Report)

- Chạy các bài kiểm thử bị ảnh hưởng.
- Tuyên bố hoàn thành bằng bằng chứng có thể quan sát hoặc thực thi được.
- Đóng kế hoạch ngắn hạn hoặc di chuyển kế hoạch lâu dài đã hoàn thành sang `harness-docs/plans/completed/`.
