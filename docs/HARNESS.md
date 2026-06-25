# Harness

Mục tiêu của dự án là cung cấp một harness (khung vận hành) có thể tái sử dụng giúp con người và các agent chuyển đổi đặc tả sản phẩm (product spec) trong tương lai thành phần việc an toàn và đã được xác thực.

Ứng dụng (app) là thứ người dùng tương tác. Harness là thứ agent tương tác.

## Mô hình Tư duy (Mental Model)

```text
Ý định của con người (Human intent)
         |
         v
Tiếp nhận tính năng (Feature intake)
         |
         v
Gói câu chuyện (Story packet)
         |
         v
Vòng lặp công việc của agent (Agent work loop)
         |
         v
Thay đổi sản phẩm (Product delta)
         |
         v
Bằng chứng xác thực (Validation proof)
         |
         v
Thay đổi harness (Harness delta)
         |
         v
Ý định tiếp theo (Next intent)
```

Mỗi nhiệm vụ có hai đầu ra khả thi:

1. Thay đổi sản phẩm (Product delta): mã nguồn ứng dụng, kiểm thử, cấu trúc API, mô hình dữ liệu hoặc tài liệu sản phẩm.
2. Thay đổi harness (Harness delta): tài liệu, template, kỳ vọng xác thực, các mục backlog hoặc bản ghi quyết định kỹ thuật giúp cho nhiệm vụ tiếp theo dễ dàng hơn.

## Phạm vi Harness v0 (Harness v0 Scope)

Harness v0 bao gồm:

- Điểm vào của agent (Agent entrypoint).
- Cấu trúc tài liệu sản phẩm trống.
- Tiếp nhận tính năng và các làn rủi ro.
- Các story template.
- Template nhật ký quyết định kỹ thuật (decision log template).
- Template báo cáo xác thực (validation report template).
- Chỗ trống cho ma trận kiểm thử (test matrix placeholder).
- Backlog tăng trưởng của Harness (Harness growth backlog).
- Lớp lưu trữ bền vững (Durable layer): Cơ sở dữ liệu SQLite và CLI cho các bản ghi vận hành.

Harness v0 cố tình không bao gồm:

- Tài liệu đặc tả cụ thể của dự án `SPEC.md`.
- Các miền sản phẩm được cắt lát sẵn (pre-sliced product domains).
- Ngăn xếp ứng dụng bị khóa cứng.
- Cấu trúc thư mục nguồn ứng dụng mẫu (app source scaffolding).
- Các kịch bản package (package scripts).
- Cấu hình chạy kiểm thử (test runner config).
- Các workflow CI.

Những thành phần này chỉ nên xuất hiện khi có một story cụ thể yêu cầu chúng.

## Lớp Lưu trữ Bền vững (Durable Layer)

Các tài liệu chính sách mô tả cách làm việc. Lớp lưu trữ bền vững lưu trữ những gì đã xảy ra.

Dữ liệu vận hành — phân loại tiếp nhận, trạng thái story, kết quả quyết định kỹ thuật, các mục backlog và dấu vết thực thi (execution trace) — nằm trong cơ sở dữ liệu SQLite (`harness.db`) được quản lý bởi Rust Harness CLI tại `scripts/bin/harness-cli`. Các agent và con người nên sử dụng CLI này cho các công việc Harness. Cơ sở dữ liệu này là cục bộ cho mỗi phiên bản dự án và được đưa vào `.gitignore`. Lược đồ cơ sở dữ liệu (schema) được quản lý phiên bản dưới thư mục `scripts/schema/`.

Sự phân tách này giữ cho các tài liệu chính sách ổn định và dễ đọc đối với con người trong khi cung cấp cho các agent một bản ghi có cấu trúc và có thể truy vấn về trạng thái vận hành. Nó cũng chuẩn bị cho harness khả năng quan sát (observability) và tiến hóa tự động trong tương lai mà không cần thêm nhiều file markdown.

Khởi tạo cơ sở dữ liệu nếu nó chưa tồn tại:

```bash
scripts/bin/harness-cli init
```

Các lệnh phổ biến:

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

## Phân cấp Nguồn (Source Hierarchy)

```text
Đặc tả hoặc prompt do người dùng cung cấp
  tài liệu đầu vào cho đợt xây dựng đầu tiên hoặc các thay đổi trong tương lai

docs/product/*
  đặc tả sản phẩm (product contract) hiện tại được rút trích từ đầu vào đã chấp nhận

docs/stories/*
  các gói công việc story-sized (story-sized work packets) và bằng chứng lịch sử

scripts/bin/harness-cli query matrix
  bảng điều khiển mối liên hệ giữa hành vi và bằng chứng xác thực được hỗ trợ bởi lớp lưu trữ bền vững

docs/decisions/*
  lý do tại sao contract thay đổi
```

