---
description: Audit a repository for HVE Core GitHub Agentic Workflow installation readiness.
---

# Audit HVE Core Agentic Workflows

Check whether the current repository is ready to run the optional HVE Core GitHub Agentic Workflow package.

## Preflight

1. Confirm this is a GitHub repository.
2. Confirm `.github/workflows/` exists.
3. Do not modify files unless the user explicitly asks for fixes.

## Plan

Inspect workflow files, required paired lock files, imported HVE source artifacts, labels, secrets documentation, and permissions. Produce an advisory readiness report.

## Commands

Check workflow file presence:

```bash
ls .github/workflows/issue-triage.md .github/workflows/issue-triage.lock.yml
ls .github/workflows/issue-implement.md .github/workflows/issue-implement.lock.yml
ls .github/workflows/pr-review.md .github/workflows/pr-review.lock.yml
ls .github/workflows/dependency-pr-review.md .github/workflows/dependency-pr-review.lock.yml
ls .github/workflows/doc-update-check.md .github/workflows/doc-update-check.lock.yml
```

Check imported HVE source artifacts:

```bash
ls .github/agents/issue-triage.agent.md
ls .github/agents/dependency-reviewer.agent.md
ls .github/agents/doc-update-checker.agent.md
ls .github/agents/hve-core/task-implementor.agent.md
ls .github/agents/hve-core/pr-review.agent.md
ls .github/instructions/hve-core/pull-request.instructions.md
```

Inspect referenced labels and permissions:

```bash
rg -n "agent-ready|needs-triage|needs-revision|review-passed|COPILOT_GITHUB_TOKEN|GH_AW_" .github/workflows
```

If GitHub CLI is authenticated, inspect repository configuration:

```bash
gh repo view --json nameWithOwner,viewerPermission
gh api repos/{owner}/{repo}/actions/permissions
gh issue list --limit 1
```

Do not print secret values. Only report whether required secret names are documented or configured when that information is available.

## Verification

Classify readiness as:

| Status | Meaning |
|---|---|
| Ready | Workflow pairs are present and no obvious configuration gaps were found. |
| Partial | Workflows are present but labels, secrets, permissions, or branch protection need review. |
| Missing | One or more workflow pairs are absent. |

## Summary

Return a concise checklist of installed workflow pairs, missing imported artifacts, likely missing labels, required secrets, and any permission risks.
