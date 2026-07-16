# QA / Performance / Review Handoff

- Owner role: `30 QA・性能・レビュー`
- Updated by `30 QA`: 2026-07-16
- Current milestone: M2 / Slice 2-A
- Authorization: `00統括` issued MFO-WO-P2-2A-009 at `6c0d5e0`
- Phase 1 package source baseline: `a13505e8fbf82962e049b9101a87593a6692d2c7`
- Required starting state: commit containing the active work order; record exact tested `HEAD`
- Current status: MFO-WO-P2-2A-009 **received; receipt recorded; source unchanged**
- QA planning base: `6c0d5e04c1c70692c57f18f98416b7ebff324706`

Active work order:
[`../work-orders/phase2-slice2a-harness-live-evidence-correction-requalification.md`](../work-orders/phase2-slice2a-harness-live-evidence-correction-requalification.md)

Required diagnostic report:
[`../test-reports/phase2-slice2a-harness-live-evidence-requalification.md`](../test-reports/phase2-slice2a-harness-live-evidence-requalification.md)

Required evidence root:
[`../test-reports/evidence/phase2-slice2a/qualification-004/`](../test-reports/evidence/phase2-slice2a/qualification-004/)

Original Slice 2-A report: [`../test-reports/phase2-slice2a-validation.md`](../test-reports/phase2-slice2a-validation.md)

Completed Gate 1 work order: [`../work-orders/phase1-gate1-power-revalidation.md`](../work-orders/phase1-gate1-power-revalidation.md)

Gate 1 report: `docs/test-reports/phase1-gate1-power-revalidation.md`

Deferred gamepad work order: [`../work-orders/phase1-gate1-manual-validation.md`](../work-orders/phase1-gate1-manual-validation.md)

Previous report: [`../test-reports/phase1-gate1-manual-validation.md`](../test-reports/phase1-gate1-manual-validation.md)

## LIVE evidence correction and requalification receipt — MFO-WO-P2-2A-009

- QA branch: `codex/phase2-slice2a-harness-live-evidence-requalification-qa`
- Supervisor starting commit: `6c0d5e04c1c70692c57f18f98416b7ebff324706`
- Authorization: per-sample slot evidence, sentinel cleanup-before-sampling order, runner／launcher LIVE
  field-completeness evidence, mechanical `-009` identity rollover, bounded seal-before five-mode tests, and one fresh
  non-performance harness requalification only
- Receipt state: received and recorded on 2026-07-16; harness source unchanged; stage not created; PREACK／LIVE not started
- Prohibited／not run: performance slot, P95, KBM, A／B／C, game, game code／tests／recorder／scene／project／values
- Gate 2／Slice 2-B: Locked; not evaluated or authorized

## Harness contract correction and requalification receipt — MFO-WO-P2-2A-008

- QA branch: `codex/phase2-slice2a-harness-contract-requalification-qa`
- Supervisor starting commit: `e313475b3ba1bb7d4c23551f96bdc0eb9dc73d18`
- Authorization: preparation receipt／preparation-audit binding, exact `MFO-WO-P2-2A-008 START_ACK`,
  persist-complete-record-before-assert, seal-before contract self-test, and one fresh new-stage requalification only
- Preparation／execution state: Stage QP complete, final candidate sealed, PREACK and one LIVE sequence executed;
  terminal **Fail / harness defect** after formal evidence audit
- QA receipt commit: `a8622893f73cb55771e69cae07f5edf28b13d659`
- QA PREPARED／execution HEAD: `da8eab0be069069cec0d59986a69ae5ad936ea31`
- Final stage ID: `p2-2a-008-qp-20260716T094018jst-e313475-c2`
- Final native source SHA-256: `01ed440a0973471ab78c057910f91101e22e04620bd33c49d52259d9cb72e810`
- Sealed manifest SHA-256: `a88e45cee008c2f774950b7c7144d7f5b263cd3502c97cb87922cd11c0497202`
- Preparation receipt SHA-256: `b20f3804b3511556998a49c805781ebbef22c0b706ee358911acf08f265f6960`
- Preparation audit SHA-256: `fef5686951cf06335d485ee64799ad4217b787040d6961f382bd63f72727a0c7`
- Repository-state evidence SHA-256: `9e8c13cc2899370acb551b3ef6e1c896528943515d839fd52dcdef984cd2a79a`
- Source-diff audit SHA-256: `6b043ff0395d2cd6ddaaad014f96738cef8adb57b9376464eeb6a5c2ca511053`
- `QP_DRYRUN`: invocation `cb80500296452e8dc6b45a4c621fd8b6de5870d58bdb4083f464dc0f3894e52a`;
  result `0 / Pass` SHA-256 `d707489e6f6b13c6b9273a1df85394ea53d5320d92a25e253cd2ed6b8ebda094`;
  journal SHA-256 `b7a47ea537fbe60d5472a2c43c9c5045c3e1cfa742c140f4eec6fd1eb6af41f8`
- `QP_SELFTEST`: invocation `df81d5bbfea2de94187ba7959453b045ead98baeac0946e07e345887f326acd1`;
  result `0 / Pass` SHA-256 `5857ffb9dc6354634725f9a23a6f0b11c8f77368e3f798382a16f43bf447c884`;
  journal SHA-256 `648fd636eb84eed6fdca6988ce54bc20580b92f530af36c0ea39136181e5f9bc`
- `QP_POWER_INPUT_SMOKE`: invocation `416632c2307e766c34ab7b079deececcd4907db03fea7658e610008e15114b65`;
  result `0 / Pass` SHA-256 `6c152e6f746a4bcc5bcb334de7d478c1ae68c8fff8782cf74d3ffe110431bec0`;
  journal SHA-256 `b19514f2f45376079d2c1c58364d1e5923ab53984323c0e6c100ffc26f430d3f`
- `QP_PREACK_CONTRACT_SELFTEST`: invocation `475de2f3294d2a76182d1a17eba973888877e17651d318bcc9731c492caf77d4`;
  result `0 / Pass` SHA-256 `f68d30de794db01ba983398f9740c0607a67e84cc8928ca709bc098c79f34ada`;
  journal SHA-256 `b9ebb803a3125c51d5b437ebb73f9664fc9633bf35a1180fbfe3053582a6df76`
