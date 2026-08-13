# Agent Instructions

Add project-specific agent instructions here.

<!-- HARNESS:BEGIN -->
## Harness

Bắt đầu với kết quả được yêu cầu, sau đó sử dụng repository làm hệ thống lưu trữ nguồn (system of record). Đọc `harness-docs/WORKFLOW.md` và chỉ các tài liệu sản phẩm, thiết kế, kế hoạch, mã nguồn và xác thực liên quan.

- Các câu trả lời, giải thích, đánh giá, chẩn đoán, kế hoạch và báo cáo trạng thái là chế độ chỉ đọc (read-only). Chỉ kiểm tra những gì cần thiết và không làm thay đổi trạng thái của repository hoặc Harness.
- Đối với thay đổi có phạm vi giới hạn, sử dụng kế hoạch ngắn hạn (ephemeral plan): kiểm tra hành vi và bằng chứng bị ảnh hưởng, triển khai và xác thực. Không yêu cầu thao tác control-plane.
- Tạo hoặc cập nhật một file trong `harness-docs/plans/active/` khi công việc trải dài qua nhiều phiên, cần sự phối hợp, có các phụ thuộc quan trọng hoặc yêu cầu các bước phục hồi. Chỉ di chuyển nó sang `harness-docs/plans/completed/` sau khi đã xác thực xong.
- Trước khi chỉnh sửa, hãy xác định quyền thẩm quyền (authority) của repository cho mỗi chính sách mới có thể quan sát từ bên ngoài. Nếu các lựa chọn khác nhau về cơ bản vẫn còn mở, hãy dừng lại trước khi chỉnh sửa; các tùy chọn mặc định có thể cấu hình không phải là quyền thẩm quyền.
- Báo cáo ma sát phát sinh từ agent có tính tái sử dụng. Chỉ thay đổi hướng dẫn, công cụ, runbook hoặc xác thực cho mục đích đó khi được yêu cầu rõ ràng bằng `$improve-harness`.
- Đồng thời tạm dừng khi mục đích sản phẩm vẫn mơ hồ, việc phục hồi khó khăn, xác thực bị suy yếu hoặc quyền thẩm quyền không đủ.
- Chỉ tuyên bố hoàn thành khi có bằng chứng thực thi hoặc quan sát được liên quan. Báo cáo kết quả, các thay đổi quan trọng, xác thực và các rủi ro chưa giải quyết.

Harness không có cơ sở dữ liệu nhiệm vụ hoặc vòng đời điều phối. Sử dụng các kế hoạch và bằng chứng ở cấp độ hành vi thuộc sở hữu của repository; không tạo trạng thái tầng điều khiển song song.
<!-- HARNESS:END -->
