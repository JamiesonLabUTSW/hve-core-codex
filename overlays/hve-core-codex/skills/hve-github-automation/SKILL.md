---
name: hve-github-automation
description: Install, audit, explain, or reason about the optional HVE Core GitHub Agentic Workflow package, including GitHub workflow files, packaged .github artifacts, issue triage, issue implementation, dependency PR review, doc update checks, and PR review automation.
---

# HVE GitHub Automation

Use this skill when a user asks about the optional HVE Core GitHub Agentic Workflow package or GitHub backlog automation.

## Runtime-first routing

1. Prefer plugin slash commands when the current Codex surface supports them.
2. Otherwise read [references/routes.md](references/routes.md), choose the matching route, and load only the listed files.
3. For install and audit work, treat `github-actions/` as an opt-in package for consumer repositories, not as behavior automatically enabled by this plugin.
4. Before mutating another repository, explain the GitHub workflow write capabilities and ask for explicit confirmation.

## Boundary

Codex can help install, audit, and explain the GitHub automation package. The event-driven runtime is GitHub Actions plus GitHub Agentic Workflows in the consumer repository.
