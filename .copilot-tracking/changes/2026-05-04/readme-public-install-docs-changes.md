<!-- markdownlint-disable-file -->
# Changes: README Public Install Documentation

## Related Artifacts

* Issue: <https://github.com/JamiesonLabUTSW/hve-core-codex/issues/10>
* Plan:
  `.copilot-tracking/plans/2026-05-04/readme-public-install-docs-plan.instructions.md`
* Research:
  `.copilot-tracking/research/2026-05-04/readme-public-install-docs-research.md`

## Summary

Updated the README install instructions to use the public GitHub repository URL
for first-time Codex plugin marketplace registration while preserving the
existing marketplace upgrade command.

## Modified

* `README.md`
  * Renamed `Install Locally` to `Install`.
  * Replaced the workstation-specific marketplace source path with
    `https://github.com/JamiesonLabUTSW/hve-core-codex`.
  * Added concise guidance for local contributors testing unpublished checkout
    changes.

## Validation

* Reviewed the patched README install section.
* Confirmed the old absolute path no longer appears in `README.md`.
* Ran `./scripts/verify-port.sh`.
  * Result: passed.
  * Output included `runtime-surface-audit: ok commands=71 agents=54 warnings=0`
    and `verify-port: ok`.
