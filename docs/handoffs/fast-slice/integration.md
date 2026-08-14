# Fast Slice Integration Handoff

- Status: Integrated validation Technical Pass / corrected manual retry ready; promotion pending manual KBM and user feel
- Branch: `codex/fast-slice-fs-a-integration`
- Worktree: `C:\tmp\mf-fs-a-int`
- Contract: `docs/FAST_SLICE_CONTRACT.md`
- Work order: `docs/work-orders/fast-slice/fs-a-00-integration.md`
- Owner: 00統括 only

00はreview済み10／20 tipとQA-prep tipをここへ固定する。integration codeはwork order発行後に10がsingle ownerとして編集し、結果は`material-frontier-online/implementation/fast-slice/integration/**`へ記録する。10はこのhandoffを編集しない。

## 2026-08-03 preflight

| Check | Result |
|---|---|
| Worktree / branch | `C:\tmp\mf-fs-a-int` / `codex/fast-slice-fs-a-integration` |
| Required base | `62f4af4a105b45f458beabecd6595ad5f58ec764` |
| Initial HEAD | required baseとexact一致 |
| Tracking / live origin | `origin/codex/fast-slice-fs-a-integration`、local tracking ref、`git ls-remote`結果がすべてrequired baseとexact一致 |
| Initial status | clean。tracked／untracked差分なし |
| Contract state | `Active / branch-local prototype contract` |
| Integration work order | `Draft / not issued`。候補review、tip固定、発行前のmerge／integration code／smoke／freezeは行わない |
| Baseline Fast Slice implementation | `scripts/fast_slice`、`data/fast_slice`、`scenes/fast_slice`は未作成。具体的な`fs_provisional`数値も未設定 |

共有契約の破綻、`main`への誤適用、データ損失は確認していない。候補未着または単一candidateのFailは全体停止条件ではない。

## Candidate input register

候補はpush済みexact SHA、changed paths、commands／results／Not run、担当handoffを受領してから固定する。branch名やworktree上の未commit差分をcandidateとして扱わない。

| Input | Required branch | Reviewed source tip | Handoff / scope | State |
|---|---|---|---|---|
| 10 gameplay | `codex/fast-slice-fs-a-gameplay` | `17773c5f186dfbbd1a1e52a304df123b76d9ad35` | Pass; 6 commits; 16 paths; scope外変更`0`; `git diff --check` exit `0` | Integrated through `80150b0b61c6caf3a6c8586e3d2a046debe81fcc` |
| 20 presentation | `codex/fast-slice-fs-a-presentation` | `04893d6d304e0d23a68df0bd1afc2fa8e71cc461` | Pass with source return-evidence gap independently closed; 3 commits; 10 paths; scope外変更`0`; `git diff --check` exit `0` | Integrated through `5504f9ef15d8ec57caa0476dce89ef2affb4209b` |
| 30 QA preparation | `codex/fast-slice-fs-a-qa-prep` | `04845e7782c19352a716dbea6aea794f1047b675` | Pass / QA readiness candidate only; 6 commits; 9 paths; unexpected／production changes`0`; `git diff --check` exit `0` | Integrated through `d4b24ed19a1410bac118ad90bbb136d822cb1a6d` |
| 10 integration-only | `codex/fast-slice-fs-a-integration` | `867899c7ccb9380b4bb6e4be5c51da4223532230` | Pass; 3 commits; 6 authorized paths; scope外変更`0`; `git diff --check` exit `0` | 00-reviewed; validation candidate source frozen at returned tip |

## 2026-08-14 integration-only candidate review

