# Gameplay / Core Handoff

- Owner role: ゲームプレイ・コア実装担当
- Updated by supervisor: 2026-07-14
- Current milestone: M1 / Phase 1
- Authorization: Gate 1 verification and Phase 1 defect correction only
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

- 実ゲームパッド確認を妨げるPhase 1 defectの再現・最小修正
- Gate 1用のinput／event／metricsログ補助（新仕様を作らないもの）
- 既存36 testsの再実行と、欠落するPhase 1 regression test
- 質問・契約案の文書化

## Do not start

- 仮攻撃Aを正式な快斬／重断へ置換
- `Integrity`／`Deformation`、core装備、回避、敗北／retry
- 3素材、3魔法、boss、parts、stage、gimmicks、loot
- network、account、persistence

Gate 1とM2 entryが監督承認されるまで停止する。

## Boundaries to preserve

- stable actor/target ID、command sequence／physics tick
- InputCommandは要求であり、発動可否はauthority simulationが決める
- player-critical queryを予約し、取得後に必ず返却
- accepted actionをpool不足で不発にしない
- simulationだけがgameplay resultを決める
- PresentationへはDomainEvent／read-only stateを渡す

## Blocking decisions

- Gate 1: GQ-003、GQ-004
- M2: OD-020、OD-021、OD-027
- Presentationと同時に触れる場合: OD-026、OD-041、OQ-001、OQ-004

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
