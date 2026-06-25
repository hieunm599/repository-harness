# Giao thức Cải tiến (Improvement Protocol)

Phase 5 khởi động vòng lặp tự cải tiến (self-improvement loop):

```text
ma sát (friction) + sự can thiệp (interventions) + phát hiện kiểm toán (audit findings)
  -> harness-cli propose
  -> mục backlog đề xuất (proposed backlog item)
  -> đánh giá của con người (human review)
  -> triển khai kèm theo tác động dự kiến (predicted impact)
  -> đóng mục backlog kèm theo kết quả thực tế (actual outcome)
```

## Tạo Đề xuất (Generate Proposals)

```bash
scripts/bin/harness-cli propose
```

Lệnh này hoạt động dựa trên quy tắc. Nó tìm kiếm:

- ma sát trace lặp đi lặp lại,
- các mẫu can thiệp lặp đi lặp lại,
- các danh mục kiểm toán có điểm số khác không.

Mỗi đề xuất bao gồm tiêu đề (title), thành phần (component), bằng chứng (evidence), tác động dự kiến (predicted impact), mức độ rủi ro (risk), hành động gợi ý, kế hoạch xác thực và độ tin cậy (confidence).

## Ghi nhận Đề xuất (Commit Proposals)

```bash
scripts/bin/harness-cli propose --commit
```

Các đề xuất được ghi nhận sẽ trở thành các mục backlog ở trạng thái `proposed` (được đề xuất). Con người đánh giá chúng bằng lệnh:

```bash
scripts/bin/harness-cli query backlog --open
```

## Quy tắc Đánh giá (Review Rules)

- Các đề xuất nhỏ (tiny proposals) có thể được triển khai trực tiếp nếu chúng chỉ làm rõ tài liệu.
- Các đề xuất bình thường (normal proposals) cần một gói story packet hoặc sự chấp thuận backlog rõ ràng.
- Các đề xuất rủi ro cao (high-risk proposals) cần một bản ghi quyết định kỹ thuật lâu dài trước khi thay đổi phân cấp nguồn, hướng đi kiến trúc, yêu cầu xác thực hoặc chính sách rủi ro.
- Công việc đề xuất đã hoàn thành phải đóng mục backlog kèm theo bằng chứng kết quả thực tế.

## Xác thực (Validation)

Sau khi triển khai, hãy so sánh tác động dự kiến với:

- lệnh `scripts/bin/harness-cli audit`,
- lệnh `scripts/bin/harness-cli query friction`,
- lệnh `scripts/bin/harness-cli query interventions`,
- chất lượng trace benchmark và độ tuân thủ harness khi áp dụng các chứng thực benchmark.
