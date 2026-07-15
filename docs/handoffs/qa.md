# QA / Performance / Review Handoff

- Owner role: `30 QA・性能・レビュー`
- Updated by `30 QA`: 2026-07-15
- Current milestone: M2 / Slice 2-A
- Authorization: `00統括` issued MFO-WO-P2-2A-006 at `2d5ef1a`
- Phase 1 package source baseline: `a13505e8fbf82962e049b9101a87593a6692d2c7`
- Required starting state: commit containing the active work order; record exact tested `HEAD`
- Current status: MFO-WO-P2-2A-006 received; **Stage QP preparation only / result pending**
- QA planning base: `2d5ef1ab149629eea9e9f73994baf1304228611e`

Active work order:
[`../work-orders/phase2-slice2a-harness-qualification.md`](../work-orders/phase2-slice2a-harness-qualification.md)

Required diagnostic report:
[`../test-reports/phase2-slice2a-harness-qualification.md`](../test-reports/phase2-slice2a-harness-qualification.md)

Required evidence root:
[`../test-reports/evidence/phase2-slice2a/qualification-001/`](../test-reports/evidence/phase2-slice2a/qualification-001/)

Original Slice 2-A report: [`../test-reports/phase2-slice2a-validation.md`](../test-reports/phase2-slice2a-validation.md)

Completed Gate 1 work order: [`../work-orders/phase1-gate1-power-revalidation.md`](../work-orders/phase1-gate1-power-revalidation.md)

Gate 1 report: `docs/test-reports/phase1-gate1-power-revalidation.md`

Deferred gamepad work order: [`../work-orders/phase1-gate1-manual-validation.md`](../work-orders/phase1-gate1-manual-validation.md)

Previous report: [`../test-reports/phase1-gate1-manual-validation.md`](../test-reports/phase1-gate1-manual-validation.md)

## Harness qualification receipt — MFO-WO-P2-2A-006

- QA branch: `codex/phase2-slice2a-harness-qualification-qa`
- Supervisor order／QA start HEAD: `2d5ef1ab149629eea9e9f73994baf1304228611e`
- Authorization: evidence-harness qualification only under the explicit external-hold exception
- Current phase: Stage QP preparation and sealed self-tests; qualification result not yet claimed
- New stage required: yes; consumed `p2-2a-005-20260715t0944jst-b32fdae` remains frozen and is not reused
- A／B／C: identity-only staged copies; launch prohibited
- Performance slots: required count `0`
- P95／frame measurement／arena／KBM: Not run and prohibited
- Game code／game tests／recorder／scene／project settings／build changes: prohibited
- Supervisor preliminary OneDrive count `0`: not reused as formal evidence; fresh PREACK and LIVE evidence required
- Tracked scope: new qualification report, new `qualification-001/` evidence, and this QA handoff only
- Performance acceptance: `MFO-HOLD-P2-2A-001` remains active
- Gate 2／Slice 2-B: Locked / not evaluated
- Qualification recommendation: Pending

Prior `-005` clarification required by `00統括`: the `[Environment]::TickCount64` auxiliary field recorded as `0` is
**not** treated as an independent blocker because a distinct nonzero Stopwatch origin drove the actual deadline.
The accepted `-005` disposition remains Blocked based on the recorded OneDrive-family condition together with QA
procedure／harness nonconformance. The frozen `-005` report and evidence are not rewritten. `-006` nevertheless
requires fresh proof using native Windows `GetTickCount64` as the sole canonical monotonic source.

Next authorized output after Stage QP seal:

```text
MFO-WO-P2-2A-006 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex>
```

## Performance-only rerun formal result — MFO-WO-P2-2A-005

