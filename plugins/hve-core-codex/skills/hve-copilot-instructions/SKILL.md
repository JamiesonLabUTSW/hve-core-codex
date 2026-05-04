---
name: hve-copilot-instructions
description: Inspect a repository and draft or update GitHub Copilot custom instruction files, including .github/copilot-instructions.md and .github/instructions/*.instructions.md, with optional AGENTS.md alignment. Use when the user asks for Copilot /init-style repository instruction generation, .github/instructions creation, instruction file migration, AGENTS.md comparison, or AI coding guidance setup.
---

# HVE Copilot Instructions

Use this skill to create or update GitHub Copilot repository instruction files from evidence in the current repository.

Read [references/copilot-instructions-workflow.md](references/copilot-instructions-workflow.md) before drafting files.

## Workflow

1. Inspect existing AI guidance: `AGENTS.md`, `.github/copilot-instructions.md`, `.github/instructions/**/*.instructions.md`, `CLAUDE.md`, `GEMINI.md`, `.cursorrules`, and any HVE or project instruction files.
2. Inspect project evidence: README files, package/build/test config, lint and formatter config, CI workflows, language manifests, docs, tests, and security or contribution guidance.
3. Separate repo-wide rules from scoped rules. Put stable global guidance in `.github/copilot-instructions.md`; put language, framework, test, security, or module-specific guidance in `.github/instructions/<topic>.instructions.md`.
4. Prefer concise, non-obvious rules derived from repository evidence. Do not duplicate rules already enforced by formatters, linters, type checkers, or CI unless the rationale matters.
5. Present a proposed file plan before writing unless the user explicitly asked to create or update files immediately.
6. When writing `.instructions.md` files, include valid YAML frontmatter with `applyTo`. Use comma-separated glob patterns for multiple scopes.
7. Keep `AGENTS.md` and Copilot instructions consistent when both exist. Do not copy all content between them; summarize shared operating rules and keep tool-specific details in the tool-specific file.
8. After edits, verify that all created files are under `.github/`, end targeted files with `.instructions.md`, and include the expected frontmatter.

## Output

When only drafting, provide a file-by-file proposal with the intended path, purpose, `applyTo` pattern, and concise content preview.

When writing files, summarize:

- Files created or updated.
- Evidence used from the repository.
- Any conventions intentionally left out because they were speculative or already enforced by tooling.
