# FS-A Option A Integrated Revalidation

## Outcome

`Technical Pass / promotion pending manual KBM and/or user feel`.

The qualifying automated sequence passed `22 / 22` invocations and provides technical support for all `15 / 15` Contract Section 10 items. Manual revalidation is `3 Pass / 0 Fail / 0 Blocked / 18 Not run`. No candidate defect was reproduced. Promotion remains stopped because composite KBM/readability items remain manually incomplete. This work order performs no promotion or Gate action.

## Identity and frozen boundaries

| Identity | Value |
|---|---|
| Work order | `MFO-WO-FS-A-30-003` |
| Branch | `codex/fast-slice-fs-a-revalidation` |
| Frozen candidate | `f03a43d2339e9772a15db1c591a31f5e4f92cca2` |
| 00 review | `ba688730e57564bbb883035972bba9ff2224cd50` |
| Issued/tested source | `29c22763c41abaace46430395dd1bdfd14caaf66` |
| Candidate/review/issuance prototype tree | `2a66e4c06308a47678e8888a739b87ffd33d1ee8` |
| Godot | `4.7.stable.official.5b4e0cb0f` |

Candidate, tests, contract, work order, production paths, and historical validation evidence were read-only. Historical final `3968be22d206bb66602dfc23efeb6bb372211461`, automated `17 / 17`, technical `13 / 13`, and manual `0 / 6 / 11 / 2` remain separate reference-only records and were not copied or rewritten.

## Preparation history

The first new QA evidence orchestrator attempt stopped before archive creation and before any Godot invocation because tool discovery looked for `.tools` under the worktree. It exited `1`, did not evaluate the candidate, and is recorded in `preparation-attempt-001.json`. 00 classified it as a QA-owned preparation defect and authorized one bounded evidence-root correction.

The qualifying run used a unique full-repository issuance archive:

- Stage: `C:\tmp\mf-fs-a-reval-auto-20260815-001` (cleaned after readback).
- Archive: `C:\tmp\mf-fs-a-reval-auto-20260815-001.tar` (cleaned after readback).
- Bytes/SHA-256: `186992640` / `7b3c2b8e82d58f3e403652ec588e98552b6afaef586e41f62e0f24add1fb53ba`.
- Embedded commit: issuance `29c22763c41abaace46430395dd1bdfd14caaf66`.
- Pre-import `.godot`: absent. Post-import cache: present.
- Prototype payload: `97 / 97` files, mismatch `0`, tree `2a66e4c06308a47678e8888a739b87ffd33d1ee8`.

The prior 00 candidate-smoke archive hash belongs to a prototype-scoped archive and is not compared as if it were the same full-repository artifact.

## Required automated sequence

All exact argv, separate stdout/stderr, numeric exits, timestamps, and hashes are in `commands/`, `exits/`, `logs/`, `command-metadata/`, and `execution-manifest.json`.

| # | Invocation | Exit | Required marker / rule |
|---:|---|---:|---|
| 1 | Godot version | 0 | Exact 4.7 stable version |
| 2 | Fresh editor import | 0 | Filesystem/class update complete |
| 3-10 | Integration, Gameplay, Presentation parse checks | 0 each | No forbidden diagnostics |
| 11 | Integration self-check | 0 | `checks=236 ... one_loop=true presentation_parity=true` |
| 12 | Integrated `fs_a_main.tscn` launch | 0 | No forbidden diagnostics |
| 13 | Gameplay self-check | 0 | `PASS: full gameplay loop` |
| 14 | Gameplay arena scene | 0 | No forbidden diagnostics |
| 15 | Presentation self-check | 0 | `snapshots=5 spatial_schema=true anchors=40 geometry=line+sector tracking_positions=5 tracking_aims=3 events=3 payload_variants=9 invalid_updates=20 deep_read_only=true` |
| 16-17 | Presentation shell/preview smokes | 0 each | No forbidden diagnostics |
| 18 | Candidate-independent QA skeleton | 0 | Fixture Pass only; not candidate acceptance |
| 19 | Existing project main smoke | 0 | Definitions valid; RHL violation count `0` |
| 20 | Phase 1 regression | 0 | All Phase 1 tests Pass |
| 21 | Slice 2-A regression | 0 | `120 assertions` |
| 22 | Correction regression | 0 | `39 assertions` |

Diagnostics: Integration expected rejection warnings `4`; Presentation expected invalid-spatial warnings `20`; other warnings `0`; `ERROR` `0`; `SCRIPT ERROR` `0`; terminal `FAIL` `0`.

Pre-commit evidence review found one terminal blank line in 16 stdout captures. Those files are stored as normalized execution logs, not unlimited byte-exact raw logs. log-normalization.json preserves each original and normalized size/SHA-256, exact removed suffix, semantic-line equality, and a byte-exact reconstruction rule. No candidate/test rerun occurred and no result changed.

The QA skeleton at invocation 18 is candidate-independent preparation coverage. It never substitutes for Gameplay, Presentation, integration, or manual candidate evidence.

## Option A technical anchors

Gameplay qualifying output individually supports out-of-range light/heavy misses; no-teleport movement/evade approach and actor/snapshot parity; in-range light/heavy target/damage/recovery/exact-once events; player positive-to-zero defeat latch; player/enemy pending work stop; post-defeat input freeze; fail-closed invalid configure; successful reset; and the existing boss/wreck/harvest/result/rematch/round-two loop.

