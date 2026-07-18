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
- Status: **Active / pre-PREPARED Recovery Step R5K-C authorized / performance not started**
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

## 19. Supervisor closure — R4F execution-infrastructure Blocked and Recovery Step R4G

R4F returned **Blocked / execution infrastructure interrupted before driver preparation**. QA directly confirmed the
required branch, local HEAD, remote-tracking HEAD, and tracking-clean status at supervisor commit
`15e4d007fcf9e954b48a2599062363ba324e337c`, then every normal process launch failed at the Codex unified-exec
boundary with `helper_unknown_error: apply deny-read ACLs`. A directly targeted read and one independent read-only
subagent probe were both refused before process start. QA terminated non-producing sessions rather than infer or
reconstruct driver bytes.

No R4F driver was created, copied, edited, or run. Qualification root／receipt／fixture／manifest,
`R4F_ATTEMPT_BEGIN`, formal root, candidate lineage／static／compile／PowerShell parse, generated output,
StagePreparer, PA self-test, six-mode, Stage／seal／PREPARED／PREACK, performance, A／B／C, P95, KBM, and game all
remain `0`／Not run. Candidate-008, every R4E artifact, and the repository are unchanged. This is not a
candidate, harness, game, or performance Fail.

The same normal-sandbox failure was reproduced by `00統括`. A single supervisor-side state-free
`require_escalated` probe, `cmd.exe /d /s /c "echo MFO_R4F_SUPERVISOR_PROBE"`, returned exit `0`.
Section 19 therefore supersedes Section 18 only for the bounded execution-transport recovery below. The sole
authorized continuation is **Recovery Step R4G / elevated capability preflight followed conditionally by the unchanged
R4F qualification and one formal closure**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 19. Require exact
   local／origin HEAD and clean worktree. `00統括` supplies the exact starting SHA after push. Do not insert a
   receipt commit before closure.
2. Freeze candidate-008; all R4E qualification／closure／formal artifacts and drivers; and the R4F return facts.
   Do not create synthetic R4F artifacts, repair old roots, backfill evidence, edit the candidate, or create
   candidate-009.
3. Before any driver read／copy／creation or qualification attempt, issue exactly one state-free process capability
   probe through the tool's `require_escalated` path:
   `cmd.exe /d /s /c "echo MFO_R4G_PREFLIGHT"`, with the repository as working directory. It must return numeric
   exit `0`, exact stdout `MFO_R4G_PREFLIGHT` plus the platform newline, and empty stderr. Do not request or use
   a reusable command-prefix approval, and do not retry, alternate, or repair this probe. Failure, timeout, missing
   numeric exit, or output mismatch is **R4G Blocked** and requires immediate return with every R4G formal counter `0`.
4. Only after the probe Pass, create a fresh explicitly named external R4G driver path and qualification root
   outside the tracked repository, then persist the exact preflight command／exit／stdout／stderr readback before the
   first qualification check. Because the normal sandbox transport is the confirmed blocker, each process invocation
   needed for this bounded audit may separately request `require_escalated` with a user-facing justification; no
   reusable prefix approval is allowed. Constrain every invocation to repository read-only checks, QA-owned external
   driver／evidence roots, and the conditional external compile root. Do not change repository files, ACLs, OneDrive
   state, power state, or network state; do not use network access.
5. Repeat Section 18 items 3 through 8 with mechanical R4G identities: the only semantic driver correction remains
   exact line-anchored start／end declaration extraction; every qualification attempt is root-first and immutable;
   Unicode transport, sequential Git, candidate eight-file identity-only readback, intentional primary／secondary
   failure isolation, JSON-safe process closure, complete manifest, and all required synthetic extractor fixtures are
   mandatory.
6. Freeze and reverify the qualified driver and qualification identities, then create exactly one
   `R4G_ATTEMPT_BEGIN`. After the marker, no alternate, repair, restart, retry, or transport change is allowed.
   Execute sequential repository identity checks, candidate-008 lineage once, full static audit once, conditional
   exact six-compile once each, conditional two approved PowerShell parse-only checks once each, and always finalize
   parseable JSON plus a complete verified manifest.
7. Generated outputs must never be launched. StagePreparer execution, PA self-test, six-mode, Stage／seal／PREPARED／
   PREACK, performance slots, A／B／C, P95, KBM, game, user quiet-window preparation, OneDrive shutdown, and power
   changes remain prohibited. Return all frozen R4G evidence to `00統括` and stop.

A complete probe／qualification／lineage／static／six-compile／two-parse closure is **R4G Pass / corrected external
extractor and candidate compile／parse closure only**. A real line-anchored static, compile, or parse nonconformance is
**R4G Fail / candidate harness integration defect**. Capability-probe failure, qualification failure, identity
mismatch, missing durable evidence, or interruption is **R4G Blocked**. Even an R4G Pass leaves
`MFO-WO-P2-2A-010` pre-PREPARED Blocked and `MFO-HOLD-P2-2A-001` active. It does not authorize
performance, Gate 2, Slice 2-B, or automatic follow-on.

## 20. Supervisor closure — R4G call-site-boundary Fail and Recovery Step R4H

R4G completed its exact-one elevated preflight and qualification attempt-001. The preflight returned numeric exit
`0`, stdout `MFO_R4G_PREFLIGHT` plus CRLF only, empty stderr, and result SHA-256
`f03962d65bcb5369f319f39c556b3d11109340f51f4a22e9a46f485015453a24`. The qualified driver is
`56598` bytes with SHA-256 `270315690a05b56fa1406ffcd588a8a99c259e90f5e2fa520f74e6af6f32a17b`.
Its qualification manifest SHA-256 is
`28422a3f5307159f0a99bd92aa05f56b30a7d2de96f6179eb0dc125710e0d1ee` with `30 / 30` payloads;
all LF／CRLF positive and duplicate／missing declaration negative fixtures passed.

The sole formal attempt returned a machine classification of **R4G Fail / candidate harness integration defect** at
the first static nonconformance: `missing declaration:     public sealed class PerformanceOwnedChild`. Repository
checks ran `4`, lineage ran once and passed, static ran once and stopped, compiler and candidate PowerShell parse
counts remained `0`. The formal marker SHA-256 is
`e26141df0203d5ba9ec97fa38c2a56b9342e522e6b89e3f7c1338b32a74d68ae`; formal final SHA-256 is
`7c200da69cf69cff344ccc58f5e85b1303737988d9600946db9216244c7dcd76`; formal manifest SHA-256 is
`3396f654b28cc689ae5a49aac21848e6e2b96d0731bc3adc7401f746aeda31a7` with `49 / 49` payloads.
All qualification and formal artifacts are frozen. Candidate-008 remained `8 / 8` unchanged and the repository
remained exact and clean.

`00統括` attributes this result to the external audit-driver call-site boundary, not to candidate-008. Frozen
candidate Native line 1279 is exactly
`    public sealed class PerformanceOwnedChild : IDisposable`. Frozen R4G driver line 416 passed the shorter
exact-line start boundary `    public sealed class PerformanceOwnedChild` to the qualified extractor. The end
boundary `    public sealed class PerformanceCounts` matches candidate line 1608. Because the extractor correctly
requires an exact whole declaration line, the shorter call-site token cannot match. There is no evidence that the
candidate declaration is absent, and compile／parse remained `0`, so candidate-008 remains unevaluated.

Section 20 supersedes Section 19 only for the bounded correction below. The sole authorized continuation is
**Recovery Step R4H / full-declaration call-site-boundary qualification and one frozen candidate-008 formal closure**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 20. Require exact
   local／origin HEAD and clean worktree. `00統括` supplies the exact starting SHA after push. Do not insert a
   receipt commit before closure.
2. Freeze candidate-008; all R4E, R4F, and R4G driver／qualification／closure／formal artifacts; and all returned
   identities. Do not repair, backfill, normalize, clean up, reuse a prior path, edit candidate source, or create
   candidate-009.
3. Before any R4H driver operation, execute exactly one state-free `require_escalated` capability probe:
   `cmd.exe /d /s /c "echo MFO_R4H_PREFLIGHT"`. Require numeric exit `0`, exact stdout
   `MFO_R4H_PREFLIGHT` plus the platform newline, and empty stderr. Do not request a reusable prefix approval,
   retry, alternate, or repair. Any mismatch is **R4H Blocked** with every R4H formal counter `0`.
4. Only after probe Pass, create fresh explicitly named external R4H driver／qualification roots outside the tracked
   repository and persist the probe readback before the first qualification check. Each required process invocation
   may separately request `require_escalated` with a user-facing justification; no reusable prefix approval is
   allowed. Repository access is read-only. Writes are limited to QA-owned external driver／evidence roots and the
   conditional external compile root. Repository, ACL, OneDrive, power, and network state must not change; network
   access is prohibited.
5. Derive the new driver from the frozen qualified R4G driver. The sole formal-path semantic correction is the
   exact call-argument replacement
   `    public sealed class PerformanceOwnedChild`
   → `    public sealed class PerformanceOwnedChild : IDisposable`.
   Preserve the exact-line extractor, end boundary `    public sealed class PerformanceCounts`, transport,
   closure, counters, and all prior fixtures. The qualification-only binding fixture in item 6 is evidence logic,
   not an additional formal-path semantic correction. Mechanical R4H identity and directly related qualification
   evidence fields may change.
6. Qualification must be root-first and immutable and must repeat every R4G transport／closure／extractor fixture.
   Add a named call-site-binding fixture that validates by exact call-argument equality—not substring or token count—
   that the same full start and end values above are supplied to the formal invocation, and that the former shortened
   value is absent as an exact formal argument. This fixture must fail closed before marker, lineage／static, compile,
   or parse. Any qualification nonconformance freezes that root／driver and returns R4H Blocked without retry, leaving
   candidate-008 unevaluated. Freeze and reverify the driver, preflight evidence, receipt, fixture results, and
   complete verified manifest before formal execution.
7. Create exactly one `R4H_ATTEMPT_BEGIN`. After the marker, no alternate driver, repair, restart, retry, or
   transport change is allowed. Execute sequential repository identity checks and candidate-008 lineage once. The
   single full static audit must first prove that the corrected start declaration line and unchanged end declaration
   line each occur exactly once as whole declaration lines in unchanged candidate-008 before extracting the region.
   Only if static passes, run the conditional exact six-compile once each and, only if all six pass, the conditional
   two approved PowerShell parse-only checks once each. Always finalize parseable JSON plus a complete verified
   manifest.
8. Generated outputs must never be launched. StagePreparer execution, PA self-test, six-mode, Stage／seal／PREPARED／
   PREACK, performance slots, A／B／C, P95, KBM, game, user quiet-window preparation, OneDrive shutdown, and power
   changes remain prohibited. Return all frozen R4H evidence to `00統括` and stop.

A complete probe／qualification／lineage／static／six-compile／two-parse closure is **R4H Pass / corrected external
driver call-site and candidate compile／parse closure only**. A real static, compile, or parse nonconformance is
**R4H Fail / candidate harness integration defect**. Probe／qualification failure, identity mismatch, missing durable
evidence, or interruption is **R4H Blocked**. Even an R4H Pass leaves `MFO-WO-P2-2A-010` pre-PREPARED Blocked
and `MFO-HOLD-P2-2A-001` active. It does not authorize performance, Gate 2, Slice 2-B, or automatic follow-on.

## 21. Supervisor closure — R4H Pass and Recovery Step R5 Stage P preparation

R4H returned **Pass / audit-driver qualified and corrected static matcher compile／parse closure only**. Its exact-one
preflight returned exit `0` with result SHA-256
`5f10590b05b5dfba3507b515b08ff5824f485796c0f5272d6e9bcd0a2b58e067`. The qualified driver is
`60801` bytes with SHA-256 `4547737e2342dc1e6011261194be366fb128ad461f39f3df2e9b4a0bd878864a`;
qualification manifest SHA-256 is
`e983d24b878f1847d36add33924f709345514d7296116a48fee906b595ffff58` with `31 / 31` payloads. Every
R4G extractor fixture and the exact whole-invocation binding fixture passed.

The sole formal attempt returned exit `0`. `R4H_ATTEMPT_BEGIN` SHA-256 is
`46d1829ac8cea67fb951e56c2ebfb83d0f2307d45c07d5d4963efaecaa279005`; final SHA-256 is
`7bede80e9bc49b27384b1b3876820011ca06db26fb3c62a869705decbb4de753`; formal manifest SHA-256 is
`cc4eec182023d85fcce2e57da4e4f042b35eeae4e6dedb8026b99f57f31ae5ed` with `112 / 112` payloads.
Repository checks `8`, lineage `1`, static `1`, exact six compile, and exact two approved PowerShell
parse-only checks all passed. Candidate-008 remained `8 / 8` byte-identical. Generated outputs were never
launched, and StagePreparer, PA self-test, six-mode, Stage／seal／PREPARED／PREACK, performance, A／B／C, P95, KBM,
and game all remained `0`／Not run. All R4H artifacts are frozen.

The supervisor accepts R4H and resolves KI-017 for audit-driver／static matcher compile／parse closure. This is not
Stage P qualification or performance acceptance. Section 21 supersedes Section 20 only for the bounded preparation
continuation below. The sole authorized continuation is **Recovery Step R5 / immutable candidate-008 fresh Stage P,
six-mode, seal, and PREPARED closure**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 21. Require exact
   local／origin HEAD and clean worktree. `00統括` supplies the exact starting SHA after push. Do not insert a
   receipt commit before preparation.
2. Freeze candidate-008; all candidate-003 through candidate-007 history; all R1 through R4H driver／qualification／
   closure／compile／parse artifacts; and every earlier Stage／evidence root. Candidate-008 must retain inventory
   SHA-256 `fef65dceee8d2bbf456034edcd0a828a96eea18d47d672179230ced367e80689`; its
   `preparation-tools/StagePreparer.cs` must remain `219016` bytes with SHA-256
   `2baa9e55266117b12df63d41229e0836eea7bdb02d11952f97df33cfdf730b5a`; all eight R4H-qualified file
   identities must match. Do not edit, normalize, repair, clean up, or reuse prior bytes or paths. Candidate-009 and
   any source／script change are prohibited. For R5, this rule explicitly supersedes any earlier Section 3 permission
   to repair or create a new candidate after a pre-PREPARED failure.
3. Before any preparation operation, execute exactly one state-free `require_escalated` capability probe:
   `cmd.exe /d /s /c "echo MFO_R5_PREP_PREFLIGHT"`. Require numeric exit `0`, exact stdout
   `MFO_R5_PREP_PREFLIGHT` plus the platform newline, and empty stderr. Do not request a reusable prefix
   approval, retry, alternate, or repair. Before deciding Pass, durably persist and read back the exact command,
   numeric exit, stdout, stderr, their byte counts／SHA-256 values, and a complete result record outside the repository.
   Any missing field, readback mismatch, or probe mismatch is **R5 Blocked** with StagePreparer／mode／Stage／slot／
   A-B-C launch counters `0`.
4. Only after probe Pass, use candidate-008 exactly as frozen and reserve one unique fresh external preparation
   parent, one fresh Stage P path, and the configured external run path outside every OneDrive directory. Before
   `INIT`, the Stage P and run paths must both be absent; only the external parent／tool-build root may exist. `INIT`
   alone creates the Stage P path. Each required process invocation may separately request
   `require_escalated` with a user-facing justification; no reusable prefix approval is allowed. Repository
   reads are allowed, but writes before successful PREPARED fixation are prohibited. Do not change ACL, OneDrive,
   power, network, or user-input state; network access is prohibited. Normal user input may continue: do not request
   a quiet window, OneDrive shutdown, AC connection, or power-mode change under R5.
4a. Do not reuse or reference any frozen R4H compiled DLL／EXE or prior tool-build path. Before the Stage attempt and
   outside `preparation_attempt_count`, create one fresh external tool-build root and use the accepted compiler
   `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe` only. Compile candidate-008
   `source/MfoQaNative.cs` to one fresh helper DLL exactly once; then compile candidate-008
   `preparation-tools/StagePreparer.cs` to one fresh x64 optimized EXE exactly once, referencing only that fresh helper
   DLL and the same approved framework references used by the R4H six-compile closure. Persist and read back each exact
   command, numeric exit, stdout, stderr, output size／SHA-256, compiler identity, and reference identity. Require
   `tool_build_attempt_count=1`, native-helper compile count `1`, StagePreparer compile count `1`, and retry `0`.
   Do not launch either output during tool build. A real source／compile nonconformance is R5 Fail; identity／compiler／
   evidence／execution interruption is R5 Blocked. In either case do not create the Stage or attempt another build.
4b. Keep the frozen candidate's internal issuance identities unchanged. Pass
   `--supervisor-commit 808492231ec601da8422691d0bae5a2f8ff35ec1` to all three StagePreparer lifecycle
   launches and pass `--qa-receipt-commit eda2ac8de05d87b995e7befb8b7ecf9a85170817` to `CONTRACT` and
   `SEAL`. These are candidate contract identities, not the current repository execution HEAD. Repository-state
   observations must use required branch `codex/phase2-slice2a-performance-acceptance-qa` and the exact current pushed
   supervisor clarification HEAD supplied by `00統括`. Do not create another receipt commit.
