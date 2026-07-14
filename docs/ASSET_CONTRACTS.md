# Material Frontier Online — Asset and Presentation Contracts

- Updated: 2026-07-14
- Owner: `00統括（監督）`
- Contract state: Responsibility boundaries and Phase 2 camera/HUD/readability baseline approved; production payloads and look/audio details open

この文書は、ゲームプレイ・コアとステージ／UI／グラフィックの接続境界を定義する。
イベントの存在は、特定VFX、SE、ヒットストップ、camera shake、配色、HUDレイアウトの承認を意味しない。

## 1. Non-negotiable invariants

- Presentationは`DomainEvent`または読み取り専用状態を消費するだけで、権威状態を書き換えない。
- 命中、ダメージ、`Integrity`、`Deformation`、温度、部位、ギミック、討伐、報酬、乱数はシミュレーションが決める。
- `Appearance`、画像、animation、VFX、色、音から性能、判定、耐性を逆算しない。
- `Heat`と`BurnCurse`は別チャンネル。表示上も同一状態へ暗黙統合しない。
- パーティクル、破片、残光、光源、camera、BGM、SEは戦闘結果を決定しない。
- 視覚弾、火花、破片は`HitQueryRuntime`を消費しない。
- 画質fallbackで、攻撃予告、操作対象、プレイヤー輪郭、部位状態、ギミック状態、主経路を消さない。
- 装飾・背景・前景・decalにゲームプレイ衝突を持たせない。例外は承認済みGameplayGeometry／InteractiveGimmickだけ。
- `EquipmentFatigueChanged`と`EquipmentDestroyed`は将来予約。MVPで実装、発行、購読、表示しない。

## 2. Definition-side asset references

ゲームプレイ定義はアセット実体ではなくstable IDを参照する。

```text
ActionDefinition
  animation_id
  vfx_id
  sfx_id

CombatFormDefinition
  presentation_id
  attachment_points[]

PresentationDefinition
  sprite_or_animation_id
  vfx_id
  sfx_id
  light_request
  quality_fallback_ids
```

契約:

- IDが見つからない場合に戦闘結果を変えない。
- presentation assetの差し替えで`ActionDefinition`のtiming、shape、effect、costを変えない。
- `attachment_points[]`は表示取り付け位置であり、権威判定形状を暗黙変更しない。
- quality fallbackは同じゲームプレイ意味を保つ。

## 3. Current Phase 1 debug event surface

次は現在の実装から抽出した**Phase 1 debug schema**であり、本番payload契約ではない。

| Event | Current payload | Current consumer | Durability |
|---|---|---|---|
| `DefinitionsValidated` | `ok`, `errors`, `query_capacity`, `actor_count`, `target_count` | Debug log/HUD | Debug-only |
| `CommandRejected` | `actor_entity_id`, `reason` | Debug log | Debug-only |
| `MovementApplied` | `actor_entity_id`, `moving`, `position`, `aim` | Debug log/HUD | Debug-only |
| `AttackRequested` | `action_id`, `actor_entity_id`, `requested_target_entity_id` | Debug log | Debug-only |
| `HitQueryReservationRejected` | `action_id`, `reason` | Debug log/telemetry | Debug-only; accepted action behaviorの本番契約にしない |
| `HitConfirmed` | `action_id`, `effect_id`, `target_entity_id`, `target_instance_id`, `debug_hit_value` | Debug log/HUD | Name overlaps future event; payload remains provisional |
| `AttackResolved` | `action_id`, `hits`, `query_released`, `active_hit_queries` | Debug log/telemetry | Debug-only |

`target_instance_id`はprocess-local、`debug_hit_value`はPhase 1仮値であり、保存、ローカライズ、asset key、
本番UI契約に使用しない。

現在のtarget flashはsimulation nodeの`receive_provisional_hit()`内、player／target placeholder描画もsimulation node内にある。
これはPhase 1の縦経路検証用placeholderであり、Presentationが権威を持つ先例にしない。正式統合時は、承認済みイベント契約を
経由して表示へ移す。

## 4. Reserved production semantic events

次の名前と意味上の権威境界は凍結仕様にある。ただしpayload、必須VFX／SE、timing ownership、画面表現は未決定。

