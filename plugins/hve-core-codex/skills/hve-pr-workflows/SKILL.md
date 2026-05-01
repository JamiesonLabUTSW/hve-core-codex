---
name: hve-pr-workflows
description: Route HVE Core pull request description, PR reference, branch diff review, functional review, standards review, and comprehensive PR review workflows through Codex-compatible command, agent, instruction, template, and skill assets.
---

# HVE PR Workflows

Use this skill for pull request preparation or review with HVE Core conventions.

## Path resolution

Resolve HVE assets from the installed plugin root, not from the user's repository. This skill lives at `skills/hve-pr-workflows/SKILL.md`, so the plugin root is two directories up from this skill directory. Route assets such as `commands/coding-standards/code-review-full.md` resolve as `../../commands/coding-standards/code-review-full.md` from this skill directory. Do not search the filesystem for these assets unless a listed path is missing.

## Runtime-first routing

1. Prefer plugin slash commands when the current Codex surface supports them.
2. Otherwise read [references/routes.md](references/routes.md), choose the matching PR workflow, and load only the listed assets using the path resolution rule above.
3. Generate PR reference XML with the `pr-reference` skill when a branch diff is needed.
4. Apply review output templates when reporting findings.

## Codex constraints

- Treat upstream PR agents as review guidance unless the Codex runtime exposes plugin agents directly.
- Use Codex review behavior and built-in subagent roles only when they are available in the current session.
- Do not create or update a pull request unless the user explicitly asks for that write action.
