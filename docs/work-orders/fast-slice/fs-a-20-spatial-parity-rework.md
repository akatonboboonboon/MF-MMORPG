# MFO-WO-FS-A-20-002 — FS-A Spatial Parity Presentation Rework

- Status: Issued / Active
- Owner: 20ステージ・UI・グラフィック
- Contract foundation: `bf89fcd26cde65659e7addc97952fb9f9fc1dc58`
- Starting ref: this work orderを含むintegration issuance tip。00が通知するexact SHAとbranch初期HEADを一致させる
- Branch: `codex/fast-slice-fs-a-presentation-rework`
- Worktree: `C:\tmp\mf-fs-a-20-rework`
- Integration target: `codex/fast-slice-fs-a-integration`
- Frozen Presentation source: `04893d6d304e0d23a68df0bd1afc2fa8e71cc461`
- Previous implementation commit: `12e109ecafa87339496c12371669dab3a66dc205`
- Frozen integrated candidate: `867899c7ccb9380b4bb6e4be5c51da4223532230`
- Contract: `docs/FAST_SLICE_CONTRACT.md`
- Milestone: `FS-A rework`
- Report path: `material-frontier-online/implementation/fast-slice/presentation/fs-a-spatial-parity-rework.md`

既存branch `codex/fast-slice-fs-a-presentation`とworktree `C:\tmp\mf-fs-a-20`はfreezeを維持する。新branchは00がintegration issuance tipから作成する。reset、rebase、amend、既存candidate履歴のrewriteは禁止する。

Frozen Presentation source `04893d6d304e0d23a68df0bd1afc2fa8e71cc461`はnew branchのcommit ancestorではなく、採用済みsource identityである。candidateのcommit ancestryはintegration issuance tip→rework final tipとする。開始時にissuance tipのPresentation-owned source blobがfrozen sourceとexact一致することを確認し、source identity mappingとcandidate ancestryを混同しない。

## Start conditions

20は次をすべて確認してから編集を開始する。

- 00がintegration issuance tipとnew branchをoriginへpush済みである。
- local HEAD、tracking ref、live originが00通知のexact issuance SHAと一致する。
- Contract foundation `bf89fcd26cde65659e7addc97952fb9f9fc1dc58`がHEADのancestorである。
- `C:\tmp\mf-fs-a-20-rework`がcleanで、既存Presentation branch／worktreeに差分がない。
- issuance tipの3 writable source blobがfrozen Presentation source `04893d6...`の同path blobとexact一致する。
- reset、rebase、amendを行わない。

不一致があれば編集を開始せず、actual SHA／blob／path evidenceを00へ返す。

## Authority and objective

Userは2026-08-15に`OQ-00-20260815-001`をOption AでApprovedした。本票はGameplay authority snapshotの既存spatial fieldを同じarena座標でread-only描画し、固定proxyによるmove／aim／evade／attack reachの不可観察を解消する。

PresentationはHP、hit、damage、part破壊、defeat、harvest、resultを決定しない。`OQ-001` event payloadと`OQ-005` retry bindingはOpenのまま扱わない。

## Exact writable paths

Tracked変更は次のexact 5 pathsだけを許可する。

1. `material-frontier-online/prototype/scripts/fast_slice/presentation/fs_a_presentation_shell.gd`
2. `material-frontier-online/prototype/scripts/fast_slice/presentation/fs_a_presentation_preview.gd`
3. `material-frontier-online/prototype/scripts/fast_slice/presentation/fs_a_preview_stub.gd`
4. `material-frontier-online/implementation/fast-slice/presentation/fs-a-spatial-parity-rework.md`
5. `docs/handoffs/fast-slice/presentation.md` — historical内容を保持してappend

scene、asset、`.uid`変更は不要かつ禁止する。原因が上記3 source以外にある場合はscopeを拡張せず、再現証拠と必要pathを00へReturnする。

## Required snapshot schema

`apply_snapshot()`は既存fieldに加えて次をrequiredとして検証する。

- root: `player_position`, `player_aim`, `boss_position`
- each `parts[*]`: `position`
- each `harvest_points[*]`: `position`
- `telegraph`: `origin`, `direction`, `range`, `half_width`, `half_angle`

position／origin／direction／aimは`Vector2`、range／width／angleはnumericとしてfail closedに検証する。invalid updateはそのPresentation updateだけを拒否し、最後のvalid snapshotを保持する。source snapshotへwrite-backしない。

`telegraph.half_angle`はradian。lineで未使用の`half_angle`、sectorで未使用の`half_width`は既存`0.0`を有効値として受理する。inactive placeholderとunknown-shape挙動は既存integration contractを変えない。

## Required spatial rendering

- authority arena座標を直接使用する。viewport全体への一様scale／letterboxだけを許可し、object別offset、fixed proxy座標、第二座標modelをauthority表現に使わない。
- player proxyを`player_position`へ置き、向き／aim cueを`player_aim`へ合わせる。evadeは新fieldを追加せず、authority position変化として観察可能にする。
- enemyとwreckを`boss_position`、各partを`parts[*].position`、exact 3 harvest markerを`harvest_points[*].position`へ置く。
- line／sector telegraphを`origin`、normalized `direction`、`range`、`half_width`／`half_angle`から描画する。固定target、固定radius、固定角を使用しない。
- attack feedbackは最新`player_position`をorigin、`player_aim`をorientationとして描画する。表示上のattack cueを固定座標に残さない。
- `player_integrity == 0`はauthority HUD値を表示するだけで、Presentation側でdefeatをlatch、state停止、phase変更、retry受付しない。新しいdefeat／retry overlayを追加しない。

