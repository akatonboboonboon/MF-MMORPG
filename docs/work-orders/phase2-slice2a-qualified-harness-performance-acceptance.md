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
- Status: **Active / pre-PREPARED recovery authorized / performance not started**
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
