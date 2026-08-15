# Material Frontier Online — Fast Vertical Slice Contract

- Status: Active / branch-local prototype contract
- Effective date: 2026-08-03
- Last amended: 2026-08-15 — FS-A spatial seam, player-defeat stop, retry binding, and opening-spawn normalization
- Owner: 00統括
- Preservation branch: `codex/checkpoint/pre-fast-vertical-slice-20260803`
- Preservation commit: `3c0169e65e95934f78ebaf51b7e7d76f4f08ac7c`
- Preservation parent: `d06a1ca0c5505f9ec1197fade4b3baec417d700e`
- Baseline branch: `prototype/fast-vertical-slice`
- Godot: `4.7.stable.official.5b4e0cb0f`
- Language: GDScript

## 1. Purpose

高速縦切り版は、短期間で遊べる戦闘ループを成立させ、面白さ、操作感、読みやすさを先に確認するための独立開発線である。

これは現在の厳格検査版、`main`、正規仕様、既存Gate判定を置き換えない。Fast Sliceで採用したコード、数値、演出、テスト結果は、別途の監督reviewなしに厳格本線へ昇格しない。

## 2. Baseline protection

- `main`へ直接commit、push、mergeしない。
- `prototype/fast-vertical-slice`は上記preservation commitから作る。
- role branchは契約commitを含む同一baseline SHAから分岐する。
- role branchからbaselineへの直接mergeは禁止し、00がreview済みcommitだけをintegration branchへ集約する。
- 厳格本線へ反映する場合は、後日の明示reviewで採用commitを選択的にcherry-pickする。whole-branch mergeはしない。
- 既存worktree、凍結evidence、未完了QA lineをreset、stash、cleanup、rewriteしない。

### 2.1 Checkpoint build state

Preservation commitは、現行履歴`d06a1ca…`と当時唯一の意図的未commit変更である`action_runtime.gd`のinitial empty-effects read-only化1行を保全した。

確認済み:

- Godot `--version`: exit `0`
- fresh worktree headless editor import／parse: exit `0`
- import後main scene headless smoke: exit `0`
- `DefinitionsValidated ok=true`
- runtime guardrail violation count: `0`
- tracked checkpoint path: exact `1`

注意: 上記1行修正の専用Stage B targeted validationは、旧実行線のlauncher quoting不適合でGodot child起動前に停止しており、厳格QA受理済みとは扱わない。Fast Sliceはこの事実を継承するが、厳格QA結果を上書きしない。

## 3. FS-A scope

FS-Aで成立させる一周は次のとおり。

1. 専用arenaを起動する。
2. 既存の移動、照準、回避を維持する。
3. player構成は`Knight / Iron`の1種類だけとする。
4. 軽攻撃と強攻撃を使える。
5. 大型敵は1体だけとする。
6. 敵の攻撃予告を2種類用意する。
7. playerの`Integrity`と`Deformation`を表示し、権威stateとして更新する。
8. 破壊可能部位を1個必須とし、2個目は一周完成を遅らせない場合だけ追加する。
9. 敵本体HPが0になる。
10. 敵HP0後はAI、攻撃、hit判定を停止する。
11. 残骸をexact 1体生成する。
12. 回収点をexact 3か所生成し、各点は1回だけ回収できる。
13. 全回収後にリザルトを表示する。
14. 再戦でplayer、enemy、parts、wreck、harvest、resultを初期化し、二周目へ入れる。

player `Integrity`がpositiveから0へ遷移した場合はplayer敗北をexact onceでlatchし、`OD-021-INPUT`のaccepted retryによるauthority resetまでplayer move／evade／action／hit query／pending actionとenemy AI／telegraph／attack／pending hitを停止する。これはboss HP 0経路を変更せず、新しいphase／snapshot field／event／UIを追加しない。

FS-A完了はGate 2、Gate 8、正規MilestoneのPassを意味しない。

