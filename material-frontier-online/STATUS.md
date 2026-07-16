# Material Frontier Online — Project Status

- Updated: 2026-07-16
- Specification baseline: **Approved / Frozen**
- Gate 0: **Open**
- Gate 1: **Pass (2026-07-14)**
- Unresolved P0 decisions: **0**
- Current phase: **Phase 2 / functional checks and KBM Pass / correction performance Fail retained / controlled matrices valid run 0 / non-performance harness qualified / MFO-WO-P2-2A-010 performance acceptance active under hold**
- Phase 2 implementation: **MFO-WO-P2-2A-001 through -009 returned / -009 Pass accepted / MFO-WO-P2-2A-010 sole active QA execution order / MFO-HOLD-P2-2A-001 active**
- Gate 2: **Locked / not evaluated**
- Decision authority: [`decisions/2026-07-13-gate-0-p0-approval.md`](./decisions/2026-07-13-gate-0-p0-approval.md)
- Gate 1 approval: [`decisions/2026-07-14-gate-1-approval.md`](./decisions/2026-07-14-gate-1-approval.md)
- Phase 2 P1 approval: [`decisions/2026-07-14-phase2-p1-approval.md`](./decisions/2026-07-14-phase2-p1-approval.md)
- Active hold: [`MFO-HOLD-P2-2A-001`](../docs/work-orders/phase2-slice2a-performance-external-hold.md)
- Active work order: [`MFO-WO-P2-2A-010`](../docs/work-orders/phase2-slice2a-qualified-harness-performance-acceptance.md)
- Returned work orders: [`-001`](../docs/work-orders/phase2-slice2a-basic-operation.md) / [`-002`](../docs/work-orders/phase2-slice2a-nonzero-direction-correction.md) / [`-003`](../docs/work-orders/phase2-slice2a-performance-diagnostic.md) / [`-004`](../docs/work-orders/phase2-slice2a-controlled-rerun.md) / [`-005`](../docs/work-orders/phase2-slice2a-performance-only-rerun.md) / [`-006`](../docs/work-orders/phase2-slice2a-harness-qualification.md) / [`-007`](../docs/work-orders/phase2-slice2a-harness-correction-requalification.md) / [`-008`](../docs/work-orders/phase2-slice2a-harness-contract-correction-requalification.md) / [`-009`](../docs/work-orders/phase2-slice2a-harness-live-evidence-correction-requalification.md)
- Formal Slice 2-A QA: [`original`](../docs/test-reports/phase2-slice2a-validation.md) / [`correction`](../docs/test-reports/phase2-slice2a-correction-validation.md) / [`diagnostic Blocked`](../docs/test-reports/phase2-slice2a-performance-diagnostic.md) / [`controlled rerun`](../docs/test-reports/phase2-slice2a-controlled-rerun.md) / [`performance-only Blocked`](../docs/test-reports/phase2-slice2a-performance-only-rerun.md) / [`harness qualification Fail`](../docs/test-reports/phase2-slice2a-harness-qualification.md) / [`harness requalification Fail`](../docs/test-reports/phase2-slice2a-harness-requalification.md) / [`harness contract requalification Fail`](../docs/test-reports/phase2-slice2a-harness-contract-requalification.md) / [`harness LIVE-evidence requalification Pass`](../docs/test-reports/phase2-slice2a-harness-live-evidence-requalification.md)
- Frozen integrated specification: [`deliverables/Material-Frontier-Online-Integrated-Specification.docx`](./deliverables/Material-Frontier-Online-Integrated-Specification.docx)
- Frozen specification SHA-256: `66df0882ad4320b07850c745a0ac7cc5d8e091e0f4dd66a38e9d6237bb89babf`
- Phase 1 report: [`implementation/2026-07-14-phase1-technical-baseline.md`](./implementation/2026-07-14-phase1-technical-baseline.md)
- Gate 1 evidence: [`../docs/test-reports/phase1-gate1-power-revalidation.md`](../docs/test-reports/phase1-gate1-power-revalidation.md)
- Windows prototype: [`deliverables/phase1/MFO-Phase1-Windows-x86_64.zip`](./deliverables/phase1/MFO-Phase1-Windows-x86_64.zip)

## Status rule

完成済みの統合仕様書は、Gate 0承認前の仕様ベースラインとして凍結する。ベースライン内に残る `Gate 0: Closed` やP0未承認の記述は、上記決定記録によって2026-07-13付で置き換えられた履歴状態である。

現在の実装可否は、ルート`AGENTS.md`のSource of truth、`docs/MILESTONES.md`、およびactive work orderを正とする。
この状態ファイルはその要約である。P1/P2の未確定事項、後回し機能、性能・制作上限は引き続き統合仕様書に従う。

## Phase 1 result

