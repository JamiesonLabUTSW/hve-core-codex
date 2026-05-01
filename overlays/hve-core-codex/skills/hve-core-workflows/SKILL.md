---
name: hve-core-workflows
description: Route HVE Core RPI, task planning, research, implementation, review, challenge, checkpoint, prompt, git, documentation, and pull request workflows through Codex-compatible command and agent assets. Use when a user asks for HVE RPI, task-plan, task-research, task-implement, task-review, task-challenge, checkpoint, prompt-build, prompt-analyze, prompt-refactor, git-commit, git-merge, doc-ops, or pull-request workflows.
---

# HVE Core Workflows

Use this skill as the Codex-facing router for core HVE workflows.

## Runtime-first routing

1. If the current Codex surface supports plugin slash commands and the user invoked one, prefer the matching command.
2. Otherwise read [references/routes.md](references/routes.md), choose the smallest matching route, and load only the listed command and agent markdown files.
3. Read command files first. If a route has an agent file, read it second and apply it as workflow guidance.
4. Treat `agents/` markdown as packaged agent definitions. Do not pass upstream agent names to `spawn_agent` unless the Codex runtime exposes those names. When Codex subagents are useful, use only the built-in roles available in the current runtime and pass relevant HVE guidance in the prompt.

## Operating rules

- Keep generated upstream files unchanged. Fix Codex-specific routing in overlay skills or route references.
- Preserve upstream tracking artifact conventions such as `.copilot-tracking/` when the loaded workflow requires them.
- If a command references tools or runtime capabilities that are unavailable in Codex, explain the limitation and continue with the closest file-based workflow.
