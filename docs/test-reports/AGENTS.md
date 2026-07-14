# Test-report instructions

このディレクトリは`30 QA・性能・レビュー`が検証事実を記録する。

- reportにはwork order ID、tested commit、environment、command／manual steps、expected、actual、evidence、resultを含める。
- Pass、Fail、Blocked、Not runを区別する。
- 自動test、manual operation、human feel、performanceを混同しない。
- reportをPassにするためにevidence、期待値、既知失敗を書き換えない。
- QAはGateを勧告できるが、承認しない。
- 仕様質問は`OPEN_QUESTIONS.md`、確認済みdefect／evidence gapは`KNOWN_ISSUES.md`へ送る。