5. Execute exactly one end-to-end candidate-008 preparation attempt. Within that single attempt, use the existing
   production lifecycle with exactly three StagePreparer process launches and no others. Run the fresh StagePreparer
   `INIT` exactly once; then run frozen candidate-008 `preparation-tools/RecordRepositoryState.ps1` exactly once with
   `ObservationKind=RepositoryState`, the required branch, and the current pushed supervisor clarification HEAD; then
   run `CONTRACT` exactly once. Next run each Section 3 mode exactly once in this order: `QP_DRYRUN`, `QP_SELFTEST`,
   `QP_POWER_INPUT_SMOKE`, `QP_PREACK_CONTRACT_SELFTEST`, `QP_LIVE_EVIDENCE_CONTRACT_SELFTEST`, and
   `PA_PERFORMANCE_CONTRACT_SELFTEST`. After all six Pass, run the same frozen repository-state script exactly once
   with `ObservationKind=PreSealOwnership`, required branch／HEAD, and residual QA subagent／background harness process／
   attached terminal counts `0`; only then run `SEAL` exactly once. Record `preparation_attempt_count=1`,
   `stagepreparer_launch_count=3`, `repository_state_script_launch_count=2`, each lifecycle-mode launch count `1`, and
   each six-mode launch count `1`. Real performance-slot attempt／launch and real
   A／B／C launch counts must remain `0`. PA self-test may exercise fixtures only. This paragraph corrects the former
   phrase `StagePreparer at most once`; that phrase referred incorrectly to the process count. The exact-one boundary
   applies to the end-to-end preparation attempt, not to its three required lifecycle launches. This is a supervisor
   work-order wording correction, not a candidate or harness defect. The already-completed preflight is outside
   `preparation_attempt_count`. The exact lifecycle／six-mode counts above are successful-closure requirements and each
   individual launch remains at most one; on any failure, preserve the actual partial counts and stop at once—never
   launch a remaining lifecycle phase or mode merely to reach the success counts.
6. Require the complete Section 3 source-diff audit against the qualified `-009` source, authorized-hunk
   classification, unrelated-region byte identity, immutable A／B／C size／MZ／SHA／source／staged-path audit, fixed
   six-slot table and arguments, tool-build attempt count `1` with two exact compile invocations, preparation
   attempt count exactly `1`, StagePreparer launch count exactly `3` (`INIT=1`, `CONTRACT=1`, `SEAL=1`), repository-
   state script launch count exactly `2` with the required observation kinds, and each six-mode exact invocation／
   numeric exit／result／launch count exactly `1`,
   all six modes Pass, candidate-008 identities unchanged, complete manifest, preparation receipt, preparation audit,
   residual QA agent／process／terminal `0`, external run root absent,
   owned runtime `0`, and slot／A-B-C launch counts `0`.
7. If any preflight, identity, source-diff, mode, evidence, process, or seal prerequisite fails, stop immediately.
   Preserve the fresh attempted root／stage and return R5 Fail for an actual candidate／harness qualification
   nonconformance or R5 Blocked for execution／identity／evidence interruption. Do not repair, reseal, retry, create a
   new candidate, or start a second preparation attempt under R5. On any Fail／Blocked result, do not modify or commit
   repository files; freeze the external evidence and return it directly to `00統括`.
8. Only if every requirement passes, create and verify the complete manifest／receipt／preparation audit, make the
   stage root and every stage file／directory ReadOnly, and reverify every identity and zero counter. Then commit and
   push only `docs/test-reports/phase2-slice2a-performance-acceptance.md`, non-executable preparation evidence under
   `docs/test-reports/evidence/phase2-slice2a/diagnostic-004/` allowed by Sections 2 and 3, and
   `docs/handoffs/qa.md`; send the exact PREPARED line
   defined in Section 3. Do not commit harness binaries, A／B／C executables, or timed-output payloads.
9. Stop after PREPARED return. PREACK, activation, controller, performance slots, A／B／C game execution, P95, KBM,
   game, user quiet-window preparation, OneDrive shutdown, and power changes remain prohibited until a new exact
   **PERFORMANCE WINDOW READY** instruction from `00統括`.

Successful completion is **R5 Pass / Stage P PREPARED only**. It does not accept performance, close
`MFO-HOLD-P2-2A-001`, open Gate 2, or authorize Slice 2-B. No automatic follow-on is allowed.

## 22. Supervisor closure — R5 Unicode-driver Blocked and Recovery Step R5A

R5 returned **Blocked / external orchestration driver Unicode decoding before tool compile**. The formal driver was
started exactly once from a BOM-less UTF-8 file. Windows PowerShell 5 decoded the repository literal
`C:\Users\osato\OneDrive\ドキュメント\MF` as mojibake and failed while opening the qualified `-009` baseline,
after candidate／compiler identity checks but before any compiler process or Stage operation. The driver is `26091`
bytes with SHA-256 `17409f14c83aac7a47f3cc25d354aca0ac694bf544fc0a67cf926e47ac7b7274`.
`TOOL_BUILD_ATTEMPT_BEGIN.json` is `763` bytes with SHA-256
`1ceedce271afb39145bbc1f3367a2ff4911c526a0715c881987c42dc6625e98a`; `r5-failure.json` is `1523` bytes with
SHA-256 `f262ecb69e6671dcdf6c1c53fa9662baa2dea2f2187b7c2557d1b01673e3fd62`. Those two files, their directories,
the driver, and every earlier artifact remain frozen.

The historical R5 counters are tool-build marker `1`, Native-helper compile `0`, StagePreparer compile `0`,
preparation attempt `0`, all lifecycle／six-mode／performance／A-B-C／game launches `0`. The preparation root, Stage,
external run root, fresh DLL, and fresh EXE were never created. Candidate-008 and the repository remained unchanged.
The supervisor therefore attributes R5 to the external driver encoding boundary, not to candidate, harness, game, or
performance. Section 22 supersedes Section 21 only for this one bounded recovery. The sole authorized continuation is
**Recovery Step R5A / ASCII-qualified external driver then one fresh tool build and Stage P preparation closure**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 22. Require exact
   local／origin HEAD and clean worktree. Do not create a receipt commit before preparation. Freeze the R5 driver and
   partial evidence, candidate-008, every R1 through R5 artifact, and every prior root; do not edit, delete, move,
   normalize, repair, or reuse them.
2. Reuse and reverify the already completed `MFO_R5_PREP_PREFLIGHT` evidence. Do not invoke that preflight again and
   do not create another general capability probe. Record inherited R5 preflight count `1` and R5A preflight count `0`.
3. At a fresh external path, create one new R5A orchestration driver whose every byte is 7-bit ASCII (`< 0x80`), with
   no BOM and non-ASCII byte count `0`. It must contain no Japanese path literal. Obtain the repository root from the
   process `WorkingDirectory`; construct the expected `ドキュメント` segment only from code points
   `U+30C9 U+30AD U+30E5 U+30E1 U+30F3 U+30C8`, then compare the complete path ordinal-exactly.
4. Before any tool-build root or formal marker exists, parse that driver with Windows PowerShell 5 and run exactly one
   state-free qualification mode. Qualification must prove and durably record all of the following without repository
   writes, compiler launch, generated-output launch, candidate edit, Stage creation, or network access:
   - driver byte identity／SHA-256, ASCII-only property, parser error `0`, actual working-directory UTF-8 bytes／SHA,
     exact expected-path equality, directory existence, and rejection of the known mojibake form;
   - readable exact identities for the qualified `-009` baseline, all eight candidate-008 files, accepted compiler,
     StagePreparer source, and both preparation PowerShell inputs, using the same path-resolution functions as formal;
   - Git child processes use the repository as `WorkingDirectory`, never concatenate its Unicode path into
     `ProcessStartInfo.Arguments`, and sequentially return the required branch, exact supervisor HEAD, matching origin
     HEAD, and clean status;
   - a root-first complete qualification receipt／result／manifest is persisted and read back, an intentional negative
     fixture retains its named primary classification, all qualification files plus the driver become ReadOnly, and
     tool-build／compile／Stage／mode／performance／A-B-C counters remain `0`.
   Any qualification, encoding, readback, identity, or infrastructure nonconformance is **R5A Blocked**. Freeze it and
   stop without creating a tool-build root or alternate driver. After qualification begins, driver repair, alternate,
   retry, and a second qualification attempt are prohibited.
5. Only after qualification Pass, reverify the frozen driver SHA and create exactly one `R5A_ATTEMPT_BEGIN`, one unique
   fresh external tool-build root, preparation parent, Stage path, and configured run path outside OneDrive. Stage and
   run paths must be absent before `INIT`. Do not reuse the failed R5 root or any R4H output／path. Record historical
   R5 and R5A-local counts separately: prior R5 tool-build marker `1`, R5A tool-build attempt `1`, aggregate `2`;
   Stage-local `tool_build_attempt_count=1` means the R5A build that produced that Stage.
6. From immutable candidate-008, compile a fresh Native helper DLL exactly once, then compile a fresh x64 optimized
   StagePreparer EXE exactly once referencing only that fresh DLL and the approved framework references. Persist and
   read back exact commands, numeric exits, streams, compiler／reference identities, and output size／SHA-256.
   Generated-output launch during tool build is `0`. A source／compile nonconformance is **R5A Fail / candidate harness
   integration defect**; identity／evidence／execution interruption is **R5A Blocked**. Stop at the first failure.
7. If and only if the tool build passes, execute the Section 21 lifecycle once using the fresh StagePreparer:
   `INIT` → `RepositoryState` → `CONTRACT` → the six modes in the exact Section 21 order → `PreSealOwnership` →
   `SEAL`. Keep candidate contract identities `808492231ec601da8422691d0bae5a2f8ff35ec1` and
   `eda2ac8de05d87b995e7befb8b7ecf9a85170817`; repository observations use this Section 22 supervisor HEAD.
   Successful R5A-local counts are driver qualification `1`, tool-build attempt `1`, compile launches `1 / 1`,
   preparation attempt `1`, StagePreparer `3`, repository-state script `2`, each six-mode `1`, and real performance
   attempt／launch and A-B-C launch `0`. Preserve actual partial counts and stop on the first nonconformance.
8. Apply every Section 21 source-diff, A／B／C identity, evidence-completeness, residual-process, ReadOnly-seal, and
   PREPARED requirement unchanged. R5A permits no candidate edit, candidate-009, second driver, second qualification,
   repair, retry, reseal, second build, or second Stage. The exception to R5's no-second-attempt rule exists only
   because R5 reached zero compiler and zero preparation launches; it does not authorize retry of candidate or Stage.
9. On Fail／Blocked, freeze external evidence and return directly with no repository change. Only on complete Pass may
   QA commit／push the same three tracked result scopes allowed by Section 21 and return exactly:

   ```text
   MFO-WO-P2-2A-010 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex>
   ```

Stop after PREPARED. PREACK, activation, controller, performance, A／B／C execution, P95, KBM, game, quiet-window
preparation, OneDrive shutdown, and power changes remain prohibited. R5A Pass is Stage P PREPARED only; it does not
close the hold, open Gate 2, or authorize Slice 2-B.

## 23. Supervisor closure — R5A qualification serialization Blocked and Recovery Step R5B

R5A returned **Blocked / external orchestration evidence serialization defect during exact-one qualification**. Its
new driver was `37286` bytes with SHA-256
`8762f09cb66f87b865beccd091684203bf86c436851db982784dcca2978322c8`, contained zero non-ASCII bytes, had no BOM,
and parsed with zero Windows PowerShell errors. The exact-one qualification proved root-first receipt readback, the
actual Unicode repository path by ordinal comparison, mojibake rejection, the qualified `-009` baseline,
candidate-008 `8 / 8`, compiler, StagePreparer／PowerShell input identities, and inherited R5 preflight identities.

The first Git child (`branch`) then exited `0` and persisted stdout. Its normal empty stderr reached the same
`Write-NewBytes` path, whose mandatory `byte[]` parameter rejected an empty collection before the zero-byte file could
be written. The qualification stopped without repair or retry. Frozen evidence includes qualification-begin SHA-256
`80dec7c5cf1cbc23da4ce3382235d5e1e9480c2ad5ad1f47658d87eead504a68`, receipt SHA-256
`dc860b5318c058b95c31eb09acbfda140337f06349ad40f3202d1983a5702cc4`, failure SHA-256
`355999090e3ecf12c29fbee8ea047338d441f5f710caee35d577d04310ea3251`, and manifest SHA-256
`5904ab28f19092bc67dc4acde2784c8a6d6bddf3314fe54478a3915af2c49281`. The root has `9` files, all ReadOnly.

R5A formal marker, tool-build attempt, both compiler launches, preparation attempt, Stage, all modes, PREACK,
performance, A／B／C, and game remained `0`; all formal／tool／preparation／Stage／run roots remained absent.
Candidate-008 and the repository remained unchanged. The supervisor attributes this result to the external
qualification driver's empty-stream serialization boundary, not to candidate, production harness, game, or
performance. Section 23 supersedes Section 22 only for the one correction below. The sole authorized continuation is
**Recovery Step R5B / empty-stream-qualified driver then one fresh tool build and Stage P preparation closure**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 23. Require exact
   local／origin HEAD and clean worktree. Freeze every R5／R5A driver, root, receipt, partial command, failure, manifest,
   candidate, and earlier artifact; do not edit, delete, move, normalize, repair, or execute them again. Do not create a
   preparation receipt commit.
2. Reverify the inherited `MFO_R5_PREP_PREFLIGHT` evidence without invoking it again. Record inherited count `1` and
   R5B preflight count `0`. Candidate-008 remains immutable with the Section 21 identities.
3. Create one fresh `c2` ASCII-only driver at a new external path. Relative to frozen R5A `c1`, permitted driver changes
   are limited to:
   - mechanical R5A→R5B identity, fresh driver／qualification／formal／tool／preparation／Stage／run paths, and this
     Section 23 supervisor HEAD;
   - the single production serialization correction needed to allow an empty `byte[]` argument at
     `Write-NewBytes` (for example exact `[AllowEmptyCollection()]` on that parameter), without changing non-empty
     persistence／readback behavior;
   - one qualification-first fixture that writes and reads back an empty byte array and empty text through the same
     production functions before the first Git child.
   No other function, evidence field, process behavior, abstraction, or fixture may change. Before invocation, persist
   a complete `c1`→`c2` diff audit and require all unrelated bytes／semantics unchanged. The new driver must again be
   7-bit ASCII-only, no BOM, non-ASCII count `0`, and parser errors `0`.
4. Run exactly one root-first state-free R5B qualification. Its first production-path fixture must create exact
   zero-byte binary and text files, read back length `0`, and record SHA-256
   `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`. Then execute every Section 22 Unicode-path,
   mojibake-negative, baseline／candidate／compiler／input, sequential branch→HEAD→origin→clean, intentional-negative,
   complete receipt／result／manifest, ReadOnly, and zero-formal-counter check unchanged. The normal empty stdout or
   stderr from any successful Git child must be persisted and read back as a valid zero-byte payload.
5. Qualification start consumes the only R5B qualification attempt. After it starts, driver repair, alternate driver,
   retry, second qualification, cleanup, and evidence rewriting are prohibited. Any serialization, identity,
   completeness, path, readback, or infrastructure nonconformance is **R5B Blocked** with formal／compiler／Stage
   counters `0`.
6. Only after complete qualification Pass, freeze and reverify the exact c2 driver SHA, create one
   `R5B_ATTEMPT_BEGIN`, and perform one fresh tool build and one Stage P preparation using Sections 21／22 unchanged:
   Native helper compile `1`, StagePreparer compile `1`, then
   `INIT` → `RepositoryState` → `CONTRACT` → six modes → `PreSealOwnership` → `SEAL`.
   Internal candidate identities remain `808492231ec601da8422691d0bae5a2f8ff35ec1` and
   `eda2ac8de05d87b995e7befb8b7ecf9a85170817`; repository observations use the Section 23 supervisor HEAD.
   R5B-local successful counts are qualification `1`, tool-build `1`, compile `1 / 1`, preparation `1`,
   StagePreparer `3`, repository-state script `2`, each six-mode `1`, and real performance／A-B-C／game `0`.
7. Preserve historical R5 and R5A counts separately. R5B permits no candidate edit, candidate-009, second c2 driver,
   second build, second Stage, repair, retry, or reseal. A real compile／source-diff／mode／seal nonconformance after
   qualification is **R5B Fail / candidate harness preparation nonconformance**; execution／identity／evidence
   interruption is **R5B Blocked**. Stop at the first nonconformance and preserve actual partial counts.
8. On Fail／Blocked, freeze external evidence and return without repository changes. Only on full Pass may QA commit
   and push the same three tracked result scopes allowed by Section 21 and return exactly:

   ```text
   MFO-WO-P2-2A-010 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex>
   ```

Stop after PREPARED. PREACK, activation, controller, performance, A／B／C execution, P95, KBM, game, quiet-window
preparation, OneDrive shutdown, and power changes remain prohibited. R5B Pass is Stage P PREPARED only; it does not
close the hold, open Gate 2, or authorize Slice 2-B.

## 24. Supervisor closure — R5B CONTRACT Fail and Recovery Step R5C

R5B returned **Fail / candidate harness preparation nonconformance** after its exact-one driver qualification had
passed. The qualified c2 driver was `38404` bytes with SHA-256
`785296fe699ef44520746961ccc84e03e8e09c09e8e38520d3f6005ed9f0a8f6`. Zero-byte binary／text persistence,
normal empty Git streams, Unicode repository ordinal equality, mojibake rejection, baseline／candidate `8 / 8`,
compiler／input identities, branch→HEAD→origin→clean, receipt／result／manifest completeness, and ReadOnly closure all
passed. Qualification manifest SHA-256 is `a4be318b2561271865708146d5e34753117c3c80e0a7bc7635d45a5e46cd7ccc`;
KI-019 is resolved within this driver scope.

