# Các Quy tắc Kỹ thuật Ngữ cảnh (Context Engineering Rules)

Các quy tắc ngữ cảnh (context rules) giúp agent quyết định tài liệu nào cần đọc, khi nào nên đọc và khi nào nên dừng đọc. Chúng bổ sung cho danh sách tài liệu cần đọc ổn định trong file `AGENTS.md`.

Mục tiêu không phải là tối đa hóa ngữ cảnh. Mục tiêu là đưa thông tin phù hợp vào mô hình cho giai đoạn nhiệm vụ (task phase) và làn rủi ro (risk lane) hiện tại.

## Các Giai đoạn Ngữ cảnh (Context Phases)

### Giai đoạn Tiếp nhận (Intake Phase)

Đọc để phân loại yêu cầu, tìm bề mặt bị ảnh hưởng và chọn làn rủi ro (lane).

| Tài liệu hoặc Nguồn | Nhỏ (Tiny) | Bình thường (Normal) | Rủi ro cao (High-Risk) |
| --- | --- | --- | --- |
| `AGENTS.md` | Bắt buộc (Must) | Bắt buộc (Must) | Bắt buộc (Must) |
| `harness-docs/FEATURE_INTAKE.md` | Bắt buộc (Must) | Bắt buộc (Must) | Bắt buộc (Must) |
| `scripts/bin/harness-cli query matrix` | Bắt buộc (Must) | Bắt buộc (Must) | Bắt buộc (Must) |
| `README.md` | Nên (Should) | Bắt buộc (Must) | Bắt buộc (Must) |
| `harness-docs/HARNESS.md` | Nên (Should) | Bắt buộc (Must) | Bắt buộc (Must) |
| `harness-docs/ARCHITECTURE.md` | Bỏ qua (Skip) | Nên (Should) | Bắt buộc (Must) |
| `harness-docs/product/*` liên quan | Bỏ qua nếu không liên quan | Bắt buộc nếu hành vi sản phẩm thay đổi | Bắt buộc (Must) |
| `harness-docs/stories/*` liên quan | Bỏ qua nếu không liên quan | Bắt buộc nếu tồn tại story | Bắt buộc (Must) |
| `harness-docs/decisions/*` liên quan | Bỏ qua (Skip) | Nên nếu chạm đến kiến trúc hoặc quy tắc lâu dài | Bắt buộc (Must) |
| `harness-docs/HARNESS_COMPONENTS.md` | Bỏ qua (Skip) | Nên đối với cải tiến Harness | Bắt buộc đối với công việc về khả năng quan sát hoặc benchmark |

### Giai đoạn Lên kế hoạch (Planning Phase)

Đọc để quyết định phương pháp tiếp cận an toàn nhỏ nhất và bằng chứng xác thực (proof) dự kiến.

| Tài liệu hoặc Nguồn | Nhỏ (Tiny) | Bình thường (Normal) | Rủi ro cao (High-Risk) |
| --- | --- | --- | --- |
| Các file hiện tại cần chỉnh sửa | Bắt buộc (Must) | Bắt buộc (Must) | Bắt buộc (Must) |
| `harness-docs/templates/story.md` | Bỏ qua (Skip) | Bắt buộc khi tạo/cập nhật một story | Nên (Should) |
| `harness-docs/templates/high-risk-story/*` | Bỏ qua (Skip) | Bỏ qua trừ khi rủi ro leo thang | Bắt buộc (Must) |
| `harness-docs/ARCHITECTURE.md` | Bỏ qua (Skip) | Nên đối với các thay đổi về mã nguồn hoặc ranh giới | Bắt buộc (Must) |
| `harness-docs/TEST_MATRIX.md` hoặc `scripts/bin/harness-cli query matrix` | Nên (Should) | Bắt buộc (Must) | Bắt buộc (Must) |
| Các quyết định kỹ thuật liên quan | Bỏ qua (Skip) | Nên (Should) | Bắt buộc (Must) |
| `harness-docs/HARNESS_MATURITY.md` | Bỏ qua (Skip) | Nên đối với cải tiến Harness | Bắt buộc đối với các thay đổi về độ hoàn thiện hoặc quy trình |
| `harness-docs/HARNESS_BACKLOG.md` và `scripts/bin/harness-cli query backlog` | Bỏ qua (Skip) | Nên nếu độ ma sát (friction) lặp lại | Bắt buộc nếu thay đổi hành vi Harness |

### Giai đoạn Triển khai (Implementation Phase)

Đọc trong khi thực hiện thay đổi. Giới hạn giai đoạn này trong các file ảnh hưởng trực tiếp đến story đã chọn.

