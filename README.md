# repository-harness

Biến bất kỳ repo phần mềm nào thành một không gian làm việc dễ đọc và sẵn sàng cho agent (agent-ready workspace).

`repository-harness` cung cấp cho các coding agent một điểm vào nhỏ (small entrypoint), tri thức repository có cấu trúc, các kế hoạch thực thi lâu dài khi công việc thực sự cần đến chúng, và cơ chế xác thực tự động. Repository — chứ không phải một database workflow ẩn — là hệ thống lưu trữ nguồn mặc định (default system of record).

Ứng dụng (app) là thứ người dùng tương tác. Harness là thứ giúp ứng dụng và các quy tắc của nó trở nên dễ hiểu đối với các agent và con người.

## Tại sao điều này tồn tại

Các coding agent thường thất bại vì những lý do kỹ thuật thông thường:

- Các ràng buộc quan trọng chỉ nằm trong lịch sử chat hoặc trong đầu của ai đó;
- Repository không nêu rõ tài liệu nào là chính thức (authoritative);
- Các thay đổi nhỏ bị bao bọc trong quy trình phức tạp làm che khuất công việc thực sự;
- Các thay đổi lớn làm thất lạc các quyết định và tiến độ giữa các phiên làm việc;
- Mức độ xác thực mơ hồ, muộn màng hoặc bị tách rời khỏi hành vi mà người dùng nhìn thấy.

Câu trả lời không phải là một quy trình bắt buộc dài hơn. Đó là một repository hiển thị đúng ngữ cảnh vào đúng thời điểm và thực thi các bất biến quan trọng bằng các bài kiểm thử và script.