One fresh tool build then compiled Native and StagePreparer exactly once each with exit `0`. INIT and RepositoryState
passed. CONTRACT returned numeric exit `30` with result SHA-256
`e72caae6f45dbf797e91ae44b6b5f50b99c7d5758af886d8f9dae0efc4cd3f96` and exception `Native source changed
outside the authorized -010 methods`. Six-mode, PreSealOwnership, SEAL, PREACK, performance, A／B／C, and game remained
`0`. Candidate-008 stayed `8 / 8` unchanged and every R5B artifact is frozen.

Independent and QA read-only attribution identified two simultaneous CONTRACT inputs. The qualified `-009` Native
baseline `46b5bead5bae9c0a049a7c3acc4e9693aab52138546482f4546dad1fb616631d` is LF-only (`CRLF 0`, `LF 4362`, no BOM),
while candidate-008 Native `b3a0fa41fca91143c9ddbe9ec6e0acb4d2de2c35bbb419191f6e74d7bead970b` is mixed (`CRLF 121`,
LF-only `5895`, no BOM). The existing StagePreparer matcher also reports `24` unauthorized hunks among `54` because
its method allowlists omit Section 3 performance-evidence changes in `NativeApi`, `HarnessOps`, and `RunnerRole`, and
`SourceMethodAt` misclassifies a RoleContext field／property initializer as method `object>`. These are preparation
source-format and matcher-boundary nonconformances, not game or performance results.

Section 24 supersedes Section 23 only for the following **Recovery Step R5C / exact candidate-009 normalization and
matcher correction, then one Stage P closure**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 24. Require exact
   local／origin HEAD and clean worktree. Freeze candidate-008, c2, all R5B qualification／tool／preparation／Stage
   artifacts, and every earlier artifact. Do not modify, normalize in place, execute, delete, or move them.
   Candidate-008 and c2 may be read only as immutable seed bytes for the exact item 2／item 7 copies; no other reuse
   is authorized.
2. Create exactly one fresh candidate-009 by first copying candidate-008 byte-for-byte. Candidate-009 may change only
   `source/MfoQaNative.cs` and `preparation-tools/StagePreparer.cs`; the other six files must remain byte-identical.
3. In candidate-009 Native, perform only a byte-level replacement of every exact `0D 0A` pair with `0A`. Do not decode
   and re-encode the file and do not alter any other byte. Require source size `456570`, source SHA-256
   `b3a0fa41fca91143c9ddbe9ec6e0acb4d2de2c35bbb419191f6e74d7bead970b`, replacement count `121`, result size
   `456449`, result SHA-256 `d5068baeb983df3ee88f365d54876273e271c3c59446a22ebcbcfbabdb7de1a9`, `CR 0`, total `LF 6016`, and no BOM.
   After normalizing both inputs in memory to LF, candidate-008 and candidate-009 decoded line sequences must be exact.
4. In candidate-009 StagePreparer, change only the source-diff matcher:
   - `SourceMethodAt` must return existing `<class-scope>` when a public／private／internal line has `=` before its
     first `(`; this prevents field／property initializers from becoming the synthetic `object>` method;
   - add exact `GetSystemTimes` to the `NativeApi` authorized method set;
   - add exact `BuildPreackPendingObservation`, `PersistCompletePendingObservation`, `HasCompletePendingFieldSet`,
     `EvaluatePersistedPreackObservation`, `CaptureRawFile`, `BuildLiveActivationPendingObservation`,
     `EvaluatePersistedActivationObservation`, `BuildLauncherLivePendingObservation`, and
     `EvaluatePersistedLauncherLiveObservation` to the `HarnessOps` authorized method set;
   - add exact `AuditPreackContractBinding` to the `RunnerRole` authorized method set.
   No other parser rule, allowlist, production source, evidence field, fixture, process behavior, or StagePreparer
   behavior may change.
5. Before any Stage or formal tool-build root is created, persist a complete candidate-008→candidate-009 two-file
   diff and inventory. Require the Native transform to be newline-only, the StagePreparer changes to match item 4,
   all other bytes identical, baseline/candidate newline style both `LF`, BOM equality true, changed hunk count `54`,
   unauthorized hunk count `0`, and unauthorized changed class count `0`. If any value differs, stop as **R5C Fail /
   candidate correction nonconformance** without repair or retry.
6. Perform one compile／parse qualification closure for candidate-009: exact six C# compiles with exit `0`, exact two
   approved PowerShell parse-only checks with error count `0`, generated-output launch `0`, candidate identity stable,
   and relevant residual process `0`. Do not run StagePreparer, PA selftest, six-mode, game, or performance during this
   closure. Candidate byte drift, unauthorized diff, or a real compile／parse failure is R5C Fail. Identity readback,
   evidence completeness, or infrastructure failure is R5C Blocked.
7. Create one fresh c3 orchestration driver from frozen qualified R5B c2. Permitted c2→c3 changes are only mechanical
   R5B→R5C identity, fresh qualification／formal／tool／preparation／Stage／run paths, the Section 24 supervisor HEAD,
   candidate-009 path, and its newly recorded inventory. Preserve the qualified empty-collection／zero-byte and Unicode
   transport implementation byte-for-byte. Require 7-bit ASCII-only, no BOM, parser errors `0`, a complete diff audit,
   and no unrelated change. Freeze c3, then run exactly one root-first state-free `QUALIFY` invocation through the
   inherited R5B path. Reconfirm zero-byte binary／text, empty streams, Unicode ordinal／mojibake negative, baseline／
   candidate-009／compiler／input identities, branch→HEAD→origin→clean, complete receipt／result／manifest, ReadOnly,
   and all formal／tool／Stage／runtime counters `0`. No alternate or post-invocation repair is allowed.
8. After items 1–7 Pass, create one R5C formal marker, perform one fresh Native／StagePreparer tool build, and run one
   production lifecycle only: `INIT` → `RepositoryState` → `CONTRACT` → the six Section 3 modes in exact order →
   `PreSealOwnership` → `SEAL`. Require source-diff audit `54 / 54` authorized, ReadOnly stage, complete manifest／receipt／
   preparation audit, external run root absent, owned runtime `0`, performance slot attempt／launch `0`, and A／B／C
   launch `0`.
9. Candidate promotion, compile／parse closure, c3 qualification, tool build, and Stage lifecycle are each exact-one.
   Stop at the first nonconformance. No candidate-010, second driver, second Stage, repair, retry, reseal, cleanup of
   frozen evidence, or evidence rewriting is authorized. Preserve actual partial counts.
10. Only on complete Pass may QA commit／push the same three non-executable tracked result scopes allowed by Section 21
    and return exactly:

    ```text
    MFO-WO-P2-2A-010 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex>
    ```

Stop after PREPARED. PREACK, activation, controller, performance, A／B／C execution, P95, KBM, game, quiet-window
preparation, OneDrive shutdown, and power changes remain prohibited. R5C Pass is Stage P PREPARED only; it does not
close the hold, open Gate 2, or authorize Slice 2-B.

## 25. Supervisor closure — R5C pre-write Blocked and Recovery Step R5D

R5C returned **Blocked / promotion driver API incompatibility before file write**. QA created candidate-009 as one
exact copy of candidate-008 and verified `8 / 8` equality. Its one-off inline Windows PowerShell command then attempted
to validate the proposed Native bytes in memory with `[System.Security.Cryptography.SHA256]::HashData`, which does not
exist in the available Windows PowerShell 5／.NET Framework runtime. It stopped before ReadOnly removal and before either
candidate file write. Candidate-009 therefore remains seed-identical: Native `456570` bytes / SHA-256
`b3a0fa41fca91143c9ddbe9ec6e0acb4d2de2c35bbb419191f6e74d7bead970b`; StagePreparer `219016` bytes / SHA-256
`2baa9e55266117b12df63d41229e0836eea7bdb02d11952f97df33cfdf730b5a`; the other six files are also identical.

The inline helper stopped before it persisted its own bytes, exact command, numeric exit, separate raw streams, attempt
marker, evidence root, result, or manifest. Those artifacts are **absent / not durably captured** and must not be
reconstructed after the fact. Candidate correction writes, promotion diff, compile／parse, c3, QUALIFY, formal marker,
tool build, Stage, PREACK, performance, A／B／C, and game remained `0`; repository HEAD stayed exact and clean. This is
an external promotion-command compatibility／evidence Blocked result, not candidate, game, or performance Fail.

Section 25 supersedes Section 24 only for the following **Recovery Step R5D / one qualified PowerShell-5-compatible c3,
then one root-first FORMAL candidate-010 and Stage P closure**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 25. Require exact local／
   origin HEAD and clean worktree. Freeze candidate-008, candidate-009, R5B c2, the R5C thread transcript boundary,
   and all earlier artifacts. Candidate-008 and c2 may be read only as immutable seeds in items 2 and 5. Do not use
   candidate-009 as a promotion seed, and do not create a standalone or inline promotion helper.
2. Create one fresh c3 ASCII-only driver by copying frozen qualified R5B c2. Permitted c2→c3 changes are limited to:
   - mechanical R5B→R5D identities, Section 25 supervisor HEAD, and fresh qualification／formal／candidate-010／tool／
     compile-check／preparation／Stage／run paths;
   - one byte-array SHA-256 function implemented only with `SHA256.Create()`, `ComputeHash(byte[])`, disposal in
     `finally`, and manual lowercase two-hex-digit formatting per byte;
   - state-free QUALIFY fixtures for empty bytes, ASCII `abc`, candidate-008 Native CRLF→LF transformation, and the
     exact Section 24 item 4 StagePreparer matcher replacements;
   - the matching FORMAL promotion path that creates candidate-010 from candidate-008 and writes only the two approved
     files before continuing through the inherited compile／parse／Stage path.
   Preserve every qualified R5B zero-byte／empty-stream／Unicode transport／Git／receipt／result／manifest function and
   all unrelated driver behavior byte-for-byte.
3. The c3 source must contain zero `HashData` and zero `ToHexString` references, be 7-bit ASCII-only with no BOM and
   parser errors `0`, and have a complete c2→c3 diff audit with every changed line assigned to item 2. Freeze its bytes
   before invocation. Qualification start consumes the only c3 driver attempt; no repair, alternate, or retry follows.
4. Run exactly one root-first state-free c3 `QUALIFY`. Before its first child or fixture, persist／read back the driver
   identity, exact command, qualification-begin, and receipt. Re-run the inherited R5B zero-byte binary／text, empty
   stream, Unicode ordinal／mojibake negative, baseline／candidate／compiler／input, branch→HEAD→origin→clean, complete
   result／manifest, and ReadOnly checks. The new production hash function must return
   `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` for empty bytes and
   `ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad` for ASCII `abc`. In memory only, require the
   candidate Native result `456449` bytes / SHA-256 `d5068baeb983df3ee88f365d54876273e271c3c59446a22ebcbcfbabdb7de1a9`,
   replacement count `121`, CR `0`, LF `6016`, no BOM, and exact StagePreparer replacement counts. Candidate-010,
   formal／tool／compile／Stage roots and all runtime counts must remain absent／`0`.
5. Only after complete QUALIFY Pass, run c3 `FORMAL` exactly once. Persist／read back `R5D_ATTEMPT_BEGIN`, exact command,
   and c3 identity before candidate-010 creation. Copy candidate-008 to fresh candidate-010, require initial `8 / 8`
   equality, then write exactly two files once: Native by byte-level `0D 0A`→`0A` only and StagePreparer by the exact
   Section 24 item 4 matcher correction only. Require the Section 24 Native identity, other six files byte-identical,
   StagePreparer diff restricted to its parser／allowlists, Native changed hunk count `54`, unauthorized hunk `0`,
   unauthorized class `0`, LF style match, BOM match, and complete promotion inventory／diff evidence.
6. Continue within the same FORMAL attempt through one candidate-010 qualification closure and one Stage P lifecycle:
   exact six C# compiles exit `0`, two PowerShell parse-only checks error `0`, generated launch `0`; then one fresh
   Native／StagePreparer tool build and `INIT` → `RepositoryState` → `CONTRACT` → six Section 3 modes in order →
   `PreSealOwnership` → `SEAL`. Require source-diff `54 / 54` authorized, complete manifest／receipt／preparation audit,
   all files／directories ReadOnly, external run root absent, owned runtime `0`, performance slot attempt／launch `0`,
   and A／B／C launch `0`.
7. Any c3 serialization／path／readback／evidence／runtime interruption is R5D Blocked. Any driver diff outside item 2,
   candidate byte drift／unauthorized diff, real compile／parse／CONTRACT／mode／seal failure is R5D Fail. Stop at the
   first nonconformance. Candidate-011, second c3, second qualification, second FORMAL, repair, retry, reseal, frozen
   evidence cleanup, and repository changes on failure are prohibited.
8. Only on complete Pass may QA commit／push the same three non-executable tracked result scopes allowed by Section 21
   and return exactly:

   ```text
   MFO-WO-P2-2A-010 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex>
   ```

Stop after PREPARED. PREACK, activation, controller, performance, A／B／C execution, P95, KBM, game, quiet-window
preparation, OneDrive shutdown, and power changes remain prohibited. R5D Pass is Stage P PREPARED only; it does not
close the hold, open Gate 2, or authorize Slice 2-B.

## 26. Supervisor closure — R5D external hunk-oracle false negative and Recovery Step R5E

R5D returned **Fail / candidate harness preparation nonconformance** at its required fail-closed boundary
`R5D_FAIL_PROMOTION_HUNK_COUNT`. The stop itself was correct under Section 25: c3 QUALIFY passed, FORMAL created
candidate-010 and wrote the two approved files, then stopped before compile, parse, tool build, Stage, PREACK,
performance, A／B／C, or game. Supervisor review reattributes the cause to **external Git hunk-count acceptance false
negative**, not candidate, game, or performance defect.

The frozen R5D evidence is accepted as follows:

- c3: `65432` bytes / SHA-256 `078c1c9abd9dd3710eca6fbfe0b3f689c8952e5f259024bc6bcfba321016d9b5`;
  ASCII-only, no BOM, parser errors `0`, ReadOnly; c2→c3 audit manifest
  `5144f92c522285dcb33c812f9f62bbdbd3bebf2be90c7f46b2b386fc2ff41c25`, `45 / 45` classified, unauthorized `0`.
- QUALIFY: Pass; manifest `8c50f0030eec39f7acb98c1bbd071d55728866952b0c5181042e826303f92f5e`,
  `27 / 27` payload match, all state-changing counts `0`.
- FORMAL: manifest `cfebceffc544b276a93df1f56c0580fa2f39172414d05e432f9f0ca8382abac7`,
  `11 / 11` payload match; candidate creation `1`, candidate writes `2`, promotion-diff launches `2`; every downstream
  compile／parse／tool／Stage／runtime count `0`. The qualification and FORMAL roots and candidate-010 are frozen
  ReadOnly, repository HEAD remained exact and clean, and residual relevant process count is `0`.
- candidate-010 Native is the exact approved transform: `456449` bytes / SHA-256
  `d5068baeb983df3ee88f365d54876273e271c3c59446a22ebcbcfbabdb7de1a9`, exactly `121` CRLF→LF replacements,
  CR `0`, LF `6016`, no BOM. StagePreparer is `219515` bytes / SHA-256
  `76a2aa3a1dfefcdd08245eafa5d7fccdf9f8e6241b3abc47821bad6f1bfef1aa`, restricted to the four approved
  SourceMethodAt／NativeApi／HarnessOps／RunnerRole matcher hunks. The other six files are byte-identical to
  candidate-008.

The `53 / 54` difference is algorithm-specific. External
`git diff --no-index --unified=0 --ignore-space-at-eol` reports `53` hunks. StagePreparer
`BuildChangedLineHunks` uses its own LCS with a different repeated-blank-line alignment and reports `54` hunks for
the same logical baseline→candidate change. Candidate-008 normalized logical text is exactly candidate-010 text, so
newline conversion did not merge an internal hunk. The only segmentation difference is the RoleContext field／property
region: Git combines it into one hunk while the internal LCS splits it around a matched blank line. External Git hunk
count therefore must not be used as the StagePreparer internal hunk-count oracle.

Section 26 supersedes Section 25 only for the following **Recovery Step R5E / one qualified c4 read-only adoption of
frozen candidate-010, then one compile／parse／Stage P closure**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 26. Require exact local／
   origin HEAD and clean worktree. Freeze c3, both R5D roots, candidate-008／009／010, R5B c2, and all earlier artifacts.
   Candidate-010 may be read only under this section. Do not remove ReadOnly, rewrite it, create candidate-011, rerun
   promotion, or reconstruct missing outer-process exit artifacts.
2. Create one fresh c4 ASCII-only driver by copying frozen qualified c3. Permitted c3→c4 changes are limited to:
   - mechanical R5D→R5E identities, Section 26 supervisor HEAD, and fresh qualification／formal／compile-check／tool／
     preparation／Stage paths;
   - replacement of candidate creation, two candidate writes, and external promotion-diff hunk acceptance with a
     read-only candidate-010 adoption block;
   - R5E counters and evidence fields that separate inherited R5D candidate creation `1`／writes `2`／diff launches `2`
     from R5E candidate creation／write／promotion counts `0`;
   - state-free QUALIFY fixtures for frozen R5D manifest readback, candidate-010 exact identities and ReadOnly state,
     normalized Native logical equality, the four exact StagePreparer changes, frozen external Git `53` diagnostic
     evidence, and one bounded RoleContext-only alignment fixture described in item 4;
   - removal of external Git hunk count as a candidate acceptance gate. Exact file identities, transform counts,
     restricted StagePreparer change inventory, and the later production CONTRACT source-diff audit remain mandatory.
   Preserve all unrelated qualified c3 behavior byte-for-byte.
