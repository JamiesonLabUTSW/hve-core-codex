# HVE Core Workflow Routes

Load only the files needed for the requested workflow.

| User intent | Command asset | Agent asset |
|---|---|---|
| RPI, Research-Plan-Implement-Review, autonomous workflow | `plugins/hve-core-codex/commands/hve-core/rpi.md` | `plugins/hve-core-codex/agents/hve-core/rpi-agent.md` |
| Task planning | `plugins/hve-core-codex/commands/hve-core/task-plan.md` | `plugins/hve-core-codex/agents/hve-core/task-planner.md` |
| Task research | `plugins/hve-core-codex/commands/hve-core/task-research.md` | `plugins/hve-core-codex/agents/hve-core/task-researcher.md` |
| Task implementation | `plugins/hve-core-codex/commands/hve-core/task-implement.md` | `plugins/hve-core-codex/agents/hve-core/task-implementor.md` |
| Task review | `plugins/hve-core-codex/commands/hve-core/task-review.md` | `plugins/hve-core-codex/agents/hve-core/task-reviewer.md` |
| Task challenge | `plugins/hve-core-codex/commands/hve-core/task-challenge.md` | `plugins/hve-core-codex/agents/hve-core/task-challenger.md` |
| Checkpoint or memory | `plugins/hve-core-codex/commands/hve-core/checkpoint.md` | `plugins/hve-core-codex/agents/hve-core/memory.md` |
| Prompt build, analyze, or refactor | `plugins/hve-core-codex/commands/hve-core/prompt-build.md`, `plugins/hve-core-codex/commands/hve-core/prompt-analyze.md`, or `plugins/hve-core-codex/commands/hve-core/prompt-refactor.md` | `plugins/hve-core-codex/agents/hve-core/prompt-builder.md` |
| Pull request description | `plugins/hve-core-codex/commands/hve-core/pull-request.md` | `plugins/hve-core-codex/instructions/hve-core/pull-request.instructions.md` and `plugins/hve-core-codex/skills/pr-reference/SKILL.md` |
| Git commit, commit message, setup, merge, or rebase | `plugins/hve-core-codex/commands/hve-core/git-commit.md`, `plugins/hve-core-codex/commands/hve-core/git-commit-message.md`, `plugins/hve-core-codex/commands/hve-core/git-setup.md`, or `plugins/hve-core-codex/commands/hve-core/git-merge.md` | `plugins/hve-core-codex/instructions/hve-core/commit-message.instructions.md` or `plugins/hve-core-codex/instructions/hve-core/git-merge.instructions.md` as needed |
| Documentation operations | `plugins/hve-core-codex/commands/hve-core/doc-ops-update.md` | `plugins/hve-core-codex/agents/hve-core/doc-ops.md` |

If this plugin is installed outside this repository, locate the same paths relative to the installed plugin root.
