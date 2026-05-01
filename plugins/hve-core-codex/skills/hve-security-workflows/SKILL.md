---
name: hve-security-workflows
description: Route HVE Core security review, OWASP assessment, Secure by Design, security planning, SSSC supply chain planning, risk register, incident response, and RAI-from-security workflows through Codex-compatible command, agent, instruction, template, and skill assets.
---

# HVE Security Workflows

Use this skill when the user asks for HVE security planning or review work.

## Runtime-first routing

1. Prefer plugin slash commands when the current Codex surface supports them.
2. Otherwise read [references/routes.md](references/routes.md), choose the matching security route, and load only the listed files.
3. Apply the command file as the workflow entrypoint. Apply the agent file as role and process guidance.
4. Use OWASP and Secure by Design skills as knowledge sources when the selected route calls for them.

## Codex constraints

- Upstream `agents/` files are packaged agent definitions, not guaranteed `spawn_agent` roles.
- Use built-in Codex subagent roles only when available and useful. Pass the relevant HVE security agent guidance into those subagent prompts.
- Do not run tools that mutate external issue trackers, repositories, or cloud resources without explicit user approval.
