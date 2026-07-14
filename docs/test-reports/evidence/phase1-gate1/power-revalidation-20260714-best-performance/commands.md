# MFO-WO-P1-G1-002 — Raw command record

- Executed: 2026-07-14 (Asia/Tokyo)
- Working directory: repository root
- Package source baseline: `a13505e8fbf82962e049b9101a87593a6692d2c7`
- Repository HEAD during validation: `e95b1442759b8b43a3a62a555af4d0e96384dd81`

## Power mode change

Windows `powrprof.dll`の`PowerGetUserConfiguredACPowerMode`で変更前値を読み、
`PowerSetUserConfiguredACPowerMode`へ次のGUIDを渡した後、同じAPIで再読込した。

```text
target AC GUID: ded574b5-45a0-4f42-8737-46345c09c238
AC before:       961cc777-2547-4f9d-8174-7d86181b8a7a
AC set RC:       0
AC after:        ded574b5-45a0-4f42-8737-46345c09c238
AC get-after RC: 0
DC unchanged:    961cc777-2547-4f9d-8174-7d86181b8a7a
```

## Empty scene

```powershell
$exe = "material-frontier-online/deliverables/phase1/MFO-Phase1-Windows-x86_64/MFO-Phase1.exe"
& $exe -- --phase1-empty --phase1-measure `
  --phase1-report=<evidence>/phase1-empty-best-performance.json `
  --phase1-capture=<evidence>/phase1-empty-best-performance.png
```

Exit code: `0`

Complete output: `phase1-empty-stdout.txt`

## Arena idle

```powershell
$exe = "material-frontier-online/deliverables/phase1/MFO-Phase1-Windows-x86_64/MFO-Phase1.exe"
& $exe -- --phase1-measure `
  --phase1-report=<evidence>/phase1-arena-best-performance.json `
  --phase1-capture=<evidence>/phase1-arena-best-performance.png
```

Exit code: `0`

Complete output: `phase1-arena-stdout.txt`
