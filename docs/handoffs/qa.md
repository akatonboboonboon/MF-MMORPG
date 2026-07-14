# QA / Performance / Review Handoff

- Owner role: `30 QA・性能・レビュー`
- Updated by `30 QA`, accepted by `00統括`: 2026-07-14
- Current milestone: M2 / Slice 2-A
- Authorization: Test-plan preparation now; QA-owned validation changes only after `10` handoff
- Phase 1 package source baseline: `a13505e8fbf82962e049b9101a87593a6692d2c7`
- Required starting state: commit containing the active work order; record exact tested `HEAD`
- Current status: Gate 1 archive complete / Slice 2-A implementation handoff pending

Active work order: [`../work-orders/phase2-slice2a-basic-operation.md`](../work-orders/phase2-slice2a-basic-operation.md)

Required Slice 2-A report: `docs/test-reports/phase2-slice2a-validation.md`

Completed Gate 1 work order: [`../work-orders/phase1-gate1-power-revalidation.md`](../work-orders/phase1-gate1-power-revalidation.md)

Gate 1 report: `docs/test-reports/phase1-gate1-power-revalidation.md`

Deferred gamepad work order: [`../work-orders/phase1-gate1-manual-validation.md`](../work-orders/phase1-gate1-manual-validation.md)

Previous report: [`../test-reports/phase1-gate1-manual-validation.md`](../test-reports/phase1-gate1-manual-validation.md)

## Next queue — MFO-WO-P2-2A-001

1. Before the `10` handoff, draft acceptance cases only; do not edit gameplay or freeze an unreturned interface.
2. After the handoff, record the exact tested commit and modify only QA-owned tests／report／evidence.
3. Run fresh Phase 1 regression, Slice 2-A deterministic tests, import／headless smoke, release／export smoke, and
   the conditional arena-idle regression described by the work order.
4. Check KBM movement／aim／Space evade separately from automation and human feel.
5. Keep physical gamepad `Not run / Deferred`; do not infer hardware behavior from mapping tests.
6. Return `Pass / Fail / Blocked` recommendation to `00`. Do not approve Gate 2 or authorize Slice 2-B.

## Initial precheck (historical)

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
- Gate recommendation at precheck: Not approved / Pending

## Latest execution — MFO-WO-P1-G1-002

- Status: QA execution complete / accepted by `00統括`
- Commit tested: repository HEAD `e95b1442759b8b43a3a62a555af4d0e96384dd81`; packaged runtime source baseline `a13505e8fbf82962e049b9101a87593a6692d2c7`
- Environment: Windows 11 Home build `26200`, Intel Core 7 150U, Intel Graphics driver `32.0.101.7077`, 1920×1080 at 60.0007 Hz, standard quality, release-equivalent packaged EXE
- AC power: Online / charging
- AC power mode: Best performance / `ded574b5-45a0-4f42-8737-46345c09c238`
- Power plan: `バランス` / `381b4222-f694-41f0-9685-ff5bb260df2e`（power modeとは別記録）
- DC power mode: Best Power Efficiency / `961cc777-2547-4f9d-8174-7d86181b8a7a`（変更なし）
- Commands and exit codes: empty `0`; arena idle `0`; raw outputとcommand recordを新規evidenceへ保存
- Empty result: 120 warmup＋600 samples、P95 `16.6667 ms`、59.9406 fps from average、Pass
- Arena result: 120 warmup＋600 samples、P95 `16.6667 ms`、59.8417 fps from average、HUD `16.67 ms`とJSON一致、Pass
- Automated result referenced: Phase 1 assertions 36 / 36 Pass（既存記録。今回再実行なし）
- RuntimeHardLimit: RHL-001 N/A、RHL-002 Pass、RHL-003 N/A、violation 0
- Manual KBM evidence: release buildでmove／aim／provisional attack／hitを既存確認
- User KBM feel: `問題なし`（overallだけ）
- Manual gamepad: Not run / Deferred to Gate Playability
- Effort evidence: `26 / 188 = 13.83%`を再計算、Pass。実績時間ではない
- Performance scope: Gate 1 idle baselineのみ。Gate 7／stress／製品最低環境の合格ではない
- Memory / GPU timing: unavailable。合格証拠として扱わない
- Evidence: [`../test-reports/evidence/phase1-gate1/power-revalidation-20260714-best-performance/`](../test-reports/evidence/phase1-gate1/power-revalidation-20260714-best-performance/)
- Test report: [`../test-reports/phase1-gate1-power-revalidation.md`](../test-reports/phase1-gate1-power-revalidation.md)
- Known issues added: 0
- Open questions added: 0
- Gate recommendation: **Pass**
- Gate approval: [`GATE-1`](../../material-frontier-online/decisions/2026-07-14-gate-1-approval.md)でPass

## Current evidence

- `material-frontier-online/deliverables/phase1/evidence/phase1-empty-performance.json`
- `material-frontier-online/deliverables/phase1/evidence/phase1-arena-performance.json`
- `material-frontier-online/deliverables/phase1/evidence/phase1-arena-capture.png`
- `material-frontier-online/deliverables/phase1/MFO-Phase1-Windows-x86_64.zip`
- `material-frontier-online/implementation/2026-07-14-phase1-technical-baseline.md`

Recorded: 36 / 36 assertions, empty P95 16.667ms, arena idle P95 16.667ms, export/smoke Pass。
旧P95の測定時power modeは未記録であり、今回のOD-004適合証拠へ流用しない。新しい再実行結果と区別する。

## Gate 1 work queue

1. ~~`MFO-WO-P1-G1-002`の記録様式を準備する。~~ Done
2. ~~成果物がLFS pointerではなく実体であることを確認する。~~ Pass
3. ~~AC接続中にWindows power modeをBest performanceへ変更・再読込する。~~ Pass
4. ~~AC GUID、power plan、GPU、driver、resolution、refresh、quality、buildを記録する。~~ Pass
5. ~~empty／arena idleを600 samplesで再計測し、HUD、JSON、screenshot、raw stdout、hashを保存する。~~ Pass
6. ~~[工数再見積り](../phase1-effort-reestimate.md)の`26 / 188 = 13.83%`を再検算する。~~ Pass
7. ~~KBM実動作、user overall feel、gamepad Not runを別fieldで集約する。~~ Done
8. ~~Pass／Fail／Blocked／Not runを分け、Gate 1合否を監督へ勧告する。~~ Pass recommendation submitted
9. ~~`00統括`によるevidence reviewとGate 1判定を待つ。~~ Gate 1 Pass / accepted

`30`はuserの体感を推測・代行しない。gamepad未所持中はmanufacturer／model／接続方式を繰り返し質問しない。
Gate 1 queue is closed. Current QA scope is only the active Slice 2-A order and only after its required handoff point.

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
Work order:
Commit tested:
Environment:
Commands and exit codes:
Phase 1 regression:
Slice 2-A automated results:
Manual KBM functional evidence:
User feel (only if actually requested):
Manual gamepad: Not run / Deferred
Performance result and scope:
Artifacts / hashes:
Known issues added:
Open questions added:
Slice recommendation: Pass / Fail / Blocked
Reasons:
```
