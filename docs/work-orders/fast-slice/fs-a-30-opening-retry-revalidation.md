# MFO-WO-FS-A-30-005 — FS-A Safe Opening and Q Retry Integrated Revalidation

- Status: `Issued / Active`
- Issued: `2026-08-16`
- User authority: 2026-08-16 exact `OKです`
- Issuer: `00統括（監督）`
- Assignee / QA-path single writer: `30 QA・性能・レビュー`
- Branch: `codex/fast-slice-fs-a-opening-retry-revalidation`
- Worktree: `C:\tmp\mf-fs-a-opening-retry-reval`
- Milestone: `FS-A`
- Authority: `docs/FAST_SLICE_CONTRACT.md`、Approved `OQ-005`／`OD-021-INPUT`、Approved `OQ-00-20260815-003`、本work order
- Frozen integrated candidate: `fab8df39900ef650b5c94cc6e4118e230de73103`
- 00 integration review record: `e9eb37a6b7dd47e3ddbf3f1dfebf61faf113abdc`
- Integrated implementation: `8777f6771db8db889050d66cc00fb140ab0fe677`（source `c3b8beac232c932af3aa91d1539671203ccea0ab`）
- Frozen prototype tree: `9e4a082de758ee64d925dc72c5382cb7dbf6c88a`
- Prior accepted QA final: `e261392dd0944d09d0ac6f3a6fef9b0346795c10`（read-only non-ancestor sibling）
- Branch start: 00が通知する本票issuance tip
- Authorized scope: fresh automated／technical revalidation、actual `fs_a_main.tscn`でのKBM manual、new QA report／checklist／evidence、QA handoff EOF append
- Forbidden scope: candidate／test／contract／old evidence変更、repair、promotion、baseline merge、Gate action
- Report: `docs/test-reports/fast-slice/fs-a-opening-retry-revalidation.md`
- Checklist: `docs/test-reports/fast-slice/fs-a-opening-retry-kbm-checklist.md`
- Evidence root: `docs/test-reports/evidence/fast-slice/fs-a-opening-retry-revalidation/`
- Handoff: `docs/handoffs/fast-slice/qa.md` EOF append-only

## Objective and result boundary

Integrated candidate `fab8df39900ef650b5c94cc6e4118e230de73103`について、safe opening spawnとdefeat中Q retryを含むcurrent Contract Section 10をfresh archiveから再検証する。automation `23 / 23`、technical mapping `20 / 20`、KBM manual canonical `21 / 21`とsupplemental safe-opening／retry seamを別ledgerで判定し、current readability／feelをuserまたは委任playtesterから取得する。

本票はcandidateを修正しない。QAはrecommendationまでを返し、integration、`prototype/fast-vertical-slice`、baseline、mainへのmerge／push、`MILESTONES.md`更新、promotion、Gate actionを行わない。FS-A結果をGate 2、Gate Playability、Gate 8、production balance／art／VFX acceptanceへ昇格しない。

## Issue condition

00は発行前に次を確認した。

- Gameplay source final `480e01342dccca845d52ade968f81854820e1ce8`はscope／semantic／evidenceの独立3 reviewをPassし、blocking／actionable finding `0`。
- source commits `c3b8bea...`→`d40aa97...`→`480e013...`はintegration commits `8777f67...`→`b81a7f7...`→`fab8df3...`へ順次cherry-pickされ、stable patch-id `3 / 3`一致、merge `0`、exact 7 paths、conflict `0`。
- candidate `fab8df3...`のprototype treeは`9e4a082de758ee64d925dc72c5382cb7dbf6c88a`で、tested source implementationと5 production blob／prototype treeが一致する。
- 00 fresh combined validationはexact prototype archiveから`23 / 23` numeric exit `0`、Gameplay `533` PASS／anchors `15 / 15`、Integration expected warning `4`、Presentation expected warning `20`、other warning／ERROR／SCRIPT ERROR／terminal FAIL `0`。
- 初回post-matrix identity wrapperのexit `92`は`--no-filters`と誤pathによるQA wrapper false negative。Godot再実行なしのpath-aware corrected readback exact 1回でtracked prototype blob／filtered size `97 / 97`、missing／mismatch `0`となり、stage／tarは00がexact cleanupした。
- integration review record `e9eb37a...`はlocal HEAD／tracking ref／live origin一致、clean、prototype tree不変でpush済み。
- 新branch／tracking ref／live origin、worktree、work order／report／checklist／evidence path、planned stage／tar pathはpreflight時に不存在だった。

