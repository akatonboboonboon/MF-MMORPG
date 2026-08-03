# MFO-WO-P2-2B-012 — Slice 2-B Stage B capture-safe terminal revalidation

- Issuer: `00統括（監督）`
- Issued: 2026-08-03 (Asia/Tokyo)
- User authority: explicit resume instruction received 2026-08-03
- Assignee: `30 QA・性能・レビュー`
- Status: **Returned / Blocked during first capture qualification; parser／FORMAL／candidate execution 0**
- Milestone: M2 / Slice 2-B
- Required branch: `codex/phase2-slice2b-stageb-action-kernel-qa`
- Required workspace: dedicated worktree `C:\tmp\q2b-stageb`
- Required starting point: the supervisor commit containing this order, supplied in the direct START notice
- Corrected predecessor QA tip: `0da24b247af18e9f28a2998ceb162b419c9b46fc`
- Frozen candidate implementation: `30b090481a9fffd123d5b16537886e5011fd7e51`
- Frozen candidate handoff: `bbed2fd98bf0435e456f9ad2bd7dba2b7a7cb0c6`
- Resume seed runner SHA-256: `e677cf7f64e6a02cbafee5c086a8b5732d8440fb1756cc0329631437783910d2`
- Frozen runner UID SHA-256: `7615a8f1d1edf4d59e5a4eb25996acd008a05a53921e4f293ea5765da4d67096`
- Integration authority: **None**
- Gate effect: **None — Gate 2 remains Locked**

## 1. Resumption disposition

`MFO-WO-P2-2B-011` is closed as:

`Blocked / validation infrastructure or evidence incomplete`

Its append-only process audit established that the external capture helper launched two argumentless main-scene
chains. The intended parser invocation, FORMAL invocation, and Stage B candidate execution counts were all `0`;
final residual process count was `0`. Candidate implementation and Approved data are not attributed Fail.

The user explicitly authorized resumption after the infrastructure issue is made safe. This order is therefore an
explicit follow-on, not the automatic `-012` prohibited by the closed `-011` boundary. It does not alter approved
values, implementation authority, integration authority, or Gate state.

The resume seed runner must not be executed unchanged. Its existing heavy-request condition expects `reach=180`
and `max_targets=2`, while Approved data and `MASTER_SPEC` require `reach=150`, `query_radius=88`,
`minimum_aim_dot=0.25`, and `max_targets=1`. Unchanged execution would falsely Fail a correct candidate. This order
permits one consolidated QA-runner correction before any child process starts.

Before START, require the corrected QA tip on `origin`, exact ancestry to the supplied supervisor commit, a clean
required worktree, and exact seed runner／UID／candidate／handoff identities. Otherwise HOLD without editing.

## 2. One consolidated runner correction

Start from the exact resume seed. Apply one offline semantic batch. The following are immutable:

- executable `_check` call sites: `153`;
- `_check` helper declarations: `1`;
- assertion descriptions: `162` distinct descriptions, unchanged;
- test-function order, loops, helper call graph, and execution reach counts, unchanged;
- `_pool()` reach count `15`, `_configured_runtime()` reach count `9`, four-effect loop cardinality `4`;
- canonical rejected timing already present in the seed: `0.20 + 0.20`.

Permitted edits are limited to existing `_check` conditions, adjacent local snapshots needed by those conditions,
and key／type／size guards in the existing `_is_final_idle` return expression. Do not add, delete, relocate, or skip
an `_check`; do not add a helper, loop, test case, label, alternate runner, or candidate expectation.

The batch must close all of the following without weakening an accepted assertion:

1. Empty and unknown actions are observed independently. Empty／unknown／zero／non-finite／unavailable rejection
   leaves the applicable accepted sequence／count, query／callback／request count, lease, result, effects, movement,
   and idle state unchanged. Busy rejection preserves the first accepted quick action, one sequence／count, one
   reservation, and zero callback requests without queueing or a second lease.
2. Quick request geometry is exact and read-only: approved hit shape, `150 / 88 / 0.25 / max 1`. Its two ordered
   effect records are exact `10 / 6`, read-only, and each has `physical / 0 / hit_target / instant / empty tags`.
