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

## Wrapper route policy

- `hve-core-workflows`: RPI, task lifecycle, checkpoint, prompt, git, doc-ops, pull request.
- `hve-security-workflows`: security review, OWASP, Secure by Design, security planning, SSSC, RAI security handoff, risk, incident response.
- `hve-pr-workflows`: PR reference, PR description, code review, PR review output.
- `hve-github-automation`: optional GitHub Agentic Workflow package and GitHub backlog commands.
- `hve-port-maintainer`: sync, verification, surface audit, and wrapper reconciliation.

Prefer updating route references over duplicating upstream instructions in wrapper skill bodies.
Use plugin-root-relative paths in route files, such as `commands/hve-core/rpi.md` and `agents/hve-core/rpi-agent.md`. Do not use repository layout paths such as `plugins/hve-core-codex/commands/hve-core/rpi.md`.
