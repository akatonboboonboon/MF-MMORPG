# QA / Performance / Review Handoff

- Owner role: QA・性能・レビュー担当
- Updated by supervisor: 2026-07-14
- Current milestone: M1 / Gate 1 review
- Authorization: Verify, collect evidence, report defects, recommend Gate result
- Baseline commit: `a13505e8fbf82962e049b9101a87593a6692d2c7`

## Current evidence

- `material-frontier-online/deliverables/phase1/evidence/phase1-empty-performance.json`
- `material-frontier-online/deliverables/phase1/evidence/phase1-arena-performance.json`
- `material-frontier-online/deliverables/phase1/evidence/phase1-arena-capture.png`
- `material-frontier-online/deliverables/phase1/MFO-Phase1-Windows-x86_64.zip`
- `material-frontier-online/implementation/2026-07-14-phase1-technical-baseline.md`

Recorded: 36 / 36 assertions, empty P95 16.667ms, arena idle P95 16.667ms, export/smoke Pass。
これは記録上の結果であり、新しい変更で再実行した結果とは区別する。

## Gate 1 work queue

1. `git lfs pull`済みで成果物がpointerではないことを確認。
2. commit、Godot version、CPU、GPU、RAM、OS build、GPU driver、resolution、refresh、quality、build、
   Windows電源設定の実表示名を記録。
3. 実ゲームパッドでLS移動、RS照準、neutral時の照準保持、X仮攻撃を確認。
4. 人間が移動、照準、仮攻撃の操作感を評価し、観察結果を記録。
5. Phase 1実績／再見積りと試作全体見積りを同じ単位で比較し、15%以下か確認。
6. import／parse、36 tests、main scene smoke、Windows export、EXE smoke、ZIP extract smokeを再実行。
7. HUD P95とJSON、artifact hashesを照合。
8. Pass／Fail／Blockedを分け、Gate 1合否を監督へ勧告。

## Representative commands

`godot`はGodot 4.7 stable console executableへのpathまたはaliasとする。

```powershell
godot --headless --editor --path material-frontier-online/prototype --quit
godot --headless --path material-frontier-online/prototype --script res://tests/run_phase1_tests.gd
godot --headless --path material-frontier-online/prototype `
  --export-release "Windows Desktop" build/windows/MFO-Phase1.exe
```
計測は `material-frontier-online/prototype/README.md` のrelease EXE手順を使う。外部入力を停止したidle測定と
通常起動の操作感確認を混ぜない。

## Review rules

- idle baselineを`PrototypeStressTarget`、Gate 7、製品性能の合格と呼ばない。
- RHL-001／003 N/Aを実機能のPassと呼ばない。
- 自動mapping testを実ゲームパッド手動確認の代わりにしない。
- raw command、stdout、exit code、commit、environment、evidence pathを保存する。
- defectは`KNOWN_ISSUES.md`、仕様不足は`OPEN_QUESTIONS.md`へ分ける。
- QAはGateを承認せず、証拠付きの勧告を提出する。

## Required handoff update

```text
Status:
Commit tested:
Environment:
Commands and exit codes:
Automated results:
Manual gamepad results:
Human feel result:
Performance result and scope:
Artifacts / hashes:
Known issues added:
Open questions added:
Gate recommendation: Pass / Fail / Blocked
Reasons:
```