Hướng đi này được định hình dựa trên bài viết [Harness engineering](https://openai.com/index/harness-engineering/) của OpenAI: giữ điểm vào của agent nhỏ gọn, làm cho tri thức repository dễ điều hướng, lưu trữ các kế hoạch thực thi phức tạp một cách lâu dài, làm cho hành vi ứng dụng có thể kiểm tra trực tiếp và thực thi các quy tắc kiến trúc một cách tự động.

## Luồng công việc Mặc định (The Default Workflow)

Bắt đầu với [`AGENTS.md`](AGENTS.md), sau đó làm theo bản đồ trong [`harness-docs/WORKFLOW.md`](harness-docs/WORKFLOW.md). Kích thước của yêu cầu sẽ quyết định mức độ của quy trình:

```text
câu hỏi chỉ đọc (read-only)
  -> kiểm tra bề mặt tài liệu chính thức nhỏ nhất
  -> trả lời kèm theo bằng chứng

thay đổi có giới hạn (bounded change)
  -> kiểm tra cục bộ
  -> thay đổi code hoặc tài liệu
  -> chạy kiểm thử/bằng chứng liên quan
  -> báo cáo kết quả

thay đổi qua nhiều phiên hoặc cần nhiều sự phối hợp
  -> tạo harness-docs/plans/active/<plan>.md
  -> ghi lại tiến độ, quyết định và xác thực trong Git
  -> di chuyển kế hoạch hoàn thành sang harness-docs/plans/completed/

khi sự mơ hồ có hệ quả quan trọng
  -> tạm dừng trước khi chỉnh sửa
  -> trình bày lựa chọn cụ thể và tác động của nó
  -> tiếp tục sau khi quyền thẩm quyền (authority) đã rõ ràng
```

Một sửa lỗi chính tả không cần intake, story row hay trace. Một đợt chuyển đổi (migration) kéo dài qua nhiều phiên làm việc thì cần một kế hoạch lâu dài. Một yêu cầu "đơn giản hóa quyền truy cập" mà không nói rõ các quyền hiện tại có bị thu hồi hay không thì cần sự quyết định của con người trước khi sửa code. Đó là các quyết định độc lập, không phải các mức độ rủi ro trên một thang quy trình đơn lẻ.

## Tri thức Repository (Repository Knowledge)

- [`AGENTS.md`](AGENTS.md) — điểm vào nhỏ gọn, ổn định cho agent.
- [`harness-docs/WORKFLOW.md`](harness-docs/WORKFLOW.md) — luồng thực thi và yêu cầu chuẩn mực.
- [`harness-docs/HARNESS.md`](harness-docs/HARNESS.md) — các nguyên tắc thiết kế và mô hình hệ thống.
- [`harness-docs/ARCHITECTURE.md`](harness-docs/ARCHITECTURE.md) — ranh giới và hướng phụ thuộc.
- [`harness-docs/product/`](harness-docs/product/) — hành vi sản phẩm hiện tại và các ràng buộc.
- [`harness-docs/plans/`](harness-docs/plans/) — các kế hoạch thực thi lâu dài đang hoạt động và đã hoàn thành.
- [`harness-docs/decisions/`](harness-docs/decisions/) — các quyết định kiến trúc lâu dài.
- [`harness-docs/templates/exec-plan.md`](harness-docs/templates/exec-plan.md) — template cho kế hoạch.
- [`harness-docs/README.md`](harness-docs/README.md) — bản đồ tài liệu đầy đủ, bao gồm các bề mặt tương thích tùy chọn.
- [`tests/README.md`](tests/README.md) — quyền sở hữu hành vi, điểm vào xác thực và ranh giới xóa bỏ đối với các bộ kiểm thử.

Đường dẫn mặc định không yêu cầu database cục bộ. Tài liệu sản phẩm, mã nguồn, bài kiểm thử, kế hoạch, quyết định và lịch sử Git tạo thành một nguồn sự thật (source of truth) có thể kiểm tra được.

## Cài đặt Harness vào một Dự án

Từ thư mục của dự án mục tiêu, chạy lệnh Bash:

```bash
curl -fsSL "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh?$(date +%s)" | bash -s -- --yes
```

Trên Windows PowerShell, chạy:

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.ps1"))) -Yes
```

Sử dụng `--merge` / `-Merge` để thêm các file Harness còn thiếu mà không thay thế các file dự án hiện tại. Chỉ sử dụng `--override` / `-Override` khi việc thay thế là cố ý. Sử dụng `--dry-run` / `-DryRun` để xem trước các thay đổi.

Bản cài đặt mặc định tải xuống binary Rust đã được kiểm tra mã checksum có tên `harness`, sau đó dùng nó để cài đặt phần core nhỏ tập trung vào repository. Nó không cài đặt CLI tương thích SQLite tùy chọn, không phát hiện schema, không cài đặt script bootstrap database, và không thêm các quy tắc gitignore cho database. Core bao gồm các skill `$onboard-repository` và `$audit-onboarding-proposal` (chỉ chạy khi được gọi rõ ràng).

Để ánh xạ một repository hiện có (brownfield) sau khi cài đặt, hãy yêu cầu agent chạy:

```text
$onboard-repository
```

Lượt chạy đầu tiên là chỉ đọc (read-only) và trả về các đề xuất dựa trên bằng chứng. Cần có sự đồng ý chính xác của người dùng trước khi lượt chạy sau áp dụng các hướng dẫn đã chọn.

## Gói Tri thức Kỹ thuật Tùy chọn (Optional Engineering Wisdom)

Cài đặt mặc định trung lập không đi kèm triết lý kỹ thuật. Để thêm gói tư vấn `engineering-wisdom` (chỉ chạy khi gọi rõ ràng) vào một dự án mới:

```bash
curl -fsSL "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh?$(date +%s)" | bash -s -- --with-engineering-wisdom --yes /path/to/project
```

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.ps1"))) -WithEngineeringWisdom -Yes -Directory C:\path\to\project
```

Đối với dự án đã có Harness, thêm `--merge` / `-Merge`:

```bash
curl -fsSL "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh?$(date +%s)" | bash -s -- --merge --with-engineering-wisdom --yes
```

Việc cài đặt không chạy hoặc kích hoạt skill. Gọi nó một cách rõ ràng khi cần:

```text
$engineering-wisdom đánh giá thay đổi thanh toán này
```

Sau khi cài đặt, xem trước và áp dụng các bản nâng cấp core trong tương lai với:

```bash
scripts/bin/harness update --dry-run
scripts/bin/harness update
scripts/bin/harness status
scripts/bin/harness doctor
```

Trên Windows, sử dụng `scripts\bin\harness.exe`.

Nếu bạn sử dụng Claude Code, hãy thêm `--claude` (PowerShell: `-Claude`). Cờ này tạo hoặc cập nhật một khối được đánh dấu trong `CLAUDE.md` giúp import `AGENTS.md`.

## Trải nghiệm Luồng công việc (Try The Flow)

[`harness-docs/demo/README.md`](harness-docs/demo/README.md) cung cấp các ví dụ cụ thể qua bốn trường hợp luồng công việc:

- điểm vào nhỏ → ít tải lại hướng dẫn và ít bị lệch hướng;
- bản đồ repository chính thức → agent chỉ truy xuất ngữ cảnh liên quan;
- kế hoạch chỉ cho công việc thực sự lâu dài → các thay đổi nhỏ giữ chi phí thấp trong khi công việc dài hạn tồn tại qua các phiên;
- bài kiểm thử nguyên bản trong repo → sự hoàn thành được chứng minh bằng hành vi chứ không phải bằng ghi chép quy trình;
- điều kiện tạm dừng rõ ràng → các lựa chọn sản phẩm có hệ quả vẫn do con người làm chủ.

## Tầng Điều khiển Tương thích Tùy chọn (Optional Compatibility Control Plane)

Rust CLI, schema SQLite, tiếp nhận tính năng (feature intake), story matrix, trace scoring, đề xuất cải tiến và contract điều phối tiếp tục được hỗ trợ cho các runner bên ngoài hoặc đội ngũ lựa chọn chúng.

Cài đặt gói tương thích đầy đủ này một cách rõ ràng:

```bash
curl -fsSL "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh?$(date +%s)" | bash -s -- --with-cli --yes /path/to/project
```

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.ps1"))) -WithCli -Yes -Directory C:\path\to\project
```

Sau đó bootstrap database cục bộ:

```bash
scripts/bootstrap-harness.sh
```

```powershell
.\scripts\bootstrap-harness.ps1
```

Một consumer độc lập là [Symphony](https://github.com/hoangnb24/symphony); nó không được cài đặt như một phần của repository này.

## Cấu trúc Kho lưu trữ (Repository Structure)

```text
project/
  .agents/
    skills/
      onboard-repository/
      audit-onboarding-proposal/
  AGENTS.md
  README.md
  harness-docs/
    WORKFLOW.md
    HARNESS.md
    ARCHITECTURE.md
    product/
    plans/
      active/
      completed/
    decisions/
    templates/
  scripts/
  tests/
```

## Đóng góp (Contributing)

Xem [hướng dẫn đóng góp](https://github.com/hieunm599/repository-harness/blob/vi/CONTRIBUTING.md). Các đóng góp đặc biệt hữu ích bao gồm các trường hợp lỗi thực tế của agent, ví dụ về tính dễ đọc của ứng dụng (application legibility), kiểm tra kiến trúc tự động, hướng dẫn mặc định nhỏ hơn và xác thực chứng minh hành vi người dùng nhìn thấy.

## Chia sẻ (Share)

Mô tả ngắn:

> Một harness kỹ thuật tập trung vào repository dành cho các coding agent: hướng dẫn nhỏ gọn, ngữ cảnh dễ điều hướng, kế hoạch lâu dài khi cần, các quyết định và cơ chế xác thực thực thi được.
