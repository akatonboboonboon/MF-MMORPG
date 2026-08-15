# MFO-WO-FS-A-10-002 — FS-A Gameplay Defeat and No-Teleport Combat Closure

- Status: Issued / Active
- Owner: 10ゲームプレイ・コア実装
- Contract foundation: `bf89fcd26cde65659e7addc97952fb9f9fc1dc58`
- Starting ref: this work orderを含むintegration issuance tip。00が通知するexact SHAとbranch初期HEADを一致させる
- Branch: `codex/fast-slice-fs-a-gameplay-rework`
- Worktree: `C:\tmp\mf-fs-a-10-rework`
- Integration target: `codex/fast-slice-fs-a-integration`
- Frozen Gameplay source: `17773c5f186dfbbd1a1e52a304df123b76d9ad35`
- Previous implementation tip: `611f34b4e1df342ff24b8e420f26d36700c39c4a`
- Frozen integrated candidate: `867899c7ccb9380b4bb6e4be5c51da4223532230`
- Contract: `docs/FAST_SLICE_CONTRACT.md`
- Milestone: `FS-A rework`
- Report path: `material-frontier-online/implementation/fast-slice/gameplay/fs-a-gameplay-defeat-traversal-rework.md`

既存branch `codex/fast-slice-fs-a-gameplay`とworktree `C:\tmp\mf-fs-a-10`はfreezeを維持する。新branchは00がintegration issuance tipから作成する。reset、rebase、amend、既存candidate履歴のrewriteは禁止する。

Frozen Gameplay source `17773c5f186dfbbd1a1e52a304df123b76d9ad35`はnew branchのcommit ancestorではなく、採用済みsource identityである。candidateのcommit ancestryはintegration issuance tip→rework final tipとする。開始時にissuance tipのGameplay-owned source blobがfrozen sourceとexact一致することを確認し、source identity mappingとcandidate ancestryを混同しない。

## Start conditions

10は次をすべて確認してから編集を開始する。

- 00がintegration issuance tipとnew branchをoriginへpush済みである。
- local HEAD、tracking ref、live originが00通知のexact issuance SHAと一致する。
- Contract foundation `bf89fcd26cde65659e7addc97952fb9f9fc1dc58`がHEADのancestorである。
- `C:\tmp\mf-fs-a-10-rework`がcleanで、既存Gameplay branch／worktreeに差分がない。
- issuance tipの3 writable source blobがfrozen Gameplay source `17773c5...`の同path blobとexact一致する。
- reset、rebase、amendを行わない。

不一致があれば編集を開始せず、actual SHA／blob／path evidenceを00へ返す。

## Authority and objective

Userは2026-08-15に`OQ-00-20260815-002`をOption AでApprovedした。本票は次の2点だけを閉じる。

1. `player_integrity`のpositive→0をexact onceでlatchし、authority resetまでApproved停止scopeを維持する。
2. 直接teleportを使わず、既存authority command経路でspawnから接近し、射程外missと射程内light／heavy hitが成立することをself-checkで固定する。

manual-002のattack-reach観察から新しいGameplay hit-query defectを推測しない。既存target選択、reach、radius、timing、damage、`fs_provisional`値を変更せず、coverageでauthority経路を閉じる。

## Exact writable paths

Tracked変更は次のexact 5 pathsだけを許可する。

1. `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_loop.gd`
2. `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_arena.gd`
3. `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd`
4. `material-frontier-online/implementation/fast-slice/gameplay/fs-a-gameplay-defeat-traversal-rework.md`
5. `docs/handoffs/fast-slice/gameplay.md` — historical内容を保持してappend

`.uid`変更は不要かつ禁止する。原因が上記3 source以外にある場合はscopeを拡張せず、再現証拠と必要pathを00へReturnする。

## Required implementation

- `player_integrity`のpositive→0をprivate authority stateでexact once latchする。
- latch時にactive evadeとvelocityを停止し、player actionをcancelしてpending action／pending hit queryを破棄する。位置はlatch時点で保持し、spawnへteleportしない。
- latch後はauthority resetまでmove／evade／action／player hit queryを受理せず、繰り返しcommandをno-opにする。
- latch時にenemyをstoppedへ移し、active telegraph、attack id、pending enemy hitを破棄する。以後enemy AI／telegraph／attack scheduling／hitを進行または再生成しない。
- defeat後に追加のIntegrity／Deformation変化、enemy attack event、player action event、hit確定を発生させない。
- player defeatでは`loop_phase == combat`を維持し、boss HP、`boss_functional`、parts、wreck、harvest、resultを変更しない。boss HP 0経路と混同しない。
- existing configure／round resetはprivate latchとstopped stateを初期化する。ただしplayer-defeat retry入力／経路は実装しない。
- 新phase、snapshot field、event、UI、retry binding、自動retryを追加しない。`E` harvest／rematchをdefeat retryへ流用しない。

