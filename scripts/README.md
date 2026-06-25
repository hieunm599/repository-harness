# Các Kịch bản Tự động hóa (Scripts)

Thư mục này chứa các công cụ tự động hóa của harness.

## Harness CLI

Rust Harness CLI là giao diện chính cho lớp lưu trữ bền vững (durable layer). Các dự án đã cài đặt sẽ sử dụng tập phân nhị phân biên dịch sẵn (prebuilt binary) tại `scripts/bin/harness-cli` trên macOS/Linux hoặc `scripts/bin/harness-cli.exe` trên Windows cho các công việc Harness thông thường.

```bash
scripts/bin/harness-cli init          # Tạo cơ sở dữ liệu
scripts/bin/harness-cli intake ...    # Ghi nhận phân loại tiếp nhận tính năng (feature intake classification)
scripts/bin/harness-cli story ...     # Thêm hoặc cập nhật một story (một dòng trong ma trận kiểm thử)
scripts/bin/harness-cli story update --id US-001 --unit 1 --integration 1 --e2e 0 --platform 0
scripts/bin/harness-cli story verify US-001  # Chạy lệnh verify_command của story
scripts/bin/harness-cli decision ...  # Thêm quyết định kỹ thuật hoặc chạy xác thực quyết định đó
scripts/bin/harness-cli backlog ...   # Thêm hoặc đóng một mục backlog
scripts/bin/harness-cli trace ...     # Ghi lại và tự động chấm điểm dấu vết thực thi (execution trace) của agent
scripts/bin/harness-cli score-trace   # Chấm điểm trace theo các cấp độ trong file TRACE_SPEC.md
scripts/bin/harness-cli query ...     # Truy vấn dữ liệu harness, bao gồm cả backlog --open/--closed
scripts/bin/harness-cli query matrix --numeric  # Hiển thị các cờ bằng chứng dưới dạng 1/0
scripts/bin/harness-cli migrate       # Áp dụng các migration lược đồ (schema migration) đang chờ xử lý
scripts/bin/harness-cli --version     # In ra phiên bản CLI đã cài đặt
```

Chạy `scripts/bin/harness-cli help` hoặc `scripts/bin/harness-cli query help` để xem hướng dẫn sử dụng đầy đủ. Trên Windows, sử dụng các lệnh tương tự thông qua `.\scripts\bin\harness-cli.exe`.

Các cờ bằng chứng (proof flags) trên `story update` là các giá trị boolean dạng số: sử dụng `1` cho "yes" và `0` cho "no". Lệnh `story verify <id>` chạy lệnh `verify_command` được cấu hình; lệnh này không chấp nhận các cờ bằng chứng. Cấu hình lệnh bằng `story add/update --verify`, chạy lệnh `story verify <id>`, sau đó cập nhật các cờ bằng chứng bằng lệnh `story update`.

Tham số độ rủi ro `--risk` của backlog sử dụng các làn (lane) của Harness, không sử dụng các từ chỉ mức độ nghiêm trọng: sử dụng `tiny`, `normal` hoặc `high-risk`. Sử dụng `tiny` thay vì `low`. Lệnh `query matrix` mặc định hiển thị dạng dễ đọc `yes`/`no`; sử dụng `query matrix --numeric` khi sao chép các giá trị vào lệnh `story update`.

Lược đồ cơ sở dữ liệu (schema) nằm trong thư mục `scripts/schema/` và được quản lý phiên bản. Tập tin cơ sở dữ liệu (`harness.db`) đã được đưa vào `.gitignore`.

Yêu cầu: Có sẵn Rust CLI được biên dịch sẵn tại `scripts/bin/harness-cli` trên macOS/Linux hoặc `scripts/bin/harness-cli.exe` trên Windows.

Việc kiểm tra cơ sở dữ liệu trực tiếp vẫn có thể sử dụng các công cụ SQLite, nhưng việc sử dụng Harness thông thường nên đi qua Rust CLI.

### Các Lệnh của Rust CLI

Các lệnh đã được migrate hiện tại:

