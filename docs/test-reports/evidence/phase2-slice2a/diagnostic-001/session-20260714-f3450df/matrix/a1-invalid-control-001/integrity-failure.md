# A1 invalid control attempt 001

- Classification: `Invalid / excluded before threshold inspection`
- Slot: `A1`
- Cause: the QA monitor called `GetClientRect` after the game process had exited and its `MainWindowHandle` had become null.
- Result files: no `performance.json` and no `capture.png` were produced; only the Godot log exists.
- Residual process check: no owned `MFO-Phase1` process remained after the controller stopped.
- Retry rule: this consumes the one integrity-based replacement allowed for slot `A1`. The replacement must occur before `B1`, and this directory must remain unchanged.
- Threshold handling: no P95 value existed or was inspected before the replacement decision.
