# Phase 2 Slice 2-B Stage A — common action foundation 実装報告

- 日付: 2026-08-01
- Work order: `MFO-WO-P2-2B-001`
- 状態: **Implementation ready for supervisor review / QA acceptance pending**
- Base: `dd36e7e8d3c2e3ad7c5db74a056fe0694027a564`
- Branch: `codex/phase2-slice2b-action-foundation-gameplay`
- Dedicated worktree: `C:\tmp\m2b`
- Godot: `4.7.stable.official.5b4e0cb0f`

この成果は非接続Stage A基盤だけである。Slice 2-A performance acceptance、Gate 2、playable Slice 2-B、
production action、入力／simulation／scene統合を受理または解錠しない。

## 実装結果

### Common Action scaffold

既存の `Phase1ActionDefinition`、既存export、`validate()`、Phase 1 resourceを維持したまま、次を追加した。

- category: `physical` / `magic` / `evade` / `interact`
- `windup_seconds`、`active_seconds`、`recovery_seconds`、`cooldown_seconds`
- `hit_shape_id`、`effect_ids`
- `hit_query_reservation_class`、非負の `max_concurrent_hit_queries`
- 保存専用の `animation_id`、`vfx_id`、`sfx_id`

common fieldが存在する定義だけをcommon validationへ送り、既存Phase 1 resourceは従来validationへ残す。
common validationは空ID／category、未知category、非有限または負の時間、負のquery最大数、未知予約class、
空effect参照、重複effect参照、legacy `effect.effect_id`とのcross-reference重複を拒否する。
hit shape／effect／presentation IDは実行・解決・消費しない。

### Common Effect scaffold

既存の `Phase1EffectDefinition` とlegacy validationを維持し、次を保存できるようにした。

- `effect_type`、`channel`
- signed `magnitude`
- 非負 `duration`
- `target_rule`、`stack_rule`
- `tags`

common validationは空の必須identity、非有限magnitude、非有限／負duration、空tag要素を拒否する。
effect type、channel、target、stack、tagの語彙や重複規則は追加していない。damage、part damage、Heat、
force、statusその他の作用は解釈・適用しない。

### Reservation-aware hit-query foundation

既存の `configure`、`try_reserve`、`release`、`active_count`、`capacity`を維持し、次を追加した。

- caller-injected capacityを持つ `PlayerCritical`、`BossCritical`、`Environment`、`LowPriority`
- class別の取得／capacity／available／active照会
- 通常予約とは別のcaller-injected emergency capacity
- PlayerCritical／BossCriticalだけが明示APIで使用できるemergency枠
- emergency active数、累積use count、nonzero-use照会
- `clear`／`reset`によるactive token解放と設定capacity復元

通常取得にcross-class borrowingやemergency fallbackはない。LowPriority／EnvironmentはPlayerCritical、
BossCritical、emergency枠を消費できない。emergency使用は成功時に必ず累積telemetryへ現れる。
slot IDとlease tokenを分離し、tokenをobject lifetime内で単調増加させるため、unknown／duplicate／released／
pre-reset stale tokenは新しいleaseを解放できない。capacityは設定値から構築し、literal `50`や51件目拒否分岐はない。

## 変更ファイル

Implementation commit対象:

- `material-frontier-online/prototype/scripts/combat/action_definition.gd`
- `material-frontier-online/prototype/scripts/combat/effect_definition.gd`
- `material-frontier-online/prototype/scripts/combat/hit_query_pool.gd`
- `material-frontier-online/implementation/2026-08-01-phase2-slice2b-action-foundation.md`

`docs/handoffs/gameplay.md`はwork orderどおり別handoff commitで更新する。

## 根拠と未決事項

参照した決定／仕様:

- OD-003: Godot 4.7 stable通常版＋GDScript
- OD-008: 物理攻撃は快斬／重断。ただし本票ではproduction action dataや挙動を実装しない
- `docs/MASTER_SPEC.md` のcommon `ActionDefinition`／`EffectDefinition`境界とperformance contract
- frozen `specification/06-data-model.md` §5.5、§5.6、§9
- frozen `specification/08-performance-budget.md` §1、§7
- `MFO-WO-P2-2B-001` Section 4

新規Decision Requestはない。OQ-002（重断の自己負荷）、OQ-005（retry input）、その他既存OQは
未変更・未解釈のまま維持した。

## 検証

実行exe:

`C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`

### 最終候補

1. Version

   `Godot_v4.7-stable_win64_console.exe --version`

   結果: `4.7.stable.official.5b4e0cb0f`、exit `0`。

2. Import / parse

   `Godot_v4.7-stable_win64_console.exe --headless --editor --path . --quit --log-file C:\tmp\m2b\material-frontier-online\prototype\logs\slice2b-stagea-import-final.log`

   結果: Pass、exit `0`。

