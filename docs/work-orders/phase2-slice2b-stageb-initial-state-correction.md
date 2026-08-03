# MFO-WO-P2-2B-014 — Slice 2-B Stage B initial immutable-effects correction

- Issuer: `00統括（監督）`
- Issued: 2026-08-03 (Asia/Tokyo)
- Assignee: `10ゲームプレイ・コア実装`
- Status: **Authorized / exact one-line candidate correction only**
- Milestone: M2 / Slice 2-B
- Required starting point: the supervisor commit containing this order; its exact hash is supplied in the direct START notice
- Required branch: `codex/phase2-slice2b-stageb-initial-state-correction-gameplay`
- Required workspace: dedicated clean worktree such as `C:\tmp\m2b-stageb-fix`
- Frozen candidate implementation: `30b090481a9fffd123d5b16537886e5011fd7e51`
- Frozen candidate handoff: `bbed2fd98bf0435e456f9ad2bd7dba2b7a7cb0c6`
- Valid QA failure tip: `67d1c93dc6362f0b1dfb685de181750a59734034`
- QA evidence manifest: `63cd3b7484ceba2ee73fb97fbba87709eab2ea0ad091f67d9fb8c95970974228` (`39 / 39` payloads)
- Validation owner: `30 QA・性能・レビュー` only after a separate supervisor order
- Integration authority: **None**
- Gate effect: **None** — Gate 2 remains Locked

## 1. Accepted failure and objective

`MFO-WO-P2-2B-013` completed fixed qualification, parser, and one capture-valid FORMAL invocation. The result was
`183 / 184` Pass with one failed assertion, `unconfigured runtime rejects acceptance`.

The failure is accepted as a candidate implementation nonconformance:

- a fresh unconfigured `Phase2ActionRuntime` initializes `_current_effect_records` as mutable `[]`;
- unconfigured `try_accept()` rejects immediately and does not run cleanup;
- `debug_state()["effects"]` exposes that same nested array, while the Stage B contract requires read-only observable state;
- `_clear_current_action_state()` already installs a fresh read-only empty array on later cleanup paths.

Approved action／effect data, the frozen QA runner／launcher, capture, and evidence are not implicated. The sole objective
of this order is to establish the already-required read-only empty-effects invariant at construction.

## 2. Starting preconditions

Before editing:

1. create the required branch from the exact supervisor commit supplied in the START notice and confirm a clean worktree;
2. confirm candidate `30b090481a9fffd123d5b16537886e5011fd7e51`, handoff
   `bbed2fd98bf0435e456f9ad2bd7dba2b7a7cb0c6`, and QA tip
   `67d1c93dc6362f0b1dfb685de181750a59734034` are unchanged ancestors;
3. confirm `action_runtime.gd` Git blob is exactly `739f76000646a63bd16c0258c866df3b7e8a7203` and worktree SHA-256 is
   `5e796a70dafe2426c08624c1f25ae53ac661bc4e029f08151c8136ba078f0719`;
4. confirm the exact source line `var _current_effect_records: Array = []` occurs once.

If any precondition differs, stop before editing and return to `00統括`.

## 3. Authorized tracked paths

Only these three paths may change:

1. `material-frontier-online/prototype/scripts/combat/action_runtime.gd`
2. `material-frontier-online/implementation/2026-08-03-phase2-slice2b-stageb-initial-state-correction.md`
3. `docs/handoffs/gameplay.md`

No other game code／data, `.uid`, test／runner／launcher／evidence, scene, project, contract, status, or work-order path is
assigned. Scratch verification may exist only below ignored `material-frontier-online/prototype/build/` or an external
temporary directory and must not be committed.

## 4. Exact correction

Change only the initializer right-hand side:

```diff
-var _current_effect_records: Array = []
+var _current_effect_records: Array = _empty_read_only_array()
```

Acceptance of the source correction requires:

- exactly one deletion and one insertion at the same location;
- unchanged prefix and suffix bytes apart from the exact replacement;
- no line-ending or BOM normalization;
- corrected `action_runtime.gd` Git blob exactly `5e764ed21b0210c2db5dd40aefa2451efe242557`;
- `_empty_read_only_array()`, `try_accept()`, `debug_state()`, `_clear_current_action_state()`, lifecycle, callback,
  lease, query, and movement-intent code otherwise unchanged.

Do not switch to an `_init()` assignment, shared constant, new helper, lazy repair, test exception, or data change. If
the exact initializer call does not parse or pass, stop at that first non-pass without trying an alternate design.

## 5. Required implementation verification

Run and record each result without changing tests or expectations:

1. exact Godot version `4.7.stable.official.5b4e0cb0f`;
2. headless import／parse;
3. an ignored targeted self-check proving that a fresh unconfigured runtime rejects acceptance and exposes idle,
   empty read-only `effects`, and empty read-only result state;
4. frozen Stage B runner exactly `184 / 184`;
5. corrected Stage A runner `71 / 71`;
6. Phase 1 `36 / 36`;
7. Slice 2-A `120 / 120`;
8. Slice 2-A correction `39 / 39`;
9. main-scene headless smoke with unchanged validation／RHL success;
10. `git diff --check`, exact three-path scope, exact one-line source diff, protected test／UID／data／evidence identity,
    nonignored-untracked `0`, and clean worktree after commits.

Stop at the first non-pass. Do not repair data, runner, helper, another runtime path, or an unrelated warning under this
order. Release export, physical gamepad, user feel, PREACK, performance, real A／B／C, and playable integration remain
Not run or prohibited.

## 6. Commit, return, and stop boundary

Return one implementation commit followed by one gameplay-handoff-only commit on the required branch, push that branch,
and report:

- base, implementation, and handoff commits plus local／origin equality and clean state;
- exact changed paths and the corrected source blob／worktree SHA-256;
- targeted check identity and result, every required command／exit／assertion total, and Not run items;
- proof that Approved data, UID, QA runner／launcher／evidence, input, authority, actor／target, scene, damage／state,
  event, presentation, and integration remain unchanged.

Stop after push. Formal QA, another candidate correction, Stage C, input／authority／scene integration, Slice 2-C／2-D,
and Gate 2 are not authorized. A separate supervisor validation order is required.
