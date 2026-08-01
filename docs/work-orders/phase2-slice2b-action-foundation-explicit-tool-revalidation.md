# MFO-WO-P2-2B-003 — Slice 2-B explicit-tool action-foundation revalidation

- Issuer: `00統括（監督）`
- Issued: 2026-08-01 (Asia/Tokyo)
- Assignee: `30 QA・性能・レビュー`
- Status: **Authorized / explicit-tool revalidation only**
- Milestone: M2 / Slice 2-B pre-integration foundation
- Required branch: `codex/phase2-slice2b-action-foundation-qa`
- Required workspace: existing dedicated worktree `C:\tmp\q2b`
- Starting QA HEAD: `ca167a688611a04b853c94596b569656ff24974c`
- Candidate implementation commit: `0f705eeba3554d1f52b7402bb625ca8a86dd1560`
- Candidate handoff / reviewed HEAD: `81efefb156af68e5f564c6a97ce7e1d163b158a0`
- Integration authority: **None**
- Gate effect: **None** — Gate 2 remains Locked

## 1. Supervisor disposition and purpose

`MFO-WO-P2-2B-002` is accepted as `Blocked / validation evidence incomplete`: its scope audit and additive test
creation completed, but every required Godot runtime, regression, smoke, and export check was Not run. This does not
establish an implementation defect.

The stated host-level absence of Godot is not accepted as the underlying cause. The reviewed candidate report already
records the installed project engine, and the supervisor independently confirmed the following executable:

- console path: `C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`
- console size: `198152` bytes
- console SHA-256: `D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`
- `--version`: exit `0`, `4.7.stable.official.5b4e0cb0f`
- adjacent editor: `Godot_v4.7-stable_win64.exe`, `178485256` bytes, SHA-256
  `B2CA888D5115A6CEDEE564764A2EE494A625F2EC2EDBABD010FE33C9A88A6BF8`

The -002 cause is therefore attributed to incomplete executable discovery. This order supplies the exact executable
binding and permits one fresh validation of the already-frozen candidate and additive runner.

## 2. Immutable inputs and starting checks

Before any Godot launch, fast-forward the required QA branch/worktree to the supervisor commit that contains this
order. Record and verify:

1. local HEAD equals origin for the required branch and the worktree is clean;
2. the candidate implementation and reviewed handoff identities above;
3. the existing runner
   `material-frontier-online/prototype/tests/run_slice2b_foundation_tests.gd` is exactly `f9f5c2efbe89e3cc6c90ff30dd9f071c8215437f2f02e6bebe2477d540ff1be2`;
4. the console executable path, size, SHA-256, and version above;
5. the -002 report and `foundation-001` evidence remain byte-identical.

Do not edit the runner, game code, existing tests, -002 report, or `foundation-001` evidence. Do not switch, reset,
clean, stash, or mutate the shared Slice 2-A QA worktree.

## 3. Authorized tracked paths

Only these tracked paths may be added or changed:

- `docs/test-reports/phase2-slice2b-action-foundation-explicit-tool-revalidation.md` — new formal report
- `docs/test-reports/evidence/phase2-slice2b/foundation-002/**` — new evidence from this order only
- `docs/handoffs/qa.md` — receipt and final handoff only

All implementation files, the existing additive runner, existing tests, data, `.uid` files, scenes, `project.godot`,
prior reports, and prior evidence are immutable. QA must not fix code or change values.

## 4. Required commands

Run from `C:\tmp\q2b\material-frontier-online\prototype`. Bind `$Godot` to the exact console path in Section 1;
do not use PATH discovery or a substitute binary. Record each exact command, numeric exit, totals, stdout／stderr,
and relevant artifact hashes.

1. `& $Godot --version` and exact version identity;
2. `& $Godot --headless --editor --path . --quit` for import／parse;
3. `& $Godot --headless --path . --script res://tests/run_slice2b_foundation_tests.gd` and `71 / 71` assertions;
4. Phase 1 `36 / 36`, Slice 2-A `120 / 120`, and correction `39 / 39` regressions;
5. `& $Godot --headless --path . --quit-after 120` for main-scene smoke;
6. the existing Windows release export, then a fresh exported-build headless smoke; do not edit export settings;
7. `git diff --check`, candidate five-path audit, forbidden/protected-path audit, untracked-file audit, runner hash
   readback, and final clean-worktree check.

Use the export preset and command already documented by the prototype README／QA handoff. If the fresh export or
exported smoke is blocked by an independently evidenced host condition, return `Blocked`; do not substitute a prior
binary or LFS pointer.

## 5. Stop and acceptance rules

Stop at the first non-pass. Do not repair implementation, alter the runner, retry a failed runtime command, switch
engines, or widen the order. Return exactly one recommendation:

- `Pass / isolated Stage A foundation validated` only if every required command and audit passes;
- `Fail / implementation or specification nonconformance` for a reproducible candidate/runtime/test failure; or
- `Blocked / validation infrastructure or evidence incomplete` for an independently evidenced host/evidence failure.

Manual user-feel is not required because this foundation is disconnected. Physical gamepad remains
`Not run / Deferred`. The Slice 2-A external harness, PREACK, P95, real A／B／C, OneDrive／power changes, Stage B,
production values, input, authority, damage, scenes, events, presentation, integration, and Gate 2 are prohibited.

## 6. Return routing

Commit the new report／evidence as one QA content commit and the final QA handoff as a separate commit, then push only
the required QA branch. Return local／origin equality, clean status, exact changed paths, every command result, report
and evidence paths, and all Not run／Deferred items to `00統括`.

Stop after return. Even a Pass accepts only the isolated Stage A foundation and does not resolve Slice 2-A
performance, open Gate 2, authorize Stage B, or authorize playable／integrated Slice 2-B.
