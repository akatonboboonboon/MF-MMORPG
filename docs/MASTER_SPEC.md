# Material Frontier Online — Master Implementation Specification

- Document role: 実装用の正規化参照先
- Updated: 2026-07-14 (Asia/Tokyo)
- Specification baseline: Approved / Frozen
- Gate 0: Open
- Gate 1: Pass (2026-07-14)

## 1. Authority

この文書は、新しいゲーム仕様を追加するものではない。凍結仕様と承認済み決定を、担当チャットが
一意に参照できる形へ正規化した実装用索引である。

根拠資料:

- 凍結統合仕様書: [`../material-frontier-online/deliverables/Material-Frontier-Online-Integrated-Specification.docx`](../material-frontier-online/deliverables/Material-Frontier-Online-Integrated-Specification.docx)
- SHA-256: `66df0882ad4320b07850c745a0ac7cc5d8e091e0f4dd66a38e9d6237bb89babf`
- Gate 0決定記録: [`../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md`](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md)
- 詳細Markdown仕様: [`../material-frontier-online/specification/`](../material-frontier-online/specification/)
- 現在の決定一覧: [`DECISIONS.md`](DECISIONS.md)

凍結仕様内の `Gate 0: Closed`、P0未承認、P0候補という記述は履歴状態であり、2026-07-13の
決定記録で上書き済みである。P1/P2、延期項目、性能予算、制作規約、Gate受入条件は上書きされていない。

## 2. Product and prototype boundary

- 正式名称は **Material Frontier Online**、正式略称は **MFO**。
- 最終構想は、2Dのリアルタイム協力狩猟を核にしたMMORPG。
- 現在作るものは、外部サービスを使わない**オフライン戦闘バーティカルスライス**。
- 試作目的はMFO固有の戦闘と素材差を検証することであり、MMO基盤を先行実装することではない。

最小試作の実コンテンツ:

| Item | Approved scope |
|---|---:|
| ローカル操作プレイヤー | 1体 |
| `CombatForm` | 共通の片手刃型1形態 |
| 素材系統 | 3種類 |
| 物理攻撃 | 2種類 |
| 魔法 | 3種類 |
| 大型敵 | 1体 |
| ステージ | 1種類 |
| 環境ギミック | 2個 |
| 部位破壊 | あり。大型敵1体あたり最大7部位 |
| 討伐 | 本体`Integrity == 0` |
| 剥ぎ取り | 簡易版 |

「将来4人対応」は、アリーナ余白、部位配置、Actor集合、stable target ID、HUD余白、4スポーン枠等の
境界だけを妨げないことを意味する。AI仲間、画面分割、ローカル複数人、複数コントローラー、通信Actorを
試作へ追加しない。性能試験の残り7人は表示・移動・状態表示だけを持つ負荷代理である。

## 3. Technical baseline

| Field | Approved value |
|---|---|
| Target | Windows x86_64 native portable |
| Distribution | ZIP展開型、単体EXE |
| Engine | Godot Engine `4.7.stable.official.5b4e0cb0f` standard build |
| Language | GDScript |
| Renderer | GL Compatibility（Phase 1実測構成） |
| Resolution | 1920×1080 |
| Target | 60fps、総フレーム時間P95 16.67ms以下 |

基準端末はIntel Core 7 150U、Intel Graphics、16GB DDR5、Windows 11 Home、標準画質、性能優先。
OS build、GPU driver、renderer、Windows電源設定の実表示名を計測記録に残す。2026-07-14時点の実機は
OS `10.0.26200`、GPU `Intel(R) Graphics`、driver `32.0.101.7077` (`2025-09-16`)、power plan
`バランス`である。Gate 1再検証ではAC online、AC power mode Best performance
`ded574b5-45a0-4f42-8737-46345c09c238`、DCは変更せずBest Power Efficiencyとして別記録した。
この条件でempty／arenaともP95 `16.6667 ms`となり、OD-004のGate 1条件を通過した。

## 4. View, movement, and input

- 斜め俯瞰2D、固定方角。カメラ回転なし。
- 8方向移動と全方向照準を分離する。
- 本格Z軸、ジャンプ、空中戦を持たない。回避は地上ステップ。
- 主入力はゲームパッド。同じ抽象入力へキーボード・マウスを対応させる。

