# HVE Core Codex Usage Guide

This guide explains how to discover and invoke HVE Core workflows from Codex.
For a first hands-on path, see [tutorial.md](tutorial.md).

## Mental Model

HVE Core is not just a file bundle. It is a set of structured AI collaboration
patterns for engineering work:

* Use **Design Thinking** when the user problem, stakeholder context, or solution
  direction is still unclear.
* Use **RPI** when the target is known but the implementation needs research,
  planning, validation, or multi-file coordination.
* Use **review, security, backlog, and PR workflows** when the work is already
  moving through delivery and needs a specialized quality gate.

In Codex, the most reliable way to reach these workflows is through wrapper
skills. The wrapper skills load the right packaged command, agent, instruction,
template, or skill assets and adapt them to the Codex runtime.

## Preferred Invocation Style

Use normal Codex instructions:

```text
Use HVE RPI to research, plan, implement, review, and discover follow-up work for this task.
Use HVE task research to inspect this repository and produce a recommendation. Do not edit files.
Use HVE security review to assess this branch for LLM and web application risks.
Use HVE PR workflow to generate a pull request description against origin/main.
```

Command-style shorthand is accepted where the runtime exposes it, but it should
not be required for day-to-day use:

```text
$hve-core-codex rpi task="Implement this documentation update."
```

## Wrapper Skill Discovery

| Wrapper skill | Use it when... | Typical prompt |
|---|---|---|
| `hve-core-workflows` | You need RPI, task research, task planning, implementation, review, challenge, checkpoint, prompt, git, documentation, or PR workflows. | `Use HVE RPI to complete this task end to end.` |
| `hve-design-thinking-workflows` | You need a Design Thinking handoff into RPI after Problem, Solution, or Implementation Space work. | `Use HVE Design Thinking to create a Problem Space RPI handoff.` |
| `hve-security-workflows` | You need security review, security planning, Secure by Design review, SSSC, RAI-from-security, risk register, or incident response work. | `Use HVE security review to assess this codebase.` |
| `hve-pr-workflows` | You need PR descriptions, branch diff review, standards review, functional review, or full PR review. | `Use HVE PR workflow to prepare a PR against origin/main.` |
| `hve-github-automation` | You need to explain, audit, or install the optional GitHub Agentic Workflow package, or work with GitHub backlog workflows. | `Use HVE GitHub automation to audit this repo for workflow installation readiness.` |
| `hve-copilot-instructions` | You need to draft or update GitHub Copilot custom instruction files. | `Use HVE Copilot instructions to inspect this repo and propose instruction files.` |
| `hve-codex-agent-porting` | You need to generate, audit, explain, install, or reconcile Codex custom-agent TOML artifacts. | `Use HVE Codex agent porting to preview project-scoped custom-agent installation.` |
| `hve-port-maintainer` | You are maintaining this downstream Codex port after upstream HVE Core changes. | `Use HVE port maintainer to reconcile upstream command changes.` |

## Common Workflows

### RPI For Implementation

Use RPI when the work benefits from research and planning before edits:

```text
Use HVE RPI to add a docs tutorial after researching the current repository structure and upstream HVE docs.
```

RPI runs through Research, Plan, Implement, Review, and Discover. It may create
local `.copilot-tracking/` artifacts. In this repository those files are ignored
by git.

### Research Without Edits

Use task research when you need a recommendation or map before changing files:

```text
Use HVE task research to compare this port with upstream HVE Core. Do not modify files.
```

### Design Thinking Before RPI

Use Design Thinking when the task starts as a solution request but the real
problem is still uncertain:

```text
Use HVE Design Thinking to assess whether this feature request is ready for RPI or needs Problem Space discovery first.
```

The DT wrapper currently focuses on DT-to-RPI handoffs. It routes Problem Space,
Solution Space, and Implementation Space outputs into RPI-ready handoff
artifacts.

### PR Preparation

Use PR workflows when a branch is ready for review:

