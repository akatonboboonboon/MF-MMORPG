# FS-A Gameplay Defeat / Traversal Rework Report

- Status: Returned for `00` review
- Work order: `MFO-WO-FS-A-10-002`
- Contract: `docs/FAST_SLICE_CONTRACT.md`
- Contract foundation: `bf89fcd26cde65659e7addc97952fb9f9fc1dc58`
- Issuance tip: `e09bf9ae8444af1570e32819096c069dca370eb5`
- Integration setup record: `7f780d13b543d147651f12df9eb702cb09122263`（candidate ancestry外のadministrative sibling record）
- Frozen Gameplay source identity: `17773c5f186dfbbd1a1e52a304df123b76d9ad35`
- Branch: `codex/fast-slice-fs-a-gameplay-rework`
- Worktree: `C:\tmp\mf-fs-a-10-rework`
- Tested implementation tip: `4eb47f83a093c9fe537577889dacaa888a0855b4`
- Integration status: not merged; `00` review／cherry-pick待ち

## Source identity and lineage

- `bf89fcd... -> e09bf9a...` ancestry: exit `0`
- `17773c5... -> e09bf9a...` ancestry: exit `1`（work orderどおりnon-ancestor source identity）
- `e09bf9a... -> 4eb47f8...` candidate ancestry: exit `0`
- frozen worktree: `codex/fast-slice-fs-a-gameplay` at `17773c5...`、clean
- issuance時のexact 3 source blobはfrozen sourceと一致した。

| Source | Frozen blob | Issuance blob | Tested implementation blob |
|---|---|---|---|
| `fs_a_gameplay_loop.gd` | `0096762451939d848c9505c4945ae29cc546c7da` | same | `cba294285acff4ae6e23c0eefa26a2ce5d405064` |
| `fs_a_gameplay_arena.gd` | `00651b12ca9a97e38e6aecb0db46e1f2264a58d2` | same | `34caf62ccfe6916e9ac1b99ea91538c9a22dd5c7` |
| `fs_a_gameplay_self_check.gd` | `1ca4a2a8ae9174d9d341a3d6687d2aeb7f1af425` | same | `94a1b81e5b6a1c121536b1321fdbdc8550ac7939` |

## Implementation-only commit and paths

- `4eb47f83a093c9fe537577889dacaa888a0855b4` — `feat: close FS-A defeat and traversal gameplay`

Changed source paths are exact three:

- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_loop.gd`
- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_arena.gd`
- `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd`

No scene、UID、data、tuning、player action、input adapter、Presentation、Integration、QA、`project.godot`、Input Map、autoload、shared contract変更。全3 sourceはLF／UTF-8 BOMなし。

## Implementation

- player Integrityのpositive-to-zero edgeをboss defeatと別のprivate latchでexact once確定する。
- latch時にexisting player actionをcancelしてpending action／pending hit queryを破棄し、existing enemy stopでtelegraph、attack ID、pending enemy hitを破棄する。
- fatal `enemy_hit_resolved`はstop前にattack ID／shapeを保持し、loop内でlatch、player action／query cancel、enemy stopを確定してから既存eventだけをemitする。同期listenerからの再入actionはloop latch、再入arena commandはcanonical Integrity `0`によりmotion前にfail closed。
- defeat後はloopのspatial、action、player hit query、enemy advance／resolve入口をno-opにし、追加damage、Deformation、counter、eventを発生させない。
- arenaはdefeat後commandをexisting motion適用前にno-opにする。fatal event return後／step return前に、fatal edgeだけexisting `reset_authority_state(current_position, current_aim)`を用い、active evade／velocityを止めながらlatch位置を保持する。
- player defeatでは`loop_phase == combat`、boss HP／function、part、wreck、harvest、reward、resultを変更しない。
- invalid `configure(null)`はlatchを解除せずfail closed。成功したconfigure／round resetだけがprivate latch／countとenemy stateを初期化する。
- snapshot field、Gameplay event、signal、public method、retry action／binding／phaseは追加していない。Acceptance観測用に既存`debug_counters()`へ`player_defeat_latches`だけを追加した。

## No-teleport traversal structure

`_test_no_teleport_traversal()`を独立区間とし、scene ready後に次を実行する。

