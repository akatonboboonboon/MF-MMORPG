# Work Order — Phase 2 Slice 2-A Quiet-Host Rerun and User-Operated KBM

- Work order ID: `MFO-WO-P2-2A-004`
- Issued by: `00統括（監督）`
- Issued: 2026-07-14 (Asia/Tokyo)
- Priority: **P1 / current Slice 2-A acceptance blocker**
- Findings: `MFO-P2-2A-QA-002`, [`KI-010`](../KNOWN_ISSUES.md), [`KI-011`](../KNOWN_ISSUES.md),
  [`KI-012`](../KNOWN_ISSUES.md)
- Owner: `30 QA・性能・レビュー`
- Required user role: quiet-host preparation and corrected-build KBM operator
- Gameplay owner: `10ゲームプレイ・コア実装` — no work in this order
- Presentation owner: `20ステージ・UI・グラフィック` — no integration work in this order
- Status: **Returned / Performance Blocked; KBM Pass; overall Blocked**
- Milestone: M2 / Slice 2-A acceptance
- Gate 2: **Locked / not evaluated**
- Ancestry base: `701bfccc529c79cab7bd0a2eb7d8ff0435f0cb24`
- Required starting state: the pushed supervisor commit containing this order; `30` records its exact SHA
- Required QA branch: `codex/phase2-slice2a-controlled-rerun-qa`
- Required report: `docs/test-reports/phase2-slice2a-controlled-rerun.md`
- Required evidence root: `docs/test-reports/evidence/phase2-slice2a/diagnostic-002/`

This order changes no product requirement, Approved decision, gameplay value, test, recorder, threshold, scene,
project setting, renderer, or quality setting. It does not authorize a gameplay fix, integration to `main`, Slice
2-B, or Gate 2. Direct push to `main` is prohibited.

## 1. Supervisor disposition and purpose

`00統括` accepts the `MFO-WO-P2-2A-003` final recommendation as **Blocked**. Its evidence and
`diagnostic-001/` archive are complete historical records and must not be reopened, overwritten, or extended.

The prior correction functional checks remain Pass. The prior correction QA performance finding also remains on
record; the Blocked diagnostic does not withdraw it. `MFO-WO-P2-2A-003` produced zero valid acceptance runs because:

- Windows-session input changed continuously and the game was usually not foreground;
- system CPU averaged `72.838%–87.620%`, with maxima `90.229%–100%`;
- OneDrive and OneDrive Sync Service consumed substantial CPU while evidence was written below the synced workspace;
- C2 lacked controller／exit／power／OS metadata, and B2／A2 were not run;
- corrected-C KBM was not an uninterrupted fresh session.

These facts establish that this diagnostic attempt was contaminated. They neither establish nor exclude a gameplay
defect. This order performs one new, separate controlled attempt with non-OneDrive staging and an explicit user
control contract.

## 2. Activation and user quiet-window contract

The timed performance matrix remains locked until the user explicitly confirms all of the following to `30 QA`:

1. OneDrive currently shows a user-reported unsynchronized red-X state, which the user suspects is related to the
   free-plan 5 GB limit. The user manually pauses or exits the OneDrive sync client for the test; QA must not delete
   files, free quota, kill the client, disable it, or reconfigure it. OneDrive sync success is not an acceptance
   condition, and this order does not assert the red-X root cause.
2. File copies, video playback, games, downloads, exports, and other heavy work are stopped.
3. The machine is on AC power and remains available for the test.
4. After `30 QA` replies that performance measurement is starting, the user will not touch the keyboard, mouse,
   touchpad, touchscreen, or other input device, and will not operate another Codex task, until `30 QA` announces
   that the performance stage is complete. Reserve up to 10 minutes.
5. After performance completion, the user is available immediately for a separate corrected-build KBM session.

The activation message must explicitly state `MFO-WO-P2-2A-004 QUIET WINDOW READY`. `30` records the message timestamp,
acknowledges the start, waits through the preflight below, and does not ask the user for input during the performance
stage. If the user cannot provide this window, return `Blocked / not started`; do not run opportunistically.

After all testing, `30` tells the user that OneDrive was left paused or exited. The user alone decides whether and
when to resume it; QA must not resume it automatically.

## 3. Authorized tracked scope and temporary staging

`30` may commit changes only to:

- the required new controlled-rerun report;
- new evidence below the required `diagnostic-002/` root;
- `docs/handoffs/qa.md`.

