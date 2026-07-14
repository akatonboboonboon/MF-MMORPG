# Phase 1 Gate 1 Power Revalidation Report

- Work order: [`MFO-WO-P1-G1-002`](../work-orders/phase1-gate1-power-revalidation.md)
- Report date: 2026-07-14 (Asia/Tokyo)
- Reporter: `30 QA・性能・レビュー`
- Report state: QA execution complete / awaiting `00統括` review
- Gate 1 recommendation: **Pass**
- Gate 1 approval: **Not granted by QA / remains Pending until supervisor decision**
- Game code changes by QA: **0**
- Work order changes by QA: **0**

## 1. Tested baseline and artifacts

| Field | Value | Result |
|---|---|---|
| Repository HEAD during validation | `e95b1442759b8b43a3a62a555af4d0e96384dd81` | Recorded |
| Package source baseline | `a13505e8fbf82962e049b9101a87593a6692d2c7` | Expected baseline |
| Runtime changes since source baseline | None | Only repository instruction `AGENTS.md` files were added below `prototype/` |
| Phase 1 ZIP SHA-256 | `88d21f91d547de8c8bdc766c144777872f000a3fe356fb26ade8717fe010e983` | Pass |
| Packaged EXE SHA-256 | `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` | Pass |
| Git LFS materialization | 38,009,576-byte ZIP / 109,075,560-byte EXE | Pass |

再buildやgame設定変更は行わず、work order指定のrelease相当packaged EXEを使用した。

## 2. Environment and power mode

| Field | Recorded value | Result / note |
|---|---|---|
| Power source | AC online / charging | Pass |
| Windows power plan | `バランス` / `381b4222-f694-41f0-9685-ff5bb260df2e` | Power modeとは別fieldとして記録 |
| AC mode before | Best Power Efficiency / `961cc777-2547-4f9d-8174-7d86181b8a7a` | Known precheck Fail |
| AC mode during measurement | Best performance / `ded574b5-45a0-4f42-8737-46345c09c238` | Pass |
| Power API result | set RC `0`, read-back RC `0` | Pass |
| DC mode | Best Power Efficiency / `961cc777-2547-4f9d-8174-7d86181b8a7a` | Unchanged |
| OS | Windows 11 Home `10.0.26200` / build `26200` | Pass |
| CPU | Intel(R) Core(TM) 7 150U | Pass |
| RAM | 16,849,256,448 bytes | Recorded |
| GPU | Intel(R) Graphics | Pass |
| GPU driver | `32.0.101.7077` / 2025-09-16 | Pass |
| Display | 1920×1080 / 60.0007 Hz | Pass |
| Quality / build | Standard / release-equivalent packaged EXE | Pass |
| Renderer | GL Compatibility | Recorded |

変更後と両計測後にAC GUIDを再読込し、期待値を維持していることを確認した。計測終了時もAC modeは
Best performanceのままである。

## 3. Procedure

1. AC接続状態をOSから確認した。
2. Windows power APIで変更前AC／DC GUIDを取得した。
3. ACだけを`ded574b5-45a0-4f42-8737-46345c09c238`へ変更し、API戻り値と再読込値を確認した。
4. 指定packaged EXEを外部入力停止の測定modeで起動した。
5. emptyとarena idleをそれぞれ120 warmup＋600 samplesで測定した。
6. JSON、PNG、stdout、exit codeを新規evidenceへ保存した。
7. arena PNGを目視し、HUDの`FRAME P95 (600) 16.67 ms`とJSONの丸め表示が一致することを確認した。
8. empty PNGが表示要素を持たない真の空sceneであることを確認した。

完全な実行コマンドは[raw command record](evidence/phase1-gate1/power-revalidation-20260714-best-performance/commands.md)、
完全な標準出力は同evidence directoryの`*-stdout.txt`に保存した。

## 4. Performance results

| Scenario | Warmup / samples | Average | P50 | P95 | P99 | Maximum | FPS from average | Exit | Result |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Empty | 120 / 600 | 16.6832 ms | 16.6667 ms | **16.6667 ms** | 16.6667 ms | 23.1750 ms | 59.9406 | 0 | Pass |
| Arena idle | 120 / 600 | 16.7107 ms | 16.6667 ms | **16.6667 ms** | 18.0556 ms | 24.9633 ms | 59.8417 | 0 | Pass |