```bash
scripts/bin/harness-cli init
scripts/bin/harness-cli migrate
scripts/bin/harness-cli import brownfield
scripts/bin/harness-cli intake ...
scripts/bin/harness-cli story add ...
scripts/bin/harness-cli story update ...
scripts/bin/harness-cli story verify ...
scripts/bin/harness-cli decision add ...
scripts/bin/harness-cli decision verify ...
scripts/bin/harness-cli backlog add ...
scripts/bin/harness-cli backlog close ...
scripts/bin/harness-cli trace ...
scripts/bin/harness-cli score-trace
scripts/bin/harness-cli query matrix
scripts/bin/harness-cli query backlog
scripts/bin/harness-cli query decisions
scripts/bin/harness-cli query intakes
scripts/bin/harness-cli query traces
scripts/bin/harness-cli query friction
scripts/bin/harness-cli query stats
scripts/bin/harness-cli query sql ...
```

Lệnh `scripts/bin/harness-cli import brownfield` gieo mầm (seed) hoặc làm mới cơ sở dữ liệu bền vững từ các tài liệu Markdown Harness v0 hiện có trong `docs/TEST_MATRIX.md`, `docs/decisions/` và `docs/HARNESS_BACKLOG.md`. Điều này giúp các kho lưu trữ đã cài đặt Harness tiếp tục sử dụng Rust CLI mà không làm mất các tài liệu vận hành đã có.

## Trình cài đặt (Installer)

Trình cài đặt thượng nguồn áp dụng các file vận hành và cấu trúc thư mục Harness v0 cho một thư mục dự án mục tiêu. Nó mặc định là thư mục hiện tại, chấp nhận một đường dẫn đích và hỏi người dùng tương tác xem có muốn thực hiện `1. Merge`, `2. Override` hoặc `3. Stop` khi thư mục đích đã chứa `AGENTS.md`, `docs/` hoặc `scripts/`.

Các bản cài đặt không tương tác (non-interactive) sẽ dừng lại ở các đường dẫn được bảo vệ đó trừ khi tùy chọn `--merge` hoặc `--override` được cung cấp. Sử dụng `--merge` như một đường dẫn cập nhật an toàn cho các kho lưu trữ đã có Harness: nó giữ nguyên các file hiện tại và chỉ tạo các file Harness còn thiếu. Thêm `--refresh-agent-shim` khi bản cài đặt cũ có tài liệu hướng dẫn Harness đầy đủ trong file `AGENTS.md` và cần chuyển sang shim nhỏ ổn định. Chỉ sử dụng `--override` khi việc thay thế bề mặt Harness được bảo vệ là có chủ ý.

```bash
curl -fsSL "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh?$(date +%s)" | bash -s -- --yes
```

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.ps1"))) -Yes
```

```bash
# Cập nhật một repo Harness hiện tại mà không di chuyển các file hiện có
curl -fsSL "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh?$(date +%s)" | bash -s -- --merge --yes
```

```powershell
# Cập nhật một repo Harness hiện tại mà không di chuyển các file hiện có
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.ps1"))) -Merge -Yes
```

```bash
# Cập nhật repo và làm mới agent shim
curl -fsSL "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh?$(date +%s)" | bash -s -- --merge --refresh-agent-shim --yes
```

```powershell
# Cập nhật repo và làm mới agent shim
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.ps1"))) -Merge -RefreshAgentShim -Yes
```

Tùy chọn `--refresh-agent-shim` sẽ sao lưu file `AGENTS.md` trước khi thay đổi nó. Nếu file hiện tại được nhận diện là tài liệu hướng dẫn cũ do Harness tạo ra, trình cài đặt sẽ thay thế nó bằng shim hiện tại. Ngược lại, nó chỉ thêm hoặc thay thế khối `<!-- HARNESS:BEGIN -->` được đánh dấu để các hướng dẫn cụ thể của dự án được giữ nguyên.

Trình cài đặt phải được giới hạn trong phạm vi các file harness. Không sử dụng nó để dựng cấu trúc (scaffold) các thư mục mã nguồn ứng dụng, package script, cấu hình CI, kiểm thử, shell nền tảng hoặc các lệnh xác thực giả. Kịch bản cài đặt không phải là một phần của gói tải trọng (payload) được cài đặt trong dự án.

Theo mặc định, trình cài đặt cũng tải xuống Rust Harness CLI biên dịch sẵn cho nền tảng hiện tại vào `scripts/bin/harness-cli` trên macOS/Linux hoặc `scripts/bin/harness-cli.exe` trên Windows, sau đó kiểm tra mã checksum `.sha256` của nó. Một nhánh nguồn có thể ghim (pin) phiên bản phát hành được trình cài đặt sử dụng thông qua `scripts/harness-cli-release-tag`; Phase 3 ghim phiên bản `harness-cli-v0.1.4` để các lượt cài đặt từ nhánh này nhận được CLI được build từ Phase 3. Thiết lập biến môi trường `HARNESS_CLI_RELEASE_TAG` để ghi đè thẻ đó hoặc thiết lập `HARNESS_CLI_BASE_URL` để trỏ đến một thư mục artifact thay thế, ví dụ như thư mục cục bộ `file:///.../dist` được tạo bởi kịch bản `scripts/build-harness-cli-release.sh`.

