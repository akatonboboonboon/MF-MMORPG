# Work Order — Phase 2 Slice 2-A QA Harness LIVE Evidence Correction and Requalification

- Work order ID: `MFO-WO-P2-2A-009`
- Issued by: `00統括（監督）`
- Issued: 2026-07-16 (Asia/Tokyo)
- Priority: **P1 / acceptance-evidence integrity blocker**
- Findings: [`KI-010`](../KNOWN_ISSUES.md), [`KI-013`](../KNOWN_ISSUES.md),
  [`KI-016`](../KNOWN_ISSUES.md)
- Defects: `MFO-P2-2A-QA-005`, `MFO-P2-2A-QA-006`, `MFO-P2-2A-QA-007`
- Owner: `30 QA・性能・レビュー`
- Required user role: temporary OneDrive closure and one quiet qualification window after PREPARED
- Gameplay owner: `10ゲームプレイ・コア実装` — no work in this order
- Presentation owner: `20ステージ・UI・グラフィック` — no integration work in this order
- Status: **Returned / Pass / harness qualified accepted / stage and committed evidence preserved**
- Milestone: M2 / Slice 2-A acceptance evidence
- Gate 2: **Locked / not evaluated**
- Basis: [`MFO-HOLD-P2-2A-001`](phase2-slice2a-performance-external-hold.md) and the accepted
  [`MFO-WO-P2-2A-008` Fail](phase2-slice2a-harness-contract-correction-requalification.md)
- Required starting state: the pushed supervisor commit containing this order; `30` records its exact SHA
- Required QA branch: `codex/phase2-slice2a-harness-live-evidence-requalification-qa`
- Required report: `docs/test-reports/phase2-slice2a-harness-live-evidence-requalification.md`
- Required evidence root: `docs/test-reports/evidence/phase2-slice2a/qualification-004/`

This is a new explicit, non-automatic exception to the active performance hold. It authorizes exactly three
LIVE-evidence contract corrections, their bounded seal-before tests, and one fresh non-performance harness
requalification. It authorizes **zero performance slots**, zero P95 interpretation, zero KBM repetition, zero game
launch, and zero game-code change. It changes no Approved product decision, performance threshold, gameplay value,
renderer, resolution, quality setting, power rule, or accepted KBM result.

## 1. Supervisor disposition

`00統括` accepts `MFO-WO-P2-2A-008` as **Fail / harness defect** after independent review:

- QA branch local／origin／actual remote are exactly `1ab2ccb4cd5b9dc8b44c5130cb942c6255a5f42c`;
  `main` remains `afcd20cd4a02d618a5d7e0e4bc7555a64fa90740`;
- changed tracked scope is QA handoff, the new formal report, and new `qualification-003` evidence only;
- `SHA256SUMS.txt` SHA-256 is
  `58827846f38becad61f08104db889f27b78f68e34f36527a891b5b8967200e25`, with `321 / 321` payloads matching;
- PREACK and exact user `START_ACK` were valid; the exact activation was `519` UTF-8 bytes, with no BOM or trailing
  newline, and SHA-256 `1a5a25b1ffd449ed545ba14eb8f373753c189a03da37099a6b27b35c6647bce0`;
- all 61 host samples held OneDrive count `0`, AC online, Best-performance overlay, stable input, forbidden-runtime
  count `0`, and the overall performance-slot launch count remained `0`;
- all three runtime roles self-reported `0 / Pass`, but explicit work-order evidence requirements still failed:
  1. all `61 / 61` `live_sample` records omitted required `performance_slot_launch_count=0`;
  2. sample `n=0` was persisted before sentinel stream flush, owned-child exit, and `sentinel_complete`;
  3. runner and launcher LIVE evaluations omitted `pending_field_completeness_success`, with no launcher-side later
     closure preserving an equivalent result;
- P95, KBM, A／B／C, exported games, frame recording, and game code were not run or changed.

The exact user activation is valid. The separate supervisor-chat text `ミスです！` was not forwarded to QA and did
not enter activation bytes or evaluation. The failure is not attributed to user input or host prerequisites.

Formal report:
[`../test-reports/phase2-slice2a-harness-contract-requalification.md`](../test-reports/phase2-slice2a-harness-contract-requalification.md)

