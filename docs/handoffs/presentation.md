# Stage / UI / Graphics Handoff

- Owner role: `20ステージ・UI・グラフィック`
- Updated by role 20: 2026-07-17
- Current milestone: Phase 2 disconnected presentation planning
- Authorization: `MFO-WO-P2-20-001` proposal work only / no integration authority
- Work base: `c1591d638ded4b17e19f93255038570426c9019a`
- Result commit: dedicated-branch result; exact SHA returned to `00統括` after commit
- Dedicated branch: `codex/phase2-hud-readability-proposal-presentation`
- Phase 1 presentation baseline: `a13505e8fbf82962e049b9101a87593a6692d2c7`

## Current return

- Status: **Proposal ready for supervisor review / non-binding / not selected**
- Files changed:
  - `docs/presentation-proposals/phase2-hud-readability-proposal.md`
  - `docs/presentation-proposals/phase2-hud-readability-wireframes.svg`
  - `docs/handoffs/presentation.md`
- Contracts relied on: `OD-026`, `OD-041-P2`, `OD-043-P2`, `ASSET_CONTRACTS.md` §7
- Contracts proposed or changed: none
- Gameplay files requested or changed: none
- Integration, shared scene, state/payload binding, production asset: **Not run / unchanged**

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

Slice 2-A work orderは`20`へintegrationを割り当てていない。次は引き続き
**非接続・非bindingのProposed候補**としてだけ作成できる。

- 斜め俯瞰用の仮player silhouette
- 片手刃の仮形状
- `Integrity`／`Deformation` HUD layout案
- 攻撃予告の色・形の候補
- Y-sort確認用の仮画像
- asset寸法と命名規則案

候補をApproved仕様として扱わず、game code／shared `.tscn`へ接続しない。

## Do not start

- production art／UI／stage layout／camera framingの確定実装
- 未承認production palette、telegraph pattern、24px未満の1080p文字、screen shake、hitstop
- provisional SE／BGM／voice production
- boss telegraph、part feedback、loot UI、retry UI
- Presentationからgameplay stateを変更する処理

Slice 2-Dで`ActionStarted`等のevent payloadとread-only stateがApprovedになった部分だけ、別work orderで統合する。
完成工場美術、バーストボア本番絵、製品版BGM、voiceの量産は引き続き禁止する。

## Blocking decisions

- OD-040 art style
- OD-041-POST production／boss camera
- OD-042 provisional audio scope
- OD-043-POST production readability details
- OD-022 boss telegraph details
- OD-023 part/body feedback semantics
- OD-024 loot interaction/results
- OQ-001 production event payload
- OQ-004 hit presentation/timing ownership

Approved baseline: OD-026、OD-041-P2、OD-043-P2。これらはconstraintであり、2-A integration許可ではない。

## Preserved constraints

- decoration has no collision
- foreground never fully hides player
- path recognizable by silhouette
- attack warning differs from background effects
- warnings, player outline, parts, gimmicks remain at low quality
- particles/lights/audio never decide combat

## MFO-WO-P2-20-001 return

- Status: **Proposal ready for supervisor review / non-binding / not selected**
- Milestone / authorization: Phase 2 disconnected proposal under `MFO-WO-P2-20-001`; no integration authority
- Base and resulting commit: base `c1591d638ded4b17e19f93255038570426c9019a`; exact dedicated-branch result SHA is returned to `00統括` after commit because a commit cannot self-identify inside its own content
- Files or assets changed:
  - `docs/presentation-proposals/phase2-hud-readability-proposal.md`
  - `docs/presentation-proposals/phase2-hud-readability-wireframes.svg`
  - `docs/handoffs/presentation.md`
- Contracts relied on or proposed: relied on `OD-026`, `OD-041-P2`, `OD-043-P2`, and `ASSET_CONTRACTS.md` §7; proposed or changed none
- Readability modes checked:
  - Normal: three unscaled `1920×1080` panels rendered statically; labels, values, geometry, borders, and patterns present
  - Grayscale: generic static grayscale transform retained the same non-color carriers; no product mode selected
  - Color-vision review transform: generic chroma-reduction review retained wording, geometry, border, and pattern; no production profile selected
  - Lowest-quality structural review: a scratch-only transform removed exactly three decorative grid rectangles; all essential HUD groups remained XML-identical to the source and retained labels, values, tracks, borders, and hatching
  - In-game / runtime / user testing: **Not run**
- Tests / screenshots / evidence:
  - SVG XML parse, root `5760×1080`, `viewBox="0 0 5760 1080"`, three `1920×1080` alternatives, and minimum visible font `24px`: **Pass**
  - Each alternative contains only the `Integrity` / `Deformation` HUD states and the exact `Proposed / non-binding / not selected` marker: **Pass**
  - Static Edge review renders for normal, grayscale, generic color-vision review transform, and scratch lowest-quality transform: **Pass for proposal-level inspection**
  - Markdown relative-link targets: `2/2` exist
  - Changed paths: exact authorized three; unauthorized paths `0`
  - `git diff --check`: **Pass**
  - Review PNGs and transformed SVG copies were scratch-only and are not committed
- Open questions added: none; existing `OD-040`, `OD-041-POST`, `OD-043-POST`, `OQ-001`, and `OQ-004` remain unresolved and unimplemented
- Known issues added: none
- Gameplay files requested: none
- Next safe step: `00統括` reviews the three unranked alternatives and questions; no selection, contract change, integration, Gate effect, or Slice 2-B authorization is implied