- QA branch: `codex/phase2-slice2a-performance-only-qa`
- Supervisor order／QA start HEAD: `b32fdae63c0ddcb150f5a4678e301f959550ad08`
- QA evidence／report content commit: `60dd270ac3418d09d3e944a2a64beb1b036b0b42`
- Stage ID: `p2-2a-005-20260715t0944jst-b32fdae`
- Preparation manifest SHA-256: `ac2c34644f7d3f2a92d39ebf54f64b1984c14fb330d31ec22b57035381334aa1`
- Stage P: Pass; A／B／C and controller sealed; dry-run exit `0`; slot launch count `0`
- Sealed environment: Windows NT `10.0.26200.0`; Intel64 Family 6 Model 186 Stepping 3; 12 logical; Intel Graphics `32.0.101.7077`; GL Compatibility／1920×1080／standard; post-failure AC／Best performance only
- User activation line: exact stage ID／digest received
- QA procedural nonconformance: measurement-start acknowledgement preceded the required preserved external OneDrive count-zero check
- Controller origin: `2026-07-15T10:25:41.8990234+09:00`
- Controller terminal error recorded: `OneDrive-family process present during settled-60s.` about `1.486 s` after origin
- Triggering OneDrive name／PID: not persisted before throw; later corroborating snapshot only observed `OneDrive.Sync.Service` PID `13496`
- Auxiliary system-wide monotonic field: `0` — preserved historical value; not an independent blocker per `00統括`
- Settled interval: incomplete; CPU preflight attempts `0`
- Matrix: A1／B1／C1／C2／B2／A2 all Not run; valid runs `0`; P95 unavailable／uninterpreted
- Cleanup: controller exited; lock absent; MFO／Godot residue `0`
- Post-run identity: manifest／controller／A／B／C full hashes unchanged
- Corrected-C KBM: frozen prior Pass; not rerun
- User feel: frozen prior `すべて問題ないです`; not re-requested
- Physical gamepad: Not run / Deferred
- QA game／test／recorder／scene／project／quality／threshold changes: `0`
- Executable／export pack copied to tracked evidence: `0`
- New known issues／open questions: `0`; supervisor-owned registry not edited
- Evidence: [`../test-reports/evidence/phase2-slice2a/diagnostic-003/p2-2a-005-20260715t0944jst-b32fdae/`](../test-reports/evidence/phase2-slice2a/diagnostic-003/p2-2a-005-20260715t0944jst-b32fdae/)
- Evidence manifest SHA-256: `d45590b80fbdef5e1b70734d20a6a2e001db542556c8b41efdd073f1b0740227`
- Report: [`../test-reports/phase2-slice2a-performance-only-rerun.md`](../test-reports/phase2-slice2a-performance-only-rerun.md)
- Final recommendation: **Blocked**

Required next route: preserve and freeze the consumed stage and all prior evidence; do not automatically retry or
issue `-006`. `00統括` decides any external-state hold or explicitly bounded future order. `30 QA` does not accept
Slice 2-A, approve Gate 2, or authorize Slice 2-B.

## Controlled rerun formal result — MFO-WO-P2-2A-004

- QA branch: `codex/phase2-slice2a-controlled-rerun-qa`
- Supervisor order／QA start HEAD: `67ba7f34b6e0ee93ca454a6da8d354b0c2e79ebc`
- QA evidence／report content commit: `45eeeb32a525b922eada9624385691a2143fd7db`
- A／B／C source and staged EXE size、SHA-256、`MZ`: all exact Pass
- Environment: Windows `10.0.26200.0`、12 logical processors、Intel Graphics driver `32.0.101.7077`
- Power: AC Online、Best performance／`ded574b5-45a0-4f42-8737-46345c09c238`
- Quiet input: final 10 seconds unchanged、last-input tick `492292203`
- Preflight system CPU: average `38.250224%`、maximum `46.012270%` — threshold Fail
- Preflight OneDrive-family CPU delta: `32.15625 CPU-seconds` — threshold Fail
- Performance matrix: A1／B1／C1／C2／B2／A2 all Not run; valid runs `0`
- Performance component: **Blocked / matrix not started**; no P95 interpreted
- Corrected-C KBM: third independent capture completed in `27.973 s` with foreground lossなし
- KBM stimuli: W／A／S／D、independent mouse、neutral Space、move＋Space、boundary hold、short-interval Space、five-second idle recorded
- User confirmation: all input intentional; all six checklist outcomes and feel `すべて問題ないです`
- KBM component: **Pass**
- User feel: **Pass / no issue reported**
- Physical gamepad: **Not run / Deferred**
- QA game／test／recorder／scene／project／quality／threshold changes: 0
- New known issues／open questions: 0; `OQ-005` unchanged
- Gate 2: Locked; Slice 2-B authorization not issued by QA
- Evidence: [`../test-reports/evidence/phase2-slice2a/diagnostic-002/controlled-20260715-67ba7f3/`](../test-reports/evidence/phase2-slice2a/diagnostic-002/controlled-20260715-67ba7f3/)
- Evidence manifest SHA-256: `f17de23065a66a982515b6d1030e926ad9d8e9c801d0e6a04950f3beb908ca03`
- Report: [`../test-reports/phase2-slice2a-controlled-rerun.md`](../test-reports/phase2-slice2a-controlled-rerun.md)
- Final recommendation: **Blocked**

