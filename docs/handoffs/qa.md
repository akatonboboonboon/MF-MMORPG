# QA / Performance / Review Handoff

- Owner role: `30 QA・性能・レビュー`
- Updated by supervisor: 2026-07-14
- Current milestone: M1 / Gate 1 review
- Authorization: Verify, collect evidence, report defects, recommend Gate result
- Baseline commit: `a13505e8fbf82962e049b9101a87593a6692d2c7`
- Current status: Power-mode nonconformance confirmed / revalidation active

Active work order: [`../work-orders/phase1-gate1-power-revalidation.md`](../work-orders/phase1-gate1-power-revalidation.md)

Required report: `docs/test-reports/phase1-gate1-power-revalidation.md`

Deferred gamepad work order: [`../work-orders/phase1-gate1-manual-validation.md`](../work-orders/phase1-gate1-manual-validation.md)

Previous report: [`../test-reports/phase1-gate1-manual-validation.md`](../test-reports/phase1-gate1-manual-validation.md)

## Latest precheck

- ZIP SHA-256: Match
- EXE SHA-256: Match
- Git LFS: Real artifacts present
- OS: Windows 11 Home `10.0.26200`
- GPU: `Intel(R) Graphics`
- GPU driver: `32.0.101.7077` (`2025-09-16`)
- Windows power plan display name: `バランス`
- AC/DC power mode GUID: `961cc777-2547-4f9d-8174-7d86181b8a7a` (`Best Power Efficiency`)
- OD-004 power result: Fail / Best performance revalidation required
- Gamepad: Not owned / Windows not detected / Deferred to Gate Playability
- KBM user overall feel: `問題なし`
- Gate recommendation: Not approved / remain Pending

## Current evidence

- `material-frontier-online/deliverables/phase1/evidence/phase1-empty-performance.json`
- `material-frontier-online/deliverables/phase1/evidence/phase1-arena-performance.json`
- `material-frontier-online/deliverables/phase1/evidence/phase1-arena-capture.png`
- `material-frontier-online/deliverables/phase1/MFO-Phase1-Windows-x86_64.zip`
- `material-frontier-online/implementation/2026-07-14-phase1-technical-baseline.md`

Recorded: 36 / 36 assertions, empty P95 16.667ms, arena idle P95 16.667ms, export/smoke Pass。
旧P95の測定時power modeは未記録であり、今回のOD-004適合証拠へ流用しない。新しい再実行結果と区別する。

## Gate 1 work queue

1. `MFO-WO-P1-G1-002`を正として、power revalidationの記録様式を準備する。
2. ~~`git lfs pull`済みで成果物がpointerではないことを確認。~~ Pass
3. userがAC電源でWindows power modeをBest performanceへ変更する。
4. AC GUID=`ded574b5-45a0-4f42-8737-46345c09c238`、power plan、GPU、driver、resolution、refresh、
   quality、buildを記録する。
5. empty／arena idleを600 samplesで再計測し、HUD、JSON、screenshot、raw stdout、hashを保存する。
6. [工数再見積り](../phase1-effort-reestimate.md)の`26 / 188 = 13.83%`を再検算する。
7. KBM実動作、user overall feel、gamepad Not runを別fieldで集約する。
8. Pass／Fail／Blocked／Not runを分け、Gate 1合否を監督へ勧告する。

`30`はuserの体感を推測・代行しない。gamepad未所持中はmanufacturer／model／接続方式を繰り返し質問しない。
report完了後もGate状態を変更せず、`00`へ返す。

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
- KBM overall feelをgamepadまたは個別feel項目のPassへ拡張しない。
- raw command、stdout、exit code、commit、environment、evidence pathを保存する。
- defectは`KNOWN_ISSUES.md`、仕様不足は`OPEN_QUESTIONS.md`へ分ける。
- QAはGateを承認せず、証拠付きの勧告を提出する。

## Required handoff update

```text
Status:
Commit tested:
Environment:
AC power mode display / GUID:
Commands and exit codes:
Automated results:
Manual KBM evidence:
User KBM feel (verbatim scope):
Manual gamepad results: Not run / Deferred
Performance result and scope:
Artifacts / hashes:
Known issues added:
Open questions added:
Gate recommendation: Pass / Fail / Blocked
Reasons:
```
