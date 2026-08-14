# FS-A KBM Play Checklist

Use only after a FS-A integration candidate is explicitly issued for validation. Record `Pass`, `Fail`, `Blocked`, or `Not run` per line; do not infer player feel from automation.

| Check | Result | Evidence / note |
| --- | --- | --- |
| Arena starts and focus remains usable | Not run | |
| Keyboard move directions remain responsive | Not run | |
| Mouse aim remains responsive while moving | Not run | |
| Evade is usable and remains legible | Not run | |
| Light and heavy use distinct inputs and timings | Not run | |
| One light or heavy attack does not damage the same target twice | Not run | Technical trace is also required; do not infer exact-once only from visuals |
| Enemy durability decreases after a valid hit | Not run | Observe the canonical contract field `boss_hp`; do not add or assume an enemy Integrity alias/equivalence |
| `telegraph_line` is recognizable without color alone | Not run | |
| `telegraph_sector` is recognizable without color alone | Not run | |
| Integrity and Deformation changes are readable | Not run | |
| One part break is recognizable | Not run | |
| Boss defeat stops hostile behavior | Not run | |
| Wreck appears once and three harvest points are usable once each | Not run | |
| A second collection attempt on the same point grants nothing | Not run | Technical state evidence is also required |
| Result appears only after the third collection | Not run | |
| Rematch restores a playable second loop | Not run | |
| Overall player feel (free text, actual user/playtester only) | Not run | |

Gamepad, performance/P95, maximum load, and strict Gate evidence are outside this checklist.

## MFO-WO-FS-A-30-002 manual session

- Automated technical validation: 13 / 13 Pass.
- This does not change any manual row above; all remain Not run.
- Tested source: 3cdf6dbd9031e3d05fd2a049c851f19409d7b592.
- Tested prototype tree: 5f948fa5b09dc970beab5afef6c21260ecd74edf.
- Required scene: res://scenes/fast_slice/fs_a_main.tscn.
- Presentation preview is not an integrated manual acceptance scene.
- Controls: WASD / mouse / LMB / RMB / Space / E.

Create a new fresh stage and launch the required scene with:

    $Godot = 'C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe'
    $ValidationWorktree = 'C:\tmp\mf-fs-a-val'
    $ManualStageRoot = 'C:\tmp\mf-fs-a-val-manual-20260814-001'
    $ManualArchive = 'C:\tmp\mf-fs-a-val-manual-20260814-001.tar'
    if (Test-Path -LiteralPath $ManualStageRoot) { throw 'Manual stage already exists' }
    if (Test-Path -LiteralPath $ManualArchive) { throw 'Manual archive already exists' }
    Set-Location -LiteralPath $ValidationWorktree
    git archive --format=tar --output=$ManualArchive 3cdf6dbd9031e3d05fd2a049c851f19409d7b592 -- material-frontier-online/prototype
    New-Item -ItemType Directory -Path $ManualStageRoot
    tar -xf $ManualArchive -C $ManualStageRoot
    $FreshProject = Join-Path $ManualStageRoot 'material-frontier-online\prototype'
    & $Godot --path $FreshProject --scene res://scenes/fast_slice/fs_a_main.tscn

Record three independent outcomes:

1. Functional KBM behavior for every applicable row.
2. Readability/legibility observations for telegraphs, state, part break,
   defeat, wreck, harvest, and result.
3. Free-text user/playtester feel.

Do not infer any of these from headless automation. After the session, preserve
the observations and remove only the exact manual stage/archive paths after
