# MFO-WO-FS-A-30-003 — FS-A Option A Integrated Revalidation

- Status: `Issued / Active`
- Issued: `2026-08-15`
- Issuer: `00統括（監督）`
- Assignee / QA-path single writer: `30 QA・性能・レビュー`
- Branch: `codex/fast-slice-fs-a-revalidation`
- Worktree: `C:\tmp\mf-fs-a-reval`
- Milestone: `FS-A`
- Authority: `docs/FAST_SLICE_CONTRACT.md` and this work order
- Frozen reworked integration candidate source: `f03a43d2339e9772a15db1c591a31f5e4f92cca2`
- 00 review record: `ba688730e57564bbb883035972bba9ff2224cd50`
- Frozen candidate prototype tree: `2a66e4c06308a47678e8888a739b87ffd33d1ee8`
- Historical validation final, read-only sibling: `3968be22d206bb66602dfc23efeb6bb372211461`
- Branch start: this work-order issuance commit。00がcommit／push後にexact SHAをdirect packetで通知し、3点一致確認前は開始しない。
- Authorized scope: frozen reworked candidateのfresh automated／manual revalidationと新規QA report／checklist／evidence／QA handoff appendだけ
- Forbidden scope: candidate repair、test code変更、旧evidence改変、promotion、Gate action
- Report: `docs/test-reports/fast-slice/fs-a-integrated-revalidation.md`
- KBM checklist: `docs/test-reports/fast-slice/fs-a-kbm-revalidation-checklist.md`
- Evidence root: `docs/test-reports/evidence/fast-slice/fs-a-integrated-revalidation/`
- Handoff: `docs/handoffs/fast-slice/qa.md` append-only

## Issue condition

00は次を確認したため本票を発行する。

- Userが`OQ-00-20260815-001`と`OQ-00-20260815-002`を双方Option AでApprovedし、Contract／Decisions／Open Questionsへ同期済み。
- Gameplay rework source `4eb47f83a093c9fe537577889dacaa888a0855b4`をintegration `9f77a02a7965ff1efcb4b7175ae30d9c1a515bf4`へ、Presentation rework source `73c6242f127b2d3d7d989ddebc17a2ea22d63537`をintegration `29993fdac66cec951d60bb289446eead87bcd7f5`へ取り込んだ。
- 10→20の順で全6 review済みcommitを競合なくcherry-pickし、exact 10 disjoint paths、merge `0`、scope違反`0`、full `git diff --check` exit `0`。
- combined candidate `f03a43d2339e9772a15db1c591a31f5e4f92cca2`のfresh archiveでGameplay full loop、Presentation spatial self-check、Integration `236` checks、QA fixture、main、Phase 1、Slice 2-A `120`、correction `39`をPassした。
- combined archive SHA-256は`885d6585067c81d781a82bf204188441678881591e19e4549bbdbd628c1f3a79`。pre-import `.godot=False`、結果確認後にtemporary stage／tarをexact cleanupした。
- candidate source、00 review record、issuance commitのprototype treeはすべて`2a66e4c06308a47678e8888a739b87ffd33d1ee8`で一致させる。
- 旧manual結果`0 Pass / 6 Fail / 11 Blocked / 2 Not run`はhistorical candidate resultとして保持し、新結果で上書きしない。
- promotionは停止中。本票のPass recommendationだけではpromotion／Gate actionを実施しない。

## Start identity and history rules

30は00のexact issuance packet受領後、次を満たしてから開始する。

1. worktreeが`C:\tmp\mf-fs-a-reval`、branchが`codex/fast-slice-fs-a-revalidation`である。
2. local HEAD、tracking ref、live originが00通知のissuance SHAとexact一致する。
3. worktree／index／untrackedがcleanである。
4. candidate `f03a43d2339e9772a15db1c591a31f5e4f92cca2`とreview record `ba688730e57564bbb883035972bba9ff2224cd50`がHEADのancestorである。
5. candidate、review record、HEADのprototype treeがすべて`2a66e4c06308a47678e8888a739b87ffd33d1ee8`とexact一致する。
6. candidate→issuance差分が00-owned docsだけで、prototype deltaが`0`である。
7. reset、rebase、amend、force push、mergeを行わず、issuance→finalの直線commit列を保持する。
8. 旧branch `codex/fast-slice-fs-a-validation`／worktree `C:\tmp\mf-fs-a-val`／final `3968be22d206bb66602dfc23efeb6bb372211461`をcheckout、編集、cleanup、再利用しない。

