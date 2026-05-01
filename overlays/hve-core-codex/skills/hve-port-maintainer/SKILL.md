---
name: hve-port-maintainer
description: Maintain the hve-core-codex downstream port when upstream microsoft/hve-core changes. Use when syncing upstream, validating command and agent runtime surfaces, reconciling new upstream commands or agents with wrapper skills, updating route maps, or explaining porting boundaries.
---

# HVE Port Maintainer

Use this skill to maintain the downstream Codex plugin port.

## Workflow

1. Read [references/reconciliation.md](references/reconciliation.md).
2. Run the upstream sync when requested by the user.
3. Run port verification, including the command and agent surface audit.
4. Inspect new or removed upstream command and agent files.
5. Update wrapper route references only for user-facing workflows that should be discoverable through skills.

## Rules

- Do not hand-edit generated plugin directories for durable changes.
- Put Codex-specific skills, helper commands, and route references under `overlays/hve-core-codex/`.
- Treat upstream command files as the target slash-command surface.
- Treat upstream agent files as packaged agent definitions. Do not claim they are Codex `spawn_agent` roles unless the runtime exposes them.
