# Material Frontier Online — Milestones and Gates

- Updated: 2026-08-02
- Approval owner: `00統括（監督）`
- Rule: QAは合否を勧告し、監督だけがGateを承認する。

## Status summary

| Milestone | Deliverable | Status | Gate |
|---|---|---|---|
| M0 / Phase 0 | 仕様確認、P0決定、試作仕様凍結 | Complete | Gate 0 Open (2026-07-13) |
| M1 / Phase 1 | 技術基盤と測定環境 | Complete | Gate 1 Pass (2026-07-14) |
| M2 / Phase 2 | Common combat system | Slice 2-A performance unresolved; Slice 2-B Stage A validated; isolated Stage B candidate unevaluated after runner-parse Blocked; `MFO-WO-P2-2B-009` exact correction revalidation active; integration locked | Gate 2 locked / not evaluated |
| M3 / Phase 3 | 3素材＋3魔法 | Not started / locked | Gate 3 locked |
| M4 / Phase 4 | ボス、部位破壊、討伐、剥ぎ取り | Not started / locked | Gate 4 locked |
| M5 / Phase 5 | 1ステージ＋2ギミック | Not started / locked | Gate 5 locked |
| M6 / Phase 6 | 垂直試作統合 | Not started / locked | Gate 6 + Playability locked |
| M7 / Phase 7 | 最大負荷検証と最適化 | Not started / locked | Gate 7 locked |
| M8 / Phase 8 | 確認用成果物 | Not started / locked | Gate 8 locked |

## Gate 8 delivery target

既存仕様を変更せず、Gate 8縦切り試作を次の日程で完成させる。

- Challenge target: 2026-09-03 (extended from 2026-08-18 on 2026-08-01)
- Realistic completion target: 2026-09-18

現実的完了目標の基準checkpoint:

| Target date | Required checkpoint |
|---|---|
| 2026-07-31 | Phase 2完了 |
| 2026-08-14 | Phase 3完了 |
| 2026-08-28 | Phase 4〜5完了 |
| 2026-09-11 | Phase 6〜7完了 |
| 2026-09-18 | Phase 8成果物完成／Gate 8判定 |

これらは工程管理目標である。日付到達または遅延だけではGate承認、work order発行、未承認仕様の実装許可、
担当有効化を意味せず、既存の仕様、受入条件、Gate／work order authorityを変更または緩和しない。

## Gate control

各Gateは次をすべて満たしたときだけ承認できる。

1. 前Gateが承認済み。
2. 該当工程のP1決定が `DECISIONS.md` にApprovedとして記録済み。
3. 実装・文書・成果物が工程スコープ内。
4. 必須テストと手動評価が証拠付きで完了。
5. QAが仕様適合と既知問題を報告し、合格を勧告。
6. 監督が差分を確認し、この文書のGate状態を更新。

テスト成功、担当チャットの完了宣言、機能の存在だけではGate承認にならない。

### QA recovery control after R5K-C

R5K-C返却後に必要なexternal QA-driver recoveryは、一欠陥ごとのwork order連鎖にせず、既知欠陥をまとめた
consolidated recovery packet 1件で扱う。

- packet開始時にread-only defect censusを行い、到達可能な既知欠陥をまとめる。監督reviewは最大2 active hoursとする。
- offline correction、parse／compile、fixture qualificationは合計最大4 active hoursとする。
  固定runtime、OS待機、user操作待ち、電源／OneDrive準備待ちはactive hoursへ含めず、別に記録する。
- offline candidateは最大3件とし、各candidateをhash／freezeして正式採用を1件に絞る。
- formal executionはexact 1回とし、最初の不適合で停止して証拠を凍結する。formal開始後、およびStage／PREACK／
  performance／game開始後のrepair／retryは禁止する。
- packet終了後も同じdriver lineageが未解決ならQA infrastructure問題として分類し、合格条件を緩和せず、
  最小の新規qualified driverへ置換するか監督判断でdeferする。defer中はperformance acceptance unresolved、
  Gate 2 Lockedを維持する。

