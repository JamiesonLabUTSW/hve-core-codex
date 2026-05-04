<!-- markdownlint-disable-file -->

# Codex CLI Agent Porting Research

Date: 2026-05-04

Research task: determine how HVE Core VS Code / GitHub Copilot agent markdown can translate into Codex CLI custom agents programmatically with each port cycle, and whether that can live inside the Codex plugin path or requires an out-of-band installation process.

## Task Implementation Request

The port currently preserves upstream HVE Core agent markdown under `plugins/hve-core-codex/agents/`, but it does not turn those files into named Codex CLI `spawn_agent` roles. The user wants research into whether each upstream port cycle can programmatically translate GitHub Copilot agent definitions into actual Codex CLI agents.

## Scope And Success Criteria

Scope:

* Inspect current repo porting mechanics for agent synchronization, runtime surface assumptions, and verification.
* Compare local behavior and official Codex documentation for plugins, custom agents, configuration, feature flags, and migration APIs.
* Identify implementation approaches and select one recommendation for future remediation.

Success criteria:

* Explain whether Codex plugins can currently package custom subagents directly.
* Define a repeatable port-cycle conversion strategy if direct plugin packaging is not supported.
* Preserve current wrapper skills as the reliable runtime path while making custom subagents optional and explicit.
* Record alternatives, trade-offs, risks, and implementation next steps.

## Research Executed

### Local File Analysis

* `README.md:16` says `plugins/hve-core-codex/agents/` preserves HVE agent definitions as a plugin agent surface where Codex supports it and as prompt assets for wrapper skills.
* `README.md:53-69` says upstream commands and agents are runtime-first surfaces, but wrapper skills are the reliable entrypoints; upstream agent markdown is not assumed to create new Codex `spawn_agent` role names.
* `README.md:87-94` notes wrapper route maps use plugin-root-relative paths and plugin cache rebuilds may be needed after changes.
* `PORTING.md:20-23` maps upstream `.github/agents/**/*.agent.md` through `plugins/hve-core-all/agents/**/*.md` into `plugins/hve-core-codex/agents/**/*.md`.
* `PORTING.md:63-85` documents the runtime surface policy and explicitly says upstream agent files are not treated as dynamic Codex `spawn_agent` roles.
* `PORTING.md:95-115` defines wrapper skills as the stable discovery layer and requires plugin-root-relative paths.
* `plugins/hve-core-codex/.codex-plugin/plugin.json:27` has a `skills` manifest field but no `agents` manifest field.
* `scripts/sync-upstream.sh:106-113` copies upstream plugin agents, commands, instructions, templates, scripts, and skills into the Codex plugin payload, then applies exclusions.
* `scripts/sync-upstream.sh:145-148` separately copies upstream `.github/agents`, instructions, and skills into `github-actions/artifacts/.github/` for the optional GitHub automation package.
* `scripts/audit-runtime-surfaces.js:7-9` roots validation in the plugin payload's `commands` and `agents` directories.
* `scripts/audit-runtime-surfaces.js:87-111` validates agent markdown frontmatter for name and description, but does not generate Codex TOML custom agents.
* `plugins/hve-core-codex/agents/hve-core/task-researcher.md:1-19` shows upstream agent frontmatter including `name`, `description`, `disable-model-invocation`, `agents`, and `handoffs`.
* `plugins/hve-core-codex/agents/hve-core/task-researcher.md:21-35` contains the agent body that should become Codex `developer_instructions` if converted.
* `plugins/hve-core-codex/agents/hve-core/rpi-agent.md:1-38` shows richer agent frontmatter including `argument-hint`, `agents`, and `handoffs`; these fields do not map directly to Codex custom agent TOML fields.

### Code Search And Runtime Probes

