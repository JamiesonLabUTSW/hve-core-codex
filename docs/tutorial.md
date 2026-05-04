# First HVE Core Codex Workflow

This tutorial walks through a practical first path for using HVE Core from Codex.
It assumes you are in a repository where the plugin is installed or available as
a local checkout.

## 1. Install Or Refresh The Plugin

Register the public marketplace source:

```bash
codex plugin marketplace add https://github.com/JamiesonLabUTSW/hve-core-codex
```

If the marketplace is already registered, refresh it:

```bash
codex plugin marketplace upgrade hve-core-codex-local
```

For local development, use your local checkout path instead of the public URL.

## 2. Verify The HVE Entry Point

Start with a non-mutating discovery request:

```text
Use HVE task research to inspect this repository structure and explain which HVE workflows would be useful here. Do not modify files.
```

You should see Codex route through the HVE workflow skill and inspect the
repository before recommending a path.

If the skill is not discovered, try the file-path fallback:

```text
Use plugins/hve-core-codex/skills/hve-core-workflows/SKILL.md to inspect this repository structure. Do not modify files.
```

## 3. Run A Small RPI Task

Choose a small task that needs context but has low risk. Documentation cleanup is
a good first task:

```text
Use HVE RPI to update one outdated README section after researching the current repository conventions.
```

RPI should move through:

1. Research: inspect the repo and gather evidence.
2. Plan: choose a small implementation path.
3. Implement: edit the relevant files.
4. Review: check the result against the request.
5. Discover: suggest sensible follow-up work.

RPI may write `.copilot-tracking/` artifacts. In this repository that directory
is gitignored, so workflow state stays local unless you explicitly choose to
share it.

## 4. Try Design Thinking When The Problem Is Unclear

Use Design Thinking before RPI when the request names a solution but not the
validated user problem:

```text
Use HVE Design Thinking to assess this feature idea and prepare a Problem Space handoff if it is ready for RPI.
```

Design Thinking is useful when:

* stakeholders disagree;
* requirements describe a desired UI or tool rather than a user need;
* user adoption matters;
* a problem needs synthesis before implementation.

When the DT work reaches a natural exit point, use the handoff workflow to feed
validated context into RPI.

## 5. Prepare A Pull Request

After a branch has committed changes, ask HVE to prepare the PR:

```text
Use HVE PR workflow to generate a pull request description against origin/main.
```

When you explicitly want Codex to create the PR, say so:

```text
Use HVE PR workflow to commit, push, and create a PR against origin/main.
```

The PR workflow analyzes the branch diff, writes local PR notes, validates
readiness, and creates the PR only when requested.

## 6. Expand From The First Workflow

After the first RPI and PR flow, try the workflow that matches your next job:

| Need | Prompt |
|---|---|
| Security review | `Use HVE security review to assess this branch.` |
| Secure by Design | `Use HVE Secure by Design review for this architecture change.` |
| Backlog discovery | `Use HVE GitHub automation to discover related issues.` |
| Repo AI guidance | `Use HVE Copilot instructions to propose repo instruction files.` |
| Custom agents | `Use HVE Codex agent porting to preview generated agent installation.` |
| Port maintenance | `Use HVE port maintainer to reconcile upstream changes.` |

## 7. Know The Boundaries

This Codex port differs from upstream HVE Core in a few important ways:

* It installs through the Codex plugin marketplace, not the VS Code Marketplace.
* Wrapper skills are the reliable workflow entrypoints.
* Packaged upstream agent markdown does not automatically become active Codex
  custom agents.
* Generated custom-agent TOML must be installed explicitly.
* GitHub event automation is optional and must be copied into target
  repositories deliberately.

For deeper usage guidance, see [usage.md](usage.md). For port maintenance, see
[../PORTING.md](../PORTING.md).
