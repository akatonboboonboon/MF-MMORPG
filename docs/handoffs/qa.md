# QA / Performance / Review Handoff

- Owner role: `30 QA・性能・レビュー`
- Updated by `30 QA`, accepted by `00統括`: 2026-07-14
- Current milestone: M2 / Slice 2-A
- Authorization: `00統括` approved MFO-WO-P2-2A-001 Stage B formal validation at `92f71d7`
- Phase 1 package source baseline: `a13505e8fbf82962e049b9101a87593a6692d2c7`
- Required starting state: commit containing the active work order; record exact tested `HEAD`
- Current status: Slice 2-A Stage B executed / **Fail recommendation returned to 00**
- QA planning base: `afcd20cd4a02d618a5d7e0e4bc7555a64fa90740`

Active work order: [`../work-orders/phase2-slice2a-basic-operation.md`](../work-orders/phase2-slice2a-basic-operation.md)

Required Slice 2-A report: [`../test-reports/phase2-slice2a-validation.md`](../test-reports/phase2-slice2a-validation.md)

Completed Gate 1 work order: [`../work-orders/phase1-gate1-power-revalidation.md`](../work-orders/phase1-gate1-power-revalidation.md)

Gate 1 report: `docs/test-reports/phase1-gate1-power-revalidation.md`

Deferred gamepad work order: [`../work-orders/phase1-gate1-manual-validation.md`](../work-orders/phase1-gate1-manual-validation.md)

Previous report: [`../test-reports/phase1-gate1-manual-validation.md`](../test-reports/phase1-gate1-manual-validation.md)

## Stage B formal result — MFO-WO-P2-2A-001

- QA branch: `codex/phase2-slice2a-qa`
- QA start HEAD: `92f71d7c3e55108a2faecaa6fbf1e1055b0d0b9f`
- Implementation source: `bd01fdf3d048accaa7f5be93afe3be5cfa138201`
- Comparison baseline: `afcd20cd4a02d618a5d7e0e4bc7555a64fa90740`
- QA tests／report commit: `TO_BE_RECORDED_AFTER_QA_CONTENT_COMMIT`
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

## Next queue — MFO-WO-P2-2A-001

1. Before the `10` handoff, draft acceptance cases only; do not edit gameplay or freeze an unreturned interface.
2. After the handoff, record the exact tested commit and modify only QA-owned tests／report／evidence.
3. Run fresh Phase 1 regression, Slice 2-A deterministic tests, import／headless smoke, release／export smoke, and
   the conditional arena-idle regression described by the work order.
4. Check KBM movement／aim／Space evade separately from automation and human feel.
5. Keep physical gamepad `Not run / Deferred`; do not infer hardware behavior from mapping tests.
6. Return `Pass / Fail / Blocked` recommendation to `00`. Do not approve Gate 2 or authorize Slice 2-B.

## Pre-handoff test plan — MFO-WO-P2-2A-001

State: **Drafted from approved behavior only / no test implementation before `10` handoff**

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
