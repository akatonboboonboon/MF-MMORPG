# MFO-WO-P2-20-001 — Phase 2 HUD / readability non-binding proposal

- Issuer: `00統括（監督）`
- Assignee: `20ステージ・UI・グラフィック`
- Status: Approved for proposal work only
- Milestone: Phase 2 / disconnected presentation planning
- Integration authority: None
- Gate effect: None

## 1. Objective

Create a reviewable, non-binding proposal for the future Phase 2 persistent `Integrity`／`Deformation` HUD while
Gate 2, Slice 2-B, game-code work, and presentation integration remain locked. This order does not alter the separate
QA performance authority. The proposal explores information hierarchy and approved minimum readability only. It does
not select a production layout, visual style, palette, event payload, or implementation.

## 2. Source constraints

- `OD-026`: future Phase 2 persistent HUD shows `Integrity` and `Deformation`, reads state only, adds temperature only
  after temperature behavior exists, and does not show charge before Phase 3.
- `OD-041-P2`: reference frame is 1920×1080, fixed direction, zoom 1.0, with no dynamic zoom.
- `OD-043-P2`: do not rely on color alone; 1080p text is at least 24px; Phase 2 has no camera shake; lowest quality
  keeps operation targets and any implemented danger display.
- `ASSET_CONTRACTS.md` Section 7: these are constraints, not production layout／palette／animation／payload approval.

## 3. Authorized deliverables

Use a dedicated worktree outside the shared main worktree and a dedicated branch
`codex/phase2-hud-readability-proposal-presentation`, based on the supervisor commit that contains this order.

Only these repository paths may change:

1. `docs/presentation-proposals/phase2-hud-readability-proposal.md`
2. `docs/presentation-proposals/phase2-hud-readability-wireframes.svg`
3. `docs/handoffs/presentation.md`

The proposal must contain:

- three visibly distinct structural wireframe alternatives in one 5760×1080 SVG, with three unscaled 1920×1080
  reference panels inspected independently;
- persistent `Integrity` and `Deformation` labels／values in every alternative;
- no temperature or charge display;
- text-size annotations showing every proposed 1080p label at 24px or larger;
- shape, label, border, or pattern redundancy so meaning does not depend on color;
- a Markdown comparison table for normal, grayscale, color-vision-assistance, and lowest-quality review modes;
- explicit `Proposed / non-binding / not selected` marking on every alternative;
- unranked trade-offs and review questions; no preferred variant, ranking, or recommendation.

This order may use monochrome and neutral placeholder styling only. It must not define a production palette or imply
that a proposal is already implemented. Color-vision assistance is a review transform, not a proposed product feature;
do not make a specific profile or tool a production requirement. Actual in-game mode results remain `Not run`.

## 4. Prohibited work

- no `.gd`, `.tscn`, `project.godot`, gameplay data, shared scene, production asset, or existing evidence change;
- no integration, consumer, event payload, signal, state binding, or combat-state write;
- no production layout／palette／animation／telegraph pattern／font hierarchy decision;
- no temperature behavior, charge resource, damage, `Integrity`, or `Deformation` implementation;
- no player／Burst Boar production silhouette, stage layout, collision, Y-sort standard, asset dimension standard, VFX,
  audio, camera, or screenshot claimed as an in-game result;
- no change to `MASTER_SPEC`, `DECISIONS`, `MILESTONES`, `ASSET_CONTRACTS`, `IMPLEMENTATION_STATUS`, or QA documents;
- no main push or modification of the shared QA worktree.

If a useful choice requires OD-040, OD-041-POST, OD-043-POST, OQ-001, OQ-004, or another unapproved decision, record
it in the proposal as an open dependency and do not choose it.

## 5. Validation and return

Before return:

1. visually inspect the SVG at the 1920×1080 reference size;
2. confirm all three variants retain both labels without color dependence and annotate 24px-or-larger text;
3. validate that the SVG parses and that Markdown links resolve;
4. run `git diff --check` and prove only the three authorized paths changed;
5. update `docs/handoffs/presentation.md` with base／result commit, files, relied-on decisions, review modes, evidence,
   all `Not run` items, open dependencies, and the next safe step;
6. commit and push only the dedicated presentation branch, then return to `00統括` for review.

Completion means **proposal ready for supervisor review**, not implementation acceptance. No automatic integration,
contract approval, milestone change, Gate 2 change, or follow-on production work is authorized.
