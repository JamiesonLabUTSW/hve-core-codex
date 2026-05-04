# Upstream Reconciliation Guide

Use this guide when upstream `microsoft/hve-core` changes.

## Refresh

Run from the repository root:

```bash
./scripts/sync-upstream.sh ../hve-core
./scripts/verify-port.sh
```

The sync copies upstream generated assets first, then applies `overlays/hve-core-codex/`.

## Inspect command and agent changes

Review changed runtime-facing files:

```bash
git diff --name-status -- plugins/hve-core-codex/commands plugins/hve-core-codex/agents
```

For every new command:

- Confirm it has frontmatter `description` or a clear command heading.
- Confirm any `agent:` reference resolves to a packaged agent name or file stem.
- Decide whether it belongs in an existing wrapper route map.
- Add route coverage only when the workflow is user-facing or important enough to be discoverable through skills.

For every new agent:

- Confirm it has `name` and `description` metadata.
- Confirm commands that reference it resolve through the runtime surface audit.
- Do not map the agent to a Codex `spawn_agent` role unless the Codex runtime exposes that role.
- Confirm `plugins/hve-core-codex/generated/codex-agents/manifest.json` includes a generated entry for the agent.
- Confirm the generated TOML has a deterministic `hve_...` name, source metadata, and compatibility notes for unsupported Copilot frontmatter.
- If `scripts/generate-codex-agents.js --check` fails on an unknown frontmatter key, update the generator with an explicit mapping or advisory-only decision.
- Decide whether the agent belongs in a generated install profile: `core`, `review`, `security`, `automation`, or `all`.

## Generated Codex custom agents

Generated Codex custom-agent TOML lives under:

```text
plugins/hve-core-codex/generated/codex-agents/
```

These TOML files are generated package artifacts. They are not active Codex
custom agents until a user explicitly installs them into `.codex/agents/` for a
project or `~/.codex/agents/` for user-global use.

Use these commands when reconciling generated agents:

```bash
node scripts/generate-codex-agents.js --check
scripts/install-codex-agents.sh --dry-run --scope project --target /path/to/repo
```

Do not add an undocumented `agents` field to `.codex-plugin/plugin.json`, and
do not silently write generated TOML into `~/.codex/agents/`.

## Wrapper route policy

- `hve-core-workflows`: RPI, task lifecycle, checkpoint, prompt, git, doc-ops, pull request.
- `hve-security-workflows`: security review, OWASP, Secure by Design, security planning, SSSC, RAI security handoff, risk, incident response.
- `hve-pr-workflows`: PR reference, PR description, code review, PR review output.
- `hve-github-automation`: optional GitHub Agentic Workflow package and GitHub backlog commands.
- `hve-port-maintainer`: sync, verification, surface audit, and wrapper reconciliation.
- `hve-codex-agent-porting`: generated Codex custom-agent TOML generation, audit, install, and upstream new-agent reconciliation.

Prefer updating route references over duplicating upstream instructions in wrapper skill bodies.
Use plugin-root-relative paths in route files, such as `commands/hve-core/rpi.md` and `agents/hve-core/rpi-agent.md`. Do not use repository layout paths such as `plugins/hve-core-codex/commands/hve-core/rpi.md`.

Keep upstream skills in their upstream category layout, such as `skills/coding-standards/python-foundational/SKILL.md`, `skills/security/owasp-top-10/SKILL.md`, and `skills/shared/pr-reference/SKILL.md`. Do not flatten upstream skills into `skills/<skill-name>/`; upstream agents and instructions may rely on category paths.

Do not port upstream installer docs as Codex skills. The upstream `skills/installer/` collection targets VS Code and GitHub Copilot setup flows for adding HVE Core assets to another repository, so the sync script excludes it from both the Codex plugin payload and the optional GitHub automation artifact bundle.
