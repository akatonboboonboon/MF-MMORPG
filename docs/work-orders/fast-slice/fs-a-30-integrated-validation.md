# MFO-WO-FS-A-30-002 — FS-A Integrated Validation

- Status: `Returned / 00 accepted Technical Pass / promotion pending manual KBM and/or user feel`
- Issued: `2026-08-14`
- Returned / technical result accepted: `2026-08-14`
- Issuer: `00統括（監督）`
- Assignee / QA-path single writer: `30 QA・性能・レビュー`
- Branch: `codex/fast-slice-fs-a-validation`
- Worktree: `C:\tmp\mf-fs-a-val`
- Milestone: `FS-A`
- Authority: `docs/FAST_SLICE_CONTRACT.md` and this work order
- Frozen integration candidate source: `867899c7ccb9380b4bb6e4be5c51da4223532230`
- 00 review record parent: `d79b542ec42f34306a0370b07752e732dcf0c7fc`
- Frozen candidate prototype tree: `5f948fa5b09dc970beab5afef6c21260ecd74edf`
- Issued / tested source: `3cdf6dbd9031e3d05fd2a049c851f19409d7b592`
- Accepted QA final tip: `55d76633d73bd042be46260746da4e55bb35e145`
- Accepted result: required automation `17 / 17` exit `0`; Contract Section 10 technical items `13 / 13` Pass; manual KBM／readability／user feel `Not run`
- Branch setup rule: 00 commits this issued order on the review record, then creates and pushes the validation branch from that issuance commit. The exact issued tip is delivered directly to 30 after identity verification.
- Authorized scope: frozen integration candidateのfocused technical／KBM validationとowned report／evidence only
- Forbidden scope: candidate repair, gameplay／presentation値変更, maximum-load／P95／large harness, strict Gate action
- Report path: `docs/test-reports/fast-slice/fs-a-integrated-validation.md`
- Evidence root: `docs/test-reports/evidence/fast-slice/fs-a-integrated-validation/`
- Handoff: `docs/handoffs/fast-slice/qa.md`

## Issue condition

次を00が確認したため発行する。

- integration candidate source `867899c7ccb9380b4bb6e4be5c51da4223532230`を00 review済みPassとしてfreezeした。
- review record `d79b542ec42f34306a0370b07752e732dcf0c7fc`はcandidate sourceの直系1 commit後で、差分は00-owned integration handoff 1件だけ。
- 両tipの`material-frontier-online/prototype` treeは`5f948fa5b09dc970beab5afef6c21260ecd74edf`でexact一致する。
- integration worktreeのlocal HEAD、tracking ref、live originは`d79b542ec42f34306a0370b07752e732dcf0c7fc`で一致しcleanだった。
- validation branch／tracking ref／live origin／`C:\tmp\mf-fs-a-val`は発行準備時にすべて不存在だった。
- 2026-08-14のユーザー指示「続きをどうぞ」は既定のintegrated validation工程を進める許可であり、user-feel結果、promotion、Gate判定の承認ではない。

## Start identity and history rules

30は00からexact issued tipを受領した後、次を満たしてから開始する。

1. validation worktreeが`C:\tmp\mf-fs-a-val`、branchが`codex/fast-slice-fs-a-validation`である。
2. local HEAD、`origin/codex/fast-slice-fs-a-validation` tracking ref、live originが00のissued tipとexact一致する。
3. worktreeがcleanで、tracked／untracked差分が`0`である。
4. `867899c7ccb9380b4bb6e4be5c51da4223532230`がHEADのancestorで、HEADのprototype treeが`5f948fa5b09dc970beab5afef6c21260ecd74edf`とexact一致する。
5. branch historyをreset、rebase、amendせず、00-owned issuance／review historyを保持する。
6. QA-prep worktree／branchを再利用・再編集せず、このvalidation worktreeだけで作業する。

identity不一致時は修復を推測せず00へ返す。

## Writable paths

30は次と対応する`.uid`だけを新規作成または編集できる。