Godot 4.7 stableの固定環境、抽象入力、1要素のActor集合、移動・独立照準、仮攻撃A、静的標的、判定予約、DomainEvent、RuntimeHardLimit起動検証、デバッグHUD、空シーン／アリーナ計測、Windows x86_64 exportを実装した。

- 自動テスト: **36 / 36 assertions passed**
- 空シーン P95: **16.6667 ms（AC Best performance、600 samples）**
- アリーナ静止ベースライン P95: **16.6667 ms（AC Best performance、600 samples）**
- Windows ZIP展開後headless smoke: **passed**
- 通常起動でKBMによる移動・照準・命中: **observed**
- ユーザーによるKBM総合操作感: **問題なし**
- 実ゲームパッド操作: **Not run / Gate Playabilityまで延期**
- GPU / driver: **Intel(R) Graphics / 32.0.101.7077 (2025-09-16)**
- Gate 1測定時AC power mode: **Best performance / OD-004適合**
- Gate 1 QA recommendation: **Pass / supervisor accepted**

## Current hold and next authorization boundary

`MFO-P2-2A-QA-001`の2条件限定修正は、Phase 1 `36 / 36`、既存Slice 2-A `120 / 120`、additive
`39 / 39`で機能Passとなった。一方、AC Best performanceのarena-idle P95は`33.4643 ms`と`20.0000 ms`で
`<= 16.67 ms`を超え、corrected-release KBM checklistも外部入力／window取得失敗により
`Blocked / Not completed`だった。Slice 2-Aは未受理である。

`MFO-WO-P2-2A-004`ではcorrected-C KBMがPassしたが、preflightはOneDrive系`32.15625 CPU-s`、system CPU
avg／max `38.250224%`／`46.012270%`でFailし、performance slotは全てNot runとなった。
`MFO-WO-P2-2A-005`もrequired pre-ack証拠未保存とcontroller-side OneDrive-family検出によりsettle前半で
Blockedとなり、slot `0`、valid matrix `0`、P95なしで返却された。後続snapshotの
`OneDrive.Sync.Service` PID `13496`はtrigger sampleとは断定しない。補助TickCount64 field `0`はQA harness
不備だが、実deadlineはnonzero Stopwatch originを使用しており、zero field単独を独立無効理由にはしない。
OneDrive容量増加、生成link除去、normal shutdown後のpreliminary `OneDrive*` count `0`をmaterial host change
として監督が受理し、明示票`MFO-WO-P2-2A-006`を発行した。PREACKでfresh OneDrive count `0`は保存されたが、
`PowerGetEffectiveOverlayScheme(out IntPtr)`／`LocalFree`のABI不一致によりlauncherが`0xC0000005`、runnerが
`30 / Fail`で終了した。performance slotは`0`で、ゲーム性能結果ではない。監督はFailを受理して旧stageを凍結し、
ABI限定修正、seal前production-path smoke、新stage再資格確認だけを許可する明示票`MFO-WO-P2-2A-007`を
発行した。ABI修正とsmokeはPassしたが、preparation receipt identity欠落、旧`-006 START_ACK`、complete
PREACK recordのpersist／readback／hash前判定により、PREACK未実施／slot `0`の`Fail / harness defect`となった。
監督は証拠manifest `86 / 86`を照合してFailを受理し、3件の限定修正、seal前contract test、新stage再資格確認だけを
許可する明示票`MFO-WO-P2-2A-008`を発行した。`-008`はPREACKとexact user activationを通過し、OneDrive `0`、
AC online、Best performanceを維持した61-sample LIVEを完走したが、全sampleのslot count field欠落、sentinel cleanup前の
`n=0`永続化、runner／launcher LIVE evaluationのfield-completeness結果欠落により`Fail / harness defect`となった。
監督はevidence `321 / 321`一致を確認してstageとruntime evidenceを凍結し、この3件だけをproduction-bound test後に
fresh stageで再資格確認する明示票`MFO-WO-P2-2A-009`を発行した。`-009`は5-mode preparation、PREACK、exact
activation、corrected `61 / 61`-sample LIVE、cleanupをslot `0`のままPassし、監督がharness qualifiedとして受理した。
userが現在のAC window確保を報告したため、監督はqualified-harness performance専用票`MFO-WO-P2-2A-010`を発行した。
`MFO-HOLD-P2-2A-001`は継続し、`-010`が唯一のexecution例外である。Gate 2とSlice 2-BはLockedのままである。
物理gamepad証跡はOD-013を維持したままGate Playabilityまで延期し、KBM結果でPassへ置き換えない。
正式な快斬・重断、損傷、HUD統合、素材、魔法、boss、stageは別work orderまで着手しない。

MMO通信、アカウント、課金、巨大マップ、全素材、本番アート・音響の量産は引き続き未承認である。
