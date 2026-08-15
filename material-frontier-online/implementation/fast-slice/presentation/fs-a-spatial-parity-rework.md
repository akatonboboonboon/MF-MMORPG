# FS-A Spatial Parity Presentation Rework Report

- Work order: `MFO-WO-FS-A-20-002`
- Contract: `docs/FAST_SLICE_CONTRACT.md`
- Contract foundation: `bf89fcd26cde65659e7addc97952fb9f9fc1dc58`
- Branch: `codex/fast-slice-fs-a-presentation-rework`
- Issuance tip: `e09bf9ae8444af1570e32819096c069dca370eb5`
- Frozen Presentation source identity: `04893d6d304e0d23a68df0bd1afc2fa8e71cc461` (non-ancestor source identity)
- Tested implementation tip: `73c6242f127b2d3d7d989ddebc17a2ea22d63537`
- Godot: `4.7.stable.official.5b4e0cb0f`
- Result: `Pass / implementation-only tip validated from fresh archive`
- Shared contract change: not required

## 1. Preflight and source identity

開始時に次を確認した。

- local HEAD、tracking ref、live originはすべてissuance tip `e09bf9a...`。
- contract foundationはissuance tipのancestor。`git merge-base --is-ancestor`はexit `0`。
- rework worktreeとfrozen旧Presentation worktreeはclean。
- frozen source `04893d6...`とissuance tipのexact 3 source blobは一致。

| Source | Frozen / issuance blob | Implementation blob |
|---|---|---|
| `fs_a_presentation_shell.gd` | `1ea97ee3863e6b8585bfb418b7d38cc45322245d` | `6a52239e8134e6ef96068d0f93a62f3cffe74fde` |
| `fs_a_presentation_preview.gd` | `3137e5700e3444b30a119eb47c9b0b16df3f1102` | `949b4b6f214482eaf58d085c60dfcd13034b0919` |
| `fs_a_preview_stub.gd` | `62600ce47eee4dfef992a35b6b20c9ee1507f1fe` | `9cedbd158b9ad01557683b0f0f5713e8b51cec61` |

Source identity mappingはcommit ancestryではない。candidate ancestryは
`e09bf9a... -> 73c6242...`で、count `1`、merge commit `0`である。

## 2. Implemented result

`apply_snapshot()`は従来fieldに加えて次をrequiredとしてfail closedに検証する。

- root `player_position`、`player_aim`、`boss_position`: `Vector2`
- each part `position`: `Vector2`
- each harvest point `position`: `Vector2`
- telegraph `origin`、`direction`: `Vector2`
- telegraph `range`、`half_width`、`half_angle`: numeric

valid snapshotはnested値までdeep-copyしてread-onlyに保持する。invalid updateはそのupdateだけを拒否し、
last valid snapshotとsource dictionaryを変更しない。

描画はauthority arena座標を直接使用する。

- player proxyは`player_position`、sword／arrow aim cueはnormalized `player_aim`
- bossとwreckは`boss_position`
- each partとexact 3 harvest markerは各recordの`position`
- line telegraphは`origin + normalized(direction) * range`と`half_width`
- sector telegraphは`origin`、normalized `direction`、`range`、radian `half_angle`
- viewport全体の既存uniform scale／letterboxだけを維持

固定proxy target、固定telegraph radius／angle、固定part／harvest anchorはauthority表現から除去した。
HUD、tag、proxy内部shapeのlocal cosmetic offsetはGameplay座標や結果を変更しない。

## 3. Event boundary

shellはeventの`event_name`だけを読む。payload、event順序、snapshot差分は解釈しない。

| Reserved event | Target-agnostic anchor |
|---|---|
| `ActionStarted` | event受領時のlatest `player_position`、orientationは`player_aim` |
| `HitConfirmed` | `player_position + normalized(player_aim) * 120.0` |
| `PartBroken` | `boss_position` |

`120.0`は`COSMETIC_FEEDBACK_OFFSET`であり、attack reach、hit位置、damage範囲ではない。
payloadなし、異なる`target_id`、異なる`part_id`で同じevent名のkind／anchor／directionが不変であることをself-checkした。
specific target／part identityは主張しない。

