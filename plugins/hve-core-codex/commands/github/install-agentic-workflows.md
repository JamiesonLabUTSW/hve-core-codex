---
description: Install or update the optional HVE Core GitHub Agentic Workflow package in the current repository.
---

# Install HVE Core Agentic Workflows

Install the optional GitHub Actions workflow package that brings HVE Core event-driven automation to a repository.

## Preflight

1. Confirm this is a GitHub repository with a `.git` directory and a configured `origin` remote.
2. Confirm the user wants repository event automation installed. These workflows can comment, label, review PRs, and create PRs when configured with the required GitHub permissions and secrets.
3. Inspect existing `.github/workflows/` files for name collisions with:
   * `issue-triage`
   * `issue-implement`
   * `pr-review`
   * `dependency-pr-review`
   * `doc-update-check`
4. Confirm the source package is available from the HVE Core Codex port under `github-actions/`.

## Plan

Copy the HVE Core source artifacts and workflow files from the HVE Core Codex automation package into `.github/`, preserving existing files unless the user explicitly approves overwriting them.

## Commands

From the `hve-core-codex` repository, copy the package into a target repository:

```bash
mkdir -p /path/to/target-repo/.github/workflows
cp -R github-actions/artifacts/.github/* /path/to/target-repo/.github/
cp github-actions/workflows/* /path/to/target-repo/.github/workflows/
```

When running inside the target repository, first locate or clone the HVE Core Codex port, then copy from its `github-actions/` directory.

After copying, inspect the workflow files and configure the required repository secrets and Actions permissions documented in `github-actions/README.md`.

## Verification

1. Confirm each workflow has both source and lock files:
   * `issue-triage.md` and `issue-triage.lock.yml`
   * `issue-implement.md` and `issue-implement.lock.yml`
   * `pr-review.md` and `pr-review.lock.yml`
   * `dependency-pr-review.md` and `dependency-pr-review.lock.yml`
   * `doc-update-check.md` and `doc-update-check.lock.yml`
2. Confirm repository labels include the labels referenced by the workflows.
3. Confirm imported source agents exist under `.github/agents/`.
4. Confirm the required secrets exist before enabling write automation.
5. Run a dry audit with `/audit-agentic-workflows`.

## Summary

Report which workflow files were installed, which existing files were preserved or overwritten, and which secrets/labels still need human configuration.
