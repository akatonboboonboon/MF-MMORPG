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
- Status: **Active / pre-PREPARED Recovery Step R4F authorized / performance not started**
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
`frame_ms.p95` field; FPS and rounded HUD text are not substitutes. The `frame_time_ms.p95` spelling in the initially
issued order was a reference-name error only. The frozen recorder, percentile algorithm, threshold `<= 16.67 ms`,
executable bytes, and sealed arguments remain unchanged. Any independent percentile recomputation is audit-only.

The HUD value is not a JSON or stdout field. After controller exit, QA must visually read `FRAME P95 (600)` from the
recorder-generated PNG named by that slot's JSON `capture_path`, then compare it with the same slot's `frame_ms.p95`
formatted to two decimals. The recorder-generated `--phase1-capture` output is required slot evidence and is not the
external screenshot/GUI action prohibited during the timed run. The stdout report JSON duplicate is corroboration
only. Durable evaluation records the capture hash, exact observed HUD text, expected two-decimal display, and visual
inspection result. OCR, external screenshot, recorder change, or retry is not authorized. A missing/unreadable PNG,
malformed/differently sized JSON, or HUD/JSON display mismatch makes that slot invalid.

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

## 8. Supervisor addendum — pre-PREPARED Blocked and Recovery Step R1

`30 QA` returned the first `-010` preparation attempt as **pre-PREPARED Blocked**. This is not a harness Pass／Fail
and is not a performance result. Stage materialization, seal, PREACK, performance slots, A／B／C, game launch, P95,
and the external run root were never started; all launch counters remain `0` and relevant processes are `0`.
At return time, the repository was clean at `eda2ac8de05d87b995e7befb8b7ecf9a85170817`.

Preserve these preparation identities without modification:

| Artifact | SHA-256 | State |
|---|---|---|
| candidate-003 failed `source/MfoQaNative.cs` | `04d5805fe7d6b9e2f821ff88d3727da703e5559e7ff3ed5c88a9ced81a054559` | frozen; fresh compile reproduced `CS1513` at line 1458, exit `1` |
| candidate-004 `source/MfoQaNative.cs` | `2c42bc984eee3c29dcda50897b6431864649e2f638ba6e74f9379ff0d7b6681f` | frozen; last valid syntax compile exit `0` |
| candidate-004 `source/MfoQaRunner.cs` | `0bba8f49748d016c17d6fe1c17aa442f31da3572248116c08c32f98558aeccce` | frozen |
| candidate-004 `preparation-tools/StagePreparer.cs` | `5c0abfdda4e05deb6d5352e0e4ab3efe2e1f840caad098a0216943aca4396d903` | frozen |
| candidate-004 `preparation-tools/RunPreparation.ps1` | `507a319486c89d02d85e04ef50c9e0ee28c2e9a657fe54bf83f3e87e5c5669b9` | frozen |
| candidate-004 `preparation-tools/RecordRepositoryState.ps1` | `149c7c5736fb6bde818594800b29dbd4785c17320b60afa6a778ea0b49783097` | frozen |
| stopped scratch `source/MfoQaNative.cs` | `49d1a815342e02ae03759ef0bd409880c037ff65de865bf3a8d1ebb60e131d84` | unqualified; compile invocation used the wrong entrypoint and produced no EXE |

The sole authorized recovery is **Recovery Step R1 / syntax compile only**:

1. Keep candidate-003, candidate-004, and the stopped scratch byte-identical.
2. Copy candidate-004 to a fresh candidate-005.
3. Replace only candidate-005 `source/MfoQaNative.cs` with the stopped scratch native bytes and require exact SHA-256
   `49d1a815342e02ae03759ef0bd409880c037ff65de865bf3a8d1ebb60e131d84`. Every other candidate-005 file must remain
   byte-identical to candidate-004. If this exact one-file promotion is not possible, stop as Blocked.
4. In a separate non-stage compile-check directory, compile only the native library and wrapper executable with the
   same identified compiler. The executable entrypoint is the existing global wrapper `MfoQaRunner`; do not use
   `MfoQa.RunnerRole` or otherwise change namespaces／source.
   Required command shapes (replace only the input／output paths):
   ```text
   csc /nologo /target:library /optimize+ /out:<check>/MfoQaNative.dll /reference:System.Web.Extensions.dll <candidate-005>/source/MfoQaNative.cs
   csc /nologo /target:exe /platform:x64 /optimize+ /main:MfoQaRunner /out:<check>/MfoQaRunner.exe /reference:<check>/MfoQaNative.dll <candidate-005>/source/MfoQaRunner.cs
   ```
5. Do not launch the generated executable. Return the compile evidence and stop.

Required R1 evidence: candidate-004／scratch／candidate-005 size and SHA-256 inventory; changed-path and hunk audit;
target-file diff hash; all non-target files byte-identical; exact compiler path／size／SHA-256; exact commands, exits,
stdout／stderr, and output DLL／EXE identities; old-candidate before／after identities; repository HEAD／clean state;
stage and external run root absent; subagent, attached terminal, compiler, MfoQa, Godot／Material process count `0`;
and slot-attempt, slot-launch, and A／B／C launch counts `0`.

R1 exit `0` for both compile commands is **R1 Pass / syntax compile only**; `-010` remains pre-PREPARED Blocked and
must stop for supervisor review. A source compile failure is **R1 Fail / candidate source compile defect** and must be
preserved without repair. Compiler unavailability, identity mismatch, or non-exact promotion is **R1 Blocked**.

R1 does not authorize StagePreparer execution／compile, six-mode tests, source-diff qualification, stage materialization,
seal, PREACK, performance slots, A／B／C, game launch, repository edits, commits, or pushes. No candidate-006 or automatic
repair is authorized.

## 9. Supervisor addendum — R1 Fail and Recovery Step R2

The exact R1 promotion completed, but the native-library compile returned exit `1`:

```text
MfoQaNative.cs(3832,70): error CS0103: name 'RunPerformanceContractSelfTest' does not exist in the current context
```

The wrapper compile also returned exit `1` only because the native DLL was absent; it is not an independent wrapper
diagnosis. No DLL or EXE was produced or launched. Candidate-005 contains the exact promoted native SHA-256
`49d1a815342e02ae03759ef0bd409880c037ff65de865bf3a8d1ebb60e131d84`; its other seven files are byte-identical
to candidate-004. The R1 result is accepted as **R1 Fail / candidate source compile defect**.

This is still neither a harness qualification result nor a performance result. Candidate-003, candidate-004, the stopped
scratch, candidate-005, and all R1 compile-check evidence are frozen. Stage materialization, seal, PREACK, performance,
A／B／C, and game launch remain unstarted; slot-attempt, slot-launch, and A／B／C launch counts remain `0`.
Commit `1c7c72a86a90d8a41d45ea7675de03854d352521` is the supervisor R1 authorization already present on the QA
branch; QA's statement that R1 made zero repository edits is consistent with that history.

