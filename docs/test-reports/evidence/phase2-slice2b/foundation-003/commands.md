# MFO-WO-P2-2B-004 command evidence

All Godot invocations used only:

`C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`

Engine identity: `198152` bytes, SHA-256
`D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`, version
`4.7.stable.official.5b4e0cb0f` (exit `0`).

| Command | Exit | Terminal result |
| --- | ---: | --- |
| `& $Godot --version` | 0 | `4.7.stable.official.5b4e0cb0f` |
| `& $Godot --headless --editor --path . --quit` | 0 | filesystem scan and editor layout completed |
| `& $Godot --headless --path . --script res://tests/run_slice2b_foundation_tests.gd` | 0 | `PASS: 71 assertions` |
| `& $Godot --headless --path . --script res://tests/run_phase1_tests.gd` | 0 | all Phase 1 tests; 36 assertions |
| `& $Godot --headless --path . --script res://tests/run_slice2a_tests.gd` | 0 | `PASS: 120 assertions` |
| `& $Godot --headless --path . --script res://tests/run_slice2a_correction_tests.gd` | 0 | `PASS: 39 assertions` |
| `& $Godot --headless --path . --quit-after 120` | 0 | definitions validated; RuntimeHardLimit report emitted |
| `& $Godot --headless --path . --export-release 'Windows Desktop' build/windows/MFO-Phase1.exe` | 1 | `テンプレートの準備: 指定されたエクスポートパスが存在しません。`; `Project export for preset "Windows Desktop" failed.` |

The export failure was the first non-pass. Stderr did not contain a separate stream record in the captured terminal
result. No command after that export invocation was launched.
