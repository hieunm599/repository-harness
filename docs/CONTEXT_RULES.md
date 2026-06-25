# Quy Tắc Context Engineering

Context rule giúp agent quyết định cần đọc gì, đọc khi nào, và khi nào nên
dừng đọc. Chúng bổ sung cho danh sách đọc ổn định trong `AGENTS.md`.

Mục tiêu không phải tối đa hóa context. Mục tiêu là đưa đúng thông tin vào model
cho phase và risk lane hiện tại của task.

## Context Phase

### Intake Phase

Đọc để phân loại yêu cầu, tìm surface bị ảnh hưởng và chọn lane.

| Document Or Source | Tiny | Normal | High-Risk |
| --- | --- | --- | --- |
| `AGENTS.md` | Must | Must | Must |
| `docs/FEATURE_INTAKE.md` | Must | Must | Must |
| `scripts/bin/harness-cli query matrix` | Must | Must | Must |
| `README.md` | Should | Must | Must |
| `docs/HARNESS.md` | Should | Must | Must |
| `docs/ARCHITECTURE.md` | Skip | Should | Must |
| Relevant `docs/product/*` | Skip if unrelated | Must if product behavior changes | Must |
| Relevant `docs/stories/*` | Skip if unrelated | Must if a story exists | Must |
| `docs/decisions/*` | Skip | Should if architecture or durable rules are touched | Must |
| `docs/HARNESS_COMPONENTS.md` | Skip | Should for Harness improvements | Must for observability or benchmark work |

### Planning Phase

Đọc để quyết định cách tiếp cận nhỏ nhất an toàn và bằng chứng được kỳ vọng.

| Document Or Source | Tiny | Normal | High-Risk |
| --- | --- | --- | --- |
| Current files to edit | Must | Must | Must |
| `docs/templates/story.md` | Skip | Must when creating/updating a story | Should |
| `docs/templates/high-risk-story/*` | Skip | Skip unless risk escalates | Must |
| `docs/ARCHITECTURE.md` | Skip | Should for code or boundary changes | Must |
| `docs/TEST_MATRIX.md` or `scripts/bin/harness-cli query matrix` | Should | Must | Must |
| Relevant decisions | Skip | Should | Must |
| `docs/HARNESS_MATURITY.md` | Skip | Should for Harness improvements | Must for maturity or process changes |
| `docs/HARNESS_BACKLOG.md` and `scripts/bin/harness-cli query backlog` | Skip | Should if friction repeats | Must if changing Harness behavior |

### Implementation Phase

Đọc trong khi thực hiện thay đổi. Giữ phase này giới hạn ở các file ảnh hưởng
trực tiếp tới story đã chọn.

| Document Or Source | Tiny | Normal | High-Risk |
| --- | --- | --- | --- |
| Files being changed | Must | Must | Must |
| Adjacent files with same pattern | Should | Must | Must |
| Relevant product docs | Skip if copy-only | Must if behavior changes | Must |
| Relevant story packet | Skip if no story needed | Must | Must |
| Relevant templates | Skip | Should when adding docs | Must |
| `docs/ARCHITECTURE.md` | Skip | Should for structural changes | Must |
| Provider/API/security docs | Skip | Should if touched | Must |
| Unrelated docs and historical traces | Skip | Skip | Should only if they affect decisions |

### Validation Phase

Đọc để chứng minh thay đổi và tránh tuyên bố hoàn thành khi chưa có hỗ trợ.

| Document Or Source | Tiny | Normal | High-Risk |
| --- | --- | --- | --- |
| Story acceptance criteria | Should | Must | Must |
| `docs/TEST_MATRIX.md` or `scripts/bin/harness-cli query matrix` | Should | Must | Must |
| Validation section of story packet | Skip if no story | Must | Must |
| `docs/templates/validation-report.md` | Skip | Should for notable proof | Must for high-risk proof |
| Relevant commands from README/package docs | Should | Must | Must |
| Benchmark protocol or external benchmark repo | Skip | Skip unless requested | Must if the story depends on benchmark proof |
| `docs/HARNESS_MATURITY.md` | Skip | Should for Harness improvements | Must for maturity claims |

### Trace Phase

Đọc để để lại bằng chứng hữu ích cho agent tiếp theo và cho benchmark scoring.

