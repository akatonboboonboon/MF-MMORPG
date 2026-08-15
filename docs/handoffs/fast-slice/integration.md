# Fast Slice Integration Handoff

- Status: FS-A opening-spawn and defeat-retry decisions approved / Gameplay rework order preparation; promotion stopped
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

### Historical automated FS-A technical acceptance status

| # | Contract item | Result |
|---:|---|---|
| 1 | 専用scene import／parse／launch | Pass |
| 2 | move／aim／evadeの既存挙動維持 | Pass — Gameplay self-check＋Phase 1回帰 |
| 3 | light／heavyの別操作・別timing | Pass — Gameplay／integration self-check |
| 4 | enemy attack 2種の予告と回避 | Pass — Gameplay／integration self-check |
| 5 | player Integrity／Deformation変化とrematch初期化 | Pass |
| 6 | partを1個以上破壊 | Pass |
| 7 | boss HP 0遷移exact once | Pass |
| 8 | boss HP 0後のAI／attack／hit停止 | Pass |
| 9 | wreck exact once | Pass |
| 10 | harvest exact 3、重複回収拒否 | Pass |
| 11 | 全回収後のresult表示 | Pass |
| 12 | rematch完全初期化と二周目主要操作 | Pass |
| 13 | Presentation無効時のGameplay結果不変 | Pass |

この表はsynthetic command／headless automationのhistorical結果である。2026-08-15 manual-002でitem 2のuser-visible parityとcombat usabilityがFailし、player defeat pathが未検証だったことを確認したため、promotion根拠には使用しない。boss HP 0経路のautomation Passをplayer `Integrity == 0`経路へ読み替えない。

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

## 2026-08-14 integrated validation Return acceptance (historical technical snapshot)

- Validation branch: `codex/fast-slice-fs-a-validation`。historical technical／pre-manual accepted tip: `81c6643b71940ca8bbf1c68d3c9ce47917b9111c`。
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
- Historical result at this snapshot: `Technical Pass / promotion pending manual KBM and/or user feel`。後続manual-002のFailは下節で別記し、このtechnical snapshotを上書きしない。共有契約変更、candidate repair、promotion、Gate actionは`0`。
- Frozen implementation candidate sourceは`867899c7ccb9380b4bb6e4be5c51da4223532230`のまま。QA final tipはvalidation evidence／handoff identityであり、implementation sourceではない。

## 2026-08-15 manual-002 functional Fail and promotion stop

