# MFO-WO-FS-A-10-003 — FS-A Safe Opening Spawn and Q Defeat Retry

- Status: Issued / Active
- Owner: 10ゲームプレイ・コア実装
- Contract foundation: `cdd54cf0fb1dfb84b857db11e69bab622018d629`
- Starting ref: this work orderを含むintegration issuance tip。00が通知するexact SHAとbranch初期HEADを一致させる
- Branch: `codex/fast-slice-fs-a-gameplay-opening-retry`
- Worktree: `C:\tmp\mf-fs-a-10-opening-retry`
- Integration target: `codex/fast-slice-fs-a-integration`
- Accepted Gameplay Return: `817f45a02ed44492084c3f7b864125451eb365b1`
- Integrated Gameplay source mapping: `9f77a02a7965ff1efcb4b7175ae30d9c1a515bf4`
- Frozen combined candidate: `f03a43d2339e9772a15db1c591a31f5e4f92cca2`
- Accepted QA final: `e261392dd0944d09d0ac6f3a6fef9b0346795c10`
- Starting prototype tree: `2a66e4c06308a47678e8888a739b87ffd33d1ee8`
- Contract: `docs/FAST_SLICE_CONTRACT.md`
- Milestone: `FS-A branch-local rework`
- Report path: `material-frontier-online/implementation/fast-slice/gameplay/fs-a-opening-safety-q-retry.md`

既存Gameplay branch／worktree `codex/fast-slice-fs-a-gameplay`／`C:\tmp\mf-fs-a-10`と、accepted rework branch／worktree `codex/fast-slice-fs-a-gameplay-rework`／`C:\tmp\mf-fs-a-10-rework`はfreezeを維持する。新branchは00がissuance tipから作成する。reset、rebase、amend、merge、既存candidate履歴のrewriteは禁止する。

Accepted Gameplay Return `817f45a...`はnew branchのdirect ancestor identityとしてではなく、integrationに採用済みのsource identityとして扱う。candidateのcommit ancestryはintegration issuance tip→本票final tipとし、source identity mappingとcommit ancestryを混同しない。

## Start conditions

10は次をすべて確認してから編集を開始する。

- 00がcontract foundation、integration issuance tip、新branchをoriginへpush済みである。
- local HEAD、tracking ref、live originが00通知のexact issuance SHAと一致する。
- Contract foundation `cdd54cf0fb1dfb84b857db11e69bab622018d629`がHEADのancestorである。
- `C:\tmp\mf-fs-a-10-opening-retry`がcleanで、既存Gameplay worktree 2件も各frozen tipでcleanである。
- issuance tipのprototype treeが`2a66e4c06308a47678e8888a739b87ffd33d1ee8`である。
- issuance tipの開始blobが次のexact identityである。
  - tuning: `db4de953b6067afb8dfa5bb563925759d1728ae8`
  - input adapter: `27dba8de6095af346c99438bfc08c123d2469ee6`
  - gameplay loop: `cba294285acff4ae6e23c0eefa26a2ce5d405064`
  - gameplay arena: `34caf62ccfe6916e9ac1b99ea91538c9a22dd5c7`
  - gameplay self-check: `94a1b81e5b6a1c121536b1321fdbdc8550ac7939`
- reset、rebase、amend、mergeを行わない。

不一致があれば編集を開始せず、actual branch／HEAD／tracking／live origin／ancestor／tree／blob／status evidenceを00へReturnする。分類は`Blocked / setup identity`とし、既存candidate defectへ帰属しない。

## Authority and objective

Userは2026-08-15に、00が提示した次の推奨2案へexact `OKです`で承認した。

1. `OQ-00-20260815-003` Option A: FS-A `fs_provisional`の`player_start_position`だけを`Vector2(520, 540)`から`Vector2(200, 540)`へ変更する。
2. `OQ-005` Option A／`OD-021-INPUT`: player defeat latch成立中だけ、既存abstract `lock_on`のfresh press（KBM `Q`／gamepad `LB`）でsame-arena authority retryを受理する。

本票はこの2点だけをGameplay owner範囲で実装し、self-checkとfresh validationで閉じる。target-selection lock-on、production retry UI、strict Slice 2-C、baseline promotion、Gate actionは開かない。

