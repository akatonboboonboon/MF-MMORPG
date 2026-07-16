# Work Order — Phase 2 Slice 2-A Qualified-Harness Performance Acceptance

- Work order ID: `MFO-WO-P2-2A-010`
- Issued by: `00統括（監督）`
- Issued: 2026-07-16 (Asia/Tokyo)
- Priority: **P1 / final unresolved Slice 2-A acceptance component**
- Finding: [`KI-010`](../KNOWN_ISSUES.md) / `MFO-P2-2A-QA-002`
- Owner: `30 QA・性能・レビュー`
- Required user role: temporary OneDrive closure, AC connection, and one quiet performance window
- Gameplay owner: `10ゲームプレイ・コア実装` — no work in this order
- Presentation owner: `20ステージ・UI・グラフィック` — no integration work in this order
- Status: **Issued / active / performance acceptance only**
- Milestone: M2 / Slice 2-A acceptance
- Gate 2: **Locked / not evaluated**
- Basis: [`MFO-HOLD-P2-2A-001`](phase2-slice2a-performance-external-hold.md) and accepted
  [`MFO-WO-P2-2A-009`](phase2-slice2a-harness-live-evidence-correction-requalification.md)
- Required starting state: the pushed supervisor commit containing this order; `30` records its exact SHA
- Required QA branch: `codex/phase2-slice2a-performance-acceptance-qa`
- Required report: `docs/test-reports/phase2-slice2a-performance-acceptance.md`
- Required evidence root: `docs/test-reports/evidence/phase2-slice2a/diagnostic-004/`

This is the sole execution exception to the active performance hold. It authorizes preparation of one fresh qualified
performance stage and one fixed performance matrix. It changes no product requirement, Approved decision, gameplay
value, test threshold, recorder, scene, project setting, renderer, resolution, or quality setting.

## 1. Supervisor decision and immutable boundary

The user reported that an AC-connected time window is currently available. This is not yet the quiet-window
activation; preparation occurs first while normal input and OneDrive may continue.

`MFO-WO-P2-2A-009` qualified the native clock, power／input API path, exact raw-byte activation, complete
persist→readback→hash→separate-evaluation flow, journal hash chain, trigger-before-terminal persistence, process
ownership, exits／streams, sentinel cleanup order, and per-sample slot evidence. Its final native source SHA-256 is
`46b5bead5bae9c0a049a7c3acc4e9693aab52138546482f4546dad1fb616631d`.

The `-009` stage and all prior stages／evidence remain immutable. No old stage, PREACK, activation, runtime evidence,
or result may be repaired, appended, cleared, or reused. This order does not authorize:

- game code, gameplay values, profiling seams, gameplay tests, recorder, scene, `project.godot`, InputMap, export
  preset, quality, threshold, or executable changes;
- KBM repetition, physical-gamepad substitution, Slice 2-B, Gate 2, integration, production assets, music／voice,
  network／server, account, or persistent-data work;
- direct push to `main` or modification of an earlier report／evidence root;
- automatic retry, a second valid matrix, or a post-PREPARED repair／reseal.

## 2. Authorized tracked scope

`30` may commit only:

- the required new report;
- new non-executable evidence below `diagnostic-004/`;
- `docs/handoffs/qa.md`.

A／B／C executables, compiled harness payloads, export packs, credentials, account identifiers, unrestricted
environment dumps, and unrelated files must not be committed. Timed output stays outside OneDrive until the controller
has ended.

## 3. Fresh Stage P and seal-before qualification

Create a fresh stage below `%LOCALAPPDATA%` or `%TEMP%`, outside every OneDrive directory. Start from the exact
qualified `-009` native source. Authorized source changes are limited to:

1. mechanical `-010` work-order identity, fresh stage／run paths, manifest, receipt, preparation-audit, and exact
   activation literals;
2. the fixed A／B／C slot table, performance-only evidence schema, inherited 61-sample settled interval, CPU
   preflight, foreground acquisition, and sealed A／B／C launch／output validation;