- Returned final tip: `867899c7ccb9380b4bb6e4be5c51da4223532230`。local HEAD、tracking ref、live originはreview開始時にexact一致し、worktreeはcleanだった。
- Tested implementation／self-check tip: `ae6bfadaad3c665b59f7cbf73a364d75da3d4a21`。final tipとの差分はintegration return report 1件だけで、prototype treeは同一である。
- Issued tip `4a443e9789ee381022c6ee8fb85330e790e734d9`以後は`f0a6608...`、`ae6bfad...`、`867899c...`の直線3 commit、merge `0`。
- Changed pathsはAuthorized paths内の新規6件だけ。Gameplay／Presentation／QA candidate、`project.godot`、Input Map、autoload、共有契約、role handoffの差分は`0`。各commit、issued range、foundation累積rangeの`git diff --check`はexit `0`。
- 独立scope／implementation／evidence reviewはいずれもblocking finding `0`。Option A、exact 3 event、deep-copy／read-only、no write-back、fail-closed、Presentation parityは実装とself-checkで整合した。
- 00はfinal tipからGit archiveの一時stage `C:\tmp\mf-fs-a-review-867899c-20260814`を作成し、import前`.godot=False`を確認して下記smokeを再実行した。stageは結果確認後に削除し、integration worktreeはclean、`C:\tmp\mf-fs-a-val`は不存在のままである。
- Decision: `Pass / integration candidate accepted for later final validation`。validation candidate source SHAを`867899c7ccb9380b4bb6e4be5c51da4223532230`へ固定する。この判定はmanual KBM／readability、gamepad、performance、export、user playtest、FS-A final validation、GateのPassではない。

### 00 fresh smoke results

| Check | Result |
|---|---|
| Godot identity | `4.7.stable.official.5b4e0cb0f`、exit `0` |
| Fresh editor import | Pass、exit `0` |
| Integration root／self-check parse | 両方exit `0` |
| Integration self-check | `self_check=PASS checks=236 shapes=3 events=3 one_loop=true presentation_parity=true`、exit `0` |
| Integrated scene launch | `res://scenes/fast_slice/fs_a_main.tscn`、exit `0` |
| Gameplay parse／self-check／scene | `PASS: full gameplay loop`、全てexit `0` |
| Presentation self-check／pure shell／preview | `snapshots=4 events=3 harvest_each=3 read_only=true`、全てexit `0` |
| QA candidate-independent fixture | `PASS: contract seam skeleton fixture`、exit `0` |
| Existing project main smoke | exit `0` |
| Phase 1 regression | `PASS: all Phase 1 tests`、exit `0` |
| Slice 2-A regression | `PASS: 120 assertions`、exit `0` |
| Slice 2-A correction | `PASS: 39 assertions`、exit `0` |
| Intentional invalid fixtures | active-empty／unknownをenabled／disabled各1回、expected warning exact `4`、self-check exit `0` |
| Post-smoke repository state | temporary stage削除済み、integration worktree clean、final validation worktree／branch未作成 |

### FS-A technical acceptance status

| # | Contract item | Result |
|---:|---|---|
| 1 | 専用scene import／parse／launch | Pass |
| 2 | move／aim／evadeの既存挙動維持 | Pass — Gameplay self-check＋Phase 1回帰 |
| 3 | light／heavyの別操作・別timing | Pass — Gameplay／integration self-check |
| 4 | enemy attack 2種の予告と回避 | Pass — Gameplay／integration self-check |
| 5 | player Integrity／Deformation変化とrematch初期化 | Pass |
| 6 | partを1個以上破壊 | Pass |
| 7 | boss HP 0遷移exact once | Pass |
| 8 | defeat後のAI／attack／hit停止 | Pass |
| 9 | wreck exact once | Pass |
| 10 | harvest exact 3、重複回収拒否 | Pass |
| 11 | 全回収後のresult表示 | Pass |
| 12 | rematch完全初期化と二周目主要操作 | Pass |
| 13 | Presentation無効時のGameplay結果不変 | Pass |

Manual KBM操作感／戦闘の読みやすさ、物理gamepad、performance／profiling、export、user playtestは`Not run`。技術13項目のPassと混同しない。

## 2026-08-14 integrated validation issuance

