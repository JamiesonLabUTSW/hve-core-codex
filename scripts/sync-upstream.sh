#!/usr/bin/env bash
set -euo pipefail

source_repo="${1:-../hve-core}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_root="$(cd "${source_repo}" && pwd)"
source_plugin="${source_root}/plugins/hve-core-all"
plugin_root="${repo_root}/plugins/hve-core-codex"
automation_root="${repo_root}/github-actions"
workflow_dest="${automation_root}/workflows"
automation_artifacts="${automation_root}/artifacts/.github"
overlay_root="${repo_root}/overlays/hve-core-codex"

if [[ ! -d "${source_plugin}" ]]; then
  echo "Could not find upstream HVE Core All plugin at: ${source_plugin}" >&2
  exit 1
fi

if [[ ! -f "${plugin_root}/.codex-plugin/plugin.json" ]]; then
  echo "Could not find Codex plugin manifest at: ${plugin_root}/.codex-plugin/plugin.json" >&2
  exit 1
fi

copy_tree() {
  local src="$1"
  local dst="$2"

  if [[ ! -d "${src}" ]]; then
    echo "Missing upstream directory: ${src}" >&2
    exit 1
  fi

  rm -rf "${dst}"
  mkdir -p "${dst}"
  rsync -aL \
    --exclude "tests/" \
    --exclude "__pycache__/" \
    --exclude ".pytest_cache/" \
    --exclude ".mypy_cache/" \
    "${src}/" "${dst}/"
}

copy_file_if_present() {
  local src="$1"
  local dst="$2"

  if [[ -f "${src}" ]]; then
    mkdir -p "$(dirname "${dst}")"
    cp "${src}" "${dst}"
  fi
}

count_files() {
  local dir="$1"
  local pattern="$2"

  if [[ ! -d "${dir}" ]]; then
    echo "0"
    return
  fi

  find -L "${dir}" -type f -name "${pattern}" | wc -l | tr -d ' '
}

count_all_files() {
  local dir="$1"

  if [[ ! -d "${dir}" ]]; then
    echo "0"
    return
  fi

  find -L "${dir}" -type f | wc -l | tr -d ' '
}

echo "Syncing HVE Core Codex plugin from ${source_root}"

copy_tree "${source_plugin}/agents" "${plugin_root}/agents"
copy_tree "${source_plugin}/commands" "${plugin_root}/commands"
copy_tree "${source_plugin}/instructions" "${plugin_root}/instructions"
copy_tree "${source_plugin}/docs/templates" "${plugin_root}/docs/templates"
copy_tree "${source_plugin}/scripts/lib" "${plugin_root}/scripts/lib"

rm -rf "${plugin_root}/skills"
mkdir -p "${plugin_root}/skills"

while IFS= read -r skill_md; do
  skill_dir="$(dirname "${skill_md}")"
  skill_name="$(basename "${skill_dir}")"

  if [[ "${skill_name}" == "owasp-docker" ]]; then
    echo "Skipping removed/incompatible skill: ${skill_name}"
    continue
  fi

  mkdir -p "${plugin_root}/skills/${skill_name}"
  rsync -aL \
    --exclude "tests/" \
    --exclude "__pycache__/" \
    --exclude ".pytest_cache/" \
    --exclude ".mypy_cache/" \
    "${skill_dir}/" "${plugin_root}/skills/${skill_name}/"
done < <(find -L "${source_plugin}/skills" -type f -name "SKILL.md" | sort)

if [[ -d "${overlay_root}" ]]; then
  rsync -a "${overlay_root}/" "${plugin_root}/"
fi

rm -rf "${workflow_dest}"
mkdir -p "${workflow_dest}"

workflow_files=(
  "dependency-pr-review.md"
  "dependency-pr-review.lock.yml"
  "doc-update-check.md"
  "doc-update-check.lock.yml"
  "issue-implement.md"
  "issue-implement.lock.yml"
  "issue-triage.md"
  "issue-triage.lock.yml"
  "pr-review.md"
  "pr-review.lock.yml"
)

for workflow_file in "${workflow_files[@]}"; do
  copy_file_if_present \
    "${source_root}/.github/workflows/${workflow_file}" \
    "${workflow_dest}/${workflow_file}"
done

rm -rf "${automation_artifacts}"
mkdir -p "${automation_artifacts}"
copy_tree "${source_root}/.github/agents" "${automation_artifacts}/agents"
copy_tree "${source_root}/.github/instructions" "${automation_artifacts}/instructions"
copy_tree "${source_root}/.github/skills" "${automation_artifacts}/skills"
rm -rf "${automation_artifacts}/skills/security/owasp-docker"
copy_file_if_present "${source_root}/.github/copilot-instructions.md" "${automation_artifacts}/copilot-instructions.md"
copy_file_if_present "${source_root}/.github/PULL_REQUEST_TEMPLATE.md" "${automation_artifacts}/PULL_REQUEST_TEMPLATE.md"
mkdir -p "${automation_artifacts}/ISSUE_TEMPLATE"
copy_file_if_present "${source_root}/.github/ISSUE_TEMPLATE/bug-report.yml" "${automation_artifacts}/ISSUE_TEMPLATE/bug-report.yml"

