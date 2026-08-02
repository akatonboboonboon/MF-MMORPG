# MFO-WO-P2-2B-011 — Stage B terminal formal revalidation

- QA starting HEAD: `48f0b051de397d9f9a1c3884e66bc6241d0151dd`
- Candidate: `30b090481a9fffd123d5b16537886e5011fd7e51`
- Reviewed handoff: `bbed2fd98bf0435e456f9ad2bd7dba2b7a7cb0c6`
- Recommendation: **Blocked / validation infrastructure or evidence incomplete**

## Pre-formal work

The authorized single runner condition-strengthening batch preserved `_check` call sites `153` and helper declarations `1`. The resulting runner SHA-256 is `e677cf7f64e6a02cbafee5c086a8b5732d8440fb1756cc0329631437783910d2`; its immutable UID remains SHA-256 `7615a8f1d1edf4d59e5a4eb25996acd008a05a53921e4f293ea5765da4d67096`.

The approved Godot console identity matched: size `198152`, SHA-256 `D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`.

## First non-pass

The first parser-only capture attempt did not retain a same-invocation numeric exit, raw stdout, raw stderr, or `invocation.json`. The designated evidence directory exists but contains no such raw payload. The owned Godot console/editor processes were identified by exact executable paths and console-to-editor parent relationship, then terminated under supervisor instruction; post-termination residual count is `0`.

Consequently parser success cannot be inferred. FORMAL, candidate execution, regressions, smoke, export, and any retry were not run. This is a validation-capture failure, not a candidate implementation or approved-data finding.

## Scope

Changed paths are limited to the authorized runner, this report, `stageb-kernel-004` closure evidence, and `docs/handoffs/qa.md`. Candidate/game code, data, scenes, project configuration, UID, and prior evidence remain unchanged.

## Append-only correction — process audit

The closure at QA commit d25526dcd11c10177a8e329646ed22a62956cd40 is **superseded by this append-only process audit**. Its statement that the attempted parser-only capture was the relevant execution is corrected: the actual child command lines had no arguments, and two argumentless Godot main-scene launches occurred. The intended parser invocation count is 0; FORMAL and Stage B candidate execution remain 0.

The external capture helper's missing child arguments is the first attribution: **Blocked / validation infrastructure or evidence incomplete**. This is not a candidate implementation or Approved-data Fail. Both process chains and supervisor/QA terminations are recorded in post-closure-process-audit.json (SHA-256 61ec8647625f37d1641b90bcfd2417134297001780a1f320c2530a7d3e5d52e7). The self-contained correction manifest is SHA-256 a37406255138448a1e56df3fa5bfe2368d52e95d17f13ad96139ce50b570497d. Final residual process count is 0. No old evidence, runner UID, candidate, or prior closure bytes were modified.