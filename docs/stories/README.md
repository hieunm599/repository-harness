# Các Story (Câu chuyện Người dùng)

Các story là các gói công việc. Chúng chuyển đổi ý định sản phẩm thành công việc triển khai và xác thực có giới hạn rõ ràng.

Hiện tại chưa có gói story packet nào đang hoạt động.

## Story Bình thường (Normal Story)

Sử dụng mẫu `docs/templates/story.md` cho các công việc phát triển tính năng thông thường.

Đường dẫn gợi ý:

```text
docs/stories/epics/E01-domain-name/US-001-short-story-title.md
```

## Story Rủi ro cao (High-Risk Story)

Sử dụng thư mục template `docs/templates/high-risk-story/` khi việc tiếp nhận tính năng (feature intake) phân loại công việc thuộc làn rủi ro cao.

Đường dẫn gợi ý:

```text
docs/stories/epics/E02-risky-domain/US-012-risky-story-title/
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