- Corrected manual stage `C:\tmp\mf-fs-a-val-manual-20260814-002`はtested source `3cdf6dbd9031e3d05fd2a049c851f19409d7b592`のarchiveから作成し、archive SHA-256は成功済みautomationと同じ`0b533e046564c2748511bf53924b3c96600832e7b5fbad41307c2f583e487458`だった。fresh editor importはexit `0`、`global_script_class_cache.cfg`生成後に実`fs_a_main.tscn`を起動したため、attempt-001のpreparation defectは再発していない。
- Exact direct evidence: `移動ができない`。initial `HPが0になっても続く`。later clarification message `0後もボスが攻撃してきました。そもそもこっちの攻撃が敵に届いていないので`。後者ではboss attackの継続とattack reachが同一message内でこの順に報告され、field identityは直接特定されていない。
- 00 inference／determination: attackが敵へ届かず`boss_hp`減少が成立していないという同じ観察から、0になった表示をplayer `INTEGRITY`と判定した。これはuserの直接field識別ではない。
- Presentation root cause: authority `PlayerActor`はsceneで`visible = false`だが、pure shellのKnight、enemy、attack feedback、telegraph、harvest markerは固定座標で、既存snapshotのauthority spatial fieldを描画へ使用していない。内部authority移動の成否にかかわらず、move／aim／evadeとattack reachをmanual画面で観察できない。
- Combat reach boundary: authority初期距離はplayer→part `745 px`、player→boss `830 px`で、heavyのradius込み命中範囲はpart `262 px`、boss `306 px`。移動表示が固定のため、userはauthority上の接近／aim／射程を判断できない。現時点ではPresentation spatial-parity defectとManual functional Failを確定し、別のGameplay hit-query defectは未確定とする。
- Player defeat root cause: candidateは`player_integrity`を0へclampするだけで、positive→0敗北をlatchせず、player motion／evade／action／hit-query／pending-actionを停止しない。上位Approved仕様は`Integrity == 0`をplayer敗北とし、凍結済みminimum prototype scopeはplayer機能停止を要求する。userの直接観察はboss attack継続までであり、pending enemy hit／enemy処理guard欠落はsource inference／corroborationとして分離する。2026-08-15のuser Option A承認により、player敗北時のenemy停止scopeはFS-A branch-local normalizationとして確定した。
- Classification: `Manual KBM functional Fail / promotion stopped`。required automation `17 / 17`とtechnical `13 / 13`はhistorical evidenceとして保持するが、manual Pass、FS-A acceptance、promotion、Gate Passへ昇格しない。
- Accepted QA final tip: `3968be22d206bb66602dfc23efeb6bb372211461`。manual evidence content tipは`0cfebd4b790ba91890d169de60a3e07a674c6ad0`、manifest-only tipは`3968be22d206bb66602dfc23efeb6bb372211461`。local HEAD、tracking ref、live originはfinal tipとexact一致し、worktree／index／untrackedはclean。
- Issued tip `3cdf6dbd9031e3d05fd2a049c851f19409d7b592`からfinal tipまでは直線`12` commit、merge `0`、exact `63` changed paths／allowlisted `63`、unexpected／protected／production／test／shared-contract差分`0`、full `git diff --check` exit `0`。candidate→final prototype deltaは`0`で、treeは`5f948fa5b09dc970beab5afef6c21260ecd74edf`のまま。
- Manual results: original `17` rowsは`0 Pass / 4 Fail / 11 Blocked / 2 Not run`、supplemental `2` rowsは`2 Fail`、total `19` rowsは`0 Pass / 6 Fail / 11 Blocked / 2 Not run`。historical automated `17 / 17` exit `0`とtechnical `13 / 13 Pass`は不変。
- Evidence manifest snapshotはcontent tip `0cfebd4b790ba91890d169de60a3e07a674c6ad0`、summary `11 / 11`のcurrent size／SHA-256一致、mismatch `0`、self-excluded。00のscope／semantic／manifest独立監査はいずれもPass、blocking finding `0`。
- Shared-contract decision: userは2026-08-15に`OQ-00-20260815-001`と`OQ-00-20260815-002`を双方Option Aで承認した。required spatial seamとplayer-defeat stop normalizationをContract／Decisionsへ同期した。frozen candidate、`fs_provisional`、boss loop、retry／event境界は変更しない。
- OQ-005 boundary: defeated retryのaction／edge／同command消費はOpenのまま。今回の最小修正で`E`をretryへ流用せず、新phase／field／event／UIや自動retryを追加しない。
- Owner routing after approval: 10はplayer defeat authorityとno-teleport traversal／hit self-check、20は既存authority spatial snapshotのread-only描画、30はtargeted regression＋full fresh automation＋manual再検証を担当する。integration側でcandidate owner fileを手修正しない。
- Frozen implementation candidate sourceは`867899c7ccb9380b4bb6e4be5c51da4223532230`のまま。QA final tipはvalidation evidence／handoff identityであり、implementation sourceではない。
- Userはmanual GUIを終了済みで、cleanup直前のGodot processは`0`。00はpath／type、archive `481280` bytes／SHA-256 `0b533e046564c2748511bf53924b3c96600832e7b5fbad41307c2f583e487458`を再確認後、exact `C:\tmp\mf-fs-a-val-manual-20260814-002`と同`.tar`だけを削除した。cleanup後は双方不存在で、cleanup操作によるrepository／evidence／candidate差分`0`（本handoff記録を除く）。

### Resume condition

1. [Completed] Userが2026-08-15にspatial seamとplayer-defeat stop normalizationを双方Option AでApprovedし、00が`FAST_SLICE_CONTRACT.md`／`DECISIONS.md`／`OPEN_QUESTIONS.md`へ同期する。
2. [Completed] 00が`MFO-WO-FS-A-10-002`と`MFO-WO-FS-A-20-002`を別々のexact-scope票として発行し、両owner Returnをreviewした。frozen source candidateのamend／rebaseはなく、issuance tipからの直線commit列を返却した。
3. [Completed / Technical Pass] 10→20統合後のfrozen candidateに対する`MFO-WO-FS-A-30-003`のfresh automationとbounded manual revalidation Returnをreviewした。technical `15 / 15`はPass、manualは`3 Pass / 0 Fail / 0 Blocked / 18 Not run`で、promotionはremaining manual KBM／readability／user feelのため停止を維持する。
4. [Completed / Technical Pass] `MFO-WO-FS-A-30-004`のmanual-only Returnをreviewした。rows `3–20`は`10 Pass / 0 Fail / 0 Blocked / 8 Not run`、accepted rowsを含む21行は`13 Pass / 0 Fail / 0 Blocked / 8 Not run`。candidate defectは`0`だが、remaining manual KBM／readability／user feelのためpromotionは停止を維持する。

## 2026-08-15 Option A approval

