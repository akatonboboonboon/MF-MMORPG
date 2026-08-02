# MFO-WO-P2-2B-010 — Slice 2-B Stage B consolidated coverage-completion revalidation

- Issuer: `00統括（監督）`
- Issued: 2026-08-02 (Asia/Tokyo)
- Assignee: `30 QA・性能・レビュー`
- Status: **Authorized / consolidated QA coverage completion and isolated Stage B validation only**
- Milestone: M2 / Slice 2-B
- Required branch: `codex/phase2-slice2b-stageb-action-kernel-qa`
- Required workspace: dedicated worktree `C:\tmp\q2b-stageb`
- Required starting point: the supervisor commit containing this order, supplied in the direct START notice
- Predecessor QA tip: `6a8f67d6173053f9eef7794a85c83f92d15a09eb`
- Frozen candidate implementation: `30b090481a9fffd123d5b16537886e5011fd7e51`
- Frozen candidate handoff: `bbed2fd98bf0435e456f9ad2bd7dba2b7a7cb0c6`
- Frozen predecessor runner SHA-256: `b55c7c6942767389f27bee67aa7fe0f9a43e3d515741307e17aacb86ad658148`
- Frozen runner UID SHA-256: `7615a8f1d1edf4d59e5a4eb25996acd008a05a53921e4f293ea5765da4d67096`
- Integration authority: **None**
- Gate effect: **None — Gate 2 remains Locked**

## 1. Predecessor disposition and purpose

`MFO-WO-P2-2B-009` is accepted as:

`Blocked / validation infrastructure or evidence incomplete`

Its exact one-line predicate correction and parser closure passed. The frozen runner then completed `108 assertions`
with numeric exit `0`; Stage A `71 / 71`, Phase 1 `36 / 36`, Slice 2-A `120 / 120`, Slice 2-A correction `39 / 39`,
and main smoke also returned exit `0`. The `32 / 32` evidence-manifest payloads independently hash-match, and no
candidate gameplay or data path changed after the reviewed handoff.

The run does not establish final Stage B acceptance because the frozen runner omitted required direct coverage.
The omissions include the two cases reported by QA—an executed `rejected` callback and an invalidated callback with
lease release—and additional items found by the supervisor's full Section 4 census. The branch-range
`git diff --check` also detects whitespace in the committed raw diff evidence that was untracked when the recorded
pre-commit check ran. These are QA runner／evidence defects, not evidence of a candidate implementation, Approved-data,
project, or specification defect.

This order replaces further one-defect micro-recovery with one bounded, consolidated coverage-completion packet.
It may complete only the missing independent QA coverage and then execute one fresh Stage B runner invocation. It
does not modify or integrate the candidate.

Before START, predecessor QA tip `6a8f67d6173053f9eef7794a85c83f92d15a09eb` must exist on `origin` and be an
unchanged ancestor of the supplied supervisor commit. Otherwise HOLD without editing.

## 2. Frozen predecessor results and exact interpretation

The following `MFO-WO-P2-2B-009` results are accepted for identity-bound inheritance and must not be rerun:

- engine identity／version and headless import;
- Stage A `71 / 71`;
- Phase 1 `36 / 36`;
- Slice 2-A `120 / 120`;
- Slice 2-A correction `39 / 39`;
- main smoke exit `0`, `DefinitionsValidated ok=true`, RHL `violation_count: 0`;
- candidate lineage, fourteen implementation paths, and post-handoff gameplay／data diff `0`.

The new evidence must read back and bind every inherited command meta／stream identity through the frozen
`stageb-kernel-002/SHA256SUMS.txt` SHA-256
`609a8dead1d6e87ce6e4d3f8daa212daebf45dd7266aa60172c6d25efb885989`. Do not copy, rewrite, normalize, or repair
prior report／evidence bytes.

For Section 4.2 of `MFO-WO-P2-2B-008`, ordered behavior means the canonical order of
`CombatForm.action_set_ids` and each action's `effect_ids`. The caller-supplied action／effect arrays are registries
keyed by stable IDs; their container enumeration order is not itself a production contract. Empty coverage includes
both empty registries and empty stable-ID entries. Unknown coverage includes an unknown form action reference and an
unknown effect reference.

## 3. Complete missing-coverage packet

