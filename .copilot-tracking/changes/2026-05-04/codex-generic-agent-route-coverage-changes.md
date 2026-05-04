<!-- markdownlint-disable-file -->
# Changes: Codex Generic Agent Route Coverage

## Related Artifacts

* Plan:
  `.copilot-tracking/plans/2026-05-04/codex-generic-agent-route-coverage-plan.instructions.md`
* Research:
  `.copilot-tracking/research/2026-05-04/codex-cli-integration-for-generic-agent-placeholder-commands-research.md`

## Summary

Implemented durable Codex wrapper route coverage for upstream VS Code prompt
files that use `agent: agent`. The runtime audit now recognizes routed generic
agent-mode prompt files as covered and still warns on future unrouted generic
agent-mode commands.

## Added

* `overlays/hve-core-codex/skills/hve-design-thinking-workflows/SKILL.md`
* `overlays/hve-core-codex/skills/hve-design-thinking-workflows/references/routes.md`
* `plugins/hve-core-codex/skills/hve-design-thinking-workflows/SKILL.md`
* `plugins/hve-core-codex/skills/hve-design-thinking-workflows/references/routes.md`

## Modified

* `scripts/audit-runtime-surfaces.js`
  * Loads wrapper route files from `skills/**/references/routes.md`.
  * Validates routed command assets exist.
  * Suppresses `agent: agent` warnings only when the command asset is routed.
* `scripts/verify-port.sh`
  * Requires `hve-design-thinking-workflows`.
* `README.md`
  * Documents the wrapper and `agent: agent` Codex mapping.
* `PORTING.md`
  * Documents the durable route-map policy for generic VS Code agent-mode prompt files.
* `plugins/hve-core-codex/.codex-plugin/plugin.json`
  * Bumps the downstream Codex suffix to `3.3.101-codex.5`.
* `upstream.lock.json`
  * Records the new final plugin skill count after a sync cycle.
* `plugins/hve-core-codex/generated/codex-agents/manifest.json`
  * Reflects the plugin version bump.

## Validation

* `node scripts/audit-runtime-surfaces.js plugins/hve-core-codex`
  * Passed with `warnings=0`.
* `./scripts/sync-upstream.sh ../hve-core`
  * Passed and preserved the overlay wrapper.
* `./scripts/verify-port.sh`
  * Passed with `warnings=0`.
