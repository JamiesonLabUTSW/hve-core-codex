# HVE Core Codex Plugin

HVE Core Codex brings High Velocity Engineering practices to Codex CLI. It
packages the upstream HVE Core All toolkit as a Codex plugin so you can use HVE
agents, commands, instructions, templates, and skills from a Codex workspace.

HVE Core upstream: <https://github.com/microsoft/hve-core>

This repository is both:

* a **user-facing Codex plugin** for HVE workflows; and
* a **downstream port** that syncs and adapts upstream HVE Core assets for
  Codex runtime surfaces.

If you are new to HVE, start with the workflow guidance below. If you maintain
the port, see [PORTING.md](PORTING.md).

## What HVE Adds

HVE Core turns AI assistance into a structured engineering workflow instead of a
one-shot code generation request.

The central practices are:

* **Research before implementation**: use RPI to turn uncertainty into verified
  context before changing files.
* **Artifact-backed handoffs**: keep research, plans, reviews, and decisions in
  files so work survives long sessions and context resets.
* **Human-guided execution**: the agent proposes, checks, and implements, but
  the human keeps intent, review, and acceptance authority.
* **Design Thinking before delivery**: when the real user problem is unclear,
  use the DT workflows to discover needs before moving into RPI.
* **Workflow-specific quality gates**: security, pull request review, backlog,
  prompt, and documentation workflows each bring their own checks and templates.

## Choose A Path

| You need to... | Use this HVE path | Example prompt |
|---|---|---|
| Complete a coding or documentation task with research, plan, implementation, review, and discovery | HVE RPI | `Use HVE RPI to update the onboarding docs after researching current repo structure.` |
| Research only before deciding what to build | Task research | `Use HVE task research to inspect the authentication flow. Do not modify files yet.` |
| Understand users, problem space, or solution direction before implementation | Design Thinking | `Use HVE Design Thinking to prepare a Problem Space handoff for this project.` |
| Prepare or review a pull request | PR workflows | `Use HVE PR workflow to generate a PR description against origin/main.` |
| Review code or architecture for security risk | Security workflows | `Use HVE security review to assess this branch for web and LLM risks.` |
| Create or inspect repository AI guidance | Copilot instructions | `Use HVE Copilot instructions to draft repo instruction files. Ask before writing.` |
| Work with GitHub issues or the optional GitHub automation package | GitHub automation | `Use HVE GitHub automation to discover related issues for this change.` |
| Work with Jira or GitLab trackers | Tracker skills | `Use HVE Jira to inspect this issue and summarize the next action.` |
| Maintain this downstream port | Port maintainer | `Use HVE port maintainer to reconcile upstream command changes.` |

See [docs/usage.md](docs/usage.md) for the full Codex usage guide and
[docs/tutorial.md](docs/tutorial.md) for a first workflow.

## Install

Register the public marketplace source:

```bash
codex plugin marketplace add https://github.com/JamiesonLabUTSW/hve-core-codex
```

If the marketplace is already registered, refresh it after changes:

```bash
codex plugin marketplace upgrade hve-core-codex-local
```

For unpublished local changes, pass the path to your local checkout as the
marketplace source instead of the public GitHub URL.

## First Workflow

After installing or refreshing the plugin, use normal Codex language. The
wrapper skills are the reliable entrypoints:

```text
Use HVE RPI to research, plan, implement, and review a small docs cleanup.
Use HVE task research to inspect this repo's plugin layout. Do not modify files.
Use HVE Design Thinking to prepare a DT-to-RPI handoff for a new feature idea.
Use HVE PR workflow to prepare a PR against origin/main.
```

The command-style shorthand is accepted for compatibility, but plain language is
the preferred Codex interaction model:

```text
$hve-core-codex rpi task="Update onboarding docs after researching the repo."
```

## Documentation

| Document | Audience | Purpose |
|---|---|---|
| [docs/usage.md](docs/usage.md) | HVE users in Codex | Tool discovery, wrapper skills, invocation examples, generated agents, and workflow boundaries. |
| [docs/tutorial.md](docs/tutorial.md) | First-time users | A short hands-on path from install to first RPI and PR workflow. |
| [github-actions/README.md](github-actions/README.md) | Repository maintainers | Optional GitHub Agentic Workflow package, permissions, and safety notes. |
| [PORTING.md](PORTING.md) | Port maintainers | Upstream sync rules, generated artifact boundaries, overlays, and runtime surface policy. |

