# FS-A QA Preparation — MFO-WO-FS-A-30-001

## Scope

This is a branch-local QA preparation package for `prototype/fast-vertical-slice`. It does not validate a gameplay or presentation candidate, does not establish a Gate result, and does not change Fast Slice values or implementation.

## Requirement-to-test matrix

| Contract requirement | Planned evidence | Current status |
| --- | --- | --- |
| Dedicated arena imports, parses, and launches | Candidate scene import plus headless launch | Not run — no integrated candidate |
| Existing move, aim, and evade remain usable | KBM checklist and short play session | Not run — user/playtester only |
| Knight / Iron is the one player configuration | Public snapshot fixture and candidate data readback | Not run — candidate dependency |
| Light and heavy are distinct inputs and timings | Input trace / authoritative action snapshot | Not run — candidate dependency |
| Two enemy telegraphs are readable without color alone | `telegraph_line` / `telegraph_sector` snapshot and visual checklist | Not run — candidate dependency |
| Integrity and Deformation change and reset | Public snapshot before/after action and rematch trace | Not run — candidate dependency |
| One required part can break | Public `parts` trace with `broken=true` | Not run — candidate dependency |
| Boss HP reaches zero exactly once | Ordered loop trace / state transition evidence | Not run — candidate dependency |
| Defeat stops AI, attacks, and hit queries | Post-defeat snapshot / event trace | Not run — candidate dependency |
| Wreck is generated exactly once | Wreck transition trace | Not run — candidate dependency |
| Three harvest points, each collectable once | Harvest snapshot trace and duplicate-attempt observation | Not run — candidate dependency |
| All harvest completes result | Ordered `combat -> wreck -> result` trace | Skeleton fixture Pass; candidate evidence Not run |
| Rematch initializes a second loop | Reset snapshot plus second-loop input trace | Skeleton fixture Pass; candidate evidence Not run |
| Presentation disabled leaves gameplay result unchanged | Integration A/B snapshot comparison | Not run — integration candidate |

## Additive runner

`material-frontier-online/prototype/tests/fast_slice/run_fs_a_contract_skeleton.gd` is intentionally small and depends only on the public Fast Slice snapshot/loop seam. Its candidate-independent fixture confirms that the test entry point can validate:

- required public snapshot fields;
- the one-loop phase trace `combat -> wreck -> result`; and
- a rematch reset snapshot.

It is a preparation seam, not a count-based acceptance harness. Candidate assertions will be added only under a separate validation order after integration is frozen.

## Result template for later validation

```text
Candidate / integration commit:
Contract version / commit:
Environment: Godot version, OS, renderer
Automated command and exit code:
Automated result: Pass / Fail / Blocked / Not run
Manual KBM result: Pass / Fail / Blocked / Not run
User/playtester feel: recorded only after an actual play session
Evidence paths and SHA-256:
Scope audit:
Candidate finding or QA-infrastructure finding:
Recommendation: Pass / Fail / Blocked (no Gate action)
```

## Preparation execution

- Runner fixture command: `Godot_v4.7-stable_win64_console.exe --headless --path material-frontier-online/prototype --script res://tests/fast_slice/run_fs_a_contract_skeleton.gd`
- Result: exit `0`, `[MFO-FS-A-QA-PREP] PASS: contract seam skeleton fixture`
- Headless editor import: exit `0`
- Candidate gameplay/presentation/integration validation: Not run
- KBM/user feel/performance/P95/maximum load: Not run / out of scope

## Boundary

No candidate implementation, data, shared contract, strict-line evidence, Gate status, or integration scene was modified. FS-A QA failures or infrastructure defects remain branch-local under the Fast Slice contract.

## MFO-WO-FS-A-30-001A evidence correction

**Result: Pass / QA preparation only.** This result establishes only the QA-owned preparation package; it is not candidate validation, integrated validation, a playability finding, or a Gate decision.

### Tested identity and environment

- Contract issuance / tested baseline: `62f4af4a105b45f458beabecd6595ad5f58ec764`
- QA-prep content commit: `9531e3d45512a326d2a020e720f35dede3915094`
- Original QA handoff tip audited for scope: `df18568e5288b7ef051800d26f12012d7980fc81`
- Godot console: `4.7.stable.official.5b4e0cb0f`
- OS: Microsoft Windows 11 Home `10.0.26200` (64-bit)
- Renderer: GL Compatibility project target; both preparation commands were headless and did not assess display rendering.

### Commands, expected results, and observed results

| Command | Expected | Observed |
| --- | --- | --- |
| `C:\\Users\\osato\\OneDrive\\ドキュメント\\MF\\material-frontier-online\\.tools\\godot-4.7-stable\\editor\\Godot_v4.7-stable_win64_console.exe --headless --path material-frontier-online\\prototype --script res://tests/fast_slice/run_fs_a_contract_skeleton.gd` | exit `0`; candidate-independent snapshot/loop/rematch fixture completes | exit `0`; `[MFO-FS-A-QA-PREP] PASS: contract seam skeleton fixture` |
| `C:\\Users\\osato\\OneDrive\\ドキュメント\\MF\\material-frontier-online\\.tools\\godot-4.7-stable\\editor\\Godot_v4.7-stable_win64_console.exe --headless --editor --path material-frontier-online\\prototype --quit` | exit `0`; runner source imports/parses | exit `0` |
| `git diff --check` | exit `0` | exit `0` |

Evidence: `docs/test-reports/evidence/fast-slice/fs-a-qa-preparation/preparation-evidence.json` and `scope-audit.json`.

The `telegraph_line` and `telegraph_sector` names used by the positive local fixture are examples for this preparation seam only. They do **not** freeze future candidate acceptance to those exact identifiers or shapes; future integrated validation follows the then-frozen FS-A candidate and contract.