This Section 9 supersedes Section 8 only for the exact candidate-006 compile-only recovery below. It does not satisfy
Section 3, run PA self-test or the six-mode suite, create a PREPARED stage, qualify the harness, or produce performance
evidence.

The sole authorized recovery is **Recovery Step R2 / fail-closed syntax compile only**:

1. Preserve candidate-003, candidate-004, the stopped scratch, candidate-005, and R1 compile-check evidence byte-identical.
2. Copy candidate-005 to a fresh candidate-006. Before editing, require all eight candidate-006 files to be byte-identical
   to candidate-005.
3. Change only candidate-006 `source/MfoQaNative.cs`. Do not change an existing line. Add exactly one contiguous method
   inside `RunnerRole`, immediately after `Run(RoleContext c)` and before `RunPreack(...)`:
   ```csharp
   private static Dictionary<string, object> RunPerformanceContractSelfTest(RoleContext c, string identity)
   {
       HarnessOps.VerifyIdentityDocument(identity, c.Stage);
       throw new HarnessException("Performance contract self-test production binding incomplete");
   }
   ```
4. This method is deliberately fail-closed. It must not return Pass, start a process, connect the performance matrix, or
   claim that the still-unwired production path is qualified. Beyond the exact method above, do not add any other helper
   or change any other production-class line, namespace, using, wrapper, StagePreparer, or PowerShell file.
5. In a fresh non-stage compile-check directory, require this exact compiler identity before running the R1 command shapes:
   `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe`; size `2569832`; SHA-256
   `46809206887326d2d24db1eff1f3064de972c3451abe766b49111450a5e08e00`. Any mismatch is R2 Blocked.
   ```text
   csc /nologo /target:library /optimize+ /out:<check>/MfoQaNative.dll /reference:System.Web.Extensions.dll <candidate-006>/source/MfoQaNative.cs
   csc /nologo /target:exe /platform:x64 /optimize+ /main:MfoQaRunner /out:<check>/MfoQaRunner.exe /reference:<check>/MfoQaNative.dll <candidate-006>/source/MfoQaRunner.cs
   ```
   Run the wrapper compile only if the native compile succeeds.
6. Do not launch the generated executable. Preserve any native DLL if the wrapper compile fails, return the compile
   evidence, and stop.

Required R2 evidence:

- candidate-005 and candidate-006 complete size／SHA-256 inventories;
- one changed path, one added contiguous method block, zero existing-line edits, one hunk, and target diff SHA-256;
- byte-level prefix／suffix identity around the inserted block, no BOM change, no line-ending normalization, and all seven
  non-target files byte-identical; candidate-005 mixed line endings must be measured before／after;
- all older candidates and R1 compile-check evidence unchanged;
- `RunPerformanceContractSelfTest` occurrence audit showing exactly two occurrences: one existing dispatch and one new
  definition; definition count exactly `1`;
- added-block audit showing no `Process.Start`, `StartRole`, `PerformanceOwnedChild.Start`, real A／B／C executable
  path, success result, or process launch;
- exact compiler path／size／SHA-256, commands, exits, stdout／stderr, and output DLL／EXE identities;
- repository HEAD, local／origin equality, and clean worktree;
- stage and external run root absent; QA subagent, attached terminal, compiler, MfoQa, Godot／Material process count `0`;
- slot-attempt, slot-launch, A／B／C launch, and generated-executable launch counts `0`.

The insertion falls inside a marker window used by a later source audit. R2 does not run that audit and must not claim
source-audit Pass; the later integration／qualification step must revalidate the complete marker binding.

Both compile commands exiting `0` is **R2 Pass / fail-closed syntax compile only**. The work order remains
pre-PREPARED Blocked and must return to `00統括`. Native compile failure is **R2 Fail / candidate native source compile
defect**. If native compilation succeeds but the wrapper fails, return **R2 Fail / candidate wrapper compile defect** and
preserve the native DLL. Identity mismatch, non-exact promotion, or compiler unavailability is **R2 Blocked**.

R2 does not authorize execution of the generated EXE, PA self-test, StagePreparer compile／execution, six-mode tests,
source-diff qualification, stage materialization, seal, PREACK, performance slots, A／B／C, game launch, repository edits,
commits, or pushes. No candidate-007 or automatic repair is authorized.

## 10. Supervisor addendum — R2 Blocked and Recovery Step R3

R2 is accepted as **Blocked / compile evidence incomplete**. Candidate-006 contains the exact authorized fail-closed
method and has source SHA-256 `25a514ee4c08564997939c79e14e72573343431e3a020d57fd6d8537d4b28e0a`.
The R2 native compiler was invoked exactly once and produced `MfoQaNative.dll` with size `208384` and SHA-256
`eff5dbf598193defc573218a672a0110f9890fe6530297aa0ef9230cada9ac62`; stdout and stderr were empty.
However, the evidence driver stopped at `return[pscustomobject]@` after `WaitForExit` and before persisting
`ExitCode`. The numeric exit is therefore unknown. The DLL is not used to infer exit `0`, candidate source Fail is
not established, and R2 Pass is not established. Wrapper invocation and generated-executable launch counts are `0`.

Candidate-006's one-path／one-hunk insertion, prefix／suffix identity, BOM and mixed-line-ending preservation, exact
method placement, occurrence count `2`, definition count `1`, and no-process／no-success block audit are accepted.
Candidate-003 through candidate-006, the stopped scratch, R1 evidence, the R2 compile-check directory, and the R2 DLL
are frozen. Repository HEAD／local／origin were exact at
`e0785c4441bf76ba52b52039a5f6d6e0a9715a99` with a clean worktree. Stage, external run root, PREACK,
performance, A／B／C, and game remain unstarted; all performance launch counters remain `0`.

This Section 10 supersedes Section 9 only to permit one fresh compile-evidence attempt from unchanged candidate-006,
using the capture qualification below. It does not authorize any candidate or production-source edit, PA self-test,
six-mode suite, StagePreparer, PREPARED stage, harness qualification, or performance execution.

The sole authorized recovery is **Recovery Step R3 / qualified exit capture and syntax compile only**:

1. Keep candidate-003 through candidate-006, the stopped scratch, R1 evidence, and all R2 compile evidence byte-identical.
   Use candidate-006 as a read-only compiler input with exact native SHA-256
   `25a514ee4c08564997939c79e14e72573343431e3a020d57fd6d8537d4b28e0a`. Do not create candidate-007.
2. Create a fresh, non-stage R3 compile-check directory. Do not reuse, delete, or overwrite the R2 compile-check
   directory or its DLL. Place the R3 exit-capture driver only in the fresh check directory; it is evidence tooling, not
   candidate or repository source.
3. Before any compiler invocation, parse the complete capture driver without executing it. Then qualify the same driver
   once with this fixed canary: `C:\Windows\System32\cmd.exe /d /s /c "exit /b 23"`. Require a directly persisted numeric
   exit `23`, empty stdout and stderr, and successful reread of all three files. Driver parse or canary mismatch is
   **R3 Blocked / capture driver preflight**; do not invoke `csc`.
