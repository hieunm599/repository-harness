# repository-harness

Biến một kho lưu trữ phần mềm (software repository) thành một không gian làm việc rõ ràng, sẵn sàng cho Agent.

`repository-harness` cài đặt một giao thức repository nhỏ gọn và một trình nâng cấp an toàn.
Repository tiếp tục là hệ thống lưu trữ nguồn (system of record): tài liệu sản phẩm, quyết định, kế hoạch, mã nguồn, kiểm thử, CI và bằng chứng thời gian chạy (runtime evidence) sẽ định hình công việc.

Đây không phải là cơ sở dữ liệu nhiệm vụ (task database), công cụ theo dõi story, trình điều phối agent (agent orchestrator), hay môi trường chạy ứng dụng.

## Những gì nó giải quyết (What It Solves)

Các AI coding agent thường thất bại vì những lý do kỹ thuật thông thường:

- Ý định quan trọng chỉ tồn tại trong cuộc trò chuyện (chat);
- Repository không xác định được tài liệu mang tính thẩm quyền;
- Những thay đổi nhỏ phải gánh chịu quy trình không cần thiết;
- Những thay đổi dài hạn làm thất lạc các quyết định và bối cảnh phục hồi;
- Tuyên bố hoàn thành mà không có bằng chứng ở cấp độ hành vi; và
- Agent tự tạo ra chính sách sản phẩm khi yêu cầu để ngỏ một lựa chọn quan trọng.

Harness cung cấp một điểm đầu vào gọn nhẹ, bản đồ repository dễ định hướng, các kế hoạch bền vững chỉ khi công việc thực sự cần, các ranh giới đánh giá rõ ràng và xác thực cơ học.

## Luồng công việc Mặc định (Default Workflow)

```text
yêu cầu chỉ đọc (read-only)
  -> kiểm tra bề mặt có thẩm quyền nhỏ nhất
  -> trả lời kèm bằng chứng

thay đổi có phạm vi giới hạn (bounded change)
  -> kiểm tra thẩm quyền và hành vi bị ảnh hưởng
  -> triển khai thay đổi nhất quán nhỏ nhất
  -> chạy bằng chứng liên quan

thay đổi trải dài qua nhiều phiên hoặc cần phối hợp (multi-session / coordinated)
  -> tạo file harness-docs/plans/active/<plan>.md
  -> cập nhật liên tục các quyết định, tiến độ, phục hồi và xác thực
  -> di chuyển kế hoạch đã xác thực sang harness-docs/plans/completed/

mục đích sản phẩm mơ hồ (material product ambiguity)
  -> dừng lại trước khi chỉnh sửa (mutation)
  -> trình bày lựa chọn cụ thể và các hệ quả
```

Một lỗi chính tả không cần lập kế hoạch. Một đợt chuyển đổi (migration) kéo dài qua nhiều phiên thì cần. Một yêu cầu “thêm giới hạn tần suất (rate limit)” mà thiếu định ngạch, khóa định danh, đơn vị thực thi, cấu trúc trạng thái dùng chung hay hợp đồng phản hồi thì phải dừng lại trước khi triển khai.

Bắt đầu với [`AGENTS.md`](AGENTS.md), sau đó là [`harness-docs/WORKFLOW.md`](harness-docs/WORKFLOW.md).

## Những gì được Cài đặt (What Gets Installed)

Tập hợp lõi mặc định bao gồm:

- File điểm vào `AGENTS.md` gọn nhẹ;
- Luồng công việc repository và bản đồ tài liệu;
- Cấu trúc sản phẩm, quyết định và kế hoạch thực thi;
- Các mẫu tùy chọn cho kế hoạch bền vững, quyết định, ứng dụng runbook và cải tiến Harness dựa trên bằng chứng; và
- Các skill onboard và kiểm tra đề xuất (proposal-audit) chỉ kích hoạt khi được yêu cầu rõ ràng.

Nó không cài đặt kiến trúc ứng dụng, chính sách sản phẩm, lệnh xác thực, thông tin xác thực, cơ sở dữ liệu, schema, hệ thống điều phối hay các tiến trình chạy ngầm.

Danh sách chi tiết được khai báo trong [`scripts/harness-install-files.txt`](scripts/harness-install-files.txt).

## Cài đặt (Install)

Chạy từ kho lưu trữ mục tiêu:

```bash
curl -fsSL "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.sh?$(date +%s)" |
  bash -s -- --yes
```

