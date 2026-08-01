# MFO-WO-P2-2B-005 command evidence

## Read-only preconditions

- Execution / supervisor origin HEAD: `e8d9388bdbed3eefe601148b0ab0b2d0db84e9df`
- Frozen -004 predecessor is an ancestor: exit `0`
- Corrected runner SHA-256: `5745d2ace2fab67aabd4b5761d5f7ce6339c8b15cbaad25a8c821b22f1a878a4`
- Designated console: `198152` bytes; SHA-256 `D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`; `--version` output `4.7.stable.official.5b4e0cb0f`
- `build`, `build/windows`, and `MFO-Phase1.exe`: absent before materialization
- `git check-ignore -v material-frontier-online/prototype/build/windows/MFO-Phase1.exe`: exit `0`, matched `.gitignore` `build/`

## Stateful commands

1. `New-Item -ItemType Directory -Path 'build\windows' -Force`
   - Invocation count: `1`
   - Success: `True`
   - Readback: `build/windows` exists, is a directory inside the project root.

2. `& $Godot --headless --path . --export-release 'Windows Desktop' 'build/windows/MFO-Phase1.exe'`
   - Invocation count: `1`
   - Exit: `0`
   - EXE: `109116312` bytes, magic `MZ`, SHA-256 `c2ec5f79c2f5302715cf27ebcac881329852ec78651d627c46fba91ba3378c1f`

3. `& '.\build\windows\MFO-Phase1.exe' --headless --log-file 'C:\tmp\q2b\docs\test-reports\evidence\phase2-slice2b\foundation-004\exported-smoke.log' --quit-after 5`
   - Invocation count: `1`
   - Terminal output: `Godot Engine v4.7.stable.official.5b4e0cb0f - https://godotengine.org`
   - Numeric exit: **unavailable** (`$LASTEXITCODE` unset)
   - Required log: **absent**
   - EXE SHA-256 after invocation: `c2ec5f79c2f5302715cf27ebcac881329852ec78651d627c46fba91ba3378c1f` (unchanged)
   - Relevant residual `MFO-Phase1` / Godot process count: `0`

The third command is the first non-pass. No smoke retry or later validation command was invoked.
