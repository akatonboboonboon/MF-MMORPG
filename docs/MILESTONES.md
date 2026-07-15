# Material Frontier Online — Milestones and Gates

- Updated: 2026-07-15
- Approval owner: `00統括（監督）`
- Rule: QAは合否を勧告し、監督だけがGateを承認する。

## Status summary

| Milestone | Deliverable | Status | Gate |
|---|---|---|---|
| M0 / Phase 0 | 仕様確認、P0決定、試作仕様凍結 | Complete | Gate 0 Open (2026-07-13) |
| M1 / Phase 1 | 技術基盤と測定環境 | Complete | Gate 1 Pass (2026-07-14) |
| M2 / Phase 2 | 共通戦闘システム | Functional checks + KBM Pass / correction performance Fail retained / controlled matrices valid run 0 / acceptance unresolved | Gate 2 locked / not evaluated |
| M3 / Phase 3 | 3素材＋3魔法 | Not started / locked | Gate 3 locked |
| M4 / Phase 4 | ボス、部位破壊、討伐、剥ぎ取り | Not started / locked | Gate 4 locked |
| M5 / Phase 5 | 1ステージ＋2ギミック | Not started / locked | Gate 5 locked |
| M6 / Phase 6 | 垂直試作統合 | Not started / locked | Gate 6 + Playability locked |
| M7 / Phase 7 | 最大負荷検証と最適化 | Not started / locked | Gate 7 locked |
| M8 / Phase 8 | 確認用成果物 | Not started / locked | Gate 8 locked |

## Gate control

各Gateは次をすべて満たしたときだけ承認できる。

1. 前Gateが承認済み。
2. 該当工程のP1決定が `DECISIONS.md` にApprovedとして記録済み。
3. 実装・文書・成果物が工程スコープ内。
4. 必須テストと手動評価が証拠付きで完了。
5. QAが仕様適合と既知問題を報告し、合格を勧告。
6. 監督が差分を確認し、この文書のGate状態を更新。

テスト成功、担当チャットの完了宣言、機能の存在だけではGate承認にならない。

## M0 — Specification and P0 freeze

- [x] 10仕様書の整理
- [x] 凍結統合仕様書とSHA-256
- [x] P0 13 / 13承認
- [x] Gate 0決定記録
- [x] Gate 0 Open

承認範囲はPhase 1のみ。巨大基盤、MMO、アカウント、課金、本番アセット量産は含まない。

## M1 — Technical baseline

Completed work order: [`work-orders/phase1-gate1-power-revalidation.md`](work-orders/phase1-gate1-power-revalidation.md)

Deferred physical-gamepad work order: [`work-orders/phase1-gate1-manual-validation.md`](work-orders/phase1-gate1-manual-validation.md)

- [x] 入力→移動→仮攻撃→命中→ログの縦経路
- [x] ローカル権威と表示の境界
- [x] 最小定義検証と判定予約
- [x] Windows release export
- [x] 空／アリーナidle測定
- [x] Phase 1自動テスト
- [x] KBM移動・照準・仮攻撃・命中の実動作
- [x] ユーザーのKBM総合操作感`問題なし`
- [x] Phase 1工数15%以下の証跡（承認済み再見積り13.83%。実績時間ではない）
- [x] 基準端末GPU／driver／power plan／power modeの記録
- [x] OD-004性能優先条件でempty／arenaを再計測（P95各`16.6667 ms`）
- [x] QA合格勧告
- [x] 監督によるGate 1承認

Deferred / not passed: 物理gamepad LS／RS／主要アクション、drift、多重入力、gamepad体感。
OD-013を維持し、入手後かつ遅くともGate Playability承認前に実施する。

Gate 1は[`GATE-1`](../material-frontier-online/decisions/2026-07-14-gate-1-approval.md)でPassした。
Phase 2 entry P1は承認済みだが、現在のactive票はSlice 2-AのQA-only performance rerunだけで、ゲームコード変更は許可しない。

現在の実行順:

```text
00 accepted MFO-WO-P2-2A-004 as performance Blocked / KBM Pass
→ 00 issued MFO-WO-P2-2A-005; 30 seals preparation outside OneDrive
→ user closes every OneDrive client; 30 runs performance-only matrix
→ 00 accepts the slice or issues an evidence-supported next order
```

Gate 1 evidence: [`test-reports/phase1-gate1-power-revalidation.md`](test-reports/phase1-gate1-power-revalidation.md)