- User continuation authority: 2026-08-14「続きをどうぞ」。既定の30 integrated validation工程だけを進め、user-feel結果、promotion、Gate承認とは扱わない。
- Frozen integration candidate source: `867899c7ccb9380b4bb6e4be5c51da4223532230`。
- 00 review record parent: `d79b542ec42f34306a0370b07752e732dcf0c7fc`。candidateとの差分は本handoff 1件だけで、両者のprototype treeは`5f948fa5b09dc970beab5afef6c21260ecd74edf`とexact一致する。
- Validation issuance commit／branch start: `3cdf6dbd9031e3d05fd2a049c851f19409d7b592`。
- Validation branch／worktree: `codex/fast-slice-fs-a-validation`／`C:\tmp\mf-fs-a-val`。exact issuance commitから作成し、local HEAD／tracking ref／live originはすべて`3cdf6dbd9031e3d05fd2a049c851f19409d7b592`、worktreeはclean。
- Frozen candidate source `867899c7ccb9380b4bb6e4be5c51da4223532230`はvalidation HEADのancestorで、prototype treeは`5f948fa5b09dc970beab5afef6c21260ecd74edf`とexact一致する。
- 30 writable paths、candidate read-only境界、13 technical item、manual KBM／user feel、gamepad／performance Deferred、Return protocolは発行票へexact固定し、30へsingle-writer authorityを移管した。
- branch setupではcandidate implementation、QA-prep historical evidence、共有契約を変更していない。

## 2026-08-14 integrated validation Return acceptance

- Validation branch: `codex/fast-slice-fs-a-validation`。accepted QA final tip: `81c6643b71940ca8bbf1c68d3c9ce47917b9111c`。
- Commit列は`2bbe3a874f0b68e800faad5125bb3e6d60f461a3`、`9944abfe7ac1f73d8351fa29b6f3a616c252c7b6`、`3afe5782639450b5b3011eb24657a2ad196afc18`、`55d76633d73bd042be46260746da4e55bb35e145`、`0745b0156f3f1c6fcc99e478e2b5e228866fd660`、`81c6643b71940ca8bbf1c68d3c9ce47917b9111c`の直線6 commit、merge `0`。
- local HEAD、tracking ref、live originはaccepted final tipとexact一致し、worktree／indexはclean。
- issued tip `3cdf6dbd9031e3d05fd2a049c851f19409d7b592`からfinal tipまでexact `62` paths、allowlisted `62`、unexpected／protected／production／QA runner差分`0`、full `git diff --check` exit `0`。
- Candidate `867899c7ccb9380b4bb6e4be5c51da4223532230`からfinal tipまでprototype delta `0`。prototype treeは`5f948fa5b09dc970beab5afef6c21260ecd74edf`で不変。
- required automation `17 / 17` exit `0`、expected warning exact `4`、unexpected warning／ERROR／SCRIPT ERROR／terminal FAIL `0`。Contract Section 10 technical itemsは`13 / 13 Pass`。
- execution artifacts `51 / 51`、evidence summary `10 / 10`のsize／SHA-256 readback一致。7件のnormalized execution logsはoriginal blobとEOF-only差分を再照合済み。
- 00の独立scope／evidence／acceptance auditはtechnical blocker `0`。QA handoff headerとsnapshot manifestのdoc-only findingはfollow-upで解消した。
- manual KBM、readability、user feelは`Not run`。gamepad、performance／P95／maximum load／long-runは`Deferred / Not run`、optional exportとStage B 184は`Not run`。
- Manual attempt-001はeditor import欠落でcandidate評価前に停止し、`QA preparation defect`として受理した。source tree exact一致、candidate Fail／playability findingではない。evidence受理後、00がattempt-001 stage／tarをexact cleanupした。
- Corrected manual-002はfresh editor import exit `0`とglobal class cache存在をpreconditionにし、その後だけ実`fs_a_main.tscn`を起動する。
- Result: `Technical Pass / promotion pending manual KBM and/or user feel`。共有契約変更、candidate repair、promotion、Gate actionは`0`。
- Frozen implementation candidate sourceは`867899c7ccb9380b4bb6e4be5c51da4223532230`のまま。QA final tipはvalidation evidence／handoff identityであり、implementation sourceではない。

## 2026-08-04 foundation candidate integration

- Common source base: `62f4af4a105b45f458beabecd6595ad5f58ec764`。
- Preserved pre-integration HEAD: `efb7acc112537a1b562daabf9945cad9b4df11b8`。既存の`50748b76498f3ed1ed60b38f27fab6062e0e44f4`と`efb7acc...`を保持し、reset／rebase／amendは行っていない。
- `origin` fetch後、各returned branchのtracking refとlive originが返却final tipにexact一致することを確認した。
- Integration order: 10 Gameplay → 20 Presentation → 30 QA Prep。全15 commitを時系列順にcherry-pickし、競合、同一tracked file衝突、integration側手修正はすべて`0`。
- Foundation integration HEAD: `d4b24ed19a1410bac118ad90bbb136d822cb1a6d`。これはintegration-only composition前の基礎HEADであり、final validation candidateではない。
- Final validation worktree／branchは作成していない。

