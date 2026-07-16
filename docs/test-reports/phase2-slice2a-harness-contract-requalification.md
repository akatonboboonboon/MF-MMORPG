# Phase 2 Slice 2-A — QA Harness Contract Requalification Report

- Work order: `MFO-WO-P2-2A-008`
- Date: 2026-07-16 (Asia/Tokyo)
- Owner: `30 QA・性能・レビュー`
- Supervisor starting commit: `e313475b3ba1bb7d4c23551f96bdc0eb9dc73d18`
- QA branch: `codex/phase2-slice2a-harness-contract-requalification-qa`
- QA receipt commit: `a8622893f73cb55771e69cae07f5edf28b13d659`
- QA PREPARED／execution HEAD: `da8eab0be069069cec0d59986a69ae5ad936ea31`
- Stage ID: `p2-2a-008-qp-20260716T094018jst-e313475-c2`
- Final recommendation: **Fail / harness defect**
- Performance slot launch count: `0`
- Gate 2／Slice 2-B: **Locked / not evaluated**

## 1. Result

PREACK、exact `START_ACK`、LIVE runner／launcher／controllerはすべてself-result `0 / Pass`で終了し、host
prerequisite、61-sample cadence、global slot count `0`、cleanup自体も観測できた。しかし、固定済みLIVE証拠と
sealed sourceをwork order Section 7／8へ照合したところ、次の3件の必須契約不適合を確認した。

1. **MFO-P2-2A-QA-005 — 全61 `live_sample`でslot field欠落**
   - Expected: 各complete sampleが`performance_slot_launch_count=0`を記録する。
   - Actual: 同fieldを持つsampleは`0 / 61`。controller最終resultのglobal `0`では代替しない。
2. **MFO-P2-2A-QA-006 — sentinel cleanupと`n=0`の順序違反**
   - Expected: sentinel exit／cleanup → `settle_origin`記録 → immediate `n=0` persist。
   - Actual: `sentinel_ready` seq 11 → `live_sample n=0` seq 12 → `settle_origin` seq 14 →
     `owned_child_exit` seq 15 → `sentinel_complete` seq 16。
3. **MFO-P2-2A-QA-007 — LIVE evaluationのfield-completeness結果欠落**
   - Expected: runner／launcherのseparate evaluation／closureがpending readbackとfield-completenessを記録する。
   - Actual: 両LIVE evaluationは`pending_readback_success=true`を持つが
     `pending_field_completeness_success`を持たない。runnerは後発receiptに値があるが、launcherはevaluation、
     receipt、resultのいずれにもlauncher completeness結果がない。

Section 8はrequired evidence欠落およびordering／cleanup mechanism failureを`Fail / harness defect`に分類する。
したがって、runtimeのself-reported Passを正式QA Passへ昇格しない。host prerequisite Blockedではなく、
sealed harnessの証拠・順序契約不適合である。stageとruntime evidenceをfreezeし、自動修正・reseal・retryは
行っていない。

Defect evidence:
[`defect-source-evidence.md`](evidence/phase2-slice2a/qualification-003/p2-2a-008-qp-20260716T094018jst-e313475-c2/defect-source-evidence.md)

## 2. Scope and environment

| Item | Observed |
|---|---|
| OS | Microsoft Windows NT `10.0.26200.0`, 64-bit OS／x64 process |
| PowerShell／.NET | `5.1.26100.8875`／`4.0.30319.42000` |
| CPU identity | Intel64 Family 6 Model 186 Stepping 3, 12 logical processors |
| External final stage | `%LOCALAPPDATA%\Temp\MFO-P2-2A-008\p2-2a-008-qp-20260716T094018jst-e313475-c2` |
| External run evidence | `%LOCALAPPDATA%\Temp\MFO-P2-2A-008-Runs\p2-2a-008-qp-20260716T094018jst-e313475-c2` |
| Final stage freeze | files `149 / 149` ReadOnly; directories including root `47 / 47` ReadOnly |
| Runtime evidence freeze | files `27 / 27` ReadOnly; directories including root `6 / 6` ReadOnly |
| Residual MfoQa runtime | `0` after LIVE／closure probe |
| Performance slot／P95／FPS／frame recorder | launch count `0`／Not run／Not run／Not run |
| KBM／user feel | Not run／Not run; prohibited in this order |
| Physical gamepad | Not run / Deferred |
| A／B／C | identity-only; launch count `0` |
| Game code／tests／recorder／scene／project／quality／values／thresholds | `0` changes |
| Prior `-005`／`-006`／`-007` stage reuse | `false`／`false`／`false` |