Frozen evidence:
[`../test-reports/evidence/phase2-slice2a/qualification-003/`](../test-reports/evidence/phase2-slice2a/qualification-003/)

The `-008` stage, runtime evidence, report, and evidence must not be repaired, appended to, resealed, deleted, or
retried. They are read-only correction inputs only.

## 2. Exact correction boundary

The only production harness logic corrections authorized by this order are:

1. **Per-sample performance-slot evidence**
   - every persisted `live_sample`, including `n=0`, contains the exact field
     `performance_slot_launch_count=0` before readback, hashing, or expected-value assertions;
   - the field is part of the sample's durable bytes and journal payload. A controller-final or runner-final global
     slot count is not a substitute;
   - missing or nonzero sample values fail the sample contract after that sample is durably recorded and hashed.
2. **Sentinel cleanup before sampling**
   - finish sentinel READY／release, observe expected exit `23`, flush stdout／stderr, drain and dispose the owned child,
     prove the sentinel job has zero active processes, and persist `sentinel_complete` before choosing `settle_origin`;
   - then persist `settle_origin`, followed immediately by sample `n=0`;
   - the durable order must be `owned_child_exit` → `sentinel_complete` → `settle_origin_after_sentinel_exit` →
     `live_sample n=0`. Do not capture `n=0` from a pre-cleanup exit callback.
3. **LIVE evaluation field-completeness result**
   - both the runner activation evaluation and launcher LIVE evaluation／closure record
     `pending_readback_success` and `pending_field_completeness_success` as separate booleans;
   - completeness is calculated from the exact required pending-field set after durable readback, before any expected
     identity, host, runtime, token, or slot assertion;
   - Pass requires both booleans `true`. A later receipt does not replace the launcher evaluation／closure field.

The work-order identity rollover from `-008` to exact `MFO-WO-P2-2A-009` in manifest, receipt, audit, tokens, fixtures,
and production activation validation is a required mechanical change. Production activation accepts only the exact
`-009 START_ACK` form in Section 6 and rejects `-006`, `-007`, `-008`, missing, extra, reordered, and case-changed forms.

### 2.1 Supervisor clarification — byte-exact activation enforcement (2026-07-16)

The mechanical exact-`-009` activation requirement above includes the minimum implementation and audit changes needed
to make "exact one-line byte content" literal rather than line-normalized. This is **not a fourth LIVE-evidence
correction** and does not broaden the three numbered corrections in Section 2.

- `RequireExactActivation` compares the raw activation bytes with the exact expected UTF-8 bytes. The expected bytes
  have no BOM and no trailing `CR`, `LF`, or `CRLF`.
- Production validation must not call `Trim`, `TrimEnd`, newline normalization, whitespace normalization, or an
  equivalent decode／normalize／re-encode step before equality is decided.
- The positive exact fixture writes only the expected bytes, with no added line terminator. Named negative fixtures
  append `CR`, `LF`, and `CRLF` separately and must each be rejected as extra-byte forms. Existing missing, reordered,
  case-changed, and legacy-ID negative coverage remains unchanged.
- `StagePreparer` source-diff and source-audit logic must bind these fixtures to the same production validator and
  fail closed if production still trims or normalizes line endings. Authorized source hunks are limited to removing
  that tolerance, changing the positive fixture bytes, adding the three named line-ending negatives, and the exact
  audit／binding needed to prove those facts.
- No activation token field, ordering, encoding, acknowledgement owner, classification, timeout, PREACK／LIVE flow,
  or other protocol behavior may change. All five Section 5 modes and the final source-diff audit must be rerun on the
  final candidate before sealing.

This clarification was issued before stage materialization. It authorizes no old-stage reuse, performance slot, P95,
KBM, A／B／C, game launch, or game-code change.

Keep the corrected direct-`out Guid` effective-overlay path, preparation receipt／audit binding, two-document
pending／evaluation protocol, native clock, process ownership, exit mapping, timeout, and 61-sample cadence unchanged
except for mechanical call-site changes strictly required by the three items above. Do not add a new acceptance
requirement or unrelated harness framework.

## 3. Authorized and forbidden scope

Authorized tracked scope is limited to:

