# Material Frontier Online — Milestones and Gates

- Updated: 2026-07-14
- Approval owner: `00統括（監督）`
- Rule: QAは合否を勧告し、監督だけがGateを承認する。

## Status summary

| Milestone | Deliverable | Status | Gate |
|---|---|---|---|
| M0 / Phase 0 | 仕様確認、P0決定、試作仕様凍結 | Complete | Gate 0 Open (2026-07-13) |
| M1 / Phase 1 | 技術基盤と測定環境 | Implementation complete / manual validation active | Gate 1 Pending |
| M2 / Phase 2 | 共通戦闘システム | Not started / locked | Gate 2 locked |
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

Active work order: [`work-orders/phase1-gate1-manual-validation.md`](work-orders/phase1-gate1-manual-validation.md)

- [x] 入力→移動→仮攻撃→命中→ログの縦経路
- [x] ローカル権威と表示の境界
- [x] 最小定義検証と判定予約
- [x] Windows release export
- [x] 空／アリーナidle測定
- [x] Phase 1自動テスト
- [ ] 実ゲームパッド LS / RS / X
- [ ] 人間による操作感評価
- [ ] Phase 1工数15%以下の証跡
- [ ] 基準端末の不足メタデータ補完
- [ ] QA合格勧告
- [ ] 監督によるGate 1承認

Gate 1まではPhase 1の検証と欠陥修正だけを許可する。

現在の実行順:

```text
00 work order issued
→ 30 QA + user physical gamepad / feel validation
→ 00 Gate 1 decision
```

Fail時は`00`が個別defectだけを`10`へ戻し、`30 + user`が再検証する。Pass勧告だけでGate状態を変更しない。

Gate 1を正式承認した場合、`00`は同じ変更で次を同期する。

- `material-frontier-online/STATUS.md`: `Gate 1 = Pass`, `Phase 1 = Complete`, `Phase 2 = Authorized`
- `docs/IMPLEMENTATION_STATUS.md`
- この`MILESTONES.md`
- Gate 1 test reportと既知問題
- Phase 2に必要なApproved P1決定とwork order

## M2 — Common combat

Entry: Gate 1承認後、Phase 2に直接必要な次のP1を`00`が決定し、`DECISIONS.md`へApprovedとして記録する。

- OD-020: 移動、回避、ロックオン
- OD-021: 敗北後のリトライ
- OD-026: `Integrity`／`Deformation`等の表示
- OD-027: 単一変形ペナルティの暫定値
- OD-041: 基準カメラ
- OD-043: 最低限の可読性基準

他のP1/P2を一括決定しない。Phase 2 work orderには目的、実装範囲、変更禁止範囲、受入条件、owner path、
event、test、Gate 2判定方法を含める。

Implementation slices:

### Slice 2-A — Basic operation

- player移動、照準、回避
- 承認された場合だけ簡易lock-on
- retry時の位置初期化

完了後に`30`が移動、回避、retryを検証する。

### Slice 2-B — Approved physical actions

- 快斬、重断
- windup、active hit window、recovery
- 入力中の向き処理
- hit query取得と返却

完了後に`30`が入力、命中、用途差、後隙、query返却を検証する。

### Slice 2-C — Damage model

- `Integrity`、`Deformation`
- 被弾、戦闘不能、単一変形penalty
- retry時の完全初期化

完了後に`30`が損傷分離、敗北条件、penalty、初期化を検証する。

### Slice 2-D — Presentation boundary

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

Exit summary: バーストボア、5部位、本体HP0の一度だけの遷移、AI／判定停止、死体、重複不可の剥ぎ取り。

## M5 — Stage and gimmicks

Entry: Gate 4承認＋OD-040、OD-041、OD-043のうち制作に必要な項目。

Exit summary: 炭酸ライン、2ギミック、ST必須規約、二値経路、前景遮蔽なし、最低画質可読性。

## M6 — Integrated vertical slice and Playability

Entry: Gate 5承認。

Exit summary: 素材選択から剥ぎ取り・リザルト・再試行まで完走し、全MVP受入条件を満たす。
その後、人間が移動／回避、2物理攻撃、3素材差、予兆回避、部位狙い、最低画質理解の6項目を評価する。

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
