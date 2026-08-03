# MFO-WO-P2-2B-013 fixed runner matrix

This matrix is an immutable supervisor input for `MFO-WO-P2-2B-013`. It does not change candidate code, Approved
data, or acceptance values.

## Identity

- Runner canonical UTF-8 LF SHA-256: `f48266b43a3f3b572d2a5747807efa8bc4bbc6150e3481473d8b9d0272c3ba22`
- Runner Git blob: `8d7d611dc3e1d3b54291ad0d23c8ae791ebdd724`
- UID canonical UTF-8 LF SHA-256: `7615a8f1d1edf4d59e5a4eb25996acd008a05a53921e4f293ea5765da4d67096`
- UID Git blob: `d11222d7ba3410864d00cee52fdc124506d8cc61`

## Cardinality ledger

| Source class | Static call sites | Runtime reach | Assertion executions |
|---|---:|---:|---:|
| One-shot `_check` sites | 148 | 1 | 148 |
| `_pool()` local `_check` site | 1 | 15 | 15 |
| `_configured_runtime()` local `_check` site | 1 | 9 | 9 |
| Effect-loop `_check` sites | 3 | 4 | 12 |
| Total executable `_check` sites | 153 | 窶・| 184 |

- `_check` helper declarations: `1`
- projected terminal assertion executions: `184`
- expanded description count: `162`
- existing test order, labels, loop topology, helper graph, and description templates: unchanged from seed Git blob
  `b2ffda205cf7430b98b107638925d88a47add609`

The terminal count is not equal to the static call-site count because `_pool()` is reached 15 times,
`_configured_runtime()` is reached 9 times, and three effect-loop checks execute once for each of four effects.

## Requirement coverage

| Requirement | Fixed observation boundary |
|---|---|
| Empty/unknown/zero/nonfinite rejection | Independent return, state, result, request, lease, effects, movement, and counter snapshots |
| Busy/unavailable rejection | Existing accepted action/lease preserved; no queue, second lease, or callback request |
| Quick request | Identity/sequence/aim, read-only `150/88/0.25/max1` geometry, ordered `10/6` effects and full metadata |
| Heavy request | Identity/sequence/locked aim, `48 px` intent, read-only `150/88/0.25/max1` geometry, ordered `14/18` effects and full metadata |
| Hit/miss/rejected/malformed/invalidated | Exact status, query `1`, release success, active/emergency `0`, pending lease false before cleanup |
| Reset/clear before active | Callback `0`, release, final idle, active/emergency `0` |
| Phase cardinality | Request/query exact `1` through active/recovery; callback ledger remains `1` after final idle |
| Registry validation | Empty action and empty effect registries evaluated independently |
| Safe diagnostics | Every indexed request/geometry/effect/state/result access has left-hand key/type/size guards |

At final idle the runtime debug-state query count is correctly `0`; the external callback request ledger, not the
cleared runtime field, proves the single callback request remained exact `1`.