## Start identity and topology

30は00のexact issuance packetを受領後、次を満たしてから開始する。

1. worktreeが`C:\tmp\mf-fs-a-opening-retry-reval`、branchが`codex/fast-slice-fs-a-opening-retry-revalidation`である。
2. local HEAD、tracking ref、live originが00通知のQA issuance SHAとexact一致する。
3. worktree／index／untrackedがcleanである。
4. candidate `fab8df3...`、00 review record `e9eb37a...`がHEADのancestorである。
5. prior QA final `e261392...`と00が後で通知するintegration setup recordはcommit objectとして存在するが、QA ancestry外のadministrative siblingでよい。
6. candidate、review record、issuanceのprototype treeがすべて`9e4a082de758ee64d925dc72c5382cb7dbf6c88a`と一致する。
7. candidate→review→issuanceは00-owned docsだけで、candidate→issuance prototype／test delta `0`、range diff-check exit `0`。
8. new report、checklist、evidence rootは開始時に不存在する。
9. reset、rebase、amend、merge、force pushを行わず、issuance→finalの直線commit列を保持する。

不一致時は推測で修復せず`Blocked / setup identity`として00へ返す。

## Historical evidence boundary

Prior QA `e261392dd0944d09d0ac6f3a6fef9b0346795c10`はread-only historical referenceであり、本票のPassへ流用・上書きしない。

- previous manual rows `3–20`: `10 Pass / 0 Fail / 0 Blocked / 8 Not run`
- previous combined 21 rows: `13 Pass / 0 Fail / 0 Blocked / 8 Not run`
- previous Pass: rows `1–10`、`14`、`15`、`21`
- previous Not run: rows `11–13`、`16–20`
- candidate defect: `0`
- negative playability findings: opening直後の攻撃圧、defeat後reset手段不足
- prior evidence manifest Git blob at `e261392...`: `27138` bytes／SHA-256 `e3dc000d0965952e2713e8f240cbdc7ea1580edc36f1e1692a7f4102eee3095f`

30はpreflightでprior report、checklist、manual results、evidence manifest、QA handoffのexact commit path／Git blob／bytes／SHA-256を`accepted-manual-closure-reference.json`へ固定する。old evidenceをcopy、rewrite、normalize、deleteしない。previous Pass rowsもcurrent candidateのmanual Passへ自動継承しない。

## Exact writable paths

30が作成または編集できるのは次の4範囲だけ。

- `docs/test-reports/fast-slice/fs-a-opening-retry-revalidation.md`
- `docs/test-reports/fast-slice/fs-a-opening-retry-kbm-checklist.md`
- `docs/test-reports/evidence/fast-slice/fs-a-opening-retry-revalidation/**`
- `docs/handoffs/fast-slice/qa.md` — existing bytesをpreserveしEOF append-only

## Read-only and forbidden paths

- `material-frontier-online/prototype/**`全体。scripts、data、scenes、tests、project.godot、Input Map、autoload、`.uid`を含む。
- `material-frontier-online/implementation/**`、10／20／integration handoff。
- `docs/FAST_SLICE_CONTRACT.md`、`docs/MASTER_SPEC.md`、`docs/DECISIONS.md`、`docs/OPEN_QUESTIONS.md`、`docs/MILESTONES.md`、全work order。
- prior QA report／checklist／evidence／handoff content。
- `fs_provisional`、production／strict-line、network／server／account／persistence、art／audio、binary／LFS path。

