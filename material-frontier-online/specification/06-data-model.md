# Material Frontier Online — データ構造案

- 文書状態: レビュー草案
- 対象: エンジン非依存の最小試作設計
- 原則: 見た目は多様でも、内部処理は少数の共通データと効果へ集約する
- 今回の改訂根拠: `origin: user_explicit`（追加・変更指示）、`user_approved`（条件付き承認された既存方針）
- Gate 0: 閉鎖中。本文書の改訂はデータ基盤の実装承認ではない

## 1. 設計原則

> origin: 1～7は `user_approved`、8は `codex_recommendation`、9～12は `user_explicit`

1. 素材、技、魔法、敵ごとに専用クラスを増やさない。
2. 不変の定義データと、戦闘中に変化する実行状態を分離する。
3. 素材選択や装備変更時に戦闘用ステータスを事前計算する。
4. 戦闘中は完成済みの `MaterialSnapshot` を参照する。
5. ホットパスでは表示名を比較せず、安定ID、列挙値、整数、ビットフラグを使う。
6. 7部位の上限と、攻撃判定50件の `PrototypeStressTarget` を区別し、検証・予約付きプールへ反映する。
7. 視覚パーティクル、火花、破片を戦闘エンティティにしない。
8. 実測で必要になるまで、大規模ECSや完全決定論を導入しない。
9. プレイヤーデータを `AvatarIdentity`、`MaterialJob`、`CombatForm`、`EquipmentInstance`、`Appearance` の5層へ分離する。
10. 素材は性能、耐性、損傷時の壊れ方を決め、`CombatForm` は操作、移動補正、アクションセット、当たり判定形状を決める。
11. 疲労破壊で失われるのは `EquipmentInstance` とその個体へ適用された加工・スキルツリーであり、人格・名前・顔・声などの `AvatarIdentity` ではない。
12. `Heat` と `BurnCurse` は別の作用チャンネルとし、耐熱性・炎耐性・バーン耐性を自動的に相互変換しない。

## 2. 全体構造

> origin: `user_explicit`（5層モデルと責務境界）、`user_approved`（共通定義へ分解する構造）、`assistant_proposal`（個別定義の詳細）

```text
Definition Data
  ├─ MaterialJobDefinition
  ├─ MaterialDefinition
  ├─ CombatFormDefinition
  ├─ ActionDefinition
  ├─ EffectDefinition
  ├─ StatusDefinition
  ├─ EnemyDefinition / EnemyPartDefinition
  ├─ StageDefinition / GimmickDefinition
  ├─ LootTableDefinition
  └─ PresentationDefinition
          ↓ 読み込み・検証・事前計算
Player Composition
  ├─ AvatarIdentity
  ├─ MaterialJob
  ├─ CombatForm
  ├─ EquipmentLoadout
  │    └─ EquipmentInstance (MVPではcore 1個のみ)
  └─ Appearance
          ↓
MaterialSnapshot + Runtime State
          ↓ シミュレーション
DomainEvent
          ↓
Animation / VFX / SFX / UI
```

表示データから戦闘結果を逆算しない。VFXが欠落してもダメージ、部位破壊、報酬は変わらない。

## 3. 安定IDと表示名

> origin: `codex_recommendation`

各定義は、言語や世界内名称に依存しない `id` を持つ。

```text
id: material.steel.knight.prototype
display_name_world: ナイト
reference_name: 鉄鋼系試作
```

- `id` は保存・参照・通信候補に使い、公開後は原則変更しない。
- `display_name_world` は戦闘や会話で使う。
- `reference_name` は図鑑や材料工学表示で使う。
- 翻訳文は定義本体へ直書きせず、ローカライズキーへ分離できる形にする。

## 4. プレイヤーデータの5層モデル

> origin: `user_explicit`

5層は別々のライフサイクルを持つ。試作では永続保存を実装しないが、同じ構造体へ押し込まない。

### 4.1 `AvatarIdentity`

名前、顔、髪、声、人格など、プレイヤーが作成した個体のアイデンティティを保持する。戦闘性能へ影響させない。

