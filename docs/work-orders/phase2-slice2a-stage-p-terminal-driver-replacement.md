# Work Order — Phase 2 Slice 2-A Stage P Terminal Driver Replacement

- Work order ID: `MFO-WO-P2-2A-012`
- Issued by: `00統括（監督）`
- Issued: 2026-08-01 (Asia/Tokyo)
- Priority: **P1 / Slice 2-A acceptance critical path**
- Owner: `30 QA・性能・レビュー`
- Gameplay owner: `10ゲームプレイ・コア実装` — no work in this order
- Presentation owner: `20ステージ・UI・グラフィック` — no work in this order
- Status: **Authorized / terminal external-driver replacement / Stage P PREPARED only**
- Milestone: M2 / Slice 2-A acceptance
- Required branch: `codex/phase2-slice2a-performance-acceptance-qa`
- Required starting point: the supervisor commit that adds this work order
- Required report: `docs/test-reports/phase2-slice2a-stage-p-terminal-driver-replacement.md`
- Required evidence root: `docs/test-reports/evidence/phase2-slice2a/diagnostic-005/stage-p-terminal-driver-012/`
- Basis: [`MFO-WO-P2-2A-010`](phase2-slice2a-qualified-harness-performance-acceptance.md),
  [`MFO-WO-P2-2A-011`](phase2-slice2a-stage-p-consolidated-recovery.md), and
  [`MFO-HOLD-P2-2A-001`](phase2-slice2a-performance-external-hold.md)

This is the single terminal replacement allowed by the recovery-control rule in `docs/MILESTONES.md`. It is not
another one-defect addendum chain. It replaces the non-Pass `-011` external qualification driver with one new,
minimal, qualified driver. It does not change product code, candidate-012, Stage P acceptance criteria, or the
performance hold.

## 1. Supervisor acceptance of MFO-WO-P2-2A-011

`MFO-WO-P2-2A-011` is closed as **Blocked / final QUALIFY non-Pass**. Its QA classification, frozen evidence, and
report remain unchanged.

Accepted facts:

- selected driver: `158448` bytes / SHA-256
  `1b90d2eb5029c8bbadabde9523184149b26751922fee6ea79599397400f02c2b`;
- offline `CP-ORDER-001` and `CP-ABC-001` closure: Pass;
- final QUALIFY invocation count `1`, numeric exit `31`, machine message
  `R5K_QUALIFICATION_BLOCKED: R5K_FAIL_CP_ORDER_UNCLASSIFIED_OPERATION`;
- failure payload SHA-256 `38d5e0a8c761b0fd55e1aef752e213e32aed16538174305d7d5e2ff1af31547b`;
- qualification manifest `21 / 21`, SHA-256
  `559ca9e1701f241a6a5d4427faed2dbef205908d8b23191d331a23da153e2c29`;
- FORMAL, compiler, PowerShell parse, tool build, StagePreparer, Stage lifecycle, PREACK, performance, real A/B/C,
  KBM, and game counts remained `0`.

The supervisor independently parsed the frozen driver and found one exact CONTRACT command and one containing
`PipelineAst`. The CONTRACT pipeline covers the complete invocation, including `| Out-Null`; its extent ends before
the compile-audit consumer assignment, and the exact gap is only one LF plus eight spaces. The failed check instead
started its gap at the end of a raw command prefix, so the remaining arguments and pipeline suffix of the same
statement were misclassified as an inserted operation.

Therefore the accepted attribution is **external QUALIFY statement-span boundary false positive**. This is not
candidate-012, StagePreparer, production harness, game, or performance defect evidence. `-011` is not relabeled Pass,
and its failed QUALIFY is not retried.

## 2. Immutable boundaries

Throughout this order, keep all of the following immutable:

- the complete `-011` driver, offline closure, qualification root, report, evidence, and hashes;
- candidate-012 and all eight files, including Native SHA-256
  `167634f7854ae9db5b061e65a8f6148c3ffe0aa399ee66d54bf2039db9fd86c1`;
- candidate-013 remains absent; candidate create／clone／write／attribute-change／promotion counts remain `0`;
- every prior tool root, partial Stage, runtime root, evidence payload, and result;
- internal `MFO-WO-P2-2A-010` production issuance identities;
- game code, gameplay tests, recorder, scenes, project/build settings, values, thresholds, renderer, resolution,
  quality settings, and the A/B/C executables;
- `MFO-HOLD-P2-2A-001`, Gate 2 Locked, Slice 2-B unauthorized, and physical gamepad Deferred.

No repository file may be edited during execution except the final QA report, new evidence index, and
`docs/handoffs/qa.md` after the result is frozen.

## 3. Terminal replacement and timebox

Create exactly one fresh external replacement driver from the frozen `-011` driver. The replacement must have one
new path and one final identity before QUALIFY. No second replacement, alternate, or abandoned candidate is allowed.

Permitted changes are limited to:

1. mechanical `-011` to `-012` external identity, required execution HEAD, fresh driver／qualification／formal／tool／
   preparation／Stage paths, report identity, and counters;
2. frozen `-011` lineage binding, including the exact driver, failure, qualification manifest, and `21 / 21` payloads;
3. replacement of the one defective raw-prefix statement-span check with the AST-bound check in Section 4;
4. the state-free fixture, static audit, receipt, failure closure, result, and manifest required to prove items 1–3.

The internal `MFO-WO-P2-2A-010` issuance identity, candidate-012, production lifecycle, and acceptance fields must not
change. Active authoring and static qualification preparation are limited to **90 minutes**. Fixed compiler/runtime
and hashing time are recorded separately.

If the single replacement cannot be qualified within this boundary, return and defer the QA infrastructure. Do not
request or create `MFO-WO-P2-2A-013` automatically.

