# Phase 2 Slice 2-B Stage B — isolated action kernel implementation report

- Date: 2026-08-02
- Work order: `MFO-WO-P2-2B-007`
- Status: **Implementation ready for supervisor review / formal QA pending**
- Base: `29432cfd5a3eb32dfc290915d72d39b077715623`
- Branch: `codex/phase2-slice2b-stageb-action-kernel-gameplay`
- Dedicated worktree: `C:\tmp\m2b-stageb`
- Godot: `4.7.stable.official.5b4e0cb0f`

This delivery is the non-connected Stage B kernel only. It does not accept Slice 2-A performance, unlock Gate 2, or authorize playable Slice 2-B integration.

## Implemented scope

- Extended the existing `Phase1ActionDefinition` common scaffold without renaming it or changing legacy resource behavior:
  - `follow_windup_then_lock` and `lock_on_accept` aim policies;
  - finite, nonnegative forward-movement intent;
  - finite geometry and aim-dot validation used by Stage B.
- Extended the existing open-vocabulary `Phase1EffectDefinition` with shared identifiers for this isolated physical package. Generic signed magnitudes and open vocabulary remain backward compatible.
- Added the partial `combat_form.blade.one_hand.prototype` registry with exact validation for its two actions and four effects.
- Added exact approved resources:
  - quick cut: `0.10 / 0.10 / 0.20 / 0.00`, follow aim through windup, no forward intent, Damage `10`, PartDamage `6`;
  - heavy cleave: `0.40 / 0.10 / 0.50 / 0.00`, lock aim on acceptance, active-only `48 px` intent, Damage `14`, PartDamage `18`;
  - both: reach `150`, radius `88`, minimum aim dot `0.25`, one target, one concurrent `PlayerCritical` query, safe-circle technical hit-shape binding.
- Added a `RefCounted`, non-connected action runtime:
  - exactly `idle`, `windup`, `active`, and `recovery`;
  - transactional one-shot configuration with immutable definition snapshots;
  - reserve-before-acceptance, no queue, no emergency use, deterministic multi-boundary advancement;
  - quick aim follow/lock and heavy acceptance lock;
  - exactly one immutable query request on active entry;
  - release after hit, miss, callback rejection, malformed or invalidated callback, reset, and clear;
  - read-only debug state/result and clean final idle state.

The `48 px` value is a request payload only. This order does not move an actor, execute a physics query, select a target, or apply damage.

## Implementation-commit paths

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

`docs/handoffs/gameplay.md` is updated in the required separate handoff commit.

## New UID identities

- `combat_form_definition.gd.uid`: `uid://cbeew6npbnccj` — SHA-256 `57091DCBF7D00D74FDE6F733E1665FF3AB51621D7C094833AD50F96CC0342D9C`
- `action_runtime.gd.uid`: `uid://b1tfw4prax5s7` — SHA-256 `96E0E63D442B3ACCF313F94B020A765109C9E4D2BF2521F679A4191D9E19FBBE`

Existing sidecars remained unchanged:

- `action_definition.gd.uid`: `9F463EC1B34CE637C2F7AA084BF74DE6F0A6AF1F137135D662943239CD81EE78`
- `effect_definition.gd.uid`: `5F28A002D5D2C33CA5326147B745546A887E770C740EF44EAF3CD40E17CEA8A7`
- `hit_query_pool.gd.uid`: `1EB4D5A82B66F4DCC68BFB0657DB200384EA333F5F25B2C78D8610A2B5CB1D9B`

## Verification

All commands below were run individually from `C:\tmp\m2b-stageb\material-frontier-online\prototype` using:

`C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`

1. Version

   `Godot_v4.7-stable_win64_console.exe --version`

   Result: `4.7.stable.official.5b4e0cb0f`, exit `0`.

2. Import / parse

   `Godot_v4.7-stable_win64_console.exe --headless --path . --editor --quit`

   Result: Pass, exit `0`; both new global classes registered without parse errors.

3. Ignored additive Stage B self-check

   `Godot_v4.7-stable_win64_console.exe --headless --path . --script res://build/stageb-self-check/run_stageb_action_kernel_self_check.gd`

   Result: `309 / 309 assertions Pass`, exit `0`.

   It covers exact registry/data rejection, `6 / 6 / 12` and `24 / 6 / 30` nominal ticks, both aim policies, all pre-accept rejection paths, no queue, reserve-before-acceptance, callback exact-once, immutable payloads, exact effect/geometry values, active-only `48 px` intent, all release paths, one-shot reconfiguration, invalidated callback release, multi-boundary deltas, final active count `0`, and emergency use `0`.

   Scratch identity: SHA-256 `58BEC687938C7ECCD8F47D667A282A65A8DAB106A4BE6785799CEB32462DE0B3`. It is ignored by `prototype/.gitignore:3:build/` and is not part of either commit.

