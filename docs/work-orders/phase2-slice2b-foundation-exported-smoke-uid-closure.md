# MFO-WO-P2-2B-006 — Slice 2-B foundation exported-smoke process and UID closure

- Issuer: `00統括（監督）`
- Issued: 2026-08-01 (Asia/Tokyo)
- Assignee: `30 QA・性能・レビュー`
- Status: **Authorized / one waitable exported smoke, one exact UID addition, and final audit only**
- Milestone: M2 / Slice 2-B pre-integration foundation
- Required branch: `codex/phase2-slice2b-action-foundation-qa`
- Required workspace: existing dedicated worktree `C:\tmp\q2b`
- Frozen `-005` QA tip / required predecessor: `3cfdcc875caa74ceb0041781db631ee930e3725c`
- Required execution HEAD: the `-006` supervisor issuance commit supplied in the START message
- Candidate implementation commit: `0f705eeba3554d1f52b7402bb625ca8a86dd1560`
- Candidate handoff / reviewed HEAD: `81efefb156af68e5f564c6a97ce7e1d163b158a0`
- Integration authority: **None**
- Gate effect: **None** — Gate 2 remains Locked

## 1. Supervisor disposition and inherited Pass evidence

`MFO-WO-P2-2B-005` is accepted as **Blocked / external smoke-launch and exit-capture specification defect**.
It does not establish a candidate, project, release-export, or exported-artifact defect. The `-005` directory
materialization and release export both completed successfully. The exported binary is a Windows GUI-subsystem
executable; direct invocation through the Windows PowerShell call operator returned shell control without a durable
numeric `$LASTEXITCODE`, while the smoke log arrived asynchronously. That launcher was unsuitable for the required
numeric-exit evidence.

The following committed results are accepted as inherited Pass evidence and must not be rerun in this order:

- `-004`: engine identity / version, import / parse, foundation runner `71 / 71`, Phase 1 `36 / 36`, Slice 2-A
  `120 / 120`, Slice 2-A correction `39 / 39`, and main-scene smoke;
- `-005`: ignored output-directory materialization exact once and release export exact once, exit `0`;
- exported EXE `109116312` bytes, `MZ`, SHA-256
  `c2ec5f79c2f5302715cf27ebcac881329852ec78651d627c46fba91ba3378c1f`;
- late `-005` smoke log `572` bytes, SHA-256
  `60d35ec29b0fad2f63df0f0a991e5d7e82fc1ae35e68544fe3ca54505641ade2`, containing
  `DefinitionsValidated` and RHL `violation_count: 0`, with residual relevant process count `0`.

Before any launch or tracked write, verify that:

1. local HEAD and origin equal the START-message supervisor commit, and the frozen `-005` QA tip is its ancestor;
2. the corrected runner SHA-256 is
   `5745d2ace2fab67aabd4b5761d5f7ce6339c8b15cbaad25a8c821b22f1a878a4`;
3. the existing ignored EXE at
   `C:\tmp\q2b\material-frontier-online\prototype\build\windows\MFO-Phase1.exe` has the exact identity above;
4. the `-002` through `-005` report / evidence blobs in the START HEAD match the frozen `-005` predecessor, and
   `docs/handoffs/qa.md` matches the `3cfdcc875caa74ceb0041781db631ee930e3725c` blob before any new receipt write;
5. the only non-ignored untracked path is the UID sidecar specified in Section 2, with the exact identity there.

Any mismatch stops before the smoke as `Blocked / validation infrastructure or evidence incomplete`. Do not
re-export, regenerate the runner, or repair an inherited artifact.

## 2. Exact UID sidecar adoption

Godot generated the following sidecar while importing the already-authorized additive runner:

- path: `material-frontier-online/prototype/tests/run_slice2b_foundation_tests.gd.uid`
- exact byte content: `uid://dku5njih7fwgp` followed by one LF byte;
- size: `20` bytes;
- SHA-256: `13a6840a6a967830e1af3dc083068b9fde63179f8217a4c93638be2531359366`;
- expected Git blob after addition: `a8df659f3db95483e040e44c60449ce05995ecc5`.

Read back the existing untracked file before changing Git state. Require exact content, size, hash, no ignore match,
and no collision with any other tracked `.uid` content. If all checks pass, add this exact existing file to Git once.
After adding, require
`git rev-parse :material-frontier-online/prototype/tests/run_slice2b_foundation_tests.gd.uid` to equal
`a8df659f3db95483e040e44c60449ce05995ecc5`. Do not delete, regenerate, rewrite, normalize, or manually create the
sidecar. No other `.uid` path may change.

## 3. Exact waitable exported smoke

