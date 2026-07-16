# Phase 2 Slice 2-A QA Harness LIVE Evidence Requalification Report

- Work order: MFO-WO-P2-2A-009
- Date: 2026-07-16 (Asia/Tokyo)
- Owner: 30 QA・性能・レビュー
- Supervisor starting commit: 6c0d5e04c1c70692c57f18f98416b7ebff324706
- Supervisor clarification commit: 45374c3545204279ae733df0e7c3d9871954fb08
- QA branch: codex/phase2-slice2a-harness-live-evidence-requalification-qa
- QA receipt / preparation HEAD: f4986e7fdd7bfbbb5983e98c1dfb2129ebab08a4
- Stage ID: p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1
- Current state: PREPARED / waiting for independent supervisor audit and exact QUALIFICATION WINDOW READY
- Final recommendation: Pending; PREACK, user activation, and LIVE have not run
- Performance slot launch count: 0
- Gate 2 / Slice 2-B: Locked / not evaluated

## 1. Current result

The fresh Stage P candidate completed INIT, repository-state capture, CONTRACT, all five mandatory preparation
modes, and SEAL in the fixed order. All five modes returned native exit 0 / Pass. The final stage is sealed and
ReadOnly, and its external run-evidence root remains absent.

This is not a final Pass recommendation. PREACK, exact user START_ACK, and the one non-performance LIVE
requalification require a later exact READY token from 00. No qualification window has started.

## 2. Exact identities

| Identity | SHA-256 |
|---|---|
| Qualification manifest | da49eaf1d24dfce39dba43d6babd649c77809450c5257696405cb15393acdcbf |
| Preparation receipt | bcbafcad629d0045184bfe5bafae1637683e93bd087264d14e7cc9721b17f050 |
| Preparation audit | f5e21f872ff492d743d81fa36ff161a35899a8a7b8d4d2ec24583e7402bebf25 |
| Post-seal audit | 8c3db1c84290966d3a7f437d5e5e70a698c8caf7e1c6facde9b8b34b7548dbc9 |
| Component contract | 0785b8e68cba53284e989bda6c7893884b03cfbf69b38203e19142f285f48bc0 |
| Repository-state evidence | 5d9bfb4c10445e23c3c45ddb07312187ba36cf144f1c4b120db957da7e37ac8d |
| Source-diff audit | c2bfc366a7431baf5f91dddc64fec7e08d61226cf3335a46bb11b5dbf54414b5 |
| Final native source | 46b5bead5bae9c0a049a7c3acc4e9693aab52138546482f4546dad1fb616631d |
| StagePreparer source | b9534738412b8cd81b6ad34f69cb38958bf2a8918ad29af2dbfd9e6046def1b8 |
| RunPreparation source | bfcbebfb63668ce121e8653d77c1c5c5e488b075eb7dca27fafeb713dfc57db6 |
| Repository recorder source | add44f21f64aad0fbd842ce73f1f29c520078e4ef5f582df800c9cd96815d666 |

The repository-state record binds HEAD and origin to f4986e7, binds its direct parent to clarification commit
45374c3, confirms 6c0d5e0 is an ancestor, confirms the receipt changed only docs/handoffs/qa.md, and records a clean
worktree.

## 3. Correction and clarification verification

- Durable live sample contract: every production-built sample includes performance_slot_launch_count=0 before
  journal persistence; missing and nonzero values are rejected after durable readback and hashing.
- Sentinel contract: owned_child_exit, sentinel_complete, settle_origin_after_sentinel_exit, then live_sample n=0
  are verified as a contiguous durable order. The contract self-test used the production sentinel path and ended
  with zero active owned processes.
- LIVE evaluation contract: runner and launcher evaluations separately persist pending_readback_success and
  pending_field_completeness_success. Positive fixtures require both true; missing-field fixtures retain readback
  true and completeness false before rejection.
- Exact activation: production reads raw bytes, constructs BOM-less expected UTF-8 bytes, and compares bytes
  directly. Source audit found zero Trim/TrimEnd/newline/whitespace normalization references in the validator.
  The exact positive fixture has no BOM, CR, LF, or CRLF. Named extra_cr, extra_lf, and extra_crlf fixtures contain
  exactly the expected additional bytes and are rejected by the same production validator.
- Source diff: 51 changed hunks, unauthorized changed hunks 0, unrelated regions byte-identical, frozen -008
  baseline SHA-256 verified.

