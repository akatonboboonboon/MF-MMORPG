# MFO-WO-P2-2B-004 — Slice 2-B foundation runner correction and revalidation

- Work order: `MFO-WO-P2-2B-004`
- Classification: **Blocked / validation infrastructure or evidence incomplete**
- Supervisor / QA start HEAD: `d6a870d669eec52bfec39d5809206d0b26f7e8ce`
- Candidate implementation: `0f705eeba3554d1f52b7402bb625ca8a86dd1560`
- Reviewed handoff: `81efefb156af68e5f564c6a97ce7e1d163b158a0`
- QA branch / workspace: `codex/phase2-slice2b-action-foundation-qa` / `C:\tmp\q2b`

## Authorized runner correction

The immutable pre-correction runner was read back as SHA-256
`f9f5c2efbe89e3cc6c90ff30dd9f071c8215437f2f02e6bebe2477d540ff1be2`, with `70` lines matching
`^\s*_check\(` and one line matching `^func _check\(`. Exactly one correction write inserted the authorized
`large_pool.clear()` line and the following one `_check` immediately after the existing 52nd-query assertion.

```gdscript
_check(large_pool.active_count() == 0 and large_pool.available_capacity_for_class(Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL) == 51, "clear removes all active reservations and restores configured capacity")
```

The corrected runner SHA-256 is `5745d2ace2fab67aabd4b5761d5f7ce6339c8b15cbaad25a8c821b22f1a878a4`.
Post-correction counts are `71` executable `_check` call sites and one helper declaration. No game code, other test,
data, scene, project configuration, existing report, or prior evidence was changed.

## Engine binding

- Console: `C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`
- Size / SHA-256: `198152` bytes / `D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`
- Version: `4.7.stable.official.5b4e0cb0f`, exit `0`

## Fixed-order results

| Order | Check | Exit | Result |
| ---: | --- | ---: | --- |
| 1 | Godot version | 0 | Pass |
| 2 | Headless editor import / parse | 0 | Pass |
| 3 | Corrected Slice 2-B runner | 0 | Pass — exact `71 assertions` |
| 4 | Phase 1 regression | 0 | Pass — `36 / 36` |
| 5 | Slice 2-A regression | 0 | Pass — `120 / 120` |
| 6 | Slice 2-A correction regression | 0 | Pass — `39 / 39` |
| 7 | Headless main-scene smoke | 0 | Pass |
| 8 | Fresh Windows release export | 1 | **Blocked** — `指定されたエクスポートパスが存在しません。` |

The release export is the first non-pass. Godot also reported `Project export for preset "Windows Desktop" failed.`
The configured output path `build/windows/MFO-Phase1.exe` did not exist. Per the order, QA did not create the output
directory, retry export, change export settings, substitute a prior binary, or run the exported-build smoke.

## Not run after the stop boundary

- Exported-build headless smoke
- Final exact-insertion audit, candidate five-path audit, protected / forbidden-path audit, prior-artifact identity
  re-read, `git diff --check`, untracked-file audit, local/origin equality, and final clean-worktree check
- Physical gamepad: **Not run / Deferred**
- Manual user-feel: **Not run**
- Slice 2-A harness, PREACK, P95, real A/B/C, Stage B, integration, Gate 2: **Not run / prohibited**

## Evidence and recommendation

- Commands: `docs/test-reports/evidence/phase2-slice2b/foundation-003/commands.md`
- Runner correction audit: `docs/test-reports/evidence/phase2-slice2b/foundation-003/runner-correction.md`

**Blocked / validation infrastructure or evidence incomplete.** The test and smoke checks completed through the
single fresh export attempt, but no release artifact was produced because the configured export directory was absent.
This report does not authorize a retry, implementation repair, Stage B, integration, or Gate 2 action.