Required next route: `00統括` reviews performance Blocked、KBM Pass、and the OneDrive-family background-load evidence.
`30 QA` does not modify gameplay、accept Slice 2-A、approve Gate 2、or authorize Slice 2-B.

## Historical performance diagnostic result — MFO-WO-P2-2A-003

- QA branch: `codex/phase2-slice2a-diagnostic-qa`
- Supervisor order／QA start HEAD: `f3450df07f84144ce10dba2584c74a0f3a5b585b`
- QA evidence／report content commit: `a3920f8419419357698c0db47f8aa35b3fd6ba34`
- A source／EXE: `a13505e8fbf82962e049b9101a87593a6692d2c7` / `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199`
- B source／EXE: `295549373fbb3b39deb6079172783ce62c7da532` / `3c15c254fbb8025d88c5636f2175a35f6e325b5368c8098e78b16181090dd4ef`
- C source／EXE: `5261a73707daca03cb160e03a12247886d3f5cce` / `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47`
- B／C detached release exports: exit `0`, distinct `MZ` hashes; B initial missing-output-directory preflight exit `1` preserved separately
- Environment: Windows 11 Home build `26200`, Intel Core 7 150U, Intel Graphics driver `32.0.101.7077`, physical `1920x1200 @ 60 Hz`, GL Compatibility, standard quality
- Power: AC Online, Best performance / `ded574b5-45a0-4f42-8737-46345c09c238`
- Fixed order result:
  - A1: P95 `18.0556 ms`, exit `0`, **Invalid** — only allowed replacement recorded external input
  - B1: P95 `19.0880 ms`, exit `0`, **Invalid** — external input; post-stop-condition diagnostic only
  - C1: P95 `18.3333 ms`, exit `0`, **Invalid** — external input; post-stop-condition diagnostic only
  - C2: P95 `18.3333 ms`, exit unknown, **Invalid** — controller evidence incomplete
  - B2: **Not run** — repeated interference stop
  - A2: **Not run** — repeated interference stop
- Valid acceptance performance runs: `0`; invalid P95 values are not converted into performance Fail
- Load observation: completed metadata runs had system CPU average `72.838%–87.620%`, maximum `90.229%–100%`, OneDrive CPU delta `+23.359–25.969 s`, and changed last-input ticks
- Performance disposition: **Blocked / causality not isolated**; do not return gameplay code to `10` from this evidence
- Corrected-C KBM: **Blocked** on first W due recurring external input; fresh log already contained 9 movement and 8 Attack A requests not issued by QA
- User feel: Not run
- Physical gamepad: Not run / Deferred
- QA game／test／recorder／scene／project／quality／threshold changes: 0
- Private non-game window titles: redacted in Git evidence; PID／time／classification／title hash retained
- New open questions: 0; `OQ-005` unchanged
- Gate 2: Locked; Slice 2-B authorization not issued by QA
- Evidence: [`../test-reports/evidence/phase2-slice2a/diagnostic-001/session-20260714-f3450df/`](../test-reports/evidence/phase2-slice2a/diagnostic-001/session-20260714-f3450df/)
- Evidence manifest SHA-256: `7a651e2a7e321cc1fa3f93390c9c563d52a86776ae0179331726112c0884fbfe`
- Report: [`../test-reports/phase2-slice2a-performance-diagnostic.md`](../test-reports/phase2-slice2a-performance-diagnostic.md)
- Final recommendation: **Blocked**

Required next route: `00統括` reviews the external-input／foreground／background-load evidence and decides whether to
issue a new bounded diagnostic session. `30 QA` does not change gameplay values, accept Slice 2-A, approve Gate 2, or
authorize Slice 2-B.

## Correction Stage B formal result — MFO-WO-P2-2A-002

