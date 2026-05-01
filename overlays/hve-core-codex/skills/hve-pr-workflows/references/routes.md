# HVE PR Workflow Routes

| User intent | Command asset | Agent, instruction, template, or skill assets |
|---|---|---|
| Pull request description | `plugins/hve-core-codex/commands/hve-core/pull-request.md` | `plugins/hve-core-codex/instructions/hve-core/pull-request.instructions.md`, `plugins/hve-core-codex/skills/pr-reference/SKILL.md` |
| Comprehensive PR review | `plugins/hve-core-codex/commands/coding-standards/code-review-full.md` | `plugins/hve-core-codex/agents/coding-standards/code-review-full.md`, `plugins/hve-core-codex/docs/templates/full-review-output-format.md` |
| Functional branch review | `plugins/hve-core-codex/commands/coding-standards/code-review-functional.md` | `plugins/hve-core-codex/agents/coding-standards/code-review-functional.md` |
| Standards-focused review | No dedicated command in the current bundle | `plugins/hve-core-codex/agents/coding-standards/code-review-standards.md`, `plugins/hve-core-codex/docs/templates/standards-review-output-format.md` |
| HVE PR review agent | No dedicated command in the current bundle | `plugins/hve-core-codex/agents/hve-core/pr-review.md`, `plugins/hve-core-codex/instructions/pull-request.instructions.md` |
| Azure DevOps PR creation | `plugins/hve-core-codex/commands/ado/ado-create-pull-request.md` | `plugins/hve-core-codex/agents/ado/ado-backlog-manager.md` |

If this plugin is installed outside this repository, locate the same paths relative to the installed plugin root.
