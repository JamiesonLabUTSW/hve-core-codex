# HVE PR Workflow Routes

Paths are relative to the plugin root. From this wrapper skill directory, prefix them with `../../`.

| User intent | Command asset | Agent, instruction, template, or skill assets |
|---|---|---|
| Pull request description | `commands/hve-core/pull-request.md` | `instructions/hve-core/pull-request.instructions.md`, `skills/shared/pr-reference/SKILL.md` |
| Comprehensive PR review | `commands/coding-standards/code-review-full.md` | `agents/coding-standards/code-review-full.md`, `docs/templates/full-review-output-format.md` |
| Functional branch review | `commands/coding-standards/code-review-functional.md` | `agents/coding-standards/code-review-functional.md` |
| Standards-focused review | No dedicated command in the current bundle | `agents/coding-standards/code-review-standards.md`, `docs/templates/standards-review-output-format.md`, `skills/coding-standards/` |
| HVE PR review agent | No dedicated command in the current bundle | `agents/hve-core/pr-review.md`, `instructions/pull-request.instructions.md` |
| Azure DevOps PR creation | `commands/ado/ado-create-pull-request.md` | `agents/ado/ado-backlog-manager.md` |