- QA branch: `codex/phase2-slice2a-correction-qa`
- Correction order commit: `295549373fbb3b39deb6079172783ce62c7da532`
- Correction implementation: `5261a73707daca03cb160e03a12247886d3f5cce`
- QA start／gameplay handoff HEAD: `0727fe562c20fcb781eb9b1d63b260eb9a94f333`
- QA tests／report content commit: `547554183187c24fd8e0ced33a4c381aaf3c4366`
- Fresh Phase 1 regression: `36 / 36 Pass`, exit `0`
- Existing Slice 2-A suite: `120 / 120 Pass`, exit `0`
- Existing suite SHA-256 before／after: `03ecfbd34bfb98333d9bdeff5c6ef90cb477090101ea6e4435511509c1e6e91a`
- Additive correction suite: `39 / 39 Pass`, exit `0`
- Correction cases: exact zero fallback、small `+X / -X / +Y / -Y`、small diagonal normalize、actor direct zero
  reject／small nonzero accept、active中のaim独立をPass
- Inherited behavior: `140 px / 0.20 s`、12／27 ticks、reject／no-buffer、collision layer／mask `4`、bounds、
  mid-step／mid-cooldown／repeated／unknown-actor resetをPass
- Import／main smoke／release export／exported smoke: all exit `0`
- Corrected release: `material-frontier-online/prototype/build/windows/MFO-Phase1.exe`
- Corrected release SHA-256: `28543cb1e45f1e4dd380654200e9336b9e95d8a6e699b4cc5ce0bae26ababb39`
- Environment: Windows 11 Home build `26200`、Intel Core 7 150U、Intel Graphics driver `32.0.101.7077`、
  GL Compatibility、project `1920x1080`、standard quality
- Power: pre／postともAC Online、charging、Best performance／`ded574b5-45a0-4f42-8737-46345c09c238`
- Arena-idle performance run 1: 120 warmup＋600 samples、P95 `33.4643 ms`、47.7472 fps from average、**Fail**
- Arena-idle performance confirmation 2: 120 warmup＋600 samples、P95 `20.0000 ms`、57.7898 fps from average、**Fail**
- Performance finding: `MFO-P2-2A-QA-002`; causality not isolated。ゲーム値／仕様変更は提案しない
- QA corrected-release KBM: Blocked／Not completed。D方向partial movement後にexternal user input検知とwindow
  capture失敗が発生し、full checklistをPassにしていない
- User feel: Not run。修正版に対するuser評価を推測しない
- Physical gamepad: Not run／Deferred
- Memory／GPU timing: unavailable。`static_memory_bytes = 0`をPassにしない
- Attack query count／release: Pass。part count: N/A。minimum-quality readability: Not run
- QA gameplay code changes: 0。additive QA testとQA-owned report／evidence／handoffだけ
- Known issue routing: KI-009 functional correctionはPass evidenceあり、closeは`00統括`待ち。新performance findingを
  `00統括`へ返す
- Open questions added: 0。OQ-005 unchanged
- Slice 2-A correction recommendation: **Fail**
- Gate 2: Locked。Slice 2-B authorizationはQAから発行しない
- Formal evidence:
  [`../test-reports/evidence/phase2-slice2a/correction-001/validation-20260714-0727fe56/`](../test-reports/evidence/phase2-slice2a/correction-001/validation-20260714-0727fe56/)
- Evidence manifest SHA-256: `d1c2c827d37519c4ace69eb4209fc09f3be903379b9c038bfbc822d2f652d31c`
- Formal report:
  [`../test-reports/phase2-slice2a-correction-validation.md`](../test-reports/phase2-slice2a-correction-validation.md)

Required next route: `00統括`が`MFO-P2-2A-QA-002`と未完了KBM evidenceを確認し、bounded performance／manual
再検証を指示する。`30 QA`は性能Failを理由にゲーム値や仕様を変更せず、Gate 2／Slice 2-Bを承認しない。

## Historical Stage B formal result — MFO-WO-P2-2A-001