Presentation qualifying output supports five spatial snapshots, 40 anchors, line/sector geometry, tracked player/aim/boss/part/wreck/harvest positions, 20 fail-closed invalid updates, event anchoring, and deep read-only behavior.

## Contract Section 10 mapping

| # | Requirement | Automated technical status | Manual boundary |
|---:|---|---|---|
| 1 | Import/parse/launch | Pass | Real GUI launch also reached |
| 2 | Move/aim/evade/spatial | Pass | Visible movement Pass; aim/evade Not run |
| 3 | Light/heavy input/timing | Pass | Composite manual row Not run |
| 4 | Two telegraphs warning/evasion/geometry | Pass | Manual readability/evasion Not run |
| 5 | Integrity/Deformation change/reset | Pass | Manual named-HUD readability Not run |
| 6 | Player defeat latch, both-side stop, invariants | Pass | Prompt-level visible stops observed; composite manual rows Not run |
| 7 | Part break | Pass | Manual recognition Not run |
| 8 | Boss HP zero exact once | Pass | Canonical HUD field not manually read |
| 9 | Boss zero stops AI/attack/hit | Pass | Explicit manual hostile-stop Not run |
| 10 | User-visible spatial parity | Pass | Composite manual parity/readability Not run |
| 11 | Wreck exact once | Pass | WRECK reached; full manual composite Not run |
| 12 | Three harvests/duplicate rejection | Pass | First collection of A/B/C succeeded alive; duplicate manual check Not run |
| 13 | Result after all collection | Pass | Result observed after all three; `only after third` manual check Not run |
| 14 | Complete rematch/round two | Pass | Rematch/round-two movement/attack observed; complete reset Not run |
| 15 | Presentation-disabled Gameplay parity | Pass | Automated authority comparison |

Technical total: `15 / 15 Pass`. The assertion count alone is not acceptance; individual anchors above and durable logs are the evidence. Manual incompleteness prevents `Pass / promotion recommended`.

## Manual revalidation

Manual archive/source identity matches the qualifying issuance archive. Fresh editor import exited `0`, generated the global class cache, and every GUI session used the real integrated scene. Preview was never used. All GUI sessions exited `0` with diagnostic warning/error/SCRIPT ERROR/terminal FAIL count `0`; those logs prove launch/normal close only.

The exact user text, QA prompts, normalized direct observations, QA/00 determinations, and 21 rows are in `manual-attempt-003.json`. The strict manual count is:

- Pass: rows `1`, `2`, `21`.
- Fail: none.
- Blocked: none.
- Not run: rows `3-20` except row `2`.

Key provenance boundary:

- The tester reported working movement, generic attack, incoming damage, and outgoing damage.
- `LMB`/`RMB` was a QA instruction abbreviation question, not a candidate UI finding.
- The first post-defeat E/collection observation occurred without an affirmed positive-Integrity precondition. 00 classified it as non-qualifying for alive-harvest acceptance, not a candidate Fail.
- In a fresh positive-Integrity retry the tester completed every listed A/B/C collection, result, rematch, and round-two movement/attack step. The exact reply was `全部できました`.
- That reply is not expanded to duplicate rejection, result absence before the third collection, complete reset, hostile-stop, or unrelated readability.
- Session B reply `②確認できました。` is retained as a prompt-level visible player/enemy stop observation. Granular stop and invariant details remain automated corroboration and do not upgrade composite manual rows.

## Pass/Fail conditions and disposition

- Candidate Fail requires a reproducible frozen-candidate parse/assertion/functional defect under the required preconditions. None was reproduced.
- QA infrastructure Blocked applies only when runner/launcher/host prevents evaluation. The initial evidence-orchestrator stop was corrected before the qualifying run and did not block final evaluation.
- Full Pass/promotion recommendation requires every required technical and manual/readability/feel condition. Manual KBM/readability remains incomplete.
- Current disposition: `Technical Pass / promotion pending manual KBM and/or user feel`; promotion remains stopped.
- Whole-line stop conditions: none. Only the candidate/revalidation branch is in scope.
- Shared contract change needed: no.

## Deferred / Not run

- Physical gamepad: `Not run / Deferred`.
- Performance, P95, maximum load, long-run: `Not run / Deferred`.
- Optional export: `Not run`.
- OQ-001 and OQ-005 remain Open; no E-retry binding, automatic retry, new phase/field/event/UI, or defeat retry was added or expected.

## Scope, cleanup, and evidence

Production Gameplay, Presentation, integration, data, tests, project settings, shared contract, work order, and old validation artifacts were not modified. QA changes are limited to the new report, checklist, new evidence root, and append-only QA handoff.

Automated stage/archive were deleted only after artifact/hash readback; both are absent. Manual stage/archive remain at:

- `C:\tmp\mf-fs-a-reval-manual-20260815-001`
- `C:\tmp\mf-fs-a-reval-manual-20260815-001.tar`

Godot process count at final manual capture: `0`. 00 owns exact cleanup after Return acceptance.

Evidence root: [`../evidence/fast-slice/fs-a-integrated-revalidation/`](../evidence/fast-slice/fs-a-integrated-revalidation/). Core summaries: `automated-results.json`, `source-hashes.json`, `execution-manifest.json`, `historical-validation-reference.json`, `cleanup.json`, `manual-attempt-003.json`, `log-normalization.json`, `scope-audit.json`, and self-excluded `evidence-manifest.json`.
