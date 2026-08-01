# MFO-WO-P2-2A-011 — Consolidated Stage P Recovery

- Final recommendation: **Blocked / final QUALIFY non-Pass**
- Scope: external recovery-driver qualification only; Stage P FORMAL was not authorized to start after the qualification failure.
- QA branch / tested HEAD: `codex/phase2-slice2a-performance-acceptance-qa` / `806a83e71ded299efdb65d31bf7e94e3a3155405`
- Local / origin / worktree: exact / exact / clean at closure.
- Supervisor order: `MFO-WO-P2-2A-011`; internal production issuance remains `MFO-WO-P2-2A-010`.

## Candidate and offline closure

Candidate 1 was the sole candidate selected for final qualification. Candidates 2 and 3 were not created.

| Item | Result |
| --- | --- |
| Driver path | `C:\Users\osato\.codex\visualizations\2026\07\14\019f5e09-e999-7963-97fe-4d67d1e8a419\p2a011_consolidated_driver_ae98a36_c1.ps1` |
| Driver size / SHA-256 | `158448` bytes / `1b90d2eb5029c8bbadabde9523184149b26751922fee6ea79599397400f02c2b` |
| Driver state | ReadOnly; ASCII-only; BOM-free; PowerShell parser error count `0` |
| Offline closure diff SHA-256 | `15daee92b17b57feb1af409773008ed21a0199e004020b7f21c324da50bb7967` |
| CP-ORDER-001 / CP-ABC-001 offline closure | Pass / Pass |
| Candidate-012 / candidate-013 | Candidate-012 remained immutable; candidate mutation count `0`; candidate-013 absent |

The selected driver's offline closure recorded the intended producer-consumer ordering and three independent A/B/C identity invocations. No compiler, StagePreparer, generated output, real A/B/C executable, Godot, or game process was launched during final qualification.

## Final QUALIFY — exact one invocation

Command:

```text
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "C:\Users\osato\.codex\visualizations\2026\07\14\019f5e09-e999-7963-97fe-4d67d1e8a419\p2a011_consolidated_driver_ae98a36_c1.ps1" -Mode QUALIFY
```

- Invocation count: `1`
- Numeric exit: `31`
- Final machine message: `R5K_QUALIFICATION_BLOCKED: R5K_FAIL_CP_ORDER_UNCLASSIFIED_OPERATION`
- Qualification outcome record: `Blocked`
- Failure payload SHA-256: `38d5e0a8c761b0fd55e1aef752e213e32aed16538174305d7d5e2ff1af31547b`
- Stdout / stderr durable payloads: `0` bytes / `0` bytes; each SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

The final static order record itself reports the required lifecycle marker order as Pass. The next exact static condition rejects a non-whitespace segment between the CONTRACT invocation marker and the compile-audit consumer marker, producing the failure above. This report records that fact only; it does not change the driver, harness, acceptance criteria, or attribution.

## Frozen evidence and counters

- Qualification root: `C:\Users\osato\.codex\visualizations\2026\07\14\019f5e09-e999-7963-97fe-4d67d1e8a419\p2a011-driver-qualification-806a83e-c1`
- Root state: ReadOnly; `21 / 21` manifest payloads match. Manifest SHA-256: `559ca9e1701f241a6a5d4427faed2dbef205908d8b23191d331a23da153e2c29`.
- Qualification begin SHA-256: `c31de14a66a9d781aad8a68b39af6893f11badd4e010a580c98750a4687064c5`
- Qualification receipt SHA-256: `a139caa37e8a2dd681064c4280288a7dc3fc0e0fc9a4f73a1fa5466c41813448`
- FORMAL invocations / compiler / PowerShell parse / tool build / StagePreparer / lifecycle modes: `0 / 0 / 0 / 0 / 0 / 0`
- Stage root, formal root, tool-build root, and external run root: absent.
- PREACK, performance attempt, performance slot launch, real A/B/C launch, P95, KBM, and game: Not run / prohibited; all launch counts `0`.
- Residual `csc`, `MfoQa`, `StagePreparer`, `Godot`, and `Material*` processes: `0`.

Raw evidence is frozen outside the repository. Its identity index is preserved in [stage-p-recovery-011 evidence](evidence/phase2-slice2a/diagnostic-004/stage-p-recovery-011/README.md).

## Active-time ledger

- Read-only census and candidate offline closure: completed before final QUALIFY.
- Final QUALIFY: one invocation only; no retry, repair, alternate candidate, or FORMAL attempt followed.
- This non-Pass result does not accept performance, unlock Gate 2, or authorize Slice 2-B.