QA must create a requirement-to-test matrix covering every bullet in Sections 4.1 through 4.3 of
`MFO-WO-P2-2B-008`. Existing assertions and inherited Stage A results may be cited only when they directly prove the
requirement. At minimum, the final runner／evidence must close all items below.

### 3.1 Definition and registry negatives

Directly execute and separately observe rejection for:

1. empty action and effect registries;
2. an empty action ID in the form membership;
3. an action-definition registry entry with an empty action ID;
4. an effect-definition registry entry with an empty effect ID;
5. an unknown form action reference;
6. an unknown effect reference;
7. reordered effect references, in addition to the existing reordered form-action coverage;
8. isolated non-finite geometry, non-finite timing, invalid aim policy, and invalid／non-finite forward intent.

Existing duplicate, missing, extra, cross-wired, form-order, exact-value, resource-load, legacy-validation, and Stage A
open-vocabulary checks remain required. A composite mutation that could pass because only one of several changed fields
was rejected does not prove the other fields.

Positive identity checks must also anchor the Approved literal vocabulary independently of candidate-declared
constants: form／action／effect stable IDs, hit shape, physical category／channel, reservation class, aim policies,
effect metadata, four runtime phase names, and four query-status names. Candidate constants and candidate resources
agreeing with each other is not sufficient if the same wrong value could occur in both.

### 3.2 Rejection and callback outcomes

Directly verify:

1. a rejected acceptance leaves phase idle, accepted count／sequence unchanged, callback count and captured-request
   count unchanged, no pending lease, no query result／effects／movement intent, and no queued action;
2. a callback that actually executes and returns canonical `rejected` is invoked exactly once, records `rejected`,
   and releases the lease before cleanup;
3. a callback target invalidated after acceptance but before active entry records `malformed`, is not invoked, and
   releases the same reserved lease before cleanup;
4. hit, miss, rejected, malformed, and invalidated-callback outcomes each show immediate successful release,
   active-query count `0`, and emergency active／use counts `0` before reset or clear;
5. reset-before-active and clear-before-active are separate cases; each invokes no callback and releases its lease
   before the final-idle observation.

### 3.3 Timing, request, and debug records

Directly verify:

1. one `advance` call crosses multiple phase boundaries deterministically; this may share the executed-`rejected`
   scenario;
2. quick and heavy each remain in windup／active／recovery immediately before the nominal `6 / 6 / 12` and
   `24 / 6 / 30` 60 Hz boundaries, cross only on the exact boundary, and never invoke the callback more than once
   after further active／recovery advancement;
3. callback request records for quick and heavy contain the exact action ID, accepted sequence, locked aim, hit-shape
   ID, reach, radius, minimum aim dot, maximum targets, exact ordered effect records and their required fields, and
   `0`／`48 px` active-only movement intent;
4. request, nested geometry, effect array, and effect records are read-only;
5. debug state contains the required phase, elapsed time, locked aim, accepted sequence／count, query count, effects,
   movement intent, release result, active count, emergency active／use counts, pending-lease flag, and query-result
   flag; debug result contains status, request, query count, release result, and active／emergency counts; both are read-only;
6. final idle clears pending lease, result, effect records, and movement intent.

Stale／duplicate／unknown lease release and generic open-vocabulary behavior may be bound to the accepted Stage A
`71 / 71` result; do not duplicate or modify the Stage A runner.

### 3.4 Isolation source audit

Record a static source audit proving that the frozen runtime extends `RefCounted` and introduces no Node lifecycle,
input-device, actor／target, physics-world query, damage／part state, production event, presentation, or scene
connection. Prove that `CombatForm` owns only ordered action membership and has no effect-registry property. Prove
that `48 px` remains request intent only and no actor movement is performed. This is read-only candidate inspection,
not permission to change the candidate.

## 4. Authorized tracked paths

Only these paths may change:

1. `material-frontier-online/prototype/tests/run_slice2b_stageb_action_kernel_tests.gd`
2. `docs/test-reports/phase2-slice2b-stageb-coverage-completion-revalidation.md`
3. `docs/test-reports/evidence/phase2-slice2b/stageb-kernel-003/**`
4. `docs/handoffs/qa.md`

