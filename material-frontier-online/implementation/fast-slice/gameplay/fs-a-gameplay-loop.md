# FS-A Gameplay Loop Implementation Report

- Status: Returned for `00` review
- Work order: `MFO-WO-FS-A-10-001`
- Contract: `docs/FAST_SLICE_CONTRACT.md`
- Branch: `codex/fast-slice-fs-a-gameplay`
- Base: `62f4af4a105b45f458beabecd6595ad5f58ec764`
- Implementation tip: `611f34b4e1df342ff24b8e420f26d36700c39c4a`
- Scope boundary: presentation非接続のGameplay child scene。integrationへは自動移行しない。

## Changed paths

- `material-frontier-online/prototype/data/fast_slice/fs_a_provisional_tuning.tres`
- `material-frontier-online/prototype/scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn`
- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_arena.gd`
- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_loop.gd`
- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd`
- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_input_adapter.gd`
- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_player_action.gd`
- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_tuning.gd`
- 上記6 scriptのGodot生成 `.uid`
- `material-frontier-online/implementation/fast-slice/gameplay/fs-a-gameplay-loop.md`
- `docs/handoffs/fast-slice/gameplay.md`

legacy gameplay、`project.godot`、Input Map設定、autoload、presentation、共有contractは変更していない。

## Implementation

- 既存 `Phase1InputAdapter` と `Phase1PlayerActor` をread-only依存としてcomposeし、move／aim／evadeを維持した。
- player buildはcontractどおり `Knight / Iron` の1構成だけをread-only snapshotへ公開した。
- light／heavyを別actionとして実装し、`idle -> windup -> active -> recovery` の状態遷移、別timing／damage／reachを持たせた。
- active開始時にhit descriptorをimmutable latchし、1 actionにつき命中解決をexact onceにした。大きなdeltaがaction全体を跨いでもheavy情報を保持する。
- large enemy 1体とbreakable part 1個を固定IDで実装した。part hitはprovisional比率でbody damageへ接続し、part breakをexact onceにした。
- line／sectorの2 telegraphを交互に開始し、予告時点で方向を固定する。両攻撃とも予告後の移動で回避でき、hit解決は1 attackにつきexact once。
- enemy hitでplayer Integrityを減少、Deformationを増加させる。
- boss HPのpositive-to-zero遷移だけでfunctional stop、pending attack停止、wreck生成をexact onceに行う。
- wreck後にstable IDのharvest pointをexact 3生成し、距離判定、重複回収拒否、3点完了待ちを実装した。
- rewardは `iron_scrap` のnon-persistent provisional dataとして集計し、result／rematch可能状態を公開する。
- rematchでplayer、boss、part、enemy AI、wreck、harvest、reward、resultを完全resetし、二周目を再開できる。
- contract必須fieldを含む深層read-only snapshot seamを提供した。`player_build`、spatial、action、rewardはadditive field。
- child sceneが平行移動された親Node下に置かれても、boss／part／player／wreck／harvest authority nodeはsnapshotと同じworld座標に保つ。

## `fs_provisional` tuning and history

すべての仮値は `fs_a_provisional_tuning.tres` に集中し、`authority_label = fs_provisional` をvalidationしている。

- player: Integrity `100`
- light: timing `0.12 / 0.10 / 0.18 s`、body／part damage `18 / 20`、reach `180`
- heavy: timing `0.32 / 0.14 / 0.42 s`、body／part damage `34 / 44`、reach `210`
- boss／part HP: `180 / 60`、part-to-body ratio `0.35`
- line warning `0.75 s`、damage `18`、Deformation `12`
- sector warning `1.00 s`、damage `26`、Deformation `20`
- harvest range `105`、result delay `0.20 s`、reward `iron_scrap x1` per point

2026-08-03の初期縦切り値として、一周／二周目resetをdeterministicに検証できる範囲だけ設定した。手動の操作感・表示可読性による調整は未実施であり、production値へ昇格していない。

## Run

Working directory:

```powershell
Set-Location 'C:\tmp\mf-fs-a-10\material-frontier-online\prototype'
```

Gameplay self-check:

```powershell
& 'C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe' `
  --headless --path . `
  --script res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd
```

Gameplay child scene smoke:

```powershell
& 'C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe' `
  --headless --path . `
  --scene res://scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn `
  --quit-after 120
```

手動integration時の既存KBM mappingはmove `WASD`、aim `mouse`、light `left mouse`、heavy `right mouse`、evade `Space`、interact／rematch `E`。本sceneはpresentation非接続でplayerも非表示のため、単独起動はvisual playtest用ではなくauthority／headless検証用である。

## Verification results

- Godot identity: `4.7.stable.official.5b4e0cb0f`, exit `0`
- exact implementation tipの一時copyによるfirst-scan fresh import／parse: exit `0`（一時copyは検証後に削除）
- `--check-only` FS-A self-check parse: exit `0`
- FS-A self-check: `200` PASS lines、final `PASS: full gameplay loop`、exit `0`
- FS-A gameplay child scene smoke: exit `0`
- existing main scene smoke: exit `0`、RHL violation `0`
- `res://tests/run_phase1_tests.gd`: all Phase 1 tests Pass、exit `0`
- `res://tests/run_slice2a_tests.gd`: `120 assertions` Pass、exit `0`
- `res://tests/run_slice2a_correction_tests.gd`: `39 assertions` Pass、exit `0`
- `git diff --check`: exit `0`
- baseからのimplementation変更は14 pathで、すべてwork order owned path内。report／handoffも指定owned path内。

## Not run / known issues

- userによるKBM操作感、予告の視認性、回収導線の手動playtest: Not run
- 物理gamepadの操作感／button確認: Not run
- presentation child scene、UI、VFX、SEとのintegration: Not run（別owner／別work order）
- Windows export／配布物検証: Not run
- standalone gameplay sceneにはpresentationがなく、resultはsnapshot stateとしてのみ確認できる。
- balance値はすべて `fs_provisional`。正式仕様・production balanceではない。
- rewardはsession内dataのみで、inventory／persistenceへの保存はscope外。

## Shared contract

変更不要。`FAST_SLICE_CONTRACT` の必須snapshot fieldとphase遷移をそのまま実装し、追加fieldはadditiveに限定した。共有contract文書は変更していない。

## Implementation commits

- `57cd671eaff9a1b5e964d198e5af4df0548f6191` — player light／heavy actions
- `74a265322c40ad1cd510ab3d076c57ed859d729f` — boss combat authority
- `603bbe53c7bfef68d5475053d4ce875e172bb555` — post-combat loop
- `46e1f664f9dd53ca0e40aaf3723f705d670e4eff` — gameplay child scene
- `611f34b4e1df342ff24b8e420f26d36700c39c4a` — final invariant review fixes
