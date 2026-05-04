<!-- markdownlint-disable-file -->
# Implementation Details: Codex Agent Sync Cycle

## Context Reference

Sources:
* .copilot-tracking/research/2026-05-04/codex-cli-agent-porting-research.md - Research selecting sync-time TOML generation plus explicit out-of-band installation.
* README.md - Current user-facing plugin surface and runtime-boundary documentation.
* PORTING.md - Current downstream porting rules, exclusions, wrapper policy, and upstream reconciliation workflow.
* scripts/sync-upstream.sh - Current deterministic upstream sync entrypoint.
* scripts/verify-port.sh - Current port verification entrypoint.
* scripts/audit-runtime-surfaces.js - Current command and agent markdown metadata audit.
* overlays/hve-core-codex/skills/hve-port-maintainer/ - Current Codex-specific port-maintenance skill.

## Implementation Phase 1: Generated Codex Agent Artifacts

<!-- parallelizable: false -->

### Step 1.1: Create the custom-agent generator

Create `scripts/generate-codex-agents.js`. The script should scan `plugins/hve-core-codex/agents/**/*.md`, parse frontmatter and body, normalize each source path into a stable Codex custom-agent name, and write TOML files under `plugins/hve-core-codex/generated/codex-agents/`.

Recommended naming rule:
* Source relative path: `hve-core/task-researcher.md`
* Generated name: `hve_hve_core_task_researcher`
* Generated file: `hve_hve_core_task_researcher.toml`

The path-derived name avoids collisions when two upstream agents share the same display `name`. The original display name should remain in `description` and inside generated instruction metadata.

