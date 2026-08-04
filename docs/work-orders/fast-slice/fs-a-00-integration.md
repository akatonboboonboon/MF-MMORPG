# MFO-WO-FS-A-00-001 — FS-A Integration-Only Composition

- Status: `Blocked before issue / OQ-00-20260804-001 unresolved`
- Prepared / blocked: `2026-08-04`; issue date pending resolution
- Issuer: `00統括（監督）`
- Planned assignee / single writer after issue: `10ゲームプレイ・コア実装`
- Milestone: `FS-A`
- Branch: `codex/fast-slice-fs-a-integration`
- Worktree: `C:\tmp\mf-fs-a-int`
- Required foundation HEAD: `d4b24ed19a1410bac118ad90bbb136d822cb1a6d`
- Authority: `docs/FAST_SLICE_CONTRACT.md` and this work order
- Report path: `material-frontier-online/implementation/fast-slice/integration/fs-a-integration.md`
- Final validation worktree／branch: `Forbidden / not created by this order`
- Issuance blocker: `OQ-00-20260804-001` — inactive telegraph `shape` representation at the Gameplay → Presentation seam

## Issue basis

00は共通base`62f4af4a105b45f458beabecd6595ad5f58ec764`から各final candidate tipまでの全commitをreviewし、次を時系列順に統合した。

| Input | Reviewed source tip | Adopted integration tip |
|---|---|---|
| 10 Gameplay | `17773c5f186dfbbd1a1e52a304df123b76d9ad35` | `80150b0b61c6caf3a6c8586e3d2a046debe81fcc` |
| 20 Presentation | `04893d6d304e0d23a68df0bd1afc2fa8e71cc461` | `5504f9ef15d8ec57caa0476dce89ef2affb4209b` |
| 30 QA Prep | `04845e7782c19352a716dbea6aea794f1047b675` | `d4b24ed19a1410bac118ad90bbb136d822cb1a6d` |

- Changed pathsは10=`16`、20=`10`、30=`9`で、全て各担当のowned paths内。range間の同一tracked fileは`0`、競合は`0`、integration側手修正は`0`。
- 各rangeと累積rangeの`git diff --check`はexit`0`。
- Foundation HEADでGodot fresh import／parse、Gameplay self-check／scene、Presentation self-check／pure shell、QA candidate-independent fixture、Phase 1、Slice 2-A `120 assertions`、correction `39 assertions`を実行し、全てPassした。
- `docs/FAST_SLICE_CONTRACT.md`自体は変更していない。`fs_provisional`値はGameplay owner dataに隔離されたまま。inactive telegraph seamだけは`OQ-00-20260804-001`の明示解決が必要。

## Issuance blocker

Foundation review後に、Gameplayがinitial／cooldown／stopped snapshotで`telegraph.active == false`かつ`telegraph.shape == ""`を返す一方、Presentation shellは`active`に関係なく`shape`を`line|sector`に限定してschema validationすることを確認した。

既存契約はactiveな2種を`telegraph_line`／`telegraph_sector`として定めるが、inactive shapeの表現とadapter normalization ownerを定めていない。initial snapshotをPresentationへ渡す本票のacceptanceは、推測mappingなしでは満たせない。

`OQ-00-20260804-001`がApprovedとして解決され、本票のexact mappingとstatusが00により更新されるまで発行しない。10はintegration-only実装を開始しない。Gameplay／Presentation候補は再編集せず、final validation worktree／branchも作成しない。


## Start condition and history rules after resolution

この節は`OQ-00-20260804-001`解決後、00が本票を`Issued / Active`へ更新してpushした場合だけ有効になる。10は開始前に次を満たすこと。

1. local HEAD、`origin/codex/fast-slice-fs-a-integration` tracking ref、live originが同じissued tipである。
2. issued tipがfoundation HEAD`d4b24ed19a1410bac118ad90bbb136d822cb1a6d`をancestorに持つ。
3. `C:\tmp\mf-fs-a-int`がcleanである。
4. 00がworktreeのsingle-writer ownershipを10へ渡した後だけ編集する。

既存historyをreset、rebase、amendしない。integration-only変更は新規commitとして追加する。候補15 commitや00のpreparation／handoff commitを置換しない。

## Objective

既存のGameplay child sceneとPresentation pure shellを、権威stateを増やさない薄いintegration-only scene／adapterで接続し、FS-Aのone-loop smokeを可能にする。Gameplay／Presentation／QA候補そのものは再実装・再編集しない。

## Authorized paths

本票がissueされた後、10は次だけをsingle ownerとして新規作成または編集できる。対応する`.uid`は同じownerに含む。

- `material-frontier-online/prototype/scenes/fast_slice/fs_a_main.tscn`
- `material-frontier-online/prototype/scenes/fast_slice/integration/**`
- `material-frontier-online/prototype/scripts/fast_slice/integration/**`
- `material-frontier-online/implementation/fast-slice/integration/**`

未存在directoryは実際に必要なfileを置く場合だけ作る。

## Required composition