- `material-frontier-online/prototype/tests/fast_slice/**`
- `docs/test-reports/fast-slice/fs-a-integrated-validation.md`
- `docs/test-reports/evidence/fast-slice/fs-a-integrated-validation/**`
- `docs/test-reports/fast-slice/fs-a-kbm-checklist.md`
- `docs/handoffs/fast-slice/qa.md`

既存のQA-prep report／evidenceはhistorical recordとして上書きしない。新しい結果はintegrated-validation専用pathへ追加する。

既定は凍結済みintegration self-checkと既存runnerのread-only実行であり、新規runnerは不要とする。`tests/fast_slice/**`の変更は、再現可能なQA-owned fixture／launcher defectまたはcoverage gapがvalidationを阻害する場合のbounded repairだけに限定し、理由とidentityを先にreportへ記録する。

## Read-only candidate and forbidden scope

次はread-onlyであり、30は変更しない。

- `material-frontier-online/prototype/scripts/fast_slice/gameplay/**`
- `material-frontier-online/prototype/scenes/fast_slice/gameplay/**`
- `material-frontier-online/prototype/data/fast_slice/**`
- `material-frontier-online/prototype/scripts/fast_slice/presentation/**`
- `material-frontier-online/prototype/scenes/fast_slice/presentation/**`
- `material-frontier-online/prototype/scripts/fast_slice/integration/**`
- `material-frontier-online/prototype/scenes/fast_slice/fs_a_main.tscn`
- `material-frontier-online/implementation/fast-slice/**`
- `material-frontier-online/prototype/project.godot`、`export_presets.cfg`、Input Map、autoload
- legacy Phase 1／Slice 2-A／Stage B tests、既存strict evidence
- `docs/FAST_SLICE_CONTRACT.md`、`docs/DECISIONS.md`、`docs/MASTER_SPEC.md`、`docs/MILESTONES.md`、`docs/work-orders/**`
- 10／20／integration handoff

candidate Gameplay／Presentation／integration implementation、`fs_provisional`値、snapshot authority、event meaningをtest通過のために修正しない。`boss_hp`をcanonical contract fieldとして検証し、未承認の`enemy Integrity` alias／同値性を追加・仮定しない。

networking、server、account、persistence、music、SE、voice、production art、maximum-load、P95、real A／B／C matrix、long-run harness、strict Gate actionは本票のscope外である。物理gamepadは`Not run / Deferred`とし、KBM結果でPassにしない。

QA-owned runner／launcher defectはcandidate実装へ触れないbounded repairだけを許可する。修正commit、再実行理由、pre-fix／post-fix identityをreportへ分離記録する。candidate FailをQA infrastructure Passへ、またはその逆へ読み替えない。

## Required execution

### A. Preflight and source evidence

- branch／HEAD／tracking／live origin／clean identityを保存する。
- frozen candidate source、issued tip、test source開始hashを記録する。
- candidate sourceからissued tipまでが00-owned docsだけで、prototype treeが同一であることを確認する。
- excluded-systems auditはcandidate delta `62f4af4a105b45f458beabecd6595ad5f58ec764..867899c7ccb9380b4bb6e4be5c51da4223532230`とvalidation delta `issued tip..HEAD`を分離する。
- writable／read-only path allowlistを固定し、開始時scope auditを保存する。
- Godot identityが`4.7.stable.official.5b4e0cb0f`であることを確認する。

### B. Automated focused validation

fresh temporary copyまたはfresh import stateで、少なくとも次を実行する。

1. Godot headless editor import。
2. integration root／self-check parse。
3. `res://scripts/fast_slice/integration/fs_a_integration_self_check.gd`。
4. `res://scenes/fast_slice/fs_a_main.tscn`のheadless launch。
5. Gameplay parse／self-check／scene smoke。
6. Presentation self-check／pure shell／preview smoke。
7. QA candidate-independent fixture。これは準備fixtureでありcandidate Passの代替にしない。
8. existing project main smoke。
9. Phase 1、Slice 2-A `120 assertions`、Slice 2-A correction `39 assertions`のregression guardrail。
10. `git diff --check`、changed-path audit、generated artifact cleanup、post-run clean確認。

