# MFO-WO-P2-2A-009 preparation commands

All commands were executed fresh on 2026-07-16 JST from QA HEAD
f4986e7fdd7bfbbb5983e98c1dfb2129ebab08a4.

## Source and preparation validation

- Native helper compile: exit 0.
- StagePreparer.exe compile, x64 optimized: exit 0.
- RunPreparation.ps1 and RecordRepositoryState.ps1 parser check: exit 0.
- StagePreparer.SourceDiffAudit and StagePreparer.SourceAudit read-only preflight: exit 0;
  changed hunks 51, unauthorized hunks 0, outside authorized regions byte-identical, five component sources audited.
- Raw activation binding: one raw read, one BOM-less expected UTF-8 conversion, one byte comparison,
  normalization references 0, and named CR/LF/CRLF fixtures 1 / 1 / 1.

## Fixed execution order

1. StagePreparer.exe --mode INIT --stage <stage> --source-root <fresh-source> --supervisor-commit 6c0d5e04c1c70692c57f18f98416b7ebff324706 --stage-id p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1
   - exit 0
2. RecordRepositoryState.ps1 -Stage <stage> -StageId p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1 -SupervisorCommit 6c0d5e04c1c70692c57f18f98416b7ebff324706 -RequiredBranch codex/phase2-slice2a-harness-live-evidence-requalification-qa -RequiredHead f4986e7fdd7bfbbb5983e98c1dfb2129ebab08a4
   - exit 0
   - evidence SHA-256 5d9bfb4c10445e23c3c45ddb07312187ba36cf144f1c4b120db957da7e37ac8d
3. StagePreparer.exe --mode CONTRACT --stage <stage> --compiler C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe --stage-id p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1 --supervisor-commit 6c0d5e04c1c70692c57f18f98416b7ebff324706 --qa-receipt-commit f4986e7fdd7bfbbb5983e98c1dfb2129ebab08a4 --baseline-source-root <qualification-003-source>
   - exit 0
4. RunPreparation.ps1 -InvocationKey qp_dryrun_runner_exact -OutputRelative preparation\dryrun-qualified
   - wrapper/native exit 0 / 0; Pass
5. RunPreparation.ps1 -InvocationKey qp_selftest_runner_exact -OutputRelative preparation\selftest-qualified
   - wrapper/native exit 0 / 0; Pass
6. RunPreparation.ps1 -InvocationKey qp_power_input_smoke_runner_exact -OutputRelative preparation\power-input-smoke-qualified
   - wrapper/native exit 0 / 0; Pass
7. RunPreparation.ps1 -InvocationKey qp_preack_contract_selftest_runner_exact -OutputRelative preparation\preack-contract-selftest-qualified
   - wrapper/native exit 0 / 0; 33 / 33 Pass
8. RunPreparation.ps1 -InvocationKey qp_live_evidence_contract_selftest_runner_exact -OutputRelative preparation\live-evidence-contract-selftest-qualified
   - wrapper/native exit 0 / 0; 20 / 20 Pass; controller launch 0
9. StagePreparer.exe --mode SEAL --stage <stage> --stage-id p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1 --supervisor-commit 6c0d5e04c1c70692c57f18f98416b7ebff324706 --qa-receipt-commit f4986e7fdd7bfbbb5983e98c1dfb2129ebab08a4
   - exit 0

The exact sealed runner command strings and their SHA-256 values are in
config/component-contract.json. PREACK, LIVE, performance slot, P95, KBM, A/B/C, and game commands were not run.
