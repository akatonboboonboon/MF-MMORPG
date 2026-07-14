# Corrected C KBM session — interrupted

- Work order: `MFO-WO-P2-2A-003`
- Build: C / `5261a73707daca03cb160e03a12247886d3f5cce`
- EXE SHA-256: `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47`
- Normal-launch start: `2026-07-14T12:35:55.389Z`
- Process stopped by QA after interruption: PID `34004`
- Window: `Material Frontier Online - Phase 1`
- Initial observation: HUD player position `(620.0, 540.0)`; actor aim line was visible and pointed down-right.

## Interruption

The first attempted `W` input at `2026-07-14T13:28:49.397Z` was rejected by the Windows automation safety layer with
`user input was detected in this window`. QA sent no further game input. A passive follow-up snapshot at
`2026-07-14T13:29:09.410Z` captured a different foreground application instead of the game, confirming focus/input
contamination. That snapshot contained private third-party conversation content and is intentionally not copied into
the repository; only the app/window-switch fact is recorded here.

The fresh Godot session log contains `9` `MovementApplied` events and `8` `AttackRequested` events. QA did not click
inside the game viewport and did not issue an Attack A input. Therefore the session was already contaminated before
the checklist could be completed. The copied raw log is `kbm-interrupted-godot.log`, SHA-256
`07fa61a93c1e9e9a65663c3cbd9020bd41190fe1f22182512149552d9403f4d6`.

## Checklist disposition

| Item | Result |
|---|---|
| W / A / S / D movement | `Blocked`; first W action interrupted, remaining directions not run |
| Independent mouse aim | `Blocked`; initial aim line observed, controlled mouse sequence not run |
| Space ground-step evade | `Blocked / Not run` |
| Movement-direction priority | `Blocked / Not run` |
| Neutral aim fallback | `Blocked / Not run` |
| Arena boundary non-crossing | `Blocked / Not run` |
| Active / reuse rejection | `Blocked / Not run` |
| Rejected request not buffered | `Blocked / Not run` |

The partial session is not combined with automation or earlier KBM attempts. No gameplay defect is claimed. User feel
is `Not run` because the user did not perform a directed evaluation for this work order. Physical gamepad remains
`Not run / Deferred`.
