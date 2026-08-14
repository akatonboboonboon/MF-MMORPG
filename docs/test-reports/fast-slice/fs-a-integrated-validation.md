# FS-A Integrated Validation Report

- Work order: MFO-WO-FS-A-30-002
- Validation date: 2026-08-14
- Branch: codex/fast-slice-fs-a-validation
- Outcome: Technical Pass / promotion pending manual KBM and/or user feel
- Automated technical acceptance: 13 / 13 Pass
- Manual KBM, readability, and user feel: Not run
- Promotion and Gate action: not authorized by this work order

## Identity

| Identity | Value |
| --- | --- |
| Frozen candidate source | 867899c7ccb9380b4bb6e4be5c51da4223532230 |
| 00 review parent | d79b542ec42f34306a0370b07752e732dcf0c7fc |
| Validation issued tip and tested source | 3cdf6dbd9031e3d05fd2a049c851f19409d7b592 |
| Frozen and tested prototype tree | 5f948fa5b09dc970beab5afef6c21260ecd74edf |
| Candidate ancestry | Confirmed |
| Candidate-to-issued prototype delta | 0 |
| Start local HEAD / tracking / live origin | Exact at 3cdf6dbd9031e3d05fd2a049c851f19409d7b592 |
| Start worktree | Clean |

The tested prototype was never modified. The final QA commits add only report,
evidence, checklist, and handoff material. The final branch identity and scope
readback are recorded in the QA handoff and scope audit.

## Environment

- Host: Microsoft Windows NT 10.0.26200.0, x64
- PowerShell: 5.1.26100.9168
- Time zone: Tokyo Standard Time
- Godot: 4.7.stable.official.5b4e0cb0f
- Godot executable SHA-256:
  d8055fb8c7e7f5010d7439ec69be051554055dae55a265f8647bd7301c34161c
- Renderer: GL Compatibility
- Automated session: headless
- Run window: 2026-08-14T12:46:18.5094259Z through
  2026-08-14T12:48:36.1037554Z

## Fresh-stage preparation

The successful stage was created from validation issued tip 3cdf6dbd by
archiving only material-frontier-online/prototype.

- Stage root: C:\tmp\mf-fs-a-val-stage-20260814-002
- Archive: C:\tmp\mf-fs-a-val-stage-20260814-002.tar
- Archive SHA-256:
  0b533e046564c2748511bf53924b3c96600832e7b5fbad41307c2f583e487458
- Pre-import .godot existed: false
- Post-import .godot existed: true
- Twelve selected source hashes matched the validation worktree exactly.

The first staging attempt stopped before any Godot invocation because Windows
PowerShell 5 does not accept New-Item -LiteralPath. It created only the exact
archive C:\tmp\mf-fs-a-val-stage-20260814-001.tar; no stage existed. That
archive was removed after exact-path verification. 00 classified this as an
external preparation command issue, not a candidate or test failure. The new
unique stage above was then created with compatible syntax.

After raw-log and source-hash readback, both successful-stage temporary targets
were removed by exact absolute path. The stage and archive are absent; the
validation worktree remains present. See preparation-cleanup.json.

## Required automated execution

All 17 required invocations exited 0. Each Command evidence link contains the
complete exact command line, including the executable and fresh project path.
The adjacent raw log contains timestamps, exit code, and merged process output.