1. configured spawnからlight／heavyを別々に完走し、両方のout-of-range miss、duplicate hitなし、boss／part HP不変を確認。
2. `step_authority_command()`とexisting move／evade commandだけで接近。
3. 全commandでsnapshot `player_position`とauthority actor world positionを比較。
4. 射程内light／heavyを別々にrequestからrecovery／idleまで完走し、existing part-first target、tuning由来damage、linked body damage、HP、hit／part-break event exact onceを確認。

実装tipの同関数をbounded抽出して次の禁止patternを監査し、すべてcount `0`:

- direct `.position =`／`.global_position =`
- direct local／global transform write
- position／transform setter
- `reset_authority_state()`
- `set_player_spatial_state()`

Audit command（repository root `C:\tmp\mf-fs-a-10-rework`）:

```powershell
$Source = 'material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd'
$Text = [IO.File]::ReadAllText((Resolve-Path -LiteralPath $Source))
$Body = [regex]::Match($Text, '(?ms)^func _test_no_teleport_traversal\b.*?(?=^func )')
$Patterns = @(
  '\.global_position\s*=',
  '\.position\s*=',
  '\.(global_)?transform\s*=',
  'set_(global_)?position\s*\(',
  'set_(global_)?transform\s*\(',
  'reset_authority_state\s*\(',
  'set_player_spatial_state\s*\('
)
if (-not $Body.Success) { exit 1 }
foreach ($Pattern in $Patterns) {
  if ([regex]::Matches($Body.Value, $Pattern).Count -ne 0) { exit 2 }
}
```

Result: bounded function found、7 forbidden regex counts all `0`、exit `0`。

`fs_provisional`のIntegrity、Deformation、damage期待値はresourceから導出し、literalをproduction仕様として固定していない。reach、geometry、damage、target selection、tuning data自体は変更していない。

## Defeat checks

- actual line／sectorの4 hitからtuning由来のpositive pre-fatal Integrityを作り、次のlineをfatal edgeとしてIntegrity exact `0`、latch exact `1`を確認。
- direct loopではfatal直前にheavy pending queryを開き、fatal後のaction idle／query破棄／duplicate resolve拒否を確認。
- arenaではfatal直前にactive evade、non-zero velocity、light windupを同時成立させ、fatal tickの合法移動後位置を保持したままevade／velocity／action／query停止を確認。
- defeat後にmove、evade、light、heavy、`E`、large deltaを反復し、step result no-op、whole snapshot、all debug counters、all Gameplay events、actor position不変を確認。
- boss functional、boss／part HP、unbroken part、combat phase、wreck／harvest／result／reward／runtime node未生成を確認。
- invalid configure後もdefeated state不変、valid configure後はlatch count `0`、Integrity復帰、action／enemy scheduling再開を確認。
- existing boss defeat、wreck exact once、harvest exact 3、duplicate拒否、result、complete rematch、round-two actionの従来checkを保持。

## Fresh archive validation

Validation source was the exact Git archive of `4eb47f83a093c9fe537577889dacaa888a0855b4`, not a worktree copy.

- Archive: `C:\tmp\mf-fs-a-10-002-validation-4eb47f8.tar`
- Bytes: `522240`
- SHA-256: `EB8424784C94476F6FA554527D81A6F1084D93649982D4A3FED3C979412A02C5`
- Stage: `C:\tmp\mf-fs-a-10-002-validation-4eb47f8\material-frontier-online\prototype`
- Pre-import `.godot` existed: `False`
- Cleanup after result confirmation: stage `False`／archive `False`（both absent）
- Host: Windows x86_64、PowerShell、Godot `4.7.stable.official.5b4e0cb0f`

Godot executable:

`C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`

Exact variables:

```powershell
$Godot = 'C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe'
$Stage = 'C:\tmp\mf-fs-a-10-002-validation-4eb47f8\material-frontier-online\prototype'
```

All Godot rows except `--version` used `& $Godot --headless --path $Stage <row command>`; fresh import used the exact order `& $Godot --headless --editor --path $Stage --quit`. Version used `& $Godot --version`. Git used `git -C C:\tmp\mf-fs-a-10-rework diff --check e09bf9ae8444af1570e32819096c069dca370eb5..4eb47f83a093c9fe537577889dacaa888a0855b4`.

