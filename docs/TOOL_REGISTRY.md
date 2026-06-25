# Tool Registry

Harness xử lý hai loại "tool" khác nhau. Hãy giữ chúng tách biệt.

| | Capability manifest (outbound) | Inbound tool registry |
| --- | --- | --- |
| Direction | harness cung cấp cho agent | một dự án trang bị để harness sử dụng |
| Examples | các subcommand `harness-cli` bên dưới | gitnexus, c3, linter, deploy check |
| Presence | luôn được compile sẵn | tùy chọn; có thể vắng mặt trên bất kỳ máy nào |
| If missing | n/a (đó là chính harness) | bỏ qua sạch; không bao giờ chặn quy trình chính |

Tài liệu này mô tả cả hai. **Inbound registry** là nền mở rộng: đó là nơi
harness biết capability bổ sung nào được trang bị, nó phục vụ mục đích gì và
hiện tại có thật sự hiện diện không, để một bước workflow có thể thích nghi với
những gì đã cài mà core không cần phụ thuộc vào nó.

## Inbound Registry: Đăng Ký Tool

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

Các field riêng cho inbound tool:

- `--kind` — cách tool được truy cập và probe. Một trong `cli`, `binary`, `mcp`,
  `skill`, `http`. Mặc định là `cli`. Kind cho mỗi agent runtime biết nó có thể
  điều phối gì (một agent không phải Claude chỉ xem `skill` không chạy được là
  vắng mặt) và cho `tool check` biết nên dùng probe nào.
- `--capability` — mục đích workflow mà một bước dùng để lookup tool. Là free
  text nhưng được normalize thành kebab-case, nên `Impact Analysis`,
  `impact_analysis` và `impact-analysis` đều đăng ký thành `impact-analysis`.
  Đây là coupling duy nhất giữa một bước và tool; step tham chiếu capability,
  không tham chiếu tên tool.
- `--scan` — với `mcp`/`skill`/`http`, là một path hoặc URL khai báo để
  `tool check` resolve nhằm quyết định presence (ví dụ `.c3`,
  `~/.claude/skills/c3`, `https://localhost:8080/health`). `cli`/`binary` được
  probe qua command của chúng.

`--force` chỉ cần cho `cli`/`binary` có command cố ý vắng mặt trên máy hiện tại.
`mcp`/`skill`/`http` tự nhiên không nằm trên `PATH`, nên chúng đăng ký không cần
`--force`; presence của chúng được resolve sau bằng `tool check`.

Đăng ký MCP server hoặc Claude skill (ví dụ):

```bash
scripts/bin/harness-cli tool register --name gitnexus --kind mcp \
  --capability impact-analysis --scan ".gitnexus" --command "mcp:gitnexus" \
  --description "Code-graph blast radius" --responsibility Verification
scripts/bin/harness-cli tool register --name c3 --kind skill \
  --capability impact-analysis --scan ".c3" --command "skill:c3" \
  --description "Component model and drift audit (Claude skill)" \
  --responsibility Verification
```

Xóa một tool bằng:

```bash
scripts/bin/harness-cli tool remove --name deploy-check
```

## Inbound Registry: Kiểm Tra Presence

Registration ghi lại ý định. `tool check` đối chiếu ý định với thực tế bằng cách
quét từng tool đã đăng ký và lưu verdict (`status` và `checked_at`). Chạy nó ở
đầu intake để status phản ánh thực tế hiện tại.

```bash
scripts/bin/harness-cli tool check            # scan all registered tools
scripts/bin/harness-cli tool check --name c3  # scan one
scripts/bin/harness-cli tool check --json     # machine-readable for agents
```

Probe theo kind:

| Kind | Probe | `present` means |
| --- | --- | --- |
| `cli`, `binary` | command resolve được trên `PATH` hoặc như một path | đã cài và chạy được |
| `mcp`, `skill` | `scan_target` path resolve được (`~` được expand) | đã trang bị/cấu hình trên disk |
| `http` | `scan_target` reachable qua TCP (2s), nếu không thì path | endpoint trả lời |

`tool check` luôn exit `0`: extension bị thiếu là một fact cần báo cáo, không
phải lỗi CLI. Một `cli`/`binary` là `present` khi runnable. Một
`mcp`/`skill`/`http` `present` nghĩa là **equipped** (config/file resolve được),
không phải **live this session** — agent vẫn xác nhận khả năng dùng live tại thời
điểm gọi, vì chỉ agent runtime mới biết MCP server của nó có đang kết nối không.
Khi không có `scan_target`, status là `unknown` và agent phải xác nhận.

## Inbound Registry: Lookup Theo Capability

Một bước workflow hỏi "có gì present cho mục đích này?" thay vì gọi tên tool:

```bash
scripts/bin/harness-cli query tools --capability impact-analysis
scripts/bin/harness-cli query tools --capability impact-analysis --status present
```

Kết quả là tập provider. Nhiều tool có thể cung cấp một capability (gitnexus và
c3 đều phục vụ `impact-analysis` và bổ sung cho nhau), nên một bước đọc tập này
và degrade dựa trên mức present.

### Thang Degrade

CLI báo cáo fact (`status`); agent áp dụng policy. Quy tắc chung, dựa trên số
provider present cho một capability:

| Providers present | Posture | Agent behavior |
| --- | --- | --- |
| none registered | Inactive | bỏ qua sạch; ghi `capability X: inactive` trong trace. Không phải drift. |
| registered but none/some present | Degraded | chạy với phần resolve được; đặt flag `Weak proof`; ghi lại khoảng trống. |
| all present | Full | vận hành bình thường. |