3. Require c4 to contain no executable path that creates or clones a new candidate tree, uses candidate-010 as a
   destination, writes any candidate-010 byte, or changes its file／directory attributes; require no `HashData` or
   `ToHexString`. Generic evidence／manifest／compile／tool／Stage writes remain allowed, and production `INIT` may read
   candidate-010 and copy source bytes into the fresh Stage. Static gates must target candidate-destination calls, not
   generic serialization functions. c4 must be 7-bit ASCII-only with no BOM and parser errors `0`, with a complete
   c3→c4 diff audit assigning every changed line to item 2. Freeze c4 before invocation. Qualification consumes the
   only c4 driver attempt; no repair, alternate, retry, or second c4 follows.
4. Run exactly one root-first state-free c4 QUALIFY. Persist／read back driver identity, exact command, begin, and
   receipt before the first child or fixture. Re-run the inherited zero-byte, empty-stream, Unicode, Git, input,
   result, manifest, and ReadOnly checks. Require frozen R5D qualification manifest `27 / 27`, FORMAL manifest
   `11 / 11`, failure `R5D_FAIL_PROMOTION_HUNK_COUNT`, exact candidate-010 `8 / 8` identities, all eight candidate files
   ReadOnly, Native transform `121`／CR `0`／LF `6016` and normalized logical equality, exact four StagePreparer changes,
   and candidate-011 absent. Read back the frozen external Git result as diagnostic evidence only: hunk count `53`,
   stdout SHA-256 `14019b0dd1eef79e39d3696ed96966b03ea3cfd1bf8db12b606fb3c62c7963d9`, baseline Native
   SHA-256 `46b5bead5bae9c0a049a7c3acc4e9693aab52138546482f4546dad1fb616631d`, candidate Native SHA-256
   `d5068baeb983df3ee88f365d54876273e271c3c59446a22ebcbcfbabdb7de1a9`. Do not rerun Git and do not use `53`
   as candidate acceptance. The bounded fixture must use strict UTF-8, `Replace("\r\n","\n")`, terminal-empty
   preserving `Split('\n')`, ordinal equality, and the production LCS `>=` baseline-consume tie break; for the
   RoleContext excerpt it must produce internal segments `-1211,0 +2039,3` and `-1212,0 +2043,4`, while binding the
   frozen Git segment `-1210,0 +2039,7`. It must not implement or assert the full-file internal hunk count; production
   CONTRACT is the sole full-file `54` oracle. R5E-local candidate-tree creation／write／promotion counts, compile, tool,
   preparation, Stage, PREACK, performance, A／B／C, and game counts must remain `0`; inherited R5D creation `1`,
   writes `2`, and diff launches `2` must be separate immutable fields.
5. Only after complete QUALIFY Pass, run c4 FORMAL exactly once. Persist／read back `R5E_ATTEMPT_BEGIN`, exact command,
   c4 identity, qualification closure, and frozen candidate-010 adoption identity before any compile. Adopt
   candidate-010 read-only; require exact eight-file inventory and identities again. New candidate-tree creation／clone,
   candidate-010 destination writes or attribute changes, promotion diff launch, and candidate-011 creation are
   prohibited. Reading candidate-010 and production `INIT` copying it into the fresh Stage are explicitly allowed.
6. Continue within the same FORMAL attempt through exactly six C# compiles and two PowerShell parse-only checks, then
   one fresh Native／StagePreparer tool build and one lifecycle:
   `INIT` → `RepositoryState` → `CONTRACT` → the six Section 3 modes in order → `PreSealOwnership` → `SEAL`.
   Generated compile outputs must not be launched outside those approved preparation roles. CONTRACT must produce its
   own production source-diff audit with internal LCS changed hunk count `54`, authorized `54 / 54`, unauthorized hunk
   `0`, unauthorized class `0`, LF style match, BOM match, and the exact candidate identities above. Require complete
   manifest／receipt／preparation audit, every Stage file／directory ReadOnly, external run root absent, owned runtime
   `0`, performance slot attempt／launch `0`, and A／B／C launch `0`. Before Pass closure, re-read candidate-010 and
   require the same `8 / 8` file identities, every candidate file／directory ReadOnly, candidate-011 absent, R5E-local
   candidate-tree creation／clone／write／attribute-change／promotion counts `0`, and inherited R5D counts `1 / 2 / 2`
   unchanged in separate fields.
7. Any c4 serialization／path／readback／evidence／runtime interruption is R5E Blocked. Candidate-010 identity drift,
   any attempted candidate mutation, unauthorized c4 diff, real compile／parse／CONTRACT／mode／seal failure, or internal
   production source-diff failure is R5E Fail. Stop at the first nonconformance. No repair, retry, reseal, cleanup of
   frozen evidence, repository change on failure, candidate-011, second c4, second QUALIFY, or second FORMAL.
8. Only on complete Pass may QA commit／push the same three non-executable tracked result scopes allowed by Section 21
   and return exactly:

   ```text
   MFO-WO-P2-2A-010 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex>
   ```

Stop after PREPARED. PREACK, activation, controller, performance, A／B／C execution, P95, KBM, game, quiet-window
preparation, OneDrive shutdown, and power changes remain prohibited. R5E Pass is Stage P PREPARED only; it does not
close the hold, open Gate 2, or authorize Slice 2-B.

## 27. Supervisor closure — R5E external fixture typing block and Recovery Step R5F

R5E returned **Blocked / external qualification fixture runtime type error before bounded RoleContext fixture
closure**. The stop is accepted under Section 26 item 7. c4 QUALIFY persisted its root-first begin／receipt and frozen
input identities, then the external PowerShell RoleContext fixture failed before it could persist
`rolecontext-alignment-fixture.json`. FORMAL, compile, parse, tool build, preparation, Stage, PREACK, performance,
A／B／C, and game were not started. This is not evidence of a candidate-010, production harness, game, or performance
defect.

The frozen R5E evidence is accepted as follows:

- c4: `67289` bytes / SHA-256 `c7399545819db27ce04a60f05b3d46836bbc8a5816b6dee1958bfc1927ad65ed`;
  7-bit ASCII-only, no BOM, parser errors `0`, ReadOnly.
- c3→c4 audit manifest:
  `843f5bec0b9379ed48cc08ac0afcf30e07e09f05c30eba28245d710319ea2c44`, `6 / 6` payload match,
  changed lines `317`, detailed line classifications `317 / 317` non-empty, unauthorized `0`. The frozen
  `audit-summary.json` has an empty aggregate classification label even though every detailed entry is classified.
  This is accepted as a non-authoritative summary-aggregation defect; do not rewrite or reconstruct R5E evidence.
- QUALIFY invocation count `1`, numeric exit `1`. Qualification manifest
  `de701dae69b40434c4c78cf048d72a227cf448bdcc7dae13a6e857f16db74997` has `9 / 9` payload match.
  Failure SHA-256 is `8b9692d60de026ed0bc4187eabbc9024a9f1fa544f32b72cf4ebceaa26292a49` with
  `Method invocation failed because [System.Object[]] does not contain a method named 'op_Addition'.`
  Input identities SHA-256 is `17a74b31411b86224149a0fd77a797978f0b08a41d63d894a99df1ad92dcd7fb`.
- candidate-010 remains exact `8 / 8` and every candidate file／directory remains ReadOnly. Native remains
  `456449` bytes / `d5068baeb983df3ee88f365d54876273e271c3c59446a22ebcbcfbabdb7de1a9`;
  StagePreparer remains `219515` bytes /
  `76a2aa3a1dfefcdd08245eafa5d7fccdf9f8e6241b3abc47821bad6f1bfef1aa`. candidate-011 is absent.
  R5E candidate create／clone／write／attribute／promotion counts are all `0`. FORMAL and every downstream root are
  absent; residual relevant process count is `0`; repository HEAD／origin remained exact and the worktree remained
  clean.

The failure is external and mechanically isolated. c4 line 290 contains:

```powershell
$lcs=[Array]::CreateInstance([int],([int[]]@($bn+1,$cn+1)))
```

Windows PowerShell 5 parses the comma expression before the `[int[]]` cast, effectively evaluating
`$bn + (1,$cn) + 1`. The first addition therefore targets an `Object[]` and fails before `Array.CreateInstance`,
the LCS fill, or the production harness is reached. Supervisor read-only reproduction confirms that the unambiguous
`CreateInstance(Type, Int32, Int32)` overload creates an `Int32` rank-2 array with dimensions `4 x 11` for the fixed
`3`-line baseline and `10`-line candidate excerpts.

Section 27 supersedes Section 26 only for the following **Recovery Step R5F / one fresh c5 correction of the external
bounded fixture, then the previously authorized read-only candidate-010 compile／parse／Stage P closure**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 27. Require exact local／
   origin HEAD and clean worktree. Freeze c3, c4, the R5E diff audit and qualification root, every R5D root,
   candidate-008／009／010, R5B c2, and all earlier artifacts at current bytes and attributes. Do not repair or rerun
   c4, append to the R5E roots, synthesize the missing RoleContext fixture, reconstruct missing results, remove
   ReadOnly, or create candidate-011.
2. Create exactly one fresh c5 by copying frozen c4 as a read-only seed. Permitted c4→c5 changes are limited to:
   - mechanical R5E→R5F attempt identities, Section 27 `ExecutionHead`, and fresh
     qualification／formal／compile-check／tool／preparation／Stage／run paths;
   - evidence fields that bind the frozen R5E failure lineage and separate R5E qualification `1`／FORMAL `0` from
     R5F QUALIFY／FORMAL counts;
   - exactly one fixture logic correction:

     ```powershell
     $lcs=[Array]::CreateInstance([int],[int]($bn+1),[int]($cn+1))
     ```

     replacing the failing c4 expression; and bounded evidence fields for element type `System.Int32`, rank `2`,
     baseline length `3`, candidate length `10`, and dimensions `4 x 11`.

   Preserve all unrelated c4 behavior byte-for-byte. In particular, do not mechanically replace production embedded
   identities such as `IssuedSupervisor` or `IssuedQaReceipt`; the new supervisor commit belongs only in execution
   and repository-observation fields. Do not change candidate-010, production Native, StagePreparer, production result schema,
   or FORMAL logic.
3. Before invocation, require c5 to be 7-bit ASCII-only with no BOM and Windows PowerShell parser errors `0`. Run one
   c4→c5 full unified diff invocation and classify every detailed changed line to item 2 with unauthorized `0`.
   The detailed line records are authoritative; do not depend on the R5E empty aggregate classification label.
   Diff exit `1` means bytes differ and is not a harness failure. Do not use an external Git hunk count as an
   acceptance oracle. Freeze c5 and its diff evidence before QUALIFY. No second c5, c6, alternate, repair, or retry.
4. Run c5 QUALIFY exactly once, root-first. Persist／read back driver identity, exact command, begin, and receipt before
   the first child or fixture. Require the frozen R5E identities above, R5E qualification count `1`, R5E FORMAL count
   `0`, and absence of R5E `rolecontext-alignment-fixture.json`. Re-run every Section 26 item 4 gate, including the
   R5D manifests, frozen Git `53` diagnostic-only readback, candidate-010 exact `8 / 8` and ReadOnly state, Native
   transform, and exact four StagePreparer changes. The corrected bounded fixture must record `System.Int32`,
   rank `2`, lengths `3`／`10`, dimensions `4`／`11`, and must produce internal segments
   `-1211,0 +2039,3` and `-1212,0 +2043,4` with the unchanged ordinal comparison and `>=`
   baseline-consume tie break, while binding frozen Git segment `-1210,0 +2039,7`. It must not compute the full-file
   hunk count. R5F candidate mutation, compile, tool, preparation, Stage, PREACK, performance, A／B／C, and game counts
   remain `0` during QUALIFY.
5. Only after complete QUALIFY Pass, absence of a qualification failure file, full manifest payload match, and c5
   ReadOnly identity readback may FORMAL run exactly once. FORMAL scope and order are unchanged from Section 26
   items 5 and 6: exactly six C# compiles, two PowerShell parse-only checks, one fresh Native／StagePreparer tool build,
   then `INIT → RepositoryState → CONTRACT → six Section 3 modes → PreSealOwnership → SEAL`. candidate-010 remains
   read-only input; no candidate creation, clone, destination write, attribute change, promotion, or candidate-011.
   Production CONTRACT is the sole full-file LCS oracle. `changed_hunk_count=54`,
   `unauthorized_changed_hunk_count=0`, `unauthorized_changed_class_count=0`, LF match, and BOM match together mean
   `54 / 54 authorized`. No nonexistent `authorized_changed_hunk_count` field or production schema change is required.
6. Any c5 serialization／path／readback／evidence／runtime interruption before production closure is R5F Blocked.
   Candidate-010 identity drift, attempted candidate mutation, unauthorized c5 diff, or real
   compile／parse／CONTRACT／mode／seal failure is R5F Fail. Stop at the first nonconformance. No repair, retry, reseal,
   cleanup of frozen evidence, repository change on failure, c4 rerun, candidate-011, second c5, second QUALIFY, or
   second FORMAL.
7. Only on complete Pass may QA commit／push the same three non-executable tracked result scopes allowed by Section 21
   and return exactly:

   ```text
   MFO-WO-P2-2A-010 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex>
   ```

Stop after PREPARED. PREACK, activation, controller, performance, A／B／C execution, P95, KBM, game, quiet-window
preparation, OneDrive shutdown, and power changes remain prohibited. R5F Pass is Stage P PREPARED only; it does not
close the hold, open Gate 2, or authorize Slice 2-B.

## 28. Supervisor closure — R5F frozen-lineage manifest schema block and Recovery Step R5G

R5F returned **Blocked / external frozen-lineage manifest schema binding mismatch before bounded RoleContext
fixture**. The stop is accepted under Section 27 item 6. c5 QUALIFY persisted its root-first begin／receipt,
zero-byte fixtures, parser result, and Unicode path result, then failed at the first payload of the first frozen R5E
manifest. The corrected bounded RoleContext fixture, R5D lineage checks, candidate transform checks, FORMAL, compile,
parse, tool build, preparation, Stage, PREACK, performance, A／B／C, and game were not started. This is not evidence of
a candidate-010, production harness, game, or performance defect.

The frozen R5F evidence is accepted as follows:

- c5: `71932` bytes / SHA-256 `b5da4ac2839dd2b71388bf5916bc49ee74501002ff9d5d78805b7f888b08b27a`;
  7-bit ASCII-only, no BOM, parser errors `0`, ReadOnly. The corrected LCS expression occurs exactly `1`, the c4
  expression occurs `0`, nonexistent `authorized_changed_hunk_count` occurs `0`, and production embedded
  `IssuedSupervisor`／`IssuedQaReceipt` remain unchanged.
- c4→c5 diff invocation count `1`, numeric exit `1` for bytes-differ. Changed lines `234`: mechanical `204`, frozen
  R5E lineage／count `25`, LCS／bounded evidence `5`, unauthorized `0`. Diff manifest SHA-256 is
  `0625ba01f593443005b13aed63964011488cd1504bbf0febbc50bd3a819ea430`. c5 and the diff root are frozen.
- QUALIFY invocation count `1`, numeric exit `1`. Qualification manifest
  `20611058ca97080a0826287fdb6868fbeac1cf0f5d50f8cb39293b97e1d8813f` has `8 / 8` payload match.
  Failure SHA-256 is `b6978fec94fb86d9e301300d0a9102a5b2c97938c7d38d31f3ec9aac85c99226` with
  `The property 'relative_path' cannot be found on this object. Verify that the property exists.` The qualification
  root contains `9` files and all files／directories are ReadOnly.
- candidate-010 remains exact `8 / 8` and every candidate file／directory remains ReadOnly. Native remains
  `456449` bytes / `d5068baeb983df3ee88f365d54876273e271c3c59446a22ebcbcfbabdb7de1a9`;
  StagePreparer remains `219515` bytes /
  `76a2aa3a1dfefcdd08245eafa5d7fccdf9f8e6241b3abc47821bad6f1bfef1aa`. candidate-011 is absent.
  R5F candidate create／clone／write／attribute／promotion counts are all `0`. FORMAL and every downstream root are
  absent; residual relevant process count is `0`; repository HEAD／origin remained exact and the worktree remained
  clean.

The failure is external and mechanically isolated. The frozen manifests intentionally have two different schemas:

| Frozen root | Exact schema | Path field | Size field | Hash field | Payloads |
|---|---|---|---|---|---:|
| R5E c3→c4 diff audit | `mfo.qa.r5e.c3-c4-diff-manifest.v1` | `name` | `size` | `sha256` | 6 |
| R5E qualification | `mfo.qa.r5e.qualification-manifest.v1` | `relative_path` | `byte_size` | `sha256` | 9 |

c5 lines 274–277 process the diff manifest first but apply `relative_path`／`byte_size` to both schemas under
`Set-StrictMode -Version 2.0`. The first payload, `audit-summary.json`, therefore raises the recorded property error
before the RoleContext fixture or production harness is reached. Supervisor and independent read-only checks using
exact schema dispatch confirm `6 / 6` and `9 / 9` payload match respectively.

Section 28 supersedes Section 27 only for the following **Recovery Step R5G / one fresh c6 correction of the external
frozen-lineage schema binding, then the previously authorized read-only candidate-010 QUALIFY／FORMAL／Stage P
closure**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 28. Require exact local／
   origin HEAD and clean worktree. Freeze c3, c4, c5, every R5D／R5E／R5F audit and qualification root,
   candidate-008／009／010, R5B c2, and all earlier artifacts at current bytes and attributes. Do not repair or rerun
   c5, append to the R5F roots, synthesize missing R5F results, remove ReadOnly, or create candidate-011.
