# Hệ thống Đăng ký Công cụ (Tool Registry)

> **Tài liệu tương thích (Compatibility reference) — không bắt buộc để sử dụng công cụ.** Các agent nên gọi trực tiếp script, skill, công cụ MCP và khả năng của ứng dụng trong repository. Trình đăng ký này vẫn khả dụng cho CLI tương thích và người dùng điều phối.

Hệ thống harness làm việc với hai loại "công cụ" riêng biệt. Hãy phân biệt rõ chúng:

| | Manifest khả năng (outbound - hướng ra) | Hệ thống đăng ký công cụ inbound (inbound - hướng vào) |
| --- | --- | --- |
| **Hướng** | harness cung cấp nó cho agent | một dự án trang bị nó để harness sử dụng |
| **Ví dụ** | các lệnh con của `harness-cli` bên dưới | gitnexus, c3, linter, deploy check |
| **Sự hiện diện** | luôn được biên dịch sẵn | tùy chọn; có thể vắng mặt trên một số máy |
| **Nếu thiếu** | n/a (chính là bản thân harness) | bỏ qua sạch sẽ; không bao giờ chặn tiến trình chính |

Tài liệu này mô tả cả hai loại. **Registry inbound** là cơ sở mở rộng: đó là nơi harness tìm hiểu xem khả năng (capability) bổ sung nào được trang bị, phục vụ mục đích gì và liệu nó có thực sự hiện diện ngay lúc này hay không, để một bước luồng công việc (workflow step) có thể điều chỉnh theo những gì được cài đặt mà không cần core phụ thuộc trực tiếp vào nó.

## Registry Inbound: Đăng ký một Công cụ (Register A Tool)

```bash
scripts/bin/harness-cli tool register \
  --name deploy-check \
  --kind cli \
  --capability deploy-verification \
  --command ./scripts/deploy-check.sh \
  --description "Verify deploy health before release" \
  --responsibility Verification \
  --args "env:enum:required:staging,production"
```

Các trường dữ liệu cụ thể cho các công cụ inbound:

- `--kind` — cách công cụ được truy cập và thăm dò. Nhận một trong các giá trị: `cli`, `binary`, `mcp`, `skill`, `http`. Mặc định là `cli`. Loại công cụ cho mỗi môi trường chạy của agent biết nó có thể điều phối những gì (một agent không phải Claude sẽ coi một `skill` mà nó không thể chạy là vắng mặt) và hướng dẫn lệnh `tool check` sử dụng đầu dò (probe) nào.
- `--capability` — mục đích luồng công việc mà một bước tìm kiếm công cụ thông qua đó. Là văn bản tự do nhưng được chuẩn hóa thành dạng kebab-case, vì vậy `Impact Analysis`, `impact_analysis` và `impact-analysis` đều đăng ký thành `impact-analysis`. Đây là kết nối duy nhất giữa một bước và một công cụ; các bước chỉ tham chiếu đến capability, không bao giờ tham chiếu đến tên công cụ cụ thể.
- `--scan` — đối với `mcp`/`skill`/`http`, đây là một đường dẫn khai báo hoặc URL mà lệnh `tool check` phân giải để quyết định sự hiện diện (ví dụ: `.c3`, `~/.claude/skills/c3`, `https://localhost:8080/health`). Các loại `cli`/`binary` được thăm dò thông qua chính lệnh của chúng.

Cờ `--force` chỉ cần thiết cho `cli`/`binary` có lệnh thực thi cố tình vắng mặt trên máy hiện tại. Các loại `mcp`/`skill`/`http` về bản chất không nằm trên `PATH`, vì vậy chúng đăng ký mà không cần cờ `--force`; sự hiện diện của chúng được phân giải sau đó bởi lệnh `tool check`.

Đăng ký một máy chủ MCP hoặc một kỹ năng Claude (ví dụ):

```bash
scripts/bin/harness-cli tool register --name gitnexus --kind mcp \
  --capability impact-analysis --scan ".gitnexus" --command "mcp:gitnexus" \
  --description "Code-graph blast radius" --responsibility Verification
scripts/bin/harness-cli tool register --name c3 --kind skill \
  --capability impact-analysis --scan ".c3" --command "skill:c3" \
  --description "Component model and drift audit (Claude skill)" \
  --responsibility Verification
```

