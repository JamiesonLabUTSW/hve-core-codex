---
applyTo: '.copilot-tracking/changes/2026-05-04/codex-agent-sync-cycle-changes.md'
---
<!-- markdownlint-disable-file -->
# Implementation Plan: Codex Agent Sync Cycle

## Overview

Implement deterministic Codex custom-agent TOML generation during upstream sync, explicit out-of-band installation instructions, verification that new upstream agents are incorporated, and focused port-correctness skills for maintainers.

## Objectives

### User Requirements

* Generate custom-agent TOML during sync cycles — Source: user request, 2026-05-04.
* Store generated TOML and provide clear out-of-band instructions for users — Source: user request and .copilot-tracking/research/2026-05-04/codex-cli-agent-porting-research.md.
* Ensure new upstream agents are incorporated correctly — Source: user request, 2026-05-04.
* Think about building HVE Core Codex skills specific to making sure the port is done correctly — Source: user request, 2026-05-04.

### Derived Objectives

* Keep generated artifacts deterministic and sync-owned — Derived from: PORTING.md generated-versus-hand-maintained policy and current `scripts/sync-upstream.sh` behavior.
* Treat plugin-packaged agent markdown and installed Codex custom-agent TOML as different runtime surfaces — Derived from: official Codex documentation and the research recommendation.
* Fail verification on stale generated TOML, missing generated TOML, duplicate names, unknown frontmatter keys, and mismatched counts — Derived from: the need to make upstream new-agent changes visible during port cycles.
* Add one focused custom-agent porting skill while extending the existing port-maintainer skill — Derived from: avoiding skill sprawl while giving maintainers a clear workflow.

## Context Summary

### Project Files

* README.md - Documents current plugin runtime surfaces and wrapper skill entrypoints.
* PORTING.md - Documents generated asset boundaries, sync workflow, exclusions, and wrapper policy.
* scripts/sync-upstream.sh - Copies upstream HVE assets and writes `upstream.lock.json`.
* scripts/verify-port.sh - Validates the generated port payload and required wrapper skills.
* scripts/audit-runtime-surfaces.js - Validates command and agent markdown metadata.
* overlays/hve-core-codex/skills/hve-port-maintainer/SKILL.md - Existing port-maintenance wrapper skill.
* overlays/hve-core-codex/skills/hve-port-maintainer/references/reconciliation.md - Existing upstream reconciliation checklist.

### References

* .copilot-tracking/research/2026-05-04/codex-cli-agent-porting-research.md - Research selecting sync-time TOML generation plus explicit installer.
* .copilot-tracking/details/2026-05-04/codex-agent-sync-cycle-details.md - Detailed implementation steps for this plan.
* .copilot-tracking/plans/logs/2026-05-04/codex-agent-sync-cycle-log.md - Planning discrepancies, alternatives, and follow-on work.
* https://developers.openai.com/codex/subagents#custom-agents - Official Codex custom-agent location and schema.
* https://developers.openai.com/codex/plugins/build#plugin-structure - Official Codex plugin component structure.

### Standards References

* PORTING.md - Generated files must be synced rather than hand-edited; durable Codex-specific changes belong in scripts, docs, and overlays.
* overlays/hve-core-codex/skills/hve-port-maintainer/references/reconciliation.md - Wrapper skills should use plugin-root-relative paths and avoid duplicating upstream instructions.

## Implementation Checklist

### [x] Implementation Phase 1: Generated Codex Agent Artifacts

<!-- parallelizable: false -->

* [x] Step 1.1: Create `scripts/generate-codex-agents.js` to scan plugin agent markdown and write deterministic custom-agent TOML plus manifest.
  * Details: .copilot-tracking/details/2026-05-04/codex-agent-sync-cycle-details.md (Lines 19-51)
* [x] Step 1.2: Preserve unsupported Copilot frontmatter fields as compatibility guidance and fail on unknown future fields.
  * Details: .copilot-tracking/details/2026-05-04/codex-agent-sync-cycle-details.md (Lines 53-83)
* [x] Step 1.3: Integrate generated artifact cleanup and generation into `scripts/sync-upstream.sh` before `upstream.lock.json` is written.
  * Details: .copilot-tracking/details/2026-05-04/codex-agent-sync-cycle-details.md (Lines 85-105)

