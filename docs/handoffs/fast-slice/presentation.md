# Fast Slice Presentation Handoff

- Status: Implementation returned / pending 00 scope review
- Work order: `MFO-WO-FS-A-20-001`
- Branch: `codex/fast-slice-fs-a-presentation`
- Worktree: `C:\tmp\mf-fs-a-20`
- Contract: `docs/FAST_SLICE_CONTRACT.md`
- Base: `62f4af4a105b45f458beabecd6595ad5f58ec764`
- Implementation commits:
  - `0404f415b7fcbe9e3c0922433232168c54595ace` — snapshot shell scaffold
  - `12e109ecafa87339496c12371669dab3a66dc205` — pure read-only seam、event feedback、fixed preview camera
- Report: `material-frontier-online/implementation/fast-slice/presentation/fs-a-presentation-shell.md`

## Start record

- Start HEAD: `62f4af4a105b45f458beabecd6595ad5f58ec764`
- Start branch: `codex/fast-slice-fs-a-presentation`
- Start status: not clean; presentation-owned untracked scaffold existed under
  `prototype/scripts/fast_slice/presentation/**` and
  `prototype/scenes/fast_slice/presentation/**`.
  内容を破棄せず監査し、Godot import／fixture self-check後にfirst milestone commitへ固定した。
- Godot identity: `4.7.stable.official.5b4e0cb0f`
- Godot console:
  `C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`

## Delivered

- Integration用pure child:
  `res://scenes/fast_slice/presentation/fs_a_presentation_shell.tscn`
- Preview用scene:
  `res://scenes/fast_slice/presentation/fs_a_presentation_preview.tscn`
- Knight / Iron proxy
- large enemy proxy、part 1〜2件のintact／broken表示
- line／sector telegraph
- Integrity／Deformation／boss HP／part／functional state HUD
- `ActionStarted`／`HitConfirmed`／`PartBroken` feedback
- function stop、wreck、harvest exact 3、result／rematch shell
- 1920×1080 fixed `Camera2D`
- normal／grayscale preview、self-check、deterministic capture

Presentationはsnapshotをdeep-copyして表示し、event payloadを読まない。
HP、damage、hit、part break、harvest、result、rematch resetは決定しない。

## Changed paths

- `material-frontier-online/prototype/scenes/fast_slice/presentation/fs_a_presentation_preview.tscn`
- `material-frontier-online/prototype/scenes/fast_slice/presentation/fs_a_presentation_shell.tscn`
- `material-frontier-online/prototype/scripts/fast_slice/presentation/fs_a_presentation_preview.gd`
- `material-frontier-online/prototype/scripts/fast_slice/presentation/fs_a_presentation_preview.gd.uid`
- `material-frontier-online/prototype/scripts/fast_slice/presentation/fs_a_presentation_shell.gd`
- `material-frontier-online/prototype/scripts/fast_slice/presentation/fs_a_presentation_shell.gd.uid`
- `material-frontier-online/prototype/scripts/fast_slice/presentation/fs_a_preview_stub.gd`
- `material-frontier-online/prototype/scripts/fast_slice/presentation/fs_a_preview_stub.gd.uid`
- `material-frontier-online/implementation/fast-slice/presentation/fs-a-presentation-shell.md`
- `docs/handoffs/fast-slice/presentation.md`

Gameplay-owned、QA-owned、legacy scene／script、`project.godot`、Input Map、autoloadの変更は0。

## Commands and results

| Check | Result |
|---|---|
| Godot `--version` | exit 0 / exact identity |
| headless editor import／parse | exit 0 |
| preview `--fs-a-self-check` | exit 0 / snapshots 4、events 3、harvest each 3、read-only true |
| pure shell scene smoke 5 frames | exit 0 |
| preview scene smoke 5 frames | exit 0 |
| existing Phase 1 deterministic tests | exit 0 / all Pass |
| existing main scene smoke 5 frames | exit 0 |
| GUI capture matrix 9 runs | all exit 0 / 1920×1080 |
| `git diff --check` | Pass before both implementation commits |

Final branch-scope audit、clean status、push resultはhandoff commit後に実行し、exact resultをfinal returnへ含める。

## Captures / readability

Capture root: `C:\tmp\mf-fs-a-20-captures`

- `combat_line-normal.png`
- `combat_line-grayscale.png`
- `combat_sector-normal.png`
- `combat_sector-grayscale.png`
- `event-action-started.png`
- `event-hit-confirmed.png`
- `event-part-broken.png`
- `wreck-normal.png`
- `result-normal.png`

