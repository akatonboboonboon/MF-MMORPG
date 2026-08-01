# MFO-WO-P2-2B-006 command and identity record

- Supervisor HEAD / origin: `98826e6ce952ee2359dc8dd7f32562f5db0d56ac`
- Frozen predecessor ancestor check: exit `0`
- Corrected runner SHA-256: `5745d2ace2fab67aabd4b5761d5f7ce6339c8b15cbaad25a8c821b22f1a878a4`
- Frozen EXE before and after: `109116312` bytes; `MZ`; SHA-256 `c2ec5f79c2f5302715cf27ebcac881329852ec78651d627c46fba91ba3378c1f`
- Evidence root and `exported-smoke.log`: absent before launch
- Launcher source: `run-exported-smoke.ps1`, `2350` bytes, SHA-256 `0d1686572392ed83afe435bf686099be4d60b1882c5ae1b374d083bb3e364bf3`

The launcher invoked the frozen EXE exactly once with:

```text
--headless --log-file C:\tmp\q2b\docs\test-reports\evidence\phase2-slice2b\foundation-005\exported-smoke.log --quit-after 5
```

The durable result record reports `numeric_exit_code: 0` and `timeout: false`. The fresh log contains
`DefinitionsValidated` and `violation_count: 0`; residual relevant process count after completion was `0`.
