# Work Order — Phase 2 Slice 2-A Basic Operation

- Work order ID: `MFO-WO-P2-2A-001`
- Issued by: `00統括（監督）`
- Issued: 2026-07-14 (Asia/Tokyo)
- Implementation owner: `10ゲームプレイ・コア実装`
- Validation owner: `30 QA・性能・レビュー` after the `10` handoff
- Presentation owner: `20ステージ・UI・グラフィック` — no integration work in this order
- Status: **Returned / original Stage B Fail; later functional correction verified**
- Milestone: M2 / Slice 2-A
- Code changes authorized: **No further changes under this order**
- Gate 2: **Locked / not evaluated**
- Required implementation report: `material-frontier-online/implementation/2026-07-14-phase2-slice2a-basic-operation.md`
- Required QA report: `docs/test-reports/phase2-slice2a-validation.md`
- Stage B result: `119 / 120 Pass`, exit `1`; `MFO-P2-2A-QA-001`
- Bounded correction: [`MFO-WO-P2-2A-002`](phase2-slice2a-nonzero-direction-correction.md) — Returned
- Current state: [`MFO-HOLD-P2-2A-001`](phase2-slice2a-performance-external-hold.md) — no execution authorized

The required starting state is the repository commit containing this work order and the Phase 2 P1 decision
record. Each role must record the exact starting `HEAD` before changing files. This order does not authorize
direct push to `main`; return work to `00統括` for integration.

## Outcome overlay — 2026-07-14

`30` returned a formal Fail recommendation because a small movement vector that remains nonzero after the input
deadzone is treated as neutral by two evade-direction checks. `00統括` accepted that result as a P1 Slice 2-A
acceptance blocker with Low runtime impact. The requirements and acceptance criteria below remain unchanged as the
regression baseline, but they no longer authorize edits. The bounded correction was routed through
`MFO-WO-P2-2A-002`.

The bounded correction was completed and functionally verified under `MFO-WO-P2-2A-002`; that order then returned
with performance Fail and KBM Blocked. `MFO-WO-P2-2A-003` also returned Blocked with zero valid acceptance runs.
`MFO-WO-P2-2A-004` returned Performance Blocked／KBM Pass. `MFO-WO-P2-2A-005` also returned Blocked with slots
`0` and valid matrix `0`. `MFO-HOLD-P2-2A-001` now authorizes no execution and permits no game-code edits.

## 1. Authority and prerequisites

- Gate 1: [`GATE-1`](../../material-frontier-online/decisions/2026-07-14-gate-1-approval.md) Pass
- Phase 2 P1 baseline: [`P2-P1-2026-07-14`](../../material-frontier-online/decisions/2026-07-14-phase2-p1-approval.md)
- Preserved decisions: OD-001, OD-004, OD-006, OD-013
- Direct Slice 2-A decisions: OD-020, OD-021, OD-041-P2, OD-043-P2
- Approved but not implemented by this order: OD-026 and OD-027

If the checked-out repository does not contain these Approved records, stop before implementation and return
to `00統括`.

## 2. Objective

Extend the Phase 1 vertical path only far enough to establish authority-owned basic operation:

1. preserve normalized 8-direction movement and independent aim;
2. carry an abstract `evade` request from Space／gamepad A into Local Authority Simulation;
3. execute the approved ground step deterministically;
4. add an authority-owned same-arena reset seam for later defeated-state retry integration.

Do not implement the defeat cause, retry input binding, formal attacks, damage, persistent HUD, or presentation
integration in this slice.

## 3. Sequence and path ownership

### Stage A — `10` implementation

`10` may change only:

- `material-frontier-online/prototype/scripts/input/input_adapter.gd`
- `material-frontier-online/prototype/scripts/simulation/input_command.gd`
- `material-frontier-online/prototype/scripts/simulation/local_authority_simulation.gd`
- `material-frontier-online/prototype/scripts/simulation/player_actor.gd`
- one narrowly scoped new configuration／runtime file under `prototype/scripts/input/` or `simulation/` only if
  the four listed files cannot express the approved state cleanly; report why it was required
- `docs/handoffs/gameplay.md`
- the required implementation report

No `.tscn`, `project.godot`, camera, presentation, combat definition, QA test, or shared contract file is assigned
to `10` by this order. Do not rename all Phase 1 classes or build a general action／online framework as part of
this slice.

### Stage B — `30` validation

After `10` records a resulting commit／handoff, `30` may change only:

- `material-frontier-online/prototype/tests/`
- `docs/test-reports/phase2-slice2a-validation.md`
- new evidence below `docs/test-reports/evidence/phase2-slice2a/`
- `docs/handoffs/qa.md`

Before the `10` handoff, `30` may draft a test plan in its handoff but must not edit implementation files or
freeze expectations against an interface that has not been returned. `30` never tunes gameplay values.

### `20` disposition

`20` has no code, asset, camera, HUD, VFX, animation, audio, or shared-scene assignment in Slice 2-A. Existing
permission for separate, non-connected, non-binding proposals remains; no such proposal is required for this
order.

## 4. Required Slice 2-A behavior

### Existing movement and aim

- Preserve normalized 8-direction movement and independent all-direction aim.
- Preserve stable actor／target IDs, command sequence, and physics tick.
- `InputCommand` remains a request; only Local Authority Simulation accepts or rejects it.
- Preserve the current Phase 1 `move_speed` and gameplay bounds as provisional test data. This order does not
  approve or retune them.
- Preserve the 1920×1080, fixed-direction, zoom 1.0 one-screen camera without editing camera files.