## No-teleport traversal and hit coverage

`fs_a_gameplay_self_check.gd`へ、scene ready後の区間でplayer transformの直接write、`reset_authority_state()`、`set_player_spatial_state()`を使わないdeterministic checkを追加する。

- initial spawnからlight／heavyが射程外missし、boss／part HPが変化しない。
- `step_authority_command()`と既存move／evade commandだけでauthority playerを接近させる。
- 移動中、snapshot `player_position`とauthority actorのworld positionが一致する。
- 射程内でlightとheavyを別々に完走し、既存target規則、damage、HP変化、eventを確認する。
- no-teleport区間の禁止API使用をself-check構造とreportへ明記する。

## Defeat acceptance

- fatal hit直前はIntegrity positive、直後はexact `0`、defeat latch countはexact `1`。
- fatal hit時にactive evade／velocity／pending player action／queryが停止する。
- defeat後のmove／evade／light／heavy反復でplayer位置、boss HP、part HP、Gameplay event countが変化しない。
- enemy counter、telegraph、pending hit、player Integrity／Deformationがdefeat後に変化しない。
- bossはfunctional、partsは既存値、wreck／harvest／resultは未生成のまま。
- existing boss-defeat one-loop、wreck、exact 3 harvest、result、rematch reset、round-two actionは従来どおりPassする。

## Forbidden scope

上記5 paths以外はread-only。特に次を変更しない。

- `fast_slice/presentation/**`、`fast_slice/integration/**`、`tests/fast_slice/**`
- `fs_a_player_action.gd`、`fs_a_input_adapter.gd`、全scene／`.uid`、`data/fast_slice/**`
- legacy input／simulation／combat／phase1、`project.godot`、Input Map、autoload、export設定
- `FAST_SLICE_CONTRACT.md`、`OPEN_QUESTIONS.md`、`DECISIONS.md`、work order、integration／Presentation／QA handoff
- `fs_provisional` label／値／意味、hit geometry、damage、target selection
- networking、server、account、persistence、audio、production art、汎用framework

共有契約の追加変更が必要な場合だけ該当実装を停止して00へ返す。無関係な票内検証は継続する。

## Required validation

implementation-only tipの`git archive`からfresh stageを作り、少なくとも次を実行する。

1. Godot `4.7.stable.official.5b4e0cb0f` identity
2. fresh editor import
3. `fs_a_gameplay_loop.gd`、`fs_a_gameplay_arena.gd`、`fs_a_gameplay_self_check.gd` parse
4. Gameplay self-checkとGameplay scene launch
5. no-teleport traversal／miss／light／heavy hit check
6. player defeat exact-once／player stop／enemy stop／state preservation check
7. existing integration self-checkと`fs_a_main.tscn` smoke
8. Presentation pure shell smokeとcandidate-independent QA fixture
9. project main smoke、Phase 1、Slice 2-A `120`、correction `39`
10. `git diff --check`、issuance tip..HEAD exact 5-path scope audit、Forbidden差分`0`

temporary stage／archiveはexact pathとhashをreportへ記録し、結果確認後にexact cleanupする。manual KBM、Presentation spatial parity、integrated user feel、gamepad、performance、exportはPass主張せず`Not run`／`Deferred`として返す。

## Commit, validation, and Return order

1. exact 3 source pathsだけのimplementation-only commitを作る。
2. そのexact implementation tipの`git archive`からfresh validationを実行する。
3. validation結果とsource identity mappingを新規report pathだけのreport commitへ記録する。
4. `docs/handoffs/fast-slice/gameplay.md`だけのhandoff commitを作る。
5. final tipの3 source blob／prototype treeがtested implementation tipとexact一致し、後続2 commitsがdocs-onlyであることを確認する。
6. 全commitをpushし、local HEAD、tracking ref、live originの同一SHAとworktree cleanを確認する。

Returnにはissuance tipからfinal tipまでの全commitを時系列順に列挙し、frozen source identity→issuance blob一致、issuance→candidate commit ancestry、implementation tip、report tip、final tip、exact changed paths、commands、exit codes、anchors、warnings、Not runを含める。integrationへ自動mergeせず、00が10→20順でreview／cherry-pickする。
