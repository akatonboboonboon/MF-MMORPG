# Stage / UI / Graphics Handoff

- Owner role: ステージ・UI・グラフィック担当
- Updated by supervisor: 2026-07-14
- Current milestone: M1 / Phase 1
- Authorization: Contract review and preservation of Phase 1 placeholders only
- Baseline commit: `a13505e8fbf82962e049b9101a87593a6692d2c7`

## Read before work

- [`../../AGENTS.md`](../../AGENTS.md)
- [`../MASTER_SPEC.md`](../MASTER_SPEC.md)
- [`../MILESTONES.md`](../MILESTONES.md)
- [`../ASSET_CONTRACTS.md`](../ASSET_CONTRACTS.md)
- [`../OPEN_QUESTIONS.md`](../OPEN_QUESTIONS.md)

## Current state

- Phase 1はprogrammatic placeholder player／target／arenaとdebug HUDのみ。
- HUDは全DomainEventをlog表示し、simulation metricsをread-onlyで表示する。
- target flashとplaceholder drawingの一部はPhase 1都合でsimulation node内にある。final architectureの先例ではない。
- 本番art、stage、VFX、audio、camera、HUD layoutは未実装。

## Current allowed work

- `ASSET_CONTRACTS.md`の不足を`Proposed`として報告
- Phase 1手動確認を妨げる表示defectの再現・最小修正
- 凍結仕様に対するstage/readability audit
- asset ID、layer、collision、quality fallbackの計画文書

## Do not start

- production art／UI／stage layout／camera framingの確定実装
- 独自palette、telegraph色、文字size、screen shake、hitstop
- provisional SE／BGM／voice production
- boss telegraph、part feedback、loot UI、retry UI
- Presentationからgameplay stateを変更する処理

## Blocking decisions

- OD-040 art style
- OD-041 camera
- OD-042 provisional audio scope
- OD-043 readability values
- OD-026 persistent HUD
- OD-020 lock-on indicator
- OD-021 defeat/retry UI
- OD-022 boss telegraph details
- OD-023 part/body feedback semantics
- OD-024 loot interaction/results
- OQ-001 production event payload
- OQ-004 hit presentation/timing ownership

## Preserved constraints

- decoration has no collision
- foreground never fully hides player
- path recognizable by silhouette
- attack warning differs from background effects
- warnings, player outline, parts, gimmicks remain at low quality
- particles/lights/audio never decide combat

## Required handoff update

```text
Status:
Milestone / authorization:
Base and resulting commit:
Files or assets changed:
Contracts relied on or proposed:
Readability modes checked:
Tests / screenshots / evidence:
Open questions added:
Known issues added:
Gameplay files requested:
Next safe step:
```