`GATE-1-INPUT-EVIDENCE`は物理gamepad証拠の取得時期だけをGate Playabilityまで延期する。OD-013、
gamepad割当、共通抽象入力は変更しない。Gate 1では記録済みKBM実動作とユーザー総合評価`問題なし`を
入力証拠に採用し、gamepad自体は`Not run / Deferred`とする。

抽象入力:

```text
move
aim
physical_light
physical_heavy
evade
lock_on
interact
magic_1
magic_2
magic_3
```

既定割当:

| Action | Gamepad | Keyboard / Mouse |
|---|---|---|
| Move | Left stick | WASD |
| Aim | Right stick | Mouse |
| 快斬 | X | Left click |
| 重断 | Y | Right click |
| 回避 | A | Space |
| ロックオン | LB | Q |
| 操作・剥ぎ取り | RB | E |
| 3魔法 | LT+X / LT+Y / LT+B | 1 / 2 / 3 |

Phase 2の回避は、移動入力方向またはneutral時のaim方向へ`140 px / 0.20 s`進む地上stepとする。
再使用間隔は`0.45 s`。無敵、stamina、input bufferはなく、再使用不能中の要求は
rejectして保持しない。gameplay collision／boundsを貫通しない。lock-on、part lock、auto approach、
attack cancelはPhase 2対象外であり、`lock_on`入力は予約のまま動作させない。Slice 2-A work orderでは
reuse clockをaccepted start間として一意化する。

Phase 2 cameraは1920×1080、固定方角、zoom 1.0の現一画面構成を維持する。dynamic zoom、正式な
画面内人数、boss最大表示寸法、boss／stage framingはOD-041-POSTとして後続Phaseへ延期する。

## 5. Player model and state authority

プレイヤーは次の5層へ分離する。

| Layer | Responsibility |
|---|---|
| `AvatarIdentity` | 名前、顔、髪、声、人格。戦闘性能へ影響しない |
| `MaterialJob` | 素材系統、基本物性、魔法適性、性能と壊れ方 |
| `CombatForm` | 形状、操作、移動補正、アクションセット、攻撃方法 |
| `EquipmentInstance` | 装備個体、損傷、加工、将来の疲労・個体ツリー |
| `Appearance` | 色、発光、外装。性能から分離 |

`EquipmentLoadout` は第6層ではなく、装備個体を束ねる集約である。最小試作ではcore装備を正確に1個だけ持つ。

- core `EquipmentInstance` が `MaterialJob` と `CombatForm` 選択の唯一の書き換え可能な正。
- core `EquipmentRuntimeState` が `Integrity`、`Deformation`、`temperature` の唯一の可変な正。
- Actor側の素材・形状参照は読み取り専用の解決結果。損傷値をActorへ複製しない。
- 不一致を暗黙修正せず、開始前の構成エラーとして拒否する。
- 素材別プレイヤークラス、独立武器／鎧耐久、複数装備間の損傷分配を作らない。

損傷契約:

- `Integrity`: HP相当。0でプレイヤー敗北／敵機能停止。
- `Deformation`: 0～100。物理被弾で増加し、単独では敗北させない。
- `Deformation >= 60`で通常移動速度を15%低下させる。これをMVPの単一penaltyとし、閾値と効果量は
  dataで保持する。回避距離／時間、aim、attack speed、敗北条件へ拡張しない。
- 戦闘中に自然回復させず、リトライ／状態初期化で0へ戻してペナルティを解除する。
- `Heat` と `BurnCurse` は別チャンネル・別耐性。相互に自動変換しない。

Phase 2 retryは、`Integrity == 0`の敗北中にretry操作を受理したとき、同一arenaの設定済み開始状態へ
戻す。authorityはposition、initial aim、velocity、evade stateに加え、その時点で存在するretry所有状態を
完全初期化する。checkpointと専用retry画面はPhase 2へ含めない。入力bindingはOQ-005承認後に接続する。

Phase 2常時HUDは`Integrity`と`Deformation`。temperatureは機能実装後に追加し、chargeはPhase 3まで
表示しない。HUDはread-onlyであり、stateを変更しない。charge非表示はOD-025の資源方式を決定しない。

疲労破壊はMVP対象外。将来有効化した場合に失うのは対象`EquipmentInstance`とその個体の加工状態・
スキルツリーであり、`AvatarIdentity`は失わない。