2. Create exactly one fresh c6 from frozen c5. Permitted c5→c6 changes are limited to:
   - mechanical R5F→R5G attempt identities, Section 28 `ExecutionHead`, and fresh
     qualification／formal／compile-check／tool／preparation／Stage／run paths;
   - evidence fields that bind the frozen R5F driver, diff audit, qualification failure／manifest, consumed
     R5F QUALIFY `1`／FORMAL `0`, and separate R5G QUALIFY／FORMAL counts;
   - exactly one lineage-loop logic correction: each of the two frozen R5E root specifications must carry its exact
     expected schema ID and fixed path／size field names from the table above. Require schema exact equality before
     payload iteration. Retrieve the exact named path, size, and `sha256` properties; require each property to exist;
     compare its `.Value` against the existing sorted relative path, file length, and SHA-256. Preserve the existing
     manifest hash, payload count, order, SHA-256, and ReadOnly checks.
   - bounded evidence recording the exact schema ID, selected fixed field names, payload count, and complete payload
     match for each of the two frozen roots.

   Unknown schema, missing required field, or explicit schema／field／hash／count mismatch must fail closed. Do not
   infer schema from field presence, add fallback field selection, normalize both manifests into a common schema,
   rewrite frozen manifests, add a generic manifest abstraction, or use payload property count as a new acceptance
   oracle. Preserve all unrelated c5 behavior byte-for-byte. Do not change the corrected LCS expression, bounded
   RoleContext fixture, candidate-010, production Native, StagePreparer, production result schema, or FORMAL logic.
3. Before invocation, require c6 to be 7-bit ASCII-only with no BOM and Windows PowerShell parser errors `0`. Run one
   c5→c6 full unified diff invocation and classify every detailed changed line to item 2 with unauthorized `0`.
   Diff exit `1` means bytes differ and is not a harness failure. Do not use an external Git hunk count as an
   acceptance oracle. Freeze c6 and its diff evidence before QUALIFY. No second c6, c7, alternate, repair, or retry.
4. Run c6 QUALIFY exactly once, root-first. Persist／read back driver identity, exact command, begin, and receipt before
   the first child or fixture. Require the frozen R5F identities above, R5F QUALIFY count `1`, R5F FORMAL count `0`,
   absence of R5F `frozen-r5e-lineage.json`, `input-identities.json`, and `rolecontext-alignment-fixture.json`, and
   absence of an R5F FORMAL root. First validate both frozen R5E manifests through the exact schema bindings in the
   table and persist the two complete match results. Then run every remaining Section 27 item 4 gate unchanged,
   including R5D manifests, frozen Git `53` diagnostic-only readback, candidate-010 exact `8 / 8` and ReadOnly state,
   Native transform, exact four StagePreparer changes, and the corrected bounded RoleContext fixture with
   `System.Int32`, rank `2`, lengths `3`／`10`, dimensions `4`／`11`, internal segments
   `-1211,0 +2039,3`／`-1212,0 +2043,4`, and frozen Git segment `-1210,0 +2039,7`. R5G candidate mutation,
   compile, tool, preparation, Stage, PREACK, performance, A／B／C, and game counts remain `0` during QUALIFY.
5. Only after complete QUALIFY Pass, absence of a qualification failure file, full manifest payload match, and c6
   ReadOnly identity readback may FORMAL run exactly once. FORMAL scope and order are unchanged from Section 27
   item 5: exactly six C# compiles, two PowerShell parse-only checks, one fresh Native／StagePreparer tool build, then
   `INIT → RepositoryState → CONTRACT → six Section 3 modes → PreSealOwnership → SEAL`. candidate-010 remains
   read-only input; no candidate creation, clone, destination write, attribute change, promotion, or candidate-011.
   Production CONTRACT remains the sole full-file LCS oracle and must establish `54 / 54 authorized`, unauthorized
   hunk／class `0`, LF match, and BOM match without a nonexistent field or production schema change.
6. Any c6 serialization／path／readback／evidence／runtime interruption before production closure is R5G Blocked. An
   explicit frozen schema／field／hash／count／payload mismatch is R5G **Fail / frozen-lineage integrity
   nonconformance**. Candidate-010 identity drift, attempted candidate mutation, unauthorized c6 diff, or real
   compile／parse／CONTRACT／mode／seal failure is R5G Fail. Stop at the first nonconformance. No repair, retry, reseal,
   cleanup of frozen evidence, repository change on failure, c5 rerun, candidate-011, second c6, second QUALIFY, or
   second FORMAL.
7. Only on complete Pass may QA commit／push the same three non-executable tracked result scopes allowed by Section 21
   and return exactly:

   ```text
   MFO-WO-P2-2A-010 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex>
   ```

Stop after PREPARED. PREACK, activation, controller, performance, A／B／C execution, P95, KBM, game, quiet-window
preparation, OneDrive shutdown, and power changes remain prohibited. R5G Pass is Stage P PREPARED only; it does not
close the hold, open Gate 2, or authorize Slice 2-B.

## 29. Supervisor closure — R5G external structural-line classifier false positive and Recovery Step R5H

R5G returned **Fail / external c5-to-c6 diff-audit line-classification defect before QUALIFY**. The machine result
is preserved. c6 creation and the exact-one c5→c6 unified diff completed, but the external detailed-line classifier
left one changed line unauthorized and stopped before QUALIFY. FORMAL, compile, parse, tool build, preparation,
Stage, PREACK, performance, A／B／C, P95, KBM, and game all remained `0`. This is not evidence of a c6,
candidate-010, production harness, game, or performance defect.

The frozen R5G evidence is accepted as follows:

- c6: `76777` bytes / SHA-256 `fbc135922132296b8239bcc70da1a55da059a1f6198f470b535c44178d77017e`;
  7-bit ASCII-only, no BOM, parser errors `0`, final file attribute ReadOnly. Production `IssuedSupervisor`,
  `IssuedQaReceipt`, the corrected bounded-LCS expression, candidate-010 identities, and all production paths remain
  unchanged.
- The c5→c6 diff invocation count is exact `1`; numeric exit `1` records differing bytes. Detailed changed lines are
  `251`. The frozen machine classification is schema dispatch `19`, frozen R5F lineage `17`, mechanical rollover
  `214`, unauthorized `1`.
- The sole unauthorized changed line is the exact text `+        }`: c6 line `299`, raw diff stdout line `122`,
  changed-lines zero-based index `93` / ordinal `94`, in hunk `@@ -287 +292,13 @@ function Invoke-Qualification`.
  c6 line `294` opens the frozen R5F manifest `foreach`; lines `295`–`298` are its body; line `299` closes it; line
  `300` begins the frozen R5F failure binding. The same hunk classifies the opening and lineage body as authorized.
  Independent read-only audit found no other unclassified changed line and no semantic drift.
- Supervisor overlays only this exact frozen line as **`r5f-frozen-lineage structural closure`**. The interpretive
  totals are therefore schema dispatch `19`, frozen R5F lineage `18`, mechanical rollover `214`, unauthorized `0`.
  This overlay does not rewrite or relabel the frozen machine result, changed-lines evidence, summary, or manifest,
  and it is not a general brace／punctuation allowance.
- The frozen c5→c6 audit root manifest SHA-256 is
  `90d145d8b762ff9977f6b1e42fc6250a52811d2c462122b7346ec6f4309a326f`, with `7 / 7` payload match. Current
  readback confirms the audit root and all files／directories are ReadOnly. Any `ReadOnly=false` value captured for
  c6 or read streams inside the pre-freeze audit records reflects observation timing
  timing before final freeze and is not the acceptance oracle. R5H must read back current actual attributes without
  changing them.
- candidate-010 remains exact `8 / 8` and ReadOnly; candidate-011 is absent. R5G QUALIFY／FORMAL roots, compile-check,
  tool build, preparation root, Stage, and external run root are absent; residual relevant process count is `0`;
  repository HEAD／origin were exact and the worktree was clean.

The first nonconformance is therefore attributed as **Fail / external c5-to-c6 diff-audit structural-line
classification false positive**. Section 29 supersedes Section 28 only for the following **Recovery Step R5H / one
fresh c7 with flat R5G-lineage binding, then the previously authorized read-only candidate-010 QUALIFY／FORMAL／
Stage P closure**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 29. Require exact local／
   origin HEAD and clean worktree. Freeze c3 through c6, all R5D／R5E／R5F／R5G audit and qualification roots,
   candidate-008／009／010, R5B c2, and all earlier artifacts at current bytes and attributes. Do not repair or rerun
   c6, re-diff c5→c6, append to R5G roots, rewrite the frozen machine classification, remove ReadOnly, or create
   candidate-011.
2. Create exactly one fresh c7 from frozen c6. Permitted c6→c7 changes are limited to:
   - mechanical R5G→R5H attempt identities, Section 29 `ExecutionHead`, and fresh
     qualification／formal／compile-check／tool／preparation／Stage／run paths; and
   - evidence fields that bind the frozen c6 identity and current ReadOnly state, the frozen R5G c5→c6 audit
     manifest and `7 / 7` payloads, the exact machine counts／sole unauthorized line, the exact supervisor overlay
     context above, R5G QUALIFY `0`／FORMAL `0`, and separate R5H QUALIFY／FORMAL counts.
   Preserve the c6 two-schema dispatch, corrected LCS expression, bounded RoleContext fixture, candidate-010
   adoption, FORMAL implementation, production identities, and all other bytes. Implement the new R5G-lineage
   binding as flat exact statements only. Do not add a new loop, standalone structural-only changed line, general
   brace／punctuation／blank-line allowance, or context-based authorization rule.
3. Before any c7 execution, prove 7-bit ASCII-only, no BOM, Windows PowerShell parser errors `0`, production identity
   preservation, and run exactly one c6→c7 full unified diff. Every detailed changed line must classify only as
   `mechanical-r5g-to-r5h-rollover` or `frozen-r5g-lineage`, with unauthorized `0`. A new standalone `{`, `}`,
   punctuation-only, or blank changed line is unauthorized. The Section 29 overlay applies only to the frozen
   c5→c6 exact line identified above. Freeze c7 and its diff evidence before QUALIFY. No second c7, alternate,
   repair, re-diff, or retry.
4. Run c7 QUALIFY exactly once, root-first. Persist／read back driver identity, exact command, begin, and receipt
   before the first child or fixture. Require frozen c6 identity and current actual ReadOnly state, the frozen R5G
   audit manifest and `7 / 7` payload match, current ReadOnly state of the audit root and every file／directory,
   exact frozen machine counts `19 / 17 / 214 / 1`, the sole line and hunk identity above, exact supervisor overlay
   context, R5G QUALIFY `0`／FORMAL `0`, and absence of R5G QUALIFY／FORMAL
   roots. Then run every Section 28 item 4 gate unchanged: both frozen R5E manifests through exact schema dispatch,
   R5D manifests, frozen Git `53` diagnostic-only readback, candidate-010 exact `8 / 8` and ReadOnly state, Native
   transform, exact four StagePreparer changes, and the corrected bounded RoleContext fixture. R5H candidate
   mutation, compile, tool, preparation, Stage, PREACK, performance, A／B／C, and game counts remain `0` during
   QUALIFY.
5. Only after complete QUALIFY Pass, absence of a qualification failure file, full manifest payload match, and c7
   ReadOnly identity readback may FORMAL run exactly once. FORMAL scope and order are unchanged from Section 28 item
   5: exactly six C# compiles, two PowerShell parse-only checks, one fresh Native／StagePreparer tool build, then
   `INIT → RepositoryState → CONTRACT → six Section 3 modes → PreSealOwnership → SEAL`. candidate-010 remains
   read-only input; candidate mutation counts remain `0`. Production CONTRACT remains the sole full-file LCS oracle
   and must establish `54 / 54 authorized`, unauthorized hunk／class `0`, LF match, and BOM match.
6. Any c7 serialization／path／readback／evidence／runtime interruption before production closure is R5H Blocked. An
   explicit frozen c6／R5G audit／schema／field／hash／count／payload mismatch, unauthorized c7 diff, candidate-010
   identity drift, or attempted candidate mutation is R5H Fail. A real compile／parse／CONTRACT／mode／seal failure is
   R5H Fail. Stop at the first nonconformance. No repair, retry, reseal, cleanup of frozen evidence, repository change
   on failure, c6 rerun, candidate-011, second c7, second QUALIFY, or second FORMAL.
7. Only on complete Pass may QA commit／push the same three non-executable tracked result scopes allowed by Section 21
   and return exactly:

   ```text
   MFO-WO-P2-2A-010 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex>
   ```

Stop after PREPARED. PREACK, activation, controller, performance, A／B／C execution, P95, KBM, game, quiet-window
preparation, OneDrive shutdown, and power changes remain prohibited. R5H Pass is Stage P PREPARED only; it does not
close the hold, open Gate 2, or authorize Slice 2-B.

## 30. Supervisor closure — R5H external diff-audit helper syntax block and Recovery Step R5I

R5H returned **Blocked / external c6-to-c7 diff-audit driver syntax defect before diff invocation**. fresh c7 was
created exactly once, then the separate external diff-audit command stopped while reading frozen c6 identity. QA
reported the malformed token `return[ordered]@`, outer invocation exit `1`, and Git diff process count `0`. The
partial root is empty, however, so those raw command／error／exit／process facts are not independently reproducible from
a durable R5H artifact and must not be reconstructed or upgraded into machine evidence.

The independently durable／read-only state, together with explicitly labeled QA-return facts, is accepted as follows:

- c7: `87132` bytes / SHA-256 `a3da5cb41f6b248bbef2a90d63a12a89752e17ac66174833db24e067d6c5b554`;
  7-bit ASCII-only, no BOM, QA-return pre-write parser errors `0`, current attributes ReadOnly／Archive. c7 contains malformed
  `return[ordered]@` occurrences `0` and correct `return [ordered]@` occurrences `2`; therefore the reported token
  defect is external to c7. c7 fixes `ExecutionHead` to `1b520e6f55bdf9d44372a891db6d4f457b8d2784` and cannot be
  executed after a later supervisor commit.
- partial audit root
  `r5h-c6-to-c7-audit-1b520e6-c7` is ReadOnly／Directory and has recursive child count `0`. attempt marker,
  command record, stdout, stderr, numeric exit, diff output, changed-lines, and manifest are absent. Do not add them
  after the fact. QA returned c6→c7 diff／QUALIFY／FORMAL counts `0`; the empty root is consistent with that stop but
  does not independently prove process count or exact error text.
- candidate-010 remains exact `8 / 8`; all eight files and all three directories including the root are ReadOnly;
  candidate-011 is absent. c6 remains `76777` bytes /
  `fbc135922132296b8239bcc70da1a55da059a1f6198f470b535c44178d77017e`, and the frozen R5G manifest remains
  `90d145d8b762ff9977f6b1e42fc6250a52811d2c462122b7346ec6f4309a326f` with `7 / 7` payload match and every root
  item ReadOnly.
- R5H qualification／formal／compile-check／tool／preparation／Stage／run roots are absent. QA returned six compile,
  two parse, StagePreparer, PREACK, performance, A／B／C, P95, KBM, and game counts as `0`; the absent roots and
  current residual relevant process count `0` are consistent with that return but do not independently prove
  historical launch counts. repository local／origin HEAD were exact and the worktree was clean.

The first nonconformance is attributed as **Blocked / external c6-to-c7 diff-audit helper syntax defect before Git
diff invocation**. This is not evidence of a c7, candidate-010, production harness, game, or performance defect.
Section 30 supersedes Section 29 only for the following **Recovery Step R5I / qualify one fresh external diff-audit
driver, create one fresh c8 from frozen c7, then the previously authorized candidate-010 QUALIFY／FORMAL／Stage P
closure**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 30. Require exact local／
   origin HEAD and clean worktree. Freeze c3 through c7, the empty R5H partial root, every R5D／R5E／R5F／R5G root,
   candidate-008／009／010, R5B c2, and all earlier artifacts at current bytes and attributes. Do not repair or execute
   c7, complete the empty root, synthesize missing R5H evidence, reconstruct the old inline helper bytes, claim an
   old-helper byte diff, remove ReadOnly, or create candidate-011.
2. Before c8 creation, create exactly one fresh 7-bit ASCII external diff-audit driver with two modes: `QUALIFY` and
   `AUDIT`. It is an external evidence tool only and must not write the repository, candidate, production source, or
   any frozen root. Its functional surface is limited to root-first receipts, file identity／hash readback, exact
   c7→c8 unified-diff capture, detailed changed-line classification, complete manifesting, and ReadOnly freeze. The
   only semantic correction carried from the non-durable R5H helper is a file-identity return statement with exact
   token `return [ordered]@{`. Extract that helper by line-anchored start／end boundaries and require the corrected
   token exact `1` and legacy `return[ordered]@` exact `0` inside that bounded region. The qualification implementation
   must construct both audit lookup markers from split fragments; neither full marker literal may appear outside the
   bounded helper. Do not claim a byte
   comparison to the missing old helper. Do not add a reusable project abstraction or production tool.
3. Run the external audit driver `QUALIFY` mode exactly once before c8 exists. Create its qualification root first and
   persist／read back driver identity, exact command, begin, and receipt before the first fixture. Require 7-bit
   ASCII-only, no BOM, Windows PowerShell parser errors `0`, bounded-helper corrected／legacy token counts `1 / 0`,
   raw lookup literals outside the bounded helper `0`, and execute its file-identity helper against frozen c7 to
   persist and read back exact size `87132`, exact SHA-256
   `a3da5cb41f6b248bbef2a90d63a12a89752e17ac66174833db24e067d6c5b554`, and current ReadOnly state. Require c8
   absent, Git diff process count `0`, candidate／production／runtime mutation counts `0`, complete payload manifest
   match, and the driver／qualification root／all files and directories ReadOnly. Any qualification error is R5I
   Blocked; stop without c8 creation, driver repair, alternate, retry, or second qualification.
