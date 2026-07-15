# Work Order — Phase 2 Slice 2-A Performance Isolation and KBM Completion

- Work order ID: `MFO-WO-P2-2A-003`
- Issued by: `00統括（監督）`
- Issued: 2026-07-14 (Asia/Tokyo)
- Priority: **P1 / current Slice 2-A acceptance blocker**
- Performance runtime severity: **Undetermined / frame-pacing acceptance failure only**
- Findings: `MFO-P2-2A-QA-002`, [`KI-010`](../KNOWN_ISSUES.md), [`KI-011`](../KNOWN_ISSUES.md)
- Owner: `30 QA・性能・レビュー`
- Gameplay owner: `10ゲームプレイ・コア実装` — no work in this order
- Presentation owner: `20ステージ・UI・グラフィック` — no work in this order
- Status: **Returned / Blocked; valid acceptance runs 0**
- Milestone: M2 / Slice 2-A acceptance
- Gate 2: **Locked / not evaluated**
- Ancestry base: `df0cd0cd17793fc2d9e0cc80d29249b3ceca5dd0`
- Required starting state: the pushed supervisor commit containing this order; `30` records its exact SHA
- Required QA branch: `codex/phase2-slice2a-diagnostic-qa`
- Required report: `docs/test-reports/phase2-slice2a-performance-diagnostic.md`
- Required evidence root: `docs/test-reports/evidence/phase2-slice2a/diagnostic-001/`

This order does not change OD-020, the `16.67 ms` criterion, any gameplay value, or any product specification. It
does not authorize a gameplay fix, integration to `main`, Slice 2-B, or Gate 2. Direct push to `main` is prohibited.

## 1. Supervisor disposition

`00統括` accepts the formal correction QA recommendation as **Fail** for Slice 2-A acceptance. The evidence is
internally consistent: two valid AC Online／Best performance runs exceeded frame P95 `<= 16.67 ms` at
`33.4643 ms` and `20.0000 ms`. The corrected-release KBM checklist is independently
`Blocked / Not completed`.

The functional correction itself is verified. Phase 1 passed `36 / 36`, the unchanged Slice 2-A suite passed
`120 / 120`, and the additive correction suite passed `39 / 39`. Exact-zero fallback, all tested small nonzero
directions, actor guard, distance, duration, tick boundaries, reject／no-buffer, collision, bounds, and reset passed.
[`KI-009`](../KNOWN_ISSUES.md) is therefore functionally resolved on the correction branch, pending Slice acceptance
and integration.

The performance failure is not yet a gameplay-code defect attribution. Commit `5261a737` changes only two conditions
executed for an evade request, while the failed scenario is arena idle. The same corrected binary also varied from
P95 `33.4643 ms` to `20.0000 ms`. No game-code or value change is authorized until the comparison below establishes
a code-correlated range.

This is not an unresolved specification question. Product requirements, Approved decisions, and
`OPEN_QUESTIONS.md` remain unchanged; `MASTER_SPEC.md` only receives the current-gate operational overlay.

## 2. Objectives

1. Separate current machine／desktop instability from a Slice 2-A candidate delta and from the two-line correction
   delta.
2. Re-run the unchanged `120`-warmup／`600`-sample arena-idle measurement in one controlled session.
3. Complete the corrected-release KBM functional checklist in a separate, uninterrupted session.
4. Return a `Pass`, `Fail`, or `Blocked` recommendation without altering gameplay, tests, recorder, build settings,
   quality, or acceptance thresholds.

## 3. Authorized scope and paths

`30` may commit changes only to:

- the required new diagnostic report;
- new evidence below the required diagnostic evidence root;
- `docs/handoffs/qa.md`.

Inline, read-only OS collection commands may be recorded in the evidence command log. Temporary detached worktrees
and untracked export outputs may be created below the existing ignored `.build/` area solely to produce the two
diagnostic builds. They must not be committed, and their source commits and resulting EXE hashes must be recorded.

The following are read／execute only and must not be edited:

