# Material Frontier Online — Implementation Status

- Updated: 2026-07-16 (Asia/Tokyo)
- Current phase: Phase 2 / Slice 2-A functional checks and corrected-C KBM Pass; correction performance Fail retained; controlled matrices valid run 0; non-performance QA harness qualified; `MFO-WO-P2-2A-010` pre-PREPARED Blocked retained; R1 Fail and R2 Blocked returned; Recovery Step R3 active; performance not started
- Gate 0: Open
- Gate 1: Pass / approved 2026-07-14
- Gate 2: Locked / not evaluated
- Phase 2: `MFO-WO-P2-2A-001` through `-009` returned; `-009` Pass / harness qualified accepted; `MFO-HOLD-P2-2A-001` remains active; `MFO-WO-P2-2A-010` is the sole active QA execution order under pre-PREPARED Recovery Step R3
- Phase 1 runtime baseline: `a13505e8fbf82962e049b9101a87593a6692d2c7`
- Slice 2-A hold basis: QA closure `54a69441ff50fa345a01e6a831a100a1f687e033`
- Latest harness closure: `35bfcf1f4efe7fe231c2956a6fa741c4acd81f3c`

凍結仕様内の`Gate 0: Closed`と未承認P0表は履歴状態である。現在値は
[`DECISIONS.md`](DECISIONS.md) とGate 0決定記録を正とする。

## Phase 1 — Technical baseline

### Implemented

- [x] Godot Engine 4.7 stable / GDScript / GL Compatibilityプロジェクト
- [x] Windows x86_64 portable export preset
- [x] 1920×1080固定方角2D検証面
- [x] KBM／ゲームパッドを共通抽象入力へ変換
- [x] 右スティック照準保持と実マウス移動による所有権切替
- [x] 8方向移動と独立全方向照準
- [x] stable actor IDを持つ1要素Actor集合
- [x] optional `target_entity_id` 境界と未知Actor拒否
- [x] debug-only仮攻撃Aと静的標的
- [x] Action／Effectリソース定義
- [x] player-critical判定予約、技別容量1、取得・必須返却
- [x] `DomainEvent` とcommand tick保持
- [x] 最小デバッグHUD、イベントログ、性能レコーダー
- [x] RHL-001～003の起動時記録（未実装範囲はN/A）
- [x] 真の空シーン／アリーナ切替bootstrap
- [x] Windows release export、EXE smoke、ZIP展開後smoke

### Verification on record

| Check | Recorded result | Scope note |
|---|---|---|
| Automated assertions | 36 / 36 Pass | Phase 1 deterministic tests |
| Project import / parse | Pass | Godot 4.7 stable |
| Main scene headless smoke | Pass | Phase 1 bootstrap |
| Windows export | Pass | Release-equivalent |
| Exported EXE / extracted ZIP smoke | Pass | Exit code 0 |
| RuntimeHardLimit startup | RHL-001 N/A / RHL-002 Pass / RHL-003 N/A / 0 violations | Phase 1 active scope only |
| Empty scene P95 | 16.6667 ms | AC Best performance、120 warmup + 600 samples、exit 0 |
| Arena idle P95 | 16.6667 ms | AC Best performance、HUD 16.67ms一致、exit 0。idleでありstress targetではない |
| KBM move / aim / hit | Observed | Manual observation, gamepadではない |

Artifacts and hashes are recorded in
[`../material-frontier-online/implementation/2026-07-14-phase1-technical-baseline.md`](../material-frontier-online/implementation/2026-07-14-phase1-technical-baseline.md).

Gate 1 revalidation: [`test-reports/phase1-gate1-power-revalidation.md`](test-reports/phase1-gate1-power-revalidation.md)

## Slice 2-A Stage B result