1. `res://scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn`をGameplay authority childとしてinstance化する。
2. `res://scenes/fast_slice/presentation/fs_a_presentation_shell.tscn`をread-only Presentation childとしてinstance化する。`fs_a_presentation_preview.tscn`とpreview stubはintegrationのstate sourceにしない。
3. 起動時のinitial snapshotと、その後のGameplay snapshotをPresentationへ渡す。Presentationへ渡す前にdeep copyし、Gameplayが返したsnapshotへwrite-backしない。
4. Gameplayの`gameplay_event(event_name, payload)`を一度だけ接続し、下記exact mappingだけをPresentation eventへ変換する。
5. 入力、action acceptance、damage、part break、defeat、wreck、harvest、result、rematch resetはGameplay childだけに決定させる。integration codeは呼出しとread-only forwarding以外のauthorityを持たない。
6. Presentationを無効化しても、同じdeterministic command列に対するGameplayの最終snapshot、result、rematch reset、round-two action結果が変わらないことをself-checkできるようにする。
7. `project.godot`を変更せず、`res://scenes/fast_slice/fs_a_main.tscn`を明示pathで起動する。

## Exact read-only adapter mapping — active values only; inactive mapping unresolved

### Snapshot

Gameplay snapshotを正とする。activeな2値について、Presentationへ渡すdeep-copied snapshotの`telegraph.shape`候補は次のとおり。他field、`telegraph.id`、`duration`、`progress`、`active`は変更しない。inactive empty shapeの扱いは未決定であり、本表から推測しない。

| Gameplay authority value | Presentation-only copy |
|---|---|
| `telegraph_line` | `line` |
| `telegraph_sector` | `sector` |

inactive empty shapeと未知shapeを推測で変換しない。`OQ-00-20260804-001`解決前はsnapshot adapterを実装しない。解決後も表外shapeはintegration reportへerrorとして記録し、そのPresentation updateだけをfail closedにする。Gameplay loopは停止・変更しない。

### Events

| Gameplay event | Condition | Presentation event name |
|---|---|---|
| `player_action_accepted` | accepted eventを受領 | `ActionStarted` |
| `player_hit_resolved` | payloadの`hit == true` | `HitConfirmed` |
| `part_broken` | eventを受領 | `PartBroken` |

event envelopeとpayloadもPresentationへ渡す前にdeep copyし、Presentation feedbackからGameplayへwrite-backしない。上表以外のeventを新たなPresentation意味へ割り当てない。`enemy Integrity`と`boss_hp`の同値化、alias追加、authority field再定義は未承認なので行わない。

## Forbidden scope

- `material-frontier-online/prototype/scripts/fast_slice/gameplay/**`
- `material-frontier-online/prototype/scenes/fast_slice/gameplay/**`
- `material-frontier-online/prototype/data/fast_slice/**`
- `material-frontier-online/prototype/scripts/fast_slice/presentation/**`
- `material-frontier-online/prototype/scenes/fast_slice/presentation/**`
- `material-frontier-online/prototype/tests/fast_slice/**`
- 各roleのhandoff、test report、strict evidence
- `material-frontier-online/prototype/project.godot`、`export_presets.cfg`
- legacy Phase 1／Slice 2-A scripts、scenes、data、tests
- `docs/FAST_SLICE_CONTRACT.md`、`docs/DECISIONS.md`、`docs/MASTER_SPEC.md`、`docs/MILESTONES.md`
- Gameplay値、`fs_provisional`値、snapshot authority、event meaningの変更
- PresentationからHP、part、reward、random、loop resultを決定する処理
- networking、server、account、persistence、music、SE、voice、production art
- candidate-dependent QA拡張、integrated final validation、final validation worktree／branch作成

同じtracked fileへの所有範囲競合を見つけた場合、手修正せず00へ返す。共有契約変更が本当に必要な場合は対象実装を停止して00へ報告し、無関係な確定作業だけ続ける。

## Acceptance

- [ ] changed pathsがAuthorized pathsと対応`.uid`だけで、Forbidden scope差分が`0`。
- [ ] `git diff --check d4b24ed19a1410bac118ad90bbb136d822cb1a6d..HEAD`がexit`0`。
- [ ] Godot`4.7.stable.official.5b4e0cb0f`のfresh headless editor importとintegration script parseがexit`0`。
- [ ] `res://scenes/fast_slice/fs_a_main.tscn`がheadlessで起動し、Gameplay childとPresentation pure shellを接続する。
- [ ] telegraph shapeと3 eventのmappingが上表にexact一致し、unknown／unmapped eventを推測で変換しない。
- [ ] one deterministic loopでcombat → wreck → exact 3 harvest → result → rematch → round-two major actionまで到達する。
- [ ] Presentation enabled／disabledでGameplay authorityの最終結果が一致する。
- [ ] Gameplay self-check、Presentation self-check／pure shell smoke、QA candidate-independent fixtureがPassする。
- [ ] Phase 1、Slice 2-A、Slice 2-A correction regressionがPassする。
- [ ] smoke後にtracked／untracked差分がなく、engine生成物をcommitしない。
- [ ] 実行commit、environment、exact commands、expected／actual、exit codes、Not run、known limitationsをintegration reportへ記録する。

この票のPassはintegration candidate作成までであり、FS-A acceptance、Gate判定、manual KBM、gamepad、performance、final validationのPassではない。

## Return protocol

10はintegration-only commitをoriginへpushし、00へ次を返す。

- branchとfinal candidate tip
- foundation HEADからtipまでの全commitを時系列順に列挙
- changed pathsとowner-scope audit
- source commitからintegration-only tipまでのlineage
- exact commands、exit codes、observed anchors、Not run
- report pathとknown limitations
- local HEAD、tracking ref、live originのidentity

00はreturnをreviewするまでvalidation candidateをfreezeせず、final validation worktreeを作成しない。