30はtestを通すためにgame値、fixture、runner、evidenceを修正しない。candidate findingはそのまま記録して返す。

## Fresh automated setup

最初のqualifying automated attemptは次のunique pathを使う。

- Stage root: `C:\tmp\mf-fs-a-30-005-auto-20260816-001`
- Archive: `C:\tmp\mf-fs-a-30-005-auto-20260816-001.tar`
- Project: `C:\tmp\mf-fs-a-30-005-auto-20260816-001\material-frontier-online\prototype`

作成前にstage／tar双方が不存在であることを確認する。どちらかが存在する場合は上書き／再利用／silent cleanupせず、preparation issueとして記録して次のunique suffixを使う。

prototype-only archiveは`git archive --format=tar --output=<archive> <issuance> -- material-frontier-online/prototype`でexact 1回作成し、archive bytes／SHA-256／embedded commit、prototype payload count・size・hash、pre-import `.git=false`／`.godot=false`、Godot executable identity、candidate→issuance prototype delta `0`を保存する。editor importはexact 1回、global class cache存在を確認する。
tracked prototype expected payloadはexact `97` files。working-tree materializationのidentityは必ず`git hash-object --path=<repo-relative> -- <stage-file>`で比較し、correct tuning path `material-frontier-online/prototype/data/fast_slice/fs_a_provisional_tuning.tres`を使う。raw `--no-filters` blob比較をqualifying identityにしない。

## Required automated order — exact 23

同一fresh projectで次を順に実行し、command、stdout、stderr、numeric exitを保存する。

1. Godot `--version`
2. `--headless --editor --path <fresh> --quit`
3. `fs_a_input_adapter.gd` parse
4. `fs_a_gameplay_loop.gd` parse
5. `fs_a_gameplay_arena.gd` parse
6. `fs_a_gameplay_self_check.gd` parse
7. unchanged Integration root parse
8. unchanged Integration self-check parse
9. Presentation shell parse
10. Presentation preview parse
11. Presentation stub parse
12. Gameplay self-check run
13. Gameplay arena scene launch
14. Integration self-check run
15. actual `res://scenes/fast_slice/fs_a_main.tscn` headless launch
16. Presentation spatial self-check
17. Presentation pure shell smoke
18. Presentation preview smoke
19. candidate-independent QA skeleton fixture
20. project main
21. Phase 1 tests
22. Slice 2-A tests — `120` assertions
23. Slice 2-A correction tests — `39` assertions

Command forms are fixed as follows.

- Steps `3–23`は共通してGodot `--headless --path <fresh>`をprefixとし、次のsuffixを付ける。
- Parse steps `3–11`は`--check-only --script <exact res:// path>`。exact pathsは`res://scripts/fast_slice/gameplay/fs_a_input_adapter.gd`、`res://scripts/fast_slice/gameplay/fs_a_gameplay_loop.gd`、`res://scripts/fast_slice/gameplay/fs_a_gameplay_arena.gd`、`res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd`、`res://scripts/fast_slice/integration/fs_a_integration_root.gd`、`res://scripts/fast_slice/integration/fs_a_integration_self_check.gd`、`res://scripts/fast_slice/presentation/fs_a_presentation_shell.gd`、`res://scripts/fast_slice/presentation/fs_a_presentation_preview.gd`、`res://scripts/fast_slice/presentation/fs_a_preview_stub.gd`。
- Gameplay self-checkは`--script res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd`、arenaは`--scene res://scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn --quit-after 120`。Integration self-checkは`--script res://scripts/fast_slice/integration/fs_a_integration_self_check.gd`、mainは`--scene res://scenes/fast_slice/fs_a_main.tscn --quit-after 120`。
- Presentation self-checkは`--scene res://scenes/fast_slice/presentation/fs_a_presentation_preview.tscn -- --fs-a-self-check`。shell smokeは`--scene res://scenes/fast_slice/presentation/fs_a_presentation_shell.tscn --quit-after 5`、preview smokeは`--scene res://scenes/fast_slice/presentation/fs_a_presentation_preview.tscn --quit-after 5`。
- QA skeletonは`--script res://tests/fast_slice/run_fs_a_contract_skeleton.gd`、project mainは`--quit-after 120`。regression 3本は順に`--script res://tests/run_phase1_tests.gd`、`--script res://tests/run_slice2a_tests.gd`、`--script res://tests/run_slice2a_correction_tests.gd`。

