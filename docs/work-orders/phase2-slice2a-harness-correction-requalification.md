# Work Order — Phase 2 Slice 2-A QA Harness ABI Correction and Requalification

- Work order ID: `MFO-WO-P2-2A-007`
- Issued by: `00統括（監督）`
- Issued: 2026-07-15 (Asia/Tokyo)
- Priority: **P1 / acceptance-evidence integrity blocker**
- Findings: [`KI-010`](../KNOWN_ISSUES.md), [`KI-012`](../KNOWN_ISSUES.md),
  [`KI-013`](../KNOWN_ISSUES.md), [`KI-014`](../KNOWN_ISSUES.md)
- Defect: `MFO-P2-2A-QA-003`
- Owner: `30 QA・性能・レビュー`
- Required user role: temporary OneDrive closure and one quiet qualification window
- Gameplay owner: `10ゲームプレイ・コア実装` — no work in this order
- Presentation owner: `20ステージ・UI・グラフィック` — no integration work in this order
- Status: **Returned / Fail accepted / stage frozen**
- Milestone: M2 / Slice 2-A acceptance evidence
- Gate 2: **Locked / not evaluated**
- Basis: [`MFO-HOLD-P2-2A-001`](phase2-slice2a-performance-external-hold.md) and the accepted
  [`MFO-WO-P2-2A-006` Fail](phase2-slice2a-harness-qualification.md)
- Required starting state: the pushed supervisor commit containing this order; `30` records its exact SHA
- Required QA branch: `codex/phase2-slice2a-harness-requalification-qa`
- Required report: `docs/test-reports/phase2-slice2a-harness-requalification.md`
- Required evidence root: `docs/test-reports/evidence/phase2-slice2a/qualification-002/`

This is an explicit, non-automatic exception to the active performance hold. It authorizes one bounded QA-harness ABI
correction and one new-stage, non-acceptance harness requalification. It authorizes **zero performance slots**, zero
P95 interpretation, zero KBM repetition, and zero game-code change. It changes no Approved decision, product
requirement, performance threshold, gameplay value, renderer, resolution, quality setting, or accepted KBM result.

## 1. Supervisor disposition and exact correction boundary

`00統括` accepts `MFO-WO-P2-2A-006` as **Fail / harness defect**:

- fresh PREACK OneDrive-family count was durably recorded as `0`;
- launcher exited `-1073741819` / `0xC0000005` in `Marshal.PtrToStructure`;
- outer runner returned structured result `30 / Fail`;
- `PREACK_READY`, `START_ACK`, LIVE, controller, P95 and KBM were not run;
- performance slot launch count remained `0`;
- the evidence manifest independently matches `33 / 33` files.

The sealed source declared `PowerGetEffectiveOverlayScheme(out IntPtr)`, treated returned GUID bytes as an allocated
pointer, dereferenced them, and called `LocalFree`. That ownership contract belongs to the separate
`PowerGetActiveScheme` `GUID **` API. The correction authorized by this order is exactly:

1. declare `PowerGetEffectiveOverlayScheme` with its existing native status return and direct `out Guid` output;
2. determine API success from native status `0` and serialize the returned `Guid` directly;
3. remove the pointer-nonzero condition, `Marshal.PtrToStructure`, and `LocalFree` from this API path;
4. remove the now-unused `LocalFree` declaration only if no other harness path uses it.

Do not replace the effective-overlay query with `PowerGetActiveScheme`, change
`ded574b5-45a0-4f42-8737-46345c09c238`, or change any power acceptance rule. Do not generalize the interop layer or
add unrelated native APIs.

The `-006` stage `p2-2a-006-qp-20260715t184405jst-2d5ef1a-c1`, `preack-001`, report, and evidence are frozen. They
must not be repaired, appended to, resealed, or retried.

## 2. Authorized and forbidden scope

Authorized tracked scope is limited to:

- this order's new QA report and new evidence below `qualification-002/`;
- the QA-owned harness source copies, compiled-component identities, raw streams, structured results, journals,
  manifests and receipts required by the new stage;
