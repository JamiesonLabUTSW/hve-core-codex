<!-- markdownlint-disable-file -->
# Task Research: Codex CLI Integration for Generic Agent Placeholder Commands

Research how the eight HVE Core command files that currently warn as `agent: agent`
can be integrated into the Codex CLI port in a more idiomatic way, using the
VS Code GitHub Copilot command/agent model and the current OpenAI Codex CLI
surface as evidence.

## Task Implementation Requests

* Investigate the eight command files flagged by `scripts/verify-port.sh` as
  generic agent placeholder warnings.
* Compare the VS Code GitHub Copilot prompt/custom-agent surface with the OpenAI
  Codex CLI surface.
* Identify implementation avenues for making those commands more idiomatic in
  the Codex CLI port.
* Recommend one path for later implementation.

## Scope and Success Criteria

* Scope: research only. No runtime behavior or generated sync scripts are changed
  in this task.
* Assumptions:
  * The current repository policy remains valid: generated upstream payloads
    should not be hand-edited.
  * Plugin skills are the reliable Codex-discoverable fallback layer.
  * Generated Codex custom-agent TOML remains an explicit out-of-band install
    path unless Codex plugin docs add a first-class packaged custom-agent surface.
* Success Criteria:
  * The warning cause is documented with exact local files.
  * VS Code and Codex surfaces are compared from current official docs.
  * A preferred integration approach is selected with rationale.
  * Implementation follow-ups are concrete enough for a planning task.

## Research Executed

### File Analysis

* `scripts/audit-runtime-surfaces.js:127-132`
  * The audit normalizes any command frontmatter `agent` value. When the normalized
    value is exactly `agent`, it records a warning instead of failing. Non-generic
    agent values must resolve to a packaged agent name or file stem.
* `plugins/hve-core-codex/commands/design-thinking/dt-handoff-implementation-space.md:1-7`
  * VS Code prompt-file frontmatter sets `agent: 'agent'` and VS Code-specific
    tool IDs. The command body explicitly targets Task Researcher through the
    DT-to-RPI handoff artifact it creates.
* `plugins/hve-core-codex/commands/design-thinking/dt-handoff-problem-space.md:1-7`
  * Same pattern: generic Copilot agent mode plus handoff content targeting the
    RPI researcher flow.
* `plugins/hve-core-codex/commands/design-thinking/dt-handoff-solution-space.md:1-7`
  * Same pattern: generic Copilot agent mode plus handoff content targeting the
    RPI researcher flow.
* `plugins/hve-core-codex/commands/hve-core/git-commit-message.md:1-13`
  * This is a lightweight prompt file for producing a commit message. It is not
    naturally a separate persona; it mostly references
    `instructions/hve-core/commit-message.instructions.md`.
* `plugins/hve-core-codex/commands/hve-core/git-commit.md:1-22`
  * This is an operational workflow that stages and commits changes. In Codex,
    it is better expressed as a skill-driven procedure because it has safety
    checks and command constraints.
* `plugins/hve-core-codex/commands/hve-core/git-merge.md:1-19`
  * This is a git operation orchestrator that references
    `instructions/hve-core/git-merge.instructions.md`.
* `plugins/hve-core-codex/commands/hve-core/git-setup.md:1-35`
  * This is an interactive setup workflow. It does not need a distinct custom
    subagent; it needs careful procedural guardrails.
* `plugins/hve-core-codex/commands/hve-core/pull-request.md:1-19`
  * This generates `.copilot-tracking/pr/pr.md` via PR-reference guidance and
    mentions parallel subagent review. Codex should route this through skills and
    built-in/custom subagents only when the runtime exposes them.
* `plugins/hve-core-codex/skills/hve-core-workflows/references/routes.md:15-16`
  * Existing wrapper coverage already maps `pull-request`, `git-commit`,
    `git-commit-message`, `git-setup`, and `git-merge` to relevant command and
    instruction assets.
* `plugins/hve-core-codex/skills/hve-pr-workflows/references/routes.md:7`
  * Existing PR wrapper coverage maps pull-request description generation to the
    command, instruction, and `pr-reference` skill.
* `PORTING.md:83-91`
  * The current port policy says upstream agent files are not dynamic Codex
    `spawn_agent` roles and that generated custom-agent TOML must be explicitly
    installed into `.codex/agents/` or `~/.codex/agents/`.
* `plugins/hve-core-codex/.codex-plugin/plugin.json:27`
  * The packaged plugin manifest advertises `skills` only as the first-class
    component path. The manifest metadata mentions commands and agents in prose,
    but there is no documented `commands` or `agents` manifest field in this file.
* `scripts/generate-codex-agents.js:197-231`
  * Generated custom-agent TOML retains non-Codex frontmatter fields as
    compatibility notes, explicitly saying they do not grant tools, create
    automatic handoffs, or register nested roles.

### External Research