| Item | Recorded result |
|---|---|
| Implementation source | `bd01fdf3d048accaa7f5be93afe3be5cfa138201` |
| Gameplay handoff | `92f71d7c3e55108a2faecaa6fbf1e1055b0d0b9f` |
| QA closure HEAD | `c0df756e72576a1367cf5282cef7138014cae591` |
| Phase 1 fresh regression | `36 / 36 Pass` |
| Slice 2-A fresh suite | `119 / 120 Pass`, exit `1` |
| Confirmed defect | `MFO-P2-2A-QA-001` / [`KI-009`](KNOWN_ISSUES.md) |
| Priority / impact | P1 Slice acceptance blocker / runtime Low |
| Build checks | import、main smoke、release export、exported smoke Pass |
| Performance | Blocked / Not run because AC Offline |
| KBM function / user feel | Not run on failing candidate; KBMはcorrection再検証、user feelはuser実施時だけ分離記録 |
| Physical gamepad | Not run / Deferred |
| Recommendation | **Fail accepted by `00統括`** |

The failure was not a new specification question. OD-020 already requires movement input that remains nonzero after
the configured input deadzone to take priority over aim fallback. The returned correction order authorized changes
only to the two evade direction checks; deadzone、distance、duration、reuse、aim behavior and all later slices remain
unchanged.

Formal report: [`test-reports/phase2-slice2a-validation.md`](test-reports/phase2-slice2a-validation.md)

## Slice 2-A correction revalidation result

| Item | Recorded result |
|---|---|
| Correction implementation | `5261a73707daca03cb160e03a12247886d3f5cce` |
| Gameplay handoff | `0727fe562c20fcb781eb9b1d63b260eb9a94f333` |
| QA content／closure | `5475541` / `df0cd0c` |
| Phase 1 regression | `36 / 36 Pass` |
| Unchanged Slice 2-A suite | `120 / 120 Pass`, original SHA unchanged |
| Additive correction suite | `39 / 39 Pass` |
| Functional correction | Pass: exact zero、small nonzero、distance／duration、12／27 ticks、no-buffer、collision、bounds、reset |
| Build checks | import、main smoke、release export、exported smoke all exit `0` |
| Performance | **Fail**: AC Best performance P95 `33.4643 ms` and `20.0000 ms` vs `<= 16.67 ms` |
| Performance causality | Not isolated; no game-code attribution or game-value change authorized |
| Corrected-release KBM | `Blocked / Not completed`; no functional Fail classification |
| User feel / physical gamepad | Not run / `Not run / Deferred` |
| Supervisor disposition | Functional correction verified; Slice not accepted; QA-only diagnostic issued |

Formal correction report:
[`test-reports/phase2-slice2a-correction-validation.md`](test-reports/phase2-slice2a-correction-validation.md)

## Slice 2-A performance diagnostic result

| Item | Recorded result |
|---|---|
| Work order / QA start | `MFO-WO-P2-2A-003` / `f3450df` |
| QA content / closure | `a3920f8` / `701bfcc` |
| A／B／C integrity | Pass: source、MZ、size、SHA-256、B→C two-line runtime delta verified |
| Scheduled performance | A1／B1／C1 invalid; C2 evidence incomplete; B2／A2 Not run |
| Valid acceptance runs | **0** |
| Host condition | continuous Windows-session input, mostly non-game foreground, system CPU avg `72.838%–87.620%`, substantial OneDrive load; user later reported a red-X unsynchronized state and suspects the free-plan 5 GB limit, root cause unconfirmed |
| Performance disposition | **Blocked / causality not isolated**; invalid P95 values are reference only |
| Corrected-C KBM | **Blocked**; not an uninterrupted fresh session and checklist incomplete |
| Gameplay defect finding | None; no game-code or game-value change authorized |
| Supervisor disposition | Blocked accepted; prior correction performance Fail remains on record; new controlled rerun issued |

Formal diagnostic report:
[`test-reports/phase2-slice2a-performance-diagnostic.md`](test-reports/phase2-slice2a-performance-diagnostic.md)

## Slice 2-A controlled rerun result