- QA branch: `codex/phase2-slice2a-qa`
- QA start HEAD: `92f71d7c3e55108a2faecaa6fbf1e1055b0d0b9f`
- Implementation source: `bd01fdf3d048accaa7f5be93afe3be5cfa138201`
- Comparison baseline: `afcd20cd4a02d618a5d7e0e4bc7555a64fa90740`
- QA tests／report content commit: `daf616253d39d48795b509d204f2ebe30177fc03`
- Fresh Phase 1 regression: `36 / 36 Pass`
- Fresh Slice 2-A suite: `119 / 120 Pass`, exit `1`
- Import／main smoke／release export／exported smoke: Pass, all exit `0`
- Confirmed defect: `MFO-P2-2A-QA-001` — deadzone直上の小さいnonzero moveをneutral扱いし、aimへfallback
- Performance: Blocked／Not run; formal precheck時の`PowerLineStatus = Offline`
- QA interactive KBM: Not run on the failing candidate
- User feel: Not run
- Physical gamepad: Not run／Deferred
- New open questions: 0; OQ-005 unchanged
- Gameplay／scene／project setting changes by QA: 0
- Slice 2-A recommendation: **Fail**
- Gate 2: Locked; Slice 2-B authorization not issued by QA
- Formal evidence: [`../test-reports/evidence/phase2-slice2a/stage-b-20260714-92f71d7/`](../test-reports/evidence/phase2-slice2a/stage-b-20260714-92f71d7/)

Required next route: `00統括` issues a bounded correction order for `MFO-P2-2A-QA-001`; `10` changes only the
nonzero／neutral direction checks without retuning distance、duration、reuse、deadzone or expanding retry scope. `30`
then reruns the full 120-assertion suite and the remaining manual／performance items fresh.

## Historical next queue — MFO-WO-P2-2A-001 (superseded)

1. Before the `10` handoff, draft acceptance cases only; do not edit gameplay or freeze an unreturned interface.
2. After the handoff, record the exact tested commit and modify only QA-owned tests／report／evidence.
3. Run fresh Phase 1 regression, Slice 2-A deterministic tests, import／headless smoke, release／export smoke, and
   the conditional arena-idle regression described by the work order.
4. Check KBM movement／aim／Space evade separately from automation and human feel.
5. Keep physical gamepad `Not run / Deferred`; do not infer hardware behavior from mapping tests.
6. Return `Pass / Fail / Blocked` recommendation to `00`. Do not approve Gate 2 or authorize Slice 2-B.

## Historical pre-handoff test plan — MFO-WO-P2-2A-001 (completed and superseded)

Historical state: **Drafted from approved behavior only / completed by Stage B and superseded by MFO-WO-P2-2A-002**

This plan does not prescribe method names, fields, extra events, or a returned implementation interface. After the
`10` handoff, QA first reviews the actual diff and chooses the narrowest QA-owned seam that can observe the approved
authority behavior. An untestable approved behavior is reported to `00`; QA does not require a production event or
edit gameplay code to expose it.

### A. Handoff and scope precheck

1. Record the exact implementation commit, implementation report, and gameplay handoff.
2. Diff from `afcd20cd4a02d618a5d7e0e4bc7555a64fa90740` and confirm implementation changes are limited to the
   work-order-owned input／simulation files plus the declared implementation report and gameplay handoff.
3. Confirm no `.tscn`, `project.godot`, camera, presentation, combat definition, existing QA test, shared contract,
   production event payload, build setting, or Phase 2-B／2-C／2-D feature changed.
4. Confirm OQ-005 remains unresolved and no retry input binding, defeated state, checkpoint, scene reload, or retry UI
   was added.
5. Confirm existing provisional `move_speed`, gameplay bounds, 1920×1080 fixed camera, zoom 1.0, stable IDs, and
   provisional attack path were not retuned or replaced.

If the handoff or diff is missing, mixed, or outside scope, stop validation and return `Blocked` or `Fail` with the
exact path list. Do not normalize the diff in QA.

### B. Phase 1 fresh regression

- Project import／parse.
- Run the existing Phase 1 deterministic suite without weakening or rewriting its expectations.
- Preserve InputMap idempotence, KBM／gamepad mappings, aim ownership and retention, normalized movement,
  stable actor／target ID, unknown-actor rejection, command sequence／physics tick, provisional hit／non-hit,
  hit-query acquire／release, and RuntimeHardLimit startup records.
- Main-scene headless smoke.

Report historical Phase 1 results separately from results freshly rerun against the Slice 2-A commit.

### C. Input request and authority boundary

