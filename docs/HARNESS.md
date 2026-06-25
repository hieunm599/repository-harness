# Harness

Mục tiêu của dự án là cung cấp một harness vận hành có thể tái sử dụng, giúp
con người và agent biến một spec sản phẩm tương lai thành công việc an toàn và
được xác thực.

Ứng dụng là thứ người dùng chạm vào. Harness là thứ agent chạm vào.

## Mô Hình Tư Duy

```text
------------------+
| Human intent    |
+------------------+
         |
         v
+------------------+
| Feature intake   |
+------------------+
         |
         v
+------------------+
| Story packet     |
+------------------+
         |
         v
+------------------+
| Agent work loop  |
+------------------+
         |
         v
+------------------+
| Product delta    |
+------------------+
         |
         v
+------------------+
| Validation proof |
+------------------+
         |
         v
+------------------+
| Harness delta    |
+------------------+
         |
         v
+------------------+
| Next intent      |
+------------------+
```

Mỗi task có hai đầu ra có thể có:

1. Product delta: mã ứng dụng, test, hình dạng API, mô hình dữ liệu hoặc tài
   liệu sản phẩm.
2. Harness delta: tài liệu, mẫu, kỳ vọng xác thực, mục backlog hoặc bản ghi
   quyết định giúp task tiếp theo dễ hơn.

## Phạm Vi Harness v0

Harness v0 bao gồm:

- Entrypoint cho agent.
- Cấu trúc tài liệu sản phẩm rỗng.
- Feature intake và risk lane.
- Mẫu story.
- Mẫu decision log.
- Mẫu validation report.
- Placeholder test matrix.
- Backlog phát triển Harness.
- Durable layer: cơ sở dữ liệu SQLite và CLI cho bản ghi vận hành.

Harness v0 cố ý không bao gồm:

- `SPEC.md` riêng cho dự án.
- Các product domain được cắt sẵn.
- Application stack bị khóa.
- Scaffold mã ứng dụng.
- Package script.
- Cấu hình test runner.
- CI workflow.

Những phần đó chỉ nên xuất hiện khi một story được chọn cần đến chúng.

## Durable Layer

Tài liệu policy mô tả cách làm việc. Durable layer lưu trữ những gì đã xảy ra.

Dữ liệu vận hành — phân loại intake, trạng thái story, kết quả quyết định, mục
backlog và execution trace — nằm trong cơ sở dữ liệu SQLite (`harness.db`) do
Rust Harness CLI tại `scripts/bin/harness-cli` quản lý. Agent và con người nên
dùng binary đó cho công việc Harness. Cơ sở dữ liệu là cục bộ cho từng instance
dự án và được `.gitignore`. Schema được version-control trong `scripts/schema/`.

Sự tách biệt này giữ cho tài liệu policy ổn định và dễ đọc với con người, đồng
thời cho agent một bản ghi vận hành có cấu trúc và truy vấn được. Nó cũng chuẩn
bị harness cho khả năng quan sát và tiến hóa tự động trong tương lai mà không
thêm nhiều file markdown hơn.

Khởi tạo cơ sở dữ liệu nếu chưa tồn tại:

```bash
scripts/bin/harness-cli init
```

Các lệnh thường dùng:

```bash
scripts/bin/harness-cli intake  --type <type> --summary <text> --lane <lane>
scripts/bin/harness-cli story   add --id <id> --title <text> --lane <lane>
scripts/bin/harness-cli story   update --id <id> --status <status>
scripts/bin/harness-cli story   update --id <id> --unit 1 --integration 1 --e2e 0 --platform 0
scripts/bin/harness-cli story   verify <id>
scripts/bin/harness-cli story   verify-all
scripts/bin/harness-cli decision add --id <id> --title <text> --doc docs/decisions/<file>.md
scripts/bin/harness-cli trace   --summary <text> --outcome <outcome>
scripts/bin/harness-cli score-trace
scripts/bin/harness-cli score-context <trace-id>
scripts/bin/harness-cli audit
scripts/bin/harness-cli propose
scripts/bin/harness-cli query   matrix
scripts/bin/harness-cli query   matrix --numeric
scripts/bin/harness-cli query   backlog
scripts/bin/harness-cli query   tools --summary
scripts/bin/harness-cli query   interventions
scripts/bin/harness-cli query   stats
scripts/bin/harness-cli --version
```

## Thứ Bậc Nguồn

```text
User-provided spec or prompt
  input material for first buildout or future changes

docs/product/*
  current product contract derived from accepted input

docs/stories/*
  story-sized work packets and historical evidence

scripts/bin/harness-cli query matrix
  behavior-to-proof control panel backed by the durable layer

docs/decisions/*
  why the contract changed
```

Trước khi triển khai, tài liệu sản phẩm mô tả ý định. Sau khi triển khai, tài
liệu sản phẩm cùng test có thể thực thi trở thành hợp đồng sống.

## Vòng Đời Spec

Harness v0 bắt đầu mà không theo dõi spec dự án. Khi con người cung cấp một đặc
tả, hãy xem nó là vật liệu đầu vào, không phải sổ tay vận hành vĩnh viễn. Dùng
nó để điền tài liệu sản phẩm, story packet, quyết định kiến trúc và kỳ vọng xác
thực trong lần buildout đầu tiên.