- this order's new QA report and new evidence below `qualification-004/`;
- QA-owned harness source copies, final-byte identity metadata, raw streams, structured results, journals, manifest,
  receipt, preparation audit, and invocation templates required by the fresh stage, with every tracked copy below
  `qualification-004/`;
- the three Section 2 corrections and Section 5 tests;
- `docs/handoffs/qa.md` for receipt, PREPARED, and final result only.

QA may use the frozen `-008` source SHA-256
`01ed440a0973471ab78c057910f91101e22e04620bd33c49d52259d9cb72e810` as the correction baseline, but must create a
fresh candidate outside every OneDrive root. It must not copy or reuse an old runtime stage, run directory, compiled
component, journal, manifest, receipt, audit, PREACK, or activation.

Forbidden:

- game code, gameplay tests, recorder, scenes, `project.godot`, export／build settings, quality, gameplay values,
  thresholds, release artifacts, or A／B／C build／launch／commit;
- performance slots, exported games, frame recorder, arena run, P95, FPS, GPU timing, CPU acceptance, KBM, user feel,
  or physical-gamepad work;
- mutation, deletion, execution, reseal, or reuse of `-006`, `-007`, or `-008` stages／evidence;
- unrelated refactoring, new native APIs, a new process framework, changed evidence meaning, or weakened
  Pass／Fail／Blocked classification;
- automatic OneDrive shutdown, power-mode change, account inspection, repository relocation, or unrelated-file
  inspection;
- Git or repository I/O after the user sends `START_ACK` and before QA announces the window ended.

`10` performs no work. `20` remains limited to separate disconnected non-binding proposals. Gate 2, Slice 2-B, damage,
binding, production events／assets, music／voice, network／server, and account／persistent-data work remain locked.

Before changing source, `30` first updates only `docs/handoffs/qa.md` with this order, its required branch, and the exact
supervisor starting commit, then commits and pushes that receipt.

## 4. Fresh stage and seal

- Create a new stage ID beginning `p2-2a-009-qp-` outside every OneDrive root.
- Choose one new external run-evidence root outside the stage and OneDrive. It remains absent until PREACK.
- Compile fresh runner, launcher, controller, native helper, and sentinel. Record source path, SHA-256, size, MZ,
  compiler invocation, role, and exact invocation templates. Do not commit EXE／DLL payloads.
- Create a final manifest with `work_order=MFO-WO-P2-2A-009`, exact stage／run roots, fixed
  `<stage>/seal/preparation-receipt.json` and `<stage>/seal/preparation-audit.json`, all component and schema identities,
  argument grammar, exact token templates, performance-slot contract `0`, P95／KBM／A-B-C false／zero, and old-stage
  reuse false.
- Hash the final manifest once; create and hash a one-way preparation receipt containing its exact path／hash, stage,
  work order, sealed flag, slot `0`, and P95／KBM／A-B-C false／zero.
- Run every Section 5 test against the exact final source, configuration, manifest, receipt, and component bytes.
- After all tests, create and externally hash the preparation audit. It enumerates all test results／journals／streams
  and rehashes unchanged runtime bytes. No digest is embedded into bytes that determine itself.
- Make all stage files and directories ReadOnly, prove stage-local `runs/` absent, rehash every enumerated identity,
  and prove the external run-evidence root is still absent.

## 5. Mandatory seal-before tests

All tests use final bytes, preserve raw stdout／stderr, structured results, journals, readback, hash chains, exact exit
codes, final cleanup, performance slot count `0`, and A／B／C launch count `0`.

1. Rerun inherited `QP_DRYRUN`, `QP_SELFTEST`, `QP_POWER_INPUT_SMOKE`, and
   `QP_PREACK_CONTRACT_SELFTEST`, including the direct-`out Guid` production smoke, receipt／audit binding, exact
   `-009` activation, and persist-before-assert positive／negative fixtures.
2. Add one bounded `QP_LIVE_EVIDENCE_CONTRACT_SELFTEST` using the same production sample builder, sentinel cleanup
   sequence, LIVE pending writer／readback, and runner／launcher evaluator used by LIVE. It must not start controller,
   exported games, A／B／C, or a performance slot.