GPU timingや描画性能は本work orderの対象外であり、GPU queryをqualification evidenceへ混ぜていない。
環境記録は
[`environment.json`](evidence/phase2-slice2a/qualification-003/p2-2a-008-qp-20260716T094018jst-e313475-c2/environment.json)、
scope記録は
[`scope-audit.json`](evidence/phase2-slice2a/qualification-003/p2-2a-008-qp-20260716T094018jst-e313475-c2/scope-audit.json)
に固定した。

## 3. Final stage identities

| Identity | SHA-256 |
|---|---|
| Qualification manifest | `a88e45cee008c2f774950b7c7144d7f5b263cd3502c97cb87922cd11c0497202` |
| Preparation receipt | `b20f3804b3511556998a49c805781ebbef22c0b706ee358911acf08f265f6960` |
| Preparation audit | `fef5686951cf06335d485ee64799ad4217b787040d6961f382bd63f72727a0c7` |
| Component contract | `0d2ed8c9c958c138b1125bcf1ec3dbcab5b1bc6402288b2220167597a7f16254` |
| Final native source | `01ed440a0973471ab78c057910f91101e22e04620bd33c49d52259d9cb72e810` |
| Source-diff audit | `6b043ff0395d2cd6ddaaad014f96738cef8adb57b9376464eeb6a5c2ca511053` |
| Repository-state evidence | `9e8c13cc2899370acb551b3ef6e1c896528943515d839fd52dcdef984cd2a79a` |
| A / Gate 1 baseline | `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` |
| B / pre-correction | `3c15c254fbb8025d88c5636f2175a35f6e325b5368c8098e78b16181090dd4ef` |
| C / corrected | `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47` |

Post-sealは`149 / 149` ReadOnly、manifest列挙14 identity一致、preparation auditによる最終列挙一致を確認した。
EXE／DLLはtracked evidenceへcommitせず、manifest、contract、auditのidentity metadataだけを保持する。

## 4. Preserved pre-seal attempt

最初のcandidate `p2-2a-008-qp-20260716T093459jst-e313475-c1`は、最初の3 QP modeがPassした後、
`QP_PREACK_CONTRACT_SELFTEST`が`30 / Fail`になった。静的production-order audit markerが自身のliteralを拾った
ことが原因である。

- c1 native source SHA-256: `435541085cbc68b30978fa72c77f8c33209cff58ae8869fefb5a1feefe1b2952`
- c1 contract result SHA-256: `289347832057c6a2b401cbfbe47162c89185d8777bd4e8dc2fccacbcd80e448c`
- c1 → c2: Section 5のstatic-audit lookup origin 3行だけを`IndexOf`から`LastIndexOf`へ変更
- Production PREACK／LIVE behavior: unchanged by that repair
- c1: unsealed、preparation auditなし、PREACK／LIVEなし、runtime stageとして未再利用

c2では全4 QPとaffected identityをfreshに再生成した。c1はterminal closure時にReadOnly化し、別区画に
byte-for-byteで保持した。詳細:
[`preseal-attempt-summary.json`](evidence/phase2-slice2a/qualification-003/p2-2a-008-qp-20260716T094018jst-e313475-c2/preseal-attempt-summary.json)

## 5. Stage QP

| Mode | Exact invocation SHA-256 | Result SHA-256 | Journal SHA-256 | Exit／result |
|---|---|---|---|---|
| `QP_DRYRUN` | `cb80500296452e8dc6b45a4c621fd8b6de5870d58bdb4083f464dc0f3894e52a` | `d707489e6f6b13c6b9273a1df85394ea53d5320d92a25e253cd2ed6b8ebda094` | `b7a47ea537fbe60d5472a2c43c9c5045c3e1cfa742c140f4eec6fd1eb6af41f8` | `0 / Pass` |
| `QP_SELFTEST` | `df81d5bbfea2de94187ba7959453b045ead98baeac0946e07e345887f326acd1` | `5857ffb9dc6354634725f9a23a6f0b11c8f77368e3f798382a16f43bf447c884` | `648fd636eb84eed6fdca6988ce54bc20580b92f530af36c0ea39136181e5f9bc` | `0 / Pass` |
| `QP_POWER_INPUT_SMOKE` | `416632c2307e766c34ab7b079deececcd4907db03fea7658e610008e15114b65` | `6c152e6f746a4bcc5bcb334de7d478c1ae68c8fff8782cf74d3ffe110431bec0` | `b19514f2f45376079d2c1c58364d1e5923ab53984323c0e6c100ffc26f430d3f` | `0 / Pass` |
| `QP_PREACK_CONTRACT_SELFTEST` | `475de2f3294d2a76182d1a17eba973888877e17651d318bcc9731c492caf77d4` | `f68d30de794db01ba983398f9740c0607a67e84cc8928ca709bc098c79f34ada` | `b9ebb803a3125c51d5b437ebb73f9664fc9633bf35a1180fbfe3053582a6df76` | `0 / Pass` |