- User instruction: `OQ-00-20260815-001/-002を双方Option Aで承認`。
- `OQ-00-20260815-001`: 既存Gameplay snapshotの列挙済みspatial fieldをFS-A required seamへ昇格し、20がauthority arenaと同一座標系でread-only描画する。integrationの別座標mapping、source write-back、authority意味の変更は行わない。
- `OQ-00-20260815-002`: `player_integrity` positive→0をexact once latchし、authority resetまでplayer move／evade／action／hit query／pending actionとenemy AI／telegraph／attack／pending hitを停止する。boss HP／`boss_functional`／parts／wreck／harvest／resultは不変。
- `OQ-001`と`OQ-005`はOpenのまま。新phase／snapshot field／event／UI／retry binding／自動retryは追加せず、`E`をretryへ流用しない。
- `fs_provisional` label／値／意味、既存boss defeat loop、historical automation、manual Fail、frozen candidate sourceは変更しない。

## 2026-08-15 owner rework issuance

- Contract decision commit: `bf89fcd26cde65659e7addc97952fb9f9fc1dc58`（`docs: approve FS-A Option A contracts`）。
- Work-order issuance tip: `e09bf9ae8444af1570e32819096c069dca370eb5`（`docs: issue FS-A owner rework orders`）。integration local HEAD／tracking ref／live originはpush後にexact一致し、worktreeはcleanだった。
- Gameplay: `MFO-WO-FS-A-10-002`、branch `codex/fast-slice-fs-a-gameplay-rework`、worktree `C:\tmp\mf-fs-a-10-rework`。
- Presentation: `MFO-WO-FS-A-20-002`、branch `codex/fast-slice-fs-a-presentation-rework`、worktree `C:\tmp\mf-fs-a-20-rework`。
- 両new branchはissuance tip `e09bf9a...`から作成してpushした。各local HEAD／tracking ref／live originはexact `e09bf9a...`、worktree clean、Contract foundation ancestry exit `0`。
- Gameplay 3 writable source blobsはfrozen source identity `17773c5f186dfbbd1a1e52a304df123b76d9ad35`とexact一致し、Presentation 3 writable source blobsは`04893d6d304e0d23a68df0bd1afc2fa8e71cc461`とexact一致した。frozen source SHAはnew branchのancestorではなくsource identityで、candidate ancestryはissuance tip→rework final tipとする。
- frozen Gameplay／Presentation source worktreeはcleanのまま。reset／rebase／amend、candidate code変更、integration-side owner file編集は`0`。
- 初回Gameplay worktree addは既存QA evidenceのlong path checkoutで停止した。directory／worktree entryは残らず、correct issuance SHAのlocal branch refだけを確認した。repository-local `core.longpaths=true`を設定後に同refを再利用してcheckoutを完了し、source／history／tracked file差分`0`を確認した。
- 10と20は並行実装できるが、00のreview／cherry-pick順は10→20。両returnと基礎smokeがPassするまで30 revalidation票を発行しない。

## 2026-08-15 Option A owner rework integration acceptance

- Decision: `Pass / reworked integrated candidate ready for dedicated QA revalidation`。これはmanual KBM／readability／user feel、physical gamepad、performance、export、promotion、GateのPassではない。
- Pre-integration setup record: `7f780d13b543d147651f12df9eb702cb09122263`。取り込み直前のlocal HEAD／tracking ref／live originはexact一致し、worktreeはcleanだった。
- Reworked integrated candidate source: `f03a43d2339e9772a15db1c591a31f5e4f92cca2`。prototype treeは`2a66e4c06308a47678e8888a739b87ffd33d1ee8`。
- Gameplay Return: branch `codex/fast-slice-fs-a-gameplay-rework`、final tip `817f45a02ed44492084c3f7b864125451eb365b1`、tested implementation `4eb47f83a093c9fe537577889dacaa888a0855b4`。
- Presentation Return: branch `codex/fast-slice-fs-a-presentation-rework`、final tip `fc509551f01a5f5ae9a82986876856542e1f8b85`、tested implementation `73c6242f127b2d3d7d989ddebc17a2ea22d63537`。
- 両Returnはlocal HEAD／tracking ref／live originがfinal tipとexact一致し、worktree clean。各3 linear commits、merge `0`、exact 5 owned paths、各commit／累積`git diff --check` exit `0`、tested implementationとfinal prototype tree／source blobs一致を確認した。
- 10と20のchanged-path intersectionは`0`。Gameplay／Presentation／integration／QA／scene／UID／data／project／shared-contract間のscope違反と競合は`0`で、integration側の手修正も`0`。

### Rework source SHA to integration SHA

