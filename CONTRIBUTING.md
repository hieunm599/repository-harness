# Đóng góp (Contributing)

Những đóng góp tốt nhất giúp cho các kho lưu trữ trở nên dễ hiểu hơn đối với agent và con người mà không cần thêm một tầng điều khiển song song (parallel control plane).

## Đóng góp Hữu ích (Useful Contributions)

- Thất bại thực tế của agent do thiếu thẩm quyền kho lưu trữ (repository authority).
- Một quy tắc kho lưu trữ nhỏ gọn hoặc rõ ràng hơn giúp ngăn chặn lỗi đã được chứng minh.
- Củng cố tính an toàn cho installer, updater, merge, checksum, rollback hoặc recovery.
- Một ví dụ người dùng thực tế đo lường sự can thiệp thủ công không được ghi chép.
- Cải tiến tài liệu hoặc xác thực được hỗ trợ bởi một nhiệm vụ cụ thể.

## Trước khi Chỉnh sửa (Before Editing)

1. Đọc `AGENTS.md` và `harness-docs/WORKFLOW.md`.
2. Xác định thẩm quyền kho lưu trữ cho các hành vi có thể quan sát từ bên ngoài.
3. Chỉ sử dụng kế hoạch bền vững (durable plan) khi công việc kéo dài qua nhiều phiên, phối hợp nhiều người, có phụ thuộc quan trọng hoặc cần bộ nhớ phục hồi.
4. Giữ thay đổi ở phạm vi một chủ sở hữu sản phẩm (product owner).
5. Chọn bằng chứng quan sát được hành vi đã thay đổi.

## Pull Request

Mô tả:

```markdown
## Outcome

## Important changes

## Validation

## Compatibility, recovery, and remaining risks
```

Chạy:

```bash
scripts/validate-premerge.sh
```

## Ranh giới Sản phẩm (Product Boundary)

Kho lưu trữ này sở hữu:

- giao thức repository và hướng dẫn được cài đặt;
- trình cài đặt/cập nhật `harness` bằng Rust;
- bằng chứng cài đặt, cập nhật, xung đột, phục hồi và phát hành.

Repository của người dùng sở hữu hành vi sản phẩm, runtime ứng dụng, fixture, thông tin xác thực, khả năng quan sát (observability), tự động hóa giao diện và xác thực end-to-end của chính họ.

Không thêm cơ sở dữ liệu nhiệm vụ (task database), vòng đời story, điểm số trace, trình điều phối chung (generic orchestrator), stack ứng dụng hay chính sách sản phẩm cụ thể trừ khi có một quyết định sản phẩm mới được chấp thuận.

Giao thức v1 và `harness-cli` đã kết thúc hỗ trợ. Các bản sửa lỗi lịch sử thuộc về nhánh hoặc fork lịch sử được ghim, không thuộc về sản phẩm hiện tại.