* VS Code prompt files: https://code.visualstudio.com/docs/copilot/customization/prompt-files
  * Prompt files are also called slash commands and are manually invoked in chat.
  * Workspace prompt files live in `.github/prompts`.
  * Prompt frontmatter supports `agent`, where values may be `ask`, `agent`,
    `plan`, or a custom agent name.
  * Prompt frontmatter supports `tools`, and tool priority is prompt tools first,
    then referenced custom-agent tools, then selected-agent defaults.
* VS Code custom agents: https://code.visualstudio.com/docs/copilot/customization/custom-agents
  * Workspace custom agents live in `.github/agents`.
  * Custom agent files are Markdown `.agent.md` files.
  * VS Code detects `.md` files in `.github/agents` as custom agents.
  * Frontmatter supports `tools`, `agents`, `handoffs`, and related workflow fields.
* GitHub prompt-file tutorial:
  https://docs.github.com/en/copilot/tutorials/customization-library/prompt-files/your-first-prompt-file
  * GitHub's example prompt uses `agent: 'agent'`, confirming that this value is a
    normal Copilot prompt-file mode selector rather than an HVE-specific agent name.
* OpenAI Codex customization docs:
  https://developers.openai.com/codex/concepts/customization#skills
  * Codex skills are the preferred reusable workflow unit when instructions,
    scripts, examples, or references matter.
  * Skills can be global in `$HOME/.agents/skills` or repo-specific in
    `.agents/skills`.
  * Codex uses progressive disclosure: metadata first, `SKILL.md` only when chosen,
    and references/scripts only when needed.
* OpenAI Codex plugin docs:
  https://developers.openai.com/codex/plugins/build#plugin-structure
  * Documented plugin structure includes `.codex-plugin/plugin.json`, `skills/`,
    `.app.json`, `.mcp.json`, hooks, and assets.
  * The documented manifest example includes a `skills` field but no `commands`
    or packaged-agent field.
* OpenAI Codex custom agents:
  https://developers.openai.com/codex/subagents#custom-agents
  * Codex built-in agents are `default`, `worker`, and `explorer`.
  * Custom agents are standalone TOML files under `~/.codex/agents/` or
    `.codex/agents/`.
  * Required fields are `name`, `description`, and `developer_instructions`.
  * Custom agents are configuration layers for spawned sessions, not prompt-file
    slash commands.
* OpenAI Codex slash commands:
  https://developers.openai.com/codex/cli/slash-commands#built-in-slash-commands
  * Codex documents built-in slash commands such as `/agent`, `/plugins`,
    `/init`, `/plan`, `/review`, and `/status`.
  * The page does not document a repo/plugin custom slash-command file format
    equivalent to VS Code `.prompt.md`.

## Key Discoveries

### Why the Warnings Exist

The eight warning files are valid VS Code GitHub Copilot prompt files. In that
surface, `agent: 'agent'` means "run this prompt in Copilot's built-in agent
mode." In this Codex port, `scripts/audit-runtime-surfaces.js` sees the same
frontmatter and tries to decide whether the command references a packaged HVE
agent. The value `agent` is not an HVE packaged agent; it is a Copilot mode
placeholder, so the audit warns instead of failing.

### Surface Mismatch

VS Code has three separate but interoperable concepts:

* Prompt files: lightweight slash commands in `.github/prompts`.
* Custom agents: persistent personas in `.github/agents`.
* Agent skills: richer reusable capabilities with supporting files.

Codex CLI's documented reliable equivalents are different:

* Built-in slash commands are fixed CLI commands, not repo Markdown prompt files.
* Skills are the documented reusable workflow/package surface.
* Custom agents are standalone TOML files installed into `.codex/agents/` or
  `~/.codex/agents/`, primarily for spawned subagent roles.
* Plugins distribute skills, apps, MCP config, hooks, and assets.

Therefore, translating `agent: agent` to a Codex custom agent is the wrong
semantic move. The better move is to translate prompt-file workflows into skills
and route maps, and optionally attach generated custom agents as out-of-band
enhancements where a real persona exists.

### Existing Coverage

Five of the eight warnings are already covered by wrapper route maps:

* `git-commit-message.md`
* `git-commit.md`
* `git-merge.md`
* `git-setup.md`
* `pull-request.md`

The three Design Thinking handoff commands are not currently exposed through a
dedicated wrapper route. They are functionally tied to `DT Coach` and
`Task Researcher`, both of which exist as packaged HVE agent markdown and
generated custom-agent TOML:

* `plugins/hve-core-codex/agents/design-thinking/dt-coach.md`
* `plugins/hve-core-codex/agents/hve-core/task-researcher.md`
* `plugins/hve-core-codex/generated/codex-agents/hve_design_thinking_dt_coach.toml`
* `plugins/hve-core-codex/generated/codex-agents/hve_hve_core_task_researcher.toml`

## Technical Scenarios

### Scenario 1: Change Upstream Command `agent` Frontmatter

Preferred Approach: Rejected.