Gate 1承認では次を同期した。

- `material-frontier-online/STATUS.md`: `Gate 1 = Pass`, `Phase 1 = Complete`
- `docs/IMPLEMENTATION_STATUS.md`
- この`MILESTONES.md`
- Gate 1 test reportと既知問題
- `docs/DECISIONS.md`のGate 1承認記録

Phase 2の無限定な`Authorized`表記は使用しない。実装許可は、次sliceに必要なP1決定と明示work orderを
揃えたscope／pathだけに発生する。現在はQA-only票だけがactiveで、実装許可を持つgame code pathはない。

## M2 — Common combat

Entry satisfied: Gate 1承認済み。次のPhase 2 P1は
[`P2-P1-2026-07-14`](../material-frontier-online/decisions/2026-07-14-phase2-p1-approval.md)で承認済み。

- [x] OD-020: Phase 2 ground-step evade
- [x] OD-021: same-arena authority reset
- [x] OD-026: `Integrity`／`Deformation` persistent HUD
- [x] OD-027: `Deformation >= 60` movement `-15%`
- [x] OD-041-P2: Phase 2 reference camera
- [x] OD-043-P2: Phase 2 minimum readability

Active performance-only order — Stage P preparation authorized:
[`MFO-WO-P2-2A-005`](work-orders/phase2-slice2a-performance-only-rerun.md)

Returned controlled-rerun order:
[`MFO-WO-P2-2A-004`](work-orders/phase2-slice2a-controlled-rerun.md)

Returned diagnostic order:
[`MFO-WO-P2-2A-003`](work-orders/phase2-slice2a-performance-diagnostic.md)

Returned correction order:
[`MFO-WO-P2-2A-002`](work-orders/phase2-slice2a-nonzero-direction-correction.md)

Returned original order:
[`MFO-WO-P2-2A-001`](work-orders/phase2-slice2a-basic-operation.md)

他のP1/P2を一括決定しない。各Phase 2 work orderには目的、実装範囲、変更禁止範囲、受入条件、owner path、
event、test、Gate 2判定方法を含める。OQ-005はSlice 2-Cのdefeated-input接続前に決定する。

Implementation slices:

### Slice 2-A — Basic operation

Status: **Functional correction + corrected-C KBM verified / correction performance Fail retained / controlled matrices valid run 0 / acceptance unresolved**

- player移動、照準、回避
- lock-onはOD-020によりPhase 2対象外
- retry用authority reset seam。defeat／input bindingは実装しない
- Original Stage A candidate: `bd01fdf`; original formal QA closure: `c0df756`
- Correction implementation: `5261a737`; gameplay handoff: `0727fe56`; correction QA closure: `df0cd0c`
- Functional QA: Phase 1 `36 / 36 Pass`; unchanged Slice 2-A `120 / 120 Pass`; additive correction `39 / 39 Pass`
- Performance QA: AC Best performance P95 `33.4643 ms` and `20.0000 ms`; both exceed `<= 16.67 ms`
- `MFO-WO-P2-2A-003`: valid acceptance runs `0`; A1／B1／C1 invalid, C2 incomplete, B2／A2 Not run
- Diagnostic host: continuous external input, mostly non-game foreground, system CPU avg `72.838%–87.620%`, substantial OneDrive load; user later reported a red-X state and suspects the free-plan 5 GB limit, root cause unconfirmed
- Diagnostic recommendation: **Blocked / causality not isolated**; prior correction performance Fail is not withdrawn
- `MFO-WO-P2-2A-004`: preflight OneDrive-family `32.15625 CPU-s`, system CPU avg／max `38.250224%`／`46.012270%`; matrix Not run
- `MFO-WO-P2-2A-004` corrected-C KBM: **Pass**, independent `27.973 s`, stable foreground, all six items and user no-problem confirmation
- KBM user feel: Pass; physical gamepad Not run / Deferred
- `MFO-P2-2A-QA-001`: functionally resolved on the correction branch, pending Slice acceptance／integration
- `MFO-P2-2A-QA-002`: P1 acceptance failure; runtime severity and code causality not isolated

`30`は`MFO-WO-P2-2A-005`に従い、A／B／CとcontrollerをOneDrive外でsealしてからPREPAREDを通知する。
userが別accountを含む全OneDrive clientを一時終了し、process count `0`を確認したquiet windowで
performanceだけを実施する。repository／account／fileは移動せず、KBMは再実施しない。`10`のgame code
変更は原因範囲が証拠で確定するまで許可しない。
Slice 2-AはQA Pass勧告と`00`受理まで未完了である。

