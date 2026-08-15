# Fast Slice QA Handoff

- Status: Ready to start `MFO-WO-FS-A-30-001`
- Current status (supersedes the preceding template status): `MFO-WO-FS-A-30-001` QA preparation complete; integrated validation not issued
- Branch: `codex/fast-slice-fs-a-qa-prep`
- Worktree: `C:\tmp\mf-fs-a-30`
- Contract: `docs/FAST_SLICE_CONTRACT.md`

30は開始時にexact HEADとclean statusを記録する。requirement mapping、test identities、commands、results、Not run、handoff tipをこのファイルへ追記する。candidate codeや値は変更しない。

## MFO-WO-FS-A-30-001 complete

- QA start HEAD / contract issuance: `62f4af4a105b45f458beabecd6595ad5f58ec764`; starting local/origin were exact and clean.
- QA-prep commit: `9531e3d45512a326d2a020e720f35dede3915094`.
- Scope: contract requirement-to-test matrix, small candidate-independent public snapshot/loop runner skeleton, KBM checklist, result template, and QA scope audit only.
- Runner: `material-frontier-online/prototype/tests/fast_slice/run_fs_a_contract_skeleton.gd`; SHA-256 `a409a834fbfc3fc8ad0eb818d0221157fa180ba58599b459e49a3cd3c62c8ca6`; UID `uid://cyihcios06q7b` / SHA-256 `817ab9f9de14b1838839745b54d7378e7320920b8b29c2c9c75c7df9882bdaad`.
- Executed: candidate-independent runner fixture exit `0` (`[MFO-FS-A-QA-PREP] PASS: contract seam skeleton fixture`); headless editor import exit `0`; `git diff --check` exit `0`.
- Not run: integrated candidate validation, manual KBM/user feel, gamepad, performance/P95/maximum load, Gate action, and any candidate gameplay/presentation test.
- Scope audit: QA-owned paths only; unexpected path count `0`; candidate code changes `0`.
- Report: [`../../test-reports/fast-slice/fs-a-qa-preparation.md`](../../test-reports/fast-slice/fs-a-qa-preparation.md); KBM checklist: [`../../test-reports/fast-slice/fs-a-kbm-checklist.md`](../../test-reports/fast-slice/fs-a-kbm-checklist.md); evidence: [`../../test-reports/evidence/fast-slice/fs-a-qa-preparation/`](../../test-reports/evidence/fast-slice/fs-a-qa-preparation/).
- Status: QA preparation complete. No integrated validation or Gate follow-on is authorized by this handoff.
## MFO-WO-FS-A-30-001A evidence correction

- Correction content commit: `3cce4d31264be20323ac4f49ffdec97a5533a402`.
- The QA-prep report now records the tested baseline, exact executed Godot commands and expected/observed exit results, Windows/Godot/renderer context, evidence paths, and explicit `Pass / QA preparation only` classification.
- The scope audit now records base `62f4af4a105b45f458beabecd6595ad5f58ec764` through prior handoff tip `df18568e5288b7ef051800d26f12012d7980fc81`: all seven changed paths, unexpected `0`, candidate-code changes `0`.
- `telegraph_line` and `telegraph_sector` are local positive-fixture examples only; they do not freeze future integrated candidate acceptance identifiers or geometry.
- Runner/UID/candidate/contract were not changed or rerun. `git diff --check` exit `0`; scope JSON parse and report/evidence hash readback passed.
- Status: documentation evidence correction complete; no integrated validation, Gate action, or automatic follow-on is authorized.

## 2026-08-03 focused smoke／regression readiness verification

- Start／tested tip: `8c13a0b545fdf4c88bf33ec7be6be6649d7e7443`; worktree and origin were exact and clean before execution.
- Focused QA content commit: `02cff48042ef1e3bc1d14d1fc4a119a3b60ca205`. It changes QA report／checklist and adds new evidence only; executed test sources remain byte-identical to the tested tip.
- Required FS-A candidate checks: `0 Pass / 0 Fail / 11 Pending or Not run`. The public snapshot／loop／rematch fixture passes only as QA preparation and is not a candidate Pass.
- Enemy durability terminology remains unresolved for validation: the user wording is “enemy Integrity”, while the contract exposes `boss_hp`. QA added no field and did not declare equivalence.
- Executed: `C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe --headless --editor --path material-frontier-online\prototype --quit` -> exit `0`.
- Executed: `C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe --headless --path material-frontier-online\prototype --script res://tests/fast_slice/run_fs_a_contract_skeleton.gd` -> exit `0`.
- Executed: `C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe --headless --path material-frontier-online\prototype --script res://tests/run_phase1_tests.gd` -> exit `0`.
- Executed: `C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe --headless --path material-frontier-online\prototype --script res://tests/run_slice2a_tests.gd` -> exit `0`; `120 assertions`.
- Executed: `C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe --headless --path material-frontier-online\prototype --script res://tests/run_slice2a_correction_tests.gd` -> exit `0`; `39 assertions`.
- Executed: `C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe --headless --path material-frontier-online\prototype --script res://tests/run_slice2b_stageb_action_kernel_tests.gd` -> exit `0`; `184 assertions`.
- Not run: dedicated FS-A scene launch, candidate gameplay／presentation／integration validation, manual KBM／user feel, gamepad, performance／P95／maximum load／long-run, and Gate action.
- Evidence: [`../../test-reports/evidence/fast-slice/fs-a-qa-preparation/focused-readiness-evidence-20260803.json`](../../test-reports/evidence/fast-slice/fs-a-qa-preparation/focused-readiness-evidence-20260803.json). Scope audit: [`../../test-reports/evidence/fast-slice/fs-a-qa-preparation/focused-readiness-scope-audit-20260803.json`](../../test-reports/evidence/fast-slice/fs-a-qa-preparation/focused-readiness-scope-audit-20260803.json).
- Scope result: base-to-handoff changes remain within the QA-owned paths; unexpected path count `0`; production gameplay／presentation／integration path modifications `0`; production dependencies were exercised read-only.
- Stop result: no whole-project stop condition occurred. Any future candidate Fail stops only the frozen candidate／integration commit under the contract.
- Status: focused QA readiness record complete. `MFO-WO-FS-A-30-002` remains Draft／not issued; no candidate validation, Gate action, or automatic follow-on is authorized.