* `find plugins/hve-core-codex/agents -type f -name '*.md' | wc -l` returned 54 plugin agent files.
* `find ../hve-core/.github/agents -type f -name '*.agent.md' | wc -l` returned 58 upstream `.github` agent files.
* `find github-actions/artifacts/.github/agents -type f -name '*.agent.md' | wc -l` returned 58 automation artifact agent files.
* Agent frontmatter keys in the plugin payload are: `name` 54, `description` 54, `tools` 19, `handoffs` 22, `agents` 14, `disable-model-invocation` 14, `user-invocable` 14, and `argument-hint` 2.
* `codex features list` reports `plugins` and `multi_agent` as stable/enabled, `codex_hooks` as stable/enabled, `plugin_hooks` as under development/disabled, and `external_migration` as experimental/disabled.
* `codex plugin --help` exposes `marketplace` management only; the CLI help did not show a direct plugin subcommand for installing custom agents.

### Official Codex Documentation

Sources fetched via the OpenAI developer docs MCP on 2026-05-04:

* https://developers.openai.com/codex/plugins/build#plugin-structure
* https://developers.openai.com/codex/plugins/build#path-rules
* https://developers.openai.com/codex/subagents#custom-agents
* https://developers.openai.com/codex/config-reference#configtoml
* https://developers.openai.com/codex/app-server#detect-and-import-external-agent-config

Findings:

* Plugin structure documentation lists `.codex-plugin/plugin.json`, `skills/`, `.app.json`, `.mcp.json`, `hooks/`, and `assets/`. It does not document an `agents/` component or an `agents` manifest field.
* Plugin manifest path rules say bundled component fields are `skills`, `apps`, `mcpServers`, and `hooks`. No documented manifest path exists for custom subagents.
* Custom agents documentation says user-defined Codex custom agents are standalone TOML files under `~/.codex/agents/` for personal agents or `.codex/agents/` for project-scoped agents.
* Custom agent TOML files require `name`, `description`, and `developer_instructions`; optional fields can include `nickname_candidates`, `model`, `model_reasoning_effort`, `sandbox_mode`, `mcp_servers`, and `skills.config`.
* Configuration reference also supports declaring `agents.<name>.description`, `agents.<name>.config_file`, and `agents.<name>.nickname_candidates` from `config.toml`, but this is still outside the plugin manifest path.
* External agent config migration APIs can import selected external-agent artifacts, but local feature flags show `external_migration` is experimental and disabled. The fetched anchor documents only `AGENTS_MD`, `CONFIG`, `SKILLS`, `PLUGINS`, and `MCP_SERVER_CONFIG` item types, while the search API overview also mentioned subagents and other types. Treat this path as not reliable for the current port.

## Key Discoveries

1. Codex custom subagents and Codex plugins are separate runtime surfaces today. Official plugin docs do not provide a direct way to package custom subagent TOML files as a plugin component.
2. The repo's current policy is consistent with the docs: upstream HVE agent markdown is preserved as runtime/prompt assets, but not assumed to become `spawn_agent` roles.
3. A programmatic converter is feasible because every plugin agent markdown file has `name` and `description`, and the body can be mapped into `developer_instructions`.
4. The converter cannot losslessly map Copilot-specific frontmatter. Fields such as `handoffs`, `agents`, `disable-model-invocation`, `user-invocable`, `argument-hint`, and `tools` need advisory treatment in generated instructions or narrowly selected Codex config fields.
5. The install step is the boundary. Generation can happen inside the repo during `scripts/sync-upstream.sh`, but activation requires copying TOML to `~/.codex/agents/`, copying TOML to a target repo's `.codex/agents/`, or editing Codex config to point at generated TOML.

## Selected Technical Scenario

### Sync-Time TOML Generation Plus Explicit Installer

Selected approach:

* Generate Codex custom-agent TOML files during each upstream sync cycle.
* Store generated TOML as inert repo/package artifacts, not as an assumed plugin runtime surface.
* Provide an explicit installer that copies generated TOML to a user or project Codex agent directory.
* Keep wrapper skills as the default supported entrypoints.

Suggested generated artifact path:

```text
plugins/hve-core-codex/generated/codex-agents/*.toml
```

Alternative if generated output should not live inside the plugin payload:

```text
dist/codex-agents/*.toml
```