Do not run Godot editor/import, any test runner, main smoke, or export. Use only the frozen EXE identity from Section 1.
First prove that the `foundation-005` evidence root and its new smoke log are absent. Then create the evidence root
before launch. The exported smoke process may be started exactly once with these arguments:

```text
--headless --log-file C:\tmp\q2b\docs\test-reports\evidence\phase2-slice2b\foundation-005\exported-smoke.log --quit-after 5
```

Launch it through `System.Diagnostics.ProcessStartInfo` and `System.Diagnostics.Process`, with all of these bindings:

- `FileName` = the frozen absolute EXE path;
- `WorkingDirectory` = `C:\tmp\q2b\material-frontier-online\prototype`;
- `UseShellExecute = false`;
- `CreateNoWindow = true`;
- `RedirectStandardOutput = true`;
- `RedirectStandardError = true`;
- call `Start()` exactly once, immediately start both stdout and stderr `ReadToEndAsync()` tasks, then call
  `WaitForExit(120000)`;
- if the bounded wait succeeds, complete both tasks and only then persist numeric `ExitCode`; sequential synchronous
  reads are prohibited;
- if the bounded wait times out, terminate only that owned process once, complete the wait / capture, record timeout,
  and stop without a second launch.

Persist the exact launcher source or command record before launch, plus captured stdout / stderr text encoded as
UTF-8 without BOM, numeric exit, process identity, start/end timestamps, timeout flag, and a result record. Require:

1. numeric exit `0`;
2. fresh post-exit log exists and contains `DefinitionsValidated` plus RHL `violation_count: 0`;
3. the frozen EXE size and SHA-256 are unchanged;
4. relevant residual process count is `0` after completion.

The direct PowerShell call operator, `Start-Process` without a durable waitable exit result, another launcher, a
second smoke, and the `-005` late log as a substitute for the fresh result are prohibited.

## 4. Final audits

After a successful smoke, perform only the read-only audits needed to close the foundation:

1. exact corrected-runner insertion, `71` `_check(...)` call sites, and one helper declaration;
2. accepted candidate five-path implementation scope from its original base through `81efefb156af68e5f564c6a97ce7e1d163b158a0`,
   plus unchanged gameplay-code blobs;
3. no game code, values, existing tests other than the already-corrected runner, data, scenes, `project.godot`,
   export preset, or prior report / evidence changes;
4. `-002` through `-005` artifact identity and the new `foundation-005` evidence completeness;
5. exact UID path / bytes / blob, no UID collision, and no other new `.uid` path;
6. START HEAD to final QA content scope contains only the paths in Section 5.

Before the content commit, require `git diff --check`, and after staging require `git diff --cached --check`; also require authorized / forbidden-path checks, exact UID index blob, and
non-ignored untracked-file count `0`. After the content commit, separate handoff commit, and push, require local HEAD
equals origin, `git status --short` has `0` entries, and the final worktree is clean.

Ignored `build/windows/**` and `.godot/**` runtime files are not tracked and need not be deleted. Record their
presence; do not edit or clean them manually.

## 5. Authorized tracked paths

Only these tracked paths may be added or changed:

- `material-frontier-online/prototype/tests/run_slice2b_foundation_tests.gd.uid` — exact frozen sidecar only;
- `docs/test-reports/phase2-slice2b-foundation-exported-smoke-uid-closure.md` — new report;
- `docs/test-reports/evidence/phase2-slice2b/foundation-005/**` — new evidence only;
- `docs/handoffs/qa.md` — receipt and final handoff only.

The runner itself, all game code, values, data, other tests / UID files, scenes, `project.godot`, export preset,
existing reports / evidence, implementation artifacts, and supervisor documents are immutable.

## 6. Stop, result, and return rules

The exported smoke is exact-one and single-attempt. UID adoption is one exact tracked addition and is not a reason to
change its bytes. Stop at the first non-pass. Do not repair, retry, re-export, rerun inherited tests, switch binaries,
delete generated files, or broaden scope. A fully captured nonzero exit, timeout, missing post-exit log, or missing
required marker is `Fail / exported artifact nonconformance`. Inability to start the owned launcher, determine its
numeric exit, or durably complete required evidence is `Blocked / validation infrastructure or evidence incomplete`.
Return one:

- `Pass / isolated common action-effect-query foundation validated`;
- `Fail / exported artifact nonconformance`; or
- `Blocked / validation infrastructure or evidence incomplete`.

Commit the exact UID, new report, and new evidence as one QA content commit and the final QA handoff as a separate
commit, then push only the required QA branch. Return all identities, numeric exit, exact changed paths, local / origin
equality, clean status, and all Not run / Deferred items.

Even a Pass validates only the isolated Stage A foundation. It does not resolve Slice 2-A performance, authorize
Stage B, production values, input, authority, damage, scenes, events, presentation, integration, Slice 2-C, or Gate 2.
