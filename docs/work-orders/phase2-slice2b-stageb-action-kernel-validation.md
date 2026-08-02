# MFO-WO-P2-2B-008 — Slice 2-B isolated Stage B action-kernel validation

- Issuer: `00統括（監督）`
- Issued: 2026-08-02 (Asia/Tokyo)
- Assignee: `30 QA・性能・レビュー`
- Status: **Authorized / formal isolated Stage B validation only**
- Milestone: M2 / Slice 2-B
- Required branch: `codex/phase2-slice2b-stageb-action-kernel-qa`
- Required workspace: dedicated clean worktree `C:\tmp\q2b-stageb`
- Required starting point: the supervisor commit containing this order, supplied in the direct START notice
- Supervisor base: `29432cfd5a3eb32dfc290915d72d39b077715623`
- Candidate implementation: `30b090481a9fffd123d5b16537886e5011fd7e51`
- Candidate handoff / reviewed HEAD: `bbed2fd98bf0435e456f9ad2bd7dba2b7a7cb0c6`
- Integration authority: **None**
- Gate effect: **None — Gate 2 remains Locked**

## 1. Purpose and acceptance boundary

Independently validate the frozen, non-connected form／action／effect data and `RefCounted` runtime returned by
`MFO-WO-P2-2B-007`.

A Pass accepts only the isolated Stage B kernel and exact approved data. It does not authorize input, authority,
actor, target, physics-world hit execution, scenes, damage state, events, presentation, integration, Slice 2-C／2-D,
performance acceptance, or Gate 2 evaluation.

The candidate implementation and handoff commits are immutable. QA must not repair implementation, change gameplay
values, weaken expectations, or reuse the ignored `309 / 309` implementation self-check as formal evidence.

## 2. Starting state and lineage

Before writing, prove and record:

1. the candidate implementation parent is exactly the supervisor base;
2. the candidate handoff parent is exactly the implementation commit;
3. the candidate implementation changes exactly its fourteen `MFO-WO-P2-2B-007` implementation paths;
4. the handoff commit changes only `docs/handoffs/gameplay.md`;
5. the QA worktree starts clean from the supervisor commit containing this order.

Do not switch, reset, clean, stash, amend, or otherwise mutate gameplay, Stage A QA, shared Slice 2-A QA, or
supervisor worktrees. Do not push to `main`, the implementation branch, or another QA branch.

A lineage, identity, or clean-state mismatch returns `Blocked` before candidate execution.

## 3. Authorized tracked paths

Only these paths may be added or changed:

- `material-frontier-online/prototype/tests/run_slice2b_stageb_action_kernel_tests.gd`
- `material-frontier-online/prototype/tests/run_slice2b_stageb_action_kernel_tests.gd.uid`
- `docs/test-reports/phase2-slice2b-stageb-action-kernel-validation.md`
- `docs/test-reports/evidence/phase2-slice2b/stageb-kernel-001/**`
- `docs/handoffs/qa.md`

The runner must be independently authored from the Approved decision and `MFO-WO-P2-2B-007`. Record its final
SHA-256, generated UID identity, and executed assertion total. Do not predeclare an assertion total by raw textual
counting. Pass requires zero failed assertions, runner exit `0`, and complete required coverage.

All gameplay code, candidate data, candidate UIDs, existing tests, prior reports／evidence, scenes, input,
simulation, actors, `project.godot`, export configuration, contracts, and status documents remain immutable.

## 4. Required independent validation

### 4.1 Scope and non-integration audit

Confirm:

- exact one-form／two-action／four-effect package;
- candidate values and technical bindings exactly match `P2-2B-P1-2026-08-01` and `MFO-WO-P2-2B-007`;
- the two new UID sidecars match the candidate identities;
- existing Phase 1／Stage A APIs and UID sidecars remain compatible and unchanged;
- runtime extends `RefCounted` and has no Node, input-device, actor, target, physics-world, damage-state, production
  event, presentation, or scene connection;
- `48 px` remains an immutable active-phase movement intent only.

### 4.2 Definition and registry coverage

The new runner must verify:

- actual `.tres` resources load and validate;
- form ID and exact ordered quick／heavy membership;
- exact timings, aim policies, geometry, query limits, reservation class, cooldown, and forward intent;
- exact ordered effect references and `10 / 6 / 14 / 18` magnitudes;
- effect type, physical channel, zero duration, `hit_target`, `instant`, empty tags, null legacy effect, and empty
  presentation IDs;
