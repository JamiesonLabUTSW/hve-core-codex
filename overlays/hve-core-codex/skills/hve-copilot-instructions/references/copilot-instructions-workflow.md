# GitHub Copilot Instructions Workflow

Use this reference when generating repository instruction files for GitHub Copilot and related coding agents.

## Supported Files

| Purpose | Path | Notes |
|---|---|---|
| Repository-wide Copilot instructions | `.github/copilot-instructions.md` | Applies broadly to Copilot requests in the repository context. |
| Path-specific Copilot instructions | `.github/instructions/<name>.instructions.md` | Use YAML frontmatter with `applyTo` globs. Subdirectories under `.github/instructions/` are acceptable. |
| Agent instructions | `AGENTS.md` | Useful for Codex and multiple AI coding agents. Keep aligned with Copilot files when both exist. |
| Compatibility instructions | `CLAUDE.md`, `GEMINI.md` | Tool-specific files. Reuse evidence, but do not assume all tools apply identical priority rules. |

## File Selection

Use `.github/copilot-instructions.md` for stable, repo-wide guidance:

- Project purpose and architecture boundaries.
- Build, test, lint, and validation commands.
- Repository-wide coding conventions.
- Security, data handling, and review expectations.
- Important generated-file or dependency-management rules.

Use `.github/instructions/*.instructions.md` for scoped guidance:

- Language rules: `python.instructions.md`, `typescript.instructions.md`, `csharp.instructions.md`.
- Framework rules: `fastapi.instructions.md`, `react.instructions.md`, `terraform.instructions.md`.
- Test rules: `tests.instructions.md`, `integration-tests.instructions.md`.
- Module rules: `api.instructions.md`, `frontend.instructions.md`, `infra.instructions.md`.

Avoid creating scoped files when the same rule applies everywhere. Avoid creating many tiny files with overlapping `applyTo` patterns.

## Frontmatter

Each `.instructions.md` file must end with `.instructions.md` and should start with frontmatter:

```markdown
---
applyTo: "**/*.py,**/pyproject.toml"
---

# Python Instructions

- Use repository-local patterns discovered from existing modules.
- Prefer explicit validation and tests for behavior changes.
```

VS Code also supports optional `name` and `description` fields in instruction file frontmatter. Use them when they clarify the instruction list:

```markdown
---
name: "Python API Standards"
description: "Python conventions for API routers, DAL code, and tests"
applyTo: "src/**/*.py,tests/**/*.py"
---
```

## Discovery Checklist

Read only what is relevant:

- Existing AI guidance: `AGENTS.md`, `.github/copilot-instructions.md`, `.github/instructions/`, `CLAUDE.md`, `GEMINI.md`.
- Repo overview: `README*`, `CONTRIBUTING*`, `docs/`, architecture notes.
- Build and package files: `package.json`, `pnpm-lock.yaml`, `pyproject.toml`, `uv.lock`, `requirements*.txt`, `Cargo.toml`, `go.mod`, `pom.xml`, `.csproj`, `global.json`.
- Tooling: formatter, linter, type checker, test config, pre-commit config.
- CI: `.github/workflows/`, Azure Pipelines, GitLab CI, Makefiles, task runners.
- Source and test layout: representative files only, enough to infer patterns.

## Content Rules

- Use direct, imperative bullets.
- Prefer rules with evidence from files, configs, or repeated patterns.
- Include exact validation commands only when they are discoverable and likely to work.
- Mark uncertain guidance as a question or omit it.
- Do not include secrets, internal tokens, personal paths, or machine-specific state.
- Do not fight existing tools. If Black, Prettier, Ruff, ESLint, mypy, or similar tools enforce a rule, mention the command rather than restating every formatting detail.

## Suggested Repository-Wide Template

```markdown
# GitHub Copilot Instructions

## Project Context
- Describe the project in one or two bullets based on repository evidence.

## Development Workflow
- List install, build, test, lint, and type-check commands that are present in the repo.

## Coding Conventions
- Capture non-obvious conventions that are visible in existing code.

## Testing
- Explain test layout, naming, fixtures, and expected regression coverage.

## Security And Data Handling
- Capture auth, authorization, secret handling, logging, and privacy rules that are relevant to this repo.

## Pull Requests
- Capture review expectations, generated files, docs updates, and validation evidence.
```

## Sources

- GitHub Docs: repository-wide instructions use `.github/copilot-instructions.md`; path-specific instructions use `.github/instructions/<name>.instructions.md` with `applyTo` frontmatter.
- VS Code Docs: `/init` can generate workspace instructions; `/create-instructions` can generate targeted instruction files; VS Code searches `.github/instructions` recursively and supports `AGENTS.md`.
