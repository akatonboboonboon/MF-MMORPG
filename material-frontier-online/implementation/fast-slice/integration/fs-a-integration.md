# FS-A Integration-Only Return Report

- Work order: `MFO-WO-FS-A-00-001 / Issued / Active`
- Branch: `codex/fast-slice-fs-a-integration`
- Foundation HEAD: `d4b24ed19a1410bac118ad90bbb136d822cb1a6d`
- Issued tip: `4a443e9789ee381022c6ee8fb85330e790e734d9`
- Tested implementation / self-check tip: `ae6bfadaad3c665b59f7cbf73a364d75da3d4a21`
- Status: `Returned for 00 review / integration candidate only`

この結果はintegration candidateの作成までであり、FS-A acceptance、Gate判定、manual KBM、物理gamepad、performance、final validationのPassではない。

## Lineage

Foundationへ採用済みのcandidate lineageは次のとおり。個別15 commitのsource SHA→integration SHA対応は
`docs/handoffs/fast-slice/integration.md`の固定表を参照する。

| Role | Reviewed source tip | Foundation integration tip |
|---|---|---|
| 10 Gameplay | `17773c5f186dfbbd1a1e52a304df123b76d9ad35` | `80150b0b61c6caf3a6c8586e3d2a046debe81fcc` |
| 20 Presentation | `04893d6d304e0d23a68df0bd1afc2fa8e71cc461` | `5504f9ef15d8ec57caa0476dce89ef2affb4209b` |
| 30 QA preparation | `04845e7782c19352a716dbea6aea794f1047b675` | `d4b24ed19a1410bac118ad90bbb136d822cb1a6d` |

Foundation以後のpreserved history:

1. `1f54c2c846b86dd52389bab7a39328f7a44f4e3a` — `docs: record FS-A foundation integration blocker`
2. `4a443e9789ee381022c6ee8fb85330e790e734d9` — `docs: approve FS-A seam and issue integration work`
3. `f0a6608ceac038b418e2db9747aa93787fa421f5` — `feat: compose FS-A gameplay and presentation`
4. `ae6bfadaad3c665b59f7cbf73a364d75da3d4a21` — `test: add FS-A integration self-check`
5. 本reportだけを追加するhandoff commit。exact final tipはpush後のReturn protocolで00へ返す。

reset、rebase、amend、merge commit、candidate commitの置換は行っていない。

## Changed paths and ownership

`d4b24ed..4a443e9`は00発行作業であり、次の5文書だけを変更している:

- `docs/DECISIONS.md`
- `docs/FAST_SLICE_CONTRACT.md`
- `docs/OPEN_QUESTIONS.md`
- `docs/handoffs/fast-slice/integration.md`
- `docs/work-orders/fast-slice/fs-a-00-integration.md`

`4a443e9..integration tip`で10が追加したpathは次のAuthorized pathsだけ:

- `material-frontier-online/prototype/scenes/fast_slice/fs_a_main.tscn`
- `material-frontier-online/prototype/scripts/fast_slice/integration/fs_a_integration_root.gd`
- `material-frontier-online/prototype/scripts/fast_slice/integration/fs_a_integration_root.gd.uid`
- `material-frontier-online/prototype/scripts/fast_slice/integration/fs_a_integration_self_check.gd`
- `material-frontier-online/prototype/scripts/fast_slice/integration/fs_a_integration_self_check.gd.uid`
- `material-frontier-online/implementation/fast-slice/integration/fs-a-integration.md`

Gameplay／Presentation／QA candidate-owned path、`project.godot`、Input Map、autoload、共有契約、00 handoff、
final validation worktree／branchの変更は`0`。新規collision／physics、preview stub、追加authorityもない。

## Implementation

- `fs_a_main.tscn`はGameplay arenaとPresentation pure shellをexact各1 childとしてinstance化する。
- parent ready時にGameplayのinitial snapshotを明示pullし、その後の`snapshot_changed`と
  `gameplay_event`を各exact once接続する。
- Presentationへ渡すdeep-copied read-only snapshotの`telegraph.shape`だけを次のとおり変換する:
  - `telegraph_line -> line`
  - `telegraph_sector -> sector`
  - `shape == "" && active == false -> line`、`active == false`は保持
- active empty、unknown shape、schema不足は、そのPresentation snapshot updateだけをfail closedにし、
  直前Presentation状態とGameplay source snapshotを変更しない。
- eventは次の3件だけをdeep-copied read-only envelope／payloadとしてforwardする:
  - `player_action_accepted -> ActionStarted`
  - `player_hit_resolved`かつ`hit == true -> HitConfirmed`
  - `part_broken -> PartBroken`
- hit false／missing／non-boolとunmapped eventは、そのPresentation event updateだけをfail closedにする。
- PresentationからGameplayへのwrite-back、`boss_hp` alias、damage／result／rematch authorityの再定義はない。
- Presentation enabled／disabledへ同一command列を与え、result、完全rematch reset、round-two full action result、
  final authority snapshotが一致することをself-checkする。