All executables, performance stdout／stderr, JSON, capture, logs, controller state, and intermediate metadata must be
staged under a new session directory in `%TEMP%` or `%LOCALAPPDATA%`, outside the OneDrive workspace. Nothing is
written below the repository during a timed performance slot. After the performance controller has stopped, copy the
compact non-executable primary and derived evidence needed for review into `diagnostic-002/`; hashes are recomputed
and source／destination identity is recorded. Required primary evidence includes each slot's recorder JSON,
stdout／stderr, generated game capture, lossless preflight and continuous-monitor samples, controller metadata, exact
invocation, and the executed controller source. Do not omit these small primary artifacts merely to reduce evidence
size. A／B／C executables, export packs, duplicate binaries, and other bulky temporary artifacts remain outside
OneDrive and are never copied into the repository, added to the evidence manifest, committed, or pushed. Record their
source identity, byte size, SHA-256, and `MZ` identity instead.

The repository may retain the user-visible OneDrive red-X state. That state does not invalidate a local Git commit or
GitHub push. Tracked evidence must remain compact; if a required non-binary artifact is unexpectedly large, stop and
return to `00` before copying it into the repository.

The following remain read／execute only and must not be edited:

- `material-frontier-online/prototype/scripts/**`;
- `material-frontier-online/prototype/tests/**`;
- the performance recorder and percentile implementation;
- scenes, `project.godot`, export presets, InputMap, quality, resolution, and renderer settings;
- all prior reports and evidence, including `diagnostic-001/`;
- all gameplay constants and behaviors.

The exact executed controller script snapshot, invocation command, and controller SHA-256 are required evidence.
Do not leave the only controller source in an ignored directory.

## 4. Immutable A／B／C set

Use the already established sources and executable hashes:

| Label | Source | Required EXE SHA-256 |
|---|---|---|
| A | Gate 1 baseline `a13505e8fbf82962e049b9101a87593a6692d2c7` | `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` |
| B | pre-correction `295549373fbb3b39deb6079172783ce62c7da532` | `3c15c254fbb8025d88c5636f2175a35f6e325b5368c8098e78b16181090dd4ef` |
| C | corrected `5261a73707daca03cb160e03a12247886d3f5cce` | `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47` |

Copy all three materialized `MZ` executables to the non-OneDrive staging directory and re-check size and SHA-256
after copying. Existing B／C outputs may be reused only when they match exactly. If either is absent or mismatched,
re-export the exact source into non-OneDrive staging with Godot `4.7.stable.official.5b4e0cb0f`, finish all exports
and hashing before user quiet-window activation, and allow the host to settle before preflight.

## 5. Quiet-host preflight

After user activation and before A1, run a lightweight 15-second, 1 Hz preflight. It may be repeated up to three
times because no acceptance run has started. All of these must pass in one attempt:

- AC Online and Best performance GUID `ded574b5-45a0-4f42-8737-46345c09c238`;
- A／B／C hashes and `MZ` identity match;
- no owned Godot, export, or earlier controller process remains;
- `GetLastInputInfo` is unchanged for the final 10 seconds;
- user-confirmed OneDrive pause or exit, with combined OneDrive／OneDrive Sync Service CPU delta `<= 0.25`
  CPU-seconds over the 15-second window; a quota or red-X status alone neither passes nor fails this check;
- total system CPU average `<= 20%` and no 1 Hz sample above `40%`;
- the controller script and required window／process APIs load successfully, and all staging paths are writable;
- the staging and destination paths are distinct, and the timed output path is outside OneDrive.

Collect only lightweight system CPU, relevant process deltas, input tick, foreground PID, power, and window state.
Do not enumerate hundreds of GPU-engine counters during an acceptance slot. Adapter identity is sufficient; the
existing portable GPU per-frame timing limitation remains recorded.

If no preflight attempt passes, return the performance component as `Blocked / matrix not started`. Preserve every
preflight attempt and proceed to the user-operated KBM stage if the user remains available and corrected C can be
launched normally with its game window acquired.

## 6. One fixed performance matrix

After a passing preflight, run exactly once in this order:

```text
A1 → B1 → C1 → C2 → B2 → A2
```

Each slot is a new process using the unchanged arena scenario, `120` warmup frames, `600` samples, standard quality,
GL Compatibility, and a `1920×1080` project window. Use a fixed `5,000 ms` idle interval before A1 and between
slots. A slot has a `60-second` hard timeout from process launch, and the whole performance stage from QA's start
acknowledgement through controller shutdown has a `10-minute` hard limit. Record that absolute deadline and check it
during preflight, pre-A1／inter-slot idle, every live slot, and finalization. If it expires with no live game process,
finalize the session metadata and return `Blocked`. If it expires with a live game process, stop that owned process in
the slot-local `finally`, preserve the partial evidence, finalize the session, and return `Blocked`. Never start a
preflight attempt or slot that cannot finish inside the remaining deadline.

