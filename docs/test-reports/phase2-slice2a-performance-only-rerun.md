# Phase 2 Slice 2-A Performance-only Rerun Report

- Work order: [`MFO-WO-P2-2A-005`](../work-orders/phase2-slice2a-performance-only-rerun.md)
- Report date: 2026-07-15 (Asia/Tokyo)
- Reporter: `30 QA・性能・レビュー`
- Supervisor order／QA start SHA: `b32fdae63c0ddcb150f5a4678e301f959550ad08`
- QA branch: `codex/phase2-slice2a-performance-only-qa`
- QA evidence／report content commit: `60dd270ac3418d09d3e944a2a64beb1b036b0b42`
- Stage ID: `p2-2a-005-20260715t0944jst-b32fdae`
- Sealed manifest SHA-256: `ac2c34644f7d3f2a92d39ebf54f64b1984c14fb330d31ec22b57035381334aa1`
- Final recommendation: **Blocked**
- Gate 2: **Locked / not evaluated**

## 1. Outcome

Stage P completed outside OneDrive. A／B／C, the final controller, all six fixed invocations, and the preparation
manifest were sealed. The non-acceptance dry-run passed with exit `0`, performance slot launch count `0`, and no timed
origin. The user then supplied the exact `ALL ONEDRIVE CLOSED / QUIET WINDOW READY` line.

The controller recorded its origin at `2026-07-15T10:25:41.8990234+09:00` and recorded the terminal error about `1.486 s` later:
`OneDrive-family process present during settled-60s.` The 60-second settled interval was incomplete, the CPU preflight
did not start, and no performance slot launched. A1 through A2 are all Not run; valid matrix count is `0`; no P95 is
available or interpreted.

There are two additional evidence／execution defects:

1. QA acknowledged measurement start before preserving the work-order-required external `OneDrive*` count-zero
   prerequisite. This is a QA procedural nonconformance. The acceptance window is not treated as valid or complete.
2. `controller-origin.json` records `system_wide_tick_count64_origin = 0`. That is not a usable required system-wide
   monotonic origin and independently prevents a valid run.

The controller did not persist the triggering OneDrive inventory before throwing. A later, separate snapshot observed
`OneDrive.Sync.Service`, PID `13496`; it is corroboration only, not the missing trigger sample. The activated stage is
frozen and is not repaired, cleared, or reused.

Performance recommendation: **Blocked / matrix not started**.

## 2. Stage P and sealed identities

| Item | Source | Size (bytes) | SHA-256 | `MZ`／result |
|---|---|---:|---|---|
| A | `a13505e8fbf82962e049b9101a87593a6692d2c7` | 109,075,560 | `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` | `4D5A` |
| B | `295549373fbb3b39deb6079172783ce62c7da532` | 109,095,104 | `3c15c254fbb8025d88c5636f2175a35f6e325b5368c8098e78b16181090dd4ef` | `4D5A` |
| C | `5261a73707daca03cb160e03a12247886d3f5cce` | 109,095,120 | `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47` | `4D5A` |
| Final controller | sealed Stage P source | 50,096 | `754c9a416dc961efcc575fec7879c3e12529a2d4f2de498412110f9ad9b21364` | parse／dry-run Pass |
| Preparation manifest | `b32fdae6` QA stage | 42,877 | `ac2c34644f7d3f2a92d39ebf54f64b1984c14fb330d31ec22b57035381334aa1` | digest match |

Dry-run results:

- exit `0`;
- fixed order `A1 → B1 → C1 → C2 → B2 → A2` and six slots sealed;
- performance slot launch count `0`;
- timed origin not created;
- preparation processes exited, runtime residue `0`, controller lock absent;
- PREPARED line issued with the stage ID and manifest digest above.

Sealed Stage P environment:

- OS: Microsoft Windows NT `10.0.26200.0`;
- CPU identifier: Intel64 Family 6 Model 186 Stepping 3, GenuineIntel; `12` logical processors;
- GPU: Intel Graphics, driver `32.0.101.7077`, driver date `2025-09-16`;
- required Godot: `4.7.stable.official.5b4e0cb0f`;
- sealed slot presentation: GL Compatibility, `1920×1080` project window, standard quality;
- AC／Best performance: observed only after failure and therefore not activation-point evidence.

## 3. Activation prerequisite audit

| Check | Required before acknowledgement | Actual | Result |
|---|---|---|---|
| User stage ID／manifest digest | exact match | exact match | Pass |
| Full staged hashes at activation point | recomputed after READY | Stage P and post-run match; not recomputed at the required pre-ack point | **Not run / QA nonconformance** |
| External OneDrive-family inventory | count `0` | no preserved pre-ack check; first controller check found a family process | **Blocked** |
| AC／Best performance at activation point | Online／`ded574b5-45a0-4f42-8737-46345c09c238` | post-failure snapshot Pass only | **Not run at required point** |
| Owned runtime at activation point | count `0` | Stage P and post-failure count `0`; no preserved pre-ack check | **Not run at required point** |

QA announced start and invoked the controller too early. This report does not shift that procedural error to the user
and does not reinterpret the partial evidence as a valid acceptance run.

## 4. Timed controller evidence

Exact sealed invocation:

```powershell
"C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-005\stages\p2-2a-005-20260715t0944jst-b32fdae\controller\run-performance-only.ps1" -Mode Run -StagePath "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-005\stages\p2-2a-005-20260715t0944jst-b32fdae"
```

