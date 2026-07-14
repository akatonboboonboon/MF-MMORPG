# Phase 1 Effort Re-estimate

- Evidence ID: `GATE-1-EFFORT-REESTIMATE`
- Date: 2026-07-14 (Asia/Tokyo)
- Owner: `00統括（監督）`
- Status: **Approved re-estimate**
- Unit: Relative Effort Point (`EP`)
- Scope: Frozen roadmap Phase 1–8
- Important: **actual hours／人日ではない**

## 1. Purpose

凍結roadmapのGate 1条件「Phase 1の基盤作業が試作全体工数の15%を超えていない」を、同じ単位の
再見積りで検証する。履歴時間ログが存在しないため実績工数とは主張しない。

Source: [`10-implementation-roadmap.md`](../material-frontier-online/specification/10-implementation-roadmap.md)

## 2. Estimation rule

- 分母は凍結roadmapのPhase 1～8。Phase 0文書作業とGate 8後のMMO工程は含めない。
- Gate PlayabilityはPhase 6の検証packageへ含め、二重計上しない。
- 1つの独立した受入可能work packageを1～5 EPで採点する。
- `1`: 設定・文書・既存枠への単純追加。
- `2`: 1層内の局所機能と通常検証。
- `3`: 複数層を跨ぐ機能、または独立した手動証拠。
- `4`: 状態lifecycle、cleanup、複数受入条件を伴うsubsystem。
- `5`: 複数system統合、高い相互作用、または大きな性能・content不確実性。
- 各packageへ通常のunit／integration検証を含める。Gate全体の回帰・人手証拠だけを独立packageとし、
  testを別計上して水増ししない。
- Lowは凍結受入条件を満たす最小経路、Workingは通常ケース、Highは既知の統合・調整risk込み。
- calendar日数や担当chat数ではなく、総作業量を比較する。

合否は将来を過大評価しない次の保守式を使う。

```text
Phase 1 High / (Phase 1 High + Phase 2–8 Low)
```

## 3. Package estimate

### Phase 1 — 技術基盤と測定環境

| Package | Low | Working | High | Reason |
|---|---:|---:|---:|---|
| P1-WP01 Engine・project・export基線 | 3 | 3 | 3 | 固定Godot版、renderer、project構造、Windows exportを一体で成立。完了済みで不確実性なし |
| P1-WP02 抽象入力と照準所有権 | 3 | 3 | 4 | KBM／gamepad割当、重複防止、RS保持とmouse移管。実gamepad差異をHighへ含む |
| P1-WP03 Command・Actor ID・local authority境界 | 4 | 4 | 4 | InputCommand、stable ID、未知Actor拒否、tick、simulation／presentation境界を横断 |
| P1-WP04 移動→仮攻撃A→標的命中とquery pool | 5 | 5 | 5 | movement／aim、Action／Effect、target、予約・返却、result eventの縦経路 |
| P1-WP05 DomainEvent・HUD・RHL起動記録 | 3 | 4 | 4 | 複数診断機能の統合。Lowはactive scope最小、Workingは全記録とHUD整合 |
| P1-WP06 空scene／arena計測と証拠 | 3 | 3 | 3 | bootstrap、600 samples、JSON／PNG照合。完了済み |
| P1-WP07 自動検証・smoke・release package | 3 | 3 | 3 | 36 assertions、import／export、EXE／ZIP smoke、hash／license／package |
| **Phase 1 total** | **24** | **25** | **26** | |

### Phase 2 — 共通戦闘system

| Package | Low | Working | High | Reason |
|---|---:|---:|---:|---|
| P2-WP01 EquipmentLoadout／core装備の状態所有権 | 3 | 4 | 5 | mutable source of truth、MaterialJob／CombatForm導出、重複保持禁止 |
| P2-WP02 Integrity・機能停止 | 3 | 3 | 3 | HP、0判定、一度だけの戦闘不能。仕様が明確 |
| P2-WP03 Deformation・単一penalty・reset | 3 | 4 | 5 | 0–100、被弾、非敗北、非回復、reset解除のlifecycle |
| P2-WP04 正式movement／aimへの置換 | 2 | 3 | 3 | Phase 1境界を再利用する局所置換 |
| P2-WP05 地上step回避 | 3 | 4 | 5 | 入力、移動、当たり判定、無敵／cancel等のP1決定を横断 |
| P2-WP06 damage・hit resolution共通系 | 3 | 4 | 5 | attack、被弾、effect、state、eventを横断 |
| P2-WP07 快斬 | 2 | 3 | 4 | 共通Action／Effect上の予備動作、判定、後隙 |
| P2-WP08 重断 | 2 | 3 | 4 | 長い予備／後隙、小前進、部位力、自己負荷P1調整 |
| P2-WP09 retry時query／state cleanup・定常allocation | 3 | 3 | 4 | pool残留防止とsteady-state検証 |
| P2-WP10 Gate 2回帰・所有権検証 | 4 | 4 | 4 | Gate条件、重複state禁止、2攻撃全段階の横断回帰 |
| **Phase 2 total** | **28** | **35** | **42** | |

