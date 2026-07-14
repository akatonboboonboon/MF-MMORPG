# Material Frontier Online — Phase 2 Slice 2-A Basic Operation

- Date: 2026-07-14 (Asia/Tokyo)
- Work order: `MFO-WO-P2-2A-001`
- Owner: `10ゲームプレイ・コア実装`
- Starting commit: `afcd20cd4a02d618a5d7e0e4bc7555a64fa90740`
- Implementation commit: `bd01fdf3d048accaa7f5be93afe3be5cfa138201`
- Result: **Implementation complete / QA validation pending**
- Gate 2: **Locked / not evaluated**

## 1. Authority and scope

Implemented only the behavior and paths authorized by
[`MFO-WO-P2-2A-001`](../../docs/work-orders/phase2-slice2a-basic-operation.md), relying on OD-001, OD-013,
OD-020, and OD-021. OD-026 and OD-027 remain unimplemented. No scene, project setting, combat definition,
QA-owned test, presentation file, production event, camera, HUD, or asset was changed.

## 2. Implemented behavior

### Abstract evade request

- `InputAdapter` captures a fresh Space／gamepad A press from the existing abstract `evade` action.
- `InputCommand` carries `evade_requested` as a request only.
- Existing command factory call sites remain compatible because the new argument is optional and appended after the
  existing actor／target arguments.
- Reserved LB／Q `lock_on` remains mapped and behaviorless.

### Authority-owned ground step

- Local Authority Simulation accepts a request only when the addressed actor has no active step and its reuse time
  has elapsed.
- Acceptance latches normalized movement input; neutral movement falls back to current normalized aim.
- The actor moves `140 px` over `0.20 s` (`700 px/s`, nominally 12 fixed 60 Hz updates).
- The `0.45 s` reuse clock begins at an accepted start. Requests during the active step or reuse interval are not
  stored, so they cannot start later without a fresh request.
- Ordinary movement cannot add to or cancel active-step travel. Aim remains independently updateable.
- `move_and_collide()` and the existing configured movement bounds may shorten travel without allowing penetration.
- No invulnerability, stamina, buffer, lock-on, part lock, auto approach, attack cancel, damage, or formal attack was
  added.

### Authority reset seam

- `LocalAuthoritySimulation.configure()` captures each configured actor's same-arena start position and initial aim.
- `reset_actor_to_start(actor_entity_id)` restores that state through the addressed authority actor.
- Reset clears velocity, active-step state, latched direction, elapsed progress, and reuse timing.
- Unknown actor IDs are rejected without mutating configured actors; repeated explicit reset calls are idempotent.
- The seam has no input binding and accepts no command, so it does not execute movement, aim, evade, or provisional
  attack as a reset side effect.

### Debug inspection boundary

`debug_evade_state()` exposes only a read-only snapshot for implementation／QA inspection. No `DomainEvent` was added
or changed, and the Phase 1 debug event surface was not promoted to a production presentation contract.

## 3. Files changed

Implementation commit:

- `prototype/scripts/input/input_adapter.gd`
- `prototype/scripts/simulation/input_command.gd`
- `prototype/scripts/simulation/local_authority_simulation.gd`
- `prototype/scripts/simulation/player_actor.gd`

Handoff documentation:

- `implementation/2026-07-14-phase2-slice2a-basic-operation.md`
- `../../docs/handoffs/gameplay.md`

## 4. Verification performed by implementation owner

| Check | Result | Notes |
|---|---|---|
| Unmodified baseline Phase 1 assertions | **36 / 36 Pass**, exit `0` | Explicit project-local `--log-file` used |
| Final import / parse | **Pass**, exit `0` | Godot `4.7.stable.official.5b4e0cb0f` |
| Final Phase 1 assertions | **36 / 36 Pass**, exit `0` | Existing expectations unchanged |
| Temporary Slice 2-A implementation self-check | **25 / 25 Pass**, exit `0` | Ignored harness removed after use; not formal QA evidence |
| Windows release export | **Pass**, exit `0` | Existing `Windows Desktop` preset; output remains ignored local build |
| Exported EXE headless smoke | **Pass**, exit `0` | `--quit-after 5`; hidden process |

The temporary self-check covered fresh evade request capture, movement-direction priority, neutral aim fallback,
140 px／12-tick travel, independent aim, active／reuse rejection, no buffered start, fresh post-reuse acceptance,
bounds and runtime-configured collision shortening, ordinary movement resumption, complete reset, reset idempotence,
and unknown-actor reset rejection.

Commands used:

```powershell
# Import / parse
Godot_v4.7-stable_win64_console.exe --headless `
  --log-file logs/slice2a-import.log --editor --path . --quit

# Existing Phase 1 regression
Godot_v4.7-stable_win64_console.exe --headless `
  --log-file logs/slice2a-final-phase1-tests.log --path . `
  --script res://tests/run_phase1_tests.gd

# Release-equivalent export
Godot_v4.7-stable_win64_console.exe --headless `
  --log-file logs/slice2a-export.log --path . `
  --export-release "Windows Desktop" build/windows/MFO-Phase1.exe

# Export smoke
MFO-Phase1.exe --headless `
  --log-file logs/slice2a-export-smoke.log --quit-after 5
```

Godot's default self-contained `user://` log location was not writable in this execution environment and caused one
pre-check launch failure. All recorded checks used explicit project-local log paths. Export also printed a non-fatal
ObjectDB snapshot-directory warning while returning exit `0`; the export and packaged smoke completed successfully.
This is recorded as a local tooling observation, not a gameplay Pass substitution.

## 5. Manual and deferred verification

- Interactive KBM feel: **Not run by implementation owner**. Formal manual verification belongs to `30` under the
  work order.
- Physical gamepad: **Not run / Deferred** under `GATE-1-INPUT-EVIDENCE`; mapping automation is not hardware evidence.
- Formal Slice 2-A QA: **Pending `30`**.

## 6. Questions, issues, and contract impact

- New open questions: **None**.
- Existing `OQ-005` remains open; no defeated-state retry input was implemented.
- Product/gameplay defects known at handoff: **None discovered by implementation self-check**.
- Production event or presentation contract impact: **None**.
- `IMPLEMENTATION_STATUS.md` and `MILESTONES.md` were not edited because approval/status integration belongs to
  `00統括`.

## 7. Next safe step

`30 QA・性能・レビュー` validates implementation commit
`bd01fdf3d048accaa7f5be93afe3be5cfa138201` under the Stage B paths in the work order. Slice 2-B, Slice 2-C,
Slice 2-D, and Gate 2 remain locked until QA returns and `00統括` issues the next decision／work order.