- `fs_provisional`値は変更・正式仕様化していない。

## Execution environment

- OS: Windows x86_64 / PowerShell
- Godot: `4.7.stable.official.5b4e0cb0f`
- Executed commit: `ae6bfadaad3c665b59f7cbf73a364d75da3d4a21`
- Fresh stage: `C:\tmp\mf-fs-a-int-validation-ae6bfad\material-frontier-online\prototype`
- Stage construction: `git archive HEAD material-frontier-online/prototype`を新規temporary directoryへ展開。
  editor import前の`.godot`存在は`False`。Git worktreeは作成していない。

## Exact commands and results

`$Godot`は
`C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`、
`$FreshStage`は上記fresh stage。

| Command | Expected | Actual |
|---|---|---|
| `& $Godot --version` | exact Godot identity | `4.7.stable.official.5b4e0cb0f`, exit `0` |
| `& $Godot --headless --editor --path $FreshStage --quit` | fresh import | import complete, exit `0` |
| `& $Godot --headless --path $FreshStage --check-only --script res://scripts/fast_slice/integration/fs_a_integration_root.gd` | root parse | exit `0` |
| `& $Godot --headless --path $FreshStage --check-only --script res://scripts/fast_slice/integration/fs_a_integration_self_check.gd` | self-check parse | exit `0` |
| `& $Godot --headless --path $FreshStage --script res://scripts/fast_slice/integration/fs_a_integration_self_check.gd` | Option A、fail-closed、one-loop、parity | `self_check=PASS checks=236 shapes=3 events=3 one_loop=true presentation_parity=true`, exit `0` |
| `& $Godot --headless --path $FreshStage --scene res://scenes/fast_slice/fs_a_main.tscn --quit-after 120` | integrated scene launch | exit `0` |
| `& $Godot --headless --path $FreshStage --check-only --script res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd` | Gameplay parse | exit `0` |
| `& $Godot --headless --path $FreshStage --script res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd` | Gameplay loop | `PASS: full gameplay loop`, exit `0` |
| `& $Godot --headless --path $FreshStage --scene res://scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn --quit-after 120` | Gameplay scene launch | exit `0` |
| `& $Godot --headless --path $FreshStage --scene res://scenes/fast_slice/presentation/fs_a_presentation_preview.tscn -- --fs-a-self-check` | Presentation self-check | `self_check=PASS snapshots=4 events=3 harvest_each=3 read_only=true`, exit `0` |
| `& $Godot --headless --path $FreshStage --scene res://scenes/fast_slice/presentation/fs_a_presentation_shell.tscn --quit-after 5` | pure shell smoke | exit `0` |
| `& $Godot --headless --path $FreshStage --scene res://scenes/fast_slice/presentation/fs_a_presentation_preview.tscn --quit-after 5` | preview smoke | exit `0` |
| `& $Godot --headless --path $FreshStage --script res://tests/fast_slice/run_fs_a_contract_skeleton.gd` | QA candidate-independent fixture | `PASS: contract seam skeleton fixture`, exit `0` |
| `& $Godot --headless --path $FreshStage --quit-after 120` | existing project main smoke | exit `0` |
| `& $Godot --headless --path $FreshStage --script res://tests/run_phase1_tests.gd` | Phase 1 regression | `PASS: all Phase 1 tests`, exit `0` |
| `& $Godot --headless --path $FreshStage --script res://tests/run_slice2a_tests.gd` | Slice 2-A regression | `PASS: 120 assertions`, exit `0` |
| `& $Godot --headless --path $FreshStage --script res://tests/run_slice2a_correction_tests.gd` | Slice 2-A correction | `PASS: 39 assertions`, exit `0` |
| `git diff --check 4a443e9789ee381022c6ee8fb85330e790e734d9..HEAD` | 10 range whitespace clean | exit `0` |
| `git diff --check d4b24ed19a1410bac118ad90bbb136d822cb1a6d..HEAD` | cumulative range whitespace clean | exit `0` |

Self-checkはfail-closed確認のためactive-empty／unknown shapeをenabled／disabled各1回意図的に注入する。
この4件の`Presentation snapshot update rejected` warningは期待値であり、assertion failure／script errorは`0`。

## Not run

- manual KBM操作感／可読性
- 物理gamepad
- performance、profiling、export build
- user playtest
- FS-A final validationおよびGate判定

## Known limitations

- 表示は既存Presentation pure shellのplaceholder表現であり、manual readability approvalは未実施。
- fail-closed updateはPresentation側だけを保持してGameplayを継続する。unknown schemaの意味を推測して補完しない。
- 本票ではcandidate-owned Gameplay／Presentation／QA実装を変更していない。

## Shared contract

追加の共有契約変更は不要。Option Aとinactive-empty normalizationはissued tip
`4a443e9789ee381022c6ee8fb85330e790e734d9`で既にApproved／同期済みであり、本実装はそのexact seamだけを実装した。