```text
avatar_id
name
face_id
hair_id
voice_id
personality_profile_id
flavor_profile
```

- 装備の損傷、変形、疲労破壊を格納しない。
- 疲労破壊後も消失・初期化しない。

### 4.2 `MaterialJob`

ナイト系鉄鋼、アルミ、銅、SUSなどの材料系統を表し、基本物性、魔法適性、耐性、損傷時の壊れ方を選ぶ。

```text
material_job_id
material_definition_id
material_skill_tree_definition_id
unlocked_blueprint_ids[]
snapshot_policy_id
```

- `MaterialJob` は材料系統と設計知識を指す。
- 個々の装備へ実際に適用した加工ノードと個体スキル進行は `EquipmentInstance` が保持する。
- 疲労破壊で `MaterialJob` の定義や既知の設計図そのものを削除しない。

### 4.3 `CombatForm`

刃、板、盾、線、管、容器などの製品形状を表し、操作方法と攻撃手段を決める。素材ステータスを複製しない。

```text
combat_form_id
combat_form_definition_id
selected_action_overrides[]
```

- 素材が「攻撃の性能と壊れ方」を決める。
- `CombatForm` が「操作、移動補正、アクションセット、攻撃形状」を決める。

### 4.4 `EquipmentInstance`

現在使用している武器・鎧など、一つの装備個体を表す。非戦闘時の保存元となる損傷値と、将来の育成履歴の権威データはこの層に置く。戦闘中の可変な損傷値は `EquipmentRuntimeState` だけを正とし、戦闘終了後に永続化する将来段階でのみ検証済み結果を一度だけ書き戻す。

```text
equipment_instance_id
owner_avatar_id
equipment_slot
material_job_id
material_definition_id
combat_form_id
integrity_current
integrity_max
deformation                 // 0..100
temperature
processing_state
processing_history[]          // 将来予約。MVPでは生成しない
fatigue_history               // 将来予約。MVPでは生成しない
instance_skill_tree_state     // 将来予約。MVPでは生成しない
appearance_id
destroyed                     // 将来予約。MVPでは状態遷移させない
schema_version
```

- `Integrity` は当該装備個体の一般的なHPに相当する。
- `Deformation` は `Integrity` と独立した損傷軸であり、試作では閾値ペナルティ1種類だけを適用する。
- `processing_state` は熱処理、表面処理、組織等の現在状態を、`processing_history` は適用履歴を保持する。
- `fatigue_history` は将来、累積負荷、亀裂段階、推定残存寿命等を拡張可能な形で保持する。
- `instance_skill_tree_state` はこの装備個体へ実際に適用した加工・スキルノードを保持する。
- 将来の疲労破壊時は `destroyed = true` とし、この個体の `processing_state`、`processing_history`、`instance_skill_tree_state` を再使用不能にする。`AvatarIdentity` は変更しない。
- `processing_history`、`fatigue_history`、`instance_skill_tree_state`、`destroyed` は将来予約である。最小試作では生成、更新、保存、UI表示せず、これらに由来するイベントも発行しない。未生成を空の履歴や既定値と解釈して処理を開始しない。

### 4.5 `EquipmentLoadout`

プレイヤーが使用する装備個体を束ね、どの個体がプレイヤー本体の損傷状態を所有するかを一意にする集約ルート。

```text
loadout_id
owner_avatar_id
core_equipment_instance_id
equipment_instance_ids[]
schema_version
```

- 最小試作では `equipment_instance_ids[]` の要素数を**正確に1**とし、その唯一の要素が `core_equipment_instance_id` と一致する。
- core装備だけが、プレイヤーの `Integrity`、`Deformation`、`temperature` を所有する。
- 武器・鎧ごとの独立耐久、複数スロット、被弾箇所に応じた損傷分配は後回しにする。
- core装備を差し替える将来操作は、ランタイム状態と `MaterialSnapshot` を一括再構築する原子的なLoadout変更として扱う。Actor側の参照だけを単独変更してはならない。

### 4.6 `MaterialJob`／`CombatForm`参照の権威

最小試作では、core `EquipmentInstance` の `material_job_id` と `combat_form_id` を、現在の戦闘構成に関する唯一の書き換え可能な正とする。

