# btime native addon

`btime` is a tiny native Node.js addon that sets a file's **creation / birth time**
(the "born" timestamp), which cannot be changed through the standard Node.js `fs`
API. Obsidian Sync stores each note's original creation time, and this addon lets
the headless client restore that timestamp when it writes a file to disk, so a
synced vault keeps the same creation dates it has on other devices.

## Why it exists

Node.js exposes `fs.utimes()` for the access and modification times, but there is
no cross-platform way to set the *creation* time. That has to go through
platform-specific system calls:

- **macOS**: `setattrlist()` with `ATTR_CMN_CRTIME` (equivalently
  `FileManager.setAttributes(_:ofItemAtPath:)` at the Foundation layer).
- **Windows**: [`SetFileTime`](https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-setfiletime),
  writing the `ftCreationTime` field.
- **Linux**: there is no supported way to set a file's birth time (the kernel
  exposes `statx()` `stx_btime` for *reading* only), so no addon is shipped and
  the client simply skips restoring creation times on Linux.

## Interface

The compiled addon exports a single function:

```js
const { btime } = require('./btime.node');
// path: a NUL-terminated UTF-8 Buffer of the absolute file path
// ctimeMs: creation time in milliseconds since the Unix epoch
btime(pathBuffer, ctimeMs);
```

In `cli.js` this is wrapped so callers pass a normal string path; the wrapper
allocates the NUL-terminated buffer. If the addon fails to load (unsupported
platform/arch, or a missing prebuilt binary), the client logs a warning and
continues without preserving creation times.

## Prebuilt binaries

This directory ships prebuilt `.node` binaries, one per supported
platform/arch, loaded at runtime from
`btime/<platform>-<arch>/btime.node` (e.g. `btime/darwin-arm64/btime.node`):

| Directory        | Platform / architecture |
|------------------|-------------------------|
| `darwin-arm64`   | macOS, Apple Silicon    |
| `darwin-x64`     | macOS, Intel            |
| `win32-x64`      | Windows, x64            |
| `win32-arm64`    | Windows, ARM64          |
| `win32-ia32`     | Windows, 32-bit x86     |

## Source

See [issue #7](https://github.com/obsidianmd/obsidian-headless/issues/7). The
addon is a thin N-API wrapper around the platform calls listed above. If you are
building it yourself, compile the corresponding platform source into a Node
N-API addon and drop the resulting `btime.node` into the matching
`btime/<platform>-<arch>/` directory.
