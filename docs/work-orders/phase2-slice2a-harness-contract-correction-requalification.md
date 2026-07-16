# Work Order — Phase 2 Slice 2-A QA Harness Contract Correction and Requalification

- Work order ID: `MFO-WO-P2-2A-008`
- Issued by: `00統括（監督）`
- Issued: 2026-07-16 (Asia/Tokyo)
- Priority: **P1 / acceptance-evidence integrity blocker**
- Findings: [`KI-010`](../KNOWN_ISSUES.md), [`KI-012`](../KNOWN_ISSUES.md),
  [`KI-013`](../KNOWN_ISSUES.md), [`KI-015`](../KNOWN_ISSUES.md)
- Defect: `MFO-P2-2A-QA-004`
- Owner: `30 QA・性能・レビュー`
- Required user role: temporary OneDrive closure and one quiet qualification window
- Gameplay owner: `10ゲームプレイ・コア実装` — no work in this order
- Presentation owner: `20ステージ・UI・グラフィック` — no integration work in this order
- Status: **Returned / Fail / harness defect accepted / stage and evidence frozen**
- Milestone: M2 / Slice 2-A acceptance evidence
- Gate 2: **Locked / not evaluated**
- Basis: [`MFO-HOLD-P2-2A-001`](phase2-slice2a-performance-external-hold.md) and the accepted
  [`MFO-WO-P2-2A-007` Fail](phase2-slice2a-harness-correction-requalification.md)
- Required starting state: the pushed supervisor commit containing this order; `30` records its exact SHA
- Required QA branch: `codex/phase2-slice2a-harness-contract-requalification-qa`
- Required report: `docs/test-reports/phase2-slice2a-harness-contract-requalification.md`
- Required evidence root: `docs/test-reports/evidence/phase2-slice2a/qualification-003/`

This is a new explicit, non-automatic exception to the active performance hold. It authorizes exactly three QA
harness contract corrections, seal-before contract tests, and one new-stage non-acceptance harness requalification.
It authorizes **zero performance slots**, zero P95 interpretation, zero KBM repetition, and zero game-code change. It
changes no Approved decision, product requirement, performance threshold, gameplay value, renderer, resolution,
quality setting, power acceptance rule, or accepted KBM result.

## 1. Supervisor disposition

`00統括` accepts `MFO-WO-P2-2A-007` as **Fail / harness defect**:

- preparation `QP_DRYRUN`, `QP_SELFTEST`, and the corrected direct-`out Guid` production power／input smoke passed;
- sealed PREACK did not load, validate, hash, or record the preparation receipt identity;
- exact activation validation still required `MFO-WO-P2-2A-006 START_ACK` and would reject the required `-007` token;
- PREACK asserted expected identity／host／runtime values before its complete prerequisite record was persisted,
  read back, and hashed;
- PREACK, `PREACK_READY`, `START_ACK`, LIVE, P95, KBM and A／B／C launch were not run;
- performance slot launch count remained `0`, and the `85 / 85` ReadOnly stage is frozen;
- the evidence-root manifest independently matches `86 / 86` payloads.

Formal report:
[`../test-reports/phase2-slice2a-harness-requalification.md`](../test-reports/phase2-slice2a-harness-requalification.md)

Frozen evidence:
[`../test-reports/evidence/phase2-slice2a/qualification-002/`](../test-reports/evidence/phase2-slice2a/qualification-002/)

The `-007` stage `p2-2a-007-qp-20260715t231258jst-2e92cc8-c1`, report, and evidence must not be repaired,
appended to, resealed, copied forward as a stage, or retried.

## 2. Exact correction boundary

The only production harness logic corrections authorized by this order are:

1. **Preparation receipt and preparation-audit identity binding**
   - use the fixed new-stage paths `<stage>/seal/preparation-receipt.json` and
     `<stage>/seal/preparation-audit.json`;
   - accept an externally supplied expected receipt SHA-256 in the PREPARED／READY／PREACK protocol, recompute the file
     SHA-256, read it back, and record both values;
   - record and validate receipt schema, `work_order=MFO-WO-P2-2A-008`, `stage_id`, exact manifest path,
     `manifest_sha256`, `sealed=true`,
     `performance_slot_launch_count=0`, `p95_produced=false`, `kbm_performed=false`, and `abc_launched=false`;
   - compare the receipt fields with the supplied stage, the recomputed manifest identity, and the new-stage contract.
     Do not place the receipt hash inside the manifest or receipt in a way that creates a circular digest.
   - accept the externally supplied expected preparation-audit SHA-256, recompute the fixed audit file SHA-256, and
     record its fixed path and supplied／observed values in the pending observation. The audit hash is bound only by the
     external protocol and must not be embedded in the manifest, receipt, or audit bytes that determine it.