### Full-range review result

| Role | Source commits | Changed paths | Owner範囲外 | Production／protected path違反 | Merge commits | `diff --check` |
|---|---:|---:|---:|---:|---:|---:|
| 10 Gameplay | 6 | 16 | 0 | 0 | 0 | exit 0 |
| 20 Presentation | 3 | 10 | 0 | 0 | 0 | exit 0 |
| 30 QA Prep | 6 | 9 | 0 | 0 | 0 | exit 0 |

3 range間のchanged-path intersectionはすべて`0`。Gameplay／Presentation／QAのreport、handoff、evidence、実装内容を全rangeで照合した。GameplayとQAは整合。Presentationのsource returnにはself-check／scene smokeのexit `0`が記載されていた一方、exact argv、tested source SHA、raw-log linkが不足していたため、採用後HEAD`5504f9ef15d8ec57caa0476dce89ef2affb4209b`でexact commandを独立再実行し、Passを確認した。この補完はsource evidenceを書き換えず、本handoffのintegration evidenceとして扱う。

### Source SHA → integration SHA

| Role | Source SHA | Integration SHA |
|---|---|---|
| 10 | `57cd671eaff9a1b5e964d198e5af4df0548f6191` | `adc1a12eb43234f0cda797987efbd8eeb35ed957` |
| 10 | `74a265322c40ad1cd510ab3d076c57ed859d729f` | `3faf8a0615ed9c7c58c3adc970955790fcf5bdf3` |
| 10 | `603bbe53c7bfef68d5475053d4ce875e172bb555` | `8332efa63767e2cc6fc5a6b4b8f811deae64bdef` |
| 10 | `46e1f664f9dd53ca0e40aaf3723f705d670e4eff` | `f1bc92b3c203ea63261d92c8d67093441f2ef0fc` |
| 10 | `611f34b4e1df342ff24b8e420f26d36700c39c4a` | `9eb02fefc8b76336c2413edaaafe55e5d850fb87` |
| 10 | `17773c5f186dfbbd1a1e52a304df123b76d9ad35` | `80150b0b61c6caf3a6c8586e3d2a046debe81fcc` |
| 20 | `0404f415b7fcbe9e3c0922433232168c54595ace` | `c1639fd0f751299598c48cb1a4c54a065fa6ffad` |
| 20 | `12e109ecafa87339496c12371669dab3a66dc205` | `2fbd9b275a013186685deac6a8737cf87a9d88fa` |
| 20 | `04893d6d304e0d23a68df0bd1afc2fa8e71cc461` | `5504f9ef15d8ec57caa0476dce89ef2affb4209b` |
| 30 | `9531e3d45512a326d2a020e720f35dede3915094` | `2dd220a8b0e64f1986cb11c69a5da4100b7836e4` |
| 30 | `df18568e5288b7ef051800d26f12012d7980fc81` | `762b0f7282fcab625f0d4a7a8572e241406aba96` |
| 30 | `3cce4d31264be20323ac4f49ffdec97a5533a402` | `81cbd4e990c7677ef6ced332892c98729fff2d94` |
| 30 | `8c13a0b545fdf4c88bf33ec7be6be6649d7e7443` | `8fbc7b1460f5e75817d3463d11c012f2780e33f7` |
| 30 | `02cff48042ef1e3bc1d14d1fc4a119a3b60ca205` | `2ca01efdb7bf6617c2f803e51c1d91e9e899e3bd` |
| 30 | `04845e7782c19352a716dbea6aea794f1047b675` | `d4b24ed19a1410bac118ad90bbb136d822cb1a6d` |

### Foundation smoke evidence

Godot identityは`4.7.stable.official.5b4e0cb0f`。各stageでintegration treeを`.godot`なしのfresh temporary copyへ複製して実行し、Pass後にtemporary copyを削除した。integration worktreeは各stage後にcleanだった。

