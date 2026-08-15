# MFO-WO-FS-A-30-004 — FS-A Manual Closure

- Status: `Issued / Active`
- Issued: `2026-08-15`
- User authority: 2026-08-15「はい。お願いします」
- Issuer: `00統括（監督）`
- Assignee / QA-path single writer: `30 QA・性能・レビュー`
- Branch: `codex/fast-slice-fs-a-manual-closure`
- Worktree: `C:\tmp\mf-fs-a-manual-closure`
- Milestone: `FS-A`
- Authority: `docs/FAST_SLICE_CONTRACT.md` and this work order
- Frozen integration candidate: `f03a43d2339e9772a15db1c591a31f5e4f92cca2`
- 00 candidate review record: `ba688730e57564bbb883035972bba9ff2224cd50`
- Accepted revalidation final / branch base: `ca15f57e6c3c23658d602cfa93212e8e91de2064`
- 00 revalidation acceptance record, administrative sibling: `deebadf2f2e025dff0262afa876f34bc9bb1699d`
- Frozen prototype tree: `2a66e4c06308a47678e8888a739b87ffd33d1ee8`
- Branch start: accepted revalidation finalから作成し、このwork-order-only portable issuance commitをcherry-pickしたcommit。00がsource→QA SHAをdirect packetとintegration handoffで通知する。
- Authorized scope: accepted checklistで`Not run`のmanual rows `3–20`、current操作感／readability短評、新規QA report／checklist／evidence、QA handoff EOF appendだけ
- Forbidden scope: candidate／test／contract／旧evidence変更、automation suite再実行、promotion、baseline merge、Gate action
- Report: `docs/test-reports/fast-slice/fs-a-manual-closure.md`
- Checklist: `docs/test-reports/fast-slice/fs-a-kbm-manual-closure-checklist.md`
- Evidence root: `docs/test-reports/evidence/fast-slice/fs-a-manual-closure/`
- Handoff: `docs/handoffs/fast-slice/qa.md` EOF append-only

## Objective and result boundary

`MFO-WO-FS-A-30-003`でacceptedとなったautomation `22 / 22`、Contract Section 10 technical `15 / 15`、manual `3 Pass / 0 Fail / 0 Blocked / 18 Not run`を前提に、未完了manual rows `3–20`のexact `18`行だけを実`fs_a_main.tscn`で閉じる。

本票はGameplay、Presentation、Integration、testを修正しない。accepted automationを再実行して新しいPassと呼ばず、accepted SHA／manifestをread-only参照する。30はrecommendationまでを返し、promotion、`prototype/fast-vertical-slice`へのmerge／push、`MILESTONES.md`更新、Gate actionを行わない。

FS-Aのmanual closureはFast Slice playability findingであり、Gate 2、Gate Playability、Gate 8またはproduction acceptanceではない。

## Issue condition

00は次を確認し、ユーザーの明示承認により本票を発行する。

- Integration branchは`deebadf2f2e025dff0262afa876f34bc9bb1699d`でlocal HEAD／tracking ref／live originが一致し、cleanだった。
- Revalidation branchは`ca15f57e6c3c23658d602cfa93212e8e91de2064`で3点一致し、cleanだった。
- candidate `f03a43d2339e9772a15db1c591a31f5e4f92cca2`はaccepted revalidation finalとintegration acceptance record双方のancestorである。
- candidate、accepted revalidation final、integration acceptance recordのprototype treeはすべて`2a66e4c06308a47678e8888a739b87ffd33d1ee8`。
- 新branch、tracking ref、live origin、worktree path、本票pathは発行preflight時に不存在だった。
- `MFO-WO-FS-A-30-003` corrected Returnは00の独立scope／semantic／evidence監査をPassし、candidate defect `0`で受理済み。
- accepted QA finalのmanual temporary stage／tarは、00がidentity／hash／Godot process `0`を再確認後にexact cleanup済み。

## Start identity and history rules

30は00のexact issuance packetを受領後、次を満たしてから開始する。