3. Heavy request is read-only and preserves exact action／sequence／locked aim, `48 px` active-only intent, approved
   hit shape, `150 / 88 / 0.25 / max 1`, and two ordered `14 / 18` effect records with the same complete immutable
   metadata. Replace the seed's false `180 / 2` expectation; do not change production data.
4. Hit, miss, canonical rejected, unsupported-result malformed, and invalidated-callback malformed each directly
   observes exact status, query count `1`, successful release, active count `0`, emergency active／use counts `0`,
   and no pending lease before cleanup.
5. Reset-before-active and clear-before-active each observes callback count `0`, released lease, final idle, and
   active／emergency counts `0`.
6. Existing quick and heavy active→recovery→idle labels retain request／query count exactly `1` through every later
   phase and after one further rejected idle advance.
7. Every indexed request／geometry／effect／debug-state／debug-result access is protected by left-hand key, type, and
   size guards so a nonconformance becomes the existing failed label rather than a script error. Both effect records
   and all required debug fields must be checked.
8. Empty action and empty effect registries are evaluated independently. Literal metadata for all four effects and
   the existing source-isolation conditions remain exact.

After the batch, regenerate a bullet-level requirement matrix and actual final-description inventory. Static source
metrics must remain `153 / 1`; projected execution must remain exactly:

```text
148 one-shot checks
15 pool-helper executions
9 configured-runtime-helper executions
12 effect-loop executions (3 descriptions x effects 0..3)
184 assertion executions total
162 distinct descriptions
```

Any topology, label, ledger, scope, Approved-value, or matrix mismatch is Blocked before capture qualification.

## 3. Persisted capture launcher

Create exactly one new launcher at:

`docs/test-reports/evidence/phase2-slice2b/stageb-kernel-005/capture-stageb-terminal.ps1`

It must be 7-bit ASCII, BOM-free, Windows PowerShell 5 parser-clean, and frozen before its first child launch. It
must use one named-parameter capture function with mandatory `[string] $ArgumentString` and one
`System.Diagnostics.ProcessStartInfo` path. Array joining, implicit argument casts, aliases, `Invoke-Expression`, and
`Start-Process` are prohibited. Assign `.Arguments = $ArgumentString`, then require ordinal equality and a nonempty
value before child start. Use `UseShellExecute=false`, redirected stdout and stderr, parallel
`BaseStream.CopyToAsync()` into separate `MemoryStream` instances, bounded `WaitForExit`, and numeric `ExitCode` only
after completion. Write each `MemoryStream.ToArray()` directly with `File.WriteAllBytes`; do not pass empty arrays
through a mandatory PowerShell parameter. Write, before launch, a durable planned record containing the
exact executable, arguments, working directory, mode, launcher SHA-256, and attempt identity. Raw stdout, raw stderr,
numeric exit, byte counts, hashes, PID, start/end time, timeout, and result JSON must be written without overwriting
an existing attempt directory. Result/manifest writes must be atomic.

The approved Godot console path must be decoded inside the ASCII launcher from this UTF-8 Base64 value:

```text
QzpcVXNlcnNcb3NhdG9cT25lRHJpdmVc44OJ44Kt44Ol44Oh44Oz44OIXE1GXG1hdGVyaWFsLWZyb250aWVyLW9ubGluZVwudG9vbHNcZ29kb3QtNC43LXN0YWJsZVxlZGl0b3JcR29kb3RfdjQuNy1zdGFibGVfd2luNjRfY29uc29sZS5leGU=
```

Decoded identity must be size `198152`, SHA-256
`D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`. The fixed working directory is
`C:\tmp\q2b-stageb\material-frontier-online\prototype`.

The launcher may expose only these fixed modes: `QUALIFY_STREAMS`, `QUALIFY_EMPTY`, `QUALIFY_GODOT_VERSION`, `PARSER`,
and `FORMAL`. Each mode maps internally to its fixed child executable and argument string; child arguments may not
be supplied or rebuilt by an outer helper. No second launcher or alternate capture path is permitted.

## 4. Capture qualification and parser