- the four exact interop corrections in Section 1;
- one seal-before production-path smoke added to close the `-006` coverage gap;
- `docs/handoffs/qa.md` for receipt, PREPARED, and final result only.

QA may create a fresh temporary candidate below `%LOCALAPPDATA%` or `%TEMP%`, outside every OneDrive root. QA may
compile the runner, launcher, controller, native helper and sentinel before sealing. The new evidence may contain their
source and identity metadata, but no executable or DLL is committed.

Forbidden:

- game code, gameplay tests, recorder, scenes, `project.godot`, build settings, quality settings, gameplay values,
  thresholds, release-artifact builds／changes, A／B／C build／change／launch／commit, or prior evidence changes;
- performance-slot launch, frame recorder, arena run, P95, FPS, GPU timing, CPU acceptance, KBM, user feel, or physical
  gamepad work;
- execution, mutation, deletion, copying-forward as a stage, or hash replacement of the `-006` stage／evidence;
- changes to evidence schemas or Pass／Fail／Blocked meanings except adding the required smoke record fields;
- automatic OneDrive shutdown／kill, startup changes, sign-out, account inspection, unrelated-file inspection,
  repository relocation, or deletion;
- Git or repository I/O after the user sends `START_ACK` and before the live window is closed.

`20` may continue only separate, disconnected, non-binding proposals. `10` performs no work. Gate 2, Slice 2-B and
all later implementation remain locked.

## 3. Fresh stage and sealed identity

Create a new stage ID beginning `p2-2a-007-qp-`; do not reuse any old stage ID or directory. A tracked copy of the
`-006` source may be used as the correction baseline, but the runtime stage, compiled components, manifests, receipts,
journals, and results must all be newly materialized.

Before PREPARED:

1. record the exact supervisor starting commit and clean QA branch;
2. record a source-diff audit proving only the Section 1 ABI change plus the required smoke path changed harness logic;
3. compile all components and record full SHA-256, byte size, `MZ`, source path, compiler invocation, component role,
   and exact invocation templates;
4. after the final source／component generation, compute candidate identities, run every mandatory test against those
   exact bytes, and independently re-hash the unchanged bytes before sealing. Any source, binary, configuration, or
   invocation change invalidates the affected test and requires a fresh run before sealing;
5. create one sealed manifest and preparation receipt covering the stage ID, every component, every source, every
   invocation template, evidence schema, and performance slot count `0` contract.

A／B／C candidates remain read-only identity inputs with the exact inherited identities below. QA may stage and hash
them read-only outside OneDrive; QA must not rebuild, alter, launch, or commit them.

| Label | Source | Required EXE SHA-256 |
|---|---|---|
| A | Gate 1 baseline `a13505e8fbf82962e049b9101a87593a6692d2c7` | `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` |
| B | pre-correction `295549373fbb3b39deb6079172783ce62c7da532` | `3c15c254fbb8025d88c5636f2175a35f6e325b5368c8098e78b16181090dd4ef` |
| C | corrected `5261a73707daca03cb160e03a12247886d3f5cce` | `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47` |

## 4. Mandatory seal-before tests

The stage may be sealed only after all of the following pass with structured results, exact exit codes, raw
stdout／stderr, journal readback, and hash-chain verification:

1. the prior `QP_DRYRUN` contract, including forbidden-runtime count `0`, final owned count `0`, and slot count `0`;
2. the prior synthetic process-inventory, expiry, process-ownership, timeout, cleanup, sentinel READY／release, and
   stream-capture self-tests;
3. a new `QP_POWER_INPUT_SMOKE` that invokes the **same compiled `HarnessOps.PowerAndInput` production method used by
   PREACK exactly once**, not a duplicate probe, second comparison query, or mocked wrapper;
4. the smoke must call `GetSystemPowerStatus`, corrected `PowerGetEffectiveOverlayScheme`, and `GetLastInputInfo`, then
   serialize and read back the same structured power／input record shape used by PREACK;