- Contract audit: runner/launcher PREACK and runner/launcher LIVE all persist, read back, and hash before evaluation;
  missing/malformed protocol fixtures Pass; exact `-008` token Pass; old `-006`/`-007` and malformed tokens rejected
- Post-seal audit: files `149 / 149` ReadOnly; stage root and directories ReadOnly; `runs/` absent;
  configured external run-evidence root absent; final QA/forbidden runtime count `0`
- Preserved pre-seal candidate: `p2-2a-008-qp-20260716T093459jst-e313475-c1` remains unsealed and unchanged;
  first three QP modes passed, contract self-test returned `30 / Fail`, result SHA-256
  `289347832057c6a2b401cbfbe47162c89185d8777bd4e8dc2fccacbcd80e448c`
- Pre-seal repair: static audit marker lookup matched its own string literal; only three Section 5 lookup origins were
  corrected, production PREACK/LIVE behavior was unchanged, and all four tests plus affected identities were regenerated on `c2`
- Stage QP prohibition outcome: performance slot launch count `0`; P95, KBM, user feel, and A/B/C launch are Not run
- PREACK: runner／launcher `0 / Pass`; OneDrive `0`, AC online, effective Best performance, input API success, slot `0`;
  `preack_sha256=e1db502d554b960341f6ca8a60cf1596f0302dcbcf7ca7118f7c3c32bb2a18f2`;
  `preack_evaluation_sha256=a75e144773d802cb5975a3e6eb1f156874aec14e96cb612a8ac7a1e031d10c1a`;
  `preack_tick=63136609`
- Activation: exact user `MFO-WO-P2-2A-008 START_ACK` accepted; 519 bytes; SHA-256
  `1a5a25b1ffd449ed545ba14eb8f373753c189a03da37099a6b27b35c6647bce0`
- LIVE self-results: runner／launcher／controller all `0 / Pass`; 61 samples; duration `60000 ms`; global slot `0`;
  final owned runtime `0`; journal 145 records／hash chain valid
- Formal LIVE finding `MFO-P2-2A-QA-005`: all `61 / 61` samples omit required
  `performance_slot_launch_count=0` field
- Formal LIVE finding `MFO-P2-2A-QA-006`: `n=0` was persisted before `settle_origin` record and before sentinel
  stream flush／job drain／owned-child exit／complete cleanup evidence
- Formal LIVE finding `MFO-P2-2A-QA-007`: runner／launcher LIVE evaluations omit
  `pending_field_completeness_success`; launcher receipt／result preserve no launcher completeness outcome
- Terminal classification: **Fail / harness defect** under work-order Section 8; host prerequisite was stable and is
  not the classification basis
- Freeze: final stage `149 / 149` files ReadOnly; runtime evidence `27 / 27` files ReadOnly; c1 pre-seal candidate
  `147 / 147` files ReadOnly at terminal closure; automatic repair／reseal／retry `0`
- Fixed evidence: final-stage `141` + runtime `27` + c1 pre-seal `139` = `307 / 307` source／destination hashes match;
  tracked EXE／DLL `0`; evidence payload manifest `321 / 321`, SHA-256
  `58827846f38becad61f08104db889f27b78f68e34f36527a891b5b8967200e25`
- Formal report:
  [`../test-reports/phase2-slice2a-harness-contract-requalification.md`](../test-reports/phase2-slice2a-harness-contract-requalification.md)
- Formal evidence:
  [`../test-reports/evidence/phase2-slice2a/qualification-003/p2-2a-008-qp-20260716T094018jst-e313475-c2/`](../test-reports/evidence/phase2-slice2a/qualification-003/p2-2a-008-qp-20260716T094018jst-e313475-c2/)
- Required new stage prefix: `p2-2a-008-qp-`; old `-006`／`-007` stages and evidence remain frozen
- Performance slots: `0`; P95／FPS／KBM／A／B／C launch: prohibited／not run
- Game code／gameplay tests／recorder／scene／project／quality／values／thresholds: unchanged／locked
- Gate 2／Slice 2-B: Locked / not evaluated

Required next route: return the three fixed harness defects to `00統括`; do not repair or rerun this stage, do not
start a new stage, performance slot, P95, KBM, or A／B／C without a new explicit work order. `MFO-HOLD-P2-2A-001`
remains active.

## Harness ABI correction and requalification receipt — MFO-WO-P2-2A-007

- QA branch: `codex/phase2-slice2a-harness-requalification-qa`
- Supervisor starting commit: `2e92cc8d39a146dc72ee74928aeb016d4da65244`
- QA receipt commit: `6d9877a4e33d97d12d54d1aa7b32d4725631a811`
- Authorization: direct-`out Guid` ABI correction, same-production-path seal-before smoke, exact-byte sealing,
  and one fresh harness requalification only
- Preparation state: `PREPARED` sent, then rejected by `00統括`; terminal **Fail / harness defect**
- Stage ID: `p2-2a-007-qp-20260715t231258jst-2e92cc8-c1`
- Sealed manifest SHA-256: `e44acd54ba1b1f01e7628d9a3899242a43fa16164fa9c78bd4d355dff8314c67`
- Preparation receipt SHA-256: `7c3c6dc7d2f015803446ce2db64e8fe2ef5acb25ef17c26bb9fbdaf104dbe6de`
- Component contract SHA-256: `b048e5e4cad4cb1817825ee7ad0062c416dedb84c819b05a30b86ecf78c90fb4`
- Source-diff audit SHA-256: `3c32686219fadce0d328cc6ccd81e5d71603e2add8a5587cb7067c434202ca86`
- Repository-state evidence SHA-256: `20dc6ac4b3b81e57c015aa106a765e7633117ac133e11220d61181bcbdca9848`
- Repository-state proof: required branch／HEAD／origin exact, supervisor ancestor true, status clean
- QP_DRYRUN: `0 / Pass`; journal SHA-256 `8a350f39100e9d79c140bb92e1ce09fe01652a2f90086868a320ca3e8278352c`
- QP_SELFTEST: runner／launcher／controller `0 / Pass`; journal SHA-256 `73eca982ca4f1dad7b909da6c794658f8c7d3a7c88ff295ee15ee475a8bfc31c`
- QP_POWER_INPUT_SMOKE: `0 / Pass`; production path call `1`; API／Guid／UInt32 round-trip Pass;
  journal SHA-256 `1b9732987397721f8006d074fd669d0ed20c5d3e7c7f0ad02adbcb98c34acf47`
