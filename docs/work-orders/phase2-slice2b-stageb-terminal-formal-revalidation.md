# MFO-WO-P2-2B-011 — Slice 2-B Stage B terminal formal revalidation

- Issuer: `00統括（監督）`
- Issued: 2026-08-02 (Asia/Tokyo)
- Assignee: `30 QA・性能・レビュー`
- Status: **Authorized / final runner correction and one terminal Stage B invocation only**
- Milestone: M2 / Slice 2-B
- Required branch: `codex/phase2-slice2b-stageb-action-kernel-qa`
- Required workspace: dedicated worktree `C:\tmp\q2b-stageb`
- Required starting point: the supervisor commit containing this order, supplied in the direct START notice
- Predecessor QA tip: `f8e7a49b16a4bc335a88c9f2b2aa84c0ca648ad8`
- Frozen candidate implementation: `30b090481a9fffd123d5b16537886e5011fd7e51`
- Frozen candidate handoff: `bbed2fd98bf0435e456f9ad2bd7dba2b7a7cb0c6`
- Seed runner SHA-256: `1a5a22da731c8bd402e734de445ee48d1a0aaab416a986eccb20bd65fcb910e6`
- Frozen runner UID SHA-256: `7615a8f1d1edf4d59e5a4eb25996acd008a05a53921e4f293ea5765da4d67096`
- Integration authority: **None**
- Gate effect: **None — Gate 2 remains Locked**

## 1. Final predecessor disposition

`MFO-WO-P2-2B-010` is accepted as:

`Blocked / validation infrastructure or evidence incomplete`

Its two parser-only attempts returned exit `0`, and it produced a frozen runner, coverage matrix, source-isolation
audit, and pre-formal evidence. It did not start FORMAL and did not execute the candidate. The Blocked result is not
a candidate or Approved-data Fail.

The returned `175` terminal projection is not accepted as authoritative. Independent read-only audit found:

- static `_check` call sites: `153`; helper declaration: `1`;
- `148` one-shot call sites;
- the `_pool()`-local check executes `15` times;
- the `_configured_runtime()`-local check executes `9` times;
- three checks inside the four-effect loop execute `12` times;
- correct projected terminal total: `148 + 15 + 9 + 12 = 184`;
- correct distinct output-label count: `162`.

The prior label inventory extracted earlier string literals such as `_query_callback` instead of the final assertion
description and omitted dynamic effect labels. The group-level matrix also overstated direct coverage: heavy request
completeness, miss／malformed immediate release, rejected-request state invariants, and later-phase callback
cardinality were not all directly established. Preserve old evidence unchanged; this order records the corrected
attribution and replaces it.

This is the terminal Stage B runner packet. If its pre-formal or FORMAL infrastructure does not pass, defer Stage B
without an automatic `-012` or another one-defect recovery.

Before START, the predecessor QA tip must exist on `origin`, be an unchanged ancestor of the supplied supervisor
commit, and the required worktree must be clean. Otherwise HOLD without editing.

## 2. Exact permitted runner correction

Start from the exact seed runner. Apply one consolidated semantic batch. The following topology is immutable:

- `_check` executable call sites: `153`;
- `_check` helper declarations: `1`;
- assertion descriptions: unchanged;
- test-function order, loops, and helper call graph: unchanged;
- `_pool()` reach count `15`, `_configured_runtime()` reach count `9`, four-effect loop cardinality `4`.

Do not add, delete, relocate, or conditionally skip an `_check`; do not add a helper, loop, runner, or alternate test
path. Only adjacent local observations and stronger conditions in the existing checks may change.

The sole permitted timing rewrite is the existing canonical-rejected scenario: replace its single `advance(0.40)`
with `advance(0.20)` to cross windup／active and observe the result while recovery is still present, then use
`advance(0.20)` inside its existing final-idle check before confirming idle, no further advance, and one callback.
This must preserve the same `_check` topology, descriptions, action timing data, and total delta. No other timing or
control-flow rewrite is permitted.

Every strengthened compound condition that indexes or dereferences an array／dictionary must first guard size／key／
type on its left-hand side so a candidate nonconformance yields the existing failed label and terminal `FAIL`, not a
runner script error.

The single batch must directly close all of the following:

1. The existing empty-registry check independently calls both `validate_registry([], effects)` and
   `validate_registry([quick, heavy], [])` and requires both to reject.
2. Literal metadata for all four effects is `physical`, duration `0`, `hit_target`, `instant`, and empty tags.
3. Empty／unknown／zero／non-finite／unavailable pre-accept rejection leaves the applicable idle state, accepted
   sequence／count, query／callback-request count, lease, result, effects, and movement intent unchanged. Busy
   rejection preserves the already accepted quick action without a second sequence, callback, request, or lease.
4. Hit, miss, canonical rejected, unsupported-result malformed, and invalidated-callback malformed each directly
   observes its exact status, query count, successful release, active count `0`, emergency active／use counts `0`,
   and no pending lease before reset or clear.
5. Reset-before-active and clear-before-active directly observe callback count `0`, release, final idle, and
   active／emergency counts `0`.
6. Quick and heavy each retain exactly one callback request through later active／recovery advancement and final
   idle; further idle advancement cannot add a callback.
7. The heavy request is read-only and contains exact action／sequence／locked aim, complete read-only geometry,
   max target, `48 px` intent, ordered `14 / 18` effect records, and all immutable metadata. Quick verifies both
   effect records' metadata as well.