### Slice 2-B — Approved physical actions

Status: **Locked / no work order**

- 快斬、重断
- windup、active hit window、recovery
- 入力中の向き処理
- hit query取得と返却

完了後に`30`が入力、命中、用途差、後隙、query返却を検証する。

### Slice 2-C — Damage model

Status: **Locked / no work order**

- `Integrity`、`Deformation`
- 被弾、戦闘不能、単一変形penalty
- retry時の完全初期化

完了後に`30`が損傷分離、敗北条件、penalty、初期化を検証する。

### Slice 2-D — Presentation boundary

Status: **Locked / no work order**

- `ActionStarted`
- `HitConfirmed`
- `DamageApplied`
- `DeformationChanged`
- `ActorDefeated`
- approved read-only state

正式payloadとconsumer contractを`ASSET_CONTRACTS.md`へ固定してから、`20`が割当済み表示fileへ統合する。
`20`はそれ以前でも、code非接続・非bindingの`Proposed` mockupを作成できる。

各sliceで`10 → 30`を行い、2-Dの契約確定部分だけ`20`と部分並行する。

Exit summary:

- 快斬／重断の予備動作、判定、ダメージ、後隙
- 回避、被弾、`Integrity == 0`、リトライ
- 独立した`Integrity`／`Deformation`と単一ペナルティ
- core装備の損傷状態が唯一の可変な正
- 共通Action／Effect、判定予約、リトライ後残留なし

## M3 — Materials and magic

Entry: Gate 2承認＋OD-025、濡れ床の電気強化方式、加熱時に下げる耐性等の必要P1決定。

Exit summary: 3素材のデータ差、3魔法の共通効果、Heat/BurnCurse分離、2～5Hz更新、VFX無効時の結果不変。

## M4 — Boss, parts, defeat, loot

Entry: Gate 3承認＋OD-022、OD-023、OD-024。

boss最大表示寸法またはboss framingをcameraへ統合する前に、OD-041-POSTの該当項目を決定する。

Exit summary: バーストボア、5部位、本体HP0の一度だけの遷移、AI／判定停止、死体、重複不可の剥ぎ取り。

## M5 — Stage and gimmicks

Entry: Gate 4承認＋OD-040、OD-041-POST、OD-043-POSTのうち制作に必要な項目。

Exit summary: 炭酸ライン、2ギミック、ST必須規約、二値経路、前景遮蔽なし、最低画質可読性。

## M6 — Integrated vertical slice and Playability

Entry: Gate 5承認。

Exit summary: 素材選択から剥ぎ取り・リザルト・再試行まで完走し、全MVP受入条件を満たす。
その後、人間が移動／回避、2物理攻撃、3素材差、予兆回避、部位狙い、最低画質理解の6項目を評価する。

Gate Playability承認前に、物理gamepadでLS移動、RS照準、主要アクション、drift／多重入力、操作感を
検証する。これはGate 1で延期した証拠であり、KBM結果をgamepad Passとして流用しない。

Gate Playability通過までM7へ進まない。

## M7 — Maximum-load performance

Entry: Gate Playability承認＋OD-044。

Exit summary: 全`PrototypeStressTarget`を同時成立、3回×10分、P95 16.67ms以下、RHL違反0、メモリ単調増加なし。

## M8 — Review deliverable

Entry: Gate 7承認。

Deliverables: オフライン試作、操作説明、仕様差分、未解決事項、性能結果、ステージ規約検査、既知不具合、次段階候補。

Gate 8でユーザーが確認するまで、オンライン、永続アカウント、課金、巨大マップ、別プラットフォームへ進まない。

## Team activation

| Role | Current status | Activation condition |
|---|---|---|
| 音楽・SE・ボイス | Not created / unauthorized | 監督がOD-042と必要イベント契約を承認し、この表を更新した後 |
| ネットワーク・サーバー | Not created / unauthorized | Gate 8後、オンライン段階をユーザーが別途承認した後 |
| アカウント・永続データ | Not created / unauthorized | 小規模オンライン境界と永続化範囲をユーザーが別途承認した後 |

候補条件は実装承認ではない。監督による明示的な`Activated`記録を必要とする。
