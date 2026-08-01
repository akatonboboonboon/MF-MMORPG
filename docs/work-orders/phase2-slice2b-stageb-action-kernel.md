# MFO-WO-P2-2B-007 — Slice 2-B isolated action kernel

- Issuer: `00統括（監督）`
- Issued: 2026-08-01 (Asia/Tokyo)
- Assignee: `10ゲームプレイ・コア実装`
- Status: **Authorized / isolated Stage B action kernel only**
- Milestone: M2 / Slice 2-B
- Required starting point: the supervisor commit containing this order; its exact hash is supplied in the direct START notice
- Required branch: `codex/phase2-slice2b-stageb-action-kernel-gameplay`
- Required workspace: dedicated clean Git worktree; do not switch or mutate shared QA worktrees
- Decision basis: `P2-2B-P1-2026-08-01`
- Validation owner: `30 QA・性能・レビュー` only after a separate supervisor validation order
- Integration authority: **None**
- Gate effect: **None** — Gate 2 remains Locked

## 1. Objective

Implement the smallest authority-time kernel and data package that makes the approved quick-cut / heavy-cleave behavior executable in isolation without connecting physical input, an actor, a scene, production damage state, events, or presentation.

The returned implementation must provide:

1. one partial `combat_form.blade.one_hand.prototype` containing the two approved physical actions;
2. approved quick-cut / heavy-cleave action and common effect resources;
3. one reusable action runtime with deterministic windup / active / recovery progression;
4. reservation-before-acceptance, exactly one active-phase query callback, complete release / reset behavior, and zero emergency use;
5. immutable debug result records for later authority / QA consumption, without production state mutation.

## 2. Starting state and repository discipline

Create the required branch from the exact supervisor commit supplied in the direct START notice. Record base, implementation, and handoff commits.

- Use a dedicated worktree such as `C:\tmp\m2b-stageb`; do not switch, reset, stash, clean, or otherwise mutate `C:\tmp\q2b` or another role's worktree.
- Do not push to `main`, a QA branch, or the previous Stage A branch.
- Return one implementation commit followed by one gameplay-handoff commit.
- Stop before editing if the decision record, this order, required base, or clean worktree cannot be confirmed.

## 3. Authorized tracked paths

Only these paths may change or be created:

- `material-frontier-online/prototype/scripts/combat/action_definition.gd`
- `material-frontier-online/prototype/scripts/combat/effect_definition.gd`
- `material-frontier-online/prototype/scripts/combat/combat_form_definition.gd`
- `material-frontier-online/prototype/scripts/combat/combat_form_definition.gd.uid`
- `material-frontier-online/prototype/scripts/combat/action_runtime.gd`
- `material-frontier-online/prototype/scripts/combat/action_runtime.gd.uid`
- `material-frontier-online/prototype/data/phase2/combat_forms/blade_one_hand_prototype.tres`
- `material-frontier-online/prototype/data/phase2/actions/quick_cut.tres`
- `material-frontier-online/prototype/data/phase2/actions/heavy_cleave.tres`
- `material-frontier-online/prototype/data/phase2/effects/quick_cut_damage.tres`
- `material-frontier-online/prototype/data/phase2/effects/quick_cut_part_damage.tres`
- `material-frontier-online/prototype/data/phase2/effects/heavy_cleave_damage.tres`
- `material-frontier-online/prototype/data/phase2/effects/heavy_cleave_part_damage.tres`
- `material-frontier-online/implementation/2026-08-01-phase2-slice2b-stageb-action-kernel.md`
- `docs/handoffs/gameplay.md`

No other `.uid`, test, scene, input, simulation, actor, project, contract, status, or evidence path is assigned. Scratch checks may exist only under ignored `prototype/build/` or an external temporary directory and must not be committed.

## 4. Required behavior

### 4.1 Backward-compatible definitions

Preserve all Phase 1 resources, public legacy exports, legacy validation results, and the validated Stage A API. Extend the common scaffold only as required to store and validate the Approved decision:

- aim policy (`follow_windup_then_lock` or `lock_on_accept`);
- nonnegative forward movement intent in pixels;
- existing reach, query radius, minimum aim dot, max targets, max concurrent queries, reservation class, timing, and effect references;
- common effects with exact type, `physical` channel, finite magnitude, zero duration, `hit_target`, `instant`, and empty tags.

Fail closed for malformed or non-finite values, unknown policies, invalid reservation class, duplicate IDs / references, unknown effect references, or action references outside the form. Do not rename the existing `Phase1*` classes or create a competing schema.

### 4.2 Exact approved data

Implement exactly the values in `P2-2B-P1-2026-08-01`:

- quick cut `0.10 / 0.10 / 0.20 / 0.00`, follow aim through windup then lock, no forward intent, Damage `10`, PartDamage `6`;
- heavy cleave `0.40 / 0.10 / 0.50 / 0.00`, lock aim on acceptance, `48 px` forward intent during active, Damage `14`, PartDamage `18`;
- both use reach `150`, radius `88`, minimum aim dot `0.25`, max targets `1`, max concurrent queries `1`, and `PlayerCritical`;
- no knockback, status, Deformation, heat, cooldown cost, resource cost, animation, VFX, SFX, or production event reference.

Technical bindings for this isolated package are supervisor normalization and must be exact:

- `hit_shape_id = hit_shape.physical.prototype.safe_circle` for both actions;
- quick `effect_ids`, in order: `effect.physical.quick_cut.damage`, `effect.physical.quick_cut.part_damage`;
- heavy `effect_ids`, in order: `effect.physical.heavy_cleave.damage`, `effect.physical.heavy_cleave.part_damage`;
- each effect uses `channel = physical`, `duration = 0`, `target_rule = hit_target`, `stack_rule = instant`, and empty tags;
- effect types are `damage` and `part_damage` matching the IDs and magnitudes above;
- legacy `effect` remains null and presentation reference IDs remain empty for these resources.

The partial CombatForm stores exactly the two action IDs. It does not store effect IDs; the isolated runtime registry resolves the four effect resources referenced by the actions.

### 4.3 Isolated action runtime

The runtime must be independent of `Node`, physics world, input devices, scenes, and target classes. It may use `RefCounted` and caller-injected definitions / query callback.

- States are exactly idle, windup, active, and recovery.
- An unknown action, malformed definition, busy runtime, invalid aim, or unavailable PlayerCritical reservation rejects before acceptance and produces no delayed action.
- Reserve PlayerCritical capacity before accepting. Do not use emergency capacity on the success path.
- Authority simulation time advances phases. Handle a delta that reaches one or more boundaries deterministically; do not lose or duplicate the active entry.
- Quick cut accepts updated nonzero aim while in windup and locks at active entry. Heavy cleave locks normalized aim on acceptance.
- Invoke the caller-injected query callback exactly once on active entry with an immutable request containing action ID, locked aim, geometry, max targets, effect records, and forward-movement intent. The callback must not receive or mutate production actor / target state in this order.
- Release the lease after callback completion on hit, miss, callback rejection, or malformed result. Reset / clear before active must also release it. Unknown, duplicate, or stale release must not corrupt the pool.
- Finish recovery at idle with no pending query, lease, result, or movement intent.
- Expose read-only debug state / result data sufficient to verify phase, elapsed time, locked aim, accepted sequence, query count, effects, requested forward movement, release result, and active / emergency query counts.

Use the existing reservation API. Do not modify `hit_query_pool.gd` under this order.

### 4.4 CombatForm validation

The partial form contains exactly quick cut and heavy cleave. The isolated registry contains exactly their four effect definitions. Validate nonempty stable IDs, duplicate action / effect IDs, unknown effect references, action category, reservation class, and the expected two-action membership. Do not require Phase 3 magic actions and do not add material behavior.

## 5. Explicitly prohibited

- `InputAdapter`, `InputCommand`, `LocalAuthoritySimulation`, `PlayerActor`, `TargetDummy`, provisional Phase 1 attack, or any `.tscn` / `project.godot` edit;
- actor locomotion suppression, collision / bounds application of the 48 px intent, hit execution in a physics world, damage / part state mutation, `Integrity`, `Deformation`, defeat, retry, or Slice 2-C behavior;
- production `ActionStarted`, `HitConfirmed`, `DomainEvent`, contract, animation, VFX, audio, HUD, camera, hitstop, or Presentation work;
- action queue, buffer, held repeat, cancellation, cooldown / stamina / resource system, lock-on, part lock, target tracking, auto approach, knockback, status, heat, or magic;
- per-action damage classes, material-specific player classes, online / rollback / server abstraction, broad refactor, legacy class rename, old evidence mutation, or weakening tests;
- Stage A artifact repair, Slice 2-A performance / PREACK, Stage B scene integration, Gate 2, Slice 2-C, or Slice 2-D.

If implementation requires a prohibited path or a choice not fixed by the Approved decision, stop and return to `00統括`; do not infer it.

## 6. Implementation verification

Before handoff, `10` must run and record:

1. Godot 4.7 exact version and import / parse;
2. an ignored additive self-check for form / data validation and runtime behavior;
3. exact 60 Hz phase boundaries: quick `6 / 6 / 12`, heavy `24 / 6 / 30` nominal ticks;
4. quick aim follow / lock and heavy acceptance lock;
5. busy / unknown / invalid / unavailable-reservation rejection with no queue;
6. reservation-before-acceptance, query callback exact once, hit / miss / callback-reject / reset release, final active count `0`, emergency use `0`;
7. exact effect and geometry payloads including heavy `48 px` intent without actor movement;
8. existing corrected Stage A runner `71 / 71`, Phase 1 `36 / 36`, Slice 2-A `120 / 120`, correction `39 / 39`;
9. main-scene headless smoke, proving the unchanged Phase 1 scene still starts;
10. `git diff --check`, exact changed-path audit, nonignored-untracked audit, and proof that all prohibited paths / prior evidence are unchanged.

Release export and physical-gamepad / user-feel checks are Not run in this isolated headless order. They are not failures and must not be reported as Pass.

## 7. Return and stop boundary

Return to `00統括` with:

- base, implementation, and handoff commits;
- local / origin equality and clean worktree;
- exact changed paths and new UID identities;
- self-check identity, assertion total, all command exits, regressions, and Not run items;
- confirmation that input / actor / target / scene / production events / presentation / damage state remain unconnected.

Stop after push. No automatic QA, integration, scene, Stage 2-C, or Gate 2 follow-on is authorized. `00統括` will review and, if appropriate, issue a separate `30` validation order.