| Document Or Source | Tiny | Normal | High-Risk |
| --- | --- | --- | --- |
| `docs/TRACE_SPEC.md` | Should | Must | Must |
| `scripts/bin/harness-cli query matrix` | Should | Must | Must |
| `scripts/bin/harness-cli query backlog` | Skip | Should if friction occurred | Must |
| Changed-file list from `git status --short` | Must | Must | Must |
| Validation command output | Should | Must | Must |
| Story packet or progress log | Skip if no story | Must | Must |
| `docs/HARNESS_COMPONENTS.md` | Skip | Should if attributing friction | Must if failure attribution is needed |

## Retrieval Trigger

| Trigger Condition | Action |
| --- | --- |
| Task touches database schema, durable records, or migrations | Read `docs/decisions/0004-sqlite-durable-layer.md`, `scripts/schema/`, and relevant CLI code before planning. |
| Task touches CLI command behavior or installer distribution | Read `docs/decisions/0005-prebuilt-rust-harness-cli.md`, `scripts/README.md`, relevant `crates/harness-cli/*` code, CLI help output, and installer docs. |
| Task touches auth, authorization, audit/security, data loss, or external providers | Treat as high-risk, read `docs/templates/high-risk-story/*`, and check prior decisions before implementation. |
| Task changes public API shape, product behavior, or user-visible workflow | Read relevant `docs/product/*`, story packets, and validation expectations before editing. |
| Task changes Harness policy, source hierarchy, risk classification, or validation requirements | Read `docs/HARNESS.md`, `docs/FEATURE_INTAKE.md`, `docs/ARCHITECTURE.md`, and `docs/decisions/*`; pause if direction is ambiguous. |
| Task discovers repeated confusion, stale docs, or missing proof | Read `docs/HARNESS_BACKLOG.md`, record `harness_friction`, and add a backlog item when the fix is out of scope. |
| Task makes a maturity, observability, trace quality, or benchmark claim | Read `docs/HARNESS_COMPONENTS.md`, `docs/HARNESS_MATURITY.md`, and `docs/TRACE_SPEC.md`. |
| Task is normal or high-risk and spans multiple iterations | Create or update a story/progress file under `docs/stories/` and keep it current. |
| Final response is being prepared | Re-read the validation evidence, `git status --short`, and `docs/TRACE_SPEC.md` before recording the final trace. |

## Hướng Dẫn Token Budget

| Lane | Target Context Budget | Read Shape | Reasoning |
| --- | --- | --- | --- |
| Tiny | Khoảng 2K token ngữ cảnh Harness | `AGENTS.md`, `docs/FEATURE_INTAKE.md`, matrix query và đúng file đang được thay đổi. | Tiny work không nên tiêu nhiều context cho policy hơn cho bản chỉnh sửa. |
| Normal | Khoảng 5K token ngữ cảnh Harness | Tài liệu intake, product/story docs liên quan, architecture khi có cấu trúc, kỳ vọng xác thực và trace spec ở cuối. | Normal work cần đủ context để giữ contract và ghi bằng chứng mà không đọc mọi file lịch sử. |
| High-risk | Khoảng 10K token ngữ cảnh Harness | Toàn bộ intake, architecture, decision liên quan, high-risk template, product docs, validation docs, trace spec và component/maturity docs khi thay đổi hành vi Harness. | High-risk work cần source hierarchy, quyết định trước đó và kỳ vọng bằng chứng trong context trước khi triển khai. |

Quy tắc budget:

- Ưu tiên tìm kiếm `rg` có mục tiêu thay vì đọc hàng loạt.
- Đọc phần nhỏ nhất trả lời câu hỏi của phase hiện tại.
- Tăng context khi một retrieval trigger kích hoạt.
- Đừng tiếp tục đọc lịch sử không liên quan sau khi lane, file bị ảnh hưởng và
  đường xác thực đã rõ.

## Hành Vi Bổ Sung

Các quy tắc này không thay thế `AGENTS.md`. Agent vẫn nên đọc các tài liệu
entrypoint ổn định được liệt kê ở đó trước khi làm việc. Tài liệu này giải thích
cần truy xuất gì sau ngữ cảnh ban đầu đó, dựa trên lane, phase và trigger.

## Checklist Review

Trước khi triển khai:

- Lane được chọn từ `docs/FEATURE_INTAKE.md`.
- Product docs hoặc story packet liên quan đã được xác định.
- Mọi high-risk trigger đã được xử lý.

Trước final response:

- Bằng chứng xác thực đã được đọc.
- `docs/TRACE_SPEC.md` đã được đọc cho task normal/high-risk.
- Trace cuối cùng bao gồm file đã đọc, file đã thay đổi, outcome và friction
  khi áp dụng.
