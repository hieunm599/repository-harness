# Nhật ký thay đổi (Changelog)

## 2026-06-15 - PR #20

- fix: add missing files to installer file lists (@NguyenQS504092s)
- Merge commit: `e3a83390be59eafcf361afe61672db1a9ed0a440`
- Bản phát hành Harness CLI (Harness CLI release): Không yêu cầu (not required)
- Các file thay đổi (Changed files):
  - `scripts/install-harness.ps1`
  - `scripts/install-harness.sh`

## 2026-06-13 - PR #19

- feat(cli): kind-aware inbound tool registry with presence scanning (@thanh-dong)
- Merge commit: `04177b25a7f7e1c5acd24b71127db331c1b6602c`
- Bản phát hành Harness CLI (Harness CLI release): `harness-cli-v0.1.10`
- Các file thay đổi (Changed files):
  - `AGENTS.md`
  - `README.md`
  - `crates/harness-cli/src/application.rs`
  - `crates/harness-cli/src/domain.rs`
  - `crates/harness-cli/src/infrastructure.rs`
  - `crates/harness-cli/src/interface.rs`
  - `harness-docs/TOOL_REGISTRY.md`
  - `harness-docs/stories/US-027-inbound-tool-registry.md`
  - `scripts/install-harness.sh`
  - `scripts/schema/005-tool-extensions.sql`

## 2026-06-09 - PR #13

- docs(phase5): Phase 5 — Evolution Infrastructure scope (@hoangnb24)
- Merge commit: `bfef94a77acfa33af81f6da96bc06f053d7f5164`
- Bản phát hành Harness CLI (Harness CLI release): `harness-cli-v0.1.9`
- Các file thay đổi (Changed files):
  - `PHASE5.md`
  - `crates/harness-cli/src/application.rs`
  - `crates/harness-cli/src/domain.rs`
  - `crates/harness-cli/src/infrastructure.rs`
  - `crates/harness-cli/src/interface.rs`
  - `harness-docs/FEATURE_INTAKE.md`
  - `harness-docs/GLOSSARY.md`
  - `harness-docs/HARNESS.md`
  - `harness-docs/HARNESS_AUDIT.md`
  - `harness-docs/HARNESS_COMPONENTS.md`
  - `harness-docs/HARNESS_MATURITY.md`
  - `harness-docs/IMPROVEMENT_PROTOCOL.md`
  - `harness-docs/TOOL_REGISTRY.md`
  - `harness-docs/decisions/0007-improvement-proposal-rules.md`
  - `harness-docs/stories/US-019-machine-readable-tool-registry.md`
  - `harness-docs/stories/US-020-batch-story-verification.md`
  - `harness-docs/stories/US-021-intervention-recording-schema.md`
  - `harness-docs/stories/US-022-context-rule-measurement.md`
  - `harness-docs/stories/US-023-drift-detection-entropy-score.md`
  - `harness-docs/stories/US-024-improvement-proposal-pipeline.md`
  - `harness-docs/stories/epics/E03-phase-5-evolution-infrastructure/phase-5-progress.md`
  - `scripts/install-harness.sh`
  - `scripts/schema/003-tool-registry.sql`
  - `scripts/schema/004-intervention.sql`

## 2026-06-09 - Tự động hóa sau khi Merge (Post-Merge Automation)

- Thêm quy trình tự động hóa nhật ký thay đổi (changelog) sau khi merge cho các pull request đã được merge.
- Thêm quy trình tự động hóa phát hành bản sửa lỗi (patch release) Harness CLI theo điều kiện khi các PR được merge có thay đổi mã nguồn Rust CLI, schema, Cargo metadata hoặc các file đóng gói phát hành.
- Tái sử dụng workflow phát hành Harness CLI hiện có cho các bản build phát hành để thẻ (tag), phát hành thủ công và phát hành sau merge chia sẻ cùng một quy trình xác thực và xuất bản asset.
