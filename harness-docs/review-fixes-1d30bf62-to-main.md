# Sửa lỗi Đánh giá (Review Fixes): 1d30bf62 to main

Base commit: `1d30bf62a30cd7e65ebcefed765b3f924d381b49`
Starting head commit: `fd8151968e7e0623ce76beadb2c41641268c0691`
Nhánh (Branch): `review/main-1d30bf62-to-fd81519`
Harness intake: `#34`

## Lượt Đánh giá 1 (Pass 1)

- Trạng thái (Status): các phát hiện đã được khắc phục; quá trình xác thực đang tiến hành.
- Lệnh chạy (Command): `codex review --base 1d30bf62a30cd7e65ebcefed765b3f924d381b49`
- Phát hiện (Findings):
  - P2: Lệnh `decision verify` chạy các lệnh được lưu trữ từ thư mục làm việc hiện tại (cwd) của người gọi thay vì từ thư mục gốc của kho lưu trữ Harness.
  - P3: Lệnh chèn dữ liệu intake của Rust lưu trữ các danh sách `--flags` và `--docs` bị thiếu dưới dạng chuỗi văn bản `"null"` thay vì lưu giá trị SQL `NULL`.
- Khắc phục (Fixes):
  - Thiết lập các lệnh xác thực quyết định chạy với thư mục làm việc hiện tại (cwd) là `self.repo_root`.
  - Lưu trữ các trường danh sách intake bị thiếu bằng `CsvList::as_json_text()` để thư viện rusqlite liên kết giá trị SQL `NULL`.
  - Thêm kiểm thử bao phủ chống thoái lui (regression coverage) cho cả hai hành vi trên.
  - Cập nhật bằng chứng xác thực của câu chuyện US-002 từ 9 lên 10 kiểm thử Rust.
- Xác thực (Validation):
  - Lệnh `cargo fmt --check`
  - Lệnh `cargo test --workspace` đã vượt qua với 10 bài kiểm thử.
  - Chạy riêng biệt các kiểm tra cú pháp `bash -n` cho các file `scripts/install-harness.sh`, `scripts/bin/harness-cli` và `scripts/build-harness-cli-release.sh`.
  - Lệnh `git diff --check`
  - Lệnh `scripts/bin/harness-cli query matrix`

## Lượt Đánh giá 2 (Pass 2)

- Trạng thái (Status): phát hiện đã được khắc phục; quá trình xác thực đang tiến hành.
- Lệnh chạy (Command): `codex review --base 1d30bf62a30cd7e65ebcefed765b3f924d381b49`
- Phát hiện (Findings):
  - P2: Tham số `--refresh-agent-shim` có thể ghi đè lên file `$BACKUP_DIR/AGENTS.md` hiện tại được tạo ra trước đó bởi tham số `--override` hoặc `--force`.
- Khắc phục (Fixes):
  - Cấu hình cho hàm `backup_agent_file` giữ nguyên bản sao lưu `AGENTS.md` hiện tại thay vì thay thế nó trong bước làm mới (refresh).
- Xác thực (Validation):
  - Thử nghiệm cài đặt tạm thời với cờ `--override --refresh-agent-shim --yes` đã giữ nguyên file `AGENTS.md` gốc trong thư mục `.harness-backup/.../AGENTS.md`.
  - Chạy riêng biệt các kiểm tra cú pháp `bash -n` cho các file `scripts/install-harness.sh`, `scripts/bin/harness-cli` và `scripts/build-harness-cli-release.sh`.
  - Lệnh `cargo fmt --check`
  - Lệnh `cargo test --workspace` đã vượt qua với 10 bài kiểm thử.
  - Lệnh `git diff --check`
  - Lệnh `scripts/bin/harness-cli query matrix`

## Lượt Đánh giá 3 (Pass 3)

- Trạng thái (Status): bị gián đoạn do giới hạn sử dụng của Codex.
- Lệnh chạy (Command): `codex review --base 1d30bf62a30cd7e65ebcefed765b3f924d381b49`
- Kết quả (Result): đánh giá không hoàn thành; Codex báo cáo đã đạt giới hạn sử dụng và đề xuất thử lại lúc 4:33 PM.
- Phát hiện (Findings): không có sẵn.
- Khắc phục (Fixes): không có.
- Xác thực (Validation): bằng chứng đánh giá cuối cùng không phát hiện lỗi (no-findings proof) vẫn đang chờ xử lý.

## Lượt Đánh giá 4 (Pass 4)