2. **Exact `-008` activation identity**
   - accept only `MFO-WO-P2-2A-008 START_ACK` with every required field in the exact order below;
   - reject old `-006`, `-007`, missing-field, extra-field, reordered, case-changed, or otherwise non-exact tokens;
   - remove stale old-work-order literals from the production activation validator. Do not generalize this into a
     product protocol or network abstraction.
3. **Persist complete PREACK evidence before expected-value assertions**
   - after syntactically valid invocation parsing, collect stage／manifest／component／source／invocation／receipt,
     OneDrive, power／input, runtime／ownership, native tick, and slot observations into non-throwing structured
     captures, including success／error fields;
   - create one complete `evaluation=pending` observation containing supplied／observed raw values and capture
     success／error only; append and flush／close its journal entry, write the standalone observation, read it back,
     verify its complete required field set, and compute its SHA-256;
   - the pending observation must not contain its own SHA-256, readback result, or expected-value match booleans. After
     readback and hashing, create a separate evaluation／closure that records the pending path／SHA-256, readback and
     field-completeness results, field-level matches, classification, and terminal reason;
   - only after the pending observation's durable readback and hash may the evaluation assert any expected stage,
     digest, receipt, OneDrive, AC, overlay, input, runtime, ownership, tick, or slot value;
   - runner and launcher must preserve structured result, mapped exit, raw streams, pending observation path／SHA-256,
     evaluation／closure path／SHA-256, and terminal reason on every invocation whose basic CLI paths can be captured.
     Moving only the final launcher assertions is insufficient if runner forwarding or file-identity helpers can still
     throw before the pending observation exists.

Keep the already corrected `PowerGetEffectiveOverlayScheme(out Guid)` path and its status handling byte-for-byte unless
a mechanical call-site adjustment is required by item 3. Do not restore `out IntPtr`, `PtrToStructure`, or `LocalFree`.
Do not replace the effective-overlay query, change the Best-performance GUID
`ded574b5-45a0-4f42-8737-46345c09c238`, or substitute the configured AC mode／power-plan name for the effective overlay.

## 3. Authorized and forbidden scope

Authorized tracked scope is limited to:

- this order's new QA report and new evidence below `qualification-003/`;
- QA-owned harness source copies, compiled-component identities, raw streams, structured results, journals,
  manifests, receipts, and exact invocation templates required by the new stage, with **every tracked copy** located
  below `qualification-003/`;
- the three corrections in Section 2 and the mandatory seal-before tests in Section 5;
- `docs/handoffs/qa.md` for receipt, PREPARED, and final result only.

QA may create a fresh candidate below `%LOCALAPPDATA%` or `%TEMP%`, outside every OneDrive root, and compile the QA
runner, launcher, controller, native helper, and sentinel before sealing. Source and identity metadata may be committed
as evidence; executable and DLL payloads must not be committed.

Forbidden:

- game code, gameplay tests, recorder, scenes, `project.godot`, export／build settings, quality settings, gameplay
  values, thresholds, release-artifact builds／changes, or A／B／C build／change／launch／commit;
- performance-slot launch, frame recorder, arena run, P95, FPS, GPU timing, CPU acceptance, KBM, user feel, or physical
  gamepad work;
- repair, mutation, deletion, execution, reseal, stage reuse, or evidence replacement for `-006` or `-007`;
- unrelated harness refactoring, native API expansion, new process framework, new evidence meaning, or weakening of
  Pass／Fail／Blocked classification;
- automatic OneDrive shutdown／kill, power-mode change, startup change, sign-out, account inspection, unrelated-file
  inspection, repository relocation, or deletion;
- Git or repository I/O after the user sends `START_ACK` and before `30` announces the live window ended.

`10` performs no work. `20` may continue only separate, disconnected, non-binding proposals. Gate 2, Slice 2-B, and
all later implementation remain locked.

Before changing harness source or materializing a candidate, `30` first updates its own `docs/handoffs/qa.md` to name
this `-008` order, the required QA branch, and the exact supervisor starting SHA. It does not edit another role's
handoff.

## 4. Fresh stage and identity protocol

Create a new stage ID beginning `p2-2a-008-qp-`; do not reuse any old stage ID or directory. The `-007` source may be
used as the correction baseline, but the runtime stage, compiled components, manifests, receipts, journals, and results
must all be newly materialized.

Before PREPARED:

