# FS-A KBM Play Checklist

Use only after a FS-A integration candidate is explicitly issued for validation. Record `Pass`, `Fail`, `Blocked`, or `Not run` per line; do not infer player feel from automation.

| Check | Result | Evidence / note |
| --- | --- | --- |
| Arena starts and focus remains usable | Blocked | Integrated arena started, but usable focus was not independently established while visible input feedback failed |
| Keyboard move directions remain responsive | Fail | User observation: `移動ができない`; no visible movement response in the integrated scene |
| Mouse aim remains responsive while moving | Fail | Source-backed acceptance finding: the fixed Presentation proxy consumes neither `player_aim` nor `player_position`, so aim response is not user-visible. The user did not separately report aim behavior |
| Evade is usable and remains legible | Fail | Source-backed acceptance finding: the fixed Presentation proxy does not consume `player_position`, so evade movement is not user-visible. The user did not separately report evade behavior or authority acceptance |
| Light and heavy use distinct inputs and timings | Blocked | Attacks were not manually usable against the enemy; live authority input/action acceptance remains unestablished |
| One light or heavy attack does not damage the same target twice | Blocked | No confirmed valid manual hit; technical trace remains historical Pass evidence only |
| Enemy durability decreases after a valid hit | Blocked | No confirmed valid manual hit and `boss_hp` was not reduced; no enemy Integrity alias/equivalence is assumed |
| `telegraph_line` is recognizable without color alone | Not run | |
| `telegraph_sector` is recognizable without color alone | Not run | |
| Integrity and Deformation changes are readable | Blocked | Player Integrity reaching 0 was observed, but the combined readability/Deformation check was not completed |
| One part break is recognizable | Blocked | Progression was unreachable after manual combat usability failed |
| Boss defeat stops hostile behavior | Blocked | Boss defeat was not reached; player Integrity 0 is recorded separately below |
| Wreck appears once and three harvest points are usable once each | Blocked | Downstream state was unreachable |
| A second collection attempt on the same point grants nothing | Blocked | Downstream state was unreachable; technical state evidence remains separate |
| Result appears only after the third collection | Blocked | Downstream state was unreachable |
| Rematch restores a playable second loop | Blocked | Downstream state was unreachable |
| Overall player feel (free text, actual user/playtester only) | Fail | User reported no visible movement, attacks not reaching the enemy, and boss attacks continuing after the displayed value reached zero; 00 separately determined that value was player Integrity |
| Light and heavy attacks can visibly reach and damage the arena enemy | Fail | User observation: `そもそもこっちの攻撃が敵に届いていないので`; combat usability failed, while authority action/input acceptance remains unestablished |
| At player Integrity 0, the player enters defeat and player move/evade/action/hit-query/pending-action stop until reset/rematch | Fail | Candidate has no defeat latch or player-function stop. Enemy AI/telegraph/attack/pending-hit stop scope is separately `Blocked / shared-contract` under `OQ-00-20260815-002` |

Gamepad, performance/P95, maximum load, and strict Gate evidence are outside this checklist.

## MFO-WO-FS-A-30-002 manual session

- Historical automated technical validation: 13 / 13 Pass; unchanged.
- Manual attempt-002: original 17 rows = 4 Fail / 11 Blocked / 2 Not run;
  two supplemental coverage rows = 2 Fail.
- Tested source: 3cdf6dbd9031e3d05fd2a049c851f19409d7b592.
- Tested prototype tree: 5f948fa5b09dc970beab5afef6c21260ecd74edf.
- Required scene: res://scenes/fast_slice/fs_a_main.tscn.
- Presentation preview is not an integrated manual acceptance scene.
- Controls: WASD / mouse / LMB / RMB / Space / E.

### Manual preparation attempt-001

The exact tested prototype was reconstructed and Godot 4.7 was invoked
directly, but the fresh stage had no `.godot` import/class cache. The launch
emitted 34 `SCRIPT ERROR` headers and 4 failed-script-load headers before any
gameplay interaction; its numeric exit was not durably captured.

Classification: `Blocked before candidate evaluation / QA preparation defect`.
This is not a candidate Fail and does not change the automated 13 / 13
Technical Pass. At attempt-001 closure every manual row was `Not run`;
attempt-002 below supersedes those manual-result fields. See
`docs/test-reports/evidence/fast-slice/fs-a-integrated-validation/manual-attempt-001.json`.

For retry `manual-20260814-002`, create a new unique fresh stage, complete the
editor import/class scan, verify its global class cache, and only then launch
the required scene:

    $Godot = 'C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe'
    $ValidationWorktree = 'C:\tmp\mf-fs-a-val'
    $ManualStageRoot = 'C:\tmp\mf-fs-a-val-manual-20260814-002'
    $ManualArchive = 'C:\tmp\mf-fs-a-val-manual-20260814-002.tar'
    if (Test-Path -LiteralPath $ManualStageRoot) { throw 'Manual stage already exists' }
    if (Test-Path -LiteralPath $ManualArchive) { throw 'Manual archive already exists' }
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

Record three independent outcomes:

1. Functional KBM behavior for every applicable row.
2. Readability/legibility observations for telegraphs, state, part break,
   defeat, wreck, harvest, and result.
3. Free-text user/playtester feel.

Do not infer any of these from headless automation. After the session, preserve
the observations and remove only the exact manual stage/archive paths after 00
confirms durable evidence and issues exact cleanup.

### Manual validation attempt-002 — result recorded 2026-08-15

The required integrated scene was launched from the byte-identical tested
source after the corrected editor import returned reported exit 0 and generated
`.godot/global_script_class_cache.cfg`. The user reached manual interaction and
then closed the GUI. No attempt-001 parse/load errors recurred.

Recorded user observations:

- `移動ができない`.
- `そもそもこっちの攻撃が敵に届いていないので`.
- `0後もボスが攻撃してきました`.

00 inference / determination: because no attack was observed reaching the enemy,
no `boss_hp` decrease was established; 00 identified the zero display as player
`INTEGRITY`, not boss HP. The user did not directly name that field.

Classification:

- Functional KBM: `Fail`.
- Manual combat usability: `Fail`; attacks could not visibly reach/damage the
  enemy. Live authority input/action acceptance remains `Blocked / not
  established` and is not inferred from the visible failure.
- Readability: `Not run / partial`.
- User feel: `Fail`.
- Player Integrity-0 defeat/spec compliance: `Fail / candidate`.
- Enemy hostile-stop scope after player defeat: `Blocked / shared-contract —
  OQ-00-20260815-002`.
- 00 formal classification: `Manual KBM functional Fail / promotion stopped`.
- QA disposition: `Fail / candidate — promotion and Gate hold`.

The historical automated 13 / 13 Technical Pass is unchanged. This result stops
only the frozen candidate/integration commit and does not authorize a whole-line
stop. Durable evidence:
`docs/test-reports/evidence/fast-slice/fs-a-integrated-validation/manual-attempt-002.json`.