| Tài liệu hoặc Nguồn | Nhỏ (Tiny) | Bình thường (Normal) | Rủi ro cao (High-Risk) |
| --- | --- | --- | --- |
| Các file đang được thay đổi | Bắt buộc (Must) | Bắt buộc (Must) | Bắt buộc (Must) |
| Các file liền kề có cùng mẫu thiết kế | Nên (Should) | Bắt buộc (Must) | Bắt buộc (Must) |
| Tài liệu sản phẩm liên quan | Bỏ qua nếu chỉ sao chép nội dung | Bắt buộc nếu hành vi thay đổi | Bắt buộc (Must) |
| Gói story packet liên quan | Bỏ qua nếu không cần story | Bắt buộc (Must) | Bắt buộc (Must) |
| Các template liên quan | Bỏ qua (Skip) | Nên khi thêm tài liệu | Bắt buộc (Must) |
| `harness-docs/ARCHITECTURE.md` | Bỏ qua (Skip) | Nên đối với các thay đổi về mặt cấu trúc | Bắt buộc (Must) |
| Tài liệu của Provider/API/bảo mật | Bỏ qua (Skip) | Nên nếu bị ảnh hưởng | Bắt buộc (Must) |
| Tài liệu không liên quan và trace lịch sử | Bỏ qua (Skip) | Bỏ qua (Skip) | Chỉ nên nếu chúng ảnh hưởng đến các quyết định kỹ thuật |

### Giai đoạn Xác thực (Validation Phase)

Đọc để chứng minh sự thay đổi và tránh tuyên bố hoàn thành không có căn cứ.

| Tài liệu hoặc Nguồn | Nhỏ (Tiny) | Bình thường (Normal) | Rủi ro cao (High-Risk) |
| --- | --- | --- | --- |
| Tiêu chí nghiệm thu của Story | Nên (Should) | Bắt buộc (Must) | Bắt buộc (Must) |
| `harness-docs/TEST_MATRIX.md` hoặc `scripts/bin/harness-cli query matrix` | Nên (Should) | Bắt buộc (Must) | Bắt buộc (Must) |
| Phần xác thực của gói story packet | Bỏ qua nếu không có story | Bắt buộc (Must) | Bắt buộc (Must) |
| `harness-docs/templates/validation-report.md` | Bỏ qua (Skip) | Nên đối với bằng chứng đáng chú ý | Bắt buộc đối với bằng chứng rủi ro cao |
| Các lệnh liên quan từ README/tài liệu package | Nên (Should) | Bắt buộc (Must) | Bắt buộc (Must) |
| Giao thức benchmark hoặc repo benchmark bên ngoài | Bỏ qua (Skip) | Bỏ qua trừ khi có yêu cầu | Bắt buộc nếu story phụ thuộc vào bằng chứng benchmark |
| `harness-docs/HARNESS_MATURITY.md` | Bỏ qua (Skip) | Nên đối với cải tiến Harness | Bắt buộc đối với tuyên bố về độ hoàn thiện |

### Giai đoạn Dấu vết (Trace Phase)

Đọc để để lại bằng chứng hữu ích cho agent tiếp theo và để chấm điểm benchmark.

| Tài liệu hoặc Nguồn | Nhỏ (Tiny) | Bình thường (Normal) | Rủi ro cao (High-Risk) |
| --- | --- | --- | --- |
| `harness-docs/TRACE_SPEC.md` | Nên (Should) | Bắt buộc (Must) | Bắt buộc (Must) |
| `scripts/bin/harness-cli query matrix` | Nên (Should) | Bắt buộc (Must) | Bắt buộc (Must) |
| `scripts/bin/harness-cli query backlog` | Bỏ qua (Skip) | Nên nếu xảy ra ma sát | Bắt buộc (Must) |
| Danh sách các file thay đổi từ `git status --short` | Bắt buộc (Must) | Bắt buộc (Must) | Bắt buộc (Must) |
| Đầu ra của lệnh xác thực | Nên (Should) | Bắt buộc (Must) | Bắt buộc (Must) |
| Gói story packet hoặc nhật ký tiến trình | Bỏ qua nếu không có story | Bắt buộc (Must) | Bắt buộc (Must) |
| `harness-docs/HARNESS_COMPONENTS.md` | Bỏ qua (Skip) | Nên nếu quy cho độ ma sát | Bắt buộc nếu cần quy trách nhiệm lỗi |

## Các Bộ kích hoạt Truy xuất (Retrieval Triggers)

