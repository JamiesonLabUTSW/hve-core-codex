---
name: hve-design-thinking-workflows
description: Route HVE Core Design Thinking coaching and DT-to-RPI handoff workflows through Codex-compatible command and agent assets. Use when the user asks for DT handoff, Problem Space handoff, Solution Space handoff, Implementation Space handoff, or Design Thinking RPI transition workflows.
---

# HVE Design Thinking Workflows

Use this skill for HVE Design Thinking workflow transitions, especially DT-to-RPI handoffs.

## Path Resolution

Resolve HVE assets from the installed plugin root, not from the user's repository. This skill lives at `skills/hve-design-thinking-workflows/SKILL.md`, so the plugin root is two directories up from this skill directory. Route assets such as `commands/design-thinking/dt-handoff-problem-space.md` resolve as `../../commands/design-thinking/dt-handoff-problem-space.md` from this skill directory. Do not search the filesystem for these assets unless a listed path is missing.

## Runtime-First Routing

1. Prefer plugin slash commands when the current Codex surface supports them.
2. Otherwise read [references/routes.md](references/routes.md), choose the matching Design Thinking workflow, and load only the listed assets using the path resolution rule above.
3. Read command files first. Read supporting agent files as workflow guidance, not as Codex `spawn_agent` role names unless the runtime exposes those roles.
4. Preserve `.copilot-tracking/dt/{project-slug}/` and `.copilot-tracking/research/` artifact paths required by the loaded command.

## Codex Constraints

- Keep generated upstream command files unchanged. Fix Codex-specific routing in overlay skills or route references.
- Treat `agent: agent` in upstream Design Thinking prompt files as VS Code GitHub Copilot built-in agent mode metadata, not as a missing HVE agent.
- Use generated Codex custom-agent TOML only when the user has explicitly installed those agents into `.codex/agents/` or `~/.codex/agents/`.
