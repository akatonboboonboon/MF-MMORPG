# Fast Slice QA Handoff

- Current status: `MFO-WO-FS-A-30-002` returned / historical automated Technical Pass / Manual KBM functional Fail / promotion stopped
- Recommendation: Do not promote — QA disposition Fail / candidate; shared-contract blockers remain Open
- Current validation branch: `codex/fast-slice-fs-a-validation`
- Current validation worktree: `C:\tmp\mf-fs-a-val`
- Historical QA-prep status: `MFO-WO-FS-A-30-001` complete
- Historical QA-prep branch: `codex/fast-slice-fs-a-qa-prep`
- Historical QA-prep worktree: `C:\tmp\mf-fs-a-30`
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

## MFO-WO-FS-A-30-002 integrated validation Return

- Authority: docs/FAST_SLICE_CONTRACT.md and
  docs/work-orders/fast-slice/fs-a-30-integrated-validation.md.
- Frozen candidate source:
  867899c7ccb9380b4bb6e4be5c51da4223532230.
- 00 review parent:
  d79b542ec42f34306a0370b07752e732dcf0c7fc.
- Validation issued tip and tested source:
  3cdf6dbd9031e3d05fd2a049c851f19409d7b592.
- Frozen and tested prototype tree:
  5f948fa5b09dc970beab5afef6c21260ecd74edf.
- QA content commit:
  2bbe3a874f0b68e800faad5125bb3e6d60f461a3.
- Candidate ancestry, candidate-to-issued prototype delta 0, and start
  HEAD/tracking/live-origin equality were confirmed before execution.

### Automated result

- Required invocations: 17 / 17 exit 0.
- Contract Section 10 technical items: 13 / 13 Pass.
- Integration terminal:
  self_check=PASS checks=236 shapes=3 events=3 one_loop=true
  presentation_parity=true.
- Gameplay terminal: PASS: full gameplay loop.
- Presentation terminal:
  self_check=PASS snapshots=4 events=3 harvest_each=3 read_only=true.
- Existing main: RuntimeHardLimit violation_count 0.
- Required regressions: Phase 1 Pass, Slice 2-A 120 assertions Pass,
  Slice 2-A correction 39 assertions Pass.
- Candidate-independent QA fixture: Pass / fixture only; it was not used as
  candidate acceptance evidence.
- Intentional invalid-fixture warnings: active-empty 2 plus unknown-shape 2,
  exact total 4. Other warning/error/SCRIPT ERROR/terminal FAIL count: 0.
- Optional Stage B 184: Not run / non-blocking inherited guardrail.

The exact executed values were:

    $Godot = 'C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe'
    $FreshProject = 'C:\tmp\mf-fs-a-val-stage-20260814-002\material-frontier-online\prototype'
    & $Godot --version
    & $Godot --headless --editor --path $FreshProject --quit
    & $Godot --headless --path $FreshProject --check-only --script res://scripts/fast_slice/integration/fs_a_integration_root.gd
    & $Godot --headless --path $FreshProject --check-only --script res://scripts/fast_slice/integration/fs_a_integration_self_check.gd
    & $Godot --headless --path $FreshProject --script res://scripts/fast_slice/integration/fs_a_integration_self_check.gd
    & $Godot --headless --path $FreshProject --scene res://scenes/fast_slice/fs_a_main.tscn --quit-after 120
    & $Godot --headless --path $FreshProject --check-only --script res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd
    & $Godot --headless --path $FreshProject --script res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd
    & $Godot --headless --path $FreshProject --scene res://scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn --quit-after 120
    & $Godot --headless --path $FreshProject --scene res://scenes/fast_slice/presentation/fs_a_presentation_preview.tscn -- --fs-a-self-check
    & $Godot --headless --path $FreshProject --scene res://scenes/fast_slice/presentation/fs_a_presentation_shell.tscn --quit-after 5
    & $Godot --headless --path $FreshProject --scene res://scenes/fast_slice/presentation/fs_a_presentation_preview.tscn --quit-after 5
    & $Godot --headless --path $FreshProject --script res://tests/fast_slice/run_fs_a_contract_skeleton.gd
    & $Godot --headless --path $FreshProject --quit-after 120
    & $Godot --headless --path $FreshProject --script res://tests/run_phase1_tests.gd
    & $Godot --headless --path $FreshProject --script res://tests/run_slice2a_tests.gd
    & $Godot --headless --path $FreshProject --script res://tests/run_slice2a_correction_tests.gd