確認結果:

- normal／grayscaleでlineのparallel railsとsectorのfan＋radial ribsを識別できた。
- HUDはblock／hatch＋numeric／solid、partはX＋text、functional stopはdiagonal hatch＋textで識別できた。
- harvest exact 3はnumber＋SALVAGE A/B/C＋COLLECTED/AVAILABLEで識別できた。
- event feedbackはarc／radial burst／shard＋Xで識別できた。
- 全textは1080pで24px以上。
- visual QA中に見つかったtext overlap、label overlap、harvest clipを修正し、該当captureを更新した。

## Not run

- real Gameplay authorityとの接続
- one-loop／two-loop rematch
- real damage、HP0、part break、functional stop、wreck exact once、harvest duplicate rejection
- Presentation disabled時のGameplay result不変
- physical gamepad、integrated play feel
- dedicated color-vision simulation mode
- non-1080p framing、production asset／font／audio

これらは失敗扱いではなく、Gameplay／Integration candidate未存在のため
`Not run / integration QA required`である。

## Known issues / integration needs

1. Integrationはpreview sceneではなくpure shell sceneをinstance化する。
2. authoritative snapshot signalを`apply_snapshot()`へ接続する。
3. shared event objectの`ActionStarted`、`HitConfirmed`、`PartBroken`を
   `consume_domain_event()`へ渡す。payload mappingは不要。
4. snapshotにworld transform、telegraph direction／range、harvest positionがないため、
   現在のproxy／marker位置はfixed placeholder。
5. PartBroken transientはrequired Part 01位置。2個目part採用時のtransform mappingはintegrationで必要。
6. Deformation maximumがないためnumeric＋hatch表示。percentage化しない。
7. result／rematchは表示のみ。入力受付とresetはGameplay authorityが行う。

Handoff commitのexact SHAは、この文書とimplementation reportをcommit後の20 final returnで提示する。

---

# MFO-WO-FS-A-20-002 Return — Spatial Parity Rework

- Status: Implementation returned / pending 00 review and ordered integration
- Work order: `MFO-WO-FS-A-20-002`
- Branch: `codex/fast-slice-fs-a-presentation-rework`
- Worktree: `C:\tmp\mf-fs-a-20-rework`
- Contract foundation: `bf89fcd26cde65659e7addc97952fb9f9fc1dc58`
- Issuance tip: `e09bf9ae8444af1570e32819096c069dca370eb5`
- Frozen source identity: `04893d6d304e0d23a68df0bd1afc2fa8e71cc461` (non-ancestor mapping)
- Tested implementation tip: `73c6242f127b2d3d7d989ddebc17a2ea22d63537`
- Report tip: `96c3534f24f96babd2b5374c861d0d8d9773f95e`
- Report: `material-frontier-online/implementation/fast-slice/presentation/fs-a-spatial-parity-rework.md`
- Shared contract change: not required

## Rework delivered

- `apply_snapshot()`でroot／part／harvest／telegraphのapproved spatial fieldsをrequired／type検証。
- valid snapshotをnested deep-copy＋read-onlyで保持。invalid updateだけを拒否しlast validとsourceを保持。
- player、boss、parts、wreck、exact 3 harvestをauthority arena coordinatesへ直接配置。
- player aim cueとattack feedback orientationをlatest `player_aim`へ追従。
- line／sector telegraphをorigin、normalized direction、range、half-width／radian half-angleから導出。
- `ActionStarted`、`HitConfirmed`、`PartBroken`はtarget-agnostic anchorだけを使用。
- payloadなし／異なるtarget／part IDでfeedback kind／anchor／directionが不変。
- `player_integrity == 0`はHUD値だけを表示し、defeat／stop／retry stateをPresentationに追加していない。
- Previewへ5 spatial statesと20 invalid casesを追加。scene／UID／shared contractは変更していない。

PresentationはHP、damage、hit、part break、defeat、harvest、reward、resultを決定せず、Gameplayへwrite-backしない。

## Exact changed paths

Implementation commit only:

- `material-frontier-online/prototype/scripts/fast_slice/presentation/fs_a_presentation_shell.gd`
- `material-frontier-online/prototype/scripts/fast_slice/presentation/fs_a_presentation_preview.gd`
- `material-frontier-online/prototype/scripts/fast_slice/presentation/fs_a_preview_stub.gd`

