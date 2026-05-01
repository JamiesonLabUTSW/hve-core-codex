---
name: hve-github-automation
description: Install, audit, explain, or reason about the optional HVE Core GitHub Agentic Workflow package, including GitHub workflow files, packaged .github artifacts, issue triage, issue implementation, dependency PR review, doc update checks, and PR review automation.
---

# HVE GitHub Automation

Use this skill when a user asks about the optional HVE Core GitHub Agentic Workflow package or GitHub backlog automation.

## Path resolution

Resolve HVE command and agent assets from the installed plugin root, not from the user's repository. This skill lives at `skills/hve-github-automation/SKILL.md`, so the plugin root is two directories up from this skill directory. Route assets such as `commands/github/github-triage-issues.md` resolve as `../../commands/github/github-triage-issues.md` from this skill directory. Do not search the filesystem for these assets unless a listed path is missing.

## Runtime-first routing

1. Prefer plugin slash commands when the current Codex surface supports them.
2. Otherwise read [references/routes.md](references/routes.md), choose the matching route, and load only the listed files using the path resolution rule above.
3. For install and audit work, treat `github-actions/` as an opt-in package for consumer repositories, not as behavior automatically enabled by this plugin.
4. Before mutating another repository, explain the GitHub workflow write capabilities and ask for explicit confirmation.

## Boundary

Codex can help install, audit, and explain the GitHub automation package. The event-driven runtime is GitHub Actions plus GitHub Agentic Workflows in the consumer repository.