## M0 — Specification and P0 freeze

- [x] 10仕様書の整理
- [x] 凍結統合仕様書とSHA-256
- [x] P0 13 / 13承認
- [x] Gate 0決定記録
- [x] Gate 0 Open

承認範囲はPhase 1のみ。巨大基盤、MMO、アカウント、課金、本番アセット量産は含まない。

## M1 — Technical baseline

Completed work order: [`work-orders/phase1-gate1-power-revalidation.md`](work-orders/phase1-gate1-power-revalidation.md)

Deferred physical-gamepad work order: [`work-orders/phase1-gate1-manual-validation.md`](work-orders/phase1-gate1-manual-validation.md)

- [x] 入力→移動→仮攻撃→命中→ログの縦経路
- [x] ローカル権威と表示の境界
- [x] 最小定義検証と判定予約
- [x] Windows release export
- [x] 空／アリーナidle測定
- [x] Phase 1自動テスト
- [x] KBM移動・照準・仮攻撃・命中の実動作
- [x] ユーザーのKBM総合操作感`問題なし`
- [x] Phase 1工数15%以下の証跡（承認済み再見積り13.83%。実績時間ではない）
- [x] 基準端末GPU／driver／power plan／power modeの記録
- [x] OD-004性能優先条件でempty／arenaを再計測（P95各`16.6667 ms`）
- [x] QA合格勧告
- [x] 監督によるGate 1承認

Deferred / not passed: 物理gamepad LS／RS／主要アクション、drift、多重入力、gamepad体感。
OD-013を維持し、入手後かつ遅くともGate Playability承認前に実施する。

Gate 1は[`GATE-1`](../material-frontier-online/decisions/2026-07-14-gate-1-approval.md)でPassした。
Phase 2 entry P1は承認済みだが、performance acceptanceは`MFO-HOLD-P2-2A-001`中である。`MFO-WO-P2-2A-006`
から`-008`は`Fail / harness defect`、`-009`は`Pass / harness qualified`で返却され、監督受理済みである。
`MFO-WO-P2-2A-010` remains the pre-PREPARED Blocked parent; `-011` and `-012` are closed Blocked, and Slice 2-A QA infrastructure is deferred. User-directed isolated Stage A implementation `MFO-WO-P2-2B-001` returned; `-002` through `-004` established the 71 / 36 / 120 / 39 / main-smoke Pass set. `MFO-WO-P2-2B-005` created the ignored output directory and exported successfully. `MFO-WO-P2-2B-006` then captured a waitable exported-smoke numeric exit `0`, tracked the exact generated UID, passed final audits, and returned `Pass / isolated common action-effect-query foundation validated` at QA tip `814c5ae0d6ee9f3826f01e22ff1d43090b6c2207`.

現在の実行順:

```text
00 accepted MFO-WO-P2-2A-012 as Blocked / QA infrastructure deferred; FORMAL and runtime counts remained 0
→ MFO-HOLD-P2-2A-001 remains active; Slice 2-A performance acceptance remains unresolved
→ user explicitly directed progress on 2026-08-01
→ 10 returned MFO-WO-P2-2B-001 at 81efefb; supervisor scope/evidence review found no blocker
→ 30 returned MFO-WO-P2-2B-002 Blocked with runtime validation Not run; no implementation defect established
→ 30 returned MFO-WO-P2-2B-003 after all 70 real assertions passed but the inherited false 71 total did not match
→ 30 returned MFO-WO-P2-2B-004 after 71／36／120／39／main smoke Pass; export stopped on an absent ignored output directory
→ 30 returned MFO-WO-P2-2B-005 Blocked after export Pass because direct GUI smoke exit was not durably captured
→ 30 returned MFO-WO-P2-2B-006 Pass after one waitable smoke, exact UID adoption, and final audits
→ P2-2B-P1-2026-08-01 approved and MFO-WO-P2-2B-007 isolated action/data kernel authorized
→ MFO-WO-P2-2B-007 returned at bbed2fd and supervisor review found no implementation blocker
→ 30 returned MFO-WO-P2-2B-008 Blocked when its runner failed parsing before assertions; candidate behavior remained unevaluated
→ MFO-WO-P2-2B-009 permits the exact one-line runner correction and one fresh fixed revalidation only
→ input, actor／target state, scenes, events, presentation, integration, Gate 2, and playable Slice 2-B remain locked
→ 20 remains frozen/non-binding-only; 30 has no active Slice 2-A execution order
```