4. The driver must:
   - persist the exact command record before process start;
   - use one process start, `UseShellExecute=false`, redirected stdout／stderr, and `WaitForExit`;
   - copy `process.ExitCode` to a numeric local value and persist that exit file before constructing or returning any
     object or summary;
   - persist stdout and stderr; write an ordered result containing numeric `exit_code` to a new `.tmp` file with
     UTF-8 no BOM, atomically move it to an unused result path, then parse it back and compare the numeric exit;
   - return only the numeric exit after successful readback; avoid `return[pscustomobject]@` and any dependency on a
     returned PowerShell object.
5. Require this exact compiler identity:
   `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe`; size `2569832`; SHA-256
   `46809206887326d2d24db1eff1f3064de972c3451abe766b49111450a5e08e00`.
6. Using the qualified driver, invoke the native compile exactly once in R3:
   ```text
   csc /nologo /target:library /optimize+ /out:<r3-check>/MfoQaNative.dll /reference:System.Web.Extensions.dll <candidate-006>/source/MfoQaNative.cs
   ```
   If the direct numeric exit is missing, stop as **R3 Blocked / compile evidence incomplete**. If it is nonzero, stop as
   **R3 Fail / candidate native source compile defect**. Do not retry.
7. Only if the native exit is directly persisted as `0`, invoke the wrapper compile exactly once with the R3 native DLL:
   ```text
   csc /nologo /target:exe /platform:x64 /optimize+ /main:MfoQaRunner /out:<r3-check>/MfoQaRunner.exe /reference:<r3-check>/MfoQaNative.dll <candidate-006>/source/MfoQaRunner.cs
   ```
   Missing wrapper exit is **R3 Blocked / compile evidence incomplete**. Nonzero wrapper exit is
   **R3 Fail / candidate wrapper compile defect**. Do not retry.
8. Do not launch either generated output. Return the evidence and stop.

Required R3 evidence:

- candidate-006 full before／after size and SHA-256 inventory and exact byte identity; all older frozen inventories
  unchanged;
- R2 compile-check directory and R2 DLL before／after identities unchanged;
- fresh R3 check directory preflight absence and final complete inventory;
- capture-driver bytes／SHA-256, parse command／exit／streams, exact canary command, direct canary exit `23`,
  canary stdout／stderr, reread comparison, and canary process identity;
- exact compiler path／size／SHA-256;
- exact native and conditional wrapper commands, invocation counts, directly persisted numeric exits, stdout／stderr,
  reread comparisons, and output identities;
- explicit proof that the R2 DLL was not used as the wrapper reference and that neither generated output was launched;
- repository HEAD, local／origin equality, and clean worktree;
- Stage and external run root absent; QA subagent, attached terminal, compiler, MfoQa, Godot／Material process count `0`;
- performance slot-attempt, slot-launch, A／B／C launch, and generated-output launch counts `0`.

Canary exit `23`, native exit `0`, and wrapper exit `0`, each directly persisted and reread, is **R3 Pass /
syntax compile evidence only**. `-010` remains pre-PREPARED Blocked and must return to `00統括`; R3 Pass does not
authorize PA self-test or any follow-on.

R3 does not authorize candidate／harness／game source edits, candidate-007, driver repair after the canary or compiler
attempt begins, compiler retry, execution of generated DLL／EXE, PA self-test, StagePreparer compile／execution,
six-mode tests, source-diff qualification, stage materialization, seal, PREACK, performance slots, A／B／C, game launch,
repository edits, commits, or pushes. No automatic repair or follow-on is authorized.

## 11. Supervisor addendum — R3 Pass and Recovery Step R4

R3 is accepted as **Pass / syntax compile evidence only**. The qualified capture driver had SHA-256
`7b6bddd82db921de04244d96439d3959b407837e8e23dd94c3cd9aaa6df3d15e`; its fixed canary directly persisted
and reread exit `23` with empty streams. Candidate-006 native and wrapper compiles each directly persisted and reread
exit `0` with empty streams. The R3 native DLL is `208384` bytes／SHA-256
`7270cabfc9e9275687853be94f796d398f916a46e499bab3b22b06385adc9aea`; the wrapper EXE is `3072`
bytes／SHA-256 `8f2712e910b938d31e31a9bc698cceff0eacaf716f4307afd3c93c8e28eb4aae`.
Neither output was launched.

R3 proves only that candidate-006 is syntax-compilable. It does not qualify the fail-closed PA method, production
performance wiring, six-mode suite, Stage P, seal, PREACK, or performance. Candidate-003 through candidate-006,
the stopped scratch, R1／R2／R3 evidence, and every R2／R3 output are frozen. Repository HEAD／local／origin were exact
at `e753ee5d31c43be3b7d86a8a9f1d8be05a99d9c9`, worktree clean. Stage and external run root remain absent;
performance slot-attempt, slot-launch, A／B／C launch, and generated-output launch counts remain `0`.

Candidate-006 still has no production matrix connection: the PA method is deliberately fail-closed,
`PerformanceOwnedChild.Start`, `PerformanceCounts`, `ReadSystemTimes`, foreground acquisition, and result adoption
have no production caller; Controller LIVE ends after the 61-sample settled interval; and post-controller executable／
recorder-output binding is absent. Therefore no execution test is safe before the bounded integration below compiles and
passes static closure.

This Section 11 supersedes Sections 9／10 only for one fresh candidate-007 integration and compile／static audit. It
does not authorize any generated output to run, PA self-test, six-mode execution, Stage materialization, seal, PREACK,
or performance.

The sole authorized recovery is **Recovery Step R4 / production integration compile and static closure only**:

1. Preserve candidate-003 through candidate-006, the stopped scratch, and all R1／R2／R3 evidence and outputs
   byte-identical. Copy candidate-006 to one fresh candidate-007 and prove all eight files byte-identical before editing.
2. Candidate-007 may change only these four paths:
   - `source/MfoQaNative.cs`;
   - `preparation-tools/StagePreparer.cs`;
   - `preparation-tools/RunPreparation.ps1`;
   - `preparation-tools/RecordRepositoryState.ps1`.
   The four wrapper／sentinel files must remain byte-identical to candidate-006. A listed path may remain unchanged.
3. Every changed hunk must map to one of the already-authorized Section 3 categories:
   - mechanical `-010` identity／path／field／source-audit binding;
   - fixed A／B／C table, performance evidence schema, settled-to-performance phases, CPU preflight, foreground,
     sealed launch／output validation, and post-controller identity audit;
   - cumulative attempt／launch／A-B-C counts, bounded slot cleanup, narrow exact-owned current-slot allowance, and
     complete Controller→Launcher→Runner result propagation;
   - production-bound PA fixtures and static binding checks that launch no real A／B／C process.
