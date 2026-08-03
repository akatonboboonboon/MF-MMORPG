# FS-A Presentation Shell Implementation Report

- Work order: `MFO-WO-FS-A-20-001`
- Contract: `docs/FAST_SLICE_CONTRACT.md`
- Branch: `codex/fast-slice-fs-a-presentation`
- Base: `62f4af4a105b45f458beabecd6595ad5f58ec764`
- Snapshot-shell commit: `0404f415b7fcbe9e3c0922433232168c54595ace`
- Event-seam implementation commit: `12e109ecafa87339496c12371669dab3a66dc205`
- Godot: `4.7.stable.official.5b4e0cb0f`
- Result: Implementation complete on Presentation branch / integration not performed

## 1. Implemented result

Primitive描画だけで構成したFS-A Presentation shellを追加した。production art、音響、collision、physicsは追加していない。

- Knight / Iron player proxy
- large enemy proxyと1〜2件のpart表示
- geometryが異なるline／sector telegraph
- read-onlyのIntegrity、Deformation、boss HP、part、phase、functional state HUD
- `ActionStarted`、`HitConfirmed`、`PartBroken`の最小feedback
- functional stop、wreck exact-one表示
- wreck／result phaseだけに表示するharvest marker exact 3
- result／rematch overlay shell
- 1920×1080、fixed direction、zoom 1.0のpreview `Camera2D`
- normal／grayscale切替とdeterministic capture入口

1080pの表示文字は24px以上とし、line／sector、Integrity／Deformation／boss HP、intact／broken、
functional／function stop、available／collectedを色だけで区別しない。

## 2. Authority boundary

Integration用sceneは
`res://scenes/fast_slice/presentation/fs_a_presentation_shell.tscn` である。
fixture、preview入力、command-line処理、cameraを含まないpure Presentation childとして分離した。

Public seam:

- `apply_snapshot(snapshot: Dictionary) -> bool`
  - 契約fieldの存在と表示可能なshapeを検査する。
  - nested値をdeep-copyし、呼出元Dictionaryを保持・変更しない。
  - HP、Deformation、part、functional、wreck、harvest、resultを計算・遷移させない。
- `consume_domain_event(event: Variant) -> bool`
  - DictionaryまたはObjectの `event_name` だけを読む。
  - reserved名 `ActionStarted`、`HitConfirmed`、`PartBroken`だけを最小feedbackへ対応させる。
  - open payloadを読まず、hit、damage、part、resultを決定しない。

`player_deformation`には契約上のmaximumがないため、percentage barへ変換せず、数値＋固定hatchで表示する。
event feedbackは0.65秒のPresentation-only transientであり、authority snapshotを変更しない。

## 3. Preview fixture

`fs_a_presentation_preview.tscn` は次をcomposeする独立preview専用sceneである。

- pure Presentation shell
- presentation-owned snapshot／event fixture
- fixed `Camera2D`
- preview controller

Snapshot fixture:

| ID | 主な確認 |
|---|---|
| `combat_line` | line telegraph、player HUD、boss HUD、intact part |
| `combat_sector` | sector telegraph、broken part |
| `wreck` | function stop、wreck、harvest exact 3、collected／available |
| `result` | harvest 3/3、result visible、rematch available |

Event fixture:

| Reserved event | 表示だけのresponse |
|---|---|
| `ActionStarted` | slash arc＋text |
| `HitConfirmed` | radial burst＋text |
| `PartBroken` | shard＋X＋text |

Fixture payloadはpreview labelでありshared payload contractではない。shellはpayloadを参照しない。

Preview controls:

- `1`／`2`／`3`／`4`: snapshot切替
- `Left`／`Right`／`Space`: snapshot循環
- `A`: `ActionStarted`
- `H`: `HitConfirmed`
- `B`: `PartBroken`
- `G`: normal／grayscale

## 4. Verification

Godot executable:

`C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`

| Command / check | Result |
|---|---|
| `--version` | exit 0 / exact `4.7.stable.official.5b4e0cb0f` |
| `--headless --editor --path . --quit` | exit 0 / import and parse Pass |
| preview scene `--fs-a-self-check` | exit 0 / `snapshots=4 events=3 harvest_each=3 read_only=true` |
| pure shell scene `--quit-after 5` | exit 0 |
| preview scene `--quit-after 5` | exit 0 |
| `res://tests/run_phase1_tests.gd` | exit 0 / all Phase 1 tests Pass |
| existing main scene `--quit-after 5` | exit 0 |
| 9 GUI-rendered captures | all exit 0 / 1920×1080 |

