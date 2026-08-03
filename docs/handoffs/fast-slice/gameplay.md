# Fast Slice Gameplay Handoff

- Status: Returned for `00` review
- Branch: `codex/fast-slice-fs-a-gameplay`
- Worktree: `C:\tmp\mf-fs-a-10`
- Contract: `docs/FAST_SLICE_CONTRACT.md`

10は開始時にexact HEAD、clean status、Godot identityを記録する。進捗、provisional tuning、commands、results、Not run、handoff tipをこのファイルへ追記する。

## MFO-WO-FS-A-10-001 start record

- Started: 2026-08-03
- Starting HEAD: `62f4af4a105b45f458beabecd6595ad5f58ec764`
- Starting status: clean
- Godot: `4.7.stable.official.5b4e0cb0f`, exit `0`
- Planned owned scene: `material-frontier-online/prototype/scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn`
- Scene owner and purpose: `10`; authoritative presentation-independent FS-A gameplay child scene.
- Read-only dependencies: `Phase1InputAdapter`, `Phase1PlayerActor`, and the existing player scene. Legacy input, simulation, combat, phase1, and `project.godot` remain unchanged.
- Planned owned implementation: FS-A input adapter, provisional tuning resource/data, authoritative loop state, deterministic additive self-check, report, and this handoff.

## MFO-WO-FS-A-10-001 return

- Returned: 2026-08-03
- Base: `62f4af4a105b45f458beabecd6595ad5f58ec764`
- Implementation tip: `611f34b4e1df342ff24b8e420f26d36700c39c4a`
- Report: `material-frontier-online/implementation/fast-slice/gameplay/fs-a-gameplay-loop.md`
- Integration status: not started; return to `00` for review only.

### Milestone commits

- `57cd671eaff9a1b5e964d198e5af4df0548f6191` — light／heavy action and action state
- `74a265322c40ad1cd510ab3d076c57ed859d729f` — large enemy、2 telegraph、Integrity／Deformation、part／HP0 stop
- `603bbe53c7bfef68d5475053d4ce875e172bb555` — wreck、harvest exact 3、reward／result／rematch
- `46e1f664f9dd53ca0e40aaf3723f705d670e4eff` — authoritative gameplay child scene
- `611f34b4e1df342ff24b8e420f26d36700c39c4a` — Knight / Iron identity、coarse-delta hit latch、両予告回避、translated-parent座標整合

### Owned changes

- `material-frontier-online/prototype/data/fast_slice/fs_a_provisional_tuning.tres`
- `material-frontier-online/prototype/scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn`
- `material-frontier-online/prototype/scripts/fast_slice/gameplay/` のFS-A script 6件と対応 `.uid`
- `material-frontier-online/implementation/fast-slice/gameplay/fs-a-gameplay-loop.md`
- `docs/handoffs/fast-slice/gameplay.md`

legacy code／data／scene、`project.godot`、Input Map設定、autoload、presentation、tests、共有contractは変更していない。

### Implementation summary

- 既存move／aim／evadeをcomposeし、Knight / Iron単一build、light／heavyの `idle -> windup -> active -> recovery` を実装。
- immutable hit descriptorにより、coarse deltaを含め1 actionの命中確定をexact once化。
- large enemy 1体、breakable part 1個、line／sector telegraph、Integrity／Deformationを実装。
- boss HP positive-to-zeroでfunctional stopとwreckをexact once生成。
- stable IDのharvest point exact 3、重複拒否、non-persistent provisional reward、result／完全rematch resetを実装。
- contract必須fieldを含むdeep read-only snapshot seamを実装。追加fieldはadditiveのみ。
- 親Nodeが平行移動しても全authority nodeとsnapshotのworld座標が一致する。

### Provisional tuning history

- Authority label: `fs_provisional`
- Initial vertical-slice pass: player Integrity `100`、boss／part HP `180 / 60`。
- light damage body／part `18 / 20`、heavy `34 / 44`。
- line warning `0.75 s`、sector warning `1.00 s`。
- harvest range `105`、reward `iron_scrap x1` per point。
- deterministicな一周／二周目reset検証用の初期値。手動feel／readability調整は未実施で、production値へ昇格していない。

### Commands and results

Godot executable:

`C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`

- `--version`: `4.7.stable.official.5b4e0cb0f`, exit `0`
- exact `611f34b...` temporary archive + `--headless --editor --path . --quit`: first-scan fresh import／parse Pass、exit `0`; temporary archive cleaned
- `--headless --path . --check-only --script res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd`: exit `0`
- `--headless --path . --script res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd`: `200` PASS lines、final full-loop Pass、exit `0`
- `--headless --path . --scene res://scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn --quit-after 120`: exit `0`
- `--headless --path . --quit-after 120`: existing main scene smoke Pass、RHL violation `0`、exit `0`
- `--headless --path . --script res://tests/run_phase1_tests.gd`: all Pass、exit `0`
- `--headless --path . --script res://tests/run_slice2a_tests.gd`: `120 assertions` Pass、exit `0`
- `--headless --path . --script res://tests/run_slice2a_correction_tests.gd`: `39 assertions` Pass、exit `0`
- `git diff --check`: exit `0`
- base-to-implementation changed paths: `14 / 14` work order owned paths

### Not run / known issues

- user／手動KBMの操作感、telegraph可読性、回収導線: Not run
- 物理gamepad: Not run
- presentation／UI／VFX／SE integration: Not run;別owner／別work order
- Windows export／配布物: Not run
- standalone sceneはpresentationなしでplayerも非表示。resultはsnapshot stateとしてのみ確認する。
- balanceはすべて `fs_provisional`。rewardはsession内dataのみでpersistenceなし。

### Shared contract

変更不要。必須field／phaseを変更せず実装でき、共有contract文書も変更していない。
