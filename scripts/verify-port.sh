#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
plugin_root="${repo_root}/plugins/hve-core-codex"
workflow_dir="${repo_root}/github-actions/workflows"
automation_artifacts="${repo_root}/github-actions/artifacts/.github"
lock_file="${repo_root}/upstream.lock.json"

fail() {
  echo "verify-port: $*" >&2
  exit 1
}

count_files() {
  local dir="$1"
  local pattern="$2"

  [[ -d "${dir}" ]] || {
    echo "0"
    return
  }

  find "${dir}" -type f -name "${pattern}" | wc -l | tr -d ' '
}

count_all_files() {
  local dir="$1"

  [[ -d "${dir}" ]] || {
    echo "0"
    return
  }

  find "${dir}" -type f | wc -l | tr -d ' '
}

json_files=(
  "${repo_root}/.agents/plugins/marketplace.json"
  "${plugin_root}/.codex-plugin/plugin.json"
  "${lock_file}"
)

for json_file in "${json_files[@]}"; do
  [[ -f "${json_file}" ]] || fail "Missing JSON file: ${json_file}"
  node -e "JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'))" "${json_file}" \
    || fail "Invalid JSON: ${json_file}"
done

export PLUGIN_MANIFEST="${plugin_root}/.codex-plugin/plugin.json"
export LOCK_FILE="${lock_file}"

node <<'NODE'
const fs = require("fs");
const manifest = JSON.parse(fs.readFileSync(process.env.PLUGIN_MANIFEST, "utf8"));
const lock = JSON.parse(fs.readFileSync(process.env.LOCK_FILE, "utf8"));
const upstreamVersion = lock.source?.version;
const pluginVersion = manifest.version;

if (!upstreamVersion || !pluginVersion) {
  console.error("Missing upstream or plugin version metadata");
  process.exit(1);
}

if (pluginVersion !== upstreamVersion && !pluginVersion.startsWith(`${upstreamVersion}-codex.`)) {
  console.error(
    `Plugin version ${pluginVersion} must equal upstream ${upstreamVersion} or use ${upstreamVersion}-codex.N`
  );
  process.exit(1);
}
NODE

required_dirs=(
  "${plugin_root}/agents"
  "${plugin_root}/commands"
  "${plugin_root}/instructions"
  "${plugin_root}/skills"
  "${plugin_root}/docs/templates"
  "${plugin_root}/scripts/lib"
  "${workflow_dir}"
  "${automation_artifacts}/agents"
  "${automation_artifacts}/instructions"
  "${automation_artifacts}/skills"
)

for dir in "${required_dirs[@]}"; do
  [[ -d "${dir}" ]] || fail "Missing generated directory: ${dir}"
done

agents="$(count_files "${plugin_root}/agents" "*.md")"
commands="$(count_files "${plugin_root}/commands" "*.md")"
instructions="$(count_files "${plugin_root}/instructions" "*.md")"
skills="$(count_files "${plugin_root}/skills" "SKILL.md")"
templates="$(count_all_files "${plugin_root}/docs/templates")"
workflows="$(count_all_files "${workflow_dir}")"
automation_agents="$(count_files "${automation_artifacts}/agents" "*.agent.md")"
automation_instructions="$(count_files "${automation_artifacts}/instructions" "*.instructions.md")"
automation_skills="$(count_files "${automation_artifacts}/skills" "SKILL.md")"

[[ "${agents}" -ge 54 ]] || fail "Expected at least 54 agents, found ${agents}"
[[ "${commands}" -ge 68 ]] || fail "Expected at least 68 commands, found ${commands}"
[[ "${instructions}" -ge 104 ]] || fail "Expected at least 104 instructions, found ${instructions}"
[[ "${skills}" -ge 22 ]] || fail "Expected at least 22 skills including Codex wrappers, found ${skills}"
[[ "${templates}" -ge 12 ]] || fail "Expected at least 12 docs template files, found ${templates}"
[[ "${workflows}" -eq 10 ]] || fail "Expected 10 GitHub workflow package files, found ${workflows}"
[[ "${automation_agents}" -ge 58 ]] || fail "Expected at least 58 automation agent files, found ${automation_agents}"
[[ "${automation_instructions}" -ge 107 ]] || fail "Expected at least 107 automation instruction files, found ${automation_instructions}"
[[ "${automation_skills}" -eq 17 ]] || fail "Expected 17 automation skill files, found ${automation_skills}"