Trên PowerShell:

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/hieunm599/repository-harness/vi/scripts/install-harness.ps1"))) -Yes
```

Sử dụng `--merge` / `-Merge` để giữ nguyên các file hiện có và chỉ thêm các đường dẫn Harness còn thiếu. Sử dụng `--override` / `-Override` chỉ khi việc ghi đè là cố ý. Sử dụng `--dry-run` / `-DryRun` để xem trước.

Quá trình bootstrap sẽ tải về binary `harness` có đánh số phiên bản cùng checksum, xác minh danh tính bản phát hành và giao việc cài đặt cho binary đó.

## Bảo trì Bản cài đặt (Maintain An Installation)

```bash
scripts/bin/harness status
scripts/bin/harness doctor
scripts/bin/harness update --dry-run
scripts/bin/harness update
```

Trình cập nhật lưu giữ chính xác gốc upstream dưới `.harness-core/`, thực hiện hợp nhất 3 chiều (three-way merge), sao lưu các file đã thay đổi và kích hoạt kết quả theo cách giao dịch (transactionally).

Nếu chỉnh sửa cục bộ và upstream chồng chéo nhau, không có file hoặc file thực thi được quản lý nào bị thay đổi. Harness sẽ giữ lại các bản sao BASE, LOCAL, UPSTREAM và RESOLVED cùng với tập hợp đầu vào được quản lý đóng băng. Sau khi con người giải quyết lựa chọn ngữ nghĩa:

```bash
scripts/bin/harness update --continue --dry-run
scripts/bin/harness update --continue
```

Sử dụng `scripts/bin/harness update --abort` để hủy bỏ phương án xử lý đã chuẩn bị.

## Skill Tùy chọn (Optional Skills)

Onboard repository là skill rõ ràng và chế độ chỉ đọc trước tiên:

```text
$onboard-repository
```

Cải tiến Harness cũng rõ ràng và yêu cầu bằng chứng so sánh trước và sau khi chạy:

```text
$improve-harness
```

Lời khuyên kỹ thuật (Engineering wisdom) là một gói tùy chọn riêng biệt:

```bash
scripts/install-harness.sh --with-engineering-wisdom --yes /path/to/project
```

Không có skill nào tự động chạy trong quá trình cài đặt hoặc công việc thông thường.

## Những gì chúng ta chứng minh (What We Prove)

Harness sở hữu ba ranh giới bằng chứng phát hành (release-evidence boundaries):

1. **Cài đặt mới:** phần lõi được khai báo được cài đặt mà không tự tạo sự thật ứng dụng giả mạo hay trạng thái vòng đời ẩn.
2. **Định hướng kho lưu trữ:** agent tuân theo thẩm quyền của repository, tránh các chính sách sản phẩm suy đoán, và có thể dừng lại tại ranh giới quyết định thực sự.
3. **Bảo trì an toàn:** các đợt cập nhật xác minh danh tính và checksum, bảo vệ các chỉnh sửa cục bộ, chuẩn bị xung đột, từ chối sự trôi dạt (drift) và phục hồi các giao dịch bị gián đoạn.

Việc vận hành ứng dụng end-to-end của người dùng vẫn thuộc về nghiên cứu của người dùng. Harness không tuyên bố rằng chỉ riêng việc cài đặt sẽ cung cấp các runtime, fixture, thông tin đăng nhập, log hay tự động hóa giao diện.

## Ngừng hỗ trợ Giao thức V1 (Protocol V1 End Of Life)

Hệ thống SQLite `harness-cli` cũ và giao thức máy (machine protocol) v1 đã kết thúc hỗ trợ vào ngày 2026-08-10. Bản phát hành tương thích cuối cùng được xuất bản là `harness-cli-v0.1.22`. Người dùng hiện tại có thể ghim bản phát hành bất biến đó, nhưng kho lưu trữ hiện tại không còn xây dựng, cài đặt, thử nghiệm hay xuất bản nó nữa.

Harness không tự động xóa các binary, cơ sở dữ liệu, schema hoặc trạng thái cũ khỏi repository người dùng.

Xem [`quyết định 0027`](harness-docs/decisions/0027-end-protocol-v1-and-focus-repository-protocol.md) (hoặc 0027 upstream).

## Phát triển (Development)

```bash
scripts/validate-premerge.sh
```

Hợp đồng này chạy định dạng Rust, tests, Clippy, kiểm tra installer và workflow, kiểm tra phát hành, kiểm tra tài liệu, cú pháp shell và `git diff --check`.
