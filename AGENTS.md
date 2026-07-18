# Material Frontier Online — Repository Instructions

## Purpose

このリポジトリでは、チャットを作業机、リポジトリ内の文書を共有記憶として扱う。
チャット間で会話履歴が完全共有されることを前提にしない。

`00統括（監督）` が仕様解釈、意思決定、スコープ、マイルストーン承認を管理する。
担当チャットは、割り当てられた実装・検証を行うが、新仕様を独自決定しない。

## Source of truth

矛盾する記述がある場合は、次の順で解決する。

1. 現在のユーザーによる明示指示
2. [`docs/DECISIONS.md`](docs/DECISIONS.md) の `Approved` 決定
3. [`docs/MASTER_SPEC.md`](docs/MASTER_SPEC.md) の実装用正規化仕様
4. [`docs/MILESTONES.md`](docs/MILESTONES.md) の承認済み工程境界
5. `material-frontier-online/decisions/` の原決定記録
6. `material-frontier-online/specification/` と凍結済み統合仕様書

進捗の事実は [`docs/IMPLEMENTATION_STATUS.md`](docs/IMPLEMENTATION_STATUS.md)、既知問題は
[`docs/KNOWN_ISSUES.md`](docs/KNOWN_ISSUES.md)、担当間の作業状態は `docs/handoffs/` を参照する。

`material-frontier-online/specification/` 内に残る `Gate 0: Closed`、P0未承認、候補表現は
凍結時点の履歴である。2026-07-13決定記録と `docs/DECISIONS.md` が明示的に上書きする。

## Delivery target