This would edit generated upstream payloads or require overlays that replace
upstream command files. It would also be semantically suspect: `agent: agent` is
valid VS Code prompt-file syntax and does not mean "use a specific HVE agent".
Changing it to `Task Researcher` or generated Codex names could make the source
less faithful to upstream and could misrepresent the command's VS Code behavior.

### Scenario 2: Generate Codex Slash Commands from Prompt Files

Preferred Approach: Rejected for now.

Codex currently documents built-in slash commands and plugin skills, but not a
repo/plugin custom slash-command Markdown format equivalent to VS Code prompt
files. The plugin build docs also do not include a `commands` manifest field.
Keeping `plugins/hve-core-codex/commands/` as a future-facing packaged asset is
reasonable, but relying on it as the idiomatic current integration point is not.

### Scenario 3: Route Warning Files Through Skills and Downgrade Covered Warnings

Preferred Approach: Selected.

Codex skills are the documented reusable workflow surface and already fit this
port's design. The implementation should:

1. Keep upstream command files unchanged.
2. Add route coverage for the three Design Thinking handoff commands in a new
   or existing Design Thinking wrapper skill.
3. Treat the five existing git/PR warnings as covered because wrapper skills
   already route them.
4. Update the runtime audit to classify `agent: agent` files as:
   * covered VS Code agent-mode prompt files, if they appear in a wrapper route
     allowlist or generated route index;
   * warnings, if they are still un-routed;
   * errors only when a non-generic `agent` reference does not resolve.
5. Document that `agent: agent` is a Copilot mode selector, not a missing HVE
   agent.

### Scenario 4: Require Out-of-Band Custom Agent Installation

Preferred Approach: Complementary, not primary.

Generated Codex custom agents are useful for users who want real spawned HVE
roles. For these eight commands, only the Design Thinking handoffs and PR review
have nearby persona value. Git setup/commit/merge are procedural workflows and
should stay skill-first. Installing all generated agents out-of-band should
remain optional and explicit.

## Recommended Approach

Use skill-first routing as the idiomatic Codex integration:

* Add an HVE Design Thinking workflow wrapper skill or extend an existing wrapper
  to route the three `dt-handoff-*` commands. Include both `DT Coach` and
  `Task Researcher` as supporting assets in the route map.
* Keep git and PR workflows under `hve-core-workflows` and `hve-pr-workflows`.
  Consider adding a focused `hve-git-workflows` wrapper only if discovery needs
  are not met by the current broader wrapper.
* Update the audit so a generic `agent` value is not inherently suspicious when
  the command is explicitly covered by a Codex wrapper route. The audit output
  should distinguish "covered generic Copilot agent mode" from "unrouted generic
  placeholder".
* Leave generated upstream command files untouched during sync cycles.
* Keep custom-agent TOML generation and installation as the optional enhancement
  path, not the primary integration mechanism for these eight command files.

## Concrete Implementation Sketch

```text
overlays/hve-core-codex/skills/hve-design-thinking-workflows/
  SKILL.md
  references/routes.md

scripts/audit-runtime-surfaces.js
  - load wrapper route files
  - build a set of covered command asset paths
  - if agent normalizes to "agent" and command is covered, do not warn
  - if agent normalizes to "agent" and command is not covered, warn
  - keep unresolved non-generic agent values as errors

scripts/verify-port.sh
  - require hve-design-thinking-workflows wrapper skill
  - continue running runtime surface audit

PORTING.md / README.md
  - document that VS Code `agent: agent` maps to Codex skill routing
```

Candidate Design Thinking routes:

```markdown
| User intent | Command asset | Supporting assets |
|---|---|---|
| DT Problem Space RPI handoff | `commands/design-thinking/dt-handoff-problem-space.md` | `agents/design-thinking/dt-coach.md`, `agents/hve-core/task-researcher.md` |
| DT Solution Space RPI handoff | `commands/design-thinking/dt-handoff-solution-space.md` | `agents/design-thinking/dt-coach.md`, `agents/hve-core/task-researcher.md` |
| DT Implementation Space RPI handoff | `commands/design-thinking/dt-handoff-implementation-space.md` | `agents/design-thinking/dt-coach.md`, `agents/hve-core/task-researcher.md` |
```

## Potential Next Research

* Inspect current Codex plugin runtime behavior for `commands/` payloads through
  `codex debug prompt-input` after a plugin cache refresh.
  * Reasoning: official docs do not currently document plugin command files, but
    the local port keeps them for runtime-first compatibility if Codex surfaces
    them.
* Review whether a focused `hve-git-workflows` skill improves discoverability
  compared with the current `hve-core-workflows` route.
  * Reasoning: the git warnings are already covered, so this is about UX rather
    than correctness.

## Completion Status

Research complete. Selected approach: route these workflows through Codex skills,
add missing Design Thinking wrapper coverage, and teach the audit to suppress
generic `agent` warnings only when the command is covered by a Codex route.