Gate 1 evidence: [`test-reports/phase1-gate1-power-revalidation.md`](test-reports/phase1-gate1-power-revalidation.md)

Gate 1承認では次を同期した。

- `material-frontier-online/STATUS.md`: `Gate 1 = Pass`, `Phase 1 = Complete`
- `docs/IMPLEMENTATION_STATUS.md`
- この`MILESTONES.md`
- Gate 1 test reportと既知問題
- `docs/DECISIONS.md`のGate 1承認記録

Phase 2の無限定な`Authorized`表記は使用しない。実装許可は明示work orderのscope／pathだけに発生する。
`MFO-HOLD-P2-2A-001`はactive、`-010`はBlocked parent、`-011`／`-012`はBlockedでclosedであり、active Slice 2-A QA execution orderはない。
`MFO-WO-P2-2B-001` game code, corrected runner, UID, and all `-002` through `-006` reports / evidence are frozen. `MFO-WO-P2-2B-006` is accepted Pass. `MFO-WO-P2-2B-007` returned the isolated action/data kernel at reviewed handoff `bbed2fd98bf0435e456f9ad2bd7dba2b7a7cb0c6`. `MFO-WO-P2-2B-008` returned Blocked before assertions because of its own runner predicate and inconsistent numeric-exit records; it did not evaluate the candidate. `MFO-WO-P2-2B-009` permits only the exact one-line runner correction and fixed revalidation; input, actor, scene, state, event, presentation, and integration remain unauthorized.

## M2 — Common combat

Entry satisfied: Gate 1承認済み。次のPhase 2 P1は
[`P2-P1-2026-07-14`](../material-frontier-online/decisions/2026-07-14-phase2-p1-approval.md)で承認済み。

- [x] OD-020: Phase 2 ground-step evade
- [x] OD-021: same-arena authority reset
- [x] OD-026: `Integrity`／`Deformation` persistent HUD
- [x] OD-027: `Deformation >= 60` movement `-15%`
- [x] OD-041-P2: Phase 2 reference camera
- [x] OD-043-P2: Phase 2 minimum readability
- [x] P2-2B-P1-2026-08-01: quick／heavy P1 feel、OQ-002 recovery-only self-load、isolated-kernel boundary

Active performance hold:
[`MFO-HOLD-P2-2A-001`](work-orders/phase2-slice2a-performance-external-hold.md)

Parent qualified-harness performance acceptance order — pre-PREPARED Blocked:
[`MFO-WO-P2-2A-010`](work-orders/phase2-slice2a-qualified-harness-performance-acceptance.md)

Returned consolidated Stage P recovery — Blocked:
[`MFO-WO-P2-2A-011`](work-orders/phase2-slice2a-stage-p-consolidated-recovery.md)

Returned terminal Stage P driver replacement — Blocked / QA infrastructure deferred:
[`MFO-WO-P2-2A-012`](work-orders/phase2-slice2a-stage-p-terminal-driver-replacement.md)

Returned isolated Slice 2-B Stage A implementation — formal QA pending:
[`MFO-WO-P2-2B-001`](work-orders/phase2-slice2b-action-foundation.md)

Returned isolated Slice 2-B Stage A validation — Blocked / runtime Not run:
[`MFO-WO-P2-2B-002`](work-orders/phase2-slice2b-action-foundation-validation.md)

Returned explicit-tool Slice 2-B Stage A revalidation — non-pass / QA count premise defect:
[`MFO-WO-P2-2B-003`](work-orders/phase2-slice2b-action-foundation-explicit-tool-revalidation.md)

