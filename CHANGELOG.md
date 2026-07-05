# Changelog

## Unreleased

- Fixed widening `--file-types` scope on a bidirectional vault deleting the newly-in-scope remote files; they are now downloaded instead (#38, #19, #28).
- Added a safety check so remote files/folders are never deleted while the file still exists locally, preventing spurious deletions from watcher races and freshly-downloaded files (#19, #28).
- Fixed `ob sync --continuous` hanging forever at "Connecting..." by adding a 30-second timeout to the websocket connect, letting the retry/backoff logic recover (#41, #26).
- Fixed `ob sync --continuous` not shutting down on SIGTERM/SIGINT (previously required SIGKILL after a 90s timeout) (#25).
- Fixed `verify() lock` failing on exFAT and other filesystems with coarse timestamp resolution by using a tolerance instead of strict equality (#16, subsumes #9).
- Added a clear error message when run on Node.js older than 22, instead of a cryptic `ReferenceError: crypto is not defined` (#35).
- Added `--included-folders` to `sync-config` for selective folder syncing; mutually exclusive with `--excluded-folders` (#37).
- Added `--json` output mode to `sync-list-local`, `sync-list-remote`, and `sync-status` (#6).
- Added `--rescan <seconds>` to `ob sync` to periodically re-scan the vault in continuous mode, catching changes the filesystem watcher misses such as edits to hard-link targets (#18).
- Added a `Dockerfile` and `docker-compose.yml` for running continuous sync in a container (#2).
- Documented the `btime` native addon's purpose, interface, and platform calls (#7).

## 0.0.12

- Add `publish-site-options` command back, which was accidentally removed in 0.0.9.

## 0.0.11

- Fixed User Agent not properly set in the preflight call, triggering attack detection.

## 0.0.10

- Set User Agent in network calls, and fix JSON parse error when response is not successful.

## 0.0.9

- Fixed NaN passed to setTimeout causing a warning to show in the console.
- Improved sync-setup error messaging for when encryption key validation failed.

## 0.0.8

- Add publish support.

## 0.0.7

- Fixed lock failure on file systems returning floating point modified times.
- Fixed some initialization errors were previously caught and completely ignored, leading to no output on failure.

## 0.0.6

- Fixed default value of file type configuration not properly applied, causing images to not sync.

## 0.0.5

- Added new sync modes "pull-only" (only download, ignore local changes) and "mirror-remote" (only download, revert local changes).
- Print the vault config when starting a sync session.

## 0.0.4

- Fixed version command always gave "1.0.0".
- Fixed config syncing deletes remote config files after downloading them.

## 0.0.3

- Removed keytar in favor of flat file configuration, as it is not available in many headless setups.
- Fix download freeze caused by a race condition in the data receiving pipeline, due to microtask queuing differences between node and web (credits to @marcus-crane).

## 0.0.2

- Updated README.md

## 0.0.1

- Initial release.