Slice 2-B Stage B action-kernel `184 assertions`はoptional／non-blocking inherited guardrailとしてread-only実行できる。結果はFS-A判定と別分類し、未実行またはFailをFS-A candidate Failへ帰属させない。

integration self-checkのactive-empty／unknown shape warning exact 4件は意図的fixtureかを照合し、他warning／errorと区別する。assertion総数自体をacceptance条件にしない。

### C. Manual KBM and playability finding

userまたは明示的に委任されたplaytesterが、既存KBM checklistを使って次を確認する。30は自動実行結果で主観評価を代用しない。

- move／aim／evade。
- light／heavyの別操作・別timing。
- line／sector telegraphの識別と回避。
- Integrity／Deformation、part break、boss defeat、functional stop。
- wreck、exact 3 harvest、result。
- rematch完全resetと二周目主要操作。
- 色だけに依存しない危険表示、対象、HUD、resultの読みやすさ。

manual integrated sessionの入口は次に固定し、Presentation preview sceneを判定に使わない。

```powershell
$Godot = 'C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe'
$FreshProject = '<fresh-stage>\material-frontier-online\prototype'
& $Godot --path $FreshProject --scene res://scenes/fast_slice/fs_a_main.tscn
```

Controls: `WASD` move、mouse aim、`LMB` light、`RMB` heavy、`Space` evade、`E` harvest／rematch。

technical functional resultと操作感／読みやすさコメントを別fieldで記録する。manual KBMまたはuser feelが未実施でもcandidate technical Failにせず、`Technical Pass / promotion pending manual KBM and/or user feel`とする。

### D. Optional normal release smoke

通常release export／smokeの既定分類は`Not run`とする。automated／KBM findingがrelease-only behaviorを具体的に示す場合、または00がexact triggerを通知した場合だけ、既存presetとtoolchainで追加変更なしに実行できる。`export_presets.cfg`を変更しない。Not runでもtechnical acceptanceをFailにしない。

### E. Evidence and cleanup

- report、QA handoff、新規evidenceへexact commands、expected／actual、exit codes、observed anchors、environment、Not run、known limitationsを記録する。
- test source開始identityと、QA-owned追加／修正runnerのfinal identityを両方記録する。
- 13 technical items、manual KBM、user feel、gamepad、performance、exportを個別に`Pass / Fail / Blocked / Not run / Deferred`分類する。
- temporary stage／archive／generated outputをexact path確認後にcleanupし、repository内容を削除しない。
- smoke後のworktree差分はQA writable pathsだけとし、engine生成物をcommitしない。

## Contract Section 10 acceptance mapping

次の13項目を個別に判定する。

1. 専用scene import／parse／launch。
2. move／aim／evadeの既存挙動維持。
3. light／heavyの別操作・別timing。
4. enemy attack 2種の予告と回避。
5. player Integrity／Deformation変化とrematch初期化。
6. partを1個以上破壊。
7. boss HP 0遷移exact once。
8. defeat後のAI／attack／hit停止。
9. wreck exact once。
10. harvest point exact 3、重複回収拒否。
11. 全回収後のresult表示。
12. rematch完全初期化と二周目主要操作。
13. Presentation無効時のGameplay結果不変。

## Acceptance

- source／test identity、scope、commands、results、Not runがreport／handoff／evidence間で一致する。
- import／parse、automated one-loop、dedicated scene、required Phase 1／Slice 2-A／correction regressionがPassする。optional Stage Bは別分類する。
- Contract Section 10の13項目を個別判定し、未実行項目をPassにしない。
- KBM一周、result、rematch、二周目とuser feelを自動結果から分離して記録する。
- Presentation無効時のGameplay結果不変とexcluded systems不在を確認する。
- candidate／共有契約／protected path差分が`0`、QA変更がWritable paths内だけである。
- `git diff --check`がexit `0`で、worktreeはReturn commit後にcleanである。

## Recommendation classification