## 6. Approved combat content

### Materials

| MaterialJob | Prototype role |
|---|---|
| ナイト系鉄鋼 | 高Integrity、高被変形耐性、高物理部位ダメージ、低速・重量、強い磁気反応 |
| アルミ | 高移動性能、高熱伝導、低質量、中物理部位ダメージ、低耐熱上限、鉄鋼より低い被変形耐性 |
| 銅 | 最高電気伝導、高熱伝導、高魔法効率、低物理耐久・低物理部位ダメージ、アルミより重い |

アルミ母材は導体。酸化皮膜由来の魔法耐性を独立した静的パラメータとして持つ。動的な皮膜破壊・
再生・導通切替はMVPへ入れない。

### CombatForm and physical actions

- `combat_form.blade.one_hand.prototype`: 3素材共通の片手刃型1形態。
- `action.physical.quick_cut`（快斬）: 短い予備動作・後隙、低～中ダメージ、低部位破壊力、方向修正しやすい。
- `action.physical.heavy_cleave`（重断）: 長い予備動作・後隙、高部位破壊力、小前進、大きな自己負荷。
- 盾、空中コンボ、ジャストガード、武器持ち替え、派生コンボツリー、二刀流、複数溜め段階を含めない。

重断の自己負荷を後隙、`Deformation`補正、その他のどれで表すかは未決定。専用ダメージ処理を作らず、
`ActionDefinition` と共通 `EffectDefinition` から構成する。

### Magic

| ID | Role |
|---|---|
| `magic.arc_discharge` | 即時電気ダメージ＋短い電気状態。導電対象・濡れ床で強化、銅が最高効率 |
| `magic.resistive_heating` | 対象部位の温度を継続上昇。一定温度で承認済みの単一低下、水で冷却 |
| `magic.magnetic_pulse` | 磁気タグ対象を押し出す。MVP初期は押し出しのみ |

3魔法は `Damage`、`HeatChange`、`Force`、`ApplyStatus` の共通効果から構成する。
濡れ床の電気強化方式、加熱時に下げる耐性、魔法資源は未決定。

## 7. Boss, stage, gimmicks, and loot

### Boss

- ID: `enemy.carbonation.burst_boar.prototype`
- Name: 炭酸圧獣《バーストボア》
- Theme: 炭酸飲料の保管、内圧、気密、充填、圧力解放
- 5破壊部位: 頭部安全弁、左右圧力嚢、前脚ピストン、後部噴射口
- Body core: 左右圧力嚢破壊後に露出する本体弱点。6番目の破壊部位ではない
- Attacks: 加圧突進、炭酸噴射、過圧衝撃波
- Defeat: 安全放出しながら機能停止し、剥ぎ取り可能な残骸を残す

AI数値・フェーズ（OD-022）、部位HPと本体HPの伝達（OD-023）、剥ぎ取り詳細（OD-024）は未決定。

### Stage and gimmicks

- Stage ID: `stage.filling_plant.carbonation_line.prototype`
- Route: 短い搬入通路 → 操作説明区画 → 充填ライン兼ボスアリーナ → 剥ぎ取り・リザルト
- `gimmick.conveyor.reversible`: 正転、停止、逆転
- `gimmick.cip_wash.water_field`: 時間制の濡れ領域。電気作用を強め、加熱を冷却
- CIP水の摩擦変化と腐食計算は実装しない
- 背景設備は原則としてゲームプレイ衝突を持たない

試作報酬は `loot.pressure_core.prototype`、`loot.seal_membrane.prototype`、
`loot.carbonate_sample.prototype` の数量表示のみ。世界内名は戦闘・会話、実在材料名は図鑑・詳細、
内部IDは言語非依存とする。

## 8. Architecture contract

```text
Input Device
  → InputAdapter
  → InputCommand
  → Local Authority Simulation
  → DomainEvent / Read-only State
  → Presentation (Animation / VFX / Lighting / Audio / HUD / Camera)
```

- 最小試作は同一プロセスの完全オフライン構成。
- 入力層は要求を作るだけで、発動・命中・ダメージを確定しない。
- ローカル権威シミュレーションが位置、行動、命中、損傷、部位、AI、ギミック、討伐、報酬を決定する。
- Presentationはイベント／読み取り専用状態を表示し、権威状態を書き換えない。
- 定義はstable IDを使い、素材や技の追加をクラス複製で行わない。
- シミュレーション時間を描画フレームから分離する。
- 画像・音声の実体をシミュレーション定義へ持ち込まない。
- MMO通信、パケット、認証、サーバービルド、DB、ロールバック、ラグ補償を先行実装しない。