```text
Use HVE PR workflow to generate a PR body against origin/main.
```

The workflow uses the bundled `pr-reference` skill to analyze branch diffs and
write PR description artifacts before creating or updating a PR when requested.

### Security Review And Planning

Use security workflows for review and planning:

```text
Use HVE security review to assess this repo for web application and LLM risks.
Use HVE Secure by Design review for this architecture change.
Use HVE SSSC planning to assess supply chain security posture.
```

AI-assisted security outputs are planning and review aids. They do not replace
professional security tools or qualified human review.

### GitHub Automation Package

The Codex plugin does not silently enable GitHub event automation. The optional
package lives under [../github-actions/](../github-actions/) and must be copied
into a target repository intentionally.

Start with:

```text
Use HVE GitHub automation to explain the workflow package and its write capabilities.
Use HVE GitHub automation to audit this repository before installing workflows.
```

### Jira And GitLab Tracker Work

Some tracker integrations are direct skills rather than wrapper routes:

```text
Use HVE Jira to inspect issue ABC-123 and summarize status, blockers, and next action.
Use HVE GitLab to inspect this merge request and summarize failed pipeline jobs.
```

Azure DevOps assets are packaged under `commands/ado/`, `agents/ado/`, and
`instructions/ado/`. Use them when the current Codex runtime has the required
ADO tools and repository context available.

## Runtime Surfaces

The plugin preserves multiple upstream surfaces:

| Surface | Path | Codex behavior |
|---|---|---|
| Commands | `plugins/hve-core-codex/commands/` | Preserved for runtime-first command support where Codex exposes plugin commands. |
| Agents | `plugins/hve-core-codex/agents/` | Preserved as packaged agent definitions and prompt assets; not assumed to become built-in `spawn_agent` roles. |
| Instructions | `plugins/hve-core-codex/instructions/` | Used by workflows as reference and guidance. |
| Skills | `plugins/hve-core-codex/skills/` | Reliable Codex-discoverable entrypoints and reusable knowledge packages. |
| Templates | `plugins/hve-core-codex/docs/templates/` | Reusable plan, review, ADR, BRD, security, SSSC, and RAI templates. |
| Generated custom agents | `plugins/hve-core-codex/generated/codex-agents/` | Inert TOML artifacts until explicitly installed into a Codex agent directory. |

## Generated Custom Agents

The port generates 54 Codex custom-agent TOML files from upstream HVE agent
markdown. They are not activated by plugin installation.

Use a project-scoped install when you want the generated agents available in a
specific repository:

```bash
scripts/install-codex-agents.sh --dry-run --scope project --target /path/to/repo
scripts/install-codex-agents.sh --scope project --target /path/to/repo
```

After installing the default `core` profile, you can invoke generated agents by
name, for example:

```text
Use hve_hve_core_task_researcher to research this repo and create the HVE research artifact.
```

Project scope is preferred because it is explicit and reviewable. Use
`--scope user` only when you want user-global agents in `~/.codex/agents/`.

## Troubleshooting Discovery

If a wrapper skill is missing after installation:

1. Refresh the marketplace:

   ```bash
   codex plugin marketplace upgrade hve-core-codex-local
   ```

2. Restart or refresh the Codex session.
3. Invoke the wrapper by file path as a temporary fallback:

   ```text
   Use plugins/hve-core-codex/skills/hve-core-workflows/SKILL.md for this task.
   ```

If generated custom agents are missing, confirm they were installed into
`.codex/agents/` or `~/.codex/agents/`; plugin installation alone is not enough.

## Relationship To Upstream HVE Core

Upstream HVE Core targets VS Code and GitHub Copilot extension surfaces. This
port keeps the upstream toolkit intact where possible, then adds Codex-specific
wrappers, generated custom-agent TOML, marketplace metadata, and optional
GitHub automation packaging.

Use upstream documentation for methodology depth and this repository's docs for
Codex-specific invocation and port boundaries.
