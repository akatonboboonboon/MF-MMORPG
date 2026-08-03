# MFO-WO-P2-2B-013 窶・Slice 2-B Stage B supervisor-fixed terminal validation

- Issuer: `00邨ｱ諡ｬ・育屮逹｣・荏
- Issued: 2026-08-03 (Asia/Tokyo)
- User authority: explicit `蜀埼幕縺励※縺上□縺輔＞` received 2026-08-03
- Assignee: `30 QA繝ｻ諤ｧ閭ｽ繝ｻ繝ｬ繝薙Η繝ｼ`
- Status: **Active / supervisor-fixed QA infrastructure; terminal Stage B validation only**
- Milestone: M2 / Slice 2-B
- Required branch: `codex/phase2-slice2b-stageb-action-kernel-qa`
- Required workspace: `C:\tmp\q2b-stageb`
- Required starting point: the supervisor commit containing this order, supplied in the START notice
- Frozen predecessor QA tip: `7eb3edb36bf58f8eb2d304c2a94e9f1e757c9560`
- Frozen candidate implementation: `30b090481a9fffd123d5b16537886e5011fd7e51`
- Frozen reviewed handoff: `bbed2fd98bf0435e456f9ad2bd7dba2b7a7cb0c6`
- Integration authority: **None**
- Gate effect: **None 窶・Gate 2 remains Locked**

## 1. Purpose and disposition

`MFO-WO-P2-2B-012` is closed `Blocked / validation infrastructure or evidence incomplete`. Its first
`QUALIFY_STREAMS` attempt used a corrupted launcher payload; parser, FORMAL, and candidate execution remained `0`.
Independent review also found that the QA runner had not completed the required direct-coverage matrix. Candidate
implementation and Approved data are not attributed Fail.

The user has now explicitly authorized resumption. This order is a single consolidated supervisor-fixed packet,
not an automatic micro-recovery. The supervisor starting commit already contains both immutable QA inputs:

1. the corrected Stage B runner; and
2. the capture-safe launcher source.

QA must not edit either input. The only candidate execution authorized is the one fixed FORMAL invocation below.
No automatic `-014` is authorized, regardless of result.

## 2. Immutable starting inputs

Corrected runner:

`material-frontier-online/prototype/tests/run_slice2b_stageb_action_kernel_tests.gd`

- canonical UTF-8 LF SHA-256: `f48266b43a3f3b572d2a5747807efa8bc4bbc6150e3481473d8b9d0272c3ba22`
- Git blob: `8d7d611dc3e1d3b54291ad0d23c8ae791ebdd724`
- executable `_check` call sites / helper declarations: `153 / 1`
- projected single-run assertion executions: `184`
- expanded description count: `162`

Runner UID:

`material-frontier-online/prototype/tests/run_slice2b_stageb_action_kernel_tests.gd.uid`

- canonical UTF-8 LF SHA-256: `7615a8f1d1edf4d59e5a4eb25996acd008a05a53921e4f293ea5765da4d67096`
- Git blob: `d11222d7ba3410864d00cee52fdc124506d8cc61`

Capture launcher source:

`docs/work-orders/support/phase2-slice2b-stageb-013/capture-stageb-terminal.ps1`

- canonical UTF-8 LF SHA-256: `671c8018e5b295bf83d7d228f41adec5802570b63d6a569939539df54d04736f`
- Git blob: `0dc8ab217fd8a47d1a143263b1318d6ed420bf30`
- 7-bit ASCII, BOM-free, Windows PowerShell 5 parser errors `0`

The runner matrix is fixed in
[`support/phase2-slice2b-stageb-013/runner-matrix.md`](support/phase2-slice2b-stageb-013/runner-matrix.md).
Line-ending conversion by `core.autocrlf` must not be treated as a semantic mismatch: compare Git blob plus
canonical UTF-8 LF SHA-256. Record raw identity as evidence, but use canonical identity for cross-worktree
acceptance.

Before any child process, require exact ancestry, local/origin equality, a clean worktree, all immutable identities,
the fixed topology and ledger, and no unexpected nonignored untracked path. A mismatch is Blocked with child count
`0`.

## 3. Pre-child coverage closure

QA must perform a read-only static audit of the immutable runner and persist a requirement-to-test matrix plus the
actual ordered description inventory. Pass requires all of the following:

- static `_check` / helper declaration count `153 / 1`;
- projected execution formula `148 + 15 + 9 + 12 = 184`;
- exact `162` expanded descriptions, with no duplicate description outside the fixed helper/effect multiplicities;
- test order, labels, loops, helper graph, and canonical rejected timing `0.20 + 0.20` unchanged;
- independent empty/unknown/zero/nonfinite/unavailable and busy rejection observations;
- guarded quick and heavy request identity, geometry `150 / 88 / 0.25 / max 1`, movement intent, and both ordered
  effect records including ID, type, magnitude, channel, duration, target rule, stack rule, and tags;
- direct hit, miss, rejected, unsupported-malformed, invalidated-malformed, reset-before-active, and
  clear-before-active status/release/counter observations;
- query/request cardinality through active, recovery, and idle boundaries;
- independent empty-action and empty-effect registry evaluation;
- no indexed request, geometry, effect, debug-state, or debug-result access without left-hand key/type/size guards.

Do not execute the candidate to construct this matrix. Do not repair the runner, alter expected values, add a label,
or create an alternate runner.

## 4. Launcher materialization and qualification

Create fresh evidence root:

`docs/test-reports/evidence/phase2-slice2b/stageb-kernel-006/`

Copy the immutable launcher source byte-for-byte to:

`stageb-kernel-006/capture-stageb-terminal.ps1`

The copy must be byte-identical to its same-checkout source and then frozen before any child. Verify source and copy
raw identities, canonical identity, 7-bit ASCII, BOM absence, and PowerShell 5 parser error count `0`.

Run only the copied launcher, in this fixed order, each mode exactly once:

1. `QUALIFY_STREAMS`
2. `QUALIFY_EMPTY`
3. `QUALIFY_GODOT_VERSION`
4. `PARSER`
5. `FORMAL`, only if every preceding item Passes

The launcher fixes executable, working directory, arguments, and attempt paths internally. Do not pass or rebuild a
child argument string externally. Do not use `Start-Process`, an alternate launcher, or an alternate engine.

Qualification acceptance:

- streams canary: exit `23`, stdout/stderr exact ASCII `MFO_CAPTURE_STDOUT_V1` / `MFO_CAPTURE_STDERR_V1`, `21 / 21`
  bytes;
- empty canary: exit `29`, stdout/stderr `0 / 0` bytes with the empty SHA-256;
- Godot version: approved console size `198152`, SHA-256
  `D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`, exit `0`, stdout exactly
  `4.7.stable.official.5b4e0cb0f` after trimming, stderr `0` bytes;
- every attempt has pre-launch planned record, assigned argument readback, separate raw streams, numeric exit,
  completion/timeout/kill fields, result, manifest, and matching hashes;
- aggregate qualification manifest exists and reads back without mismatch;
- a mode-specific atomic Pass verdict and transitive pass manifest exist only after that mode's acceptance checks;
  each later mode revalidates all predecessor verdicts, raw streams, results, manifests, fixed arguments, and
  immutable identities before creating its own attempt directory;
- final relevant-process count `0`.

`PARSER` must be exact one invocation with the launcher's fixed arguments. Pass requires numeric exit `0`, no parse
or script error, immutable identities unchanged, and relevant-process count `0`. A parser non-pass leaves FORMAL
count `0`.

## 5. One FORMAL invocation

After the static closure, three qualification modes, and parser all Pass, run `FORMAL` exactly once through the same
copied launcher. Pass requires from that same captured child:

- numeric exit `0`, no timeout/kill/capture error, and both streams durably captured;
- terminal summary exactly `184 assertions`;
- exactly `184` PASS records and `0` failed assertion/script/capture records;
- exactly the fixed `162` expanded descriptions and multiplicities;
- immutable runner, UID, launcher, candidate, and reviewed-handoff identities;
- direct matrix coverage and final relevant-process count `0`.

Do not rerun Stage A, Phase 1, Slice 2-A, correction, import, main smoke, export, or exported smoke. Bind the accepted
`MFO-WO-P2-2B-009` manifest
`609a8dead1d6e87ce6e4d3f8daa212daebf45dd7266aa60172c6d25efb885989` for inherited results.

## 6. Stop boundary and result

At the first non-pass, stop. No runner/launcher/matrix/expectation repair, retry, second parser, second FORMAL,
alternate engine, evidence overwrite, candidate repair, or cleanup that destroys failure evidence is permitted.
Terminate only a process started and owned by this order; never terminate an ambient process.

Return exactly one recommendation:

- `Pass / isolated Stage B action kernel and approved data validated`;
- `Fail / candidate implementation or approved-data nonconformance`; or
- `Blocked / validation infrastructure or evidence incomplete`.

Candidate Fail requires a completed capture-valid FORMAL ledger with failed labels directly mapped to candidate or
Approved-data requirements. Any static matrix, launcher, parser, capture, identity, scope, manifest, or residual
process defect is Blocked.

This order is timeboxed to 60 active minutes after START. Even on Pass, stop. Stage C, input, authority, actor/target,
scene, damage/state, event, presentation, integration, Slice 2-C/2-D, PREACK/performance/P95/real A-B-C,
KBM/gamepad/user feel, and Gate 2 remain prohibited or Deferred.

## 7. Authorized tracked paths

QA may change only:

1. `docs/test-reports/phase2-slice2b-stageb-supervisor-fixed-terminal-validation.md`
2. `docs/test-reports/evidence/phase2-slice2b/stageb-kernel-006/**`
3. `docs/handoffs/qa.md`

The corrected runner, UID, launcher source, candidate/gameplay/data, prior reports/evidence, other tests, scenes,
project configuration, contracts, and supervisor documents are immutable. Commit QA content first, final QA handoff
second, push only the required QA branch, and stop. No automatic `MFO-WO-P2-2B-014` may be requested or started.