required_wrapper_skills=(
  "hve-core-workflows"
  "hve-security-workflows"
  "hve-pr-workflows"
  "hve-github-automation"
  "hve-port-maintainer"
)

for skill_name in "${required_wrapper_skills[@]}"; do
  [[ -f "${plugin_root}/skills/${skill_name}/SKILL.md" ]] || fail "Missing Codex wrapper skill: ${skill_name}"
done

if find "${plugin_root}/skills" -path "*owasp-docker*" -print -quit | grep -q .; then
  fail "owasp-docker must not be included in the plugin payload"
fi

if find "${automation_artifacts}/skills" -path "*owasp-docker*" -print -quit | grep -q .; then
  fail "owasp-docker must not be included in the automation artifact payload"
fi

workflow_bases=(
  "dependency-pr-review"
  "doc-update-check"
  "issue-implement"
  "issue-triage"
  "pr-review"
)

for base in "${workflow_bases[@]}"; do
  [[ -f "${workflow_dir}/${base}.md" ]] || fail "Missing workflow source: ${base}.md"
  [[ -f "${workflow_dir}/${base}.lock.yml" ]] || fail "Missing workflow lock: ${base}.lock.yml"
done

required_workflow_agents=(
  "issue-triage.agent.md"
  "dependency-reviewer.agent.md"
  "doc-update-checker.agent.md"
  "hve-core/task-implementor.agent.md"
  "hve-core/pr-review.agent.md"
)

for agent_path in "${required_workflow_agents[@]}"; do
  [[ -f "${automation_artifacts}/agents/${agent_path}" ]] || fail "Missing workflow import agent: ${agent_path}"
done

node "${repo_root}/scripts/audit-runtime-surfaces.js" "${plugin_root}" \
  || fail "Runtime command/agent surface audit failed"

export ACTUAL_AGENTS="${agents}"
export ACTUAL_COMMANDS="${commands}"
export ACTUAL_INSTRUCTIONS="${instructions}"
export ACTUAL_SKILLS="${skills}"
export ACTUAL_TEMPLATES="${templates}"
export ACTUAL_WORKFLOWS="${workflows}"
export ACTUAL_AUTOMATION_AGENTS="${automation_agents}"
export ACTUAL_AUTOMATION_INSTRUCTIONS="${automation_instructions}"
export ACTUAL_AUTOMATION_SKILLS="${automation_skills}"
export LOCK_FILE="${lock_file}"

node <<'NODE'
const fs = require("fs");
const lock = JSON.parse(fs.readFileSync(process.env.LOCK_FILE, "utf8"));
const expected = lock.artifactCounts?.final || {};
const actual = {
  agents: Number(process.env.ACTUAL_AGENTS),
  commands: Number(process.env.ACTUAL_COMMANDS),
  instructions: Number(process.env.ACTUAL_INSTRUCTIONS),
  skills: Number(process.env.ACTUAL_SKILLS),
  docsTemplateFiles: Number(process.env.ACTUAL_TEMPLATES),
  automationWorkflowFiles: Number(process.env.ACTUAL_WORKFLOWS),
  automationAgentFiles: Number(process.env.ACTUAL_AUTOMATION_AGENTS),
  automationInstructionFiles: Number(process.env.ACTUAL_AUTOMATION_INSTRUCTIONS),
  automationSkillFiles: Number(process.env.ACTUAL_AUTOMATION_SKILLS)
};

for (const [key, value] of Object.entries(actual)) {
  if (expected[key] !== value) {
    console.error(`upstream.lock.json count mismatch for ${key}: expected ${expected[key]}, actual ${value}`);
    process.exit(1);
  }
}
NODE

echo "verify-port: ok"
echo "agents=${agents} commands=${commands} instructions=${instructions} skills=${skills} templates=${templates} workflowFiles=${workflows}"
echo "automationAgents=${automation_agents} automationInstructions=${automation_instructions} automationSkills=${automation_skills}"
