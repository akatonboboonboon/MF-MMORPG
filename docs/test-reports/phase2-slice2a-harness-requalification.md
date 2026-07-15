# Phase 2 Slice 2-A — QA Harness Requalification Report

- Work order: `MFO-WO-P2-2A-007`
- Date: 2026-07-15 (Asia/Tokyo)
- Owner: `30 QA・性能・レビュー`
- Supervisor starting commit: `2e92cc8d39a146dc72ee74928aeb016d4da65244`
- QA branch: `codex/phase2-slice2a-harness-requalification-qa`
- QA receipt commit: `6d9877a4e33d97d12d54d1aa7b32d4725631a811`
- QA PREPARED-record commit／terminal inspection HEAD: `11389257424736bdbdb3f64c36e3811d8f84e33e`
- Stage ID: `p2-2a-007-qp-20260715t231258jst-2e92cc8-c1`
- Sealed manifest SHA-256: `e44acd54ba1b1f01e7628d9a3899242a43fa16164fa9c78bd4d355dff8314c67`
- Final recommendation: **Fail / harness defect**
- Gate 2／Slice 2-B: **Locked / not evaluated**

## 1. Result

Stage QPのdry-run、self-test、同一production `PowerAndInput` path smokeはそれぞれexit `0 / Pass`で完了し、
exact bytesをsealした。`PREPARED`送信後、`00統括`の構造監査により、sealed PREACK／activation pathに3件の
必須契約違反が確認されたため、`PREPARED`は不受理となった。

1. PREACKが`preparation-receipt.json`を読込・検証・hash記録せず、complete prerequisite recordにも
   receipt identityを持たない。
2. `RequireExactActivation`が旧`MFO-WO-P2-2A-006 START_ACK`をordinal完全一致で要求し、正しい
   `MFO-WO-P2-2A-007 START_ACK`を拒否する。
3. identity、OneDrive、power/input、runtime/ownership、native tickを、必須のcomplete prerequisite recordを
   append／flush／readback／hash化する前に判定する。

これらは外部host prerequisiteではなく、sealed harness bytesだけで再現できるmechanism defectである。
監督指示に従い、PREACKを起動せずstageをFail状態のままfreezeした。修理、再seal、別stage、自動再試行は
行っていない。

## 2. Scope and environment

| Item | Observed |
|---|---|
| OS | Microsoft Windows NT `10.0.26200.0`, x64 OS／x64 process |
| PowerShell／.NET | `5.1.26100.8875`／`4.0.30319.42000` |
| External stage | `%LOCALAPPDATA%\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1` |
| Stage files | `85`; ReadOnly `85 / 85` |
| `runs/` | Absent |
| Qualification window | Not started |
| Performance slot launch count | `0` |
| Game code／tests／recorder／scene／project／quality／values／thresholds | `0` changes |
| Tracked EXE／DLL／PCK／ZIP | `0` |
| Prior `-006` stage reuse／change | `false`／`0` |

Environment and scope records:

- [`environment.json`](evidence/phase2-slice2a/qualification-002/p2-2a-007-qp-20260715t231258jst-2e92cc8-c1/environment.json)
- [`scope-audit.json`](evidence/phase2-slice2a/qualification-002/p2-2a-007-qp-20260715t231258jst-2e92cc8-c1/scope-audit.json)

## 3. Sealed identities

| Identity | SHA-256 |
|---|---|
| Preparation receipt | `7c3c6dc7d2f015803446ce2db64e8fe2ef5acb25ef17c26bb9fbdaf104dbe6de` |
| Component contract | `b048e5e4cad4cb1817825ee7ad0062c416dedb84c819b05a30b86ecf78c90fb4` |
| Native source | `d4739f380a6fd27ec9413849752078239574494bbbaa010644e979e5d02f0c1f` |
| Native helper DLL | `36e4f6297ab005af38b52bf67b62bf75d705edf1acbbf34a7c82f1846b27b974` |
| Runner EXE | `81bbb9dfaeeda285f63fff4c47eeaced02ca2655196374e18f6dc5feb4202074` |
| Launcher EXE | `bdf3746991d23f9a6e489fdac68cfb13c310e7009f0bdc816ec4209cf00c6404` |
| Controller EXE | `5f4fccf2ffd63a80fbe29685c252eeb6d7135f5159860ca26939857f5763d9f3` |
| Sentinel EXE | `e7f9017ddf1fcc4a7be9b04fba8a1c5a7dc28c75c24dbd4d58c19ce6937baf24` |
| A / Gate 1 baseline | `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` |
| B / pre-correction | `3c15c254fbb8025d88c5636f2175a35f6e325b5368c8098e78b16181090dd4ef` |
| C / corrected | `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47` |
| Source-diff audit | `3c32686219fadce0d328cc6ccd81e5d71603e2add8a5587cb7067c434202ca86` |
| Repository-state evidence | `20dc6ac4b3b81e57c015aa106a765e7633117ac133e11220d61181bcbdca9848` |