1. worktreeが`C:\tmp\mf-fs-a-manual-closure`、branchが`codex/fast-slice-fs-a-manual-closure`である。
2. local HEAD、tracking ref、live originが00通知のQA issuance SHAとexact一致する。
3. worktree／index／untrackedがcleanである。
4. candidate `f03a43d2339e9772a15db1c591a31f5e4f92cca2`、review `ba688730e57564bbb883035972bba9ff2224cd50`、accepted revalidation final `ca15f57e6c3c23658d602cfa93212e8e91de2064`がHEADのancestorである。
5. `deebadf2f2e025dff0262afa876f34bc9bb1699d`は00 acceptanceのadministrative siblingであり、HEADのancestorでなくてよい。commit objectとして存在し、00通知と一致する。
6. candidate、accepted revalidation final、integration acceptance、HEADのprototype treeがすべて`2a66e4c06308a47678e8888a739b87ffd33d1ee8`とexact一致する。
7. `ca15f57...`→issuance差分は本票1ファイルだけ、merge `0`、prototype delta `0`である。
8. accepted report／checklist／evidence／QA handoffは開始時点で`ca15f57...`とbyte-identicalである。
9. 新report、checklist、evidence rootが開始時に不存在である。
10. reset、rebase、amend、merge、force pushを行わず、issuance→finalの直線commit列を保持する。

identity不一致時は推測で修復せず、candidate未評価の`Blocked / setup identity`として00へ返す。

## Accepted results and evidence to preserve

次をread-only accepted evidenceとして固定し、本票の再実行結果へ言い換えない。

- `MFO-WO-FS-A-30-003` issuance／tested source: `29c22763c41abaace46430395dd1bdfd14caaf66`
- accepted final: `ca15f57e6c3c23658d602cfa93212e8e91de2064`
- four-commit lineage: `f028c76bf7b38315dc093c008b0196b617c0b788` → `fc11664071ccf46652380c672da9d23e33f680f5` → `2dde6bbfec893a5c611c01638ec2b188e1b6cf1b` → `ca15f57e6c3c23658d602cfa93212e8e91de2064`
- automation: `22 / 22` numeric exit `0`
- technical mapping: `15 / 15 Pass`
- manual: rows `1`、`2`、`21`だけPass、rows `3–20`は`18 Not run`
- candidate defect: `0`
- automated-results: `31073` bytes / SHA-256 `87fae7ceaa0db958f87a7e55fe8fe102377b3e151fefa123c921f9a70440988a`
- evidence-manifest: `38468` bytes / SHA-256 `ba266ed34d14cdb749df3a5a12014c3720894e869e0f169f15ea89360dd84f40`
- accepted report: `10777` bytes / SHA-256 `dd41fc0b9340937110dd4d678ef04d4accbe3bf23605dc2a1fe207d83e72b075`
- accepted checklist: `6812` bytes / SHA-256 `408c3b3a2400b16c70243c229e54b9faee3e37c20a3d83cd79467857e145eb18`
- accepted manual-attempt-003: `13627` bytes / SHA-256 `3bcc15c4915b32169275f81ad91225b396086c7611965dfb0293863fd65e017a`
- execution artifacts `110 / 110`、manual artifacts `24 / 24`、normalized logs `16 / 16`、evidence＋summary `153 / 153`

historical `3968be22...` validation、旧`17 / 17`／`13 / 13`／manual `0 / 6 / 11 / 2`も別履歴として保持する。どの旧evidenceもcopy、rewrite、normalize、deleteしない。

## Exact writable paths

30が作成または編集できるのは次の4範囲だけ。

- `docs/test-reports/fast-slice/fs-a-manual-closure.md`
- `docs/test-reports/fast-slice/fs-a-kbm-manual-closure-checklist.md`
- `docs/test-reports/evidence/fast-slice/fs-a-manual-closure/**`
- `docs/handoffs/fast-slice/qa.md` — 既存本文をbyte-preserveし、EOF append-only

## Read-only and forbidden paths

次はread-onlyであり、差分を作らない。

