# Material Frontier Online — Phase 2 Slice 2-A Nonzero Direction Correction

- Date: 2026-07-14 (Asia/Tokyo)
- Work order: `MFO-WO-P2-2A-002`
- Defect: `MFO-P2-2A-QA-001`
- Owner: `10ゲームプレイ・コア実装`
- Starting commit: `295549373fbb3b39deb6079172783ce62c7da532`
- Correction implementation commit: `5261a73707daca03cb160e03a12247886d3f5cce`
- Result: **Correction implemented / fresh QA revalidation pending**
- Gate 2: **Locked / not evaluated**

## 1. Authority and scope

Implemented only the two direction-condition changes authorized by
[`MFO-WO-P2-2A-002`](../../docs/work-orders/phase2-slice2a-nonzero-direction-correction.md). No input adapter,
input command, deadzone, gameplay value, aim/reset behavior, `MovementApplied` condition, event, scene, QA source,
presentation file, or asset was changed.

## 2. Corrected behavior

- Authority evade direction selection now treats only exact `Vector2.ZERO` movement as neutral and falls back to
  aim only in that case.
- The actor evade-start guard now rejects only exact `Vector2.ZERO` direction.
- Every nonzero direction that remains after input deadzone processing is accepted and normalized by the actor.
- The shared `_DIRECTION_EPSILON_SQUARED := 0.0001` constant is unchanged and retains its existing non-evade uses.
- Step distance, duration, reuse interval, collision, arena bounds, aim, reset, and event behavior are unchanged.

## 3. Files changed

Correction implementation commit:

- `prototype/scripts/simulation/local_authority_simulation.gd`
- `prototype/scripts/simulation/player_actor.gd`

Handoff documentation:

- `implementation/2026-07-14-phase2-slice2a-nonzero-direction-correction.md`
- `../../docs/handoffs/gameplay.md`

## 4. Verification performed by implementation owner

| Check | Result | Notes |
|---|---|---|
| `git diff --check` | **Pass**, exit `0` | No whitespace errors |
| Existing Phase 1 suite | **36 / 36 Pass**, exit `0` | QA source and expectations unchanged |
| Existing Slice 2-A suite | **120 / 120 Pass**, exit `0` | `run_slice2a_tests.gd` executed without modification |
| Import / parse | **Pass**, exit `0` | Godot `4.7.stable.official.5b4e0cb0f` |
| QA test source comparison | **Unchanged**, exit `0` | SHA-256 matches Stage B source |

Commands used from `material-frontier-online/prototype` unless otherwise noted:

```powershell
# Existing Phase 1 regression
Godot_v4.7-stable_win64_console.exe --headless `
  --log-file logs/slice2a-correction-phase1.log --path . `
  --script res://tests/run_phase1_tests.gd

# Existing Slice 2-A regression
Godot_v4.7-stable_win64_console.exe --headless `
  --log-file logs/slice2a-correction-suite.log --path . `
  --script res://tests/run_slice2a_tests.gd

# Import / parse
Godot_v4.7-stable_win64_console.exe --headless `
  --log-file logs/slice2a-correction-import.log --editor --path . --quit

# Repository root
git diff --check
git diff --exit-code 295549373fbb3b39deb6079172783ce62c7da532 -- `
  material-frontier-online/prototype/tests/run_slice2a_tests.gd
Get-FileHash -Algorithm SHA256 `
  material-frontier-online/prototype/tests/run_slice2a_tests.gd
```

The QA source SHA-256 before and after correction is
`03ecfbd34bfb98333d9bdeff5c6ef90cb477090101ea6e4435511509c1e6e91a`.

Import printed a non-fatal inability to create the ObjectDB snapshot directory under `user://`; file scanning and
script-class registration completed and Godot returned exit `0`. Explicit project-local log paths were used for all
Godot commands.

## 5. Questions, issues, and contract impact

- New open questions: **None**.
- Existing `OQ-005` remains open; no retry binding or related behavior was implemented.
- Known issues added: **None**. This correction addresses `KI-009`; closure remains pending fresh `30` revalidation.
- Cross-role contract impact: **None**.
- `IMPLEMENTATION_STATUS.md`, `MILESTONES.md`, QA tests, QA reports, and QA evidence were not edited.

## 6. Next safe step

`30 QA・性能・レビュー` performs fresh correction revalidation against implementation commit
`5261a73707daca03cb160e03a12247886d3f5cce`. Slice 2-B and later work remain locked until `00統括` accepts Slice
2-A and issues a new work order.