4. Complete these existing-contract connections without changing their values or semantics:
   - replace the fail-closed PA method with fixtures for fixed order, `0…6` count transitions, deadline reservation,
     trigger persistence, slot-local `try/finally`, exact-owned cleanup, complete role results, raw streams, JSON／PNG
     structure, and production binding; fixture real-process starts remain exactly `0`;
   - load the sealed performance contract in Controller LIVE and connect the inherited 61-sample interval to CPU
     preflight／bounded retry, deadline reservation, 5-second idles, exact order `A1→B1→C1→C2→B2→A2`,
     current-slot foreground／host monitoring, 60-second slot budget, and 5-second cleanup;
   - keep the generic forbidden-runtime mechanism unchanged and add only the Section 3 current-slot PID／creation-time／
     image-path plus owned-child allowance in the performance phase;
   - propagate non-constant counts and terminal evidence through Controller, Launcher, and Runner;
   - perform full A／B／C byte／SHA audit only after Controller exit, never during a timed slot;
   - validate each recorder JSON as exactly 600 post-warmup samples with authoritative `frame_ms.p95`, bind its sealed
     `capture_path`, require the PNG and hash it. Do not implement OCR or decide HUD visual equality;
   - bind StagePreparer and preparation scripts to the same fields, controller output root, six modes, current
     `-010` identities, and complete source-diff audit.
5. Before compilation, produce a static changed-path／hunk audit and require:
   - all changed hunks fall within the four paths and four authorized categories;
   - PA fixture code contains no `Process.Start`, `StartRole`, `PerformanceOwnedChild.Start`, or real A／B／C path;
   - the only real slot-start call is reachable from Controller LIVE's fixed matrix path;
   - `PerformanceContract.Load`, `PerformanceCounts`, `ReadSystemTimes`, foreground, count adoption, post-controller
     executable audit, and recorder-output validation each have a production binding;
   - generic clock／power／input／activation／journal／sentinel semantics and generic
     `ForbiddenRuntimeInventory` remain byte-identical;
   - no HUD OCR／external screenshot path, recorder change, game change, threshold change, or retry path exists.
6. In a fresh R4 compile-check directory, use the exact accepted compiler identity and compile candidate-007 native,
   Runner, Launcher, Controller, Sentinel, and StagePreparer. Parse both PowerShell files. Capture exact commands,
   numeric exits, streams, and output identities with the R3-qualified capture approach.
7. Do not launch any generated DLL／EXE or either PowerShell script. Return the evidence and stop.

Required R4 evidence:

- complete candidate-006 and pre-edit／post-edit candidate-007 size／SHA-256 inventories;
- four-path maximum changed-path audit, candidate-006→007 diff, each hunk's authorized-category mapping, target diff
  SHA-256, and all unlisted files byte-identical;
- exact static-binding counts／locations and negative scans required by Step 5;
- exact compiler／PowerShell identities, commands, numeric exits, stdout／stderr, and all generated output identities;
- proof that no generated output, PA self-test, six-mode, StagePreparer, PowerShell, Stage, A／B／C, or game was run;
- frozen candidate／evidence／output before／after identities;
- repository HEAD, local／origin equality, clean worktree, Stage／external run root absence, residual process／subagent／
  terminal `0`, and every performance launch count `0`.

All static audits, the native library compile, four wrapper／sentinel executable compiles, the StagePreparer compile,
and two PowerShell parses passing is
**R4 Pass / production integration compile and static closure only**. The order remains pre-PREPARED Blocked and must
return to `00統括`. Source, compile, parse, fixture-binding, production-binding, or source-diff nonconformance is
**R4 Fail / candidate harness integration defect**. Missing durable evidence is **R4 Blocked / evidence incomplete**.
Frozen identity, compiler, branch, or input mismatch is **R4 Blocked / preparation integrity**. Any real A／B／C or
generated-output execution is **R4 Fail / prohibited execution**.

R4 does not authorize candidate-008, automatic repair, retry, PA self-test execution, six-mode execution, Stage
materialization, seal／ReadOnly, PREPARED, PREACK, performance slots, A／B／C, game launch, repository edits, commits,
or pushes. No automatic follow-on is authorized.

## 12. Supervisor addendum — R4 administrative Blocked and Recovery Step R4A

R4 returned **Blocked / preparation integrity** at its mandatory clean preflight, before candidate-007 editing or any
compile. The detected item was the untracked supervisor transcript helper
`conversation_export/inspect_session.py`, `2026` bytes, SHA-256
`e60052a1435b0da5cd5cd7075d19b07c066859a0754102090c19f27e4fcefb22`, created and last written
`2026-07-16T14:31:37.6585133Z`. QA correctly made no cleanup, source edit, compile, Stage, or execution.

After the formal return, a second supervisor transcript subagent independently created untracked
`conversation_export/analyze_30.py`, `2012` bytes, SHA-256
`377d7904f0c7815d4ed6af7be8ad9874976e816078bf99f981d335649054d239`, created
`2026-07-16T14:36:24.3070910Z`. Neither item is QA, harness, game, test, or project source. `00統括` stopped the
transcript agents and moved the two exact files outside the repository to the Codex visualization workspace as
`repo_helper_inspect_session.py` and `repo_helper_analyze_30.py`. Post-move size and SHA-256 match exactly; repository
status is clean. No tracked file, game code, candidate, evidence, or prior output was changed by the relocation.

The R4 return is accepted as a correct fail-closed response to supervisor-owned administrative contamination, not as a
candidate or harness defect. Candidate-007 remains the fresh pre-edit copy of candidate-006: `8 / 8` files
byte-identical, diff count `0`, inventory SHA-256
`4938e24a70ac7069a6c945fdc9bb2f9dc7cc33a3a4981846d447c436b5c953cf`. Compile-check and external run roots remain
absent; every performance count and relevant residual process remains `0`.

The sole authorized continuation is **Recovery Step R4A / clean-state resume of unchanged candidate-007**:

1. Fast-forward the required QA branch to this supervisor addendum and require local HEAD equals origin and worktree
   clean. Prove both repository-relative helper paths are absent and record the two relocated external file identities.
2. Reverify candidate-003 through candidate-006, stopped scratch, R1／R2／R3 evidence／outputs, and candidate-007 against
   the frozen identities. Candidate-007 must still be pre-edit, `8 / 8` byte-identical to candidate-006, with the exact
   inventory above.
3. If Steps 1／2 pass, continue Section 11 Steps 2 through 7 using that same candidate-007. Do not create
   candidate-008. The prior preflight is not a compile or execution attempt; no compile retry is authorized.
4. Return the full Section 11 evidence and stop. All Section 11 classifications and prohibitions remain in force.