identity不一致時は修復を推測せず、candidate未評価の`Blocked / setup identity`として00へ返す。

## Exact writable paths

30が作成または編集できるのは次の4範囲だけ。

- `docs/test-reports/fast-slice/fs-a-integrated-revalidation.md`
- `docs/test-reports/fast-slice/fs-a-kbm-revalidation-checklist.md`
- `docs/test-reports/evidence/fast-slice/fs-a-integrated-revalidation/**`
- `docs/handoffs/fast-slice/qa.md` — current branch本文を保持し、revalidation節をappend-onlyで追加

旧`fs-a-integrated-validation.md`、旧`fs-a-kbm-checklist.md`、旧`fs-a-integrated-validation/**` evidenceは新branchに存在するか否かを問わずhistorical sibling recordであり、copy、rewrite、normalize、削除しない。新reportの`historical-validation-reference.json`からSHAで参照する。

`tests/fast_slice/**`を含む全test codeは本票ではread-only。runner／launcher／host defectでcandidate評価を阻害した場合、candidateを修正せず`Blocked / QA infrastructure`で返し、別bounded repair票を待つ。

## Read-only candidate and forbidden scope

次を変更しない。

- `material-frontier-online/prototype/scripts/fast_slice/gameplay/**`、対応scene／`.uid`
- `material-frontier-online/prototype/scripts/fast_slice/presentation/**`、対応scene／`.uid`
- `material-frontier-online/prototype/scripts/fast_slice/integration/**`、`fs_a_main.tscn`
- `material-frontier-online/prototype/data/fast_slice/**`、`fs_provisional`値／label
- `material-frontier-online/implementation/fast-slice/**`
- `material-frontier-online/prototype/tests/**`、legacy tests、strict evidence
- `project.godot`、Input Map、autoload、`export_presets.cfg`、`.gitattributes`
- `docs/FAST_SLICE_CONTRACT.md`、`docs/DECISIONS.md`、`docs/OPEN_QUESTIONS.md`、`docs/MASTER_SPEC.md`、`docs/MILESTONES.md`、`docs/work-orders/**`
- 10／20／integration handoff、QA-prep evidence、旧validation evidence
- networking、server、account、persistence、music、SE、voice、production art、binary／LFS payload

Presentationからauthority、HP、hit、part、loot、resultを決定しない。`boss_hp`をcanonical fieldとして扱い、enemy Integrity aliasを追加しない。OQ-001 event payloadとOQ-005 retry inputはOpenのまま。`E`のdefeat retry流用、新phase／snapshot field／event／UI／auto retryを期待または追加しない。

## Required execution

### A. Preflight and fresh source

- branch／HEAD／tracking／live origin／clean、candidate／review／issuance ancestry、prototype treeをdurable evidenceへ保存する。
- issuance tipの`git archive`からunique fresh stageを作る。pre-import `.godot`不存在、archive bytes／SHA-256、tracked payload identityを保存する。
- Godot identity `4.7.stable.official.5b4e0cb0f`とexecutable SHA-256を保存する。
- exact writable／read-only allowlist、candidate delta／validation delta、excluded-system auditを分離する。

### B. Required automated order

fresh stageで次の22 invocationを順番どおり実行し、command／stdout／stderr／numeric exitを保存する。

1. Godot `--version`。
2. fresh headless editor import。
3. integration root parse。
4. integration self-check parse。
5. Gameplay loop parse。
6. Gameplay arena script parse。
7. Gameplay self-check parse。
8. Presentation shell parse。
9. Presentation preview parse。
10. Presentation preview stub parse。
11. integration self-check。
12. `res://scenes/fast_slice/fs_a_main.tscn` launch。
13. Gameplay self-check。
14. Gameplay arena scene launch。
15. Presentation preview `--fs-a-self-check`。
16. Presentation pure shell smoke。
17. Presentation preview smoke。
18. candidate-independent QA skeleton fixture。candidate Passの代替にしない。
19. existing project main smoke。
20. Phase 1 regression。
21. Slice 2-A `120 assertions`。
22. Slice 2-A correction `39 assertions`。

