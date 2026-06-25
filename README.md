# repository-harness

Biến bất kỳ repo phần mềm nào thành một không gian làm việc sẵn sàng cho agent (agent-ready workspace).

`repository-harness` là một harness (khung vận hành) cấp độ repository dành cho Claude Code, Codex, Cursor và các coding agent khác. Nó cung cấp cho các agent ngữ cảnh dự án (project context) còn thiếu trước khi thay đổi mã nguồn: bắt đầu từ đâu, đặc tả sản phẩm (product contract) yêu cầu gì, mức độ rủi ro của công việc ra sao, cần những bằng chứng xác thực (proof) nào và những quyết định kỹ thuật nào mà các agent trong tương lai cần kế thừa.

Ứng dụng (app) là thứ người dùng tương tác. Harness là thứ agent tương tác.

## Tại sao nên Star Repo này

Hãy star repo này nếu bạn muốn tìm kiếm các mẫu thiết kế (pattern) thực tế, có thể tái sử dụng để giúp việc phát triển phần mềm được hỗ trợ bởi AI trở nên đáng tin cậy hơn, dễ kiểm tra (inspectable) và dễ điều hướng hơn đối với con người.

Dự án này đang khám phá một ý tưởng đơn giản:

> Các coding agent không chỉ cần những prompt tốt hơn. Chúng cần những repository tốt hơn.

## Vấn đề

Hầu hết các repo được xây dựng cho con người đọc mã nguồn trong một codebase quen thuộc. Các coding agent thường bắt đầu chỉ với một chat prompt và một bản chụp nhanh (snapshot) nông của các file. Điều đó dẫn đến các lỗi phổ biến (failure modes):

- Agent chỉnh sửa code trước khi hiểu rõ mục đích sản phẩm (product intent).
- Các ràng buộc quan trọng chỉ nằm trong lịch sử chat hoặc trong đầu của ai đó.
- Kỳ vọng xác thực (validation expectations) mơ hồ hoặc được phát hiện quá muộn.
- Các đánh đổi về mặt kiến trúc (architecture tradeoffs) bị lặp lại thay vì được kế thừa.
- Các yêu cầu lớn không được chia nhỏ thành các phần việc có kích thước phù hợp với story (story-sized work).

## Cách tiếp cận bằng Harness

Một repository bắt đầu có một harness khi nó giúp một agent trả lời các câu hỏi kỹ thuật thực tế mà không cần chỉ phụ thuộc vào lịch sử chat:

- Tôi nên đọc tài liệu nào trước?
- Đây là loại công việc gì?
- Nó ảnh hưởng đến đặc tả sản phẩm (product contract) nào?
- Thay đổi này rủi ro như thế nào?
- Bằng chứng xác thực (proof) nào sẽ chứng minh công việc đã hoàn thành?
- Quyết định kỹ thuật hoặc bài học nào mà các agent tương lai cần kế thừa?

Trong repo này, các câu trả lời đó nằm ở:

- `AGENTS.md` — shim cho agent ổn định chứa các ghi chú dự án cục bộ và các liên kết tài liệu Harness.
- `harness-docs/HARNESS.md` — mô hình cộng tác giữa con người và agent.
- `harness-docs/FEATURE_INTAKE.md` — phân loại công việc theo mức độ rủi ro nhỏ (tiny), bình thường (normal) và rủi ro cao (high-risk).
- `harness-docs/ARCHITECTURE.md` — khám phá kiến trúc và các quy tắc ranh giới (boundary rules).
- `harness-docs/TEST_MATRIX.md` — bảng điều khiển mối liên hệ giữa hành vi và bằng chứng xác thực (behavior-to-proof).
- `harness-docs/stories/` — các story packet và danh sách backlog.
- `harness-docs/decisions/` — các quyết định lâu dài (durable decisions) và sự đánh đổi (tradeoffs).
- `harness-docs/templates/` — các template có thể tái sử dụng cho đặc tả (spec), story, quyết định kỹ thuật (decision) và xác thực (validation).

OpenAI mô tả sự chuyển dịch này như một thế giới ưu tiên agent (agent-first world), nơi con người điều hướng và agent thực thi:

https://openai.com/index/harness-engineering/

## Cài đặt Harness vào một Dự án

Từ thư mục của dự án mục tiêu, chạy lệnh sau:

```bash
curl -fsSL "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh?$(date +%s)" | bash -s -- --yes
```

Trên Windows PowerShell, chạy:

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.ps1"))) -Yes
```

Nếu mục tiêu đã có `AGENTS.md`, `harness-docs/` hoặc `scripts/`, hãy chọn một trong hai cách:

```bash
# Cập nhật một repo Harness hiện có mà không di chuyển các file hiện tại
curl -fsSL "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh?$(date +%s)" | bash -s -- --merge --yes

# Sao lưu và ghi đè AGENTS.md, harness-docs/, và scripts/
curl -fsSL "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh?$(date +%s)" | bash -s -- --override --yes
```

```powershell
# Cập nhật một repo Harness hiện có mà không di chuyển các file hiện tại
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.ps1"))) -Merge -Yes