Each command's expanded one-line executable/path form, timestamps, exit code,
and execution log are retained under the integrated-validation evidence root.

### Technical items

1. Dedicated scene import/parse/launch: Pass.
2. Existing move/aim/evade: Pass technical.
3. Distinct light/heavy input and timing: Pass technical.
4. Line/sector warning and avoidance: Pass technical.
5. Player Integrity/Deformation change and reset: Pass.
6. At least one part break and exact-once transition: Pass.
7. Canonical boss_hp zero transition exact once: Pass.
8. AI/attack/hit stop after defeat: Pass.
9. Wreck exact once: Pass.
10. Exact three harvest points and duplicate rejection: Pass.
11. Result after all collection: Pass.
12. Complete rematch reset and round-two major actions: Pass.
13. Presentation-disabled Gameplay result parity: Pass.

No enemy Integrity alias/equivalence was added or assumed; boss_hp is the
canonical enemy durability field.

### Evidence packaging and cleanup

- Initial staging attempt 001 stopped before Godot because Windows PowerShell 5
  rejected New-Item -LiteralPath. Only its exact tar existed and was removed.
  00 classified it as an external preparation command issue.
- Successful fresh archive SHA-256:
  0b533e046564c2748511bf53924b3c96600832e7b5fbad41307c2f583e487458.
- Pre-import .godot false; post-import .godot true.
- Twelve selected source files matched fresh-stage SHA-256 exactly.
- Seven short execution logs were normalized only by removing one redundant
  terminal LF. Original/index-blob and normalized size/SHA identities plus
  semantic-line equality are in log-normalization.json. They are not claimed
  as unlimited byte-exact raw logs. Tests were not rerun.
- Execution-artifact manifest: 51 files = 17 commands + 17 exits + 17 logs;
  44 unmodified, 7 EOF-normalized; all hashes read back.
- Exact successful stage and archive are absent after cleanup; validation
  worktree remains present.

### Manual and Deferred

- Manual KBM functional check: Fail.
- Manual combat usability: Fail.
- Readability: Not run / partial.
- User feel: Fail.
- Physical gamepad: Deferred / Not run.
- Performance/P95/maximum-load/long-run: Deferred / Not run.
- Optional release export/smoke: Not run.
- Promotion and Gate action: hold; not authorized.

- Manual preparation attempt-001: `Blocked before candidate evaluation / QA
  preparation defect`. The byte-identical fresh prototype was launched without
  a prior editor import/class scan, producing 34 `SCRIPT ERROR` and 4
  failed-script-load headers before manual interaction. Numeric exit was not
  durably captured. This is not a candidate Fail or playability finding; all
  manual rows were `Not run` at attempt-001 closure, and the automated Technical
  Pass was unchanged. Attempt-002 supersedes only manual result/recommendation.
  Retry `manual-20260814-002` must complete editor import and verify the global
  class cache before launching the integrated GUI scene. Evidence:
  `docs/test-reports/evidence/fast-slice/fs-a-integrated-validation/manual-attempt-001.json`.
- Manual validation attempt-002: the same archive/source/prototype tree was
  reconstructed, `.godot` was absent before import, the corrected editor import
  was reported exit 0, and the 24-entry global class cache was generated before
  the required `fs_a_main.tscn` GUI scene. The attempt-002 log contains no parse,
  load, or warning header. Manual interaction was reached; the user closed the GUI.
- Exact user observations: `移動ができない`; initial
  `HPが0になっても続く`; later clarification message
  `0後もボスが攻撃してきました。そもそもこっちの攻撃が敵に届いていないので`.
  The boss clause (including `。`) specifies what continued; the attack-reach
  clause follows in the same message. Field identity remains a separate 00
  determination.