| Điều kiện Kích hoạt | Hành động |
| --- | --- |
| Nhiệm vụ liên quan đến lược đồ cơ sở dữ liệu (database schema), bản ghi bền vững hoặc migration | Đọc `harness-docs/decisions/0004-sqlite-durable-layer.md`, `scripts/schema/` và mã nguồn CLI liên quan trước khi lên kế hoạch. |
| Nhiệm vụ liên quan đến hành vi lệnh CLI hoặc phân phối trình cài đặt (installer) | Đọc `harness-docs/decisions/0005-prebuilt-rust-harness-cli.md`, `scripts/README.md`, mã nguồn `crates/harness-cli/*` liên quan, đầu ra trợ giúp của CLI và tài liệu trình cài đặt. |
| Nhiệm vụ liên quan đến xác thực (auth), phân quyền (authorization), kiểm toán/bảo mật, mất mát dữ liệu hoặc nhà cung cấp bên ngoài | Coi như rủi ro cao, đọc `harness-docs/templates/high-risk-story/*` và kiểm tra các quyết định trước đó trước khi triển khai. |
| Nhiệm vụ thay đổi cấu trúc API công khai, hành vi sản phẩm hoặc luồng công việc hiển thị với người dùng | Đọc các file `harness-docs/product/*` liên quan, các story packet và kỳ vọng xác thực trước khi chỉnh sửa. |
| Nhiệm vụ thay đổi chính sách Harness, phân cấp nguồn, phân loại rủi ro hoặc yêu cầu xác thực | Đọc `harness-docs/HARNESS.md`, `harness-docs/FEATURE_INTAKE.md`, `harness-docs/ARCHITECTURE.md` và `harness-docs/decisions/*`; tạm dừng nếu hướng đi mơ hồ. |
| Nhiệm vụ phát hiện sự mơ hồ lặp lại, tài liệu cũ hoặc thiếu bằng chứng xác thực | Đọc `harness-docs/HARNESS_BACKLOG.md`, ghi lại `harness_friction` và thêm một mục backlog khi việc sửa lỗi nằm ngoài phạm vi. |
| Nhiệm vụ đưa ra tuyên bố về độ hoàn thiện (maturity), khả năng quan sát (observability), chất lượng trace hoặc benchmark | Đọc `harness-docs/HARNESS_COMPONENTS.md`, `harness-docs/HARNESS_MATURITY.md` và `harness-docs/TRACE_SPEC.md`. |
| Nhiệm vụ có rủi ro bình thường hoặc cao và kéo dài qua nhiều lần lặp (iteration) | Tạo hoặc cập nhật một file story/tiến trình trong thư mục `harness-docs/stories/` và cập nhật nó thường xuyên. |
| Phản hồi cuối cùng đang được chuẩn bị | Đọc lại bằng chứng xác thực, lệnh `git status --short` và `harness-docs/TRACE_SPEC.md` trước khi ghi lại trace cuối cùng. |

## Hướng dẫn Ngân sách Token (Token Budget Guidance)

| Làn rủi ro | Ngân sách Ngữ cảnh Mục tiêu | Cấu trúc Đọc (Read Shape) | Lý do |
| --- | --- | --- | --- |
| Nhỏ (Tiny) | Khoảng 2K token ngữ cảnh Harness | `AGENTS.md`, `harness-docs/FEATURE_INTAKE.md`, truy vấn ma trận và chính xác file đang được thay đổi. | Công việc nhỏ không nên tiêu tốn nhiều ngữ cảnh cho chính sách hơn là cho việc chỉnh sửa code thực tế. |
| Bình thường (Normal) | Khoảng 5K token ngữ cảnh Harness | Tài liệu intake, tài liệu sản phẩm/story liên quan, tài liệu kiến trúc khi liên quan đến cấu trúc, kỳ vọng xác thực và đặc tả trace ở cuối. | Công việc bình thường cần đủ ngữ cảnh để bảo toàn các ràng buộc và ghi lại bằng chứng xác thực mà không cần đọc mọi file lịch sử. |
| Rủi ro cao (High-risk) | Khoảng 10K token ngữ cảnh Harness | Đầy đủ tài liệu intake, tài liệu kiến trúc, các quyết định liên quan, template rủi ro cao, tài liệu sản phẩm, tài liệu xác thực, đặc tả trace, tài liệu thành phần/độ hoàn thiện khi hành vi Harness thay đổi. | Công việc rủi ro cao cần phân cấp nguồn, các quyết định trước đó và kỳ vọng bằng chứng xác thực trong ngữ cảnh trước khi triển khai. |

Quy tắc ngân sách:

- Ưu tiên tìm kiếm mục tiêu bằng `rg` hơn là đọc hàng loạt.
- Đọc phần nhỏ nhất trả lời cho câu hỏi của giai đoạn hiện tại.
- Leo thang ngữ cảnh khi bộ kích hoạt truy xuất hoạt động.
- Không tiếp tục đọc lịch sử không liên quan sau khi làn rủi ro, các file bị ảnh hưởng và đường dẫn xác thực đã rõ ràng.

## Hành vi Bổ trợ (Additive Behavior)

Các quy tắc này không thay thế `AGENTS.md`. Agent vẫn nên đọc các tài liệu điểm vào ổn định được liệt kê ở đó trước khi làm việc. Tài liệu này giải thích những gì cần truy xuất sau ngữ cảnh ban đầu đó, dựa trên làn rủi ro, giai đoạn và bộ kích hoạt.

## Danh sách Kiểm tra (Review Checklist)

Trước khi triển khai:

- Làn rủi ro (lane) được chọn từ `harness-docs/FEATURE_INTAKE.md`.
- Tài liệu sản phẩm hoặc các story packet liên quan được xác định.
- Bất kỳ bộ kích hoạt rủi ro cao nào đã được xử lý.

Trước phản hồi cuối cùng:

- Bằng chứng xác thực (validation evidence) đã được đọc.
- Tài liệu `harness-docs/TRACE_SPEC.md` đã được đọc đối với các nhiệm vụ bình thường/rủi ro cao.
- Trace cuối cùng bao gồm các file đã đọc, các file đã thay đổi, kết quả và độ ma sát nếu có.
