# Material Frontier Online — Project Status

- Updated: 2026-07-14
- Specification baseline: **Approved / Frozen**
- Gate 0: **Open**
- Gate 1: **Pass (2026-07-14)**
- Unresolved P0 decisions: **0**
- Current phase: **Phase 2 / Slice 2-A correction QA Fail / functional checks Pass / performance diagnostic / KBM Blocked**
- Phase 2 implementation: **MFO-WO-P2-2A-003 active / QA-only isolation and KBM completion**
- Gate 2: **Locked / not evaluated**
- Decision authority: [`decisions/2026-07-13-gate-0-p0-approval.md`](./decisions/2026-07-13-gate-0-p0-approval.md)
- Gate 1 approval: [`decisions/2026-07-14-gate-1-approval.md`](./decisions/2026-07-14-gate-1-approval.md)
- Phase 2 P1 approval: [`decisions/2026-07-14-phase2-p1-approval.md`](./decisions/2026-07-14-phase2-p1-approval.md)
- Active work order: [`../docs/work-orders/phase2-slice2a-performance-diagnostic.md`](../docs/work-orders/phase2-slice2a-performance-diagnostic.md)
- Returned work orders: [`MFO-WO-P2-2A-001`](../docs/work-orders/phase2-slice2a-basic-operation.md) / [`MFO-WO-P2-2A-002`](../docs/work-orders/phase2-slice2a-nonzero-direction-correction.md)
- Formal Slice 2-A QA: [`original`](../docs/test-reports/phase2-slice2a-validation.md) / [`correction`](../docs/test-reports/phase2-slice2a-correction-validation.md)
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

## Next authorized work

`MFO-P2-2A-QA-001`の2条件限定修正は、Phase 1 `36 / 36`、既存Slice 2-A `120 / 120`、additive
`39 / 39`で機能Passとなった。一方、AC Best performanceのarena-idle P95は`33.4643 ms`と`20.0000 ms`で
`<= 16.67 ms`を超え、corrected-release KBM checklistも外部入力／window取得失敗により
`Blocked / Not completed`だった。Slice 2-Aは未受理である。

現在は`MFO-WO-P2-2A-003`に従い、`30`だけがGate 1／pre-correction／corrected buildの同一session比較と
corrected-release KBM完遂を行う。性能とcodeの相関が確定するまで`10`のgame code変更は許可しない。
物理gamepad証跡はOD-013を維持したままGate Playabilityまで延期し、KBM結果でPassへ置き換えない。
正式な快斬・重断、損傷、HUD統合、素材、魔法、boss、stageは別work orderまで着手しない。

MMO通信、アカウント、課金、巨大マップ、全素材、本番アート・音響の量産は引き続き未承認である。
