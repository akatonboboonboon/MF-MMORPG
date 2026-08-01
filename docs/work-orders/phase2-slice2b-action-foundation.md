# MFO-WO-P2-2B-001 — Slice 2-B parallel common-action foundation

- Issuer: `00統括（監督）`
- Issued: 2026-08-01 (Asia/Tokyo)
- Assignee: `10ゲームプレイ・コア実装`
- Status: **Authorized / isolated Stage A only**
- Milestone: M2 / Slice 2-B pre-integration foundation
- Required branch: `codex/phase2-slice2b-action-foundation-gameplay`
- Required workspace: dedicated Git worktree; do not switch the shared QA worktree
- Validation owner: `30 QA・性能・レビュー` only after a separate supervisor validation order
- Integration authority: **None**
- Gate effect: **None** — Gate 2 remains Locked

## 1. Authority and purpose

The user explicitly directed the project to proceed on 2026-08-01. This order uses that authority only to run
work that is independent of unresolved Slice 2-A performance infrastructure and independent of unresolved
Slice 2-B gameplay values. It does not accept Slice 2-A, resolve `MFO-HOLD-P2-2A-001`, approve Gate 2, or authorize
the playable quick-cut／heavy-cleave vertical path.

Implement the smallest reusable combat foundation already fixed by the source specification:

1. data-driven shared action and effect definitions rather than per-move damage classes;
2. fail-closed validation of the unambiguous common fields;
3. reservation-aware hit-query acquisition／release mechanics that protect important reserved capacity and do
   not turn the `50`-query `PrototypeStressTarget` into a hard runtime cap;
4. complete backward compatibility with the Phase 1 and Slice 2-A runtime.

This is a parallel pre-integration Stage A. Production action data, input capture, authority execution, scenes,
and acceptance remain locked for a later work order.

## 2. Starting state and branch isolation

`10` must create the required branch from the supervisor commit that contains this order, using a dedicated Git
worktree outside the shared QA worktree. Record the exact base commit before editing.

- Do not branch from an older implementation commit.
- Do not switch, reset, clean, stash, or otherwise mutate the shared QA worktree.
- Do not push to `main` or the QA branch.
- Return a dedicated implementation commit and a separate handoff commit on the required branch.

If the required supervisor commit, this order, or a clean dedicated worktree cannot be confirmed, stop and return
to `00統括` before editing.

## 3. Authorized paths

Only the following tracked paths may change:

- `material-frontier-online/prototype/scripts/combat/action_definition.gd`
- `material-frontier-online/prototype/scripts/combat/effect_definition.gd`
- `material-frontier-online/prototype/scripts/combat/hit_query_pool.gd`
- `material-frontier-online/implementation/2026-08-01-phase2-slice2b-action-foundation.md`
- `docs/handoffs/gameplay.md`

Godot may regenerate the existing `.uid` sidecars only if their content actually changes as a direct consequence
of importing these same scripts; otherwise they remain unchanged. No new production file or directory is authorized.
Scratch self-check files may be created only under ignored build／temporary output and must not be committed.

## 4. Required implementation

### 4.1 Backward-compatible common definitions

Extend the existing provisional definition classes in place; do not create a second competing action／effect schema
and do not rename the existing public `Phase1*` classes in this stage. Existing Phase 1 resources, exports, methods,
and validation results must remain compatible.

The common action scaffold may add only fields whose meaning is already fixed by the frozen data model:

- stable action ID and category;
- nonnegative `windup_seconds`, `active_seconds`, `recovery_seconds`, and `cooldown_seconds`;
- stable hit-shape and effect-reference IDs without executing them;
- one of the existing reservation classes;
- nonnegative `max_concurrent_hit_queries`;
- stable presentation IDs may be stored but not consumed.

Validation must fail closed for an empty required ID, negative timing, negative maximum query count, invalid
reservation class, duplicate nonempty effect reference, or an otherwise malformed value that the frozen schema
unambiguously rejects. Do not invent resource-cost semantics, load-rank semantics, phase-boundary semantics,
target selection, or production defaults.

The common effect scaffold may store and validate the frozen schema's stable effect ID, effect type, channel,
magnitude, duration, target rule, stack rule, and tags. It must not interpret or apply damage, part damage, heat,
force, status, or any other effect. Do not require positive magnitude because signed effects remain possible;
duration alone must not be negative.

