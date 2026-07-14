# Agent Instructions

Add project-specific agent instructions here.

<!-- HARNESS:BEGIN -->
## Harness

Chọn loại yêu cầu (request class) trước khi thực hiện bất kỳ thao tác Harness nào.

- Khi kết quả mong muốn chỉ là một câu trả lời, giải thích, đánh giá, chẩn đoán,
  kế hoạch hoặc báo cáo trạng thái: chỉ kiểm tra các tài liệu cần thiết để phản hồi.
  Giữ tác vụ ở chế độ chỉ đọc (read-only). Không bootstrap, khởi tạo hoặc migrate
  database, không ghi nhận intake, hoặc ghi nhận trace.
- Khi người dùng yêu cầu rõ ràng thay đổi, xây dựng, sửa lỗi hoặc viết các artifact
  trong repository: trước tiên chạy `scripts/bootstrap-harness.sh`
  trên macOS/Linux hoặc `.\scripts\bootstrap-harness.ps1` trên Windows. Sau đó sử dụng
  `harness-docs/FEATURE_INTAKE.md` để phân loại và ghi nhận yêu cầu, truy vấn
  `scripts/bin/harness-cli query matrix --active --summary` trên macOS/Linux hoặc
  `.\scripts\bin\harness-cli.exe query matrix --active --summary` trên Windows,
  và chỉ lấy ngữ cảnh theo lane và tác vụ cụ thể được mô tả trong
  `harness-docs/CONTEXT_RULES.md`.
<!-- HARNESS:END -->
