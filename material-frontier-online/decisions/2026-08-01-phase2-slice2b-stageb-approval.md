# Phase 2 Slice 2-B Stage B P1 Approval

- Decision ID: `P2-2B-P1-2026-08-01`
- Status: **Approved**
- Authority: `user_approved` for the visible recommendation; `supervisor_normalization` for exact phase/input/technical decomposition; `supervisor_determination` for work-order ownership and integration boundaries
- Approved: 2026-08-01 (Asia/Tokyo)
- Scope: Slice 2-B quick-cut / heavy-cleave P1 action-feel and isolated action-kernel implementation
- Gate effect: **None**; Gate 2 remains Locked

## 1. Preserved decisions

This approval concretizes OD-008 and OD-016 without changing their roles:

- `action.physical.quick_cut` remains the short, direction-correctable, low-to-medium damage action.
- `action.physical.heavy_cleave` remains the committed, high-part-damage action with a small forward movement and large self-load.
- both actions use the one shared `combat_form.blade.one_hand.prototype` and the common action / effect / query systems;
- no action-specific damage class, material-specific player class, new resource meter, lock-on, auto approach, attack cancel, or future-online abstraction is approved.

## 2. Approved P1 action values

| Field | Quick cut | Heavy cleave |
|---|---:|---:|
| `windup_seconds` | `0.10` | `0.40` |
| `active_seconds` | `0.10` | `0.10` |
| `recovery_seconds` | `0.20` | `0.50` |
| `cooldown_seconds` | `0.00` | `0.00` |
| Normal physical damage | `10` | `14` |
| Physical part damage | `6` | `18` |
| `reach` | `150 px` | `150 px` |
| Query radius | `88 px` | `88 px` |
| Minimum aim dot | `0.25` | `0.25` |
| Maximum targets | `1` | `1` |
| Maximum concurrent hit queries | `1` | `1` |
| Reservation class | `PlayerCritical` | `PlayerCritical` |

The user approved the total durations (`0.40 s` quick / `1.00 s` heavy), damage values, aim behavior, `48 px` heavy movement, recovery-only self-load, and the input principles of no buffering, no held repeat, no attack cancel, and evade priority. The exact 60 Hz-aligned phase split, established Phase 1 geometry reuse, fresh-press/no-queue/busy-reject mechanics, heavy-over-quick tie-break, and preservation of the existing LT modifier precedence are supervisor normalization within those approved principles. These are initial P1 values, not a claim that later user-feel tuning is complete. Any change requires a later Approved decision and must not be hidden inside implementation or QA.

## 3. Aim, motion, and phase policy

- Quick cut follows the latest nonzero aim during windup and locks its direction when active begins.
- Heavy cleave locks its direction when the authority accepts the action.
- Heavy cleave requests `48 px` of forward movement. Supervisor normalization places that request across the active phase. Later actor integration must apply it through collision-aware movement and gameplay bounds; collision or bounds may shorten it. It must not track a target or auto-approach.
- Phase durations use authority simulation time. At the 60 Hz reference step, quick cut is nominally `6 / 6 / 12` ticks and heavy cleave is `24 / 6 / 30` ticks for windup / active / recovery.
- A hit query may execute only during the active phase. The first isolated-kernel work order uses one query callback per accepted action as a bounded supervisor implementation rule; a later Approved decision is required to broaden multi-hit behavior.

Ordinary locomotion interaction during an action is not added by the first isolated kernel order. It must be fixed explicitly by the later actor / scene integration order rather than inferred here.

## 4. Input and conflict policy

- User-approved behavior excludes held-repeat and input buffering. Supervisor normalization uses fresh press edges only (`just_pressed`) and adds no action queue.
- Supervisor normalization rejects requests while an action is busy and does not replay them later.
- Existing input-contract precedence is preserved: holding the magic modifier reserves X/Y for magic and suppresses the physical request; Slice 2-B does not implement magic.
- The user-approved principle is evade priority. Supervisor normalization resolves otherwise eligible same-idle-tick requests as exactly one of `evade > heavy cleave > quick cut`.
- The user-approved no-attack-cancel principle means an attack does not cancel evade and evade does not cancel an accepted attack.

The first isolated action-kernel order does not edit `InputAdapter`, `InputCommand`, actor movement, or a scene. These policies become implementation requirements when a later explicit integration order assigns those paths.

## 5. Effect and self-load decision

- Quick cut resolves common `Damage(physical)=10` plus `PartDamage(physical)=6`.
- Heavy cleave resolves common `Damage(physical)=14` plus `PartDamage(physical)=18`.
- Neither action adds knockback, status, heat, Deformation, or another effect in Slice 2-B.
- OQ-002 is closed for Slice 2-B: heavy cleave's large self-load is represented only by its `0.50 s` recovery. Its longer windup remains part of move identity, not an additional self-load effect. It does not add Deformation.
- Damage and PartDamage may be recorded and validated by the isolated action kernel, but must not mutate production `Integrity`, `Deformation`, or part state before Slice 2-C assigns that authority.

## 6. CombatForm and integration boundary

- `combat_form.blade.one_hand.prototype` may contain quick cut and heavy cleave as the Phase 2 partial action set. Phase 3 magic actions are not required for this Slice 2-B definition.
- The first implementation is an isolated, headless action kernel and data package. It does not replace the Phase 1 provisional attack and does not connect input, actor movement, damage state, a shared scene, production events, or presentation.
- A later integration order must use a new Slice 2-B-owned scene assigned solely to `10`; it must not implicitly rewrite the shared Phase 1 arena.
- Production `ActionStarted` / `HitConfirmed` payloads and presentation remain deferred to Slice 2-D and OQ-001 / OQ-004. Debug-only audit results are not production contracts.

## 7. Immediate implementation sequence

1. Implement and validate the partial CombatForm, action data, effect data, and isolated authority-time action runtime.
2. Validate phase boundaries, aim policy, one-query behavior, reservation-before-acceptance, release on all exits, effect result records, reset, and zero emergency use without scene or target-state mutation.
3. Return for separate QA.
4. Only after that QA may a new work order connect input, actor collision-aware movement, the isolated scene, and manual feel verification.

Gate 2, Slice 2-C, Slice 2-D, performance acceptance, physical-gamepad Pass, and integration remain unauthorized by this decision alone.
