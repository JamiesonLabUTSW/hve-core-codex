<!-- markdownlint-disable-file -->
# Planning Log: Codex Agent Sync Cycle

## Discrepancy Log

Gaps and differences identified between research findings and the implementation plan.

### Unaddressed Research Items

* DR-01: Live runtime proof that a generated TOML file appears as a custom `spawn_agent` type is not included in the implementation phases.
  * Source: .copilot-tracking/research/2026-05-04/codex-cli-agent-porting-research.md (Lines 248-253)
  * Reason: The current request is for an implementation plan. The plan includes a project-scoped install validation path but keeps live Codex runtime verification as follow-on work because it can depend on local session permissions and Codex UI state.
  * Impact: medium

### Plan Deviations from Research

* DD-01: The plan adds a dedicated `hve-codex-agent-porting` skill in addition to the research recommendation.
  * Research recommends: Generate custom-agent TOML, install out-of-band, and keep wrapper skills as the default supported route.
  * Plan implements: The same generator and installer path, plus a focused wrapper skill that explains and audits generated custom-agent lifecycle.
  * Rationale: The user explicitly asked to consider skills that ensure the port is done correctly. A narrow skill gives maintainers a discoverable workflow without making generated TOML plugin-native.

* DD-02: The task-planning process did not run a separate Plan Validator subagent.
  * Research recommends: Not applicable.
  * Plan implements: Direct planner validation through checklist, discrepancy tracking, and line-referenced planning files.
  * Rationale: This Codex session requires explicit user authorization before spawning subagents. The planning files include a final validation phase and no critical or major planning blockers are known.

## Implementation Paths Considered

### Selected: Sync-Time Generator Plus Explicit Installer

* Approach: Generate Codex custom-agent TOML from `plugins/hve-core-codex/agents/**/*.md` during `scripts/sync-upstream.sh`, verify generated output during `scripts/verify-port.sh`, and provide an explicit installer for project or user Codex agent directories.
* Rationale: This matches official Codex custom-agent locations while preserving deterministic upstream port cycles and avoiding surprising global config writes.
* Evidence: .copilot-tracking/research/2026-05-04/codex-cli-agent-porting-research.md (Lines 83-118)

### IP-01: Add `agents` To The Codex Plugin Manifest

* Approach: Add an undocumented `agents` path to `.codex-plugin/plugin.json` and expect Codex to load custom agents from the plugin payload.
* Trade-offs: Would be convenient if supported, but official plugin docs only document `skills`, `apps`, `mcpServers`, and `hooks`.
* Rejection rationale: Undocumented fields risk producing inert package contents and confusing users.

### IP-02: Copy Generated TOML Automatically Through Plugin Hooks

* Approach: Use plugin lifecycle hooks to copy generated TOML into `~/.codex/agents/` during plugin install or upgrade.
* Trade-offs: Could reduce setup steps, but mutates user-global behavior outside the plugin cache and `plugin_hooks` is currently under development/disabled locally.
* Rejection rationale: Out-of-band installation should remain explicit and auditable.

### IP-03: Generate One Skill Per Upstream Agent

* Approach: Convert every upstream HVE agent into a Codex skill rather than a custom subagent.
* Trade-offs: Skills are plugin-native, but they do not become `spawn_agent` roles and would add substantial skill-discovery noise.
* Rejection rationale: Wrapper skills already provide the plugin-native route; this does not solve the custom-agent requirement.

## Suggested Follow-On Work

Items identified during planning that fall outside current scope.

* WI-01: Runtime custom-agent smoke test - After implementation, create a disposable project with one generated `.codex/agents/*.toml` file and confirm Codex exposes the generated name as a custom subagent. (high)
  * Source: DR-01
  * Dependency: Generator and installer implementation

* WI-02: Curated install profile tuning - After generated agents exist, review all generated names and define narrower default install profiles such as `core`, `review`, `security`, and `automation`. (medium)
  * Source: Implementation Phase 3 profile design
  * Dependency: Generated manifest with agent categories or source paths

* WI-03: Additional port-correctness skills - Consider splitting `hve-port-surface-audit` and `hve-port-release-check` out of `hve-port-maintainer` only if the combined port-maintainer workflow becomes too broad. (low)
  * Source: User request and Implementation Phase 4
  * Dependency: Experience using `hve-codex-agent-porting`
