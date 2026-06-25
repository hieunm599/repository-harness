# Glossary

**Bản đồ thuật ngữ tiếng Việt**

| English term | Vietnamese term |
| --- | --- |
| Harness | Harness |
| agent | agent |
| feature intake | feature intake |
| story packet | story packet |
| product contract | hợp đồng sản phẩm |
| validation proof | bằng chứng xác thực |
| decision | quyết định |
| trace | trace |
| backlog | backlog |
| tool registry | tool registry |
| durable layer | durable layer |
| risk lane | risk lane |

Giữ nguyên các thuật ngữ tiếng Anh khi chúng là tên khái niệm vận hành của
Harness hoặc xuất hiện trong command, flag, schema, field, path, URL hay code
identifier. Dùng bản dịch tiếng Việt cho phần giải thích xung quanh để giữ tài
liệu dễ đọc mà không làm mờ các contract kỹ thuật.

## Agent

Một cộng tác viên coding AI vận hành bên trong repository.

## Harness

Hệ vận hành cấp repo cho con người và agent biết cách biến ý định thành thay
đổi sản phẩm an toàn.

## Product Contract

Hợp đồng sản phẩm: hành vi hiện được kỳ vọng của sản phẩm. Tài liệu sản phẩm
cộng với test có thể thực thi trở thành hợp đồng sống khi đã có implementation.

## Story Packet

Một file hoặc folder công việc cỡ story mô tả hợp đồng sản phẩm, tài liệu bị ảnh
hưởng, ghi chú thiết kế và kỳ vọng xác thực cho một feature.

## Feature Intake

Bước phân loại biến một prompt thành công việc tiny, normal hoặc high-risk
trước khi triển khai bắt đầu.

## Component Taxonomy

Bản đồ từ các file và capability của Harness tới trách nhiệm mà chúng phục vụ,
dùng để đánh giá coverage, quy kết lỗi và nhận diện capability harness còn
thiếu.

## Maturity Level

Một giai đoạn có thể xác minh trong capability của Harness, từ H0 bare
environment tới H5 self-improving harness. Mỗi level có file, tiêu chí và chỉ
báo benchmark bắt buộc.

## Trace Quality Tier

Độ sâu được kỳ vọng của một task trace: minimal cho tiny work, standard cho
normal work và detailed cho high-risk work.

## Verification Gate

Một kiểm tra Harness advisory chạy hoặc inspect bằng chứng cơ học trước khi một
task được đóng. Trong Phase 4, `story verify <id>` thực thi `verify_command` của
story, `story verify-all` chạy mọi lệnh proof story đã cấu hình, và
`trace --story <id>` cảnh báo khi xác thực của story đó chưa pass.

## Tool Registry

Manifest tool đã compile và đã đăng ký được expose bởi
`scripts/bin/harness-cli query tools`. Nó cho agent khám phá command, argument,
responsibility và custom project tool có sẵn.

## Intervention

Một bản ghi bền vững về phản hồi từ con người, reviewer, CI hoặc agent đã sửa,
override, escalate hoặc approve công việc. Intervention được lưu riêng với trace
và cấp dữ liệu cho improvement proposal.

## Context Score

Kết quả advisory từ `scripts/bin/harness-cli score-context <trace-id>`. Nó so
sánh `files_read` đã ghi trong trace với context rule đã compile và retrieval
trigger.

## Entropy Score

Điểm drift được in bởi `scripts/bin/harness-cli audit`. Càng thấp càng tốt. Nó
đếm durable record cũ hoặc chưa hoàn chỉnh như story mồ côi, proof command chưa
xác thực, backlog thiếu outcome và registered tool bị hỏng.

## Improvement Proposal

Một đề xuất có cấu trúc được tạo bởi `scripts/bin/harness-cli propose` từ
friction lặp lại, mẫu intervention và audit finding. Proposal chỉ mang tính
advisory trừ khi được commit vào backlog bằng `--commit`.

## Context Phase

Một phase của task agent làm thay đổi context cần đọc, như intake, planning,
implementation, validation hoặc trace recording.

## Retrieval Trigger

Một điều kiện yêu cầu agent lấy thêm context, chẳng hạn chạm vào database
schema, thay đổi public contract hoặc phát hiện thiếu validation.

## Harness Delta

Một cập nhật tài liệu, template, validation, backlog hoặc decision làm cho công
việc của agent tương lai an toàn hơn hoặc dễ hơn.

## Backlog Outcome Loop

Workflow phản hồi cho các cải thiện Harness: ghi tác động dự đoán khi tạo mục
backlog, rồi ghi outcome đo được thực tế khi đóng mục để agent tương lai có thể
so sánh kỳ vọng với kết quả.

## Durable Layer

Cơ sở dữ liệu SQLite và CLI (`scripts/bin/harness-cli`) lưu operational record
(intake, story, decision, backlog item, trace) dưới dạng dữ liệu có cấu trúc và
truy vấn được. Tài liệu policy mô tả cách làm việc; durable layer lưu những gì
đã xảy ra.

## Product Delta

Một thay đổi hướng sản phẩm như mã, test, hình dạng API, mô hình dữ liệu hoặc
tài liệu sản phẩm.

## Trace

Một bản ghi có cấu trúc về những gì agent đã làm trong task: hành động đã thực
hiện, file đã đọc, file đã thay đổi, quyết định đã đưa ra, lỗi gặp phải, outcome
và mọi harness friction được phát hiện.

## Tool Registry

Manifest tool đã compile và do người dùng đăng ký được expose bởi
`scripts/bin/harness-cli query tools` và được tài liệu hóa trong
`docs/TOOL_REGISTRY.md`.

## Intervention

Một bản ghi bền vững về correction, override, escalation hoặc approval từ con
người, reviewer, CI hoặc agent, tách riêng với task trace thông thường.

## Context Score

Kết quả advisory từ `scripts/bin/harness-cli score-context <trace-id>`, so sánh
các file đã đọc được ghi trong trace với context rule đã compile.

## Entropy Score

Điểm drift từ `scripts/bin/harness-cli audit`. Điểm thấp hơn nghĩa là ít record
mồ côi, stale, chưa xác thực, thiếu outcome hoặc broken-tool hơn.

## Improvement Proposal

Một proposal có cấu trúc được tạo bởi `scripts/bin/harness-cli propose` từ
friction lặp lại, intervention và audit drift. Proposal có thể được commit thành
backlog item bằng `--commit`.
