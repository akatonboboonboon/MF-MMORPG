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
| ゲームプレイ・コア実装 | 入力、権威シミュレーション、戦闘、データ定義、ゲームプレイ状態 | `docs/handoffs/gameplay.md` |
| ステージ・UI・グラフィック | 表示、UI、VFX、カメラ、ステージ表現、可読性 | `docs/handoffs/presentation.md` |
| QA・性能・レビュー | テスト、再現、性能計測、仕様適合レビュー、Gate合否勧告 | `docs/handoffs/qa.md` |

音楽・SE・ボイス、ネットワーク・サーバー、アカウント・永続データの担当は現在未設置である。
`docs/MILESTONES.md` に監督の有効化記録が追加されるまで、そのスコープを実装しない。

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
- QA: 新規の検証証拠。既存証拠を結果に合わせて改変しない。

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
