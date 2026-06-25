# repository-harness

Biến bất kỳ repo phần mềm nào thành một workspace sẵn sàng cho agent.

`repository-harness` là một harness vận hành cấp repo dành cho Claude Code,
Codex, Cursor và các coding agent khác. Nó cung cấp cho agent phần ngữ cảnh dự
án còn thiếu trước khi agent thay đổi mã: bắt đầu từ đâu, hợp đồng sản phẩm nói
gì, công việc rủi ro đến mức nào, bằng chứng nào là bắt buộc, và quyết định nào
các agent tương lai cần kế thừa.

Ứng dụng là thứ người dùng chạm vào. Harness là thứ agent chạm vào.

## Vì Sao Nên Star Repo Này

Star repo này nếu bạn muốn các mẫu thực tế, có thể tái sử dụng để làm phát
triển phần mềm có AI hỗ trợ trở nên đáng tin cậy hơn, dễ kiểm tra hơn, và dễ để
con người điều hướng hơn.

Dự án này đang khám phá một ý tưởng đơn giản:

> Coding agent không chỉ cần prompt tốt hơn. Chúng cần repo tốt hơn.

## Vấn Đề

Phần lớn repo được xây cho con người đọc mã trong một codebase quen thuộc.
Coding agent thường bước vào chỉ với một prompt chat và một ảnh chụp nông của
các file. Điều đó dẫn tới các lỗi thường gặp:

- Agent sửa mã trước khi hiểu ý định sản phẩm.
- Ràng buộc quan trọng chỉ nằm trong lịch sử chat hoặc trong đầu ai đó.
- Kỳ vọng xác thực mơ hồ hoặc được phát hiện quá muộn.
- Đánh đổi kiến trúc bị lặp lại thay vì được kế thừa.
- Yêu cầu lớn không được chia thành các phần việc cỡ story để review được.

## Cách Tiếp Cận Harness

Một repo bắt đầu có harness khi nó giúp agent trả lời các câu hỏi kỹ thuật thực
tế mà không chỉ dựa vào lịch sử chat:

- Tôi nên đọc gì trước?
- Đây là loại công việc nào?
- Nó ảnh hưởng hợp đồng sản phẩm nào?
- Mức rủi ro của thay đổi là gì?
- Bằng chứng nào cho thấy công việc đã xong?
- Quyết định hoặc bài học nào agent tương lai nên kế thừa?

Trong repo này, các câu trả lời đó nằm ở:

- `AGENTS.md` — shim agent ổn định với ghi chú dự án cục bộ và liên kết tài
  liệu Harness.
- `docs/HARNESS.md` — mô hình cộng tác giữa con người và agent.
- `docs/FEATURE_INTAKE.md` — phân loại công việc tiny, normal và high-risk.
- `docs/ARCHITECTURE.md` — quy tắc khám phá kiến trúc và ranh giới.
- `docs/TEST_MATRIX.md` — kỳ vọng xác thực từ hành vi tới bằng chứng.
- `docs/stories/` — các story packet và mục backlog.
- `docs/decisions/` — quyết định và đánh đổi bền vững.
- `docs/templates/` — mẫu tái sử dụng cho spec, story, quyết định và xác thực.

OpenAI mô tả dịch chuyển này như một thế giới ưu tiên agent, nơi con người điều
hướng và agent thực thi:

https://openai.com/index/harness-engineering/

## Cài Harness Vào Một Dự Án

Từ thư mục dự án đích, chạy:

```bash
curl -fsSL "https://raw.githubusercontent.com/hoangnb24/repository-harness/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --yes
```

Trên Windows PowerShell, chạy:

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/hoangnb24/repository-harness/main/scripts/install-harness.ps1"))) -Yes
```

Nếu đích đã có `AGENTS.md`, `docs/`, hoặc `scripts/`, chọn một cách:

```bash
# Update an existing Harness repo without moving existing files
curl -fsSL "https://raw.githubusercontent.com/hoangnb24/repository-harness/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --merge --yes

# Back up and replace AGENTS.md, docs/, and scripts/
curl -fsSL "https://raw.githubusercontent.com/hoangnb24/repository-harness/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --override --yes
```

```powershell
# Update an existing Harness repo without moving existing files
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/hoangnb24/repository-harness/main/scripts/install-harness.ps1"))) -Merge -Yes

