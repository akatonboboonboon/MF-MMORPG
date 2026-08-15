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

## MFO-WO-FS-A-10-002 return

- Returned: 2026-08-15
- Work order: `MFO-WO-FS-A-10-002`
- Branch: `codex/fast-slice-fs-a-gameplay-rework`
- Worktree: `C:\tmp\mf-fs-a-10-rework`
- Contract foundation: `bf89fcd26cde65659e7addc97952fb9f9fc1dc58`
- Issuance tip: `e09bf9ae8444af1570e32819096c069dca370eb5`
- Frozen Gameplay source identity: `17773c5f186dfbbd1a1e52a304df123b76d9ad35`（non-ancestor; issuanceのexact 3 source blobは一致）
- Integration setup record: `7f780d13b543d147651f12df9eb702cb09122263`（candidate ancestry外のadministrative sibling record）
- Tested implementation tip: `4eb47f83a093c9fe537577889dacaa888a0855b4`
- Report tip: `d0ef924a6854edee9b8304e34b13d5811efd5fd0`
- Report: `material-frontier-online/implementation/fast-slice/gameplay/fs-a-gameplay-defeat-traversal-rework.md`
- Integration status: not merged; `00`へReturnし、10→20順のreview／cherry-pick待ち
- Handoff-only commit／final tip: このappend-only記録のcommit SHAをpush後のdirect Returnで通知する。

### Commit order

1. `4eb47f83a093c9fe537577889dacaa888a0855b4` — implementation-only、exact 3 source
2. `d0ef924a6854edee9b8304e34b13d5811efd5fd0` — report-only、exact report 1 path
3. handoff-only — this append、exact handoff 1 path

reset、rebase、amend、mergeは実施していない。

### Owned changes

- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_loop.gd`
- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_arena.gd`
- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd`
- `material-frontier-online/implementation/fast-slice/gameplay/fs-a-gameplay-defeat-traversal-rework.md`
- `docs/handoffs/fast-slice/gameplay.md`

上記exact 5 pathだけ。scene、UID、data、tuning、player action、input adapter、Presentation、Integration、QA、legacy、`project.godot`、Input Map、autoload、shared contractは変更していない。

### Implementation summary

- player Integrity positive-to-zeroをboss defeatと別のprivate stateでexact once latch。
- latch時にpending player action／queryをcancelし、enemy AI／telegraph／attack ID／pending hitをstop。
- fatal既存eventはattack ID／shapeを保持し、latch／player action cancel／enemy stop後にexact once emit。再入authority action／commandはfail closed。
- arenaはfatal event return後／step return前にcurrent position／aimでexisting actorをresetし、teleportせずactive evade／velocityを停止。
- defeat後のmove／evade／light／heavy／`E`／large deltaはmotion前no-op。Integrity／Deformation、boss／part、wreck／harvest／result、counter、event、positionを保持。
- invalid configureは`false`を返し、latchを解除せずsnapshot／counters／eventsを保持してfail closed。成功configure／round resetだけがlatch／enemyを初期化。
- new phase、snapshot field、Gameplay event、signal、public method、retry binding／routeなし。exact-once観測は既存debug countersへのadditive keyだけ。
- no-teleport独立fixtureはconfigured spawn miss、existing move／evade接近、全command spatial parity、part-first light／heavy hitと両recovery完走を検証。bounded禁止API 7 patternは全count `0`。
- existing boss defeat、wreck、harvest exact 3、result、rematch、round-two actionは継続Pass。

### Fresh validation

- Source: exact Git archive of `4eb47f83a093c9fe537577889dacaa888a0855b4`
- Archive: `C:\tmp\mf-fs-a-10-002-validation-4eb47f8.tar`
- Stage: `C:\tmp\mf-fs-a-10-002-validation-4eb47f8\material-frontier-online\prototype`
- Bytes／SHA-256: `522240`／`EB8424784C94476F6FA554527D81A6F1084D93649982D4A3FED3C979412A02C5`
- Pre-import `.godot`: `False`
- Result確認後cleanup: stage／archiveともに不存在
- Godot: `4.7.stable.official.5b4e0cb0f`

Results:

- fresh editor import: exit `0`
- Gameplay loop／arena／self-check parse: each exit `0`
- Integration root／self-check parse: each exit `0`
- Gameplay self-check: `343` PASS lines、unexpected error `0`、final `PASS: full gameplay loop`、exit `0`
- Gameplay arena scene: error `0`、exit `0`
- Integration self-check: `self_check=PASS checks=236 shapes=3 events=3 one_loop=true presentation_parity=true`、exit `0`
- Integration expected fail-closed rejection warning: exact `4`; unexpected script／assertion error `0`
- `fs_a_main.tscn`: error `0`、exit `0`
- Presentation pure shell: error `0`、exit `0`
- candidate-independent QA fixture: `PASS: contract seam skeleton fixture`、exit `0`
- project main: `DefinitionsValidated ok=true`、RHL violation `0`、exit `0`
- Phase 1: all tests Pass、exit `0`
- Slice 2-A: `120 assertions` Pass、exit `0`
- correction: `39 assertions` Pass、exit `0`
- implementation range `git diff --check`: exit `0`

Two non-qualifying summary-only PowerShell attempts（Gameplay wildcard count `0`、Integration text count `14`）はunderlying Godot exit `0`だったが集計誤りとして破棄し、corrected rerunの`343`／warning exact `4`を上記結果に使用した。full commands、anchors、expected vs actualはreportに記録済み。

### Not run / known limitations

- manual KBM functional／feel、telegraph readability、integrated user playtest: Not run; 統合後の再validation待ち
- Presentation spatial parity manual check: Not run
- physical gamepad: Not run / Deferred
- performance、export／portable build: Not run
- final validation／Gate判定: Not run; 本票では既存validation branch／worktreeを使用・変更していない
- FS-A combat／tuning値は既存`fs_provisional`のまま。Phase 1 move／evadeはread-only dependencyとして不変。
- user retry／UI／production defeat eventは未実装で、`OQ-005`／`OQ-001`をOpenのまま保持する。

### Shared contract

追加変更不要。Approved済みplayer-defeat stop normalization／spatial seam内で閉じ、contract、Open Question、Decision文書は変更していない。
