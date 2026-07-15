# Material Frontier Online — Known Issues and Evidence Gaps

- Updated: 2026-07-16
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
| KI-010 | Performance acceptance failure / `MFO-P2-2A-QA-002` | P1 acceptance blocker / runtime severity undetermined | correction QAのvalid 2 runはP95 `33.4643 ms`／`20.0000 ms`で`<= 16.67 ms`を超過。`-003`、`-004`、`-005`はいずれもvalid matrix `0`で、現在candidateの性能受入と因果は未解決 | `MFO-HOLD-P2-2A-001`をperformance acceptanceに対して維持。`-006`／`-007`はperformance slot `0`のharness Failで終了し、`-008`もharness契約修正／再資格確認だけを行う | `30 QA` + Supervisor + user | Open / requalification active under performance hold |
| KI-011 | Manual validation evidence gap | Resolved for Slice 2-A KBM | `-003`まではcorrected-release KBM checklistがsession contaminationで未完了だった | `-004` attempt 3の独立`27.973 s` capture、foreground維持、技術証拠、意図入力、全6項目問題なしを監督受理。observer再現性制限は記録し、再実施しない | `30 QA` + user + Supervisor | Resolved / KBM Pass |
| KI-012 | QA environment contamination | P1 Slice acceptance evidence blocker | `-005`controllerはsettled interval最初にOneDrive-family presenceで停止。trigger inventoryは未保存でexact process不明。後続snapshotの`OneDrive.Sync.Service` PID `13496`は補強証拠のみ。2026-07-15に容量増加、生成link除去、normal shutdown後のpreliminary `OneDrive*` count `0`が報告された | `-006` PREACKでfresh OneDrive-family count `0`を保存できたが、API crash前の単発記録でLIVEは未成立。`-007`前の監督確認ではOneDrive `0`／configured AC mode `ded574b5…`に対しdirect effective overlayは`961cc777…`のままで、READY未送信。`-008` READY前にfresh effective-overlay確認を要求し、performance holdを維持 | `30 QA` + user + Supervisor | Open / pre-ack count zero confirmed; effective overlay and live interval pending |
| KI-013 | QA acceptance harness／procedure integrity | P1 evidence blocker / game defectではない | `-005`でpre-ack hash／OneDrive／power／runtime証拠を保存せず開始を通知。trigger inventoryはthrow前に未保存。unsupported `[Environment]::TickCount64`により補助fieldが`0`、child exit／raw streamsも未取得。実deadlineのnonzero `Stopwatch` originは別に存在するため、zero field単独を独立無効理由にはしない | `-006`でnative monotonic、persist-before-assert OneDrive inventory、child exit／raw streams、slot `0`は部分確認した。`-007`はcomplete PREACK recordより先に期待値をassertする欠陥を残した。`-008`で完全recordのpersist／readback／hash後だけ判定する二相契約をseal前に検証 | `30 QA` + Supervisor | Open / partial mechanics verified; full qualification pending |
| KI-014 | QA harness defect / `MFO-P2-2A-QA-003` | P1 evidence blocker / game defectではない | `-006` sealed sourceが`PowerGetEffectiveOverlayScheme`を`out IntPtr`＋`PtrToStructure`＋`LocalFree`で扱い、PREACK launcherが`0xC0000005`で異常終了。runnerは`30 / Fail`、performance slotは`0` | `-006` stageを凍結。`-007`でdirect `out Guid`へ限定修正し、同一production `PowerAndInput` smoke、Guid／UInt32 round-trip、static ABI auditがPass。full qualificationは別のKI-015で未成立 | `30 QA` + Supervisor | Resolved for ABI / full qualification tracked by KI-015 |
| KI-015 | QA harness contract defect / `MFO-P2-2A-QA-004` | P1 evidence blocker / game defectではない | `-007` sealed PREACKはpreparation receipt identityを検証・記録せず、activation validatorは旧`MFO-WO-P2-2A-006 START_ACK`を要求し、complete prerequisite recordのpersist／readback／hash前に期待値を判定する。PREACK／LIVE未実施、slot `0` | `-007` stage／evidenceを凍結。`MFO-WO-P2-2A-008`でreceipt外部hash binding、exact `-008 START_ACK`、persist-before-assert二相処理だけを修正し、正負のseal前contract self-test後に新stageを再資格確認 | `30 QA` + Supervisor | Open / explicit correction work order active |

## Not a defect

- Phase 1の旧空／アリーナidle P95はpower mode未記録のためGate 1証拠へ流用せず、AC Best performanceで
  再計測した。新P95はGate 1だけのidle baselineであり、最大負荷、Gate 7、製品最低環境の保証ではない。
- RHL-001／003のN/Aは、該当機能をPhase 1へ先行実装しないスコープ判断である。
- 正式アクション、素材、損傷、魔法、ボス、ステージが未実装なのは現在の工程境界どおりである。