4. Only after complete external-driver qualification Pass may one fresh c8 be created from frozen c7. Permitted
   c7→c8 changes are limited to:
   - mechanical R5H→R5I attempt identities, Section 30 `ExecutionHead`, and fresh
     audit／qualification／formal／compile-check／tool／preparation／Stage／run paths and counts; and
   - flat exact statements binding c7 identity／ReadOnly, the empty R5H partial root identity／ReadOnly／child count
     `0`, absence of marker／command／streams／exit／changed-lines／manifest, supervisor-recorded R5H diff／QUALIFY／
     FORMAL counts `0` explicitly marked non-durable, and separate R5I counts.
   Preserve c7's c6／R5G／R5F／R5E／R5D bindings, two-schema dispatch, corrected LCS expression, bounded RoleContext
   fixture, candidate-010 adoption, FORMAL implementation, production `IssuedSupervisor`／`IssuedQaReceipt`, and all
   other bytes. Add no new loop, function, abstraction, standalone structural-only changed line, or general brace／
   punctuation／blank／context allowance. Freeze c8 before the actual diff. No second c8, alternate, repair, or retry.
5. Use the same qualified external audit driver at the exact qualified SHA-256 in `AUDIT` mode exactly once. Create
   the actual audit root first. Before the Git child, persist／read back driver identity, exact command, begin, receipt,
   and c7／c8 identities. Only after those pre-child records are complete may the c7→c8 unified diff child launch
   exactly once. Persist／read back stdout, stderr, numeric exit, detailed changed lines, summary, and complete manifest.
   Diff exit `1` means bytes differ and is expected. Every changed line must classify only as
   `mechanical-r5h-to-r5i-rollover` or `frozen-r5h-lineage`, with unauthorized `0`; a standalone structural-only line
   is unauthorized. Freeze the driver, c8, audit root, and all files／directories. Process start failure, timeout,
   numeric exit unavailable, missing marker／stream／manifest／readback, or durable Git exit greater than `1` with an
   operational error is R5I Blocked. Durable diff exit `0` is R5I Fail because the mandatory rollover diff is absent.
   Driver identity drift, c8 identity drift, or any unauthorized c8 changed line is R5I Fail. No re-diff or second
   audit invocation.
6. Only after the actual audit Pass may c8 QUALIFY run exactly once, root-first. Require the external-driver
   qualification and actual-audit manifests, exact shared driver identity, frozen c7／empty-root state, frozen R5G
   `7 / 7` lineage, candidate-010 exact `8 / 8`／ReadOnly, both frozen R5E manifest schemas, R5D manifests, frozen
   Git `53` diagnostic-only readback, Native transform, exact four StagePreparer changes, and the corrected bounded
   RoleContext fixture. R5I candidate mutation, compile, tool, preparation, Stage, PREACK, performance, A／B／C, and
   game counts remain `0` during QUALIFY. Any c8 QUALIFY interruption is R5I Blocked; any explicit lineage／identity／
   fixture mismatch is R5I Fail. No QUALIFY repair or second QUALIFY.
7. Only after complete c8 QUALIFY Pass may FORMAL run exactly once. FORMAL scope and order are unchanged from Section
   29 item 5: exactly six C# compiles, two PowerShell parse-only checks, one fresh Native／StagePreparer tool build,
   then `INIT → RepositoryState → CONTRACT → six Section 3 modes → PreSealOwnership → SEAL`. candidate-010 remains
   read-only input; candidate mutation counts remain `0`. Production CONTRACT must establish `54 / 54 authorized`,
   unauthorized hunk／class `0`, LF match, and BOM match. A real compile／parse／CONTRACT／mode／seal failure is R5I
   Fail. Stop at the first nonconformance; no repair, retry, reseal, cleanup of frozen evidence, repository change on
   failure, or second FORMAL.
8. Only on complete Pass may QA commit／push the same three non-executable tracked result scopes allowed by Section 21
   and return exactly:

   ```text
   MFO-WO-P2-2A-010 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex> receipt_sha256=<64-hex> preparation_audit_sha256=<64-hex>
   ```

Stop after PREPARED. PREACK, activation, controller, performance, A／B／C execution, P95, KBM, game, quiet-window
preparation, OneDrive shutdown, and power changes remain prohibited. R5I Pass is Stage P PREPARED only; it does not
close the hold, open Gate 2, or authorize Slice 2-B.

## 31. Supervisor closure — R5I preparation-details schema nonconformance and Recovery Step R5J

R5I returned **Fail / candidate harness preparation nonconformance**. The supervisor narrows the accepted attribution
to **candidate harness preparation-details schema nonconformance**. The external evidence chain and the previously
corrected candidate-010 source-format／matcher path passed far enough to reach the first production preparation mode:

- external diff-driver qualification manifest
  `be2d7f50c7eb0cea1862ba5ec42155b896b71fd07c74526c78bab0a1277e63ae` matched `5 / 5` payloads;
- c7→c8 audit manifest `0c3b6306e5625511c2f88239e07b7021a2c849ecaa3b69b9663e6fab19a9bc1f`
  matched `7 / 7`, with changed lines `319 = 300 mechanical + 19 frozen lineage`, structural `0`, unauthorized `0`;
- c8 QUALIFY manifest `194ba50a1410d106cedc0e4b5dbfb6a2534f9ac2273bc406b14fdf4a98e4df23`
  matched `34 / 34`;
- exact six compile, two PowerShell parse-only checks, fresh Native／StagePreparer tool build, INIT,
  RepositoryState, and CONTRACT passed. CONTRACT source-diff was `46110` bytes /
  `98ffa701885972a4b2e90bced7f492f87c5404a0a1a2a2fb6fed69253d307f80`, with changed hunk `54`,
  unauthorized hunk／class `0`, newline-style match, and UTF-8 BOM match;
- first `QP_DRYRUN` runner result was `7638` bytes /
  `5cd71f75b541b00481fb8c50c87d3852f4f57b9b89790f245073ca3469dc49f3`, result code `0 / Pass`,
  and root `performance_slot_attempt_count=0`, `performance_slot_launch_count=0`, `abc_launch_count=0`.
  Its Pass `details` contained launch, ABC, and final-owned counts but omitted
  `performance_slot_attempt_count`; the wrapper therefore stopped correctly with numeric exit `1` and stderr
  `5eec7849a6b1165359d4ecff953058934a0d07367aa95cb39e8f6128a8c042c7`;
- later five modes, PreSealOwnership, SEAL, PREPARED, PREACK, performance, A／B／C, P95, KBM, and game were not run.
  Formal failure `0b10c0c0fa2fa291614399bf2f847de4ed975c95957df57aaecc3ab148455988` and formal manifest
  `d6fb78861cffbad8add697d2ab57366a92e7443a4383f0b120d1f8310e19db54` (`3 / 3`) remain frozen.

This is evidence of an incomplete candidate preparation result record. It is not a gameplay, game-performance,
host-condition, or external audit-driver defect. Section 31 supersedes Section 30 only for the following
**Recovery Step R5J / candidate-011 exact one-line correction and compile／static closure only**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 31. Require exact local／
   origin HEAD and a clean worktree. Freeze R5I driver／c8／audit／QUALIFY／FORMAL evidence, partial Stage, candidate-010,
   and every earlier artifact at current bytes and attributes. Do not complete, repair, execute, or delete the partial
   Stage. Do not modify the repository or any frozen artifact.
2. Create exactly one fresh 7-bit ASCII, BOM-free, Windows PowerShell 5-compatible external R5J evidence driver with
   `QUALIFY` and `FORMAL` modes. Limit it to root-first receipts, exact identity／byte-boundary checks, candidate-011
   clone and one-line write, bounded static checks, six compiler invocations, two parse-only checks, complete
   manifests, and ReadOnly freeze. Use only the already-qualified PS5-compatible hash, empty-stream, Unicode-path,
   and root-first primitives. Add no generic diff classifier, c9 lineage layer, reusable project abstraction, Stage
   orchestration, or product tool.
3. Run `QUALIFY` exactly once before candidate-011 exists. Persist and read back the driver／command／begin／receipt
   before fixtures. Require ASCII-only, no BOM, parser errors `0`, exact repository state, all frozen R5I manifest
   identities and payload matches, candidate-010 exact `8 / 8` and ReadOnly, and candidate-011／candidate-012 absent.
   In candidate-010 Native, require the bounded `RoleContext.Execute` definition exactly once, the exact anchor
   `details = body();` exactly once in that method, and the target assignment absent. Require the unchanged
   StagePreparer allowlist to authorize `RoleContext` method `Execute`, and unchanged RunPreparation Pass-details
   contract to require attempt／launch／ABC／final-owned fields. Compute the transform entirely in memory and require:
   - only `source/MfoQaNative.cs` would change;
   - exact insertion immediately after `details = body();`:

     ```csharp
     details["performance_slot_attempt_count"] = performanceAttemptCount;
     ```

   - candidate-011 Native expected size `456534` and SHA-256
     `167634f7854ae9db5b061e65a8f6148c3ffe0aa399ee66d54bf2039db9fd86c1`;
   - LF-only count `6017`, UTF-8 BOM absent, and the other seven candidate files seed-identical.

   During QUALIFY, candidate creation／write, compiler, generated-output launch, StagePreparer, Stage, mode,
   PREACK, performance, A／B／C, and game counts remain `0`. Any driver／serialization／path／evidence interruption is
   R5J Blocked. Any identity／anchor／binding／in-memory-transform mismatch is R5J Fail. No repair, alternate, retry,
   or second qualification.
4. Only after complete QUALIFY Pass may `FORMAL` run exactly once. Clone candidate-010 to candidate-011 exactly once,
   change only `source/MfoQaNative.cs`, and perform the semantic write exactly once. Do not remove ReadOnly from or
   write candidate-010. Only candidate-011 Native ReadOnly may be cleared exactly once immediately before that write
   and restored exactly once immediately after verified write; no other candidate attribute may be loosened. Prove
   candidate-011 by full-file hash, exact changed path count `1`, inserted-line count `1`,
   deletion count `0`, anchor adjacency, prefix／suffix byte equality, line-ending／BOM preservation, expected Native
   identity above, and other seven files byte-identical. Git hunk count is diagnostic-only and must not be an
   acceptance oracle. Freeze candidate-011 root／directories／files ReadOnly; candidate-012 remains absent.
5. Before compile, run bounded static checks exactly once. Require the `RoleContext.Execute` definition and target
   assignment each exactly once, the assignment immediately after `details = body();`, and all six preparation modes
   to return through the common `RoleContext.Execute` wrapper. Require StagePreparer's existing `RoleContext / Execute`
   authorization and RunPreparation's four-field Pass-details requirement unchanged. An in-memory projection may
   record expected internal LCS `55 / 55 authorized`, unauthorized `0`, but it is diagnostic only; authoritative
   CONTRACT execution is deferred to a later work order.
6. Compile candidate-011 fresh exactly once for each of Native library, Runner, Launcher, Controller, Sentinel, and
   StagePreparer. Parse only the approved `RunPreparation.ps1` and `RecordRepositoryState.ps1` exactly once each.
   Require all six numeric compiler exits `0`, both parser error counts `0`, complete command／stream／exit／identity
   readback, no generated-output launch, candidate identity stable, and residual relevant process count `0`. Do not
   reuse R4H or R5I compile outputs.
7. R5J Pass classification is exactly **Pass / candidate-011 exact correction and compile／parse closure only**. A
   candidate transform, exact-diff, bounded-static, compile, or parse nonconformance is R5J Fail. An external driver,
   evidence, path, serialization, or process-control interruption is R5J Blocked. Stop at the first nonconformance.
   No repair, retry, second driver／QUALIFY／FORMAL／candidate, cleanup of frozen evidence, repository edit, commit, or
   push is authorized in R5J. Return the classification, driver and manifest identities, candidate-011 complete
   inventory, exact diff／static results, six compile／two parse results, launch counts, residual processes, and frozen
   state directly to `00統括`.

Stop after R5J compile／static closure. StagePreparer execution, fresh Stage P, repository-state capture, CONTRACT
execution, six preparation modes, PreSealOwnership, SEAL, PREPARED, PREACK, activation, controller, performance,
A／B／C execution, P95, KBM, game, quiet-window preparation, OneDrive shutdown, and power changes remain prohibited.
R5J Pass does not close the hold, open Gate 2, authorize Slice 2-B, or itself authorize R5K／Stage P.

## 32. Supervisor closure — R5J clone-tree ReadOnly precondition Blocked and Recovery Step R5J-A

R5J returned **Blocked / external R5J driver clone-tree ReadOnly precondition mismatch before semantic write**. The
supervisor accepts that classification. Independent read-only verification confirmed the payload hashes, current
candidate state, driver order, and absent downstream artifacts. Execution-count wording below remains a QA-return fact
where no dedicated durable counter or host result exists:

- R5J driver `50387` bytes / SHA-256
  `f6e45f21942245c03a2ecd926062923e2b494196a1a1b850a613e6a0b1cf7f1d` passed exact-one QUALIFY;
- qualification manifest `80dca50ce90370caa015d3f40b2d2fa19b8c6f30449ad651347905ec00d2ad9d`
  matched `23 / 23` payloads and proved the in-memory target Native identity `456534` bytes /
  `167634f7854ae9db5b061e65a8f6148c3ffe0aa399ee66d54bf2039db9fd86c1`, LF-only count `6017`, and no BOM;
- the QA return records one FORMAL invocation and one candidate-010→candidate-011 clone. Dedicated durable exact-one
  counters／host result are absent, but begin-time candidate absence, failure-time candidate existence, timestamps, and
  the frozen driver flow strongly support that report. The driver called its inventory check with whole-tree ReadOnly
  required before byte identity confirmation, before the existing tree-freeze primitive, and before the only permitted
  Native ReadOnly clear. The clone did not satisfy that external precondition;
- failure `aab4acd0bc084ec853b9d8d5746c376435f4081376e88e1e4716c3b7265a22e8` and formal manifest
  `d22140f30cd0ac2c0da66f0958c17c1a52be6e5119494e06e6894a097da1289a` matched `20 / 20` payloads;
- candidate-011 is now frozen ReadOnly and remains candidate-010 seed-identical `8 / 8`; Native remains `456449`
  bytes / `d5068baeb983df3ee88f365d54876273e271c3c59446a22ebcbcfbabdb7de1a9`. Candidate-012 is absent;
- Native ReadOnly clear, semantic write, restore, bounded static, all six compiles, both parses, generated-output launch,
  StagePreparer, Stage, PREACK, performance, A／B／C, and game counts are all `0`.

The exact fresh-clone item that lacked ReadOnly was not durably preserved and must not be inferred. The verified defect
is the external driver's ordering and unsupported precondition, not candidate bytes or the intended correction. This is
not evidence of a candidate correction, production harness, gameplay, or performance defect. Candidate-011 is a frozen
failed-attempt artifact and must not be repaired or adopted for semantic write. Section 32 supersedes Section 31 only for
the following **Recovery Step R5J-A / fresh candidate-012 exact correction and compile／static closure only**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 32. Require exact local／
   origin HEAD and a clean worktree. Freeze the R5J driver, qualification／formal evidence, candidate-010, candidate-011,
   R5I partial Stage, and all earlier artifacts at current bytes and attributes. Do not modify, delete, or complete them.
2. Create exactly one fresh 7-bit ASCII, BOM-free, Windows PowerShell 5-compatible external R5J-A d2 driver with
   `QUALIFY` and `FORMAL` modes. Reuse the already-qualified hash, empty-stream, Unicode-path, root-first, inventory,
   and `Freeze-Tree` primitives; add no new attribute helper, generic classifier, lineage framework, Stage orchestration,
   or product abstraction. Limit d1→d2 semantic changes to mechanical supervisor／step／path／candidate rollover, frozen
   R5J lineage bindings, and the exact clone-attribute ordering／counter／failure-finalization correction in this section.
   Source-audit that bounded difference and the exact ordering in items 4 and 5 before FORMAL.
3. Run `QUALIFY` exactly once before candidate-012 exists. Persist and read back d2, command, begin, receipt, fixtures,
   result, and manifest. Require ASCII-only, no BOM, parser errors `0`, exact repository state, R5J qualification manifest
   `23 / 23`, R5J formal failure manifest `20 / 20`, exact failure identity, candidate-010 and candidate-011 each exact
   `8 / 8` and fully ReadOnly, and candidate-012／candidate-013 absent. Recompute the Section 31 in-memory transform and
   exact expected Native identity unchanged. During QUALIFY, candidate clone／write, compiler, generated-output launch,
   StagePreparer, Stage, mode, PREACK, performance, A／B／C, and game counts remain `0`.
4. Qualification must prove the bounded d2 FORMAL call order exactly once: verify frozen inputs and candidate-012
   absence; clone candidate-010 to candidate-012; inventory the fresh clone **without requiring ReadOnly** and require
   seed byte identity `8 / 8`; apply the existing `Freeze-Tree` primitive to candidate-012 exactly once; read back the
   entire candidate-012 tree ReadOnly; clear ReadOnly only from candidate-012 `source/MfoQaNative.cs` exactly once;
   perform the prequalified one-line semantic write exactly once; and restore Native ReadOnly in `finally` exactly once.
   No other candidate attribute may be loosened. Prove this order statically during QUALIFY; do not add or execute a
   clone／attribute mutation fixture.
