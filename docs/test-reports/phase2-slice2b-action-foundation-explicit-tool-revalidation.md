# MFO-WO-P2-2B-003 — Slice 2-B explicit-tool action-foundation revalidation

- Work order: `MFO-WO-P2-2B-003`
- Classification: **Fail / implementation or specification nonconformance**
- QA start / supervisor HEAD: `f6d0fdcef3638f8e92244e2afb03237c038e41f3`
- Candidate implementation: `0f705eeba3554d1f52b7402bb625ca8a86dd1560`
- Reviewed handoff: `81efefb156af68e5f564c6a97ce7e1d163b158a0`
- QA branch: `codex/phase2-slice2b-action-foundation-qa`
- Workspace: `C:\tmp\q2b`

## Immutable inputs

- Runner: `material-frontier-online/prototype/tests/run_slice2b_foundation_tests.gd`
- Runner SHA-256: `f9f5c2efbe89e3cc6c90ff30dd9f071c8215437f2f02e6bebe2477d540ff1be2`
- Required runner result: `71 / 71` assertions, exit `0`
- Exact console executable: `C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`
- Console size / SHA-256: `198152` bytes / `D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`
- Console version: `4.7.stable.official.5b4e0cb0f`

The existing runner, game code, existing tests, data, scenes, project configuration, -002 report, and
`foundation-001` evidence were not modified by this order.

## Commands and results

| Check | Command | Exit | Result |
| --- | --- | ---: | --- |
| Engine identity | `& $Godot --version` | 0 | Pass — `4.7.stable.official.5b4e0cb0f` |
| Import / parse | `& $Godot --headless --editor --path . --quit` | 0 | Pass |
| Additive foundation runner | `& $Godot --headless --path . --script res://tests/run_slice2b_foundation_tests.gd` | 0 | **Fail** — required `71 / 71`; actual terminal summary was `70 assertions` |

The third command is the first non-pass. The runner’s numeric exit was `0`, but the acceptance total in the
work order is exact and was not met. No runner repair, rerun, substitute engine, or follow-on runtime command was
performed.

## Not run after the stop boundary

- Phase 1 regression: `36 / 36`
- Slice 2-A regression: `120 / 120`
- Slice 2-A correction regression: `39 / 39`
- Main-scene smoke
- Fresh Windows release export
- Exported-build headless smoke
- Final scope / clean audit for this order

The -002 scope audit remains historical supporting evidence only: expected changed paths `5`, unexpected `0`,
missing `0`, protected changed `0`, and `git diff --check` exit `0`. It was not rerun after the -003 stop boundary.

## Evidence and exclusions

- Command transcript: `docs/test-reports/evidence/phase2-slice2b/foundation-002/commands.md`
- Physical gamepad: **Not run / Deferred**
- Manual user-feel: **Not run** (not required for disconnected foundation)
- Slice 2-A external harness, PREACK, P95, real A/B/C, Stage B, integration, Gate 2: **Not run / prohibited**

## Recommendation

**Fail / implementation or specification nonconformance.** The frozen additive runner did not produce the required
`71 / 71` result. This report does not authorize an implementation fix, runner modification, Stage B, integration,
or Gate 2 action.
