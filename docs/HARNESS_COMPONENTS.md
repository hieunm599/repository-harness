# Các Thành phần Harness (Harness Components)

Hệ thống phân loại (taxonomy) này ánh xạ kho lưu trữ `repository-harness` hiện tại vào hai component framework (khung thành phần) được Phase 2 sử dụng và được cập nhật bởi công việc về khả năng quan sát chủ động (active observability) của Phase 3:

- Các trách nhiệm của Runtime Substrate: 11 vùng trách nhiệm mà harness nên bao phủ.
- Sự phân rã NexAU (NexAU decomposition): bảy bề mặt triển khai ảnh hưởng đến hành vi của agent.

Các giá trị trạng thái (Status values):

- **Đã bao phủ (Covered)**: kho lưu trữ có một file, lệnh hoặc bản ghi rõ ràng cho trách nhiệm này.
- **Một phần (Partial)**: kho lưu trữ có hỗ trợ một phần, nhưng việc hỗ trợ này chưa đầy đủ, còn làm thủ công hoặc chưa được đo lường.
- **Còn thiếu (Missing)**: chưa có sự hỗ trợ đáng kể nào tồn tại.

## Bản đồ Trách nhiệm (Responsibility Map)

| # | Trách nhiệm (Responsibility) | Trạng thái | Các file Harness | Bằng chứng | Khoảng trống/Thiếu sót |
| --- | --- | --- | --- | --- | --- |
| 1 | Đặc tả nhiệm vụ (Task specification) | Đã bao phủ | `AGENTS.md`, `docs/FEATURE_INTAKE.md`, `docs/templates/story.md`, `docs/templates/spec-intake.md`, `docs/templates/high-risk-story/*`, `docs/stories/*`, bảng `intake`, bảng `story` | Các yêu cầu được phân loại theo loại hình và làn rủi ro trước khi triển khai; công việc bình thường và rủi ro cao có các template và dòng story lâu dài. | Giữ các gói story packet đồng bộ với tài liệu sản phẩm trong tương lai. |
| 2 | Lựa chọn ngữ cảnh (Context selection) | Đã bao phủ | `AGENTS.md`, `docs/CONTEXT_RULES.md`, `docs/ARCHITECTURE.md`, `docs/decisions/*`, `docs/product/README.md`, `scripts/bin/harness-cli score-context` | Phase 2 bổ sung các quy tắc ngữ cảnh theo giai đoạn và làn rủi ro cùng các bộ kích hoạt truy xuất; Phase 5 bổ sung việc tính điểm ngữ cảnh dựa trên các file đã đọc được ghi lại trong trace. | Tự động hóa trong tương lai có thể áp đặt việc lựa chọn ngữ cảnh thay vì chỉ đo lường nó. |
| 3 | Truy cập công cụ (Tool access) | Đã bao phủ | `scripts/bin/harness-cli`, `docs/TOOL_REGISTRY.md`, bảng `tool`, `crates/harness-cli/*`, `scripts/install-harness.sh`, `scripts/build-harness-cli-release.sh` | Harness CLI cung cấp các lệnh vận hành và manifest công cụ có thể đọc được bằng máy thông qua `query tools`; các công cụ bên ngoài có thể được đăng ký và gỡ bỏ. | Hồ sơ phân quyền (Permission profiles) và phân tích sử dụng vẫn là công việc trong tương lai. |
| 4 | Bộ nhớ dự án (Project memory) | Đã bao phủ | `docs/HARNESS.md`, `docs/decisions/*`, `docs/GLOSSARY.md`, `docs/HARNESS_BACKLOG.md`, `docs/stories/*`, `harness.db`, các bảng `decision`, `backlog` và `trace` | Các quyết định kỹ thuật, backlog, story và trace lưu giữ kiến thức bền vững qua các nhiệm vụ. | Công việc trong tương lai nên thêm kiểm tra độ cũ của tài liệu và tóm tắt các trace cũ. |
| 5 | Trạng thái nhiệm vụ (Task state) | Đã bao phủ | `scripts/bin/harness-cli query matrix`, `docs/TEST_MATRIX.md`, bảng `intake`, bảng `story`, bảng `trace` | Các bản ghi lâu dài theo dõi quy trình intake, trạng thái story, các cột bằng chứng và trace nhiệm vụ. | Thêm các kiểm tra vòng đời để các story đang triển khai không bị bỏ quên. |
| 6 | Khả năng quan sát (Observability) | Một phần | `docs/TRACE_SPEC.md`, bảng `trace`, `scripts/bin/harness-cli trace`, `scripts/bin/harness-cli score-trace`, `scripts/bin/harness-cli query traces`, `scripts/bin/harness-cli query friction`, `docs/HARNESS_MATURITY.md` | Các trace được tự động chấm điểm khi ghi lại, có thể được chấm điểm lại bằng lệnh và có thể được xem xét kèm theo ngữ cảnh ma sát. | Chưa có dashboard hoặc cơ chế nạp benchmark (benchmark ingestion) trong repo này. |
| 7 | Quy trách nhiệm lỗi (Failure attribution) | Một phần | `docs/HARNESS_COMPONENTS.md`, `docs/TRACE_SPEC.md`, `trace.errors`, `trace.harness_friction`, `docs/HARNESS_BACKLOG.md`, bảng `backlog`, `scripts/bin/harness-cli query friction` | Các lỗi có thể được liên kết với các file, thành phần, độ ma sát, đề xuất backlog và ngữ cảnh làn/loại intake liên quan. | Chưa có quy trách nhiệm lỗi tự động từ lỗi benchmark đến các thành phần harness. |
| 8 | Xác thực (Verification) | Đã bao phủ | `docs/TEST_MATRIX.md`, `scripts/bin/harness-cli query matrix`, `scripts/bin/harness-cli story verify`, `scripts/bin/harness-cli story verify-all`, `scripts/bin/harness-cli trace`, `scripts/bin/harness-cli score-trace`, `story.verify_command`, `story.last_verified_result`, `.github/workflows/harness-cli-release.yml`, `docs/templates/validation-report.md` | Các story có thể lưu trữ và chạy các lệnh xác thực cơ học riêng lẻ hoặc hàng loạt, trace sẽ cảnh báo khi việc xác thực story liên kết chưa vượt qua, chất lượng trace có thể được kiểm tra cơ học và workflow phát hành sẽ xác thực các bản phát hành Rust CLI. | Cơ chế nạp benchmark vẫn là công việc trong tương lai. |
| 9 | Quyền hạn (Permissions) | Một phần | `AGENTS.md`, `docs/HARNESS.md`, `docs/FEATURE_INTAKE.md`, `docs/ARCHITECTURE.md`, xử lý xung đột của trình cài đặt trong `scripts/install-harness.sh` | Chính sách mô tả khi nào các agent có thể cập nhật tài liệu và khi nào cần hỏi trước khi thay đổi kiến trúc hoặc luồng công việc. | Quyền hạn chỉ ở cấp độ hướng dẫn; chưa có lớp chính sách cưỡng chế hoặc danh sách lệnh được cho phép (allowlist). |
| 10 | Kiểm toán entropy (Entropy auditing) | Đã bao phủ | `docs/HARNESS_BACKLOG.md`, `docs/HARNESS_AUDIT.md`, `docs/IMPROVEMENT_PROTOCOL.md`, bảng `backlog`, `trace.harness_friction`, `scripts/bin/harness-cli audit`, `scripts/bin/harness-cli propose`, `docs/HARNESS_MATURITY.md` | Quy tắc tăng trưởng ghi lại ma sát, audit phát hiện sai lệch và tính điểm entropy, các mục backlog so sánh tác động dự kiến với kết quả thực tế, và việc tạo đề xuất có thể tạo ra các mục backlog dễ đánh giá. | Tự động sửa chữa vẫn là công việc trong tương lai. |
| 11 | Ghi nhận sự can thiệp (Intervention recording) | Đã bao phủ | `intervention` table, `scripts/bin/harness-cli intervention add`, `scripts/bin/harness-cli query interventions`, bảng `trace`, `docs/decisions/*`, `docs/stories/*`, `docs/HARNESS.md` | Các can thiệp của con người, người đánh giá, hệ thống CI và agent là các bản ghi lâu dài riêng biệt và có thể được lọc theo trace, story hoặc loại hình. | Việc thu thập thông tin vẫn là thủ công và mang tính khuyến nghị. |

