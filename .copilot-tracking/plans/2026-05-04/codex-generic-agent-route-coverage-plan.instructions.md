<!-- markdownlint-disable-file -->
# Implementation Plan: Codex Generic Agent Route Coverage

## User Requests

* Plan and implement the recommended Codex-native handling for the eight
  `agent: agent` command warnings.
* Create a new branch before implementation.
* Make the solution durable across upstream HVE Core sync cycles.

## Context

* Branch: `codex-generic-agent-route-coverage`
* Research:
  `.copilot-tracking/research/2026-05-04/codex-cli-integration-for-generic-agent-placeholder-commands-research.md`
* Port rule: durable Codex-specific changes live in
  `overlays/hve-core-codex/` and are copied into the plugin payload during
  `scripts/sync-upstream.sh`.

## Checklist

* [x] Create implementation branch.
* [x] Add a Design Thinking wrapper skill in `overlays/hve-core-codex/skills/`
  with routes for the three `dt-handoff-*` commands.
* [x] Copy the wrapper into `plugins/hve-core-codex/skills/` for the current
  packaged payload.
* [x] Update `scripts/audit-runtime-surfaces.js` to load wrapper route files and
  suppress generic `agent` warnings only for routed command assets.
* [x] Update `scripts/verify-port.sh` to require the new wrapper skill and keep
  route path checks.
* [x] Update README and PORTING documentation with the VS Code `agent: agent`
  mapping rule.
* [x] Run `./scripts/verify-port.sh`.
* [x] Review final diff and summarize follow-ups.

## Success Criteria

* `./scripts/verify-port.sh` passes.
* The previous eight generic-agent warnings are gone because all eight commands
  are covered by Codex wrapper routes.
* Any future upstream command with unrouted `agent: agent` still produces a
  warning.
* No generated upstream command files are hand-edited.