### Phase 3 — 素材3系統と魔法3種類

| Package | Low | Working | High | Reason |
|---|---:|---:|---:|---|
| P3-WP01 MaterialJob schema＋3定義 | 3 | 4 | 5 | 同一Actorへ3 preset、物性／戦闘値境界、class複製禁止 |
| P3-WP02 素材選択・戦闘前status事前計算 | 3 | 4 | 5 | UI／data／simulationを横断し測定可能な差を保証 |
| P3-WP03 共通Effect基盤 | 4 | 5 | 5 | Damage／HeatChange／Force／ApplyStatusを共通化 |
| P3-WP04 放電 | 3 | 4 | 5 | 即時damage、短い電気状態、導電差を統合 |
| P3-WP05 抵抗加熱 | 3 | 4 | 5 | 継続温度、低頻度更新、単一低下を統合 |
| P3-WP06 磁気pulse | 3 | 4 | 5 | 磁気tag、Force、押出し、位置制御を統合 |
| P3-WP07 Heat／BurnCurse分離契約 | 2 | 2 | 3 | ID・耐性・stateの禁止契約と誤結合検査 |
| P3-WP08 2–5Hz scheduler | 3 | 4 | 5 | frame非依存、経過時間積算、rate telemetry |
| P3-WP09 VFX／戦闘結果分離 | 2 | 3 | 4 | particles-offでも同じ結果を保証 |
| P3-WP10 Gate 3回帰・素材比較証拠 | 4 | 4 | 4 | 3素材×3魔法、data-only調整、rate、particle分離の横断検証 |
| **Phase 3 total** | **30** | **38** | **46** | |

### Phase 4 — 大型敵・部位破壊・討伐・剥ぎ取り

| Package | Low | Working | High | Reason |
|---|---:|---:|---:|---|
| P4-WP01 boss定義・body shell | 2 | 2 | 3 | ID、body HP、collision、表示土台 |
| P4-WP02 FSM lifecycle | 3 | 4 | 5 | 接近／通常／特殊／硬直／部位後／死亡の状態遷移 |
| P4-WP03 target選択・movement | 2 | 3 | 4 | 1人実装と将来4人境界、arena移動 |
| P4-WP04 加圧突進 | 3 | 4 | 5 | 予兆、移動、実判定、硬直を持つ統合attack |
| P4-WP05 炭酸噴射 | 3 | 4 | 5 | 予兆、範囲、継続／方向、停止cleanup |
| P4-WP06 過圧衝撃波 | 3 | 4 | 5 | 広域予告、範囲判定、回避可読性 |
| P4-WP07 attack予兆・最低画質可読性 | 2 | 3 | 4 | presentationとmanual QAの横断 |
| P4-WP08 breakable-part schema・最大7検証 | 2 | 2 | 2 | 定義validator中心で範囲明確 |
| P4-WP09 5部位のtarget／hit／destroy | 3 | 4 | 5 | 独立HP、重複破壊防止、表示差分、event |
| P4-WP10 部位→本体damage／AI／報酬変化 | 3 | 4 | 5 | OD-023決定後の複数system相互作用 |
| P4-WP11 HP0・AI／query停止・corpse | 3 | 4 | 5 | 一度だけの終了、全攻撃停止、死体lifecycle |
| P4-WP12 剥ぎ取り権・報酬・result | 2 | 3 | 4 | 近接操作、重複取得禁止、破壊flag、result受渡し |
| P4-WP13 Gate 4回帰 | 3 | 3 | 3 | 定義上限、終了、全part、loot権の固定横断検証 |
| **Phase 4 total** | **34** | **44** | **55** | |

### Phase 5 — stage 1種類とgimmick 2個

| Package | Low | Working | High | Reason |
|---|---:|---:|---:|---|
| P5-WP01 搬入→説明→arena→resultのgreybox | 3 | 4 | 5 | route、camera、boss空間、4人余白を統合 |
| P5-WP02 navigation・collision境界 | 2 | 3 | 4 | 通行、前景隠れ、装飾collision禁止 |
| P5-WP03 可逆conveyor logic | 3 | 4 | 5 | 正転／停止／逆転、Actor／敵位置、状態遷移 |
| P5-WP04 conveyor cues | 1 | 2 | 3 | 既存logicへの方向・稼働表示追加 |
| P5-WP05 CIP水field lifecycle | 3 | 4 | 5 | 時間制領域、開始／終了、重複、cleanup |
| P5-WP06 CIP電気強化・冷却interaction | 3 | 4 | 5 | magic／Heat／field／environmentを横断 |
| P5-WP07 stage layer・asset／collision contract | 2 | 3 | 4 | 地形／設備／小物／光の層と禁止事項 |
| P5-WP08 通常／gray／最低画質の可読性証拠 | 2 | 3 | 4 | silhouette、priority、遮蔽の人手確認 |
| P5-WP09 Gate 5回帰 | 3 | 3 | 3 | 必須規約、上限、gimmick数、collision検査 |
| **Phase 5 total** | **22** | **30** | **38** | |

