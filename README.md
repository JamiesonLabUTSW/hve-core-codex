# HVE Core Codex Plugin

This repository packages the upstream HVE Core All bundle as a Codex CLI compatible plugin.

HVE Core upstream: <https://github.com/microsoft/hve-core>

## What Is Included

The Codex plugin lives at `plugins/hve-core-codex/` and is synced from upstream
`plugins/hve-core-all` where possible.

Generated from upstream:

| Path | Purpose |
|---|---|
| `plugins/hve-core-codex/agents/` | HVE Core agent definitions preserved as the plugin agent surface where Codex supports it, and as prompt assets for wrapper skills. |
| `plugins/hve-core-codex/commands/` | Prompt-derived Codex slash commands plus local HVE Codex helper commands. |
| `plugins/hve-core-codex/instructions/` | HVE Core coding, workflow, security, RAI, and domain instruction references. |
| `plugins/hve-core-codex/skills/` | Upstream Codex skill packages plus Codex wrapper skills that route to command and agent assets, with Codex-incompatible upstream installer docs excluded. |
| `plugins/hve-core-codex/generated/codex-agents/` | Generated Codex custom-agent TOML artifacts and manifest for explicit out-of-band installation. |
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
| `scripts/audit-runtime-surfaces.js` | Command and agent metadata compatibility audit for the runtime-first plugin surfaces. |
| `scripts/generate-codex-agents.js` | Generates Codex custom-agent TOML from packaged HVE agent markdown. |
| `scripts/install-codex-agents.sh` | Explicit out-of-band installer for project or user Codex custom-agent directories. |
| `overlays/hve-core-codex/` | Codex-specific helper commands and wrapper skills copied after upstream sync. |
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

## Runtime Surfaces

This port keeps upstream HVE `commands/` and `agents/` as runtime-first plugin
surfaces. Codex surfaces that support plugin slash commands or plugin agents can
use those files directly.

The reliable Codex-discoverable entrypoints are wrapper skills:

* `hve-core-workflows`
* `hve-security-workflows`
* `hve-pr-workflows`
* `hve-github-automation`
* `hve-port-maintainer`
* `hve-copilot-instructions`
* `hve-codex-agent-porting`

The wrappers prefer runtime command/agent behavior when available, then fall
back to loading the packaged markdown files directly. Upstream agent markdown is
not assumed to create new Codex `spawn_agent` role names; wrappers use built-in
Codex subagent roles only when the current runtime exposes them.

Preferred Codex prompts should read like normal instructions:

```text
Use HVE RPI to validate and plan remediation for an access-control issue. Do not modify files yet.
Use HVE security review to review group ownership checks around transcription jobs.
Use HVE Copilot instructions to inspect this repo and draft .github/copilot-instructions.md plus .github/instructions/*.instructions.md. Ask before writing.
```

The command-style shorthand is accepted for compatibility, but it is not the
preferred Codex interaction model:

```text
$hve-core-codex rpi task="Validate and plan remediation for an access-control issue. Do not modify files yet."
$hve-core-codex security-review task="Review group ownership checks around transcription jobs."
```

Wrapper route maps use plugin-root-relative assets such as
`commands/hve-core/rpi.md` and `agents/hve-core/rpi-agent.md`. This avoids
repo-layout paths when the plugin is installed in the Codex plugin cache.

If a newly added wrapper skill does not appear in `codex exec` or
`codex debug prompt-input`, refresh the local plugin installation from the Codex
UI or reinstall the local marketplace so the plugin cache is rebuilt. As a
fallback before cache refresh, invoke wrappers by file path, for example:

```text
Use plugins/hve-core-codex/skills/hve-core-workflows/SKILL.md for this task.
```

## Custom Codex Agents

This port generates Codex custom-agent TOML from packaged HVE Core agent
markdown under `plugins/hve-core-codex/generated/codex-agents/`. Those files are
packaged artifacts only. Installing the plugin does not activate them as Codex
custom agents.

To preview a project-scoped install:

```bash
scripts/install-codex-agents.sh --dry-run --scope project --target /path/to/repo
```

To install the default `core` profile into a project:

```bash
scripts/install-codex-agents.sh --scope project --target /path/to/repo
```

To install every generated agent:

```bash
scripts/install-codex-agents.sh --scope project --target /path/to/repo --profile all
```

Use `--scope user` only when you explicitly want user-global agents in
`~/.codex/agents/`. The installer writes an `hve-core-codex-install.json`
manifest, skips unrelated TOML files, and supports `--dry-run`, `--force`,
`--prune`, and `--uninstall`.

After installation, ask Codex for the generated agent by name, for example:

```text
Use hve_hve_core_task_researcher to research this repo and create the HVE research artifact.
```

## Sync From Upstream

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

The plugin manifest version may use an upstream-based downstream suffix such as
`3.3.101-codex.1`. The upstream version remains recorded separately in
`upstream.lock.json`; the Codex suffix lets local plugin caches refresh when this
port changes without a new upstream release.

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
