# Material Frontier Online — Known Issues and Evidence Gaps

- Updated: 2026-07-14
- Scope: 確認済みの不具合、制約、証拠不足。仕様未決は [`OPEN_QUESTIONS.md`](OPEN_QUESTIONS.md) へ置く。

| ID | Type | Severity | Description | Impact / next action | Owner | Status |
|---|---|---|---|---|---|---|
| KI-001 | Manual validation gap | Playability blocker | gamepad未所持のためLS／RS／主要アクション、drift、多重入力、体感が未確認 | OD-013を維持し、入手後かつGate Playability承認前に検証 | `30 QA` + user | Deferred awaiting hardware |
| KI-002 | Evidence gap | Resolved for Gate 1 | actual effort logがなくPhase 1実績時間比は復元不能 | 同一EP再見積りの保守式13.83%を採用。scope縮小時は再判定 | Supervisor | Mitigated / Pass by re-estimate |
| KI-003 | Environment nonconformance | Resolved for Gate 1 | 初回はAC/DC Best Power EfficiencyでOD-004に不適合だった | AC Best performanceへ変更し、empty／arena P95 `16.6667 ms`を取得 | `30 QA` + user | Resolved / Gate 1 Pass evidence |
| KI-004 | Measurement limitation | Medium | GL Compatibilityでportableなper-frame GPU timingが取れず、`static_memory_bytes`は0。Phase 1 CPU monitor値も受入判定に未使用 | Gate 7までに取得可能な計測手段を決める。idle frame P95だけを過大解釈しない | QA | Open |
| KI-005 | Evidence metadata | Low | `phase1-arena-performance.json`の`capture_path`が旧`.../New project/...`絶対パスを参照 | 成果物とhashは有効。次回計測ではworkspace相対または現行パスを記録 | QA | Open |
| KI-006 | Evidence archive | Medium | 36 assertions、import/export、EXE/ZIP smokeのraw stdoutがdeliverablesへ保存されていない。報告書と成果物hashのみ | 次回Gate証拠ではcommand、stdout、exit code、commitを保存 | QA | Open |
| KI-007 | Coverage gap | Medium | RHL-001とRHL-003はPhase 1でN/A。8部位、規定外scheduler、粒子→ルール参照を拒否する負例fixtureは未実装 | 該当機能を実装するPhaseでnegative testsを追加 | Gameplay + QA | Deferred to relevant phase |
| KI-008 | Historical wording | Low | 凍結Markdown仕様に`Gate 0: Closed`と未承認P0表現が残る | 凍結文書は変更しない。AGENTS／MASTER_SPEC／DECISIONSの優先順位を維持 | Supervisor | Mitigated |
| KI-009 | Gameplay defect / `MFO-P2-2A-QA-001` | P1 acceptance blocker / runtime Low | input deadzone後もnonzeroの小さいmoveをauthority／actorの追加epsilonがneutral扱いし、回避がmove方向ではなくaimへfallbackする | `MFO-WO-P2-2A-002`で2つのevade nonzero条件だけをexact-zero判定へ是正し、30がfresh再検証 | `10 Gameplay` + `30 QA` | Open / correction active |

## Not a defect

- Phase 1の旧空／アリーナidle P95はpower mode未記録のためGate 1証拠へ流用せず、AC Best performanceで
  再計測した。新P95はGate 1だけのidle baselineであり、最大負荷、Gate 7、製品最低環境の保証ではない。
- RHL-001／003のN/Aは、該当機能をPhase 1へ先行実装しないスコープ判断である。
- 正式アクション、素材、損傷、魔法、ボス、ステージが未実装なのは現在の工程境界どおりである。