| Event | Authoritative fact | Presentation may do | Presentation must not do | Payload status |
|---|---|---|---|---|
| `ActionStarted` | 行動が権威側で開始された | 承認済みanimation／予告を開始 | windup、cost、発動可否を変更 | Open |
| `HitConfirmed` | 指定actionが指定targetへ命中 | 承認済み命中表現を再生 | 命中対象やdamageを変更 | Open |
| `DamageApplied` | damageと残り状態が確定 | 読み取り専用表示 | damageを再計算・上書き | Open |
| `DeformationChanged` | 変形値／閾値状態が確定 | 承認済みHUD／表示を更新 | 閾値、penalty、敗北を決定 | Open |
| `TemperatureChanged` | 温度状態が確定 | 承認済み熱表現を更新 | Heat結果を再計算 | Open |
| `BurnCurseApplied` | BurnCurseが独立して適用 | 承認済み呪い表現を更新 | Heatへ読み替え、加工状態を変更 | Open |
| `PartBroken` | 部位破壊flagが確定 | 破壊状態を判別可能に表示 | 部位／本体HP、loot条件を変更 | Open |
| `GimmickStateChanged` | gimmick状態が確定 | 待機／作動等を判別可能に表示 | 作動結果、位置、状態を上書き | Open |
| `ActorDefeated` | core `Integrity == 0`で敗北確定 | 承認済み敗北表示 | `EquipmentDestroyed`へ読み替え | Open |
| `CorpseCreated` | 剥ぎ取り可能な残骸が生成 | 操作可能性を判別可能に表示 | 権利、回数、seedを変更 | Open |
| `LootGranted` | item ID、数量、権利消費が確定 | 結果を表示 | 再抽選、数量変更、重複付与 | Open |

payloadがOpenのイベントへ依存する実装は、必要fieldを [`OPEN_QUESTIONS.md`](OPEN_QUESTIONS.md) の
OQ-001へ提出し、監督承認まで停止する。

## 5. Information-preservation contract

表現方法の詳細は未決定でも、次の意味は最低画質を含め失わない。

1. 即時または近日中にdamageを与える範囲
2. boss本体、部位、破壊状態
3. gimmickの危険、操作可能性、状態
4. playerと将来の味方の輪郭
5. 剥ぎ取り可能位置
6. 入口、出口、主経路

背景装飾より1～5を優先する。攻撃予告専用の色・輪郭・形・patternの具体値はOD-043-POSTで決定する。

## 6. Stage layer contract

```text
GameplayGeometry        collision allowed
InteractiveGimmick      approved gameplay collision allowed
LargeStructureVisual    no collision unless separately approved
EquipmentVisual         no collision
Decoration / Decal      no collision
Foreground              no collision; never fully hides player
Lighting / Particles    no gameplay collision or authority
```

一画面の独立gimmickは最大2、試作の大型可動背景は最大2。工業設備として意図した規則反復は許可されるが、
経路、部位、予告を妨げない。

## 7. Phase 2 approved presentation baseline

The following decisions constrain future presentation work but do not by themselves authorize integration:

- `OD-026`: read-only persistent HUD shows `Integrity` and `Deformation`; temperature appears only after its
  behavior exists, and charge is not shown before Phase 3.
- `OD-041-P2`: 1920×1080, fixed direction, zoom 1.0, current one-screen camera; no dynamic zoom in Phase 2.
- `OD-043-P2`: do not rely on color alone; player and target use high-contrast outlines; 1080p text is at least
  24px; no Phase 2 camera shake; operation targets and existing danger displays survive lowest quality.

These facts do not approve a production layout, palette, animation, VFX, event payload, or consumer. Slice 2-A
has no presentation integration authorization.

## 8. Open presentation choices

次は契約化されていない。担当チャットが独自決定しない。

- OD-040: 美術スタイル
- OD-041-POST: dynamic zoom、正式画面内人数、boss最大表示寸法、boss／stage framing
- OD-042: 仮音響範囲
- OD-043-POST: production palette／pattern、他解像度scale、後続Phaseのshake、文字階層
- OQ-001: production event payload
- OQ-004: hit VFX、素材別接触SE、hitstop、camera shakeとtiming ownership

## 9. Contract change template

```text
Contract ID:
Owner:
Status: Proposed / Approved / Current / Deprecated
Milestone:
Source decision:
Producer:
Consumer:
Event or read-only field:
Required payload:
Required information to communicate:
Quality fallback:
Forbidden side effects:
Tests:
Open questions:
```

実装担当は`Proposed`差分を提出できる。監督が`Approved`へ変更する前に依存実装を開始しない。