Gỡ bỏ một công cụ bằng lệnh:

```bash
scripts/bin/harness-cli tool remove --name deploy-check
```

## Registry Inbound: Kiểm tra sự Hiện diện (Check Presence)

Việc đăng ký ghi nhận ý định. Lệnh `tool check` đối chiếu ý định đó với thực tế bằng cách quét từng công cụ đã đăng ký và lưu lại kết quả phán quyết (`status` và `checked_at`). Chạy lệnh này lúc bắt đầu quy trình tiếp nhận (intake) để trạng thái phản ánh đúng thực tế hiện tại.

```bash
scripts/bin/harness-cli tool check            # quét tất cả các công cụ đã đăng ký
scripts/bin/harness-cli tool check --name c3  # quét một công cụ cụ thể
scripts/bin/harness-cli tool check --json     # trả về dạng JSON để agent đọc
```

Đầu dò cho mỗi loại công cụ (Probe per kind):

| Loại (Kind) | Đầu dò (Probe) | `present` nghĩa là |
| --- | --- | --- |
| `cli`, `binary` | lệnh được tìm thấy trên `PATH` hoặc dưới dạng một đường dẫn hợp lệ | đã cài đặt và có thể chạy được |
| `mcp`, `skill` | đường dẫn `scan_target` tồn tại (hỗ trợ phân giải dấu `~`) | đã được trang bị/cấu hình trên đĩa |
| `http` | `scan_target` có thể kết nối qua TCP (trong 2 giây), nếu không thì là đường dẫn | endpoint phản hồi |

Lệnh `tool check` luôn trả về mã thoát `0`: một extension bị thiếu chỉ là một sự thật cần báo cáo, không phải lỗi của CLI. Một `cli`/`binary` ở trạng thái `present` khi nó có thể chạy được. Một `mcp`/`skill`/`http` ở trạng thái `present` nghĩa là **được trang bị** (cấu hình/file tồn tại), không có nghĩa là **đang hoạt động trong phiên này** — agent vẫn phải xác nhận khả năng sử dụng thực tế tại thời điểm gọi, vì chỉ môi trường chạy của agent mới biết liệu máy chủ MCP của nó có thực sự kết nối hay không. Nếu không có `scan_target`, trạng thái sẽ là `unknown` và agent phải tự xác nhận.

## Registry Inbound: Tìm kiếm theo Capability

Một bước luồng công việc sẽ hỏi "cái gì hiện diện cho mục đích này?" thay vì gọi đích danh một công cụ:

```bash
scripts/bin/harness-cli query tools --capability impact-analysis
scripts/bin/harness-cli query tools --capability impact-analysis --status present
```

Kết quả trả về là tập hợp các provider (nhà cung cấp). Nhiều công cụ có thể cung cấp cùng một capability (cả gitnexus và c3 đều phục vụ `impact-analysis` và bổ sung cho nhau), vì vậy một bước luồng công việc sẽ đọc tập hợp này và tự động hạ cấp theo mức độ hiện diện của chúng.

### Nấc thang Hạ cấp Tự động (Degrade Ladder)

CLI báo cáo các sự thật (`status`); agent áp dụng chính sách. Quy tắc chung dựa trên số lượng provider hiện diện cho một capability:

| Số provider hiện diện | Tư thế (Posture) | Hành vi của agent |
| --- | --- | --- |
| không có cái nào đăng ký | Inactive (Không hoạt động) | bỏ qua sạch sẽ; ghi nhận `capability X: inactive` trong trace. Không tính là sai lệch (drift). |
| đã đăng ký nhưng không có/chỉ có một số hiện diện | Degraded (Bị hạ cấp) | chạy với những gì phân giải được; bật cờ `Weak proof` (chứng thực yếu); ghi nhận khoảng trống. |
| tất cả đều hiện diện | Full (Đầy đủ) | vận hành bình thường. |

