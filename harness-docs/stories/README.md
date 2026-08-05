# Các Story (Câu chuyện Người dùng)

> **Tài liệu tương thích và tham chiếu lịch sử (Compatibility and historical reference).** Công việc có giới hạn mới sử dụng kế hoạch ngắn hạn. Công việc phức tạp mới sử dụng một file dưới `harness-docs/plans/active/`. Gói story vẫn được giữ lại cho trạng thái CLI hiện tại, người dùng điều phối và lịch sử triển khai đã lưu giữ.

Các story là các gói công việc. Chúng chuyển đổi ý định sản phẩm thành công việc triển khai và xác thực có giới hạn rõ ràng.

Hiện tại chưa có gói story packet nào đang hoạt động.

## Story Bình thường (Normal Story)

Sử dụng mẫu `harness-docs/templates/story.md` cho các công việc phát triển tính năng thông thường.

Đường dẫn gợi ý:

```text
harness-docs/stories/epics/E01-domain-name/US-001-short-story-title.md
```

## Story Rủi ro cao (High-Risk Story)

Sử dụng thư mục template `harness-docs/templates/high-risk-story/` khi việc tiếp nhận tính năng (feature intake) phân loại công việc thuộc làn rủi ro cao.

Đường dẫn gợi ý:

```text
harness-docs/stories/epics/E02-risky-domain/US-012-risky-story-title/
  execplan.md
  overview.md
  design.md
  validation.md
```

## Luồng Trạng thái (Status Flow)

```text
planned (lên kế hoạch) -> in_progress (đang làm) -> implemented (đã triển khai)
                              |
                              v
                           changed (đã thay đổi)
                              |
                              v
                           retired (đã loại bỏ)
```