Suggested installer command shape:

```text
scripts/install-codex-agents.sh --scope project --target /path/to/repo
scripts/install-codex-agents.sh --scope user
```

Install destinations:

* `--scope project`: copy to `<target>/.codex/agents/`
* `--scope user`: copy to `~/.codex/agents/`

Project scope should be the default for consumer repositories because it is explicit, reviewable, and versionable with the target repo. User scope should require a direct action because it writes to the user's global Codex environment.

## Proposed Conversion Mapping

Use `plugins/hve-core-codex/agents/**/*.md` as the canonical source for Codex custom agents. Keep `github-actions/artifacts/.github/agents/**/*.agent.md` reserved for the optional GitHub automation package unless a separate decision says workflow-only automation agents should become Codex subagents too.

Mapping:

| GitHub Copilot agent markdown | Codex custom agent TOML |
|---|---|
| File path | Source metadata comment inside `developer_instructions`; generated filename |
| `name` | Normalized `name`, prefixed to avoid collisions, for example `hve_task_researcher` |
| `description` | `description`, with source HVE display name/path appended if useful |
| Markdown body | `developer_instructions` |
| `tools` | Advisory section in `developer_instructions`; optional `sandbox_mode` heuristic only after validation |
| `handoffs` | Advisory section in `developer_instructions`; no direct TOML field |
| `agents` | Advisory section in `developer_instructions`; can mention preferred installed custom agent names after all mappings are known |
| `disable-model-invocation` | Advisory section only; no direct Codex custom-agent TOML field |
| `user-invocable` | Advisory section or installer allowlist; no direct TOML field |
| `argument-hint` | Advisory section or description suffix |

Recommended generated TOML shape:

```toml
name = "hve_task_researcher"
description = "HVE Core Task Researcher. Use for repository research tasks that need a consolidated .copilot-tracking research document."
developer_instructions = """
Source: plugins/hve-core-codex/agents/hve-core/task-researcher.md
Original HVE agent name: Task Researcher

The original HVE frontmatter contained Codex-incompatible fields. Treat the following as workflow guidance, not runtime configuration:
- disable-model-invocation: true
- agents: Researcher Subagent
- handoffs: Task Planner, Task Researcher

# Task Researcher

Research-only specialist for deep, comprehensive analysis. Produces a single authoritative document in `.copilot-tracking/research/`.

...
"""
```

Do not emit model overrides initially. Inherit parent model and reasoning settings until real use shows categories that benefit from specific defaults. Do not wire `skills.config` to plugin-cache paths in generated TOML because installed plugin cache paths include marketplace, plugin name, and version. If a future installer can resolve the installed plugin root reliably at install time, it can optionally add user-local config, but that should be a separate explicit step.

## Validation Requirements

Add a generator verification step to `scripts/verify-port.sh` after implementation:

* Generated custom-agent count equals the expected source count, initially 54 from `plugins/hve-core-codex/agents/**/*.md`.
* Every generated TOML file has `name`, `description`, and `developer_instructions`.
* Generated names are unique and do not collide with built-in Codex names `default`, `worker`, or `explorer`.
* Generated TOML parses successfully.
* Generated instructions include source path metadata for traceability.
* Unsupported Copilot frontmatter keys are either represented in advisory text or intentionally omitted by a documented allowlist.
* Generator output is deterministic so upstream sync diffs remain reviewable.

## Evaluated Alternatives

### Add `agents` To `.codex-plugin/plugin.json`

Status: rejected for now.

Rationale: official plugin docs list `skills`, `apps`, `mcpServers`, and `hooks` as bundled component fields. No documented `agents` manifest field exists. Adding an undocumented field risks producing an inert or unstable package.

### Keep Agent Markdown Only Inside The Plugin

Status: insufficient.

Rationale: this is the current state and is useful for wrapper skills, but it does not create named Codex `spawn_agent` roles. It also keeps HVE workflow text that references Copilot/VS Code subagent concepts unless wrapper guidance translates that at invocation time.

### Use Plugin Hooks To Install Agents Automatically