## Tham chiếu chéo NexAU (NexAU Cross-Reference)

| Thành phần | Tương đương trong Harness | Trạng thái | Ghi chú |
| --- | --- | --- | --- |
| Prompts hệ thống (System prompts) | `AGENTS.md` kèm theo các tài liệu chính sách Harness | Đã bao phủ | `AGENTS.md` là shim ổn định; các file `docs/HARNESS.md`, `docs/FEATURE_INTAKE.md` và `docs/CONTEXT_RULES.md` chứa các hướng dẫn vận hành đang phát triển. |
| Mô tả công cụ | `docs/TOOL_REGISTRY.md`, `scripts/README.md`, `docs/HARNESS.md`, `docs/TRACE_SPEC.md`, đầu ra trợ giúp CLI từ `crates/harness-cli/src/interface.rs`, `scripts/bin/harness-cli query tools` | Đã bao phủ | Các lệnh được tài liệu hóa trong một registry độc lập và hiển thị dưới dạng các mục manifest công cụ được biên dịch và đăng ký. |
| Triển khai công cụ | `scripts/bin/harness-cli`, `crates/harness-cli/*`, `scripts/schema/001-init.sql`, `scripts/schema/002-story-verify.sql` | Đã bao phủ | Rust CLI là triển khai lớp lưu trữ bền vững chính và là điểm vào cục bộ ổn định của repo. |
| Phần mềm trung gian (Middleware) | logic an toàn của trình cài đặt, luồng tiếp nhận tính năng | Một phần | Trình cài đặt và quy trình tiếp nhận điều phối công việc, nhưng không có middleware runtime nào thực thi các chính sách. |
| Kỹ năng (Skills) | `docs/templates/*`, `docs/FEATURE_INTAKE.md`, `docs/CONTEXT_RULES.md`, `docs/TRACE_SPEC.md` | Một phần | Các quy trình có thể tái sử dụng tồn tại dưới dạng markdown, không phải là kỹ năng agent có thể thực thi hoặc cài đặt. |
| Sub-agents | Không có trong kho lưu trữ này | Còn thiếu | Không tồn tại các agent chuyên trách được ủy quyền hoặc các giao thức sub-agent. |
| Bộ nhớ dài hạn | `harness.db`, `docs/decisions/*`, `docs/stories/*`, `docs/HARNESS_BACKLOG.md`, `docs/GLOSSARY.md` | Đã bao phủ | Các bản ghi lâu dài và các quyết định kỹ thuật dạng markdown giúp bảo tồn lịch sử nhiệm vụ và từ vựng của dự án. |