Any new repository contamination, frozen-identity mismatch, or non-clean state is **R4A Blocked / preparation
integrity**. Passing the clean audit, static closure, six prescribed compiles, and two parses is **R4A Pass / production
integration compile and static closure only**. Source／binding／compile／parse nonconformance is **R4A Fail / candidate
harness integration defect**. Missing durable evidence is **R4A Blocked / evidence incomplete**. Any generated-output,
PA self-test, six-mode, Stage, PowerShell, A／B／C, performance, or game execution is **R4A Fail / prohibited
execution**.

R4A still does not authorize Stage materialization, seal, PREPARED, PREACK, performance, Gate 2, or Slice 2-B. No
automatic follow-on is authorized.

## 13. Supervisor closure — R4A interrupted before static closure

R4A returned **Blocked / interrupted before static closure** after the executing Codex turn ended with a system error
before a formal result could be emitted. A separate read-only closure established that the repository remained clean at
`8176c4efe6ad59ccb29e1e431c6848f12a2285dc`, local and origin matched, and no repository edit, commit, or push occurred.

Candidate-007 contains eight files with inventory SHA-256
`afc1ca0c42c243212a06ffe0309c35003d6fa3ffd685d459ae5706f591d58882`. Exactly the four Section 11 authorized paths
changed from candidate-006: `source/MfoQaNative.cs`, `preparation-tools/StagePreparer.cs`,
`preparation-tools/RunPreparation.ps1`, and `preparation-tools/RecordRepositoryState.ps1`. The marker correction discussed
immediately before the system error is present in the frozen bytes; it was not merely planned. This fact is not a static
closure result and is not a candidate Pass／Fail determination.

The R4 compile-check directory, R4 DLL／EXE, Stage, and external run root are absent. There is no durable R4 compile or
PowerShell parse evidence. Relevant residual processes, `performance_slot_attempt_count`,
`performance_slot_launch_count`, `abc_launch_count`, and generated-output launch count are all `0`.

R4A is closed Blocked and candidate-007 is frozen in place. `MFO-WO-P2-2A-010` remains pre-PREPARED Blocked. No result
from R4A authorizes performance, Gate 2, or Slice 2-B.

## 14. Supervisor addendum — Recovery Step R4B

The sole authorized continuation is **Recovery Step R4B / frozen candidate-007 static and compile closure only**.
R4B does not authorize any source or script edit.

1. Fast-forward the required QA branch to this supervisor commit. Require local HEAD equals origin, worktree clean, and
   no repository-relative transcript helper. Preserve candidate-003 through candidate-006, stopped scratch, and all
   R1／R2／R3／R4／R4A evidence and outputs byte-identical.
2. Before any compile or parse, verify candidate-007 has exactly these eight identities:
   - `preparation-tools/RecordRepositoryState.ps1`: `12740` bytes /
     `838e9bf4d626178b4306b8b0d27b4bcd8e631d19d20d9ac3e943b29302f410b7`
   - `preparation-tools/RunPreparation.ps1`: `14879` bytes /
     `bcb15d58e09691b891a114c5b7d2f0cfe25a1eb01dda7e9dca004e5e7de585ca`
   - `preparation-tools/StagePreparer.cs`: `218514` bytes /
     `0fab344155b710c4fe743d9156d2c8a78cbce42d845c10ea7caa5f22014a9dfb`
   - `source/MfoQaController.cs`: `147` bytes /
     `37c1c52d278704d0aa426e82aebe7e246f841e63d31ffeeae661e6da96502743`
   - `source/MfoQaLauncher.cs`: `143` bytes /
     `8fb493ea6ef36540fdde2dd572b0f5b2ef082ef895070c9a55e3377f0eeb2d2e`
   - `source/MfoQaNative.cs`: `456570` bytes /
     `b3a0fa41fca91143c9ddbe9ec6e0acb4d2de2c35bbb419191f6e74d7bead970b`
   - `source/MfoQaRunner.cs`: `139` bytes /
     `0bba8f49748d016c17d6fe1c17aa442f31da3572248116c08c32f98558aeccce`
   - `source/MfoQaSentinel.cs`: `1121` bytes /
     `b624699fe07c64104704ce5c0b25a77dbffc64b131aa518e7c7e90322efd8bb3`
   The eight-file inventory SHA-256 must be
   `afc1ca0c42c243212a06ffe0309c35003d6fa3ffd685d459ae5706f591d58882`. A mismatch is preparation-integrity Blocked.
3. With those bytes unchanged, complete the Section 11 changed-path, hunk, source-diff, fixture-binding,
   production-binding, process-start-count, and forbidden-token static audits. Partial R4A observations are not a
   substitute. Any static nonconformance is Fail; do not repair it under R4B.
4. Only if every static audit passes, create one fresh non-stage `candidate-007-r4b-compile-check` directory. Using the
   frozen R3-qualified capture driver and compiler identity, execute each prescribed compile once, in dependency order:
   native library, Runner, Launcher, Controller, Sentinel, then StagePreparer. Persist and reread numeric exit and both
   streams for every invocation. Stop on the first nonzero or incomplete result. Do not retry.
5. Only if all six compiles pass, parse `RunPreparation.ps1` and `RecordRepositoryState.ps1` exactly once each with the
   approved parse-only path. Do not execute either script.
6. Freeze all R4B evidence, prove no generated DLL／EXE was launched, prove Stage and external run root remain absent,
   prove every performance／A-B-C count and relevant residual process is `0`, return the result to `00統括`, and stop.

Passing every static audit, six compiles, and two parses is **R4B Pass / production integration compile and static
closure only**. Source／binding／compile／parse nonconformance is **R4B Fail / candidate harness integration defect**.
Missing durable evidence, interruption, or frozen-input mismatch is **R4B Blocked**. Any source edit, candidate-008,
retry, generated-output execution, PA self-test, six-mode, Stage, seal, PREPARED, PREACK, performance slot, A／B／C, or
game launch is prohibited.

Even an R4B Pass leaves `MFO-WO-P2-2A-010` pre-PREPARED Blocked and does not authorize performance, Gate 2, or
Slice 2-B. No automatic follow-on is authorized.

## 15. Supervisor closure — R4B static Fail and Recovery Step R4C

Section 15 closes and supersedes Section 14 only for the bounded R4C authorization below. Every other frozen identity,
prohibition, and no-automatic-follow-on boundary from Section 14 remains in force.

R4C uses external candidate／evidence paths only. After the required fast-forward, QA must not edit, add, commit, or
push repository paths; the broader tracked-report permissions in Section 2 do not apply to R4C.

R4B returned **Fail / candidate harness integration defect** at the first production-binding static audit. The frozen
StagePreparer counted the Controller-region substring `sample_frames\", 600` and required at least two hits; the exact
observed count was one. It correctly stopped before creating a compile-check directory. Compile invocations,
PowerShell parses, generated outputs, PA self-test, six-mode, Stage, seal, PREPARED, PREACK, performance, A／B／C,
P95, KBM, and game launches were all `0`／Not run. The repository remained clean at
`549590939a10ba6f53313f9d02b0f9b082c90ef5`, local and origin matched, and all performance counts and relevant
residual processes were `0`.

