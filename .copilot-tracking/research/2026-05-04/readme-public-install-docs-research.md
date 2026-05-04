<!-- markdownlint-disable-file -->
# README Public Install Documentation Research

Date: 2026-05-04

## Task

Update the README install instructions because the HVE Core Codex port is
publicly available at:

```text
https://github.com/JamiesonLabUTSW/hve-core-codex
```

## User Requests

* Create a branch for the work.
* Log a well-specified issue.
* Research the best fix.
* Plan and implement the README update.

## Evidence

* Current branch created for the work: `readme-public-install-docs`.
* GitHub issue created: <https://github.com/JamiesonLabUTSW/hve-core-codex/issues/10>.
* `README.md` currently tells users to register a workstation-specific path:

  ```bash
  codex plugin marketplace add /Users/michael/sideprojects/hve-core-codex
  ```

* `codex plugin marketplace add --help` says the source argument supports
  owner/repo refs, HTTP(S) Git URLs, SSH URLs, or local marketplace root
  directories.
* `.agents/plugins/marketplace.json` names the marketplace
  `hve-core-codex-local`, so the existing refresh command remains the correct
  named upgrade command for an already registered marketplace.

## Alternatives Considered

### Replace the local path with the public GitHub URL

Selected. This directly fixes the stale instruction while matching Codex CLI
support for HTTP(S) Git URLs.

### Use `JamiesonLabUTSW/hve-core-codex`

Valid according to the CLI help, but the user provided the full public URL.
Using the full URL is more explicit for public readers and avoids ambiguity
about the hosting provider.

### Rename the marketplace from `hve-core-codex-local`

Rejected for this task. That would change marketplace identity and could break
the documented upgrade path for existing users. The requested stale content is
the install section, not the marketplace manifest contract.

## Selected Fix

Update the README `Install Locally` section to:

* use `codex plugin marketplace add
  https://github.com/JamiesonLabUTSW/hve-core-codex` for first-time setup;
* keep `codex plugin marketplace upgrade hve-core-codex-local` for refreshes;
* add a short note that local contributors can pass a local checkout path when
  testing unpublished changes.

## Validation Plan

* Review the patched README install section.
* Search for the stale absolute path.
* Run the repository verification script if available and practical.
