# MFO-WO-P2-2B-002 command evidence

Working directory for Godot commands: `C:\tmp\q2b\material-frontier-online\prototype`

| Command | Observed result |
| --- | --- |
| `godot --version` | PowerShell command resolution failed: `godot` was not recognized. |
| `godot --headless --editor --path . --quit` | Not invoked because `godot` could not be resolved. |
| `godot --headless --path . --script res://tests/run_slice2b_foundation_tests.gd` | Not invoked because `godot` could not be resolved. |

Read-only discovery checked command resolution plus representative Program Files, user, cache, and tools locations for `godot*.exe`; no executable was found. This is a host validation-infrastructure blocker. No fallback executable, old export, LFS pointer, or performance harness was used.