- `ActorRuntimeState` の `resolved_material_job_ref` と `resolved_combat_form_ref` は、戦闘開始時にcore装備から解決する読み取り専用キャッシュである。
- Actor側の解決済み参照を独立に編集・保存しない。
- `MaterialJob` または `CombatForm` を変更するときはcore `EquipmentInstance` の参照を変更し、Loadout検証後にActorランタイムと `MaterialSnapshot` を一括再生成する。
- 読み込み時と戦闘開始時に、core装備の `material_job_id` が存在すること、`combat_form_id` が存在すること、その形状が `MaterialJobDefinition.allowed_combat_form_ids[]` に含まれることを検証する。
- Actorの解決済み参照とcore装備の参照が一致しない場合はデータ不整合として開始を拒否し、どちらかへ暗黙に上書きしない。

### 4.7 `Appearance`

鎧・武器の外装、主色、副色、発光色など、性能から分離した見た目を保持する。

```text
appearance_id
armor_skin_id
weapon_skin_id
primary_color
secondary_color
emissive_color
surface_finish_id
decal_ids[]
```

- `Appearance` の値からダメージ、耐性、当たり判定を決定しない。
- 素材固有の被弾音、変形表示、熱表示などの読み取り専用表現は `MaterialSnapshot` と状態イベントから選ぶ。

## 5. 定義データ

> origin: `user_explicit`（`CombatFormDefinition`、装備個体境界、Heat/BurnCurse）、`assistant_proposal`（既存の共通定義群）

### 5.1 `MaterialJobDefinition`

```text
id
material_definition_id
material_skill_tree_definition_id
allowed_combat_form_ids[]
display_name_world
schema_version
```

### 5.2 `MaterialDefinition`

```text
id
display_name_world
reference_name
base_stats
trait_ids[]
resistance_profile_id
presentation_id
schema_version
```

試作の `base_stats` 候補:

```text
max_integrity
physical_power
toughness
mass
mobility
electrical_conductivity
thermal_conductivity
heat_tolerance
burn_curse_resistance
corrosion_resistance
magnetic_response
```

すべてを使う必要はない。計算へ使わない物性値は `ReferenceMaterialData` へ分離し、図鑑だけで表示する。

素材由来の値は攻撃威力、耐性、変形しやすさ、疲労特性などへ反映する。入力割り当てやモーションはここで決めない。

### 5.3 `MaterialSnapshot`

戦闘開始時に `MaterialDefinition` と将来の加工・装備修正から生成する読み取り中心の完成値。

```text
source_material_id
resolved_stats
trait_bits
resistance_channels
damage_behavior_profile_id
action_modifier_table
snapshot_version
```

試作では素材プリセット選択時だけ再計算する。被弾や攻撃のたびにスキルツリーを走査しない。

### 5.4 `CombatFormDefinition`

```text
id
form_category
action_set_ids[]
movement_modifier
hit_shape_profile
attachment_points[]
presentation_id
```

- `action_set_ids[]` が、その形状で利用できる軽攻撃、強攻撃、回避、特殊行動等を定める。
- `movement_modifier` が旋回、移動、回避距離等の形状差を定める。
- `hit_shape_profile` は共通の円、カプセル、矩形、扇形等を参照し、素材ごとの専用判定を作らない。
- `attachment_points[]` は武器、端子、VFX等の取り付け位置を表す。

### 5.5 `ActionDefinition`

物理攻撃、魔法、回避、操作を共通形式で定義する。

```text
id
category              // physical, magic, evade, interact
windup_seconds
active_seconds
recovery_seconds
cooldown_seconds
resource_cost
load_rank
hit_shape_id
effect_ids[]
animation_id
vfx_id
sfx_id
priority
hit_query_reservation_class
max_concurrent_hit_queries
merge_group_id
```

`hit_query_reservation_class` はプレイヤー操作由来の重要判定、ボスの必須判定、低優先度判定などの予約区分を表す。受理済みのプレイヤー技がプール不足で不発にならないよう、行動受理前に必要枠を保証する。

### 5.6 `EffectDefinition`