| Item | Recorded result |
|---|---|
| Work order / QA start | `MFO-WO-P2-2A-004` / `67ba7f3` |
| QA content / closure | `45eeeb3` / `bfaff7b` |
| A／B／C identity | size、SHA-256、`MZ` all exact Pass |
| Preflight | OneDrive-family `32.15625 CPU-s`; system CPU avg／max `38.250224%`／`46.012270%` — Fail |
| Performance matrix | A1 through A2 all Not run; valid run `0`; P95 not evaluated |
| Performance component | **Blocked / matrix not started** |
| Corrected-C KBM | **Pass**: independent attempt 3 `27.973 s`, stable foreground, all six items, intentional input |
| User feel | **Pass / `すべて問題ないです`** |
| Physical gamepad | Not run / Deferred |
| Supervisor audit | Blocked arithmetic and KBM evidence supported; two post-activation copy／hash cycles and controller／observer limitations recorded |
| Supervisor disposition | Overall Blocked accepted; KBM frozen; performance-only final rerun issued; no gameplay edit |

Formal controlled-rerun report:
[`test-reports/phase2-slice2a-controlled-rerun.md`](test-reports/phase2-slice2a-controlled-rerun.md)

## Slice 2-A performance-only rerun result

| Item | Recorded result |
|---|---|
| Work order / QA start | `MFO-WO-P2-2A-005` / `b32fdae` |
| QA content / closure | `60dd270` / `54a6944` |
| Stage / PREPARED manifest | `p2-2a-005-20260715t0944jst-b32fdae` / `ac2c34644f7d3f2a92d39ebf54f64b1984c14fb330d31ec22b57035381334aa1` |
| Stage P | Sealed／dry-run Pass; performance slot launch count `0` |
| Activation prerequisite | **Not established**: required external pre-ack evidence was not preserved before start acknowledgement |
| Settled interval | Controller detected OneDrive-family presence and terminated before completion; trigger name／PID not persisted |
| Later corroboration | `OneDrive.Sync.Service` PID `13496`; not treated as the trigger sample |
| Matrix / P95 | slots `0`; valid matrix `0`; P95 unavailable／uninterpreted |
| Harness evidence | auxiliary TickCount64 field `0`; actual deadline used nonzero Stopwatch origin; trigger persistence／exit／streams incomplete |
| Post-run identity | controller／manifest／A／B／C exact match |
| Recommendation / disposition | **Blocked accepted / Slice 2-A unaccepted / external-state hold** |

Formal performance-only report:
[`test-reports/phase2-slice2a-performance-only-rerun.md`](test-reports/phase2-slice2a-performance-only-rerun.md)

Active performance hold:
[`MFO-HOLD-P2-2A-001`](work-orders/phase2-slice2a-performance-external-hold.md)

Sole active execution exception — qualified-harness performance acceptance:
[`MFO-WO-P2-2A-010`](work-orders/phase2-slice2a-qualified-harness-performance-acceptance.md)

## Host recovery and harness qualification result