## 4. Branch-local provisional authority

高速縦切りを未決数値で停止させないため、ユーザー指示に基づき次を`fs_provisional`としてFast Slice内だけで設定、調整できる。

- player、enemy、partのHP
- 軽攻撃、強攻撃、敵攻撃のdamageとDeformation量
- windup、active、recovery、telegraph、cooldownの時間
- enemyの選択規則、距離、移動速度
- part damageとbody HPのFast Slice限定関係
- harvest時間、表示量、result timing

条件:

- 値は`material-frontier-online/prototype/data/fast_slice/**`へ集中させ、`fs_provisional`と明記する。
- `fs_provisional`値を正規OD、`docs/MASTER_SPEC.md`、厳格本線のproduction dataへ昇格させない。承認済みbranch-local normalizationの追跡は`docs/DECISIONS.md`のFast Slice sectionに限る。
- stable production value、正式balance、Gate証拠として扱わない。
- FS-Aの範囲外mechanicを追加しない。
- 調整履歴はgameplay handoffへ短く記録する。

初期の攻撃予告は、色以外でも区別できる`telegraph_line`と`telegraph_sector`をbranch-local defaultとする。形状変更はFast Slice内で許可するが、種類数は2を維持する。

### Approved FS-A opening-spawn normalization

- `player_start_position`だけを`Vector2(520, 540)`から`Vector2(200, 540)`へ変更する。boss `Vector2(1350, 540)`からの距離は`1150 px`で、現line range `980 px`とsector range `520 px`の外に置く。
- `player_start_aim = Vector2(1, 0)`、movement bounds、boss／part／harvest位置、telegraph／attack geometry・timing・damage、enemy selection／cooldownは変更しない。grace、invulnerability、新stateは追加しない。
- arena初期化、player敗北retry、result後rematchは同じconfigured startを使用する。Presentation／integrationは既存spatial seamをそのままread-only描画し、別座標mappingを追加しない。
- この座標はFS-A限定`fs_provisional`であり、stable production value、正規balance、Gate証拠、`MASTER_SPEC`へ昇格しない。

## 5. Explicit exclusions

FS-A一周が動くまで、以下を追加しない。

- オンライン、server、account
- 永続データ、save、inventory persistence
- 全材料、素材選択画面
- 装備強化tree、craft、warehouse
- lifecycle mode
- magic
- production art、music、voice、VFXの量産
- 最大負荷、P95 matrix、長時間stress
- 新しい巨大test harness、汎用framework
- 複数boss、複数stage、複数CombatForm
- networking将来対応の抽象化

## 6. Exclusive file ownership

`.uid` sidecarは対応するsource、sceneのownerに従う。role間で同じtracked fileを編集しない。

| Owner | Writable paths |
|---|---|
| 00 / supervisor | `docs/FAST_SLICE_CONTRACT.md`; `docs/work-orders/fast-slice/**`; `docs/handoffs/fast-slice/integration.md`; Fast Slice branch promotion記録 |
| 10 / gameplay | `material-frontier-online/prototype/scripts/fast_slice/gameplay/**`; `material-frontier-online/prototype/data/fast_slice/**`; `material-frontier-online/prototype/scenes/fast_slice/gameplay/**`; `material-frontier-online/implementation/fast-slice/gameplay/**`; `docs/handoffs/fast-slice/gameplay.md` |
| 20 / presentation | `material-frontier-online/prototype/scripts/fast_slice/presentation/**`; `material-frontier-online/prototype/scenes/fast_slice/presentation/**`; `material-frontier-online/prototype/assets/fast_slice/**`; `material-frontier-online/implementation/fast-slice/presentation/**`; `docs/handoffs/fast-slice/presentation.md` |
| 30 / QA | `material-frontier-online/prototype/tests/fast_slice/**`; `docs/test-reports/fast-slice/**`; `docs/test-reports/evidence/fast-slice/**`; `docs/handoffs/fast-slice/qa.md` |
| 10 / future integration-only WO | `material-frontier-online/prototype/scripts/fast_slice/integration/**`; `material-frontier-online/prototype/scenes/fast_slice/fs_a_main.tscn`; `material-frontier-online/prototype/scenes/fast_slice/integration/**`; `material-frontier-online/implementation/fast-slice/integration/**` |

