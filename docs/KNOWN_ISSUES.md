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
| KI-009 | Gameplay defect / `MFO-P2-2A-QA-001` | Runtime Low | input deadzone後もnonzeroの小さいmoveをauthority／actorの追加epsilonがneutral扱いし、回避がmove方向ではなくaimへfallbackした | `5261a737`で2条件をexact-zero判定へ是正。既存`120 / 120`とadditive `39 / 39`を含むfresh QAで機能Pass | `10 Gameplay` + `30 QA` | Functionally resolved on correction branch / integration pending |
| KI-010 | Performance acceptance failure / `MFO-P2-2A-QA-002` | P1 acceptance blocker / runtime severity undetermined | correction QAのAC Online／Best performance valid 2 runでP95が`33.4643 ms`／`20.0000 ms`となり`<= 16.67 ms`を超過。`-003`はenvironment contaminationでvalid run `0`となり、因果を分離できなかった | `MFO-WO-P2-2A-004`でOneDrive外stagingとquiet hostを使いA／B／Cを再比較。相関確定までgame code・値を変更しない | `30 QA` + Supervisor + user | Open / controlled rerun awaiting user |
| KI-011 | Manual validation evidence gap | P1 Slice acceptance evidence blocker / defect unconfirmed | corrected-release KBM checklistが2回とも外部入力／session contaminationで未完了。`-003`ではlaunchから意図したWまで約53分空き、fresh continuous sessionではなかった | `MFO-WO-P2-2A-004`でuserを明示operator、QAをpassive observerとし、launch直後の1 continuous sessionでWASD／mouse／Space／priority／fallback／bounds／reject／no-bufferを実施 | `30 QA` + user | Open / user-operated retry awaiting user |
| KI-012 | QA environment contamination | P1 Slice acceptance evidence blocker | `-003`のA1／B1／C1でWindows-session inputが継続変化しgameはほぼ非foreground。system CPU avg `72.838%–87.620%`、OneDrive系負荷も高く、C2 controller証拠不完備、valid acceptance run `0`。userはOneDrive無料planの5 GB上限が原因と推測するred-X／非同期状態を報告したが、原因は未確定 | userがOneDrive clientを手動pause／exitし端末無操作windowを確保。容量整理／削除や同期成功は要求しない。`-004`は15秒preflight、非OneDrive staging、compact evidence、continuous integrity監視を満たすまでmatrixを開始しない | `30 QA` + user | Awaiting explicit quiet-window confirmation |

## Not a defect

- Phase 1の旧空／アリーナidle P95はpower mode未記録のためGate 1証拠へ流用せず、AC Best performanceで
  再計測した。新P95はGate 1だけのidle baselineであり、最大負荷、Gate 7、製品最低環境の保証ではない。
- RHL-001／003のN/Aは、該当機能をPhase 1へ先行実装しないスコープ判断である。
- 正式アクション、素材、損傷、魔法、ボス、ステージが未実装なのは現在の工程境界どおりである。
