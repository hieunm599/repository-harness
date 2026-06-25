# Bản Đồ Tài Liệu

Thư mục này chứa harness dự án và mọi hợp đồng sản phẩm được dẫn xuất từ spec
do người dùng cung cấp trong tương lai.

## File Chính

- `HARNESS.md`: cách con người và agent cộng tác.
- `FEATURE_INTAKE.md`: cách prompt trở thành công việc tiny, normal hoặc
  high-risk.
- `ARCHITECTURE.md`: quy tắc khám phá kiến trúc và ranh giới.
- `TEST_MATRIX.md`: bản đồ bằng chứng cũ; trạng thái bằng chứng hiện tại được
  truy vấn bằng `scripts/bin/harness-cli query matrix`.
- `HARNESS_BACKLOG.md`: danh sách cải thiện cũ; bản ghi cải thiện hiện tại
  được lưu bằng `scripts/bin/harness-cli backlog`.
- `GLOSSARY.md`: thuật ngữ dùng chung.

## Thư Mục

- `product/`: sự thật sản phẩm hiện tại, trống cho tới khi một spec được dẫn
  xuất.
- `stories/`: feature packet và backlog.
- `decisions/`: quyết định và đánh đổi bền vững.
- `demo/`: walkthrough cụ thể cho thấy harness chuyển đổi input thành công
  việc sẵn sàng cho agent như thế nào.
- `templates/`: format tái sử dụng cho spec-intake, story, kế hoạch, quyết định
  và xác thực.

## Trạng Thái Hiện Tại

Harness v0 tồn tại trước khi triển khai. Các tài liệu này định nghĩa cách dự án
sẽ phát triển; chúng không hàm ý rằng mã ứng dụng, test, CI hoặc tự động hóa
deploy đã tồn tại.
