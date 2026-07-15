# Work Order — Phase 2 Slice 2-A QA Harness Qualification Only

- Work order ID: `MFO-WO-P2-2A-006`
- Issued by: `00統括（監督）`
- Issued: 2026-07-15 (Asia/Tokyo)
- Priority: **P1 / acceptance-evidence integrity blocker**
- Findings: [`KI-010`](../KNOWN_ISSUES.md), [`KI-012`](../KNOWN_ISSUES.md),
  [`KI-013`](../KNOWN_ISSUES.md)
- Owner: `30 QA・性能・レビュー`
- Required user role: temporary OneDrive closure and one quiet qualification window
- Gameplay owner: `10ゲームプレイ・コア実装` — no work in this order
- Presentation owner: `20ステージ・UI・グラフィック` — no integration work in this order
- Status: **Issued / active / qualification only**
- Milestone: M2 / Slice 2-A acceptance evidence
- Gate 2: **Locked / not evaluated**
- Basis: [`MFO-HOLD-P2-2A-001`](phase2-slice2a-performance-external-hold.md)
- Required starting state: the pushed supervisor commit containing this order; `30` records its exact SHA
- Required QA branch: `codex/phase2-slice2a-harness-qualification-qa`
- Required report: `docs/test-reports/phase2-slice2a-harness-qualification.md`
- Required evidence root: `docs/test-reports/evidence/phase2-slice2a/qualification-001/`

This is the explicit, non-automatic `-006` exception permitted by the user-reported host change and `00統括` review.
It qualifies evidence plumbing only. It authorizes **zero performance slots**, zero P95 interpretation, zero KBM
repetition, and zero game-code change. It changes no product requirement, Approved decision, threshold, gameplay
value, scene, renderer, quality setting, resolution, or prior evidence.

## 1. Supervisor disposition and host-change basis

`MFO-WO-P2-2A-005` remains **Blocked / valid matrix 0** and its stage and evidence remain frozen. The earlier valid
correction performance Fail also remains on record.

`00統括` accepts the following as a material host-condition change sufficient to consider this bounded qualification,
but not as performance acceptance evidence:

- the user reports that the OneDrive allocation is now `100 GB`, with `4.8 GB` shown in use, and the client-level
  status shows a green backup／sync indicator;
- a supervisor read-only traversal of both Documents roots, including OneDrive cloud-directory markers, visited
  `2,005` directories and found `0` actual directory junctions／symbolic links with `0` scan errors after generated
  dependency directories were moved without deletion to a non-OneDrive quarantine;
- after the user-authorized normal OneDrive shutdown request, the preliminary `OneDrive*` process inventory fell
  from `2` to `0`, and the local MFO repository remained present.

Residual red Explorer overlays are neither Pass nor Fail evidence. The qualification must establish its own fresh,
persisted process inventories. Account identifiers, email addresses, unrelated OneDrive paths, and unrelated files
remain out of scope.

The external-state hold remains active for performance acceptance. This order is its only execution exception.

## 2. Authorized tracked and host scope

`30` may commit changes only to:

- the required new qualification report;
- new evidence below the required `qualification-001/` root, including exact runner／launcher／controller／native-
  helper／sentinel source;
- `docs/handoffs/qa.md`.

`30` may create at most three candidate directories below `%LOCALAPPDATA%` or `%TEMP%`, outside every OneDrive
directory, while preparing the order. Exactly one sealed stage may be activated. A rejected pre-seal candidate is
marked `ABANDONED_PRESEAL`, is never reused or activated, and is retained without deletion until this order closes.
The activated stage may contain read-only A／B／C copies, one sealed outer runner, one sealed launcher, one
controller, one precompiled native-API helper, and one deterministic sentinel helper.

The following are read-only or forbidden:

- all game code, game tests, recorder, scenes, `project.godot`, export presets, InputMap, game values, and builds;
- all existing QA reports and evidence, especially the consumed `-005` stage;
- performance executable launch, arena launch, frame sampling, P95 calculation／interpretation, and KBM;
- Git or repository I/O during the live qualification window;
- `main`, Gate 2, Slice 2-B, presentation integration, network, account, and persistent-data work;
- killing non-QA processes, changing startup settings, signing out accounts, deleting user／repository／pre-existing
  files, or inspecting account identity. On native-tick timeout only, the sealed runner may terminate the exact
  launcher and verified descendants it launched, and the sealed launcher may terminate its exact controller／
  sentinel children. Every target is matched by PID／creation time／image path and every timeout, termination, exit,
  descendant, and cleanup result is recorded. Such a timeout is never Pass.

Direct push to `main` is prohibited. Executables and export packs must not be committed or pushed.

## 3. Immutable staged identities

Use a new stage ID and do not reuse, repair, clear, or append to
`p2-2a-005-20260715t0944jst-b32fdae`.

| Label | Source | Required EXE SHA-256 |
|---|---|---|
| A | Gate 1 baseline `a13505e8fbf82962e049b9101a87593a6692d2c7` | `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` |
| B | pre-correction `295549373fbb3b39deb6079172783ce62c7da532` | `3c15c254fbb8025d88c5636f2175a35f6e325b5368c8098e78b16181090dd4ef` |
| C | corrected `5261a73707daca03cb160e03a12247886d3f5cce` | `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47` |

A／B／C are staged and fully hashed only to qualify identity and pre-ack evidence. **They must not be launched.**

## 4. Stage QP — preparation and sealed self-tests

Preparation occurs before the user activation message and may be repaired only before sealing.

1. Create a new non-OneDrive candidate stage, stage A／B／C, and record full SHA-256, byte size, `MZ`, last-write time,
   source commit, source path, and staged path.
2. Implement one outer runner／watchdog, one launcher／orchestrator, one qualification controller, one precompiled
   native-API helper, and one deterministic sentinel helper. Seal each exact source／binary, invocation template,
   output path, native-tick timeout, process ownership rule, and evidence schema. Only the concrete stage／manifest／
   pre-ack／activation values named by the sealed template may vary. The runner owns launcher identity, job／child
   containment, raw streams, exit, outer timeout and final closure. The launcher owns controller start, raw streams,
   exit, inner timeout, post-controller inventory and rehash.
3. The precompiled helper must expose native Windows `GetTickCount64`, `GetSystemPowerStatus`,
   `PowerGetEffectiveOverlayScheme`, and `GetLastInputInfo`. The power requirement is the effective overlay GUID
   `ded574b5-45a0-4f42-8737-46345c09c238`, not the base plan returned by `PowerGetActiveScheme`. Persist the
   `GetLastInputInfo` `dwTime` as `UInt32` and compare exact equality to the authoritative LIVE runner-receipt
   baseline; persist API success／failure before evaluation. The helper is built and hashed before sealing and must
   not compile or spawn `powercfg.exe` during pre-ack or live qualification. Loading the sealed helper and binding its
   functions is the only initialization allowed before the controller records its live origin.
4. Use native `GetTickCount64` as the sole monotonic source for origin, current tick, cadence, sentinel／controller
   timeout, the `600,000 ms` deadline, and expiry comparisons. `[Environment]::TickCount64`, `Stopwatch`, wall-clock
   time, `WaitForExit(timeout)`, and chat time must not influence qualification outcome.
5. The production path must record a nonzero origin, at least two advancing native samples, and
   `deadline = origin + 600000`. Audit every comparison site. Run a sealed short synthetic expiry self-test through
   the exact same deadline-comparison and persist-before-assert function, injecting `now = deadline`; prove the
   expiry record survives before the expected terminal result. The live path never accepts an injected clock.
6. Implement one append-and-flush evidence journal. Each process inventory and prerequisite record is written,
   flushed, closed or durably committed, and read back before the corresponding assertion can terminate execution.