次は新しい00 work orderでexact ownerを割り当てるまでread-onlyとする。

- `material-frontier-online/prototype/project.godot`
- `material-frontier-online/prototype/export_presets.cfg`
- `material-frontier-online/prototype/scenes/phase1/**`
- `material-frontier-online/prototype/scripts/input/**`
- `material-frontier-online/prototype/scripts/simulation/**`
- `material-frontier-online/prototype/scripts/combat/**`
- `material-frontier-online/prototype/scripts/phase1/**`
- `material-frontier-online/prototype/scripts/presentation/**`
- existing data、tests、handoffs、strict evidence
- `docs/DECISIONS.md`、`docs/MASTER_SPEC.md`、`docs/MILESTONES.md`

既存移動、照準、回避はread-only dependencyとしてcomposeする。変更が必要な場合は`fast_slice/**`内にadapterを作る。

## 7. Cross-role seam

10が権威を持つ:

- player、enemy、partのstate
- action acceptance、hit、damage
- telegraph開始、終了の意味
- defeat、functional stop、wreck生成
- harvest eligibility、result eligibility、rematch reset

20はread-only snapshot／eventだけを消費し、上記を変更しない。30はcandidate codeや値を修正しない。

最低限のsnapshot fields:

- `loop_phase`: `combat | wreck | result`
- `player_integrity`, `player_integrity_max`
- `player_deformation`
- `player_position`: authority arena内の`Vector2`
- `player_aim`: authorityが保持する正規化済み方向`Vector2`
- `boss_hp`, `boss_hp_max`
- `boss_position`: authority arena内の`Vector2`
- `parts`: 1〜2件の`id`, `hp`, `broken`, `position`
- `telegraph`: `id`, `shape`, `duration`, `progress`, `active`, `origin`, `direction`, `range`, `half_width`, `half_angle`
- `boss_functional`
- `wreck_active`
- `harvest_points`: exact 3件の`id`, `collected`, `position`
- `result_visible`, `rematch_available`

presentationを無効化してもgameplay結果は変わらない。表示は色だけに依存しない。

### Approved FS-A spatial seam

- 上記spatial fieldはGameplay authorityの同一arena座標系を表す。20はplayer、boss、parts、telegraph、wreck、harvestをこの値からread-only描画し、object別の固定proxy座標や第二の座標modelをauthority表現として使用しない。
- Presentation側のviewport全体に対する一様scale／letterboxは許可するが、Gameplay sourceの意味、attack reach、hit、damage、harvest eligibility、resultを変更しない。
- integrationは既存のdeep copy／read-only境界を維持し、spatial fieldを別座標へmappingせず、Gameplay sourceへwrite-backしない。Presentationを無効化した場合もGameplay結果は不変である。
- `telegraph.half_angle`はradianである。lineで未使用の`half_angle`、sectorで未使用の`half_width`は既存どおり`0.0`を保持し、別形状へ推測変換しない。

### Approved FS-A player-defeat stop and retry binding normalization