Sau khi đặc tả đã được phân rã, đừng tiếp tục mở rộng nó như kế hoạch sản phẩm
sống. Công việc tiếp diễn nên cập nhật các tài liệu sản phẩm nhỏ hơn, story, bản
ghi bằng chứng bền vững và bản ghi quyết định.

Công việc tiếp diễn nên đi vào harness dưới một trong các loại input sau:

- New spec: đặc tả dự án cần trở thành tài liệu sản phẩm và ứng viên story ban
  đầu.
- Spec slice: một hành vi đã chọn từ spec được chấp nhận.
- Change request: thay đổi hành vi có giới hạn, sửa lỗi hoặc tinh chỉnh sản
  phẩm.
- New initiative: vùng sản phẩm lớn hơn cần nhiều story.
- Maintenance request: công việc dependency, kiến trúc, hiệu năng, bảo mật hoặc
  vận hành.
- Harness improvement: thay đổi quy trình, mẫu, bằng chứng hoặc hướng dẫn agent.

Vòng lặp từ spec tới work là:

```text
human intent or supplied spec
  -> classify input type
  -> update or create product contract
  -> create story packet or initiative notes when needed
  -> define validation proof
  -> implement or document the blocker
  -> update product docs, stories, durable proof records, and decisions
  -> capture harness friction
```

Các vùng sản phẩm lớn nên dùng initiative note có phạm vi thay vì một đặc tả
nguyên khối thứ hai. Một initiative nên giải thích mục tiêu, tài liệu sản phẩm
bị ảnh hưởng, story ứng viên, hình dạng xác thực, quyết định còn mở và tiêu chí
thoát. Nếu công việc initiative trở thành mẫu lặp lại, hãy thêm template hoặc
ghi đề xuất bằng `scripts/bin/harness-cli backlog add`.

## Quy Tắc Phát Triển

Harness phát triển từ friction.

Khi agent bối rối, lặp lại suy luận thủ công, cần lệnh xác thực mới, phát hiện
quy tắc bị thiếu, hoặc thấy một mẫu lỗi lặp lại, nó phải cải thiện harness trực
tiếp hoặc ghi lại friction:

```bash
scripts/bin/harness-cli backlog add --title "<short name>" --pain "<what was hard>"
```

Dùng backlog outcome loop cho các cải thiện dự kiến thay đổi hành vi agent hoặc
kết quả xác thực:

1. Khi tạo mục backlog, điền `--predicted` bằng tác động đo được mà cải thiện
   được kỳ vọng tạo ra.
2. Khi đóng mục, điền `--outcome` bằng kết quả đo được thực tế hoặc bằng chứng
   review.
3. Dùng `scripts/bin/harness-cli query backlog --open` để xem các mục đã đề
   xuất và được chấp nhận, và `scripts/bin/harness-cli query backlog --closed`
   để so sánh dự đoán với kết quả sau triển khai.

Trường `harness_friction` trên trace cũng ghi friction theo từng task để các mẫu
có thể được truy vấn sau này:

```bash
scripts/bin/harness-cli query friction
```

Rủi ro backlog dùng cùng vocab lane như intake và story: `tiny`, `normal`, hoặc
`high-risk`. Dùng `--risk tiny` cho mục theo dõi rủi ro thấp; `low` không phải
lane hợp lệ.

## Vòng Lặp Task

Với mọi task:

1. Phân loại yêu cầu bằng `docs/FEATURE_INTAKE.md`.
2. Ghi phân loại bằng `scripts/bin/harness-cli intake`.
3. Tìm tài liệu sản phẩm và file story bị ảnh hưởng.
4. Kiểm tra trạng thái bằng chứng bằng `scripts/bin/harness-cli query matrix`.
5. Chỉ làm việc trong lane đã chọn: tiny, normal hoặc high-risk.
6. Trước khi kết thúc, hỏi liệu sự thật sản phẩm, kỳ vọng xác thực, quy tắc kiến
   trúc, mẫu lỗi lặp lại hoặc hướng dẫn cho agent tiếp theo có thay đổi không.
7. Ghi trace bằng `scripts/bin/harness-cli trace`, dùng `docs/TRACE_SPEC.md` cho
   trace tier và độ sâu field được kỳ vọng.
8. Xem trace score được in bởi `scripts/bin/harness-cli trace`; chỉ dùng
   `scripts/bin/harness-cli score-trace --id <id>` khi kiểm tra lại một trace
   lịch sử cụ thể.
9. Nếu phát hiện harness friction, sửa trực tiếp hoặc ghi lại bằng
   `scripts/bin/harness-cli backlog add`.

## Xác Thực Story

Story có thể mang một lệnh bằng chứng cơ học:

```bash
scripts/bin/harness-cli story add --id US-012 --title "Story verification" --lane normal --verify "cargo test --workspace"
scripts/bin/harness-cli story update --id US-012 --verify "cargo test --workspace"
scripts/bin/harness-cli story verify US-012
```