Trước khi triển khai, các tài liệu sản phẩm mô tả ý định (intent). Sau khi triển khai, tài liệu sản phẩm cùng với các bài kiểm thử có thể thực thi sẽ trở thành contract sống.

## Vòng đời Đặc tả (Spec Lifecycle)

Harness v0 bắt đầu mà không có tài liệu đặc tả dự án nào được theo dõi. Khi người dùng cung cấp một đặc tả, hãy coi nó như tài liệu đầu vào, không phải là một hướng dẫn vận hành vĩnh viễn. Sử dụng nó để điền vào tài liệu sản phẩm, các gói story packet, các quyết định kiến trúc và các kỳ vọng xác thực trong đợt xây dựng đầu tiên.

Sau khi đặc tả đã được phân rã, không tiếp tục mở rộng nó như là kế hoạch sản phẩm sống. Các công việc tiếp theo nên cập nhật các tài liệu sản phẩm nhỏ hơn, các story, các bản ghi chứng thực lâu dài và các bản ghi quyết định kỹ thuật.

Các công việc tiếp theo nên đi vào harness dưới một trong các loại đầu vào sau:

- Đặc tả mới (New spec): một đặc tả dự án cần được chuyển đổi thành tài liệu sản phẩm và các story ứng viên ban đầu.
- Lát cắt đặc tả (Spec slice): một hành vi được chọn từ đặc tả được cung cấp.
- Yêu cầu thay đổi (Change request): thay đổi hành vi có giới hạn, sửa lỗi hoặc tinh chỉnh sản phẩm.
- Sáng kiến mới (New initiative): một vùng sản phẩm lớn hơn cần nhiều story.
- Yêu cầu bảo trì (Maintenance request): công việc về dependency, kiến trúc, hiệu năng, bảo mật hoặc vận hành.
- Cải tiến Harness (Harness improvement): thay đổi về quy trình, template, bằng chứng hoặc hướng dẫn cho agent.

Vòng lặp từ đặc tả sang công việc thực tế là:

```text
ý định của con người hoặc đặc tả được cung cấp
  -> phân loại loại đầu vào
  -> cập nhật hoặc tạo đặc tả sản phẩm (product contract)
  -> tạo gói story packet hoặc ghi chú sáng kiến khi cần thiết
  -> định nghĩa bằng chứng xác thực (validation proof)
  -> triển khai thực tế hoặc tài liệu hóa điểm nghẽn (blocker)
  -> cập nhật tài liệu sản phẩm, các story, các bản ghi chứng thực lâu dài và quyết định kỹ thuật
  -> ghi nhận độ ma sát harness (harness friction)
```

Các vùng sản phẩm lớn nên sử dụng ghi chú sáng kiến (initiative notes) có phạm vi giới hạn thay vì một tài liệu đặc tả nguyên khối thứ hai. Một sáng kiến nên giải thích mục tiêu, tài liệu sản phẩm bị ảnh hưởng, các story ứng viên, dạng xác thực, các quyết định mở và tiêu chí kết thúc. Nếu công việc sáng kiến trở thành một mẫu lặp đi lặp lại, hãy thêm một template hoặc ghi lại đề xuất đó bằng lệnh `scripts/bin/harness-cli backlog add`.

## Quy tắc Tăng trưởng (Growth Rule)

Harness tăng trưởng từ độ ma sát (friction).

Khi một agent bối rối, phải lặp lại các suy luận thủ công, cần một lệnh xác thực mới, phát hiện một quy tắc còn thiếu hoặc nhìn thấy một mẫu lỗi lặp đi lặp lại, nó phải cải tiến trực tiếp harness hoặc ghi lại độ ma sát đó:

```bash
scripts/bin/harness-cli backlog add --title "<tên ngắn>" --pain "<điều gì đã gây khó khăn>"
```

Sử dụng vòng lặp kết quả backlog cho các cải tiến dự kiến sẽ thay đổi hành vi của agent hoặc kết quả xác thực:

1. Khi tạo mục backlog, điền vào tham số `--predicted` tác động có thể đo lường được kỳ vọng từ cải tiến này.
2. Khi đóng mục backlog, điền vào tham số `--outcome` kết quả thực tế đo được hoặc bằng chứng đánh giá.
3. Sử dụng lệnh `scripts/bin/harness-cli query backlog --open` để xem xét các mục được đề xuất và chấp nhận, và lệnh `scripts/bin/harness-cli query backlog --closed` để so sánh các dự đoán với kết quả thực tế sau khi triển khai.

Trường dữ liệu `harness_friction` trên các trace cũng ghi lại ma sát cho mỗi nhiệm vụ để có thể truy vấn các mẫu lỗi sau này:

```bash
scripts/bin/harness-cli query friction
```