Một công cụ đã đăng ký nhưng khi quét báo trạng thái `missing` là một chốt chặn hiệu lực bị thất bại, không phải là một sự bỏ qua sạch sẽ. Một capability không có nhà cung cấp nào đăng ký chỉ đơn giản là không hoạt động và được bỏ qua mà không bị phạt — điều này giúp core của harness hoạt động mượt mà ngay trên một bản cài đặt mới.

### Từ vựng Capability Khuyến nghị

Danh sách capability là mở (không cần đổi mã nguồn để thêm), nhưng một bước và các nhà cung cấp của nó phải thống nhất về chuỗi ký tự chính xác. Hãy tái sử dụng các từ vựng dưới đây trước khi đặt từ mới; đặt từ mới ở dạng kebab-case:

```
impact-analysis · deploy-verification · coverage · security-scan
performance-benchmark · documentation-lookup
```

## Kiểm tra Registry (Inspecting The Registry)

```bash
scripts/bin/harness-cli query tools --summary
scripts/bin/harness-cli query tools --json
scripts/bin/harness-cli query tools --responsibility Verification
```

Các bản ghi JSON mang theo `kind`, `capability`, `scan_target`, `status` và `checked_at` cùng với các trường dữ liệu hiện có, vì vậy bất kỳ agent nào cũng có thể đọc registry mà không cần phân tích cú pháp bảng của con người.

## Các Lệnh Harness được Biên dịch (Outbound Manifest)

