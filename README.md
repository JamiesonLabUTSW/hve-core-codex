# HVE Core Codex Plugin

This repository packages the upstream HVE Core All bundle as a Codex CLI compatible plugin.

HVE Core upstream: <https://github.com/microsoft/hve-core>

## What Is Included

The Codex plugin lives at `plugins/hve-core-codex/` and is synced from upstream
`plugins/hve-core-all` where possible.

Generated from upstream:

| Path | Purpose |
|---|---|
| `plugins/hve-core-codex/agents/` | HVE Core agent definitions, including RPI, planning, review, security, backlog, and design-thinking agents. |
| `plugins/hve-core-codex/commands/` | Prompt-derived Codex slash commands plus local HVE Codex helper commands. |
| `plugins/hve-core-codex/instructions/` | HVE Core coding, workflow, security, RAI, and domain instruction references. |
| `plugins/hve-core-codex/skills/` | Codex skill packages, flattened for Codex discovery. |
| `plugins/hve-core-codex/docs/templates/` | Reusable planning, review, ADR, BRD, security, SSSC, and RAI templates. |
| `plugins/hve-core-codex/scripts/lib/` | Small upstream shared helper scripts bundled with generated plugins. |
| `github-actions/workflows/` | Optional GitHub Agentic Workflow automation package for consumer repos. |
| `github-actions/artifacts/.github/` | Source agents, instructions, and skills expected by the optional workflow package. |

Hand-maintained in this port:

| Path | Purpose |
|---|---|
| `.agents/plugins/marketplace.json` | Local marketplace entry for Codex. |
| `plugins/hve-core-codex/.codex-plugin/plugin.json` | Codex plugin manifest. |
| `scripts/sync-upstream.sh` | Deterministic sync from upstream HVE Core. |
| `scripts/verify-port.sh` | Port verification checks. |
| `overlays/hve-core-codex/` | Codex-specific helper commands copied after upstream sync. |
| `PORTING.md` | Porting rules, exclusions, and known limitations. |

## Install Locally

From this repository:

```bash
codex plugin marketplace add /Users/michael/sideprojects/hve-core-codex
```

If the marketplace is already registered, refresh it after changes:

```bash
codex plugin marketplace upgrade hve-core-codex-local
```

## Sync From Upstream

Run this from the repo root when the adjacent upstream HVE Core checkout changes:

```bash
./scripts/sync-upstream.sh ../hve-core
./scripts/verify-port.sh
```

The sync writes `upstream.lock.json` with the upstream commit, version, generated
counts, and known exclusions. Treat generated directories as vendored output:
refresh them with the sync script instead of editing them by hand.

## Optional GitHub Automation

The Codex plugin provides interactive agents, commands, instructions, templates,
and skills. GitHub event automation is packaged separately under
`github-actions/workflows/` so consumer repositories can opt in explicitly.

See `github-actions/README.md` before installing these workflows into another
repository. They can perform write actions such as labeling issues, commenting,
submitting PR reviews, creating issues, and creating pull requests when the
required GitHub Agentic Workflow secrets and permissions are configured. The
package also includes `github-actions/artifacts/.github/` because the workflows
import HVE Core agents and instructions at runtime.

## Licensing

Most content is MIT licensed. Some security skills contain third-party reference
content under the licenses declared in each skill's frontmatter and in
`THIRD-PARTY-NOTICES`.