| Role | Source SHA | Integration SHA | Scope |
|---|---|---|---|
| 10 implementation | `4eb47f83a093c9fe537577889dacaa888a0855b4` | `9f77a02a7965ff1efcb4b7175ae30d9c1a515bf4` | exact 3 Gameplay source paths |
| 10 report | `d0ef924a6854edee9b8304e34b13d5811efd5fd0` | `11db93ccf623afba0becbe5aef43855e86e29395` | new Gameplay rework report only |
| 10 handoff | `817f45a02ed44492084c3f7b864125451eb365b1` | `922ef6652b606fb84b3b72b19e96e90e7690b965` | Gameplay handoff only |
| 20 implementation | `73c6242f127b2d3d7d989ddebc17a2ea22d63537` | `29993fdac66cec951d60bb289446eead87bcd7f5` | exact 3 Presentation source paths |
| 20 report | `96c3534f24f96babd2b5374c861d0d8d9773f95e` | `113c851c13c6491d6757900feb75fc4a7bd8d162` | new Presentation rework report only |
| 20 handoff | `fc509551f01a5f5ae9a82986876856542e1f8b85` | `f03a43d2339e9772a15db1c591a31f5e4f92cca2` | Presentation handoff only |

Review済みcommitは指定どおり10→20の順でcherry-pickした。統合range `7f780d1...f03a43d`は直線6 commits、merge `0`、exact 10 disjoint paths、full `git diff --check` exit `0`。

### 00 fresh smoke after Gameplay integration

Gameplay integration HEAD `922ef6652b606fb84b3b72b19e96e90e7690b965`、prototype tree `678fd4de5f0808e55cd897ca01d8ebcef5e808d3`のGit archiveからfresh stageを作成した。archive SHA-256は`ff0c58e049b0c1bb865e718be2cc943e3d69701f09813d78fbb9b15c74d2de2e`、pre-import `.godot=False`。

Godot `4.7.stable.official.5b4e0cb0f`、fresh editor import、Gameplay／integration parse、Gameplay `PASS: full gameplay loop`、Gameplay arena、Integration `checks=236`、`fs_a_main.tscn`、Presentation pure shell、QA candidate-independent fixture、project main、Phase 1、Slice 2-A `120`、correction `39`、range diff-checkはすべてexit `0`。expected integration warningsはactive-empty／unknown shapeのexact `4`のみ。結果確認後、exact stage／tarを削除し双方不存在を確認した。

### 00 fresh smoke after Gameplay plus Presentation integration

Combined candidate `f03a43d2339e9772a15db1c591a31f5e4f92cca2`のGit archiveから別のunique fresh stageを作成した。archive SHA-256は`885d6585067c81d781a82bf204188441678881591e19e4549bbdbd628c1f3a79`、pre-import `.godot=False`。

Godot identity／fresh editor import、Gameplay 3 scripts、Presentation 3 scripts、integration 2 scriptsのparseはすべてexit `0`。Gameplay self-checkは`PASS: full gameplay loop`。Presentation self-checkは`snapshots=5 spatial_schema=true anchors=40 geometry=line+sector tracking_positions=5 tracking_aims=3 events=3 payload_variants=9 invalid_updates=20 deep_read_only=true`。Integration self-checkは`self_check=PASS checks=236 shapes=3 events=3 one_loop=true presentation_parity=true`。

Gameplay arena、Presentation pure shell／preview、実`fs_a_main.tscn`、QA candidate-independent fixture、project main、Phase 1、Slice 2-A `120`、correction `39`、full range diff-checkはすべてexit `0`。Presentationのexpected invalid-spatial warnings exact `20`とintegrationのexpected warnings exact `4`をfixture由来として分離した。結果確認後、exact stage／tarを削除し双方不存在を確認した。

Owner reworkはApproved Option A内で閉じ、追加shared-contract変更、`fs_provisional`変更、新phase／snapshot field／event／UI／retry bindingは`0`。OQ-001とOQ-005はOpenのまま。manual-002 historical Failは上書きせず、dedicated QA revalidationでmove／aim／evade、射程外miss／射程内light・heavy hit、player defeat stop、boss defeat、wreck／3 harvest／result／rematchを再確認するまでpromotion stoppedを維持する。

## 2026-08-15 Option A integrated revalidation issuance