## Di chuyển Lược đồ Cơ sở Dữ liệu (Schema Migrations)

Các file migration nằm trong thư mục `scripts/schema/` và được đặt tên theo định dạng `NNN-description.sql` với `NNN` là số phiên bản được điền thêm số 0 ở trước. Chạy lệnh `scripts/bin/harness-cli migrate` để áp dụng các migration đang chờ xử lý.

## Ràng buộc Lệnh trong Tương lai (Future Command Contract)

Các kiểm tra dự kiến trong tương lai:

```text
validate:quick
  format, lint, typecheck, unit tests, kiểm tra kiến trúc (architecture check)

test:integration
  kiểm tra tích hợp và ràng buộc backend (backend contract)

test:e2e
  các luồng end-to-end hiển thị với người dùng

test:platform
  kiểm tra nhanh (smoke check) shell nền tảng, nếu dự án có native shell

test:release
  toàn bộ suite kiểm thử, kiểm tra log và đo hiệu năng sơ bộ (performance smoke)
```

## Đóng gói Phát hành (Release Packaging)

Biên dịch artifact phát hành Rust CLI cho nền tảng hiện tại từ repo nguồn:

```bash
scripts/build-harness-cli-release.sh
```

Kịch bản này sẽ ghi kết quả vào thư mục `dist/harness-cli-<platform>` kèm theo checksum `.sha256`. Artifact của Windows bao gồm hậu tố `.exe`. Các nhãn nền tảng được hỗ trợ là:

- `macos-arm64`
- `macos-x64`
- `linux-x64`
- `linux-arm64`
- `windows-x64`

Để biên dịch chéo (cross-compilation), truyền thêm một Cargo target triple:

```bash
scripts/build-harness-cli-release.sh --target x86_64-unknown-linux-gnu
```

Các bản phát hành GitHub được tạo bởi workflow `.github/workflows/harness-cli-release.yml`. Đẩy một tag khớp với `v*` hoặc `harness-cli-v*` để chạy job xác thực, build tất cả các target được hỗ trợ trên các hosted runner native và tải lên các release asset này:

- `harness-cli-macos-arm64`
- `harness-cli-macos-arm64.sha256`
- `harness-cli-macos-x64`
- `harness-cli-macos-x64.sha256`
- `harness-cli-linux-x64`
- `harness-cli-linux-x64.sha256`
- `harness-cli-linux-arm64`
- `harness-cli-linux-arm64.sha256`
- `harness-cli-windows-x64.exe`
- `harness-cli-windows-x64.exe.sha256`

Các PR đã merge được xử lý bởi workflow `.github/workflows/post-merge-maintenance.yml`. Workflow này luôn thêm tóm tắt PR vào file `CHANGELOG.md`. Nếu PR được merge có thay đổi thư mục `crates/harness-cli/`, `scripts/schema/`, Cargo metadata hoặc kịch bản `scripts/build-harness-cli-release.sh`, nó cũng sẽ tăng phiên bản patch của CLI, cập nhật `scripts/harness-cli-release-tag`, tạo một tag `harness-cli-v*` tương ứng và gọi workflow phát hành Harness CLI có thể tái sử dụng cho ref được gắn tag đó.