Required result:

- all `23 / 23` numeric exit `0`
- Gameplay terminal `[MFO-FS-A-SELF-CHECK] PASS: full gameplay loop` exact `1`、PASS lines exact `533`、required named anchors `15 / 15` each exact `1`。required exact linesは次の15本。
  - `[MFO-FS-A-SELF-CHECK] PASS: configured safe opening spawn is exact (200, 540)`
  - `[MFO-FS-A-SELF-CHECK] PASS: stationary safe opening first line resolves a range miss`
  - `[MFO-FS-A-SELF-CHECK] PASS: stationary safe opening sector resolves a range miss`
  - `[MFO-FS-A-SELF-CHECK] PASS: spawn light resolves an out-of-range miss`
  - `[MFO-FS-A-SELF-CHECK] PASS: spawn heavy resolves an out-of-range miss`
  - `[MFO-FS-A-SELF-CHECK] PASS: no-teleport traversal reaches attack range`
  - `[MFO-FS-A-SELF-CHECK] PASS: real fresh Q press captures retry edge`
  - `[MFO-FS-A-SELF-CHECK] PASS: real held Q captures no repeated retry edge`
  - `[MFO-FS-A-SELF-CHECK] PASS: real Q release captures no retry edge`
  - `[MFO-FS-A-SELF-CHECK] PASS: fatal command Q edge does not retry an alive-start command`
  - `[MFO-FS-A-SELF-CHECK] PASS: fresh Q composite emits the reset snapshot exact once`
  - `[MFO-FS-A-SELF-CHECK] PASS: same arena second defeat latches exact once`
  - `[MFO-FS-A-SELF-CHECK] PASS: same-arena second fresh Q emits reset snapshot exact once`
  - `[MFO-FS-A-SELF-CHECK] PASS: post-retry enemy schedule restarts with the first line warning`
  - `[MFO-FS-A-SELF-CHECK] PASS: round-two fresh Q preserves current round`
- Integration marker `[MFO-FS-A-INTEGRATION] self_check=PASS checks=236 shapes=3 events=3 one_loop=true presentation_parity=true`、expected warning headers exact `4`
- Presentation marker `[MFO-FS-A-PRESENTATION] self_check=PASS snapshots=5 spatial_schema=true anchors=40 geometry=line+sector tracking_positions=5 tracking_aims=3 events=3 payload_variants=9 invalid_updates=20 deep_read_only=true`、expected warning headers exact `20`
- other warning、`ERROR`、`SCRIPT ERROR`、terminal `FAIL` exact `0`
- QA skeletonはfixture-onlyでありcandidate acceptanceの代替にしない

## Targeted technical anchors

automation／source readbackで最低限次を個別に記録する。