- Sealed rehash: sealed files `14 / 14`; preparation evidence `69 / 69`; readonly files `85 / 85`
- Supervisor terminal findings:
  1. PREACK does not load／validate／hash／record the preparation receipt identity
  2. `RequireExactActivation` still requires `MFO-WO-P2-2A-006 START_ACK`
  3. PREACK evaluates identity／OneDrive／power／runtime before the complete prerequisite record is persisted,
     read back, and hashed
- PREACK／PREACK_READY／START_ACK／LIVE／qualification window: Not run／not produced／not received／not run／not started
- Frozen stage: no repair, reseal, retry, or new stage; external files `85 / 85` ReadOnly; `runs/` absent
- Fixed evidence: stage-derived nonbinary payloads `77 / 77` byte-identical; executable／DLL commit `0`
- Evidence: [`../test-reports/evidence/phase2-slice2a/qualification-002/p2-2a-007-qp-20260715t231258jst-2e92cc8-c1/`](../test-reports/evidence/phase2-slice2a/qualification-002/p2-2a-007-qp-20260715t231258jst-2e92cc8-c1/)
- Evidence payload manifest: `86 / 86` match; `SHA256SUMS.txt` SHA-256
  `465db27591c3cd26be0cd0594cb46bb214a016e27a4f0779f4e896153833205a`
- Authored-file cached diff check: exit `0`; whole immutable-evidence diff check: exit `2` from preserved original
  CRLF only, with no byte rewrite (`77 / 77` copy hashes and `86 / 86` payload hashes remain exact)
- Report: [`../test-reports/phase2-slice2a-harness-requalification.md`](../test-reports/phase2-slice2a-harness-requalification.md)
- Frozen input: `-006` stage／report／evidence remain unchanged and are not reused as a runtime stage
- Performance slots: `0`; P95／FPS／KBM／A／B／C launch: prohibited／not run
- Game code／gameplay tests／values／Gate 2／Slice 2-B: unchanged／locked
- Final recommendation: **Fail / harness defect**; returned to `00統括`; no automatic follow-on work

## Harness qualification formal result — MFO-WO-P2-2A-006

- QA branch: `codex/phase2-slice2a-harness-qualification-qa`
- Supervisor order commit: `2d5ef1ab149629eea9e9f73994baf1304228611e`
- QA receipt／execution HEAD: `e87bf429e9b7b18ad717ffb0314e7c2052b013e0`
- Authorization: evidence-harness qualification only under the explicit external-hold exception
- Stage ID: `p2-2a-006-qp-20260715t184405jst-2d5ef1a-c1`
- Sealed manifest SHA-256: `582c65b3430a26834d92bc19951a0f5ebf92b8bf7b4853d8aadddb07de0eb8f7`
- Stage QP dry-run: runner `0 / Pass`; journal 4 records／hash chain valid; final owned `0`; slot `0`
- Stage QP self-test: runner／launcher／controller all `0 / Pass`; journal 18 records／hash chain valid
- Synthetic coverage: native origin／advancing samples／`origin + 600000` deadline、expiry at equality、OneDrive PID `4242` fixture、sentinel READY／release／exit `23` all Pass
- User activation: exact `QUALIFICATION WINDOW READY` received once
- PREACK fresh OneDrive inventory: count `0`, persisted at native tick `18920734`
- PREACK launcher: exit `-1073741819` / `0xC0000005`; unhandled `AccessViolationException` in `NativeApi.EffectiveOverlayGuid`
- Harness cause: `PowerGetEffectiveOverlayScheme` declared as `out IntPtr` and treated as LocalFree-owned pointer instead of direct GUID output
- Launcher structured result／pre-ack record: not produced
- PREACK runner: exit／result `30 / Fail`; final owned runtime `0`; descendants `0`; forbidden runtime `0`; all sealed identities match
- PREACK_READY／START_ACK／LIVE／controller: not sent／not received／not run
- AC overlay／GetLastInputInfo PREACK record: not established; no historical substitution
- Performance slots: `0`; P95／frame measurement／arena／KBM: Not run / prohibited
- A／B／C: identity-only hashes exact; launched `false`; prior `-005` stage reused `false`
- Physical gamepad: Not run / Deferred; user feel: Not run
- Game code／tests／recorder／scene／project／quality／threshold changes: `0`
- Executable／DLL／export pack committed: `0`
- Evidence: [`../test-reports/evidence/phase2-slice2a/qualification-001/p2-2a-006-qp-20260715t184405jst-2d5ef1a-c1/`](../test-reports/evidence/phase2-slice2a/qualification-001/p2-2a-006-qp-20260715t184405jst-2d5ef1a-c1/)
- Evidence payload manifest SHA-256: `b2cb41b04ff4928c45be1065e5e4e0f944137b89cf962b18b92f429fef6722bd` (33 / 33; evidence-local `-text` preservation metadata included)
- Report: [`../test-reports/phase2-slice2a-harness-qualification.md`](../test-reports/phase2-slice2a-harness-qualification.md)
- New QA finding: `MFO-P2-2A-QA-003`; `KNOWN_ISSUES.md` is supervisor-owned and was not edited
- Open questions added: `0`; specification ambiguityではない
- Performance acceptance: `MFO-HOLD-P2-2A-001` remains active
- Gate 2／Slice 2-B: Locked / not evaluated
- Qualification recommendation: **Fail / harness defect**

Prior `-005` clarification required by `00統括`: the `[Environment]::TickCount64` auxiliary field recorded as `0` is
**not** treated as an independent blocker because a distinct nonzero Stopwatch origin drove the actual deadline.
The accepted `-005` disposition remains Blocked based on the recorded OneDrive-family condition together with QA
procedure／harness nonconformance. The frozen `-005` report and evidence are not rewritten. `-006` nevertheless
requires fresh proof using native Windows `GetTickCount64` as the sole canonical monotonic source.