# Sao lưu và ghi đè AGENTS.md, harness-docs/, và scripts/
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.ps1"))) -Override -Yes
```

Sử dụng tùy chọn `--merge` khi một dự án đã có Harness và bạn muốn thêm các file Harness mới mà không đưa các đường dẫn `AGENTS.md`, `harness-docs/` hoặc `scripts/` hiện tại vào thư mục sao lưu (backup). Các file hiện tại sẽ được giữ nguyên; chỉ các file Harness còn thiếu mới được tạo.

Đối với các bản cài đặt Harness cũ hơn mà file `AGENTS.md` vẫn chứa hướng dẫn vận hành đầy đủ, hãy chuyển đổi nó thành một shim nhỏ ổn định:

```bash
curl -fsSL "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh?$(date +%s)" | bash -s -- --merge --refresh-agent-shim --yes
```

Quá trình làm mới sẽ sao lưu file hiện tại. Nếu phát hiện hướng dẫn cũ do Harness tạo ra, nó sẽ thay thế bằng shim. Nếu file được tùy biến (custom), nó sẽ thêm hoặc cập nhật khối Harness được đánh dấu thay vì ghi đè các hướng dẫn cục bộ của dự án.

Nếu dự án được chạy bằng Claude Code, hãy thêm `--claude`. Claude Code không bao giờ tự động tải `AGENTS.md`, vì vậy nếu không có cờ này, harness được cài đặt sẽ vô hình đối với các phiên làm việc (session) mới. Cờ này cài đặt (hoặc làm mới) file `CLAUDE.md` có khối Harness được đánh dấu nhằm `@`-import `AGENTS.md` và `harness-docs/FEATURE_INTAKE.md` vào ngữ cảnh (context) của mỗi session. File `CLAUDE.md` hiện tại sẽ được thêm khối này sau khi sao lưu; việc cài đặt thông thường không có cờ này sẽ không bao giờ chạm vào `CLAUDE.md`:

```bash
curl -fsSL "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh?$(date +%s)" | bash -s -- --claude --yes
```

Hoặc cài đặt vào một đường dẫn cụ thể:

```bash
curl -fsSL "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh?$(date +%s)" | bash -s -- --directory /path/to/project --yes
```

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.ps1"))) -Directory C:\path\to\project -Yes
```

Sử dụng cờ `--dry-run` trên Bash hoặc `-DryRun` trên PowerShell để xem trước các thay đổi trước khi ghi file thật.

Trình cài đặt cũng tải xuống Harness CLI được biên dịch sẵn cho nền tảng hiện tại, kiểm tra mã checksum `.sha256` của nó và cài đặt tại `scripts/bin/harness-cli` trên macOS/Linux hoặc `scripts/bin/harness-cli.exe` trên Windows. Rust CLI là công cụ Harness chính và là đường dẫn lệnh ổn định.

Các bản phát hành (release asset) của Harness CLI được xuất bản từ các thẻ (tag) bởi workflow GitHub Actions `Harness CLI Release`. Trình cài đặt yêu cầu mỗi phiên bản phát hành phải bao gồm các file `harness-cli-<platform>` và `harness-cli-<platform>.sha256` cho macOS arm64, macOS x64, Linux x64, Linux arm64 và Windows x64. File cho Windows là `harness-cli-windows-x64.exe` kèm theo `harness-cli-windows-x64.exe.sha256`.

Các pull request đã merge được ghi nhận vào `CHANGELOG.md` bởi workflow `Post-Merge Maintenance`. Khi một PR được merge có thay đổi mã nguồn Rust CLI, schema, Cargo metadata hoặc đóng gói phát hành CLI, workflow đó sẽ tăng phiên bản patch của CLI, cập nhật `scripts/harness-cli-release-tag`, tạo tag `harness-cli-v*` và chạy bản build phát hành Harness CLI cho tag đó.

## Trải nghiệm Luồng công việc (Try The Flow)

Cách nhanh nhất để hiểu harness là kiểm tra bản demo nhỏ sau:

- `harness-docs/demo/README.md`: chỉ ra cách một ý tưởng sản phẩm đơn giản trở thành tài liệu sản phẩm, các story, kỳ vọng xác thực và quyết định kỹ thuật trước khi quá trình triển khai (implementation) bắt đầu.

Một luồng công việc điển hình sẽ như thế này:

```text
ý tưởng của con người hoặc đặc tả sản phẩm (product spec)
  -> đặc tả sản phẩm (product contract)
  -> tiếp nhận tính năng (feature intake)
  -> câu chuyện người dùng (story packet)
  -> kỳ vọng xác thực (validation expectations)
  -> công việc triển khai thực tế (implementation work)
  -> quyết định kỹ thuật hoặc bài học được ghi lại cho các agent tương lai
```

Các prompt triển khai không đi thẳng vào code. Đầu tiên chúng đi qua quy trình tiếp nhận tính năng (feature intake), trở thành công việc có kích thước phù hợp với story khi cần thiết, sau đó mang theo cả kỳ vọng xác thực sản phẩm lẫn kỳ vọng bảo trì harness.

