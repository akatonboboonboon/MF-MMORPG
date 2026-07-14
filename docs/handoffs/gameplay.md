# Gameplay / Core Handoff

- Owner role: `10ゲームプレイ・コア実装`
- Updated by supervisor: 2026-07-14
- Current milestone: M2 / Slice 2-A
- Authorization: `MFO-WO-P2-2A-002` listed correction scope and paths only
- Phase 1 code baseline: `a13505e8fbf82962e049b9101a87593a6692d2c7`
- Required starting state: commit containing the active work order; record exact `HEAD` before editing

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

- Active work order: [`../work-orders/phase2-slice2a-nonzero-direction-correction.md`](../work-orders/phase2-slice2a-nonzero-direction-correction.md)
- Approved decision source: [`../../material-frontier-online/decisions/2026-07-14-phase2-p1-approval.md`](../../material-frontier-online/decisions/2026-07-14-phase2-p1-approval.md)
- work orderが列挙するsimulation 2 files、指定correction report、このhandoffだけ
- evade方向のexact-zero判定だけを是正し、共有epsilonと既存挙動を維持
- 既存Phase 1／Slice 2-A test、import／parse、QA source不変確認

`10`はQA test file、scene、project.godot、camera、presentation、shared contractを変更しない。曖昧さを
見つけた場合は該当実装を止め、OPEN_QUESTIONSへ戻す。

## Do not start

- 仮攻撃Aを正式な快斬／重断へ置換、仮攻撃／hit queryの変更
- `Integrity`／`Deformation`、core装備、damage、defeat、retry input binding
- lock-on、part lock、auto approach、iframe、stamina、evade buffer
- HUD、production DomainEvent、VFX、camera、asset integration
- 3素材、3魔法、boss、parts、stage、gimmicks、loot
- network、account、persistence

2-Aを完了しても2-Bへ自動着手しない。`30`検証と`00`のslice受理後、新work orderを待つ。

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
accepts or returns Slice 2-A. Do not start Slice 2-B／2-C／2-D without a new work order.