Contract casesは`29 / 29`、production persistence pathは`4 / 4`。receipt／preparation-audit binding、
exact `-008` activation、old `-006`／`-007`およびmissing／extra／reordered／case-changed token rejectionはPass。
synthetic negative fixtureはobserved host failureではない。全QPでslot `0`、A／B／C launch `0`。

Exact full command stringsは
[`exact-invocations.json`](evidence/phase2-slice2a/qualification-003/p2-2a-008-qp-20260716T094018jst-e313475-c2/exact-invocations.json)、
command／exit対応は
[`commands.md`](evidence/phase2-slice2a/qualification-003/p2-2a-008-qp-20260716T094018jst-e313475-c2/commands.md)
に固定した。

## 6. PREACK and activation

Supervisor READY受領後、PREACK runnerを1回だけ起動した。launcherだけを起動し、controllerは起動していない。

| Record | Result / SHA-256 |
|---|---|
| PREACK runner result | `0 / Pass`; `888f09dfb585961dd25a3409607db716cef6b026201a0d055837c38357e81c7a` |
| PREACK launcher result | `0 / Pass`; `0e2abc215e80cdbabb5500a877957d22c58fdd832b24bcc269bd20c469f1a230` |
| Runner pending／evaluation | `c87879cc06847fd3eda754a24b1d0acc1d0edbe8eae488a5f345836169725de5`／`43ec32ae3235631e7d533c50027c483c9593ec7c989b499c926d3250be65501c` |
| Launcher pending (`preack_sha256`) | `e1db502d554b960341f6ca8a60cf1596f0302dcbcf7ca7118f7c3c32bb2a18f2` |
| Launcher evaluation | `a75e144773d802cb5975a3e6eb1f156874aec14e96cb612a8ac7a1e031d10c1a` |
| PREACK closure | `4d3e54980ee2821fefe6ebe2e4ad31989e32f8eb9ad6bd29bd16d89edac4252a` |
| PREACK journal | 9 records; file `890b510e7c9ff65da1bb11bcca58c0830aa5a4be97a2e616da160553efbc0224` |

Durable PREACKはOneDrive `0`、AC `1`、effective overlay
`ded574b5-45a0-4f42-8737-46345c09c238`、input API success、slot `0`、`preack_tick=63136609`。
sequence／previous link／record hash chainは全9件一致した。

User `START_ACK`は519 UTF-8 bytes、BOM／末尾改行なし、SHA-256
`1a5a25b1ffd449ed545ba14eb8f373753c189a03da37099a6b27b35c6647bce0`でexact `-008` tokenとして受理された。
READY、PREACK_READY、START_ACKは
[`protocol-transcript.md`](evidence/phase2-slice2a/qualification-003/p2-2a-008-qp-20260716T094018jst-e313475-c2/protocol-transcript.md)
に記録した。

## 7. LIVE observations and formal audit

### 7.1 Self-reported completed mechanics

| Role | Native exit／self-result | Result SHA-256 |
|---|---|---|
| Controller | `0 / Pass` | `ad8bec4a54ebd9705c6b383011261738248825727863e034efd373cf64af8e73` |
| Launcher | `0 / Pass` | `3c9121cbab54c5c650b6578f473ffa729e07b09614ad076da504c1287f8fa0b3` |
| Runner | `0 / Pass` | `fc86de5689b041983e879f9e772d4b361d2b54e8b3eedcc2fe14dcadaf7f16be` |

Tick relation:

```text
63136609 < 63478718 <= 63481687 <= 63481921
preack       runner          launcher       controller origin
deadline = 64081921 = controller origin + 600000
```

Cadenceは`n=0..60`の61件が一意・連続、settle／first actual `63482625`、final actual `63542625`、
duration `60000 ms`、lateness `0..15 ms`で全件`target..target+250`内だった。61件すべてOneDrive `0`、AC online、
Best performance、input baseline `63329031`一致、forbidden runtime `0`、owned roleはrunner／launcher／controllerのみ。
Sentinelはexit `23`、raw token exact。LIVE journalは145件でsequence／previous link／record hash chainが一致し、
file SHA-256は`f7a92f7652e6b9b2d27393ce5362a02bb582af2974796d4875ae287892feea41`。

