# Gameplay / Core Handoff

- Owner role: `10ゲームプレイ・コア実装`
- Updated by supervisor: 2026-07-14
- Current milestone: M2 / Slice 2-A
- Authorization: `MFO-WO-P2-2A-001` listed scope and paths only
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

- Active work order: [`../work-orders/phase2-slice2a-basic-operation.md`](../work-orders/phase2-slice2a-basic-operation.md)
- Approved decision source: [`../../material-frontier-online/decisions/2026-07-14-phase2-p1-approval.md`](../../material-frontier-online/decisions/2026-07-14-phase2-p1-approval.md)
- work orderが列挙するinput／simulation 4 filesと、必要時の狭い新runtime fileだけ
- 8方向移動・独立aimの維持、OD-020 ground step、OD-021 authority reset seam
- 既存Phase 1 test実行、implementation report、このhandoffの更新

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