Một tool đã đăng ký nhưng scan là `missing` là validity gate thất bại, không
phải một skip. Một capability không có provider đã đăng ký chỉ đơn giản là
inactive và được bỏ qua không phạt — đây là cách giữ core liền mạch trên bản cài
mới.

### Vocabulary Capability Khuyến Nghị

Capability mở (không cần đổi code để thêm), nhưng một step và provider của nó
phải thống nhất đúng string. Tái sử dụng các mục này khi phù hợp trước khi đặt
tên mới; tên mới dùng kebab-case:

```
impact-analysis · deploy-verification · coverage · security-scan
performance-benchmark · documentation-lookup
```

## Inspect Registry

```bash
scripts/bin/harness-cli query tools --summary
scripts/bin/harness-cli query tools --json
scripts/bin/harness-cli query tools --responsibility Verification
```

JSON record mang `kind`, `capability`, `scan_target`, `status` và `checked_at`
cùng với các field hiện có, để bất kỳ agent nào cũng đọc registry mà không cần
parse bảng dành cho người.

## Lệnh Harness Đã Compile (Outbound Manifest)

| Command | Responsibility | Purpose | Arguments |
| --- | --- | --- | --- |
| `init` | Task state | Tạo cơ sở dữ liệu harness. | none |
| `migrate` | Task state | Áp dụng schema migration còn pending. | none |
| `import brownfield` | Project memory | Seed durable record từ markdown state. | none |
| `intake` | Task specification | Ghi phân loại feature intake. | `--type`, `--summary`, `--lane` |
| `story add` | Task state | Tạo durable story record. | `--id`, `--title`, `--lane`, optional `--verify` |
| `story update` | Task state | Cập nhật trạng thái story, proof flag, evidence hoặc verification command. | `--id`, optional proof/status fields |
| `story verify` | Verification | Chạy một `verify_command` của story và ghi pass/fail. | story id |
| `story verify-all` | Verification | Chạy mọi lệnh proof story đã cấu hình và bỏ qua story không có lệnh. | none |
| `decision add` | Project memory | Tạo durable decision record. | `--id`, `--title`, optional `--doc`, `--verify` |
| `decision verify` | Verification | Chạy một lệnh xác thực decision. | decision id |
| `backlog add` | Entropy auditing | Ghi đề xuất cải thiện harness. | `--title`, optional pain/suggestion/risk/predicted fields |
| `backlog close` | Entropy auditing | Đóng mục backlog với outcome evidence. | `--id`, optional `--status`, `--outcome` |
| `tool register` | Tool access | Đăng ký external project tool. | `--name`, `--command`, `--description`, `--responsibility`, optional `--kind`, `--capability`, `--scan`, `--args`, `--force` |
| `tool check` | Tool access | Quét registered tool và lưu status present/missing/unknown. | optional `--name`, `--json` |
| `tool remove` | Tool access | Xóa một registered external tool. | `--name` |
| `intervention add` | Intervention recording | Ghi human, reviewer, CI hoặc agent intervention. | `--type`, `--description`, `--source`, optional `--trace`, `--story`, `--impact` |
| `trace` | Observability | Ghi agent execution trace và in trace quality. | `--summary`, optional trace fields |
| `score-trace` | Observability | Chấm điểm chi tiết trace theo yêu cầu lane. | optional `--id` |
| `score-context` | Context selection | Chấm điểm các file đã đọc trong trace theo context rule đã compile. | trace id |
| `audit` | Entropy auditing | Chạy drift check và tính entropy score. | none |
| `propose` | Entropy auditing | Tạo improvement proposal từ friction, intervention và audit finding. | optional `--commit` |
| `query matrix` | Task state | Hiển thị durable story proof matrix. | optional `--numeric` |
| `query backlog` | Entropy auditing | Hiển thị harness improvement backlog. | optional `--open`, `--closed` |
| `query decisions` | Project memory | Hiển thị durable decision record. | none |
| `query intakes` | Task specification | Hiển thị intake record gần đây. | none |
| `query traces` | Observability | Hiển thị trace record gần đây. | none |
| `query friction` | Failure attribution | Hiển thị trace có harness friction. | none |
| `query tools` | Tool access | Hiển thị compiled và registered tool entry. | optional `--json`, `--summary`, `--responsibility`, `--capability`, `--status` |
| `query interventions` | Intervention recording | Hiển thị intervention record. | optional `--trace`, `--story`, `--type` |
| `query stats` | Task state | Hiển thị số lượng durable record. | none |
| `query sql` | Tool access | Chạy SQL tùy ý trên `harness.db`. | SQL text |

## Quy Tắc Xác Thực

- Tên tool phải là duy nhất trong các registered tool.
- Description phải dài 10-200 ký tự.
- Responsibility phải khớp danh sách trách nhiệm Runtime Substrate.
- `--kind` phải là một trong `cli`, `binary`, `mcp`, `skill`, `http`.
- `--capability` phải là kebab-case (chữ thường, chữ số, dấu gạch nối đơn);
  space và underscore được normalize thành dấu gạch nối.
- Entry `--args` phải dùng `name:type:required` hoặc
  `name:type:required:help`, với `required` hoặc `optional` làm field thứ ba.
- Với `cli`/`binary`, command phải tồn tại như path hoặc trên `PATH`, trừ khi
  cung cấp `--force`. `mcp`/`skill`/`http` bỏ qua kiểm tra này.