続けて`git diff --check`、candidate／issuance／final prototype tree、changed-path allowlist、protected／production／excluded-system差分`0`、temporary artifact cleanupを確認する。Stage B `184`、performance、exportはrequiredではない。

Expected fixture warningsをexact分類する。

- Integration active-empty／unknown-shape: exact `4`。
- Presentation invalid-spatial updates: exact `20`。
- その他のWARNING／ERROR／SCRIPT ERROR／terminal FAIL: `0`。

### C. Required Option A anchors

Gameplay self-checkで少なくとも次を個別確認する。

- spawn light／heavyのout-of-range miss。
- teleportなしのmove／evade接近とactor／snapshot position parity。
- in-range light／heavy hit、target、damage、recovery、exact-once event。
- player Integrity positive→0のdefeat latch exact once。
- fatal latchがactive evade、velocity、pending action、hit query、enemy telegraph／attack／pending hitを停止。
- defeat後のmove／evade／light／heavy／interactとlarge deltaがstateを進めない。
- invalid configureがdefeat latch／snapshot／counters／eventsを保持しfail closed。
- successful configure／authority resetだけがlatchを解除しenemy schedulingを再開。
- existing boss defeat／wreck／exact 3 harvest／result／rematch／round twoが不変。

Presentation self-checkで少なくとも次を個別確認する。

- `snapshots=5 spatial_schema=true anchors=40 geometry=line+sector tracking_positions=5 tracking_aims=3 events=3 payload_variants=9 invalid_updates=20 deep_read_only=true`。
- player／aim／boss／parts／wreck／harvestがauthority arena座標へ追従。
- lineのorigin／direction／range／half-width、sectorのorigin／direction／range／radian half-angle。
- invalid updateがlast valid snapshotを保持し、sourceへwrite-backしない。
- event feedbackがevent nameとlatest snapshot anchorだけを使い、payload target／part semanticsを採用しない。

Historical automation `17 / 17`、旧technical `13 / 13`、QA skeleton fixtureを新candidateのPassへ流用しない。

### D. Manual KBM revalidation

manual前に同じcandidate／issuanceのunique fresh archiveを作り、headless editor import exit `0`と`.godot\global_script_class_cache.cfg`存在を確認してから実sceneをGUI起動する。Presentation previewは判定に使用しない。

```powershell
$Godot = 'C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe'
$FreshProject = '<unique-fresh-stage>\material-frontier-online\prototype'
& $Godot --headless --editor --path $FreshProject --quit
if ($LASTEXITCODE -ne 0) { throw 'Godot editor import failed' }
$GlobalClassCache = Join-Path $FreshProject '.godot\global_script_class_cache.cfg'
if (-not (Test-Path -LiteralPath $GlobalClassCache)) { throw 'Godot global class cache was not generated' }
& $Godot --path $FreshProject --scene res://scenes/fast_slice/fs_a_main.tscn
```

Controls: `WASD` move、mouse aim、`LMB` light、`RMB` heavy、`Space` evade、`E` harvest／rematch。

新規checklistは次の21行を`Pass / Fail / Blocked / Not run`で個別記録する。

1. Arena起動とfocus。
2. WASD移動が同arena座標上のplayer表示へ追従。
3. mouse aim cueが静止中・移動中とも追従。
4. evadeが使用でき、位置変化として読める。
5. light／heavyが別入力・別timing。
6. teleportなしで接近し、表示上の敵へ攻撃が届いてdamage。
7. 一攻撃が同targetへ二重damageしない。
8. canonical `BOSS HP`がvalid hitで減少。
9. line telegraphがgeometry一致、色以外で識別可能、回避可能。
10. sector telegraphがgeometry一致、色以外で識別可能、回避可能。
11. Integrity／Deformation変化が読める。
12. player Integrity 0後、player move／evade／action／damage確定が停止。
13. player Integrity 0後、enemy telegraph／attack／追加damageが停止し、boss／part／wreck／harvest／resultが不変。
14. part breakが位置を含め認識可能。
15. boss HP 0後、hostile behaviorが停止。
16. wreck位置とexact 3 harvest markerが一貫。
17. 各harvestが1回だけで、重複回収で追加取得なし。
18. resultが第三回収後だけ表示。
19. rematch完全resetと二周目主要操作。
20. target／HUD／resultの色非依存readability。
21. actual user／delegated playtesterのfree-text feel。

