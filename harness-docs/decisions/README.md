# Quyết định Kỹ thuật (Decisions)

Các bản ghi quyết định kỹ thuật lưu giữ các lựa chọn lâu dài về sản phẩm, kiến trúc, quyền sở hữu dữ liệu, bảo mật, tính tương thích và xác thực mà công việc trong tương lai phải kế thừa.

Sử dụng mẫu `harness-docs/templates/decision.md`. Các lựa chọn triển khai cục bộ ở cấp độ nhiệm vụ được giữ trong kế hoạch thực thi đang hoạt động và không cần một bản ghi quyết định riêng.

Dự án consumer khi cài đặt không tự tạo các quyết định giả lập. Thêm các tài liệu quyết định cục bộ vào đây khi các lựa chọn thực tế được chấp nhận, sau đó đánh chỉ mục chúng trong file này.

## Quyết định Upstream Hiện tại

Các quyết định trong kho lưu trữ nguồn này giải thích chính Harness; chúng không phải là lựa chọn sản phẩm của consumer.

| Quyết định | Trạng thái | Tiêu đề |
| --- | --- | --- |
| [0019](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0019-repository-centered-default-workflow.md) | Active | Repository-Centered Default Workflow |
| [0020](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0020-installation-profiles-and-knowledge-boundaries.md) | Active | Installation Profiles And Knowledge Boundaries |
| [0021](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0021-consumer-first-application-legibility-phase.md) | Active | Consumer-First Application Legibility Phase |
| [0022](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0022-control-plane-freeze-and-compatibility-runway.md) | Active | Control-Plane Freeze And Compatibility Runway |
| [0023](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0023-optional-consumer-ownership.md) | Active | Optional Consumer Ownership |
| [0024](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0024-rust-harness-core-maintenance-cli.md) | Accepted target | Rust Harness Core Maintenance CLI |
| [0025](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0025-latest-release-self-update-and-human-directed-conflicts.md) | Active | Latest-Release Self-Update And Human-Directed Conflicts |
| [0026](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0026-explicit-onboarding-skills-in-default-core.md) | Active | Explicit Onboarding Skills In Default Core |

## Quyết định Tương thích

Các quyết định này chỉ còn liên quan khi bảo trì CLI tùy chọn, SQLite hoặc bề mặt điều phối.

| Quyết định | Trạng thái | Tiêu đề |
| --- | --- | --- |
| [0004](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0004-sqlite-durable-layer.md) | Compatibility | SQLite Durable Layer |
| [0005](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0005-prebuilt-rust-harness-cli.md) | Compatibility | Prebuilt Rust Harness CLI |
| [0006](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0006-phase-4-benchmark-triage.md) | Compatibility | Phase 4 Benchmark Triage |
| [0007](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0007-improvement-proposal-rules.md) | Compatibility | Improvement Proposal Rules |
| [0011](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0011-reproducible-core-state.md) | Compatibility | Reproducible Core State |
| [0010](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0010-proof-before-cli-release-promotion.md) | Compatibility | Proof Before Harness CLI Release Promotion |

## Quyết định Lịch sử

Các bản ghi này giải thích hành vi mặc định đã bị thay thế và được giữ lại để tra cứu nguồn gốc thay vì hướng dẫn hiện tại.

| Quyết định | Trạng thái | Tiêu đề |
| --- | --- | --- |
| [0001](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0001-harness-first-development.md) | Amended by 0019 | Harness-First Development |
| [0002](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0002-post-spec-product-lifecycle.md) | Superseded by 0003 | Seed Specification Product Lifecycle |
| [0003](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0003-generic-spec-intake-harness.md) | Amended by 0019 | Generic Spec Intake Harness |
| [0008](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0008-self-improving-harness-lifecycle.md) | Superseded by 0019 and 0022 | Self-Improving Harness Lifecycle |
| [0009](https://github.com/hieunm599/repository-harness/blob/vi/harness-docs/decisions/0009-separate-symphony-product-repository.md) | Completed migration | Separate Symphony Into Its Own Product Repository |

## Thêm Quyết định Khi

- Lựa chọn kỹ thuật cố định bị thay đổi.
- Hành vi sản phẩm thay đổi một cách có ý nghĩa và các phương án có hệ quả khác nhau.
- Quyền sở hữu dữ liệu, phân quyền, quyền riêng tư, bảo mật hoặc tính tương thích công khai được quyết định.
- Yêu cầu xác thực được thêm vào, loại bỏ hoặc bị làm yếu đi.
- Phân cấp nguồn sự thật hoặc luồng công việc mặc định thay đổi.

Không thêm quyết định chỉ vì một nhiệm vụ đề cập đến miền nhạy cảm hoặc sử dụng một kế hoạch thực thi lâu dài.