| Item | Recorded result / boundary |
|---|---|
| User-reported OneDrive allocation | `100 GB`; UI shows `4.8 GB` used and a green client-level backup／sync indicator |
| Generated-link cleanup verification | Documents roots traversed through cloud markers; `2,005` directories, actual junction／symlink `0`, scan errors `0` |
| Preliminary process observation | `OneDrive*` count `2` before normal shutdown request, delayed transition to count `0`; MFO repository remained present |
| Evidence meaning | Material host-condition change accepted for qualification consideration only; residual red Explorer overlays are not acceptance evidence |
| Returned order / QA closure | [`MFO-WO-P2-2A-006`](work-orders/phase2-slice2a-harness-qualification.md) / `47d8ca6e04a3f32f6a120b998fc9e4ca0f0e7fa1` |
| QA execution HEAD | `e87bf429e9b7b18ad717ffb0314e7c2052b013e0` |
| Stage / preparation manifest | `p2-2a-006-qp-20260715t184405jst-2d5ef1a-c1` / `582c65b3430a26834d92bc19951a0f5ebf92b8bf7b4853d8aadddb07de0eb8f7` |
| Fresh PREACK prerequisite | OneDrive-family count `0` persisted; power／input record not produced because the API path crashed |
| Harness terminal | launcher `-1073741819` / `0xC0000005`; runner `30 / Fail`; **Fail / harness defect accepted** |
| Defect | `MFO-P2-2A-QA-003`: `PowerGetEffectiveOverlayScheme(out IntPtr)` plus pointer dereference／`LocalFree` ABI mismatch |
| Not run | `PREACK_READY`, `START_ACK`, LIVE, controller, P95, KBM; performance slot launch count `0` |
| Evidence manifest | `b2cb41b04ff4928c45be1065e5e4e0f944137b89cf962b18b92f429fef6722bd`; supervisor check `33 / 33` match |
| Returned successor | [`MFO-WO-P2-2A-007`](work-orders/phase2-slice2a-harness-correction-requalification.md): Fail / harness defect before PREACK |
| Returned successor | [`MFO-WO-P2-2A-008`](work-orders/phase2-slice2a-harness-contract-correction-requalification.md): Fail / harness defect after LIVE |
| Returned final successor / QA closure | [`MFO-WO-P2-2A-009`](work-orders/phase2-slice2a-harness-live-evidence-correction-requalification.md) / `35bfcf1f4efe7fe231c2956a6fa741c4acd81f3c` |
| Harness qualification | **Pass / harness qualified accepted**; all five preparation modes, PREACK, exact activation, corrected LIVE evidence and cleanup Pass |
| Not run | Performance slot, P95, KBM, A／B／C, game; slot count `0` |
| Next authority | `MFO-WO-P2-2A-010` active: fresh qualified stage, exact activation, one fixed A／B／C matrix; supervisor reviews the result |

The fresh PREACK OneDrive count `0` from `-006` was only a failed pre-ack. `-007` did not start PREACK. `-008` later
established a complete host-stable count-zero 61-sample LIVE interval and global slot count `0`, but failed its explicit
per-sample, sentinel-order, and LIVE-evaluation evidence contract. The later `-009` qualification closed that harness
contract gap, but neither interval is a performance run or replaces the later performance acceptance matrix.

Formal harness qualification report:
[`test-reports/phase2-slice2a-harness-qualification.md`](test-reports/phase2-slice2a-harness-qualification.md)

## Harness ABI correction and PREACK contract result

| Item | Recorded result / boundary |
|---|---|
| Returned order / QA closure | [`MFO-WO-P2-2A-007`](work-orders/phase2-slice2a-harness-correction-requalification.md) / `dc6d82115f42132a6f7e6424ea77c8c2cc3ebaee` |
| Stage / manifest | `p2-2a-007-qp-20260715t231258jst-2e92cc8-c1` / `e44acd54ba1b1f01e7628d9a3899242a43fa16164fa9c78bd4d355dff8314c67` |
| ABI preparation result | direct-`out Guid` static audit, `QP_DRYRUN`, `QP_SELFTEST`, and same-production-path power／input smoke Pass |
| Terminal defects | preparation receipt identity missing; exact activation still `-006 START_ACK`; expected values asserted before complete PREACK record persistence／readback／hash |
| Informational supervisor pre-READY host observation | OneDrive-family count reached `0`; configured AC mode read back `ded574b5-45a0-4f42-8737-46345c09c238`, but direct effective-overlay readback remained `961cc777-2547-4f9d-8174-7d86181b8a7a`. `-007` READY was not sent; the later fresh `-008` check completed as recorded below |
| Terminal classification | **Fail / harness defect accepted** |
| Not run | PREACK, `PREACK_READY`, `START_ACK`, LIVE, P95, KBM, A／B／C; performance slot launch count `0` |
| Freeze | external stage `85 / 85` ReadOnly; `runs/` absent; repair／reseal／retry none |
| Evidence manifest | `465db27591c3cd26be0cd0594cb46bb214a016e27a4f0779f4e896153833205a`; supervisor check `86 / 86` match |
| Returned successor | [`MFO-WO-P2-2A-008`](work-orders/phase2-slice2a-harness-contract-correction-requalification.md): Fail / harness defect after LIVE |
| Successor boundary | receipt hash／fields binding, exact `-008 START_ACK`, complete-record persist-before-assert; seal-before positive／negative contract tests; slot `0` |

