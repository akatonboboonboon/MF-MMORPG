# Phase 2 HUD / Readability Structural Proposal

- Work order: `MFO-WO-P2-20-001`
- Status: **Proposed / non-binding / not selected**
- Integration status: **Disconnected / not implemented**
- Reference frame: `1920×1080`, fixed direction, zoom `1.0`
- Wireframe sheet: [three unscaled 1920×1080 panels](phase2-hud-readability-wireframes.svg)

## Purpose and boundary

This proposal compares three structural locations for a future persistent `Integrity`／`Deformation` HUD. It does
not select a production layout, palette, font hierarchy, art style, animation, event payload, state consumer, or
implementation. The neutral fills and line patterns in the SVG exist only to make the wireframes distinguishable
without relying on color.

All displayed values and fill lengths are illustrative placeholders. They are not gameplay values, thresholds,
recommendations, or bindings.

## Approved constraints used

- `OD-026`: show persistent `Integrity` and `Deformation` only; keep the HUD read-only. Temperature is absent because
  its behavior does not exist, and charge is absent before Phase 3.
- `OD-041-P2`: inspect each alternative as an unscaled `1920×1080` panel using the fixed-direction, zoom `1.0`
  reference composition. No dynamic zoom is proposed.
- `OD-043-P2`: labels do not depend on color; every proposed 1080p text element is annotated at `24px` or larger;
  no camera shake is proposed; essential labels, values, and borders remain part of the lowest-quality structure.
- `ASSET_CONTRACTS.md` §7: these constraints do not approve a production layout, palette, animation, payload, or
  consumer.

## Shared structural notation

- `INTEGRITY` uses an explicit label, `VALUE / MAX` text, a rectangular track, solid neutral fill, and bracket lines.
- `DEFORMATION` uses an explicit label, `VALUE / 100` text, an angled track, segmented marks, and neutral hatching.
- The two meanings therefore remain distinguishable by wording, geometry, border treatment, and pattern even if all
  color information is removed.
- The background grid is a review aid only and is marked decorative. It is not a stage, camera, or production asset
  proposal.
- The SVG is `5760×1080`: Alternatives A, B, and C occupy `x=0–1919`, `1920–3839`, and `3840–5759` respectively.
  No panel is scaled inside the sheet.

## Alternative A — Stacked status rail

**Proposed / non-binding / not selected.**

`Integrity` and `Deformation` are grouped into one upper-left vertical rail. Each state receives a complete
label/value/track row, separated by a divider.

Unranked trade-offs:

- Keeps both persistent states in one scanning region.
- Uses a taller continuous block along the left edge of the playfield.
- Keeps the upper center and lower edge structurally free.
- A single container makes shared visibility straightforward, while simultaneous occlusion would affect both rows.

## Alternative B — Paired top bands

**Proposed / non-binding / not selected.**

`Integrity` and `Deformation` occupy separate, horizontally paired modules near the top edge. Their distinct outer
shapes reinforce the explicit labels and fill treatments.

Unranked trade-offs:

- Gives each state comparable horizontal space and independent framing.
- Distributes reading across two neighboring top modules instead of one vertical stack.
- Uses more top-edge width while keeping both lower corners structurally free.
- Separation supports independent emphasis later, but the production emphasis rules remain undecided.

## Alternative C — Split lower ledger

**Proposed / non-binding / not selected.**

`Integrity` sits in a lower-left ledger and `Deformation` in a lower-right ledger. The central playfield remains
structurally open between them.

Unranked trade-offs:

- Separates the two persistent states by screen region as well as by label and shape.
- Preserves the top edge but increases the eye-travel distance between the two values.
- Uses both lower corners, which could interact with later UI needs that are not yet approved.
- Independent containers reduce shared occlusion, while their wide separation makes simultaneous reading less local.

## Static readability comparison

The table records proposal-level review targets and static wireframe observations only. It is not an in-game result.
No specific color-vision profile, product accessibility mode, rendering tool, or lowest-quality implementation is
selected by this proposal.

| Alternative | Normal static view | Grayscale review transform | Color-vision review transform | Lowest-quality structural review | In-game result |
|---|---|---|---|---|---|
| A — stacked rail | Both labels, values, tracks, and divider remain present | Neutral structure remains; solid versus hatched track is still separable | Wording, geometry, border, and pattern remain the carriers of meaning | Decorative grid may be absent; both rows retain label, value, track, and border | **Not run** |
| B — paired bands | Both labeled modules remain independently framed | Module shape and solid versus segmented/hatch treatment remain separable | Separation, wording, geometry, border, and pattern remain the carriers of meaning | Decorative grid may be absent; both modules retain label, value, track, and border | **Not run** |
| C — split ledger | Both corner ledgers remain labeled and independently framed | Corner location and solid versus segmented/hatch treatment remain separable | Location, wording, geometry, border, and pattern remain the carriers of meaning | Decorative grid may be absent; both ledgers retain label, value, track, and border | **Not run** |

Static review status is recorded in the [presentation handoff](../handoffs/presentation.md). Actual game integration,
runtime state binding, other resolutions, user testing, and in-game quality modes remain **Not run**.

## Open dependencies

- `OD-040`: production art style is open.
- `OD-041-POST`: boss/stage framing and post-Phase-2 camera behavior are open.
- `OD-043-POST`: production palette, pattern system, other-resolution scaling, and production type hierarchy are open.
- `OQ-001`: production event payload is open.
- `OQ-004`: hit presentation and timing ownership are open.

None of these dependencies is resolved or implied by the wireframes.

## Review questions

These questions are unranked and request review; they do not nominate a preferred variant.

- Which screen regions must remain reserved before any structural alternative can be considered for integration?
- Should future review keep `Integrity` and `Deformation` in one local scan region or explicitly evaluate separated
  scan regions? No answer is selected here.
- What read-only state interface and payload contract will be available when a later integration work order is issued?
- Which approved evidence method should be used later for lowest-quality and color-vision checks in the running game?
- Are additional non-color redundancies required before a structure can move from `Proposed` to contract review?

## Explicitly not proposed

- No production layout, palette, font, style, iconography, animation, VFX, audio, camera behavior, or telegraph pattern.
- No state implementation, event consumer, payload, signal, scene binding, or gameplay write.
- No temperature, charge, damage, threshold, penalty, stage, silhouette, collision, Y-sort, or asset-size standard.
- No preferred variant, ranking, recommendation, integration approval, Gate effect, or Slice 2-B authorization.

## Validation record

Validation commands and exact results are recorded after static review in the presentation handoff. At proposal
creation time, all game/runtime results remain **Not run**.