| Tested integration HEAD | Available checks | Result |
|---|---|---|
| `80150b0b61c6caf3a6c8586e3d2a046debe81fcc` | fresh import、Gameplay parse／self-check／scene、main scene、Phase 1、Slice 2-A、correction、diff check | all exit 0。20／30 filesはこのstageには未存在のため、そのrole固有commandはNot run |
| `5504f9ef15d8ec57caa0476dce89ef2affb4209b` | 上記＋Presentation self-check／pure shell／preview | all exit 0。QA fixtureはこのstageには未存在のためNot run |
| `d4b24ed19a1410bac118ad90bbb136d822cb1a6d` | fresh import、Gameplay、Presentation、QA candidate-independent fixture、main scene、Phase 1、Slice 2-A、correction、range／cumulative diff check | all exit 0 |

Final foundation stageのexact command形:

```powershell
& $Godot --version
& $Godot --headless --editor --path $FreshStage --quit
& $Godot --headless --path $FreshStage --check-only --script res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd
& $Godot --headless --path $FreshStage --script res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd
& $Godot --headless --path $FreshStage --scene res://scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn --quit-after 120
& $Godot --headless --path $FreshStage --scene res://scenes/fast_slice/presentation/fs_a_presentation_preview.tscn -- --fs-a-self-check
& $Godot --headless --path $FreshStage --scene res://scenes/fast_slice/presentation/fs_a_presentation_shell.tscn --quit-after 5
& $Godot --headless --path $FreshStage --scene res://scenes/fast_slice/presentation/fs_a_presentation_preview.tscn --quit-after 5
& $Godot --headless --path $FreshStage --script res://tests/fast_slice/run_fs_a_contract_skeleton.gd
& $Godot --headless --path $FreshStage --quit-after 120
& $Godot --headless --path $FreshStage --script res://tests/run_phase1_tests.gd
& $Godot --headless --path $FreshStage --script res://tests/run_slice2a_tests.gd
& $Godot --headless --path $FreshStage --script res://tests/run_slice2a_correction_tests.gd
git diff --check 5504f9ef15d8ec57caa0476dce89ef2affb4209b..d4b24ed19a1410bac118ad90bbb136d822cb1a6d
git diff --check efb7acc112537a1b562daabf9945cad9b4df11b8..d4b24ed19a1410bac118ad90bbb136d822cb1a6d
```

Observed anchors: Gameplay `PASS: full gameplay loop`、Presentation `self_check=PASS snapshots=4 events=3 harvest_each=3 read_only=true`、QA `PASS: contract seam skeleton fixture`、Phase 1 `PASS: all Phase 1 tests`、Slice 2-A `PASS: 120 assertions`、correction `PASS: 39 assertions`。

### Integration-only seam notes

- `FS-A-INACTIVE-TELEGRAPH`以外のshared contractは変更しない。Gameplay snapshot／eventをauthority sourceとし、Presentationにはdeep-copied read-only dataだけを渡す。
- Gameplayのactive telegraph shapeは`telegraph_line`／`telegraph_sector`、Presentation shell内部schemaは`line`／`sector`。integration adapterはPresentationへ渡すcopyだけを変換し、Gameplay snapshotを変更しない。
- Gameplay eventは`player_action_accepted`、`player_hit_resolved`、`part_broken`。Presentation shellが消費するevent nameは`ActionStarted`、`HitConfirmed`、`PartBroken`。対応は作業票でexact固定し、hit feedbackは`player_hit_resolved`の`hit == true`だけを対象とする。
- `enemy Integrity`と`boss_hp`の同値性は承認されていない。integration adapterはalias追加、同値化、authority fieldの再定義を行わない。
- Resolved 2026-08-14: user approved Option A。Gameplayが`telegraph.active == false`かつ`shape == ""`を返す場合、integration adapterはPresentation用deep copyの`shape`だけを非表示`line`へ正規化し、`active == false`を保持する。source snapshotは不変。active empty／unknown shapeはfail closed。`OQ-00-20260804-001`をClosedとし、`MFO-WO-FS-A-00-001`を発行した。