Formal `-007` report:
[`test-reports/phase2-slice2a-harness-requalification.md`](test-reports/phase2-slice2a-harness-requalification.md)

## Harness contract and LIVE-evidence result

| Item | Recorded result / boundary |
|---|---|
| Returned order / QA closure | [`MFO-WO-P2-2A-008`](work-orders/phase2-slice2a-harness-contract-correction-requalification.md) / `1ab2ccb4cd5b9dc8b44c5130cb942c6255a5f42c` |
| Stage / supplied manifest | `p2-2a-008-qp-20260716T094018jst-e313475-c2` / `a88e45cee008c2f774950b7c7144d7f5b263cd3502c97cb87922cd11c0497202` |
| PREACK / activation | PREACK Pass; exact user `START_ACK` 519 UTF-8 bytes, no BOM／trailing newline, SHA-256 `1a5a25b1ffd449ed545ba14eb8f373753c189a03da37099a6b27b35c6647bce0` |
| Host-stable evidence | `61 / 61` samples: OneDrive-family `0`, AC online, Best-performance overlay, stable input, forbidden runtime `0`; global performance slot count `0` |
| Terminal defects | `MFO-P2-2A-QA-005`: per-sample slot field absent; `QA-006`: `n=0` persisted before sentinel cleanup; `QA-007`: runner／launcher LIVE evaluation completeness result absent |
| Terminal classification | **Fail / harness defect accepted**; user activation and host prerequisites are not the cause |
| Not run | Performance slot, P95, KBM, A／B／C, exported game, frame recorder, physical gamepad |
| Freeze / manifest | stage `149 / 149` ReadOnly; runtime evidence `27 / 27` ReadOnly; residual runtime `0`; evidence `321 / 321` match; `SHA256SUMS.txt` SHA-256 `58827846f38becad61f08104db889f27b78f68e34f36527a891b5b8967200e25` |
| Returned successor | [`MFO-WO-P2-2A-009`](work-orders/phase2-slice2a-harness-live-evidence-correction-requalification.md): Pass / harness qualified |
| Successor boundary | Exactly the three LIVE-evidence corrections, production-bound seal-before tests, and one fresh non-performance requalification; performance slot remains `0` |

Formal `-008` report:
[`test-reports/phase2-slice2a-harness-contract-requalification.md`](test-reports/phase2-slice2a-harness-contract-requalification.md)

## Harness LIVE-evidence correction and qualification result

