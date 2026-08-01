# MFO-WO-P2-2B-005 — Slice 2-B foundation export-output closure

- Work order: `MFO-WO-P2-2B-005`
- Classification: **Blocked / validation infrastructure or evidence incomplete**
- Supervisor / execution HEAD: `e8d9388bdbed3eefe601148b0ab0b2d0db84e9df`
- Frozen -004 predecessor: `aa259df7dac23676f86f48e45a91fa5b4c49c85e` (confirmed ancestor)
- Candidate implementation / reviewed handoff: `0f705eeba3554d1f52b7402bb625ca8a86dd1560` / `81efefb156af68e5f564c6a97ce7e1d163b158a0`

## Inherited inputs

The -004 corrected runner was read back as SHA-256
`5745d2ace2fab67aabd4b5761d5f7ce6339c8b15cbaad25a8c821b22f1a878a4`. The designated Godot console was
read back as `198152` bytes, SHA-256 `D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`,
version `4.7.stable.official.5b4e0cb0f`. The -002, -003, and -004 reports/evidence and current handoff were
hash-read before runtime writes. No inherited engine, import, runner, regression, or main-smoke command was rerun.

## Output precondition and export

Before stateful work, `build`, `build/windows`, and `build/windows/MFO-Phase1.exe` were absent. Git confirmed the
target executable is ignored by `material-frontier-online/prototype/.gitignore:3` (`build/`).

The required exact-one directory materialization succeeded:

```powershell
New-Item -ItemType Directory -Path 'build\windows' -Force
```

The new `build/windows` path was read back as a directory under the project root. The required release export then
completed exit `0` using the specified engine, preset, and output path:

```powershell
& $Godot --headless --path . --export-release 'Windows Desktop' 'build/windows/MFO-Phase1.exe'
```

The exported executable existed, was `109116312` bytes, began with `MZ`, and had SHA-256
`c2ec5f79c2f5302715cf27ebcac881329852ec78651d627c46fba91ba3378c1f`.

## First non-pass: exported smoke evidence

The required exact-one exported-smoke command was invoked:

```powershell
& '.\build\windows\MFO-Phase1.exe' --headless --log-file 'C:\tmp\q2b\docs\test-reports\evidence\phase2-slice2b\foundation-004\exported-smoke.log' --quit-after 5
```

It emitted only the Godot engine banner and returned control to PowerShell, but `$LASTEXITCODE` was unset. Therefore
the required numeric exit code could not be recorded. The specified `exported-smoke.log` was absent on readback.
The exported EXE remained byte-identical at the SHA-256 above and relevant `MFO-Phase1` / Godot process count was `0`.

This missing numeric-exit and missing-log evidence is the first non-pass. The smoke was not restarted through another
launcher, no alternate capture was introduced, and no cleanup was performed. The engine generated an untracked
`tests/run_slice2b_foundation_tests.gd.uid`; it is preserved rather than deleted under the post-non-pass boundary.

## Not run after the stop boundary

- Final runner insertion audit and candidate five-path scope audit
- Protected / forbidden-path audit
- Final immutable-artifact identity readback
- `git diff --check`, non-ignored untracked audit, local/origin equality, final clean-worktree audit
- Physical gamepad and manual user-feel
- Slice 2-A harness, PREACK, performance/P95, real A/B/C, Stage B, integration, Gate 2

## Recommendation

**Blocked / validation infrastructure or evidence incomplete.** The fresh release export itself passed, but the sole
exported-build smoke invocation did not yield the mandatory numeric exit or designated log. This report does not
authorize smoke retry, launcher changes, cleanup, implementation modification, Stage B, integration, or Gate 2.

Evidence: `docs/test-reports/evidence/phase2-slice2b/foundation-004/commands.md`.

### Post-return log readback

The required log was absent immediately after PowerShell returned from the sole smoke invocation, but was created asynchronously later at the required absolute path. Its size is `572` bytes and its SHA-256 is `60d35ec29b0fad2f63df0f0a991e5d7e82fc1ae35e68544fe3ca54505641ade2`; it records the engine banner, `DefinitionsValidated`, and a RuntimeHardLimit record. Relevant residual process count at that later readback was `0` and the EXE hash remained unchanged. This does not supply the missing numeric `$LASTEXITCODE`; the classification therefore remains Blocked. See `foundation-004/smoke-readback.md`.
