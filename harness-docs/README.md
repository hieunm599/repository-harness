# Bản đồ Tài liệu (Documentation Map)

Thư mục này chứa harness của dự án và bất kỳ đặc tả sản phẩm (product contract) nào được rút trích từ tài liệu spec do người dùng cung cấp trong tương lai.

## Các File Chính

- `HARNESS.md`: mô hình cộng tác giữa con người và agent.
- `FEATURE_INTAKE.md`: cách phân loại các prompt thành công việc có mức độ rủi ro nhỏ (tiny), bình thường (normal) hoặc rủi ro cao (high-risk).
- `ARCHITECTURE.md`: khám phá kiến trúc và các quy tắc ranh giới (boundary rules).
- `TEST_MATRIX.md`: bản đồ chứng thực cũ (legacy proof map); trạng thái chứng thực hiện tại được truy vấn bằng lệnh `scripts/bin/harness-cli query matrix`.
- `HARNESS_BACKLOG.md`: danh sách cải tiến cũ (legacy improvement list); các bản ghi cải tiến hiện tại được lưu trữ bằng lệnh `scripts/bin/harness-cli backlog`.
- `GLOSSARY.md`: các thuật ngữ chung.

## Các Thư mục

- `product/`: nguồn sự thật hiện tại của sản phẩm (product truth), thư mục này trống cho đến khi tài liệu spec được rút trích.
- `stories/`: các gói tính năng (feature packet) và backlog.
- `decisions/`: các quyết định lâu dài (durable decisions) và sự đánh đổi (tradeoffs).
- `demo/`: các tài liệu hướng dẫn (walkthrough) thực tế chỉ ra cách harness chuyển đổi đầu vào thành công việc sẵn sàng cho agent (agent-ready work).
- `templates/`: các định dạng có thể tái sử dụng cho tiếp nhận đặc tả (spec-intake), story, kế hoạch (plan), quyết định kỹ thuật (decision) và xác thực (validation).

## Trạng thái Hiện tại (Current State)

Harness v0 hiện diện trước khi việc triển khai thực tế bắt đầu. Các tài liệu này định nghĩa cách dự án sẽ phát triển; chúng không ngụ ý rằng mã nguồn ứng dụng, kiểm thử, CI hoặc tự động hóa triển khai (deployment automation) đã tồn tại.