- configured start exact `(200, 540)`、initial aim right、boss distance `1150`、line `980`／sector `520` range外。
- fresh stationary first line＋next sector scheduleは抑制されずmissし、Integrity／Deformation不変。
- spawn light／heavy miss、bounded no-teleport traversal、actor／snapshot parity、part hit／recovery。
- real Input neutral／fresh／held／release／new-fresh Q capture、Q／LB bindingとE／RB bindingのstatic exact／idempotence。
- command-start defeat latch、alive-fatal edge nonreuse／noncarry、held／release／neutral／aim-only／E negative。
- accepted composite retryのmove／aim／evade／light／heavy／E／delta consume、snapshot exact1、retry／rematch event0。
- Integrity／Deformation／player actor／action／query／boss／parts／enemy／telegraph／pending hit／wreck／harvest／result／rewardのfull configured reset。
- round index／rematch counter保持、same-arena second defeat／fresh retry、round-two retry。
- stale pending hit0、enemy schedule restart、alive Q nonconsume、wreck/result Q-only negative、existing E harvest/rematch regression。
- snapshot／debug／step-result schema exact、新phase／field／event／signal／counter／UI `0`。
- tuning deltaはstart exact 1値だけ、Forbidden API／path drift `0`。

Contract Section 10の20 bulletを`technical-mapping.json`とreportで`20 / 20`個別判定する。physical gamepad itemはstatic LB bindingと`Not run / Deferred` manualを分離し、KBM Qで実機Passへ昇格しない。

manifest／hash readback完了後、automated stage／tarはQAがresolved exact 2 pathsだけcleanupしてよい。repository／candidate／result変更`0`とcleanup後不存在を保存する。

## Fresh manual setup

manualはautomationと別のfresh archiveを使う。

- Stage root: `C:\tmp\mf-fs-a-30-005-manual-20260816-001`
- Archive: `C:\tmp\mf-fs-a-30-005-manual-20260816-001.tar`
- Project: `C:\tmp\mf-fs-a-30-005-manual-20260816-001\material-frontier-online\prototype`

manualも別tar／stageで`git archive --format=tar --output=<manual-archive> <issuance> -- material-frontier-online/prototype`をexact 1回使う。tracked prototype exact `97` files、archive bytes／SHA／embedded issuance、candidate／prototype tree、`.git=false`／pre-import `.godot=false`を固定し、`git hash-object --path=<repo-relative> -- <stage-file>`でmissing／mismatch `0`を確認する。raw `--no-filters`比較は禁止する。editor import exact 1回／global class cacheを確認し、実行対象はactual `fs_a_main.tscn` GUIだけ。Presentation previewは禁止する。

candidate評価前のmechanical preparation failureは別attemptとして保存する。修正が一意なcommand transportだけならunique suffixでcorrected setup exact 1回まで許可するが、source／acceptance変更は禁止する。

Session Aはprecondition lossまたはuser-authored early closeでexact 1 fresh GUI relaunch、Session Bもprecondition contaminationまたはearly closeでexact 1 fresh GUI relaunchまで。同じimported stageを使い、archive／importを再実行しない。観測済みcandidate failureをPassへ変えるrerunは禁止する。setup quota外のQ reset test actionはSession BのS4 accepted retry exact1と、同一sessionで可能なoptional second-defeat corroboration exact1だけ。Session AではWRECK／resultのQ-negative以外にdefeated Q recoveryを使わず、precondition lossはauthorized GUI relaunchだけで扱う。

## Manual evidence rule

- 全promptは操作前に番号付きで全subclauseを列挙し、exact replyと一体で保存する。
- direct observation、normalized observation、QA inference、source／automation evidence、field identity、numeric exitを分離する。
- generic replyは直前promptが全項目を一意に列挙した場合だけ採用する。
- composite rowは全clauseのdirect manual supportが揃うまでPassにしない。automation／source／partial observationでupgradeしない。
- exit未取得は`null`とし推測しない。GUI close理由、process count、force-kill有無を保存する。

## Canonical manual 21-row ledger

current candidateで全21 rowsを判定する。prior QA resultはhistorical columnだけに置く。

