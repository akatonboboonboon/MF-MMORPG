# QA and test instructions

このディレクトリでは、ルート `AGENTS.md` に加えて次を守る。

- 失敗を通すために期待値、assertion、受入条件を弱めない。
- 自動テスト、手動確認、性能計測を区別して報告する。
- 「記録上Pass」と「この変更で再実行してPass」を区別する。
- live inputを停止した決定的テストと、人間による実入力・操作感評価を混同しない。
- 性能測定はリリース相当ビルド、基準端末、画質、電源モード、サンプル条件を記録する。
- `PrototypeStressTarget`、`RuntimeHardLimit`、`ProductTarget` を混同しない。
- QAはGate合否を勧告できるが、`MILESTONES.md` のGateを承認済みに変更しない。
- 新しい不具合は `docs/KNOWN_ISSUES.md`、仕様不足は `docs/OPEN_QUESTIONS.md` へ分けて報告する。

証拠には、実行コマンド、commit、環境、結果、失敗時のログ位置を含める。
