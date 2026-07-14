# Stage B manual evidence disposition

- QA start HEAD: `92f71d7c3e55108a2faecaa6fbf1e1055b0d0b9f`
- Implementation source: `bd01fdf3d048accaa7f5be93afe3be5cfa138201`
- Release build SHA-256: `0f4533d6ac4246844f9e0097e8f46e91abaa519164ccc957c7d23d62024cb640`

| Evidence class | Result | Reason |
|---|---|---|
| Deterministic automation | Fail | `119 / 120 Pass`; one reproducible nonzero-move priority defect |
| QA interactive KBM functionality | Not run | The candidate already requires a bounded correction; the previous pre-Stage-B Windows capture attempt was not reused |
| User feel | Not run | The user was not asked to evaluate a build already returned for correction |
| Physical gamepad | Not run / Deferred | Approved deferral remains; mapping automation is not hardware evidence |

The formal report does not infer KBM function, user feel, or gamepad behavior from deterministic command injection.
After the bounded fix, QA should repeat the release-build KBM checklist at 1920×1080 standard quality: WASD, mouse aim,
Space move-direction evade, neutral／aim fallback, boundary shortening, and repeated-input rejection. Physical gamepad
remains deferred until the established Gate Playability condition.