## Exact writable paths

Tracked変更は次のexact 7 pathsだけを許可する。

1. `material-frontier-online/prototype/data/fast_slice/fs_a_provisional_tuning.tres`
2. `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_input_adapter.gd`
3. `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_loop.gd`
4. `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_arena.gd`
5. `material-frontier-online/prototype/scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd`
6. `material-frontier-online/implementation/fast-slice/gameplay/fs-a-opening-safety-q-retry.md` — new report
7. `docs/handoffs/fast-slice/gameplay.md` — historical内容を保持してEOF append only

`.uid`変更は不要かつ禁止する。原因が上記5 production paths以外にある場合はscopeを拡張せず、再現証拠と必要pathを00へReturnする。

## Required implementation — safe opening

- `fs_a_provisional_tuning.tres`では`player_start_position = Vector2(520, 540)`を`Vector2(200, 540)`へexact 1値だけ変更する。
- `player_start_aim = Vector2(1, 0)`、boss／part／harvest位置、movement bounds、line／sector geometry・timing・damage、enemy selection／cooldown、HP、reward、全その他provisional値を変更しない。
- initial configure、accepted player retry、result後のexisting rematchはすべて同じconfigured start `(200, 540)`を使用する。
- grace、invulnerability、attack suppression、enemy delay、新stateを追加しない。enemy telegraph／attack schedulingは従来どおり開始する。
- new startはFS-A branch-local provisional値であり、stable production値、strict Gate証拠、MASTER_SPECの座標へ昇格させない。

## Required implementation — defeated Q retry

- `fs_a_input_adapter.gd`は既存`Phase1InputAdapter.ACTION_LOCK_ON`を使い、`Input.is_action_just_pressed(ACTION_LOCK_ON)`のfresh edgeだけをGameplay retry requestとしてcaptureする。InputMap、`project.godot`、Phase 1 input adapterを変更しない。
- retryを評価できるのはcommand開始時点ですでに`player_integrity == 0`かつprivate authority defeat latch成立中の場合だけとする。
- alive開始commandで同frame内にfatal hitがdefeat latchを成立させても、そのcommandでcapture済みのQ／LB edgeをretryへ使わず、次commandへ繰り越さない。held／release／neutral／retained aimはretryにしない。
- `fs_a_gameplay_loop.gd`はconfigured＋defeat latch＋Integrity 0でguardしたGameplay-only retry requestを受理し、既存round reset semanticsでretry-owned configured round stateを初期化する。
- retryはcurrent `round_index`／rematch counterを保持して増減させず、existing rematch eventを生成しない。新しいretry event／signal／counterを追加しない。
- `fs_a_gameplay_arena.gd`はexisting defeated no-op returnより前にretryを判定する。`step_authority_command()`へseamを追加する場合は既存Integrationの4-arg callを壊さないtrailing default `false`または同等のbackward-compatible Gameplay-only形にする。
- accepted retry commandではloop reset後にplayer actorをconfigured position／initial aimへ戻し、velocity、evade state／reuse、action stateを初期化し、authority nodesをsyncしてexisting snapshotをexact 1回emitし、そのcommandを即returnする。
- accepted trigger command上のmove、aim update、evade、`physical_light`、`physical_heavy`、interactは全消費する。configured initial aimが同commandのaimより優先し、motion／action／hit／harvest／rematchを発生させない。
- step resultの既存key／意味を変更せず、新しい`retry_reset`等のpublic result keyを追加しない。
- alive Qはtarget-selection lock-onを開始せず、retry logicで他のvalid inputを消費しない。defeat中の`E`はno-op、wreck harvest／result rematchの`E`は従来どおりとする。Qはresult rematchに使わない。
- accepted retry完了後は次の新しいcommandから通常受付へ戻る。新phase、snapshot field、Gameplay event、signal、UI、auto retryを追加しない。

## Full reset acceptance

accepted Q retry後に少なくとも次を確認する。