Report commit only:

- `material-frontier-online/implementation/fast-slice/presentation/fs-a-spatial-parity-rework.md`

Handoff commit only:

- `docs/handoffs/fast-slice/presentation.md`

Gameplay、integration、QA、scene、`.uid`、asset、`project.godot`、Input Map、autoload、
shared contract／decision／open questionの変更は0。

## Fresh archive validation

Implementation tip `73c6242...`の`prototype` tree `f613143135c1075dbcf3af5774e53ddae541a941`を
fresh `git archive`で検証した。archive SHA-256は
`7d6ec1809f3936be6fd0383eafeb3436f66628475f44dae78ee75335c6b720c6`、bytes `512000`。

| Check | Result |
|---|---|
| Godot identity | exit 0 / `4.7.stable.official.5b4e0cb0f` |
| fresh editor import | exit 0 / pre-import `.godot` absent |
| exact 3 Presentation parse | exit 0 each |
| Presentation self-check | exit 0 / snapshots 5、anchors 40、positions 5、aims 3、payload variants 9、invalid updates 20 |
| pure shell／preview smoke | exit 0 each |
| integration parse／self-check | exit 0 / `checks=236`、one loop、Presentation parity |
| Gameplay parse／self-check | exit 0 / full gameplay loop |
| `fs_a_main.tscn` | exit 0 |
| candidate-independent QA skeleton | exit 0 / Pass |
| project main | exit 0 / DefinitionsValidated |
| Phase 1 | exit 0 / all Pass |
| Slice 2-A | exit 0 / 120 assertions |
| correction | exit 0 / 39 assertions |
| implementation scope／diff | exact 3 source / Forbidden 0 / diff-check exit 0 |

Expected warnings:

- Presentation invalid spatial fixture 20件のreject warning。
- Integration active-empty／unknown-shape fixtureのenabled／disabled計4件のreject warning。
- Windows `core.autocrlf` warning。committed source blobはLF、mixed EOLは0。

Capture runnerの最初のargv組立はstateが空文字になり8 run exit 2、PNG 0件だった。
括弧でargvを固定したbounded rerunは8 / 8 exit 0、error 0。

## Capture identity and readability

各pairはrepeat 1／2でbytesとSHA-256が一致、全capture `(1920, 1080)`。

- line normal: `90d8c77eaf0bbcc1a0d31ef48245804f966622a19389d635e539b0526523b8af`
- line grayscale: `eb9bf0f151ed882e8b170efee8515d480d2909c04836a5e4fde0ef210b1c1eea`
- sector normal: `effbffc0b7fc131c9a38b4c5ef8c8e73270c43c88537521b5b5732c4f5d084d6`
- sector grayscale: `050c4087e034d328c132b5191803b21cbd954c36ace87bc6bb162bd16cc6a785`

normal／grayscaleの両方でline parallel railsとsector fan／radial ribsを識別した。
HUDはblocks／hatch／solid＋numeric、partはbars対X＋textで色以外でも区別できた。

fresh stage、archive、captures、visual-review copiesはreport記録後にexact cleanupし、全target不存在を確認した。

## Known issues

- 1080p placeholderで`AUTHORITY POSITION + AIM`末尾がclipする。
- sector stateでtelegraph progress／labelsとplayer proxyが一部重なる。
- 上記でもauthority position、aim arrow、telegraph shape、HUD valueは確認可能。production layout polishは本票外。
- QA skeletonはcandidate-independentで、spatial parityそのものは新Presentation self-check／capture evidenceが担当。
- Deformationは契約にmaximumがないためnumeric＋hatch。
- result／rematchは表示だけで、入力／reset／rewardを決定しない。

## Not run / Deferred

- Gameplay rework統合後のmanual KBM move／aim／evade／attack reach
- integrated readability／user feel、二周目rematch manual play
- player defeat／enemy stop manual path
- physical gamepad
- performance／profiling／stress
- export／portable build
- production art／audio／non-1080p final framing

自動validationはこれらをPassへ代替しない。

## Integration handoff

00は10 reworkを先にreview／cherry-pickし、その後implementation tip `73c6242...`を取り込む。
Previewではなく既存pure Presentation shell sceneをexact 1 childとして維持する。

既存snapshot／event forward seamを変更せず、payload semanticsを追加しない。
10＋20統合後にQA manual KBM／readability／user feelを再実行する。

Final handoff commit SHA、push identity、final prototype tree一致は20 final Returnで提示する。