5. runtime smoke requires native API success and requires the serialized `effective_overlay_guid` to round-trip
   through `Guid.Parse`. Static／source-diff audit must prove that field is serialized directly from the `Guid` written
   by the same single `out Guid` call; do not add a second native query to compare values;
6. valid smoke input metadata means `GetLastInputInfo` success plus lossless `UInt32 dwTime` serialization／readback.
   The smoke imposes no nonzero, quiet-window equality, or Best-performance requirement and is not acceptance evidence;
7. the smoke record must bind the exact source, `MfoQaNative.dll`, invoking role binary, and invocation hashes. The
   final sealed manifest must match them byte-for-byte; any later byte／source／invocation change invalidates the smoke;
8. a static source audit must prove the effective-overlay path contains `out Guid` and contains no
   `out IntPtr`, `PtrToStructure`, or `LocalFree` use;
9. every preparation test must prove performance slot launch count `0` and A／B／C／MFO／Godot runtime count `0`.

Any failure before sealing may be repaired only within the Section 1 correction and smoke scope, then all affected
preparation tests and identity records must be regenerated. Once sealed, the stage is immutable.

After sealing, `30` sends exactly:

```text
MFO-WO-P2-2A-007 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex>
```

No qualification window has started at PREPARED.

## 5. PREACK and user activation

The user saves unrelated work, keeps AC connected, closes OneDrive, stops heavy work, and sends:

```text
MFO-WO-P2-2A-007 stage_id=<stage-id> manifest_sha256=<64-hex> QUALIFICATION WINDOW READY
```

The sealed PREACK runner starts the sealed launcher once without starting the controller. Before it can succeed, the
launcher must durably record and read back:

- exact stage／manifest／component／source／invocation identity match;
- case-insensitive `OneDrive*` inventory count `0`;
- AC online and effective overlay GUID `ded574b5-45a0-4f42-8737-46345c09c238` from the corrected direct-GUID wrapper;
- successful `GetLastInputInfo` and informational `UInt32 dwTime`;
- owned-child count `0` excluding the active PREACK runner／launcher, and MFO／Godot／A／B／C runtime count `0`;
- canonical native monotonic tick, preparation receipt identity, and performance slot launch count `0`.

The complete PREACK prerequisite record must include identity, OneDrive inventory, power API success／status／value,
input API success／`dwTime`, runtime／ownership, native ticks, receipt identity, and slot count. Append and flush／close,
read back, and hash that complete record before asserting any expected prerequisite value. The runner must capture
launcher result／exit／raw streams, validate mapped exit `0`, close its own structured result, and exit `0` before `30`
sends:

```text
MFO-WO-P2-2A-007 PREACK_READY stage_id=<stage-id> manifest_sha256=<64-hex> preack_sha256=<64-hex> preack_tick=<uint64>
```

The user replies by echoing every field exactly:

```text
MFO-WO-P2-2A-007 START_ACK stage_id=<stage-id> manifest_sha256=<64-hex> preack_sha256=<64-hex> preack_tick=<uint64>
```

Immediately afterward the user stops keyboard／mouse input until `30` announces that the window ended. A missing or
mismatched field, nonzero runner exit, missing record, timeout, or failed prerequisite prevents `PREACK_READY`. QA
reports the observed non-account prerequisite or harness result and does not repair the host automatically.

## 6. One live harness requalification

After exact `START_ACK`, execute one new-stage LIVE sequence using the `-006` ownership, clock, sentinel, cadence,
journal, timeout, cleanup, and exit-code contracts without weakening them:

1. immediately after exact `START_ACK`, the LIVE runner obtains and persists in the same read-back-verified receipt the
   exact activation fields, `runner_receipt_tick`, and authoritative successful `GetLastInputInfo` `UInt32 dwTime`
   quiet-window baseline. PREACK time and PREACK input are not the LIVE baseline;
2. runner owns launcher, launcher owns controller, and controller owns sentinel through the sealed job／process rules.
   Persist and prove `preack_tick < runner_receipt_tick <= launcher_receipt_tick <= controller_origin`, and set the
   600-second deadline to exactly `controller_origin + 600000` on the canonical native clock;