Self-checkは各snapshot schema、deep-copy isolation、reserved 3 event、Object event seam、
unsupported event rejection、およびevent前後のauthority snapshot不変を確認する。

## 5. Captures and readability

Capture root: `C:\tmp\mf-fs-a-20-captures`

| Capture | SHA-256 |
|---|---|
| `combat_line-normal.png` | `C3D2DB50C272A2261D68E923CF352CC314FA12B981B269DDA430D8C3ABB80843` |
| `combat_line-grayscale.png` | `196C0883D6E2E84A0BF18F076F90020C44E9CF45D635A5673C540500D281151D` |
| `combat_sector-normal.png` | `6DAA1EB819CC9611D41D953CDE44D9A572848609CEA3409BB0A5347896C397DB` |
| `combat_sector-grayscale.png` | `D304201659D9E354B8577B6D969BDB6FF767CEDB9225DDD7BCF6F461D9CC352E` |
| `event-action-started.png` | `B3D51412ABE1274EC12D2FBDFFD8D76650FEB0496D65724A13C047C6967FEC3C` |
| `event-hit-confirmed.png` | `A872B5E65FE8DD1F04E8B5A76C914D769C2C32ECCC3D9849E169E739BE0CDB03` |
| `event-part-broken.png` | `66CFFFB93F8494EB42A658E29F91D2DA4C4DCADD5C4F6B32E5C1CC94B37008B2` |
| `wreck-normal.png` | `120C4570E5A94C77BA53B08731B2BEBE5BE37B801649313E5D5FCA02252EF0B3` |
| `result-normal.png` | `D702BFD69E69C086798D4AF1A4FF8B1F04EC30F72C596B3D1AE73BBD2261D958` |

Visual review:

- normal／grayscaleの両方でlineはparallel rails、sectorはfan＋radial ribsとして判別できた。
- Integrityはblock、Deformationはhatch＋numeric、boss HPはsolidとして判別できた。
- brokenはX、function stopはdiagonal hatch、harvest collectedはcheck、availableはdotで判別できた。
- attack／hit／part breakはそれぞれarc、radial burst、shard＋Xで判別できた。
- captureで見つかったHUD text overlap、telegraph label overlap、harvest label clipは修正後に再captureした。

## 6. Known issues / integration work

- Gameplay branchのconcrete signal name／payloadは未接続。Integrationはauthoritative snapshotを
  `apply_snapshot()`へ渡し、reserved event objectを`consume_domain_event()`へ渡す。
- snapshotにはworld position、aim／direction、telegraph range、harvest positionがないため、proxyとmarkerは固定preview位置である。
- `PartBroken` transientはpayloadに依存しないためrequired Part 01位置へ表示する。2個目のpartを採用する場合は、
  approved transform mappingをintegration adapterで与える必要がある。
- Deformation maximum／unitは未定義なのでnumeric displayのみ。正式percentage表示は追加契約が必要。
- result overlayのrematchは表示だけで、入力受付やresetを行わない。
- fixed 1920×1080以外のscale、production palette／font／asset、audio、animation bindingは未実装。

Not run / integration QA required:

- real Gameplay一周、attack回避、damage／HP／part break／harvest／result／rematch reset
- exact-once boss defeat／wreck／harvest semantics
- Presentation disabled時のGameplay result不変
- physical gamepad、play feel、integrated camera framing
- dedicated color-vision simulation mode

## 7. Integration instructions

1. `fs_a_presentation_preview.tscn`ではなく`fs_a_presentation_shell.tscn`をinstance化する。
2. Gameplayの初期snapshotと以後のread-only snapshotを`apply_snapshot()`へ接続する。
3. shared DomainEvent streamの`ActionStarted`、`HitConfirmed`、`PartBroken`を
   payload変換なしで`consume_domain_event()`へ渡す。
4. Gameplay stateをPresentationから参照・変更するcallbackを追加しない。
5. world transformが確定するまではfixed proxy位置を維持し、Integration work order外でcontractを拡張しない。