- `material-frontier-online/prototype/scripts/**`;
- `material-frontier-online/prototype/tests/**`;
- the performance recorder and percentile implementation;
- scenes, `project.godot`, export presets, InputMap, quality, resolution, and renderer settings;
- all existing QA reports and evidence archives;
- all gameplay constants and behaviors.

If collecting a needed signal would require a tracked helper, recorder instrumentation, test change, or project
change, stop and request a scope amendment from `00統括`. Do not self-authorize it.

## 4. Immutable comparison set

Use these three sources:

| Label | Source | Purpose |
|---|---|---|
| A | Gate 1 source baseline `a13505e8fbf82962e049b9101a87593a6692d2c7`; packaged EXE at `material-frontier-online/deliverables/phase1/MFO-Phase1-Windows-x86_64/MFO-Phase1.exe`; SHA-256 `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` | Current-session environmental control |
| B | clean detached export of `295549373fbb3b39deb6079172783ce62c7da532` | Pre-correction Slice 2-A control |
| C | clean detached export of `5261a73707daca03cb160e03a12247886d3f5cce` | Corrected acceptance candidate |

`B` and `C` are parent／child sources whose runtime project delta is limited to the two authorized exact-zero
conditions. Export both with the same Godot `4.7.stable.official.5b4e0cb0f` executable and the unchanged Windows
release preset. Verify worktree cleanliness, export exit codes, actual EXE contents, sizes, and SHA-256 values before
measurement. Do not assume the earlier corrected QA EXE hash will equal the new clean detached export.

The Gate 1 EXE must be an LFS materialized binary, not a pointer, and its hash must match before use. Do not rebuild or
replace A.

## 5. Controlled performance procedure

Before the fixed run matrix:

1. finish both exports and hashing before timed measurement;
2. confirm AC Online／charging and AC Best performance GUID
   `ded574b5-45a0-4f42-8737-46345c09c238`;
3. record active plan, OS, CPU, GPU／driver, RAM, physical display mode, Windows logical bounds／DPI, foreground
   process, project window size, renderer, and quality;
4. record whether Defender, OneDrive, export, indexing, or another process is consuming material CPU／GPU／IO;
5. ensure no owned export or test process remains running and establish the same idle preparation before every run.

Run exactly this counterbalanced order, each as a new process:

```text
A1 → B1 → C1 → C2 → B2 → A2
```

Every run uses the unchanged arena scenario, `120` warmup frames, `600` samples, standard quality, GL Compatibility,
and a `1920×1080` project window. For every run preserve separately:

- exact command, timestamp, source／EXE hash, stdout, stderr, and exit code;
- performance JSON and HUD capture;
- power and display／window state before and after;
- read-only process／system CPU, GPU-engine when available, and IO observations during the run;
- any observable Defender／OneDrive or foreground-window interference.

The existing recorder remains unchanged. If raw per-frame／present timing cannot be acquired by an already available
external read-only method, record it as unavailable; do not instrument the game to obtain it. The JSON／HUD P95 is the
acceptance value. Existing GPU per-frame timing and memory limitations remain explicit.

Do not continue running until a favorable sample appears. A run is invalid only for a recorded integrity failure such
as wrong hash, wrong power／quality／window condition, process crash, missing output, or confirmed external
interference. Preserve invalid evidence and its reason; replacement of an invalid slot is allowed once. A valid
threshold failure is never discarded or replaced.

## 6. Corrected-release KBM completion

In a separate normal-launch session, use build C and record its exact hash. Complete all of the following in one
uninterrupted session:

- W／A／S／D movement;
- independent mouse aim;
- Space ground-step evade;
- movement direction priority on a fresh evade press;
- current aim fallback when movement is neutral;
- arena boundary non-crossing;
- active／reuse requests rejected;
- rejected requests are not buffered.

Partial sessions must not be combined into a Pass. Automation evidence does not replace manual KBM evidence. If
external user input or window acquisition failure recurs, return this item as `Blocked`, not as a gameplay Fail. A
repeatable functional discrepancy is a Fail and must include reproduction evidence; QA must not edit game values.

User feel is recorded only if the user actually operates build C. Physical gamepad remains `Not run / Deferred` under
OD-013 and is not converted to Pass from KBM or mapping automation.

## 7. Decision matrix