- Codex launcher-wrapper exit code: `1`.
- The controller child exit code was not independently captured. The source assigns terminal error result `2`, but that value is not reported as an observed child exit code.
- Raw launcher streams were not redirected to a file. The error is independently preserved in
  `timed/controller-error.json`.
- Controller self: PID `6212`, creation UTC `2026-07-15T01:25:41.2436280Z`, expected PowerShell image path.
- Local origin: `2026-07-15T10:25:41.8990234+09:00`.
- Stopwatch origin／deadline: `5294911865847`／`5300911865847`.
- System-wide monotonic origin: `0` — **invalid / Blocked**.
- Error captured: `2026-07-15T01:25:43.3854998Z`.
- Exact error: `OneDrive-family process present during settled-60s.`
- Triggering process name／PID sample: **missing**; throw occurred before persistence.
- Final controller-boundary OneDrive count-zero inventory: **missing / not established**.

The later `2026-07-15T03:13:03.7000312Z` read-only snapshot observed only
`OneDrive.Sync.Service`, PID `13496`. No account, email, CPU, image path, creation time, or command line was collected.
It is not substituted for the missing trigger sample.

## 5. Settled interval, preflight, and fixed matrix

- 60-second settled interval: **Blocked before completion**.
- 15-interval CPU preflight attempts: `0`.
- System CPU acceptance result: Not run.
- OneDrive CPU-delta acceptance result: Not run; a nonzero process count already blocked the run.
- Valid matrix runs: `0`.

| Order | Slot | Result | P95 |
|---:|---|---|---|
| 1 | A1 | Not run | N/A |
| 2 | B1 | Not run | N/A |
| 3 | C1 | Not run | N/A |
| 4 | C2 | Not run | N/A |
| 5 | B2 | Not run | N/A |
| 6 | A2 | Not run | N/A |

No matrix directory, slot JSON, performance JSON, capture, Godot log, settled sample, preflight sample, continuous
sample, or session summary was generated. Invalid／partial evidence is not converted to Pass or Fail.

## 6. Post-controller integrity and cleanup

| Check | Actual | Result |
|---|---|---|
| Controller PID `6212` | exited | Pass |
| Controller lock | absent | Pass |
| MFO／Godot owned runtime | count `0` | Pass |
| Manifest SHA-256 | unchanged `ac2c...4aa1` | Pass |
| Controller SHA-256 | unchanged `754c...1364` | Pass |
| A／B／C full hashes, sizes, mtimes, `MZ` | all PREPARED identities match | Pass |
| Final OneDrive count-zero boundary | not established; later count `1` | **Blocked** |
| Executable／export pack copied to tracked evidence | `0` | Pass |

The post-failure power observation was AC Online and Best performance GUID
`ded574b5-45a0-4f42-8737-46345c09c238`; it is not backdated or substituted for the missing activation-point check.

## 7. Frozen functional evidence

- Phase 1／Slice 2-A automation: prior accepted correction functional evidence remains unchanged; not rerun here.
- Corrected-C KBM: accepted `MFO-WO-P2-2A-004` evidence remains **Pass**; not rerun under this order.
- User feel: accepted prior report `すべて問題ないです`; not re-requested here.
- Physical gamepad: **Not run / Deferred**.
- No game code, test, recorder, scene, project setting, quality, threshold, KBM, or gameplay value was changed.

The `-004` KBM observer source and exact observer command were not fully preserved, as already recorded by the
supervisor. This performance-only run does not repair or expand that frozen evidence.

## 8. Evidence, hashes, and scope

Evidence root:
[`evidence/phase2-slice2a/diagnostic-003/p2-2a-005-20260715t0944jst-b32fdae/`](evidence/phase2-slice2a/diagnostic-003/p2-2a-005-20260715t0944jst-b32fdae/)

- Byte-for-byte copied compact source evidence: `12` files; source／destination SHA-256 all match.
- Authored compact QA evidence: launcher observation, post-controller inventory, post-run integrity, copy
  verification, and session notes.
- Evidence manifest: `SHA256SUMS.txt`; SHA-256 `d45590b80fbdef5e1b70734d20a6a2e001db542556c8b41efdd073f1b0740227`.
- No `.exe`, `.pck`, `.zip`, export pack, screenshot, unrelated path content, OneDrive account identifier, or email address was copied. Required sealed local filesystem paths are preserved.
- Prior `diagnostic-001`／`diagnostic-002` evidence and reports were not modified.

Tracked changes are restricted to:

- this new report;
- new files under `docs/test-reports/evidence/phase2-slice2a/diagnostic-003/`;
- `docs/handoffs/qa.md`.

Known issues added: `0`（supervisor-owned registry not edited）. Open questions added: `0`.

## 9. Recommendation and routing

Final recommendation: **Blocked**.

Activation prerequisites were not valid, the first controller-side settled-window check found a OneDrive-family
process, the triggering inventory and final count-zero boundary were not persisted, and the recorded system-wide
monotonic origin was `0`. No slot launched and no P95 was interpreted.

The consumed stage remains frozen. `30 QA` does not retry it, issue an automatic `-006`, change the controller, accept
Slice 2-A, approve Gate 2, or authorize Slice 2-B. Further action returns to `00統括` under the external-state hold and
evidence-supported bounded-work rules.