Status: rejected for now.

Rationale: local feature flags show `plugin_hooks` as under development and disabled. Even if hooks become available, automatically writing to `~/.codex/agents/` from plugin installation would be surprising because it mutates user-global Codex behavior outside the plugin cache. If hooks are considered later, use them only to prompt or validate, not to silently install global agents.

### Edit `~/.codex/config.toml` To Point At Plugin-Cache TOML

Status: viable but not preferred.

Rationale: Codex config supports `agents.<name>.config_file`, but plugin cache paths are versioned and may change after marketplace upgrades. This requires out-of-band config mutation anyway and is more brittle than copying generated TOML to the documented agent directories.

### Use External Agent Config Migration

Status: future investigation only.

Rationale: the app-server docs expose detect/import APIs, but local feature flags show `external_migration` as experimental and disabled. The documented item types in the fetched section also do not consistently include subagents. This should not be the implementation path for the current port.

### Generate One Skill Per Agent

Status: useful as a fallback, not a replacement.

Rationale: skills are plugin-native, but they do not create true Codex subagent role names. The repo already uses wrapper skills as the stable interaction model, so one-skill-per-agent would increase plugin noise without solving the custom subagent requirement.

## Risks And Mitigations

* Risk: generated HVE subagents may still instruct Codex to use unavailable Copilot tools or human-readable subagent names.
  Mitigation: converter should translate unsupported frontmatter into advisory compatibility notes and normalize HVE subagent references to generated Codex names only after all names are known.

* Risk: generating all 54 plugin agents creates too many choices for users and may reduce selection quality.
  Mitigation: installer can support profiles, for example `--set core`, `--set review`, or `--all`; initial implementation can generate all but install a curated subset by default.

* Risk: global install mutates user behavior across unrelated repos.
  Mitigation: default to project-scoped `.codex/agents/` install and make user-scoped install explicit.

* Risk: generated TOML includes stale paths after plugin upgrades.
  Mitigation: include source metadata for review, but keep runtime instructions self-contained; avoid depending on plugin-cache absolute paths.

* Risk: HVE workflows assume automatic delegation.
  Mitigation: wrapper skills should continue to tell Codex when to use built-in agents or installed generated agents. Codex custom agents only matter when Codex is explicitly instructed to spawn them.

## Implementation Plan Candidate

1. Add `scripts/generate-codex-agents.js`.
2. Parse `plugins/hve-core-codex/agents/**/*.md` frontmatter and body.
3. Normalize names with an `hve_` prefix and path-aware suffixes to avoid collisions.
4. Write deterministic TOML to `plugins/hve-core-codex/generated/codex-agents/`.
5. Call the generator from `scripts/sync-upstream.sh` after overlays and attribution stripping.
6. Add generator validation to `scripts/verify-port.sh`.
7. Add `scripts/install-codex-agents.sh` with project/user scope support and a generated manifest for uninstall/audit.
8. Update `README.md` and `PORTING.md` to document optional custom-agent installation and the plugin boundary.
9. Update wrapper route maps or wrapper skills to mention generated custom agent names only when installed.

## Selected Recommendation

Implement generated Codex custom-agent TOML as a sync-time downstream artifact and install it through an explicit out-of-band installer. Do not treat `plugins/hve-core-codex/agents/` or a new plugin manifest field as sufficient for actual Codex CLI custom subagents.

This approach matches official Codex documentation, keeps upstream sync deterministic, avoids surprising writes outside the plugin cache, and preserves the current wrapper-skill fallback model for users who do not install custom agents.

## Potential Next Research

* Test a minimal generated TOML file under `.codex/agents/` in a disposable project and confirm it appears as a `spawn_agent` `agent_type`.
* Determine whether local Codex exposes custom agents in `codex debug prompt-input` once session directory permissions allow it.
* Prototype a converter against all 54 plugin agents and inspect name collisions, instruction length, and unsupported frontmatter coverage.
* Research whether future Codex plugin releases add a documented `agents` component before implementing a long-lived installer contract.