manualは少なくとも2 sessionへ分離する。

- Session A: move／aim／evade、combat、boss defeat、harvest、result、rematch、二周目。
- Session B: fresh scene relaunch後にplayer defeat stop。

OQ-005はOpenなのでplayer defeat後のin-game retry、`E`流用、自動retryを期待しない。Session B後のscene relaunchをretry acceptanceとして数えない。

### E. Contract Section 10 mapping

次の15項目を個別判定する。

1. 専用scene import／parse／launch。
2. move／aim／evadeとspatial変化。
3. light／heavy別操作／timing。
4. enemy 2 telegraphの予告／回避／geometry。
5. Integrity／Deformation変化とrematch初期化。
6. player defeat exact-once latchとplayer／enemy stop、boss側state不変。
7. part break。
8. boss HP 0 exact once。
9. boss HP 0後のAI／attack／hit停止。
10. player／boss／parts／wreck／telegraph／harvestのuser-visible spatial parity。
11. wreck exact once。
12. harvest exact 3／重複拒否。
13. 全回収後result。
14. rematch完全初期化／二周目。
15. Presentation無効時のGameplay結果不変。

### F. Evidence and cleanup

新evidence rootへ最低限次を保存する。

- `automated-results.json`、`source-hashes.json`、`scope-audit.json`。
- `historical-validation-reference.json`。
- `manual-attempt-003.json`。
- `cleanup.json`。
- 22 invocationのcommand／exit-code／execution log。
- `execution-manifest.json`、`evidence-manifest.json`。

candidate／review／issuance／archive／prototype tree、exact commands、numeric exit、warning分類、Not runをreport／JSON／handoffで一致させる。user発言はverbatimとnormalized observationを分離し、field identity／root cause／classificationなどの推論は決定者を明記する。numeric exit未取得は`null`で、推測しない。

execution logを正規化した場合はrawと呼ばず、original bytes／SHA-256と変換内容を別記録する。evidence manifestはcontent tipを`summary_snapshot_tip`としてself-excludedにし、manifest-only commit前にcurrent filesのsize／SHA-256を全件readbackする。修正はamendせずcontent＋manifest follow-upで行う。

automated stage／archiveはhash／readback後にQAがexact cleanupできる。manual stage／archiveはGUI終了とdurable commit／push後も保持し、00 acceptance後に00がexact path確認してcleanupする。

## Recommendation classification

- `Pass / promotion recommended`: required automation、15 technical items、manual functional、readability、user feelが受入可能。
- `Technical Pass / promotion pending manual KBM and/or user feel`: automationはPassだがmanualまたはuser feel未完了。
- `Technical Pass / promotion not recommended — playability finding`: automation／manual functionalはPassだがreadability／feel findingがnegative。
- `Fail / candidate`: frozen candidateの再現可能なparse／assertion／functional defect。
- `Blocked / QA infrastructure`: runner／launcher／hostでcandidate評価前に停止。

gamepad、performance／P95／maximum load／long-run、optional exportのNot runは別分類する。本票はpromotion、baseline merge、Gate actionを行わない。

## Return protocol

30はQA-owned commitをpushし、00 Integration taskへ直接次を返す。

- branch、final tip、local／tracking／live origin、clean。
- issuance→finalの全commit列、merge count。
- exact changed paths、allowlist、protected／production／candidate差分`0`。
- candidate／review／issuance／tested source／final prototype identity。
- 22 commands、numeric exits、anchors、warning／error分類。
- 15 technical items、21 manual rows、user feel、gamepad、performance、exportの個別結果。
- report／checklist／evidence／handoff paths、manifest counts、size／SHA-256 readback。
- recommendation、Not run、known limitations、shared-contract change要否。
- manual stage／archiveのexact path、GUI／Godot process state、cleanup boundary。

共有契約変更が本当に必要な場合だけ該当検証を停止して00へ返す。それ以外は発行済みscope内で承認待ちせず継続する。

## Promotion boundary

30は`prototype/fast-vertical-slice`へmerge／pushせず、promotion／Gate actionを実行しない。00がReturn、evidence、manual result、user feelをreviewした後だけ別工程で判断する。
