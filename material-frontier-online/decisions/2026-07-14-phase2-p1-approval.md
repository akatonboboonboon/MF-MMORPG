# Phase 2 P1 Baseline Approval

- Decision group: `P2-P1-2026-07-14`
- Status: **Approved**
- Authority: `user_approved`
- Effective date: 2026-07-14 (Asia/Tokyo)
- Scope: Phase 2 prototype baseline and Slice 2-A entry
- Source: user approved the immediately preceding six-item P1 proposal with `OKです。`

This record is an approved overlay. It does not edit the frozen specification files under
`material-frontier-online/specification/`.

## OD-020 — Phase 2 evade

Phase 2 evade is a ground-direction step.

- With nonzero movement input, use that normalized direction; otherwise use the current aim direction.
- Travel distance is `140 px` over `0.20 s`.
- There is no invulnerability window, stamina cost, or evade input buffer.
- The reuse interval is `0.45 s`. Requests while active or before reuse is available are rejected and not queued.
- Gameplay collision and the configured gameplay bounds may shorten the actual travel, but the step must not
  pass through them.
- Lock-on, part lock, auto approach, and attack cancel are outside Phase 2.
- The reserved `lock_on` abstract input remains defined but has no behavior in Phase 2.

This decision does not decide OD-025 or introduce a general stamina resource.

## OD-021 — Phase 2 retry

While the actor is defeated by core `Integrity == 0`, accepting a retry operation returns the actor to
the configured start of the same arena. Local Authority Simulation resets at least position, initial aim,
velocity, and the complete evade runtime state. Checkpoint return and a dedicated retry screen are not part
of Phase 2.

When later slices add `Integrity`, `Deformation`, the single deformation penalty, hit queries, or other
retry-owned runtime state, the existing complete-reset contract still applies; the four fields above do not
limit it.

The abstract action and press／release／held edge used for the future defeated-state retry operation are not
selected by this approval. The decision must also state whether the triggering command consumes its other actions.
These details are tracked as `OQ-005` and must be approved before Slice 2-C connects defeat to player input. Slice 2-A
may implement and test only the authority-owned reset seam; it must not invent a defeat state or input binding.

## OD-026 — Phase 2 persistent HUD

- Always display `Integrity` and `Deformation` once those states exist.
- Display `temperature` only after temperature behavior is implemented.
- Do not display charge before Phase 3.
- HUD state is read-only and cannot change combat state.

Deferring charge display does not select charge as the OD-025 magic resource.

## OD-027 — Single deformation penalty

- At `Deformation >= 60`, reduce ordinary movement speed by `15%`.
- Below `60`, remove that penalty.
- This is the only MVP deformation penalty; threshold and amount are data values.
- It does not modify evade distance or duration, aim, attack speed, or defeat rules.
- Playtest-driven retuning is allowed only with evidence and a recorded tuning or decision change.
- Retry returns `Deformation` to `0` and removes the penalty, as required by the existing reset contract.

## OD-041-P2 — Phase 2 reference camera

Phase 2 uses the existing one-screen reference composition at `1920x1080`, fixed direction, and `zoom 1.0`.
There is no dynamic zoom in Phase 2. Formal player-count framing, boss maximum display size, and boss/stage
camera adjustment remain deferred as `OD-041-POST` and are not Gate 2 blockers.

## OD-043-P2 — Phase 2 minimum readability

- Do not distinguish gameplay information by color alone.
- Player and target use a high-contrast outline.
- Text shown at `1920x1080` is at least `24 px`.
- Phase 2 uses no camera shake.
- The lowest quality setting retains operation targets and any danger display that exists.

Target outline does not imply lock-on or target selection. This baseline does not select production palette,
telegraph pattern, other-resolution scaling, or post-Phase-2 camera shake; those remain `OD-043-POST`.

## Authorization boundary

These decisions satisfy the Phase 2 P1 entry baseline but do not authorize all Phase 2 implementation.
Only work explicitly named by an active `00統括` work order may begin. The first authorization is
[`MFO-WO-P2-2A-001`](../../docs/work-orders/phase2-slice2a-basic-operation.md), limited to Slice 2-A.

Gate 2 remains locked. Physical gamepad validation remains `Not run / Deferred`, and OD-013 is unchanged.

## Slice 2-A deterministic interpretation

For the bounded Slice 2-A work order, `00統括` operationalizes the approved `0.45 s` reuse interval as the
minimum interval between accepted evade starts. This interpretation is recorded separately from the six
user-approved facts so implementation and QA cannot choose different clock origins.