Returned QA runner correction and full Stage A revalidation:
[`MFO-WO-P2-2B-004`](work-orders/phase2-slice2b-foundation-runner-cardinality-correction-revalidation.md)

Returned QA export-output closure -- export Pass / smoke-exit evidence Blocked:
[`MFO-WO-P2-2B-005`](work-orders/phase2-slice2b-foundation-export-output-closure.md)

Returned final exported-smoke process and UID closure -- Pass accepted:
[`MFO-WO-P2-2B-006`](work-orders/phase2-slice2b-foundation-exported-smoke-uid-closure.md)

Returned harness LIVE-evidence correction／requalification order — Pass accepted:
[`MFO-WO-P2-2A-009`](work-orders/phase2-slice2a-harness-live-evidence-correction-requalification.md)

Returned harness contract-correction／requalification order:
[`MFO-WO-P2-2A-008`](work-orders/phase2-slice2a-harness-contract-correction-requalification.md)

Returned harness ABI-correction／requalification order:
[`MFO-WO-P2-2A-007`](work-orders/phase2-slice2a-harness-correction-requalification.md)

Returned harness-qualification order:
[`MFO-WO-P2-2A-006`](work-orders/phase2-slice2a-harness-qualification.md)

Returned performance-only order:
[`MFO-WO-P2-2A-005`](work-orders/phase2-slice2a-performance-only-rerun.md)

Returned controlled-rerun order:
[`MFO-WO-P2-2A-004`](work-orders/phase2-slice2a-controlled-rerun.md)

Returned diagnostic order:
[`MFO-WO-P2-2A-003`](work-orders/phase2-slice2a-performance-diagnostic.md)

Returned correction order:
[`MFO-WO-P2-2A-002`](work-orders/phase2-slice2a-nonzero-direction-correction.md)

Returned original order:
[`MFO-WO-P2-2A-001`](work-orders/phase2-slice2a-basic-operation.md)

他のP1/P2を一括決定しない。各Phase 2 work orderには目的、実装範囲、変更禁止範囲、受入条件、owner path、
event、test、Gate 2判定方法を含める。OQ-005はSlice 2-Cのdefeated-input接続前に決定する。

Implementation slices:

### Slice 2-A — Basic operation

Status: **Functional correction + corrected-C KBM verified / correction performance Fail retained / controlled matrices valid run 0 / non-performance harness qualified / performance hold active / consolidated Stage P recovery active**

- player移動、照準、回避
- lock-onはOD-020によりPhase 2対象外
- retry用authority reset seam。defeat／input bindingは実装しない
- Original Stage A candidate: `bd01fdf`; original formal QA closure: `c0df756`
- Correction implementation: `5261a737`; gameplay handoff: `0727fe56`; correction QA closure: `df0cd0c`
- Functional QA: Phase 1 `36 / 36 Pass`; unchanged Slice 2-A `120 / 120 Pass`; additive correction `39 / 39 Pass`
- Performance QA: AC Best performance P95 `33.4643 ms` and `20.0000 ms`; both exceed `<= 16.67 ms`
- `MFO-WO-P2-2A-003`: valid acceptance runs `0`; A1／B1／C1 invalid, C2 incomplete, B2／A2 Not run
- Diagnostic host: continuous external input, mostly non-game foreground, system CPU avg `72.838%–87.620%`, substantial OneDrive load; user later reported a red-X state and suspects the free-plan 5 GB limit, root cause unconfirmed
- Diagnostic recommendation: **Blocked / causality not isolated**; prior correction performance Fail is not withdrawn
- `MFO-WO-P2-2A-004`: preflight OneDrive-family `32.15625 CPU-s`, system CPU avg／max `38.250224%`／`46.012270%`; matrix Not run
- `MFO-WO-P2-2A-004` corrected-C KBM: **Pass**, independent `27.973 s`, stable foreground, all six items and user no-problem confirmation
- `MFO-WO-P2-2A-005`: QA began before preserving required external pre-ack checks; controller detected OneDrive-family presence during settle; trigger name／PID not persisted
- `MFO-WO-P2-2A-005`: slots `0`, valid matrix `0`, P95 unavailable; later `OneDrive.Sync.Service` PID `13496` is corroboration only
- QA harness: auxiliary TickCount64 field `0` on unsupported PowerShell property; actual deadline used nonzero
  Stopwatch origin; `MFO-WO-P2-2A-006` replaced this with a native monotonic path