3. Ignored isolated self-check

   `Godot_v4.7-stable_win64_console.exe --headless --path . --script res://build/stagea_self_check.gd --log-file C:\tmp\m2b\material-frontier-online\prototype\logs\slice2b-stagea-self-check-final.log`

   結果: `149 / 149 assertions Pass`、exit `0`。legacy validation、empty／negative／invalid／
   duplicate validation、signed magnitude、class isolation、explicit emergency telemetry、transactional
   configuration、unknown／duplicate／stale release、reset、caller-injected 51 slotsを確認した。

   Scratch identity: SHA-256
   `470973604169FF718E3592F7644F2C3BFDDBB681F6EAEE1C49DA46C5FF0CA57F`。
   `prototype/.gitignore:3:build/`でignoreされ、commit対象外。

4. Existing Phase 1

   `Godot_v4.7-stable_win64_console.exe --headless --path . --script res://tests/run_phase1_tests.gd --log-file C:\tmp\m2b\material-frontier-online\prototype\logs\slice2b-stagea-phase1-final.log`

   結果: `36 / 36 Pass`、exit `0`。

5. Existing Slice 2-A

   `Godot_v4.7-stable_win64_console.exe --headless --path . --script res://tests/run_slice2a_tests.gd --log-file C:\tmp\m2b\material-frontier-online\prototype\logs\slice2b-stagea-slice2a-final.log`

   結果: `120 / 120 Pass`、exit `0`。

6. Existing Slice 2-A correction

   `Godot_v4.7-stable_win64_console.exe --headless --path . --script res://tests/run_slice2a_correction_tests.gd --log-file C:\tmp\m2b\material-frontier-online\prototype\logs\slice2b-stagea-slice2a-correction-final.log`

   結果: `39 / 39 Pass`、exit `0`。

7. Main-scene headless smoke

   `Godot_v4.7-stable_win64_console.exe --headless --path . --quit-after 120 --log-file C:\tmp\m2b\material-frontier-online\prototype\logs\slice2b-stagea-main-smoke-final.log`

   結果: Pass、exit `0`。`DefinitionsValidated ok=true`、actor `1`、target `1`、
   query capacity `1`、RHL violation `0`を維持。

8. Repository boundary

   - `git diff --check`: exit `0`
   - baseとのchanged-path監査: Section 3のimplementation対象4件だけ
   - Phase 1 data、全scene、`project.godot`、tests、input／simulation／phase1／presentation runtime、
     `docs/test-reports`の `git diff --quiet`: exit `0`
   - `git ls-files --others --exclude-standard`: outputなし、exit `0`
   - 許可3 code fileへの `rg -n "\\b50\\b"`: matchなし、exit `1`（期待値）
   - QA test source: baseから変更なし

9. Existing UID sidecars

   開始時と最終候補のSHA-256は一致した。

   - `action_definition.gd.uid`: `9F463EC1B34CE637C2F7AA084BF74DE6F0A6AF1F137135D662943239CD81EE78`
   - `effect_definition.gd.uid`: `5F28A002D5D2C33CA5326147B745546A887E770C740EF44EAF3CD40E17CEA8A7`
   - `hit_query_pool.gd.uid`: `1EB4D5A82B66F4DCC68BFB0657DB200384EA333F5F25B2C78D8610A2B5CB1D9B`

### 中間Failの記録

最初のself-checkは `hit_query_pool.gd` のemergency slot取得でVariant推論warningが
warning-as-errorとなり、parse不成立のままexit `1`（途中表示 `21 / 33`）だった。
意味を変えず `slot_id: int`を明示し、以後のimportと最終self-check `149 / 149`はexit `0`。
この中間runをPassには数えない。

## Not run / Deferred

- Formal `30 QA` validation: Not run。別work order待ち
- Performance acceptance／P95／A-B-C／qualified harness: Not run。本票外であり既存HOLDへ影響なし
- Physical gamepad操作感: Not run / Deferred
- Windows release export: Not run。本票はimport／parseと比例的main smokeまで
- production快斬／重断resource、値、hit shape、effect magnitude／damage: Not implemented
- action lifecycle、input binding／request、authority、hit execution、damage、Integrity／Deformation: Not implemented
- data、scene、event、presentation、animation／VFX／SFX消費、integration: Not implemented
- OQ-002の解釈、resource cost、load rank、phase policy、cross-class borrowing: Not implemented

## 受渡し境界

これは **implementation ready for supervisor review** まででありQA Passではない。
Supervisor review後に別の `30` validation orderが必要。次のwork orderなしにStage B、production data、
input／simulation／scene接続へ進まない。
