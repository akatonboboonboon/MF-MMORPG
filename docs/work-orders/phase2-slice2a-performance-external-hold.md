# Hold Notice — Phase 2 Slice 2-A Performance Acceptance

- Hold ID: `MFO-HOLD-P2-2A-001`
- Issued by: `00統括（監督）`
- Effective: 2026-07-15 (Asia/Tokyo)
- Basis: `MFO-WO-P2-2A-005` final QA recommendation
- QA content／closure: `60dd270ac3418d09d3e944a2a64beb1b036b0b42` /
  `54a69441ff50fa345a01e6a831a100a1f687e033`
- Status: **Active for performance acceptance / correction-requalification exception `MFO-WO-P2-2A-007`**
- Milestone: M2 / Slice 2-A acceptance
- Gate 2: **Locked / not evaluated**
- Slice 2-B: **Locked / no work order**
- Active work order: [`MFO-WO-P2-2A-007`](phase2-slice2a-harness-correction-requalification.md) — harness ABI correction and requalification only

This is a hold notice, not a work order. By itself it authorizes no gameplay, QA harness, performance run,
presentation integration, repository move, OneDrive operation, or product-scope change. The later explicit
qualification exception is governed only by `MFO-WO-P2-2A-007`. This hold changes no Approved decision, performance
threshold, gameplay value, renderer, resolution, or quality setting.

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
- Do not repair, clear, reuse, or append to `MFO-WO-P2-2A-006` stage
  `p2-2a-006-qp-20260715t184405jst-2d5ef1a-c1` or its `preack-001` evidence.
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

## 4. Supervisor overlay — material host change and explicit qualification exception

Effective 2026-07-15, `00統括` accepts a material host-condition change for the limited purpose of considering the
required harness qualification:

- user-provided UI evidence shows a `100 GB` OneDrive allocation, `4.8 GB` in use, and a green client-level
  backup／sync indicator;
- a supervisor traversal through both Documents roots and OneDrive cloud markers found actual directory
  junction／symbolic-link count `0` and scan-error count `0` after generated dependency directories were moved
  without deletion to a non-OneDrive quarantine;
- a user-authorized normal OneDrive shutdown request was followed by preliminary `OneDrive*` process count `0`, with
  the MFO repository still present.

These observations are not a performance run and do not establish a valid acceptance window. Residual red Explorer
overlays are not interpreted. Fresh persisted evidence remains mandatory.

The user explicitly authorized proceeding, so `00統括` issued
[`MFO-WO-P2-2A-006`](phase2-slice2a-harness-qualification.md). It returned **Fail / harness defect** after a fresh
OneDrive-family count `0`: the PREACK launcher exited `0xC0000005` because the effective-overlay API used an invalid
`out IntPtr`／`LocalFree` interop contract. Runner result was `30 / Fail`; LIVE and performance slots were never started.
The stage is frozen, and this result does not end the hold or change the retained performance Fail.

After reviewing that evidence, `00統括` explicitly issued
[`MFO-WO-P2-2A-007`](phase2-slice2a-harness-correction-requalification.md). It authorizes only the bounded ABI
correction, a seal-before production-path smoke, and one new-stage non-acceptance harness requalification with
performance slot count `0`. While it is active, its narrower instructions supersede the no-execution sentence only for
its named QA files, temporary stage, and qualification sequence. Every other hold restriction remains in force.

`-007` Pass does not end this hold. After its result returns, only `00統括` may amend or close the hold or issue a
separate performance-measurement order.
