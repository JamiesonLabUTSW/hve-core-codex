<!-- markdownlint-disable-file -->
# Planning Log: README Public Install Documentation

## Implementation Paths Considered

Selected:

* README-only documentation update using the public GitHub URL for first-time
  registration and the existing marketplace name for upgrades.

Rejected:

* Renaming the marketplace manifest from `hve-core-codex-local`, because this
  task is scoped to stale install instructions and renaming would change the
  upgrade contract for existing registrations.

## Discrepancy Log

None at planning time.

## Validation Log

* `rg -n "/Users/michael/sideprojects/hve-core-codex|codex plugin marketplace add|codex plugin marketplace upgrade" README.md`
  returned only the updated public install command and the existing upgrade
  command.
* `./scripts/verify-port.sh` passed with `runtime-surface-audit: ok` and
  `verify-port: ok`.

## Suggested Follow-On Work

* Consider a separate marketplace identity cleanup if public naming should move
  away from `hve-core-codex-local`.