3. Sample fixture: the production builder's durable representative sample contains
   `performance_slot_launch_count=0`. Missing and nonzero negative samples are rejected after durable write,
   readback, and hash. The enclosing self-test remains Pass when each expected rejection occurs.
4. Sentinel fixture: run the actual sentinel READY／release path once with expected internal exit `23`; persist and
   verify `owned_child_exit` with streams flushed, `sentinel_complete`, `settle_origin_after_sentinel_exit`, then
   representative `live_sample n=0` in that exact order, with zero active owned processes before settle origin.
5. LIVE evaluation fixtures: runner and launcher evaluations each contain
   `pending_readback_success=true` and `pending_field_completeness_success=true`; a missing-required-field fixture
   yields completeness `false` only after the pending bytes are durably read back and hashed.
6. Static and runtime binding proves production LIVE uses those same tested functions. Source scan proves the sample
   field is written before persistence, no pre-cleanup callback can capture `n=0`, and the production acceptance
   constant／path uses exact raw-byte `-009` equality without line-ending or whitespace normalization. Legacy `-006`,
   `-007`, and `-008` literals may exist only in named negative-test fixtures and must never be accepted by the
   production validator.
7. Source-diff audit proves only Section 2, the mechanical `-009` identity rollover, and these tests changed from the
   frozen `-008` source. The direct-overlay ABI and every unrelated region remain byte-identical.

Any pre-seal failure may be repaired only within Sections 2 and 5. After any source, component, configuration, or
invocation change, rerun all affected tests and regenerate affected identities. Once sealed, no repair is allowed.

After sealing, `30` sends exactly:

```text
MFO-WO-P2-2A-009 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex>
```

No qualification window begins at PREPARED. `00` independently checks branch scope, supplied hashes, receipt／audit,
all five test results, final identity enumeration, ReadOnly state, absent external run root, and slot／A-B-C counts.

## 6. READY, PREACK, and exact activation

Before READY, the user saves unrelated work, keeps AC connected, closes OneDrive, and stops heavy work. `00` confirms
OneDrive-family count `0`, AC online, and direct `PowerGetEffectiveOverlayScheme(out Guid)` exactly
`ded574b5-45a0-4f42-8737-46345c09c238`. QA does not change host settings automatically.

Only after these checks, `00` sends exactly:

```text
MFO-WO-P2-2A-009 stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex> QUALIFICATION WINDOW READY
```

PREACK starts the sealed launcher once but not the controller. Runner and launcher each persist complete pending
observations, close／read back／hash them, then create separate evaluations containing both
`pending_readback_success` and `pending_field_completeness_success` before asserting identities, receipt／audit, host,
runtime, tick, input, or slot. On exact Pass, `30` sends:

```text
MFO-WO-P2-2A-009 PREACK_READY stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex> preack_sha256=<64-hex> preack_evaluation_sha256=<64-hex> preack_tick=<uint64>
```

The user replies with this exact one-line byte content:

```text
MFO-WO-P2-2A-009 START_ACK stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex> preack_sha256=<64-hex> preack_evaluation_sha256=<64-hex> preack_tick=<uint64>
```

The user stops keyboard／mouse input immediately after sending it and resumes only after QA announces the window
ended. QA persists the exact activation bytes before evaluation. Missing or non-exact user activation prevents LIVE
and is **Blocked / invalid user activation acknowledgement**; an exact-token validator defect is **Fail / harness
defect**.

## 7. One LIVE harness requalification

After exact `START_ACK`, execute one fresh non-performance LIVE sequence:

1. Runner and launcher each persist and hash a complete LIVE pending observation, then create separate evaluations
   containing readback and field-completeness results before expected assertions or child start.
2. Preserve `preack_tick < runner_receipt_tick <= launcher_receipt_tick <= controller_origin`; deadline remains
   `controller_origin + 600000` on the canonical native clock.
3. Complete sentinel READY／release, expected exit `23`, stream flush, child drain／dispose, job active count `0`, and
   durable `sentinel_complete` before recording settle origin.
4. Persist `settle_origin_after_sentinel_exit`, then immediate `n=0`, followed by `n=1..60` at one-second targets.
   Require unique contiguous `0..60`, increasing ticks, each within `[target,target+250]`, and duration at least
   `60000 ms`.
