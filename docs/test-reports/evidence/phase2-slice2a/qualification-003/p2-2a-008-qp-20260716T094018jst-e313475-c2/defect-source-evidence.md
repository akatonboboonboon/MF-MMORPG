# Terminal LIVE contract audit

Formal classification: **Fail / harness defect**.

The harness self-reported PREACK, LIVE runner, launcher, and controller as `0 / Pass`. Those self-results do not
override the explicit evidence and ordering requirements in MFO-WO-P2-2A-008. The fixed stage and runtime evidence
show three contract defects.

## MFO-P2-2A-QA-005 — per-sample slot evidence missing

Work-order Section 7.5 requires every complete sample to record `performance_slot_launch_count=0` before expected-value
assertions. The LIVE journal contains 61 `live_sample` entries, but the required key appears in `0 / 61` payloads.
The controller's final result does contain a global slot count of `0`; that is not the required per-sample evidence.

Fixed evidence:

- [`runs/live-001/evidence.journal.jsonl`](runs/live-001/evidence.journal.jsonl): all 61 original sample records.
- [`live-contract-audit.json`](live-contract-audit.json): `performance_slot_field_present_count=0` and
  `performance_slot_field_missing_count=61`.
- [`source/MfoQaNative.cs`](source/MfoQaNative.cs): line 3802 builds the sample without the field; line 3803 appends it.

## MFO-P2-2A-QA-006 — n=0 precedes sentinel cleanup

Work-order Section 7.4 requires sentinel exit and cleanup, then a `settle_origin` record, then immediate persistence of
sample `n=0`. The durable journal order is instead:

```text
sequence 11  sentinel_ready
sequence 12  live_sample n=0, target=actual=63482625
sequence 14  settle_origin_after_sentinel_exit, settle_origin=63482625
sequence 15  owned_child_exit, exit=23, raw_streams_flushed=true
sequence 16  sentinel_complete, exit=23, raw_tokens_exact=true
```

The fixed source confirms this is a mechanism-order defect, not merely an event-label issue. Lines 3768–3773 run
`CaptureLiveSample(... n=0 ...)` inside the exit-observed callback. Stream finalization, job drain, and the
`owned_child_exit` append occur later at lines 890–909. The explicit `sentinel_complete` record is later still.

Fixed evidence:

- [`runs/live-001/evidence.journal.jsonl`](runs/live-001/evidence.journal.jsonl), sequences 11–16.
- [`live-contract-audit.json`](live-contract-audit.json), `sentinel_cleanup_order`.
- [`source/MfoQaNative.cs`](source/MfoQaNative.cs), lines 869–910 and 3766–3775.

## MFO-P2-2A-QA-007 — LIVE field-completeness result not preserved

Work-order Sections 2.3 and 7.1 require the separate evaluation or closure after each durable LIVE pending observation
to record both readback and required-field completeness. The PREACK evaluations do this. The two LIVE evaluations
record `pending_readback_success=true` but omit `pending_field_completeness_success`.

The runner's later receipt happens to carry a runner-side completeness value. The launcher evaluation, launcher
receipt, and launcher result preserve no launcher pending-field-completeness result. The launcher therefore lacks the
required durable evaluation/closure evidence.

Fixed evidence:

- [`runs/live-001/live-activation-evaluation.json`](runs/live-001/live-activation-evaluation.json).
- [`runs/live-001/launcher/launcher-live-evaluation.json`](runs/live-001/launcher/launcher-live-evaluation.json).
- [`runs/live-001/runner-receipt.json`](runs/live-001/runner-receipt.json).
- [`runs/live-001/launcher/launcher-receipt.json`](runs/live-001/launcher/launcher-receipt.json).
- [`source/MfoQaNative.cs`](source/MfoQaNative.cs), lines 2151–2258 and 2318–2414.

## Classification basis

Work-order Section 8 classifies missing required evidence and ordering／cleanup mechanism failures as
**Fail / harness defect**. Host prerequisites were stable, global slot and A／B／C launch counts were `0`, and the
61-sample cadence otherwise completed. No automatic repair, reseal, or retry was performed after the terminal audit.