### 4.2 Reservation-aware hit-query foundation

Preserve the current Phase 1 API and behavior used by existing resources and tests. Add an isolated reservation API
whose capacities are injected by the caller and whose recognized classes are at least:

- `PlayerCritical`
- `BossCritical`
- `Environment`
- `LowPriority`

The separate preallocated emergency capacity required by the performance specification may be represented and
audited, but using it must be observable as an error／telemetry condition; the accepted success criterion is zero
emergency use. Low-priority or environment acquisition must never consume PlayerCritical, BossCritical, or emergency
reserved capacity. Do not decide cross-class borrowing beyond what is required to enforce that invariant.

Every successful acquisition must return exactly once. Unknown, duplicate, or already-released tokens must be rejected
without corrupting counts. Reset／clear must leave all active counts at zero and restore configured capacity. Capacity
comes from supplied configuration; never hard-code `50`, reject the 51st query because of the stress target, or convert
the current `PrototypeStressTarget` into a product limit.

This foundation is not connected to action acceptance. It therefore must not consume a cost, start a cooldown, emit
an event, or silently fail an accepted player action.

## 5. Explicitly prohibited scope

- quick-cut／heavy-cleave production `.tres` resources or any production timing, magnitude, reach, shape, target,
  capacity, cooldown, cost, priority, movement, or recovery value;
- interpreting heavy cleave's “large self-load” while `OQ-002` remains Open;
- an action lifecycle state machine, tick-boundary behavior, zero-duration phase behavior, buffering, queueing,
  cancellation, or phase transition policy;
- `InputAdapter`, `InputCommand`, physical input mappings, simultaneous／held／repeat policy, or quick／heavy request wiring;
- `LocalAuthoritySimulation`, `PlayerActor`, provisional attack replacement, hit execution, target mutation, damage,
  part damage, `Integrity`, `Deformation`, defeat, or reset integration;
- `CombatFormDefinition`, action-set selection, material behavior, magic, boss, stage, loot, persistence, network,
  server, account, or future-online abstraction;
- production `DomainEvent`, `ActionStarted`, `HitConfirmed`, presentation payload, VFX, animation, audio, HUD, camera,
  hitstop, or shared contract change;
- `.tscn`, `project.godot`, `data/phase1/**`, `scripts/phase1/**`, presentation paths, QA tests／reports／evidence,
  existing build outputs, or any previous evidence;
- weakening an existing test or changing provisional values merely to make a test pass.

Any requirement outside Section 4, or any interpretation not uniquely determined by approved records, must be returned
to `00統括`; it is not permission to widen this order.

## 6. Implementation checks and acceptance boundary

Before handoff, `10` must:

1. run the existing Phase 1 suite and retain `36 / 36 Pass`;
2. run the existing Slice 2-A suite and retain `120 / 120 Pass`;
3. run the additive correction suite and retain `39 / 39 Pass`;
4. use an untracked isolated self-check to demonstrate definition rejection for empty／negative／invalid／duplicate
   inputs and reservation acquisition／release／reset invariants;
5. demonstrate that PlayerCritical reserved capacity cannot be consumed by LowPriority and that no branch treats
   `50` as a hard cap;
6. run Godot import／parse and a proportionate main-scene headless smoke;
7. run `git diff --check` and prove that only Section 3 paths changed;
8. confirm Phase 1 resource bytes, scenes, project configuration, runtime behavior, QA artifacts, and production data
   are unchanged.

Record exact commands, numeric exits, assertion totals, scratch self-check identity, changed paths, and all Not run
items in the implementation report and `docs/handoffs/gameplay.md`.

Completion of these checks means only **implementation ready for supervisor review**. It is not QA acceptance. `10`
must stop after push and must not connect the foundation to input, simulation, data, or scenes.

## 7. Return routing

Return to `00統括` with:

- base, implementation, and handoff commits;
- required branch and local／origin equality;
- exact changed paths;
- relied-on decisions and unresolved questions preserved;
- all command results and deferred checks;
- confirmation of no runtime／scene／input／event integration.

After review, `00統括` may issue a separate `30` validation order. Playable Slice 2-B Stage B requires separate
approval of timing, direction, input-conflict, hit-shape／effect values, `OQ-002`, and single-owner integration paths.
No automatic follow-on is authorized.