### Evade request and authority

- Space and gamepad A remain the same abstract `evade` action. Capture a fresh press as a request; the input
  layer must not decide acceptance, collision, travel, or cooldown.
- On acceptance, latch normalized nonzero movement input as the step direction. If movement input is neutral,
  latch the current aim direction.
- In a collision-free test, travel `140 px` over `0.20 s` using fixed physics updates. Ordinary locomotion must
  not add distance to or cancel the active step.
- Gameplay collision and configured gameplay bounds may shorten actual travel but may not be crossed.
- The next evade start may be accepted no earlier than `0.45 s` after the previous accepted start. At 60 fixed
  ticks per second, the nominal values are 12 active ticks and 27 start-to-start ticks.
- Requests while the step is active or before reuse becomes available are rejected and never queued for later.
- Do not add invulnerability, stamina, input buffering, lock-on, part lock, auto approach, or attack cancel.
- Keep the reserved LB／Q `lock_on` mapping behaviorless; do not delete its abstract action.

### Authority reset seam

- Local Authority Simulation owns a callable reset operation for a configured actor and same-arena start state.
- Reset restores configured start position, configured initial aim, zero velocity, and the complete evade runtime
  state, including active progress, reuse timing, and any pending request state.
- Reset is idempotent and does not also execute movement, aim change, evade, or provisional attack from the
  command that caused it.
- Slice 2-A does not add `Integrity`, a defeated state, retry UI, retry input binding, checkpoint logic, or scene
  reload. OQ-005 must be decided before Slice 2-C connects defeated-state input to this seam.
- Cached aim, neutral per-tick input, and ordinary simulation stepping must never trigger reset automatically.

### Events and presentation boundary

- Do not add or change a production `DomainEvent` payload.
- Do not promote Phase 1 debug events to production contracts.
- Do not add a retry presentation event or make `ActionStarted` an evade consumer contract.
- QA may inspect authority state or a clearly debug-only seam; Presentation may not consume it in this slice.

## 5. Forbidden scope

- Slice 2-B quick cut／heavy cleave, windup, active window, recovery, hit-query behavior, or provisional attack changes
- Slice 2-C `EquipmentLoadout`, core `EquipmentRuntimeState`, `Integrity`, `Deformation`, damage, defeat, or OD-027 penalty
- Slice 2-D production event payloads, persistent HUD, VFX, hitstop, camera shake, or presentation consumer
- lock-on, part lock, target cycling, auto approach
- camera／viewport／HUD／art／audio／asset／shared-scene changes
- materials, magic, boss, parts, stage, gimmicks, corpse, loot
- network, server, account, persistence, payment, rollback, general future-online abstraction
- fatigue or destruction reserved events
- material-specific player classes or action-specific damage code
- weakening existing assertions, changing expected values to hide a failure, or editing old evidence
- treating KBM automation as physical-gamepad Pass

## 6. Acceptance — implementation and automated verification

`10` must run the existing Phase 1 tests before handoff. `30` then owns fresh regression and Slice 2-A tests.
At minimum, `30` verifies:

1. Project import／parse and all existing Phase 1 assertions pass without weaker expectations.
2. Space and gamepad A map to one abstract evade request; device-specific gameplay branches do not exist.
3. Move direction and neutral-move／aim-direction evade cases both pass.
4. Collision-free travel is `140 px` over `0.20 s` within a documented floating-point tolerance.
5. Collision and gameplay bounds are not penetrated; shortened travel is reported as collision-limited, not failure.
6. Requests during the active interval and remaining `0.45 s` start interval are rejected without delayed buffered evade.
7. Ordinary movement resumes after the step and does not alter the approved step distance.
8. Unknown actor commands cannot mutate any actor; stable ID, sequence, and physics tick remain auditable.
9. Authority reset returns start position, initial aim, zero velocity, and full evade state with no residual cooldown.
10. Neutral ticks／cached aim never auto-reset; repeated explicit reset calls remain safe.
11. No invulnerability, stamina, lock-on, auto approach, damage state, HUD integration, or production event was added.
12. Main-scene headless smoke and a proportionate release／export smoke pass.

`30` should also run a 600-sample arena-idle performance regression on the reference device if the established
measurement command remains usable. Report it as Slice 2-A regression evidence, not a new Gate 1, Gate 7, stress,
or product-minimum result.

## 7. Manual QA disposition

On a release-equivalent build at 1920×1080／standard quality, `30` checks KBM WASD movement, mouse aim, Space
evade, direction fallback, boundary behavior, and repeated-input rejection. Automated reset-seam verification is
sufficient in 2-A because defeat and retry binding are deliberately not implemented yet.

- Functional observation and human feel must be reported separately.
- Do not infer user feel without asking the user.
- Physical gamepad remains `Not run / Deferred`; mapping tests are not hardware evidence.

## 8. Required outputs and routing

`10` records:

- starting and resulting commit;
- files and exact behavior changed;
- decisions relied on;
- tests and exact results;
- implementation report and gameplay handoff;
- new open questions or known issues;
- confirmation that no forbidden scope changed.

`30` records:

- tested commit and environment;
- commands, exit codes, fresh results, raw evidence paths, and hashes where applicable;
- automated, manual KBM, user feel, and deferred gamepad as separate fields;
- defects versus specification questions;
- Slice 2-A recommendation: `Pass / Fail / Blocked`.

Fail or ambiguity returns to `00統括`. A correction requires a bounded follow-up order. Completion or QA Pass of
this work order does not approve Gate 2 and does not authorize Slice 2-B, 2-C, or 2-D.
