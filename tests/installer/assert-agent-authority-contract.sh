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

required_agent_text=(
  'Bắt đầu với kết quả được yêu cầu'
  'chế độ chỉ đọc (read-only)'
  'Không yêu cầu thao tác control-plane.'
  'harness-docs/plans/active/'
  'xác định quyền thẩm quyền (authority)'
  'các tùy chọn mặc định có thể cấu hình không phải là quyền thẩm quyền'
  'được yêu cầu rõ ràng bằng `$improve-harness`'
  'mục đích sản phẩm vẫn mơ hồ'
  'Harness không có cơ sở dữ liệu nhiệm vụ hoặc vòng đời điều phối.'
)
for text in "${required_agent_text[@]}"; do
  grep -Fq "$text" "$agent_block"
done

[[ "$(wc -c <"$agent_block" | tr -d ' ')" -le 2500 ]]
entry_words=$(awk '{ words += NF } END { print words }' "$agent_block" "$workflow")
[[ "$entry_words" -le 1200 ]]

required_workflow_text=(
  'Does The Work Need Durable Memory?'
  'Does The Work Need Human Judgment?'
  'Add rate limiting'
  'must stop'
  'What Proves The Behavior?'
  'Operate The Application'
  'Improve The Harness'
)
for text in "${required_workflow_text[@]}"; do
  grep -Fq "$text" "$workflow"
done

[[ "$(grep -Fc '@AGENTS.md' "$claude_block")" == 1 ]]
! grep -Fq 'query matrix' "$claude_block"

payloads=(
  .agents/skills/audit-onboarding-proposal/SKILL.md
  .agents/skills/audit-onboarding-proposal/agents/openai.yaml
  .agents/skills/audit-onboarding-proposal/scripts/validate_evidence_capsule.py
  .agents/skills/improve-harness/SKILL.md
  .agents/skills/improve-harness/agents/openai.yaml
  .agents/skills/onboard-repository/SKILL.md
  .agents/skills/onboard-repository/agents/openai.yaml
  .agents/skills/onboard-repository/references/evidence-capsule-v1.md
  .agents/skills/onboard-repository/references/evidence-capsule-v2.md
  .agents/skills/onboard-repository/scripts/emit_evidence_bundle.py
  .agents/skills/onboard-repository/scripts/render_patch.py
  harness-docs/WORKFLOW.md
  harness-docs/README.md
  harness-docs/product/README.md
  harness-docs/plans/README.md
  harness-docs/plans/active/README.md
  harness-docs/plans/completed/README.md
  harness-docs/decisions/README.md
  harness-docs/templates/application-runbook.md
  harness-docs/templates/decision.md
  harness-docs/templates/exec-plan.md
  harness-docs/templates/harness-improvement.md
)
for payload in "${payloads[@]}"; do
  grep -Fxq "$payload" "$root/scripts/harness-install-files.txt"
done

skill_metadata=(
  .agents/skills/onboard-repository/agents/openai.yaml
  .agents/skills/audit-onboarding-proposal/agents/openai.yaml
  .agents/skills/improve-harness/agents/openai.yaml
)
for metadata in "${skill_metadata[@]}"; do
  grep -Fq 'allow_implicit_invocation: false' "$root/$metadata"
done

grep -Fq 'read_source_text "scripts/agent-harness-block.md"' "$root/scripts/install-harness.sh"
grep -Fq 'read_source_text "scripts/claude-harness-block.md"' "$root/scripts/install-harness.sh"
grep -Fq 'REFRESH_AGENT_SHIM=1' "$root/scripts/install-harness.sh"
grep -Fq 'ENGINEERING_WISDOM_PAYLOAD_MANIFEST="scripts/engineering-wisdom-install-files.txt"' "$root/scripts/install-harness.sh"
! grep -Fq 'CLI_PAYLOAD_MANIFEST' "$root/scripts/install-harness.sh"

grep -Fq 'Read-SourceText "scripts/agent-harness-block.md"' "$root/scripts/install-harness.ps1"
grep -Fq '[switch]$RefreshAgentShim' "$root/scripts/install-harness.ps1"
grep -Fq '$script:EngineeringWisdomPayloadManifest = "scripts/engineering-wisdom-install-files.txt"' "$root/scripts/install-harness.ps1"
! grep -Fq 'CliPayloadManifest' "$root/scripts/install-harness.ps1"

echo "repository authority, bounded context, canonical shims, and core-only installer parity passed"
