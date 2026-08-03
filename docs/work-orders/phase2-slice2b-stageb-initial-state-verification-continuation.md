# MFO-WO-P2-2B-015 — Slice 2-B Stage B initial-state correction verification continuation

- Issuer: `00統括（監督）`
- Issued: 2026-08-03 (Asia/Tokyo)
- Assignee: `10ゲームプレイ・コア実装`
- Status: **Authorized / ignored helper replacement and remaining implementation verification only**
- Milestone: M2 / Slice 2-B
- Required starting point: the supervisor commit containing this order; its exact hash is supplied in the direct START notice
- Required branch: `codex/phase2-slice2b-stageb-initial-state-correction-gameplay`
- Required workspace: the stopped worktree `C:\tmp\m2b-stageb-fix`
- Predecessor order: [`MFO-WO-P2-2B-014`](phase2-slice2b-stageb-initial-state-correction.md)
- Validation owner: `30 QA・性能・レビュー` only after a separate supervisor order
- Integration authority: **None**
- Gate effect: **None** — Gate 2 remains Locked

## 1. Accepted stop and objective

`MFO-WO-P2-2B-014` applied its exact authorized source correction and Passed the required Godot version and headless
import／parse checks. Its first targeted self-check did not parse because the ignored scratch helper contained literal
two-byte `\t` sequences instead of indentation and ended at `\tif condition:` without the remainder of `_check()`.
Godot reported `Expected new line after "\\"` at helper line 8.

This is an implementation-validation helper defect, not a candidate game-code or Approved-data failure. The targeted
behavior is still unevaluated, so candidate Pass is not established either. The source correction remains exact and must
not be rewritten. The sole objective of this continuation is to replace that ignored helper once with the complete fixed
bytes below and, only if the targeted retry Passes, finish the remaining `-014` implementation verification.

## 2. Exact starting state

Before any write or process launch, confirm all of the following:

1. the existing worktree is on `codex/phase2-slice2b-stageb-initial-state-correction-gameplay`;
2. before synchronizing this order, its HEAD is `508ab6040f41669e38324affe39b43b948ddcfa4` and the only tracked change is
   `material-frontier-online/prototype/scripts/combat/action_runtime.gd`;
3. that tracked diff is exactly one deletion／one insertion and its corrected Git blob is
   `5e764ed21b0210c2db5dd40aefa2451efe242557`;
4. the corrected worktree SHA-256 is `a366845ea803efcf0edb96d6e63a27ab022d16adb23277722abf2ae2e3d7aa43`;
5. the ignored helper is exactly
   `material-frontier-online/prototype/build/verification/run_slice2b_stageb_initial_state_check.gd`, size `1411`,
   SHA-256 `a5ecde69a3e36b6a67e8e8465e95e5eeebf6a14defbf7ddecb6f94e20d353251`, `41` lines, literal
   `\t` count `38`, and final line `\tif condition:`;
6. no report／handoff edit, commit, push, Stage B／regression runner, main smoke, or other retry occurred after the returned
   first non-pass.

Fast-forward the existing branch to the supervisor commit supplied in the START notice without resetting, stashing,
rewriting, or discarding the exact tracked source diff. If any precondition differs or the fast-forward cannot preserve
that diff, stop and return to `00統括`.

## 3. Authorized paths and exact ignored-helper replacement

The only tracked paths that may differ from the original `-014` starting point remain:

1. `material-frontier-online/prototype/scripts/combat/action_runtime.gd`
2. `material-frontier-online/implementation/2026-08-03-phase2-slice2b-stageb-initial-state-correction.md`
3. `docs/handoffs/gameplay.md`

Do not perform another tracked source correction. The only newly authorized write before verification is one exact
whole-file replacement of the ignored helper named in Section 2. Its complete authorized UTF-8, BOM-free, LF-only bytes
are:

```gdscript
extends SceneTree

var _passed := 0
var _failed := 0


func _init() -> void:
    var runtime := Phase2ActionRuntime.new()
    var rejected := not runtime.try_accept(
        Phase2CombatFormDefinition.ACTION_QUICK_CUT,
        Vector2.RIGHT
    )
    var state := runtime.debug_state()
    var effects: Array = state["effects"] if state.has("effects") and state["effects"] is Array else []
    var result := runtime.debug_result()

    _check(rejected, "fresh unconfigured runtime rejects acceptance")
    _check(state.is_read_only(), "fresh debug state is read-only")
    _check(
        state.has("phase") and state["phase"] is StringName and state["phase"] == Phase2ActionRuntime.PHASE_IDLE,
        "fresh debug state is idle"
    )
    _check(state.has("effects") and state["effects"] is Array, "fresh debug state exposes effects")
    _check(effects.is_read_only(), "fresh effects are read-only")
    _check(effects.is_empty(), "fresh effects are empty")
    _check(result.is_read_only(), "fresh result is read-only")
    _check(result.is_empty(), "fresh result is empty")

    if _failed == 0:
        print("[MFO-P2-2B-STAGEB-INITIAL-STATE-CHECK] PASS: %d assertions" % _passed)
        quit(0)
        return
    push_error(
        "[MFO-P2-2B-STAGEB-INITIAL-STATE-CHECK] FAIL: %d of %d assertions failed"
        % [_failed, _passed + _failed]
    )
    quit(1)


func _check(condition: bool, label: String) -> void:
    if condition:
        _passed += 1
        print("[MFO-P2-2B-STAGEB-INITIAL-STATE-CHECK] PASS: %s" % label)
        return
    _failed += 1
    push_error("[MFO-P2-2B-STAGEB-INITIAL-STATE-CHECK] FAIL: %s" % label)
```

Expected identity is size `1646`, SHA-256
`eedc6ee73ad5a5c376eb38be55140a9006840aaf1d4cd5c84a9a6712eba2ac73`, `46` lines, CR count `0`,
BOM absent, literal `\t` count `0`, and tab-byte count `0`. The eight test conditions and labels above match the
stopped helper; only valid indentation and the complete result-accounting body are supplied. Keep the helper ignored,
do not commit it, do not create a `.uid` sidecar, and write the retry log to a fresh path so the original failure log is
not overwritten.

No helper redesign, formatter, alternate script, candidate-branch recreation, test edit, data edit, or additional runtime
change is authorized.

## 4. Fixed verification continuation

The predecessor's Godot version and headless import／parse Passes are inherited and must not be rerun. After the exact
helper identity is established, run in this order:

1. the same targeted self-check command exactly once as the single authorized retry and require numeric exit `0` plus
   terminal `PASS: 8 assertions`;
2. only if it Passes, the frozen Stage B runner exactly once and require `184 / 184`;
3. corrected Stage A runner exactly once and require `71 / 71`;
4. Phase 1 runner exactly once and require `36 / 36`;
5. Slice 2-A runner exactly once and require `120 / 120`;
6. Slice 2-A correction runner exactly once and require `39 / 39`;
7. main-scene headless smoke exactly once with unchanged validation／RHL success;
8. final `git diff --check`, exact three-path scope, exact one-line source diff, protected test／UID／data／evidence
   identity, nonignored-untracked `0`, and clean worktree after commits.

Stop at the first non-pass. There is no second helper replacement, second targeted retry, alternate command, source
repair, expectation change, or partial success classification under this order.

## 5. Report, commit, return, and stop

The implementation report must record the original `-014` helper non-pass without overwriting its log, the exact helper
preimage／replacement／retry, all inherited and newly executed commands, numeric exits, assertion totals, and Not run
items. Then:

1. create one implementation commit containing only the corrected `action_runtime.gd` and implementation report;
2. create one gameplay-handoff-only commit;
3. push the required branch, prove local／origin equality and a clean worktree, and return to `00統括`;
4. stop.

Formal QA, another candidate correction, Stage C, input／authority／actor／target／scene／damage／state／event／presentation
integration, Slice 2-C／2-D, PREACK／performance／real A／B／C, and Gate 2 remain unauthorized. A separate supervisor QA
order is required after a successful gameplay handoff.