- Work order: `MFO-WO-FS-A-30-003` / `docs/work-orders/fast-slice/fs-a-30-integrated-revalidation.md`。
- Frozen reworked candidate source: `f03a43d2339e9772a15db1c591a31f5e4f92cca2`。00 review record: `ba688730e57564bbb883035972bba9ff2224cd50`。prototype tree: `2a66e4c06308a47678e8888a739b87ffd33d1ee8`。
- Work-order issuance commit: `29c22763c41abaace46430395dd1bdfd14caaf66`。integration branchでcommit／pushし、作成時のlocal HEAD／tracking ref／live originがexact一致、worktree cleanを確認した。
- New branch／worktree: `codex/fast-slice-fs-a-revalidation`／`C:\tmp\mf-fs-a-reval`。issuance commit `29c22763c41abaace46430395dd1bdfd14caaf66`から作成し、local HEAD／tracking ref／live originが同SHAでexact一致、worktree／index／untracked cleanを確認した。
- Candidate `f03a43d2339e9772a15db1c591a31f5e4f92cca2`とreview record `ba688730e57564bbb883035972bba9ff2224cd50`はissuance HEADのancestor。3点のprototype treeはすべて`2a66e4c06308a47678e8888a739b87ffd33d1ee8`で、candidate→issuanceは00-owned handoff／work orderのexact 2 docs、prototype delta `0`。
- Old validation branch／worktree／final `3968be22d206bb66602dfc23efeb6bb372211461`はhistorical siblingとしてclean／frozenを維持し、merge、cherry-pick、checkout、編集、cleanup、再利用しない。
- New QA writable scopeは新report、新KBM checklist、新evidence root、QA handoff append-onlyの4範囲だけ。candidate、test code、旧report／checklist／evidence、owner handoff、contract／work orderはread-only。
- Required orderはfresh archiveの22 automated invocations、Option A targeted anchors、Contract Section 10の15項目、manual 21 rows／2 sessions。旧`17 / 17`、旧`13 / 13`、manual `0 / 6 / 11 / 2`はhistorical結果として分離する。
- OQ-001／OQ-005はOpenのまま。physical gamepad、performance／P95／maximum load／long-run、exportはNot run／Deferredを独立分類し、本票ではpromotion／Gate actionを行わない。

## 2026-08-15 Option A integrated revalidation Return acceptance

- Decision: `Technical Pass / promotion pending manual KBM and/or user feel`。`MFO-WO-FS-A-30-003`のcorrected Returnを受理する。promotionは停止を維持し、promotion／Gate actionは`0`。
- QA branch／worktreeは`codex/fast-slice-fs-a-revalidation`／`C:\tmp\mf-fs-a-reval`。accepted final tipは`ca15f57e6c3c23658d602cfa93212e8e91de2064`で、local HEAD／tracking ref／live originはexact一致、worktree／index／untrackedはclean。issued／tested sourceは`29c22763c41abaace46430395dd1bdfd14caaf66`、frozen candidateは`f03a43d2339e9772a15db1c591a31f5e4f92cca2`、00 review recordは`ba688730e57564bbb883035972bba9ff2224cd50`。
- Issuance→finalは`f028c76bf7b38315dc093c008b0196b617c0b788`、`fc11664071ccf46652380c672da9d23e33f680f5`、`2dde6bbfec893a5c611c01638ec2b188e1b6cf1b`、`ca15f57e6c3c23658d602cfa93212e8e91de2064`の直線4 commit、merge `0`。`2dde6bb...`は`automated-results.json`だけのmarker-summary correction、`ca15f57...`は`evidence-manifest.json`だけのmanifest follow-up。amend／rebase／test rerunは`0`。
- Issuance→finalはexact `154` changed paths／allowlisted `154`、unexpected／protected／production／candidate／test／contract差分`0`、full／latest `git diff --check` exit `0`。candidate→final prototype deltaは`0`で、treeは`2a66e4c06308a47678e8888a739b87ffd33d1ee8`。
- Required automationは`22 / 22` numeric exit `0`、Integration expected warnings exact `4`、Presentation invalid-spatial expected warnings exact `20`、other warning／ERROR／SCRIPT ERROR／terminal FAILは`0`。Contract Section 10 technical mappingは`15 / 15 Pass`。
- Strict manual 21 rowsは`3 Pass / 0 Fail / 0 Blocked / 18 Not run`。Passはreal scene／focus、visible movement、actual user free-textの3行だけで、部分観察を複合rowへ昇格していない。candidate defectは`0`。remaining manual KBM／readability／user feel、physical gamepad、performance／P95／maximum load／long-run、exportはPassへ昇格しない。
- Evidence-summary findingは`2dde6bb...`で解消した。invocation 2はANSI SGR除去後のrendered marker exact once、invocation 19はraw literal exact onceとして記録し、underlying logs／commands／numeric exits／warnings／required anchors／resultsは不変。manifest snapshot tipは`2dde6bbfec893a5c611c01638ec2b188e1b6cf1b`、evidence `150`＋summaries `3`の`153 / 153` current size／SHA readback一致、mismatch／duplicate／self-reference `0`、self-excluded。
- Shared contract追加変更は不要。historical `17 / 17`／`13 / 13`／manual Fail evidenceを上書きせず、OQ-001／OQ-005はOpenのまま。
- Return時点でretainedだった`C:\tmp\mf-fs-a-reval-manual-20260815-001`と同`.tar`について、00はpath／type、archive `186992640` bytes／SHA-256 `7b3c2b8e82d58f3e403652ec588e98552b6afaef586e41f62e0f24add1fb53ba`、Godot process `0`を再確認後、exact 2 pathだけをcleanupした。cleanup後は双方不存在で、repository／evidence／candidate差分`0`（本handoff更新を除く）。一時artifactはtested sourceから再生成できる。

