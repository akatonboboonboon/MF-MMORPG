# Material Frontier Online — Implementation Status

- Updated: 2026-07-14 (Asia/Tokyo)
- Current phase: Phase 2 / Slice 2-A correction QA Fail; functional checks Pass; performance diagnostic active; KBM Blocked
- Gate 0: Open
- Gate 1: Pass / approved 2026-07-14
- Gate 2: Locked / not evaluated
- Phase 2: `MFO-WO-P2-2A-003` active; `MFO-WO-P2-2A-001` and `-002` returned; all unlisted scope locked
- Phase 1 runtime baseline: `a13505e8fbf82962e049b9101a87593a6692d2c7`
- Slice 2-A diagnostic ancestry base: `df0cd0cd17793fc2d9e0cc80d29249b3ceca5dd0`; assignee starts from the pushed order commit

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

Active diagnostic order:
[`MFO-WO-P2-2A-003`](work-orders/phase2-slice2a-performance-diagnostic.md)

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
- [ ] Slice 2-A ground-step回避の監督受理（機能修正Pass、性能診断・KBM完遂待ち）
- [ ] 被弾、戦闘不能、リトライ
- [ ] 3素材、3魔法
- [ ] バーストボア、部位破壊、AI、死体、剥ぎ取り
- [ ] 飲料充填工場、可逆コンベア、CIP洗浄水
- [ ] 本番UI、アート、VFX、音響
- [ ] 最大負荷代理／Gate 7性能試験
- [ ] MMO通信、アカウント、永続化、課金

## Current authorized work

Active QA diagnostic order:
[`MFO-WO-P2-2A-003`](work-orders/phase2-slice2a-performance-diagnostic.md)

Returned correction order:
[`MFO-WO-P2-2A-002`](work-orders/phase2-slice2a-nonzero-direction-correction.md)

Returned original order:
[`MFO-WO-P2-2A-001`](work-orders/phase2-slice2a-basic-operation.md)

Completed work order: [`work-orders/phase1-gate1-power-revalidation.md`](work-orders/phase1-gate1-power-revalidation.md)

Deferred work order: [`work-orders/phase1-gate1-manual-validation.md`](work-orders/phase1-gate1-manual-validation.md)

1. `30`だけがdiagnostic order記載のreport／new evidence／QA handoffを変更する。
2. `30`はA／B／C buildを固定順で比較し、corrected-release KBM checklistを一つのsessionで完遂する。
3. `10`は性能とcodeの相関範囲が証拠で確定し、別work orderが出るまでgame codeを変更しない。
4. `20`はintegrationを行わず、別fileのnon-binding proposalだけを維持する。
5. OD-026 HUD、OD-027 damage penalty、2-B正式攻撃、2-C損傷、2-D event／表示は別work orderまでlockする。
6. 物理gamepad証拠はGate PlayabilityまでDeferredとして追跡する。

Slice 2-A diagnostic orderの発行はGate 2を開かず、2-B以降を自動許可しない。
