# MFO-WO-P2-2A-009 Runtime Commands

- Stage ID: `p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1`
- Exactly one PREACK invocation and one LIVE invocation were made.
- No performance slot, P95, KBM, A/B/C, or game process was started.

## PREACK

```powershell
& 'C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-009\p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1\bin\MfoQaRunner.exe' --mode 'PREACK' --stage 'C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-009\p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1' --identity 'C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-009\p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1\seal\qualification-manifest.json' --out 'C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-009-Runs\p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1\preack-001' --journal 'C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-009-Runs\p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1\preack-001\evidence.journal.jsonl' --result 'C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-009-Runs\p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1\preack-001\runner-result.json' --manifest-sha 'da49eaf1d24dfce39dba43d6babd649c77809450c5257696405cb15393acdcbf' --preparation-audit-sha 'f5e21f872ff492d743d81fa36ff161a35899a8a7b8d4d2ec24583e7402bebf25' --receipt-sha 'bcbafcad629d0045184bfe5bafae1637683e93bd087264d14e7cc9721b17f050' --stage-id 'p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1'
```

Native exit: `0`. PREACK SHA-256: `c290434aa7b9078a45f0a71590712643bb01e813ded3d5f262624388b46eb8b2`.
Evaluation SHA-256: `1a3db31494edd60c28bc0a95dc0e9ac468a3e33ad899cc1ece45ef3bd9b97fe0`. Tick: `10785343`.

## Exact user activation

The user supplied the exact plain `START_ACK` in this QA thread before file creation. `30 QA` persisted it with
`FileMode.CreateNew`, `FileOptions.WriteThrough`, `Flush(true)`, close, byte readback, and SHA-256.

- Creation UTC: `2026-07-16T08:37:59.8550994Z`
- Bytes: `519`
- SHA-256: `e2d6a02451ef3b0e5588e56e4d4e4fb86c0e39c4587b98b48054703e421cc721`
- BOM / CR / LF: absent / `0` / `0`

## LIVE

```powershell
& 'C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-009\p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1\bin\MfoQaRunner.exe' --mode 'LIVE' --stage 'C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-009\p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1' --identity 'C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-009\p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1\seal\qualification-manifest.json' --out 'C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-009-Runs\p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1\live-001' --journal 'C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-009-Runs\p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1\live-001\evidence.journal.jsonl' --result 'C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-009-Runs\p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1\live-001\runner-result.json' --activation 'C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-009-Runs\p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1\live-001\activation-token.txt' --manifest-sha 'da49eaf1d24dfce39dba43d6babd649c77809450c5257696405cb15393acdcbf' --preack-evaluation 'C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-009-Runs\p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1\preack-001\launcher\preack-evaluation.json' --preack-evaluation-sha '1a3db31494edd60c28bc0a95dc0e9ac468a3e33ad899cc1ece45ef3bd9b97fe0' --preack-record 'C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-009-Runs\p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1\preack-001\launcher\preack-record.json' --preack-sha 'c290434aa7b9078a45f0a71590712643bb01e813ded3d5f262624388b46eb8b2' --preack-tick '10785343' --preparation-audit-sha 'f5e21f872ff492d743d81fa36ff161a35899a8a7b8d4d2ec24583e7402bebf25' --receipt-sha 'bcbafcad629d0045184bfe5bafae1637683e93bd087264d14e7cc9721b17f050' --stage-id 'p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1'
```

Native exit: `0`. Runner, launcher, and controller each returned `0 / Pass`.

## Safety HOLD note

`00` sent a safety HOLD while LIVE was running because its asynchronous channel had not yet received the user's
acknowledgement. `30 QA` requested an interrupt immediately. The backend returned `process interrupt is not
supported`; the request did not act on the process. The next poll returned natural completion with exit `0`.
`00` then independently confirmed the exact user acknowledgement preceded activation creation and is valid.
No retry, regeneration, repair, deletion, or Git/repository I/O during the qualification window occurred.

## Read-only closure

- Journal: `145 / 145` contiguous records and independently recomputed hashes.
- Samples: `61 / 61`, exact `n=0..60`, complete fields.
- Host: OneDrive `0`, AC online, Best performance, stable input, forbidden runtime `0` for `61 / 61`.
- Per-sample slot: `61 / 61` equal `0`.
- Cleanup sequence: journal `12 -> 13 -> 14 -> 15`.
- Final MfoQa process count: `0`.

See `runtime-closure-audit.json` for the machine-readable closure summary.