## 4. Required AST statement-span qualification

Before QUALIFY, record a complete diff from the frozen `-011` driver and prove all changed lines belong to Section 3.
The replacement must be 7-bit ASCII, BOM-free, Windows PowerShell 5 parse error `0`, and ReadOnly before invocation.

QUALIFY must use PowerShell AST extents, not raw-prefix length, for the CONTRACT producer/consumer boundary:

1. find exact one `Invoke-FormalProcess` `CommandAst` whose bound arguments identify
   `stagepreparer-contract` and `CONTRACT`;
2. find its exact one containing `PipelineAst` and use `PipelineAst.Extent.EndOffset` as the producer-statement end;
3. find exact one compile-audit consumer assignment for `Read-Json $compileAuditPath` and use the assignment
   extent start as the consumer start;
4. require producer end `<` consumer start and require the exact source gap between those AST extents to be
   whitespace only;
5. require raw command-prefix plus `marker.Length`／`Substring` statement-boundary guards in the FORMAL-order
   qualification region to be `0`;
6. persist the AST type, start/end offsets, complete extent text hashes, exact gap byte length/hash, and whitespace
   result.

Add one state-free no-process fixture containing a complete invocation with arguments and `| Out-Null`, followed by
the consumer assignment. It must prove that the AST-bound rule Passes and that no suffix inside the same pipeline is
treated as a separate operation.

The qualification must also retain every `-011` census condition, `CP-ORDER-001`, and `CP-ABC-001`, including:

- lifecycle order `INIT → RepositoryState → CONTRACT → six modes → PreSealOwnership → SEAL`;
- compile-audit read before CONTRACT `0` and after CONTRACT exact `1`;
- A/B/C `Assert-Identity` CommandAst exact `3`, ArrayLiteral command-argument `0`, distinct identities, `MZ`, and
  launch count `0`;
- candidate-012 exact／ReadOnly, candidate-013 absent, all frozen lineage identities, root-first receipt, zero-byte
  streams, Unicode path handling, manifests, and residual-process count `0`.

Run replacement `QUALIFY` **exactly once**. QUALIFY may not launch a compiler, StagePreparer, generated output,
A/B/C, Godot, or the game. On any non-Pass, freeze and return. Repair, retry, alternate, second replacement, and
second QUALIFY are prohibited.

## 5. FORMAL Stage P — exact once

Only after complete replacement QUALIFY Pass may FORMAL run **exactly once**, using one fresh tool-build root, one
fresh preparation root, one fresh Stage P path, and the configured absent external run root.

The only allowed production lifecycle is unchanged from `MFO-WO-P2-2A-011`:

```text
fresh Native helper compile (1)
fresh StagePreparer compile (1)
StagePreparer INIT (1)
RecordRepositoryState RepositoryState (1)
StagePreparer CONTRACT (1)
QP_DRYRUN (1)
QP_SELFTEST (1)
QP_POWER_INPUT_SMOKE (1)
QP_PREACK_CONTRACT_SELFTEST (1)
QP_LIVE_EVIDENCE_CONTRACT_SELFTEST (1)
PA_PERFORMANCE_CONTRACT_SELFTEST (1; synthetic fixtures only)
RecordRepositoryState PreSealOwnership (1)
StagePreparer SEAL (1)
```

All `-011` FORMAL acceptance conditions remain mandatory, including five fresh component compile receipts, all six
mode Pass results, numeric-zero `performance_slot_attempt_count`, `performance_slot_launch_count`,
`abc_launch_count`, and `final_owned_runtime_count`, source-diff authorization, ownership, manifest／receipt／audit
hashes, absent external run root, residual process `0`, and every Stage file／directory ReadOnly.

Stop at the first FORMAL nonconformance and freeze complete evidence. No repair, retry, alternate, second tool build,
second Stage, reseal, cleanup, evidence rewrite, candidate change, or repository edit is authorized after FORMAL
begins.

## 6. Completion, failure, and prohibition

The only successful result is:

```text
MFO-WO-P2-2A-012 PASS / MFO-WO-P2-2A-010 PREPARED stage_id=<id> manifest_sha256=<sha256> receipt_sha256=<sha256> preparation_audit_sha256=<sha256>
```

Stop immediately after PREPARED. PREACK, activation, START_ACK, LIVE, user quiet window, OneDrive shutdown,
AC／power-mode request, performance attempt／slot, real A/B/C launch, P95, KBM, game, Gate 2 decision, Slice 2-B,
presentation integration, and product-code change are prohibited.

On any non-Pass, return the frozen partial state and classify QA infrastructure as deferred. Do not create a new
micro-recovery work order automatically. Performance remains unresolved, Gate 2 remains Locked, and Slice 2-B
remains unauthorized.

After freeze, `30` may update only the required report, new evidence under the required evidence root, and
`docs/handoffs/qa.md`, then commit and push the required QA branch. Do not push `main`.

## 7. Required report contents

The report must record:

- replacement driver path, size, SHA-256, parser／ASCII／BOM／ReadOnly state, and full authorized diff;
- frozen `-011` driver, failure, manifest, and `21 / 21` lineage verification;
- exact AST command／pipeline／consumer counts, extents, gap bytes/hash, state-free fixture, and absence of other
  same-class raw-prefix boundary guards;
- QUALIFY and FORMAL commands, invocation counts, numeric exits, stdout/stderr, counters, root identities, and
  manifests;
- candidate-012 before／after `8 / 8` equality and candidate-013 absence;
- all compile, lifecycle, PREACK, performance, A/B/C, KBM, and game counters;
- final recommendation and an explicit statement that PREPARED does not accept performance or unlock Gate 2／
  Slice 2-B.