`player_integrity == 0`は既存HUD値としてだけ表示する。Presentation側のdefeat latch、state停止、phase変更、
retry受付、defeat overlayは追加していない。

## 4. Preview fixture and self-check

Preview fixtureは`combat_line`、`combat_sector`、`wreck`、`result`、`reset`の5 stateを持つ。
全required spatial fieldを含み、5 player positions、3 normalized aim directions、異なるboss／part／harvest positions、
line／sector geometry、inactive placeholder、wreck／result／resetを確認する。

Self-check final anchor:

`self_check=PASS snapshots=5 spatial_schema=true anchors=40 geometry=line+sector tracking_positions=5 tracking_aims=3 events=3 payload_variants=9 invalid_updates=20 deep_read_only=true`

確認内容:

- source／shell copyのnested deep-copy isolationとshell internal deep-read-only
- root／part／harvest／telegraph spatial fieldのrequired／type rejection
- invalid update 20件のreject、last-valid保持、source不変
- player、aim、boss、wreck、part、harvest anchor一致
- line endpoint／corner／half-width、sector direction／range／radian half-angle一致
- 複数position／aimでActionStarted／HitConfirmed anchorとorientationが追従
- 3 reserved eventsのpayload independence、Object event seam、unsupported event rejection
- event処理前後のauthority snapshot不変

## 5. Fresh archive identity

Implementation tipの`material-frontier-online/prototype`だけを`git archive --format=tar`し、
repository外のunique stageへ展開した。

- Temporary stage: `C:\tmp\mf-fs-a-20-002-validation-73c6242f127b-591db3284017`
- Archive: `C:\tmp\mf-fs-a-20-002-validation-73c6242f127b-591db3284017.tar`
- Archive bytes: `512000`
- Archive SHA-256: `7d6ec1809f3936be6fd0383eafeb3436f66628475f44dae78ee75335c6b720c6`
- Prototype tree: `f613143135c1075dbcf3af5774e53ddae541a941`
- Before import: `.godot` absent、`project.godot` present、`.git` absent
- Fresh stage exact 3 source `git hash-object`はimplementation blob 3件と一致

## 6. Validation commands and results

すべて上記fresh stageのproject pathで実行した。

| Command / check | Exit | Result anchor |
|---|---:|---|
| Godot `--version` | 0 | exact `4.7.stable.official.5b4e0cb0f` |
| `--headless --editor --path <fresh> --quit` | 0 | fresh import／class registration Pass |
| exact 3 Presentation scripts `--check-only --script` | 0 each | parse error 0 |
| preview `--fs-a-self-check` | 0 | 5 snapshots／40 anchors／20 invalid updates／9 payload variants |
| pure shell scene `--quit-after 5` | 0 | smoke Pass |
| preview scene `--quit-after 5` | 0 | smoke Pass |
| integration self-check parse | 0 | error 0 |
| integration self-check run | 0 | `checks=236 shapes=3 events=3 one_loop=true presentation_parity=true` |
| Gameplay self-check parse | 0 | error 0 |
| Gameplay self-check run | 0 | `PASS: full gameplay loop` |
| `fs_a_main.tscn --quit-after 120` | 0 | error 0 |
| candidate-independent QA skeleton fixture | 0 | `PASS: contract seam skeleton fixture` |
| project main `--quit-after 120` | 0 | `DefinitionsValidated ok=true` |
| Phase 1 tests | 0 | `PASS: all Phase 1 tests` |
| Slice 2-A tests | 0 | `PASS: 120 assertions` |
| Slice 2-A correction tests | 0 | `PASS: 39 assertions` |
| `git diff --check e09bf9a..73c6242` | 0 | clean |
| issuance..implementation path audit | 0 | exact 3 source、Forbidden diff 0 |

Integration self-checkのwarning 4件はintentional active-empty／unknown-shape fail-closed fixtureであり、
enabled／disabled各2件。errorは0である。Presentation self-checkのwarning 20件もinvalid spatial updateの
expected rejectionである。

## 7. Deterministic captures and visual review

