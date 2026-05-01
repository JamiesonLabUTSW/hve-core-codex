# HVE Core Workflow Routes

Load only the files needed for the requested workflow. Paths are relative to the plugin root. From this wrapper skill directory, prefix them with `../../`.

| User intent | Command asset | Agent asset |
|---|---|---|
| RPI, Research-Plan-Implement-Review, autonomous workflow | `commands/hve-core/rpi.md` | `agents/hve-core/rpi-agent.md` |
| Task planning | `commands/hve-core/task-plan.md` | `agents/hve-core/task-planner.md` |
| Task research | `commands/hve-core/task-research.md` | `agents/hve-core/task-researcher.md` |
| Task implementation | `commands/hve-core/task-implement.md` | `agents/hve-core/task-implementor.md` |
| Task review | `commands/hve-core/task-review.md` | `agents/hve-core/task-reviewer.md` |
| Task challenge | `commands/hve-core/task-challenge.md` | `agents/hve-core/task-challenger.md` |
| Checkpoint or memory | `commands/hve-core/checkpoint.md` | `agents/hve-core/memory.md` |
| Prompt build, analyze, or refactor | `commands/hve-core/prompt-build.md`, `commands/hve-core/prompt-analyze.md`, or `commands/hve-core/prompt-refactor.md` | `agents/hve-core/prompt-builder.md` |
| Pull request description | `commands/hve-core/pull-request.md` | `instructions/hve-core/pull-request.instructions.md` and `skills/pr-reference/SKILL.md` |
| Git commit, commit message, setup, merge, or rebase | `commands/hve-core/git-commit.md`, `commands/hve-core/git-commit-message.md`, `commands/hve-core/git-setup.md`, or `commands/hve-core/git-merge.md` | `instructions/hve-core/commit-message.instructions.md` or `instructions/hve-core/git-merge.instructions.md` as needed |
| Documentation operations | `commands/hve-core/doc-ops-update.md` | `agents/hve-core/doc-ops.md` |