- `docs/test-reports/fast-slice/fs-a-integrated-revalidation.md`
- `docs/test-reports/fast-slice/fs-a-kbm-revalidation-checklist.md`
- `docs/test-reports/evidence/fast-slice/fs-a-integrated-revalidation/**`
- 旧validation／QA-prepのreport、checklist、evidence
- `material-frontier-online/prototype/scripts/fast_slice/**`
- `material-frontier-online/prototype/scenes/fast_slice/**`
- `material-frontier-online/prototype/data/fast_slice/**`
- `material-frontier-online/prototype/tests/**`
- `material-frontier-online/prototype/project.godot`
- Input Map、autoload、`.uid`、export設定
- implementation report、10／20／integration handoff
- `docs/FAST_SLICE_CONTRACT.md`、`docs/DECISIONS.md`、`docs/OPEN_QUESTIONS.md`、`docs/MILESTONES.md`、全work order
- `fs_provisional`、production／strict-line、networking／server／account／persistence、art／audio、binary／LFS paths

30はtestを通すためにgame値、fixture、runner、evidenceを変更しない。scope違反は修復せずReturnする。

## Fresh manual-only setup

最初のqualifying attemptは次のunique pathを使う。

- Stage root: `C:\tmp\mf-fs-a-manual-closure-stage-20260815-001`
- Archive: `C:\tmp\mf-fs-a-manual-closure-stage-20260815-001.tar`
- Project: `C:\tmp\mf-fs-a-manual-closure-stage-20260815-001\material-frontier-online\prototype`

作成前にstage rootとarchiveが双方不存在であることを確認する。どちらかが存在する場合は上書き／再利用／silent cleanupを行わず、preparation issueとして記録して次のunique numeric suffixを使う。

issuance HEADの`git archive`から作成し、次をdurable evidenceへ保存する。

- issuance／candidate／accepted QA／prototype tree identity
- archive bytes／SHA-256
- extracted source payloadとprototype payloadのfile count、size／SHA readback
- pre-import `.godot=False`、`.git=False`
- Godot `4.7.stable.official.5b4e0cb0f`
- Godot executable size／SHA-256

manual準備としてのみ、次をexact 1回実行する。

```powershell
& $Godot --headless --editor --path $FreshProject --quit
if ($LASTEXITCODE -ne 0) { throw 'Godot editor import failed' }

$GlobalClassCache = Join-Path $FreshProject '.godot\global_script_class_cache.cfg'
if (-not (Test-Path -LiteralPath $GlobalClassCache)) {
    throw 'Godot global class cache was not generated'
}
```

その後、必ず実sceneをGUI起動する。

```powershell
& $Godot --path $FreshProject --scene res://scenes/fast_slice/fs_a_main.tscn
```

Presentation preview、self-check、QA fixture、Phase 1、Slice 2-A、accepted 22-command suite、technical 15-item suiteは再実行しない。editor importと実scene launchをautomation再実行と呼ばない。

candidate評価前のmechanical preparation failureは別attemptとして保存し、candidate resultへ混ぜない。修正が一意なcommand transportだけなら、original pathをcleanupして次のunique suffixで一度だけ継続できる。source、candidate、test、acceptance ruleを変える修正は禁止する。

## Controls and manual evidence rule

- `WASD`: move
- mouse: aim
- `LMB`: light attack
- `RMB`: heavy attack
- `Space`: evade
- `E`: harvest／rematch only

各rowは番号付きpromptで全subclauseを先に列挙し、exact user replyと組で保存する。genericな「全部できました」は、直前promptが全subclauseを列挙し、その回答が一意に対応するときだけ採用する。

direct observation、normalized observation、QA／00 inference、field identity、numeric exitを分離する。numeric exit未取得は`null`とし、推測しない。automation、source audit、部分観察で複合rowをPassへ昇格しない。

## Session A — rows 3–11 and 14–20

fresh sceneでplayer Integrityをpositiveのままboss defeatまで進める。順序は誤defeatで後続項目を失わないよう調整してよいが、各rowの全subclauseを個別に確認する。