- 00 inference / determination: no attack was observed reaching the enemy, so no
  `boss_hp` decrease was established; 00 identified the zero display as player
  `INTEGRITY`. The user did not directly identify that field.
- Finding 1: visible move/aim/evade `Fail`. The authority actor is hidden while
  Presentation draws a fixed-position knight proxy without consuming
  `player_position` or `player_aim`. Only movement was directly user-reported;
  aim/evade are source-backed user-visible acceptance findings, not separate
  user reports. Live authority input/action acceptance remains unestablished and
  is not inferred Fail.
- Finding 2: manual combat usability `Fail`; attacks could not visibly reach or
  damage the enemy. Valid-hit, exact-once damage, and authority-action questions
  remain Blocked where no manual hit was established.
- Finding 3: approved player-side Integrity-0 defeat/spec compliance
  `Fail / candidate`. The candidate clamps Integrity to zero but has no defeat
  latch; arena motion/action/authority/hit processing and player action/hit-query
  guards do not stop on player defeat.
- The user's direct observation that boss attack continued after zero is
  preserved separately. Enemy AI/telegraph/attack/pending-hit stop scope is
  `Blocked / shared-contract — OQ-00-20260815-002`; pending-hit is source
  inference/corroboration, not user testimony, and the enemy side is not asserted
  as an already-approved candidate spec Fail.
- Original 17 manual rows: 4 Fail / 11 Blocked / 2 Not run. Two supplemental
  coverage rows: 2 Fail. Functional KBM and user feel are Fail; readability is
  Not run / partial.
- Automated 17 / 17 exits and technical 13 / 13 Pass remain historical and
  unchanged. 00 formal classification: `Manual KBM functional Fail / promotion
  stopped`. QA disposition: `Fail / candidate — promotion and Gate hold`.
  This stops only the frozen candidate/integration commit; no whole-line stop.
- Evidence:
  `docs/test-reports/evidence/fast-slice/fs-a-integrated-validation/manual-attempt-002.json`.
  The exact attempt-002 stage/archive remain for 00-owned cleanup.

The exact fresh-stage reconstruction, integrated manual launch command, controls
(WASD / mouse / LMB / RMB / Space / E), and observation rows are in
fs-a-kbm-checklist.md. Do not use the Presentation preview for manual
integrated acceptance.

### Scope and handoff

- Candidate Gameplay, Presentation, integration, data, project settings,
  shared contract, legacy tests, and all production paths changed: 0.
- QA test runner changes: 0.
- Candidate excluded-system matches: 0.
- All validation changes are under the exact QA writable allowlist;
  unexpected/protected path count 0.
- Shared-contract coverage gap detected: yes. The prior FS-A contract/work order/
  checklist did not explicitly map MASTER_SPEC player-Integrity-zero defeat.
  00 tracks the read-only spatial seam as `OQ-00-20260815-001` and player-defeat
  hostile-stop scope as `OQ-00-20260815-002`, both recommended Option A.
  These remain separate from the candidate findings; shared-contract files
  changed by QA: 0. 00 blocker record commit:
  `f398ffb54ec38eb527688d071d32b268a6a5d100`.
- Whole-project stop condition: none.
- Current result stops only the frozen candidate/integration commit, stops no
  unrelated worktree, and authorizes no promotion/Gate action.
- Report: ../../test-reports/fast-slice/fs-a-integrated-validation.md
- Evidence:
  ../../test-reports/evidence/fast-slice/fs-a-integrated-validation/
- Scope audit:
  ../../test-reports/evidence/fast-slice/fs-a-integrated-validation/scope-audit.json

The historical QA-prep 0 Pass / 0 Fail / 11 Pending or Not run record remains
unchanged and separate. Final handoff commit SHA, final local/tracking/live
origin equality, final changed-path count, hashes, and clean state are returned
directly to 00 after this handoff commit is created and pushed.
