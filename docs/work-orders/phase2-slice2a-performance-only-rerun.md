# Work Order — Phase 2 Slice 2-A Performance-Only Final Rerun

- Work order ID: `MFO-WO-P2-2A-005`
- Issued by: `00統括（監督）`
- Issued: 2026-07-15 (Asia/Tokyo)
- Priority: **P1 / final unresolved Slice 2-A acceptance component**
- Findings: `MFO-P2-2A-QA-002`, [`KI-010`](../KNOWN_ISSUES.md), [`KI-012`](../KNOWN_ISSUES.md),
  [`KI-013`](../KNOWN_ISSUES.md)
- Owner: `30 QA・性能・レビュー`
- Required user role: temporary closure of every OneDrive client and quiet-host control
- Gameplay owner: `10ゲームプレイ・コア実装` — no work in this order
- Presentation owner: `20ステージ・UI・グラフィック` — no integration work in this order
- Status: **Returned / Performance Blocked / external-state hold active**
- Milestone: M2 / Slice 2-A acceptance
- Gate 2: **Locked / not evaluated**
- Ancestry base: `bfaff7bb88f535ca568765263a65c8513bd43a39`
- Required starting state: the pushed supervisor commit containing this order; `30` records its exact SHA
- Required QA branch: `codex/phase2-slice2a-performance-only-qa`
- Required report: `docs/test-reports/phase2-slice2a-performance-only-rerun.md`
- Required evidence root: `docs/test-reports/evidence/phase2-slice2a/diagnostic-003/`

This order changes no product requirement, Approved decision, gameplay value, recorder, percentile implementation,
threshold, scene, project setting, renderer, or quality setting. It does not authorize gameplay edits, integration to
`main`, Slice 2-B, or Gate 2. Direct push to `main` is prohibited.

## 1. Supervisor disposition

`00統括` accepts `MFO-WO-P2-2A-004` as **Performance Blocked / KBM Pass / overall Blocked**. Its report and
`diagnostic-002/` evidence are frozen historical records.

- the OneDrive-family CPU delta `32.15625 CPU-seconds`, system CPU average `38.250224%`, and maximum
  `46.012270%` recompute from the primary preflight evidence and exceed the unchanged integrity limits;
- A1 through A2 were correctly Not run and no P95 was interpreted;
- corrected-C KBM attempt 3 was an independent `27.973 s` foreground-stable capture, and its technical evidence plus
  the user's intentional-input and six-item no-problem confirmation support **KBM Pass**;
- the earlier functional suites remain Pass, while the earlier valid correction performance Fail remains historical
  evidence until a new valid matrix resolves current acceptance;
- no evidence supports returning game code to `10` at this point.

The `-004` quiet window included two complete executable copy／hash cycles and a controller repair before preflight.
The two cycles copied `654,531,568` bytes of A／B／C executables from the OneDrive workspace and also read source and
destination files for hashing, without a separate settled-host boundary. The user separately reports that another
OneDrive account was open; the observed processes are not attributed to a specific account. Account identifiers and
files are out of scope. These facts do not reverse the Blocked result, but they prohibit repeating the same procedure.
This order separates all preparation from the timed window and requires every OneDrive-family process to be absent at
each required inventory sample.

The accepted `-004` KBM component must not be rerun under this order.

## 2. Authorized tracked scope

`30` may commit changes only to:

- the required new performance-only report;
- new evidence below the required `diagnostic-003/` root;
- `docs/handoffs/qa.md`.

All prior reports／evidence, game code, tests, recorder, scenes, `project.godot`, export presets, InputMap, quality,
resolution, renderer, gameplay constants, and supervisor documents are read-only. A／B／C executables and export packs
must never be copied into tracked evidence, committed, or pushed.

## 3. Stage P — preparation before user activation

Preparation is not an acceptance run and may occur while the user continues normal work. Complete all of it before
asking the user to close OneDrive or provide a quiet window.

1. Create a new stable stage below `%LOCALAPPDATA%` or `%TEMP%`, outside every OneDrive directory.
2. Materialize A／B／C there. Reuse an existing non-OneDrive copy only if it passes the complete identity checks below.
3. Record full SHA-256, byte size, `MZ`, last-write time, source commit, source path, and staged path for all three.
4. Finalize the performance controller, exact invocation, APIs, output paths, timeout behavior, process ownership, and
   evidence schema. Run a non-acceptance dry-run that launches no performance slot.
5. Do not use CIM calls already shown to fail on this host. Any controller repair or source change occurs only here.
6. The controller must accept the sealed stage path and must not require a repository path during timed execution.
7. Identify every QA-owned process by PID, process creation time, and exact image path. Before activation, verify all
   preparation PIDs have exited and no `MFO-A`, `MFO-B`, `MFO-C`, `MFO-Phase1`, or `Godot*` process remains.