## Danh mục File (File Inventory)

Mỗi file dự án được theo dõi cùng với file đầu vào Phase 2 đều được ánh xạ tới ít nhất một trách nhiệm của Runtime Substrate.

*(Lưu ý: Các đường dẫn file bên dưới được giữ nguyên bằng tiếng Anh để đảm bảo độ chính xác của đường dẫn).*

| Đường dẫn File | Trách nhiệm Chính | Trách nhiệm Phụ |
| --- | --- | --- |
| `.gitignore` | Truy cập công cụ | Trạng thái nhiệm vụ |
| `AGENTS.md` | Lựa chọn ngữ cảnh | Đặc tả nhiệm vụ, quyền hạn |
| `README.md` | Đặc tả nhiệm vụ | Bộ nhớ dự án |
| `CONTRIBUTING.md` | Ghi nhận sự can thiệp | Bộ nhớ dự án |
| `Cargo.toml` | Truy cập công cụ | Xác thực |
| `Cargo.lock` | Truy cập công cụ | Xác thực |
| `PHASE2.md` | Đặc tả nhiệm vụ | Khả năng quan sát, lựa chọn ngữ cảnh |
| `PHASE3.md` | Đặc tả nhiệm vụ | Khả năng quan sát, xác thực, kiểm toán entropy |
| `PHASE4.md` | Đặc tả nhiệm vụ | Xác thực, khả năng quan sát, trạng thái nhiệm vụ |
| `PHASE5.md` | Đặc tả nhiệm vụ | Xác thực, kiểm toán entropy, ghi nhận sự can thiệp |
| `crates/harness-cli/Cargo.toml` | Truy cập công cụ | Xác thực |
| `crates/harness-cli/src/main.rs` | Truy cập công cụ | Triển khai công cụ |
| `crates/harness-cli/src/domain.rs` | Truy cập công cụ | Trạng thái nhiệm vụ, xác thực |
| `crates/harness-cli/src/application.rs` | Truy cập công cụ | Trạng thái nhiệm vụ |
| `crates/harness-cli/src/infrastructure.rs` | Truy cập công cụ | Bộ nhớ dự án, trạng thái nhiệm vụ, khả năng quan sát |
| `crates/harness-cli/src/interface.rs` | Truy cập công cụ | Lựa chọn ngữ cảnh, xác thực |
| `docs/ARCHITECTURE.md` | Quyền hạn | Lựa chọn ngữ cảnh, đặc tả nhiệm vụ |
| `docs/FEATURE_INTAKE.md` | Đặc tả nhiệm vụ | Quyền hạn, lựa chọn ngữ cảnh |
| `docs/GLOSSARY.md` | Bộ nhớ dự án | Lựa chọn ngữ cảnh |
| `docs/HARNESS.md` | Đặc tả nhiệm vụ | Bộ nhớ dự án, trạng thái nhiệm vụ, quyền hạn |
| `docs/HARNESS_BACKLOG.md` | Kiểm toán entropy | Bộ nhớ dự án, quy trách nhiệm lỗi |
| `docs/HARNESS_COMPONENTS.md` | Quy trách nhiệm lỗi | Khả năng quan sát, kiểm toán entropy |
| `docs/HARNESS_MATURITY.md` | Kiểm toán entropy | Khả năng quan sát, xác thực |
| `docs/HARNESS_AUDIT.md` | Kiểm toán entropy | Xác thực, trạng thái nhiệm vụ |
| `docs/IMPROVEMENT_PROTOCOL.md` | Kiểm toán entropy | Quy trách nhiệm lỗi, quyền hạn |
| `docs/CONTEXT_RULES.md` | Lựa chọn ngữ cảnh | Quyền hạn, đặc tả nhiệm vụ |
| `docs/TRACE_SPEC.md` | Khả năng quan sát | Quy trách nhiệm lỗi, ghi nhận sự can thiệp |
| `docs/TOOL_REGISTRY.md` | Truy cập công cụ | Lựa chọn ngữ cảnh, xác thực |
| `docs/README.md` | Bộ nhớ dự án | Lựa chọn ngữ cảnh |
| `docs/TEST_MATRIX.md` | Xác thực | Trạng thái nhiệm vụ |
| `docs/decisions/0001-harness-first-development.md` | Bộ nhớ dự án | Quyền hạn |
| `docs/decisions/0002-post-spec-product-lifecycle.md` | Bộ nhớ dự án | Đặc tả nhiệm vụ |
| `docs/decisions/0003-generic-spec-intake-harness.md` | Bộ nhớ dự án | Đặc tả nhiệm vụ |
| `docs/decisions/0004-sqlite-durable-layer.md` | Bộ nhớ dự án | Khả năng quan sát, trạng thái nhiệm vụ |
| `docs/decisions/0005-prebuilt-rust-harness-cli.md` | Bộ nhớ dự án | Truy cập công cụ |
| `docs/decisions/0006-phase-4-benchmark-triage.md` | Bộ nhớ dự án | Xác thực |
| `docs/decisions/0007-improvement-proposal-rules.md` | Bộ nhớ dự án | Kiểm toán entropy, quyền hạn |
| `docs/decisions/README.md` | Bộ nhớ dự án | Lựa chọn ngữ cảnh |
| `docs/demo/README.md` | Đặc tả nhiệm vụ | Bộ nhớ dự án |
| `docs/product/README.md` | Đặc tả nhiệm vụ | Bộ nhớ dự án |
| `docs/review-fixes-1d30bf62-to-main.md` | Ghi nhận sự can thiệp | Quy trách nhiệm lỗi, xác thực |
| `docs/stories/README.md` | Đặc tả nhiệm vụ | Bộ nhớ dự án |
| `docs/stories/US-001-install-harness.md` | Đặc tả nhiệm vụ | Xác thực, ghi nhận sự can thiệp |
| `docs/stories/US-008-trace-quality-scoring.md` | Đặc tả nhiệm vụ | Khả năng quan sát, xác thực |
| `docs/stories/US-009-enriched-friction-query.md` | Đặc tả nhiệm vụ | Quy trách nhiệm lỗi, khả năng quan sát |
| `docs/stories/US-011-backlog-outcome-workflow.md` | Đặc tả nhiệm vụ | Kiểm toán entropy, bộ nhớ dự án |
| `docs/stories/US-012-story-verify-command-field.md` | Đặc tả nhiệm vụ | Xác thực |
| `docs/stories/US-015-story-verify-command.md` | Đặc tả nhiệm vụ | Xác thực |
| `docs/stories/US-016-auto-trace-scoring-on-write.md` | Đặc tả nhiệm vụ | Khả năng quan sát, xác thực |
| `docs/stories/US-017-pre-close-verification-gate.md` | Đặc tả nhiệm vụ | Xác thực, quyền hạn |
| `docs/stories/US-018-phase4-cli-ux-hardening.md` | Đặc tả nhiệm vụ | Truy cập công cụ, xác thực |
| `docs/stories/US-019-machine-readable-tool-registry.md` | Đặc tả nhiệm vụ | Truy cập công cụ |
| `docs/stories/US-020-batch-story-verification.md` | Đặc tả nhiệm vụ | Xác thực |
| `docs/stories/US-021-intervention-recording-schema.md` | Đặc tả nhiệm vụ | Ghi nhận sự can thiệp |
| `docs/stories/US-022-context-rule-measurement.md` | Đặc tả nhiệm vụ | Lựa chọn ngữ cảnh |
| `docs/stories/US-023-drift-detection-entropy-score.md` | Đặc tả nhiệm vụ | Kiểm toán entropy |
| `docs/stories/US-024-improvement-proposal-pipeline.md` | Đặc tả nhiệm vụ | Kiểm toán entropy, quyền hạn |
| `docs/stories/backlog.md` | Đặc tả nhiệm vụ | Bộ nhớ dự án |
| `docs/stories/epics/README.md` | Đặc tả nhiệm vụ | Bộ nhớ dự án |
| `docs/stories/epics/E01-durable-layer/US-002-rust-harness-cli/overview.md` | Đặc tả nhiệm vụ | Bộ nhớ dự án |
| `docs/stories/epics/E01-durable-layer/US-002-rust-harness-cli/design.md` | Đặc tả nhiệm vụ | Truy cập công cụ, quyền hạn |
| `docs/stories/epics/E01-durable-layer/US-002-rust-harness-cli/execplan.md` | Đặc tả nhiệm vụ | Xác thực, trạng thái nhiệm vụ |
| `docs/stories/epics/E01-durable-layer/US-002-rust-harness-cli/validation.md` | Xác thực | Ghi nhận sự can thiệp |
| `docs/stories/epics/E02-phase-2-observability-taxonomy/phase-2-progress.md` | Trạng thái nhiệm vụ | Ghi nhận sự can thiệp |
| `docs/stories/epics/E03-phase-5-evolution-infrastructure/phase-5-progress.md` | Trạng thái nhiệm vụ | Xác thực, kiểm toán entropy |
| `docs/templates/decision.md` | Bộ nhớ dự án | Đặc tả nhiệm vụ |
| `docs/templates/spec-intake.md` | Đặc tả nhiệm vụ | Lựa chọn ngữ cảnh |
| `docs/templates/story.md` | Đặc tả nhiệm vụ | Xác thực |
| `docs/templates/validation-report.md` | Xác thực | Ghi nhận sự can thiệp |
| `docs/templates/high-risk-story/overview.md` | Đặc tả nhiệm vụ | Lựa chọn ngữ cảnh |
| `docs/templates/high-risk-story/design.md` | Đặc tả nhiệm vụ | Quyền hạn |
| `docs/templates/high-risk-story/execplan.md` | Trạng thái nhiệm vụ | Xác thực |
| `docs/templates/high-risk-story/validation.md` | Xác thực | Quy trách nhiệm lỗi |
| `scripts/README.md` | Truy cập công cụ | Lựa chọn ngữ cảnh |
| `scripts/bin/harness-cli` | Truy cập công cụ | Trạng thái nhiệm vụ, khả năng quan sát |
| `scripts/install-harness.sh` | Truy cập công cụ | Quyền hạn |
| `scripts/build-harness-cli-release.sh` | Xác thực | Truy cập công cụ |
| `scripts/schema/001-init.sql` | Trạng thái nhiệm vụ | Khả năng quan sát, bộ nhớ dự án |
| `scripts/schema/002-story-verify.sql` | Xác thực | Trạng thái nhiệm vụ, bộ nhớ dự án |
| `scripts/schema/003-tool-registry.sql` | Truy cập công cụ | Bộ nhớ dự án |
| `scripts/schema/004-intervention.sql` | Ghi nhận sự can thiệp | Quy trách nhiệm lỗi |
| `.github/ISSUE_TEMPLATE/agent-failure-case.md` | Quy trách nhiệm lỗi | Kiểm toán entropy |
| `.github/ISSUE_TEMPLATE/pattern-request.md` | Kiểm toán entropy | Ghi nhận sự can thiệp |
| `.github/ISSUE_TEMPLATE/real-world-example.md` | Bộ nhớ dự án | Ghi nhận sự can thiệp |
| `.github/workflows/harness-cli-release.yml` | Xác thực | Truy cập công cụ |

## Tóm tắt Độ bao phủ (Coverage Summary)

- Đã bao phủ (Covered): 8/11 trách nhiệm.
- Một phần (Partial): 3/11 trách nhiệm.
- Còn thiếu (Missing): 0/11 trách nhiệm.

Các trách nhiệm đã bao phủ:

- Đặc tả nhiệm vụ.
- Lựa chọn ngữ cảnh.
- Truy cập công cụ.
- Bộ nhớ dự án.
- Trạng thái nhiệm vụ.
- Xác thực.
- Kiểm toán entropy.
- Ghi nhận sự can thiệp.

Các trách nhiệm một phần:

- Khả năng quan sát.
- Quy trách nhiệm lỗi.
- Quyền hạn.

Phase 5 chuyển đổi việc truy cập công cụ, kiểm toán entropy và ghi nhận sự can thiệp thành các trách nhiệm đã bao phủ với registry, audit sai lệch, vòng lặp đề xuất và lược đồ can thiệp. Các phase sau nên tập trung vào nạp benchmark, quy trách nhiệm ở cấp độ thành phần, thực thi quyền hạn và phân tích sử dụng công cụ.
