<!-- markdownlint-disable-file -->
# Release Changes: Codex Agent Sync Cycle

**Related Plan**: .copilot-tracking/plans/2026-05-04/codex-agent-sync-cycle-plan.instructions.md
**Implementation Date**: 2026-05-04

## Summary

Implemented deterministic Codex custom-agent TOML generation during upstream sync cycles, explicit out-of-band installation, generated-agent verification, documentation, and port-correctness wrapper skills.

## Changes

### Added

* scripts/generate-codex-agents.js - Generates deterministic Codex custom-agent TOML, manifest metadata, install profiles, and a generated README from packaged HVE agent markdown.
* scripts/install-codex-agents.sh - Installs generated custom-agent TOML out-of-band into project `.codex/agents/` or user `~/.codex/agents/` with dry-run, force, prune, uninstall, and profile support.
* plugins/hve-core-codex/generated/codex-agents/ - Generated custom-agent TOML files, manifest, and README for 54 packaged HVE agents.
* overlays/hve-core-codex/skills/hve-codex-agent-porting/ - New focused wrapper skill for generated custom-agent generation, audit, install, and upstream new-agent reconciliation.
* plugins/hve-core-codex/skills/hve-codex-agent-porting/ - Synced plugin payload copy of the new wrapper skill.

### Modified

* scripts/sync-upstream.sh - Runs the generated-agent generator during sync and records generated Codex agent counts in `upstream.lock.json`.
* scripts/verify-port.sh - Requires generated custom-agent artifacts, checks count parity with packaged agents, runs generator `--check`, and requires the new wrapper skill.
* README.md - Documents generated custom-agent artifacts, out-of-band installation, profiles, and the wrapper skill.
* PORTING.md - Documents generated custom-agent lifecycle, upstream new-agent checks, and the explicit install boundary.
* overlays/hve-core-codex/skills/hve-port-maintainer/SKILL.md - Adds generated custom-agent audit responsibilities.
* overlays/hve-core-codex/skills/hve-port-maintainer/references/reconciliation.md - Adds generated custom-agent reconciliation checklist and wrapper policy entry.
* plugins/hve-core-codex/skills/hve-port-maintainer/SKILL.md - Synced plugin payload copy of updated port maintainer guidance.
* plugins/hve-core-codex/skills/hve-port-maintainer/references/reconciliation.md - Synced plugin payload copy of updated reconciliation guidance.
* upstream.lock.json - Records `generatedCodexAgentFiles` and generated custom-agent directory metadata.
* .copilot-tracking/plans/2026-05-04/codex-agent-sync-cycle-plan.instructions.md - Marked all implementation phases complete.

### Removed

* None for this implementation. Existing generated removals in the worktree come from the prior upstream installer exclusion and upstream category-layout sync.

## Additional or Deviating Changes

* The generated manifest includes install profiles: `core`, `review`, `security`, `automation`, and `all`.
* The installer default profile is `core` to avoid installing all 54 generated agents unless the user requests `--profile all`.

## Validation

* `node scripts/generate-codex-agents.js` - Passed; generated 54 Codex agents.
* `node scripts/generate-codex-agents.js --check` - Passed; verified generated output is current.
* `scripts/install-codex-agents.sh --dry-run --scope project --target /tmp/hve-core-codex-agent-install-test` - Passed for default `core` profile.
* `scripts/install-codex-agents.sh --dry-run --scope project --target /tmp/hve-core-codex-agent-install-test --profile all` - Passed for all 54 generated agents.
* `./scripts/sync-upstream.sh ../hve-core` - Passed; final counts included `generatedCodexAgents=54`.
* `./scripts/verify-port.sh` - Passed; retained 8 pre-existing runtime-surface warnings for generic command agent placeholders.
* `scripts/install-codex-agents.sh --scope project --target /tmp/hve-core-codex-agent-install-test-20260504` - Passed; installed 18 default `core` profile TOML files into the temporary project.
* `scripts/install-codex-agents.sh --dry-run --scope project --target /tmp/hve-core-codex-agent-install-test-20260504 --profile review --prune` - Passed; showed expected prune/create/skip actions without writing.

## Release Summary

All five implementation phases completed. The port now generates, verifies, documents, and explicitly installs Codex custom-agent TOML artifacts while preserving wrapper skills as the reliable default plugin entrypoint.