## 4. Stage QP

| Mode | Invocation SHA-256 | Result SHA-256 | Journal SHA-256 | Result |
|---|---|---|---|---|
| QP_DRYRUN | a1d9161a84f8b53c1ac959fe7cc19d761d71cf758c0589dce92658ce2e7ffd6c | 9d84d894ca82b3a863e555787cd8be2fbf1916c8f3f171a95a8394e11a5b55b5 | 27bce4ed268bf1f2378d12bf08fadfc0ea6f66a8dcb914620af4d46cc49de258 | 0 / Pass |
| QP_SELFTEST | 7104906be164c4ee713ff75c8ff4b8bc1fa9f4f8795412d0153ba589d27e40cc | a19651a7cfc90c78e531fc30e4862bfbef839b4fab13b853edc5b634de96880b | f1185752219822354263ac29f59e3fa83f2dd3b44f3509608b0e252289da780d | 0 / Pass |
| QP_POWER_INPUT_SMOKE | 8aafab8570c4127c7ced82f009884eab2411b68a6e98af729ae4854d9f393493 | e0ba2948046b7f068552bc313b839ea38809f49278f886a288d46af6ac6dd405 | 445157c1babba445b37e057a7af56ff986f0926342675b627196bf1552215670 | 0 / Pass |
| QP_PREACK_CONTRACT_SELFTEST | 6561170a2b5ebb3eeea9bb2b308400168180209b9f9b1895205e9f67029f41f4 | 4ab8061041b756fb1b4138a5592861fb1950ffb51b94e3b51f972e0de227ec76 | fcbc83bc77617762f693aab1648245291a0690d5025383fa7e0dbcc5acdbb059 | 33 / 33 Pass |
| QP_LIVE_EVIDENCE_CONTRACT_SELFTEST | a5e9131958bbb01451f23b45e1932733e82527ad85e4f1eb86ed50943eadbf1f | 585cf78c9a02e7b813f1d37f04c183ddc2a10be8a5dda65562beb3775485c8ff | cb699616ef8894e030df53e8578cb5067f6426f30d0c3a48bdf2c5b2448b058e | 20 / 20 Pass |

All five results record performance slot 0, A/B/C launch 0, and final owned runtime 0. The fifth mode records
controller launch 0. QP_POWER_INPUT_SMOKE used the production direct-out Guid power/input path.

## 5. Seal and tracked evidence

- External stage: 232 / 232 files ReadOnly; 77 / 77 directories ReadOnly.
- External run-evidence root: absent.
- Stage nonbinary copy: 227 files copied and SHA-256 matched; 5 EXE/DLL payloads excluded.
- Preparation tool sources: 3 files copied and SHA-256 matched; compiled payloads excluded.
- Tracked EXE/DLL count: 0.
- SHA256SUMS.txt: 237 / 237 payloads match; manifest self excluded; SHA-256
  e496d4758aa4178c2092f13af31f49bf1870d646aa07f5bdbf81853447567795.
- Evidence-local .gitattributes uses * -text to preserve raw bytes.
- Old -005, -006, -007, and -008 stages were not changed, executed, resealed, or reused.

Evidence root:
evidence/phase2-slice2a/qualification-004/p2-2a-009-qp-20260716T131715jst-6c0d5e0-c1/

## 6. Pass / Fail / Blocked / Not run separation

| Component | State |
|---|---|
| Source scope, five-mode Stage P, seal, ReadOnly closure | Pass |
| PREACK | Not run; exact READY not received |
| User START_ACK | Not run |
| LIVE harness requalification | Not run |
| Host prerequisite classification | Not evaluated for LIVE |
| Performance slot / P95 / FPS / frame recording | Not run / prohibited; launch count 0 |
| KBM / user feel | Not run / prohibited |
| Physical gamepad | Not run / Deferred |
| A/B/C and game | Not run / prohibited; launch count 0 |
| Final Pass / Fail / Blocked recommendation | Pending |

## 7. Route

Return the exact PREPARED token to 00 and wait. Do not start PREACK or LIVE until 00 independently audits the branch
and sends the exact QUALIFICATION WINDOW READY token containing this stage ID and the three supplied digests.
This PREPARED result does not authorize a performance slot, P95, KBM, A/B/C, game launch, Gate 2, or Slice 2-B.