`A/B/C`はidentity-onlyで起動していない。EXE／DLLは証拠へcommitせず、manifestとcomponent contractの
identity metadataのみを固定した。

## 4. Stage QP execution

実行済み3 commandのfull absolute invocationは、byte-for-byte固定した
[`qualification-manifest.json`](evidence/phase2-slice2a/qualification-002/p2-2a-007-qp-20260715t231258jst-2e92cc8-c1/seal/qualification-manifest.json)
の`invocations`に保存されている。実際のcommand identityは次のとおり。

`QP_DRYRUN`:

```text
"C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1\bin\MfoQaRunner.exe"  --mode "QP_DRYRUN" --stage "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1" --identity "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1\config\component-contract.json" --out "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1\preparation\dryrun-qualified" --journal "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1\preparation\dryrun-qualified\evidence.journal.jsonl" --result "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1\preparation\dryrun-qualified\runner-result.json"
```

`QP_SELFTEST`:

```text
"C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1\bin\MfoQaRunner.exe"  --mode "QP_SELFTEST" --stage "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1" --identity "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1\config\component-contract.json" --out "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1\preparation\selftest-qualified" --journal "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1\preparation\selftest-qualified\evidence.journal.jsonl" --result "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1\preparation\selftest-qualified\runner-result.json"
```

`QP_POWER_INPUT_SMOKE`:

```text
"C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1\bin\MfoQaRunner.exe"  --mode "QP_POWER_INPUT_SMOKE" --stage "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1" --identity "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1\config\component-contract.json" --out "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1\preparation\power-input-smoke-qualified" --journal "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1\preparation\power-input-smoke-qualified\evidence.journal.jsonl" --result "C:\Users\osato\AppData\Local\Temp\MFO-P2-2A-007\p2-2a-007-qp-20260715t231258jst-2e92cc8-c1\preparation\power-input-smoke-qualified\runner-result.json"
```

| Mode | Exact invocation SHA-256 | Exit／result | Result SHA-256 | Journal SHA-256 |
|---|---|---|---|---|
| `QP_DRYRUN` | `ee7f5e0e283103d1aec410b3ead636c02bf0586f8becba08a735a9771085e638` | `0 / 0 / Pass` | `4fae29ebbbdfc19d76d67996fdb20ba5089644825ced2b86ed543f28a1aef248` | `8a350f39100e9d79c140bb92e1ce09fe01652a2f90086868a320ca3e8278352c` |
| `QP_SELFTEST` | `d7a39be3a05a94b2700c596d70d44d95945d640cc3839f667f781264d933a410` | runner／launcher／controller `0 / Pass` | runner `598b5d40de627919d63379ab09afd6b01937ec5136d0605a0bc038a671f7c49f`; launcher `cd60a0b0a59cef24f27dc2cfa62bf4006be8c12caa4faf6cf518c1c0354eeea9`; controller `19b526416340cb3a2c5f865cdc17f9d8d625971df909824f37ea1f82aa267683` | `73eca982ca4f1dad7b909da6c794658f8c7d3a7c88ff295ee15ee475a8bfc31c` |
| `QP_POWER_INPUT_SMOKE` | `4831eadb33c0b9f59ff98e5d187a83d7525fc0eaa81a9eac8263bf18c4ff0f91` | `0 / 0 / Pass` | `2711bffa3a37992b320f3c70bc24ca2781568888b4fe0447d9ca087f9cea2c86` | `1b9732987397721f8006d074fd669d0ed20c5d3e7c7f0ad02adbcb98c34acf47` |

All three preparation modes recorded slot `0`, final owned runtime `0`, forbidden runtime `0`, and unexpected
descendant `0`. The smoke called the compiled production path once; GUID parse and `UInt32` round-trip passed. Its
observed overlay `961cc777-2547-4f9d-8174-7d86181b8a7a` was informational only under the work order and is not
performance acceptance evidence.

The sealed compile invocations, source hashes, raw streams, results, journals, and preseal attempts are preserved under
[`preparation/`](evidence/phase2-slice2a/qualification-002/p2-2a-007-qp-20260715t231258jst-2e92cc8-c1/preparation/).

## 5. Defect evidence

### 5.1 Missing preparation receipt identity

The sealed source contains zero `preparation-receipt`, `preparation_receipt`, or `receipt_identity` references.
Runner PREACK's PREACK-specific dictionary at lines 1843–1845 forwards only stage ID and manifest SHA; it forwards no
preparation-receipt identity. Launcher PREACK's complete record at line 2268 has no receipt path or receipt SHA-256,
and no receipt-derived stage ID／manifest SHA-256／slot fields. The receipt exists and is sealed, but it is not part of
the production PREACK evidence path.

Result: **Fail**.

### 5.2 Wrong exact START_ACK work-order ID

