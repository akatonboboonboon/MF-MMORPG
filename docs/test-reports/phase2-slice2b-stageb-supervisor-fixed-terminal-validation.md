# MFO-WO-P2-2B-013 — Stage B supervisor-fixed terminal validation

## Result

**Fail / candidate implementation or approved-data nonconformance**

The single authorized FORMAL execution completed with a capture-valid ledger but one direct assertion failure. No retry, repair, alternate launcher, or follow-on work was started.

## Scope and identities

- QA start / supervisor commit: `75e11146451054535ad852a659037b35a4e3d537`
- Candidate implementation: `30b090481a9fffd123d5b16537886e5011fd7e51`
- Reviewed handoff: `bbed2fd98bf0435e456f9ad2bd7dba2b7a7cb0c6`
- Runner canonical UTF-8 LF SHA-256: `f48266b43a3f3b572d2a5747807efa8bc4bbc6150e3481473d8b9d0272c3ba22`
- Runner Git blob: `8d7d611dc3e1d3b54291ad0d23c8ae791ebdd724`
- Runner UID SHA-256: `7615a8f1d1edf4d59e5a4eb25996acd008a05a53921e4f293ea5765da4d67096`
- Launcher canonical UTF-8 LF SHA-256: `671c8018e5b295bf83d7d228f41adec5802570b63d6a569939539df54d04736f`
- Launcher Git blob: `0dc8ab217fd8a47d1a143263b1318d6ed420bf30`
- Candidate runtime readback SHA-256: `5e796a70dafe2426c08624c1f25ae53ac661bc4e029f08151c8136ba078f0719`

## Static closure

- `_check` executable call sites / helper declaration: `153 / 1`
- Projected terminal assertions: `148 + 15 + 9 + 12 = 184`
- Expanded descriptions: `162`
- Fixed runner, UID, and copied ReadOnly launcher were unchanged before child execution.

## Fresh fixed sequence

| Step | Result | Evidence |
| --- | --- | --- |
| `QUALIFY_STREAMS` | Pass, exit `23`, stdout/stderr `21 / 21` bytes | `qualify-streams-001/` |
| `QUALIFY_EMPTY` | Pass, exit `29`, stdout/stderr `0 / 0` bytes | `qualify-empty-001/` |
| `QUALIFY_GODOT_VERSION` | Pass, exit `0`, Godot `4.7.stable.official.5b4e0cb0f` | `qualify-godot-version-001/` |
| `PARSER` | Pass, exit `0` | `parser-001/` |
| `FORMAL` | **Fail**, exit `1`; `183` PASS records, `1` failed assertion | `formal-001/` |

All five invocations used only the copied launcher and completed without timeout. No relevant Godot/Material/MfoQa process remained after FORMAL.

## Direct failure

- Failed label: `unconfigured runtime rejects acceptance`
- Runner location: `run_slice2b_stageb_action_kernel_tests.gd:128`
- Engine error location: `run_slice2b_stageb_action_kernel_tests.gd:45`
- Captured stderr SHA-256: `eba46d42b58414080900e0da48ef7a862e946cf9a17a88e10a8426aa9b4bdf4f`
- Captured stdout SHA-256: `d59942918673facf52a46056fcc42bc75e404ca114f4ee12a72afbfcc3e75310`

The frozen runner directly checks that a newly created, unconfigured `Phase2ActionRuntime` rejects acceptance while reporting an exact final-idle, read-only state. The candidate initializes `_current_effect_records` as a mutable `[]` at `action_runtime.gd:32`; `_is_final_idle()` requires `debug_state()["effects"]` to be read-only. The same candidate resets this field to a read-only array only during `_clear_current_action_state()` (`action_runtime.gd:310`). This directly explains the observed initial-state failure and is not a launcher, parser, capture, identity, or evidence defect.

## Boundaries

- Regressions, import, main smoke, release export, and exported smoke: not run by this order.
- PREACK, performance/P95, real A/B/C, KBM, gamepad, game integration, Gate 2: prohibited / not run.
- Gate 2 remains Locked. No Stage C or automatic `-014` was started.

## Evidence

Evidence root: `docs/test-reports/evidence/phase2-slice2b/stageb-kernel-006/`

The root preserves static closure, ordered qualification evidence, the single FORMAL capture, a closure record, and `SHA256SUMS.txt`.