## Event payload boundary

既存reserved event名だけを消費し、payload semanticsを採用しない。

- `ActionStarted`: 最新snapshotの`player_position`をanchor、`player_aim`をorientationにする。
- `HitConfirmed`: target identityを主張せず、`player_position + normalized(player_aim) * cosmetic_feedback_offset`をanchorにする。このoffsetは純Presentation表現であり、attack reach／hit位置／damage範囲ではない。
- `PartBroken`: specific part identityを主張せず、transient feedbackを`boss_position`へ置く。各partの正確な位置とbroken表示はeventではなく`parts[*].position`＋`parts[*].broken`だけから描画する。
- 同じevent名でpayloadなし／異なるpayloadを渡してもfeedback kindとanchorを同じにする。unsupported eventだけfail closedにする。

`payload.target_id`、`payload.part_id`、その他payload fieldを位置、部位選択、素材、channel、数値、ID semanticsとして解釈しない。current candidate値のhard-code、event順序からのtarget推測、snapshot差分によるnewly-broken推測も禁止する。per-target transientが必要なら実装を止め、`OQ-001`へ戻す。

## Preview and self-check

- preview fixtureへ全required spatial fieldを追加する。
- 2点以上のplayer position、2方向以上のaim、異なるboss／part／harvest位置、line／sector geometry、wreck／result／reset状態を用意する。
- snapshot sourceとshell保存copyのdeep-copy／read-onlyを確認する。
- fixture値とplayer／boss／part／harvest anchor、telegraph geometryが一致することを確認する。
- player position／aim変更にderived geometryが追従し、固定座標を使用しないことを確認する。
- payloadなし／異なる`target_id`／異なる`part_id`でも同じevent名のfeedback kind／anchorが不変であることを確認する。
- invalid spatial fieldは当該updateだけを拒否し、last valid snapshotとGameplay sourceを不変にする。

## Forbidden scope

上記5 paths以外はread-only。特に次を変更しない。

- `fast_slice/gameplay/**`、`fast_slice/integration/**`、`data/fast_slice/**`、`tests/fast_slice/**`
- `fs_a_main.tscn`、全Presentation scene／asset／`.uid`
- `project.godot`、Input Map、autoload、export設定、legacy presentation
- `FAST_SLICE_CONTRACT.md`、`OPEN_QUESTIONS.md`、`DECISIONS.md`、work order、integration／Gameplay／QA handoff
- `fs_provisional`値、snapshot生成、event mapping、authority meaning
- hit／damage／HP／part／harvest／reward／result決定、attack reach／hit volumeの推測
- production art、audio、networking、server、account、persistence、汎用framework

共有契約の追加変更が必要な場合だけ該当実装を停止して00へ返す。無関係な票内検証は継続する。

## Required validation

implementation-only tipの`git archive`からfresh stageを作り、少なくとも次を実行する。

1. Godot `4.7.stable.official.5b4e0cb0f` identity
2. fresh editor importと3 script parse
3. Presentation self-check、pure shell smoke、preview smoke
4. required schema、deep-copy／read-only、invalid-update fail-closed checks
5. player／boss／part／harvest anchor、line／sector geometry、position／aim追従 checks
6. 3 reserved event feedback anchorとpayload-independence checks
7. normal／grayscaleでtelegraph 2種とHUDを色以外でも識別できるdeterministic capture
8. existing Gameplay self-check、integration self-check、`fs_a_main.tscn`、candidate-independent QA fixture
9. project main smoke、Phase 1、Slice 2-A `120`、correction `39`
10. `git diff --check`、issuance tip..HEAD exact 5-path scope audit、Forbidden差分`0`

captureはrepository外のunique temporary pathへ出力し、hashとstateをreportへ記録後にexact cleanupする。owner branchでのGUI spot-checkは実施できれば記録するが、10 rework統合後のmanual KBM／readability／user feelを代替しない。player defeat／enemy stop、gamepad、performance、exportはPass主張せず`Not run`／`Deferred`として返す。

## Commit, validation, and Return order

1. exact 3 source pathsだけのimplementation-only commitを作る。
2. そのexact implementation tipの`git archive`からfresh validationを実行する。
3. validation結果、capture identity、source identity mappingを新規report pathだけのreport commitへ記録する。
4. `docs/handoffs/fast-slice/presentation.md`だけのhandoff commitを作る。
5. final tipの3 source blob／prototype treeがtested implementation tipとexact一致し、後続2 commitsがdocs-onlyであることを確認する。
6. 全commitをpushし、local HEAD、tracking ref、live originの同一SHAとworktree cleanを確認する。

Returnにはissuance tipからfinal tipまでの全commitを時系列順に列挙し、frozen source identity→issuance blob一致、issuance→candidate commit ancestry、implementation tip、report tip、final tip、exact changed paths、commands、exit codes、capture identity、warnings、Not runを含める。integrationへ自動mergeせず、00が10→20順でreview／cherry-pickする。
