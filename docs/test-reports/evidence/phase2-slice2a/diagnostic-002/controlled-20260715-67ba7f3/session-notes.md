# MFO-WO-P2-2A-004 Session Notes

## Activation

User activation text:

```text
MFO-WO-P2-2A-004 QUIET WINDOW READY
OneDrive client：手動でpause／exit済み
AC電源：接続済み
重いアプリ、download、export：停止済み
性能測定終了まで最大10分、入力操作や他のCodex task操作をしません。
性能測定後、続けてKBM操作確認を実施できます。
```

- Local receipt／acknowledgement: `2026-07-15T00:01:08.0043338+09:00`
- Absolute controller deadline: `2026-07-15T00:11:08.0043338+09:00`
- OneDrive was not killed、reconfigured、resumed、or quota-cleaned by QA.

## Controller invocations

Setup attempt 1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-004\controlled-20260715-000108-67ba7f3\run_controlled_rerun.ps1" `
  -RepoRoot "C:\Users\osato\OneDrive\ドキュメント\MF" `
  -SessionRoot "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-004\controlled-20260715-000108-67ba7f3" `
  -AcknowledgedLocal "2026-07-15T00:01:08.0043338+09:00"
```

- Controller SHA-256: `4b4c71a076282bfa16eed3754edf6e2bbd7a2860ef041689032d21b27726dac4`
- Exit: `1`
- Failure: `Get-CimInstance Win32_OperatingSystem` returned `Access denied` before preflight.
- Performance slot started: no.

Controlled attempt 2:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-004\controlled-20260715-000108-67ba7f3-attempt2\run_controlled_rerun.ps1" `
  -RepoRoot "C:\Users\osato\OneDrive\ドキュメント\MF" `
  -SessionRoot "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-004\controlled-20260715-000108-67ba7f3-attempt2" `
  -AcknowledgedLocal "2026-07-15T00:01:08.0043338+09:00"
```

- Controller SHA-256: `fae29f8da114cbdbe3611e8e015485e1eb7ef5072f68ef8cf26d7203754a96e5`
- Exit: `2`
- Preflight: Fail.
- Performance slots started: none.

Each KBM attempt used this exact executable invocation shape:

```powershell
"<TEMP>\executables\MFO-C.exe" --log-file "<attempt>\godot.log"
```

The observer used designated W／A／S／D／Space key-state reads、cursor delta、foreground PID、last-input tick、and
game log only. It did not use `SendInput` or capture unrelated window titles／contents.

## User confirmation

- Attempt 1: interrupted and preserved as partial; user requested a new attempt.
- Attempt 2: foreground loss after W／A／S／D and mouse stimulus; preserved as partial.
- Attempt 3: foreground remained on corrected C for the full `27.973 s` capture; all planned stimuli plus five-second
  idle were observed.
- Intentional input: `意図した入力です`
- Six checklist outcomes／user feel: `いいえ、すべて問題ないです`
- Interpreted checklist result: items 1 through 6 all Pass.

## Copy and privacy handling

- All timed outputs were first written under `%TEMP%`, outside OneDrive.
- `staging-copy-verification.json` records source／destination hashes for copied evidence.
- No `.exe`, export pack, duplicate binary, unrelated window title, screenshot, or private conversation was copied.
- Empty Godot／stderr logs are retained because they are primary outputs, not omitted to make the result look cleaner.
