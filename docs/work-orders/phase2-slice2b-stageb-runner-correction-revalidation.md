# MFO-WO-P2-2B-009 — Slice 2-B Stage B QA runner correction revalidation

- Issuer: `00統括（監督）`
- Issued: 2026-08-02 (Asia/Tokyo)
- Assignee: `30 QA・性能・レビュー`
- Status: **Authorized / exact runner correction and fixed revalidation only**
- Milestone: M2 / Slice 2-B
- Required branch: `codex/phase2-slice2b-stageb-action-kernel-qa`
- Required workspace: existing dedicated worktree `C:\tmp\q2b-stageb`
- Required starting point: the supervisor commit containing this order, supplied in the direct START notice
- Predecessor QA tip: `9c8f58ef29eaa6090f748b1872d47186b043370f`
- Candidate implementation: `30b090481a9fffd123d5b16537886e5011fd7e51`
- Candidate handoff / reviewed HEAD: `bbed2fd98bf0435e456f9ad2bd7dba2b7a7cb0c6`
- Frozen defective runner SHA-256: `08af5c6c834561a5b54c08dcaa0a585da2a9d2ea25f877112ebdddcdd4941e59`
- Frozen runner UID SHA-256: `7615a8f1d1edf4d59e5a4eb25996acd008a05a53921e4f293ea5765da4d67096`
- Integration authority: **None**
- Gate effect: **None — Gate 2 remains Locked**

## 1. Predecessor disposition and purpose

`MFO-WO-P2-2B-008` is accepted as `Blocked / validation infrastructure or evidence incomplete`.
The frozen runner declared `runtime` as `Phase2ActionRuntime`, then attempted the statically incompatible predicate
`runtime is Node`. Godot rejected the runner at parse time before any assertion or candidate behavior executed.
The candidate extends `RefCounted` and contains no Node connection; the result is not evidence of a candidate or
Approved-data defect.

The predecessor numeric exit is not adopted as a settled fact: its durable meta records `1`, while its report,
handoff, and return message record `0`. Parse failure, assertion count `0`, and candidate non-execution are common to
both records and remain authoritative. Existing report and evidence bytes must not be rewritten.

This order permits one exact QA-runner correction, a parser-only closure, and one fresh fixed validation sequence.
It does not authorize candidate repair, expectation changes, gameplay-value changes, or integration.

## 2. Exact permitted correction

Change exactly one existing line in
`material-frontier-online/prototype/tests/run_slice2b_stageb_action_kernel_tests.gd`:

```gdscript
# before
_check(runtime is RefCounted and not (runtime is Node), "runtime is an isolated RefCounted object")

# after
_check(runtime is RefCounted, "runtime is an isolated RefCounted object")
```

This removes a parser-invalid redundant predicate; it does not relax the isolation contract. Independently retain
the static check that `action_runtime.gd` extends `RefCounted` and has no Node, scene, input, actor, or presentation
connection.

Requirements:

1. verify the predecessor runner and UID identities before writing;
2. perform the replacement once, with exactly one deletion and one insertion;
3. record the complete before／after diff and before／after runner SHA-256;
4. leave the tracked UID byte-identical;
5. do not change another runner line, helper, assertion message, expectation, or assertion cardinality.

A precondition, identity, line-count, or diff mismatch returns `Blocked` without a write retry or alternate fix.

## 3. Authorized tracked paths

Only these paths may change:

- `material-frontier-online/prototype/tests/run_slice2b_stageb_action_kernel_tests.gd`
- `docs/test-reports/phase2-slice2b-stageb-action-kernel-runner-correction-revalidation.md`
- `docs/test-reports/evidence/phase2-slice2b/stageb-kernel-002/**`
- `docs/handoffs/qa.md`

The runner UID, all candidate gameplay code／data／UIDs, Stage A runner, existing tests, prior reports／evidence,
scenes, input, simulation, actors, `project.godot`, export configuration, contracts, and supervisor status documents
remain immutable.

## 4. Parser-only closure and runner freeze

Use only the Godot console identity specified by `MFO-WO-P2-2B-008`:

- size `198152` bytes;
- SHA-256 `D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`;
- version `4.7.stable.official.5b4e0cb0f`.

After the exact correction, execute one parser-only `--check-only --script` invocation for the corrected runner.
Capture the same invocation's numeric exit, stdout, and stderr durably. It must exit `0` with no parse error.
If it does not, freeze and return `Blocked`; do not repair or retry.

After parser-only Pass, freeze and hash the corrected runner. Copy the frozen corrected runner and unchanged UID into
the new evidence root as evidence copies before formal execution. The new manifest must be self-contained: every
payload entry resolves within `stageb-kernel-002`, and every file／size／SHA-256 readback must match.

No runner edit is permitted after the parser-only invocation or after candidate behavior is observed.

## 5. Fresh fixed formal sequence

Run each item once and in this order, preserving the exact command, same-invocation numeric exit, stdout, stderr,
assertion total, and relevant identities:

1. engine identity and `--version`;
2. headless editor import／parse;
3. corrected Stage B action-kernel runner;
4. corrected Stage A runner, requiring `71 / 71`;
5. Phase 1 runner, requiring `36 / 36`;
6. Slice 2-A runner, requiring `120 / 120`;
7. Slice 2-A correction runner, requiring `39 / 39`;
8. unchanged main-scene headless smoke, requiring exit `0`, successful definition validation, and no RHL violation;
9. candidate／approved-data／UID／protected-path audit, `git diff --check`, nonignored-untracked audit, manifest
   readback, local／origin comparison, and final clean audit.

The Stage B runner must cover the complete Section 4 contract of `MFO-WO-P2-2B-008`; Pass requires zero failed
assertions and a complete terminal summary. Do not adopt a predeclared assertion count derived from raw text.

Stop at the first formal non-pass. Do not edit the frozen runner, repair the candidate, change engines, rebaseline
values, rerun a failed command, or replace missing evidence after the stop boundary.

Release export and exported smoke remain `Not run`: the isolated kernel／data are not connected to the main scene.
Physical gamepad, KBM／user feel, performance／P95, PREACK, real A／B／C, OneDrive／power changes, Stage C,
Slice 2-C／2-D, input, authority, actor／target, physics hit, damage, events, presentation, integration, and Gate 2
are `Not run / Deferred` or prohibited.

## 6. Result and return

Return exactly one recommendation:

- `Pass / isolated Stage B action kernel and data validated`;
- `Fail / candidate implementation or approved-data nonconformance`; or
- `Blocked / validation infrastructure or evidence incomplete`.

A runner, command-capture, manifest, or evidence defect is `Blocked`. Attribute `Fail` only when the frozen
candidate behavior or data directly violates the Approved order.

Commit the corrected runner, new report, and new evidence as one QA content commit, then commit only the final
`docs/handoffs/qa.md` update separately. Push only the required QA branch and return:

- starting, QA-content, and QA-handoff commits;
- candidate, predecessor runner, corrected runner, and UID identities;
- exact changed paths and complete one-line correction diff;
- parser-only and every formal command, same-invocation exit, assertion total, and evidence path;
- self-contained manifest readback, local／origin equality, and clean status;
- every `Not run / Deferred` item.

Stop after return. Even a Pass requires separate supervisor acceptance and a new explicit follow-on order.
