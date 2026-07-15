# Material Frontier Online — Implementation Status

- Updated: 2026-07-16 (Asia/Tokyo)
- Current phase: Phase 2 / Slice 2-A functional checks and corrected-C KBM Pass; correction performance Fail retained; controlled matrices valid run 0; QA harness contract correction and requalification active under performance hold
- Gate 0: Open
- Gate 1: Pass / approved 2026-07-14
- Gate 2: Locked / not evaluated
- Phase 2: `MFO-WO-P2-2A-001` through `-007` returned; `MFO-WO-P2-2A-008` contract-correction-requalification-only order active; `MFO-HOLD-P2-2A-001` remains active for performance acceptance
- Phase 1 runtime baseline: `a13505e8fbf82962e049b9101a87593a6692d2c7`
- Slice 2-A hold basis: QA closure `54a69441ff50fa345a01e6a831a100a1f687e033`
- Latest harness closure: `dc6d82115f42132a6f7e6424ea77c8c2cc3ebaee`

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

Active performance hold — correction／requalification exception active:
[`MFO-HOLD-P2-2A-001`](work-orders/phase2-slice2a-performance-external-hold.md)

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
| Active order | [`MFO-WO-P2-2A-008`](work-orders/phase2-slice2a-harness-contract-correction-requalification.md) |
| Authorized execution | Three exact PREACK／activation contract corrections, seal-before contract tests, new-stage harness requalification only |
| Explicitly forbidden | Performance slot, P95, KBM, game code／value／test changes, old-stage reuse, Gate 2／Slice 2-B |
| Next authority | `30` returns requalification `Pass / Fail / Blocked`; `00` alone decides whether to issue a separate measurement order |

The fresh PREACK OneDrive count `0` is valid only for the failed `-006` pre-ack. It is not a performance run and does
not establish the missing LIVE interval. `-007` did not start PREACK because its sealed contract audit failed. `-008`
must establish a new complete persisted count-zero interval and performance slot count `0` after its seal-before
contract tests pass.

Formal harness qualification report:
[`test-reports/phase2-slice2a-harness-qualification.md`](test-reports/phase2-slice2a-harness-qualification.md)

## Harness ABI correction and PREACK contract result

| Item | Recorded result / boundary |
|---|---|
| Returned order / QA closure | [`MFO-WO-P2-2A-007`](work-orders/phase2-slice2a-harness-correction-requalification.md) / `dc6d82115f42132a6f7e6424ea77c8c2cc3ebaee` |
| Stage / manifest | `p2-2a-007-qp-20260715t231258jst-2e92cc8-c1` / `e44acd54ba1b1f01e7628d9a3899242a43fa16164fa9c78bd4d355dff8314c67` |
| ABI preparation result | direct-`out Guid` static audit, `QP_DRYRUN`, `QP_SELFTEST`, and same-production-path power／input smoke Pass |
| Terminal defects | preparation receipt identity missing; exact activation still `-006 START_ACK`; expected values asserted before complete PREACK record persistence／readback／hash |
| Informational supervisor pre-READY host observation | OneDrive-family count reached `0`; configured AC mode read back `ded574b5-45a0-4f42-8737-46345c09c238`, but direct effective-overlay readback remained `961cc777-2547-4f9d-8174-7d86181b8a7a`. READY was not sent; fresh `-008` check remains mandatory |
| Terminal classification | **Fail / harness defect accepted** |
| Not run | PREACK, `PREACK_READY`, `START_ACK`, LIVE, P95, KBM, A／B／C; performance slot launch count `0` |
| Freeze | external stage `85 / 85` ReadOnly; `runs/` absent; repair／reseal／retry none |
| Evidence manifest | `465db27591c3cd26be0cd0594cb46bb214a016e27a4f0779f4e896153833205a`; supervisor check `86 / 86` match |
| Active successor | [`MFO-WO-P2-2A-008`](work-orders/phase2-slice2a-harness-contract-correction-requalification.md) |
| Successor boundary | receipt hash／fields binding, exact `-008 START_ACK`, complete-record persist-before-assert; seal-before positive／negative contract tests; slot `0` |

Formal `-007` report:
[`test-reports/phase2-slice2a-harness-requalification.md`](test-reports/phase2-slice2a-harness-requalification.md)

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

Active contract-correction／requalification-only order:
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

1. `30`は`MFO-WO-P2-2A-008`の3件のharness契約限定修正、seal前contract self-test、新stage再資格確認だけを実行し、performance slot countを`0`に保つ。
2. `-008`は`-007` Failの監督レビュー後に発行した新しい明示票であり自動retryではない。消費済みstageの修理／再利用、KBM、追加performance測定を行わない。
3. `10`はgame code、値、profiling seam、性能修正を変更しない。
4. `20`はintegrationを行わず、別fileのnon-binding proposalだけを維持する。
5. OD-026 HUD、OD-027 damage penalty、2-B正式攻撃、2-C損傷、2-D event／表示は別work orderまでlockする。
6. 物理gamepad証拠はGate PlayabilityまでDeferredとして追跡する。
7. userは`PREPARED`後の`QUALIFICATION WINDOW READY`前にOneDriveを閉じ、AC onlineとeffective overlay `ded574b5-45a0-4f42-8737-46345c09c238`を確認する。READY送信から終了通知までOneDriveを再起動しない。キーボード／マウス停止は`START_ACK`送信直後からであり、それ以前の通常操作は妨げない。account識別子取得は行わない。

資格確認Passでもperformance acceptance、Gate 2、2-B以降を自動許可しない。
