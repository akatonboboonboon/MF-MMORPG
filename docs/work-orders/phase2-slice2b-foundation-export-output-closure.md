# MFO-WO-P2-2B-005 — Slice 2-B foundation export-output closure

- Issuer: `00統括（監督）`
- Issued: 2026-08-01 (Asia/Tokyo)
- Assignee: `30 QA・性能・レビュー`
- Status: **Authorized / export precondition, exported smoke, and final audit only**
- Milestone: M2 / Slice 2-B pre-integration foundation
- Required branch: `codex/phase2-slice2b-action-foundation-qa`
- Required workspace: existing dedicated worktree `C:\tmp\q2b`
- Frozen `-004` QA tip / required predecessor: `aa259df7dac23676f86f48e45a91fa5b4c49c85e`
- Required execution HEAD: the `-005` supervisor issuance commit supplied in the START message
- Candidate implementation commit: `0f705eeba3554d1f52b7402bb625ca8a86dd1560`
- Candidate handoff / reviewed HEAD: `81efefb156af68e5f564c6a97ce7e1d163b158a0`
- Integration authority: **None**
- Gate effect: **None** — Gate 2 remains Locked

## 1. Supervisor disposition and inherited Pass evidence

`MFO-WO-P2-2B-004` is accepted as **Blocked / external export-output directory precondition omitted**. It does not
establish a candidate implementation, specification, project-configuration, or release-export defect. The ignored
`build/windows` directory is absent in a fresh worktree, and Godot 4.7 does not create the parent export directory.
The same missing-directory failure is preserved in earlier diagnostic evidence, while precreating the directory let
the same engine, preset, and export command succeed.

The following committed `-004` results are accepted as inherited Pass evidence and must not be rerun in this order:

- engine identity and version;
- headless import / parse;
- corrected foundation runner `PASS: 71 assertions`;
- Phase 1 `36 / 36`;
- Slice 2-A `120 / 120`;
- Slice 2-A correction `39 / 39`;
- headless main-scene smoke.

Before any runtime write, read back and bind all of these identities:

- execution HEAD equals the START-message supervisor commit, local / origin are exact, and the frozen `-004` tip
  above is its expected ancestor;
- corrected runner: `5745d2ace2fab67aabd4b5761d5f7ce6339c8b15cbaad25a8c821b22f1a878a4`;
- Godot console: `198152` bytes / SHA-256
  `D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C` / version
  `4.7.stable.official.5b4e0cb0f`;
- candidate and reviewed commits above;
- `-004` report, `foundation-003` command summary, runner-correction evidence, and QA handoff at their Git bytes.

Any mismatch stops before directory creation as `Blocked / validation evidence incomplete`.

## 2. Exact output-directory materialization

Run from `C:\tmp\q2b\material-frontier-online\prototype`. First prove that `build/windows/MFO-Phase1.exe` is
ignored by Git and that `build`, `build/windows`, and the EXE are absent. Then run exactly one directory-creation
invocation:

```powershell
New-Item -ItemType Directory -Path 'build\windows' -Force
```

`directory_materialization_attempt_count` must be `1`; retry is `0`. This one invocation may create the missing
`build` parent and `windows` child. Read back that the result is an ordinary directory inside the project root.
Alternative paths, cleanup, deletion, moving, project configuration changes, and a second materialization attempt are
prohibited.

## 3. Exact export and exported smoke

Use only this console executable:

`C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`

Run the release export exactly once:

```powershell
& $Godot --headless --path . --export-release 'Windows Desktop' 'build/windows/MFO-Phase1.exe'
```

On exit `0`, prove that the EXE exists, has nonzero size, begins with `MZ`, and record its size and SHA-256. Then run
the exported smoke exactly once:

```powershell
& '.\build\windows\MFO-Phase1.exe' --headless --log-file 'C:\tmp\q2b\docs\test-reports\evidence\phase2-slice2b\foundation-004\exported-smoke.log' --quit-after 5
```

For directory materialization, record the exact invocation, success / exception state, and before / after path
readback; a PowerShell cmdlet numeric process exit is not required. For export and exported smoke, require exit `0`
and record raw stdout, raw stderr, numeric exit, command bytes, and result identity. After smoke, prove the EXE hash
is unchanged and relevant residual process count is `0`.

## 4. Final audits

After a successful smoke, complete the final audits that `-004` did not reach:

1. exact runner two-line insertion and `71` call sites / one helper declaration;
2. candidate implementation five-path scope, with the three gameplay code blobs unchanged from the accepted
   implementation;
3. protected / forbidden-path diff audit;
4. immutable `-002`, `-003`, `-004`, `foundation-001`, `foundation-002`, and `foundation-003` artifact identities;
5. `git diff --check`, non-ignored untracked-file count `0`, local / origin equality, and final clean worktree;
6. report / evidence completeness and recorded Not run / Deferred boundaries.

## 5. Authorized paths

Only these tracked paths may be added or changed:

- `docs/test-reports/phase2-slice2b-foundation-export-output-closure.md` — new report;
- `docs/test-reports/evidence/phase2-slice2b/foundation-004/**` — new evidence only;
- `docs/handoffs/qa.md` — receipt and final handoff only.

Runtime-only ignored output is limited to `material-frontier-online/prototype/build/windows/**` plus engine-generated
ignored `material-frontier-online/prototype/.godot/**`. Record any `.godot/**` paths changed by the engine; manual
edits there are prohibited. The corrected runner, game code, all tests, values, data, `.uid` files, scenes,
`project.godot`, export preset, existing reports / evidence, and implementation artifacts are immutable.

## 6. Stop and result rules

Directory materialization, release export, and exported smoke are each exact-one and single-attempt. Read-only
identity and final audit commands may be used only to complete their required evidence; they may not repeat or mask a
failed stateful command. Stop at the first non-pass. Do not repair, retry, change the output path, use another engine /
preset / binary, rerun inherited tests, clean up, or continue to a later step. Return one:

- `Pass / isolated common action-effect-query foundation validated`;
- `Fail / release export or exported artifact nonconformance`; or
- `Blocked / validation infrastructure or evidence incomplete`.

Commit the new report / evidence as one QA content commit and the final QA handoff as a separate commit, then push
only the required QA branch. Return every command / exit / identity, exact changed paths, local / origin equality,
clean status, and all Not run / Deferred items.

Even a Pass validates only the isolated Stage A foundation. It does not resolve Slice 2-A performance, authorize
Stage B, production values, input, authority, damage, scenes, events, presentation, integration, Slice 2-C, or Gate 2.