Files:
* scripts/generate-codex-agents.js - New deterministic generator script.
* plugins/hve-core-codex/generated/codex-agents/*.toml - Generated custom-agent TOML output.
* plugins/hve-core-codex/generated/codex-agents/manifest.json - Generated source-to-agent manifest for verification and installers.

Discrepancy references:
* None.

Success criteria:
* Every source plugin agent markdown file has exactly one generated TOML file.
* Every generated TOML file contains `name`, `description`, and `developer_instructions`.
* Generated names are unique and never equal built-in Codex names `default`, `worker`, or `explorer`.
* Generated output is stable across repeated runs with unchanged input.

Context references:
* .copilot-tracking/research/2026-05-04/codex-cli-agent-porting-research.md (Lines 75-81) - Key discoveries that generation is feasible but activation is out-of-band.
* .copilot-tracking/research/2026-05-04/codex-cli-agent-porting-research.md (Lines 120-161) - Proposed field mapping and generated TOML shape.
* scripts/sync-upstream.sh (Lines 106-113) - Current plugin agent copy flow that should feed generation.

Dependencies:
* Existing upstream sync must run before generation.
* Node.js must be available, matching existing repo verification scripts.

### Step 1.2: Preserve unsupported Copilot fields as compatibility guidance

The generator should not discard upstream frontmatter semantics silently. It should copy unsupported fields into a generated compatibility section inside `developer_instructions`, with language that tells Codex to treat them as workflow guidance rather than runtime configuration.

Initial supported frontmatter allowlist:
* `name`
* `description`
* `tools`
* `handoffs`
* `agents`
* `disable-model-invocation`
* `user-invocable`
* `argument-hint`

The generator should fail on a new frontmatter key unless the key is added to the allowlist with an explicit mapping or explicit advisory-only treatment. This makes upstream schema changes visible during each port cycle.

Files:
* scripts/generate-codex-agents.js - Add frontmatter allowlist, compatibility preamble, and diagnostics.
* plugins/hve-core-codex/generated/codex-agents/manifest.json - Record observed frontmatter keys per source file.

Success criteria:
* Unsupported-but-known fields appear in generated instructions or are recorded as intentionally omitted.
* Unknown future fields fail generation with source file paths and key names.
* `handoffs` and `agents` are not treated as automatic Codex delegation.

Context references:
* .copilot-tracking/research/2026-05-04/codex-cli-agent-porting-research.md (Lines 47-54) - Current frontmatter key inventory.
* .copilot-tracking/research/2026-05-04/codex-cli-agent-porting-research.md (Lines 77-81) - Need to treat Copilot-specific fields carefully.

Dependencies:
* Step 1.1 generator structure.

### Step 1.3: Add generated artifact cleanup and deterministic sync integration

Update `scripts/sync-upstream.sh` so each sync deletes and regenerates `plugins/hve-core-codex/generated/codex-agents/` after upstream assets are copied, overlays are applied, and Copilot attribution is stripped.

The generator should run after `strip_copilot_attribution "${plugin_root}"` so generated TOML does not preserve removed attribution text. It should run before `upstream.lock.json` is written so the lock file can record generated Codex agent counts.

Files:
* scripts/sync-upstream.sh - Call generator and include generated counts in `upstream.lock.json`.
* upstream.lock.json - Add generated Codex custom-agent count metadata during sync.

Success criteria:
* `./scripts/sync-upstream.sh ../hve-core` refreshes generated TOML every time.
* `upstream.lock.json` records generated custom-agent count and source count.
* Re-running sync with unchanged upstream produces no generated TOML drift.

Context references:
* scripts/sync-upstream.sh (Lines 119-120) - Current attribution stripping point.
* scripts/sync-upstream.sh (Lines 161-220) - Current lock file count generation.

Dependencies:
* Steps 1.1 and 1.2.

## Implementation Phase 2: Verification And Upstream Change Detection

<!-- parallelizable: true -->

### Step 2.1: Add generated-agent verification

Add a verification script, either as `scripts/audit-codex-agents.js` or a `--check` mode in `scripts/generate-codex-agents.js`. Wire it into `scripts/verify-port.sh`.

Verification should check:
* Generated TOML count equals source plugin agent markdown count.
* Manifest source paths exactly match `plugins/hve-core-codex/agents/**/*.md`.
* Every generated TOML parses.
* Every required field exists.
* No generated name collides with another generated name or built-in Codex names.
* Every observed frontmatter key is in the generator allowlist.
* No generated TOML references stale source files.

Files:
* scripts/generate-codex-agents.js - Add `--check` if using one script.
* scripts/audit-codex-agents.js - Optional separate audit script if cleaner.
* scripts/verify-port.sh - Call generated-agent verification after runtime surface audit or immediately before it.

Discrepancy references:
* None.

Success criteria:
* `./scripts/verify-port.sh` fails when a new upstream agent is copied but no corresponding TOML exists.
* `./scripts/verify-port.sh` fails when generated TOML is stale after upstream changes.
* `./scripts/verify-port.sh` fails on unknown agent frontmatter keys.

Context references:
* .copilot-tracking/research/2026-05-04/codex-cli-agent-porting-research.md (Lines 163-173) - Validation requirements from research.
* scripts/verify-port.sh (Lines 188-224) - Current runtime audit and lock count verification location.

Dependencies:
* Phase 1 generated manifest.

### Step 2.2: Make upstream new-agent incorporation explicit in the port workflow

Update `PORTING.md` and the port-maintainer reconciliation reference so new upstream agents have a required checklist:

* Confirm source markdown has `name` and `description`.
* Confirm generated TOML exists and has a deterministic name.
* Confirm unsupported frontmatter keys are handled by the converter.
* Decide whether the new agent belongs in a generated install profile.
* Decide whether wrapper skills need route changes because a new command or user-facing workflow references the agent.
* Confirm `upstream.lock.json` count changes match generated artifacts.

Files:
* PORTING.md - Add optional Codex custom-agent generation and new-agent reconciliation sections.
* overlays/hve-core-codex/skills/hve-port-maintainer/references/reconciliation.md - Add generated Codex agent checks.
* README.md - Add user-facing summary of generated custom agents and out-of-band installation boundary.

Success criteria:
* Maintainers have a documented checklist for new upstream agents.
* New upstream agents cannot pass verification without generated TOML.
* Documentation distinguishes plugin-packaged markdown from installed custom-agent TOML.

Context references:
* PORTING.md (Lines 80-85) - Current policy that upstream markdown is not dynamic `spawn_agent` roles.
* overlays/hve-core-codex/skills/hve-port-maintainer/references/reconciliation.md (Lines 31-36) - Current new-agent checklist.

Dependencies:
* Step 2.1 verification behavior.

## Implementation Phase 3: Out-Of-Band Installer And User Documentation

<!-- parallelizable: true -->

### Step 3.1: Create the explicit installer

Create `scripts/install-codex-agents.sh` to copy generated TOML into a documented Codex custom-agent directory. The script should default to project scope and require explicit selection for user-global scope.

Recommended options:
* `--scope project --target <repo>` - Copy to `<repo>/.codex/agents/`.
* `--scope user` - Copy to `~/.codex/agents/`.
* `--profile core|review|security|automation|all` - Select a curated install set.
* `--dry-run` - Print actions without writing.
* `--force` - Overwrite generated HVE files when needed.
* `--prune` - Remove previously installed HVE-generated files that are no longer in the manifest.
* `--uninstall` - Remove files installed by this package.

The installer should write a non-TOML manifest next to installed files, such as `hve-core-codex-install.json`, recording plugin version, upstream commit, generated agent names, source paths, and install timestamp. It should never overwrite non-HVE TOML files unless `--force` is provided and the file has the expected generated marker.

Files:
* scripts/install-codex-agents.sh - New installer.
* plugins/hve-core-codex/generated/codex-agents/manifest.json - Installer input.
* README.md - Document installer commands and scope behavior.

Discrepancy references:
* None.

Success criteria:
* Project install writes only to `<target>/.codex/agents/`.
* User install writes only to `~/.codex/agents/`.
* Dry-run output shows create, update, skip, prune, and conflict actions.
* Installer refuses to overwrite unrelated custom-agent TOML files.

Context references:
* .copilot-tracking/research/2026-05-04/codex-cli-agent-porting-research.md (Lines 83-118) - Selected install approach and destinations.
* .copilot-tracking/research/2026-05-04/codex-cli-agent-porting-research.md (Lines 213-228) - Risks and mitigations for install scope and generated agent behavior.

Dependencies:
* Phase 1 generated artifacts.

### Step 3.2: Add user-facing out-of-band instructions

Update user-facing docs to explain that the plugin ships generated TOML artifacts but Codex custom agents only activate after explicit installation into Codex agent directories.

Documentation should include:
* When to use wrapper skills instead of custom agents.
* How to install project-scoped agents.
* How to install user-scoped agents.
* How to dry-run and uninstall.
* How to refresh after upstream sync.
* Why plugin installation alone does not activate custom subagents.
* How to ask Codex to use installed generated agent names.

Files:
* README.md - Add a "Custom Codex Agents" section.
* PORTING.md - Add maintainer-specific generated-agent lifecycle notes.
* plugins/hve-core-codex/generated/codex-agents/README.md - Optional generated or hand-maintained short readme for users browsing the package.

Success criteria:
* Users can install generated agents without reading implementation scripts.
* Docs clearly separate plugin installation from custom-agent installation.
* Docs recommend project scope by default and explain user-global impact.

Context references:
* README.md (Lines 51-69) - Current runtime surface explanation.
* .copilot-tracking/research/2026-05-04/codex-cli-agent-porting-research.md (Lines 242-246) - Final recommendation.

Dependencies:
* Step 3.1 installer behavior.

## Implementation Phase 4: Port-Correctness Skills

<!-- parallelizable: true -->

### Step 4.1: Extend the existing port-maintainer skill

Update the existing `hve-port-maintainer` skill so it explicitly covers generated Codex custom-agent lifecycle checks. Keep this as the top-level maintenance entrypoint instead of forcing users to remember several narrow skills.

Files:
* overlays/hve-core-codex/skills/hve-port-maintainer/SKILL.md - Add generated custom-agent responsibilities.
* overlays/hve-core-codex/skills/hve-port-maintainer/references/reconciliation.md - Add the detailed checklist from Step 2.2.

Success criteria:
* "Use HVE Port Maintainer" routes maintainers to generated-agent verification.
* The skill warns that generated TOML still needs out-of-band installation.
* The skill tells maintainers to update install profiles when new upstream agents arrive.

Context references:
* overlays/hve-core-codex/skills/hve-port-maintainer/SKILL.md (Lines 10-23) - Current port-maintainer workflow and rules.

Dependencies:
* Phase 2 verification rules.

### Step 4.2: Add a dedicated custom-agent porting skill

Create a focused wrapper skill for generated custom-agent workflows, for example `hve-codex-agent-porting`. This skill should route tasks such as "generate Codex agents", "audit generated agents", "explain installation", "install project agents", and "verify new upstream agents".

Recommended skill responsibilities:
* Explain plugin versus out-of-band custom-agent installation.
* Run or describe `scripts/generate-codex-agents.js`.
* Run or describe `scripts/install-codex-agents.sh`.
* Interpret `manifest.json`.
* Help maintainers decide install profiles for new upstream agents.
* Avoid claiming generated TOML is active until installed.

Files:
* overlays/hve-core-codex/skills/hve-codex-agent-porting/SKILL.md - New wrapper skill.
* overlays/hve-core-codex/skills/hve-codex-agent-porting/references/agent-porting.md - Detailed workflow and command references.
* scripts/verify-port.sh - Add this wrapper to required wrapper skills after sync overlay.
* README.md and PORTING.md - Mention the new skill.

Success criteria:
* The skill is discoverable after sync.
* `scripts/verify-port.sh` requires the skill to exist.
* The skill body stays short and keeps detailed workflow in `references/`.

Context references:
* PORTING.md (Lines 95-115) - Existing wrapper skill policy.
* overlays/hve-core-codex/skills/hve-port-maintainer/references/reconciliation.md (Lines 37-50) - Existing wrapper route and exclusion policy.

Dependencies:
* Phase 1 generator and Phase 3 installer command names.

### Step 4.3: Defer broader skill splitting until workflows prove separate

Do not create a large set of narrow port skills in the first implementation. Keep the first pass to:
* Existing `hve-port-maintainer` updated for broad maintenance.
* New `hve-codex-agent-porting` focused on generated custom-agent lifecycle.

Possible follow-on skills can be considered later if the workflows become noisy:
* `hve-port-surface-audit` for command/agent/route audit only.
* `hve-port-release-check` for final release packaging and cache checks.

Files:
* .copilot-tracking/plans/logs/2026-05-04/codex-agent-sync-cycle-log.md - Record deferred split as follow-on work.

Success criteria:
* Initial implementation improves correctness without creating skill sprawl.
* Follow-on skill split is documented but not required for the current task.

Context references:
* User request in conversation - User asked to think about a set of skills specific to making sure the port is done correctly.

Dependencies:
* None.

## Implementation Phase 5: Final Validation

<!-- parallelizable: false -->

### Step 5.1: Run full port validation

Run validation after all implementation phases:
* `./scripts/sync-upstream.sh ../hve-core`
* `./scripts/verify-port.sh`
* `node scripts/generate-codex-agents.js --check`
* `scripts/install-codex-agents.sh --dry-run --scope project --target /tmp/hve-core-codex-agent-install-test`

Files:
* scripts/sync-upstream.sh - Full sync validation.
* scripts/verify-port.sh - Full port validation.
* plugins/hve-core-codex/generated/codex-agents/ - Generated artifact validation.

Success criteria:
* Full sync succeeds.
* Full verify succeeds.
* Dry-run install reports expected files without writing to global config.
* Generated output count matches plugin agent count.

Context references:
* PORTING.md (Lines 145-156) - Current refresh workflow.
* scripts/verify-port.sh (Lines 226-228) - Current successful verification output.

Dependencies:
* Phases 1 through 4.

### Step 5.2: Test one project-scoped install path

Use a temporary directory under `/tmp` or another disposable location. Run a project-scoped install and verify that generated TOML files and install manifest land under `.codex/agents/`.

Do not write to `~/.codex/agents/` during automated validation unless the user explicitly requests global installation.

Files:
* /tmp/hve-core-codex-agent-install-test/.codex/agents/ - Temporary validation target outside the repo.

Success criteria:
* Installer creates `.codex/agents/`.
* Installer writes selected TOML files and install manifest.
* Installer can run with `--prune` and `--uninstall` without touching unrelated files.

Context references:
* .copilot-tracking/research/2026-05-04/codex-cli-agent-porting-research.md (Lines 115-118) - Project scope default rationale.

Dependencies:
* Step 3.1 installer.

### Step 5.3: Review generated diffs and update lock metadata

Review all generated and hand-maintained diffs. Confirm generated files are updated only by sync/generation, and durable Codex-specific behavior lives in scripts, overlays, docs, and verification.

Files:
* upstream.lock.json - Confirm generated count metadata.
* plugins/hve-core-codex/generated/codex-agents/manifest.json - Confirm source mapping and counts.
* README.md - Confirm user installation docs.
* PORTING.md - Confirm maintainer lifecycle docs.

Success criteria:
* No generated plugin directories are hand-edited.
* New generated custom-agent artifacts are reproducible.
* Hand-maintained overlay skills document the intended maintenance workflow.

Context references:
* PORTING.md (Lines 29-59) - Generated versus hand-maintained boundaries.

Dependencies:
* All previous validation steps.

## Dependencies

* Node.js for generator and verification scripts.
* Bash for sync, verify, and installer scripts.
* Existing adjacent upstream checkout at `../hve-core`.
* Codex custom-agent behavior documented under `~/.codex/agents/` and `.codex/agents/`.

## Success Criteria

* Generated Codex custom-agent TOML is refreshed every upstream sync cycle.
* New upstream plugin agents cannot pass verification without generated TOML and manifest entries.
* Unknown upstream agent frontmatter keys fail verification until intentionally mapped.
* Users have explicit project and user-scope installation instructions.
* Wrapper skills remain the reliable default entrypoint when custom agents are not installed.
* Port-maintainer workflows include generated-agent checks.
* A focused custom-agent porting skill exists for generator, audit, and installer workflows.
