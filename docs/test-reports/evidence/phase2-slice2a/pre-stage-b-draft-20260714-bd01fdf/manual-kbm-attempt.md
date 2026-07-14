# QA interactive KBM attempt

- Date: 2026-07-14 (Asia/Tokyo)
- Build: `MFO-Phase1.exe`
- Build SHA-256: `8523b59dbfc063b3f51e8c5b364c056bb997a7320f420a4ae55ea6e33e4c8946`
- Classification: QA interactive functional observation; not user feel and not physical-gamepad evidence

## Observed

- The release window opened and rendered the arena, player, target, HUD, and guardrail trace.
- A keyboard `D` tap changed HUD player X from `620.0` to approximately `624.7`; ordinary KBM movement was therefore
  observed at least once.
- A mouse click on the arena emitted the existing provisional attack request／resolution trace. This was not treated as
  sufficient evidence for the independent mouse-aim or evade requirements.

## Limitation and disposition

After the first state capture, Windows Graphics Capture returned the GL Compatibility surface as transparent／partially
transparent and exposed the unrelated underlying window instead of a reliable game frame. No screenshot containing the
underlying window was written into repository evidence. Per the Windows-control verification rule, input was stopped and
the test build was closed.

The following remain **Not run** on this implementation build: mouse-aim direction observation, Space evade,
move-direction／aim-fallback comparison, repeated-input rejection, and boundary behavior. This partial attempt is not a
manual KBM Pass. A human-operated rerun should use the bounded correction build, so the current failing build is not sent
to the user for feel evaluation.

Physical gamepad remains **Not run / Deferred**. Mapping automation is recorded separately.