5. Only after complete QUALIFY Pass may `FORMAL` run exactly once and follow item 4 without deviation. The only semantic
   insertion remains immediately after the unique `details = body();` in `RoleContext.Execute`:

   ```csharp
   details["performance_slot_attempt_count"] = performanceAttemptCount;
   ```

   Prove candidate-012 Native expected size `456534`, SHA-256
   `167634f7854ae9db5b061e65a8f6148c3ffe0aa399ee66d54bf2039db9fd86c1`, LF-only count `6017`, no BOM,
   prefix／suffix byte equality, exact changed path `1`, insertion `1`, deletion `0`, and other seven files seed-identical.
   Require candidate-010／011 unchanged, candidate-012 full tree ReadOnly, and candidate-013 absent. If FORMAL stops
   after candidate-012 exists, only conditional `finally` restore, actual inventory, first-failure evidence, manifest
   finalization, and the still-unused authorized candidate-012 `Freeze-Tree` invocation are allowed. The candidate-012
   tree freeze has its own counter and remains at most one invocation across FORMAL; qualification／formal evidence-root
   freeze operations are separate counters. Once the candidate-012 freeze is attempted or completed it must not be
   retried. Semantic repair or retry is not allowed.
6. Run the bounded static checks exactly once, then compile candidate-012 fresh exactly once for Native, Runner,
   Launcher, Controller, Sentinel, and StagePreparer, and parse only `RunPreparation.ps1` and
   `RecordRepositoryState.ps1` exactly once each. Retain every Section 31 binding and acceptance condition. Do not reuse
   R4H, R5I, or R5J outputs and do not launch generated output.
7. R5J-A Pass classification is exactly **Pass / candidate-012 exact correction and compile／parse closure only**.
   Driver／path／serialization／attribute-control／evidence interruption is R5J-A Blocked. Seed identity, transform,
   exact-diff, bounded-static, compile, or parse nonconformance is R5J-A Fail. Stop at the first nonconformance. No
   repair, alternate, retry, second d2／QUALIFY／FORMAL／candidate, cleanup, repository edit, commit, or push is authorized.
   Return complete identities, manifests, counters, inventory, static／compile／parse results, residual processes, and
   frozen state directly to `00統括`.

Stop after R5J-A compile／static closure. StagePreparer execution, Stage P, repository-state capture, CONTRACT, all six
preparation modes, PreSealOwnership, SEAL, PREPARED, PREACK, activation, controller, performance, A／B／C execution, P95,
KBM, game, quiet-window preparation, OneDrive shutdown, and power changes remain prohibited. R5J-A Pass does not close
the hold, open Gate 2, authorize Slice 2-B, or itself authorize R5K／Stage P.

## 33. Supervisor closure — R5J-A Pass and Recovery Step R5K Stage P preparation

R5J-A returned **Pass / candidate-012 exact correction and compile／parse closure only**. Independent read-only
verification found no acceptance blocker:

- d2 is `63931` bytes / SHA-256
  `51a09bdefe6feb21b0bf2c40d557b8f20fcf379fae7239251343644b07f72e5d`, 7-bit ASCII, BOM-free, CR `0`,
  Windows PowerShell 5 parser error `0`, and ReadOnly;
- QUALIFY ran exactly once with exit `0`; manifest
  `312d6fbf74b3fc535d309a759bcfa0187b5235f2df8b15674a6b2fe7ad237669` matches `24 / 24` payloads;
- FORMAL ran exactly once with exit `0`; manifest
  `d6d66a075a1122bf236175c56b05b102491ddb049b00d908029abf2e24f1c89e` matches `55 / 55` payloads;
- candidate-012 is exact `8 / 8` with its whole tree `11 / 11` ReadOnly. Its only changed path is
  `source/MfoQaNative.cs`: `456534` bytes / SHA-256
  `167634f7854ae9db5b061e65a8f6148c3ffe0aa399ee66d54bf2039db9fd86c1`, LF-only count `6017`, no BOM,
  insertion `1`, deletion `0`, exact prefix／suffix equality, and exact target／anchor／adjacency count `1`;
- all six fresh C# compiles returned exit `0`; both approved PowerShell parse-only checks returned error count `0`;
- generated-output launch, StagePreparer execution, Stage, modes, PREPARED, PREACK, performance, A／B／C, and game
  remained `0`; residual relevant process count was `0`, repository state was clean, and prior artifacts remained frozen.

The supervisor accepts R5J-A and resolves KI-029. KI-028 is mitigated by the exact correction and compile closure but
remains open until the six production preparation modes prove the complete Pass-details schema. This does not accept
performance or authorize PREACK. Section 33 supersedes Section 32 only for the following **Recovery Step R5K /
immutable candidate-012 fresh Stage P, six-mode, seal, and PREPARED closure**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 33. Require exact local／
   origin HEAD and a clean worktree; record that new execution HEAD. Do not create a receipt commit before preparation.
   Freeze d2, both R5J-A evidence roots, candidate-010／011／012, the R5I partial Stage, and every earlier driver,
   candidate, output, Stage, and evidence root. Candidate-012 must retain all identities above. Candidate-013,
   candidate mutation, ReadOnly removal, source／script change, cleanup, or reuse of prior generated output is prohibited.
2. Create exactly one fresh 7-bit ASCII, BOM-free, Windows PowerShell 5-compatible R5K preparation driver from the
   frozen R5I c8 preparation driver (`105857` bytes / SHA-256
   `9c28774ed30ad756993689444273fce4222c95c7f002743cb69a2568be7b0e2b`). It may contain `QUALIFY` and
   `FORMAL` modes only. Limit semantic changes to mechanical R5K identity／path／execution-HEAD rollover, frozen R5I and
   R5J-A lineage bindings, candidate-012 identities, removal of the already-corrected expected R5I failure, and the
   exact counters／finalization required here. Do not add a generic diff classifier, lineage framework, hash／attribute
   helper, product abstraction, alternate driver, or second driver.
3. Run `QUALIFY` exactly once before any R5K tool, preparation, Stage, or run root exists. Persist and read back the
   driver, command, begin, receipt, zero-byte streams, result, and complete manifest. Require ASCII-only, no BOM,
   parser errors `0`, exact repository state, exact frozen R5I c8 identity and manifests, exact R5J-A d2 and both
   manifests, candidate-012 exact `8 / 8` and fully ReadOnly, candidate-013 absent, configured Stage／run／tool paths
   absent, and real performance／A-B-C counts `0`. QUALIFY must source-audit the exact FORMAL order below without
   launching compiler, StagePreparer, generated output, mode, performance, A／B／C, or game.
4. Only after complete QUALIFY Pass may `FORMAL` run exactly once. Reserve one unique fresh external tool-build parent,
   one fresh Stage P path, and the configured external run path outside every OneDrive directory. Before `INIT`, Stage
   and run paths must be absent. Do not reuse or launch R5J-A compile outputs. Using only
   `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe`, compile candidate-012 Native to one fresh helper DLL
   exactly once, then compile candidate-012 StagePreparer to one fresh x64 optimized EXE exactly once referencing that
   helper. Record `tool_build_attempt_count=1`, both compile counts `1`, retry `0`, exact commands／numeric exits／streams,
   compiler／reference identities, and output size／SHA-256. A compile or source nonconformance is Fail; execution,
   identity, or durable-evidence interruption is Blocked. In either case do not create Stage or retry.
5. Keep internal issuance identities unchanged:
   `--supervisor-commit 808492231ec601da8422691d0bae5a2f8ff35ec1` for all three lifecycle launches and
   `--qa-receipt-commit eda2ac8de05d87b995e7befb8b7ecf9a85170817` for CONTRACT／SEAL. Use the new
   Section 33 supervisor commit only for repository-state observations. Execute exactly one end-to-end preparation
   attempt in this order and stop at the first nonconformance:

   ```text
   StagePreparer INIT (1)
   RecordRepositoryState RepositoryState (1)
   StagePreparer CONTRACT (1)
   QP_DRYRUN (1)
   QP_SELFTEST (1)
   QP_POWER_INPUT_SMOKE (1)
   QP_PREACK_CONTRACT_SELFTEST (1)
   QP_LIVE_EVIDENCE_CONTRACT_SELFTEST (1)
   PA_PERFORMANCE_CONTRACT_SELFTEST (1)
   RecordRepositoryState PreSealOwnership (1)
   StagePreparer SEAL (1)
   ```

   Record `preparation_attempt_count=1`, `stagepreparer_launch_count=3`, repository-state script count `2`, and every
   lifecycle／mode count `1`. INIT must record `fresh_component_compile_count=5`: Native, Runner, Launcher,
   Controller, and Sentinel each exactly `1`. Candidate clone／write／attribute-change and candidate-013 counts remain
   `0`. The PA mode may run fixtures only. Real `performance_slot_attempt_count`, `performance_slot_launch_count`, and
   `abc_launch_count` must remain numeric `0`.
6. CONTRACT must run the complete authorized source-diff audit against the qualified `-009` source and require every
   changed hunk authorized, unauthorized hunk／class count `0`, unrelated regions byte-identical, LF style match, BOM
   match, immutable A／B／C identity, fixed six-slot table／arguments, and candidate-012 identity unchanged. Record the
   authoritative internal changed-hunk count; do not substitute Git unified-diff hunk counts. Each of the six modes
   must return numeric exit `0 / Pass`, with Pass `details` containing numeric-zero
   `performance_slot_attempt_count`, `performance_slot_launch_count`, `abc_launch_count`, and
   `final_owned_runtime_count`. Require complete manifest／receipt／preparation audit, external run root absent,
   ownership／residual agent／process／terminal counts `0`, and all Stage files／directories ReadOnly before PREPARED.
7. On any Fail／Blocked result, freeze the actual partial roots and return complete evidence directly to `00統括`.
   Do not repair, reseal, retry, create another candidate／driver／tool build／Stage, or edit／commit／push repository
   files. Only if every requirement passes may `30` commit and push exactly the existing three approved scopes:
   `docs/test-reports/phase2-slice2a-performance-acceptance.md`, non-executable preparation evidence under
   `docs/test-reports/evidence/phase2-slice2a/diagnostic-004/`, and `docs/handoffs/qa.md`; then return the exact PREPARED
   identity line. Do not commit executables, DLLs, harness source, candidate bytes, or timed-output payloads.
8. Successful completion is exactly **Pass / candidate-012 Stage P PREPARED only**. Stop immediately after PREPARED.
   PREACK, activation, controller, performance slots, real A／B／C execution, P95, KBM, game, quiet-window preparation,
   OneDrive shutdown, AC／power changes, Gate 2, and Slice 2-B remain prohibited until a new exact supervisor order.

R5K is the sole QA execution exception under `MFO-HOLD-P2-2A-001`. It does not close the hold or accept performance.

## 34. Supervisor closure — R5K qualification Blocked and Recovery Step R5K-A

R5K formally returned **Blocked / external R5K qualification lineage serialization-path binding before
candidate／tool／Stage**. The supervisor accepts the Blocked boundary and, from independent read-only verification,
attributes the concrete cause to an **external qualification driver case-insensitive variable collision**:

- d1 is `115526` bytes / SHA-256
  `94fb33fd625b26d7249215fa662cc4fc49a03cd9804f57f5ab8a61345cfc76ee`, 7-bit ASCII, BOM-free,
  Windows PowerShell parser error `0`, and ReadOnly;
- QUALIFY ran exactly once and exited `1`; failure
  `2a268df0f439eb7ce2fe84b6f8af54c498828d0182d773301a324ecd2e490131` and manifest
  `41d258a4097ab45809b61f9a7fae8b8fc646abab14c6c2ba86369714abc48990` match all `3 / 3`
  recorded payloads;
- PowerShell variable names are case-insensitive. d1 assigns the R5I path to `$FrozenR5IDriver`, then assigns an
  `OrderedDictionary` identity to `$frozenR5iDriver`; these are the same variable. The immediately following
  `Get-Item -LiteralPath $FrozenR5IDriver` therefore receives the dictionary type name instead of the path. The
  corresponding `$FrozenR5JADriver`／`$frozenR5jaDriver` pair has the same latent collision;
- FORMAL, compiler, tool build, StagePreparer, mode, Stage, PREACK, performance, A／B／C, and game counts remained `0`;
  candidate-012 remained exact and ReadOnly, downstream roots were absent, repository state was clean, and residual
  relevant process count was `0`.

The supervisor accepts the R5K Blocked result and opens KI-030. This is an external qualification-driver defect, not
candidate-012, production harness, game, or performance evidence. Section 34 supersedes Section 33 only for the
following **Recovery Step R5K-A / paired external identity-variable correction, qualification, and conditional
candidate-012 Stage P preparation**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 34. Require exact local／
   origin HEAD and a clean worktree; do not create a receipt commit. Freeze R5K d1, its qualification root, every
   R5J-A／R5I and earlier artifact, candidate-010／011／012, and every partial Stage／output. Candidate-012 must retain
   the Section 33 identities and full ReadOnly state. Candidate-013 and all candidate／production-source changes remain
   prohibited.
2. Create exactly one fresh 7-bit ASCII, BOM-free, Windows PowerShell 5-compatible R5K-A d2 from frozen R5K d1.
   Apart from mechanical R5K→R5K-A identity／fresh-path／execution-HEAD rollover and the exact fixture／counter／
   finalization required below, the only semantic changes are these six identifier-reference substitutions:

   ```text
   $frozenR5iDriver   -> $frozenR5iDriverIdentity    (exact 4 references)
   $frozenR5jaDriver  -> $frozenR5jaDriverIdentity   (exact 2 references)
   ```

   Keep path variables `$FrozenR5IDriver` and `$FrozenR5JADriver`, their path values, all identity／hash helpers,
   `Write-NewJson`, serialization, manifest logic, candidate-012, production source, and lifecycle behavior unchanged.
   Do not add a helper, generic framework, alternate driver, or second d2.
3. Before QUALIFY, run one detailed d1→d2 audit and one state-free paired-collision fixture. Require only the six
   semantic substitutions above plus approved mechanical／fixture lines; unauthorized semantic changes `0`. Require
   AST variable-expression counts of exact-case legacy identity references `0`, new R5I identity references `4`, and
   new R5J-A identity references `2`, plus exactly one AST assignment to each preserved path variable. String literals
   used by the fixture do not count as variable references. For both collision families, persist and read back that the
   path before／after remains the same `System.String`, the identity is a
   `System.Collections.Specialized.OrderedDictionary`, `Get-Item -LiteralPath` succeeds through the preserved path,
   and expected size／SHA-256 identities match. Record `collision_family_count=2`,
   `legacy_collision_count_in_d1=2`, `collision_count_in_d2=0`, and `fixture_execution_count=1`.
4. Run d2 `QUALIFY` exactly once before any R5K-A FORMAL, compiler, tool, preparation, Stage, mode, run, performance,
   A／B／C, or game root／process exists. Preserve every Section 33 qualification condition. Additionally bind and
   verify the frozen R5K d1 identity, frozen R5K failure, complete `3 / 3` manifest, the d1→d2 audit, the paired fixture,
   and separated historical／local counters. Persist and read back root-first begin／receipt, zero-byte streams,
   command, result, failure absence, and complete manifest; freeze d2 and the qualification root ReadOnly. During
   QUALIFY, all FORMAL／compiler／StagePreparer／generated-output／mode／performance／A-B-C／game counts remain `0`.
5. Only after complete QUALIFY Pass may d2 `FORMAL` run exactly once. Execute the unchanged Section 33 steps 4 through
   6 with one fresh external tool-build parent, one fresh Stage P path, immutable candidate-012, and no reuse or launch
   of prior outputs. Required local counters are: FORMAL `1`, tool-build attempt `1`, Native helper compile `1`,
   StagePreparer compile `1`, retry `0`, preparation attempt `1`, StagePreparer launches `3`, RepositoryState script
   launches `2`, each of the six modes `1`, PreSealOwnership `1`, candidate create／clone／write／attribute-change `0`,
   candidate-013 `0`, real performance attempt／launch `0`, A／B／C launch `0`, and game launch `0`.
6. Keep the Section 33 internal issuance identities, lifecycle order, CONTRACT acceptance, six-mode four-field Pass
   details, complete receipt／audit／manifest, ownership, residual-process, terminal, and ReadOnly requirements exact.
   Do not substitute Git hunk counts for the production CONTRACT count. The PA mode may run fixtures only and must not
   start a real performance slot.
7. Stop at the first nonconformance. After d2 creation or QUALIFY begins, no repair, alternate, second d2／audit／
   fixture／QUALIFY／FORMAL／tool build／Stage, reseal, cleanup, evidence rewrite, or candidate／repository edit is
   authorized. Freeze the actual roots and return complete identities, commands, numeric exits, streams, manifests,
   counters, inventories, process closure, and classification directly to `00統括`. Only a complete Pass may commit
   and push the same three non-executable QA scopes authorized in Section 33.
8. Successful completion is exactly **Pass / candidate-012 Stage P PREPARED only**. Stop immediately after PREPARED.
   PREACK, activation, controller, performance slots, real A／B／C execution, P95, KBM, game, user quiet window,
   OneDrive shutdown, AC／power changes, Gate 2, and Slice 2-B remain prohibited until a new exact supervisor order.

Under Section 34, R5K-A was the sole QA execution exception under `MFO-HOLD-P2-2A-001`; that authority is
superseded by Section 35. R5K-A did not close the hold or accept performance.

## 35. Supervisor closure — R5K-A prequalification Blocked and Recovery Step R5K-B