表現との具体的な接続は [`ASSET_CONTRACTS.md`](ASSET_CONTRACTS.md) を正とする。

## 9. Performance contract

性能値を混同しない。

- `PrototypeStressTarget`: 試作の負荷試験条件。製品容量でも実装数でもない。
- `RuntimeHardLimit`: 現在の試作ルール／データ契約として超えてはならない条件。
- `ProductTarget`: 正式版保証。Gate 8以後に決定し、現在はTBD。

主要`PrototypeStressTarget`:

| Item | Target |
|---|---:|
| Resolution / frame | 1920×1080 / 60fps |
| Visible player load | 8表示（1実体＋7代理） |
| Large / small enemies | 2 / 30（未実装分は代理） |
| Breakable parts | 各大型敵7 |
| Active gameplay hit queries | 50 |
| Background / combat lights | 4 / 8 |
| Remote updates | 5Hz以下 |
| Temperature / corrosion | 2～5Hz |

`RuntimeHardLimit`:

- RHL-001: 大型敵1体の破壊可能部位は最大7。8以上の定義を拒否。
- RHL-002: 視覚パーティクルは戦闘結果を決定しない。
- RHL-003: 温度・腐食更新は2～5Hz、描画フレームから分離。

攻撃判定50は固定プール上限ではない。技別設計上限と予約クラスから容量を事前検証し、受理済みの
プレイヤー技やボス必須攻撃をプール不足で不発にしない。

## 10. Stage and readability contract

必須規約:

- ST-001: 装飾物には原則として当たり判定を付けない。
- ST-004: 試作の背景大型可動物は2個以下。
- ST-005: 試作の一画面ギミックは2個以下。
- ST-007: 重要な足場と背景の明度差を確保する。
- ST-008: 攻撃予告と背景エフェクトの色・形を混同させない。
- ST-009: 前景でプレイヤーを完全に隠さない。
- ST-010: 移動経路を二値シルエットでも認識可能にする。

ST-002（反復感）、ST-003（視覚的優先順位）、ST-006（装飾密度）は制作目安であり、数値だけで
不合格にしない。通常、グレースケール、色覚補助、最低画質で可読性を検査する。

Phase 2最低基準では、情報を色だけで区別せず、playerとtargetへ高contrast outlineを付ける。
1920×1080で表示する文字は24px以上、camera shakeは使用しない。最低画質でも操作対象と、実装済みの
危険表示を維持する。具体palette、telegraph pattern、他解像度scale、後続PhaseのshakeはOD-043-POST。

## 11. Explicit exclusions

現在の承認範囲に含めない:

- MMO通信、アカウント、永続サービス、課金、ギルド、市場
- 巨大マップ、全素材、全プラットフォーム展開
- AI仲間、画面分割、ローカル複数人、ネットワーク協力
- 本番アート・音響の量産
- キャラクタークリエイト、装備着色、スキルツリーUI
- 疲労破壊、永久損傷、加工履歴巻き戻し、精密外見変形
- 捕獲・封入、クラフト、倉庫、精密解体
- 汎用プラグイン基盤、全データ型の先行実装、完全決定論、ロールバック

## 12. Current gate and escalation

Gate 1は2026-07-14にPass、Phase 1はCompleteとなった。KBM実動作と総合体感をGate 1証拠へ採用し、
物理gamepad証拠はGate Playabilityまで延期した。Phase 1工数は承認済み再見積りで13.83%。Phase 2
entry P1は承認済みで、現在は`MFO-WO-P2-2A-001`のSlice 2-Aだけを実装許可する。2-B以降、損傷、
HUD統合、素材、boss、stageは別work orderまでlockする。詳細は [`IMPLEMENTATION_STATUS.md`](IMPLEMENTATION_STATUS.md)
と [`MILESTONES.md`](MILESTONES.md) を参照する。

未確定事項は [`OPEN_QUESTIONS.md`](OPEN_QUESTIONS.md) に集約する。既存決定から一意に導けない場合、
担当チャットは実装せず、質問を登録して `00統括` へ戻す。
