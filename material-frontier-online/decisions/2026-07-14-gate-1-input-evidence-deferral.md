# Gate 1 Input Evidence Deferral

- Decision ID: `GATE-1-INPUT-EVIDENCE`
- Status: **Approved**
- Authority: `user_explicit`
- Effective date: 2026-07-14 (Asia/Tokyo)
- Scope: Gate 1 input evidence only
- Impact: Gate 1、GQ-004、Gate Playability、QA work-order順序
- Sources: user direction on 2026-07-14、[`OD-013`](2026-07-13-gate-0-p0-approval.md)、
  [`Gate 1 / Gate Playability`](../specification/10-implementation-roadmap.md)

## Trigger

ユーザーは現在gamepadを所持しておらず、当面はkeyboard／mouse対応で進めること、現在のKBM操作感に
「問題なし」と明示した。

## Decision

1. Gate 1における物理gamepadのLS／RS／X確認を延期する。
2. Phase 1で記録済みのKBM移動・照準・仮攻撃・命中の実動作確認と、今回のユーザーによる総合評価
   「問題なし」を、Gate 1の現時点の手動入力証跡として採用する。
3. これはgamepad操作感のPassを意味しない。物理gamepad確認は`Not run / Deferred`として残す。
4. 物理gamepadを入手した後、遅くともGate Playability承認前にLS移動、RS照準、主要アクション入力、
   drift／多重入力と人間の操作感を検証する。
5. 将来の実機確認で欠陥が出た場合、該当するPhase 1／Phase 2の入力境界へ戻して修正・再検証する。

## Non-change

- `OD-013`は変更しない。gamepad主入力、KBMとの共通抽象入力、既存gamepad割当を削除・劣化させない。
- 既存work order `MFO-WO-P1-G1-001`のgamepad checklistをKBM結果でPassへ書き換えない。
- この決定だけではGate 1をPassにしない。OD-004準拠の性能再計測その他のGate条件を別に満たす。

## Basis

- 凍結roadmapのGate 1条件は、仮プレイヤーの移動と仮攻撃Aの命中を要求するが、入力deviceを限定しない。
- OD-013はgamepadを主入力とする製品仕様であり、Gate 1での物理実機確認時期までは指定していない。
- Gate Playabilityは人間による実操作を必須とするため、物理gamepad証跡の最終期限として扱う。
