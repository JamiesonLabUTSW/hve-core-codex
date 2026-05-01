#!/usr/bin/env bash
set -euo pipefail

source_repo="${1:-../hve-core}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_root="$(cd "${source_repo}" && pwd)"
source_skills="${source_root}/.github/skills"
plugin_root="${repo_root}/plugins/hve-core-codex"
dest_skills="${plugin_root}/skills"

if [[ ! -d "${source_skills}" ]]; then
  echo "Could not find HVE Core skills at: ${source_skills}" >&2
  exit 1
fi

mkdir -p "${dest_skills}"

skills=(
  "coding-standards/python-foundational"
  "experimental/customer-card-render"
  "experimental/powerpoint"
  "experimental/video-to-gif"
  "experimental/vscode-playwright"
  "gitlab/gitlab"
  "installer/hve-core-installer"
  "jira/jira"
  "security/owasp-agentic"
  "security/owasp-cicd"
  "security/owasp-infrastructure"
  "security/owasp-llm"
  "security/owasp-mcp"
  "security/owasp-top-10"
  "security/secure-by-design"
  "security/security-reviewer-formats"
  "shared/pr-reference"
)

for skill_path in "${skills[@]}"; do
  src="${source_skills}/${skill_path}"
  skill_name="$(basename "${skill_path}")"
  dst="${dest_skills}/${skill_name}"

  if [[ ! -f "${src}/SKILL.md" ]]; then
    echo "Skipping ${skill_path}: missing SKILL.md" >&2
    continue
  fi

  mkdir -p "${dst}"
  rsync -a \
    --exclude "tests/" \
    --exclude "__pycache__/" \
    --exclude ".pytest_cache/" \
    "${src}/" "${dst}/"
done

for file_name in LICENSE THIRD-PARTY-NOTICES; do
  if [[ -f "${source_root}/${file_name}" ]]; then
    cp "${source_root}/${file_name}" "${repo_root}/${file_name}"
    cp "${source_root}/${file_name}" "${plugin_root}/${file_name}"
  fi
done

echo "Synced ${#skills[@]} HVE Core skill packages into ${dest_skills}"