### 7.2 Formal contract failures

正常なcadence／host観測と正式contract Passは別である。

- 各sampleの必須slot field: `0 / 61`。
- Required sentinel cleanup order: Fail。`n=0`がstream flush／job drain／owned-child exit／sentinel-completeより先。
- LIVE separate evaluation field-completeness result: runner／launcher両evaluationで欠落。launcherは後続closureにも欠落。

機械集計:
[`live-contract-audit.json`](evidence/phase2-slice2a/qualification-003/p2-2a-008-qp-20260716T094018jst-e313475-c2/live-contract-audit.json)

全10 preparation／preseal／PREACK／LIVE journalの独立hash-chain再計算:
[`journal-verification.json`](evidence/phase2-slice2a/qualification-003/p2-2a-008-qp-20260716T094018jst-e313475-c2/journal-verification.json)

## 8. Pass／Fail／Blocked／Not run separation

| Evidence component | Result |
|---|---|
| Final-stage byte identity／seal／ReadOnly | Pass |
| Stage QP 4 modes | Pass |
| Receipt／audit binding and exact `-008` activation fixtures | Pass |
| PREACK host／identity／persistence self-result | Pass |
| Exact user activation | Pass |
| LIVE host stability／cadence／global cleanup self-result | Pass |
| LIVE per-sample slot evidence | **Fail** |
| Sentinel cleanup → settle → n=0 ordering | **Fail** |
| LIVE launcher field-completeness evaluation／closure evidence | **Fail** |
| External host prerequisite | Not Blocked; observed stable during PREACK／LIVE |
| Performance slot／P95／FPS／frame recorder | Not run / prohibited; launch count `0` |
| KBM／user feel | Not run / prohibited |
| Physical gamepad | Not run / Deferred |
| A／B／C execution | Not run / prohibited; identity-only |

## 9. Freeze and evidence integrity

Evidence root:
[`qualification-003/p2-2a-008-qp-20260716T094018jst-e313475-c2/`](evidence/phase2-slice2a/qualification-003/p2-2a-008-qp-20260716T094018jst-e313475-c2/)

- Final stage nonbinary: `141` copied; runtime evidence: `27`; c1 pre-seal evidence: `139`。
- Source-derived payloads: `307 / 307` source／destination SHA-256 match。
- Source EXE／DLL occurrences excluded: `16`; tracked EXE／DLL: `0`。
- External final stage: `149 / 149` files ReadOnly。
- External runtime evidence: `27 / 27` files ReadOnly。
- External c1 pre-seal candidate: `147 / 147` files ReadOnly at terminal freeze; still unsealed and separately labelled。
- Evidence-local `.gitattributes`: `* -text` to preserve fixed bytes。
- Old report／evidence overwrite: `0`。
- Automatic repair／reseal／retry: `0`。
- `SHA256SUMS.txt`: `321 / 321` payloads match; self excluded。
- `SHA256SUMS.txt` SHA-256: `58827846f38becad61f08104db889f27b78f68e34f36527a891b5b8967200e25`。

Copy proof:
[`staging-copy-verification.json`](evidence/phase2-slice2a/qualification-003/p2-2a-008-qp-20260716T094018jst-e313475-c2/staging-copy-verification.json)

Freeze proof:
[`freeze-summary.json`](evidence/phase2-slice2a/qualification-003/p2-2a-008-qp-20260716T094018jst-e313475-c2/freeze-summary.json)

Changed tracked scopeは新規report、新規`qualification-003/`、既存`docs/handoffs/qa.md`だけとする。game code、
tests、recorder、scene、project、quality、value、threshold、既存report／evidence、`main`は変更しない。

## 10. Recommendation and route

**Fail / harness defect**。

`MFO-P2-2A-QA-005`、`-006`、`-007`を固定証拠とともに`00統括`へ返す。stage／runtime evidenceをfreezeし、
同stage修理、別stage、自動再試行、performance slot、P95、KBM、A／B／Cを開始しない。

このFailは`MFO-HOLD-P2-2A-001`を終了せず、performance acceptance、Slice 2-A acceptance、Gate 2、
Slice 2-Bを承認しない。次の作業は`00統括`の新しい明示work order待ちとする。