for file_name in LICENSE THIRD-PARTY-NOTICES; do
  copy_file_if_present "${source_root}/${file_name}" "${repo_root}/${file_name}"
  copy_file_if_present "${source_root}/${file_name}" "${plugin_root}/${file_name}"
done

upstream_commit="$(git -C "${source_root}" rev-parse HEAD)"
upstream_version="$(node -e "process.stdout.write(require('${source_root}/package.json').version)")"
synced_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

upstream_agents="$(count_files "${source_plugin}/agents" "*.md")"
upstream_commands="$(count_files "${source_plugin}/commands" "*.md")"
upstream_instructions="$(count_files "${source_plugin}/instructions" "*.md")"
upstream_skills="$(find -L "${source_plugin}/skills" -type f -name "SKILL.md" | wc -l | tr -d ' ')"
templates="$(count_all_files "${plugin_root}/docs/templates")"
automation_workflows="$(count_all_files "${workflow_dest}")"
automation_agent_files="$(count_files "${automation_artifacts}/agents" "*.agent.md")"
automation_instruction_files="$(count_files "${automation_artifacts}/instructions" "*.instructions.md")"
automation_skill_files="$(count_files "${automation_artifacts}/skills" "SKILL.md")"
final_agents="$(count_files "${plugin_root}/agents" "*.md")"
final_commands="$(count_files "${plugin_root}/commands" "*.md")"
final_instructions="$(count_files "${plugin_root}/instructions" "*.md")"
final_skills="$(count_files "${plugin_root}/skills" "SKILL.md")"

export SOURCE_ROOT="${source_root}"
export UPSTREAM_COMMIT="${upstream_commit}"
export UPSTREAM_VERSION="${upstream_version}"
export SYNCED_AT="${synced_at}"
export UPSTREAM_AGENTS="${upstream_agents}"
export UPSTREAM_COMMANDS="${upstream_commands}"
export UPSTREAM_INSTRUCTIONS="${upstream_instructions}"
export UPSTREAM_SKILLS="${upstream_skills}"
export TEMPLATES="${templates}"
export AUTOMATION_WORKFLOWS="${automation_workflows}"
export AUTOMATION_AGENT_FILES="${automation_agent_files}"
export AUTOMATION_INSTRUCTION_FILES="${automation_instruction_files}"
export AUTOMATION_SKILL_FILES="${automation_skill_files}"
export FINAL_AGENTS="${final_agents}"
export FINAL_COMMANDS="${final_commands}"
export FINAL_INSTRUCTIONS="${final_instructions}"
export FINAL_SKILLS="${final_skills}"

node > "${repo_root}/upstream.lock.json" <<'NODE'
const data = {
  source: {
    repository: "https://github.com/microsoft/hve-core",
    localPath: process.env.SOURCE_ROOT,
    commit: process.env.UPSTREAM_COMMIT,
    version: process.env.UPSTREAM_VERSION,
    bundle: "plugins/hve-core-all"
  },
  syncedAt: process.env.SYNCED_AT,
  artifactCounts: {
    upstream: {
      agents: Number(process.env.UPSTREAM_AGENTS),
      commands: Number(process.env.UPSTREAM_COMMANDS),
      instructions: Number(process.env.UPSTREAM_INSTRUCTIONS),
      skills: Number(process.env.UPSTREAM_SKILLS)
    },
    final: {
      agents: Number(process.env.FINAL_AGENTS),
      commands: Number(process.env.FINAL_COMMANDS),
      instructions: Number(process.env.FINAL_INSTRUCTIONS),
      skills: Number(process.env.FINAL_SKILLS),
      docsTemplateFiles: Number(process.env.TEMPLATES),
      automationWorkflowFiles: Number(process.env.AUTOMATION_WORKFLOWS),
      automationAgentFiles: Number(process.env.AUTOMATION_AGENT_FILES),
      automationInstructionFiles: Number(process.env.AUTOMATION_INSTRUCTION_FILES),
      automationSkillFiles: Number(process.env.AUTOMATION_SKILL_FILES)
    }
  },
  generatedDirectories: [
    "plugins/hve-core-codex/agents",
    "plugins/hve-core-codex/commands",
    "plugins/hve-core-codex/instructions",
    "plugins/hve-core-codex/skills",
    "plugins/hve-core-codex/docs/templates",
    "plugins/hve-core-codex/scripts/lib",
    "github-actions/workflows",
    "github-actions/artifacts/.github"
  ],
  overlays: [
    "overlays/hve-core-codex"
  ],
  excludedArtifacts: [
    {
      name: "owasp-docker",
      reason: "Upstream marks this skill as removed due distribution-incompatible source licensing."
    },
    {
      name: "co-located tests and caches",
      reason: "Runtime plugin payload excludes test fixtures and local cache directories."
    }
  ]
};

process.stdout.write(`${JSON.stringify(data, null, 2)}\n`);
NODE

echo "Synced upstream HVE Core ${upstream_version} (${upstream_commit})"
echo "Final counts: agents=${final_agents}, commands=${final_commands}, instructions=${final_instructions}, skills=${final_skills}, workflowFiles=${automation_workflows}"
echo "Automation artifacts: agents=${automation_agent_files}, instructions=${automation_instruction_files}, skills=${automation_skill_files}"