| Item | Recorded result / boundary |
|---|---|
| Returned order / QA closure | [`MFO-WO-P2-2A-009`](work-orders/phase2-slice2a-harness-live-evidence-correction-requalification.md) / `35bfcf1f4efe7fe231c2956a6fa741c4acd81f3c` |
| PREPARED / runtime evidence commit | `a595743b6d67093904bd374bae4dbf8dbbd43067` / `132c18889b5655518b1feba1391c5ffa1cb6cf3f` |
| Stage / manifest | `p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1` / `da49eaf1d24dfce39dba43d6babd649c77809450c5257696405cb15393acdcbf` |
| Qualification | Five Stage P modes Pass; PREACK runner／launcher Pass; exact 519-byte activation Pass; LIVE runner／launcher／controller Pass |
| Corrected evidence | `61 / 61` samples contain slot `0`; sentinel completion precedes `n=0`; both LIVE evaluations record readback and completeness success |
| Host / cleanup | `61 / 61` OneDrive `0`, AC online, Best performance, stable input; final owned runtime and residual MfoQa process `0` |
| Terminal classification | **Pass / harness qualified accepted** |
| Not run | Performance slot, P95, KBM, A／B／C, game, physical gamepad |
| Evidence manifest | `267 / 267` match; SHA-256 `5504a7bebc51165a6faa84f0e7a75d98b388b4718aea032fad9ba7816a8451a2` |
| Post-return integrity | Two documentation blocks regressed to placeholders／CRLF; QA isolated the regression and restored exact HEAD bytes. Exact initiating process was not identified; placeholder hit `0`, diff `0`, new commit／evidence change `0` |
| Boundary | Non-performance harness qualification only; performance hold, Gate 2 lock, Slice 2-B prohibition and gamepad deferral remain unchanged |

Formal `-009` report:
[`test-reports/phase2-slice2a-harness-live-evidence-requalification.md`](test-reports/phase2-slice2a-harness-live-evidence-requalification.md)

## Gate 1 checklist

| Requirement | Status | Evidence / gap |
|---|---|---|
| ZIP／EXE hashとLFS実体 | Pass | `30 QA`事前確認で一致・実体確認 |
| 基準端末CPU/GPU/RAM/OS/解像度 | Pass | GPU `Intel(R) Graphics`を含め記録済み |
| Windows電源設定の実表示名 | Pass | AC online、Best performance、GUID=`ded574b5-45a0-4f42-8737-46345c09c238`。DCは変更なし |
| GPU driver | Pass | `32.0.101.7077` (`2025-09-16`) |
| 標準画質／release相当の実測設定 | Pass | packaged EXE、standard、1920×1080／60.0007Hz |
| HUDとJSONのP95一致 | Pass | 同一600サンプル、16.67ms |
| 起動時RuntimeHardLimit記録 | Pass for active scope | RHL-001/003はN/A |
| 空シーン1920×1080・60fps | Pass | Best performance、P95 `16.6667 ms`、600 samples、exit 0 |
| 仮プレイヤー移動・仮攻撃命中 | Pass on KBM | release buildで実動作確認済み |
| KBM人間評価 | Pass overall | user: `問題なし`。個別feel項目へは拡張しない |
| 物理gamepad LS／RS／主要アクション | Deferred / Not run | `GATE-1-INPUT-EVIDENCE`によりGate Playabilityまで延期。OD-013は維持 |
| Phase 1工数が試作全体の15%以下 | Pass by re-estimate | [保守式13.83%](phase1-effort-reestimate.md)。actual timeではない |
| network/account/payment非搭載 | Pass | スコープ外を維持 |

上記Gate 1条件はすべて解消され、QA Pass勧告を監督が受理した。Gate 1は2026-07-14付でPass。

## Explicitly not implemented

- [ ] 正式な快斬・重断
- [ ] `MaterialJob`、`CombatForm`、`EquipmentLoadout`、core `EquipmentRuntimeState`
- [ ] `Integrity`、`Deformation`、`Heat`、`BurnCurse`
- [ ] Slice 2-A ground-step回避の監督受理（機能修正・KBM Pass、performance external-state hold）
- [ ] 被弾、戦闘不能、リトライ
- [ ] 3素材、3魔法
- [ ] バーストボア、部位破壊、AI、死体、剥ぎ取り
- [ ] 飲料充填工場、可逆コンベア、CIP洗浄水
- [ ] 本番UI、アート、VFX、音響
- [ ] 最大負荷代理／Gate 7性能試験
- [ ] MMO通信、アカウント、永続化、課金

## Current authorized work

Active performance hold:
[`MFO-HOLD-P2-2A-001`](work-orders/phase2-slice2a-performance-external-hold.md)

