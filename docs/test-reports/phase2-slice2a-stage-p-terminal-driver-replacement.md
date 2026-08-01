# MFO-WO-P2-2A-012 — Terminal Stage P Driver Replacement

- Final recommendation: **Blocked / QA infrastructure deferred**
- Tested QA branch / execution receipt HEAD: `codex/phase2-slice2a-performance-acceptance-qa` / `0a62c5d66632edcbc4ee6670ebd5f4c20c8e1dec`
- Work order: `MFO-WO-P2-2A-012`; production issuance remains `MFO-WO-P2-2A-010`.
- Scope: terminal external-driver replacement qualification only. No FORMAL Stage P attempt occurred.

## Frozen -011 lineage and replacement driver

| Item | Result |
| --- | --- |
| Frozen -011 driver | `158448` bytes; SHA-256 `1b90d2eb5029c8bbadabde9523184149b26751922fee6ea79599397400f02c2b` |
| Frozen -011 failure | SHA-256 `38d5e0a8c761b0fd55e1aef752e213e32aed16538174305d7d5e2ff1af31547b` |
| Frozen -011 manifest | `21 / 21` payloads; SHA-256 `559ca9e1701f241a6a5d4427faed2dbef205908d8b23191d331a23da153e2c29` |
| Replacement driver | `C:\Users\osato\.codex\visualizations\2026\07\14\019f5e09-e999-7963-97fe-4d67d1e8a419\p2a012_terminal_driver_d0090b3_c1.ps1` |
| Replacement identity | `165599` bytes; SHA-256 `b1e82b728bdaaaec8d4fe922187a140fd742fb7b47841fac9e97470bf8e578c9`; ReadOnly |
| Parser / byte boundary | PowerShell parser error `0`; ASCII-only; BOM-free |
| Offline closure | diff SHA-256 `c53857fb0abcdfca0050c8613d21a261e1360ef925b74a75ed74747640e21205`; manifest SHA-256 `e48a261e1ef737e56880cbd5b963297a3129df29abdbb99631d74a3d4007d90e`; ReadOnly |

The replacement changes the former raw-prefix boundary check to use the CONTRACT `PipelineAst.EndOffset` and compile-consumer `AssignmentStatementAst.StartOffset`. Offline static closure recorded one CONTRACT command, one containing pipeline, one consumer assignment, a whitespace-only production gap of `9` bytes, raw-prefix guard count `0`, and a no-process `| Out-Null` fixture with a whitespace-only gap of `1` byte. Candidate-012 remained immutable and candidate-013 remained absent.

## Final QUALIFY — exact one invocation

```text
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "C:\Users\osato\.codex\visualizations\2026\07\14\019f5e09-e999-7963-97fe-4d67d1e8a419\p2a012_terminal_driver_d0090b3_c1.ps1" -Mode QUALIFY
```

- Invocation count: `1`
- Observed process exit: `1`
- Failure payload outcome: `Blocked`
- Machine failure: `R5K_QUALIFICATION_BLOCKED: R5K_FAIL_R5KC_PREQUALIFICATION_MANIFEST`
- Failure payload SHA-256: `0ee87c7a1971939d2a0fd0b7203e9aa7c1354b4a5c2e49676c722e5817727763`
- Qualification root: ReadOnly; manifest `9 / 9`, SHA-256 `5f40a68e33f8737996eb9deb3ec9e39552e6d36309930b91cbba8dc35be05026`.

The failure occurred before `ast-statement-span.json` could be emitted. It therefore does not invalidate the offline AST boundary closure and does not constitute a candidate-012, StagePreparer, production harness, game, or performance result. No repair, retry, alternate replacement, or second QUALIFY was performed.

## Downstream state

- FORMAL, compiler, PowerShell parse-only, tool build, StagePreparer, RepositoryState, CONTRACT, modes, and SEAL: `0`.
- FORMAL root, tool-build root, preparation/Stage root, and external run root: absent.
- Candidate-012 mutation / candidate-013 creation: `0 / 0`.
- PREACK, performance attempt/slot, real A/B/C, P95, KBM, and game: Not run / prohibited; all counts `0`.
- Residual `csc`, `MfoQa`, `StagePreparer`, `Godot`, and `Material*` processes: `0`.
- Local/origin were exact and the repository was clean at execution closure.

The frozen evidence index is available at [diagnostic-005/stage-p-terminal-driver-012](evidence/phase2-slice2a/diagnostic-005/stage-p-terminal-driver-012/README.md). This result does not accept performance, unlock Gate 2, or authorize Slice 2-B.