7. Run a sealed synthetic inventory-negative self-test through the same persist-then-assert function used by the live
   path. Inject only fixture process name `OneDrive.exe` and PID `4242`; prove the triggering record survives before
   the expected terminal result. Do not start a real OneDrive process for this test.
8. Give the sentinel a deterministic `READY`／release handshake. After start it emits
   `MFO-QA-SENTINEL-READY` and waits. While it is alive, the owner captures PID／creation time／image path, then sends
   the sealed release signal. The sentinel emits `MFO-QA-SENTINEL-STDOUT` to stdout and
   `MFO-QA-SENTINEL-STDERR` to stderr and exits `23`. Capture unmodified raw streams, identity, native-tick timeout,
   exit, and cleanup. Use the identical invocation and handshake in the self-test and live qualification.
9. Prove the dry-run and all self-tests launch no A／B／C, MFO, Godot, arena, or performance slot. Record slot-launch
   count `0` and final owned-runtime count `0`.
10. The final manifest contains the A／B／C／runner／launcher／controller／native-helper／sentinel hashes, exact
    invocations, evidence paths, expected live sequence, and self-test results. It does not contain its own digest.
    Compute the final manifest SHA-256 once and store that digest only in a separate sealed preparation receipt and
    later handshake／report fields.
11. Seal one shared result contract for runner, launcher, and controller: exit `0` = completed Pass path, `20` =
    persisted external-prerequisite Blocked, `30` = harness Fail, and `31` = timeout／cleanup Fail. Each process writes
    and flushes its structured result before exit. A missing result, unknown code, or code／record disagreement is
    Fail. Sentinel exit `23` remains its expected internal test result and is not an overall classification.

After sealing, any runner, launcher, controller, helper, invocation, schema, or staged identity change invalidates
that stage.
Before user activation, `30` may mark it `ABANDONED_PRESEAL` and prepare another candidate within the three-candidate
limit; “discard” never means delete or reuse. After live activation begins, no repair or retry is authorized.

## 5. PREPARED handoff and activation

After Stage QP is sealed, `30` sends exactly:

```text
MFO-WO-P2-2A-006 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex>
```

The user saves unrelated work, leaves OneDrive closed, keeps AC connected, stops heavy work, and sends:

```text
MFO-WO-P2-2A-006 stage_id=<stage-id> manifest_sha256=<64-hex> QUALIFICATION WINDOW READY
```

The sealed runner starts the sealed launcher once in `PREACK` mode without starting the controller. The runner owns
and captures the launcher identity, raw streams, exit and native-tick timeout. The launcher freshly recomputes and
persists:

- exact activation stage ID, supplied manifest digest, recomputed manifest digest, and sealed invocation;
- full A／B／C／runner／launcher／controller／native-helper／sentinel hashes and file identities;
- AC online and Best performance GUID `ded574b5-45a0-4f42-8737-46345c09c238`;
- owned-child count `0` excluding the active sealed PREACK runner／launcher, and MFO／Godot runtime count `0`;
- case-insensitive `OneDrive*` inventory with count `0`;
- successful `GetLastInputInfo` and its informational PREACK `UInt32 dwTime`; this is not the quiet-window baseline
  because the required user `START_ACK` occurs afterward;
- one nonzero native `GetTickCount64` pre-ack tick.

The complete pre-ack record must be flushed, closed, read back, and SHA-256 hashed. The PREACK runner must capture the
launcher result／exit／raw streams, verify mapped exit `0`, write and read back its own PREACK closure, then exit `0`.
Any missing record, timeout, code mismatch, or nonzero runner exit prevents `PREACK_READY`; classify it by the shared
result contract. Only after both records pass may `30` send exactly:

```text
MFO-WO-P2-2A-006 PREACK_READY stage_id=<stage-id> manifest_sha256=<64-hex> preack_sha256=<64-hex> preack_tick=<uint64>
```

The user copies those exact four values and sends:

```text
MFO-WO-P2-2A-006 START_ACK stage_id=<stage-id> manifest_sha256=<64-hex> preack_sha256=<64-hex> preack_tick=<uint64>
```

Immediately after sending `START_ACK`, the user stops keyboard／mouse input and leaves the machine untouched until
`30` announces the window has ended. The subsequent LIVE runner receipt, not PREACK, establishes the equality
baseline.

Only after receiving that exact echo may `30` save it verbatim as the activation token, hash it, and invoke the sealed
runner in `LIVE` mode. The runner validates every echoed field, obtains and persists the authoritative quiet-window
`GetLastInputInfo` UInt32 baseline plus its native tick and the activation-token hash in the runner receipt, then
starts and owns the sealed launcher. The launcher revalidates the fields, persists its own
receipt, then starts the controller. Require
`preack_tick < runner_receipt_tick <= launcher_receipt_tick <= controller_origin`. These four durable records are the
ordering evidence; wall-clock and chat timestamps are descriptive only. No additional “measurement starting”
message is an ordering substitute.

If a prerequisite fails, no `PREACK_READY` is sent and no live runner／launcher／controller starts. Report only the observed
non-account process names／PIDs or other failed prerequisite to `00`; do not repair the host automatically.

## 6. One live qualification sequence

Invoke the sealed runner once in `LIVE` mode. It remains alive as the launcher's watchdog and outer evidence
collector; the launcher remains alive as the controller's owner. The allowed QA process set is runner + launcher +
controller, plus the sentinel only during its bounded handshake.

1. The runner validates the activation token and component identities, persists the runner receipt, starts the exact
   launcher with redirected raw stdout／stderr, captures its PID／creation time／image path, and places the launcher／
   descendants under sealed ownership containment. The launcher revalidates stage／manifest／pre-ack identity,
   persists its receipt, then starts the exact controller with redirected raw streams and captured identity.
2. After loading and binding the already sealed native helper, the controller's first sampled action records a
   nonzero native origin, requires the ordering relation above, and records `deadline = origin + 600000`. Sealed API
   initialization is allowed before this origin; compilation, external power-query processes, and prerequisite
   evaluation are not.
3. Run the deterministic sentinel READY／release handshake once. Capture its identity while alive, exact stdout／
   stderr tokens, exit `23`, native-tick timeout, and cleanup. It is not a performance slot.
4. Immediately after the sentinel exits, record `settle_origin = GetTickCount64()` and one durable baseline
   prerequisite sample `n=0`, then exactly 60 scheduled samples `n=1..60` at target tick
   `settle_origin + n*1000`, for exactly 61 records. Each record contains target tick, actual native tick, lateness,
   `OneDrive*` names／PIDs and count, in-process AC／effective overlay, `GetLastInputInfo` success and UInt32 `dwTime`,
   and owned process inventory.
5. Each sample is persisted and read back before evaluation. Sample numbers are unique and contiguous, actual ticks
   strictly increase, every scheduled `n=1..60` tick is within `[target_tick, target_tick + 250]`, and the final actual
   tick minus `settle_origin` is at least `60,000 ms`. A missing, duplicate, out-of-order, late, or unreadable
   controller sample is **Fail / harness defect** unless the same durable sample records a qualifying external
   prerequisite change.
6. Every sample requires OneDrive count `0`, successful `GetLastInputInfo` with exact UInt32 equality to the LIVE
   runner-receipt baseline, AC online／Best performance effective overlay, and no A／B／C／MFO／Godot or unexpected QA-owned process.
   After sentinel exit, only the sealed runner, launcher, and controller are allowed.
7. A recorded OneDrive reappearance, power change, input change, or non-QA external host condition is **Blocked**.
   Its triggering record must remain readable after controller exit. Journal／API／serialization／ordering failure
   after a valid pre-ack is **Fail**, not Blocked.
