# MFO-WO-P2-2A-005 Session Notes

## Prepared stage

- Stage ID: `p2-2a-005-20260715t0944jst-b32fdae`
- Preparation manifest SHA-256: `ac2c34644f7d3f2a92d39ebf54f64b1984c14fb330d31ec22b57035381334aa1`
- Stage location: `%LOCALAPPDATA%\Temp\MFO-P2-2A-005\stages\p2-2a-005-20260715t0944jst-b32fdae`
- Stage P dry-run: Pass, exit `0`, sealed slot count `6`, performance slot launch count `0`, timed origin not created.
- Stage P and the independent read-only audit verified all preparation PIDs exited, no MFO／Godot residue, no lock, and no `run/` directory before PREPARED.

## User activation and QA acknowledgement

The user supplied the required activation line:

```text
MFO-WO-P2-2A-005 stage_id=p2-2a-005-20260715t0944jst-b32fdae manifest_sha256=ac2c34644f7d3f2a92d39ebf54f64b1984c14fb330d31ec22b57035381334aa1 ALL ONEDRIVE CLOSED / QUIET WINDOW READY
```

QA then announced measurement start and invoked the sealed command. QA did **not** first preserve the external
`OneDrive*` count-zero prerequisite required by section 4. This is a QA procedural nonconformance. The first preserved
prerequisite evaluation occurred only after controller origin creation and immediately failed. The acceptance window is
therefore not treated as valid or complete.

Exact sealed invocation:

```powershell
"C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-005\stages\p2-2a-005-20260715t0944jst-b32fdae\controller\run-performance-only.ps1" -Mode Run -StagePath "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-005\stages\p2-2a-005-20260715t0944jst-b32fdae"
```

- Codex launcher-wrapper exit code: `1`.
- The controller source sets its terminal error result to `2`, but the child process exit was not captured separately from the launcher wrapper; it is not reported as an observed child exit code.
- Raw launcher stdout／stderr was not redirected to a file. The observed error text was `OneDrive-family process present during settled-60s.` and is preserved independently in `timed/controller-error.json`.

## Terminal integrity failure

- Controller origin: `2026-07-15T10:25:41.8990234+09:00`.
- Controller PID: `6212`; the process exited.
- Error capture: `2026-07-15T01:25:43.3854998Z`, about `1.486 s` after the recorded local origin.
- The 60-second settled interval did not complete; the 15-interval CPU preflight did not start.
- The triggering OneDrive inventory was not persisted before the controller threw. No exact trigger name／PID sample and no final controller-boundary inventory exist.
- A separate post-controller snapshot observed `OneDrive.Sync.Service`, PID `13496`. This is corroborating evidence only and is not substituted for the missing trigger sample.
- `system_wide_tick_count64_origin` is `0`. This is not a usable system-wide monotonic origin and independently invalidates the controller run.
- `run/` contains only `controller-origin.json` and `controller-error.json`. No matrix directory, slot output, P95, capture, settled sample, preflight sample, or session summary exists.
- A1／B1／C1／C2／B2／A2: all Not run. Valid performance runs: `0`.

## Cleanup, integrity, privacy, and routing

- Controller PID `6212` exited; controller lock absent; MFO／Godot residue count `0`.
- Post-controller full hashes for the manifest, controller, and staged A／B／C match the PREPARED identities.
- QA did not kill, reconfigure, sign out, or restart OneDrive. The user was told input could resume after the controller ended.
- OneDrive evidence contains process name and PID only. No OneDrive account identifier, email, CPU, image path, creation time, or command line was collected. Required sealed local filesystem paths are preserved separately.
- No executable, export pack, screenshot, or unrelated file was copied into tracked evidence.
- The activated stage is frozen and will not be repaired, cleared, or reused. QA will not issue or run an automatic retry.
- Recommendation: **Blocked**. Further routing returns to `00統括`.