### 30 QA preparation candidate review — 2026-08-03

- Decision: `Pass / QA readiness candidate only`。integrated FS-A validationまたはGate結果ではない。
- Source branch: `codex/fast-slice-fs-a-qa-prep`。
- Base: `62f4af4a105b45f458beabecd6595ad5f58ec764`。
- Tested source HEAD: `8c13a0b545fdf4c88bf33ec7be6be6649d7e7443`。
- QA content commit: `02cff48042ef1e3bc1d14d1fc4a119a3b60ca205`。
- Final candidate tip: `04845e7782c19352a716dbea6aea794f1047b675`。
- 以前固定した`8c13a0b545fdf4c88bf33ec7be6be6649d7e7443`はsource range内の先行handoff／tested source HEADであり、現在のfinal candidate tipではない。

Source commits in chronological order:

1. `9531e3d45512a326d2a020e720f35dede3915094` — `test: prepare Fast Slice QA validation package`
2. `df18568e5288b7ef051800d26f12012d7980fc81` — `docs: hand off Fast Slice QA preparation`
3. `3cce4d31264be20323ac4f49ffdec97a5533a402` — `docs: clarify Fast Slice QA preparation evidence`
4. `8c13a0b545fdf4c88bf33ec7be6be6649d7e7443` — `docs: hand off Fast Slice QA evidence correction`
5. `02cff48042ef1e3bc1d14d1fc4a119a3b60ca205` — `test: record FS-A focused QA readiness`
6. `04845e7782c19352a716dbea6aea794f1047b675` — `docs: hand off FS-A focused QA readiness`

Review evidence:

- baseはfinal tipのancestorで、merge commitは`0`。local branch、origin tracking ref、live originはfinal tipとexact一致。
- base-to-tip changed pathはexact `9`で、すべて30 QAのowned paths内。allowlist外、production gameplay／presentation／integration、protected／strict pathの変更はすべてexact `0`。
- `git diff --check 62f4af4a105b45f458beabecd6595ad5f58ec764..04845e7782c19352a716dbea6aea794f1047b675`はexit `0`。
- QA preparation report、QA handoff、KBM checklist、4件のevidence JSONはidentity、commands／results／Not run、scope countと整合し、全JSONをparseできる。
- focused evidenceはtest実行対象を先行tip`8c13a0b...`として正しく記録し、content commitはtest sourceを変更せずreadiness記録だけを追加する。focused scope auditはfocused delta `5`、base-to-final `9`、unexpected `0`、production変更`0`を記録する。
- QA-prep return review時点ではFS-A candidate acceptanceは`0 Pass / 0 Fail / 11 Pending or Not run`だった。QA fixture／legacy regressionのPassをcandidate Passへ昇格していなかった。このhistorical readiness resultは、上記2026-08-14の独立integration review結果で置換しない。
- `enemy Integrity`とcontract field `boss_hp`の同値性は未承認であり、凍結candidate mappingまたは監督判断まで該当validationをPendingに保つ。

Historical action on 2026-08-03: QA source tipだけを固定し、10 Gameplay／20 Presentation到着まではcherry-pickしなかった。2026-08-04に3候補をreview済み順で統合したため、この待機条件は完了済み。

## Candidate review checklist — completed 2026-08-04

各role tipについて次を順に確認し、3候補すべてで完了した。

- [x] returned SHAがcommit objectとして存在し、required baseをancestorに持つ。
- [x] returned branchのlive origin tipと返却identityを照合する。
- [x] `base..tip`の全commitとdiffをreviewし、implementation／handoff commitを記録する。
- [x] `git diff --check base..tip`がexit `0`である。
- [x] changed pathが当該roleのexclusive writable pathsと対応`.uid`だけである。
- [x] `project.godot`、`export_presets.cfg`、legacy scripts／scenes／data／tests、strict evidence、正規文書の差分が`0`である。
- [x] 別roleのowned path、`fs_a_main.tscn`、`fast_slice/integration/**`への先行差分が`0`である。
- [x] 実行済み結果とNot runが分離され、未実行項目をPassとしていない。
- [x] role work order固有acceptanceとreturn項目を確認した。Presentationのsource evidence不足は採用後の独立再実行で補完し、元記録は変更していない。

