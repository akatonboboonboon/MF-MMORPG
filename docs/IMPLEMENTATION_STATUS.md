# Material Frontier Online — Implementation Status

- Updated: 2026-07-14 (Asia/Tokyo)
- Current phase: Phase 1 automated technical baseline implemented
- Gate 0: Open
- Gate 1: Pending / not approved
- Phase 2: Not started / not authorized
- Baseline commit: `a13505e8fbf82962e049b9101a87593a6692d2c7`

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
| Empty scene P95 | 16.667 ms | 120 warmup + 600 samples |
| Arena idle P95 | 16.667 ms | Idle baseline, not stress target |
| KBM move / aim / hit | Observed | Manual observation, gamepadではない |

Artifacts and hashes are recorded in
[`../material-frontier-online/implementation/2026-07-14-phase1-technical-baseline.md`](../material-frontier-online/implementation/2026-07-14-phase1-technical-baseline.md).

## Gate 1 checklist

| Requirement | Status | Evidence / gap |
|---|---|---|
| ZIP／EXE hashとLFS実体 | Pass | `30 QA`事前確認で一致・実体確認 |
| 基準端末CPU/GPU/RAM/OS/解像度 | Partial | 主情報とOS buildは記録済み |
| Windows電源設定の実表示名 | Partial / mismatch unresolved | power planは`バランス`と記録。別のpower modeが性能優先か未確認 |
| GPU driver | Pending | 未記録 |
| 標準画質／release相当の実測設定 | Partial | 報告に方針はあるが、再現用の明示記録を補強する |
| HUDとJSONのP95一致 | Pass | 同一600サンプル、16.67ms |
| 起動時RuntimeHardLimit記録 | Pass for active scope | RHL-001/003はN/A |
| 空シーン1920×1080・60fps | Pass | P95 16.667ms |
| 仮プレイヤー移動・仮攻撃命中 | Pass on KBM/injected tests | 実ゲームパッドは未確認 |
| 左stick移動／右stick照準／X攻撃 | Blocked | 現在gamepadをWindows上で検出できず、manufacturer／model／接続方式待ち |
| 人間による操作感評価 | Pending | 自動テストで代替不可 |
| Phase 1工数が試作全体の15%以下 | Pending | 実績または再見積り記録なし |
| network/account/payment非搭載 | Pass | スコープ外を維持 |

Gate 1は、上記Pendingが解消され、QAが証拠付きで合格を勧告し、監督が承認するまで通過扱いにしない。

## Explicitly not implemented

- [ ] 正式な快斬・重断
- [ ] `MaterialJob`、`CombatForm`、`EquipmentLoadout`、core `EquipmentRuntimeState`
- [ ] `Integrity`、`Deformation`、`Heat`、`BurnCurse`
- [ ] 回避、被弾、戦闘不能、リトライ
- [ ] 3素材、3魔法
- [ ] バーストボア、部位破壊、AI、死体、剥ぎ取り
- [ ] 飲料充填工場、可逆コンベア、CIP洗浄水
- [ ] 本番UI、アート、VFX、音響
- [ ] 最大負荷代理／Gate 7性能試験
- [ ] MMO通信、アカウント、永続化、課金

## Current authorized work

Active work order: [`work-orders/phase1-gate1-manual-validation.md`](work-orders/phase1-gate1-manual-validation.md)

1. `30 QA + user`によるGate 1の実ゲームパッド／操作感確認。
2. Gate 1の不足メタデータと工数証跡の記録。
3. Phase 1の範囲内で発見された不具合の再現・修正。
4. P1質問の整理と監督判断。

不具合が見つかった場合、`00`が発行する個別修正票の範囲だけ`10`が変更する。
Phase 2のゲームコード、正式アクション、素材、ボス、ステージ制作へはまだ進まない。