8. Define an exclusive stage ID and controller mutex／lock. Record the allowed performance-controller self identity;
   a parallel or earlier controller for this stage is forbidden.
9. Seal every slot's label, executable path, exact arguments and arena flags, working directory, sanitized allowlist
   of test-relevant environment fields／overrides, log, JSON, capture path, and fixed order. Never record secrets,
   credentials, account identifiers, or the unrestricted parent environment. Slot invocation must not be constructed
   from unsealed runtime input.
10. Hash the final controller and write a sealed preparation manifest covering controller identity, A／B／C identity,
    slot invocations, expected matrix, output paths, file sizes／times, and the exited owned-process identities. Hash
    the manifest itself and record its SHA-256.

Immutable executable set:

| Label | Source | Required EXE SHA-256 |
|---|---|---|
| A | Gate 1 baseline `a13505e8fbf82962e049b9101a87593a6692d2c7` | `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` |
| B | pre-correction `295549373fbb3b39deb6079172783ce62c7da532` | `3c15c254fbb8025d88c5636f2175a35f6e325b5368c8098e78b16181090dd4ef` |
| C | corrected `5261a73707daca03cb160e03a12247886d3f5cce` | `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47` |

After preparation is sealed, `30` sends this format with concrete values:

```text
MFO-WO-P2-2A-005 PREPARED stage_id=<stage-id> manifest_sha256=<64-hex>
```

The acceptance rules and thresholds never change under this order. The manifest, staged executable, controller source,
slot／controller invocation, or output plumbing may not change after PREPARED. If one of those staged items must change,
discard that stage, return to Stage P, create a new stage ID／manifest digest, and send PREPARED again before user
activation.

## 4. User closure and activation contract

The repository stays at its current path. No file or account is moved, and QA must not inspect or record an email
address, account name, unrelated OneDrive path, or unrelated file.

After receiving PREPARED, the user:

1. saves unrelated work;
2. manually quits every visible OneDrive client for every account;
3. stops heavy apps, downloads, exports, media playback, and other background work;
4. keeps AC power connected;
5. allows QA to inspect only OneDrive-family process names and PIDs.

QA does not kill a process, sign out an account, change startup settings, delete files, free quota, move the repository,
or resume OneDrive. If any `OneDrive*` process remains, QA does not acknowledge activation and tells the user only the
remaining process names／PIDs. The user decides whether to close them manually.

When the user believes all clients are closed and is ready to leave the machine untouched, the user copies the stage
ID and manifest digest from QA's PREPARED message into this format, sends it, and then leaves the machine untouched
until QA announces completion or prerequisite rejection:

```text
MFO-WO-P2-2A-005 stage_id=<stage-id> manifest_sha256=<64-hex> ALL ONEDRIVE CLOSED / QUIET WINDOW READY
```

QA first recomputes the manifest digest and full SHA-256 of staged A／B／C and the final controller outside the timed
window, then confirms the supplied stage ID／digest, OneDrive-family process count `0`, AC／Best performance, and no
owned runtime. If any prerequisite fails, the 10-minute deadline does not start. After all pass, QA sends one
acknowledgement that measurement is starting and invokes the already sealed controller command without adding or
changing arguments. As its first timed action, the controller records its own local timestamp and system-wide
monotonic tick, and that controller-recorded tick is the only origin for the 10-minute deadline. No activation time or
deadline value is supplied as an unsealed command argument.

## 5. Timed quiet-host preflight

After acknowledgement, the controller may read and write only below the sealed non-OneDrive stage. It must not access
the repository, invoke Git, copy or hash repository files, edit itself, or attach a GUI-control session. Full executable
hashing is already complete; timed integrity uses the sealed manifest plus staged byte size, last-write time, and `MZ`.

1. Observe a `60-second` settled interval with required inventories at 1 Hz.
2. At every required inventory, match process names case-insensitively with `OneDrive*` and require count `0`. Save
   only process name and PID for every match; do not inspect or record creation time, CPU, image path, command line, or
   account information. Enumeration／access failure is terminal. A count-zero sample records OneDrive-family CPU delta
   `0`; do not reuse the prior PID-delta algorithm. Any observed reappearance is terminal `Blocked` with no retry.
   Continuous absence between the required 1 Hz inventories is not claimed.
3. Require the session input tick unchanged and AC／Best performance GUID
   `ded574b5-45a0-4f42-8737-46345c09c238` throughout.
4. After settling, run a 15-interval, 1 Hz preflight and record actual monotonic wall duration.
5. Save raw `GetSystemTimes` idle／kernel／user snapshots and monotonic timestamps. Calculate preflight average from
   the aggregate first-to-last counter delta, calculate interval maxima from each delta, and apply thresholds to
   unrounded values. Require average `<= 20%` and no interval above `40%`.
