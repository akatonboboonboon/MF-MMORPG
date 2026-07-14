# Slice 2-A QA command record

All commands were run from `C:\Users\osato\OneDrive\ドキュメント\MF` on 2026-07-14.

## Static scope

```powershell
git diff --name-status afcd20cd4a02d618a5d7e0e4bc7555a64fa90740 bd01fdf3d048accaa7f5be93afe3be5cfa138201
git diff --check afcd20cd4a02d618a5d7e0e4bc7555a64fa90740 bd01fdf3d048accaa7f5be93afe3be5cfa138201
git rev-parse HEAD
git rev-parse origin/codex/phase2-slice2a-gameplay
git rev-parse main
git rev-parse origin/main
```

Result: four permitted gameplay files only; `git diff --check` exit `0`; handoff branch local／remote
`92f71d7c3e55108a2faecaa6fbf1e1055b0d0b9f`; local／remote `main`
`afcd20cd4a02d618a5d7e0e4bc7555a64fa90740`.

## Import and parse

```powershell
& material-frontier-online/.tools/godot-4.7-stable/editor/Godot_v4.7-stable_win64_console.exe `
  --headless --editor `
  --log-file docs/test-reports/evidence/phase2-slice2a/validation-20260714-bd01fdf/final-import-parse-godot.log `
  --path material-frontier-online/prototype --quit
```

Exit: `0`.

## Fresh Phase 1 regression

```powershell
& material-frontier-online/.tools/godot-4.7-stable/editor/Godot_v4.7-stable_win64_console.exe `
  --headless `
  --log-file docs/test-reports/evidence/phase2-slice2a/validation-20260714-bd01fdf/phase1-regression-final-godot.log `
  --path material-frontier-online/prototype `
  --script res://tests/run_phase1_tests.gd
```

Exit: `0`; fresh result: `36 / 36 Pass`.

## Slice 2-A deterministic suite

```powershell
& material-frontier-online/.tools/godot-4.7-stable/editor/Godot_v4.7-stable_win64_console.exe `
  --headless `
  --log-file docs/test-reports/evidence/phase2-slice2a/validation-20260714-bd01fdf/slice2a-tests-final-godot.log `
  --path material-frontier-online/prototype `
  --script res://tests/run_slice2a_tests.gd
```

Exit: `1`; final result: `1 / 111 assertions failed` (`110 Pass`, `1 Fail`). The failing assertion is the
approved nonzero-movement priority at the deadzone edge.

Historical execution inside this same QA session is preserved:

- initial suite: exit `1`, two QA-harness expectation／frame-edge errors;
- corrected suite before independent boundary review: exit `0`, `77 / 77 Pass`;
- expanded boundary run: exit `1`, `1 / 81` failed;
- final strengthened collision／bounds／8-direction run: exit `1`, `1 / 111` failed.

The initial two failures were corrected only in the QA-owned test: held-input sampling advances frames, and cooldown
rejection no longer conflates approved ordinary locomotion with buffered evade. No gameplay value or product file was
changed, and the failed raw evidence was not overwritten.

## Main-scene headless smoke

```powershell
& material-frontier-online/.tools/godot-4.7-stable/editor/Godot_v4.7-stable_win64_console.exe `
  --headless `
  --log-file docs/test-reports/evidence/phase2-slice2a/validation-20260714-bd01fdf/main-scene-headless-godot.log `
  --path material-frontier-online/prototype --quit-after 5
```

Exit: `0`; RuntimeHardLimit violations: `0`.

## Release export

```powershell
& material-frontier-online/.tools/godot-4.7-stable/editor/Godot_v4.7-stable_win64_console.exe `
  --headless `
  --log-file docs/test-reports/evidence/phase2-slice2a/validation-20260714-bd01fdf/release-export-godot.log `
  --path material-frontier-online/prototype `
  --export-release "Windows Desktop"
```

Exit: `0`.

## Exported-EXE headless smoke

The GUI-subsystem executable does not return `$LASTEXITCODE` through a direct PowerShell invocation. The final run used
`System.Diagnostics.ProcessStartInfo` with `UseShellExecute = false`, redirected stdout／stderr, waited for process exit,
and passed these arguments:

```text
--headless
--log-file <evidence>/release-headless-smoke-attempt4-godot.log
--quit-after 5
```

Final exit: `0`. Earlier non-authoritative launch-attempt files remain in the evidence directory and are not cited as
the successful result.

## Performance eligibility precheck

```powershell
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SystemInformation]::PowerStatus
Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes'
powercfg /getactivescheme
```

Actual: `PowerLineStatus = Offline`; configured AC overlay remains Best performance
`ded574b5-45a0-4f42-8737-46345c09c238`. The 600-sample run was not started because an AC configuration value is not
evidence that the machine is currently operating on AC.
