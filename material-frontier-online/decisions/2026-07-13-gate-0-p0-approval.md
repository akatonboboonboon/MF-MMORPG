# Material Frontier Online — Gate 0 P0 Decision Record

- Record ID: `MFO-DR-GATE0-2026-07-13`
- Decision date: 2026-07-13
- Status: **Effective**
- Gate 0: **Open**
- Authority: `user_approved`
- Approved P0 count: **13 / 13**
- Remaining P0 count: **0**
- Specification baseline: [`../deliverables/Material-Frontier-Online-Integrated-Specification.docx`](../deliverables/Material-Frontier-Online-Integrated-Specification.docx)
- Specification SHA-256: `66df0882ad4320b07850c745a0ac7cc5d8e091e0f4dd66a38e9d6237bb89babf`

## 1. Approval statement

ユーザーが提示したGate 0一括決定案を、以下の13件について正式な `user_approved` 決定として記録する。これによりGate 0をOpenとし、統合仕様書のPhase 1に限定して実装開始を承認する。

この記録は完成済み仕様ベースラインを再編集するものではない。P1/P2、後回し機能、性能予算、ステージ制作規約、各Gateの受入条件は変更しない。

## 2. Approved P0 decisions

| ID | Approved decision | origin |
|---|---|---|
| OD-001 | 斜め俯瞰2D。固定方角、8方向移動、全方向照準、移動方向と照準方向を分離する。本格Z軸・ジャンプは持たず、回避は地上ステップとする | `user_approved` |
| OD-002 | Windows x86_64向けネイティブ・ポータブルビルド。ZIP展開型、単体EXE、インストーラー・ストア・Web・スマホは試作対象外 | `user_approved` |
| OD-003 | Godot Engine 4.7 stable通常版とGDScriptを採用する。.NET/C#、開発版、RC版は使わない | `user_approved` |
| OD-004 | 実際の開発PCを基準端末とする。Intel Core 7 150U、Intel Graphics、16 GB DDR5、Windows 11 Home、1920×1080、標準画質、性能優先の電源設定、リリース相当、60 fps | `user_approved` |
| OD-006 | 操作可能キャラクターは1人だけ実装し、空間とデータ構造のみ将来4人対応可能にする。AI仲間、画面分割、ローカル複数人、ネットワーク、複数コントローラーは入れない | `user_approved` |
| OD-007 | 3素材系統はナイト系鉄鋼、アルミ、銅とする | `user_approved` |
| OD-008 | 物理攻撃は快斬と重断の2種類とする | `user_approved` |
| OD-009 | 魔法は放電、抵抗加熱、磁気パルスの3種類とする | `user_approved` |
| OD-010 | 大型敵は炭酸圧獣《バーストボア》とする | `user_approved` |
| OD-011 | ステージは飲料充填工場・炭酸ラインとする | `user_approved` |
| OD-012 | 環境ギミックは可逆コンベアとCIP洗浄水の2個とする。圧力弁は独立ギミックにせずボスの頭部安全弁へ統合する | `user_approved` |
| OD-013 | ゲームパッドを主入力とし、同じ抽象入力へキーボード・マウスも対応させる | `user_approved` |
| OD-016 | 3素材共通の片手刃型CombatFormを1形態だけ実装する | `user_approved` |

## 3. Locked implementation details

### OD-001 — View and movement

- Camera rotation: none
- Locomotion: 8 directions
- Aim: full direction
- Real height physics and jumping: none
- Evade: ground step
- Visual-only hops may exist without adding Z-axis simulation

### OD-002 / OD-003 — Platform and engine

- Target: Windows x86_64
- Distribution: portable ZIP / standalone executable
- Engine: Godot Engine 4.7 stable, Standard build
- Language: GDScript
- Export templates: engine versionと一致させる
- 4.7.xの安定パッチ版へ移行するときは、別ブランチで自動テスト、起動、戦闘、exportを確認してから更新する

Godot公式の4.7 stable配布日は2026-06-18である。2026-07-13時点の4.7.1はRCであり、この決定には含めない。

- Official archive: <https://godotengine.org/download/archive/4.7-stable/>
- Release policy: <https://docs.godotengine.org/en/stable/about/release_policy.html>

### OD-004 — Reference device

| Field | Approved value |
|---|---|
| CPU | Intel(R) Core(TM) 7 150U |
| GPU | Intel(R) Graphics |
| RAM | 16.0 GB DDR5（15.7 GB使用可能） |
| OS | Windows 11 Home x86_64 |
| Resolution | 1920×1080 |
| Quality | 標準 |
| Power profile | 性能優先。Gate 1の計測記録で実際のWindows表示名を一意に残す |
| Build | リリース相当 |
| Target | 60 fps、P95 frame time 16.67 ms以下 |

OS build、GPU driver、Godot rendererは最初の性能計測時に実測記録へ追加する。正式版の最低動作環境へは自動流用しない。

### OD-006 — Four-player-ready boundary

将来4人を妨げない対象は、アリーナ余白、前後左右から狙える部位配置、Actor配列、`target_entity_id`、パーティーHUD余白、4スポーン枠、複数人対応の部位ロック境界とする。

性能試験時の残り7人は、移動・表示・状態表示だけを持つ負荷代理であり、プレイヤー、AI仲間、通信Actorとして実装しない。

### OD-007 — Material roles

| MaterialJob | Prototype role |
|---|---|
| ナイト系鉄鋼 | 高Integrity、高被変形耐性、高物理部位ダメージ、低速・重量、強い磁気反応 |
| アルミ | 高移動性能、高熱伝導、低質量、中物理部位ダメージ、低耐熱上限、鉄鋼より低い被変形耐性 |
| 銅 | 最高電気伝導、高熱伝導、高魔法効率、低物理耐久・低物理部位ダメージ、アルミより重い |