6. Require no owned runtime, APIs loaded, and sealed identity intact. Expected processes are identified by PID,
   creation time, and exact image path. The current controller self PID is explicitly allowed; prior controller
   identities are not.
7. The existing OneDrive-family CPU limit remains `<= 0.25 CPU-seconds`; process count `0` produces `0`.

The `60-second` settled interval runs once. If only system CPU fails while OneDrive count, input, power, identity, and
APIs remain valid, wait a fixed `15 seconds` and retry only the complete 15-interval CPU preflight, up to three
15-interval attempts total. Input change, invalid power, OneDrive reappearance, identity change, missing sample,
controller error, or owned-runtime residue is terminal `Blocked`. Preserve every attempt. Enforce the 10-minute
deadline using the controller-recorded monotonic origin. Do not start pre-A1 idle／matrix unless at least `420 seconds`
remain, reserving six `60-second` slot budgets, six `5-second` idle budgets, and `30 seconds` for bounded
cleanup／finalization.

## 6. One fixed performance matrix

After one passing preflight, run exactly once:

```text
A1 → B1 → C1 → C2 → B2 → A2
```

Each slot is a new process using the unchanged arena scenario, `120` warmup frames, `600` samples, standard quality,
GL Compatibility, and a `1920×1080` project window. Use the same `5,000 ms` pre-A1 and inter-slot idle. Each slot has a
`60-second` total budget from process launch through normal exit and ordinary cleanup. At budget expiry the slot is
immediately `Blocked`; an additional safety cleanup grace of at most `5 seconds` may stop only the exact owned process
and children, cannot rescue or continue the slot, and must fit within the global `30-second` cleanup／finalization
reserve. Preserve the `-004` foreground-acquisition rule: the game must become foreground during the
120-frame warmup and no later than `1,000 ms` after the timestamped startup line, without `SendInput`.

Maintain one session-wide input baseline, AC／Best performance, OneDrive-family count `0` at every required 1 Hz
inventory, foreground ownership while the game is live, and continuous integrity monitoring through A2. During idle,
MFO／Godot process count is `0`. For each slot, the controller launches the sealed executable path, immediately records
the returned PID and creation time, resolves its image path, and requires that path to equal the sealed path. That
runtime PID／creation-time／image-path tuple becomes the expected identity for that slot; only that tuple is allowed and
all extra MFO／Godot processes are forbidden. Failure to capture or match the tuple is `Blocked`. Normal window
destruction after the recorded completion boundary is not foreground loss.

For each sample with wall interval `delta_wall_seconds` and logical processor count `N`:

```text
game_process_pct = 100 × delta_game_cpu_seconds / (delta_wall_seconds × N)
background_pct = clamp(system_total_pct - game_process_pct, 0%, 100%)
```

The controller remains part of background load. Save raw counters and monotonic wall intervals. Calculate each segment
background average as `sum(background_pct × delta_wall_seconds) / sum(delta_wall_seconds)`, and apply average／maximum
thresholds to unrounded values. Every slot and idle segment requires background average `<= 20%`, no sample above
`40%`, and OneDrive-family CPU delta `<= 0.25 CPU-seconds`. Missing／non-comparable samples, process
reappearance, input change, power invalidity, live-game foreground loss, timeout, nonzero exit, missing output, or
controller-finalization failure makes the matrix `Blocked`; stop before the next slot. Never replace a slot, continue
after terminal invalidity, or discard a valid threshold failure.

Every launch／timeout／exception path uses slot-local `try/finally`, stops only the exact QA-owned PID and its owned
children, observes the `5-second` safety-cleanup maximum above, and records exit／cleanup results. A leftover owned
process is Blocked.

Do not use computer-use, external screenshots, chat interaction, Git, repository I/O, or GUI automation during the
timed matrix, apart from the already authorized pre-slot `SetForegroundWindow` call. The sealed game-generated capture
remains required. All outputs remain in the sealed stage until the timed controller has ended.

## 7. Performance disposition

Only a complete six-slot valid matrix is interpreted:

| Evidence pattern | Performance recommendation |
|---|---|
| A and C each have two P95 values `<= 16.67 ms` | **Pass**; B remains attribution-only |
| A has any valid threshold failure | **Blocked / control not reproduced** |
| A passes twice, B passes twice, and C exceeds the threshold twice | **Fail / correction-delta correlation** |
| A passes twice, and B／C each exceed the threshold twice | **Fail / failure present before correction; relative magnitude un-attributed** |
| A passes twice, but C has any other valid threshold failure, including a Pass／Fail mix | **Fail / current candidate does not meet acceptance; causality unisolated** |

Any C P95 above `16.67 ms` prevents Pass. Invalid or partial matrices are never converted to Pass or Fail.

## 8. Frozen KBM evidence