- Host change reported 2026-07-15: OneDrive allocation UI `100 GB`／usage `4.8 GB`, generated-link rescan actual
  junction／symlink `0` with scan error `0`, and preliminary `OneDrive*` count `0` after normal shutdown. Red Explorer
  overlays are not acceptance evidence.
- `MFO-WO-P2-2A-006`: fresh PREACK OneDrive count `0`, launcher `0xC0000005`, runner `30 / Fail`, performance slot `0`;
  `PowerGetEffectiveOverlayScheme(out IntPtr)`／`LocalFree` ABI mismatch caused the harness failure before PREACK_READY
- `MFO-WO-P2-2A-007`: direct-`out Guid` correction and production smoke Pass; PREACK contract audit found missing
  receipt identity, stale `-006 START_ACK`, and assertions before complete-record persistence／readback／hash. PREACK／LIVE
  were Not run, stage frozen, performance slot `0`
- `MFO-WO-P2-2A-008`: PREACK／exact activation／61-sample LIVE completed; returned `Fail / harness defect` because all
  samples lacked slot field, `n=0` preceded sentinel cleanup, and LIVE evaluations lacked completeness results; slot `0`
- `MFO-WO-P2-2A-009`: five-mode Stage P、PREACK、exact activation、corrected `61 / 61`-sample LIVE、cleanup Pass; **Pass / harness qualified accepted**; performance slot `0`
- `MFO-WO-P2-2A-010`: pre-PREPARED Blocked parent; `-011`／`-012`: qualification non-Passでclosed Blocked; QA infrastructure deferred; PREACK／performance matrix／KBMは未許可
- KBM user feel: Pass; physical gamepad Not run / Deferred
- `MFO-P2-2A-QA-001`: functionally resolved on the correction branch, pending Slice acceptance／integration
- `MFO-P2-2A-QA-002`: P1 acceptance failure; runtime severity and code causality not isolated
- `MFO-P2-2A-QA-003`: QA harness ABI defect; direct-`out Guid` correction and same-production-path smoke verified
- `MFO-P2-2A-QA-004`: QA PREACK／activation contract defect; `-008`で修正・fixture／PREACK／activation Pass
- `MFO-P2-2A-QA-005`／`006`／`007`: `MFO-WO-P2-2A-009`でresolved; game defectではない

