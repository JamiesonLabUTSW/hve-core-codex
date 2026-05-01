# HVE Core Codex Plugin

This repository packages HVE Core skills as a Codex CLI compatible plugin.

The local marketplace manifest lives at `.agents/plugins/marketplace.json`.
The plugin payload lives at `plugins/hve-core-codex/`, with its manifest at
`plugins/hve-core-codex/.codex-plugin/plugin.json` and skills under
`plugins/hve-core-codex/skills/`.

The plugin package name is `hve-core-codex` so it is distinct from the upstream
HVE Core VS Code extension and source repository.

## Included Skills

This plugin currently mirrors the HVE Core skill packages that are distributed
through the HVE Core collections, excluding `owasp-docker` because HVE Core marks
that skill as removed from distribution.

| Skill | Purpose |
|---|---|
| `customer-card-render` | Generate customer-card PowerPoint content YAML from Design Thinking artifacts. |
| `gitlab` | Manage GitLab merge requests and pipelines with a Python CLI. |
| `hve-core-installer` | Guide HVE Core installation, environment detection, validation, and customization workflows. |
| `jira` | Search, inspect, create, update, transition, and comment on Jira issues. |
| `owasp-agentic` | OWASP Agentic Security Top 10 knowledge base. |
| `owasp-cicd` | OWASP CI/CD Top 10 knowledge base. |
| `owasp-infrastructure` | OWASP Infrastructure Top 10 knowledge base. |
| `owasp-llm` | OWASP Top 10 for LLM Applications knowledge base. |
| `owasp-mcp` | OWASP MCP Top 10 knowledge base. |
| `owasp-top-10` | OWASP Top 10 for Web Applications knowledge base. |
| `powerpoint` | Generate and manage PowerPoint decks with `python-pptx`. |
| `pr-reference` | Generate branch diff and commit reference XML for PRs and reviews. |
| `python-foundational` | Foundational Python coding standards and quality guidance. |
| `secure-by-design` | Secure by Design principles knowledge base. |
| `security-reviewer-formats` | Data contracts and report formats for HVE security review agents. |
| `video-to-gif` | Convert videos to optimized GIFs with FFmpeg. |
| `vscode-playwright` | Capture VS Code screenshots using Playwright MCP and `serve-web`. |

## Sync From HVE Core

Run this from the plugin repo root when the adjacent HVE Core checkout changes:

```bash
./scripts/sync-skills.sh ../hve-core
```

The sync copies skill directories into
`plugins/hve-core-codex/skills/<skill-name>/`, excludes co-located test
directories, and copies `LICENSE` plus `THIRD-PARTY-NOTICES` when available.

## Licensing

Most content is MIT licensed. Some security skills contain third-party reference
content under the licenses declared in each skill's frontmatter and in
`THIRD-PARTY-NOTICES`.
