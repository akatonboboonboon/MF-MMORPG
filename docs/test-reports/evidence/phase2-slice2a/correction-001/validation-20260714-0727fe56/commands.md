# MFO-WO-P2-2A-002 — Fresh command record

- Executed: 2026-07-14 (Asia/Tokyo)
- Working directory: `C:\Users\osato\OneDrive\ドキュメント\MF`
- QA start HEAD: `0727fe562c20fcb781eb9b1d63b260eb9a94f333`
- Correction implementation: `5261a73707daca03cb160e03a12247886d3f5cce`
- Godot: `material-frontier-online/.tools/godot-4.7-stable/editor/Godot_v4.7-stable_win64_console.exe`
- Project: `material-frontier-online/prototype`
- Evidence directory: this directory

```powershell
$root = 'C:\Users\osato\OneDrive\ドキュメント\MF'
$godot = "$root\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe"
$project = "$root\material-frontier-online\prototype"
$evidence = "$root\docs\test-reports\evidence\phase2-slice2a\correction-001\validation-20260714-0727fe56"
$exe = "$root\material-frontier-online\prototype\build\windows\MFO-Phase1.exe"
```

## Scope and source integrity

```powershell
git diff --check `
  295549373fbb3b39deb6079172783ce62c7da532..0727fe562c20fcb781eb9b1d63b260eb9a94f333
git diff --name-status `
  295549373fbb3b39deb6079172783ce62c7da532..0727fe562c20fcb781eb9b1d63b260eb9a94f333
git diff --exit-code daf616253d39d48795b509d204f2ebe30177fc03 -- `
  material-frontier-online/prototype/tests/run_slice2a_tests.gd `
  material-frontier-online/prototype/tests/run_slice2a_tests.gd.uid
git diff --exit-code 0727fe562c20fcb781eb9b1d63b260eb9a94f333 -- `
  docs/test-reports/phase2-slice2a-validation.md `
  docs/test-reports/evidence/phase2-slice2a/stage-b-20260714-92f71d7
Get-FileHash -Algorithm SHA256 `
  material-frontier-online/prototype/tests/run_slice2a_tests.gd
```

Results: all three diff／check commands exit `0`; the correction changed four authorized paths; the inherited test
SHA-256 was `03ecfbd34bfb98333d9bdeff5c6ef90cb477090101ea6e4435511509c1e6e91a`. Raw outputs are
`scope-correction-name-status.txt`, `scope-diff-check.txt`, `scope-qa-working-status.txt`, and
`unchanged-test-sha256.txt`.

## Deterministic suites

The inherited suite was run before the additive correction test was created.

```powershell
& $godot --headless --log-file $evidence/phase1-regression-godot.log `
  --path $project --script res://tests/run_phase1_tests.gd
```

Result: `36 / 36 Pass`, exit `0`.

```powershell
& $godot --headless --log-file $evidence/slice2a-unchanged-godot.log `
  --path $project --script res://tests/run_slice2a_tests.gd
```

Result: `120 / 120 Pass`, exit `0`. Before and after SHA-256:
`03ecfbd34bfb98333d9bdeff5c6ef90cb477090101ea6e4435511509c1e6e91a`.

```powershell
& $godot --headless --log-file $evidence/slice2a-correction-additive-godot.log `
  --path $project --script res://tests/run_slice2a_correction_tests.gd
```

Result: `39 / 39 Pass`, exit `0`.

## Import, smoke, and export

```powershell
& $godot --headless --editor --log-file $evidence/import-parse-godot.log `
  --path $project --quit
```

Result: exit `0`. The editor emitted `Could not create ObjectDB Snapshots directory: user://`; file scan and parse
completed, and the warning is separated from gameplay results.

```powershell
& $godot --headless --log-file $evidence/main-headless-smoke-godot.log `
  --path $project --quit-after 5
```

Result: exit `0`, definition validation OK, RuntimeHardLimit violation count `0`.

```powershell
& $godot --headless --log-file $evidence/windows-release-export-godot.log `
  --path $project --export-release "Windows Desktop"
```

Result: exit `0`. Exported EXE SHA-256:
`28543cb1e45f1e4dd380654200e9336b9e95d8a6e699b4cc5ce0bae26ababb39`.

```powershell
& $exe --headless `
  --log-file "$evidence\exported-exe-headless-smoke-godot.log" `
  --quit-after 5
```

Result: exit `0`, definition validation OK, RuntimeHardLimit violation count `0`.

## Arena-idle performance

Before execution, `PowerLineStatus = Online` and AC user power mode was read through
`PowerGetUserConfiguredACPowerMode` as Best performance / `ded574b5-45a0-4f42-8737-46345c09c238`.

```powershell
& $exe -- --phase1-measure `
  ("--phase1-report=" + $evidence/arena-idle-performance.json) `
  ("--phase1-capture=" + $evidence/arena-idle-capture.png)
```

Result: exit `0`; warmup `120`, samples `600`; P95 `33.4643333333333 ms` — Fail against `<= 16.67 ms`.

One ProcessStartInfo confirmation attempt was interrupted after it did not finish normally. The owned process was
stopped, returned exit `-1`, produced no JSON or PNG, and is retained as `arena-idle-performance-confirmation-*` raw
evidence. It is `Invalid / Not used`.

```powershell
& $exe -- --phase1-measure `
  ("--phase1-report=" + $evidence/arena-idle-performance-confirmation-2.json) `
  ("--phase1-capture=" + $evidence/arena-idle-capture-confirmation-2.png)
```

Result: exit `0`; warmup `120`, samples `600`; P95 `20.0 ms` — confirmation Fail against `<= 16.67 ms`.
Both valid runs retained AC Online / Best performance in their post-check evidence.

## Corrected-release KBM attempt

The same `$exe` was launched normally through Windows app control. The initial HUD showed player position
`(620.0, 540.0)`. During a batched `D` input attempt, external user input was detected; the subsequent fresh window
observation failed with `foreground window did not report a process id`, so QA stopped further input. The copied raw
Godot log shows X-only movement through `(1310.666, 540.0)`, but the full checklist was not completed and the session
is not accepted as a KBM Pass. See `manual-kbm-interrupted.md` and `kbm-interrupted-godot.log`.