Corrected capture matrixはline／sector x normal／grayscaleを各2回実行し、全run exit `0`、error `0`、
size `(1920, 1080)`。repeat pairのbytesとSHA-256は一致した。

| State / mode | Bytes | SHA-256 (repeat 1 = repeat 2) |
|---|---:|---|
| `combat_line` / normal | 130880 | `90d8c77eaf0bbcc1a0d31ef48245804f966622a19389d635e539b0526523b8af` |
| `combat_line` / grayscale | 123421 | `eb9bf0f151ed882e8b170efee8515d480d2909c04836a5e4fde0ef210b1c1eea` |
| `combat_sector` / normal | 170632 | `effbffc0b7fc131c9a38b4c5ef8c8e73270c43c88537521b5b5732c4f5d084d6` |
| `combat_sector` / grayscale | 158970 | `050c4087e034d328c132b5191803b21cbd954c36ace87bc6bb162bd16cc6a785` |

Visual inspection:

- lineはparallel rails／cross ticks／`LINE ATTACK` textで識別できる。
- sectorはfan outline／radial ribs／concentric arcs／`SECTOR ATTACK` textで識別できる。
- normal／grayscaleともlineとsectorを色以外で区別できる。
- Integrityはblocks＋numeric、Deformationはhatch＋numeric、boss HPはsolid＋numeric。
- intact／brokenはbars対X＋textで区別でき、player positionとaim arrow、boss／part anchorを確認できる。

最初のcapture orchestration attemptはPowerShell array内の連結式に括弧がなく、stateが空文字で渡されて
8 runすべてexit `2`、PNG `0`件だった。candidate／fixture failureではない。argvを括弧で固定したbounded rerunが
上記8件すべてPassした。

Capture／archive cleanup status: `Complete`。検証済みexact pathだけを削除し、
stage `False`、archive `False`、visual-review copy `False`を`Test-Path`で確認した。

Removed exact temporary targets:

- `C:\tmp\mf-fs-a-20-002-validation-73c6242f127b-591db3284017`（fresh stageと`_captures`）
- `C:\tmp\mf-fs-a-20-002-validation-73c6242f127b-591db3284017.tar`
- `C:\Users\osato\.codex\visualizations\2026\08\03\019fc6e9-afca-7ad0-9a0c-f17054b9b419\fs-a-20-002-visual-review`

## 8. Known issues and limits

- 1920x1080 placeholderではplayer下の`AUTHORITY POSITION + AIM`末尾がclipし、sector stateでは
  telegraph progress／labelsとplayer proxyが一部重なる。authority anchors、aim arrow、telegraph shape、HUD valueは視認可能。
  production layout polishは本票scope外。
- QA skeleton fixtureはcandidate-independentの旧shape seam確認であり、spatial parityの証拠はPresentation self-checkと
  deterministic capturesである。
- Deformation maximum／unitは契約にないため、numeric＋hatchのまま。
- result／rematch shellは表示のみ。入力、reset、rewardを決定しない。
- source3件はGit blob／indexともLF。Windows `core.autocrlf`はworking-copy変換warningを出すが、mixed EOLは0。

## 9. Not run / Deferred

- 10 rework統合後のmanual KBM move／aim／evade／attack reach
- integrated readability／user feelと二周目rematch manual play
- player defeat／enemy stopのmanual path（PresentationはHUD表示だけ）
- physical gamepad
- performance／profiling／long-run stress
- export／portable Windows build
- production art、audio、non-1080p final framing

自動testsはこれらのmanual／Deferred項目をPassへ代替しない。

## 10. Integration work

00はGameplay reworkを先にreview／cherry-pickし、その後このimplementation commitをintegrationへ取り込む。
Presentation scene／UIDの再編集は不要。

- authority snapshotを既存`apply_snapshot()`へforwardする。
- reserved 3 eventを既存`consume_domain_event()`へforwardする。
- payloadを変換／解釈せず、specific target／part anchorを追加しない。
- PresentationからGameplayへwrite-backしない。
- 10＋20統合後にQA manual KBM／readability／user feelを再実行する。

共有契約の追加変更は不要である。