| Lệnh (Command) | Trách nhiệm | Mục đích | Đối số (Arguments) |
| --- | --- | --- | --- |
| `init` | Trạng thái nhiệm vụ | Tạo cơ sở dữ liệu harness. | không có |
| `migrate` | Trạng thái nhiệm vụ | Áp dụng các migration lược đồ cơ sở dữ liệu đang chờ xử lý. | không có |
| `import brownfield` | Bộ nhớ dự án | Gieo mầm các bản ghi lâu dài từ trạng thái markdown cũ. | không có |
| `intake` | Đặc tả nhiệm vụ | Ghi lại phân loại tiếp nhận tính năng. | `--type`, `--summary`, `--lane` |
| `story add` | Trạng thái nhiệm vụ | Tạo một bản ghi story lâu dài. | `--id`, `--title`, `--lane`, tùy chọn `--verify` |
| `story update` | Trạng thái nhiệm vụ | Cập nhật trạng thái story không liên quan đến hoàn thành (non-completion), các cờ bằng chứng, chứng cứ, hoặc lệnh xác thực; `implemented` yêu cầu `story complete`. | `--id`, tùy chọn các trường trạng thái/bằng chứng |
| `story update --json` | Trạng thái nhiệm vụ | Thực hiện cập nhật trạng thái non-completion có thể đọc bằng máy với so sánh-và-đặt giao dịch (transactional compare-and-set)/điều kiện tiên quyết runnable. | `--id`, `--status`, `--expected-status`, tùy chọn `--require-runnable` |
| `story dependency add` | Trạng thái nhiệm vụ | Thêm cạnh phụ thuộc bền vững an toàn chu trình (cycle-safe). | `--blocker`, `--blocked` |
| `story dependency remove` | Trạng thái nhiệm vụ | Xóa cạnh phụ thuộc bền vững; các cạnh không tồn tại không thay đổi. | `--blocker`, `--blocked` |
| `story hierarchy add` | Trạng thái nhiệm vụ | Thêm cạnh cha/con bất biến (idempotent), an toàn chu trình. | `--parent`, `--child`, tùy chọn `--json` |
| `story hierarchy remove` | Trạng thái nhiệm vụ | Xóa cạnh cha/con bất biến. | `--parent`, `--child`, tùy chọn `--json` |
| `story backlog link` | Trạng thái nhiệm vụ | Thêm liên kết `resolves` hoặc `references` có thể phát lại (replayable) đến một mục backlog ổn định. | `--story`, `--backlog`, `--relationship` |
| `story backlog unlink` | Trạng thái nhiệm vụ | Xóa mối quan hệ; nguồn gốc (provenance) của resolver đã đóng vẫn bất biến. | `--story`, `--backlog` |
| `story backlog list` | Trạng thái nhiệm vụ | Hiển thị các mối quan hệ story-backlog. | tùy chọn `--story`, `--backlog` |
| `story verify` | Xác thực | Chạy lệnh `verify_command` của một story và ghi nhận kết quả thành công/thất bại. | story id |
| `story complete` | Trạng thái nhiệm vụ | Chạy bằng chứng mới và triển khai nguyên tử (atomically) một story đủ điều kiện cộng với công việc backlog resolver đã chấp nhận. | story id |
| `story verify-all` | Xác thực | Chạy tất cả các lệnh xác thực story đã cấu hình và bỏ qua các story không có lệnh này. | không có |
| `decision add` | Bộ nhớ dự án | Tạo một bản ghi quyết định kỹ thuật lâu dài. | `--id`, `--title`, tùy chọn `--doc`, `--verify` |
| `decision verify` | Xác thực | Chạy một lệnh xác thực quyết định kỹ thuật. | decision id |
| `backlog add` | Kiểm toán entropy | Ghi nhận một đề xuất cải tiến harness. | `--title`, tùy chọn các trường pain/suggestion/risk/predicted |
| `backlog close` | Kiểm toán entropy | Đóng một mục backlog kèm theo bằng chứng kết quả thực tế. | `--id`, tùy chọn `--status`, `--outcome` |
| `backlog reconcile` | Kiểm toán entropy | Xem trước hoặc áp dụng backfill danh tính vòng đời di sản bảo thủ. | `--action backfill-lifecycle-identity`, chính xác một trong `--dry-run` hoặc `--apply` |
| `backlog outcome record` | Kiểm toán entropy | Thêm quan sát kết quả đo được vào mục đã triển khai có khóa. | `--id`, `--status`, `--outcome`, tùy chọn `--evidence` |
| `tool register` | Truy cập công cụ | Đăng ký một công cụ dự án bên ngoài. | `--name`, `--command`, `--description`, `--responsibility`, tùy chọn `--kind`, `--capability`, `--scan`, `--args`, `--force` |
| `tool check` | Truy cập công cụ | Quét các công cụ đã đăng ký và lưu lại trạng thái present/missing/unknown. | tùy chọn `--name`, `--json` |
| `tool remove` | Truy cập công cụ | Gỡ bỏ một công cụ bên ngoài đã đăng ký. | `--name` |
| `intervention add` | Ghi nhận can thiệp | Ghi lại can thiệp của con người, người đánh giá, hệ thống CI hoặc agent. | `--type`, `--description`, `--source`, tùy chọn `--trace`, `--story`, `--impact` |
| `trace` | Khả năng quan sát | Ghi lại trace thực thi của agent và in ra chất lượng trace. | `--summary`, tùy chọn các trường trace |
| `score-trace` | Khả năng quan sát | Tính điểm chi tiết của trace so với yêu cầu của làn rủi ro. | tùy chọn `--id` |
| `score-context` | Lựa chọn ngữ cảnh | Tính điểm các file đã đọc của trace so với các quy tắc ngữ cảnh đã biên dịch. | trace id |
| `audit` | Kiểm toán entropy | Chạy kiểm tra sai lệch và tính điểm entropy. | không có |
| `propose` | Kiểm toán entropy | Đọc các đề xuất cải tiến xác định, hoặc chấp nhận/từ chối rõ ràng một khóa ổn định. | `--accept <key>` cộng một lịch trình kết quả, hoặc `--reject <key> --reason <text>` |
| `query matrix` | Trạng thái nhiệm vụ | Hiển thị ma trận chứng thực story lâu dài, tùy chọn tập trung vào active, runnable, hoặc một story chính xác và không có văn bản bằng chứng dài. | tùy chọn `--numeric`, `--active`, `--runnable`, `--story <id>`, `--summary` |
| `query contract` | Truy cập công cụ | Khám phá giao thức, khả năng, phạm vi schema được hỗ trợ, và trạng thái DB mà không ghi. | bắt buộc `--json` |
| `query stories` | Trạng thái nhiệm vụ | Trả về bản ghi story điều phối ổn định. | bắt buộc `--json` |
| `query work-graph` | Trạng thái nhiệm vụ | Trả về một đồ thị story/phụ thuộc/phân cấp nhất quán giao dịch và phiên bản sửa đổi. | bắt buộc `--json` |
| `query dependencies` | Trạng thái nhiệm vụ | Hiển thị các cạnh phụ thuộc story. | tùy chọn `--story` |
| `query hierarchy` | Trạng thái nhiệm vụ | Hiển thị các cạnh cha/con xác định. | tùy chọn `--story`, tùy chọn `--json` |
| `query backlog` | Kiểm toán entropy | Hiển thị backlog cải tiến Harness và, với `--id`, các mối quan hệ của nó. | tùy chọn `--open`, `--closed`, `--id` |
| `query decisions` | Bộ nhớ dự án | Hiển thị các bản ghi quyết định kỹ thuật lâu dài. | không có |
| `query intakes` | Đặc tả nhiệm vụ | Hiển thị các bản ghi tiếp nhận gần đây. | không có |
| `query traces` | Khả năng quan sát | Hiển thị các bản ghi trace gần đây. | không có |
| `query friction` | Quy trách nhiệm lỗi | Hiển thị các trace có chứa ma sát harness. | không có |
| `query tools` | Truy cập công cụ | Hiển thị các mục công cụ đã biên dịch và đã đăng ký. | tùy chọn `--json`, `--summary`, `--responsibility`, `--capability`, `--status` |
| `query interventions` | Ghi nhận can thiệp | Hiển thị các bản ghi can thiệp. | tùy chọn `--trace`, `--story`, `--type` |
| `query stats` | Trạng thái nhiệm vụ | Hiển thị số lượng các bản ghi lâu dài. | không có |
| `query sql` | Truy cập công cụ | Chạy một câu lệnh SQL chỉ đọc (read-only) với `harness.db`. | văn bản lệnh SQL |
| `db changeset apply` | Trạng thái nhiệm vụ | Áp dụng một changeset ngữ nghĩa một cách bất biến (idempotently). | đường dẫn changeset |
| `db changeset status` | Trạng thái nhiệm vụ | Phân tích và kiểm tra ID/SHA nội dung/trạng thái đã áp dụng của một changeset mà không ghi. | đường dẫn changeset, bắt buộc `--json` |
| `db snapshot` | Trạng thái nhiệm vụ | Tạo ảnh chụp online-backup SQLite nguyên tử có kiểm tra tính toàn vẹn. | `--output`, bắt buộc `--json` |
| `db rebuild` | Trạng thái nhiệm vụ | Xây dựng lại `harness.db` mới từ các changeset ngữ nghĩa. | `--from` thư mục changeset |