Required next route: qualification windowは終了済み。同sealed stageのretry／repair／reseal、別stage、LIVE、
performance orderを自動開始しない。sealed stageと`preack-001`をfreezeし、`00統括`へexact defectを返して
新しい明示work orderを待つ。game codeは変更せず、Gate 2／Slice 2-Bを承認しない。

## Performance-only rerun formal result — MFO-WO-P2-2A-005

- QA branch: `codex/phase2-slice2a-performance-only-qa`
- Supervisor order／QA start HEAD: `b32fdae63c0ddcb150f5a4678e301f959550ad08`
- QA evidence／report content commit: `60dd270ac3418d09d3e944a2a64beb1b036b0b42`
- Stage ID: `p2-2a-005-20260715t0944jst-b32fdae`
- Preparation manifest SHA-256: `ac2c34644f7d3f2a92d39ebf54f64b1984c14fb330d31ec22b57035381334aa1`
- Stage P: Pass; A／B／C and controller sealed; dry-run exit `0`; slot launch count `0`
- Sealed environment: Windows NT `10.0.26200.0`; Intel64 Family 6 Model 186 Stepping 3; 12 logical; Intel Graphics `32.0.101.7077`; GL Compatibility／1920×1080／standard; post-failure AC／Best performance only
- User activation line: exact stage ID／digest received
- QA procedural nonconformance: measurement-start acknowledgement preceded the required preserved external OneDrive count-zero check
- Controller origin: `2026-07-15T10:25:41.8990234+09:00`
- Controller terminal error recorded: `OneDrive-family process present during settled-60s.` about `1.486 s` after origin
- Triggering OneDrive name／PID: not persisted before throw; later corroborating snapshot only observed `OneDrive.Sync.Service` PID `13496`
- Auxiliary system-wide monotonic field: `0` — preserved historical value; not an independent blocker per `00統括`
- Settled interval: incomplete; CPU preflight attempts `0`
- Matrix: A1／B1／C1／C2／B2／A2 all Not run; valid runs `0`; P95 unavailable／uninterpreted
- Cleanup: controller exited; lock absent; MFO／Godot residue `0`
- Post-run identity: manifest／controller／A／B／C full hashes unchanged
- Corrected-C KBM: frozen prior Pass; not rerun
- User feel: frozen prior `すべて問題ないです`; not re-requested
- Physical gamepad: Not run / Deferred
- QA game／test／recorder／scene／project／quality／threshold changes: `0`
- Executable／export pack copied to tracked evidence: `0`
- New known issues／open questions: `0`; supervisor-owned registry not edited
- Evidence: [`../test-reports/evidence/phase2-slice2a/diagnostic-003/p2-2a-005-20260715t0944jst-b32fdae/`](../test-reports/evidence/phase2-slice2a/diagnostic-003/p2-2a-005-20260715t0944jst-b32fdae/)
- Evidence manifest SHA-256: `d45590b80fbdef5e1b70734d20a6a2e001db542556c8b41efdd073f1b0740227`
- Report: [`../test-reports/phase2-slice2a-performance-only-rerun.md`](../test-reports/phase2-slice2a-performance-only-rerun.md)
- Final recommendation: **Blocked**

Required next route: preserve and freeze the consumed stage and all prior evidence; do not automatically retry or
issue `-006`. `00統括` decides any external-state hold or explicitly bounded future order. `30 QA` does not accept
Slice 2-A, approve Gate 2, or authorize Slice 2-B.

## Controlled rerun formal result — MFO-WO-P2-2A-004

- QA branch: `codex/phase2-slice2a-controlled-rerun-qa`
- Supervisor order／QA start HEAD: `67ba7f34b6e0ee93ca454a6da8d354b0c2e79ebc`
- QA evidence／report content commit: `45eeeb32a525b922eada9624385691a2143fd7db`
- A／B／C source and staged EXE size、SHA-256、`MZ`: all exact Pass
- Environment: Windows `10.0.26200.0`、12 logical processors、Intel Graphics driver `32.0.101.7077`
- Power: AC Online、Best performance／`ded574b5-45a0-4f42-8737-46345c09c238`
- Quiet input: final 10 seconds unchanged、last-input tick `492292203`
- Preflight system CPU: average `38.250224%`、maximum `46.012270%` — threshold Fail
- Preflight OneDrive-family CPU delta: `32.15625 CPU-seconds` — threshold Fail
- Performance matrix: A1／B1／C1／C2／B2／A2 all Not run; valid runs `0`
- Performance component: **Blocked / matrix not started**; no P95 interpreted
- Corrected-C KBM: third independent capture completed in `27.973 s` with foreground lossなし
- KBM stimuli: W／A／S／D、independent mouse、neutral Space、move＋Space、boundary hold、short-interval Space、five-second idle recorded
- User confirmation: all input intentional; all six checklist outcomes and feel `すべて問題ないです`
- KBM component: **Pass**
- User feel: **Pass / no issue reported**
- Physical gamepad: **Not run / Deferred**
- QA game／test／recorder／scene／project／quality／threshold changes: 0
- New known issues／open questions: 0; `OQ-005` unchanged
- Gate 2: Locked; Slice 2-B authorization not issued by QA
- Evidence: [`../test-reports/evidence/phase2-slice2a/diagnostic-002/controlled-20260715-67ba7f3/`](../test-reports/evidence/phase2-slice2a/diagnostic-002/controlled-20260715-67ba7f3/)
- Evidence manifest SHA-256: `f17de23065a66a982515b6d1030e926ad9d8e9c801d0e6a04950f3beb908ca03`
- Report: [`../test-reports/phase2-slice2a-controlled-rerun.md`](../test-reports/phase2-slice2a-controlled-rerun.md)
- Final recommendation: **Blocked**

Required next route: `00統括` reviews performance Blocked、KBM Pass、and the OneDrive-family background-load evidence.
`30 QA` does not modify gameplay、accept Slice 2-A、approve Gate 2、or authorize Slice 2-B.

## Historical performance diagnostic result — MFO-WO-P2-2A-003