- fail-closed handling for malformed or non-finite geometry, timing, aim policy, or forward intent;
- empty, duplicate, missing, unknown, extra, reordered, or cross-wired action／effect registry entries;
- Phase 1 legacy validation and accepted Stage A open-vocabulary behavior remain usable.

Do not convert the generic effect schema into a broader closed production enum.

### 4.3 Runtime coverage

Using a fresh caller-injected pool with `PlayerCritical = 1` and emergency capacity `0`, verify:

- one-shot valid configuration and fail-closed invalid form, registry, pool, or callback configuration;
- rejection before acceptance for unconfigured, busy, unknown action, zero／non-finite aim, and unavailable reservation;
- rejected requests create no queue, accepted sequence, callback, or leaked lease;
- reservation exists before acceptance completes;
- quick nominal `6 / 6 / 12` 60 Hz progression and windup aim-follow followed by active-entry lock;
- heavy nominal `24 / 6 / 30` progression and acceptance-time aim lock;
- deterministic exact-boundary and multi-boundary delta handling;
- exactly one callback on active entry;
- immutable callback request containing exact action, locked aim, geometry, maximum targets, ordered effect records,
  accepted sequence, and `0`／`48 px` movement intent;
- hit, miss, rejected, malformed, and invalidated-callback results all release the lease;
- reset and clear before active release the lease without invoking the callback;
- final idle has no pending lease, result, effect record, or movement intent;
- active query count returns to `0`, emergency active／use counts remain `0`, and stale／duplicate release cannot
  corrupt the accepted Stage A pool;
- debug state／result records are read-only and contain the fields required by `MFO-WO-P2-2B-007`.

No physics query, target selection, damage application, part state, or actor movement may be added to obtain coverage.

## 5. Runner authoring closure and fixed formal sequence

Use only:

`C:\Users\osato\OneDrive\ドキュメント\MF\material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe`

Required identity:

- size: `198152` bytes
- SHA-256: `D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`
- version: `4.7.stable.official.5b4e0cb0f`

Before candidate execution, QA may run parser／import-only checks needed to finish the additive runner and generate
its single UID. It must not execute the runner during this authoring closure. Record all parser attempts. Freeze and
hash the final runner before the formal sequence; no runner edit is allowed after candidate behavior is observed.

Run the following formal sequence once, in order, preserving commands, numeric exits, stdout／stderr, and relevant
hashes:

1. engine identity and `--version`;
2. headless editor import／parse;
3. new Stage B action-kernel runner;
4. corrected Stage A runner, requiring `71 / 71`;
5. Phase 1 runner, requiring `36 / 36`;
6. Slice 2-A runner, requiring `120 / 120`;
7. Slice 2-A correction runner, requiring `39 / 39`;
8. unchanged main-scene headless smoke, requiring exit `0`, successful definition validation, and no RHL violation;
9. candidate／path／UID／protected-file audits, `git diff --check`, nonignored-untracked audit, and final clean audit.

Stop at the first formal non-pass. Do not edit the frozen runner to match observed candidate behavior, repair the
candidate, change engines, rebaseline values, or rerun a failed formal command as Pass.

Release export and exported smoke are deliberately `Not run`: this kernel／data package is not connected to the main
scene, so a main-scene export would not independently execute it. Confirm export configuration is unchanged, but do
not create or validate a new artifact.

Physical gamepad, KBM／user feel, performance／P95, PREACK, A／B／C, OneDrive／power changes, and Gate 2 are
`Not run / Deferred` or prohibited.

## 6. Result and return

Return exactly one recommendation:

- `Pass / isolated Stage B action kernel and data validated`;
- `Fail / candidate implementation or approved-data nonconformance`; or
- `Blocked / validation infrastructure or evidence incomplete`.

A runner or evidence defect is `Blocked`, not proof of a candidate defect. Attribute `Fail` only when frozen
candidate behavior or data directly violates the Approved order.

Commit runner／UID／new report／new evidence as one QA content commit, then commit the final
`docs/handoffs/qa.md` update separately. Push only the required QA branch and return:

- starting, QA-content, and QA-handoff commits;
- candidate and runner identities;
- exact changed paths;
- every executed command, exit, assertion total, and evidence path;
- local／origin equality and clean status;
- all `Not run / Deferred` items.

Stop after return. QA must not fix the candidate, merge, integrate, start Slice 2-C／2-D, run performance acceptance,
or evaluate Gate 2. Even a Pass requires separate supervisor acceptance and a new explicit follow-on order.