3. cumulative `performance_slot_attempt_count`／`performance_slot_launch_count`／`abc_launch_count` semantics,
   bounded performance cleanup, and the narrow ownership allowance for only the current sealed slot's
   PID／creation-time／image-path tuple and its owned children;
4. production-bound performance contract fixtures that launch no real A／B／C process.

Keep the qualified clock, power／input, raw-byte validator, persistence／readback／hash／evaluation, journal chain,
sentinel cleanup, ownership／identity mechanism, trigger persistence, exit／stream capture, and residual-runtime
mechanism unchanged. Apart from the performance phases and narrow current-slot allowance listed above, do not alter
their semantics. Produce a source-diff audit enumerating every authorized hunk and proving all unrelated regions
byte-identical to the `-009` source.

Immutable executable set:

| Label | Source | Required EXE bytes | Required EXE SHA-256 |
|---|---|---:|---|
| A | Gate 1 baseline `a13505e8fbf82962e049b9101a87593a6692d2c7` | `109075560` | `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` |
| B | pre-correction `295549373fbb3b39deb6079172783ce62c7da532` | `109095104` | `3c15c254fbb8025d88c5636f2175a35f6e325b5368c8098e78b16181090dd4ef` |
| C | corrected `5261a73707daca03cb160e03a12247886d3f5cce` | `109095120` | `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47` |

Record byte size, `MZ`, full SHA-256, source commit／path, staged path, and last-write time. Seal exact arguments,
working directories, arena flags, `120` warmup frames, `600` samples, GL Compatibility, standard quality,
`1920×1080` project window, outputs, timeout, and order `A1 → B1 → C1 → C2 → B2 → A2`.

Before seal, all six modes must Pass and launch real performance slots `0`:

1. `QP_DRYRUN`;
2. `QP_SELFTEST`;
3. `QP_POWER_INPUT_SMOKE`;
4. `QP_PREACK_CONTRACT_SELFTEST`;
5. `QP_LIVE_EVIDENCE_CONTRACT_SELFTEST`;
6. `PA_PERFORMANCE_CONTRACT_SELFTEST`.

The sixth mode must fixture cumulative slot counts `0…6`, fixed ordering, deadline reservation, host-trigger
persistence, slot-local `try/finally`, exact-owned cleanup, complete runner／launcher／controller results, and raw
stdout／stderr without launching A／B／C. A pre-PREPARED failure may be repaired only within the four authorized source
categories; preserve the failed candidate history and create a new candidate. After PREPARED, no repair is allowed.

Before sealing, `30` must be the sole owner of host-side execution for this order and record residual QA subagents,
background harness processes, and attached terminal sessions as `0`. This prevents a returned-stage writer or polling
session from changing evidence during the quiet window.

Create and hash a complete manifest, preparation receipt, and preparation audit, then make the final stage ReadOnly.
Confirm external run root absent, owned runtime `0`, performance slot `0`, and A／B／C launch `0`. Commit only the
non-executable PREPARED evidence and send:

```text
MFO-WO-P2-2A-010 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex>
```

## 4. User window, PREACK, and exact activation

After PREPARED, `00統括` asks the user to save unrelated work, manually quit every visible OneDrive client for every
account, stop heavy apps／downloads／media／exports, keep AC connected, select Best performance, and prepare to leave
the machine untouched. QA does not kill OneDrive, inspect accounts, move the repository, delete files, or change power
settings.

When the user confirms readiness, `00統括` sends exact:

```text
MFO-WO-P2-2A-010 stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex> PERFORMANCE WINDOW READY
```

QA recomputes all identities and runs one fresh PREACK only. Before evaluation, persist, read back, and hash the
complete prerequisite record: supplied identities, OneDrive-family count `0`, AC online, effective Best-performance
GUID `ded574b5-45a0-4f42-8737-46345c09c238`, input API success, owned runtime `0`, forbidden runtime `0`, slot count
`0`, exact runner／launcher exits and raw streams. Both evaluations must separately record readback and field
completeness success. On Pass, QA sends:

```text
MFO-WO-P2-2A-010 PREACK_READY stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex> preack_sha256=<64-hex> preack_evaluation_sha256=<64-hex> preack_tick=<uint64>
```

The user sends the exact corresponding `START_ACK` as one plain message with no extra byte, then stops all
keyboard／mouse input until completion:

```text
MFO-WO-P2-2A-010 START_ACK stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex> preack_sha256=<64-hex> preack_evaluation_sha256=<64-hex> preack_tick=<uint64>
```

A direct plain user message in the QA thread is valid authority; visibility in the supervisor thread is not a
prerequisite. QA must persist its source turn／time and exact raw bytes before creating the activation file. Reject BOM,
CR, LF, trimming, normalization, missing, stale, or extra content. Missing, stale, or non-exact user bytes are
**Blocked / invalid user activation acknowledgement** and start no performance process; they are not a harness Fail.
A defect in the raw-byte validator or activation persistence／evaluation mechanism is **Fail / harness defect**.
Capture the acceptance input baseline after exact activation persistence and require it unchanged thereafter.

## 5. One timed qualified performance run

Use the qualified native system-wide monotonic clock. After activation, prove
`preack_tick < runner_receipt_tick <= launcher_receipt_tick <= controller_origin` and set the only global deadline to
exactly `controller_origin + 600000 ms`. Run the owned sentinel and persist `owned_child_exit` then
`sentinel_complete` before recording the settle origin. The settle origin does not reset or extend the deadline.

`performance_slot_attempt_count`, `performance_slot_launch_count`, and `abc_launch_count` are cumulative and start at
`0`. Persist `slot_launch_intent` and increment the attempt count immediately before each sealed A／B／C `Process.Start`.
Only after `Process.Start` returns a PID may the two launch counts increment exactly once. Never decrement or reuse an
ordinal. Every settle, preflight, idle, slot, terminal, and cleanup sample records phase, planned slot／ordinal, and all
three counts. A complete matrix finishes at exact attempt／launch／A-B-C counts `6 / 6 / 6`; any divergence is terminal.

1. Run the inherited settled interval as exactly `61` durable samples `n=0..60`. Record `n=0` only after sentinel
   completion, then target `settle_origin + n * 1000 ms`; require contiguous unique sequence, strictly increasing
   actual ticks, every actual tick in `[target, target + 250]`, and final duration `>= 60000 ms`. Persist, read back,
   hash, and evaluate each complete sample. Every sample requires OneDrive-family count `0`, AC online, Best
   performance, unchanged post-activation input tick, forbidden runtime `0`, owned identity valid, and all counts `0`.
2. Run a `15`-interval 1 Hz CPU preflight using raw `GetSystemTimes` counters. Require aggregate average `<= 20%` and
   every interval `<= 40%` on unrounded values.
3. If and only if CPU fails while every other prerequisite remains valid, wait exactly `15 seconds` and repeat the
   complete CPU preflight, at most three attempts total. Preserve all attempts. Any other failure is terminal.
4. Before each remaining slot's required pre-idle begins, require at least
   `remaining_slots * 60 s + required_remaining_idles * 5 s + 30 s` before the global deadline. Required idles include
   the pre-A1 idle or each remaining inter-slot idle, so A1 requires at least `420 seconds`. Do not begin any slot whose
   full remaining budget is unavailable.
5. Run exactly once: `A1 → B1 → C1 → C2 → B2 → A2`. Use `5,000 ms` before A1 and between slots. Each slot is a fresh
   process with a `60-second` launch-to-exit budget and at most `5 seconds` exact-owned safety cleanup that cannot
   rescue a failed slot.
6. The game must become foreground during warmup and no later than `1,000 ms` after the timestamped startup line,
   using only the sealed `SetForegroundWindow` path and never `SendInput`.