The successful preflight's final input tick becomes one session-wide input baseline. Keep 1 Hz input, power, system
CPU, game／controller CPU, OneDrive-family CPU, foreground PID, and process/window-liveness observations running
continuously through the pre-A1 idle, every live slot, every inter-slot idle, and controller shutdown after A2. The
input tick must remain identical and AC／Best performance must remain valid for that entire interval.

For every slot and inter-slot idle segment, use the same sample window and logical-processor count `N` throughout.
For a process, calculate `process_pct = 100 × delta_cpu_seconds / (delta_wall_seconds × N)` and clamp it to
`0%–100%`. Calculate `background_pct = clamp(system_total_pct - game_process_pct, 0%, 100%)`; the controller is
deliberately not subtracted and therefore remains part of background load. Store the unrounded system sample,
game／controller CPU-second deltas, wall delta, `N`, and calculated values; apply thresholds to unrounded values. A
missing, negative, or non-comparable required sample invalidates the segment. Expected process absence is not a
missing sample: record game contribution as `0%` during inter-slot idle and OneDrive-family CPU delta as `0`
CPU-seconds when the user has exited the client. A live-slot game disappearing before the recorded normal-termination
boundary, or a process-enumeration／sampling failure, remains missing and invalid.

A segment is invalid if background CPU averages above `20%`, any 1 Hz background sample is above `40%`, or combined
OneDrive／OneDrive Sync Service CPU delta exceeds `0.25` CPU-seconds. These are integrity conditions, not product
performance thresholds. On any violation, preserve the segment, stop before the next slot, and return `Blocked`;
never interpret that slot's P95 as Pass or Fail.

The controller must be sequential, not pre-queued:

1. launch one executable and acquire the game window without `SendInput`; natural foreground activation or a
   pre-slot `SetForegroundWindow` call is allowed, but no synthesized keyboard or mouse event is allowed;
2. recognize that the existing recorder starts automatically in `_ready()` and has no external delayed-start seam.
   Timestamp process creation and receipt of the `[MFO-P1-MEASURE]` startup line, poll HWND／foreground at `100 ms`
   intervals during acquisition, and establish foreground no later than `1,000 ms` after that startup
   line. Under the unchanged standard 60 Hz configuration this is within the `120`-frame warmup and before the first
   of `600` measured frames. If the controller cannot prove foreground acquisition inside that warmup, return
   `Blocked`. Stop high-frequency polling after acquisition; do not replace the session-wide input baseline;
3. record lightweight input／foreground／power／relevant-process observations;
4. wait for process completion;
5. in a slot-local `try/finally`, persist exit, hashes, power, output presence, and integrity metadata;
6. validate the completed slot before launching the next slot.

From window acquisition until the required performance output is complete and the controller records the normal
termination phase, foreground must remain on that game PID. Save the last valid HWND／PID and foreground observation
before that boundary. Normal window destruction and foreground change during or after the recorded normal
termination phase are not integrity failures, even if the PID remains briefly alive. If the session input changes at
any time, foreground leaves a live game, power becomes invalid, an external-load condition above is violated, the process fails, required
output is missing, or controller metadata cannot be finalized, stop before the next slot and return `Blocked`.
Preserve the invalid slot. There is no replacement slot and no continuation after a terminal integrity failure. A
valid threshold failure is never discarded.

All performance outputs remain in non-OneDrive staging until the matrix controller has ended. Apart from the explicit
pre-slot `SetForegroundWindow` allowance above, do not attach computer-use／GUI-control sessions or use screenshots,
chat interaction, or GUI automation during the timed matrix; the game-generated capture is sufficient.

## 7. Performance disposition

Only a complete six-slot valid matrix is interpreted:

| Evidence pattern | Performance disposition |
|---|---|
| A and C each have two P95 values `<= 16.67 ms` | **Pass**; B remains attribution-only |
| A has any valid threshold failure | **Blocked / control not reproduced** |
| A passes twice, B passes twice, and C exceeds the threshold twice | **Fail / correction-delta correlation** |
| A passes twice, and B／C each exceed the threshold twice | **Fail / failure present before correction; relative magnitude un-attributed** |
| A passes twice, but C has any other valid threshold failure, including a Pass／Fail mix | **Fail / current candidate does not meet acceptance; causality unisolated** |

Any C P95 above `16.67 ms` prevents performance Pass. Invalid or partial matrices are never converted to performance
Pass or Fail.

## 8. User-operated corrected-C KBM

