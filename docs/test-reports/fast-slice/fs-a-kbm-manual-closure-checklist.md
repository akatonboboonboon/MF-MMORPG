# FS-A KBM Manual Closure Checklist

- Work order: `MFO-WO-FS-A-30-004`
- Branch / worktree: `codex/fast-slice-fs-a-manual-closure` / `C:\tmp\mf-fs-a-manual-closure`
- Issuance / candidate / accepted: `a64f9f0e4f536cd96bd331b87cc7c720d44e31fa` / `f03a43d2339e9772a15db1c591a31f5e4f92cca2` / `ca15f57e6c3c23658d602cfa93212e8e91de2064`
- Prototype tree: `2a66e4c06308a47678e8888a739b87ffd33d1ee8`
- Real `fs_a_main.tscn`; preview/accepted automation not run.

## Result

Rows `3–20`: `10 Pass / 0 Fail / 0 Blocked / 8 Not run`. Combined 21: `13 Pass / 0 Fail / 0 Blocked / 8 Not run`.

| Row | Requirement | Result | Direct basis / limitation |
|---:|---|---|---|
| 3 | Aim cue follows while stationary and moving | Pass | Exact `はい。` bound to both aim-tracking clauses. |
| 4 | Space evade accepted with distinct visible position change | Pass | Exact `はい` bound to acceptance and visible displacement. |
| 5 | LMB/RMB separate inputs and timing | Pass | RMB directly reported slower than LMB after both were exercised. |
| 6 | No-teleport WASD approach, visible reach and damage | Pass | Exact `確認済みです。` bound to all clauses. |
| 7 | One isolated attack produces exact-one same-target decrement | Pass | Functional `確認済みです。`; separate reset concern does not alter result. |
| 8 | Named BOSS HP decreases after a valid hit | Pass | INTEGRITY 64/100; BOSS HP 180/180 to 174/180; hit cue and decrease confirmed. |
| 9 | Line geometry/non-color cue and evade | Pass | 20/100; thin-long shape; `形で見分けました`; evade; post20/100. |
| 10 | Sector geometry/non-color cue and evade | Pass | 20/100; fan shape; evade; post20/100. |
| 11 | Named INTEGRITY and DEFORMATION changes readable | Not run | Exact `覚えてないですね…`; composite not established. |
| 12 | After player zero, individual player inputs and updates stop | Not run | Partial visible stop only; individual WASD/Space/LMB/RMB composite not performed. |
| 13 | Enemy stop beyond a prior cycle and boss-side invariants | Not run | Partial state evidence; beyond-cycle confirmation incomplete. |
| 14 | Part break recognizable by position/bar/X/text | Pass | 20/100; `Part 01 Intact`; prompt-bound bar/X/text/position and exact-one cue. |
| 15 | Boss zero stops hostile behavior beyond prior cycle | Pass | All seven prompt clauses affirmed; post INTEGRITY20/100. |
| 16 | Wreck exact one and exact-three spatially consistent markers | Not run | Partial number identification only; positive precondition lost before clauses1-5. |
| 17 | Harvest each once and reject duplicate | Not run | Authorized positive-Integrity retry exhausted. |
| 18 | Result only after third collection | Not run | Authorized positive-Integrity retry exhausted. |
| 19 | Complete rematch reset and round-two major actions | Not run | Authorized positive-Integrity retry exhausted. |
| 20 | Color-independent target/HUD/telegraph/part/harvest/result readability | Not run | Authorized positive-Integrity retry exhausted. |

Partial observations, automation, source inspection, and exit codes did not upgrade composite rows.

## Current feel and disposition

> ないです。ないですが、開始時点で即攻撃受けるのはどうにかしてほしいです。開始位置を変えるのが一番かと

Current playability finding only; no functional row Fail, candidate defect, approved repair, or contract change. Earlier player-zero reset concern remains under excluded OQ-005.

- `Technical Pass / promotion pending manual KBM and/or user feel`; promotion stopped.
- Candidate defects `0`; shared-contract change `No`.
- Gamepad/performance: `Not run / Deferred`; export: `Not run`.
- Evidence: [`../evidence/fast-slice/fs-a-manual-closure/`](../evidence/fast-slice/fs-a-manual-closure/).