| Case | Stimulus | Required observation |
|---|---|---|
| Abstract mapping | Inspect and exercise Space and gamepad A mappings | Both feed the same abstract `evade` request; mapping test is not physical-gamepad evidence |
| Fresh press | Press／inject a new evade edge once | One request is captured; held input does not become repeated accepted starts |
| Request only | Observe input command before authority step | Input carries intent only; it does not choose acceptance, direction result, collision, distance, or reuse |
| Lock-on reservation | Inspect LB／Q mapping and run normal commands | Mapping remains present and behaviorless |
| Device neutrality | Review changed gameplay paths | No device-specific evade gameplay branch exists |

The exact command member or method name is intentionally not frozen before handoff.

### D. Deterministic evade behavior

Run with fixed physics delta `1 / 60 s` and a collision-free actor unless the case states otherwise.

| Case | Setup / request | Expected |
|---|---|---|
| Move-direction step | Nonzero normalized move plus fresh evade | Direction is the latched move direction |
| Diagonal normalization | Diagonal move plus fresh evade | Direction is normalized; total collision-free travel is not diagonally inflated |
| Aim fallback | Neutral move, known aim, fresh evade | Direction is the latched current aim direction |
| Distance / duration | Accepted start followed through 12 nominal active ticks | `140 px` over `0.20 s`; provisional absolute endpoint tolerance `<= 0.1 px` |
| Ordinary movement isolation | Hold ordinary movement throughout active step | Ordinary locomotion neither adds to nor cancels approved step travel |
| Active rejection | Request again while step is active | Rejected; it does not restart, extend, or queue another step |
| Reuse rejection | Request after active end but before tick 27 from accepted start | Rejected |
| Earliest reuse | Fresh request at nominal start-to-start tick 27 | May be accepted, not earlier |
| No delayed buffer | Request on a rejected tick, then send no request when reuse becomes ready | No later automatic step occurs |
| Resume movement | Continue ordinary movement after step completion | Normal movement resumes only after the approved step finishes |
| Bounds limit | Start near each relevant configured boundary and step outward | Boundary is not crossed; shortened travel is recorded as bounds-limited |
| Collision limit | Place a QA fixture obstacle in the travel path | Collision is not penetrated; shortened travel is recorded as collision-limited |

The `0.1 px` value is a QA floating-point observation tolerance, not a gameplay retune. QA will not silently widen it
to pass an implementation. If the returned fixed-tick representation needs a different tolerance, record the measured
error and return the question to `00` before changing the expectation.

### E. Authority reset seam

1. Configure and record the actor start position and initial aim.
2. Enter an active evade and a non-ready reuse state, then call the explicit authority reset seam.
3. Verify start position, initial aim, zero velocity, inactive evade, zero active progress, cleared pending request state,
   and no residual reuse lock.
4. Verify a fresh post-reset evade can be accepted immediately when otherwise valid.
5. Repeat explicit reset and confirm identical state with no accumulated side effect.
6. Verify neutral ticks, cached aim, and ordinary simulation steps never invoke reset automatically.
7. Verify reset does not also apply movement, aim change, evade, or provisional attack from a triggering command.
8. Verify no defeated state or retry input binding is required or inferred in this slice.

Reset automation may use a QA-only observation seam. It must not demand a new production `DomainEvent` or
presentation consumer.

### F. Invalid identity and auditability

- Send movement／aim／evade intent with an unknown actor ID and verify no configured actor mutates.
- Confirm rejection remains auditable with the originating stable actor ID, command sequence, and physics tick.
- Confirm valid actor and optional target IDs retain Phase 1 behavior.
- Exercise ordered command ticks around evade start, rejection, end, and reuse boundary to expose off-by-one or
  stale-command behavior. Do not invent a new network ordering rule in this slice.

### G. Forbidden-scope review

Search the implementation diff and runtime behavior for unintended additions: invulnerability, stamina, input buffer,
lock-on behavior, part lock, auto approach, attack cancel, quick cut／heavy cleave, damage, `Integrity`, `Deformation`,
defeat, retry binding, persistent HUD, production payloads, VFX, camera changes, networking, persistence, or account
logic. Presence of a forbidden behavior is a scope failure even when functional tests pass.

### H. Build, smoke, and conditional performance

After deterministic tests pass:

1. Re-run import／parse and main-scene headless smoke with exact command and exit code capture.
2. Produce a proportionate Windows release-equivalent export and run exported-EXE headless smoke.
3. If the established measurement path remains usable, run one 120-warmup／600-sample arena-idle regression on the
   reference device at 1920×1080, standard quality, AC Best performance.