4. Corrected Stage A runner

   `Godot_v4.7-stable_win64_console.exe --headless --path . --script res://tests/run_slice2b_foundation_tests.gd`

   Result: `71 / 71 Pass`, exit `0`.

5. Phase 1 regression

   `Godot_v4.7-stable_win64_console.exe --headless --path . --script res://tests/run_phase1_tests.gd`

   Result: `36 / 36 Pass`, exit `0`.

6. Slice 2-A regression

   `Godot_v4.7-stable_win64_console.exe --headless --path . --script res://tests/run_slice2a_tests.gd`

   Result: `120 / 120 Pass`, exit `0`.

7. Slice 2-A correction regression

   `Godot_v4.7-stable_win64_console.exe --headless --path . --script res://tests/run_slice2a_correction_tests.gd`

   Result: `39 / 39 Pass`, exit `0`.

8. Main-scene headless smoke

   `Godot_v4.7-stable_win64_console.exe --headless --path . --quit-after 120`

   Result: Pass, exit `0`; `DefinitionsValidated ok=true`, one actor, one target, and zero RuntimeHardLimit violations.

9. Repository boundary

   - `git diff --check`: exit `0`.
   - Changed and nonignored-untracked paths: only the 14 implementation paths before the separate handoff update.
   - Existing QA runners retain their base SHA-256 identities:
     - Stage A `70FC505F7C47F48AB68C8A1EA2E278A57D97FA9ED19EF66B044A56BFAD116DEF`
     - Phase 1 `86CC8259C4F8197892D398A3F3B27BF0C6C32B6B09BB6F726B6022B092763D99`
     - Slice 2-A `ECEB564962BA38AC2F61BC392D2F7889C06D45EFB418278BB94B3A8A994DD7A3`
     - correction `0536E0F6AD1C2C120FA319A3F8D4BD7A0A01F96924A5B50AB855BC01D8917E6C`
   - `prototype/tests` and `hit_query_pool.gd` plus its UID are unchanged from the required base.
   - Input, simulation, actors, target, scenes, `project.godot`, event, presentation, status, contract, prior QA report, and evidence paths are unchanged.

## Intermediate invalid runs

- The first ignored self-check draft contained an invalid typed test expression (`runtime is Node`) and exited `1` during parse. The scratch-only assertion was corrected; production code was not changed for this harness error.
- A later scratch self-check run exposed a debug-key naming mismatch and exited `1`. The runtime debug key was aligned with the work-order term `requested_forward_movement_intent_pixels`, then the final self-check passed.
- One attempted combined PowerShell test wrapper bound its `$args` parameter incorrectly and produced no valid test evidence (`IMPORT_EXIT=-1`). Only the two Godot processes started by that wrapper were stopped. Every required command was then rerun individually with literal arguments; the final results above are the accepted evidence.

These intermediate runs are not counted as Pass.

## Decisions and unresolved items

- Implemented only the Approved `P2-2B-P1-2026-08-01` values and work-order technical bindings.
- `OQ-002` is closed by the Approved decision reflected in the work order; no unresolved decision is required for this isolated kernel.
- New Decision Request: none.
- New known issue: none.

## Not run / explicitly unconnected

- Formal `30 QA` validation: Not run; requires a separate work order.
- Release export and exported smoke: Not run by order.
- Physical gamepad / user-feel: Not run / Deferred.
- Slice 2-A performance acceptance, PREACK, performance matrix, and Gate 2: Not run / unchanged and locked.
- Input binding, `InputAdapter`, `InputCommand`, authority simulation, player actor, target dummy, scene, production event, presentation, animation, VFX, SFX, hit execution, damage, part state, Integrity, Deformation, collision/bounds application of `48 px`, and integration: not implemented and unconnected.

## Return boundary

This result is ready for supervisor review, not a QA Pass. Stop after the dedicated implementation commit, separate gameplay handoff commit, and dedicated-branch push. Do not start QA, integration, Slice 2-C, or Gate 2 work without a new explicit order.