Độ rủi ro của backlog sử dụng cùng từ vựng làn rủi ro như tiếp nhận và story: `tiny`, `normal` hoặc `high-risk`. Sử dụng `--risk tiny` cho các mục theo dõi có rủi ro thấp; `low` không phải là một làn rủi ro hợp lệ.

## Vòng lặp Nhiệm vụ (Task Loop)

Đối với mỗi nhiệm vụ:

1. Phân loại yêu cầu bằng file `docs/FEATURE_INTAKE.md`.
2. Ghi lại phân loại bằng lệnh `scripts/bin/harness-cli intake`.
3. Xác định tài liệu sản phẩm và các file story bị ảnh hưởng.
4. Kiểm tra trạng thái chứng thực bằng lệnh `scripts/bin/harness-cli query matrix`.
5. Chỉ làm việc trong làn rủi ro đã chọn: nhỏ (tiny), bình thường (normal) hoặc rủi ro cao (high-risk).
6. Trước khi hoàn thành, tự hỏi xem đặc tả sản phẩm, kỳ vọng xác thực, quy tắc kiến trúc, mẫu lỗi lặp lại hoặc hướng dẫn cho agent tiếp theo có thay đổi hay không.
7. Ghi lại một trace bằng lệnh `scripts/bin/harness-cli trace`, sử dụng file `docs/TRACE_SPEC.md` để biết cấp độ trace và độ sâu trường dữ liệu kỳ vọng.
8. Xem xét điểm trace (trace score) được in ra bởi lệnh `scripts/bin/harness-cli trace`; chỉ sử dụng lệnh `scripts/bin/harness-cli score-trace --id <id>` khi kiểm tra lại một trace cụ thể trong lịch sử.
9. Nếu phát hiện ma sát harness, hãy trực tiếp sửa đổi hoặc ghi lại nó bằng lệnh `scripts/bin/harness-cli backlog add`.

## Xác thực Story (Story Verification)

Các story có thể đi kèm một lệnh xác thực cơ học (mechanical proof command):

```bash
scripts/bin/harness-cli story add --id US-012 --title "Story verification" --lane normal --verify "cargo test --workspace"
scripts/bin/harness-cli story update --id US-012 --verify "cargo test --workspace"
scripts/bin/harness-cli story verify US-012
```

Lệnh `story verify` chạy lệnh xác thực từ thư mục gốc của kho lưu trữ, ghi nhận `last_verified_at` cùng với `last_verified_result`, và trả về mã thoát (exit code) 0 nếu thành công hoặc 1 nếu thất bại. Khi lệnh `trace --story <id>` liên kết đến một story có lệnh xác thực chưa từng thành công, trace vẫn được ghi lại nhưng sẽ in ra một cảnh báo khuyến nghị trước khi đóng phiên.

Sử dụng lệnh `story verify-all` trước khi merge, tuyên bố độ hoàn thiện và chạy benchmark. Lệnh này chạy mọi lệnh xác thực story đã cấu hình, in ra một kết quả cho mỗi story, bỏ qua các story không có `verify_command` và trả về mã thoát 1 nếu có bất kỳ story được cấu hình nào thất bại.

Lệnh `story verify` chỉ chấp nhận tham số story id. Cấu hình lệnh xác thực bằng `story add --verify` hoặc `story update --verify`. Ghi lại các giá trị boolean chứng thực bằng `story update` sử dụng giá trị số: `1` nghĩa là có (yes) và `0` nghĩa là không (no). Rust CLI từ chối các giá trị văn bản như `yes` và `no`.

Sử dụng lệnh `scripts/bin/harness-cli query matrix --numeric` khi sao chép các giá trị chứng thực quay lại lệnh `story update`. Đầu ra mặc định của ma trận là dạng dễ đọc cho con người `yes`/`no`; đầu ra dạng số sẽ phản chiếu trực tiếp đầu vào của CLI.

## Các Lệnh Tiến hóa Phase 5 (Phase 5 Evolution Commands)

Khám phá công cụ (Tool discovery):

```bash
scripts/bin/harness-cli query tools --summary
scripts/bin/harness-cli query tools --json
scripts/bin/harness-cli tool register --name <name> --command <cmd> --description <text> --responsibility Verification
```

Kiểm tra ngữ cảnh và sai lệch (Context/drift checks):

```bash
scripts/bin/harness-cli score-context <trace-id>
scripts/bin/harness-cli audit
```

Lệnh `score-context` mang tính khuyến nghị; nó báo cáo độ bao phủ quy tắc ngữ cảnh mà không thay đổi trace. Lệnh `audit` báo cáo các danh mục sai lệch (drift categories) và một điểm số entropy được tài liệu hóa trong `docs/HARNESS_AUDIT.md`.