# Back up and replace AGENTS.md, docs/, and scripts/
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/hoangnb24/repository-harness/main/scripts/install-harness.ps1"))) -Override -Yes
```

Dùng `--merge` khi một dự án đã có Harness và bạn muốn thêm các file Harness
mới mà không chuyển các đường dẫn `AGENTS.md`, `docs/`, hoặc `scripts/` hiện có
vào bản sao lưu. File hiện có được giữ nguyên; chỉ các file Harness còn thiếu
được tạo.

Với các bản cài Harness cũ mà `AGENTS.md` vẫn chứa toàn bộ hướng dẫn vận hành
được sinh ra, hãy làm mới nó thành shim ổn định nhỏ:

```bash
curl -fsSL "https://raw.githubusercontent.com/hoangnb24/repository-harness/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --merge --refresh-agent-shim --yes
```

Bước làm mới sẽ sao lưu file hiện có. Nếu phát hiện hướng dẫn cũ do Harness tạo,
nó thay bằng shim. Nếu file có vẻ đã được tùy biến, nó nối thêm hoặc cập nhật
khối Harness được đánh dấu thay vì ghi đè hướng dẫn cục bộ của dự án.

Nếu dự án chạy với Claude Code, thêm `--claude`. Claude Code không tự tải
`AGENTS.md`, nên nếu thiếu cờ này thì harness đã cài sẽ vô hình với phiên mới.
Cờ này cài đặt hoặc làm mới `CLAUDE.md`, trong đó khối Harness được đánh dấu
`@`-import `AGENTS.md` và `docs/FEATURE_INTAKE.md` vào ngữ cảnh của mọi phiên.
Một `CLAUDE.md` hiện có sẽ được thêm khối sau khi sao lưu; cài đặt thường không
có cờ này sẽ không chạm vào `CLAUDE.md`:

```bash
curl -fsSL "https://raw.githubusercontent.com/hoangnb24/repository-harness/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --claude --yes
```

Hoặc cài vào một đường dẫn cụ thể:

```bash
curl -fsSL "https://raw.githubusercontent.com/hoangnb24/repository-harness/main/scripts/install-harness.sh?$(date +%s)" | bash -s -- --directory /path/to/project --yes
```

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/hoangnb24/repository-harness/main/scripts/install-harness.ps1"))) -Directory C:\path\to\project -Yes
```

Dùng `--dry-run` trên Bash hoặc `-DryRun` trên PowerShell để xem trước thay đổi
trước khi ghi file.

Installer cũng tải Harness CLI đã build sẵn cho nền tảng hiện tại, xác minh
checksum `.sha256`, và cài tại `scripts/bin/harness-cli` trên macOS/Linux hoặc
`scripts/bin/harness-cli.exe` trên Windows. Rust CLI là công cụ Harness chính và
là đường dẫn lệnh ổn định.

Các release asset của Harness CLI được xuất bản từ tag bởi GitHub Actions
workflow `Harness CLI Release`. Installer kỳ vọng mỗi release có các asset
`harness-cli-<platform>` và `harness-cli-<platform>.sha256` cho macOS arm64,
macOS x64, Linux x64, Linux arm64, và Windows x64. Asset Windows là
`harness-cli-windows-x64.exe` cùng `harness-cli-windows-x64.exe.sha256`.

Pull request đã merge được ghi vào `CHANGELOG.md` bởi workflow
`Post-Merge Maintenance`. Khi một PR đã merge thay đổi mã nguồn Rust CLI,
schema, metadata Cargo, hoặc đóng gói release CLI, workflow đó tăng phiên bản
patch của CLI, cập nhật `scripts/harness-cli-release-tag`, tạo tag
`harness-cli-v*`, và chạy bản build release Harness CLI cho tag đó.

## Thử Luồng Làm Việc

Cách nhanh nhất để hiểu harness là xem demo nhỏ:

- `docs/demo/README.md`: cho thấy cách một ý tưởng sản phẩm đơn giản trở thành
  tài liệu sản phẩm, story, kỳ vọng xác thực và quyết định trước khi bắt đầu
  triển khai.

Một luồng điển hình trông như sau:

```text
human intent or product spec
  -> product contract
  -> feature intake
  -> story packet
  -> validation expectations
  -> implementation work
  -> decision or lesson captured for future agents
```

Prompt triển khai không đi thẳng tới mã. Trước tiên chúng đi qua feature
intake, trở thành phần việc cỡ story khi cần, rồi mang theo cả kỳ vọng xác thực
sản phẩm lẫn kỳ vọng bảo trì harness.

## Tool Registry

Harness có thể dùng các công cụ bên ngoài tùy chọn như linter, code-graph
server hoặc kiểm tra deploy mà không phụ thuộc vào bất kỳ công cụ nào. Bạn đăng
ký một công cụ như provider cho một *capability*, harness quét xem nó có thật sự
hiện diện không, và một bước workflow dùng bất kỳ thứ gì đang được trang bị —
công cụ vắng mặt là bỏ qua sạch, không bao giờ là lỗi.

```bash
# register a tool as a provider of a capability
scripts/bin/harness-cli tool register --name deploy-check --kind cli \
  --capability deploy-verification --command ./scripts/deploy-check.sh \
  --responsibility Verification --description "Verify deploy health before release"

# scan presence (writes present/missing/unknown)
scripts/bin/harness-cli tool check

# a step looks up what is equipped for a purpose
scripts/bin/harness-cli query tools --capability deploy-verification --status present
```

Các kind (`cli`, `binary`, `mcp`, `skill`, `http`) làm cho cơ chế này dùng được
với nhiều loại agent: mỗi agent runtime dùng phần nó có thể điều phối. Xem
`docs/TOOL_REGISTRY.md` để biết đầy đủ mô hình, thang degrade, và cách nối một
công cụ vào một bước trong luồng.

## Trạng Thái Hiện Tại

Repository này đang ở Harness v0.

Chưa có triển khai ứng dụng và chưa có đặc tả sản phẩm được gắn sẵn. Công việc
hiện tại là harness dự án có thể tái sử dụng: cấu trúc file, mô hình vận hành
agent, quy trình feature intake, mẫu story và kỳ vọng xác thực giúp con người
và agent biến một spec do người dùng cung cấp trong tương lai thành công việc
triển khai.

## Nguồn Sản Phẩm

Chưa có hợp đồng sản phẩm nào được định nghĩa.

Khi người dùng cung cấp đặc tả dự án, hãy thêm hoặc tham chiếu nó như spec đầu
vào cho lần buildout đầu tiên, rồi dẫn xuất các artifact sống nhỏ hơn từ nó:

- `docs/product/`: các file hợp đồng sản phẩm hiện tại, được tạo từ spec.
- `docs/stories/`: story packet và backlog được tạo từ công việc đã chọn.
- `docs/TEST_MATRIX.md`: bảng điều khiển từ hành vi tới bằng chứng.
- `docs/decisions/`: quyết định và đánh đổi bền vững.

Đừng giữ một spec hoặc phân rã sản phẩm riêng cho dự án trong harness này cho
đến khi một dự án thật cung cấp nó.

## Cấu Trúc Repository

```text
project/
  AGENTS.md
  README.md
  docs/
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

## Đóng Góp

Dự án còn sớm và hữu ích nhất khi nhận được các trường hợp lỗi agent ngoài thực
tế, ví dụ cài Harness, cải thiện tài liệu và các mẫu workflow có thể tái sử
dụng. Xem `CONTRIBUTING.md` để biết các ý tưởng đóng góp.

Các đóng góp hữu ích gồm:

- Chỉ ra harness hoạt động như thế nào trong một dự án thật.
- Thêm mẫu còn thiếu hoặc cải thiện mẫu hiện có.
- Đề xuất mẫu xác thực cho các stack khác nhau.
- Chia sẻ lỗi trong đó agent thay đổi sai vì repo thiếu ngữ cảnh.
- So sánh hành vi harness giữa Claude Code, Codex, Cursor và các công cụ khác.

## Chia Sẻ

Nếu ý tưởng này phù hợp, hãy star repo và chia sẻ với người đang xây dựng bằng
coding agent.

Mô tả ngắn:

> Một repo harness sẵn sàng cho agent dành cho Claude Code, Codex, Cursor và
> các coding agent khác: AGENTS.md, product contract, story packet, validation
> matrix và decision record.