### Shared seam review

- [x] 10だけがplayer／enemy／part state、action acceptance、hit／damage、telegraph意味、defeat／functional stop／wreck、harvest／result／rematch resetを決定する。
- [x] public snapshotに契約上の最低限fieldがある: `loop_phase`、player Integrity／Deformation、boss HP、parts、telegraph、`boss_functional`、`wreck_active`、harvest points、result／rematch flags。
- [x] `parts`は1〜2件、harvest pointsはexact 3件で、telegraphは色以外でも識別可能な2種類である。
- [x] 20はread-only snapshot／eventだけを消費し、gameplay authorityを変更しない。
- [x] presentation無効時もgameplay結果が同じになるseamを維持する。integration self-checkとfinal validationでauthority結果不変を確認した。
- [x] presentation preview stubはpreview専用で、integrationではpure shellへ置換する境界が明確である。

### `fs_provisional` review

- [x] 具体値を`material-frontier-online/prototype/data/fast_slice/**`へ集中し、`fs_provisional`と明記する。
- [x] 許可カテゴリはHP、damage／Deformation、timing、enemy選択／距離／速度、part-body関係、harvest／表示量／result timingだけである。
- [x] production data、正規仕様、stable balance、Gate証拠へ昇格させない。
- [x] 調整履歴をgameplay handoffへ短く記録する。
- [x] FS-A外mechanicや将来online向け抽象化を追加しない。

具体的な数値は共有契約では定義されておらず、10 candidateのowned dataとしてreviewする。候補数値の調整だけを共有契約変更として扱わない。

## Integration state and remaining order

1. [Completed] 10 Gameplayのreview済み6 commitを統合。
2. [Completed] 20 Presentationのreview済み3 commitを統合。
3. [Completed] 30 QA Prepのreview済み6 commitを統合。
4. [Completed] `FS-A-INACTIVE-TELEGRAPH`をApprovedとして固定し、`MFO-WO-FS-A-00-001`を発行。
5. [Completed] 10がauthorized integration-only pathsだけでchild scenesを接続し、returnをpush。
6. [Completed] 00が3 commit／6 pathをreviewし、fresh import／parse／one-loop／全指定回帰をPass。
7. [Completed] returned final tip `867899c7ccb9380b4bb6e4be5c51da4223532230`をvalidation candidate source SHAとしてfreeze。
8. [Completed / Technical Pass] 30 integrated validation final tip `81c6643b71940ca8bbf1c68d3c9ce47917b9111c`をreviewし、automated technical `13 / 13 Pass`とmanual preparation correctionを受理。
9. [Pending human / retry ready] corrected manual-002でKBM、readability、user feelを実scene確認するまでpromotionを保留。

既定の取り込み方式はreview済みcommitだけの順次cherry-pickとし、source exact SHAとintegration側SHAを両方記録する。role branch全体や未review commitを取り込まない。

## Conflict and shared-file policy

exclusive ownershipにより、role候補間の同一tracked file競合は本来発生しない。競合時は手修正で機能を混ぜず、越境candidateを止めてownerへ返す。

特に注意する境界:

- `docs/FAST_SLICE_CONTRACT.md`、`docs/work-orders/fast-slice/**`: 00だけが変更できる共有authority。
- `docs/handoffs/fast-slice/integration.md`: 00だけが更新する統合記録。
- `scenes/fast_slice/fs_a_main.tscn`、`fast_slice/integration/**`、integration report: work order発行後も10のsingle-owner path。
- `project.godot`、`export_presets.cfg`: read-only。専用sceneをpath指定で起動する。
- `.uid`: 対応source／scene ownerに従う。duplicate UID、他owner sidecar、import生成物の混入を確認する。
- gameplay snapshot／event: 物理的な共有fileではなくcross-role契約面。field欠落やwrite-back依存は該当candidateを止める。

2担当以上が依存する契約変更が本当に必要な場合だけ全体を停止し、対象field、再現／diff、影響roleを00へ報告する。

## Acceptance confirmation procedure

### A. Input freeze and scope evidence

