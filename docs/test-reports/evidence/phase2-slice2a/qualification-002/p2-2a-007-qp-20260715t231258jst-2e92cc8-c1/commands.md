# Closure commands and evidence provenance

No harness command was executed after the supervisor classified the stage as `Fail / harness defect`.

Read-only observations:

```powershell
git status -sb
git rev-parse HEAD
Get-ChildItem -LiteralPath <stage> -Recurse -File
Get-FileHash -Algorithm SHA256 -LiteralPath <stage-file>
rg -n --no-heading <defect-patterns> <stage>/source/MfoQaNative.cs
Test-Path -LiteralPath <stage>/runs
```

Freeze copy:

```text
Source roots: config/, source/, preparation/, seal/
Destination: docs/test-reports/evidence/phase2-slice2a/qualification-002/p2-2a-007-qp-20260715t231258jst-2e92cc8-c1/
Source files: 77
Destination files before closure-authored records: 77
Source/destination SHA-256 matches: 77 / 77
Excluded executable or DLL payloads: 8
```

The exact preparation invocations and invocation SHA-256 values are preserved in
`seal/qualification-manifest.json`. Their structured results, raw streams, and journals are preserved under
`preparation/`. PREACK and LIVE templates are identity records only and were not invoked.
