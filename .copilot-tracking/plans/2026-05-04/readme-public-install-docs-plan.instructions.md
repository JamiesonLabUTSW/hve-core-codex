<!-- markdownlint-disable-file -->
# Implementation Plan: README Public Install Documentation

## User Requests

* Create a branch for the README install update.
* Log a well-specified issue.
* Research the best fix.
* Plan and implement the README update.

## Context

* Branch: `readme-public-install-docs`
* Issue: <https://github.com/JamiesonLabUTSW/hve-core-codex/issues/10>
* Research:
  `.copilot-tracking/research/2026-05-04/readme-public-install-docs-research.md`
* The Codex CLI accepts HTTP(S) Git URLs for `codex plugin marketplace add`.
* The marketplace manifest still names the marketplace
  `hve-core-codex-local`, so the existing upgrade command remains valid.

## Checklist

* [x] Create implementation branch.
* [x] Create GitHub issue with problem statement, desired outcome, scope, and
  acceptance criteria.
* [x] Research Codex marketplace command behavior and current marketplace
  metadata.
* [x] Update the README install section to use the public repository URL.
* [x] Clarify the first-time registration and existing-marketplace refresh
  paths.
* [x] Validate that the stale absolute path no longer appears in the install
  instructions.
* [x] Record changes and review outcome.

## Success Criteria

* `README.md` includes a public install command using
  `https://github.com/JamiesonLabUTSW/hve-core-codex`.
* `README.md` clearly distinguishes first-time marketplace registration from
  refreshing an existing registration.
* The developer-specific absolute path is no longer the primary installation
  instruction.
* Validation confirms the install section has no stale local path references.
