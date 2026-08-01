# MFO-WO-P2-2B-004 — Slice 2-B foundation runner cardinality correction and revalidation

- Issuer: `00統括（監督）`
- Issued: 2026-08-01 (Asia/Tokyo)
- Assignee: `30 QA・性能・レビュー`
- Status: **Authorized / QA runner correction and isolated revalidation only**
- Milestone: M2 / Slice 2-B pre-integration foundation
- Required branch: `codex/phase2-slice2b-action-foundation-qa`
- Required workspace: existing dedicated worktree `C:\tmp\q2b`
- Starting QA HEAD: `c595f67d61bc86720e47321594a55ff7e04b133f`
- Candidate implementation commit: `0f705eeba3554d1f52b7402bb625ca8a86dd1560`
- Candidate handoff / reviewed HEAD: `81efefb156af68e5f564c6a97ce7e1d163b158a0`
- Integration authority: **None**
- Gate effect: **None** — Gate 2 remains Locked

## 1. Supervisor disposition

`MFO-WO-P2-2B-003` is accepted as a formal non-pass, but it does not establish a candidate implementation or
specification defect. The frozen runner executed successfully and reported `70 assertions`. Read-only source counting
shows exactly `70` `_check(...)` call sites plus the `_check` function declaration. The earlier `71 assertions`
inventory counted the declaration as if it were an executed assertion, and -003 inherited that incorrect exact total.

The defect is therefore attributed to the QA runner cardinality declaration and coverage artifact. Do not change the
candidate implementation or lower the acceptance total after failure. The original implementation order requires
both `reset()` and `clear()` to leave active counts at zero and restore configured capacity, while the runner covers
only `reset()`. This order permits one bounded `clear()` assertion, then performs the complete validation once.

## 2. Exact correction

The only permitted runner semantic change is this exact two-line insertion immediately after the existing
`52nd query follows configured capacity without a special 51st case` assertion in `_test_reservation_query_pool()`:

```gdscript
large_pool.clear()
_check(large_pool.active_count() == 0 and large_pool.available_capacity_for_class(Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL) == 51, "clear removes all active reservations and restores configured capacity")
```

This adds exactly one executed assertion and covers the original -001 `clear()` contract using the already-active
51-lease pool. No helper, existing assertion, value, expected string, or implementation file may change.

Before writing, verify the frozen runner SHA-256
`f9f5c2efbe89e3cc6c90ff30dd9f071c8215437f2f02e6bebe2477d540ff1be2`, exactly `70` lines matching
`^\s*_check\(`, and exactly one line matching `^func _check\(`. After writing, prove the exact two-line insertion,
exactly `71` lines matching the first expression, exactly one matching the second, and record the new runner SHA-256.
One correction write only; no alternate runner.

## 3. Authorized tracked paths

Only these tracked paths may be added or changed:

- `material-frontier-online/prototype/tests/run_slice2b_foundation_tests.gd` — exact two-line correction above
- `docs/test-reports/phase2-slice2b-foundation-runner-correction-revalidation.md` — new formal report
- `docs/test-reports/evidence/phase2-slice2b/foundation-003/**` — new evidence from this order only
- `docs/handoffs/qa.md` — receipt and final handoff only

Game code, all other existing tests, values, data, `.uid` files, scenes, `project.godot`, -002／-003 reports,
`foundation-001`／`foundation-002` evidence, and all implementation artifacts are immutable.

## 4. Engine binding and required validation

Run from `C:\tmp\q2b\material-frontier-online\prototype` with only this exact console executable:

`C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`

Required identity: `198152` bytes; SHA-256
`D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`; version
`4.7.stable.official.5b4e0cb0f`. Run and preserve exact commands, exits, totals, stdout／stderr, and relevant hashes:

1. engine size／SHA-256／`--version`;
2. headless editor import／parse;
3. corrected runner, requiring exit `0` and exact `PASS: 71 assertions`;
4. Phase 1 `36 / 36`, Slice 2-A `120 / 120`, and correction `39 / 39`;
5. headless main-scene smoke;
6. fresh Windows release export and exported-build headless smoke using unchanged configuration;
7. exact two-line insertion audit, candidate five-path audit, protected／forbidden-path audit, prior artifact identity,
   `git diff --check`, untracked-file audit, local／origin equality, and final clean-worktree check.

## 5. Stop and result rules

The correction and each required command are single-attempt. Stop at the first non-pass. Do not repair, rerun,
change the expected total, switch engines, or alter implementation. Return exactly one recommendation:

- `Pass / isolated Stage A foundation validated`;
- `Fail / candidate implementation or specification nonconformance`; or
- `Blocked / validation infrastructure or evidence incomplete`.

A corrected runner failure may establish a candidate defect only when the failing assertion and output directly
support that attribution. Manual user-feel is not required. Physical gamepad remains `Not run / Deferred`. Slice 2-A
PREACK／P95／real A／B／C, OneDrive／power changes, Stage B, production action values, input, authority, damage,
scenes, events, presentation, integration, and Gate 2 are prohibited.

## 6. Return routing

Commit the runner／new report／new evidence as one QA content commit and the final QA handoff as a separate commit,
then push only the required QA branch. Return exact changed paths, before／after runner identities and counts, every
command result, report／evidence paths, local／origin equality, clean status, and all Not run／Deferred items.

Stop after return. Even a Pass accepts only the isolated Stage A foundation and does not resolve Slice 2-A
performance, open Gate 2, authorize Stage B, or authorize playable／integrated Slice 2-B.
