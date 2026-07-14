# Material Frontier Online — Known Issues and Evidence Gaps

- Updated: 2026-07-14
- Scope: 確認済みの不具合、制約、証拠不足。仕様未決は [`OPEN_QUESTIONS.md`](OPEN_QUESTIONS.md) へ置く。

| ID | Type | Severity | Description | Impact / next action | Owner | Status |
|---|---|---|---|---|---|---|
| KI-001 | Manual validation gap | Gate blocker | 現在、gamepadをWindows上で検出できず、LS／RS／Xを開始できない | 接続後にmanufacturer／model、有線／無線、Windows controller名を記録して再開 | `30 QA` + user | Blocked awaiting hardware |
| KI-002 | Evidence gap | Gate blocker | Phase 1工数が試作全体の15%以下である証跡がない | 実績または再見積りと全体見積りの単位を記録 | Supervisor | Open |
| KI-003 | Environment metadata | Gate blocker | power plan表示名は`バランス`。承認済み性能優先に対応するpower mode実表示とGPU driverが未記録 | 同じ基準端末でpower modeとdriverを取得し、Gate 1証拠へ追加 | `30 QA` | Open |
| KI-004 | Measurement limitation | Medium | GL Compatibilityでportableなper-frame GPU timingが取れず、`static_memory_bytes`は0。Phase 1 CPU monitor値も受入判定に未使用 | Gate 7までに取得可能な計測手段を決める。idle frame P95だけを過大解釈しない | QA | Open |
| KI-005 | Evidence metadata | Low | `phase1-arena-performance.json`の`capture_path`が旧`.../New project/...`絶対パスを参照 | 成果物とhashは有効。次回計測ではworkspace相対または現行パスを記録 | QA | Open |
| KI-006 | Evidence archive | Medium | 36 assertions、import/export、EXE/ZIP smokeのraw stdoutがdeliverablesへ保存されていない。報告書と成果物hashのみ | 次回Gate証拠ではcommand、stdout、exit code、commitを保存 | QA | Open |
| KI-007 | Coverage gap | Medium | RHL-001とRHL-003はPhase 1でN/A。8部位、規定外scheduler、粒子→ルール参照を拒否する負例fixtureは未実装 | 該当機能を実装するPhaseでnegative testsを追加 | Gameplay + QA | Deferred to relevant phase |
| KI-008 | Historical wording | Low | 凍結Markdown仕様に`Gate 0: Closed`と未承認P0表現が残る | 凍結文書は変更しない。AGENTS／MASTER_SPEC／DECISIONSの優先順位を維持 | Supervisor | Mitigated |

## Not a defect

- Phase 1の空／アリーナidle P95は合格記録だが、最大負荷、Gate 7、製品最低環境の保証ではない。
- RHL-001／003のN/Aは、該当機能をPhase 1へ先行実装しないスコープ判断である。
- 正式アクション、素材、損傷、魔法、ボス、ステージが未実装なのは現在の工程境界どおりである。
