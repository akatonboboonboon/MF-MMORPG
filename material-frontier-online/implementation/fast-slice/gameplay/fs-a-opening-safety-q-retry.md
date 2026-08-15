# FS-A Gameplay Safe Opening / Q Defeat Retry Report

- Status: Completed / prepared for `00` review
- Work order: `MFO-WO-FS-A-10-003`
- Contract: `docs/FAST_SLICE_CONTRACT.md`
- Contract foundation: `cdd54cf0fb1dfb84b857db11e69bab622018d629`
- Issuance tip: `36286a88925520d588d8745de34478c855b34fdb`
- Integration setup record: `1c20674a2780f89f98a645e9fe0d93f2ce5b5a38`（candidate ancestry外のadministrative sibling record）
- Accepted Gameplay Return: `817f45a02ed44492084c3f7b864125451eb365b1`（source identity、candidate ancestry外）
- Integrated Gameplay source: `9f77a02a7965ff1efcb4b7175ae30d9c1a515bf4`
- Frozen combined candidate: `f03a43d2339e9772a15db1c591a31f5e4f92cca2`
- Accepted QA final: `e261392dd0944d09d0ac6f3a6fef9b0346795c10`（evidence identity、candidate ancestry外）
- Branch: `codex/fast-slice-fs-a-gameplay-opening-retry`
- Worktree: `C:\tmp\mf-fs-a-10-opening-retry`
- Tested implementation tip: `c3b8beac232c932af3aa91d1539671203ccea0ab`
- Integration status: not merged; `00` review／ordered cherry-pick待ち

## Source identity and lineage

- `cdd54cf0... -> 36286a8...` contract-foundation ancestry: exit `0`
- `9f77a02... -> 36286a8...` integrated Gameplay source ancestry: exit `0`
- `f03a43d... -> 36286a8...` frozen combined candidate ancestry: exit `0`
- accepted Return `817f45a...`、QA final `e261392...`、setup record `1c20674...`はwork orderどおりcandidate ancestry外のsource／evidence／administrative identity。
- setup record `1c20674...`のparentはissuance `36286a8...`で、本candidateと並ぶadministrative sibling。
- `36286a8... -> c3b8bea...` candidate ancestry: exit `0`、one implementation commit、merge `0`。
- issuance prototype tree: `2a66e4c06308a47678e8888a739b87ffd33d1ee8`
- tested implementation root tree: `5cf9d5f74a8c03da79588c61cfbfb0f9dca0ffd1`
- tested implementation prototype tree: `9e4a082de758ee64d925dc72c5382cb7dbf6c88a`
- frozen Gameplay worktrees `C:\tmp\mf-fs-a-10` at `17773c5...` and `C:\tmp\mf-fs-a-10-rework` at `817f45a...`は開始時cleanで、変更していない。

開始5 blobはaccepted Return、integrated source、frozen combined candidate、issuanceで全件同一だった。

| Source | Issuance blob | Tested implementation blob |
|---|---|---|
| `fs_a_provisional_tuning.tres` | `db4de953b6067afb8dfa5bb563925759d1728ae8` | `9ba34dead8b70a42698087d2c2d273c6af3be23e` |
| `fs_a_input_adapter.gd` | `27dba8de6095af346c99438bfc08c123d2469ee6` | `7aa6c3c1d61ac44e140e0af9b2cc759eba0557c5` |
| `fs_a_gameplay_loop.gd` | `cba294285acff4ae6e23c0eefa26a2ce5d405064` | `2619e908209cf0231146a560f1f321a0c200517f` |
| `fs_a_gameplay_arena.gd` | `34caf62ccfe6916e9ac1b99ea91538c9a22dd5c7` | `c94b0e4e1e7cdf6c199a8e8144ba124a710137f7` |
| `fs_a_gameplay_self_check.gd` | `94a1b81e5b6a1c121536b1321fdbdc8550ac7939` | `0bf3dc42fee5aeba829fbc1c8d876ebe78aab3d9` |

## Implementation-only commit and paths

- `c3b8beac232c932af3aa91d1539671203ccea0ab` — `feat: add FS-A safe opening and defeat retry`

Changed production paths are exact five:

- `material-frontier-online/prototype/data/fast_slice/fs_a_provisional_tuning.tres`
- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_input_adapter.gd`
- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_loop.gd`
- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_arena.gd`
- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd`

No scene、UID、`project.godot`、Input Map、autoload、Phase 1 input／actor／action、Presentation、Integration、QA、shared contract変更。implementation commit時のworktreeはclean。

