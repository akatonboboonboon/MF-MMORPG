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
