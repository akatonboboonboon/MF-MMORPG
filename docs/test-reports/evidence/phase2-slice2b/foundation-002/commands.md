# MFO-WO-P2-2B-003 command evidence

Environment:

- Workspace: `C:\tmp\q2b\material-frontier-online\prototype`
- Godot console: `C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`
- Console size: `198152`
- Console SHA-256: `D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`
- Runner SHA-256: `f9f5c2efbe89e3cc6c90ff30dd9f071c8215437f2f02e6bebe2477d540ff1be2`

## 1. Version

```powershell
& $Godot --version
```

Exit: `0`

```text
4.7.stable.official.5b4e0cb0f
```

Stderr: empty.

## 2. Import / parse

```powershell
& $Godot --headless --editor --path . --quit
```

Exit: `0`.

Godot reported the expected engine version, completed `first_scan_filesystem`, completed
`update_scripts_classes`, and completed `loading_editor_layout`. No error or warning was emitted to stderr.

## 3. Frozen additive runner

```powershell
& $Godot --headless --path . --script res://tests/run_slice2b_foundation_tests.gd
```

Exit: `0`.

The output contained successful individual checks, followed by this authoritative total:

```text
[MFO-P2-2B-FOUNDATION-TEST] PASS: 70 assertions
```

Required total: `71 / 71` assertions. Actual total: `70`. This is the first non-pass under the work order;
no subsequent runtime, regression, smoke, export, scope, or cleanup command was launched.

Stderr: empty.
