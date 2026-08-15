# FS-A Integrated Validation Report

- Work order: MFO-WO-FS-A-30-002
- Automated validation date: 2026-08-14
- Manual result recorded: 2026-08-15
- Branch: codex/fast-slice-fs-a-validation
- 00 formal classification: Manual KBM functional Fail / promotion stopped
- QA disposition: Fail / candidate — historical automated Technical Pass retained / promotion and Gate hold
- Automated technical acceptance: 13 / 13 Pass (historical and unchanged)
- Manual: functional KBM Fail; combat usability Fail; readability Not run / partial; user feel Fail
- Recommendation: do not promote; Gate action remains unauthorized by this work order

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

After execution-artifact and source-hash readback, both successful-stage temporary targets
were removed by exact absolute path. The stage and archive are absent; the
validation worktree remains present. See preparation-cleanup.json.

## Required automated execution

All 17 required invocations exited 0. Each Command evidence link contains the
complete exact command line, including the executable and fresh project path.
The adjacent execution log contains timestamps, exit code, and merged process output.

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

Seven short execution logs initially ended with one redundant blank line.
Before commit, packaging normalization removed exactly one terminal LF from
each, leaving one terminal LF. Their verified pre/post byte sizes, SHA-256
values, original pre-normalization index blob OIDs, and semantic-line equality
are recorded in log-normalization.json. These seven files are normalized
execution logs and are not claimed as unlimited byte-exact raw logs. No test
was rerun and no result semantics changed.

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

All automated commands were headless. They do not establish real keyboard/mouse
operation, telegraph/HUD/result readability, reaction clarity, or player feel.
Manual attempt-002 below reached the required integrated GUI scene and now
provides separate human results; it does not rewrite the automated evidence.

### Manual preparation attempt-001 — 2026-08-14

The user reconstructed tested source
`3cdf6dbd9031e3d05fd2a049c851f19409d7b592` at
`C:\tmp\mf-fs-a-val-manual-20260814-001` and invoked the integrated scene
directly. The archive was 481,280 bytes with SHA-256
`0b533e046564c2748511bf53924b3c96600832e7b5fbad41307c2f583e487458`,
exactly matching the successful automated archive. All 97 extracted files
(381,821 bytes) matched the tracked prototype byte-for-byte, and the prototype
tree remained `5f948fa5b09dc970beab5afef6c21260ecd74edf`.

The fresh stage had neither `.godot` nor
`.godot/global_script_class_cache.cfg`. Direct scene launch reached the Godot
4.7 banner, then emitted 34 `SCRIPT ERROR` headers and 4 failed-script-load
`ERROR` headers for unresolved global classes before gameplay interaction.
Every referenced `class_name` declaration was present at line 1 in the staged
source. Numeric process exit was not durably captured.

The attached transcript was 7,333 bytes / 79 lines / SHA-256
`8528a5b25a66fcc6b8caa8b64f1049c03ee5aca8af42f4df5fb580ff182e9f47`.
The durable attempt summary is
[`manual-attempt-001.json`](../evidence/fast-slice/fs-a-integrated-validation/manual-attempt-001.json).

Classification: `Blocked before candidate evaluation / QA preparation defect`.
This is not a candidate Fail or playability finding. Functional KBM,
readability, and user feel were `Not run` at attempt-001 closure; the automated
Technical Pass remained unchanged. Attempt-002 below supersedes only the manual
result and recommendation fields.

For retry `manual-20260814-002`, create a new fresh stage from
the exact tested source;
the automated temporary stage was intentionally cleaned up. The following is
the exact launch preparation and integrated scene command. Do not use the
Presentation preview as the manual acceptance scene.

    $Godot = 'C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe'
    $ValidationWorktree = 'C:\tmp\mf-fs-a-val'
    $ManualStageRoot = 'C:\tmp\mf-fs-a-val-manual-20260814-002'
    $ManualArchive = 'C:\tmp\mf-fs-a-val-manual-20260814-002.tar'
    Set-Location -LiteralPath $ValidationWorktree
    git archive --format=tar --output=$ManualArchive 3cdf6dbd9031e3d05fd2a049c851f19409d7b592 -- material-frontier-online/prototype
    New-Item -ItemType Directory -Path $ManualStageRoot
    tar -xf $ManualArchive -C $ManualStageRoot
    $FreshProject = Join-Path $ManualStageRoot 'material-frontier-online\prototype'
    & $Godot --headless --editor --path $FreshProject --quit
    if ($LASTEXITCODE -ne 0) { throw "Godot editor import failed with exit $LASTEXITCODE" }
    $GlobalClassCache = Join-Path $FreshProject '.godot\global_script_class_cache.cfg'
    if (-not (Test-Path -LiteralPath $GlobalClassCache)) { throw 'Godot global class cache was not generated' }
    & $Godot --path $FreshProject --scene res://scenes/fast_slice/fs_a_main.tscn