- QA branch: `codex/phase2-slice2a-diagnostic-qa`
- Supervisor order／QA start HEAD: `f3450df07f84144ce10dba2584c74a0f3a5b585b`
- QA evidence／report content commit: `a3920f8419419357698c0db47f8aa35b3fd6ba34`
- A source／EXE: `a13505e8fbf82962e049b9101a87593a6692d2c7` / `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199`
- B source／EXE: `295549373fbb3b39deb6079172783ce62c7da532` / `3c15c254fbb8025d88c5636f2175a35f6e325b5368c8098e78b16181090dd4ef`
- C source／EXE: `5261a73707daca03cb160e03a12247886d3f5cce` / `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47`
- B／C detached release exports: exit `0`, distinct `MZ` hashes; B initial missing-output-directory preflight exit `1` preserved separately
- Environment: Windows 11 Home build `26200`, Intel Core 7 150U, Intel Graphics driver `32.0.101.7077`, physical `1920x1200 @ 60 Hz`, GL Compatibility, standard quality
- Power: AC Online, Best performance / `ded574b5-45a0-4f42-8737-46345c09c238`
- Fixed order result:
  - A1: P95 `18.0556 ms`, exit `0`, **Invalid** — only allowed replacement recorded external input
  - B1: P95 `19.0880 ms`, exit `0`, **Invalid** — external input; post-stop-condition diagnostic only
  - C1: P95 `18.3333 ms`, exit `0`, **Invalid** — external input; post-stop-condition diagnostic only
  - C2: P95 `18.3333 ms`, exit unknown, **Invalid** — controller evidence incomplete
  - B2: **Not run** — repeated interference stop
  - A2: **Not run** — repeated interference stop
- Valid acceptance performance runs: `0`; invalid P95 values are not converted into performance Fail
- Load observation: completed metadata runs had system CPU average `72.838%–87.620%`, maximum `90.229%–100%`, OneDrive CPU delta `+23.359–25.969 s`, and changed last-input ticks
- Performance disposition: **Blocked / causality not isolated**; do not return gameplay code to `10` from this evidence
- Corrected-C KBM: **Blocked** on first W due recurring external input; fresh log already contained 9 movement and 8 Attack A requests not issued by QA
- User feel: Not run
- Physical gamepad: Not run / Deferred
- QA game／test／recorder／scene／project／quality／threshold changes: 0
- Private non-game window titles: redacted in Git evidence; PID／time／classification／title hash retained
- New open questions: 0; `OQ-005` unchanged
- Gate 2: Locked; Slice 2-B authorization not issued by QA
- Evidence: [`../test-reports/evidence/phase2-slice2a/diagnostic-001/session-20260714-f3450df/`](../test-reports/evidence/phase2-slice2a/diagnostic-001/session-20260714-f3450df/)
- Evidence manifest SHA-256: `7a651e2a7e321cc1fa3f93390c9c563d52a86776ae0179331726112c0884fbfe`
- Report: [`../test-reports/phase2-slice2a-performance-diagnostic.md`](../test-reports/phase2-slice2a-performance-diagnostic.md)
- Final recommendation: **Blocked**

Required next route: `00統括` reviews the external-input／foreground／background-load evidence and decides whether to
issue a new bounded diagnostic session. `30 QA` does not change gameplay values, accept Slice 2-A, approve Gate 2, or
authorize Slice 2-B.

## Correction Stage B formal result — MFO-WO-P2-2A-002

- QA branch: `codex/phase2-slice2a-correction-qa`
- Correction order commit: `295549373fbb3b39deb6079172783ce62c7da532`
- Correction implementation: `5261a73707daca03cb160e03a12247886d3f5cce`
- QA start／gameplay handoff HEAD: `0727fe562c20fcb781eb9b1d63b260eb9a94f333`
- QA tests／report content commit: `547554183187c24fd8e0ced33a4c381aaf3c4366`
- Fresh Phase 1 regression: `36 / 36 Pass`, exit `0`
- Existing Slice 2-A suite: `120 / 120 Pass`, exit `0`
- Existing suite SHA-256 before／after: `03ecfbd34bfb98333d9bdeff5c6ef90cb477090101ea6e4435511509c1e6e91a`
- Additive correction suite: `39 / 39 Pass`, exit `0`
- Correction cases: exact zero fallback、small `+X / -X / +Y / -Y`、small diagonal normalize、actor direct zero
  reject／small nonzero accept、active中のaim独立をPass
- Inherited behavior: `140 px / 0.20 s`、12／27 ticks、reject／no-buffer、collision layer／mask `4`、bounds、
  mid-step／mid-cooldown／repeated／unknown-actor resetをPass
- Import／main smoke／release export／exported smoke: all exit `0`
- Corrected release: `material-frontier-online/prototype/build/windows/MFO-Phase1.exe`
- Corrected release SHA-256: `28543cb1e45f1e4dd380654200e9336b9e95d8a6e699b4cc5ce0bae26ababb39`
- Environment: Windows 11 Home build `26200`、Intel Core 7 150U、Intel Graphics driver `32.0.101.7077`、
  GL Compatibility、project `1920x1080`、standard quality
- Power: pre／postともAC Online、charging、Best performance／`ded574b5-45a0-4f42-8737-46345c09c238`
- Arena-idle performance run 1: 120 warmup＋600 samples、P95 `33.4643 ms`、47.7472 fps from average、**Fail**
- Arena-idle performance confirmation 2: 120 warmup＋600 samples、P95 `20.0000 ms`、57.7898 fps from average、**Fail**
- Performance finding: `MFO-P2-2A-QA-002`; causality not isolated。ゲーム値／仕様変更は提案しない
- QA corrected-release KBM: Blocked／Not completed。D方向partial movement後にexternal user input検知とwindow
  capture失敗が発生し、full checklistをPassにしていない
- User feel: Not run。修正版に対するuser評価を推測しない
- Physical gamepad: Not run／Deferred
- Memory／GPU timing: unavailable。`static_memory_bytes = 0`をPassにしない
- Attack query count／release: Pass。part count: N/A。minimum-quality readability: Not run
- QA gameplay code changes: 0。additive QA testとQA-owned report／evidence／handoffだけ
- Known issue routing: KI-009 functional correctionはPass evidenceあり、closeは`00統括`待ち。新performance findingを
  `00統括`へ返す