Active qualified-harness performance acceptance order:
[`MFO-WO-P2-2A-010`](work-orders/phase2-slice2a-qualified-harness-performance-acceptance.md)

### MFO-WO-P2-2A-010 preparation state

| Item | Current fact |
|---|---|
| Returned classification | Underlying **pre-PREPARED Blocked** retained; R1 was source compile Fail; R2 is **Blocked / compile evidence incomplete** because numeric native exit was not persisted |
| Harness／performance classification | Not evaluated; this is neither harness Pass／Fail nor a performance result |
| Execution state | Stage／seal／PREACK／performance／A／B／C／game `0`; external run root absent; relevant process `0` |
| Candidate history | candidate-003／004, stopped scratch, candidate-005 frozen; exact fail-closed candidate-006 and its R2 DLL／evidence frozen |
| Current authority | Recovery Step R3: unchanged candidate-006 input, qualified exit-capture canary, one fresh native and conditional wrapper compile, then mandatory stop |
| Still prohibited | any source edit, candidate-007, generated output execution, PA self-test, StagePreparer, six-mode, stage／seal, PREACK, slots, A／B／C, game, retry |

Returned LIVE-evidence-correction／requalification order — Pass accepted:
[`MFO-WO-P2-2A-009`](work-orders/phase2-slice2a-harness-live-evidence-correction-requalification.md)

Returned contract-correction／requalification order:
[`MFO-WO-P2-2A-008`](work-orders/phase2-slice2a-harness-contract-correction-requalification.md)

Returned ABI-correction／requalification order:
[`MFO-WO-P2-2A-007`](work-orders/phase2-slice2a-harness-correction-requalification.md)

Returned qualification-only order:
[`MFO-WO-P2-2A-006`](work-orders/phase2-slice2a-harness-qualification.md)

Returned performance-only order:
[`MFO-WO-P2-2A-005`](work-orders/phase2-slice2a-performance-only-rerun.md)

Returned controlled-rerun order:
[`MFO-WO-P2-2A-004`](work-orders/phase2-slice2a-controlled-rerun.md)

Returned diagnostic order:
[`MFO-WO-P2-2A-003`](work-orders/phase2-slice2a-performance-diagnostic.md)

Returned correction order:
[`MFO-WO-P2-2A-002`](work-orders/phase2-slice2a-nonzero-direction-correction.md)

Returned original order:
[`MFO-WO-P2-2A-001`](work-orders/phase2-slice2a-basic-operation.md)

Completed work order: [`work-orders/phase1-gate1-power-revalidation.md`](work-orders/phase1-gate1-power-revalidation.md)

Deferred work order: [`work-orders/phase1-gate1-manual-validation.md`](work-orders/phase1-gate1-manual-validation.md)

1. `MFO-WO-P2-2A-009`はPass受理済みでclosedである。`MFO-WO-P2-2A-010`が`30`への唯一のactive execution orderであり、現在の許可はRecovery Step R3だけである。
2. `MFO-HOLD-P2-2A-001`を維持する。`-010`のperformance例外は未開始であり、R3はexit-capture canaryとcandidate-006のsyntax compileだけで停止する。
3. `10`はgame code、値、profiling seam、性能修正を変更しない。
4. `20`はintegrationを行わず、別fileのnon-binding proposalだけを維持する。
5. OD-026 HUD、OD-027 damage penalty、2-B正式攻撃、2-C損傷、2-D event／表示は別work orderまでlockする。
6. 物理gamepad証拠はGate PlayabilityまでDeferredとして追跡する。
7. `-010`の新しいPREPAREDまではuserは通常操作とOneDriveを継続でき、AC接続を維持する必要もない。監督が明示的にquiet windowを求めた後だけOneDriveを終了してAC／Best performanceを用意し、exact `START_ACK`後はQAの終了通知まで入力を止める。

Accepted harness qualification does not resolve performance acceptance, accept Slice 2-A, open Gate 2, or authorize Slice 2-B.
