---
description: Explain the optional HVE Core GitHub Agentic Workflow package and its write capabilities.
---

# Explain HVE Core Agentic Workflows

Explain the optional GitHub Actions automation package included with the HVE Core Codex port.

## Preflight

1. Read `github-actions/README.md` when available.
2. Read the workflow markdown files when present.
3. Do not modify repository files.

## Plan

Summarize the automation boundary, event triggers, required secrets, and write actions in plain language.

## Commands

Inspect the package:

```bash
find github-actions/workflows -maxdepth 1 -type f | sort
rg -n "^description:|^on:|safe-outputs:|permissions:|COPILOT_GITHUB_TOKEN|GH_AW_" github-actions/workflows
```

If the package has already been installed into the current repository, inspect `.github/workflows/` instead.

## Verification

Make clear that:

* The Codex plugin provides interactive agents, commands, instructions, templates, and skills.
* GitHub Actions provides event-driven automation.
* The workflow package includes `github-actions/artifacts/.github/` because the workflows import HVE Core source agents and instructions at runtime.
* Installing the Codex plugin alone does not enable repository write automation.
* The workflow package is opt-in and should be reviewed before enabling.

## Summary

Explain each workflow:

| Workflow | Purpose |
|---|---|
| Issue Triage | Classifies new issues, labels them, detects duplicates, and may mark issues `agent-ready`. |
| Issue Implementation | Handles `agent-ready` issues and can open implementation PRs. |
| PR Review | Reviews pull requests and can comment, label, or request changes. |
| Dependabot PR Review | Reviews dependency bump PRs from Dependabot. |
| Documentation Update Check | Opens documentation follow-up issues after relevant main-branch changes. |