- Open questions added: 0。OQ-005 unchanged
- Slice 2-A correction recommendation: **Fail**
- Gate 2: Locked。Slice 2-B authorizationはQAから発行しない
- Formal evidence:
  [`../test-reports/evidence/phase2-slice2a/correction-001/validation-20260714-0727fe56/`](../test-reports/evidence/phase2-slice2a/correction-001/validation-20260714-0727fe56/)
- Evidence manifest SHA-256: `d1c2c827d37519c4ace69eb4209fc09f3be903379b9c038bfbc822d2f652d31c`
- Formal report:
  [`../test-reports/phase2-slice2a-correction-validation.md`](../test-reports/phase2-slice2a-correction-validation.md)

Required next route: `00統括`が`MFO-P2-2A-QA-002`と未完了KBM evidenceを確認し、bounded performance／manual
再検証を指示する。`30 QA`は性能Failを理由にゲーム値や仕様を変更せず、Gate 2／Slice 2-Bを承認しない。

## Historical Stage B formal result — MFO-WO-P2-2A-001

- QA branch: `codex/phase2-slice2a-qa`
- QA start HEAD: `92f71d7c3e55108a2faecaa6fbf1e1055b0d0b9f`
- Implementation source: `bd01fdf3d048accaa7f5be93afe3be5cfa138201`
- Comparison baseline: `afcd20cd4a02d618a5d7e0e4bc7555a64fa90740`
- QA tests／report content commit: `daf616253d39d48795b509d204f2ebe30177fc03`
- Fresh Phase 1 regression: `36 / 36 Pass`
- Fresh Slice 2-A suite: `119 / 120 Pass`, exit `1`
- Import／main smoke／release export／exported smoke: Pass, all exit `0`
- Confirmed defect: `MFO-P2-2A-QA-001` — deadzone直上の小さいnonzero moveをneutral扱いし、aimへfallback
- Performance: Blocked／Not run; formal precheck時の`PowerLineStatus = Offline`
- QA interactive KBM: Not run on the failing candidate
- User feel: Not run
- Physical gamepad: Not run／Deferred
- New open questions: 0; OQ-005 unchanged
- Gameplay／scene／project setting changes by QA: 0
- Slice 2-A recommendation: **Fail**
- Gate 2: Locked; Slice 2-B authorization not issued by QA
- Formal evidence: [`../test-reports/evidence/phase2-slice2a/stage-b-20260714-92f71d7/`](../test-reports/evidence/phase2-slice2a/stage-b-20260714-92f71d7/)

Required next route: `00統括` issues a bounded correction order for `MFO-P2-2A-QA-001`; `10` changes only the
nonzero／neutral direction checks without retuning distance、duration、reuse、deadzone or expanding retry scope. `30`
then reruns the full 120-assertion suite and the remaining manual／performance items fresh.

## Historical next queue — MFO-WO-P2-2A-001 (superseded)

1. Before the `10` handoff, draft acceptance cases only; do not edit gameplay or freeze an unreturned interface.
2. After the handoff, record the exact tested commit and modify only QA-owned tests／report／evidence.
3. Run fresh Phase 1 regression, Slice 2-A deterministic tests, import／headless smoke, release／export smoke, and
   the conditional arena-idle regression described by the work order.
4. Check KBM movement／aim／Space evade separately from automation and human feel.
5. Keep physical gamepad `Not run / Deferred`; do not infer hardware behavior from mapping tests.
6. Return `Pass / Fail / Blocked` recommendation to `00`. Do not approve Gate 2 or authorize Slice 2-B.

## Historical pre-handoff test plan — MFO-WO-P2-2A-001 (completed and superseded)

Historical state: **Drafted from approved behavior only / completed by Stage B and superseded by MFO-WO-P2-2A-002**

This plan does not prescribe method names, fields, extra events, or a returned implementation interface. After the
`10` handoff, QA first reviews the actual diff and chooses the narrowest QA-owned seam that can observe the approved
authority behavior. An untestable approved behavior is reported to `00`; QA does not require a production event or
edit gameplay code to expose it.

### A. Handoff and scope precheck

1. Record the exact implementation commit, implementation report, and gameplay handoff.
2. Diff from `afcd20cd4a02d618a5d7e0e4bc7555a64fa90740` and confirm implementation changes are limited to the
   work-order-owned input／simulation files plus the declared implementation report and gameplay handoff.
3. Confirm no `.tscn`, `project.godot`, camera, presentation, combat definition, existing QA test, shared contract,
   production event payload, build setting, or Phase 2-B／2-C／2-D feature changed.
4. Confirm OQ-005 remains unresolved and no retry input binding, defeated state, checkpoint, scene reload, or retry UI
   was added.
5. Confirm existing provisional `move_speed`, gameplay bounds, 1920×1080 fixed camera, zoom 1.0, stable IDs, and
   provisional attack path were not retuned or replaced.

If the handoff or diff is missing, mixed, or outside scope, stop validation and return `Blocked` or `Fail` with the
exact path list. Do not normalize the diff in QA.

### B. Phase 1 fresh regression

- Project import／parse.
- Run the existing Phase 1 deterministic suite without weakening or rewriting its expectations.
- Preserve InputMap idempotence, KBM／gamepad mappings, aim ownership and retention, normalized movement,
  stable actor／target ID, unknown-actor rejection, command sequence／physics tick, provisional hit／non-hit,
  hit-query acquire／release, and RuntimeHardLimit startup records.
- Main-scene headless smoke.

Report historical Phase 1 results separately from results freshly rerun against the Slice 2-A commit.

### C. Input request and authority boundary

| Case | Stimulus | Required observation |
|---|---|---|
| Abstract mapping | Inspect and exercise Space and gamepad A mappings | Both feed the same abstract `evade` request; mapping test is not physical-gamepad evidence |
| Fresh press | Press／inject a new evade edge once | One request is captured; held input does not become repeated accepted starts |
| Request only | Observe input command before authority step | Input carries intent only; it does not choose acceptance, direction result, collision, distance, or reuse |
| Lock-on reservation | Inspect LB／Q mapping and run normal commands | Mapping remains present and behaviorless |
| Device neutrality | Review changed gameplay paths | No device-specific evade gameplay branch exists |

The exact command member or method name is intentionally not frozen before handoff.