- player Integrity=max、Deformation=`0`、actor／snapshot position=`(200, 540)`、aim=`(1, 0)`、velocity=`0`、evade inactive／reuse=`0`、action idle、pending player queryなし。
- `loop_phase == combat`、boss HP=max／functional、parts=max／intact、enemy initial cooldown、active telegraphなし、pending enemy hitなし。
- wreck／resultは非active、exact 3 harvestはuncollected、reward=`0`、runtime wreck／harvest node count=`0`。
- current `round_index`／rematch counterはretry前とexact同値で、rematch event／retry eventは生成されない。
- existing snapshot schemaとevent payloadに追加・変更がない。

## Opening and traversal acceptance

- initial actor／snapshotはexact `(200, 540)`、aim `(1, 0)`でauthority／Presentation同一座標を維持する。
- boss `(1350, 540)`からnew startまでの距離はexact `1150`で、current line range `980`、sector range `520`の双方より大きい。
- stationary initial stateでfirst scheduled line telegraph／attackは通常どおり進行するがmissし、Integrity／Deformationは変化しない。続くsector shapeもnew startではrange外であることをdeterministic self-checkする。
- initial spawnのlight／heavyは従来どおり射程外missし、boss／part HPを変えない。
- player transformの直接write、`reset_authority_state()`、`set_player_spatial_state()`を使わず、existing move／evade commandだけでpart射程へ接近する。
- start→part距離は`1065`、既存thresholdまで必要な移動は約`843`。bounded `180` command以内で接近し、actor／snapshot parity、part-first light／heavy hitとrecoveryを確認する。
- result rematchとQ retryの双方がconfigured `(200, 540)`へ戻る。

## Retry edge and regression acceptance

- defeated commandでQなしの場合は従来どおり全authority stateがfreezeする。
- defeated stateのfresh Q＋move＋noninitial aim＋evade＋light＋heavy＋E composite commandがresetをexact 1回だけ行い、co-inputを全消費する。
- alive Qはotherwise-valid movement／actionを消費せず、target-selection behaviorを追加しない。
- Qをalive中からheldしたままpositive→0へ到達してもauto retryせず、release後のnew fresh pressだけがretryする。
- fatal command上のQ edgeを再利用しない。release／neutral／aim-only／Eではretryしない。
- retry後にmove／evade／light／heavyとenemy schedulingが再開する。
- round twoでもretryがcurrent round／rematch countを保持し、再度defeat後のfresh edgeでexact 1回retryできる。
- existing boss defeat、wreck exact 1、harvest exact 3、result、E rematch、round-two loopを変更せずPassする。
- physical gamepad `LB`はbinding／static evidenceだけを確認し、manual Passへ昇格しない。

## Forbidden scope

上記7 paths以外はread-only。特に次を変更しない。

- `fast_slice/presentation/**`、`fast_slice/integration/**`、`tests/fast_slice/**`
- `material-frontier-online/prototype/scripts/input/**`、Phase 1 `InputCommand`、player actor、`fs_a_player_action.gd`
- `project.godot`、Input Map、autoload、scene、`.uid`、asset、export設定
- player start以外の`fs_provisional`値、line／sector geometry・timing・damage、boss／part／harvest／reward、target selection
- snapshot schema、Gameplay／Domain event、signal、phase、public UI、retry screen、auto retry、checkpoint
- `E` semantics、result rematch semantics、round increment semantics、target-selection lock-on
- `FAST_SLICE_CONTRACT.md`、`MASTER_SPEC.md`、`DECISIONS.md`、`OPEN_QUESTIONS.md`、`MILESTONES.md`、work order、integration／Presentation／QA handoff
- networking、server、account、persistence、audio、production art、generic future framework

`OQ-001`のproduction `ActorDefeated` payloadと`OQ-004` production hit presentationはOpenのまま。本票で解決・拡張しない。共有契約の追加変更が本当に必要な場合だけ該当実装を停止して00へ返し、無関係な票内検証は続行する。

## Required self-check anchors

`fs_a_gameplay_self_check.gd`へ少なくとも次のdeterministic anchorsを追加する。

1. configured `(200, 540)` safe spawn、actor／snapshot／aim parity
2. stationary first line cycle miss、sector range外、Integrity／Deformation不変
3. spawn light／heavy missとbounded no-teleport traversal／hit regression
4. Q／LB既存bindingとE binding不変、duplicate InputMap action／eventなし
5. defeated Qなしfreeze、fresh Q composite consume＋full reset exact once
6. command-start latch、alive-held-through-fatal、release／fresh-edge behavior
7. alive Q、neutral、release、aim-only、E negative cases
8. current round／rematch counter保持、rematch／retry eventなし
9. post-retry action／enemy schedule、second defeat／fresh retry
10. boss defeat／wreck／3 harvest／result／E rematch／round-two regression