Do not launch a normal corrected-C KBM session and do not ask the user to repeat the six-item checklist. The accepted
KBM evidence is:

- report: `docs/test-reports/phase2-slice2a-controlled-rerun.md`;
- evidence: `docs/test-reports/evidence/phase2-slice2a/diagnostic-002/controlled-20260715-67ba7f3/`;
- evidence manifest SHA-256: `f17de23065a66a982515b6d1030e926ad9d8e9c801d0e6a04950f3beb908ca03`;
- QA content／closure: `45eeeb32a525b922eada9624385691a2143fd7db` / `bfaff7bb88f535ca568765263a65c8513bd43a39`;
- corrected C SHA-256: `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47`;
- component: **KBM Pass**;
- user feel: **Pass / no issue reported**;
- physical gamepad: **Not run / Deferred**.

The report must note the observer-source／exact-observer-command reproducibility limitation from `-004`; this does not
invalidate the accepted component and does not authorize another KBM run.

## 9. Post-run integrity and evidence

After the timed controller ends and QA tells the user input is allowed:

1. record the final timed OneDrive-family inventory and require count `0` at the controller boundary;
2. require owned process count `0`, then full-hash staged A／B／C, the controller, and the sealed manifest again;
3. if any post-run identity differs from the prepared identity, classify the matrix `Blocked`, do not interpret its
   P95 values, and preserve both identities;
4. preserve the exact preparation and performance controller sources, invocations, hashes, process inventories,
   preflight samples, continuous samples, segment summaries, slot JSON／stdout／stderr／capture, exits, and disposition;
5. copy only compact non-executable evidence into `diagnostic-003/` and verify source／destination hashes;
6. create a manifest covering every committed evidence file; explicitly record that no executable／export pack was
   copied;
7. record the exact changed-path audit and privacy handling.

QA tells the user that the final controller-boundary inventory observed OneDrive-family process count `0` and that QA
did not restart a client. Only the user decides when to restart one or more clients.

## 10. Routing and terminal rule

The final QA output is one performance recommendation: `Pass`, `Fail`, or `Blocked`. QA does not accept Slice 2-A,
close Gate 2, authorize Slice 2-B, edit game code, or rewrite prior evidence.

If this order returns Blocked because OneDrive cannot remain absent or the quiet host still cannot meet integrity
limits, do not issue or run an automatic `-006` repetition. `00統括` will place performance acceptance on an explicit
external-state hold until the host condition materially changes. After the QA handoff, only `00統括` determines Slice
2-A acceptance or an evidence-supported bounded code order.

## 11. Outcome overlay — 2026-07-15

- QA report／evidence commit: `60dd270ac3418d09d3e944a2a64beb1b036b0b42`
- QA closure／handoff commit: `54a69441ff50fa345a01e6a831a100a1f687e033`
- Stage ID: `p2-2a-005-20260715t0944jst-b32fdae`
- PREPARED manifest SHA-256: `ac2c34644f7d3f2a92d39ebf54f64b1984c14fb330d31ec22b57035381334aa1`
- Evidence: `docs/test-reports/evidence/phase2-slice2a/diagnostic-003/p2-2a-005-20260715t0944jst-b32fdae/`
- Evidence manifest SHA-256: `d45590b80fbdef5e1b70734d20a6a2e001db542556c8b41efdd073f1b0740227`
- Stage P: sealed／dry-run Pass; performance slot launch count `0`
- Activation: exact stage ID／digest received, but required external pre-ack hash／OneDrive／power／runtime evidence
  was not preserved before QA announced measurement start
- Controller: terminated during the settled interval with
  `OneDrive-family process present during settled-60s.`; triggering name／PID was not persisted
- Later corroboration only: `OneDrive.Sync.Service`, PID `13496`; not identified as the triggering sample
- Settled interval: incomplete; CPU preflight attempts `0`
- Matrix: A1 through A2 Not run; performance slots `0`; valid matrix `0`; P95 unavailable／uninterpreted
- Post-run identity: controller／manifest／A／B／C match the sealed values
- Final QA recommendation: **Blocked**
- Supervisor disposition: **Blocked accepted / Slice 2-A unaccepted / external-state hold**
- Hold: [`MFO-HOLD-P2-2A-001`](phase2-slice2a-performance-external-hold.md)

`system_wide_tick_count64_origin` was `0` because the sealed source referenced an unavailable
`[Environment]::TickCount64` property on this PowerShell／CLR runtime. The actual deadline used the separate nonzero
`Stopwatch` origin, so the zero auxiliary field is not treated by `00統括` as an independent invalidation. It is still
a QA harness qualification defect. The pre-ack nonconformance and controller-side OneDrive-family detection already
make the result Blocked. The consumed stage and evidence are frozen; no automatic `-006` or game-code change is
authorized.
