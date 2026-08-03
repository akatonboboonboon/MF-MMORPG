# Fast Slice Integration Handoff

- Status: Preparation active / integration execution not yet authorized
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
| 10 gameplay | `codex/fast-slice-fs-a-gameplay` | Pending | Pending | Waiting for returned exact SHA |
| 20 presentation | `codex/fast-slice-fs-a-presentation` | Pending | Pending | Waiting for returned exact SHA |
| 30 QA preparation | `codex/fast-slice-fs-a-qa-prep` | `8c13a0b545fdf4c88bf33ec7be6be6649d7e7443` | Pass / QA preparation candidate only; 7 paths; unexpected `0`; `git diff --check` exit `0` | Reviewed and pinned |
| 10 integration-only | integration branch | Not applicable before issue | `material-frontier-online/implementation/fast-slice/integration/fs-a-integration.md` | Not authorized before work-order issue |

## Candidate review checklist

各role tipについて次を順に確認する。

- [ ] returned SHAがcommit objectとして存在し、required baseをancestorに持つ。
- [ ] returned branchのlive origin tipと返却identityを照合する。
- [ ] `base..tip`の全commitとdiffをreviewし、implementation／handoff commitを記録する。
- [ ] `git diff --check base..tip`がexit `0`である。
- [ ] changed pathが当該roleのexclusive writable pathsと対応`.uid`だけである。
- [ ] `project.godot`、`export_presets.cfg`、legacy scripts／scenes／data／tests、strict evidence、正規文書の差分が`0`である。
- [ ] 別roleのowned path、`fs_a_main.tscn`、`fast_slice/integration/**`への先行差分が`0`である。
- [ ] 実行済み結果とNot runが分離され、未実行項目をPassとしていない。
- [ ] role work order固有acceptanceとreturn項目を満たす。

### Shared seam review

- [ ] 10だけがplayer／enemy／part state、action acceptance、hit／damage、telegraph意味、defeat／functional stop／wreck、harvest／result／rematch resetを決定する。
- [ ] public snapshotに契約上の最低限fieldがある: `loop_phase`、player Integrity／Deformation、boss HP、parts、telegraph、`boss_functional`、`wreck_active`、harvest points、result／rematch flags。
- [ ] `parts`は1〜2件、harvest pointsはexact 3件で、telegraphは色以外でも識別可能な2種類である。
- [ ] 20はread-only snapshot／eventだけを消費し、gameplay authorityを変更しない。
- [ ] presentation無効時もgameplay結果が同じになるseamを維持する。
- [ ] presentation preview stubはpreview専用で、integration時に権威sourceへ置換できる。

### `fs_provisional` review

- [ ] 具体値を`material-frontier-online/prototype/data/fast_slice/**`へ集中し、`fs_provisional`と明記する。
- [ ] 許可カテゴリはHP、damage／Deformation、timing、enemy選択／距離／速度、part-body関係、harvest／表示量／result timingだけである。
- [ ] production data、正規仕様、stable balance、Gate証拠へ昇格させない。
- [ ] 調整履歴をgameplay handoffへ短く記録する。
- [ ] FS-A外mechanicや将来online向け抽象化を追加しない。

具体的な数値は共有契約では定義されておらず、10 candidateのowned dataとしてreviewする。候補数値の調整だけを共有契約変更として扱わない。

## Planned integration order

1. 10 gameplayのreview済みimplementation／handoff commits。
2. 20 presentationのreview済みimplementation／handoff commits。
3. 30 QA-prepのreview済みcommits。
4. 上記exact source SHAを本handoffへ固定し、`MFO-WO-FS-A-00-001`を発行可能な状態にする。
5. 発行後、10をsingle ownerとして`fs_a_main.tscn`と`fast_slice/integration/**`だけでchild scenesを接続する。
6. integration-only commitのscopeをreviewし、import／parse／one-loop smokeを実行する。
7. Passしたintegration HEADをvalidation candidate SHAとしてfreezeする。
8. 別worktree／branchで30 integrated validationへ渡す。

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

- [ ] 10／20／30-prepのsource tip、origin identity、source commit列、changed pathsを保存する。
- [ ] 各candidateのowned-path auditと`git diff --check`をPassする。
- [ ] 契約／provisional／excluded-systems reviewを完了する。

### B. Integration execution after issuance

- [ ] integration worktreeが取り込み直前にcleanで、HEADが記録済みである。
- [ ] planned orderでreview済みcommitだけを取り込む。
- [ ] 各取り込み後にunexpected pathsとconflict `0`を確認する。
- [ ] 10のintegration-only commit後もrole-owned implementation fileを再編集していない。

### C. Technical smoke

- [ ] Godot identityが`4.7.stable.official.5b4e0cb0f`である。
- [ ] fresh headless editor import／parseがexit `0`である。
- [ ] QA-prepのcandidate-independent runnerを準備fixtureとして実行し、candidate validationを主張しない。
- [ ] 10 candidateが返すexact self-check commandでone-loop／rematch smokeを実行する。
- [ ] `res://scenes/fast_slice/fs_a_main.tscn`を明示pathでheadless launchする。
- [ ] one-loop、result、rematch reset、二周目主要操作をsmokeする。
- [ ] presentation無効時のgameplay結果不変を確認する。
- [ ] candidate-dependent runner拡張とfull integrated validationはfreeze後の`MFO-WO-FS-A-30-002`まで行わない。
- [ ] smoke後のtracked／untracked差分を記録し、engine生成物を勝手にcleanupしない。

準備済みの固定command。one-loop self-checkのexact path／argumentsだけは10 candidate review後に追記する。

```powershell
$FsAGodot = 'C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe'
$FsAProject = 'C:\tmp\mf-fs-a-int\material-frontier-online\prototype'
& $FsAGodot --version
& $FsAGodot --headless --editor --path $FsAProject --quit
& $FsAGodot --headless --path $FsAProject --script res://tests/fast_slice/run_fs_a_contract_skeleton.gd
& $FsAGodot --headless --path $FsAProject res://scenes/fast_slice/fs_a_main.tscn --quit-after 120
& $FsAGodot --headless --path $FsAProject --script res://tests/run_phase1_tests.gd
```

最後のPhase 1 runnerはread-only dependencyのguardrailであり、FS-A one-loop acceptanceの代替にしない。

### D. Freeze and handoff

- [ ] source tips、integration commit列、final HEAD、commands、exit codes、Not runを統合report／handoffへ記録する。
- [ ] FS-A技術acceptance 13項目のPass／Fail／Blocked／Not runを個別に記録する。
- [ ] Passしたfinal HEADだけをvalidation candidate SHAとしてfreezeする。
- [ ] `MFO-WO-FS-A-30-002`発行前にvalidation branch／worktreeのsource identityを固定する。
- [ ] userまたは委任playtesterの操作感／読みやすさ評価はtechnical smokeと分けて後続QAへ渡す。
