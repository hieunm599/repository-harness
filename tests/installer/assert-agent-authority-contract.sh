#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
agent_block="$root/scripts/agent-harness-block.md"
claude_block="$root/scripts/claude-harness-block.md"
workflow="$root/harness-docs/WORKFLOW.md"

extract_block() {
  awk '
    /<!-- HARNESS:BEGIN -->/ { in_block = 1 }
    in_block { print }
    /<!-- HARNESS:END -->/ { exit }
  ' "$1"
}

cmp -s <(extract_block "$root/AGENTS.md") "$agent_block"
cmp -s <(extract_block "$root/CLAUDE.md") "$claude_block"

grep -Fq 'Bắt đầu với kết quả được yêu cầu' "$agent_block"
grep -Fq 'chế độ chỉ đọc (read-only)' "$agent_block"
grep -Fq 'Không yêu cầu thao tác control-plane.' "$agent_block"
grep -Fq 'harness-docs/plans/active/' "$agent_block"
grep -Fq 'xác định quyền thẩm quyền (authority)' "$agent_block"
grep -Fq 'các tùy chọn mặc định có thể cấu hình không phải là quyền thẩm quyền' "$agent_block"
grep -Fq 'được yêu cầu rõ ràng bằng `$improve-harness`' "$agent_block"
grep -Fq 'mục đích sản phẩm vẫn mơ hồ' "$agent_block"
grep -Fq 'Các lệnh SQLite intake, story, trace, scoring, audit và proposal' "$agent_block"
! grep -Fq '## Current Upstream Goal' "$root/AGENTS.md"
! grep -Fq 'scripts/bootstrap-harness.sh' "$agent_block"
! grep -Fq 'query matrix --active --summary' "$agent_block"
! grep -Fq 'lane- and task-specific context' "$agent_block"
[[ "$(wc -c <"$agent_block" | tr -d ' ')" -le 2500 ]]

# The only mandatory initial Harness context stays near the approximately
# 1,000-word target. Everything else is retrieved because the task needs it.
entry_words=$(awk '{ words += NF } END { print words }' "$agent_block" "$workflow")
[[ "$entry_words" -le 1200 ]]

grep -Fq 'Does The Work Need Durable Memory?' "$workflow"
grep -Fq 'Does The Work Need Human Judgment?' "$workflow"
grep -Fq 'Add rate limiting' "$workflow"
grep -Fq 'must stop' "$workflow"
grep -Fq 'What Proves The Behavior?' "$workflow"
grep -Fq 'Operate The Application' "$workflow"
grep -Fq 'Improve The Harness' "$workflow"
grep -Fq 'No bootstrap, intake, story, matrix, trace, scoring, audit, or proposal command' "$workflow"
grep -Fiq 'harness' "$root/harness-docs/HARNESS.md"

[[ "$(grep -Fc '@AGENTS.md' "$claude_block")" == 1 ]]
! grep -Fq '@harness-docs/FEATURE_INTAKE.md' "$claude_block"
! grep -Fq 'query matrix' "$claude_block"

for payload in \
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
  harness-docs/WORKFLOW.md \
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
  grep -Fxq "$payload" "$root/scripts/harness-install-files.txt"
done

grep -Fq 'allow_implicit_invocation: false' \
  "$root/.agents/skills/onboard-repository/agents/openai.yaml"
grep -Fq 'allow_implicit_invocation: false' \
  "$root/.agents/skills/audit-onboarding-proposal/agents/openai.yaml"
grep -Fq 'allow_implicit_invocation: false' \
  "$root/.agents/skills/improve-harness/agents/openai.yaml"

for source_only in scripts/agent-harness-block.md scripts/claude-harness-block.md; do
  ! grep -Fxq "$source_only" "$root/scripts/harness-install-files.txt"
done

grep -Fq 'read_source_text "scripts/agent-harness-block.md"' "$root/scripts/install-harness.sh"
grep -Fq 'read_source_text "scripts/claude-harness-block.md"' "$root/scripts/install-harness.sh"
grep -Fq 'REFRESH_AGENT_SHIM=1' "$root/scripts/install-harness.sh"
grep -Fq 'CLI_PAYLOAD_MANIFEST="scripts/harness-cli-install-files.txt"' "$root/scripts/install-harness.sh"
grep -Fq 'ENGINEERING_WISDOM_PAYLOAD_MANIFEST="scripts/engineering-wisdom-install-files.txt"' "$root/scripts/install-harness.sh"
! grep -Fq "cat <<'EOF'" <(sed -n '/agent_shim_block()/,/^}/p' "$root/scripts/install-harness.sh")

# PowerShell is asserted statically on hosts without pwsh. Runtime coverage is
# provided by test-install-harness-modes.ps1 in the Windows release job.
grep -Fq 'Read-SourceText "scripts/agent-harness-block.md"' "$root/scripts/install-harness.ps1"
grep -Fq '$RefreshAgentShim = $true' "$root/scripts/install-harness.ps1"
grep -Fq '$script:CliPayloadManifest = "scripts/harness-cli-install-files.txt"' "$root/scripts/install-harness.ps1"
grep -Fq '$script:EngineeringWisdomPayloadManifest = "scripts/engineering-wisdom-install-files.txt"' "$root/scripts/install-harness.ps1"
grep -Fq 'Assert-HarnessMarkers $content "AGENTS.md"' "$root/scripts/install-harness.ps1"
! grep -Fq '<!-- HARNESS:BEGIN -->' <(sed -n '/function Get-AgentShimBlock/,/^}/p' "$root/scripts/install-harness.ps1")

echo "repository-centered authority, bounded context, canonical shims, and installer parity passed"
