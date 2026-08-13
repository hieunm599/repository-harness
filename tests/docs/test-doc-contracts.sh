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

current_files=(
  README.md
  AGENTS.md
  harness-docs/WORKFLOW.md
  harness-docs/ARCHITECTURE.md
  harness-docs/HARNESS.md
  harness-docs/README.md
  harness-docs/product/README.md
  harness-docs/product/installation-profiles.md
  harness-docs/plans/README.md
  harness-docs/plans/active/README.md
  harness-docs/plans/completed/README.md
  harness-docs/decisions/README.md
  harness-docs/templates/application-runbook.md
  harness-docs/templates/decision.md
  harness-docs/templates/exec-plan.md
  harness-docs/templates/harness-improvement.md
  harness-docs/decisions/0019-repository-centered-default-workflow.md
  harness-docs/decisions/0020-installation-profile-and-knowledge-boundaries.md
  harness-docs/decisions/0024-rust-harness-core-maintenance-cli.md
  harness-docs/decisions/0025-latest-release-self-update-and-human-directed-conflicts.md
  harness-docs/decisions/0026-explicit-onboarding-skills-in-default-core.md
  harness-docs/decisions/0027-end-protocol-v1-and-focus-repository-protocol.md
  harness-docs/research/application-legibility.md
  .github/ISSUE_TEMPLATE/real-world-example.md
)
for file in "${current_files[@]}"; do
  [[ -f "$root/$file" ]] || fail "missing current artifact: $file"
done

require AGENTS.md 'Bắt đầu với kết quả được yêu cầu'
require AGENTS.md 'các tùy chọn mặc định có thể cấu hình không phải là quyền thẩm quyền'
require harness-docs/WORKFLOW.md '### Bounded Change'
require harness-docs/WORKFLOW.md '### Durable Planned Change'
require harness-docs/WORKFLOW.md '### Operate The Application'
require harness-docs/WORKFLOW.md '### Improve The Harness'
require harness-docs/ARCHITECTURE.md 'binary'
require README.md '## Những gì chúng ta chứng minh'
require README.md '## Ngừng hỗ trợ Giao thức V1'
require harness-docs/research/application-legibility.md 'research, not a release gate'
require harness-docs/decisions/0027-end-protocol-v1-and-focus-repository-protocol.md '`harness-cli-v0.1.22`'
require .github/ISSUE_TEMPLATE/real-world-example.md '`harness-docs/WORKFLOW.md`'
require .github/ISSUE_TEMPLATE/real-world-example.md '`harness-docs/ARCHITECTURE.md`'

for heading in Outcome Context Scope Approach 'Risks And Recovery' Progress Decisions Validation Result; do
  require harness-docs/templates/exec-plan.md "## $heading"
done

while IFS= read -r payload; do
  [[ -f "$root/$payload" ]] || fail "core manifest target is missing: $payload"
done < <(sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' "$root/scripts/harness-install-files.txt")

compatibility_paths=(
  crates/harness-cli
  scripts/schema
  scripts/harness-cli-install-files.txt
  .github/workflows/harness-cli-release.yml
  harness-docs/contracts/harness-orchestration-v1.md
  harness-docs/compatibility
  harness-docs/stories
  .harness/core-state
  .harness/changesets
)
for compatibility_path in "${compatibility_paths[@]}"; do
  target="$root/$compatibility_path"
  if [[ -d "$target" ]]; then
    [[ -z "$(find "$target" -type f -print -quit)" ]] ||
      fail "EOL compatibility files remain: $compatibility_path"
  else
    [[ ! -e "$target" ]] || fail "EOL compatibility path remains: $compatibility_path"
  fi
done

executables=(
  scripts/validate-premerge.sh
  tests/workflow/test-repository-workflow.sh
  tests/workflow/test-task-authority.sh
  tests/installer/test-install-harness-modes.sh
)
for executable in "${executables[@]}"; do
  [[ -x "$root/$executable" ]] || fail "documented gate is not executable: $executable"
done

required_gates=(
  'cargo fmt --all -- --check'
  'cargo test --workspace --locked'
  'cargo clippy --workspace --all-targets --locked -- -D warnings'
  'tests/installer/test-install-harness-modes.sh'
  'tests/docs/test-doc-contracts.sh'
  'tests/workflow/test-repository-workflow.sh'
  'tests/workflow/test-task-authority.sh'
  'tests/release/test-harness-release-workflow-contract.sh'
)
for gate in "${required_gates[@]}"; do
  require scripts/validate-premerge.sh "$gate"
done

require .github/workflows/premerge.yml 'run: scripts/validate-premerge.sh'
require .github/workflows/premerge.yml 'tests/installer/test-install-harness-modes.ps1'
require .github/workflows/harness-release.yml 'run: scripts/validate-premerge.sh'

"$root/tests/installer/assert-agent-authority-contract.sh" >/dev/null
"$root/tests/installer/assert-install-manifest-links.sh" >/dev/null

echo "current product, EOL boundary, manifest, authority, and validation references passed"
