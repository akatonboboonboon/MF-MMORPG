# MFO-WO-P2-2B-002 — Slice 2-B isolated action-foundation validation

- Issuer: `00統括（監督）`
- Issued: 2026-08-01 (Asia/Tokyo)
- Assignee: `30 QA・性能・レビュー`
- Status: **Authorized / formal Stage A validation only**
- Milestone: M2 / Slice 2-B pre-integration foundation
- Required branch: `codex/phase2-slice2b-action-foundation-qa`
- Required workspace: dedicated Git worktree; do not switch or mutate the shared Slice 2-A QA worktree
- Candidate implementation commit: `0f705eeba3554d1f52b7402bb625ca8a86dd1560`
- Candidate handoff / reviewed HEAD: `81efefb156af68e5f564c6a97ce7e1d163b158a0`
- Integration authority: **None**
- Gate effect: **None** — Gate 2 remains Locked

## 1. Purpose and acceptance boundary

Independently validate the non-connected common action／effect／reservation-query foundation returned by
[`MFO-WO-P2-2B-001`](phase2-slice2b-action-foundation.md). Supervisor scope and evidence review found no commit blocker;
this order supplies the required formal QA result.

This is deliberately a normal Godot validation order. Do not create or reuse the Slice 2-A external performance
harness, sealed Stage, PREACK, activation token, performance matrix, or recovery driver. Do not run P95 or real A／B／C
slots. A Pass accepts only the isolated Stage A foundation. It does not accept Slice 2-A, resolve
`MFO-HOLD-P2-2A-001`, open Gate 2, authorize production values, or authorize Slice 2-B Stage B／runtime integration.

## 2. Starting state and branch isolation

Create the required QA branch and a dedicated worktree from the supervisor commit containing this order. Before any
write, record the exact starting HEAD, candidate identities above, branch, local／origin state, and clean worktree.

- Do not switch, reset, clean, stash, or otherwise mutate the shared Slice 2-A QA worktree.
- Do not change, rewrite, or amend either candidate commit.
- Do not push to `main`, the implementation branch, or the shared Slice 2-A QA branch.
- If the order, candidate, or clean dedicated worktree cannot be verified, stop as `Blocked` before editing.

## 3. Authorized paths

Only these tracked paths may be added or changed:

- `material-frontier-online/prototype/tests/run_slice2b_foundation_tests.gd` — new additive test runner only
- `docs/test-reports/phase2-slice2b-action-foundation-validation.md` — new formal report
- `docs/test-reports/evidence/phase2-slice2b/foundation-001/**` — new evidence from this order only
- `docs/handoffs/qa.md` — QA receipt and final handoff only

Existing tests, game code, `.uid` files, data, scenes, `project.godot`, build outputs, previous reports, and previous
evidence must remain byte-identical. QA must not fix implementation code or change a value to obtain a Pass.

## 4. Required independent validation

### 4.1 Scope and compatibility

1. Prove the candidate changes exactly the five paths authorized by `MFO-WO-P2-2B-001`.
2. Confirm existing Phase 1 class names, exports, public legacy pool API, resources, and validation behavior remain usable.
3. Confirm there is no production action data, lifecycle, input／authority／hit／damage execution, scene, event,
   presentation, or integration connection.
4. Confirm existing combat `.uid` files, QA sources, Phase 1 data, scene, project configuration, input／simulation／
   phase1／presentation paths are unchanged from the candidate base.

### 4.2 Common action definition

Add independent assertions for:

- one valid common scaffold;
- empty action ID or category and an unsupported category;
- non-finite or negative timing and negative maximum query count;
- invalid reservation class;
- empty effect reference, duplicate common effect reference, and duplicate across common／legacy references;
- stable hit／effect／reservation／presentation identifiers being stored without execution.

Do not invent a schema-version requirement or production timing／shape／effect vocabulary that is not approved.

### 4.3 Common effect definition

Add independent assertions for:

- one valid common scaffold, including signed and zero magnitude;
- empty required identity fields;
- non-finite magnitude, non-finite duration, negative duration, and empty tags;
- storage-only behavior with no damage, part damage, force, heat, status, or other effect interpretation.

Do not turn the open effect vocabulary into a closed enum merely for testing.

### 4.4 Reservation-query pool

Add independent assertions for:

- legacy configure／try-acquire／release behavior;
- caller-injected `PlayerCritical`, `BossCritical`, `Environment`, and `LowPriority` capacities;
- invalid or incomplete reconfiguration failing without corrupting the previous valid configuration;
- strict normal-class isolation;
- LowPriority and Environment never consuming PlayerCritical, BossCritical, or emergency capacity;
- explicit PlayerCritical／BossCritical emergency use only, with observable telemetry;
- unique monotonic lease tokens and rejection of unknown, duplicate, released, and pre-reset stale releases;
- reset clearing all active counts and restoring configured capacity while telemetry remains observable and
  nondecreasing;
- caller-injected capacity of at least `51` succeeding without a literal `50` product cap or a 51st-query special case.

## 5. Commands and regression

Use the installed project Godot version and record exact commands, numeric exits, totals, and logs:

1. `godot --version` and expected `4.7.stable.official.5b4e0cb0f` identity;
2. headless editor import／parse;
3. the new `run_slice2b_foundation_tests.gd` runner;
4. Phase 1 `36 / 36`, Slice 2-A `120 / 120`, and correction `39 / 39` regressions;
5. headless main-scene smoke;
6. Windows release export and exported-build headless smoke, using existing configuration without editing it;
7. `git diff --check`, changed-path audit, forbidden-path audit, untracked-file audit, and final clean-worktree check.

If release export cannot run for a host reason, record `Blocked / Not run` accurately; do not substitute an old binary
or LFS pointer. No manual user-feel session is required because Stage A is not connected. Physical gamepad remains
`Not run / Deferred`. Performance／P95／A／B／C remain `Not run` under the separate Slice 2-A hold.

## 6. Result and return routing

Return exactly one formal recommendation:

- `Pass / isolated Stage A foundation validated`;
- `Fail / implementation or specification nonconformance`; or
- `Blocked / validation infrastructure or evidence incomplete`.

Commit test／report／evidence as one QA content commit and the final QA handoff as a separate commit, then push only the
required QA branch. Return local／origin equality, clean status, exact changed paths, command results, report／evidence
paths, and all Not run／Deferred items to `00統括`.

Stop after return. There is no automatic implementation fix, Stage B, merge, integration, performance, or Gate 2
follow-on. Any implementation defect returns to `00統括` for a separate correction order.
