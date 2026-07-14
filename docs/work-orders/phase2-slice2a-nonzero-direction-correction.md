# Work Order — Phase 2 Slice 2-A Nonzero Direction Correction

- Work order ID: `MFO-WO-P2-2A-002`
- Issued by: `00統括（監督）`
- Issued: 2026-07-14 (Asia/Tokyo)
- Priority: **P1 / current Slice 2-A acceptance blocker**
- Runtime severity: **Low / narrow analog deadzone-edge case**
- Defect: `MFO-P2-2A-QA-001`
- Implementation owner: `10ゲームプレイ・コア実装`
- Revalidation owner: `30 QA・性能・レビュー` after the correction handoff
- Presentation owner: `20ステージ・UI・グラフィック` — no work in this order
- Status: **Active / correction authorized for listed scope only**
- Milestone: M2 / Slice 2-A correction
- Gate 2: **Locked / not evaluated**
- Correction ancestry base: `c0df756e72576a1367cf5282cef7138014cae591`
- Required starting state: the pushed supervisor commit containing this order; each assignee records its exact SHA
- Required implementation report:
  `material-frontier-online/implementation/2026-07-14-phase2-slice2a-nonzero-direction-correction.md`
- Required revalidation report: `docs/test-reports/phase2-slice2a-correction-validation.md`

This order corrects one confirmed implementation defect. It does not change OD-020, expand Slice 2-A, approve
Slice 2-B, or open Gate 2. Direct push to `main` is not authorized.

## 1. Provenance and supervisor disposition

- Phase 2 P1 and original order base: `afcd20cd4a02d618a5d7e0e4bc7555a64fa90740`
- Slice 2-A implementation: `bd01fdf3d048accaa7f5be93afe3be5cfa138201`
- Gameplay handoff: `92f71d7c3e55108a2faecaa6fbf1e1055b0d0b9f`
- QA tests and Fail report: `daf616253d39d48795b509d204f2ebe30177fc03`
- QA closure／correction ancestry base: `c0df756e72576a1367cf5282cef7138014cae591`
- Formal QA result: Phase 1 `36 / 36 Pass`; Slice 2-A `119 / 120 Pass`, exit `1`
- Formal report: [`phase2-slice2a-validation.md`](../test-reports/phase2-slice2a-validation.md)

`00統括` accepts the Stage B Fail recommendation. The defect is not an unresolved specification question:
OD-020 and `MFO-WO-P2-2A-001` already require every movement vector that remains nonzero after the input deadzone
to take priority over aim fallback. No `OPEN_QUESTIONS.md` entry or new product decision is required.

## 2. Objective and exact correction

Correct only the two evade-direction nonzero checks:

1. In Local Authority Simulation direction selection, only exact `Vector2.ZERO` is neutral and may use aim fallback.
   Every nonzero `command.move_vector`, including a magnitude such as `0.005` after deadzone processing, must remain
   the chosen movement direction and be normalized by the actor.
2. In the PlayerActor evade-start guard, an otherwise-ready evade rejects only exact `Vector2.ZERO`. Every nonzero
   direction must be accepted and normalized.

For evade direction selection and its start guard, the input adapter remains the only deadzone boundary. Do not add a
second gameplay deadzone in authority or actor code.

## 3. Stage A — `10` correction scope

`10` may change only:

- `material-frontier-online/prototype/scripts/simulation/local_authority_simulation.gd`
- `material-frontier-online/prototype/scripts/simulation/player_actor.gd`
- `docs/handoffs/gameplay.md`
- the required correction implementation report

Expected code delta is the two direction conditions. A materially larger code change must stop and return to
`00統括` before implementation.

`10` must branch from the required starting state using:

```text
codex/phase2-slice2a-correction-gameplay
```

The QA test, Fail report, and evidence inherited from the starting HEAD may be executed and read but must not be
edited by `10`.

## 4. Explicitly unchanged