The R4B evidence is frozen outside the repository at
`C:\Users\osato\.codex\visualizations\2026\07\14\019f5e09-e999-7963-97fe-4d67d1e8a419\wo010-r4b-static-fail`.
Its `SHA256SUMS.txt` has `7 / 7` matching payload entries and SHA-256
`0c48ad29892956d94368e7812a709fa28a538070e562deb24900643eb4140bab`.

Supervisor and two independent read-only reviews confirm that production binding is present and the matcher is the
defect:

- Controller validates recorder input with exact `HarnessOps.SafeInteger(report, "sample_frames", -1) != 600`;
- after validation it records exact `"sample_frames", 600` in the durable slot result;
- the production matrix calls that recorder validator after each completed slot;
- the sealed matrix separately requires `sample_frames == 600`.

Reducing the existing threshold to one would be unsafe because the evidence literal alone could pass after removal of
the input validation. Adding a duplicate or dummy Native literal would also be incorrect. R4B remains Fail and
candidate-007 plus its evidence remain frozen.

The sole authorized continuation is **Recovery Step R4C / one-file static matcher correction and closure only**:

1. Fast-forward the required QA branch to this supervisor commit. Require local HEAD equals origin, worktree clean,
   no repository-relative transcript helper, candidate-007's exact Section 14 eight-file identities, and frozen prior
   candidate／evidence／output identities.
2. Copy candidate-007 to one fresh candidate-008 and prove all eight files byte-identical before editing.
3. Candidate-008 may change only `preparation-tools/StagePreparer.cs`, and only the three related sites in
   `VerifyPerformanceProductionSourceBinding`: counter declaration, Pass predicate, and returned audit fields.
4. Replace the ambiguous same-token count with two independent exact Controller-region checks:
   - sample-600 input-validation reference: `HarnessOps.SafeInteger(report, "sample_frames", -1) != 600`, exactly `1`;
   - sample-600 validated-evidence reference: `"sample_frames", 600`, exactly `1`.
   Require each count independently with `== 1`. Return the exact fields
   `sample_600_input_validation_reference_count` and `sample_600_validated_evidence_reference_count`. Keep
   `sample_600_reference_count` as their sum, exactly `2`. Do not weaken either condition to `>= 1`.
5. Prove candidate-007→candidate-008 changes only that file and those three semantic sites. Native, wrappers,
   sentinel, preparation scripts, recorder, game, values, performance／CPU／P95 thresholds, production behavior, and every other
   StagePreparer byte remain unchanged. Reconfirm candidate-006→candidate-008 still changes only the four Section 11
   authorized paths.
6. Run the full Section 11 static audit exactly once on candidate-008. The two new counts must each be exactly `1`; all other
   positive and negative bindings must retain the frozen R4B values. Stop without repair on any nonconformance.
7. Only if static audit passes, create one fresh non-stage `candidate-008-r4c-compile-check` directory and compile,
   exactly once in order, native, Runner, Launcher, Controller, Sentinel, then StagePreparer using the frozen
   R3-qualified capture path. Persist and reread numeric exit and both streams. Stop on the first nonzero or incomplete
   result; no retry.
8. Only if all six compiles pass, parse `RunPreparation.ps1` and `RecordRepositoryState.ps1` exactly once each with the
   approved parse-only path. Do not execute either script.
9. Freeze all R4C evidence, prove no generated output was launched, prove Stage and external run root remain absent,
   prove all performance／A-B-C counts and relevant residual processes remain `0`, return to `00統括`, and stop.

All "Required R4 evidence" items in Section 11 are inherited by R4C, substituting candidate-007→candidate-008 and
`candidate-008-r4c-compile-check` for the R4 names. This includes complete pre／post inventories, target and aggregate
diff identities, exact commands／compiler／parse results／streams／output identities, frozen before／after identities,
and final repository／process／Stage／run-root／count state.

Passing the one-file diff audit, full static closure, six compiles, and two parses is **R4C Pass / corrected static
matcher and production integration compile closure only**. Any unexpected source diff, static／compile／parse
nonconformance is **R4C Fail / candidate harness integration defect**. Missing durable evidence, interruption, or
frozen-input mismatch is **R4C Blocked**. Any retry, candidate-009, generated-output execution, PA self-test, six-mode,
Stage, seal, PREPARED, PREACK, performance slot, A／B／C, or game launch is prohibited.

Even an R4C Pass leaves `MFO-WO-P2-2A-010` pre-PREPARED Blocked. It does not authorize performance, Gate 2, or
Slice 2-B, and it has no automatic follow-on.



## 16. Supervisor closure — R4C procedure Blocked and Recovery Step R4D

R4C returned **Blocked / preparation procedure retry boundary**. The first external `apply_patch` attempt failed with
ACL deny-read and wrote no candidate bytes. PowerShell edit helper `#1` then failed to parse and wrote no candidate
bytes. A second helper using another anchor method exited `0` and wrote the Section 15 change before the supervisor
HOLD arrived. Because the second helper followed the first helper failure, R4C crossed its no-retry boundary and is
not accepted as Pass. This classification is procedural; it is not a candidate source Fail or a game defect.

The HOLD closure confirmed that candidate-007 remains byte-identical with inventory SHA-256
`afc1ca0c42c243212a06ffe0309c35003d6fa3ffd685d459ae5706f591d58882`. Candidate-008 is frozen with inventory
SHA-256 `fef65dceee8d2bbf456034edcd0a828a96eea18d47d672179230ced367e80689`. Its only changed path from candidate-007 is
`preparation-tools/StagePreparer.cs`, size `219016`, SHA-256
`2baa9e55266117b12df63d41229e0836eea7bdb02d11952f97df33cfdf730b5a`; the other seven candidate files are
byte-identical. The recorded diff has exactly three hunks:

- `@@ -2153 +2153,3 @@`;
- `@@ -2174 +2176 @@`;
- `@@ -2195,0 +2198,2 @@`.

Full static audit, compile, candidate PowerShell parse-only, generated-output launch, PA self-test, six-mode, Stage,
seal, PREPARED, PREACK, performance, A／B／C, P95, KBM, and game were all `0`／Not run. The external run root and
compile-check directory are absent, relevant residual processes are `0`, and the repository remained clean with local
and origin at `c1591d638ded4b17e19f93255038570426c9019a`.

Section 16 supersedes Section 15 only for the bounded continuation below. The sole authorized continuation is
**Recovery Step R4D / frozen candidate-008 read-only static and compile closure only**:

1. Fast-forward the required QA branch to this supervisor commit. Require local HEAD equals origin, worktree clean,
   no repository-relative transcript helper, all frozen candidate／evidence／output identities unchanged, candidate-007
   inventory exactly as above, and candidate-008's complete eight-file identity exactly matching the R4C closure.