### D. Deterministic evade behavior

Run with fixed physics delta `1 / 60 s` and a collision-free actor unless the case states otherwise.

| Case | Setup / request | Expected |
|---|---|---|
| Move-direction step | Nonzero normalized move plus fresh evade | Direction is the latched move direction |
| Diagonal normalization | Diagonal move plus fresh evade | Direction is normalized; total collision-free travel is not diagonally inflated |
| Aim fallback | Neutral move, known aim, fresh evade | Direction is the latched current aim direction |
| Distance / duration | Accepted start followed through 12 nominal active ticks | `140 px` over `0.20 s`; provisional absolute endpoint tolerance `<= 0.1 px` |
| Ordinary movement isolation | Hold ordinary movement throughout active step | Ordinary locomotion neither adds to nor cancels approved step travel |
| Active rejection | Request again while step is active | Rejected; it does not restart, extend, or queue another step |
| Reuse rejection | Request after active end but before tick 27 from accepted start | Rejected |
| Earliest reuse | Fresh request at nominal start-to-start tick 27 | May be accepted, not earlier |
| No delayed buffer | Request on a rejected tick, then send no request when reuse becomes ready | No later automatic step occurs |
| Resume movement | Continue ordinary movement after step completion | Normal movement resumes only after the approved step finishes |
| Bounds limit | Start near each relevant configured boundary and step outward | Boundary is not crossed; shortened travel is recorded as bounds-limited |
| Collision limit | Place a QA fixture obstacle in the travel path | Collision is not penetrated; shortened travel is recorded as collision-limited |

The `0.1 px` value is a QA floating-point observation tolerance, not a gameplay retune. QA will not silently widen it
to pass an implementation. If the returned fixed-tick representation needs a different tolerance, record the measured
error and return the question to `00` before changing the expectation.

### E. Authority reset seam

1. Configure and record the actor start position and initial aim.
2. Enter an active evade and a non-ready reuse state, then call the explicit authority reset seam.
3. Verify start position, initial aim, zero velocity, inactive evade, zero active progress, cleared pending request state,
   and no residual reuse lock.
4. Verify a fresh post-reset evade can be accepted immediately when otherwise valid.
5. Repeat explicit reset and confirm identical state with no accumulated side effect.
6. Verify neutral ticks, cached aim, and ordinary simulation steps never invoke reset automatically.
7. Verify reset does not also apply movement, aim change, evade, or provisional attack from a triggering command.
8. Verify no defeated state or retry input binding is required or inferred in this slice.

Reset automation may use a QA-only observation seam. It must not demand a new production `DomainEvent` or
presentation consumer.

### F. Invalid identity and auditability

- Send movement／aim／evade intent with an unknown actor ID and verify no configured actor mutates.
- Confirm rejection remains auditable with the originating stable actor ID, command sequence, and physics tick.
- Confirm valid actor and optional target IDs retain Phase 1 behavior.
- Exercise ordered command ticks around evade start, rejection, end, and reuse boundary to expose off-by-one or
  stale-command behavior. Do not invent a new network ordering rule in this slice.

### G. Forbidden-scope review

Search the implementation diff and runtime behavior for unintended additions: invulnerability, stamina, input buffer,
lock-on behavior, part lock, auto approach, attack cancel, quick cut／heavy cleave, damage, `Integrity`, `Deformation`,
defeat, retry binding, persistent HUD, production payloads, VFX, camera changes, networking, persistence, or account
logic. Presence of a forbidden behavior is a scope failure even when functional tests pass.

### H. Build, smoke, and conditional performance

After deterministic tests pass:

1. Re-run import／parse and main-scene headless smoke with exact command and exit code capture.
2. Produce a proportionate Windows release-equivalent export and run exported-EXE headless smoke.
3. If the established measurement path remains usable, run one 120-warmup／600-sample arena-idle regression on the
   reference device at 1920×1080, standard quality, AC Best performance.
4. Record P50／P95／P99／maximum, average-derived FPS, HUD／JSON consistency, environment, stdout, screenshot, and hashes.
5. Label the result `Slice 2-A arena-idle regression`; do not call it Gate 1, Gate 7, stress, or product-minimum evidence.

Performance execution is conditional on an implementation handoff, a successful export, and the existing measurement
command remaining valid. If any prerequisite fails, record `Blocked` or `Not run` rather than substituting old evidence.

### I. Manual evidence separation

- Automation: deterministic command and state observations only.
- Manual KBM functionality: WASD movement, mouse aim, Space evade, move-direction case, neutral／aim fallback,
  boundary behavior, and repeated-input rejection on the release-equivalent build.
- User feel: request and quote only if the user actually performs the build; do not infer from automation or QA function checks.
- Physical gamepad: `Not run / Deferred`; mapping tests remain automation only.
- Authority reset seam: automated verification is sufficient; defeat／retry manual flow is out of scope.

### J. Evidence and routing

- Required report: `docs/test-reports/phase2-slice2a-validation.md`
- New raw evidence only: `docs/test-reports/evidence/phase2-slice2a/`
- Record tested commit, environment, exact commands, exit codes, fresh assertions, manual steps, actual results,
  screenshot／JSON／stdout paths, and SHA-256 where applicable.
- Separate `Pass`, `Fail`, `Blocked`, and `Not run` by evidence type.
- Defect evidence returns to `00`; specification ambiguity goes to `OPEN_QUESTIONS.md` without QA resolution.
- Final output is only a Slice 2-A `Pass / Fail / Blocked` recommendation. QA does not approve Gate 2 or authorize 2-B.

## Initial precheck (historical)

- ZIP SHA-256: Match
- EXE SHA-256: Match
- Git LFS: Real artifacts present
- OS: Windows 11 Home `10.0.26200`
- GPU: `Intel(R) Graphics`
- GPU driver: `32.0.101.7077` (`2025-09-16`)
- Windows power plan display name: `バランス`
- AC/DC power mode GUID: `961cc777-2547-4f9d-8174-7d86181b8a7a` (`Best Power Efficiency`)
- OD-004 power result: Fail / Best performance revalidation required
- Gamepad: Not owned / Windows not detected / Deferred to Gate Playability
- KBM user overall feel: `問題なし`
- Gate recommendation at precheck: Not approved / Pending