| Row | Current-candidate manual requirement |
|---:|---|
| 1 | actual `fs_a_main.tscn`が開きfocus／interactionに到達する。 |
| 2 | WASD moveがvisible position changeとして読める。 |
| 3 | stationary中とmove中のmouse aim cueが追従する。 |
| 4 | `Space` evadeが受理されvisible position changeを持つ。 |
| 5 | `LMB` light／`RMB` heavyが別input／別timingで成立する。 |
| 6 | teleport／state injectionなしでWASD接近し、攻撃が表示上の敵へ届きdamageが起きる。 |
| 7 | isolated一攻撃の同target damage変化がexact 1回で、recoveryまでduplicateしない。 |
| 8 | named canonical `BOSS HP`がvalid boss hitで減少する。 |
| 9 | line telegraphを非色geometryで識別しevadeできる。 |
| 10 | sector telegraphを非色geometryで識別しevadeできる。 |
| 11 | named `INTEGRITY`／`DEFORMATION`をsingle nonfatal hitのbefore／afterで読み、Integrity down／Deformation upを確認する。 |
| 12 | player defeat後、WASD／Space／LMB／RMB／Eを個別入力し、visible move／evade／action cue／hit／damage／interactがなく、player position、displayed Integrity／Deformation、BOSS／part damage、harvest／result表示が変化しない。private latch／query／pending exactnessはtechnical mappingだけで判定する。 |
| 13 | defeat前の一attack cycle超を待ち、enemy telegraph／attack／追加damage停止、boss／part／wreck／harvest／result／phase不変を確認する。 |
| 14 | part breakを位置、bar、X、textからexact once認識できる。 |
| 15 | `BOSS HP` 0後、pre-defeat cycle超でtelegraph／attack／hit停止、Integrity不変を確認する。 |
| 16 | wreck exact1、wreck-relative `SALVAGE A/B/C` exact3、labels／number／shape／no fourth markerを確認する。 |
| 17 | A/B/C各1回回収。third前にcollected pointへE release→fresh tapしてduplicate grant／state change0。 |
| 18 | first／second collection後result hidden、third collection後だけresult visible。 |
| 19 | resultでE rematch exact1後、user-visible configured state（Integrity max／Deformation0／player positionがSession A開始時に記録したsame visible spawn anchorへ戻る／BOSS HP／parts／COMBAT／wreck・harvest・result absence）を個別readbackし、round2 move／aim responsiveness／evade／light／heavyが成立する。exact `(200, 540)`、initial aim right、same-command consume、private counters／pending／eventsはtechnical mappingだけで判定する。 |
| 20 | target／HUD／telegraph／part／harvest／resultを色名なしのshape／text／number／hatch／Xで識別する。 |
| 21 | current操作感と戦闘readabilityのverbatim user／playtester短評を保存する。 |

## Manual Session A — safe opening, combat, wreck, result, rematch

1. title bar／taskbar／OS task switchなどnon-gameplay手段でactual sceneをfocusし、viewport LMBを発火させずinputなしでnamed INTEGRITY／DEFORMATION baselineとplayerのvisible spawn anchorを記録する。first lineとnext sectorの両cycleを観察し、telegraph／AI／attack進行、hitなし、before＝after、直後move可能を確認する。gameplay clickが発火した場合はprecondition contaminationとして記録する。これをsupplemental `S1 safe opening`とする。
2. Integrityをpositiveに保ち、rows 1–10を番号付きで実行する。row 11は早期にbefore値→single nonfatal enemy hit exact1→after値／方向を読み、直ちに安全へ退避する。
3. ordinary playでrows 14／15を確認し、bossをdefeatする。E前にrow16を完了する。
4. WRECK markerでfresh Qを押し、collection／reward／marker stateが変わらないことを確認する。QをreleaseしてからEでAを回収し、同AへE release→fresh tapしてduplicate0。B／Cを各1回回収し、rows17／18をcheckpointごとに確認する。
5. result表示中にfresh Qを押し、rematch／round／reward／resultが変わらないことを確認する。Q release後、WASD／mouse／actionをneutralにしてE exact1でrow19 rematchし、row19に列挙したuser-visible configured stateとround2主要操作を確認する。
6. lifecycle checkpointでrow20を全対象別に回答する。framing／overlapもcurrent candidateで確認する。