| Order | Command evidence | Expected | Actual |
| --- | --- | --- | --- |
| 0 | [Godot version](../evidence/fast-slice/fs-a-integrated-validation/logs/00-godot-version.command.txt) | Exact 4.7 stable; exit 0 | Exact version; exit 0 |
| 1 | [Fresh import](../evidence/fast-slice/fs-a-integrated-validation/logs/01-fresh-import.command.txt) | Import; exit 0 | Imported; exit 0 |
| 2 | [Integration root parse](../evidence/fast-slice/fs-a-integrated-validation/logs/02-integration-root-parse.command.txt) | Parse; exit 0 | Exit 0 |
| 3 | [Integration self-check parse](../evidence/fast-slice/fs-a-integrated-validation/logs/03-integration-self-check-parse.command.txt) | Parse; exit 0 | Exit 0 |
| 4 | [Integration self-check](../evidence/fast-slice/fs-a-integrated-validation/logs/04-integration-self-check.command.txt) | One loop, parity, expected warning fixtures; exit 0 | PASS, checks=236, one_loop=true, presentation_parity=true; exit 0 |
| 5 | [FS-A main scene](../evidence/fast-slice/fs-a-integrated-validation/logs/05-fs-a-main-launch.command.txt) | Dedicated scene launches; exit 0 | Exit 0 |
| 6 | [Gameplay parse](../evidence/fast-slice/fs-a-integrated-validation/logs/06-gameplay-self-check-parse.command.txt) | Parse; exit 0 | Exit 0 |
| 7 | [Gameplay self-check](../evidence/fast-slice/fs-a-integrated-validation/logs/07-gameplay-self-check.command.txt) | Full loop Pass; exit 0 | PASS: full gameplay loop; exit 0 |
| 8 | [Gameplay scene](../evidence/fast-slice/fs-a-integrated-validation/logs/08-gameplay-scene-launch.command.txt) | Scene launches; exit 0 | Exit 0 |
| 9 | [Presentation self-check](../evidence/fast-slice/fs-a-integrated-validation/logs/09-presentation-self-check.command.txt) | Read-only self-check; exit 0 | PASS, snapshots=4, events=3, harvest_each=3, read_only=true |
| 10 | [Presentation pure shell](../evidence/fast-slice/fs-a-integrated-validation/logs/10-presentation-pure-shell.command.txt) | Pure shell launches; exit 0 | Exit 0 |
| 11 | [Presentation preview](../evidence/fast-slice/fs-a-integrated-validation/logs/11-presentation-preview.command.txt) | Preview launches; exit 0 | Exit 0 |
| 12 | [Candidate-independent QA fixture](../evidence/fast-slice/fs-a-integrated-validation/logs/12-candidate-independent-qa-fixture.command.txt) | Fixture Pass only | PASS: contract seam skeleton fixture; exit 0 |
| 13 | [Existing project main](../evidence/fast-slice/fs-a-integrated-validation/logs/13-existing-project-main-smoke.command.txt) | Launch; RHL violations 0 | Exit 0; violation_count=0 |
| 14 | [Phase 1 regression](../evidence/fast-slice/fs-a-integrated-validation/logs/14-phase1-regression.command.txt) | All Phase 1 tests Pass | PASS; exit 0 |
| 15 | [Slice 2-A regression](../evidence/fast-slice/fs-a-integrated-validation/logs/15-slice2a-120-regression.command.txt) | 120 assertions Pass | PASS; exit 0 |
| 16 | [Slice 2-A correction](../evidence/fast-slice/fs-a-integrated-validation/logs/16-slice2a-correction-39-regression.command.txt) | 39 assertions Pass | PASS; exit 0 |

The candidate-independent QA fixture is preparation evidence only. It is not
used as a substitute for any candidate acceptance item.

### Warning and error audit

- Intentional active-empty rejection warnings: 2
- Intentional unknown-shape rejection warnings: 2
- Total expected warning fixtures: exactly 4
- Other warnings: 0
- ERROR or SCRIPT ERROR lines: 0

The four warnings occur only in the integration self-check, once per invalid
fixture in Presentation-enabled and Presentation-disabled loops. Their stack
continuation lines were not counted as new warnings.

## Contract Section 10 results

