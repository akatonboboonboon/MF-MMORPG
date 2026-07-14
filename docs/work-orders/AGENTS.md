# Work-order instructions

このディレクトリでは、ルートおよび`docs/AGENTS.md`に加えて次を守る。

- work orderの発行、scope変更、取消、完了承認は`00統括`だけが行う。
- 各票にID、owner、milestone、authorized scope、forbidden scope、acceptance、report pathを含める。
- work orderは未決仕様を暗黙決定しない。必要な決定IDがOpenなら実装票を発行しない。
- 担当は結果をhandoff／test reportへ記録し、元work orderの命令文を成功したことに合わせて書き換えない。
- Gate work orderの完了とGate承認を分離する。