## Hệ thống Đăng ký Công cụ (Tool Registry)

Harness có thể sử dụng các công cụ bên ngoài tùy chọn (linter, code-graph server, kiểm tra deploy) mà không bị phụ thuộc vào bất kỳ công cụ nào trong số chúng. Bạn đăng ký một công cụ như một nhà cung cấp của một khả năng (capability), harness quét xem công cụ đó có thực sự hiện diện hay không, và một bước workflow sẽ sử dụng bất cứ thứ gì được trang bị — công cụ vắng mặt sẽ được bỏ qua một cách sạch sẽ, không bao giờ gây lỗi.

```bash
# đăng ký một công cụ làm nhà cung cấp cho một capability
scripts/bin/harness-cli tool register --name deploy-check --kind cli \
  --capability deploy-verification --command ./scripts/deploy-check.sh \
  --responsibility Verification --description "Verify deploy health before release"

# quét sự hiện diện (ghi nhận present/missing/unknown)
scripts/bin/harness-cli tool check

# một bước tìm kiếm xem công cụ nào được trang bị cho mục đích cụ thể
scripts/bin/harness-cli query tools --capability deploy-verification --status present
```

Các loại công cụ (`cli`, `binary`, `mcp`, `skill`, `http`) giúp nó có tính độc lập với agent (agent-generic): mỗi môi trường chạy của agent sẽ sử dụng những gì nó có thể điều phối. Xem `harness-docs/TOOL_REGISTRY.md` để biết mô hình đầy đủ, các nấc hạ cấp tự động (degrade ladder) và cách kết nối một công cụ vào một bước luồng công việc.

## Trạng thái Hiện tại (Current State)

Repository này hiện đang ở phiên bản Harness v0.

Vẫn chưa có phần triển khai ứng dụng (application implementation) và chưa tích hợp đặc tả sản phẩm (product specification). Công việc hiện tại là phần harness dự án có thể tái sử dụng: cấu trúc file, mô hình vận hành của agent, quy trình tiếp nhận tính năng, các story template và kỳ vọng xác thực giúp con người và agent biến một tài liệu spec trong tương lai do người dùng cung cấp thành công việc triển khai thực tế.

## Nguồn Sản phẩm (Product Sources)

Hiện tại chưa có đặc tả sản phẩm (product contract) nào được định nghĩa.

Khi người dùng cung cấp một tài liệu spec dự án, hãy thêm hoặc tham chiếu nó như là spec đầu vào cho đợt xây dựng đầu tiên, sau đó rút trích các tài liệu sống (living artifacts) nhỏ hơn từ đó:

- `harness-docs/product/`: các file đặc tả sản phẩm hiện tại, được tạo từ spec đầu vào.
- `harness-docs/stories/`: các story packet và backlog được tạo từ các công việc được chọn.
- `harness-docs/TEST_MATRIX.md`: bảng điều khiển liên kết giữa hành vi và bằng chứng xác thực (behavior-to-proof).
- `harness-docs/decisions/`: các quyết định kỹ thuật lâu dài và sự đánh đổi.

Không giữ spec riêng biệt của dự án hoặc bảng phân rã sản phẩm trong harness này cho đến khi có một dự án thực tế cung cấp.

## Cấu trúc Kho lưu trữ (Repository Structure)

```text
project/
  AGENTS.md
  README.md
  harness-docs/
    HARNESS.md
    FEATURE_INTAKE.md
    ARCHITECTURE.md
    TEST_MATRIX.md
    HARNESS_BACKLOG.md
    product/
    stories/
    decisions/
    demo/
    templates/
  scripts/
    README.md
```

## Đóng góp (Contributing)

Dự án này đang ở giai đoạn đầu và được hưởng lợi nhiều nhất từ các trường hợp lỗi thực tế của agent, các bản cài đặt harness mẫu, các cải tiến tài liệu và các mẫu luồng công việc tái sử dụng được. Xem `CONTRIBUTING.md` để biết thêm ý tưởng đóng góp.

Các đóng góp hữu ích bao gồm:

- Chỉ ra cách harness hoạt động trong một dự án thực tế.
- Thêm các template còn thiếu hoặc cải thiện các template hiện có.
- Đề xuất các mẫu xác thực (validation patterns) cho các stack công nghệ khác nhau.
- Chia sẻ các trường hợp lỗi mà agent thực hiện sai thay đổi vì repo thiếu ngữ cảnh.
- So sánh hành vi của harness trên Claude Code, Codex, Cursor và các công cụ khác.

## Chia sẻ (Share)

Nếu ý tưởng này hữu ích với bạn, vui lòng star repo và chia sẻ nó với những ai đang xây dựng phần mềm bằng các coding agent.

Mô tả ngắn:

> Một repo harness sẵn sàng cho agent dành cho Claude Code, Codex, Cursor và các coding agent khác: AGENTS.md, product contracts, story packets, validation matrix, và các bản ghi quyết định kỹ thuật (decision records).
