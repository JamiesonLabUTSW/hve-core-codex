# HVE Codex Agent Porting Workflow

Use this reference when maintaining generated Codex custom-agent artifacts for the HVE Core Codex port.

## Runtime Boundary

The plugin preserves upstream HVE Core agent markdown under `plugins/hve-core-codex/agents/`, but Codex custom agents are TOML files loaded from:

* `.codex/agents/` in a trusted project
* `~/.codex/agents/` for user-global agents

Generated TOML under `plugins/hve-core-codex/generated/codex-agents/` is packaged output. It remains inert until explicitly copied into one of those Codex custom-agent directories.

## Generate

Run from the repository root:

```bash
node scripts/generate-codex-agents.js
```

The generator reads `plugins/hve-core-codex/agents/**/*.md` and writes:

* `plugins/hve-core-codex/generated/codex-agents/*.toml`
* `plugins/hve-core-codex/generated/codex-agents/manifest.json`
* `plugins/hve-core-codex/generated/codex-agents/README.md`

## Audit

Run:

```bash
node scripts/generate-codex-agents.js --check
./scripts/verify-port.sh
```

Verification must fail when:

* A packaged upstream agent has no generated TOML.
* Generated TOML is stale after an upstream sync.
* A generated name collides with another generated name or a built-in Codex agent name.
* Upstream adds an unknown frontmatter key that has not been intentionally mapped.

## Install

Default to project-scoped installation:

```bash
scripts/install-codex-agents.sh --scope project --target /path/to/repo
```

Use `--dry-run` before writing:

```bash
scripts/install-codex-agents.sh --dry-run --scope project --target /path/to/repo
```

Use `--scope user` only when the user explicitly wants global agents in `~/.codex/agents/`.

Install profiles come from `manifest.json`:

* `core` - HVE Core task, RPI, prompt, and subagent workflows.
* `review` - Code review and validation-focused agents.
* `security` - Security, SSSC, and RAI planning/review agents.
* `automation` - ADO, GitHub, and Jira backlog agents.
* `all` - Every generated agent.

## Upstream New-Agent Checklist

When upstream adds or changes an agent:

1. Run `./scripts/sync-upstream.sh ../hve-core`.
2. Confirm `plugins/hve-core-codex/agents/**/*.md` includes the new or changed source.
3. Confirm `plugins/hve-core-codex/generated/codex-agents/manifest.json` includes a generated entry for the source path.
4. Confirm the generated TOML includes source metadata and compatibility notes.
5. If generation fails on an unknown frontmatter key, update the generator allowlist with an explicit mapping or advisory-only decision.
6. Decide whether the new agent belongs in an install profile.
7. Decide whether a wrapper skill route map needs a user-facing route update.
8. Run `./scripts/verify-port.sh`.

## Do Not Do

* Do not add an undocumented `agents` field to `.codex-plugin/plugin.json`.
* Do not claim plugin installation activates generated TOML as Codex custom agents.
* Do not silently write to `~/.codex/agents/`.
* Do not hand-edit generated TOML for durable changes.