1. record the exact supervisor starting commit and clean QA branch;
2. record a source-diff audit proving only the three Section 2 corrections and Section 5 tests changed harness logic;
3. compile all components and record SHA-256, byte size, `MZ`, source path, compiler invocation, role, and exact
   invocation templates;
4. choose and record one fresh writable run-evidence root outside the sealed stage and every OneDrive root, for example
   `%LOCALAPPDATA%\Temp\MFO-P2-2A-008-Runs\<stage-id>`. It must be absent before PREPARED and is the only location that
   PREACK／LIVE may create runtime observations, evaluations, activations, journals, results, or raw streams;
5. create one final runtime manifest that covers stage ID, work order `MFO-WO-P2-2A-008`, exact run-evidence root,
   every component, source, evidence schema, fixed `<stage>/seal/preparation-receipt.json` and
   `<stage>/seal/preparation-audit.json` paths, invocation argument grammar／templates, and performance slot count `0`
   contract. Templates use named digest placeholders; neither manifest／receipt／preparation-audit digest may be embedded
   as a literal in bytes that determine that same digest;
6. hash that final manifest once, then create the final preparation receipt containing its exact identity and every
   field required by Section 2. Hash the final receipt separately. The manifest does not contain its own hash or the
   receipt hash; the receipt points one-way to the manifest, and external tokens bind the receipt hash;
7. run every Section 5 test against the final exact source／component／configuration／template／manifest／receipt bytes,
   including the actual final receipt positive case. Test outputs are preparation evidence, not inputs to the runtime
   manifest digest;
8. after all tests, create the final `<stage>/seal/preparation-audit.json` covering every test result／journal／raw stream
   and independently re-hashing the unchanged runtime source, components, configuration, manifest, and receipt. Hash
   the preparation audit externally; no tested runtime byte may change after its test;
9. make the entire stage immutable, prove all stage files ReadOnly and `runs/` absent, then post-seal re-hash the
   manifest, receipt, preparation audit, and every identity they enumerate. The external run-evidence root must remain
   absent until PREACK.

A／B／C remain identity-only inputs and must not be launched. Preserve these exact EXE identities:

| Label | Source | Required EXE SHA-256 |
|---|---|---|
| A | Gate 1 baseline `a13505e8fbf82962e049b9101a87593a6692d2c7` | `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` |
| B | pre-correction `295549373fbb3b39deb6079172783ce62c7da532` | `3c15c254fbb8025d88c5636f2175a35f6e325b5368c8098e78b16181090dd4ef` |
| C | corrected `5261a73707daca03cb160e03a12247886d3f5cce` | `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47` |

## 5. Mandatory seal-before tests

The stage may be sealed only after all tests pass with structured results, exact exit codes, raw stdout／stderr,
journal readback, hash-chain verification, final byte identities, A／B／C launch count `0`, and performance slot count
`0`:

1. rerun the inherited `QP_DRYRUN`, process inventory／ownership／timeout／cleanup／sentinel／stream self-tests, and the
   exact same-production-`PowerAndInput` direct-`out Guid` smoke on final bytes;
2. static audit proves the effective-overlay path has one direct `out Guid` query and no `out IntPtr`,
   `PtrToStructure`, or `LocalFree` use;
3. add a bounded `QP_PREACK_CONTRACT_SELFTEST` using the same compiled receipt reader, complete-record writer／readback,
   evaluator, and exact activation validator used by production PREACK／LIVE. It must not start PREACK, LIVE,
   controller, exported games, A／B／C, or a performance slot;
4. positive receipt fixture: exact receipt hash and every required receipt field pass, and the pending-observation path
   and SHA-256 are produced before the Pass evaluation;
5. negative receipt fixtures: missing／unreadable file, malformed JSON, missing required field, wrong hash, schema,
   work order, stage, exact manifest path, manifest digest, `sealed` flag, nonzero slot, `p95_produced=true`,
   `kbm_performed=true`, and `abc_launched=true` are each rejected only after a complete pending observation is
   written, read back, and hashed;
6. exact token fixtures: the exact `MFO-WO-P2-2A-008 START_ACK` passes; `-006`, `-007`, missing, extra, reordered, and
   case-changed tokens fail;
7. representative host／runtime fixture mismatches, including OneDrive nonzero and wrong overlay, prove a complete
   pending observation and SHA-256 exist before terminal classification. These are synthetic fixtures and must not be
   reported as observed host state;
8. static and runtime audit prove production PREACK uses the same tested persistence／readback／evaluation functions,
   and that no expected-value assertion is reachable before successful complete-record readback and hash;
