# Đóng góp cho repository-harness

Cảm ơn bạn đã giúp cải thiện harness.

Kho lưu trữ (repository) này đang ở giai đoạn đầu. Những đóng góp có giá trị nhất là các mẫu thiết kế (pattern) thực tế giúp các coding agent hoạt động an toàn hơn, rõ ràng hơn và dễ điều hướng hơn trong các dự án thực tế.

## Các hình thức đóng góp tốt (Good Contribution Types)

### 1. Các ví dụ sử dụng harness trong thực tế

Chỉ ra cách bạn đã cài đặt hoặc điều chỉnh harness trong một dự án thực tế:

- Dự án đó thuộc loại nào?
- Bạn đã sử dụng agent/công cụ nào? Claude Code, Codex, Cursor hay công cụ nào khác?
- Harness đã giúp ích gì cho bạn?
- Có điều gì còn thiếu hoặc gây khó hiểu không?

### 2. Các trường hợp lỗi của agent (Agent failure cases)

Chia sẻ các trường hợp mà một agent thực hiện thay đổi không tốt do kho lưu trữ thiếu ngữ cảnh (context):

- Bạn đã yêu cầu agent làm gì?
- Nó đã hiểu sai điều gì?
- Artifact nào của harness có thể ngăn chặn được vấn đề đó?
- Bài học rút ra có thể trở thành một template, rule hoặc kỳ vọng xác thực (validation expectation) hay không?

### 3. Cải tiến các template

Cải thiện các file trong thư mục `harness-docs/templates/` khi bạn tìm thấy một mẫu thiết kế có thể tái sử dụng cho:

- đặc tả sản phẩm (product specs)
- các story packet
- bản ghi quyết định kỹ thuật (decision records)
- kế hoạch xác thực (validation plans)
- quy tắc vận hành của agent (agent operating rules)
- đánh giá thay đổi rủi ro cao (high-risk change reviews)

### 4. Các mẫu xác thực (Validation patterns)

Thêm hoặc tinh chỉnh các kỳ vọng trong file `harness-docs/TEST_MATRIX.md` cho các stack công nghệ và loại công việc phổ biến. Mục tiêu không chỉ dừng lại ở việc "vượt qua các bài kiểm thử" (tests pass). Mục tiêu là bằng chứng rõ ràng chứng minh công việc phù hợp với đặc tả sản phẩm (product contract).

### 5. Sự rõ ràng của tài liệu

Nếu một khái niệm khó hiểu, hãy cải thiện phần giải thích đó. Những thay đổi nhỏ đối với tài liệu luôn được chào đón.

## Trước khi mở một Pull Request

1. Đọc kỹ file `AGENTS.md`.
2. Phân loại công việc bằng cách sử dụng file `harness-docs/FEATURE_INTAKE.md`.
3. Giữ cho các thay đổi tập trung và dễ đánh giá (reviewable).
4. Cập nhật các tài liệu liên quan nếu bạn thay đổi một quy tắc harness (harness rule) hoặc một template.
5. Giải thích bằng chứng nào chứng minh thay đổi này là hữu ích.

## Danh sách kiểm tra Pull Request (Pull Request Checklist)

Bao gồm nội dung này trong mô tả PR của bạn:

```markdown
## Summary
-

## Type of contribution
- [ ] Real-world harness example
- [ ] Agent failure case
- [ ] Template improvement
- [ ] Validation pattern
- [ ] Documentation clarity
- [ ] Other

## Proof / validation
-

## Follow-up questions
-
```

## Những thứ chưa nên thêm vào (What Not To Add Yet)

Tránh thêm các đặc tả sản phẩm (product specs) cụ thể của dự án vào harness này trừ khi chúng là một phần của bản demo hoặc ví dụ được đánh dấu rõ ràng. Repo này cần được giữ nguyên để có thể tái sử dụng trên nhiều dự án khác nhau.

Tránh thêm các quy tắc cụ thể cho một công cụ (tool-specific rules) chỉ hoạt động cho một coding agent duy nhất trừ khi sự đánh đổi được giải thích rõ ràng và hành vi harness tổng quát vẫn rõ ràng.