8. The existing debug-state and debug-result checks verify required fields and their exact values in the observed
   quick-active context, not key presence alone.

Existing exact values, expected outcomes, and accepted assertions must not be weakened. Candidate code／data and
the runner UID are immutable.

## 3. Correct execution ledger

Static source metrics are informative; the following frozen execution ledger is authoritative:

```text
148 one-shot checks
15 pool-helper executions
9 configured-runtime-helper executions
12 effect-loop executions (3 descriptions x effects 0..3)
184 assertion executions total
```

The expected output has `162` distinct descriptions:

- `caller pool configures PlayerCritical=1 emergency=0`: exactly `15`;
- `runtime fixture configures`: exactly `9`;
- each of the twelve formatted `effect 0..3` descriptions: exactly `1`;
- every other assertion description: exactly `1`.

An inventory must read the actual final description argument of each `_check`; it must not classify callable names or
other preceding string literals as labels.

## 4. Authorized tracked paths

Only these paths may change:

1. `material-frontier-online/prototype/tests/run_slice2b_stageb_action_kernel_tests.gd`
2. `docs/test-reports/phase2-slice2b-stageb-terminal-formal-revalidation.md`
3. `docs/test-reports/evidence/phase2-slice2b/stageb-kernel-004/**`
4. `docs/handoffs/qa.md`

The runner UID, candidate, prior report／evidence, other tests, game code／data, scenes, project configuration,
contracts, export artifacts, and supervisor files are immutable.

## 5. Pre-formal correction and freeze

Use only this Godot console executable:

`C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`

Before parser execution, require size `198152`, SHA-256
`D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`, and version
`4.7.stable.official.5b4e0cb0f`. From `material-frontier-online/prototype`, the parser-only command is exactly:

```text
<approved-console> --headless --path . --check-only --script res://tests/run_slice2b_stageb_action_kernel_tests.gd
```

Each invocation must durably capture its own numeric exit, raw stdout, raw stderr, byte counts, and SHA-256 values.

This phase is timeboxed to 30 active minutes. Candidate execution is prohibited.

1. Verify branch／HEAD／origin／ancestry／clean state and all frozen identities.
2. Read back `stageb-kernel-003` without editing it and record the corrected `184` attribution.
3. Apply the Section 2 correction as one semantic batch.
4. Produce a bullet-by-bullet requirement matrix covering every `MFO-WO-P2-2B-008` Section 4.1 through 4.3 bullet
   and every Section 2 item here, plus source diff, source-isolation audit, and the exact Section 3 multiset ledger.
5. Require exact static metrics `153 / 1` and projected dynamic metrics `184 / 162`.
6. Run parser-only at most twice. A second parser invocation may correct syntax only; it may not change semantics,
   expectations, topology, labels, or the ledger.
7. At the first complete parser Pass, freeze and hash the runner and unchanged UID.

Any scope, coverage, topology, ledger, identity, or parser non-pass returns Blocked. Do not start FORMAL.

## 6. One terminal FORMAL invocation

After Section 5 passes, read back the approved Godot console identity and execute the frozen Stage B runner exactly
once. Do not rerun Stage A, Phase 1, Slice 2-A, correction, or main smoke; bind the accepted `-009` manifest
`609a8dead1d6e87ce6e4d3f8daa212daebf45dd7266aa60172c6d25efb885989`.

From `material-frontier-online/prototype`, the only FORMAL runner command is exactly:

```text
<approved-console> --headless --path . --script res://tests/run_slice2b_stageb_action_kernel_tests.gd
```

Capture the same invocation's numeric exit, raw stdout, raw stderr, byte counts, and SHA-256 values durably before
classification. A later readback or process-state inference cannot substitute for the same-invocation numeric exit.

Pass requires, from that same process invocation:

- numeric exit `0`;
- terminal summary exactly `184 assertions`;
- exactly `184` assertion PASS records and zero failed assertion／script-error records;
- exact `162`-description multiset with Section 3 multiplicities;
- exact frozen runner／UID／candidate identities;
- direct coverage of every Section 2 item without cleanup manufacturing release state.

After the runner, run only identity, protected-path, scope, nonignored-untracked, residual-process, branch-range
`git diff --check`, and self-contained SHA-256 manifest audits.

Stop at the first FORMAL or evidence non-pass. Runner repair, expectation change, retry, alternate engine, second
runner invocation, evidence rewriting, or candidate repair is prohibited after FORMAL begins.

## 7. Result and return

Return exactly one recommendation:

- `Pass / isolated Stage B action kernel and approved data validated`;
- `Fail / candidate implementation or approved-data nonconformance`; or
- `Blocked / validation infrastructure or evidence incomplete`.

Candidate Fail requires a completed terminal `FAIL n / 184`; PASS records plus failed-label records exactly `184`;
the exact `162`-description multiset and Section 3 multiplicities; zero script／capture errors; and failed labels that
directly map to candidate／data requirements. Any incomplete or nonexact ledger is Blocked. Parser, crash, capture,
cardinality, label, matrix, manifest, or documentation defects are Blocked.

Commit QA content, then the final QA handoff separately; push only the required QA branch and report exact commits,
paths, identities, parser attempts, FORMAL command／exit／counts, manifest, and clean local／origin state.

Even on Pass, stop. Stage C, input／authority／actor／target／scene／damage／state／event／presentation integration,
Slice 2-C／2-D, PREACK／performance／P95／real A-B-C, KBM／gamepad／user feel, and Gate 2 remain prohibited or
Deferred until a separate supervisor order.