- `player_integrity`のpositive→0をprivate authority stateでexact once latchする。公開`loop_phase`、snapshot field、event、UIは追加せず、`player_integrity == 0`を既存のcanonical敗北signalとして使用する。
- latch時にplayerのactive evade／pending action／pending hit queryをcancelし、以後authority resetまでmove／evade／action／player hit queryを受理しない。latch位置と既存boss／part stateを保持する。
- 同じlatchからauthority resetまでenemy AI／telegraph／attack schedulingを停止し、pending enemy hitを破棄する。追加damage、Integrity／Deformation更新、enemy attack eventを確定しない。
- player敗北でboss HP、`boss_functional`、parts、wreck、harvest、resultを変更せず、boss HP 0経路と混同しない。
- command開始時点で`player_integrity == 0`かつauthority敗北latch中の場合だけ、既存abstract `lock_on`（gamepad `LB`／KBM `Q`）のfresh press／`just_pressed`をretry要求として受理する。alive開始command内でfatal latchした同edgeはretryへ使わず繰り越さない。alive、held／release、neutral／retained aimではretryせず、alive中のQは他actionを消費しない。
- accepted retry command上のmove／aim更新／evade／`physical_light`／`physical_heavy`／interactを全消費し、同一arenaのretry-owned configured round stateへ初期化する。current round index／rematch counterは保持して増減させず、rematch eventを生成しない。reset／authority node同期／既存snapshot emit後に同commandを終了し、次の新しいcommandから通常受付へ戻る。
- `E`はharvest／rematch専用のままで、player敗北中はretryにならない。自動retry、新phase／snapshot field／Gameplay event／signal／UIを追加せず、`rematch_reset` eventを流用しない。production `ActorDefeated` payloadは`OQ-001`のままOpenとする。

### Approved integration-only normalization

- Gameplayのactive shape `telegraph_line`／`telegraph_sector`は、Presentationへ渡すdeep copyだけを`line`／`sector`へ変換する。
- Gameplay snapshotが`telegraph.active == false`かつ`shape == ""`の場合、Presentation用deep copyの`shape`だけを`line`へ正規化し、`active == false`を保持する。これはPresentation schema用の非表示placeholderであり、Gameplay上のline telegraph、予告開始、攻撃選択を意味しない。
- Gameplay source snapshotへwrite-backしない。`active == true`のempty shape、または承認済みのinactive emptyとcanonical 2値を除く未知shapeはactive値を問わず推測変換せず、そのPresentation updateだけをfail closedにする。

## 8. Worktree and branch topology

| Purpose | Worktree | Branch |
|---|---|---|
| Preservation | `C:\tmp\mf-fast-checkpoint` | `codex/checkpoint/pre-fast-vertical-slice-20260803` |
| Protected baseline | `C:\tmp\mf-fast-base` | `prototype/fast-vertical-slice` |
| Gameplay | `C:\tmp\mf-fs-a-10` | `codex/fast-slice-fs-a-gameplay` |
| Presentation | `C:\tmp\mf-fs-a-20` | `codex/fast-slice-fs-a-presentation` |
| Gameplay rework | `C:\tmp\mf-fs-a-10-rework` | `codex/fast-slice-fs-a-gameplay-rework` |
| Presentation rework | `C:\tmp\mf-fs-a-20-rework` | `codex/fast-slice-fs-a-presentation-rework` |
| QA preparation | `C:\tmp\mf-fs-a-30` | `codex/fast-slice-fs-a-qa-prep` |
| Integration | `C:\tmp\mf-fs-a-int` | `codex/fast-slice-fs-a-integration` |
| Final validation, later | `C:\tmp\mf-fs-a-val` | `codex/fast-slice-fs-a-validation` |

- 10、20、30-prep、integration branchは同じ契約commitから作る。
- roleは`prototype/fast-vertical-slice`へ直接commitしない。
- 00だけがreview済みtipをintegration branchへ取り込む。
- final validation branchはintegration candidate freeze後に作る。
- baseline更新後のrole同期は00の明示通知で行う。

## 9. QA and stop policy

QAのFail／Blockedは、そのcandidate branchまたはそのintegration commitだけを止める。無関係なrole branchは同じ契約の範囲で継続する。

branch-local stopの例:

- parse failure、assertion failure
- 一攻撃、HUD、loot、resetのbug
- placeholder不足
- QA runner、launcher、export helperの不具合
- role branchのscope違反、dirty state

