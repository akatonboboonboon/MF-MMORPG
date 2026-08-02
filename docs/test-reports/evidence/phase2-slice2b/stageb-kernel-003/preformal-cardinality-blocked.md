# Pre-formal cardinality closure

- Frozen runner SHA-256: `1a5a22da731c8bd402e734de445ee48d1a0aaab416a986eccb20bd65fcb910e6`
- UID SHA-256: `7615a8f1d1edf4d59e5a4eb25996acd008a05a53921e4f293ea5765da4d67096`
- Parser-only attempts: `2`, both exit `0`.
- Static executable `_check` call sites: `153`.
- `_check` helper declarations: `1`.

The runner calls `_check` inside `_pool()` and `_configured_runtime()`. In the frozen runner, `_pool()` is reached 15 times and `_configured_runtime()` is reached 9 times in one complete run. The static count includes each helper call site once, so the predicted terminal total is `153 - 2 + 15 + 9 = 175`, not `153`.

The work order requires the frozen source call-site count and one formal terminal assertion total to agree exactly. This structural mismatch was found before FORMAL. The runner was already frozen after parser-only Pass; therefore no runner edit or Stage B formal invocation is permitted.