After launcher freeze, run the following modes in fixed order, each exactly once. At the first non-pass, stop;
launcher repair, retry, alternate, later mode, and candidate execution are prohibited.

1. `QUALIFY_STREAMS`: launch
   `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe` with exact arguments
   `-NoLogo -NoProfile -NonInteractive -EncodedCommand JABvAD0AWwBUAGUAeAB0AC4ARQBuAGMAbwBkAGkAbgBnAF0AOgA6AEEAUwBDAEkASQAuAEcAZQB0AEIAeQB0AGUAcwAoACcATQBGAE8AXwBDAEEAUABUAFUAUgBFAF8AUwBUAEQATwBVAFQAXwBWADEAJwApADsAWwBDAG8AbgBzAG8AbABlAF0AOgA6AE8AcABlAG4AUwB0AGEAbgBkAGEAcgBkAE8AdQB0AHAAdQB0ACgAKQAuAFcAcgBpAHQAZQAoACQAbwAsADAALAAkAG8ALgBMAGUAbgBnAHQAaAApADsAJABlAD0AWwBUAGUAeAB0AC4ARQBuAGMAbwBkAGkAbgBnAF0AOgA6AEEAUwBDAEkASQAuAEcAZQB0AEIAeQB0AGUAcwAoACcATQBGAE8AXwBDAEEAUABUAFUAUgBFAF8AUwBUAEQARQBSAFIAXwBWADEAJwApADsAWwBDAG8AbgBzAG8AbABlAF0AOgA6AE8AcABlAG4AUwB0AGEAbgBkAGEAcgBkAEUAcgByAG8AcgAoACkALgBXAHIAaQB0AGUAKAAkAGUALAAwACwAJABlAC4ATABlAG4AZwB0AGgAKQA7AGUAeABpAHQAIAAyADMA`.
   Require numeric exit `23`; stdout exact ASCII `MFO_CAPTURE_STDOUT_V1`, size `21`, SHA-256
   `09be25dbd44da39d9b0bdfcf724ad1c0d676506d9b86febb44ec0cf9f6398ec8`; stderr exact ASCII
   `MFO_CAPTURE_STDERR_V1`, size `21`, SHA-256
   `110ee3432705922ece23462f453fa0f44844392c38e78fceff7135545b75a418`.
2. `QUALIFY_EMPTY`: use fixed EncodedCommand `ZQB4AGkAdAAgADIAOQA=`. Require numeric exit `29` and exact zero-byte
   stdout／stderr, each SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.
3. `QUALIFY_GODOT_VERSION`: approved console with exact arguments `--version`. Require numeric exit `0`, one trimmed
   line exactly `4.7.stable.official.5b4e0cb0f`, zero-byte stderr, and no residual relevant process.
4. Freeze a self-contained qualification manifest covering the launcher and all three attempts. Require every
   planned/result/raw-stream readback and hash to match.
5. `PARSER`: approved console with exact arguments
   `--headless --path . --check-only --script res://tests/run_slice2b_stageb_action_kernel_tests.gd`. Require numeric
   exit `0`, no parse/script error, exact frozen launcher／runner／UID identities, and no residual relevant process.

The intended parser invocation count is exactly `1`; no syntax retry is authorized. The prior `-010` parser results
do not validate the corrected runner, and `-011` contains no intended parser execution.

## 5. One FORMAL invocation

Only after all preceding requirements Pass, read back all frozen identities and run `FORMAL` exactly once. Its fixed
Godot arguments are:

```text
--headless --path . --script res://tests/run_slice2b_stageb_action_kernel_tests.gd
```

Pass requires from that same captured child invocation:

- numeric exit `0`;
- terminal summary exactly `184 assertions`;
- exactly `184` PASS records and zero failed assertion／script／capture records;
- exact `162`-description multiset and Section 2 multiplicities;
- exact frozen launcher／runner／UID／candidate identities;
- direct requirement-matrix coverage without cleanup manufacturing release state;
- final relevant-process count `0`.