既存仕様を変更せず、Gate 8縦切り試作を2026-09-18までに完成させる。2026-08-18を挑戦目標とし、
基準checkpointと日程運用は [`docs/MILESTONES.md`](docs/MILESTONES.md#gate-8-delivery-target) に従う。
この日程はGate条件、work order authority、受入条件、未承認仕様の実装境界を変更しない。

## Roles

| Role | Primary responsibility | Handoff |
|---|---|---|
| `00統括（監督）` | 仕様解釈、P0/P1/P2決定、スコープ、質問回答、決定記録、マイルストーン承認、仕様差分 | 全文書 |
| `10ゲームプレイ・コア実装` | 入力、権威シミュレーション、戦闘、データ定義、ゲームプレイ状態 | `docs/handoffs/gameplay.md` |
| `20ステージ・UI・グラフィック` | 表示、UI、VFX、カメラ、ステージ表現、可読性 | `docs/handoffs/presentation.md` |
| `30 QA・性能・レビュー` | テスト、再現、性能計測、仕様適合レビュー、Gate合否勧告 | `docs/handoffs/qa.md` |

音楽・SE・ボイス、ネットワーク・サーバー、アカウント・永続データの担当は現在未設置である。
`docs/MILESTONES.md` に監督の有効化記録が追加されるまで、そのスコープを実装しない。

## Execution order

全担当を常時同時起動しない。現在の必須順序は次のとおり。

```text
00  MFO-WO-P2-2A-010 R5K-C Blocked accepted as external FORMAL artifact producer-consumer order defect after INIT
 ↓
00  MFO-HOLD-P2-2A-001 remains active; Gate 2 Locked; Slice 2-B unauthorized
 ├─→ 30  MFO-WO-P2-2A-011: one consolidated, timeboxed Stage P recovery packet → PREPARED only
 └─→ 20  MFO-WO-P2-20-001 package and administrative handoff frozen; no variant selected; no follow-on
       ↓
00  Review MFO-WO-P2-2A-011 Stage P PREPARED closure; no automatic PREACK, performance, integration, Gate 2, or Slice 2-B approval
 ↓
10  No game-code work / 20 no follow-on work
```

物理gamepadのLS／RS／主要アクションとgamepad操作感は`Not run / Deferred`とし、入手後かつ遅くとも
Gate Playability承認前に`30 + user`が検証する。KBM結果でgamepadをPassにしない。

Gate 1は2026-07-14にPassした。Phase 2 entry P1は承認済みだが、Slice 2-A correction QAの機能項目Passと
`MFO-WO-P2-2A-004`のKBM Passだけを受理している。correction performance Failは保持し、`-003`／`-004`／
`-005`のcontrolled matrixはvalid run `0`であるため、現在のperformance acceptanceは未解決である。
`MFO-WO-P2-2A-005`はOneDrive-family検出とQA手順／harness不適合によりBlockedとして返却され、現在は
[`MFO-HOLD-P2-2A-001`](docs/work-orders/phase2-slice2a-performance-external-hold.md)がperformance acceptanceに対して
有効である。容量増加、生成link除去、user-authorized OneDrive shutdown後のpreliminary count `0`をmaterial
host-condition changeとして監督が受理し、明示的な
[`MFO-WO-P2-2A-006`](docs/work-orders/phase2-slice2a-harness-qualification.md)を発行したが、PREACK production pathの
`PowerGetEffectiveOverlayScheme` ABI不一致により`Fail / harness defect`で返却された。`-007`のdirect-`out Guid`
修正とseal前smokeはPassしたが、preparation receipt identity欠落、旧`-006 START_ACK`、完全PREACK recordの
永続化前判定という3件のharness契約不適合で再び`Fail / harness defect`となった。`-008`はそれらを修正し、PREACK、
exact user activation、61-sample LIVE、host stability、global slot `0`まで完走したが、各sampleのslot field欠落、
sentinel cleanup前の`n=0`保存、LIVE evaluationのfield-completeness結果欠落により正式には`Fail / harness defect`
となった。[`MFO-WO-P2-2A-009`](docs/work-orders/phase2-slice2a-harness-live-evidence-correction-requalification.md)は
この3件を限定修正し、5-mode preparation、PREACK、exact user activation、61-sample LIVE、host stability、
corrected ordering／completeness、global／per-sample slot `0`を確認して`Pass / harness qualified`で返却され、
2026-07-16に監督が受理した。この結果はnon-performance harness資格確認だけであり、P95、KBM、A／B／C、
gameは実行していない。performance acceptanceには
[`MFO-HOLD-P2-2A-001`](docs/work-orders/phase2-slice2a-performance-external-hold.md)が引き続き有効である。
現在のQA実行例外は、親票[`MFO-WO-P2-2A-010`](docs/work-orders/phase2-slice2a-qualified-harness-performance-acceptance.md)の
Stage P recoveryだけを扱う[`MFO-WO-P2-2A-011`](docs/work-orders/phase2-slice2a-stage-p-consolidated-recovery.md)である。
R4Eはqualification-003でUnicode path transport、root-first receipt、intentional-failure closure、`24 / 24` manifestをPassし、
formal lineageを1回Passしたが、static extractorが`RunPerformanceContractSelfTest`の完全署名raw tokenを2件検出して停止した。
独立read-only監査では、candidate-008のline 3863が唯一のmethod宣言、line 3989がproduction self-audit用の引用文字列であり、
candidate-007／008のNativeはbyte-identicalだった。したがって監督はR4Eを
`Fail / external audit-driver lexical extraction defect`として受理し、重複methodやcandidate static defectの証拠とは扱わない。
compile／parseは`0`のためcandidate-008は未評価のままである。R4E qualification／formal evidenceとdriverを凍結し、`30`は
R4Fはexecution infrastructureでBlocked、R4Gはexternal driver call-site boundary mismatchでFailとなった。R4Hは
exact-one preflight、qualification `31 / 31`、corrected binding fixture、formal repo check／lineage／static、exact six compile、
two PowerShell parse-only checksを全てPassした。candidate-008は`8 / 8`不変、generated output launch／StagePreparer／Stage／
PREACK／performance／A／B／C／gameは全て`0`である。監督はR4Hを
`Pass / audit-driver qualified and corrected static matcher compile/parse closure only`として受理し、KI-017を解決する。
R5はBOMなしUTF-8 driverの日本語path誤読で停止し、R5AはASCII-only化と実Unicode path／candidate 8/8を
確認したが、正常な空stderrをmandatory `byte[]`が拒否してqualification中に停止した。R5Bはempty collection許可と
0-byte write／readback fixtureをexact-one qualificationでPassし、fresh Native／StagePreparer compile、INIT、
RepositoryStateもPassした。CONTRACTはcandidate-008 NativeがbaselineのLF-onlyに対してCRLF `121`＋LF-only `5895`の
mixed newlineであること、およびStagePreparer allowlist／method boundaryがSection 3の既存差分`24 / 54` hunksを
unauthorizedと誤分類することによりexit `30`で停止した。監督はR5Bを
`Fail / candidate harness preparation nonconformance`として受理するが、game／performance defectとは扱わない。
`30`はR5Cでcandidate-009をcandidate-008からexact copyしたが、書込み前のinline promotion commandがWindows
PowerShell 5に存在しない`SHA256.HashData`で停止した。candidate correction write、compile／parse、c3、Stage、runtimeは
全て`0`でcandidate-009は`8 / 8` seed-identicalである。helper file、command／stream／exit record、marker、root、
manifestも永続化前で不存在のため、監督はR5Cを
`Blocked / promotion driver API incompatibility before file write`として受理する。R5Dは別helperを追加せず、
資格確認済みR5B c2からfresh c3を作り、PowerShell 5互換hashとcandidate-010変換をstate-free QUALIFYで先に証明し、
QUALIFYをPassした。FORMALはcandidate-010へ指定2 fileをexact適用した後、external Git diffのhunk数を
StagePreparer内部LCSと同じ`54`と要求したため、Git固有の正値`53`でfail-closed停止した。candidate-010 Nativeは
`456449` bytes／`d5068baeb983df3ee88f365d54876273e271c3c59446a22ebcbcfbabdb7de1a9`、StagePreparerは
`219515` bytes／`76a2aa3a1dfefcdd08245eafa5d7fccdf9f8e6241b3abc47821bad6f1bfef1aa`で、他6 filesもseedと
byte-identicalである。監督はR5Dを`Fail / external Git hunk-count acceptance false negative`として帰属し、
candidate／game／performance defectとは扱わない。R5Eはfresh c4のQUALIFY中、RoleContext限定fixtureの
`[int[]]@($bn+1,$cn+1)`をWindows PowerShell 5が`Object[]`加算として評価し、bounded fixture evidence生成前に停止した。
監督は`Blocked / external qualification fixture runtime type error`として受理し、candidate-010、production harness、
game、performance defectとは扱わない。R5Fはfresh c5で2次元配列生成式を
PowerShell 5で一意な`CreateInstance(Type, Int32, Int32)`へ直したが、QUALIFYの最初のfrozen R5E lineage
manifest比較で、diff manifestの`name / size`とqualification manifestの`relative_path / byte_size`を一律後者として
読んだため停止した。監督は`Blocked / external frozen-lineage manifest schema binding mismatch`として受理し、
candidate-010、production harness、game、performance defectとは扱わない。R5Gはfrozen c5からfresh c6を作り、
既知2 schemaへのexact field dispatchを実装したが、c5→c6 detailed diff `251`行の外部分類で、frozen R5F lineage
loopを閉じる唯一の`+        }`だけが未分類となり、QUALIFY前に停止した。機械証拠はschema dispatch `19`、
R5F lineage `17`、mechanical `214`、unauthorized `1`のまま凍結する。独立read-only監査は当該行が同一hunk内の
許可済みlineage blockの構造的終端であり、他の未分類行やsemantic driftがないことを確認した。監督はR5Gを
`Fail / external c5-to-c6 diff-audit structural-line classification false positive`として受理し、c6、candidate-010、
production harness、game、performance defectの証拠とは扱わない。R5Hはfrozen c6からfresh c7をexact 1回作ったが、
外部c6→c7 diff-audit commandのidentity helperが`return[ordered]@`を実行し、Git diff child前に停止した。c7現物は
`87132` bytes／`a3da5cb41f6b248bbef2a90d63a12a89752e17ac66174833db24e067d6c5b554`、ASCII、BOMなし、ReadOnlyで、
不正tokenは`0`、正常な`return [ordered]@`は`2`である。partial audit rootはReadOnlyだが完全に空で、raw command／
stream／exit／marker／manifestは存在しないため、exact error、outer exit、Git child countはQA返却依存でありdurable
artifactから独立証明しない。監督はR5Hを`Blocked / external c6-to-c7 diff-audit helper syntax defect before diff
invocation`として受理し、c7、candidate-010、production harness、game、performance defectとは扱わない。c7は`ExecutionHead=1b520e6…`を固定するため新監督commit後に直接実行できなかった。R5Iはfresh external audit driverの
qualification、fresh c8、c7→c8 audit、c8 QUALIFYを全てPassした。FORMALでもexact six compile、two PowerShell
parse-only、fresh Native／StagePreparer tool build、INIT、RepositoryState、CONTRACTをPassし、CONTRACT source-diffは
changed `54`、unauthorized hunk／class `0`、LF／BOM一致を確認した。最初の`QP_DRYRUN` runner自体はresult code `0 / Pass`で
root `performance_slot_attempt_count=0`を保存したが、Pass detailsに同fieldがなく、wrapperが必須property欠落としてexit `1`で
停止した。detailsにはlaunch／ABC／final-owned各`0`があり、後続5 mode、PreSealOwnership、SEALは`0`である。監督はR5Iを
`Fail / candidate harness preparation-details schema nonconformance`として受理し、game／performance defectとは扱わない。
R5JはQUALIFYをPassしたが、FORMALでcandidate-010からcandidate-011をcloneした直後、byte identity確認より先に
fresh clone tree全体のReadOnlyを要求したため停止した。semantic write、bounded static、compile、parseは全て`0`で、
candidate-011はcandidate-010と`8 / 8` seed-identicalのままReadOnlyで凍結されている。監督はこれを
`Blocked / external R5J driver clone-tree ReadOnly precondition mismatch before semantic write`として受理し、
candidate correction、production harness、game、performance defectとは扱わない。R5J-Aはfresh candidate-012をexact 1回作り、
byte-first identity、既存`Freeze-Tree`、Native-only exact 1行write／`finally` restore、bounded static、fresh six compile、
two PowerShell parse-onlyを全てPassした。candidate-012 Nativeは`456534` bytes／
`167634f7854ae9db5b061e65a8f6148c3ffe0aa399ee66d54bf2039db9fd86c1`、LF-only `6017`、BOMなしで、tree `11 / 11`は
ReadOnlyである。監督はR5J-Aを`Pass / candidate-012 exact correction and compile／parse closure only`として受理する。
R5Kはfresh d1のQUALIFYをexact 1回開始したが、最初のfrozen-R5I lineage closureで停止した。PowerShellでは変数名が
case-insensitiveであるため、path `$FrozenR5IDriver`がidentity `$frozenR5iDriver`でOrderedDictionaryへ上書きされ、直後の
`Get-Item -LiteralPath`が型名をpathとして受け取った。candidate-012、FORMAL、tool build、Stage、runtimeは全て不変／`0`である。
正式返却分類は`Blocked / external R5K qualification lineage serialization-path binding before candidate/tool/Stage`
である。監督はBlocked境界を受理し、停止原因を`external qualification driver case-insensitive variable collision`
と帰属する。R5K-Aはfresh d2でR5I identity 4参照とR5J-A identity 2参照を専用名へ改め、d1→d2 detailed auditと
paired collision fixtureをPassした。続くQUALIFYは、凍結prequalification manifestと実列挙が同じ4 payload／identityを
保持する一方、d2の固定期待名配列だけが異なる順序だったため、FORMAL前に停止した。正式返却分類は
`Blocked / external R5K-A prequalification payload-order binding mismatch before FORMAL`であり、監督はこれを外部driverの
positional expected-name false negativeとして受理する。R5K-Bはfresh d3で期待順1件を実順へ直し、fresh d2→d3監査とorder fixtureをPassした。v3は`41077` bytes／
`d3d81fc0ab1b13f0218b677a75c3016666dd5142ddeea7946cf168d513c5b259`、d3は`138180` bytes／
`c2381abcb73e3236fe175b5eb62e355486149da9bf4d6a0b455dd35e37706e78`である。QUALIFYは
`$frozenR5kaDriverIdentity`を4回参照した後に同変数を初期化するd3の順序によりStrictModeで停止し、FORMAL、tool、
Stage、runtimeは全て`0`だった。正式返却分類は`Blocked / external d3 qualification lineage initialization-order defect before FORMAL`
であり、candidate-012、production harness、game、performance defectではない。R5K-Cはfresh d4のQUALIFYまでPassし、FORMALで
tool buildとINITをPassした後、CONTRACTが生成する`compile-and-source-audit.json`をCONTRACT前に読んだため停止した。監督はこれを
`Blocked / external FORMAL artifact producer-consumer order defect after INIT`として受理し、candidate-012、StagePreparer、game、performanceの
defect証拠とは扱わない。独立監査では、A／B／Cの3つの`Assert-Identity`がPowerShell AST上1 commandへ結合される潜在不適合
`CP-ABC-001`も確認した。`MFO-WO-P2-2A-011`は両件と到達可能な同系統欠陥をread-only censusでまとめ、最大3 offline candidate、
final QUALIFY exact 1回、FORMAL exact 1回のtimeboxed consolidated recoveryとしてPREPAREDまでだけを扱う。PREACK、performance、
A／B／C real slot、game、quiet window、OneDrive／power変更は`-011`で許可しない。

`20`の
[`MFO-WO-P2-20-001`](docs/work-orders/phase2-presentation-hud-readability-proposal.md)は返却済みであり、監督は
`Integrity`／`Deformation` HUD可読性の非接続proposal packageが票のscopeに適合したことだけを受理した。
A／B／Cはすべて`Proposed / non-binding / not selected`のまま凍結し、variant、production layout／palette／asset、
integration、shared scene、contract、gameplay stateは選択・承認しない。`20`へのfollow-on work orderはなく待機とする。
`10`はgame code／値／profiling seamを変更しない。2-B以降、損傷、表示統合、binding／production asset制作は
別work orderまで変更しない。`MFO-WO-P2-2A-011` PREPARED Passまたはpresentation proposalの行政受理だけではPREACK、performance、Gate 2、Slice 2-Bは開かない。

Gate 1通過後の標準順序:

```text
00  必要P1決定とPhase 2 work order
 ↓
10  Slice 2-A → 2-B → 2-C → 2-D
 ↓          ↘
30 各slice QA   20 契約確定済み部分だけ表示統合
        ↘       ↓
          integration build
                 ↓
              30 Gate 2検証
                 ↓
              00 Gate 2判定
```

`20`はイベント契約前でも、codeに接続しない`Proposed` mockup／候補制作だけ並行できる。
`30`は最後だけでなく各slice後に検証する。

## Mandatory rules

- 未承認仕様を実装しない。
- 未確定事項を発見したら推測で決めず、`docs/OPEN_QUESTIONS.md` に記録し、影響範囲の実装を停止して `00統括` へ戻す。
- `Approved` 決定を変更・拡張・言い換えで実質変更しない。
- スコープ外機能、ついでの基盤、将来オンライン向け抽象化を追加しない。
- Presentation、UI、VFX、音響、パーティクルから戦闘状態、HP、部位、報酬、乱数を変更しない。
- 素材別の専用プレイヤークラスや、技別の専用ダメージ系を作らない。
- `MaterialJob` は性能と壊れ方、`CombatForm` は操作とアクション、core `EquipmentInstance` は可変損傷状態を所有する。
- 視覚パーティクル、光、カメラ、音は戦闘結果を決定しない。
- 凍結済みWordと `material-frontier-online/specification/` を直接改訂しない。変更提案は質問・決定オーバーレイとして扱う。
- 変更後は担当範囲のテストを実行し、実行したコマンドと結果を担当handoffへ記録する。
- テスト未実行、失敗、手動確認未完了を成功扱いにしない。
- 完了報告前に担当handoffを更新する。`IMPLEMENTATION_STATUS.md` と `MILESTONES.md` の承認状態は監督だけが確定する。
- `main` への直接push、他担当ファイルの編集、担当間ファイルの同時編集は、監督の明示許可なしに行わない。
- R5K-C以後のQA external-driver recoveryは一欠陥ごとのmicro-recovery連鎖にせず、既知・到達可能な欠陥を1件のtimeboxed consolidated packetへ集約する。formal開始後のrepair／retryと受入条件の緩和は禁止する。

## Escalation

仕様不足、矛盾、既存決定では一意に解けない設計選択を見つけた場合:

1. 影響する実装を止める。無関係な確定作業は続行してよい。
2. `docs/OPEN_QUESTIONS.md` のテンプレートで質問を追記する。
3. 担当handoffに、停止したファイル・機能・必要期限を記録する。
4. `00統括` の回答を待つ。
5. 監督が `docs/DECISIONS.md` へ `Approved` として記録するまで、回答案を仕様として使用しない。

## Document ownership

- 監督のみ: `docs/MASTER_SPEC.md`, `docs/DECISIONS.md`, `docs/MILESTONES.md`
- 監督が統合: `docs/IMPLEMENTATION_STATUS.md`, `docs/ASSET_CONTRACTS.md`, `docs/KNOWN_ISSUES.md`
- 全担当が質問追記可、監督のみ解決可: `docs/OPEN_QUESTIONS.md`
- 各担当: 自担当の `docs/handoffs/*.md`
- `00`: `docs/work-orders/` の発行・scope・完了承認
- `30`: `docs/test-reports/` と新規の検証証拠。既存証拠を結果に合わせて改変しない。

## File ownership

| Role | Primary paths |
|---|---|
| `00` | `AGENTS.md`, `docs/MASTER_SPEC.md`, `docs/DECISIONS.md`, `docs/MILESTONES.md`, `docs/work-orders/`, status／contract統合 |
| `10` | `material-frontier-online/prototype/scripts/input/`, `combat/`, `simulation/`, `phase1/`, gameplay data、割当済みgameplay scene |
| `20` | `material-frontier-online/prototype/scripts/presentation/`, 割当済みvisual／UI child scene、将来のpresentation assets |
| `30` | `material-frontier-online/prototype/tests/`, QA fixture、`docs/test-reports/`, 新規benchmark／evidence |

未存在directoryを所有表のためだけに作らない。

`.tscn`、`project.godot`、共通data、contractは単一ownerをwork orderまたはhandoffで指定してから編集する。
たとえばgameplay grayboxがvisual child sceneをinstance化する境界を使い、`10`と`20`が同じplayer sceneを同時編集しない。

## Parallel-work rules

並行してよい:

- `10`のgameplay logicと、`20`の非接続mockup／外部asset候補
- `10`のslice実装と、`30`のapproved behaviorに対するtest case準備
- `20`の仮HUD候補と、`30`のstate検証項目
- `00`の判断材料整理と、`30`の結果report

並行してはいけない:

- `10`と`20`による同一`.tscn`／player scene編集
- `20`によるhit判定、damage、attack timing、resourceの変更
- `30`によるtestを通すためのgame値変更
- 複数担当による`STATUS`、`DECISIONS`、`MILESTONES`の同時更新
- active work orderに明記されていないPhase 2正式機能
- production art、music、voiceの未承認量産

## Shared-file protocol

`.tscn`、共通データ定義、`project.godot`、`ASSET_CONTRACTS.md` など複数担当が触れるファイルは、
作業前に担当handoffへ予定ファイルと目的を記載し、単一の担当を決める。
同一ファイルの並行編集を避け、境界変更は契約文書を先に更新する。

## Repository and tools

- Godot: `4.7.stable.official.5b4e0cb0f`
- Language: GDScript
- Renderer: GL Compatibility
- Project: `material-frontier-online/prototype`
- Windows target: x86_64 portable
- `.exe` と `.zip` はGit LFS管理。LFSポインタだけの状態で成果物検証をしない。

代表的な検証コマンドは `material-frontier-online/prototype/README.md` と
`docs/handoffs/qa.md` を参照する。