## 2026-08-15 FS-A manual closure issuance

- User instruction: `はい。お願いします`。次工程として`MFO-WO-FS-A-30-004 — FS-A Manual Closure`を正式発行した。
- Portable integration issuance sourceは`1329e283c64aba850ae1ed8d90211a6d8cc35cec`（parent `deebadf2f2e025dff0262afa876f34bc9bb1699d`）。変更は新規`docs/work-orders/fast-slice/fs-a-30-manual-closure.md` exact 1 file／290 linesだけで、prototype delta `0`、`git diff --check` exit `0`。integration local HEAD／tracking ref／live originはsource issuance push後にexact一致し、worktree cleanだった。
- QA branch／worktreeは`codex/fast-slice-fs-a-manual-closure`／`C:\tmp\mf-fs-a-manual-closure`。accepted revalidation final `ca15f57e6c3c23658d602cfa93212e8e91de2064`から作成し、portable source commitだけをcherry-pickした。
- QA issuance tipは`a64f9f0e4f536cd96bd331b87cc7c720d44e31fa`（parent `ca15f57e6c3c23658d602cfa93212e8e91de2064`）。source→QA patch-idは`d4725d70440d2820e33d7e5dc4058b5b9bfa3700`で一致し、local HEAD／tracking ref／live originはexact一致、worktree／index／untracked clean。
- Candidate `f03a43d2339e9772a15db1c591a31f5e4f92cca2`、review `ba688730e57564bbb883035972bba9ff2224cd50`、accepted QA final `ca15f57...`はQA issuance HEADのancestor。integration acceptance `deebadf2...`は共通base `29c22763...`を持つadministrative siblingで、non-ancestorを正常境界として記録する。
- Candidate／review／accepted QA／integration acceptance／QA issuanceのprototype treeはすべて`2a66e4c06308a47678e8888a739b87ffd33d1ee8`。`ca15f57...`→QA issuance差分は本票exact 1 file、merge `0`、prototype delta `0`、`git diff --check` exit `0`。
- Authorized executionはnew unique archive／stageのidentity、fresh editor import／global class cache、実`fs_a_main.tscn`のSession A／B、rows `3–20` exact `18`、current feel／readability、新規report／checklist／evidence、QA handoff EOF appendだけ。accepted automation `22 / 22`とtechnical `15 / 15`は再実行せずread-only参照する。
- Candidate／test／contract／旧evidenceはread-only。physical gamepadは`Not run / Deferred`、performance／P95／maximum load／long-runは`Not run / Deferred`、optional exportは`Not run`。promotion、baseline merge、Gate actionは本票のauthority外で、promotion stoppedを維持する。
- `OQ-00-20260815-001`／`-002`はClosed／Approved Option A。`OQ-001`／`OQ-004`／`OQ-005`はOpenのままで、manual closureは拡張または解決しない。

## 2026-08-15 FS-A manual closure Return acceptance

