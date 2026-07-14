# Governance document instructions

このディレクトリでは、ルート`AGENTS.md`に加えて次を守る。

- `MASTER_SPEC.md`、`DECISIONS.md`、`MILESTONES.md`の規範内容は`00統括`だけが承認・更新する。
- `DECISIONS.md`にはApproved事項だけを置き、未決事項や推奨案を混ぜない。
- 決定にはID、status、authority、date、impact、sourceを付ける。
- 新決定時はMASTER_SPEC、契約、status、milestone、handoffの影響を同じ変更で確認する。
- 凍結仕様の意味を無言で書き換えず、オーバーレイとsource precedenceを維持する。
- 他担当は`OPEN_QUESTIONS.md`へ質問を追記できるが、回答・解決・削除は行わない。
- `work-orders/`は`00`が発行・変更・完了承認し、担当は結果をhandoff／test reportへ記録する。
- `test-reports/`は`30`が事実と証拠を記録する。QA勧告をGate承認として記載しない。
