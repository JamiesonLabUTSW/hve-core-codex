# HVE GitHub Automation Routes

Command and agent paths are relative to the plugin root. From this wrapper skill directory, prefix them with `../../`. The optional `github-actions/` package paths refer to this repository checkout, not the installed plugin payload.

| User intent | Command or package asset | Supporting assets |
|---|---|---|
| Explain the optional workflow package | `commands/github/explain-agentic-workflows.md` | `github-actions/README.md` |
| Audit a repo before installing workflows | `commands/github/audit-agentic-workflows.md` | `github-actions/README.md`, `github-actions/workflows/` |
| Install or update workflows | `commands/github/install-agentic-workflows.md` | `github-actions/workflows/`, `github-actions/artifacts/.github/` |
| GitHub issue discovery | `commands/github/github-discover-issues.md` | `agents/github/github-backlog-manager.md` |
| GitHub issue triage | `commands/github/github-triage-issues.md` | `agents/github/github-backlog-manager.md` |
| GitHub sprint planning | `commands/github/github-sprint-plan.md` | `agents/github/github-backlog-manager.md` |
| GitHub backlog execution | `commands/github/github-execute-backlog.md` | `agents/github/github-backlog-manager.md` |
| Add a GitHub issue | `commands/github/github-add-issue.md` | `agents/github/github-backlog-manager.md` |