Các intervention (sự can thiệp) độc lập với các trace:

```bash
scripts/bin/harness-cli intervention add --trace <id> --type correction --description <text> --source human
scripts/bin/harness-cli query interventions --story US-024
```

Ghi lại một intervention khi con người, người đánh giá, hệ thống CI hoặc một agent khác sửa đổi, ghi đè, báo cáo khẩn cấp hoặc phê duyệt công việc.

Các đề xuất cải tiến (Improvement proposals):

```bash
scripts/bin/harness-cli propose
scripts/bin/harness-cli propose --commit
```

Lệnh `propose` in ra các đề xuất mang tính xác định từ ma sát lặp đi lặp lại, các intervention và sai lệch kiểm toán. Cờ `--commit` chỉ tạo các mục backlog được đề xuất; nó không chỉnh sửa tài liệu chính sách hoặc phê duyệt đề xuất.

## Các Bản ghi Quyết định Kỹ thuật (Decision Records)

Công việc rủi ro cao cần các quyết định lâu dài khi nó thay đổi hành vi hoặc kiến trúc. Đối với các thay đổi về xác thực (auth), phân quyền (authorization), quyền sở hữu dữ liệu, cấu trúc API, kiểm toán/bảo mật hoặc thay đổi yêu cầu xác thực, hãy ghi lại quyết định ở cả hai nơi:

1. Thêm một file markdown dưới thư mục `docs/decisions/` dựa trên template `docs/templates/decision.md`.
2. Thêm hoặc làm mới bản ghi lâu dài:

```bash
scripts/bin/harness-cli decision add \
  --id 0008-auth-boundary \
  --title "Auth Boundary" \
  --doc docs/decisions/0008-auth-boundary.md \
  --notes "Accepted during T4 authentication work."
```

Trường dữ liệu `--decisions` trong trace là bằng chứng hữu ích, nhưng nó không phải là nhật ký quyết định kỹ thuật. Không coi nội dung quyết định trong trace là đáp ứng yêu cầu của bản ghi quyết định kỹ thuật lâu dài.

## Chính sách Thay đổi Harness (Harness Change Policy)

Các agent có thể cập nhật trực tiếp:

- Trạng thái và bằng chứng của story thông qua lệnh `scripts/bin/harness-cli story update`.
- Các dòng ma trận kiểm thử thông qua lệnh `scripts/bin/harness-cli story add` và `scripts/bin/harness-cli story update`.
- Các liên kết từ các gói story packet đến tài liệu sản phẩm.
- Các ghi chú và báo cáo xác thực.
- Các làm rõ nhỏ gắn liền với nhiệm vụ hiện tại.
- Các bản ghi tiếp nhận, trace và các mục backlog thông qua `scripts/bin/harness-cli`.

Các agent nên yêu cầu xác nhận từ con người trước khi:

- Thay đổi hướng đi của kiến trúc.
- Loại bỏ các yêu cầu xác thực.
- Thay đổi phân cấp nguồn sự thật (source-of-truth hierarchy).
- Thay đổi các quy tắc phân loại rủi ro.
- Thay thế luồng công việc tính năng.

## Định nghĩa về Sự hoàn thành (Done Definition)

Một nhiệm vụ chỉ được coi là hoàn thành khi:

- Thay đổi được yêu cầu đã hoàn thành hoặc điểm nghẽn đã được ghi nhận bằng tài liệu.
- Các tài liệu liên quan, các story và các mục ma trận kiểm thử được cập nhật.
- Các lệnh xác thực đã được chạy khi chúng tồn tại.
- Một trace đã được ghi lại bằng lệnh `scripts/bin/harness-cli trace`.
- Các capability harness còn thiếu đã được ghi nhận bằng lệnh `scripts/bin/harness-cli backlog add`.
- Phản hồi cuối cùng chỉ rõ những gì đã thay đổi và những gì chưa được thực hiện.

## Nấc thang Xác thực Tương lai (Future Validation Ladder)

Chưa có kịch bản xác thực nào tồn tại. Khi quá trình triển khai bắt đầu, nấc thang xác thực dự kiến là:

```text
validate:quick
  format, lint, typecheck, unit tests, kiểm tra kiến trúc (architecture check)

test:integration
  kiểm tra backend, database, nhà cung cấp hoặc các dịch vụ theo yêu cầu của stack công nghệ

test:e2e
  các luồng end-to-end hiển thị với người dùng

test:platform
  kiểm tra nhanh (smoke checks) shell, mobile, desktop hoặc triển khai theo yêu cầu của stack công nghệ

test:release
  toàn bộ suite kiểm thử, kiểm tra log và đo hiệu năng sơ bộ
```

Các agent không được tuyên bố các lệnh này vượt qua cho đến khi chúng thực sự tồn tại và được chạy.