判定基準はP95 `<= 16.67 ms`であり、両scenarioとも合格した。arena HUDは`16.67 ms`、JSONは
`16.6666666666667 ms`で、表示丸めを考慮して一致した。emptyは真の空sceneでHUD自体を持たないため、
HUD照合はNot applicable、JSONとstdoutを証拠とした。

arena起動時のRuntimeHardLimit記録はRHL-001 Not applicable、RHL-002 Pass、RHL-003 Not applicable、
violation 0だった。これはPhase 1 active scopeだけの結果である。

`static_memory_bytes`は今回も`0`、portableなGPU per-frame timingは取得不能だったため、これらをメモリ／GPU性能の
合格証拠とは扱わない。本結果はidle baselineであり、`PrototypeStressTarget`、Gate 7、製品最低環境の合格を意味しない。

## 5. Input and human-feel disposition

| Evidence | Result | Scope |
|---|---|---|
| KBM move / aim / provisional attack / hit | Pass on existing release-build observation | Gate 1入力機能証拠として繰越 |
| User overall KBM feel | Pass — user verbatim: `問題なし` | 個別feel項目へ拡張しない |
| Physical gamepad LS / RS / actions | Not run / Deferred | `GATE-1-INPUT-EVIDENCE`によりGate Playabilityまで延期 |
| Gamepad drift / multi-input / feel | Not run / Deferred | KBM結果で代替しない |

OD-013は変更していない。

## 6. Effort evidence

承認済み再見積り`26 / 188`を再計算し、`13.83%`であることを確認した。15%以下の条件はPassと勧告する。
これは実績時間ではない。

## 7. Evidence and hashes

Evidence directory:
[`evidence/phase1-gate1/power-revalidation-20260714-best-performance/`](evidence/phase1-gate1/power-revalidation-20260714-best-performance/)

| Artifact | SHA-256 |
|---|---|
| `environment.json` | `1c8eb7eff1ac5193660e9afa00894d7b9baad9963acbe0e83d22aeb2915a6ef6` |
| `phase1-empty-best-performance.json` | `b09939ab2148efccb2a221517c51cc0198ae8c5534cb9e51e284a77c62bca61b` |
| `phase1-empty-best-performance.png` | `a953ae3570024edcce00cbd70ba55cbb8dc2955152f96d9b3832a4b4bbad0b7e` |
| `phase1-empty-stdout.txt` | `ab472bc2bc87a0e79fc6a7b552af535da6903e4e77829166ce4e7827a4e5d202` |
| `phase1-arena-best-performance.json` | `080197094748b81e1c062baf53d156a65059019ae2fa161faebce3af6ef5a22b` |
| `phase1-arena-best-performance.png` | `5e3a93d255aec1ff9906417d31a9b91fef083d8295c0d4eb2aa88991bf1b2328` |
| `phase1-arena-stdout.txt` | `ad2814870a6bbc32d81fef8d46f5cc2a9a65be0c086ad99a8e33da226cbf1b71` |

全ファイルのmanifestは[`SHA256SUMS.txt`](evidence/phase1-gate1/power-revalidation-20260714-best-performance/SHA256SUMS.txt)を参照。
旧evidenceは上書きしていない。

## 8. Defects, gaps, and recommendation

- Defects found: **0**
- New known issues added: **0**
- New open questions added: **0**
- Code or build-setting changes: **0**
- Remaining explicit Not run: physical gamepad validation（Approved deferral）

OD-004準拠のAC Best performance条件でempty／arenaのP95が合格し、hash、環境、GPU driver、電源mode、
KBM証拠、保守的工数再見積りが揃った。したがって`30 QA`は**Gate 1 Passを勧告**する。

これはQA勧告でありGate承認ではない。`00統括`が差分と延期条件を確認し、正規status／milestoneを更新するまで
Gate 1はPendingのままとする。
