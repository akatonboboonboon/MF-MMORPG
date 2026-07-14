# Material Frontier Online — Project Status

- Updated: 2026-07-14
- Specification baseline: **Approved / Frozen**
- Gate 0: **Open**
- Gate 1: **Power-mode revalidation and final evidence pending**
- Unresolved P0 decisions: **0**
- Current phase: **Phase 1 — technical baseline implemented / Gate evidence completion**
- Decision authority: [`decisions/2026-07-13-gate-0-p0-approval.md`](./decisions/2026-07-13-gate-0-p0-approval.md)
- Frozen integrated specification: [`deliverables/Material-Frontier-Online-Integrated-Specification.docx`](./deliverables/Material-Frontier-Online-Integrated-Specification.docx)
- Frozen specification SHA-256: `66df0882ad4320b07850c745a0ac7cc5d8e091e0f4dd66a38e9d6237bb89babf`
- Phase 1 report: [`implementation/2026-07-14-phase1-technical-baseline.md`](./implementation/2026-07-14-phase1-technical-baseline.md)
- Windows prototype: [`deliverables/phase1/MFO-Phase1-Windows-x86_64.zip`](./deliverables/phase1/MFO-Phase1-Windows-x86_64.zip)

## Status rule

完成済みの統合仕様書は、Gate 0承認前の仕様ベースラインとして凍結する。ベースライン内に残る `Gate 0: Closed` やP0未承認の記述は、上記決定記録によって2026-07-13付で置き換えられた履歴状態である。

現在の実装可否は、この状態ファイルとGate 0決定記録を正とする。P1/P2の未確定事項、後回し機能、性能・制作上限は引き続き統合仕様書に従う。

## Phase 1 result

Godot 4.7 stableの固定環境、抽象入力、1要素のActor集合、移動・独立照準、仮攻撃A、静的標的、判定予約、DomainEvent、RuntimeHardLimit起動検証、デバッグHUD、空シーン／アリーナ計測、Windows x86_64 exportを実装した。

- 自動テスト: **36 / 36 assertions passed**
- 空シーン P95: **16.667 ms（履歴値。power mode未記録）**
- アリーナ静止ベースライン P95: **16.667 ms（履歴値。power mode未記録）**
- Windows ZIP展開後headless smoke: **passed**
- 通常起動でKBMによる移動・照準・命中: **observed**
- ユーザーによるKBM総合操作感: **問題なし**
- 実ゲームパッド操作: **Not run / Gate Playabilityまで延期**
- GPU / driver: **Intel(R) Graphics / 32.0.101.7077 (2025-09-16)**
- 記録時power mode: **Best Power Efficiency / OD-004不適合**

## Next authorized work

`MFO-WO-P1-G1-002`に従い、基準端末をAC電源・Best performanceへ設定してempty sceneとarena idleを
再計測する。物理gamepad証跡はOD-013を維持したままGate Playabilityまで延期し、KBM結果でPassへ
置き換えない。正式な快斬・重断、素材、CombatForm、損傷、魔法、ボス、ステージへはGate 1判定後に進む。

MMO通信、アカウント、課金、巨大マップ、全素材、本番アート・音響の量産は引き続き未承認である。