## Latest execution — MFO-WO-P1-G1-002

- Status: QA execution complete / accepted by `00統括`
- Commit tested: repository HEAD `e95b1442759b8b43a3a62a555af4d0e96384dd81`; packaged runtime source baseline `a13505e8fbf82962e049b9101a87593a6692d2c7`
- Environment: Windows 11 Home build `26200`, Intel Core 7 150U, Intel Graphics driver `32.0.101.7077`, 1920×1080 at 60.0007 Hz, standard quality, release-equivalent packaged EXE
- AC power: Online / charging
- AC power mode: Best performance / `ded574b5-45a0-4f42-8737-46345c09c238`
- Power plan: `バランス` / `381b4222-f694-41f0-9685-ff5bb260df2e`（power modeとは別記録）
- DC power mode: Best Power Efficiency / `961cc777-2547-4f9d-8174-7d86181b8a7a`（変更なし）
- Commands and exit codes: empty `0`; arena idle `0`; raw outputとcommand recordを新規evidenceへ保存
- Empty result: 120 warmup＋600 samples、P95 `16.6667 ms`、59.9406 fps from average、Pass
- Arena result: 120 warmup＋600 samples、P95 `16.6667 ms`、59.8417 fps from average、HUD `16.67 ms`とJSON一致、Pass
- Automated result referenced: Phase 1 assertions 36 / 36 Pass（既存記録。今回再実行なし）
- RuntimeHardLimit: RHL-001 N/A、RHL-002 Pass、RHL-003 N/A、violation 0
- Manual KBM evidence: release buildでmove／aim／provisional attack／hitを既存確認
- User KBM feel: `問題なし`（overallだけ）
- Manual gamepad: Not run / Deferred to Gate Playability
- Effort evidence: `26 / 188 = 13.83%`を再計算、Pass。実績時間ではない
- Performance scope: Gate 1 idle baselineのみ。Gate 7／stress／製品最低環境の合格ではない
- Memory / GPU timing: unavailable。合格証拠として扱わない
- Evidence: [`../test-reports/evidence/phase1-gate1/power-revalidation-20260714-best-performance/`](../test-reports/evidence/phase1-gate1/power-revalidation-20260714-best-performance/)
- Test report: [`../test-reports/phase1-gate1-power-revalidation.md`](../test-reports/phase1-gate1-power-revalidation.md)
- Known issues added: 0
- Open questions added: 0
- Gate recommendation: **Pass**
- Gate approval: [`GATE-1`](../../material-frontier-online/decisions/2026-07-14-gate-1-approval.md)でPass

## Current evidence

- `material-frontier-online/deliverables/phase1/evidence/phase1-empty-performance.json`
- `material-frontier-online/deliverables/phase1/evidence/phase1-arena-performance.json`
- `material-frontier-online/deliverables/phase1/evidence/phase1-arena-capture.png`
- `material-frontier-online/deliverables/phase1/MFO-Phase1-Windows-x86_64.zip`
- `material-frontier-online/implementation/2026-07-14-phase1-technical-baseline.md`

Recorded: 36 / 36 assertions, empty P95 16.667ms, arena idle P95 16.667ms, export/smoke Pass。
旧P95の測定時power modeは未記録であり、今回のOD-004適合証拠へ流用しない。新しい再実行結果と区別する。

## Gate 1 work queue

1. ~~`MFO-WO-P1-G1-002`の記録様式を準備する。~~ Done
2. ~~成果物がLFS pointerではなく実体であることを確認する。~~ Pass
3. ~~AC接続中にWindows power modeをBest performanceへ変更・再読込する。~~ Pass
4. ~~AC GUID、power plan、GPU、driver、resolution、refresh、quality、buildを記録する。~~ Pass
5. ~~empty／arena idleを600 samplesで再計測し、HUD、JSON、screenshot、raw stdout、hashを保存する。~~ Pass
6. ~~[工数再見積り](../phase1-effort-reestimate.md)の`26 / 188 = 13.83%`を再検算する。~~ Pass
7. ~~KBM実動作、user overall feel、gamepad Not runを別fieldで集約する。~~ Done
8. ~~Pass／Fail／Blocked／Not runを分け、Gate 1合否を監督へ勧告する。~~ Pass recommendation submitted
9. ~~`00統括`によるevidence reviewとGate 1判定を待つ。~~ Gate 1 Pass / accepted

`30`はuserの体感を推測・代行しない。gamepad未所持中はmanufacturer／model／接続方式を繰り返し質問しない。
Gate 1 queue is closed. Current QA scope is only the active Slice 2-A order and only after its required handoff point.

## Representative commands

`godot`はGodot 4.7 stable console executableへのpathまたはaliasとする。

```powershell
godot --headless --editor --path material-frontier-online/prototype --quit
godot --headless --path material-frontier-online/prototype --script res://tests/run_phase1_tests.gd
godot --headless --path material-frontier-online/prototype `
  --export-release "Windows Desktop" build/windows/MFO-Phase1.exe
```
計測は `material-frontier-online/prototype/README.md` のrelease EXE手順を使う。外部入力を停止したidle測定と
通常起動の操作感確認を混ぜない。

## Review rules

- idle baselineを`PrototypeStressTarget`、Gate 7、製品性能の合格と呼ばない。
- RHL-001／003 N/Aを実機能のPassと呼ばない。
- 自動mapping testを実ゲームパッド手動確認の代わりにしない。
- KBM overall feelをgamepadまたは個別feel項目のPassへ拡張しない。
- raw command、stdout、exit code、commit、environment、evidence pathを保存する。
- defectは`KNOWN_ISSUES.md`、仕様不足は`OPEN_QUESTIONS.md`へ分ける。
- QAはGateを承認せず、証拠付きの勧告を提出する。

## Required handoff update

```text
Status:
Work order:
Commit tested:
Environment:
Commands and exit codes:
Phase 1 regression:
Slice 2-A automated results:
Manual KBM functional evidence:
User feel (only if actually requested):
Manual gamepad: Not run / Deferred
Performance result and scope:
Artifacts / hashes:
Known issues added:
Open questions added:
Slice recommendation: Pass / Fail / Blocked
Reasons:
```