- Decision: `Technical Pass / promotion pending manual KBM and/or user feel`。`MFO-WO-FS-A-30-004`のReturnを受理する。promotionは停止を維持し、promotion／Gate actionは`0`。
- QA branch／worktreeは`codex/fast-slice-fs-a-manual-closure`／`C:\tmp\mf-fs-a-manual-closure`。accepted final tipは`e261392dd0944d09d0ac6f3a6fef9b0346795c10`で、local HEAD／tracking ref／live originはexact一致、worktree／index／untrackedはclean。
- Issuance `a64f9f0e4f536cd96bd331b87cc7c720d44e31fa`からcontent `30edc9b026c3ba61a6a50dc52823d4c04dfdb811`、manifest-only `e261392dd0944d09d0ac6f3a6fef9b0346795c10`の直線2 commit、merge `0`。contentはexact `107` paths、manifest childはexact `1` pathである。
- Issuance→finalはexact `108` changed paths／allowlisted `108`、unexpected／protected／prototype／test／contract／work-order／old-evidence差分`0`、全latest／full `git diff --check` exit `0`。candidate→final prototype deltaは`0`で、treeは`2a66e4c06308a47678e8888a739b87ffd33d1ee8`。
- Manual rows `3–20`は`10 Pass / 0 Fail / 0 Blocked / 8 Not run`。Passは`3–10`、`14`、`15`、Not runは`11–13`、`16–20`。accepted rows `1`／`2`／`21`を含む21行は`13 Pass / 0 Fail / 0 Blocked / 8 Not run`。部分観察、source、automation、外部screenshotで複合rowをPassへ昇格していない。
- Accepted automation `22 / 22`とtechnical `15 / 15`はread-only referenceであり、本票では再実行していない。candidate functional defectは`0`、shared-contract changeは不要。physical gamepadは`Not run / Deferred`、performance／P95／maximum load／long-runは`Not run / Deferred`、optional exportは`Not run`。
- Current feelのexact replyは`ないです。ないですが、開始時点で即攻撃受けるのはどうにかしてほしいです。開始位置を変えるのが一番かと`。開始直後の攻撃圧はnegative playability findingとして保持し、開始位置変更はuser proposalだけで、candidate functional Fail、Approved仕様、実装authorityにはしない。player敗北後のreset懸念も`OQ-005`境界として保持する。
- Manifest snapshotはcontent tip `30edc9b026c3ba61a6a50dc52823d4c04dfdb811`。evidence `104`＋summaries `3`の`107 / 107` current size／SHA readback一致、missing／mismatch／duplicate／self-reference `0`。manifestは`27734` bytes／SHA-256 `92a925ca4fc6d7ac234eb4d55aa161d972a8031d07e3db9b0516372fc243519c`。
- Evidence transportのfixed-point境界: cleanup-boundary最終bytesを生成したpost-snapshot `.codex-fs-a-manual-closure-finalize-consolidated.patch`は`41658` bytes／SHA-256 `93807d4fd399922705afb8d28a321719d0e9a7e84a8ccbb99bc263f07b6cd001`、exact 4 paths、`git apply --check`／apply Pass。manifest transportは`28051` bytes／SHA-256 `45631c8a752c808cf94fa111db1249c00a3a161d8010d4b8f5e4f8f22f08c228`。00が両exact leafをidentity照合後に削除し、双方不存在、candidate／runtime／result差分`0`を確認した。generatorをrepo内snapshotへ再帰追記しない。
- Manual runtimeはfresh editor import exit `0`、global class cache生成済み。session exitはinitial A `null`、continuation A `0`、positive-Integrity retry A `0`、B attempt `0`、B retry `0`。Return review時のGodot processは`0`。
- Return時点で保持された`C:\tmp\mf-fs-a-manual-closure-stage-20260815-001`と同`.tar`について、00はresolved exact path／type、reparse pointでないこと、archive `187750400` bytes／SHA-256 `ab176f39764c28294db6f72ec841892f4909e3d30bab456a60a05b602173e806`、Godot process `0`を再確認後、exact 2 targetsだけをcleanupした。cleanup後は双方不存在で、repository／evidence／candidate差分`0`（本handoff更新を除く）。

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

- `FS-A-INACTIVE-TELEGRAPH`、`FS-A-SPATIAL-SEAM`、`FS-A-PLAYER-DEFEAT-STOP`以外のshared contractは変更しない。Gameplay snapshot／eventをauthority sourceとし、Presentationにはdeep-copied read-only dataだけを渡す。
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
8. [Completed / Historical Technical Pass] 30 integrated validation technical／pre-manual tip `81c6643b71940ca8bbf1c68d3c9ce47917b9111c`をreviewし、automated technical `13 / 13 Pass`とmanual preparation correctionを受理。
9. [Completed / Manual Fail] corrected manual-002を実sceneで確認し、visible movement／combat reachのFailを観察し、source auditでplayer defeat latch／player-function stop欠落を確認。
10. [Completed / Evidence accepted] QA final tip `3968be22d206bb66602dfc23efeb6bb372211461`のmanual evidenceをreviewし、exact temporary stage／archiveをcleanup。
11. [Completed / shared contract] Userが`OQ-00-20260815-001`と`OQ-00-20260815-002`を双方Option AでApprovedし、00がContract／Decisions／Open Questionsへ同期。
12. [Completed] `MFO-WO-FS-A-10-002`と`MFO-WO-FS-A-20-002`をreviewし、10→20の順で6 commits／10 disjoint pathsを統合した。
13. [Completed / Technical Pass] `MFO-WO-FS-A-30-003` corrected final tip `ca15f57e6c3c23658d602cfa93212e8e91de2064`をreview／受理した。automation `22 / 22`、technical `15 / 15`はPass。manual `3 / 0 / 0 / 18`の未完了境界によりpromotionは停止を維持する。
14. [Completed / Technical Pass] `MFO-WO-FS-A-30-004` final tip `e261392dd0944d09d0ac6f3a6fef9b0346795c10`をreview／受理した。rows `3–20`は`10 / 0 / 0 / 8`、combined 21 rowsは`13 / 0 / 0 / 8`、candidate defect `0`。remaining manual／playability境界によりpromotionは停止を維持する。

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

