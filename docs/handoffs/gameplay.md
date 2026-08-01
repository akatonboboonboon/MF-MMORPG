# Gameplay / Core Handoff

- Owner role: `10ゲームプレイ・コア実装`
- Updated by `10ゲームプレイ・コア実装`: 2026-08-01
- Current milestone: M2 / Slice 2-B isolated Stage A
- Authorization: `MFO-WO-P2-2B-001` listed non-connected foundation scope and exact paths only
- Phase 1 code baseline: `a13505e8fbf82962e049b9101a87593a6692d2c7`
- Required starting state: `dd36e7e8d3c2e3ad7c5db74a056fe0694027a564`

## Read before work

- [`../../AGENTS.md`](../../AGENTS.md)
- [`../MASTER_SPEC.md`](../MASTER_SPEC.md)
- [`../DECISIONS.md`](../DECISIONS.md)
- [`../MILESTONES.md`](../MILESTONES.md)
- [`../ASSET_CONTRACTS.md`](../ASSET_CONTRACTS.md)
- [`../OPEN_QUESTIONS.md`](../OPEN_QUESTIONS.md)

## Current vertical path

```text
InputAdapter
→ InputCommand (actor_entity_id / optional target_entity_id)
→ LocalAuthoritySimulation (one-entry Actor collection)
→ PlayerActor / provisional HitQuery
→ DomainEvent (command tick preserved)
→ DebugHUD / placeholder presentation
```
36 assertions、判定予約・返却、KBM mapping、gamepad mapping、照準所有権、stable ID、未知Actor拒否、
command tick、target ID、命中／非命中、RHL startup recordはPhase 1報告上Pass。

## Current allowed work

- Active work order: [`../work-orders/phase2-slice2b-action-foundation.md`](../work-orders/phase2-slice2b-action-foundation.md)
- Approved／frozen sources: `docs/DECISIONS.md`、`docs/MASTER_SPEC.md`、
  `specification/06-data-model.md`、`specification/08-performance-budget.md`
- work order Section 3のcombat 3 files、指定implementation report、このhandoffだけ
- 後方互換common Action／Effect scaffoldとfail-closed validation
- 非接続reservation-aware hit-query foundation。capacityはcaller注入、emergency使用はobservable error telemetry
- 既存Phase 1／Slice 2-A／correction test、import／parse、main smoke、禁止path不変確認

`10`はproduction data、QA test file、scene、project.godot、input／authority、damage、event、camera、
presentation、shared contractを変更しない。曖昧さを見つけた場合は該当実装を止め、OPEN_QUESTIONSへ戻す。

## Do not start

- 仮攻撃Aを正式な快斬／重断へ置換、production action data、action lifecycle、hit-query runtime接続
- `Integrity`／`Deformation`、core装備、damage、defeat、retry input binding
- lock-on、part lock、auto approach、iframe、stamina、evade buffer
- HUD、production DomainEvent、VFX、camera、asset integration
- 3素材、3魔法、boss、parts、stage、gimmicks、loot
- network、account、persistence

Stage Aを完了してもplayable Stage Bへ自動着手しない。`30`検証と`00`の受理後、新work orderを待つ。

## Boundaries to preserve

- stable actor/target ID、command sequence／physics tick
- InputCommandは要求であり、発動可否はauthority simulationが決める
- player-critical queryを予約し、取得後に必ず返却
- accepted actionをpool不足で不発にしない
- simulationだけがgameplay resultを決める
- PresentationへはDomainEvent／read-only stateを渡す

## Blocking decisions

- Deferred Playability evidence: GQ-004
- Slice 2-C retry input: OQ-005
- Slice 2-B: OQ-002 and action timing values
- Presentation契約: OQ-001、OQ-004

決めずにコードへ埋め込まない。

## Required handoff update

作業終了時にこの節を置換または追記する。

```text
Status:
Milestone / authorization:
Base and resulting commit:
Files changed:
Behavior changed:
Decisions relied on:
Tests run and exact result:
Evidence paths:
Open questions added:
Known issues added:
Cross-role contract impact:
Next safe step:
```

## Slice 2-A implementation return — 2026-07-14

Status: **Implementation complete / QA validation pending**

Milestone / authorization: M2 / Slice 2-A, `MFO-WO-P2-2A-001`

Base and resulting commit:

- Base: `afcd20cd4a02d618a5d7e0e4bc7555a64fa90740`
- Implementation: `bd01fdf3d048accaa7f5be93afe3be5cfa138201`

Files changed:

- `material-frontier-online/prototype/scripts/input/input_adapter.gd`
- `material-frontier-online/prototype/scripts/simulation/input_command.gd`
- `material-frontier-online/prototype/scripts/simulation/local_authority_simulation.gd`
- `material-frontier-online/prototype/scripts/simulation/player_actor.gd`
- `material-frontier-online/implementation/2026-07-14-phase2-slice2a-basic-operation.md`
- `docs/handoffs/gameplay.md`

Behavior changed:

- Fresh Space／gamepad A abstract `evade` press is carried as an `InputCommand` request.
- Authority accepts movement-priority／neutral-aim-fallback ground step at `140 px / 0.20 s` with `0.45 s`
  accepted-start reuse and no queued request.
- Active step ignores ordinary locomotion distance while retaining independent aim.
- Existing collision／movement bounds can shorten the step without penetration.
- Callable same-arena reset restores configured position／aim and clears velocity plus complete evade runtime state.
- No production event, presentation integration, retry binding, or forbidden gameplay system was added.

Decisions relied on: OD-001, OD-013, OD-020, OD-021. OD-026／OD-027 were not implemented.

Tests run and exact result:

- Unmodified baseline Phase 1 suite: `36 / 36 Pass`, exit `0` after explicit local log path.
- Final import／parse: Pass, exit `0`.
- Final Phase 1 suite: `36 / 36 Pass`, exit `0`; no expectation changed.
- Temporary ignored implementation self-check: `25 / 25 Pass`, exit `0`; harness removed, formal QA still pending.
- Windows release export: Pass, exit `0`.
- Exported EXE headless smoke: Pass, exit `0`.

Evidence paths:

- Implementation report:
  `material-frontier-online/implementation/2026-07-14-phase2-slice2a-basic-operation.md`
- Local ignored logs: `material-frontier-online/prototype/logs/slice2a-*.log`
- Formal QA evidence: pending `30`; implementation logs are not substituted for QA evidence.

Open questions added: None. Existing `OQ-005` remains open and no retry input binding was implemented.

Known issues added: None. Explicit `--log-file` was required because the default self-contained `user://` log path
was not writable in this environment; report records the observation.

Cross-role contract impact: None. No `DomainEvent`, `ASSET_CONTRACTS.md`, scene, camera, HUD, VFX, or asset change.

Next safe step: `30` validates implementation commit `bd01fdf3d048accaa7f5be93afe3be5cfa138201`; then `00統括`
accepts or returns Slice 2-A. Do not start Slice 2-B／2-C／2-D without a new work order.

## Slice 2-A bounded correction return — 2026-07-14

Status: **Correction implemented / fresh QA revalidation pending**

Milestone / authorization: M2 / Slice 2-A, `MFO-WO-P2-2A-002`

Base and resulting commit:

- Base: `295549373fbb3b39deb6079172783ce62c7da532`
- Correction implementation: `5261a73707daca03cb160e03a12247886d3f5cce`

Files changed:

- `material-frontier-online/prototype/scripts/simulation/local_authority_simulation.gd`
- `material-frontier-online/prototype/scripts/simulation/player_actor.gd`
- `material-frontier-online/implementation/2026-07-14-phase2-slice2a-nonzero-direction-correction.md`
- `docs/handoffs/gameplay.md`

Behavior changed:

- Authority movement-to-aim fallback now occurs only for exact `Vector2.ZERO` movement.
- Actor evade start rejects only exact `Vector2.ZERO`; all post-deadzone nonzero directions are normalized and
  accepted when the existing authority guard permits the step.
- `_DIRECTION_EPSILON_SQUARED`, input/deadzone, step values, aim/reset, collision/bounds, `MovementApplied`, events,
  and scenes are unchanged.

Decisions relied on: OD-001, OD-013, OD-020, OD-021 and bounded work order `MFO-WO-P2-2A-002`.

Tests run and exact result:

- `git diff --check`: Pass, exit `0`.
- Existing Phase 1 suite: `36 / 36 Pass`, exit `0`.
- Unmodified existing `run_slice2a_tests.gd`: `120 / 120 Pass`, exit `0`.
- Godot import／parse: Pass, exit `0`; non-fatal `user://` ObjectDB snapshot-directory warning recorded.
- QA test source comparison against starting commit: unchanged, exit `0`; SHA-256
  `03ecfbd34bfb98333d9bdeff5c6ef90cb477090101ea6e4435511509c1e6e91a`.

Evidence paths:

- Correction report:
  `material-frontier-online/implementation/2026-07-14-phase2-slice2a-nonzero-direction-correction.md`
- Local ignored logs: `material-frontier-online/prototype/logs/slice2a-correction-*.log`
- Fresh formal QA evidence: pending `30`.