5. Every persisted sample contains target／actual tick, lateness, complete power／input, OneDrive count `0`, AC online,
   Best-performance overlay, unchanged input baseline, owned／forbidden inventories, and exact
   `performance_slot_launch_count=0`. Read back and hash each complete sample before assertions.
6. Preserve runner／launcher／controller results, activation, all pending／evaluation files, sentinel raw streams,
   journal and hash chain, cleanup, final identity audit, residual runtime `0`, and global slot／A-B-C counts `0`.

This is not a performance run. Do not launch the game, record frames, calculate P95, or infer gameplay performance.

## 8. Acceptance and terminal routing

Recommend **Pass / harness qualified** only when all five preparation modes, PREACK, exact activation, both LIVE
evaluation completeness results, corrected sentinel order, all 61 complete sample payloads, cadence, host stability,
ownership, streams, cleanup, identities, journals, and slot count `0` are valid.

| Observed outcome | Classification |
|---|---|
| All required mechanics and evidence complete; external state stable; slot count `0` | **Pass / harness qualified** |
| Harness identity／token／ordering／persistence／readback／completeness／clock／journal／process／stream／cleanup mechanism fails or required evidence is absent | **Fail / harness defect** |
| Durable evidence proves OneDrive／power／input or another host prerequisite unavailable or changed | **Blocked / host prerequisite** |
| Durable activation evidence proves the user's acknowledgement missing or non-exact before LIVE | **Blocked / invalid user activation acknowledgement** |

The report records exact commits, stage and all supplied identities, commands, source-diff audit, five preparation
results, PREACK／activation, both LIVE evaluations, all 61 samples, sentinel event order, exits／streams, cleanup,
changed-path audit, and an evidence-root `SHA256SUMS.txt` covering every payload except itself. Preserve Pass, Fail,
Blocked, and Not run separately.

On any terminal result, freeze the new stage and evidence and return to `00統括`; do not retry automatically. Pass
does not end `MFO-HOLD-P2-2A-001`, authorize performance measurement, accept Slice 2-A, open Gate 2, or authorize
Slice 2-B. Only a later explicit supervisor order may authorize performance measurement.

## 9. Supervisor closure — 2026-07-16

`00統括` accepts the final QA recommendation **Pass / harness qualified** at
`35bfcf1f4efe7fe231c2956a6fa741c4acd81f3c`.

- PREPARED commit is `a595743b6d67093904bd374bae4dbf8dbbd43067`; runtime evidence commit is
  `132c18889b5655518b1feba1391c5ffa1cb6cf3f`;
- stage `p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1`, manifest
  `da49eaf1d24dfce39dba43d6babd649c77809450c5257696405cb15393acdcbf`, receipt
  `bcbafcad629d0045184bfe5bafae1637683e93bd087264d14e7cc9721b17f050`, and preparation audit
  `f5e21f872ff492d743d81fa36ff161a35899a8a7b8d4d2ec24583e7402bebf25` match;
- all five preparation modes, PREACK runner／launcher, exact raw-byte activation, LIVE
  runner／launcher／controller, all `61 / 61` samples, corrected sentinel order, evaluation completeness,
  journals, streams, and cleanup passed;
- all LIVE samples record `performance_slot_launch_count=0`; global performance slot and A／B／C launch counts
  remain `0`;
- P95, KBM, A／B／C, game, and physical gamepad were Not run;
- evidence manifest SHA-256
  `5504a7bebc51165a6faa84f0e7a75d98b388b4718aea032fad9ba7816a8451a2`
  matches `267 / 267` payloads;
- the user activation was valid before activation-file creation. The asynchronous safety HOLD did not interrupt
  or alter the naturally completed run; no retry, repair, regeneration, or raw-evidence mutation occurred;
- after formal return, two documentation blocks regressed to placeholders／CRLF. QA isolated the regression and
  restored exact HEAD bytes; the exact initiating process was not identified. Placeholder hit and worktree diff are
  `0`, with no new commit or evidence change.

The stage and committed evidence remain preserved. This closed order qualifies only the non-performance harness.
It does not end `MFO-HOLD-P2-2A-001`, authorize performance measurement, accept Slice 2-A, open Gate 2, or
authorize Slice 2-B. No successor execution order is active.