全体停止は次の3条件だけとする。

1. `main`の破損、またはFast Slice変更の誤適用
2. tracked source、asset、user workのデータ損失
3. 2担当以上が依存する`FAST_SLICE_CONTRACT`の破綻

全体停止には再現手順またはdiff証拠を必要とする。単一branchの失敗を全体停止へ格上げしない。

QA-owned test／launcherの不具合は30 branch内でbounded repairできる。candidate implementationや値は変更しない。assertion総数そのものをacceptance条件にしない。

## 10. FS-A acceptance

- 専用sceneがimport、parse、launchできる。
- move、aim、evadeが既存挙動を維持し、`player_position`／`player_aim`の変化として同じarena座標上で観察できる。
- light、heavyが別操作、別timingで成立する。
- enemy attack 2種を予告から回避でき、予告geometryがauthority snapshotと一致する。
- player Integrity、Deformationが変化し、rematchで初期化される。
- player Integrityのpositive→0をexact onceでlatchし、authority resetまでplayer move／evade／action／hit query／pending actionおよびenemy AI／telegraph／attack／pending hitが停止する。boss／part／wreck／harvest／result stateはこの敗北だけで変化しない。
- fresh arenaはconfigured start `Vector2(200, 540)`から開始し、静止した最初のline attack cycleでIntegrity／Deformationが変化しない。telegraph／enemy AIを抑制せず、現range外missとして成立する。
- command開始時点ですでに敗北latch済みの場合のfresh Q／LB pressだけがretryをexact once受理する。敗北前からheldだったQ／LB、release、neutral／retained aim、およびalive開始command内でfatal latchした同edgeはretryせず繰り越さない。accepted commandのmove／aim更新／evade／light／heavy／Eを全消費する。
- retryはplayer Integrity／Deformation／position／initial aim／velocity／evade／action、boss／parts／enemy／telegraph／pending hits／wreck／harvest／result／rewardのretry-owned configured round stateを初期化する。current round index／rematch counterは保持して増減させず、rematch eventを生成しない。
- player敗北中のEはno-opで、既存wreck harvest／result rematchのE semanticsを変更しない。retry後はmove／aim／evade／light／heavyとenemy scheduleが再び成立する。
- 物理gamepad `LB`のbindingはstaticに維持するが、実機証拠は`Not run / Deferred`であり、KBM `Q`のPassで代替しない。
- partを1個以上破壊できる。
- boss HP 0遷移がexact onceである。
- boss HP 0後にAI、attack、hitが停止する。
- player、boss、parts、wreck、telegraph、harvestのuser-visible位置がrequired spatial seamと一致し、固定proxyだけを動作確認の代替にしない。
- wreckがexact once生成される。
- harvest pointがexact 3件で、重複回収できない。
- 全回収後にresultが表示される。
- rematchで完全初期化し、二周目の主要操作が再度可能である。
- presentation無効時もgameplay結果が同じである。

技術acceptanceに加えて、userまたは委任playtesterが操作感と戦闘の読みやすさを短く評価する。これは厳格Gate証拠ではなくFast Sliceのplayability findingである。

## 11. Promotion and closure

```text
checkpoint
  -> prototype/fast-vertical-slice + contract
      -> 10 gameplay ---------+
      -> 20 presentation -----+-> 00 scope review -> integration candidate
      -> 30 QA preparation ---+                         |
                                                        v
                                          30 integrated validation
                                                        |
                                                        v
                                   QA Pass + user feel review
                                                        |
                                                        v
                                   prototype/fast-vertical-slice
```

- FS-A結果はplayability findingであり、正規Gate証拠ではない。
- 本線へ反映する場合、採用commit、値、contractを個別に再審査する。
- 採用しないFast Slice固有code、data、assetsはFast Slice branchに残す。
- FS-A一周成立後にだけ、FS-B候補を別work orderで検討する。
