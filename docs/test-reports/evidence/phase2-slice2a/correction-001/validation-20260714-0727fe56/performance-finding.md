# MFO-P2-2A-QA-002 — arena-idle frame-time regression

- Classification: confirmed acceptance failure; causality not isolated
- Scope: Slice 2-A arena-idle regression only
- Threshold: frame P95 `<= 16.67 ms`
- Power: AC Online, charging, Best performance `ded574b5-45a0-4f42-8737-46345c09c238` before and after
- Release SHA-256: `28543cb1e45f1e4dd380654200e9336b9e95d8a6e699b4cc5ce0bae26ababb39`

| Run | Warmup / samples | Average | P50 | P95 | P99 | Maximum | FPS from average | Result |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| Fresh run 1 | 120 / 600 | 20.9436 ms | 16.6667 ms | 33.4643 ms | 100.0000 ms | 147.1060 ms | 47.7472 | Fail |
| Fresh confirmation 2 | 120 / 600 | 17.3041 ms | 16.6667 ms | 20.0000 ms | 30.8941 ms | 66.5020 ms | 57.7898 | Fail |

The invalid confirmation attempt that returned exit `-1` is not included. Both accepted captures show HUD P95 equal
to the JSON value rounded to two decimals. GPU timing is unavailable. `static_memory_bytes = 0` is treated as
unavailable, not as a memory Pass.

The two correction conditions are in evade request handling and do not establish causality for an idle regression.
No gameplay value or specification adjustment is recommended from this evidence.

Suggested bounded next paths for `00統括`:

- A: back-to-back Gate 1 baseline EXE and correction EXE runs under the same current desktop load;
- B: collect OS process／GPU load alongside the existing 600-frame recorder to identify background contention;
- C: rerun the correction EXE in a controlled desktop session, preserving all failed evidence.