Open questions added: None. Existing `OQ-005` remains open and unchanged.

Known issues added: None. The correction addresses `KI-009`; formal closure remains pending fresh QA.

Cross-role contract impact: None. No QA source/report/evidence, production event, presentation contract, scene,
camera, HUD, VFX, or asset was changed.

Next safe step: `30` revalidates correction commit `5261a73707daca03cb160e03a12247886d3f5cce`; then `00統括`
accepts or returns Slice 2-A. Historical return retained; the active boundary is the Stage A section below.

## Slice 2-B isolated Stage A implementation return — 2026-08-01

Status: **Implementation ready for supervisor review / formal QA validation pending**

Milestone / authorization: M2 / Slice 2-B isolated Stage A, `MFO-WO-P2-2B-001`

Base and resulting commit:

- Base: `dd36e7e8d3c2e3ad7c5db74a056fe0694027a564`
- Implementation: `0f705eeba3554d1f52b7402bb625ca8a86dd1560`
- Handoff: separate commit containing this section; exact hash is returned to `00統括`

Files changed:

- `material-frontier-online/prototype/scripts/combat/action_definition.gd`
- `material-frontier-online/prototype/scripts/combat/effect_definition.gd`
- `material-frontier-online/prototype/scripts/combat/hit_query_pool.gd`
- `material-frontier-online/implementation/2026-08-01-phase2-slice2b-action-foundation.md`
- `docs/handoffs/gameplay.md`（this separate handoff commit only）

Behavior changed:

- Existing `Phase1ActionDefinition`／`Phase1EffectDefinition` APIs and legacy validation remain compatible.
- Common action fields store stable category／timings／hit-shape／effect／reservation／presentation IDs and reject
  unambiguously malformed values without executing them.
- Common effect fields store signed magnitude, nonnegative duration, rule IDs, and tags without applying any effect.
- Caller-injected reservation classes isolate PlayerCritical／BossCritical from Environment／LowPriority.
- Emergency capacity is explicit, preallocated, restricted to critical classes, and observable through nonzero-use telemetry.
- Unique monotonic lease tokens reject unknown／duplicate／released／stale releases without corrupting counts.
- No literal `50` cap; the isolated self-check acquires and returns 51 caller-injected slots.
- No action acceptance、input、simulation、hit、damage、data、scene、event、presentation、integration was connected.

Decisions relied on:

- OD-003 and OD-008 only within this Stage A boundary.
- `docs/MASTER_SPEC.md` common definition／performance boundaries.
- Frozen data-model §5.5／§5.6／§9 and performance-budget §1／§7.
- Exact authority remains `MFO-WO-P2-2B-001`; no decision record was edited.

Tests run and exact result:

- Godot version: `4.7.stable.official.5b4e0cb0f`, exit `0`.
- Final import／parse: Pass, exit `0`.
- Ignored isolated self-check: `149 / 149 Pass`, exit `0`; SHA-256
  `470973604169FF718E3592F7644F2C3BFDDBB681F6EAEE1C49DA46C5FF0CA57F`.
- Existing Phase 1: `36 / 36 Pass`, exit `0`.
- Existing Slice 2-A: `120 / 120 Pass`, exit `0`.
- Existing Slice 2-A correction: `39 / 39 Pass`, exit `0`.
- Main scene headless smoke, `--quit-after 120`: Pass, exit `0`; definition validation／RHL violation `0`.
- `git diff --check`: Pass, exit `0`.
- UID SHA-256 values: unchanged for all three existing combat sidecars.
- Phase 1 data、scene、`project.godot`、runtime paths、QA tests／reports: baseから変更なし、exit `0`.
- Initial self-check compile preflight: exit `1` due Variant inference warning; corrected with an explicit `int`
  annotation and not counted as Pass.

Evidence paths:

- Implementation report:
  `material-frontier-online/implementation/2026-08-01-phase2-slice2b-action-foundation.md`
- Local ignored logs: `material-frontier-online/prototype/logs/slice2b-stagea-*-final.log`
- Formal QA evidence: pending a separate `30` work order; implementation logs do not substitute for QA evidence.

Open questions added: None. OQ-002、OQ-005、その他既存OQ remain open／unchanged and were not interpreted.

Known issues added: None. Existing Slice 2-A performance HOLD remains unchanged.

Cross-role contract impact: None. No `ASSET_CONTRACTS.md`、production `DomainEvent`、scene、HUD、VFX、
animation、audio、camera、asset change.

Not run / Deferred:

- Formal `30 QA` validation、performance acceptance／P95／A-B-C、physical gamepad、release export.
- Production action values／resources、lifecycle、input conflict、authority execution、hit shape／effect resolution、
  damage、Integrity／Deformation、data／scene／event／presentation integration.

Next safe step: `00統括` reviews implementation commit `0f705eeba3554d1f52b7402bb625ca8a86dd1560`
and this handoff commit, then may issue a separate `30` validation order. Do not start Stage B or connect this
foundation without a new work order.

## Slice 2-B isolated Stage B action-kernel return - 2026-08-02

Status: **Implementation ready for supervisor review / formal QA validation pending**

Milestone / authorization: M2 / Slice 2-B isolated Stage B, `MFO-WO-P2-2B-007`

Current-state override:

- Required starting state: `29432cfd5a3eb32dfc290915d72d39b077715623`
- Active work order: `docs/work-orders/phase2-slice2b-stageb-action-kernel.md`
- The Stage A current-state header above is historical; this latest return is the active handoff state.

Base and resulting commit:

- Base: `29432cfd5a3eb32dfc290915d72d39b077715623`
- Implementation: `30b090481a9fffd123d5b16537886e5011fd7e51`
- Handoff: separate commit containing this section; exact hash is returned to the supervisor.

Files changed:

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
- `docs/handoffs/gameplay.md` (this separate handoff commit only)

Behavior changed:

- Existing Phase 1 and Stage A definition APIs remain backward compatible.
- The partial blade one-hand CombatForm validates exactly quick cut, heavy cleave, and their four physical effects.
- Approved quick/heavy timings, geometry, aim rules, `48 px` heavy intent, and `10 / 6 / 14 / 18` magnitudes are stored and fail-closed validated.
- The non-connected `RefCounted` runtime advances exactly idle/windup/active/recovery, reserves before acceptance, invokes one immutable callback request, and releases every accepted lease.
- Busy/unknown/invalid/unavailable requests reject without queue; emergency capacity remains unused.
- An invalidated callback during windup normalizes to malformed and still releases its lease.
- No input, authority, actor, target, scene, hit execution, damage, event, presentation, or integration was connected.

Decisions relied on:

- Approved `P2-2B-P1-2026-08-01` values and exact technical normalization in `MFO-WO-P2-2B-007`.
- OQ-002 is closed for this bounded package. No broader behavior was inferred.

Tests run and exact result:

- Godot version: `4.7.stable.official.5b4e0cb0f`, exit `0`.
- Final import/parse: Pass, exit `0`.
- Ignored additive Stage B self-check: `309 / 309 Pass`, exit `0`; SHA-256 `58BEC687938C7ECCD8F47D667A282A65A8DAB106A4BE6785799CEB32462DE0B3`.
- Existing corrected Stage A: `71 / 71 Pass`, exit `0`.
- Existing Phase 1: `36 / 36 Pass`, exit `0`.
- Existing Slice 2-A: `120 / 120 Pass`, exit `0`.
- Existing Slice 2-A correction: `39 / 39 Pass`, exit `0`.
- Main scene headless smoke, `--quit-after 120`: Pass, exit `0`; definition validation and RHL violation `0`.
- `git diff --check`: Pass, exit `0`.
- Existing QA runner SHA-256 values and three pre-existing combat UID sidecars remain unchanged.
- The implementation report records scratch-only intermediate invalid runs; none is counted as Pass.

Evidence paths:

- Implementation report: `material-frontier-online/implementation/2026-08-01-phase2-slice2b-stageb-action-kernel.md`
- Ignored scratch self-check: `material-frontier-online/prototype/build/stageb-self-check/run_stageb_action_kernel_self_check.gd`
- Formal QA report/evidence: Not run; requires a separate `30` work order.

Open questions added: None. `OQ-005` and unrelated existing questions remain unchanged.

Known issues added: None. Existing Slice 2-A performance HOLD and Gate 2 Locked remain unchanged.

Cross-role contract impact: None. No `ASSET_CONTRACTS.md`, production `DomainEvent`, scene, HUD, VFX, animation, audio, camera, or asset change.

Not run / Deferred:

- Formal `30 QA`, release export, exported smoke, physical gamepad/user-feel.
- Slice 2-A performance/PREACK/performance matrix and Gate 2 acceptance.
- Input/authority/actor/target/scene/hit/damage/part state/Integrity/Deformation/event/presentation/integration.

Next safe step: the supervisor reviews implementation commit `30b090481a9fffd123d5b16537886e5011fd7e51` and this handoff commit, then may issue a separate `30` validation order. Do not start QA, integration, Slice 2-C, or Gate 2 work without a new explicit order.