4. Record P50／P95／P99／maximum, average-derived FPS, HUD／JSON consistency, environment, stdout, screenshot, and hashes.
5. Label the result `Slice 2-A arena-idle regression`; do not call it Gate 1, Gate 7, stress, or product-minimum evidence.

Performance execution is conditional on an implementation handoff, a successful export, and the existing measurement
command remaining valid. If any prerequisite fails, record `Blocked` or `Not run` rather than substituting old evidence.

### I. Manual evidence separation

- Automation: deterministic command and state observations only.
- Manual KBM functionality: WASD movement, mouse aim, Space evade, move-direction case, neutral／aim fallback,
  boundary behavior, and repeated-input rejection on the release-equivalent build.
- User feel: request and quote only if the user actually performs the build; do not infer from automation or QA function checks.
- Physical gamepad: `Not run / Deferred`; mapping tests remain automation only.
- Authority reset seam: automated verification is sufficient; defeat／retry manual flow is out of scope.

### J. Evidence and routing

- Required report: `docs/test-reports/phase2-slice2a-validation.md`
- New raw evidence only: `docs/test-reports/evidence/phase2-slice2a/`
- Record tested commit, environment, exact commands, exit codes, fresh assertions, manual steps, actual results,
  screenshot／JSON／stdout paths, and SHA-256 where applicable.
- Separate `Pass`, `Fail`, `Blocked`, and `Not run` by evidence type.
- Defect evidence returns to `00`; specification ambiguity goes to `OPEN_QUESTIONS.md` without QA resolution.
- Final output is only a Slice 2-A `Pass / Fail / Blocked` recommendation. QA does not approve Gate 2 or authorize 2-B.

## Initial precheck (historical)

- ZIP SHA-256: Match
- EXE SHA-256: Match
- Git LFS: Real artifacts present
- OS: Windows 11 Home `10.0.26200`
- GPU: `Intel(R) Graphics`
- GPU driver: `32.0.101.7077` (`2025-09-16`)
- Windows power plan display name: `バランス`
- AC/DC power mode GUID: `961cc777-2547-4f9d-8174-7d86181b8a7a` (`Best Power Efficiency`)
- OD-004 power result: Fail / Best performance revalidation required
- Gamepad: Not owned / Windows not detected / Deferred to Gate Playability
- KBM user overall feel: `問題なし`
- Gate recommendation at precheck: Not approved / Pending

## Latest execution — MFO-WO-P1-G1-002

- Status: QA execution complete / accepted by `00統括`
- Commit tested: repository HEAD `e95b1442759b8b43a3a62a555af4d0e96384dd81`; packaged runtime source baseline `a13505e8fbf82962e049b9101a87593a6692d2c7`
- Environment: Windows 11 Home build `26200`, Intel Core 7 150U, Intel Graphics driver `32.0.101.7077`, 1920×1080 at 60.0007 Hz, standard quality, release-equivalent packaged EXE
- AC power: Online / charging
- AC power mode: Best performance / `ded574b5-45a0-4f42-8737-46345c09c238`
- Power plan: `バランス` / `381b4222-f694-41f0-9685-ff5bb260df2e`（power modeとは別記録）
- DC power mode: Best Power Efficiency / `961cc777-2547-4f9d-8174-7d86181b8a7a`（変更なし）
- Commands and exit codes: empty `0`; arena idle `0`; raw outputとcommand recordを新規evidenceへ保存
- Empty result: 120 warmup＋600 samples、P95 `16.6667 ms`、59.9406 fps from average、Pass
- Arena result: 120 warmup＋600 samples、P95 `16.6667 ms`、59.8417 fps from average、HUD `16.67 ms`とJSON一致、Pass
- Automated result referenced: Phase 1 assertions 36 / 36 Pass（既存記録。今回再実行なし）
- RuntimeHardLimit: RHL-001 N/A、RHL-002 Pass、RHL-003 N/A、violation 0
- Manual KBM evidence: release buildでmove／aim／provisional attack／hitを既存確認
- User KBM feel: `問題なし`（overallだけ）
- Manual gamepad: Not run / Deferred to Gate Playability
- Effort evidence: `26 / 188 = 13.83%`を再計算、Pass。実績時間ではない
- Performance scope: Gate 1 idle baselineのみ。Gate 7／stress／製品最低環境の合格ではない
- Memory / GPU timing: unavailable。合格証拠として扱わない
- Evidence: [`../test-reports/evidence/phase1-gate1/power-revalidation-20260714-best-performance/`](../test-reports/evidence/phase1-gate1/power-revalidation-20260714-best-performance/)
- Test report: [`../test-reports/phase1-gate1-power-revalidation.md`](../test-reports/phase1-gate1-power-revalidation.md)
- Known issues added: 0
- Open questions added: 0
- Gate recommendation: **Pass**
- Gate approval: [`GATE-1`](../../material-frontier-online/decisions/2026-07-14-gate-1-approval.md)でPass