| Row | Exact manual requirement |
|---:|---|
| 3 | stationary中とmove中の双方でmouse aim cueが追従する。 |
| 4 | `Space` evadeが受理され、visible position changeとして読める。 |
| 5 | `LMB` lightと`RMB` heavyを別々に実行し、入力とtiming差を直接確認する。 |
| 6 | teleport／state injectionなしでWASD接近し、表示上の敵へ攻撃が届きdamageが確認できる。 |
| 7 | isolated一攻撃につき同targetへのdamage変化がexact 1回で、recovery完了まで二重減少しない。 |
| 8 | named canonical HUD `BOSS HP`がvalid hitで減少する。 |
| 9 | line telegraphをgeometry／非色cueで識別し、evadeで回避できる。 |
| 10 | sector telegraphをgeometry／非色cueで識別し、evadeで回避できる。 |
| 11 | named `INTEGRITY`／`DEFORMATION`双方の変化が読み取れる。 |
| 14 | part breakを位置、bar／X／textで認識できる。 |
| 15 | `BOSS HP` 0後、defeat前に観察した一攻撃周期を超えてtelegraph／attack／hitが停止する。 |
| 16 | wreck exact 1と、wreckとの位置関係が一貫した`SALVAGE A/B/C` exact 3 markersを確認する。 |
| 17 | AまたはBを回収後、third collection前にその回収済みpointで`E` release→fresh tapしてduplicate grant／state changeがないことを確認し、その後に残るpointを含めA／B／Cを各1回だけ回収する。 |
| 18 | first／second collection後はresult非表示、third collection後だけresult表示。 |
| 19 | `E` rematch後、player、enemy、parts、wreck、harvest、result、位置を個別にreset確認し、二周目でmove／aim／evade／light／heavyを再確認する。 |
| 20 | target、HUD、telegraph、part、harvest、resultを色名なしでもshape／text／number／hatch／Xで識別できる。 |

Integrity `0`でのharvest no-opはApproved player-defeat stopであり、harvest defectに分類しない。Session AでIntegrityが0になった場合、該当attemptを保存し、fresh Session Aのprecondition retryをexact 1回だけ許可する。retryでもpositive Integrity条件を維持できない場合は残るSession A rowsを`Not run`としてReturnし、それ以上rerunしない。

## Session B — rows 12–13

別のfresh scene relaunchを使い、bossを倒さずenemy attackによってplayer Integrityをpositiveから0へ遷移させる。defeat前に同sessionでenemy telegraph→attack周期とboss-side stateを観察する。

| Row | Exact manual requirement |
|---:|---|
| 12 | Integrity 0後にWASD、`Space`、`LMB`、`RMB`を個別入力し、move、evade、action cue、hit／damage確定がすべて停止する。latch位置とIntegrity／Deformationが追加更新されない。 |
| 13 | defeat前の一攻撃周期を超えてenemy telegraph／attack／追加damageがなく、boss HP、parts、wreck、harvest、resultがdefeatだけでは変化せず、wreck／harvest／resultが誤生成されない。 |

`OQ-005`はOpenなのでdefeat後の`E` retry、自動retry、新UIを期待または評価しない。Session B後のGUI relaunchをretry acceptanceとして扱わない。

## Current feel and readability question

accepted historical row `21`を上書きしない。ただしpromotion recommendationにはcurrent candidateに対する明示的な操作感／戦闘可読性の短評が必要なため、全manual後に次をexact promptとして聞く。

> 今回の操作感と戦闘の読みやすさについて、遊びづらかった点や分かりにくかった点はありますか。なければ、その旨も短く教えてください。

replyはverbatim保存し、functional row resultとfeel／readability findingを分離する。

## OQ and excluded-system boundary

- `OQ-00-20260815-001`／`-002`はClosed／Approved Option A。spatial seamとplayer-defeat stopをexact検証し、拡張しない。
- `OQ-001`はOpen。production DomainEvent payloadを仮定または追加しない。
- `OQ-004`はOpen。placeholder readability結果をproduction VFX／SE／hit-stop／camera仕様へ昇格しない。
- `OQ-005`はOpen。defeat retry binding／edge／command consumptionを実装またはacceptanceしない。
- physical gamepadは`Not run / Deferred`。KBMでPassへ代替しない。
- performance／P95／maximum load／long-runは`Not run / Deferred`。
- optional exportは`Not run`。
- `fs_provisional`はstable balance／production値／Gate evidenceではない。