## Implementation

### Safe opening

- `fs_a_provisional_tuning.tres`の`player_start_position`だけを`Vector2(520, 540)`から`Vector2(200, 540)`へ変更した。
- initial aim `(1, 0)`、boss／part／harvest位置、movement bounds、line／sector geometry・timing・damage、enemy selection／cooldown、HP、reward、その他`fs_provisional`値は変更していない。
- boss `(1350, 540)`までの距離はexact `1150`。line range `980`、sector range `520`の双方より大きい。
- partまでの距離はexact `1065`。fresh sceneのlight／heavyは射程外missし、existing move／evade commandだけのbounded `180` commands以内でpart射程へ接近できる。
- stationary openingでもenemy line／sector schedulingは通常どおり進み、grace／suppressionなしのrange missとしてIntegrity／Deformationを保持する。
- initial configure、Q retry、existing result rematchは同じconfigured `(200, 540)`／aim rightへ戻る。

### Defeated Q retry

- `FsAInputAdapter`は既存`Phase1InputAdapter.ACTION_LOCK_ON`を`Input.is_action_just_pressed()`でfresh captureし、buffer／retained stateを追加していない。
- `FsAGameplayLoop.request_player_defeat_retry()`はconfigured＋private defeat latch＋Integrity `0`でguardし、existing `_reset_round_state()`だけを実行する。round index／rematch counterを変更せず、event／signal／counter／snapshot fieldを追加しない。
- arenaのseamは既存4-arg caller互換のtrailing default `retry_requested = false`。command開始時snapshotがすでにIntegrity `0`の場合だけretryを評価する。
- alive-start fatal command上のQ edgeは同commandで再利用せず、次commandへ繰り越さない。held／release／neutral／aim-only／defeat中Eは従来どおりno-op。
- accepted retryはloop reset、actor configured position／aim reset、authority node sync、existing snapshot exact 1 emit後に即returnする。同command上のmove、aim、evade、light、heavy、E、deltaを全消費する。
- step resultの既存5 keyと意味は不変で、新しいretry result keyはない。Gameplay event、rematch event、retry eventも生成しない。
- alive Qはretryせず、同commandのvalid move／aim／evade／actionを消費しない。wreck Qはharvestせず、result Qはrematchしない。

### Full reset and repeated retry evidence

- Integrity=max、Deformation `0`、actor／snapshot position `(200, 540)`、aim `(1, 0)`、velocity `0`、evade inactive／reuse `0`、action idle、pending player queryなし。
- combat phase、boss max／functional、part max／intact、enemy initial cooldown、telegraph inactive、pending enemy hitなし。
- wreck／result inactive、exact 3 harvest uncollected、reward `0`、runtime wreck／harvest node `0`。
- current round／rematch counter保持、snapshot／debug／step-result schema exact、rematch／retry event `0`。
- real `Input.action_press/release`からcaptureしたneutral／fresh／held／release／new fresh edgeをfatal、defeated、retry commandへ渡した。
- first Q retry後の同一arenaで再度player defeatをlatchし、held-through-fatal／releaseではfreeze、新しいfresh Qだけでsecond retry exact onceを確認した。
- retry後half cooldownでstale pending enemy hit／event／resolution counterが`0`、その後first line scheduleが通常再開した。
- round twoでもfresh Q retryがround／rematch countを保持した。

## No-teleport traversal audit

`_test_no_teleport_traversal()`（tested source lines `460–824`、次のfunc boundary直前）をbounded抽出し、次の7 patternを監査した。

- `.global_position =`
- `.position =`
- local／global transform direct write
- position setter
- transform setter
- `reset_authority_state()`
- `set_player_spatial_state()`

全pattern count `0`、audit exit `0`。fixtureはconfigured spawnでlight／heavy missを完走し、existing move／evadeだけで接近し、全commandのactor／snapshot position parity、part-first light／heavy hit、両recovery、duplicate hitなしを確認する。

## Fresh archive validation

Validation source was the exact Git archive of `c3b8beac232c932af3aa91d1539671203ccea0ab`, not a worktree copy.