Các envelope protocol-v1 chính xác, mã thoát (exit codes), định nghĩa runnable, quy tắc timeout và hủy bỏ, và các JSON schema được chuẩn hóa (normative) trong `harness-docs/contracts/harness-orchestration-v1.md`. Bảng registry chỉ là chỉ mục lệnh cho con người.

## Các Quy tắc Xác thực (Validation Rules)

- Tên công cụ phải là duy nhất trong số các công cụ đã đăng ký.
- Mô tả phải từ 10 đến 200 ký tự.
- Trách nhiệm (responsibility) phải khớp với danh sách trách nhiệm của Runtime Substrate.
- Tham số `--kind` phải là một trong các giá trị: `cli`, `binary`, `mcp`, `skill`, `http`.
- Tham số `--capability` phải ở dạng kebab-case (chữ thường, chữ số, dấu gạch ngang đơn); khoảng trắng và dấu gạch dưới được tự động chuẩn hóa thành dấu gạch ngang.
- Các mục của `--args` phải sử dụng định dạng `name:type:required` hoặc `name:type:required:help`, với trường thứ ba là `required` hoặc `optional`.
- Đối với `cli`/`binary`, lệnh thực thi phải tồn tại dưới dạng một đường dẫn hoặc trên hệ thống `PATH`, trừ khi cờ `--force` được cung cấp. Các loại `mcp`/`skill`/`http` bỏ qua kiểm tra này.

