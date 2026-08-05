#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

fail() {
  printf 'documentation contract failed: %s\n' "$*" >&2
  exit 1
}

require() {
  local file=$1
  local text=$2
  grep -Fq -- "$text" "$root/$file" || fail "$file omits: $text"
}

reject() {
  local file=$1
  local text=$2
  if grep -Fq -- "$text" "$root/$file"; then
    fail "$file contains stale default-path instruction: $text"
  fi
}

# Current default authority is repository-centered and explicitly keeps
# workflow-database operations off the bounded path.
require AGENTS.md 'Bắt đầu với kết quả được yêu cầu'
require AGENTS.md 'Không yêu cầu thao tác control-plane.'
require harness-docs/WORKFLOW.md '### Bounded Change'
require harness-docs/WORKFLOW.md '### Durable Planned Change'
require harness-docs/WORKFLOW.md '### Does The Work Need Human Judgment?'
require harness-docs/WORKFLOW.md '### Operate The Application'
require harness-docs/WORKFLOW.md '### Improve The Harness'
require AGENTS.md 'các tùy chọn mặc định có thể cấu hình không phải là quyền thẩm quyền'
require AGENTS.md 'được yêu cầu rõ ràng bằng `$improve-harness`'
require harness-docs/WORKFLOW.md '`Add rate limiting` without a quota'
require harness-docs/WORKFLOW.md 'must stop'
require harness-docs/HARNESS.md 'Harness'
require harness-docs/CONTEXT_RULES.md 'AGENTS.md'
require README.md 'Đường dẫn mặc định không yêu cầu database cục bộ.'
require harness-docs/demo/README.md 'Đặc tả sản phẩm'

for file in AGENTS.md harness-docs/WORKFLOW.md harness-docs/HARNESS.md harness-docs/CONTEXT_RULES.md; do
  reject "$file" 'scripts/bin/harness-cli query matrix --active --summary'
  reject "$file" 'first run `scripts/bootstrap-harness.sh`'
done

# Durable planning and decision structure are part of both source and the
# fresh core. Upstream decisions remain source-only.
for file in \
  .agents/skills/audit-onboarding-proposal/SKILL.md \
  .agents/skills/audit-onboarding-proposal/agents/openai.yaml \
  .agents/skills/audit-onboarding-proposal/scripts/validate_evidence_capsule.py \
  .agents/skills/improve-harness/SKILL.md \
  .agents/skills/improve-harness/agents/openai.yaml \
  .agents/skills/onboard-repository/SKILL.md \
  .agents/skills/onboard-repository/agents/openai.yaml \
  .agents/skills/onboard-repository/references/evidence-capsule-v1.md \
  .agents/skills/onboard-repository/references/evidence-capsule-v2.md \
  .agents/skills/onboard-repository/scripts/emit_evidence_bundle.py \
  .agents/skills/onboard-repository/scripts/render_patch.py \
  harness-docs/README.md \
  harness-docs/product/README.md \
  harness-docs/plans/README.md \
  harness-docs/plans/active/README.md \
  harness-docs/plans/completed/README.md \
  harness-docs/decisions/README.md \
  harness-docs/templates/application-runbook.md \
  harness-docs/templates/decision.md \
  harness-docs/templates/exec-plan.md \
  harness-docs/templates/harness-improvement.md; do
  [[ -f "$root/$file" ]] || fail "missing repository artifact: $file"
  grep -Fxq "$file" "$root/scripts/harness-install-files.txt" ||
    fail "installer payload omits: $file"
done
for file in \
  harness-docs/decisions/0019-repository-centered-default-workflow.md \
  harness-docs/decisions/0020-installation-profiles-and-knowledge-boundaries.md \
  harness-docs/decisions/0021-consumer-first-application-legibility-phase.md \
  harness-docs/decisions/0022-control-plane-freeze-and-compatibility-runway.md \
  harness-docs/decisions/0023-optional-consumer-ownership.md \
  harness-docs/decisions/0024-rust-harness-core-maintenance-cli.md \
  harness-docs/compatibility/README.md \
  harness-docs/provenance/README.md; do
  [[ -f "$root/$file" ]] || fail "missing source-only artifact: $file"
done