## Minimum durable evidence

新evidence rootへ最低限次を保存する。

- `accepted-revalidation-reference.json` — automated-results、evidence-manifest、accepted report、accepted checklist、manual-attempt-003のexact path／bytes／SHA-256 rowsを必須とする
- `setup-identity.json`
- `source-hashes.json`
- `manual-closure-results.json`
- Session A／Bのcommand、stdout、stderr、numeric exit
- prompt／reply provenance
- `scope-audit.json`
- `cleanup-boundary.json`
- `manual-artifact-manifest.json`
- `evidence-manifest.json`

旧evidenceをcopyしない。reference JSONはaccepted SHA、path、bytes、SHA-256だけを指す。ログをnormalizationする場合はrawと呼ばず、original／normalized bytesとSHA、変換内容、semantic equality、byte-exact reconstructionを記録する。

## Result classification

- `Pass / promotion recommended`
  - rows `3–20`が`18 / 18 Pass`。
  - accepted rows `1`、`2`、`21`と合わせてmanual `21 / 21 Pass`。
  - current feel／readabilityにblocking negative findingがない。
  - candidate defect `0`。
- `Technical Pass / promotion pending manual KBM and/or user feel`
  - manualに`Not run`／`Blocked`が1件以上残り、candidate defectが未確定または`0`。
- `Technical Pass / promotion not recommended — playability finding`
  - functional closureはPassしたがreadability／feelにnegative findingがある。
- `Fail / candidate`
  - frozen candidateの再現可能なmanual functional defect。
- `Blocked / setup identity`
  - branch／HEAD／tracking／live origin、ancestry、prototype tree、starting byte identityが通知値と一致しない。
- `Blocked / QA infrastructure`
  - fresh import、launcher、host、evidence captureがcandidate評価前に停止。
- `Blocked / shared contract`
  - Approved contractでは一意に分類できない。

candidate Fail発見時も修正せず、安全に独立確認できる他項目は続行する。共有契約変更が必要な項目だけ停止し、00へ返す。

## Commit and push protocol

1. report、checklist、manual evidence、QA handoff appendをcontent commitにする。
2. content commit SHAをmanifestの`summary_snapshot_tip`へ固定し、全current artifactのsize／SHAをreadbackする。
3. `evidence-manifest.json`だけをmanifest-only child commitにする。
4. amend、rebase、mergeを行わない。
5. issuance→final、content、manifest各rangeの`git diff --check`をPassする。
6. changed pathsがallowlist内で、protected／candidate／test／prototype差分`0`であることを確認する。
7. branchをpushする。
8. local HEAD／tracking ref／live originのexact一致とworktree cleanを確認する。

manual stage／tarはGUI正常終了、Godot process `0`、durable commit／push後も保持する。30はcleanupせず、00がReturnを受理した後だけpath／type／archive bytes／SHAを再確認してexact cleanupする。

## Return protocol

30は00へ次をdirectに返す。

- branch、worktree、final tip、local／tracking／live origin、clean
- integration上のportable work-order source SHA → QA branch上のcherry-pick issuance SHA対応、issuance→final全commit列、merge count
- exact changed paths、allowlist、protected／candidate／test／prototype差分
- candidate、review、accepted QA final、integration acceptance、issuance、finalのidentity／ancestry
- prototype tree `2a66e4c06308a47678e8888a739b87ffd33d1ee8`不変
- fresh archive／Godot／import／global class cache identity
- Session A／Bのcommands、numeric exits、Godot process state
- rows `3–20`の18個別resultとaggregate
- accepted rows `1`／`2`／`21`を含む21-row total
- exact prompt／user quote、current feel／readability、candidate finding count
- report／checklist／evidence／handoff、manifest count、size／SHA readback
- recommendation、Not run、shared-contract change要否
- retained stage／tarのexact path、bytes／SHA、cleanup boundary

30は本票からintegration branch、`prototype/fast-vertical-slice`、mainへmerge／pushしない。`Pass / promotion recommended`を返してもpromotion／Gate actionは00の別review／別commitまで未承認である。