## MFO-WO-FS-A-30-003 Option A integrated revalidation Return

- Branch: `codex/fast-slice-fs-a-revalidation`.
- Frozen candidate: `f03a43d2339e9772a15db1c591a31f5e4f92cca2`; review: `ba688730e57564bbb883035972bba9ff2224cd50`; issued/tested source: `29c22763c41abaace46430395dd1bdfd14caaf66`.
- Candidate/review/issuance prototype tree: `2a66e4c06308a47678e8888a739b87ffd33d1ee8`; candidate-to-issuance prototype delta `0`.
- Current disposition: `Technical Pass / promotion pending manual KBM and/or user feel`; promotion remains stopped. No promotion or Gate action is authorized or performed.

### Automated and technical result

- Qualifying unique fresh-stage order: `22 / 22` numeric exits `0` in the required order.
- Expected warning headers: Integration `4`; Presentation invalid-spatial `20`; other warnings `0`.
- `ERROR` / `SCRIPT ERROR` / terminal `FAIL`: `0 / 0 / 0`.
- Gameplay Option A and Presentation spatial/read-only anchors: Pass.
- Contract Section 10 automated technical mapping: `15 / 15 Pass`; counts alone are not acceptance.
- Candidate-independent QA skeleton is preparation coverage only and is not used as candidate acceptance.
- The first evidence-orchestrator stop occurred before archive/Godot/candidate evaluation and is recorded separately as a corrected QA preparation defect.

### Manual result and provenance

- Manual 21 rows: `3 Pass / 0 Fail / 0 Blocked / 18 Not run`.
- Pass rows: real integrated scene/focus, visible movement, and actual user free-text capture.
- User direct positive evidence: movement, generic attack, incoming damage, and outgoing damage worked.
- `LMB`/`RMB` was a QA instruction terminology question and is not a candidate UI finding.
- Initial post-defeat item/E nonresponse is preserved. The tester did not affirm a positive-Integrity precondition, so 00 classified that attempt as non-qualifying for alive-harvest acceptance, not a candidate Fail.
- The retained-stage alive retry explicitly required positive Integrity, boss defeat, WRECK, A/B/C center positioning, E release/fresh tap, three `COLLECTED`, result, rematch, and round-two movement/attack. User reply: `全部できました`; session exit `0`, diagnostic count `0`, normal close.
- The reply is not expanded into duplicate rejection, `result only after third`, complete reset, hostile-stop, or unrelated readability. Those composite manual rows remain Not run.
- Session B prompt-level visible player/enemy stop was confirmed. Granular stop/invariant clauses remain automated technical corroboration; composite manual rows remain Not run.
- Candidate defect count: `0`; shared-contract change needed: `No`.

### Scope and retention

- Changed paths are restricted to the new revalidation report/checklist/evidence root and this append-only handoff section. Candidate, tests, contract, work order, old validation, production, and 00-owned handoffs remain unchanged.
- Historical final `3968be22d206bb66602dfc23efeb6bb372211461`, automated `17 / 17`, technical `13 / 13`, and manual `0 / 6 / 11 / 2` remain frozen reference-only records.
- Automated temporary stage/archive were exact-cleaned after readback.
- Manual stage/archive remain retained for 00 cleanup after acceptance: `C:\tmp\mf-fs-a-reval-manual-20260815-001` and `.tar`; Godot process count `0`.
- Physical gamepad and performance/P95/maximum load/long-run are `Not run / Deferred`; optional export is `Not run`.

### Durable records

- Report: [`../../test-reports/fast-slice/fs-a-integrated-revalidation.md`](../../test-reports/fast-slice/fs-a-integrated-revalidation.md).
- Checklist: [`../../test-reports/fast-slice/fs-a-kbm-revalidation-checklist.md`](../../test-reports/fast-slice/fs-a-kbm-revalidation-checklist.md).
- Evidence: [`../../test-reports/evidence/fast-slice/fs-a-integrated-revalidation/`](../../test-reports/evidence/fast-slice/fs-a-integrated-revalidation/).
- Exact commands/exits/logs, source identities, 15-item mapping, user prompts/replies, cleanup, scope audit, and self-excluded evidence manifest are stored in that evidence root.