| Command / check | Result |
|---|---|
| `--version` | exact `4.7.stable.official.5b4e0cb0f`, exit `0` |
| `--editor --quit` | fresh import Pass、exit `0` |
| `--check-only --script res://scripts/fast_slice/gameplay/fs_a_gameplay_loop.gd` | exit `0` |
| `--check-only --script res://scripts/fast_slice/gameplay/fs_a_gameplay_arena.gd` | exit `0` |
| `--check-only --script res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd` | exit `0` |
| `--check-only --script res://scripts/fast_slice/integration/fs_a_integration_root.gd` | exit `0` |
| `--check-only --script res://scripts/fast_slice/integration/fs_a_integration_self_check.gd` | exit `0` |
| `--script res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd` | `343` PASS lines、unexpected error `0`、final `PASS: full gameplay loop`、exit `0` |
| `--scene res://scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn --quit-after 120` | error `0`、exit `0` |
| `--script res://scripts/fast_slice/integration/fs_a_integration_self_check.gd` | `self_check=PASS checks=236 shapes=3 events=3 one_loop=true presentation_parity=true`、exit `0` |
| `--scene res://scenes/fast_slice/fs_a_main.tscn --quit-after 120` | error `0`、exit `0` |
| `--scene res://scenes/fast_slice/presentation/fs_a_presentation_shell.tscn --quit-after 5` | error `0`、exit `0` |
| `--script res://tests/fast_slice/run_fs_a_contract_skeleton.gd` | `PASS: contract seam skeleton fixture`、exit `0` |
| `--quit-after 120` | existing main `DefinitionsValidated ok=true`、RHL `violation_count=0`、exit `0` |
| `--script res://tests/run_phase1_tests.gd` | `PASS: all Phase 1 tests`、exit `0` |
| `--script res://tests/run_slice2a_tests.gd` | `PASS: 120 assertions`、exit `0` |
| `--script res://tests/run_slice2a_correction_tests.gd` | `PASS: 39 assertions`、exit `0` |
| `git -C C:\tmp\mf-fs-a-10-rework diff --check e09bf9ae8444af1570e32819096c069dca370eb5..4eb47f83a093c9fe537577889dacaa888a0855b4` | exit `0` |
| bounded no-teleport function extraction + 7 forbidden regex checks（command above） | all count `0`、exit `0` |

Targeted Gameplay anchors include:

- `spawn light resolves an out-of-range miss`
- `spawn heavy resolves an out-of-range miss`
- `movement snapshot parity holds through no-teleport traversal`
- `in-range light completes recovery`
- `in-range heavy completes recovery`
- `player defeat latches exact once`
- `fatal latch cancels active evade`
- `defeat freezes player enemy counters events and position`
- `invalid configure preserves defeated authority state`

Integration emitted the expected fail-closed snapshot rejection warning exact `4`（active-empty／unknown shape、enabled／disabled）and no unexpected script/assertion error.

Two log-summary-only PowerShell attempts were not used as qualifying counts: the first Gameplay wrapper treated square brackets as wildcard syntax and reported an invalid `PASS_LINES=0`; the first Integration wrapper counted all text containing “rejected” and reported `14` instead of warning lines only. In both attempts the underlying Godot process exited `0`. Corrected non-mutating summary reruns produced Gameplay `343` and Integration warning exact `4` as recorded above.

## Scope audit

- `e09bf9a..4eb47f8`: one non-merge implementation commit、exact 3 source paths
- `.uid`、file mode、submodule、untracked temporary、Forbidden path changes: `0`
- no new snapshot field、Gameplay event、signal、public method
- no Presentation、Integration、QA、scene、data、shared contract delta
- source commit時のworktree: clean

Final 5-path／3-commit audit、prototype tree identity、local／tracking／live origin identityはreport-only／handoff-only commit後のReturnで記録する。

## Not run / known limitations

- manual KBM functional／feel、telegraph readability、integrated user playtest: Not run; rework統合後に再validationが必要
- Presentation spatial parityの手動確認: Not run; Presentation rework／00 integration側の責任境界
- physical gamepad: Not run / Deferred
- performance、export／portable build: Not run
- final validation／Gate判定: Not run; 本票では既存validation branch／worktreeを使用・変更していない
- standalone Gameplay sceneはauthority smoke用で、Presentation可読性の証拠ではない。
- FS-A combat／tuning値はすべて既存`fs_provisional`であり、production仕様へ昇格していない。Phase 1 move／evade値はread-only dependencyとして不変。
- user retry／UI／production defeat eventは未実装で、`OQ-005`／`OQ-001`をOpenのまま保持する。

## Shared contract

追加変更不要。既にApprovedのFS-A player-defeat stop normalizationとspatial seamの範囲内で実装できた。共有contract、Open Question、Decision文書は変更していない。