`source/MfoQaNative.cs:1701` constructs the exact expected string with:

```text
MFO-WO-P2-2A-006 START_ACK
```

The manifest says `MFO-WO-P2-2A-007`. Because line 1702 uses ordinal equality, the required `-007` token is rejected.

Result: **Fail**.

### 5.3 Complete prerequisite record is persisted too late

The sealed PREACK path evaluates stage／manifest at line 2250, OneDrive at 2253, power/input at 2254–2255,
runtime／ownership at 2260–2265, and tick at 2267. It first constructs the complete record at 2268 and persists it at
2270–2271. An earlier expected-value failure therefore terminates before the required complete record exists,
readback and hash. The later record also lacks receipt identity.

Result: **Fail**.

Full source and the line-oriented review are fixed at:

- [`source/MfoQaNative.cs`](evidence/phase2-slice2a/qualification-002/p2-2a-007-qp-20260715t231258jst-2e92cc8-c1/source/MfoQaNative.cs)
- [`defect-source-evidence.md`](evidence/phase2-slice2a/qualification-002/p2-2a-007-qp-20260715t231258jst-2e92cc8-c1/defect-source-evidence.md)

## 6. Not-run and non-produced evidence

| Phase／artifact | Status |
|---|---|
| `QUALIFICATION WINDOW READY` for `-007` | Not received |
| PREACK runner／launcher | Not run |
| PREACK complete record／SHA／tick | Not produced |
| `PREACK_READY` | Not produced／not sent |
| `START_ACK` | Not requested／not received |
| Activation token／SHA | Not produced |
| LIVE runner／launcher／controller／sentinel | Not run |
| 61 live samples／clock ordering／cleanup record | Not produced |
| Performance slot／arena／frame recorder／P95 | Not run / prohibited; count `0` |
| KBM／user feel | Not run / prohibited |
| Physical gamepad | Not run / Deferred |
| A／B／C | Not launched; identity-only |

The stage has no `runs/` directory. Missing values are not replaced with QP smoke values, previous-stage values, or
historical host observations.

## 7. Freeze and evidence integrity

Evidence root:
[`qualification-002/p2-2a-007-qp-20260715t231258jst-2e92cc8-c1/`](evidence/phase2-slice2a/qualification-002/p2-2a-007-qp-20260715t231258jst-2e92cc8-c1/)

- External stage: `85 / 85` files ReadOnly; unchanged; `runs/` absent.
- Stage-derived nonbinary payloads copied once: `77 / 77` source/destination SHA-256 match.
- Executable／DLL payloads committed: `0`.
- Closure-authored payloads before checksum manifest: `9`.
- `SHA256SUMS.txt`: `86 / 86` payloads match; self excluded.
- `SHA256SUMS.txt` SHA-256: `465db27591c3cd26be0cd0594cb46bb214a016e27a4f0779f4e896153833205a`.
- Evidence-local `.gitattributes`: `* -text` to preserve fixed bytes.
- Old report／evidence overwrite: `0`.
- Repair／reseal／retry／new stage: `0`.

Changed-path audit:

- Modified existing tracked path: `docs/handoffs/qa.md` only.
- New report: `docs/test-reports/phase2-slice2a-harness-requalification.md`.
- New evidence: `docs/test-reports/evidence/phase2-slice2a/qualification-002/` only.
- Other tracked change roots: `0`.
- `main` push: `false`; only the required QA branch is in scope.
- Authored-file `git diff --cached --check`: exit `0`.
- Whole fixed-evidence `git diff --cached --check`: exit `2`, solely because byte-identical stage-derived
  JSON／journal payloads preserve their original CRLF bytes under evidence-local `-text`; those bytes were not
  rewritten. Integrity for that immutable set is established by `77 / 77` source/destination hashes and the
  `86 / 86` payload manifest.

Freeze and per-file copy proof:

- [`freeze-summary.json`](evidence/phase2-slice2a/qualification-002/p2-2a-007-qp-20260715t231258jst-2e92cc8-c1/freeze-summary.json)
- [`staging-copy-verification.json`](evidence/phase2-slice2a/qualification-002/p2-2a-007-qp-20260715t231258jst-2e92cc8-c1/staging-copy-verification.json)
- [`SHA256SUMS.txt`](evidence/phase2-slice2a/qualification-002/p2-2a-007-qp-20260715t231258jst-2e92cc8-c1/SHA256SUMS.txt)

## 8. Recommendation and route

**Fail / harness defect**.

QP Passはproduction PREACK／activation contractを満たす証拠へ拡張しない。`performance_slot_launch_count=0`を
維持し、stage、report、evidenceをfreezeして`00統括`へ返す。新しい明示work orderなしにharness修理、
PREACK、別stage、performance、KBM、A/B/C起動を行わない。

This result does not end `MFO-HOLD-P2-2A-001`, accept performance, approve Slice 2-A, open Gate 2, or authorize
Slice 2-B.