Controls: WASD move, mouse aim, LMB light, RMB heavy, Space evade, E harvest
and rematch. Record functional result separately from readability and free-text
feel in fs-a-kbm-checklist.md. The manual stage/archive must be cleaned by exact
path only after 00 confirms durable evidence and issues cleanup.

### Manual validation attempt-002 — result recorded 2026-08-15

00 reconstructed the same tested source at
`C:\tmp\mf-fs-a-val-manual-20260814-002`. Its 481,280-byte archive SHA-256 was
`0b533e046564c2748511bf53924b3c96600832e7b5fbad41307c2f583e487458`
and embedded source `3cdf6dbd9031e3d05fd2a049c851f19409d7b592`, matching the
successful automated archive. The extracted tracked payload was 97 files /
381,821 bytes, byte-identical to prototype tree
`5f948fa5b09dc970beab5afef6c21260ecd74edf`.

Before import, `.godot` was absent. The corrected headless editor import was
reported exit 0 by 00 and generated
`.godot/global_script_class_cache.cfg` (4,680 bytes, SHA-256
`5ce6d11c9e76f74bf13940c6d6345f9649e2bfec2c4ca060be47f8ea339a7afa`).
All 24 source `class_name` declarations were present in the cache. The
attempt-002 Godot userdata log contains only the 4.7/OpenGL banner and zero
`SCRIPT ERROR`, `ERROR`, or `WARNING` headers. The GUI launch numeric exit was
not captured; the user reached interaction and later closed the process.

The user reported:

- `移動ができない`.
- Initial observation: `HPが0になっても続く`.
- Later clarification message:
  `0後もボスが攻撃してきました。そもそもこっちの攻撃が敵に届いていないので`.
  The boss clause specifies what continued; the attack-reach clause follows in the same message.

00 inference / determination: because the user observed no attack reaching the
enemy, no `boss_hp` decrease was established; 00 identified the zero display as
the left-side player `INTEGRITY`, not boss HP. The user did not directly identify
the field.

Manual findings and bounded source corroboration:

1. Visible move/aim/evade is `Fail`. FS-A requires existing move/aim/evade
   behavior. The user directly reported movement only: `移動ができない`.
   Aim and evade are source-backed acceptance findings, not separate user
   reports. The authority PlayerActor is `visible = false` in
   `fs_a_gameplay_arena.tscn:21-23`; Presentation draws `_draw_knight_proxy()`
   at fixed `Vector2(430.0, 660.0)` in `fs_a_presentation_shell.gd:372-373`
   and references neither `player_position` nor `player_aim`. This explains the
   user-visible aim/evade failure without proving whether their live authority
   input/action was accepted.
2. Manual combat usability is `Fail`: light/heavy attacks could not visibly
   reach or damage the enemy. No valid manual hit or `boss_hp` decrease was
   established, so exact-once damage and authority action/input acceptance
   remain `Blocked / not established`; they are not falsely classified Fail.
3. Player Integrity-0 defeat/spec compliance is `Fail / candidate` on the
   approved player side. `docs/MASTER_SPEC.md:141` makes Integrity zero a player
   defeat, but the candidate has no positive-to-zero defeat latch. The arena
   continues motion, action request, authority advance, player-hit query, and
   pending enemy-hit resolution without a defeat guard
   (`fs_a_gameplay_arena.gd:80-95`); player action/hit-query guards depend only
   on combat phase and `boss_functional` (`fs_a_gameplay_loop.gd:89-125`), while
   Integrity is only clamped at zero at lines 171-189.
4. The user's separate direct observation is only that boss attack continued
   after the displayed value reached zero. Enemy AI/telegraph/attack/pending-hit
   stop scope is `Blocked / shared-contract — OQ-00-20260815-002`; the
   pending-hit portion is source inference/corroboration, not user testimony.
   Neither is used as an already-approved enemy-side candidate spec-Fail assertion.

The original 17 checklist rows are `4 Fail / 11 Blocked / 2 Not run`; two
supplemental coverage rows are both `Fail`. Functional KBM and user feel are
Fail. Readability remains `Not run / partial`: a displayed zero was observed;
00 determined it was player Integrity. Deformation and the complete readability set were not evaluated.

The historical automated 17 / 17 command result and Contract Section 10
technical 13 / 13 Pass remain unchanged. They are deterministic technical
evidence, not a substitute for this contradictory manual acceptance result.
00's formal classification is `Manual KBM functional Fail / promotion stopped`.
The QA disposition under this validation work order is:

`Fail / candidate — promotion and Gate hold`.

This stops only the frozen candidate/integration commit. No whole-line stop is
invoked. A shared-contract coverage gap was also found: the Fast Slice contract,
validation work order, and prior checklist do not explicitly map the
MASTER_SPEC player-Integrity-zero defeat behavior. QA added a supplemental row
but changed no shared contract. 00 tracks the read-only spatial seam boundary as
`OQ-00-20260815-001` and player-defeat hostile-stop scope as
`OQ-00-20260815-002`, both recommended Option A; these contract-boundary
questions remain separate from the candidate gameplay findings. 00's durable
blocker record is integration commit `f398ffb54ec38eb527688d071d32b268a6a5d100`.

Durable attempt evidence:
[`manual-attempt-002.json`](../evidence/fast-slice/fs-a-integrated-validation/manual-attempt-002.json).
The exact attempt-002 stage and archive remain present for 00-owned cleanup and
were not modified or removed by QA.

## Manual and Deferred state

- Manual KBM functional check: Fail
- Manual combat usability: Fail
- Readability: Not run / partial
- User feel: Fail
- Physical gamepad: Deferred / Not run
- Performance, P95, maximum load, and long-run: Deferred / Not run
- Optional normal release export/smoke: Not run
- Slice 2-B Stage B 184: Not run; optional, non-blocking inherited guardrail
- Real A/B/C matrix: Not run and out of scope
- Promotion and Gate action: hold; not authorized

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
- Shared-contract coverage gap detected: yes. The FAST_SLICE_CONTRACT, validation
  work order, and prior checklist did not explicitly map MASTER_SPEC player
  Integrity-0 defeat semantics. 00 owns `OQ-00-20260815-001` and
  `OQ-00-20260815-002`; QA modified shared-contract files 0 times and did not
  touch OQ-005 retry binding, OQ-001 event, any new phase/field, or UI.
- Whole-project stop conditions encountered: none.

## Pass, Fail, and blocker conditions

Historical automated Technical Pass requires import/parse/scene launch, the integrated loop,
individual evidence for all 13 items, required regressions, protected-path
delta 0, diff check 0, evidence readback, and exact cleanup. Those technical
conditions remain met and the automated evidence is unchanged.

A reproducible frozen-candidate parse/assertion/functional defect would be
Fail / candidate and stop only that candidate. A QA runner/launcher/host
condition preventing evaluation would be Blocked / QA infrastructure and would
not be attributed to the candidate. Whole-line stop remains limited to the
three conditions in the Fast Slice contract; none occurred.

Manual attempt-002 reached candidate evaluation and established user-reported
movement failure, source-backed user-visible aim/evade failure, unusable
presented combat reach, and the absence of a player-defeat latch/player-function
stop. The candidate therefore fails manual functional/spec acceptance even
though the technical automation passed. The direct observation that boss attack
continued after the displayed value reached zero is retained. Separately, 00
determined that displayed value was player Integrity. Enemy hostile-stop scope
is `Blocked / shared-contract — OQ-00-20260815-002`; it is not conflated with the
approved player-side candidate finding. The attack-authority/input-acceptance
subquestion also remains Blocked and is not overstated.

00 formal classification: `Manual KBM functional Fail / promotion stopped`.
QA disposition: `Fail / candidate — historical automated Technical Pass
retained; promotion and Gate hold`.

The shared-contract coverage gap requires 00 follow-up but does not authorize
QA to edit the contract or stop unrelated worktrees.

## Durable evidence

- [Structured automated results](../evidence/fast-slice/fs-a-integrated-validation/automated-results.json)
- [Manual preparation attempt-001](../evidence/fast-slice/fs-a-integrated-validation/manual-attempt-001.json)
- [Manual validation attempt-002](../evidence/fast-slice/fs-a-integrated-validation/manual-attempt-002.json)
- [Preparation and cleanup](../evidence/fast-slice/fs-a-integrated-validation/preparation-cleanup.json)
- [Source hashes](../evidence/fast-slice/fs-a-integrated-validation/source-hashes.json)
- [Execution artifact manifest](../evidence/fast-slice/fs-a-integrated-validation/raw-logs-manifest.json)
- [Log normalization record](../evidence/fast-slice/fs-a-integrated-validation/log-normalization.json)
- [Evidence-level manifest](../evidence/fast-slice/fs-a-integrated-validation/evidence-manifest.json)
- [Execution logs and exact commands](../evidence/fast-slice/fs-a-integrated-validation/logs/)
- [KBM checklist](fs-a-kbm-checklist.md)

The historical QA-prep record remains unchanged at 0 Pass / 0 Fail /
11 Pending or Not run. It is separate from this integrated validation and from
the earlier integration technical smoke.