WRECK Q no-harvest／result Q no-rematchをsupplemental `S6 Q/E separation`とする。

## Manual Session B — defeat stop and Q retry

1. fresh positive stateのplayer visible spawn anchorを操作前に記録する。Q単独fresh tap後、Qをreleaseし、resetなし、move／aim／Space／LMB／RMBが通常成立することを確認する。`S2 alive Q negative`。
2. WASDでenemy rangeへ入り、bossを攻撃せずpre-defeat telegraph→attack cycleとboss／part baselineを記録する。fatal予定attack前からQをholdし、Integrity0後もauto-resetしないことを観察する。manual timingをverbatim保存し、same-command exactnessはdeterministic anchorと分離する。`S3 fatal-held-release`。
3. Q release後もresetなしを確認する。row13を先にno-inputでcycle超観察し、次にrow12のWASD／Space／LMB／RMB／Eを個別実行する。Eはdefeat retryでない。
4. WASD／mouse／Space／LMB／RMB／Eをすべてreleaseしてneutralにし、defeated player positionとdisplayed stateを記録する。Qだけをfresh pressし、そのaccepted edge後もQをholdしたまま、INTEGRITY max、DEFORMATION0、playerがSession B開始時に記録したsame visible spawn anchorへ戻る、BOSS HP max、parts intact、COMBAT、wreck／harvest／resultなしのvisible resetを個別readbackする。exact `(200, 540)`、initial aim right、same-command co-input consume、内部velocity／query／pending hit／event／round counterはtechnical mappingだけで判定する。`S4 fresh Q visible reset`。
5. 他inputをneutralに保った同じaccepted Q hold中にrepeat resetなしを確認し、Q releaseだけでもresetなしを確認する。stationaryのままsafe start first line missを先に観察し、その後move／aim／evade／light／heavyとenemy schedule再開を確認する。`S5 post-retry restart`。

Session BではQ以外のdefeat reset手段を期待しない。追加relaunchなしで可能ならsecond defeat→release→new fresh Qをmanual corroborationとして記録するが、deterministic exact-once evidenceの代替にしない。

## Current feel and readability prompt

全manual後に次をexact promptとして聞く。

> 開始直後に考える時間ができたか、敗北後のQ retryが分かりやすく使えたか、telegraph／HUD／part／harvest／resultを読み分けられたかを含め、今回の操作感と戦闘の読みやすさで遊びづらい点はありますか。なければその旨も教えてください。

no retry UIはApproved境界だがdiscoverability／feel findingは記録できる。userの改善提案を仕様承認やcandidate repair authorityへ変換しない。

## OQ and excluded-system boundary

- `OQ-005`／`OD-021-INPUT`と`OQ-00-20260815-003`はClosed／Approved。Q failureやunsafe openingをcontract未決として扱わずcandidate findingとして判定する。
- `OQ-001` production `ActorDefeated` payloadと`OQ-004` production hit presentationはOpenのまま。新event／VFX／SE／camera仕様を仮定しない。
- target-selection lock-on、新retry UI、自動retry、新phase／snapshot field／event／signalは期待しない。
- physical gamepad LBは`Not run / Deferred`。KBM QでPassへ代替しない。
- performance／P95／maximum load／long-runは`Not run / Deferred`。optional exportは`Not run`。
- `fs_provisional`はstable balance／production value／Gate evidenceではない。

## Minimum durable evidence