2. Do not copy, patch, replace, normalize, repair, or otherwise edit candidate-008. Candidate-009 and fallback candidates
   are prohibited. Reverify as a read-only lineage audit that candidate-007→candidate-008 changes only
   `preparation-tools/StagePreparer.cs`, the other seven files are byte-identical, and the diff is exactly the three
   recorded Section 15 semantic hunks. This lineage audit is not the formal static-audit attempt.
3. QA may author one external **read-only** audit-capture driver outside the repository, candidate directories, and
   frozen evidence. Before the formal attempt begins, QA may syntax-parse and correct that driver without reading or
   writing candidate-008, invoking a compiler, or creating execution evidence. Record a durable `R4D_ATTEMPT_BEGIN`
   containing the final driver SHA-256 and parser identity. After that marker, the driver is immutable and no alternate
   driver, helper, anchor, repair, or retry is allowed.
4. Run the full Section 11 static audit exactly once on frozen candidate-008. Require
   `sample_600_input_validation_reference_count == 1`,
   `sample_600_validated_evidence_reference_count == 1`, and `sample_600_reference_count == 2`; every other positive
   and negative binding must retain the frozen R4B expectation. Stop on the first nonconformance without repair.
5. Only if the full static audit passes, create one fresh non-stage `candidate-008-r4d-compile-check` directory. Using
   the frozen R3-qualified exit-capture path and compiler identity, compile exactly once in dependency order: native,
   Runner, Launcher, Controller, Sentinel, then StagePreparer. Persist and reread numeric exit, stdout, and stderr for
   every invocation. Stop on the first nonzero or incomplete result; do not retry or recompile.
6. Only if all six compiles pass, parse `RunPreparation.ps1` and `RecordRepositoryState.ps1` exactly once each with the
   approved parse-only path. Do not execute either script. Stop on the first nonzero or incomplete result and do not use
   another parser or command.
7. Freeze the R4C helper chronology and closure identities together with all R4D lineage, driver, static-audit,
   compiler／parser command, exit, stream, readback, output-identity, and final-state evidence. Prove candidate-008 is
   unchanged before／after, no generated output was launched, Stage and external run root remain absent, and every
   performance／A-B-C count and relevant residual process remains `0`. Return to `00統括` and stop.

Passing the lineage audit, one full static audit, six compiles, and two parses is **R4D Pass / corrected static matcher
and production integration compile closure only**. Static／compile／parse nonconformance is **R4D Fail / candidate
harness integration defect**. Frozen identity mismatch, missing durable evidence, or interruption is **R4D Blocked**.
Any candidate edit, post-marker driver change, retry, candidate-009, generated-output execution, PA self-test,
six-mode, Stage, seal, PREPARED, PREACK, performance slot, A／B／C, or game launch is prohibited.

Even an R4D Pass leaves `MFO-WO-P2-2A-010` pre-PREPARED Blocked. It does not authorize performance, Gate 2, or
Slice 2-B, and it has no automatic follow-on.


## 17. Supervisor closure — R4D evidence Blocked and Recovery Step R4E

R4D returned **Blocked / missing durable evidence and interrupted before static audit**. This is not a candidate
source Fail, compile Fail, game defect, or performance result. The formal attempt began at
`2026-07-17T01:22:21.4061392Z` with a `44078`-byte driver, SHA-256
`812b41e97b731608227250e6ea9842790103920b9f41e478562d417b5bf4038b`, zero pre-marker parser errors, and marker
SHA-256 `93fd5965ca103f1ba7e4ded8906f25f19d8f0fd6bb38297afffc7fb298198c6d`.

The driver concatenated the Japanese repository path into `ProcessStartInfo.Arguments`. Its initial branch, HEAD,
origin, and status checks were constructed before the first result was asserted; all four read-only Git invocations
therefore ran and returned exit `128` after the path became mojibake. The catch closure then failed while converting
the relevant-process generic list to an array. `r4d-final.json` and `SHA256SUMS.txt` were not created. The marker and
Git evidence total `21` files and remain frozen exactly as returned; QA must not add a manifest, repair, clean up,
delete, move, or otherwise alter them.

Formal lineage audit, full Section 11 static audit, compiler invocation, candidate PowerShell parse-only, generated
output, PA self-test, six-mode, Stage, seal, PREPARED, PREACK, performance slot, A／B／C, P95, KBM, and game were all
`0`／Not run. Candidate-008 remains unevaluated and frozen with inventory SHA-256
`fef65dceee8d2bbf456034edcd0a828a96eea18d47d672179230ced367e80689`; its StagePreparer remains `219016` bytes,
SHA-256 `2baa9e55266117b12df63d41229e0836eea7bdb02d11952f97df33cfdf730b5a`.

Section 17 supersedes Section 16 only for the bounded continuation below. The sole authorized continuation is
**Recovery Step R4E / pre-marker driver qualification followed by one frozen candidate-008 formal closure**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing this Section 17. Require local
   HEAD equals origin and worktree clean. The exact starting SHA is supplied by `00統括` in the direct handoff after
   commit and must be persisted in R4E evidence.
2. R4D driver, marker, and 21 evidence files remain immutable. Before `R4E_ATTEMPT_BEGIN` only, QA may create,
   syntax-parse, repair, and requalify one new external R4E audit driver. Each qualification attempt uses a separate
   immutable external root; failed qualification roots are preserved and never reused.
3. The pre-marker qualification must use the actual Unicode repository path
   `C:\Users\osato\OneDrive\ドキュメント\MF`. Run branch, HEAD, origin, and status sequentially, asserting each
   result immediately before invoking the next. Do not eagerly construct or execute all four calls. Do not concatenate
   the Unicode repository path into `ProcessStartInfo.Arguments`; use `WorkingDirectory` with ASCII Git arguments or
   another argument-vector transport proven by this qualification.
4. During pre-marker qualification, read the actual candidate-008 only for byte-open, complete eight-file size／hash
   identity, the inventory SHA-256 above, and the StagePreparer size／SHA above. Do not evaluate lineage or any static
   predicate, invoke a compiler, or parse a candidate PowerShell script before the formal marker.
5. After the Unicode transport and identity readback succeed, trigger a named intentional failure through the same
   top-level catch／finalizer used by the formal run. Qualification passes only if the primary intentional-failure tag
   is retained, process information becomes a JSON-safe array, any secondary closure error cannot mask the primary or
   stop finalization, a parseable final JSON is durable, a complete `SHA256SUMS.txt` is durable and every entry matches,
   and all lineage／static／compiler／parse／Stage／performance counters remain exactly `0`.
6. Freeze the qualified driver bytes, size, SHA-256, qualification receipt, and qualification manifest hash. Reverify
   the driver SHA immediately before creating one new formal evidence root and one durable `R4E_ATTEMPT_BEGIN` marker.
   The marker records those qualification identities, expected branch／starting commit, candidate-008 identities,
   exact formal mode／argv, and all formal counters at `0`.
