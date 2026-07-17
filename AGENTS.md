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
00  MFO-WO-P2-2A-010 R4E Fail / external audit-driver lexical extraction defect accepted; candidate-008 unchanged and unevaluated
 ↓
00  MFO-HOLD-P2-2A-001 remains active; Gate 2 Locked; Slice 2-B unauthorized
 ├─→ 30  Recovery Step R4F: line-anchored extractor qualification → one frozen candidate-008 lineage／static／conditional compile／parse closure
 └─→ 20  MFO-WO-P2-20-001 package and administrative handoff frozen; no variant selected; no follow-on
       ↓
00  Review R4F only; no automatic performance, integration, Gate 2, or Slice 2-B approval
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
現在のQA実行例外は
[`MFO-WO-P2-2A-010`](docs/work-orders/phase2-slice2a-qualified-harness-performance-acceptance.md)のRecovery Step R4Fだけである。
R4Eはqualification-003でUnicode path transport、root-first receipt、intentional-failure closure、`24 / 24` manifestをPassし、
formal lineageを1回Passしたが、static extractorが`RunPerformanceContractSelfTest`の完全署名raw tokenを2件検出して停止した。
独立read-only監査では、candidate-008のline 3863が唯一のmethod宣言、line 3989がproduction self-audit用の引用文字列であり、
candidate-007／008のNativeはbyte-identicalだった。したがって監督はR4Eを
`Fail / external audit-driver lexical extraction defect`として受理し、重複methodやcandidate static defectの証拠とは扱わない。
compile／parseは`0`のためcandidate-008は未評価のままである。R4E qualification／formal evidenceとdriverを凍結し、`30`は
新しい外部R4F driverのmethod-region抽出だけを行頭固定の宣言一致へ限定修正し、synthetic fixtureと既存transport／closureを
marker前に資格確認する。合格driverを凍結後、candidate-008を編集せず、一度だけlineage／staticと条件付きcompile／parseを行う。
performance、Stage、PREACK、A／B／C、gameはまだ許可しない。

`20`の
[`MFO-WO-P2-20-001`](docs/work-orders/phase2-presentation-hud-readability-proposal.md)は返却済みであり、監督は
`Integrity`／`Deformation` HUD可読性の非接続proposal packageが票のscopeに適合したことだけを受理した。
A／B／Cはすべて`Proposed / non-binding / not selected`のまま凍結し、variant、production layout／palette／asset、
integration、shared scene、contract、gameplay stateは選択・承認しない。`20`へのfollow-on work orderはなく待機とする。
`10`はgame code／値／profiling seamを変更しない。2-B以降、損傷、表示統合、binding／production asset制作は
別work orderまで変更しない。R4Fまたはpresentation proposalの行政受理だけではperformance、Gate 2、Slice 2-Bは開かない。

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