`MFO-WO-P2-2A-005`のBlockedを監督受理し、`MFO-HOLD-P2-2A-001`をperformance acceptanceに対して維持する。
material host-condition changeの報告後、監督は自動反復ではない明示票`MFO-WO-P2-2A-006`を発行した。
`-006`から`-008`のharness Failを順次受理・凍結した後、明示票`MFO-WO-P2-2A-009`を発行した。
`-009`は3件を限定修正し、seal前contract test、fresh stage、PREACK、exact activation、corrected LIVE、
host stability、cleanupをPassした。監督は`Pass / harness qualified`を受理した。
`-009`はperformance slot、P95、KBM、A／B／C、gameを実行しておらず、performance acceptanceを解決しない。
userのAC window確保報告後、監督は`MFO-WO-P2-2A-010`を発行した。同票はpre-PREPARED Blockedの親票として維持する。
R5K-Cの外部driver順序不良受理後、監督は`MFO-WO-P2-2A-011`をconsolidated Stage P recoveryとして発行した。`-011`は
offline `CP-ORDER-001`／`CP-ABC-001` closureをPassしたが、final QUALIFYがraw prefix終端と完全PipelineAst終端を混同して
exit `31`となり、FORMALは`0`だった。監督はこれをexternal QUALIFY statement-span boundary false positiveとして受理し、
MILESTONESのterminal replacement規則に基づき`MFO-WO-P2-2A-012`を発行した。最終QUALIFYはfrozen prequalification-manifest境界で
Blockedとなり、FORMAL／compiler／Stage／runtimeは`0`だった。監督はQA infrastructure deferredとして受理し、自動`-013`を発行しない。
Slice 2-A performance acceptanceとGate 2は未完了のままである。ユーザーの開始指示により、Slice 2-Bは非接続Stage A foundationだけを
`MFO-WO-P2-2B-001`で実装し、監督scope review後に`MFO-WO-P2-2B-002`で正式QAへ渡した。`-002`はrunnerを71 assertionsと誤記したが、実体は70 call sites＋helper定義1件であり、scope auditを
完了した一方、Godot探索漏れによりruntime検証を全てNot runとしてBlocked返却した。監督は実装欠陥の証拠とは扱わず、既設Godot 4.7の
absolute pathを指定した`MFO-WO-P2-2B-003`を同一candidate／runnerの限定再検証として発行した。`-003`はengine／importをPassし、runnerも
実在する70件を全Passしたが、旧QAがhelper定義をassertionとして数えた`71`条件で停止した。candidate defectの証拠ではないため、30 QAだけに
`MFO-WO-P2-2B-004` added one meaningful `clear()` assertion and passed 71 / 36 / 120 / 39 / main smoke; export then stopped only because ignored `build/windows` was absent.
`MFO-WO-P2-2B-005` created the directory and exported successfully, but direct GUI-subsystem invocation did not provide durable numeric exit evidence.
`MFO-WO-P2-2B-006` passed one waitable smoke with numeric exit `0`, exact UID closure, and final audits. At that closure, playable attack, production values, input, authority, scenes, and integration remained Locked; current authority is recorded below.

### Slice 2-B — Approved physical actions

Status: **Stage A validated; Stage B candidate unevaluated after runner-parse Blocked / exact correction revalidation active under `MFO-WO-P2-2B-009`; input／actor／scene integration locked**

Returned implementation order: [`MFO-WO-P2-2B-001`](work-orders/phase2-slice2b-action-foundation.md)

Returned validation order: [MFO-WO-P2-2B-002](work-orders/phase2-slice2b-action-foundation-validation.md)

Returned explicit-tool revalidation order: [MFO-WO-P2-2B-003](work-orders/phase2-slice2b-action-foundation-explicit-tool-revalidation.md)

Returned runner correction / full revalidation order: [MFO-WO-P2-2B-004](work-orders/phase2-slice2b-foundation-runner-cardinality-correction-revalidation.md)

Returned export-output closure order: [MFO-WO-P2-2B-005](work-orders/phase2-slice2b-foundation-export-output-closure.md)

Returned exported-smoke process and UID closure order -- Pass accepted: [MFO-WO-P2-2B-006](work-orders/phase2-slice2b-foundation-exported-smoke-uid-closure.md)

Returned isolated Stage B action-kernel implementation order: [MFO-WO-P2-2B-007](work-orders/phase2-slice2b-stageb-action-kernel.md)

Returned isolated Stage B action-kernel validation order — Blocked before assertions: [MFO-WO-P2-2B-008](work-orders/phase2-slice2b-stageb-action-kernel-validation.md)

Active Stage B runner correction and fixed revalidation order: [MFO-WO-P2-2B-009](work-orders/phase2-slice2b-stageb-runner-correction-revalidation.md)

- 快斬、重断
- windup、active hit window、recovery
- 入力中の向き処理
- hit query取得と返却

Stage Aの共通定義／query基盤は`30`がPass検証済みである。`MFO-WO-P2-2B-007`のP1値と非接続action kernelは監督review済みだが、`MFO-WO-P2-2B-008`はQA runner parse時点でBlockedとなりcandidateを評価していない。現在activeなのは`MFO-WO-P2-2B-009`の一行runner補正と固定再検証だけである。input、actor／target state、scene、production event、presentation、integrationは後続票までlockする。