- `accepted-manual-closure-reference.json`
- `setup-identity.json`
- `source-hashes.json`
- `automated-results.json`
- `technical-mapping.json`
- `manual-results.json`
- automated／manual commands、stdout、stderr、numeric exits
- GUI session/window/process、prompt／reply／normalized observations
- `scope-audit.json`
- `cleanup-boundary.json`
- `execution-manifest.json` — automated setupとexact 23 command／stdout／stderr／exitのautomated execution artifact setだけを対象とし、自身とtop-level `evidence-manifest.json`を除外する。manual subtreeとdisjoint、duplicate `0`、current size／SHA readback一致を保存する。
- `manual-artifact-manifest.json` — manual setup、GUI session、window／process、prompt／reply／observationのmanual subtreeだけを対象とし、自身とtop-level `evidence-manifest.json`を除外する。automated execution setとdisjoint、duplicate `0`、current size／SHA readback一致を保存する。
- normalizationを行う場合のoriginal／normalized bytes・SHA・semantic equality・byte reconstruction record
- `evidence-manifest.json` — content snapshot SHAを固定し、自身だけを除外してsubordinate manifestsを含める。missing／mismatch／duplicate／self-reference `0`を保存する。

external screenshotを使う場合はpath／bytes／SHA／timestamp／session provenanceと`repository_copy=false`を記録し、ambiguous provenanceでrowをupgradeしない。

## Result classification

- `Pass / promotion recommended`: automation `23 / 23`、technical `20 / 20`、canonical manual `21 / 21`、manual-observable S1–S6がPass、candidate defect `0`、current readability／feelにblocking negativeなし。
- `Technical Pass / promotion pending manual KBM and/or user feel`: required manualにNot run／Blockedまたはfeel未完が残る。
- `Technical Pass / promotion not recommended — playability finding`: functional closureはPassだがopening／Q discoverability／readability／feelにnegative findingがある。
- `Fail / candidate`: unsafe opening hit、fresh Q不受理、fatal／held edge retry、reset不全、E／rematch regression等のreproducible defect。
- `Blocked / setup identity`: ref／ancestry／prototype／starting byte identity不一致。
- `Blocked / QA infrastructure`: candidate評価前のarchive／import／launcher／host／evidence capture failure。
- `Blocked / shared contract`: Approved recordsで一意に判定できないgenuine ambiguity。

candidate finding時も修正せず、安全な独立項目は続行できる。受入条件を緩和しない。

## Evidence commit protocol

1. report、checklist、evidence、QA handoff EOF appendをcontent commitにする。
2. content SHAを`summary_snapshot_tip`へ固定し、全artifactのcurrent size／SHAをreadbackする。
3. `evidence-manifest.json`だけをmanifest-only child commitにする。
4. review correctionが必要ならcontent follow-up→manifest-only childを守り、amend／rebaseしない。
5. issuance→final、content、manifest各rangeのdiff-check、JSON parse、allowlist、candidate／prototype／test／contract delta `0`を確認する。
6. push後local HEAD／tracking ref／live origin一致、worktree cleanを確認する。

manual stage／tarはGUI exit、Godot process `0`、durable commit／push後も30がcleanupせず保持する。00がReturnを受理した後だけpath／type／archive bytes／SHAを再確認してexact cleanupする。

## Return protocol

30は00へ次をdirectに返す。

- branch／worktree／final tip、local／tracking／live origin、clean
- candidate／review／issuance／prior QA sibling identity、ancestry、prototype tree
- issuance→final全commit、merge count、exact changed paths、allowlist／protected差分
- automated archive／Godot／23 commands／warnings／anchors／cleanup
- technical Section 10 `20 / 20` individual mapping
- current canonical 21 rows、S1–S6、exact prompts／quotes、candidate finding count
- report／checklist／evidence／handoff、manifest counts／sizes／SHA readback
- recommendation、Not run／Deferred、shared-contract change要否
- retained manual stage／tar exact path／bytes／SHA、Godot process state、cleanup boundary

30は本票からintegration、baseline、mainへmerge／pushしない。`Pass / promotion recommended`でもpromotion／Gate actionは00の別review／別commitまで未承認である。