`story verify` chạy lệnh từ repository root, ghi `last_verified_at` và
`last_verified_result`, rồi exit 0 khi pass hoặc 1 khi fail. Khi
`trace --story <id>` liên kết tới một story mà lệnh xác thực chưa từng pass,
trace vẫn được ghi nhưng in cảnh báo advisory trước khi đóng.

Dùng `story verify-all` trước merge, maturity claim và benchmark run. Nó chạy
mọi lệnh xác thực story đã cấu hình, in một kết quả cho mỗi story, bỏ qua story
không có `verify_command`, và exit 1 nếu bất kỳ story đã cấu hình nào fail.

`story verify` chỉ nhận story id. Cấu hình command bằng `story add --verify`
hoặc `story update --verify`. Ghi proof boolean bằng `story update`, dùng giá
trị số: `1` nghĩa là yes và `0` nghĩa là no. Rust CLI từ chối giá trị text như
`yes` và `no`.

Dùng `scripts/bin/harness-cli query matrix --numeric` khi copy proof value trở
lại `story update`. Output matrix mặc định là `yes`/`no` dễ đọc với con người;
numeric output phản chiếu input CLI.

## Lệnh Tiến Hóa Phase 5

Tool discovery:

```bash
scripts/bin/harness-cli query tools --summary
scripts/bin/harness-cli query tools --json
scripts/bin/harness-cli tool register --name <name> --command <cmd> --description <text> --responsibility Verification
```

Context và drift check:

```bash
scripts/bin/harness-cli score-context <trace-id>
scripts/bin/harness-cli audit
```

`score-context` là advisory; nó báo cáo coverage context-rule mà không thay đổi
trace. `audit` báo cáo drift category và entropy score được tài liệu hóa trong
`docs/HARNESS_AUDIT.md`.

Intervention tách riêng với trace:

```bash
scripts/bin/harness-cli intervention add --trace <id> --type correction --description <text> --source human
scripts/bin/harness-cli query interventions --story US-024
```

Ghi một intervention khi con người, reviewer, hệ thống CI hoặc agent khác sửa,
override, escalate hoặc approve công việc.

Improvement proposal:

```bash
scripts/bin/harness-cli propose
scripts/bin/harness-cli propose --commit
```

`propose` in deterministic proposal từ friction lặp lại, intervention và audit
drift. `--commit` chỉ tạo các proposed backlog item; nó không sửa policy docs
hoặc approve proposal.

## Decision Record

High-risk work cần durable decision khi nó thay đổi hành vi hoặc kiến trúc. Với
auth, authorization, quyền sở hữu dữ liệu, hình dạng API, audit/security hoặc
thay đổi validation, hãy ghi decision ở cả hai nơi:

1. Thêm một markdown file trong `docs/decisions/` từ
   `docs/templates/decision.md`.
2. Thêm hoặc làm mới durable record:

```bash
scripts/bin/harness-cli decision add \
  --id 0008-auth-boundary \
  --title "Auth Boundary" \
  --doc docs/decisions/0008-auth-boundary.md \
  --notes "Accepted during T4 authentication work."
```

Field trace `--decisions` là bằng chứng hữu ích, nhưng không phải decision log.
Đừng xem decision text trong trace là đã đáp ứng yêu cầu durable decision
record.

## Policy Thay Đổi Harness

Agent có thể cập nhật trực tiếp:

- Story status và evidence qua `scripts/bin/harness-cli story update`.
- Test matrix row qua `scripts/bin/harness-cli story add` và
  `scripts/bin/harness-cli story update`.
- Link từ story packet tới product docs.
- Validation note và report.
- Làm rõ nhỏ gắn với task hiện tại.
- Intake record, trace và backlog item qua `scripts/bin/harness-cli`.

Agent nên hỏi xác nhận từ con người trước khi:

- Thay đổi hướng kiến trúc.
- Loại bỏ yêu cầu validation.
- Thay đổi thứ bậc source-of-truth.
- Thay đổi quy tắc risk classification.
- Thay thế feature workflow.

## Định Nghĩa Done

Một task chỉ done khi:

- Thay đổi được yêu cầu đã hoàn tất hoặc blocker đã được tài liệu hóa.
- Tài liệu, story và test matrix entry liên quan vẫn cập nhật.
- Validation command đã được chạy khi tồn tại.
- Trace đã được ghi bằng `scripts/bin/harness-cli trace`.
- Capability Harness còn thiếu đã được ghi bằng
  `scripts/bin/harness-cli backlog add`.
- Final response nói rõ đã thay đổi gì và không thử làm gì.

## Validation Ladder Tương Lai

Chưa có validation script nào tồn tại. Khi triển khai bắt đầu, ladder được kỳ
vọng là:

```text
validate:quick
  format, lint, typecheck, unit tests, architecture check

test:integration
  backend, database, provider, or service checks as the stack requires

test:e2e
  user-visible end-to-end flows

test:platform
  shell, mobile, desktop, or deployment smoke checks as the stack requires

test:release
  full suite, log checks, and performance smoke
```

Agent không được tuyên bố các command này pass cho tới khi chúng tồn tại và đã
được chạy.