7. Maintain 1 Hz host／input／power／identity／foreground monitoring through A2. During idle, MFO／Godot count is `0`.
   At each slot launch record PID, creation time, and exact image path; only that tuple and its owned children are
   allowed.
8. Save raw system／game counters and wall intervals. Compute:

```text
game_process_pct = 100 × delta_game_cpu_seconds / (delta_wall_seconds × logical_processor_count)
background_pct = clamp(system_total_pct - game_process_pct, 0%, 100%)
```

Every idle and slot segment requires background weighted average `<= 20%`, no sample above `40%`, and
OneDrive-family delta `0` because count remains `0`. Persist a trigger sample before any terminal assertion.

For every slot preserve the unchanged recorder command, exit, raw stdout／stderr, and JSON containing exactly the
post-warmup `600` frame samples. The authoritative acceptance value is the unchanged recorder's unrounded JSON
`frame_time_ms.p95` field; FPS and rounded HUD text are not substitutes. Any independent percentile recomputation is
audit-only and must use the existing recorder algorithm without changing the recorded result. Record the HUD
`FRAME P95 (600)` value and require its two-decimal display to agree with the JSON field at displayed precision.
A missing, malformed, differently sized, or HUD-inconsistent recorder result makes that slot invalid.

Repository I/O, Git, chat, screenshots, GUI control, recompilation, hashing full executables, or changing sealed
arguments is forbidden during the timed run. Outputs remain in the external stage until controller exit.

## 6. Classification

Only a complete six-slot valid matrix receives a performance recommendation:

| Evidence pattern | Recommendation |
|---|---|
| A and C each have two P95 values `<= 16.67 ms` | **Pass**; B is attribution-only |
| A has any valid threshold failure | **Blocked / control not reproduced** |
| A passes twice, B passes twice, and C exceeds twice | **Fail / correction-delta correlation** |
| A passes twice, and B／C each exceed twice | **Fail / failure present before correction; magnitude un-attributed** |
| A passes twice, but C has any other valid threshold failure | **Fail / current candidate does not meet acceptance; causality unisolated** |

Any C P95 above `16.67 ms` prevents Pass. Invalid or partial matrices are **Blocked**, never converted to Pass or Fail.
Missing／stale／non-exact user START_ACK is **Blocked / invalid user activation acknowledgement**. OneDrive／power／input／
CPU／foreground／timeout host invalidity is **Blocked / host prerequisite**. A sealed executable byte／path／tuple
identity mismatch is **Blocked / integrity prerequisite**, and its P95 is uninterpreted. A defect in the identity
capture／evaluator／persistence mechanism, raw-byte activation mechanism, ordering, readback, completeness, clock,
journal, slot-count, ownership, streams, or cleanup is **Fail / harness defect**. Stop immediately, preserve current
bytes, and do not retry.

The accepted `-004` KBM Pass remains frozen and is not rerun. Physical gamepad remains Not run / Deferred.

## 7. Post-run evidence and routing

After controller exit, QA tells the user that keyboard／mouse input may resume, but asks the user to keep OneDrive
closed until evidence fixation ends. Require final OneDrive count `0` and owned runtime `0`, then full-hash staged
A／B／C, controller, and manifest. Any identity change makes the matrix Blocked and its P95 uninterpreted.

Preserve preparation, PREACK, activation, controller／launcher／runner results, journals and hash chain, all raw samples,
slot JSON／stdout／stderr／capture, exits, cleanup, final identities, commands, and changed-path audit. Copy only compact
non-executable evidence into `diagnostic-004/`, verify source／destination hashes, and create `SHA256SUMS.txt` covering
every payload except itself. Freeze the external stage and committed evidence.

Return exactly one formal recommendation: `Pass`, `Fail`, or `Blocked`, with performance and harness classifications
kept separate. QA does not accept Slice 2-A, close the hold, open Gate 2, authorize Slice 2-B, or edit game code.
No automatic follow-on is authorized; `00統括` reviews the result.