R5K-A formally returned **Blocked / external R5K-A prequalification payload-order binding mismatch before FORMAL**.
Independent read-only verification found:

- the executed materialization instrument v2 is `34443` bytes / SHA-256
  `8ce3ac6ee6b7816d01233a86f827ef0c84cb225e996ec4731e91670c60942bf1`, ASCII, BOM-free, parser
  error `0`, and ReadOnly; d2 is `126400` bytes / SHA-256
  `7650361e9a7f7501f967ce16b700af0dc3469e3e59417e1b43a5aa5dcbc4d460`, parser error `0`, and
  ReadOnly;
- the d1→d2 detailed audit passed with `26` operations, exact semantic substitutions `6`, unauthorized `0`, legacy／
  new R5I identity refs `0 / 4`, legacy／new R5J-A identity refs `0 / 2`, and path assignments `1 / 1`; the paired
  collision fixture passed with counters `2 / 2 / 0 / 1` and both identity types `OrderedDictionary`;
- prequalification manifest `da2a9ab4f091513c8b54accb1d8cec63d5f44281ed06220ebea99b70e7482caa`
  matches all `4 / 4` payloads. Its payload order and the actual `Sort-Object FullName` enumeration are both:

  ```text
  d1-d2-detailed-audit.json
  paired-collision-fixture.json
  prequalification-result.json
  R5KA_PREQUAL_ATTEMPT_BEGIN.json
  ```

  d2 alone hard-codes `R5KA_PREQUAL_ATTEMPT_BEGIN.json` first, followed by audit, fixture, and result. All four names,
  sizes, and SHA-256 identities are otherwise equal;
- QUALIFY ran exactly once and stopped at `R5K_FAIL_PREQUALIFICATION_PAYLOAD`. Failure
  `9c10274ffadd6f764b4b23da822b61fce75a1af95f905dcd9c15323a54ad881c` and qualification manifest
  `fef6489f56493d0ca04f6808e7a515259c214774eeb003f3bc841d523128d19a` match all `4 / 4`
  recorded payloads;
- FORMAL, compiler, tool build, StagePreparer, mode, Stage, PREACK, performance, A／B／C, and game remained `0`.
  Candidate-012 stayed exact and ReadOnly, candidate-013 and downstream roots were absent, repository state was clean,
  and current residual relevant process count was `0`.

The supervisor accepts the R5K-A Blocked result and resolves KI-030 because the six-reference correction and paired
fixture passed. KI-031 is opened for the positional expected-name false negative. This is external driver evidence,
not candidate-012, production harness, game, or performance evidence. Section 35 supersedes Section 34 only for the
following **Recovery Step R5K-B / one payload-order correction, fresh lineage qualification, and conditional
candidate-012 Stage P preparation**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 35. Require exact local／
   origin HEAD and a clean worktree; do not create a receipt commit. Do not use, execute, edit, or change attributes on
   the unexecuted v1 draft. Freeze the executed R5K-A instrument v2, d2, both R5K-A roots, d1 and its roots, every prior
   candidate／driver／evidence／partial Stage／output, and candidate-012. Do not
   modify or rerun frozen d1→d2 audit or paired collision fixture. Candidate-013 and all candidate／production-source
   changes remain prohibited.
2. Create exactly one fresh 7-bit ASCII, BOM-free, Windows PowerShell 5-compatible R5K-B materializer v3 from the
   frozen executed v2. Before execution require parser error `0`, exact frozen-v2 identity, and a complete source-diff
   classification. V3 may create exactly one fresh d3 from frozen d2 and one fresh R5K-B prequalification root.
   Allowed changes are only mechanical R5K-A→R5K-B／d2→d3／fresh-path／stage-ID／Section-35 execution-HEAD rollover,
   the exact expected-order correction below, frozen R5K-A lineage binding, fresh d2→d3 audit／order fixture, and
   their local counters／finalization. Do not add or change hash／serialization／manifest helpers, `Sort-Object FullName`,
   payload-loop behavior, candidate logic, product code, production lifecycle, alternate materializer, or second d3.
3. The only functional correction in d3 is exact once:

   ```powershell
   # frozen d2
   $prequalNames=@('R5KA_PREQUAL_ATTEMPT_BEGIN.json','d1-d2-detailed-audit.json','paired-collision-fixture.json','prequalification-result.json')
   # fresh d3
   $prequalNames=@('d1-d2-detailed-audit.json','paired-collision-fixture.json','prequalification-result.json','R5KA_PREQUAL_ATTEMPT_BEGIN.json')
   ```

   Treat `$R5KAPrequalificationRoot` as frozen historical lineage. Its `execution_head` must equal
   `2bd9da1f3b2e9242f09c9e39a952c90982faeb5a`; its manifest `driver_sha256`, manifest `d2.sha256`, and result
   `d2.sha256` must bind frozen d2, never current d3. Bind current d3 only through the fresh R5K-B prequalification
   manifest and d2→d3 audit. Record frozen R5K-A prequalification lineage, frozen R5K-A qualification lineage, and
   R5K-B prequalification lineage separately. Frozen R5K-A schemas and bytes remain unchanged; current output schemas
   may roll mechanically to `mfo.qa.r5k-b.*`.
4. Execute v3 exactly once. The fresh prequalification root must be root-first and contain a begin record, one
   d2→d3 detailed audit, one state-free payload-order fixture, one result, and one self-excluded manifest. Require d3
   creation `1`, audit `1`, fixture `1`, parser error `0`, ASCII-only, no BOM, exact old sequence in d2 `1`／d3 `0`,
   corrected sequence in d2 `0`／d3 `1`, `$prequalNames` assignment count `1` in each driver, order-correction semantic
   count `1`, unauthorized semantic change `0`, and manifest enumeration／payload-loop AST extents byte-identical.
   The fixture must read frozen R5K-A evidence without mutation and persist actual names, manifest names, legacy names,
   and corrected names with `payload_count=4`, manifest-order matches `4`, corrected-order matches `4`, legacy-order
   matches `0`, payload-identity matches `4`, fixture execution `1`, process launch `0`, and frozen-root mutation `0`.
   Validate the fresh root by manifest-to-actual index equality and an independent exact required-name set; do not add
   another hand-maintained positional list.
5. Only after complete materialization／audit／fixture Pass and full ReadOnly freeze may d3 `QUALIFY` run exactly once.
   Bind the complete frozen R5K／R5K-A histories and fresh R5K-B prequalification evidence, then execute every remaining
   Section 34 QUALIFY condition without omission. Historical counters remain separate: frozen R5K QUALIFY `1`／FORMAL
   `0`; frozen R5K-A d2 creation／d1→d2 audit／paired fixture／QUALIFY each `1`, FORMAL `0`; R5K-B materializer／d3
   creation／d2→d3 audit／order fixture／QUALIFY each `1`, FORMAL `0`. During QUALIFY, compiler／tool／preparation／
   StagePreparer／mode／performance／A-B-C／game／candidate mutation counts remain `0`. Require failure absence, complete
   manifest equality, and d3／all roots ReadOnly before proceeding.
6. Only after complete QUALIFY Pass may d3 `FORMAL` run exactly once. Execute Section 34 items 5 and 6 unchanged with
   one unique fresh tool-build parent and Stage P path. Required local counters remain: FORMAL `1`, tool-build attempt
   `1`, retry `0`, Native helper compile `1`, StagePreparer compile `1`, preparation attempt `1`, StagePreparer INIT／
   CONTRACT／SEAL each `1` and total `3`, repository-state script count `2` with RepositoryState `1` and
   PreSealOwnership `1`, each of six modes `1`, fresh
   component compile `5` with each role `1`, and candidate create／clone／write／attribute／promotion, candidate-013,
   real performance attempt／launch, A／B／C launch, and game launch all `0`. Keep internal issuance identities
   `808492231ec601da8422691d0bae5a2f8ff35ec1`／`eda2ac8de05d87b995e7befb8b7ecf9a85170817`, CONTRACT,
   six-mode four-field Pass details, ownership, residual, terminal, manifest, and ReadOnly requirements unchanged.
7. Stop at the first nonconformance. Materializer／audit／fixture failure returns with QUALIFY `0`; QUALIFY failure
   returns with FORMAL `0`; FORMAL failure returns at its actual partial state. No repair, alternate, second v3／d3／
   audit／fixture／QUALIFY／FORMAL／tool build／Stage, reseal, cleanup, evidence rewrite, candidate change, or repository
   edit is authorized. Freeze and return complete evidence directly to `00統括`. Only a complete Pass may commit and
   push the same three non-executable QA scopes authorized in Section 34.
8. Successful completion is exactly **Pass / candidate-012 Stage P PREPARED only**. Stop immediately after PREPARED.
   PREACK, activation, controller, performance slots, real A／B／C execution, P95, KBM, game, user quiet window,
   OneDrive shutdown, AC／power changes, Gate 2, and Slice 2-B remain prohibited until a new exact supervisor order.

Under Section 35, R5K-B was the sole QA execution exception under `MFO-HOLD-P2-2A-001`; that authority is
superseded by Section 36. R5K-B did not close the hold or accept performance.

## 36. Supervisor closure — R5K-B qualification Blocked and Recovery Step R5K-C

R5K-B formally returned **Blocked / external d3 qualification lineage initialization-order defect before FORMAL**.
Independent read-only verification found:

- executed v3 is `41077` bytes / SHA-256
  `d3d81fc0ab1b13f0218b677a75c3016666dd5142ddeea7946cf168d513c5b259`, ASCII, BOM-free, parser
  error `0`, and ReadOnly; d3 is `138180` bytes / SHA-256
  `c2381abcb73e3236fe175b5eb62e355486149da9bf4d6a0b455dd35e37706e78`, parser error `0`, and
  ReadOnly;
- prequalification manifest `a66710d49fc9d56e02b540d5f4c6d6189b377c9738ec6c5cbf84e9bcface7596`
  matches all `4 / 4` payloads. The d2→d3 audit passed with d3 creation `1`, audit `1`, expected-order
  semantic correction `1`, unauthorized `0`; the order fixture passed with manifest／corrected／legacy／payload
  identity counts `4 / 4 / 0 / 4`, process launch `0`, and frozen mutation `0`;
- d3 has one assignment to `$frozenR5kaDriverIdentity` at line 310, but its first runtime reference is line 298.
  Four non-assignment references occur before the assignment. Under StrictMode, QUALIFY stopped at that first reference
  with `The variable '$frozenR5kaDriverIdentity' cannot be retrieved because it has not been set.`;
- QUALIFY ran exactly once. QA reported outer exit `1`; no dedicated numeric-exit artifact exists, while persisted
  failure `16f3ce70db858b7c4a9ee7e48c4eb3d03f27996ad9df7104ccc5d0f0472e35a0` and qualification manifest
  `60a5cdb51da3f2f6328e9566926a6a2888f9293728134de0378f9d4d27c7872f` independently match all
  `4 / 4` recorded payloads and the static use-before-initialization order;
- FORMAL, compiler, tool build, StagePreparer, mode, Stage, PREACK, performance, A／B／C, and game remained `0`.
  Candidate-012 stayed exact and ReadOnly, candidate-013 and downstream roots were absent, repository state was clean,
  and current residual relevant process count was `0`.

The supervisor accepts the R5K-B Blocked result and resolves KI-031 because the expected-order correction, audit, and
fixture passed. KI-032 is opened for the d3 initialization-order defect. This is external driver evidence, not
candidate-012, production harness, game, or performance evidence. Section 36 supersedes Section 35 only for the
following **Recovery Step R5K-C / one assignment relocation, fresh lineage qualification, and conditional
candidate-012 Stage P preparation**:

1. Fast-forward the required QA branch to the pushed supervisor commit containing Section 36. Require exact local／
   origin HEAD and a clean worktree; do not create a receipt commit. Freeze executed v3, d3, both R5K-B roots, v2／d2
   and their roots, every prior candidate／driver／evidence／partial Stage／output, and candidate-012. Do not modify or
   rerun the frozen d2→d3 audit or order fixture. Candidate-013 and all candidate／production-source changes remain
   prohibited.
2. Create exactly one fresh 7-bit ASCII, BOM-free, Windows PowerShell 5-compatible R5K-C materializer v4 from frozen
   executed v3. Before execution require parser error `0`, exact frozen-v3 identity, and a complete source-diff
   classification. V4 may create exactly one fresh d4 from frozen d3 and one fresh R5K-C prequalification root.
   Allowed changes are only mechanical R5K-B→R5K-C／d3→d4／fresh-path／stage-ID／Section-36 execution-HEAD rollover,
   the exact assignment relocation below, frozen R5K-B lineage binding, fresh d3→d4 audit／initialization-order
   fixture, and their local counters／finalization. Do not add or change hash／serialization／manifest helpers,
   `Sort-Object FullName`, payload-loop behavior, candidate logic, product code, production lifecycle, alternate
   materializer, or second d4.
3. The only functional correction in d4 is to relocate this existing AST statement exact once, with expression bytes
   unchanged:

   ```powershell
   $frozenR5kaDriverIdentity=Assert-Identity $FrozenR5KADriver 126400 '7650361e9a7f7501f967ce16b700af0dc3469e3e59417e1b43a5aa5dcbc4d460' 'frozen-r5k-a-d2-driver'
   ```

   Remove it exact once from the frozen d3 position after the R5K-A prequalification-lineage record and insert it
   exact once immediately before
   `$prequalManifestPath=Join-Path $R5KAPrequalificationRoot 'SHA256-MANIFEST.json'`, after all right-hand-side
   dependencies are initialized and before every runtime reference to the identity. Do not rename or duplicate the
   variable, alter the assignment expression, move or change the existing ReadOnly guard, or reorder any other
   QUALIFY statement.
4. Execute v4 exactly once. The fresh prequalification root must be root-first and contain a begin record, one d3→d4
   detailed audit, one state-free initialization-order fixture, one result, and one self-excluded manifest. Require
   d4 creation `1`, audit `1`, fixture `1`, parser error `0`, ASCII-only, no BOM, relocation semantic count `1`,
   unauthorized semantic change `0`, assignment count d3／d4 `1 / 1`, non-assignment reference count `8 / 8`,
   pre-assignment reference count `4 / 0`, assignment-before-all-references d3／d4 `false / true`, and the existing
   payload-order corrected sequence present exact once in both d3 and d4. Require manifest enumeration／payload-loop
   AST extents and every non-target statement to remain byte-identical. The fixture must run under StrictMode without
   process launch, bind the frozen d2 size／SHA／identity type, demonstrate assignment dominance and lineage-record
   construction, and persist fixture execution `1`, process launch `0`, frozen-root mutation `0`. Validate all
   `4 / 4` manifest payloads by index equality and an independent exact required-name set.
5. Only after complete materialization／audit／fixture Pass and full ReadOnly freeze may d4 `QUALIFY` run exactly once.
   Bind the complete frozen R5K／R5K-A／R5K-B histories and fresh R5K-C prequalification evidence, then execute every
   remaining Section 35 QUALIFY condition without omission. Historical counters remain separate: frozen R5K
   QUALIFY／FORMAL `1 / 0`; frozen R5K-A materializer／d2／audit／collision fixture／QUALIFY each `1`, FORMAL `0`;
   frozen R5K-B v3／d3／audit／order fixture／QUALIFY each `1`, FORMAL `0`; R5K-C v4／d4／audit／initialization fixture／
   QUALIFY each `1`, FORMAL `0`. During QUALIFY, compiler／tool／preparation／StagePreparer／mode／performance／
   A-B-C／game／candidate mutation counts remain `0`. Require failure absence, complete manifest equality, and d4／
   all roots ReadOnly before proceeding.
6. Only after complete QUALIFY Pass may d4 `FORMAL` run exactly once. Execute Section 35 item 6 unchanged with
   one unique fresh tool-build parent and Stage P path. Required local counters remain: FORMAL `1`, tool-build attempt
   `1`, retry `0`, Native helper compile `1`, StagePreparer compile `1`, preparation attempt `1`,
   StagePreparer INIT／CONTRACT／SEAL each `1` and total `3`, repository-state script count `2` with RepositoryState
   `1` and PreSealOwnership `1`, each of six modes `1`, fresh component compile `5` with each role `1`, and
   candidate create／clone／write／attribute／promotion, candidate-013, real performance attempt／launch, A／B／C launch,
   and game launch all `0`. Keep internal issuance identities
   `808492231ec601da8422691d0bae5a2f8ff35ec1`／`eda2ac8de05d87b995e7befb8b7ecf9a85170817`, CONTRACT,
   six-mode four-field Pass details, ownership, residual, terminal, manifest, and ReadOnly requirements unchanged.
7. Stop at the first nonconformance. Materializer／audit／fixture failure returns with QUALIFY `0`; QUALIFY failure
   returns with FORMAL `0`; FORMAL failure returns at its actual partial state. No repair, alternate, second v4／d4／
   audit／fixture／QUALIFY／FORMAL／tool build／Stage, reseal, cleanup, evidence rewrite, candidate change, or repository
   edit is authorized. Freeze and return complete evidence directly to `00統括`. Only a complete Pass may commit and
   push the same three non-executable QA scopes authorized in Section 35.
8. Successful completion is exactly **Pass / candidate-012 Stage P PREPARED only**. Stop immediately after PREPARED.
   PREACK, activation, controller, performance slots, real A／B／C execution, P95, KBM, game, user quiet window,
   OneDrive shutdown, AC／power changes, Gate 2, and Slice 2-B remain prohibited until a new exact supervisor order.

R5K-C is the sole QA execution exception under `MFO-HOLD-P2-2A-001`. It does not close the hold or accept performance.