- Archive: `C:\tmp\mf-fs-a-10-003-validation-c3b8bea.tar`
- Bytes: `583680`
- SHA-256: `EAC4406BAD320FB07B9C0E64303D70132738A3E7BA8088E73E3D02C329850FEF`
- Pax `get-tar-commit-id`: `c3b8beac232c932af3aa91d1539671203ccea0ab`
- Archive manifest: `125` entries、`project.godot` exact `1`、`.git`／`.godot` `0`、target 5 files each exact `1`
- Stage: `C:\tmp\mf-fs-a-10-003-validation-c3b8bea\material-frontier-online\prototype`
- Pre-import `.godot`: `False`; post-import `.godot`／global class cache: `True`; stage `.git`: `False`
- Host `core.autocrlf=true`により展開sourceはCRLF／BOMなしでmaterializeした。raw stage byte hashをGit LF blob identityとして扱わず、repository path-aware clean filter後のhashがtested implementation 5 blobsと`5 / 5`一致した。
- Result確認後cleanup: root `False`／archive `False`（both absent）、exit `0`
- Host: Windows x86_64、PowerShell、Godot `4.7.stable.official.5b4e0cb0f`

Godot executable:

`C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`

Exact variables:

```powershell
$Godot = 'C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe'
$Stage = 'C:\tmp\mf-fs-a-10-003-validation-c3b8bea\material-frontier-online\prototype'
```

All Godot rows except version and fresh import used `& $Godot --headless --path $Stage <row command>`. Version used `& $Godot --version`; import used `& $Godot --headless --editor --path $Stage --quit`.

| # | Exact command suffix / check | Result |
|---:|---|---|
| 1 | `--version` | exact `4.7.stable.official.5b4e0cb0f`、exit `0` |
| 2 | `--headless --editor --path $Stage --quit` | fresh import／global class cache Pass、exit `0` |
| 3 | `--check-only --script res://scripts/fast_slice/gameplay/fs_a_input_adapter.gd` | exit `0` |
| 4 | `--check-only --script res://scripts/fast_slice/gameplay/fs_a_gameplay_loop.gd` | exit `0` |
| 5 | `--check-only --script res://scripts/fast_slice/gameplay/fs_a_gameplay_arena.gd` | exit `0` |
| 6 | `--check-only --script res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd` | exit `0` |
| 7 | `--check-only --script res://scripts/fast_slice/integration/fs_a_integration_root.gd` | exit `0` |
| 8 | `--check-only --script res://scripts/fast_slice/integration/fs_a_integration_self_check.gd` | exit `0` |
| 9 | `--script res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd` | `533` PASS lines、required named anchors `15 / 15`、each exact `1`、unexpected error／FAIL `0`、final `PASS: full gameplay loop`、exit `0` |
| 10 | `--scene res://scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn --quit-after 120` | error `0`、exit `0` |
| 11 | `--script res://scripts/fast_slice/integration/fs_a_integration_self_check.gd` | `self_check=PASS checks=236 shapes=3 events=3 one_loop=true presentation_parity=true`、expected warning exact `4`、exit `0` |
| 12 | `--scene res://scenes/fast_slice/fs_a_main.tscn --quit-after 120` | error `0`、exit `0` |
| 13 | `--check-only --script res://scripts/fast_slice/presentation/fs_a_presentation_shell.gd` | exit `0` |
| 14 | `--check-only --script res://scripts/fast_slice/presentation/fs_a_presentation_preview.gd` | exit `0` |
| 15 | `--check-only --script res://scripts/fast_slice/presentation/fs_a_preview_stub.gd` | exit `0` |
| 16 | `--scene res://scenes/fast_slice/presentation/fs_a_presentation_preview.tscn -- --fs-a-self-check` | `self_check=PASS snapshots=5 spatial_schema=true anchors=40 ... invalid_updates=20 deep_read_only=true`、expected warning exact `20`、exit `0` |
| 17 | `--scene res://scenes/fast_slice/presentation/fs_a_presentation_shell.tscn --quit-after 5` | error `0`、exit `0` |
| 18 | `--scene res://scenes/fast_slice/presentation/fs_a_presentation_preview.tscn --quit-after 5` | error `0`、exit `0` |
| 19 | `--script res://tests/fast_slice/run_fs_a_contract_skeleton.gd` | fixture-only `PASS: contract seam skeleton fixture`、exit `0` |
| 20 | `--quit-after 120` | existing main `DefinitionsValidated ok=true`、RHL `violation_count=0`、exit `0` |
| 21 | `--script res://tests/run_phase1_tests.gd` | `PASS: all Phase 1 tests`、exit `0` |
| 22 | `--script res://tests/run_slice2a_tests.gd` | `PASS: 120 assertions`、exit `0` |
| 23 | `--script res://tests/run_slice2a_correction_tests.gd` | `PASS: 39 assertions`、exit `0` |