### Phase 6 — 垂直試作統合＋Playability

| Package | Low | Working | High | Reason |
|---|---:|---:|---:|---|
| P6-WP01 素材選択→開始flow | 2 | 3 | 4 | UI／data／simulationを接続するscene-state flow |
| P6-WP02 全combat／gimmickの1経路統合 | 3 | 4 | 5 | 3素材、2物理、3魔法、2gimmickを同時成立 |
| P6-WP03 討伐→corpse→loot→result | 3 | 4 | 5 | Phase 4 lifecycleを全体flowへ接続 |
| P6-WP04 敗北→再開→retry | 3 | 4 | 5 | Integrity敗北、Deformation reset、penalty解除 |
| P6-WP05 全state／resource cleanup・idempotence | 3 | 4 | 5 | part／query／corpse／light／reward／subscription残留防止 |
| P6-WP06 最小UI統合 | 2 | 3 | 4 | HP／変形／boss／part／cooldown／gimmick／result |
| P6-WP07 仮SE・hit／danger／break feedback | 2 | 3 | 4 | 表現契約を守る複数event feedback |
| P6-WP08 AC-001～018横断回帰 | 3 | 4 | 5 | 全受入条件を1本のflowで検証 |
| P6-WP09 人手Gate Playability証拠 | 3 | 4 | 5 | 初見観察、入力／被弾、素材比較、最低画質録画 |
| **Phase 6 total** | **24** | **33** | **42** | |

### Phase 7 — 最大負荷検証と最適化

| Package | Low | Working | High | Reason |
|---|---:|---:|---:|---|
| P7-WP01 stress harness・scenario orchestration | 2 | 3 | 5 | 全proxy同時起動、warmup、run制御 |
| P7-WP02 残り7 player proxy | 1 | 2 | 4 | proxy忠実度により表示／状態／更新負荷が増える |
| P7-WP03 2大型敵＋30小型proxy | 2 | 3 | 5 | 異なる描画面積、更新密度、lifecycle |
| P7-WP04 7 parts／敵＋50 hit-query proxy | 2 | 3 | 5 | 実判定、予約分類、counterを同時成立 |
| P7-WP05 lights／particles／2 gimmicks proxy | 1 | 3 | 4 | GL描画負荷と戦闘非依存性 |
| P7-WP06 2–5Hz／remote 5Hz workload | 1 | 2 | 4 | stress同期とtelemetry |
| P7-WP07 CPU／GPU／memory／frame／counter metrics | 2 | 3 | 5 | portable計測の取得可能性に不確実性 |
| P7-WP08 60秒warmup＋10分×3測定／report | 2 | 3 | 4 | repeatability、spike、leak、raw evidence |
| P7-WP09 profiling・原因修正・最適化 | 2 | 4 | 5 | Lowは最小確認、Working／Highは結果依存 |
| P7-WP10 最低画質／particle-off／readability／determinism | 1 | 2 | 4 | 複数設定で戦闘結果と可読性を照合 |
| **Phase 7 total** | **16** | **28** | **45** | |

### Phase 8 — 確認用成果物

| Package | Low | Working | High | Reason |
|---|---:|---:|---:|---|
| P8-WP01 release build／package／hash／license | 2 | 3 | 4 | 最終export、portable ZIP、再現確認、法的同梱 |
| P8-WP02 quick-start・controls | 1 | 2 | 3 | 操作説明と実機差分 |
| P8-WP03 captures・performance logs・evidence index | 2 | 3 | 4 | 複数Gate証拠を再追跡可能に統合 |
| P8-WP04 known issues・spec差分・remaining risks | 2 | 2 | 3 | 読み取り監査中心、差分量でHigh増 |
| P8-WP05 user review・Gate 8 decision record | 1 | 2 | 2 | review packetと承認記録、実装なし |
| **Phase 8 total** | **8** | **12** | **16** | |

## 4. Result

| Scope | Low | Working | High |
|---|---:|---:|---:|
| Phase 1 | 24 | 25 | 26 |
| Phase 2–8 | 162 | 220 | 284 |
| Phase 1–8 total | 186 | 245 | 310 |

```text
Conservative Gate 1 ratio
= Phase 1 High / (Phase 1 High + Phase 2–8 Low)
= 26 / (26 + 162)
= 13.8298%
```

**Result: Pass by approved re-estimate (`13.83% <= 15%`).**

Working estimateは`25 / 245 = 10.20%`。合否にはより厳しい13.83%を採用する。

## 5. Change control and limits

- この証拠はactual timeの復元ではない。実績時間として引用しない。
- Phase 1 Highが`28.59 EP`を超える、またはPhase 2–8 Lowが合計`147.33 EP`未満になるscope変更時は
  15%条件を再判定する。
- 現在のfuture Low `162 EP`から`14.66 EP`を超えるscope削減が入る場合も再判定する。
- 後からPhase 1 packageを小さく、将来packageを大きく再分類して比率を調整しない。
- この再見積りは工程管理用であり、仕様、受入条件、P0／P1／P2を変更しない。