| # | Technical result | Observed evidence |
| --- | --- | --- |
| 1 | Pass | Fresh import, integration root/self-check parse, dedicated scene launch all exit 0; integration scene loads and instantiates as FsAIntegrationRoot |
| 2 | Pass | Gameplay log lines 175-179: movement, independent aim, evade start/completion, and player movement |
| 3 | Pass | Gameplay lines 11, 17, 19-20: light accepted, heavy separately accepted with distinct timing, one action cannot commit twice |
| 4 | Pass | Gameplay lines 41-47 and 99-101: line and sector warnings precede attacks and both are avoidable |
| 5 | Pass | Gameplay lines 49-50 and 157-158: player Integrity decreases, Deformation increases, and rematch restores/clears both |
| 6 | Pass | Gameplay lines 62 and 95: required part breaks and transition count is exact once |
| 7 | Pass | Gameplay lines 88 and 96: canonical boss_hp reaches zero and defeat transition is exact once |
| 8 | Pass | Gameplay lines 89 and 92-94: boss becomes non-functional; attack, player-hit query, and enemy-hit stop |
| 9 | Pass | Gameplay line 97 and integration line 134: wreck spawn/node is exact once |
| 10 | Pass | Gameplay lines 139-152 and integration lines 135-138: exact three points, duplicate reject, exact three collections |
| 11 | Pass | Gameplay lines 149-153: all collection reaches visible result and transition is exact once |
| 12 | Pass | Gameplay lines 159-169 and integration lines 149-155: complete reset, round-two light/hit, and enemy AI restart |
| 13 | Pass | Integration lines 258-267: Presentation-enabled/disabled result, reset, and round-two authority are identical |

Enemy durability was validated only as the canonical boss_hp field. No enemy
Integrity alias or equivalence was added or assumed.

## Manual KBM and human boundary

All recorded commands were headless. They do not establish real keyboard/mouse
operation, telegraph/HUD/result readability, reaction clarity, or player feel.
Every manual checklist row remains Not run.

For the manual session, create a new fresh stage from the exact tested source;
the automated temporary stage was intentionally cleaned up. The following is
the exact launch preparation and integrated scene command. Do not use the
Presentation preview as the manual acceptance scene.

    $Godot = 'C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe'
    $ValidationWorktree = 'C:\tmp\mf-fs-a-val'
    $ManualStageRoot = 'C:\tmp\mf-fs-a-val-manual-20260814-001'
    $ManualArchive = 'C:\tmp\mf-fs-a-val-manual-20260814-001.tar'
    Set-Location -LiteralPath $ValidationWorktree
    git archive --format=tar --output=$ManualArchive 3cdf6dbd9031e3d05fd2a049c851f19409d7b592 -- material-frontier-online/prototype
    New-Item -ItemType Directory -Path $ManualStageRoot
    tar -xf $ManualArchive -C $ManualStageRoot
    $FreshProject = Join-Path $ManualStageRoot 'material-frontier-online\prototype'
    & $Godot --path $FreshProject --scene res://scenes/fast_slice/fs_a_main.tscn

Controls: WASD move, mouse aim, LMB light, RMB heavy, Space evade, E harvest
and rematch. Record functional result separately from readability and free-text
feel in fs-a-kbm-checklist.md. The manual stage/archive must be cleaned by exact
path after the session.

## Deferred and Not run

- Manual KBM functional check: Not run
- Readability and user feel: Not run
- Physical gamepad: Deferred / Not run
- Performance, P95, maximum load, and long-run: Deferred / Not run
- Optional normal release export/smoke: Not run
- Slice 2-B Stage B 184: Not run; optional, non-blocking inherited guardrail
- Real A/B/C matrix: Not run and out of scope
- Promotion and Gate action: not authorized

## Scope and exclusions

- Base-to-candidate changed paths: 46.
- Candidate excluded-system matches for network/server/account/persistence,
  music/SE/voice/audio, production art/assets, binaries, and LFS paths: 0.
- Candidate changes to project.godot, export_presets.cfg, and .gitattributes: 0.
- Validation changed-path audit is reported separately from candidate scope.
- Candidate Gameplay, Presentation, integration, data, project settings, shared
  contract, and legacy tests were exercised read-only and modified 0 times.
- QA test runner changes: 0; existing validation and fixture sources were used.
- Production gameplay specification or values changed: no.
- Shared contract change required: no.
- Whole-project stop conditions encountered: none.

## Pass, Fail, and blocker conditions

Technical Pass requires import/parse/scene launch, the integrated loop,
individual evidence for all 13 items, required regressions, protected-path
delta 0, diff check 0, evidence readback, and exact cleanup. Those technical
conditions are met.

A reproducible frozen-candidate parse/assertion/functional defect would be
Fail / candidate and stop only that candidate. A QA runner/launcher/host
condition preventing evaluation would be Blocked / QA infrastructure and would
not be attributed to the candidate. Whole-line stop remains limited to the
three conditions in the Fast Slice contract; none occurred.