Gameplay qualifying anchors included:

- configured safe opening spawn exact `(200, 540)`、stationary line／sector range miss
- spawn light／heavy out-of-range miss、bounded no-teleport approach
- real fresh Q／held／release capture
- fatal-command Q edge non-reuse、fresh composite snapshot exact once
- same-arena second defeat／second fresh Q exact once
- stale enemy hit `0`／enemy schedule restart
- wreck Q-only／result Q-only negative
- round-two retry round preservation
- terminal `PASS: full gameplay loop`

Integration warning exact `4`はactive-empty／unknown telegraph shapeのenabled／disabled fail-closed fixture。Presentation warning exact `20`はinvalid-spatial fixture。qualifying matrixのwarningはこのexpected `24`件だけでunexpected warningは`0`、unexpected `ERROR`／`SCRIPT ERROR`／terminal `FAIL`も`0`。

### Non-qualifying orchestration attempts

次の試行はcandidate acceptanceへ使用せず、条件を緩和せずにcorrected commandを再実行した。

1. precommit local parseをeditor import前に開始してglobal class cache未生成で停止。local editor import後のparse／self-checkと、上表のfresh import後parseをqualifying evidenceに使用した。
2. first Gameplay summary wrapperは`[`を未escapeのPowerShell wildcardとして扱い、underlying Godot exit `0`／anchors each `1`にもかかわらずPASS countを集計できなかった。corrected regex wrapperの`533`を採用した。
3. Presentation stub parseのfirst pathを不存在の`fs_a_presentation_preview_stub.gd`と誤記してexit `1`。archive列挙後、actual `fs_a_preview_stub.gd`をparseしてexit `0`。
4. bounded auditのfirst JavaScript templateはnewline quotingでchild invocation前にsyntax stop。corrected bounded extractionは7 counts `0`、exit `0`。
5. first Git scope wrapperはPowerShellの`$issuance..$impl`をrange文字列として渡せずGit usageで停止。明示的`$range = $issuance + '..' + $impl`へ直し、exact 5／diff-check `0`を確認した。

## Scope audit

- `36286a8..c3b8bea`: one non-merge implementation commit、exact 5 production paths、merge `0`
- `git diff --check 36286a8..c3b8bea`: exit `0`
- implementation checkpoint `c3b8beac232c932af3aa91d1539671203ccea0ab`（validation完了・report作成前）では、`.uid`、mode、submodule、nonignored untracked、temporary helper、Forbidden path changes: `0`
- tuning deltaは`player_start_position` exact 1値だけ。他`fs_provisional`値、geometry、damage、selectionは不変。
- no snapshot field、Gameplay event、signal、phase、public step-result key追加。Integration existing 4-arg callは不変。
- Input Map／`project.godot`変更`0`。Q／LB、E／RB exact event countとrepeated `ensure_input_map()` idempotenceはGameplay self-checkでPass。
- archive provenance、path-aware 5 blob identity、implementation checkpointのworktree cleanを独立read-only reviewでもPass。

Final 7-path／3-commit audit、final prototype tree／5 blobs、local／tracking／live origin identityはreport-only／handoff-only commit後のformal Returnで記録する。

## Not run / known limitations

- manual KBM Q fresh-edge、opening feel、integrated readability／user feel: Not run; integrated QA revalidationへ渡す。
- physical gamepad `LB`: static binding only、Not run / Deferred。KBM結果でPassへ昇格しない。
- performance／P95／maximum load／long-run: Not run / Deferred。
- export／portable build: Not run。
- final validation／Gate／promotion: Not run。本票で既存validation branch／worktreeを使用・変更していない。
- safe opening coordinateはFS-A branch-local `fs_provisional`で、stable production value／MASTER_SPEC／Gate evidenceへ昇格していない。
- alive Qのtarget-selection lock-on、production retry UI、auto retry、production `ActorDefeated` eventは実装していない。
- `OQ-001` production defeat eventと`OQ-004` hit presentationはOpenのまま。`OQ-005`／`OD-021-INPUT`はApproved／Closedで、本票はそのexact Option Aだけを実装した。

## Shared contract

追加変更不要。Approved済みsafe opening normalizationとplayer-defeat Q retry normalizationの範囲内で閉じ、contract、MASTER_SPEC、Decision、Open Question、Milestone、work orderを変更していない。
