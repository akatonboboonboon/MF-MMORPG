# MFO-WO-P2-2B-006 — Slice 2-B foundation exported-smoke and UID closure

- Work order: `MFO-WO-P2-2B-006`
- Recommendation: **Pass / isolated common action-effect-query foundation validated**
- Supervisor / execution HEAD: `98826e6ce952ee2359dc8dd7f32562f5db0d56ac`
- Frozen predecessor: `3cfdcc875caa74ceb0041781db631ee930e3725c` (ancestor confirmed)
- Candidate implementation / reviewed handoff: `0f705eeba3554d1f52b7402bb625ca8a86dd1560` / `81efefb156af68e5f564c6a97ce7e1d163b158a0`

## Inherited Pass evidence

The following -004/-005 results were identity-bound and not rerun: Godot identity/version, import/parse,
foundation runner `71 / 71`, Phase 1 `36 / 36`, Slice 2-A `120 / 120`, Slice 2-A correction `39 / 39`, main
smoke, output-directory materialization, and fresh release export. The corrected runner remained SHA-256
`5745d2ace2fab67aabd4b5761d5f7ce6339c8b15cbaad25a8c821b22f1a878a4` with `71` `_check` call sites and one
`_check` helper declaration.

## UID sidecar closure

The pre-existing engine-generated sidecar was read before Git state changed:

- Path: `material-frontier-online/prototype/tests/run_slice2b_foundation_tests.gd.uid`
- Bytes: `uid://dku5njih7fwgp` plus LF; size `20`
- SHA-256: `13a6840a6a967830e1af3dc083068b9fde63179f8217a4c93638be2531359366`
- Ignore match: none
- Index blob after one exact addition: `a8df659f3db95483e040e44c60449ce05995ecc5`

The three other test sidecars have distinct identities; no other `.uid` path changed.

## Exact waitable exported smoke

The frozen export was verified before launch as `109116312` bytes, `MZ`, SHA-256
`c2ec5f79c2f5302715cf27ebcac881329852ec78651d627c46fba91ba3378c1f`. The evidence root and fresh smoke log were
absent before launch. The persisted launcher used `System.Diagnostics.ProcessStartInfo` with `UseShellExecute=false`,
both standard streams redirected and read through parallel `ReadToEndAsync()` tasks, and `WaitForExit(120000)`.

One process launch produced:

- PID `32516`; timeout `false`; numeric exit `0`
- stdout `576` bytes, SHA-256 `848df27bd117ebf8e412be1320619342548e265252e3a69a7b83e6da475fddd0`
- stderr `0` bytes, SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`
- Fresh log SHA-256 `967ba199e07d42eba93811da0ca821bf878a350ee30795c85e550d34f625e78e`

The new log contains `DefinitionsValidated` and a RuntimeHardLimit record with `violation_count: 0`. The EXE
identity was unchanged after exit and relevant residual `MFO-Phase1` / Godot process count was `0`.

## Scope and closure audit

The implementation diff from `dd36e7e8d3c2e3ad7c5db74a056fe0694027a564` to reviewed handoff
`81efefb156af68e5f564c6a97ce7e1d163b158a0` contains exactly five expected paths: gameplay handoff, implementation
report, and three combat scripts. The three gameplay blobs are identical between implementation commit and reviewed
handoff. New -006 tracked content is limited to the adopted UID, this report, `foundation-005` evidence, and final
QA handoff.

## Boundaries

Physical gamepad is **Not run / Deferred**. Manual user-feel, PREACK, Slice 2-A performance/P95, real A/B/C, Stage B,
integration, production action behavior, and Gate 2 are **Not run / prohibited**. This Pass validates only the
isolated Stage A foundation; it does not authorize any follow-on scope.

Evidence: `docs/test-reports/evidence/phase2-slice2b/foundation-005/`.