The runner UID is immutable. Candidate code／data／UIDs, prior reports／evidence, existing tests, Stage A runner,
scenes, project configuration, input, simulation, actors, state, events, presentation, export artifacts, and
contracts are immutable.

Raw diff evidence must be stored in a whitespace-safe representation such as JSON-escaped records or base64. Do not
repeat the predecessor raw-diff hygiene defect. The final supervisor-to-QA-tip branch range must pass
`git diff --check`.

## 5. Pre-formal authoring, coverage closure, and freeze

This section is an offline QA-infrastructure authoring phase. Candidate execution is prohibited until it closes.

1. Verify required branch／HEAD／origin, predecessor ancestry, and a clean worktree.
2. Read back the predecessor runner／UID, candidate, work orders, report, and all inherited evidence identities.
3. Add only the fixtures, local observations, and assertions required by Section 3. Existing passing assertions and
   expectations must not be weakened or removed.
4. Produce the complete requirement-to-test matrix, source-diff classification, isolation audit, assertion-call-site
   count, helper-declaration count, and stable assertion-label inventory.
5. Run the approved `--check-only --script` parser command. Up to three recorded parser-only authoring attempts are
   permitted before FORMAL; no runner process invocation is permitted. After the first parser Pass that also matches
   the complete matrix, freeze the runner and UID and record their bytes／SHA-256.

The pre-formal phase is timeboxed to 45 active minutes. If the complete matrix and parser Pass are not both obtained
within the timebox or three parser attempts, return `Blocked`. Do not execute the candidate runner. No second runner
file or alternate test implementation is permitted.

The assertion total is not prescribed in advance. Acceptance requires the frozen source's executable `_check` call
site count, one unchanged `_check` helper declaration, terminal assertion total, and stable-label execution inventory
to agree exactly. This prevents both helper miscounting and coverage-by-cardinality.

## 6. Single fresh FORMAL execution and evidence

After Section 5 Passes, execute only the frozen Stage B runner exactly once with the approved Godot console. Capture
the same process invocation's exact command, engine file identity, PID where available, numeric exit, stdout, stderr,
and hashes. Pass requires:

- numeric exit `0`;
- zero failed assertions;
- terminal assertion total exactly equal to the frozen executable call-site count;
- every stable assertion label in the coverage matrix present exactly once in that invocation's output;
- frozen runner and unchanged UID SHA-256 bound to the result;
- all Section 3 cases observed without cleanup manufacturing release state.

Do not rerun inherited regressions or main smoke. Bind them by Section 2 identities. After the Stage B process, run
only final candidate／runner／UID／protected-path／scope／nonignored-untracked／process／manifest audits. The evidence
manifest must be self-contained, list every payload with path, size, and SHA-256, and read back with zero mismatch.
`git diff --check` must cover all new QA paths, including report and evidence payloads.

Stop at the first FORMAL or evidence non-pass. After FORMAL begins, runner repair, expectation change, retry, alternate
engine, second Stage B invocation, evidence rewriting, or candidate repair is prohibited.

Release export／exported smoke, physical gamepad, KBM／user feel, Slice 2-A PREACK／performance／P95, real A／B／C,
Stage C, input／authority／actor／target／scene／damage／state／event／presentation integration, Slice 2-C／2-D, and
Gate 2 evaluation are `Not run / Deferred` or prohibited.

## 7. Result and return

Return exactly one recommendation:

- `Pass / isolated Stage B action kernel and approved data validated`;
- `Fail / candidate implementation or approved-data nonconformance`; or
- `Blocked / validation infrastructure or evidence incomplete`.

A candidate Fail requires direct evidence from the single frozen Stage B invocation. Runner authoring, parser,
coverage, capture, manifest, or documentation defects are Blocked and must not be attributed to the candidate.

On return:

1. commit runner／report／new evidence as one QA content commit;
2. update `docs/handoffs/qa.md` in a separate final handoff commit;
3. run final branch-range and clean-worktree checks;
4. push only the required QA branch;
5. report exact commits, changed paths, runner／UID／manifest identities, parser-attempt count, formal command／exit／
   assertion total, inherited-result bindings, and worktree status.

Even on Pass, stop. Do not merge, integrate, start Stage C or Slice 2-C, run performance acceptance, or evaluate
Gate 2 without a separate supervisor work order.