- Trạng thái (Status): phát hiện đã được khắc phục; quá trình xác thực đang tiến hành.
- Lệnh chạy (Command): `codex review --base 1d30bf62a30cd7e65ebcefed765b3f924d381b49`
- Phát hiện (Findings):
  - P2: Quá trình cài đặt với cờ `--merge` giữ nguyên các file Harness thông thường nhưng vẫn ghi đè lên tập tin nhị phân `scripts/bin/harness-cli` hiện tại khi không có cờ `--force`.
- Khắc phục (Fixes):
  - Cấu hình cho hàm `install_harness_cli_binary` bỏ qua tập tin nhị phân CLI đã tải xuống hiện tại trong chế độ merge (gộp) trừ khi cờ `--force` được cung cấp.
- Xác thực (Validation):
  - Thử nghiệm cài đặt tạm thời trên Harness hiện có với cờ `--merge --yes` đã giữ nguyên checksum và nội dung của `scripts/bin/harness-cli` gốc.
  - Chạy riêng biệt các kiểm tra cú pháp `bash -n` cho các file `scripts/install-harness.sh`, `scripts/bin/harness-cli` và `scripts/build-harness-cli-release.sh`.
  - Lệnh `cargo fmt --check`
  - Lệnh `cargo test --workspace` đã vượt qua với 10 bài kiểm thử.
  - Lệnh `git diff --check`
  - Lệnh `scripts/bin/harness-cli query matrix`

## Lượt Đánh giá 5 (Pass 5)

- Trạng thái (Status): các phát hiện đã được khắc phục; quá trình xác thực đang tiến hành.
- Lệnh chạy (Command): `codex review --base 1d30bf62a30cd7e65ebcefed765b3f924d381b49`
- Phát hiện (Findings):
  - P2: Các bản cài đặt từ mã nguồn (source-checkout) mặc định nguồn tải xuống CLI là thư mục cục bộ `dist/`, vốn được bỏ qua trong `.gitignore` và có thể vắng mặt trong một bản sao clone mới.
  - P3: Workflow phát hành sử dụng một lệnh gọi `bash -n` duy nhất cho ba đường dẫn kịch bản, việc này chỉ kiểm tra cú pháp của kịch bản đầu tiên.
- Khắc phục (Fixes):
  - Đặt giá trị mặc định cho `HARNESS_CLI_BASE_URL` là URL phát hành đã xuất bản ngay cả khi các file nguồn Harness là cục bộ; tiếp tục giữ các thư mục chứa artifact cục bộ khả dụng thông qua thiết lập rõ ràng `HARNESS_CLI_BASE_URL=file:///.../dist`.
  - Thay đổi workflow phát hành và tài liệu xác thực để chạy lệnh `bash -n` riêng biệt cho từng kịch bản shell.
  - Cập nhật chứng cứ lâu dài của story US-002 để đặt tên cho smoke test trình cài đặt từ mã nguồn và các kiểm tra cú pháp shell riêng biệt.
- Xác thực (Validation):
  - Thử nghiệm cài đặt từ mã nguồn đã thành công khi tạm thời di chuyển thư mục `dist/` cục bộ đi nơi khác; trình cài đặt tải xuống từ URL phát hành đã xuất bản và cài đặt thành công tập tin thực thi `scripts/bin/harness-cli`.
  - Chạy riêng biệt các kiểm tra cú pháp `bash -n` cho các file `scripts/install-harness.sh`, `scripts/bin/harness-cli` và `scripts/build-harness-cli-release.sh`.
  - Lệnh `cargo fmt --check`
  - Lệnh `cargo test --workspace` đã vượt qua với 10 bài kiểm thử.
  - Lệnh `git diff --check`
  - Lệnh `scripts/bin/harness-cli query matrix`

## Lượt Đánh giá 6 (Pass 6)

- Trạng thái (Status): đánh giá sạch sẽ, không có lỗi.
- Lệnh chạy (Command): `codex review --base 1d30bf62a30cd7e65ebcefed765b3f924d381b49`
- Kết quả (Result): không phát hiện lỗi thoái lui (regression).
- Ghi chú của người đánh giá: Rust CLI, các thay đổi của trình cài đặt và workflow phát hành tỏ ra nhất quán nội bộ, và các lệnh xác thực được thực thi trong quá trình đánh giá đều vượt qua.
- Khắc phục (Fixes): không có.
- Xác thực (Validation):
  - Chạy riêng biệt các kiểm tra cú pháp `bash -n` cho các file `scripts/install-harness.sh`, `scripts/bin/harness-cli` và `scripts/build-harness-cli-release.sh`.
  - Lệnh `cargo fmt --check`
  - Lệnh `cargo test --workspace` đã vượt qua với 10 bài kiểm thử.
  - Lệnh `git diff --check`
  - Lệnh `scripts/bin/harness-cli query matrix`