### [x] Implementation Phase 2: Verification And Upstream Change Detection

<!-- parallelizable: true -->

* [x] Step 2.1: Add generated-agent verification and wire it into `scripts/verify-port.sh`.
  * Details: .copilot-tracking/details/2026-05-04/codex-agent-sync-cycle-details.md (Lines 111-142)
* [x] Step 2.2: Update maintainer docs and reconciliation guidance so new upstream agents require generated TOML, manifest, allowlist, profile, and route decisions.
  * Details: .copilot-tracking/details/2026-05-04/codex-agent-sync-cycle-details.md (Lines 144-170)

### [x] Implementation Phase 3: Out-Of-Band Installer And User Documentation

<!-- parallelizable: true -->

* [x] Step 3.1: Create `scripts/install-codex-agents.sh` with project/user scopes, dry-run, force, prune, uninstall, and install manifest behavior.
  * Details: .copilot-tracking/details/2026-05-04/codex-agent-sync-cycle-details.md (Lines 176-210)
* [x] Step 3.2: Add user-facing documentation that plugin install does not activate custom agents and that project-scoped install is the default recommendation.
  * Details: .copilot-tracking/details/2026-05-04/codex-agent-sync-cycle-details.md (Lines 212-240)

### [x] Implementation Phase 4: Port-Correctness Skills

<!-- parallelizable: true -->

* [x] Step 4.1: Extend `hve-port-maintainer` so it covers generated custom-agent lifecycle and new-agent checks.
  * Details: .copilot-tracking/details/2026-05-04/codex-agent-sync-cycle-details.md (Lines 246-263)
* [x] Step 4.2: Add a focused `hve-codex-agent-porting` wrapper skill for generator, audit, installer, and new-upstream-agent workflows.
  * Details: .copilot-tracking/details/2026-05-04/codex-agent-sync-cycle-details.md (Lines 265-293)
* [x] Step 4.3: Defer broader port skill splitting until the focused skill proves insufficient.
  * Details: .copilot-tracking/details/2026-05-04/codex-agent-sync-cycle-details.md (Lines 295-316)

### [x] Implementation Phase 5: Final Validation

<!-- parallelizable: false -->

* [x] Step 5.1: Run full sync and verification, including generated-agent check and installer dry-run.
  * Details: .copilot-tracking/details/2026-05-04/codex-agent-sync-cycle-details.md (Lines 322-346)
* [x] Step 5.2: Test one project-scoped install path in a disposable directory without writing to `~/.codex/agents/`.
  * Details: .copilot-tracking/details/2026-05-04/codex-agent-sync-cycle-details.md (Lines 348-366)
* [x] Step 5.3: Review generated and hand-maintained diffs, confirm lock metadata, and ensure generated files are reproducible.
  * Details: .copilot-tracking/details/2026-05-04/codex-agent-sync-cycle-details.md (Lines 368-387)

## Planning Log

See `.copilot-tracking/plans/logs/2026-05-04/codex-agent-sync-cycle-log.md` for discrepancy tracking, implementation paths considered, and suggested follow-on work.

## Dependencies

* Node.js for generator and verification scripts.
* Bash for sync, verify, and installer scripts.
* Existing adjacent upstream checkout at `../hve-core`.
* Codex custom-agent behavior documented under `~/.codex/agents/` and `.codex/agents/`.

## Success Criteria

* `./scripts/sync-upstream.sh ../hve-core` regenerates Codex custom-agent TOML and manifest output.
* `./scripts/verify-port.sh` fails when generated custom-agent output is missing, stale, malformed, mismatched, or based on unknown upstream frontmatter.
* New upstream plugin agents automatically receive generated TOML and are surfaced for profile and wrapper-route decisions.
* Users have clear README instructions for project-scoped install, user-scoped install, dry-run, prune, uninstall, and refresh behavior.
* The port keeps wrapper skills as the reliable default route and clearly labels generated TOML installation as out-of-band.
* The existing `hve-port-maintainer` skill and new `hve-codex-agent-porting` skill make port-correctness workflows discoverable.