Upstream HVE Core documentation remains the best reference for methodology depth:

* HVE docs: <https://microsoft.github.io/hve-core/>
* RPI workflow: <https://microsoft.github.io/hve-core/docs/rpi/>
* Design Thinking: <https://microsoft.github.io/hve-core/docs/design-thinking/>

## What Is Included

The Codex plugin payload lives at `plugins/hve-core-codex/` and is synced from
upstream `plugins/hve-core-all` where possible.

Generated from upstream:

| Path | Purpose |
|---|---|
| `plugins/hve-core-codex/agents/` | HVE Core agent definitions preserved as plugin agent assets where Codex supports them and as prompt assets for wrapper skills. |
| `plugins/hve-core-codex/commands/` | Prompt-derived command assets plus local HVE Codex helper commands. |
| `plugins/hve-core-codex/instructions/` | Coding, workflow, security, Responsible AI, and domain instruction references. |
| `plugins/hve-core-codex/skills/` | Upstream skill packages plus Codex wrapper skills that route to command and agent assets. |
| `plugins/hve-core-codex/generated/codex-agents/` | Generated Codex custom-agent TOML artifacts for explicit out-of-band installation. |
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
| `scripts/audit-runtime-surfaces.js` | Command and agent metadata compatibility audit for runtime-first plugin surfaces. |
| `scripts/generate-codex-agents.js` | Generates Codex custom-agent TOML from packaged HVE agent markdown. |
| `scripts/install-codex-agents.sh` | Explicit out-of-band installer for project or user Codex custom-agent directories. |
| `overlays/hve-core-codex/` | Codex-specific helper commands and wrapper skills copied after upstream sync. |
| `docs/` | Codex-specific usage and tutorial documentation. |
| `PORTING.md` | Porting rules, exclusions, and known limitations. |

## How This Port Differs From Upstream

Upstream HVE Core primarily targets VS Code and GitHub Copilot extension
surfaces. This port adapts the same toolkit for Codex:

* Installation uses `codex plugin marketplace add`, not the VS Code Marketplace.
* Wrapper skills are the reliable Codex-discoverable entrypoints.
* Upstream command markdown is preserved for runtime-first command support.
* Upstream agent markdown is preserved, but plugin install does not guarantee
  those files become Codex `spawn_agent` role names.
* Jira, GitLab, and some other domain capabilities are exposed as direct skills
  or packaged command assets rather than only through wrapper skills.
* Generated Codex custom-agent TOML is packaged under
  `plugins/hve-core-codex/generated/codex-agents/`, but activation requires an
  explicit install into `.codex/agents/` or `~/.codex/agents/`.
* GitHub event automation is packaged separately under `github-actions/` and
  must be installed into consumer repositories deliberately.

## Custom Codex Agents

The generated TOML files are package artifacts only. Installing the plugin does
not activate them as Codex custom agents.

Preview a project-scoped install:

```bash
scripts/install-codex-agents.sh --dry-run --scope project --target /path/to/repo
```

Install the default `core` profile into a project:

```bash
scripts/install-codex-agents.sh --scope project --target /path/to/repo
```

Install every generated agent:

```bash
scripts/install-codex-agents.sh --scope project --target /path/to/repo --profile all
```

Use `--scope user` only when you explicitly want user-global agents in
`~/.codex/agents/`.

## Maintain The Port

Run this from the repo root when the adjacent upstream HVE Core checkout changes:

```bash
./scripts/sync-upstream.sh ../hve-core
./scripts/verify-port.sh
```

The sync writes `upstream.lock.json` with the upstream commit, version, generated
counts, generated Codex custom-agent counts, and known exclusions. Treat
generated directories as vendored output: refresh them with the sync script
instead of editing them by hand.

When upstream adds commands or agents, use the `hve-port-maintainer` and
`hve-codex-agent-porting` skills to reconcile runtime metadata, generated
custom-agent TOML, install profiles, and wrapper route maps.

## Licensing

Most content is MIT licensed. Some security skills contain third-party reference
content under the licenses declared in each skill's frontmatter and in
`THIRD-PARTY-NOTICES`.
