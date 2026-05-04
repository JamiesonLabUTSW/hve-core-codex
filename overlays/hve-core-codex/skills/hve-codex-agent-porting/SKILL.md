---
name: hve-codex-agent-porting
description: Generate, audit, install, and explain HVE Core Codex custom-agent TOML artifacts, including upstream agent reconciliation, install profiles, and out-of-band project or user Codex agent installation.
---

# HVE Codex Agent Porting

Use this skill for generated Codex custom-agent workflows in the HVE Core Codex port.

## Workflow

1. Read [references/agent-porting.md](references/agent-porting.md).
2. For generation or audit requests, use `scripts/generate-codex-agents.js`.
3. For installation requests, use `scripts/install-codex-agents.sh` and keep project scope as the default.
4. For upstream sync reconciliation, compare packaged agent markdown, generated TOML, and `manifest.json`.

## Rules

- Generated TOML is not active just because the plugin is installed.
- Activate generated custom agents only through explicit out-of-band install to `.codex/agents/` or `~/.codex/agents/`.
- Do not overwrite unrelated user custom-agent TOML files.
- Keep generated agent changes deterministic and owned by `scripts/sync-upstream.sh`.