Do not rerun Stage A, Phase 1, Slice 2-A, correction, import, main smoke, export, or exported smoke. Bind only the
accepted `-009` manifest `609a8dead1d6e87ce6e4d3f8daa212daebf45dd7266aa60172c6d25efb885989`
for those inherited results.

After FORMAL, run only identity, protected-path, scope, nonignored-untracked, residual-process, branch-range
`git diff --check`, and self-contained SHA-256 manifest audits. Stop at the first non-pass. Runner repair, expectation
change, retry, alternate engine, evidence rewriting, or candidate repair is prohibited after qualification begins.

## 6. Authorized tracked paths

Only these paths may change:

1. `material-frontier-online/prototype/tests/run_slice2b_stageb_action_kernel_tests.gd`
2. `docs/test-reports/phase2-slice2b-stageb-capture-safe-terminal-revalidation.md`
3. `docs/test-reports/evidence/phase2-slice2b/stageb-kernel-005/**`
4. `docs/handoffs/qa.md`

The runner UID, candidate, gameplay／data, prior reports／evidence, other tests, scenes, project configuration,
contracts, export artifacts, and supervisor documents are immutable.

## 7. Result and return

Return exactly one recommendation:

- `Pass / isolated Stage B action kernel and approved data validated`;
- `Fail / candidate implementation or approved-data nonconformance`; or
- `Blocked / validation infrastructure or evidence incomplete`.

Candidate Fail requires a completed, capture-valid FORMAL ledger: exact `184` records, exact `162` descriptions,
zero script／capture errors, and failed labels directly mapped to candidate／Approved-data requirements. Any capture,
parser, ledger, matrix, manifest, process, identity, documentation, or scope defect is Blocked.

The complete order is timeboxed to 60 active minutes after START. A timebox expiration returns Blocked with current
evidence; it does not authorize repair or retry. Commit QA content, then final QA handoff separately, and push only
the required QA branch. Even on Pass, stop. Stage C, input／authority／actor／target／scene／damage／state／event／
presentation integration, Slice 2-C／2-D, PREACK／performance／P95／real A-B-C, KBM／gamepad／user feel, and Gate 2
remain prohibited or Deferred until a separate supervisor order.

## 8. Supervisor return closure — 2026-08-03

QA returned `Blocked / validation infrastructure or evidence incomplete` at branch tip
`7eb3edb36bf58f8eb2d304c2a94e9f1e757c9560` (content `0e0f98db5d13122c419e62684a5f561bfc526434`).
The Section 2 batch produced runner SHA-256
`5bc45949cc21d29b0bcc160aafed46257aa572259c761de3b031778aa3f67556`, preserved `153 / 1`,
and removed the false heavy `180 / 2` expectation without changing candidate／production data.

The first and only child attempt was `QUALIFY_STREAMS`: numeric exit `1`, stdout `0` bytes, stderr `409` bytes,
and PowerShell `TerminatorExpectedAtEndOfString`. Later qualification modes, parser, FORMAL, and candidate
execution were `0`; final reported residual relevant process count was `0`.

Independent supervisor readback establishes the primary QA-infrastructure attribution:

- the authorized EncodedCommand is `624` Base64 characters and decodes to `468` UTF-16LE bytes;
- the launcher／planned record instead contain a different `600`-character Base64 payload decoding to an odd
  `449` bytes, first differing at Base64 offset `132`;
- the corrupted payload is internally self-consistent between launcher and planned record but is not equal to
  the work-order literal. Therefore `preflight.json`'s `stream_arguments_exact=true` proves only internal
  self-equality, not ticket equality;
- raw streams and numeric exit were captured successfully, so this is not ProcessStartInfo transport,
  PowerShell, candidate, or Approved-data failure.

The required pre-child runner closure was also incomplete: no regenerated bullet-level matrix／actual description
inventory exists; quick／heavy effect access retains missing key guards, heavy request effects omit direct
`effect_id`／`effect_type` checks, and callback／boundary／independent-registry observations remain incomplete.
Accordingly the runner was not qualified even apart from the launcher failure. No candidate Fail is established.
No automatic `-013` is authorized. Stage B validation is Deferred, no active Slice 2-B QA order exists, and Gate 2
remains Locked.