技の作用を少数の共通効果へ分解する。

```text
id
effect_type           // damage, part_damage, heat_change, force, apply_status 等
channel               // physical, electric, heat, burn_curse 等
magnitude
duration
target_rule
stack_rule
tags
```

構成例:

```text
軽攻撃      = Damage + PartDamage
強攻撃      = Damage + PartDamage + Knockback
放電        = Damage(electric) + ApplyStatus(electric)
抵抗加熱    = HeatChange + PartDamage(heat)
磁気作用    = Force + ApplyStatus(magnetic_hold)
```

`Heat` と `BurnCurse` は正式に別チャンネルとする。

- `Heat`: 温度上昇、軟化、溶融、熱衝撃などの通常の熱作用。
- `BurnCurse`: 育成、加工、組織、耐性を崩す呪い作用。
- `heat_tolerance` や炎耐性から `burn_curse_resistance` を自動導出しない。
- 同一の攻撃が両方を与える場合も、2つの `EffectDefinition` として独立に解決する。

### 5.7 `StatusDefinition`

```text
id
channel
duration
tick_rate
stack_rule
max_stacks
aggregated_modifiers
presentation_id
```

同じ種類の継続効果を発生元ごとに無制限保持せず、温度変化率、腐食変化率、移動修正などのチャンネルへ集約する。

### 5.8 `EnemyDefinition`

```text
id
base_stats
part_definitions[]       // 最大7
action_ids[]
ai_state_definition_id
phase_rules[]
loot_table_id
presentation_id
```

### 5.9 `EnemyPartDefinition`

```text
part_id
display_name
hit_shape_id
max_hp
defense_profile_id
body_damage_ratio
break_threshold
break_effect_ids[]
loot_condition_bits
presentation_states
```

7部位以内なので、破壊状態は1つの整数ビット集合で保持できる。見た目の装飾部品は主要部位へ所属させ、部位数へ数えない。

### 5.10 `StageDefinition`

```text
id
gameplay_geometry_id
spawn_points[]
gimmick_ids[]
visual_layer_ids[]
lighting_budget
audio_zone_ids[]
camera_bounds
```

衝突用の `gameplay_geometry` と、装飾用の `visual_layer` を分離する。背景タンク、配管、手すりをゲームエンティティとして常駐させない。

### 5.11 `GimmickDefinition`

```text
id
state_machine_id
trigger_rule
cooldown_seconds
effect_ids[]
collision_change_id
presentation_id
```

試作では待機、作動、クールダウン程度の状態だけを使う。

### 5.12 `LootTableDefinition`

```text
id
entries[]
  item_id
  min_quantity
  max_quantity
  weight
  required_broken_part_bits
  forbidden_broken_part_bits
```

抽選はローカル権威シミュレーションが乱数シードを使って決定し、UIは結果だけを表示する。

### 5.13 `PresentationDefinition`

```text
sprite_or_animation_id
vfx_id
sfx_id
light_request
quality_fallback_ids
```

戦闘定義と表現定義を分けることで、最低画質やパーティクル無効でもルールを維持する。

## 6. 実行状態

> origin: `user_explicit`（装備個体の損傷所有権と攻撃判定上限時の方針）、`assistant_proposal`（既存ランタイム構成）

### 6.1 `WorldRuntimeState`

```text
simulation_tick
actor_states[]
enemy_states[]
active_hit_queries[]    // 予約区分付きプール。50はPrototypeStressTarget
gimmick_states[]
corpse_states[]
domain_event_queue
```

### 6.2 `ActorRuntimeState`

```text
entity_id
avatar_identity_ref
loadout_ref
resolved_material_job_ref
resolved_combat_form_ref
core_equipment_runtime_ref
appearance_ref
transform
velocity
facing_or_aim
material_snapshot_ref
cooldowns[]
resource_values
aggregated_statuses
state_flags
```

戦闘中のプレイヤー `Integrity`、`Deformation`、`temperature` は、`core_equipment_runtime_ref` が指す `EquipmentRuntimeState` を唯一の可変な正とする。`ActorRuntimeState` や元の `EquipmentInstance` へ同じ可変値を並行保持しない。試作のHUDもcore `EquipmentRuntimeState` から読み取る。