Integration deterministic self-checkのexisting 4-arg authority seamへQ injectionを追加しない。Q retry qualificationはGameplay self-checkと後続real integrated manual QAで閉じ、Integration self-checkはunchanged seam regressionとして扱う。

## Required fresh validation

implementation-only tipのexact `git archive`からunique fresh stageを作り、少なくとも次を順に実行する。

1. Godot `4.7.stable.official.5b4e0cb0f` identity、archive bytes／SHA、pre-import `.godot=false`
2. fresh editor import、global class cache確認
3. modified 4 GDScriptとunchanged Integration root／self-checkのparse
4. Gameplay self-checkとGameplay arena scene launch
5. opening miss、bounded no-teleport、fresh-edge、same-command consume、full reset、round preservation anchors
6. Integration self-check（既存expected warning exact `4`）と`fs_a_main.tscn` smoke
7. Presentation spatial self-check、pure shell、preview（invalid-spatial expected warning exact `20`）
8. candidate-independent QA skeletonをfixture-onlyとして実行
9. project main、Phase 1、Slice 2-A `120`、correction `39`
10. no-teleport forbidden API、InputMap Q／E idempotence、unexpected ERROR／SCRIPT ERROR／terminal FAIL=`0`
11. issuance→implementation／final exact 7-path audit、Forbidden=`0`、`git diff --check` exit `0`
12. final prototype tree／5 production blobsがtested implementation tipとexact一致

temporary stage／archiveはexact path、bytes、SHA、pre／post import stateをreportへ記録し、結果確認後にexact cleanupする。最初の非qualifying wrapper／orchestration stopがあればunderlying candidate resultと分離してdurable記録し、受入条件を緩和しない。

manual KBM Q fresh-edge、opening feel、integrated readability、physical gamepad、performance／P95／maximum load／long-run、exportは本票でPass主張しない。physical gamepadとperformanceは`Not run / Deferred`、optional exportは`Not run`としてReturnし、別QA票へ渡す。

## Commit, validation, and Return order

1. exact 5 production pathsだけのimplementation-only commitを作る。
2. そのexact implementation tipの`git archive`からfresh validationを実行する。
3. validation結果とsource identity mappingをnew report pathだけのreport commitへ記録する。
4. `docs/handoffs/fast-slice/gameplay.md`だけのEOF append handoff commitを作る。
5. final tipの5 production blob／prototype treeがtested implementation tipとexact一致し、後続2 commitsがdocs-onlyであることを確認する。
6. 全commitをpushし、local HEAD、tracking ref、live originの同一SHAとworktree cleanを確認する。

Commit列はlinear exact 3、merge `0`とする。reset／rebase／amend／mergeを行わない。integrationへ自動mergeしない。

## Return requirements

Returnには少なくとも次を含める。

- Result、branch／worktree、contract foundation、issuance tip、frozen candidate／accepted source identity、local／tracking／live origin、clean state
- issuance→finalの3 commitsを時系列順、parent chain、merge count `0`
- exact 7 changed paths、Forbidden／prototype以外のunexpected path `0`
- start blob→implementation blob mapping、tested implementation tip、final 5 blob／prototype tree一致
- safe spawn geometry、first line／sector miss、no-teleport traversal
- fresh／held／release／fatal-edge／same-command consumption、full reset、round／rematch preservation、no-event結果
- archive／stage identity、Godot commands、numeric exits、anchors、expected／unexpected warnings、cleanup
- Not run／Deferred、open OQ境界、shared-contract追加変更の要否

00はReturnを独立scope／semantic／evidence reviewし、review済み3 commitsだけをimplementation→report→handoff順でintegrationへ取り込む。fresh combined smoke後に新candidateをfreezeし、別QA票でautomationとmanual opening／Q retry／remaining rows／readability／feelを検証する。promotion／Gate actionはそのQA Return reviewまで`0`とする。