### Slice 2-C — Damage model

Status: **Locked / no work order**

- `Integrity`、`Deformation`
- 被弾、戦闘不能、単一変形penalty
- retry時の完全初期化

完了後に`30`が損傷分離、敗北条件、penalty、初期化を検証する。

### Slice 2-D — Presentation boundary

Status: **Locked / no work order**

- `ActionStarted`
- `HitConfirmed`
- `DamageApplied`
- `DeformationChanged`
- `ActorDefeated`
- approved read-only state

正式payloadとconsumer contractを`ASSET_CONTRACTS.md`へ固定してから、`20`が割当済み表示fileへ統合する。
`20`はそれ以前でも、code非接続・非bindingの`Proposed` mockupを作成できる。

各sliceで`10 → 30`を行い、2-Dの契約確定部分だけ`20`と部分並行する。

Exit summary:

- 快斬／重断の予備動作、判定、ダメージ、後隙
- 回避、被弾、`Integrity == 0`、リトライ
- 独立した`Integrity`／`Deformation`と単一ペナルティ
- core装備の損傷状態が唯一の可変な正
- 共通Action／Effect、判定予約、リトライ後残留なし

## M3 — Materials and magic

Entry: Gate 2承認＋OD-025、濡れ床の電気強化方式、加熱時に下げる耐性等の必要P1決定。

Exit summary: 3素材のデータ差、3魔法の共通効果、Heat/BurnCurse分離、2～5Hz更新、VFX無効時の結果不変。

## M4 — Boss, parts, defeat, loot

Entry: Gate 3承認＋OD-022、OD-023、OD-024。

boss最大表示寸法またはboss framingをcameraへ統合する前に、OD-041-POSTの該当項目を決定する。

Exit summary: バーストボア、5部位、本体HP0の一度だけの遷移、AI／判定停止、死体、重複不可の剥ぎ取り。

## M5 — Stage and gimmicks

Entry: Gate 4承認＋OD-040、OD-041-POST、OD-043-POSTのうち制作に必要な項目。

Exit summary: 炭酸ライン、2ギミック、ST必須規約、二値経路、前景遮蔽なし、最低画質可読性。

## M6 — Integrated vertical slice and Playability

Entry: Gate 5承認。

Exit summary: 素材選択から剥ぎ取り・リザルト・再試行まで完走し、全MVP受入条件を満たす。
その後、人間が移動／回避、2物理攻撃、3素材差、予兆回避、部位狙い、最低画質理解の6項目を評価する。

Gate Playability承認前に、物理gamepadでLS移動、RS照準、主要アクション、drift／多重入力、操作感を
検証する。これはGate 1で延期した証拠であり、KBM結果をgamepad Passとして流用しない。

Gate Playability通過までM7へ進まない。

## M7 — Maximum-load performance

Entry: Gate Playability承認＋OD-044。

Exit summary: 全`PrototypeStressTarget`を同時成立、3回×10分、P95 16.67ms以下、RHL違反0、メモリ単調増加なし。

## M8 — Review deliverable

Entry: Gate 7承認。

Deliverables: オフライン試作、操作説明、仕様差分、未解決事項、性能結果、ステージ規約検査、既知不具合、次段階候補。

Gate 8でユーザーが確認するまで、オンライン、永続アカウント、課金、巨大マップ、別プラットフォームへ進まない。

## Team activation

| Role | Current status | Activation condition |
|---|---|---|
| 音楽・SE・ボイス | Not created / unauthorized | 監督がOD-042と必要イベント契約を承認し、この表を更新した後 |
| ネットワーク・サーバー | Not created / unauthorized | Gate 8後、オンライン段階をユーザーが別途承認した後 |
| アカウント・永続データ | Not created / unauthorized | 小規模オンライン境界と永続化範囲をユーザーが別途承認した後 |

候補条件は実装承認ではない。監督による明示的な`Activated`記録を必要とする。
