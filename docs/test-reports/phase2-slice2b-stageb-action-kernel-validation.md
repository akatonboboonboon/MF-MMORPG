# MFO-WO-P2-2B-008 — Slice 2-B Stage B action-kernel validation

- QA start HEAD: `c5051f5ec7c764eed24523097ad125aa4d4fce9d`
- Candidate implementation: `30b090481a9fffd123d5b16537886e5011fd7e51`
- Reviewed gameplay handoff: `bbed2fd98bf0435e456f9ad2bd7dba2b7a7cb0c6`
- QA branch: `codex/phase2-slice2b-stageb-action-kernel-qa`
- Worktree: `C:\tmp\q2b-stageb`
- Environment: Windows; Godot `4.7.stable.official.5b4e0cb0f`; console `198152` bytes; SHA-256 `D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`.

## Scope and lineage

Candidate parent was `29432cfd5a3eb32dfc290915d72d39b077715623`; reviewed handoff parent was the candidate. The implementation diff had the required 14 paths, the handoff changed only `docs/handoffs/gameplay.md`, and the QA worktree was clean before authoring.

The new independent runner was authored only in the permitted QA path. Authoring parse/import ran twice, both exit `0`; it did not execute the runner. Final frozen runner SHA-256: `08af5c6c834561a5b54c08dcaa0a585da2a9d2ea25f877112ebdddcdd4941e59` (spaces removed in evidence manifest), UID `uid://do8gfjtm83s05`, UID SHA-256 `7615a8f1d1edf4d59e5a4eb25996acd008a05a53921e4f293ea5765da4d67096`.

## Fresh formal sequence

| Order | Command | Exit | Result |
|---|---|---:|---|
| 1 | `Godot_v4.7-stable_win64_console.exe --version` | 0 | Pass |
| 2 | `Godot_v4.7-stable_win64_console.exe --headless --editor --path . --quit` | 0 | Pass |
| 3 | `Godot_v4.7-stable_win64_console.exe --headless --path . --script res://tests/run_slice2b_stageb_action_kernel_tests.gd` | 0 | **Non-pass**: Godot reported a GDScript parse error before assertions began. |

Formal item 3 reported: `Expression is of type "Phase2ActionRuntime" so it can't be of type "Node"` at runner line 112. The engine process exit was `0`, but no runner assertions executed and the parser error is a validation-runner defect. Per the fixed first-non-pass boundary, no runner edit, candidate repair, regression suite, smoke, export, or final audit was launched.

## Evidence

- Raw evidence and manifest: [`stageb-kernel-001`](evidence/phase2-slice2b/stageb-kernel-001/)
- Runner and UID: `material-frontier-online/prototype/tests/run_slice2b_stageb_action_kernel_tests.gd` and `.uid`

## Not run / deferred

Stage A `71 / 71`, Phase 1 `36 / 36`, Slice 2-A `120 / 120`, correction `39 / 39`, main smoke, release export, exported smoke, physical gamepad, KBM/user feel, performance/P95, PREACK, real A/B/C, integration, and Gate 2 were not run. No candidate execution evidence was obtained.

## Recommendation

**Blocked / validation infrastructure or evidence incomplete**

This result does not attribute a defect to the candidate implementation or approved data.
