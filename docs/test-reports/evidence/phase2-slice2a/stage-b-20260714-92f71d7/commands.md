# MFO-WO-P2-2A-001 Stage B command record

Working directory: `C:\Users\osato\OneDrive\ドキュメント\MF`

Godot executable:
`material-frontier-online/.tools/godot-4.7-stable/editor/Godot_v4.7-stable_win64_console.exe`

## Scope and refs

```powershell
git diff --name-status afcd20cd4a02d618a5d7e0e4bc7555a64fa90740 bd01fdf3d048accaa7f5be93afe3be5cfa138201
git diff --check afcd20cd4a02d618a5d7e0e4bc7555a64fa90740 bd01fdf3d048accaa7f5be93afe3be5cfa138201
git rev-parse HEAD
git rev-parse main
git rev-parse origin/main
```

Actual: four permitted implementation files; diff check exit `0`; QA start HEAD `92f71d7`; local／remote main
`afcd20c`.

## Import／parse

```powershell
godot --headless --editor --log-file <evidence>/import-parse-godot.log `
  --path material-frontier-online/prototype --quit
```

Exit `0`. The editor emitted the known non-fatal sandbox-local `user://` ObjectDB snapshot warning; parse completed.

## Fresh Phase 1 regression

```powershell
godot --headless --log-file <evidence>/phase1-regression-godot.log `
  --path material-frontier-online/prototype --script res://tests/run_phase1_tests.gd
```

Exit `0`; `36 / 36 Pass`.

## Fresh Slice 2-A deterministic suite

```powershell
godot --headless --log-file <evidence>/slice2a-tests-godot.log `
  --path material-frontier-online/prototype --script res://tests/run_slice2a_tests.gd
```

Exit `1`; `119 / 120 Pass`, `1 Fail`.

## Main scene smoke

```powershell
godot --headless --log-file <evidence>/main-scene-headless-godot.log `
  --path material-frontier-online/prototype --quit-after 5
```

Exit `0`; RuntimeHardLimit violation count `0`.

## Windows release export

```powershell
godot --headless --log-file <evidence>/release-export-godot.log `
  --path material-frontier-online/prototype --export-release "Windows Desktop"
```

Exit `0`.

## Exported-EXE headless smoke

The GUI-subsystem EXE was started with `System.Diagnostics.ProcessStartInfo`, `UseShellExecute = false`, redirected
stdout／stderr, and `WaitForExit()` using:

```text
MFO-Phase1.exe --headless --log-file <evidence>/release-headless-smoke-godot.log --quit-after 5
```

Exit `0`.

## Performance precheck

```powershell
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SystemInformation]::PowerStatus
Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes'
powercfg /getactivescheme
```

Actual: `PowerLineStatus = Offline`; configured AC overlay is Best performance
`ded574b5-45a0-4f42-8737-46345c09c238`. A 600-sample result was not generated under an invalid power-source
condition, and the Gate 1 measurement was not reused.
