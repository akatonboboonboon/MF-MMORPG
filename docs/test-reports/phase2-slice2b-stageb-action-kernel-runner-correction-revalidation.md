# MFO-WO-P2-2B-009 — Stage B runner-correction revalidation

- QA start / supervisor HEAD: `359178daf2fb1ebe25d77f013257827a29f5e147`
- Predecessor QA tip: `9c8f58ef29eaa6090f748b1872d47186b043370f`
- Candidate: `30b090481a9fffd123d5b16537886e5011fd7e51`
- Gameplay handoff: `bbed2fd98bf0435e456f9ad2bd7dba2b7a7cb0c6`
- Environment: Godot `4.7.stable.official.5b4e0cb0f`, console `198152` bytes, SHA-256 `D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`.

## Exact permitted correction

The predecessor runner and UID matched the required SHA-256 values before writing. Exactly one runner line changed:

```diff
-_check(runtime is RefCounted and not (runtime is Node), "runtime is an isolated RefCounted object")
+_check(runtime is RefCounted, "runtime is an isolated RefCounted object")
```

The predecessor runner SHA-256 was `08af5c6c834561a5b54c08dcaa0a585da2a9d2ea25f877112ebdddcdd4941e59`. The corrected runner SHA-256 is `b55c7c6942767389f27bee67aa7fe0f9a43e3d515741307e17aacb86ad658148`; the tracked UID remained byte-identical, SHA-256 `7615a8f1d1edf4d59e5a4eb25996acd008a05a53921e4f293ea5765da4d67096`.

Parser-only ran once with exit `0`, empty stderr, and no parse error. The corrected runner and unchanged UID were copied to the new evidence root before formal execution.

## Formal sequence

| Order | Result |
|---|---|
| Engine version | exit `0` |
| Headless import / parse | exit `0` |
| Corrected Stage B runner | exit `0`; `108 assertions`, zero failed |
| Stage A runner | exit `0`; `71 / 71` |
| Phase 1 runner | exit `0`; `36 / 36` |
| Slice 2-A runner | exit `0`; `120 / 120` |
| Slice 2-A correction runner | exit `0`; `39 / 39` |
| Main-scene headless smoke | exit `0`; `DefinitionsValidated ok=true`, RHL `violation_count: 0` |
| Scope / candidate / UID audit | `git diff --check` exit `0`; 14 candidate implementation paths; post-handoff gameplay/data diff `0` |

Evidence manifest contains `32` payloads; every payload resolved and hash-read back exactly. Manifest SHA-256: `609a8dead1d6e87ce6e4d3f8daa212daebf45dd7266aa60172c6d25efb885989`.

## Acceptance gap and stop boundary

The corrected runner executed successfully, but its frozen coverage is incomplete for Section 4.3: it does not invoke a callback returning the accepted `rejected` status, and it does not demonstrate lease release for the required invalidated-callback case. Those omissions prevent a complete acceptance claim. They are QA-runner/evidence defects, not direct evidence against candidate gameplay code or approved data.

The runner was frozen before formal candidate behavior and cannot be edited after this observation. No repair, retry, candidate change, export, integration, performance, PREACK, real A/B/C, gamepad, or Gate 2 action was started.

## Recommendation

**Blocked / validation infrastructure or evidence incomplete**

Raw commands, same-invocation numeric exits, streams, correction diff, frozen copies, and audit output are in [stageb-kernel-002](evidence/phase2-slice2b/stageb-kernel-002/).
