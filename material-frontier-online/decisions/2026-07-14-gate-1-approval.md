# Gate 1 Approval

- Decision ID: `GATE-1`
- Status: **Approved / Pass**
- Authority: `supervisor_determination`
- Effective date: 2026-07-14 (Asia/Tokyo)
- Scope: M1 closure and Phase 2 entry preparation
- Impact: Gate 1、Phase 1 completion、M2 planning boundary

## Decision

1. `MFO-WO-P1-G1-002`のQA Pass勧告と証拠を受理し、Gate 1を**Pass**とする。
2. Phase 1を**Complete**とする。
3. Phase 2はentry preparation、必要P1決定、work-order作成だけを許可する。ゲームコード実装は
   Approved P1決定と`00統括`発行の明示work orderが揃うまで`Not started / locked`とする。
4. Gate 2はlockedのままとする。
5. `GATE-1-INPUT-EVIDENCE`を維持する。物理gamepadは`Not run / Deferred`であり、Passではない。
   入手後かつ遅くともGate Playability承認前に検証する。

## Accepted Gate 1 evidence

| Requirement | Supervisor result | Evidence |
|---|---|---|
| ZIP／EXE／LFS実体 | Pass | ZIP `88d21f...e983`、EXE `13fb5d...199`を独立再照合 |
| 基準端末・標準画質・release相当 | Pass | environment record、packaged EXE、1920×1080／60.0007Hz |
| AC performance mode | Pass | AC online、Best performance、GUID `ded574b5-45a0-4f42-8737-46345c09c238` |
| Empty FHD performance | Pass | 120 warmup＋600 samples、P95 `16.6667 ms`、exit `0` |
| Arena idle performance | Pass | 120 warmup＋600 samples、P95 `16.6667 ms`、exit `0` |
| HUD／JSON consistency | Pass | HUD `16.67 ms`、JSON `16.666666... ms` |
| RuntimeHardLimit startup | Pass for active scope | RHL-001／003 N/A、RHL-002 Pass、violation `0` |
| Input vertical path | Pass on KBM | release buildの移動・照準・仮攻撃・命中、user overall `問題なし` |
| Phase 1 effort cap | Pass by approved re-estimate | `26 / 188 = 13.8298%`。actual timeではない |
| network／account／payment exclusions | Pass | Phase 1 runtimeとscope監査 |
| QA recommendation | Pass | 2026-07-14 power revalidation report |

## Evidence integrity review

- `SHA256SUMS.txt`の10 entriesを実ファイルから再計算し、10 / 10一致した。
- arena screenshotで`FRAME P95 (600) 16.67 ms`を目視確認した。
- empty screenshotは表示要素を持たない真の空sceneだった。
- QA差分はhandoff、test report、evidenceだけで、game code、scene、test code、build設定、work orderを
  変更していない。
- memory値とportable GPU per-frame timingは取得不能であり、Gate 1合格証拠へ含めていない。
- idle baselineはGate 7、`PrototypeStressTarget`、製品最低環境のPassを意味しない。

## Non-blocking provenance note

`commands.md`は出力先を`<evidence>`へ正規化し、power APIのliteral invocationを保存していない。ただし、
JSON／stdout内の実path、set／read-back RC、測定後environment、manifest、timestampで今回の内部Gate 1証拠は
再追跡可能と判断した。以後のGate証拠ではliteral commandまたはscript hash、raw output、timezoneを残す。

## Sources

- [QA power revalidation report](../../docs/test-reports/phase1-gate1-power-revalidation.md)
- [Evidence manifest](../../docs/test-reports/evidence/phase1-gate1/power-revalidation-20260714-best-performance/SHA256SUMS.txt)
- [Input evidence deferral](2026-07-14-gate-1-input-evidence-deferral.md)
- [Effort re-estimate](../../docs/phase1-effort-reestimate.md)
- [Gate 1 roadmap](../specification/10-implementation-roadmap.md)