| Evidence pattern | Required disposition |
|---|---|
| A and C each have two valid P95 values `<= 16.67 ms`, all C KBM items Pass, and integrity checks pass | `30` may recommend **Pass**; B is attribution-only and does not block this result; `00` decides Slice acceptance |
| A passes twice; B passes twice; C exceeds the threshold in both valid runs | **Fail**, correction-delta correlation; stop and return to `00` |
| A passes twice; B and C each fail twice | **Fail**; the failure is present before the correction, but relative magnitude remains un-attributed; stop and return to `00` |
| A has any threshold failure or is internally unstable, results follow run order／external load, or comparison integrity is inconsistent | **Blocked / causality not isolated**; do not return gameplay code to `10` |
| A passes twice, but C has any valid threshold failure outside a fully code-correlated pattern, including a C Pass／Fail mix | Slice cannot Pass; return **Fail** for acceptance and explicitly keep causality unisolated |
| KBM has a repeatable functional discrepancy | **Fail** with reproduction; `00` decides any later code order |
| KBM is interrupted by external input or window-control failure | **Blocked**; do not classify it as a gameplay defect |
| Hash, LFS materialization, AC mode, quality, renderer, or required window condition is wrong | Stop before measurement and return **Blocked** |

A／B／C integrity and A-control stability are evaluated before the performance pattern rows. B is attribution-only:
its instability is recorded but does not block an otherwise complete A／C／KBM Pass. Determine performance and KBM
component dispositions first, then set the overall recommendation in this order: any confirmed component `Fail`
overrides `Blocked`; otherwise any mandatory `Blocked` overrides `Pass`; `Pass` requires every mandatory component to
Pass. Thus a performance Fail plus an interrupted KBM returns overall Fail, while a performance Pass plus interrupted
KBM returns overall Blocked.

A valid C run above `16.67 ms` prevents a Pass recommendation. No result in this matrix authorizes `30` to modify
game code or authorizes `10` to begin a fix. Any later gameplay profiling or correction requires a separate `00`
work order with an evidence-supported scope.

## 8. Report and routing

The new report must include:

- supervisor order SHA, QA branch and start SHA, A／B／C source and EXE hashes;
- all six scheduled results in execution order, including average, P50, P95, P99, maximum, and exit code;
- comparison interpretation using the decision matrix without claiming unsupported causality;
- OS load observations and unavailable metrics;
- the complete KBM checklist, user-feel separation, and physical-gamepad deferral;
- exact commands, evidence paths, a hash manifest, changed-path audit, and final recommendation.

`30` may not accept Slice 2-A, close Gate 2, authorize Slice 2-B, integrate to `main`, or rewrite the prior Fail
archive. After the QA handoff, only `00統括` determines acceptance and the next work order.

## 9. Outcome overlay — 2026-07-14

- QA report／evidence commit: `a3920f8419419357698c0db47f8aa35b3fd6ba34`
- QA closure／handoff commit: `701bfccc529c79cab7bd0a2eb7d8ff0435f0cb24`
- A／B／C source and executable integrity: Pass
- A1／B1／C1: Invalid because Windows-session input changed and foreground／load conditions were contaminated
- C2: Invalid because controller／exit／power／OS evidence was incomplete
- B2／A2: Not run after the repeated-interference stop
- Valid acceptance runs: `0`
- Performance component: **Blocked / causality not isolated**
- Corrected-C KBM: **Blocked / not an uninterrupted completed session**
- Gameplay defect found by this diagnostic: none
- Final QA recommendation: **Blocked**
- Supervisor disposition: Blocked accepted; the earlier correction performance Fail remains on record
- Controlled follow-up: [`MFO-WO-P2-2A-004`](phase2-slice2a-controlled-rerun.md) — Returned / Performance Blocked; KBM Pass
- Current follow-up: [`MFO-WO-P2-2A-005`](phase2-slice2a-performance-only-rerun.md) — performance only

The formal report and `diagnostic-001/` evidence remain immutable. `MFO-WO-P2-2A-004` used its assigned
`diagnostic-002/` root; subsequent orders use their own newly assigned roots and must not append to either archive.
