# Hold Notice — Phase 2 Slice 2-A Performance Acceptance

- Hold ID: `MFO-HOLD-P2-2A-001`
- Issued by: `00統括（監督）`
- Effective: 2026-07-15 (Asia/Tokyo)
- Basis: `MFO-WO-P2-2A-005` final QA recommendation
- QA content／closure: `60dd270ac3418d09d3e944a2a64beb1b036b0b42` /
  `54a69441ff50fa345a01e6a831a100a1f687e033`
- Status: **Active / external-state hold / no execution authorized**
- Milestone: M2 / Slice 2-A acceptance
- Gate 2: **Locked / not evaluated**
- Slice 2-B: **Locked / no work order**
- Active work order: **None**

This is a hold notice, not a work order. It authorizes no gameplay, QA harness, performance run, presentation
integration, repository move, OneDrive operation, or product-scope change. It changes no Approved decision,
performance threshold, gameplay value, renderer, resolution, or quality setting.

## 1. Supervisor disposition

`00統括` accepts `MFO-WO-P2-2A-005` as **Performance Blocked / valid matrix 0 / overall Blocked**.

- Stage P sealed A／B／C, the controller, six fixed invocations, and preparation manifest. The dry-run launched no
  performance slot.
- QA acknowledged measurement start before preserving the required external pre-ack checks for full staged hashes,
  OneDrive-family count `0`, AC／Best performance, and owned-runtime count `0`. This is a QA procedural
  nonconformance; a valid acceptance window was not established.
- The controller terminated about `1.486 s` after its local origin with
  `OneDrive-family process present during settled-60s.` The triggering inventory was not persisted before the throw,
  so its exact process name／PID is unknown.
- A separate post-controller snapshot observed `OneDrive.Sync.Service`, PID `13496`. This is corroborating evidence
  only and is not identified as the triggering sample or proof of continuous presence.
- `system_wide_tick_count64_origin` was `0`. The sealed source uses `[Environment]::TickCount64` before native API
  initialization; on this host's Windows PowerShell 5.1／CLR Desktop runtime that property is absent. A supervisor
  read-only reproduction confirmed the property is unavailable. The actual 10-minute deadline used the separate,
  nonzero `Stopwatch` origin `5294911865847`, so `00統括` does **not** treat the zero auxiliary field alone as an
  independent invalidation. It remains a sealed-controller qualification defect that must be removed before any
  future run.
- The settled interval was incomplete, CPU preflight attempts were `0`, A1 through A2 were Not run, performance slot
  count was `0`, valid matrix count was `0`, and no P95 was generated or interpreted.
- Post-run controller／manifest／A／B／C identities match their sealed values. No game code, tests, recorder, scene,
  project setting, threshold, executable evidence, or prior evidence was changed.

The earlier functional correction remains Pass, the accepted corrected-C KBM remains Pass and frozen, and the earlier
valid correction performance Fail remains on record. None of the `-005` evidence attributes a defect to game code.
Slice 2-A remains unaccepted.

Formal report:
[`../test-reports/phase2-slice2a-performance-only-rerun.md`](../test-reports/phase2-slice2a-performance-only-rerun.md)

Frozen evidence:
[`../test-reports/evidence/phase2-slice2a/diagnostic-003/p2-2a-005-20260715t0944jst-b32fdae/`](../test-reports/evidence/phase2-slice2a/diagnostic-003/p2-2a-005-20260715t0944jst-b32fdae/)

- PREPARED manifest SHA-256: `ac2c34644f7d3f2a92d39ebf54f64b1984c14fb330d31ec22b57035381334aa1`
- Evidence manifest SHA-256: `d45590b80fbdef5e1b70734d20a6a2e001db542556c8b41efdd073f1b0740227`

## 2. Frozen state while this hold is active

- Do not issue or run an automatic `MFO-WO-P2-2A-006` repetition.
- Do not repair, clear, reuse, or append to stage `p2-2a-005-20260715t0944jst-b32fdae`.
- `30 QA` does not change the controller, create a new stage, run another preflight／matrix, or repeat KBM without a
  new explicit supervisor work order.
- `10 Gameplay` does not change game code, gameplay values, profiling seams, or performance behavior from this result.
- `20 Presentation` does not integrate, edit shared scenes／contracts, or create production assets. Existing separate,
  disconnected, non-binding proposals remain the only permitted parallel scope.
- Gate 2, Slice 2-B and later slices, damage, binding, production events, music／voice, network／server, and
  account／persistent-data work remain locked.
- The user may resume normal input and may restart OneDrive. No repository move, account inspection, sign-out, quota
  cleanup, or file deletion is required by this hold.

## 3. Conditions for future consideration

The hold does not end automatically. `00統括` may consider a future bounded order only after a material external-state
change is explicitly reported, such as a host／session condition in which every required `OneDrive*` inventory can
stably reach count `0`. Account identifiers and unrelated files remain out of scope.

Before any future acceptance matrix, a separately authorized non-acceptance QA harness qualification must prove on a
new stage that:

1. one canonical supported system-wide monotonic source is present, nonzero, advancing, and is the actual origin and
   expiry source for the 600-second deadline; auxiliary clocks are not used for acceptance;
2. activation stage ID／manifest digest and sealed invocation match, and full A／B／C／controller hashes,
   AC／Best performance, owned-runtime zero, and OneDrive-family count zero are persisted before measurement
   acknowledgement;
3. every triggering inventory is saved before a terminal assertion throws;
4. controller child exit code and raw stdout／stderr are captured;
5. no performance slot launches during qualification, and the old stage is not reused.

Only after both the material host change and an explicit supervisor-issued qualification／measurement sequence may QA
resume. Passing a harness qualification would not itself accept Slice 2-A, open Gate 2, or authorize Slice 2-B.