7. After the marker, the driver is immutable and no alternate driver, repair, restart, or retry is allowed. Execute in
   strict order: sequential repository identity checks; candidate-008 lineage audit once; full Section 11 static audit
   once; only if both pass, the exact six-compile dependency set once each; only if all six pass, the exact two
   PowerShell parse-only checks once each; then always finalize durable JSON and a complete verified manifest.
8. Compile outputs, if authorized by the gates above, go only to a new external R4E compile root. Do not launch any
   generated DLL／EXE. Prove candidate-008 unchanged before／after, all prohibited execution counts `0`, and no relevant
   residual process, Stage, or external performance run root.
9. Return the frozen qualification and formal evidence to `00統括` and stop. Do not create candidate-009, run
   StagePreparer, PA self-test, six-mode, Stage／seal／PREPARED／PREACK, performance, A／B／C, P95, KBM, or game.

Passing the complete R4E closure is **R4E Pass / audit-driver qualified and corrected static matcher compile／parse
closure only**. Formal static／compile／parse nonconformance is **R4E Fail / candidate harness integration defect**.
Identity mismatch, qualification failure, missing durable evidence, or interruption is **R4E Blocked**. Even an R4E
Pass leaves `MFO-WO-P2-2A-010` pre-PREPARED Blocked and `MFO-HOLD-P2-2A-001` active. It does not authorize
performance, Gate 2, Slice 2-B, or automatic follow-on.


## 18. Supervisor closure — R4E lexical-extractor Fail and Recovery Step R4F

R4E returned a formal machine classification of **Fail / candidate harness integration defect** at the first static
nonconformance. The qualified driver reported a duplicate raw marker for
`RunPerformanceContractSelfTest(RoleContext c, string identity)`. Repository checks ran sequentially and passed,
lineage ran once and passed, static ran once and stopped, compiler and candidate PowerShell parse counts were `0`,
and no retry, repair, alternate formal driver, generated-output launch, Stage, performance, or game occurred.

Supervisor and independent read-only review attribute the failure to the **external audit-driver lexical extractor**,
not to candidate-008. The exact signature text occurs twice in frozen `source/MfoQaNative.cs`, but line 3863 is the
only method declaration and line 3989 is a quoted `string paStart = "..."` marker used by production self-audit.
Candidate-007 and candidate-008 Native are byte-identical with SHA-256
`b3a0fa41fca91143c9ddbe9ec6e0acb4d2de2c35bbb419191f6e74d7bead970`. The R4E driver `Extract-Between` used
whole-source `IndexOf` and rejected any second raw token before extracting the method region, so it counted the
quoted marker as a second declaration. No duplicate method definition was found. Because compile／parse remained
`0`, candidate-008 remains unevaluated.

R4E qualification and formal artifacts remain frozen. The qualified driver SHA-256 is
`1ca63ee78164a82d45aa0fe7fe0f19071ec70b45f03dc808fcfe82a984d19807`; qualification manifest SHA-256 is
`014100d2861db9152aac00a7fd6d1ed634b169313ca6c3f73b778dccd31bc878` with `24 / 24` payloads; formal
`R4E_ATTEMPT_BEGIN` SHA-256 is `78a58eb3653238ce9009a111b19303e53b58782b30c1775c3a601a783b3b7313`;
formal manifest SHA-256 is `bfccba99a32fb56d38a5367f034e403c6c16fc9e4c3e5c6c104e55609714910f` with
`49 / 49` payloads. Qualification-001, the noncompliant qualification-002 closure, qualification-003, and formal
evidence are immutable and must not be repaired, retried, cleaned up, or reused.

Section 18 supersedes Section 17 only for the bounded continuation below. The sole authorized continuation is
**Recovery Step R4F / line-anchored external extractor qualification and one formal closure**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing this Section 18. Require exact
   local／origin HEAD and clean worktree. `00統括` supplies the exact starting SHA after push; do not insert a receipt
   commit before the R4F closure.
2. Freeze candidate-008 and every R4E driver／qualification／closure／formal artifact. Candidate edit, copy, repair,
   normalization, candidate-009, and R4E evidence backfill are prohibited.
3. Before `R4F_ATTEMPT_BEGIN` only, create one new external R4F driver at a new path. Starting from the qualified
   R4E transport／closure behavior, the only semantic correction is method-region boundary extraction: start and end
   markers must match exact line-anchored declaration lines, tolerate CRLF／LF, ignore identical text inside quoted
   literals, and reject missing or multiple actual declaration lines. Mechanical R4F identity and directly related
   qualification evidence fields may change; no candidate or product source may change.
4. Each pre-marker qualification attempt must create and read back its own immutable root and attempt-begin receipt
   before its first check. Preserve failed roots and never reuse a driver path or root. Qualification must repeat the
   R4E qualification-003 Unicode repository transport, sequential Git checks, candidate eight-file identity-only
   readback, named intentional primary／secondary failure isolation, JSON-safe process array, final JSON, complete
   manifest, and all formal counters `0`.
5. Add synthetic extractor fixtures, without reading candidate source beyond identity: one actual start declaration and
   one actual end declaration plus quoted copies of both marker texts must extract exactly one region and Pass; two
   actual start declarations must fail; two actual end declarations must fail; missing start or end must fail. Assert
   that raw token count is not used as declaration count. Persist fixture names and outcomes in qualification evidence.
6. Freeze the qualified R4F driver bytes／size／SHA, qualification receipt, fixture results, and verified manifest.
   Reverify those identities immediately before creating one new formal root and one durable `R4F_ATTEMPT_BEGIN`.
   The marker records the exact expected branch／starting commit, candidate identities, qualification identities,
   formal mode／argv, and all formal counters at `0`.
7. After the marker, the driver is immutable and no alternate, repair, restart, or retry is allowed. Execute strictly:
   sequential repository identity checks; candidate-008 lineage once; full static audit once; only if both pass, the
   exact six-compile dependency set once each; only if all six pass, the two approved PowerShell parse-only checks once
   each; then always finalize parseable JSON and a complete verified manifest.
8. Compile outputs, if gated in, go only to a new external R4F compile root and must never be launched. Prove
   candidate-008 unchanged before／after; generated-output launch, StagePreparer launch, PA selftest, six-mode, Stage,
   seal, PREPARED, PREACK, performance slots, A／B／C, P95, KBM, and game all remain `0`／Not run.
9. Return all frozen R4F qualification and formal evidence to `00統括` and stop. No automatic follow-on is allowed.

A complete lineage／static／six-compile／two-parse closure is **R4F Pass / corrected external extractor and candidate
compile／parse closure only**. A real line-anchored static, compile, or parse nonconformance is **R4F Fail / candidate
harness integration defect**. Qualification failure, identity mismatch, missing durable evidence, or interruption is
**R4F Blocked**. Even an R4F Pass leaves `MFO-WO-P2-2A-010` pre-PREPARED Blocked and
`MFO-HOLD-P2-2A-001` active. It does not authorize performance, Gate 2, Slice 2-B, or user quiet-window preparation.
