# Work Order — Phase 2 Slice 2-A Stage P Consolidated Recovery

- Work order ID: `MFO-WO-P2-2A-011`
- Issued by: `00統括（監督）`
- Issued: 2026-07-18 (Asia/Tokyo)
- Priority: **P1 / Slice 2-A acceptance critical path**
- Owner: `30 QA・性能・レビュー`
- Gameplay owner: `10ゲームプレイ・コア実装` — no work in this order
- Presentation owner: `20ステージ・UI・グラフィック` — no work in this order
- Status: **Authorized / consolidated Stage P recovery only / performance not started**
- Milestone: M2 / Slice 2-A acceptance
- Authorized scope: external read-only census／driver correction／QUALIFY and one candidate-012 Stage P FORMAL through PREPARED only
- Forbidden scope: product-code changes, PREACK, performance, real A／B／C, game, Gate 2 approval, and Slice 2-B authorization
- Gate 2: **Locked / not evaluated**
- Required QA branch: `codex/phase2-slice2a-performance-acceptance-qa`
- Required report: `docs/test-reports/phase2-slice2a-stage-p-consolidated-recovery.md`
- Required evidence root: `docs/test-reports/evidence/phase2-slice2a/diagnostic-004/stage-p-recovery-011/`
- Basis: [`MFO-WO-P2-2A-010`](phase2-slice2a-qualified-harness-performance-acceptance.md),
  [`MFO-HOLD-P2-2A-001`](phase2-slice2a-performance-external-hold.md), and the frozen R5K-C return

This order replaces the one-defect／one-addendum R5K recovery chain with one bounded consolidated packet. It
supersedes only the R5K-C Stage P recovery authority. It does not supersede the performance hold, accept
performance, authorize PREACK, or authorize Slice 2-B.

## 1. Supervisor attribution of R5K-C

R5K-C returned **Blocked / execution or evidence interruption during FORMAL after INIT**. The supervisor accepts
the observed partial state and attributes the first nonconformance to the external orchestration driver:

- StagePreparer `INIT` completed with numeric exit `0` and correctly produced only the initial materialization;
- candidate-012 StagePreparer creates `compile-and-source-audit.json` in `CONTRACT`, after RepositoryState and the
  five fresh component compiles, not in `INIT`;
- the R5K-C d4 driver attempted to read that CONTRACT-owned artifact immediately after `INIT`, before both
  RepositoryState and `CONTRACT`;
- the partial Stage contained the expected INIT-only nine files, candidate-012 remained exact and ReadOnly, and
  PREACK, performance, A／B／C, and game remained `0`.

Therefore R5K-C is **Blocked / external FORMAL artifact producer-consumer order mismatch after INIT**. It is not
candidate-012, production harness, game, or performance defect evidence. The earlier sentence “INIT must record
`fresh_component_compile_count=5`” is procedurally corrected here: `CONTRACT` performs and records those five
fresh compiles, and the external driver may read and validate them only after successful `CONTRACT`.

## 2. Immutable boundaries

The following are immutable throughout this order:

- candidate-012, all eight files, directory attributes, identities, and the accepted R5J-A correction;
- candidate-013 remains absent; candidate create／clone／write／attribute-change／promotion counts remain `0`;
- production game code, gameplay tests, recorder, scene, project settings, build settings, values, thresholds,
  renderer, resolution, quality settings, and A／B／C executables;
- every frozen R5K-C and prior driver, root, evidence payload, partial Stage, and result;
- the internal issuance identities already accepted by `MFO-WO-P2-2A-010`;
- `MFO-HOLD-P2-2A-001`, Gate 2 Locked, Slice 2-B unauthorized, and physical gamepad Deferred.

Only external, repository-untracked preparation-driver candidates and their fresh qualification evidence may be
created before the final attempt. No game repository file may be edited by `30` under this order.

## 3. Timebox and consolidation policy

This is one recovery packet, not permission for another addendum chain.

1. Supervisor/read-only defect census: maximum **2 active hours**.
2. Offline driver correction, parser/static checks, state-free fixtures, and qualification preparation: maximum
   **4 active hours**.
3. Fixed compiler/process runtime and evidence hashing are recorded separately from active authoring time.
4. At most **3 offline driver candidates** may be created. Each candidate must have a unique path, size, SHA-256,
   parser result, creation ordinal, complete diff from its predecessor, and immutable freeze on abandonment.
5. No offline candidate may launch StagePreparer, a generated harness executable, A／B／C, Godot, or the game.
6. If the complete census cannot be closed within the timebox or the third candidate remains nonconforming, return
   `Blocked / consolidated QA infrastructure recovery exhausted`. Do not issue another micro-recovery automatically.
7. Acceptance criteria, thresholds, and evidence completeness must not be relaxed to meet the timebox.

## 4. Mandatory read-only defect census

Before selecting the final driver, inspect the complete FORMAL path, not only the previous first failure. Persist one
census with every checked site, evidence, classification, and disposition. At minimum it must cover:

- every Stage-path `Read-Json`, file identity, hash, and field read, with the exact earlier producer and lifecycle
  phase;
- exact lifecycle order `INIT → RepositoryState → CONTRACT → six modes → PreSealOwnership → SEAL`;
- candidate-012 and compiler identities, PowerShell 5 compatibility, 7-bit ASCII／BOM boundary, Unicode repository
  path construction, zero-byte stream serialization, and root-first evidence;
- JSON schema and field agreement for materialization, repository state, compile receipts, source-diff audit,
  component contract, six runner results, seal outputs, manifest, receipt, preparation audit, and post-seal audit;
- invocation ASTs, argument binding, process counts, timeouts, exit capture, stdout/stderr persistence, failure
  finalization, self-excluded manifests, ReadOnly closure, and residual-process checks;