for heading in Outcome Context Scope Approach 'Risks And Recovery' Progress Decisions Validation Result; do
  require harness-docs/templates/exec-plan.md "## $heading"
done
for heading in Scope Prerequisites Start Readiness 'Deterministic State' Interface \
  'Runtime Evidence' 'Ownership And Cleanup' Validation Unknowns; do
  require harness-docs/templates/application-runbook.md "## $heading"
done
for heading in Status 'Representative Job' Baseline 'Earliest Gap' \
  'Correct Owner' Intervention 'Native Validation' 'Fresh Rerun' Decision Result; do
  require harness-docs/templates/harness-improvement.md "## $heading"
done
require .agents/skills/improve-harness/agents/openai.yaml \
  'allow_implicit_invocation: false'

# Old surfaces remain available but must identify themselves as compatibility
# references before presenting commands or lifecycle policy.
for file in \
  harness-docs/FEATURE_INTAKE.md \
  harness-docs/TEST_MATRIX.md \
  harness-docs/TRACE_SPEC.md \
  harness-docs/HARNESS_AUDIT.md \
  harness-docs/HARNESS_MATURITY.md \
  harness-docs/HARNESS_BACKLOG.md \
  harness-docs/IMPROVEMENT_PROTOCOL.md \
  harness-docs/TOOL_REGISTRY.md \
  harness-docs/stories/README.md; do
  head -n 12 "$root/$file" | grep -Fq 'Compatibility' ||
    fail "$file lacks an early compatibility boundary"
  grep -Fxq "$file" "$root/scripts/harness-cli-install-files.txt" ||
    fail "CLI compatibility payload omits: $file"
done

require scripts/README.md 'Normal'
require scripts/README.md 'story row, matrix query, trace, score, audit, or proposal'
require harness-docs/ARCHITECTURE.md 'Sản phẩm Harness upstream được triển khai dưới dạng một Rust workspace'
require harness-docs/ARCHITECTURE.md 'Template tái sử dụng không lựa chọn ngăn xếp ứng dụng'
require scripts/README.md 'Installed consumer projects keep their own stack-specific validation commands'
require scripts/README.md 'By default the installer downloads the checksum-verified `harness` maintenance'
require harness-docs/README.md '## Các File Chính'
require harness-docs/README.md '## Các Thư mục'
require tests/README.md '## Current Core'
require tests/README.md '## Optional Compatibility CLI'
require tests/README.md '## Historical Migration Proof'
require harness-docs/compatibility/README.md '## Install Boundary'
require harness-docs/plans/active/application-legibility.md '# Execution Plan: Application Legibility Pilot'
require harness-docs/plans/active/application-legibility.md '## Evidence Matrix'
require harness-docs/plans/active/application-legibility.md '## What Remains To Prove'
require harness-docs/plans/active/application-legibility.md 'Phase 3 completes only when one task exercises that loop'
require harness-docs/decisions/README.md '0021-consumer-first-application-legibility-phase.md'
require harness-docs/decisions/0021-consumer-first-application-legibility-phase.md 'Phase 3 therefore remains active.'
require harness-docs/plans/README.md 'application-legibility.md'
require harness-docs/plans/completed/README.md 'rust-harness-core-maintenance-cli.md'
require harness-docs/plans/completed/README.md 'repository-cleanup.md'
require harness-docs/plans/completed/repository-cleanup.md 'Completed. Current application-legibility work now lives'
require harness-docs/plans/completed/rust-harness-core-maintenance-cli.md 'A Rust executable named `harness`.'
require harness-docs/plans/completed/rust-harness-core-maintenance-cli.md 'optional SQLite control plane remains outside the CLI'
require harness-docs/plans/completed/rust-harness-core-maintenance-cli.md 'PR #56'
require harness-docs/plans/completed/README.md 'phase-4-control-plane-freeze.md'
require harness-docs/plans/completed/phase-4-control-plane-freeze.md 'Complete. New upstream work has one Git-native authority path.'
require harness-docs/plans/completed/phase-4-control-plane-freeze.md '## Validation'
require harness-docs/decisions/README.md '0022-control-plane-freeze-and-compatibility-runway.md'
require harness-docs/decisions/0022-control-plane-freeze-and-compatibility-runway.md 'warn on new upstream legacy lifecycle writes'
require harness-docs/compatibility/README.md 'phase-4-write-consumer-inventory.md'
require harness-docs/compatibility/phase-4-write-consumer-inventory.md 'No current upstream product or execution authority exists only in SQLite.'
require harness-docs/contracts/harness-orchestration-v1.md '`--compatibility-write` flag'
require scripts/README.md '`--compatibility-write` flag'
require harness-docs/compatibility/phase-3-active-observability-legacy.md 'Historical compatibility plan.'
require harness-docs/compatibility/phase-4-mechanical-verification-legacy.md 'Historical compatibility roadmap.'
require harness-docs/provenance/README.md 'source evidence, not default task'
require harness-docs/decisions/README.md '0023-optional-consumer-ownership.md'
require harness-docs/decisions/0023-optional-consumer-ownership.md '`hoangnb24/symphony` owns orchestration policy'
require harness-docs/decisions/README.md '0024-rust-harness-core-maintenance-cli.md'
require harness-docs/decisions/0024-rust-harness-core-maintenance-cli.md 'The next upstream product goal is a Rust CLI named `harness`.'
require harness-docs/decisions/README.md '0025-latest-release-self-update-and-human-directed-conflicts.md'
require harness-docs/decisions/0025-latest-release-self-update-and-human-directed-conflicts.md '`harness update --continue --dry-run`'
require harness-docs/product/installation-profiles.md '.harness-core/update/'
require README.md 'scripts/bin/harness update --continue'
require README.md 'Symphony owns work selection, agent runs, worktrees'
require harness-docs/compatibility/README.md 'Phase 5 ownership boundary'
require harness-docs/compatibility/README.md 'phase-5-evolution-infrastructure-legacy.md'
require harness-docs/compatibility/phase-5-evolution-infrastructure-legacy.md 'Historical compatibility roadmap.'
require harness-docs/plans/completed/README.md 'phase-5-optional-consumer-split.md'
require harness-docs/plans/completed/phase-5-optional-consumer-split.md 'Complete. Symphony remains the independent owner'