3. execute the deterministic sentinel READY／release handshake once and capture identity, raw streams, expected
   internal exit `23`, timeout, and cleanup;
4. after sentinel exit／cleanup, record `settle_origin`; persist sample `n=0` immediately, then samples `n=1..60` at
   target `settle_origin + n * 1000` ms. Require unique contiguous `n=0..60`, strictly increasing actual native ticks,
   each actual tick within `[target, target + 250]`, and final actual duration at least `60000 ms`;
5. every complete sample records native target／actual tick, the same corrected production power／input API
   success／status／value, OneDrive inventory count `0`, AC online,
   Best performance overlay, exact last-input equality to the LIVE baseline, owned process inventory, and no
   A／B／C／MFO／Godot or unexpected QA runtime. Append and flush／close and read back each complete sample before
   asserting any expected value;
6. every trigger record is therefore durable before a terminal assertion; controller, launcher, and runner each write a
   structured result and capture child exit／raw streams;
7. final cleanup, owned-runtime count `0`, identity audit, journal readback, hash chain, and performance slot count `0`
   are mandatory.

This sequence is not a performance run. Do not launch an exported game, record frames, calculate or interpret P95,
or infer gameplay performance from its timing.

## 7. Acceptance and terminal routing

Recommend **Pass** only when the corrected production path, all seal-before tests, PREACK, activation ordering, LIVE
61-sample sequence, sentinel, process ownership, streams, structured results, cleanup, final identities, journal, and
slot count `0` are all complete and valid.

| Observed outcome | Classification |
|---|---|
| All required mechanics and evidence complete; external state stable; slot count `0` | **Pass / harness qualified** |
| Harness API／ABI／clock／identity／ordering／journal／process／stream／timeout／cleanup mechanism fails or required harness evidence is missing | **Fail / harness defect** |
| Fresh durable evidence proves OneDrive／power／input or another non-QA host prerequisite changed or was unavailable | **Blocked / host prerequisite** |

The report must include supervisor start commit, QA HEAD, stage／manifest identities, exact invocations, source-diff
audit, smoke evidence, PREACK and activation tokens, all live records, exits／streams, final cleanup, changed-path
audit, and an evidence-root `SHA256SUMS.txt` covering every payload except itself. Preserve Pass, Fail, Blocked, and
Not run separately.

On any terminal result, freeze the new stage and evidence and return to `00統括`; do not retry automatically. The user
may restart OneDrive only after `30` announces the qualification window ended. Pass does not end
`MFO-HOLD-P2-2A-001`, authorize performance measurement, accept Slice 2-A, open Gate 2, or authorize Slice 2-B.

## 8. Supervisor closure — 2026-07-16

`00統括` accepts the final `30 QA` recommendation **Fail / harness defect** at QA commit
`dc6d82115f42132a6f7e6424ea77c8c2cc3ebaee`.

- stage: `p2-2a-007-qp-20260715t231258jst-2e92cc8-c1`;
- sealed manifest SHA-256: `e44acd54ba1b1f01e7628d9a3899242a43fa16164fa9c78bd4d355dff8314c67`;
- evidence `SHA256SUMS.txt` SHA-256:
  `465db27591c3cd26be0cd0594cb46bb214a016e27a4f0779f4e896153833205a`, independently verified `86 / 86`;
- terminal defects: missing preparation-receipt identity binding, stale `-006 START_ACK`, and expected-value
  assertions before complete PREACK record persistence／readback／hash;
- PREACK, LIVE, P95, KBM, and A／B／C launch were Not run; performance slot launch count remained `0`;
- the `85 / 85` ReadOnly stage and its evidence are frozen without repair, reseal, or retry.

This closure does not change product specification or establish a host／performance result. The explicit successor is
[`MFO-WO-P2-2A-008`](phase2-slice2a-harness-contract-correction-requalification.md), limited to the three contract
corrections, their seal-before tests, and one new-stage harness requalification. Performance acceptance remains under
`MFO-HOLD-P2-2A-001`.