KBM is a separate session after performance has ended or been safely stopped. `30` tells the user that input is now
allowed, launches corrected C normally, verifies its hash, and becomes a passive observer. No QA GUI automation sends
game input during this stage.

The user is the declared operator. Intentional user keyboard and mouse input is the test stimulus and must not be
classified as external-input contamination. Before launch, `30` gives the entire ordered checklist and explains the
capture boundary. Start the checklist within 60 seconds after the game becomes foreground and complete it in one
continuous capture lasting at most five minutes:

1. W／A／S／D movement;
2. independent mouse aim;
3. neutral movement + Space uses current aim direction;
4. held movement + fresh Space prioritizes movement direction;
5. arena boundary is not crossed;
6. Space during active／reuse is rejected and does not trigger later without a fresh press.

After performing item 6, the user keeps the game in the foreground and idles without returning to chat. `30` does
not attach a computer-use／GUI-control session during the capture; it uses only non-interfering shell／game-log
observation and ends the capture when all six planned stimuli are represented in that output or when the five-minute
limit is reached. This alone does not determine each outcome. `30` may then close the owned game process, announces
that the capture boundary has ended, and only then asks the user to return to chat. The user reports the observed
outcome of each numbered checklist item as Pass／Fail, confirms that the inputs were intentional, and gives a short
user-feel response. `30` records the six item-by-item answers beside the non-interfering game log／window evidence; a
mandatory Pass may not rest on input occurrence alone. That normal post-capture close／focus change is not `Blocked`.

Record the game log, game-window evidence, user confirmation, and user-feel response. Do not capture unrelated
windows or private conversation. Partial sessions are not combined. Window loss or unintended other-app input before
the capture boundary ends, or a delay beyond the session limits, is `Blocked`; a repeatable gameplay discrepancy is
`Fail` with reproduction evidence. Physical gamepad remains `Not run / Deferred` under OD-013.

## 9. Overall recommendation and routing

Determine performance and KBM components separately, then set the overall recommendation in this order:

1. any confirmed component `Fail` overrides `Blocked`;
2. otherwise any mandatory `Blocked` overrides `Pass`;
3. `Pass` requires both performance and KBM to Pass, with user feel and gamepad explicitly separated.

The report must include the supervisor order SHA, activation timestamp, all preflights, all scheduled slot results,
A／B／C hashes／sizes／`MZ` identity, continuous integrity observations and segment calculations, controller
source／invocation／hash, compact staging-to-repository copy verification, KBM checklist, exact commands, changed-path
audit, privacy handling, and a manifest covering every committed evidence file. The manifest must confirm that no
executable or export pack was copied into tracked evidence.

`30` may not accept Slice 2-A, close Gate 2, authorize Slice 2-B, modify game code, or rewrite prior evidence. After
the QA handoff, only `00統括` determines acceptance and the next work order.

## 10. Outcome overlay — 2026-07-15

- QA report／evidence commit: `45eeeb32a525b922eada9624385691a2143fd7db`
- QA closure／handoff commit: `bfaff7bb88f535ca568765263a65c8513bd43a39`
- Evidence: `docs/test-reports/evidence/phase2-slice2a/diagnostic-002/controlled-20260715-67ba7f3/`
- Evidence manifest SHA-256: `f17de23065a66a982515b6d1030e926ad9d8e9c801d0e6a04950f3beb908ca03`
- A／B／C size、SHA-256、`MZ`: exact Pass
- Preflight: OneDrive-family `32.15625 CPU-seconds`; system CPU average／maximum
  `38.250224%`／`46.012270%`; Fail
- Matrix: A1 through A2 Not run; valid acceptance runs `0`; P95 not evaluated
- Performance component: **Blocked / matrix not started**
- Corrected-C KBM: **Pass** on independent attempt 3 (`27.973 s`, stable foreground, all six items)
- User input／feel: intentional; `すべて問題ないです`
- Physical gamepad: Not run / Deferred
- Final QA recommendation: **Blocked**
- Supervisor disposition: overall Blocked accepted; KBM Pass frozen; performance remains unresolved; no gameplay edit
- Follow-up: [`MFO-WO-P2-2A-005`](phase2-slice2a-performance-only-rerun.md)

Supervisor audit confirmed the reported load arithmetic and KBM technical evidence. It also recorded two complete
post-activation copy／hash cycles (`654,531,568` bytes copied), a controller repair, an incomplete runtime-residue
matcher, and the absence of the KBM observer source／exact observer invocation. These limitations do not reverse the
component results, but they must not be repeated. This order and `diagnostic-002/` remain immutable historical records.