- `Pass / promotion recommended`: automated technical validation、required KBM functional check、user feel reviewがPass。00へpromotionを勧告できるが、自動promotion／Gate actionは行わない。
- `Technical Pass / promotion pending manual KBM and/or user feel`: automated technical validationはPassだが、manual KBMまたはuser／delegated playtester評価が未完了。candidate Failではない。
- `Technical Pass / promotion not recommended — playability finding`: automated technical／KBM functionalはPassしたが、実施済みuser-feel／readability findingがnegative。candidate technical defectやGate Failとは扱わない。
- `Fail / candidate`: frozen candidateの再現可能なparse／assertion／functional defect。candidateだけを停止する。
- `Blocked / QA infrastructure`: QA-owned runner、launcher、host conditionでcandidateを評価できない。candidate defectへ帰属しない。

Gamepad、performance／P95／maximum load／long-run、optional exportのNot runは、上記classificationと別に保持する。本票はstrict Gate証拠を作らず、Gate Passを主張しない。

## Return protocol

30はQA-owned commitをvalidation branchへpushし、00 Integration taskへ直接次を返す。ユーザーの中継を待たない。

- branch、final tip、local HEAD／tracking ref／live origin identity、worktree clean。
- issued tipからfinal tipまでの全commitを時系列順に列挙。
- changed paths、scope audit、candidate／protected path差分`0`。
- frozen candidate／issued tip／test source／final test sourceのidentity。
- exact commands、exit codes、observed anchors、warning分類。
- 13 technical item、manual KBM、user feel、gamepad、performance、exportの個別結果。
- report、handoff、evidence pathとhash／readback結果。
- recommendation、Not run、known limitations、共有契約変更要否。

共有契約変更が本当に必要な場合だけ該当validationを停止して00へ報告する。それ以外は発行済みscope内で承認待ちせず継続する。

## 2026-08-14 Return acceptance

- Validation commit列は`2bbe3a874f0b68e800faad5125bb3e6d60f461a3`、`9944abfe7ac1f73d8351fa29b6f3a616c252c7b6`、`3afe5782639450b5b3011eb24657a2ad196afc18`、`55d76633d73bd042be46260746da4e55bb35e145`の直線4 commit、merge `0`。
- final tipのlocal HEAD、tracking ref、live originはexact一致し、validation worktreeはclean。
- issued tipからfinal tipまでのchanged pathsはexact `61`、allowlisted `61`、unexpected／protected／production／QA runner差分`0`。candidateからfinalまでのprototype deltaも`0`で、treeは`5f948fa5b09dc970beab5afef6c21260ecd74edf`のまま。
- required automationは`17 / 17` invocationがexit `0`。expected warningはactive-empty `2`＋unknown-shape `2`のexact `4`、unexpected warning／ERROR／SCRIPT ERROR／terminal FAILは`0`。
- Contract Section 10 technical itemsは個別に`13 / 13 Pass`。durabilityはcanonical `boss_hp`だけを検証し、enemy Integrity alias／equivalenceは追加・仮定していない。
- execution artifactsは`51 / 51`、evidence summaryは`9 / 9`のsize／SHA-256 readback一致。7件のexecution log normalizationはoriginal blob identityとEOF-only 1 byte差分を独立再確認した。
- 00の独立scope／evidence／acceptance reviewはtechnical blocker `0`。QA handoff headerとevidence snapshot manifestのdoc-only findingはfollow-up commitで閉じた。
- manual KBM、readability、user feelは`Not run`。物理gamepad、performance／P95／maximum load／long-runは`Deferred / Not run`、optional exportとStage B 184は`Not run`。
- 受理分類は`Technical Pass / promotion pending manual KBM and/or user feel`。共有契約変更、candidate repair、promotion、Gate actionは行っていない。
- Frozen integration candidate sourceは引き続き`867899c7ccb9380b4bb6e4be5c51da4223532230`であり、QA final tipをimplementation sourceへ言い換えない。

## Promotion boundary

30は`prototype/fast-vertical-slice`へmerge／pushしない。Pass recommendation、user feel、scope evidenceを00がreviewした後だけ、00が別工程としてpromotionを判断する。FS-A結果はplayability findingであり、正規Gate証拠ではない。