- [x] 10／20／30-prepのsource tip、origin identity、source commit列、changed pathsを保存する。
- [x] 各candidateのowned-path auditと`git diff --check`をPassする。
- [x] 契約／provisional／excluded-systems reviewを完了する。

### B. Integration execution after issuance

- [x] integration worktreeが取り込み直前にcleanで、HEADが記録済みである。
- [x] planned orderでreview済みcommitだけを取り込む。
- [x] 各取り込み後にunexpected pathsとconflict `0`を確認する。
- [x] 10のintegration-only commit後もrole-owned implementation fileを再編集していない。candidate-owned path差分`0`を確認した。

### C. Technical smoke

- [x] Godot identityが`4.7.stable.official.5b4e0cb0f`である。
- [x] foundation各stageのfresh headless editor import／parseがexit `0`である。
- [x] QA-prepのcandidate-independent runnerを準備fixtureとして実行し、candidate validationを主張していない。
- [x] Gameplay candidateのexact self-check commandでone-loop／rematch smokeを実行した。
- [x] `res://scenes/fast_slice/fs_a_main.tscn`を明示pathでheadless launchし、exit `0`。
- [x] integrated one-loop、result、rematch reset、二周目主要操作をself-checkした。
- [x] Presentation無効時のGameplay authority結果不変を確認した。
- [x] final-validation QA runnerは拡張せず、既存self-check／runnerでrequired automation `17 / 17`とtechnical acceptance `13 / 13`をPassした。
- [x] foundation smokeはfresh temporary copyで行い、各stage後のintegration worktreeがcleanであることを確認した。

以下はwork order発行時に準備したhistorical smoke template。今回のexact実行記録は上記2026-08-14 review節とintegration return reportを正とする。

```powershell
$FsAGodot = 'C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe'
$FsAProject = 'C:\tmp\mf-fs-a-int\material-frontier-online\prototype'
& $FsAGodot --version
& $FsAGodot --headless --editor --path $FsAProject --quit
& $FsAGodot --headless --path $FsAProject --script res://tests/fast_slice/run_fs_a_contract_skeleton.gd
& $FsAGodot --headless --path $FsAProject --scene res://scenes/fast_slice/fs_a_main.tscn --quit-after 120
& $FsAGodot --headless --path $FsAProject --script res://tests/run_phase1_tests.gd
```

最後のPhase 1 runnerはread-only dependencyのguardrailであり、FS-A one-loop acceptanceの代替にしない。

### D. Freeze and handoff

integration-only return後、00がreview、fresh smoke、candidate source freezeを完了し、ユーザーの継続指示に基づいて`MFO-WO-FS-A-30-002`を発行した。30 Return final tip `81c6643b71940ca8bbf1c68d3c9ce47917b9111c`は00の独立scope／evidence／acceptance reviewをPassし、technical resultとmanual preparation correctionを受理した。manual KBM／readability／user feelだけを後続human boundaryとして残す。

- [x] source tips、integration commit列、final HEAD、commands、exit codes、Not runを統合report／handoffへ記録する。
- [x] FS-A技術acceptance 13項目のPass／Fail／Blocked／Not runを個別に記録する。
- [x] Passしたreturned final tip `867899c7ccb9380b4bb6e4be5c51da4223532230`をvalidation candidate source SHAとしてfreezeする。
- [x] validation source identityをcandidate `867899c7ccb9380b4bb6e4be5c51da4223532230`、review parent `d79b542ec42f34306a0370b07752e732dcf0c7fc`、本issuance commitの3層へ分離して固定する。
- [x] issuance commit `3cdf6dbd9031e3d05fd2a049c851f19409d7b592`からvalidation branch／worktreeを作成し、local／tracking／live originのexact identityとclean状態を記録する。
- [x] QA final tip `81c6643b71940ca8bbf1c68d3c9ce47917b9111c`の6 commit／62 path／evidenceをreviewし、technical `13 / 13 Pass`とmanual preparation correctionを受理する。
- [x] manual sessionのexact fresh reconstruction、entry scene、controls、記録境界をQA checklistへ固定して後続human確認へ渡す。
- [ ] userまたは委任playtesterの操作感／読みやすさ評価はtechnical smokeと分けて後続QAへ渡す。