### OD-008 — Physical actions

| Action | ID | Prototype role |
|---|---|---|
| 快斬 | `action.physical.quick_cut` | 短い予備動作と後隙、低～中ダメージ、低部位破壊力、方向修正しやすい差し込み攻撃 |
| 重断 | `action.physical.heavy_cleave` | 長い予備動作と後隙、高部位破壊力、小前進、大きな自己負荷、硬直・ギミック後向け |

重断の自己負荷を後隙、`Deformation`補正、その他のどれで表すかはP1調整として残し、疲労破壊は実装しない。

### OD-009 — Magic actions

| Magic | ID | Prototype role |
|---|---|---|
| 放電 | `magic.arc_discharge` | 即時電気ダメージと短い電気状態。導電対象・濡れ床で強化し、銅が最高効率 |
| 抵抗加熱 | `magic.resistive_heating` | 対象部位の温度を継続上昇。一定温度で単一の承認済み低下を適用し、水で冷却 |
| 磁気パルス | `magic.magnetic_pulse` | 磁気タグ対象へ力を加える。試作初期は押し出しだけを実装 |

3魔法は専用システムを増やさず、`Damage`、`HeatChange`、`Force`、`ApplyStatus`の共通効果から構成する。濡れ床の電気強化を範囲または効率のどちらで表すか、加熱時にどの耐性を下げるかはP1調整として残す。

### OD-010 — Boss

- ID: `enemy.carbonation.burst_boar.prototype`
- Theme: 炭酸飲料の保管、内圧、気密、充填、圧力解放
- Breakable parts: 頭部安全弁、左右圧力嚢、前脚ピストン、後部噴射口の5部位
- Body core: 左右圧力嚢破壊後に露出する本体弱点領域。6番目の破壊部位ではない
- Attacks: 加圧突進、炭酸噴射、過圧衝撃波
- Defeat: 安全放出しながら機能停止し、剥ぎ取り可能な残骸を残す

試作報酬は`loot.pressure_core.prototype`（圧力核）、`loot.seal_membrane.prototype`（気密膜）、`loot.carbonate_sample.prototype`（炭酸内容物サンプル）とし、数量表示だけを行う。

### OD-011 / OD-012 — Stage and gimmicks

- Stage ID: `stage.filling_plant.carbonation_line.prototype`
- Route: 短い搬入通路 → 操作説明区画 → 充填ライン兼ボスアリーナ → 剥ぎ取り・リザルト
- Gimmick 1: `gimmick.conveyor.reversible`。正転、停止、逆転
- Gimmick 2: `gimmick.cip_wash.water_field`。時間制の濡れ領域
- CIP water: 電気作用を強め、加熱を冷却する。摩擦変化と腐食計算は実装しない
- Background equipment: 原則として当たり判定を持たせない

### OD-013 — Abstract input

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

Gamepad defaults: left stick move, right stick aim, X快斬, Y重断, A回避, LBロックオン, RB操作・剥ぎ取り, LT+X/Y/Bで3魔法。

Keyboard/mouse defaults: WASD move, mouse aim, left/right click physical attacks, Space evade, Q lock, E interact, 1/2/3 magic。

### OD-016 — CombatForm

- ID: `combat_form.blade.one_hand.prototype`
- Includes: 快斬、重断、方向ステップ、剥ぎ取り、ギミック操作、魔法3枠
- Excludes: 盾、空中コンボ、ジャストガード、武器持ち替え、派生コンボツリー、二刀流、複数の溜め段階
- Purpose: 3素材で同じ形状を使い、材料差だけを比較する

## 4. Additional approved decisions

次のP0外事項も、ユーザーの同一承認によって解決済みとする。

| ID | Approved decision | origin |
|---|---|---|
| OD-031 | アルミ母材は導体。酸化皮膜由来の魔法耐性を独立した静的パラメータで持つ。動的な皮膜破壊・再生・導通切替はMVPに入れない | `user_approved` |
| OD-034 | 戦闘・会話では世界内名、図鑑・詳細では実在材料名、内部IDは言語非依存とする | `user_approved` |
| OD-035 | 剥ぎ取り物は用途器官と内容物サンプルとする | `user_approved` |
| OD-037 | `MFO`を正式略称とする | `user_approved` |

OD-015はP2のまま維持する。添付画像は今回のMVP決定根拠に使わず、再提示された場合も既存仕様との差分候補としてだけ確認する。

## 5. Decisions that remain outside Gate 0

- `OD-020`: 回避無敵、キャンセル、ロックオン詳細
- `OD-022`: ボスAIの数値・フェーズ詳細
- `OD-023`: 部位HPと本体HPの伝達規則
- `OD-024`: 剥ぎ取り回数・時間・抽選詳細
- `OD-025`: 魔法資源
- `OD-026`: HUD常時表示項目
- `OD-027`: 変形ペナルティ対象・閾値・効果量
- `OD-041`: 基準カメラ
- 性能計測時の電源設定表示名、OS build、GPU driver、renderer

これらは各機能または計測へ着手する前に決めるP1であり、Gate 0を再度閉じる理由にはしない。

## 6. Gate result

```text
Specification phase: Complete
P0 decision phase: Complete
Gate 0: Open
Next phase: Phase 1 — Technical foundation and measurement environment
```

Gate 0のOpenは、巨大な基盤、MMO通信、課金、アカウント、本番アセット量産、正式版プラットフォーム展開の承認ではない。