`resolved_material_job_ref` と `resolved_combat_form_ref` はcore装備の参照から生成した読み取り専用キャッシュであり、Actor独自の構成データではない。入力コマンドの検証と `MaterialSnapshot` はこの解決結果を使用するが、永続化や個別更新はしない。

### 6.3 `EquipmentRuntimeState`

永続化候補の `EquipmentInstance` から戦闘開始時に作る実行状態。戦闘開始時に値を一度コピーし、戦闘中はこの実行状態だけを更新する。戦闘終了時に永続化が必要な将来段階では、ローカル権威またはサーバー権威が検証済み結果を `EquipmentInstance` へ一度だけコミットする。最小試作では永続コミットを行わず、リトライ時に初期値から再生成してよい。

```text
equipment_instance_ref
integrity_current
deformation
temperature
heat_status
burn_curse_status
processing_state
state_flags
```

`heat_status` と `burn_curse_status` は別々に更新し、抵抗値も別々に参照する。

最小試作の `EquipmentRuntimeState` はcore装備1個についてだけ生成する。`processing_history`、`fatigue_history`、`instance_skill_tree_state`、`fatigue_accumulator`、`destroyed` はMVPランタイムへ展開しない。独立した武器・鎧ランタイムや複数装備への損傷分配も作らない。

### 6.4 `EnemyRuntimeState`

```text
entity_id
integrity
ai_state
phase
target_entity_id
part_hp[]
broken_part_bits
cooldowns[]
aggregated_statuses
state_flags
```

### 6.5 `HitQueryRuntime`

```text
query_id
owner_entity_id
action_id
shape
start_tick
end_tick
target_filter
already_hit_ids
priority
reservation_class
merge_group_id
```

- 円、カプセル、矩形、扇形など少数の形状だけを使う。
- プールから取得し、終了時に返却する。
- 同一アクションの意図しない多重命中を `already_hit_ids` で防ぐ。
- プレイヤー操作由来の重要判定には予約枠を確保し、装飾・低優先度判定がその枠を消費できないようにする。
- 同じ所有者・作用・時間帯・範囲として扱える判定は `merge_group_id` で一つへ統合する。
- 技ごとの最大同時判定数を定義時に制限し、想定同時実行の最悪ケースが予算を超えるコンテンツは読み込み・ビルド検証で失敗させる。
- ランタイム飽和は開発エラーとして記録・可視化する。受理済みのプレイヤー技を不発にしたり、効果を出さずに資源だけ消費したりしない。
- 視覚だけの弾、火花、破片は `HitQueryRuntime` を消費しない。

### 6.6 `CorpseRuntimeState`

```text
source_enemy_id
broken_part_bits
remaining_carves
loot_seed
despawn_time
claimed_flags
```

死体内へ物理アイテムを大量生成せず、必要なフラグと報酬表だけを保持する。

## 7. コマンドとイベント

> origin: `user_explicit`（Heat/BurnCurseと装備損傷イベントの分離）、`codex_recommendation`（コマンド／イベント境界）

### 7.1 `InputCommand`

```text
sequence
simulation_tick
move_vector
aim_vector
action_id
target_entity_id
target_part_id
```

`action_id` は要求であり、ローカル権威シミュレーションが現在の `CombatFormDefinition.action_set_ids[]` に含まれることを検証してから受理する。入力層だけで実行可否を確定しない。

### 7.2 `DomainEvent`

```text
ActionStarted
HitConfirmed
DamageApplied
DeformationChanged
TemperatureChanged
BurnCurseApplied
EquipmentFatigueChanged
EquipmentDestroyed
PartBroken
GimmickStateChanged
ActorDefeated
CorpseCreated
LootGranted
```

アニメーション、VFX、SE、UIはイベントを購読する。表示側からHP、部位フラグ、報酬を書き換えない。

`EquipmentFatigueChanged` と `EquipmentDestroyed` は将来予約イベント名である。最小試作ではイベント型の実装、生成、キュー投入、保存、購読、UI表示を行わない。core装備の `Integrity == 0` では `ActorDefeated` だけを発行し、`EquipmentDestroyed` へ読み替えない。