9. source scan proves the production activation validator contains `MFO-WO-P2-2A-008` and contains no `-006` or `-007`
   work-order literal.

Negative fixtures must internally assert the expected rejection while the enclosing contract self-test returns Pass;
they are not terminal stage results and must not be reported as observed host failures.

Any failure before sealing may be repaired only inside Sections 2 and 5. After any source, component, configuration,
or invocation change, rerun every affected test and regenerate all affected identities. Once sealed, the stage is
immutable.

After sealing, `30` sends exactly:

```text
MFO-WO-P2-2A-008 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex>
```

No qualification window has started at PREPARED. Before any READY token, `00` independently verifies the three
supplied digests, final receipt fields, preparation-audit enumeration and Pass results, post-seal rehash, stage
ReadOnly state, absent external run-evidence root, QA branch／scope, and slot／A／B／C launch counts `0`.

## 6. READY, PREACK, and user activation

Before READY, the user saves unrelated work, keeps AC connected, closes OneDrive, and stops heavy work. `00` confirms
that OneDrive-family count is `0`, AC is online, and the corrected direct-GUID effective-overlay readback is exactly
`ded574b5-45a0-4f42-8737-46345c09c238`. A configured AC-mode value, base-plan name, UI label, or historical result is
not a substitute. QA must not change these host settings automatically.

This is an independent read-only `00`／user host probe. It must not execute or modify a sealed stage component and does
not replace the fresh durable PREACK evidence.

Only after those checks and the sealed-stage audit pass, `00` sends exactly:

```text
MFO-WO-P2-2A-008 stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex> QUALIFICATION WINDOW READY
```

The sealed PREACK runner starts the sealed launcher once and does not start the controller. After the syntactically
valid basic CLI paths are captured, it creates the fixed external run-evidence root and follows Section 2's observe →
complete pending observation → flush／close → readback → hash → separate evaluation order. The pending observation
contains only raw supplied／observed values and capture outcomes:

- supplied and observed stage, work-order, manifest, component, source, invocation, preparation receipt, and final
  preparation-audit identities;
- preparation-receipt path, supplied／observed SHA-256, raw parsed fields, and parse／capture errors;
- full case-insensitive `OneDrive*` inventory;
- power API success／status／AC value and the direct-GUID effective overlay;
- input API success／error／informational `UInt32 dwTime`;
- QA-owned, descendant, and forbidden-runtime inventories;
- canonical native monotonic tick and performance slot launch count `0`;
- per-capture success／error, `evaluation=pending`, and the fixed pending-observation path.

The pending observation contains no match booleans, readback result, or self-hash. After durable readback and hashing,
the separate evaluation／closure records its path and SHA-256, readback／field-completeness results, field-level matches,
classification, and terminal reason. PREACK then requires exact identities, receipt, preparation audit, OneDrive count
`0`, AC online, effective Best-performance overlay, successful input API, expected runtime ownership, nonzero native
tick, and slot count `0`. `preack_sha256` is the SHA-256 of the exact pending-observation bytes; the separate evaluation
has its own `preack_evaluation_sha256`. The runner captures launcher result／exit／raw streams, validates mapped exit `0`,
writes its own structured closure, and exits `0` before `30` sends:

```text
MFO-WO-P2-2A-008 PREACK_READY stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex> preack_sha256=<64-hex> preack_evaluation_sha256=<64-hex> preack_tick=<uint64>
```

The user replies by echoing every field exactly:

```text
MFO-WO-P2-2A-008 START_ACK stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex> preack_sha256=<64-hex> preack_evaluation_sha256=<64-hex> preack_tick=<uint64>
```

Immediately afterward the user stops keyboard／mouse input until `30` announces the window ended. Any PREACK identity,
receipt, host, runtime, persistence, readback, hash, exit, or timeout failure prevents `PREACK_READY`.

After a valid `PREACK_READY`, QA first writes the user's exact raw `START_ACK` bytes to the external run-evidence root,
then the LIVE runner persists and hashes a non-throwing activation-parse observation before exact-token evaluation. A
missing or non-exact user acknowledgement prevents LIVE launcher／controller start and is **Blocked / invalid user
activation acknowledgement**. The validator accepting an invalid token or rejecting the exact required token is
**Fail / harness defect**. QA reports the fresh terminal result and does not repair the stage or host automatically.

## 7. One live harness requalification

After exact `START_ACK`, execute one new-stage LIVE sequence using the frozen ownership, clock, sentinel, cadence,
journal, timeout, cleanup, and exit-code contracts:

1. the LIVE runner read-back verifies stage／manifest／preparation receipt／preparation audit／PREACK evaluation／activation
   identities, obtains the authoritative successful `GetLastInputInfo` `UInt32 dwTime` quiet-window baseline, and
   persists a new live-runner pending observation followed by its separate evaluation／closure before expected-value
   assertions. Launcher does the same for its own observation. Neither path modifies or reuses the sealed
   `preparation-receipt.json`;
2. prove `preack_tick < runner_receipt_tick <= launcher_receipt_tick <= controller_origin`; set the 600-second
   deadline to exactly `controller_origin + 600000` on the canonical native clock;
3. execute the deterministic sentinel READY／release handshake once and capture identity, raw streams, expected
   internal exit `23`, timeout, and cleanup;
4. after sentinel exit／cleanup, record `settle_origin`; persist sample `n=0` immediately, then `n=1..60` at target
   `settle_origin + n * 1000` ms. Require contiguous unique `n=0..60`, strictly increasing actual ticks, every actual
   tick within `[target, target + 250]`, and final duration at least `60000 ms`;
5. every complete sample records target／actual native tick, corrected production power／input success／status／value,
   OneDrive count `0`, AC online, effective Best-performance overlay, exact last-input equality to the LIVE baseline,
   owned／forbidden process inventories, and slot count `0`. Persist, read back, and hash the complete sample before
   asserting expected values;
6. preserve structured controller／launcher／runner results, child exits, raw streams, final cleanup, owned-runtime
   count `0`, identity audit, journal readback／hash chain, and performance slot count `0`.

This is not a performance run. Do not launch an exported game, record frames, calculate or interpret P95, or infer
gameplay performance from its timing.

## 8. Acceptance and terminal routing

Recommend **Pass / harness qualified** only when all seal-before tests, corrected PREACK protocol, exact activation,
LIVE 61-sample sequence, ordering, sentinel, ownership, streams, structured results, cleanup, final identities,
journal, and slot count `0` are complete and valid.

| Observed outcome | Classification |
|---|---|
| All required mechanics and evidence complete; external state stable; slot count `0` | **Pass / harness qualified** |
| Harness identity／receipt／token／ordering／persistence／readback／API／clock／journal／process／stream／timeout／cleanup mechanism fails or required evidence is missing | **Fail / harness defect** |
| Durable pending observation and evaluation prove OneDrive／power／input or another non-QA host prerequisite unavailable or changed | **Blocked / host prerequisite** |
| Durable activation observation proves the user's `START_ACK` is missing or non-exact before LIVE starts | **Blocked / invalid user activation acknowledgement** |

The report must include supervisor start commit, QA HEAD, stage／manifest／receipt／preparation-audit identities, exact
invocations, source-diff and final-byte audits, all preparation tests, PREACK and activation tokens, pending
observations and separate evaluations, live records, exits／streams, cleanup, changed-path audit, and an evidence-root
`SHA256SUMS.txt` covering every payload except itself. Preserve Pass, Fail, Blocked, and Not run separately.

On any terminal result, freeze the new stage and evidence and return to `00統括`; do not retry automatically. The user
may restart OneDrive only after `30` announces the qualification window ended. Pass does not end
`MFO-HOLD-P2-2A-001`, authorize performance measurement, accept Slice 2-A, open Gate 2, or authorize Slice 2-B.

## 9. Supervisor closure — 2026-07-16

`00統括` accepts the final QA recommendation **Fail / harness defect** at
`1ab2ccb4cd5b9dc8b44c5130cb942c6255a5f42c`.

- PREACK, exact user activation, host stability, 61-sample cadence, global cleanup, and runtime self-results completed;
- all 61 sample payloads omitted the required per-sample `performance_slot_launch_count=0` field;
- `n=0` was persisted before sentinel stream flush, owned-child exit, and `sentinel_complete`;
- runner and launcher LIVE evaluations omitted `pending_field_completeness_success`;
- performance slot launch count remained `0`; P95, KBM, A／B／C, and game execution were Not run;
- evidence manifest SHA-256
  `58827846f38becad61f08104db889f27b78f68e34f36527a891b5b8967200e25` independently matches `321 / 321` payloads;
- the exact user `START_ACK` was valid. The separate supervisor-chat message `ミスです！` was not used by QA.

The stage and evidence remain frozen. No repair, reseal, or retry is authorized by this closed order. The only active
successor is
[`MFO-WO-P2-2A-009`](phase2-slice2a-harness-live-evidence-correction-requalification.md), limited to the three new
LIVE-evidence defects and one fresh non-performance requalification.