- absence of candidate mutation, external run root, PREACK, performance attempt／launch, A／B／C launch, and game
  launch.

The census must distinguish candidate／production defects from external-driver／evidence defects. Raw token counts
alone are insufficient when PowerShell AST binding determines behavior.

## 5. Required consolidated corrections

### CP-ORDER-001 — CONTRACT artifact producer/consumer order

Correct the external FORMAL driver so the only allowed order is:

```text
StagePreparer INIT
assert materialization exists and compile-and-source-audit is not consumed
RecordRepositoryState RepositoryState
StagePreparer CONTRACT
read and validate compile-and-source-audit and all five fresh compile receipts
continue to A/B/C identity validation and the six modes
```

Move the existing compile-audit read and validation block without weakening any field check. It must validate
`fresh_compile_receipt_count=5`, five distinct roles, exit `0`, fresh outputs, and old-stage reuse `0`. Name its
external evidence as CONTRACT-owned; do not label it as an INIT compile audit.

QUALIFY must prove, using bounded AST/source inspection and a state-free no-process fixture:

- compile-audit read before CONTRACT: `0`;
- compile-audit read after CONTRACT: exact `1`;
- INIT-only materialization and CONTRACT-owned compile/source audit producer mapping;
- expected lifecycle launch order exact once, with no unclassified operation inserted between producer and consumer.

### CP-ABC-001 — Three independent A/B/C identity calls

The frozen d4 line containing three comma-separated `Assert-Identity` tokens parses as one `Assert-Identity`
CommandAst with ArrayLiteralAst argument binding. Replace it with three independent invocations or one bounded loop
over three exact immutable specifications.

QUALIFY must require:

- `Assert-Identity` CommandAst count for the A/B/C block: exact `3`;
- ArrayLiteralAst command-argument binding in that block: `0`;
- A／B／C path, byte size, SHA-256, `MZ`, and launch count `0` each exact;
- a state-free fixture that returns three distinct identity records without launching a process.

## 6. Final driver qualification

After the complete census and all authorized corrections are closed, select exactly one final driver from the maximum
three offline candidates. Freeze every other candidate.

The final driver must be 7-bit ASCII, BOM-free, Windows PowerShell 5 parse error `0`, and have a complete diff whose
authorized semantic changes are limited to:

- mechanical work-order／execution-HEAD／fresh-path rollover;
- `CP-ORDER-001`;
- `CP-ABC-001`;
- census, fixture, counters, and evidence finalization required by this order.

Run final `QUALIFY` **exactly once**. QUALIFY must launch no compiler, StagePreparer, generated output, mode,
performance slot, A／B／C, Godot, or game. Require all census items, both named corrections, fixtures, identities,
root-first receipt, manifests, ReadOnly state, and zero downstream counters to Pass. On QUALIFY failure, freeze and
return; no repair, retry, alternate, or second QUALIFY is authorized.

## 7. Final FORMAL Stage P attempt

Only after complete QUALIFY Pass may final `FORMAL` run **exactly once** using one unique fresh tool-build root, one
fresh preparation root, one fresh Stage P path, and the configured absent external run root.

FORMAL must execute the existing production lifecycle only:

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

Require five fresh Stage component compile receipts, six-mode Pass details with numeric-zero
`performance_slot_attempt_count`, `performance_slot_launch_count`, `abc_launch_count`, and
`final_owned_runtime_count`, complete source-diff authorization, ownership, manifest／receipt／audit hashes,
external run root absent, residual process `0`, and every Stage file／directory ReadOnly.

Stop at the first FORMAL nonconformance. Persist exact command, numeric exit, stdout, stderr, partial counts, root
inventory, and a complete manifest before freeze. No repair, retry, alternate driver, second tool build, second Stage,
reseal, cleanup, evidence rewrite, candidate change, or repository edit is authorized after FORMAL begins.

## 8. Completion and prohibition

The only successful result is:

**Pass / candidate-012 Stage P PREPARED only**

The successful return line must be:

```text
MFO-WO-P2-2A-011 PASS / MFO-WO-P2-2A-010 PREPARED stage_id=<id> manifest_sha256=<sha256> receipt_sha256=<sha256> preparation_audit_sha256=<sha256>
```

Stop immediately after PREPARED. This order explicitly prohibits:

- PREACK, activation token, START_ACK, LIVE controller, and user quiet window;
- performance attempt or slot launch, real A／B／C execution, P95 interpretation, KBM, and game launch;
- OneDrive shutdown, AC／power-mode request, Gate 2 decision, Slice 2-B authorization, presentation integration,
  and any product-code change.

On any non-Pass result, return the frozen actual partial state. On final return, whether Pass or non-Pass, `30` may update only
the required report, new evidence under the required evidence root, and `docs/handoffs/qa.md` on the required QA branch.
Do not create a receipt-only commit before execution and do not push `main`. `00統括` alone accepts the result and decides
whether a later performance-only order may be issued.

## 9. Required report contents

The report at `docs/test-reports/phase2-slice2a-stage-p-consolidated-recovery.md` must include:

- active-time ledger for the 2h census and 4h offline recovery limits;
- every offline candidate identity and disposition, with count no greater than `3`;
- complete census and explicit `CP-ORDER-001`／`CP-ABC-001` results;
- final QUALIFY and FORMAL exact invocation counts, commands, exits, streams, manifests, and root identities;
- candidate-012 before／after `8 / 8` equality and candidate-013 absence;
- all lifecycle, compile, mode, PREACK, performance, A／B／C, and game counters;
- final recommendation and a statement that PREPARED does not accept performance or unlock Gate 2／Slice 2-B.