## 8. 更新頻度

> origin: `user_explicit`

- 入力、近距離移動、重要な当たり判定はシミュレーション更新で処理する。
- 温度・腐食は毎秒2～5回の独立スケジューラで集約更新する。
- 遠距離キャラクターの表示更新は毎秒5回以下とし、表示側で補間する。
- VFXは描画更新してよいが、戦闘結果を決定しない。

## 9. データ検証

> origin: `user_explicit`（予約枠・優先度・統合・設計時検証）、`assistant_proposal`（既存検証項目）

読み込み時に最低限、次を検証する。

- IDの一意性
- 参照先IDの存在
- 大型敵の部位数が7以下
- `MaterialJob`、`CombatForm`、`EquipmentInstance` の参照関係が有効
- `EquipmentLoadout` のcore参照が存在し、所有者が一致する
- 最小試作では `equipment_instance_ids[]` が正確に1件で、その要素が `core_equipment_instance_id` と一致する
- core装備の `material_job_id` と `combat_form_id` が存在し、形状が当該MaterialJobの許可一覧に含まれる
- Actorの読み取り専用 `resolved_material_job_ref`／`resolved_combat_form_ref` がcore装備からの解決結果と一致する
- `CombatFormDefinition.action_set_ids[]` の全参照が存在
- ステージのギミック数と画面内上限
- `PresentationDefinition.light_request` が有効な分類・品質フォールバックを参照する。背景4／戦闘8はデータ拒否上限にせず、負荷試験で同時に成立・計測する
- 行動の時間が負でない
- 効果の循環参照がない
- 報酬表に未知のアイテムがない
- 表現データがなくても代替表示を選べる
- スキーマバージョンが対応範囲内
- 各アクションの `max_concurrent_hit_queries` が非負で、予約区分が有効
- 想定同時実行時の重要判定が、コンテンツ組み合わせから事前算出した予約容量内へ収まる
- `PrototypeStressTarget` の同時50件を性能試験で成立させられる。50件をコンテンツ定義の拒否上限には使わない
- 統合可能と宣言した判定の作用、対象規則、持続時間が互換

## 10. 保存範囲

> origin: `user_explicit`（5層境界と実装範囲）、`assistant_proposal`（既存の試作保存範囲）

最小試作で保存してよいもの:

- 音量、画質、入力などの最小設定
- 最後に選んだ素材プリセット
- 最後に選んだCombatFormプリセット
- デバッグ表示の有無

保存しないもの:

- 永続キャラクター進行
- `AvatarIdentity`、`EquipmentInstance` の永続保存
- `EquipmentLoadout` の永続保存
- `processing_history`、`fatigue_history`、`instance_skill_tree_state`、`destroyed`
- スキルツリー
- インベントリ経済
- アカウント
- MMO状態

試作リザルトはセッション内だけで保持してよい。

## 11. 軽量化上の禁止事項

> origin: `user_explicit`（受理済み技の不発禁止）、`assistant_proposal`（既存禁止事項）

- 攻撃ごとにスキルツリー全体を再計算する
- 素材ごとに専用プレイヤークラスを作る
- 見た目の火花一つずつに当たり判定を付ける
- 全身を格子分割して熱・応力・電流を解く
- 装飾物へ個別AIや個別物理を付ける
- 死体内部に全報酬オブジェクトを先に生成する
- 表示名の文字列比較でゲームルールを分岐する
- 素材定義に入力操作や専用アクション実装を埋め込み、`CombatForm` と重複させる
- 疲労破壊で `AvatarIdentity` を削除・初期化する
- Actorとcore装備の両方に、独立して書き換え可能な `MaterialJob`／`CombatForm` 参照を持たせる
- core装備以外へプレイヤーの `Integrity`、`Deformation`、`temperature` を重複保持する
- 将来予約の履歴、疲労、個体ツリー、装備破壊イベントを最小試作で生成・更新・保存・表示・発行する
- 攻撃判定プール不足を理由に、受理済みのプレイヤー技を不発にする