## Current evidence

- `material-frontier-online/deliverables/phase1/evidence/phase1-empty-performance.json`
- `material-frontier-online/deliverables/phase1/evidence/phase1-arena-performance.json`
- `material-frontier-online/deliverables/phase1/evidence/phase1-arena-capture.png`
- `material-frontier-online/deliverables/phase1/MFO-Phase1-Windows-x86_64.zip`
- `material-frontier-online/implementation/2026-07-14-phase1-technical-baseline.md`

Recorded: 36 / 36 assertions, empty P95 16.667ms, arena idle P95 16.667ms, export/smoke Pass。
旧P95の測定時power modeは未記録であり、今回のOD-004適合証拠へ流用しない。新しい再実行結果と区別する。

## Gate 1 work queue

1. ~~`MFO-WO-P1-G1-002`の記録様式を準備する。~~ Done
2. ~~成果物がLFS pointerではなく実体であることを確認する。~~ Pass
3. ~~AC接続中にWindows power modeをBest performanceへ変更・再読込する。~~ Pass
4. ~~AC GUID、power plan、GPU、driver、resolution、refresh、quality、buildを記録する。~~ Pass
5. ~~empty／arena idleを600 samplesで再計測し、HUD、JSON、screenshot、raw stdout、hashを保存する。~~ Pass
6. ~~[工数再見積り](../phase1-effort-reestimate.md)の`26 / 188 = 13.83%`を再検算する。~~ Pass
7. ~~KBM実動作、user overall feel、gamepad Not runを別fieldで集約する。~~ Done
8. ~~Pass／Fail／Blocked／Not runを分け、Gate 1合否を監督へ勧告する。~~ Pass recommendation submitted
9. ~~`00統括`によるevidence reviewとGate 1判定を待つ。~~ Gate 1 Pass / accepted

`30`はuserの体感を推測・代行しない。gamepad未所持中はmanufacturer／model／接続方式を繰り返し質問しない。
Gate 1 queue is closed. Current QA scope is only the active Slice 2-A order and only after its required handoff point.

## Representative commands

`godot`はGodot 4.7 stable console executableへのpathまたはaliasとする。

```powershell
godot --headless --editor --path material-frontier-online/prototype --quit
godot --headless --path material-frontier-online/prototype --script res://tests/run_phase1_tests.gd
godot --headless --path material-frontier-online/prototype `
  --export-release "Windows Desktop" build/windows/MFO-Phase1.exe
```
計測は `material-frontier-online/prototype/README.md` のrelease EXE手順を使う。外部入力を停止したidle測定と
通常起動の操作感確認を混ぜない。

## Review rules

- idle baselineを`PrototypeStressTarget`、Gate 7、製品性能の合格と呼ばない。
- RHL-001／003 N/Aを実機能のPassと呼ばない。
- 自動mapping testを実ゲームパッド手動確認の代わりにしない。
- KBM overall feelをgamepadまたは個別feel項目のPassへ拡張しない。
- raw command、stdout、exit code、commit、environment、evidence pathを保存する。
- defectは`KNOWN_ISSUES.md`、仕様不足は`OPEN_QUESTIONS.md`へ分ける。
- QAはGateを承認せず、証拠付きの勧告を提出する。

## Required handoff update

```text
Status:
Work order:
Commit tested:
Environment:
Commands and exit codes:
Phase 1 regression:
Slice 2-A automated results:
Manual KBM functional evidence:
User feel (only if actually requested):
Manual gamepad: Not run / Deferred
Performance result and scope:
Artifacts / hashes:
Known issues added:
Open questions added:
Slice recommendation: Pass / Fail / Blocked
Reasons:
```
