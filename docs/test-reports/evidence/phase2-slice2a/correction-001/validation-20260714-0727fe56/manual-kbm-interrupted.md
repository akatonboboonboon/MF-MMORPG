# Corrected-release KBM functional attempt

- Build: `material-frontier-online/prototype/build/windows/MFO-Phase1.exe`
- SHA-256: `28543cb1e45f1e4dd380654200e9336b9e95d8a6e699b4cc5ce0bae26ababb39`
- Mode: normal release launch; no performance flags
- Initial visual state: HUD player position `(620.0, 540.0)`, aim line visible
- Final disposition: **Blocked / Not completed**

## Observation

QA attempted a batch of `D` key inputs. The copied raw log records movement starting at `(624.6667, 540.0)` and
stopping at `(1273.333, 540.0)`, then a second short interval ending at `(1310.666, 540.0)`. This is partial evidence
that rightward keyboard movement reached the corrected release.

During that batch, the Windows control layer reported `user input was detected in this window`. A required fresh
window observation then failed with `foreground window did not report a process id`. QA stopped all further input.
The session also contains 116 attack requests and 111 hits from interleaved input; because the input source cannot be
cleanly attributed after interruption, those events are not accepted as QA mouse／attack evidence.

| Checklist item | Result | Reason |
|---|---|---|
| D movement | Partial observation | X increased while Y stayed `540.0`; session later interrupted |
| W／A／S movement | Not completed | input stopped after interruption |
| Independent mouse aim | Not completed | interleaved input cannot be attributed |
| Space evade | Not completed | input stopped after interruption |
| move-direction priority | Automation Pass only | manual checklist not completed |
| neutral／aim fallback | Automation Pass only | manual checklist not completed |
| boundary non-crossing | Automation Pass only | manual checklist not completed |
| repeated-input rejection | Automation Pass only | manual checklist not completed |

- User feel: **Not run**. No user evaluation of the corrected release was supplied.
- Physical gamepad: **Not run / Deferred**.