- `input_adapter.gd`, `input_command.gd`, InputMap, action deadzone, and device mappings
- `EVADE_DISTANCE_PX = 140.0`
- `EVADE_DURATION_SECONDS = 0.20`
- `EVADE_REUSE_SECONDS = 0.45`
- nominal 12 active ticks and 27 accepted-start ticks at 60 Hz
- move speed, gameplay bounds, collision behavior, normalization, and reset behavior
- aim update epsilon and initial-aim／reset fallback behavior
- ordinary movement and debug `MovementApplied` thresholds
- Phase 1 provisional attack, query pool, and existing debug events
- scenes, `project.godot`, camera, presentation, HUD, VFX, audio, and assets
- defeat, retry binding, damage, `Integrity`, `Deformation`, lock-on behavior, network, account, and persistence

Do not set the shared `_DIRECTION_EPSILON_SQUARED` constant to zero. It is also used by aim update and reset logic,
which are outside this correction.

OQ-005 remains unresolved, and production `DomainEvent` payloads remain unchanged.

## 5. `10` pre-handoff verification

Before returning the correction, `10` must:

1. run `git diff --check`;
2. confirm the changed path list contains only the Stage A paths above;
3. run the unchanged Phase 1 suite and obtain `36 / 36 Pass`;
4. run the inherited, unchanged `run_slice2a_tests.gd` and obtain `120 / 120 Pass`, exit `0`;
5. run project import／parse;
6. record commands, exit codes, exact resulting commit, and whether any new question was found;
7. confirm the QA test source was not modified.

No new question is expected. If exact-zero handling cannot satisfy the inherited test without changing another
behavior, stop and return the evidence to `00統括`.

## 6. Stage B — `30` fresh revalidation

After `10` returns a correction commit and gameplay handoff, `30` creates:

```text
codex/phase2-slice2a-correction-qa
```

from that exact handoff HEAD. `30` may change only:

- a new additive correction test and `.uid` under `material-frontier-online/prototype/tests/` if needed;
- `docs/test-reports/phase2-slice2a-correction-validation.md`;
- new evidence below `docs/test-reports/evidence/phase2-slice2a/correction-001/`;
- `docs/handoffs/qa.md`.

The existing `run_slice2a_tests.gd`, original Stage B report, test hash, and
`evidence/phase2-slice2a/stage-b-20260714-92f71d7/` must not be weakened, rewritten, or replaced. The first full
revalidation run uses the existing 120 assertions byte-for-byte unchanged.

At minimum, `30` verifies fresh:

1. exact-zero movement uses current aim fallback;
2. deadzone-edge small nonzero movement uses and normalizes the movement direction;
3. small positive／negative axis inputs and a small diagonal input do not fall back to aim;
4. PlayerActor rejects exact zero but accepts a small nonzero direction when active／reuse state permits;
5. the full unchanged Slice 2-A suite passes `120 / 120`, exit `0`;
6. the full Phase 1 suite passes `36 / 36`, exit `0`;
7. `140 px / 0.20 s`, 12／27 tick boundaries, reject／no-buffer, collision, bounds, and reset remain unchanged;
8. import／parse, main-scene smoke, Windows release export, and exported-EXE smoke pass;
9. the corrected release build passes the original KBM functional checklist;
10. no forbidden scope or unrelated gameplay value changed.

If the reference device is AC Online, also run the existing 120-warmup／600-sample arena-idle regression under AC
Best performance. If AC remains Offline, do not reuse Gate 1 or failed-candidate results; return the performance item
as `Blocked / Not run` and let `00統括` decide whether the slice can be accepted.

The revalidation report records the correction implementation SHA, QA test／report SHA, exact commands and exit
codes, environment, raw evidence paths, and evidence hashes.

User feel is recorded only if the user actually runs the corrected build. It is not inferred from automation. Physical
gamepad remains `Not run / Deferred` and is not a blocker for this correction under the existing deferral.

## 7. Acceptance and routing

The correction is acceptable only when:

- the two authorized code conditions are the only gameplay-code changes;
- every post-deadzone nonzero move vector takes precedence over aim fallback;
- exact zero continues to use aim fallback;
- Phase 1 and the unchanged full Slice 2-A suite pass;
- build／smoke and KBM functional checks pass;
- evidence is fresh, hashed, and separated from the original Fail archive;
- `30` returns a `Pass` recommendation with performance、user-feel、physical-gamepad evidence explicitly separated.

`30` may return `Fail` or `Blocked`; it may not approve Gate 2 or Slice 2-B. After QA returns, only `00統括` may
accept Slice 2-A, resolve the known issue, integrate to `main`, or issue the next work order.