for executable in \
  scripts/validate-premerge.sh \
  scripts/verify-revision-coherence.sh \
  tests/boundary/test-phase5-optional-consumer-split.sh \
  tests/workflow/test-repository-workflow.sh \
  tests/workflow/test-task-authority.sh; do
  [[ -x "$root/$executable" ]] || fail "documented gate is not executable: $executable"
done

for required_gate in \
  'cargo fmt --all -- --check' \
  'cargo test --workspace --locked' \
  'cargo clippy --workspace --all-targets --locked -- -D warnings' \
  'scripts/verify-revision-coherence.sh' \
  'tests/boundary/test-phase4-control-plane-freeze.sh' \
  'tests/boundary/test-phase5-optional-consumer-split.sh' \
  'tests/docs/test-doc-contracts.sh' \
  'tests/workflow/test-repository-workflow.sh' \
  'tests/workflow/test-task-authority.sh' \
  'tests/maintenance/test-harness-release-classification.sh' \
  'tests/release/test-harness-release-workflow-contract.sh' \
  'tests/release/test-harness-release-identity-guard.sh' \
  'tests/release/test-post-merge-release-recovery.sh'; do
  require scripts/validate-premerge.sh "$required_gate"
done

"$root/tests/installer/assert-agent-authority-contract.sh" >/dev/null
"$root/tests/installer/assert-install-manifest-links.sh" >/dev/null

require .github/workflows/premerge.yml 'run: scripts/validate-premerge.sh'
grep -Fq 'tests/installer/test-install-harness-modes.ps1' "$root/.github/workflows/premerge.yml" &&
  grep -Fq -- '-InitialArtifact dist/us092-harness-cli-windows-x64.exe' \
    "$root/.github/workflows/premerge.yml" ||
  fail 'pull-request workflow does not exercise the PowerShell installer contract'
require .github/workflows/harness-cli-release.yml 'run: scripts/validate-premerge.sh'
require .github/workflows/harness-release.yml 'run: scripts/validate-premerge.sh'

echo "repository workflow, compatibility boundary, links, authority, and validation references passed"