8. The launcher uses native ticks for a sealed controller timeout no greater than `180,000 ms`. It captures controller
   exit code and raw stdout／stderr. On timeout it may terminate only that exact owned controller and any exact owned
   sentinel still alive, matched by sealed identity, records every cleanup action, and returns Fail.
9. After controller exit, the launcher records its post-controller inventory, requires owned controller／sentinel
   count `0`, rehashes the sealed children and manifest, writes and flushes its result, then exits with the mapped
   code.
10. The runner uses native ticks for a sealed launcher timeout no greater than `240,000 ms`, captures launcher raw
    streams／exit, and may terminate only the exact launcher and verified descendants on timeout. After launcher exit,
    the runner requires owned-descendant count `0`, records the final host inventory, rehashes A／B／C／runner／launcher／
    controller／native-helper／sentinel and manifest, writes and reads back its final closure, then exits with the
    mapped code. The tool-level numeric runner exit is recorded and must match this durable closure; it is descriptive
    transport evidence, not an unsealed additional observer or raw-stream requirement.

No system-CPU acceptance threshold is applied, no frame recorder runs, and no P95 is produced or interpreted.
Performance slot launch count must be exactly `0`.

## 7. Qualification disposition

Return exactly one recommendation:

| Evidence pattern | Recommendation |
|---|---|
| Every Stage QP and live requirement passes; slot count `0`; final identities match | **Pass / harness qualified** |
| After valid pre-ack, runner／launcher／controller／journal／clock／API／cadence／stream／identity／timeout mechanism fails or required evidence is missing | **Fail / harness defect** |
| Before launch a prerequisite is unavailable, or a durable live record proves OneDrive／input／power／other non-QA host state changed | **Blocked / host prerequisite** |

Partial evidence is never converted to Pass. A Pass qualifies only the evidenced harness mechanics; it does not
validate a future performance matrix, withdraw the prior performance Fail, or accept Slice 2-A.
When categories appear to overlap, persisted external-state evidence is required for Blocked; otherwise a missing or
failed harness record after valid pre-ack is Fail. Neither category can become Pass.

## 8. Report and evidence closure

The report must include:

- supervisor starting commit and QA branch／HEAD;
- stage ID, manifest digest, exact runner／launcher／controller／native-helper／sentinel invocations and hashes;
- pre-ack file hash／native tick, exact `PREACK_READY`／`START_ACK` fields, activation-token hash, runner／launcher
  receipts and controller-origin ordering proof;
- synthetic inventory／expiry self-tests and sentinel READY／release raw streams／identity／exit evidence;
- native monotonic origin, deadline, advancing samples, and source-use audit;
- every live inventory, controller／launcher result records and exits／streams, runner closure／exit, slot count `0`,
  final identity audit, and changed-path audit;
- explicit confirmation that no executable, export pack, account identifier, or unrelated file was committed;
- final `Pass / Fail / Blocked` recommendation.

Within the required evidence root, create `SHA256SUMS.txt` covering every evidence payload file except
`SHA256SUMS.txt` itself. Record the resulting manifest digest in the report; the report and QA handoff are covered by
the final Git commit rather than recursively by that evidence manifest. `30` may update its QA handoff once on
receipt／PREPARED to identify `-006` as active without claiming a result, and again after report／evidence closure. The
handoff must preserve the supervisor interpretation that the prior auxiliary TickCount64 `0` was not an independent
blocker. Push only the required QA branch; do not merge or push `main`.

## 9. Routing and terminal rule

After `30` returns its recommendation, the order closes and control returns to `00統括`.

- On Pass, `00` may consider a separate, explicit performance-measurement order. No `-007` is automatic.
- On Fail, do not modify game code. Return the harness defect and exact failed requirement to `00`.
- On Blocked, do not retry, restart OneDrive, alter startup settings, or create a new stage without a new supervisor
  order.

The user may restart OneDrive only after `30` announces that the qualification window has ended. Gate 2 and Slice 2-B
remain locked in every outcome.