integration-only return後、00がreview、fresh smoke、candidate source freezeを完了し、ユーザーの継続指示に基づいて`MFO-WO-FS-A-30-002`を発行した。technical／pre-manual tip `81c6643b71940ca8bbf1c68d3c9ce47917b9111c`はhistorical technical resultとmanual preparation correctionとして保持する。後続manual-002はfunctional Failとなり、provenance修正後のQA final tip `3968be22d206bb66602dfc23efeb6bb372211461`を00が独立scope／semantic／manifest reviewで受理した。promotionは停止し、Approved shared-contract decisionsに基づくowner reworkと再validationを後続境界とする。

- [x] source tips、integration commit列、final HEAD、commands、exit codes、Not runを統合report／handoffへ記録する。
- [x] FS-A技術acceptance 13項目のPass／Fail／Blocked／Not runを個別に記録する。
- [x] Passしたreturned final tip `867899c7ccb9380b4bb6e4be5c51da4223532230`をvalidation candidate source SHAとしてfreezeする。
- [x] validation source identityをcandidate `867899c7ccb9380b4bb6e4be5c51da4223532230`、review parent `d79b542ec42f34306a0370b07752e732dcf0c7fc`、本issuance commitの3層へ分離して固定する。
- [x] issuance commit `3cdf6dbd9031e3d05fd2a049c851f19409d7b592`からvalidation branch／worktreeを作成し、local／tracking／live originのexact identityとclean状態を記録する。
- [x] QA technical／pre-manual tip `81c6643b71940ca8bbf1c68d3c9ce47917b9111c`の6 commit／62 path／evidenceをreviewし、historical technical `13 / 13 Pass`とmanual preparation correctionを受理する。
- [x] manual sessionのexact fresh reconstruction、entry scene、controls、記録境界をQA checklistへ固定して後続human確認へ渡す。
- [x] userがmanual-002でvisible movement／combat reachとzero後のboss attack継続を報告し、source auditがplayer defeat latch／player-function stop欠落を確認した。direct evidenceと00／source inferenceを分離して記録する。
- [x] QA final tip `3968be22d206bb66602dfc23efeb6bb372211461`のmanual evidence／manifestを受理し、exact manual-002 temporary stage／archiveをcleanupする。
- [x] shared-contract決定、owner rework、fresh automated validationとbounded manual revalidation Return reviewを完了する。Technical Passだけを受理し、remaining manual KBM／readability／user feelのためpromotionを停止する。
- [x] `MFO-WO-FS-A-30-004`のmanual-only Returnでrows `3–20`とcurrent feel／readabilityを個別reviewした。Technical Passだけを受理し、8行のNot runとnegative playability findingのためpromotion recommendationは発行せず停止を維持する。

## 2026-08-15 opening-spawn and defeat-retry approval

- User approval: 00が提示した推奨2案「FS-A `player_start_position`を`Vector2(520, 540)`から`Vector2(200, 540)`へ変更」「`Integrity == 0`中は既存`lock_on`のKBM `Q`／gamepad `LB` fresh pressでsame-arena retry」に対し、userはexact `OKです`で双方を承認した。
- `OQ-00-20260815-003` Option A: FS-A `fs_provisional`のplayer startだけを`Vector2(200, 540)`へ変更する。initial aim、boss／part／harvest位置、movement bounds、telegraph／attack geometry・timing・damage、enemy selection／cooldownは不変で、grace／invulnerability／新stateを追加しない。
- `OQ-005` Option A／`OD-021-INPUT`: command開始時点で`Integrity == 0`かつauthority敗北latch中の場合だけ`lock_on`のfresh `just_pressed`をretryとして受理する。alive開始command内でfatal latchした同edgeはretryへ使わず繰り越さない。accepted trigger commandはmove／aim更新／evade／light／heavy／interactを全消費し、retry-owned configured round stateへ初期化する。current round index／rematch counterは保持して増減させず、rematch eventを生成しない。
- alive、held／release、neutral／retained aimでretryせず、`E`はharvest／rematch専用のまま。新phase／snapshot field／Gameplay event／signal／UI／自動retryは追加しない。物理gamepadは`Not run / Deferred`、`OQ-001`はOpenのまま。
- Frozen combined candidate `f03a43d2339e9772a15db1c591a31f5e4f92cca2`、accepted QA final `e261392dd0944d09d0ac6f3a6fef9b0346795c10`、integration acceptance `1b34059f25da59b141ceb81a90e1ca4c51d12ed8`、prototype tree `2a66e4c06308a47678e8888a739b87ffd33d1ee8`を入力identityとして保持する。
- この承認だけではcandidate codeを変更しない。00は決定／契約同期commitを先に固定し、その後にFS-A限定`MFO-WO-FS-A-10-003`を正式発行する。strict Slice 2-C、baseline promotion、Gate actionは開かない。
- Gameplay owner Returnを00がreview／統合した後、別QA票でopening safety、Q fresh-edge retry、remaining manual rows、current readability／feelを再検証するまでpromotion stoppedを維持する。
