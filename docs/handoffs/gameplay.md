# Gameplay / Core Handoff

- Owner role: `10ゲームプレイ・コア実装`
- Updated by supervisor: 2026-07-14
- Current milestone: M2 entry preparation
- Authorization: No code changes / await Approved P1 decisions and Phase 2 work order
- Baseline commit: `a13505e8fbf82962e049b9101a87593a6692d2c7`

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

- 質問・契約案の文書化
- 次sliceに必要なP1の選択肢、影響、test案を`00`へ返す読み取り作業

Gate 1は2026-07-14にPassしたが、Phase 2実装work orderは未発行である。code／testを変更しない。

## Do not start

- 仮攻撃Aを正式な快斬／重断へ置換
- `Integrity`／`Deformation`、core装備、回避、敗北／retry
- 3素材、3魔法、boss、parts、stage、gimmicks、loot
- network、account、persistence

`00`がPhase 2 work orderを発行するまで着手しない。予定順は2-A基本操作、2-B物理攻撃、
2-C損傷、2-D表示契約であり、各slice後に`30`検証を挟む。

## Boundaries to preserve

- stable actor/target ID、command sequence／physics tick
- InputCommandは要求であり、発動可否はauthority simulationが決める
- player-critical queryを予約し、取得後に必ず返却
- accepted actionをpool不足で不発にしない
- simulationだけがgameplay resultを決める
- PresentationへはDomainEvent／read-only stateを渡す

## Blocking decisions

- Deferred Playability evidence: GQ-004
- M2 entry: OD-020、OD-021、OD-026、OD-027、OD-041、OD-043
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
