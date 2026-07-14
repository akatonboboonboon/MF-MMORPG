# Phase 2 Slice 2-A Correction Validation Report

- Work order: [`MFO-WO-P2-2A-002`](../work-orders/phase2-slice2a-nonzero-direction-correction.md)
- Report date: 2026-07-14 (Asia/Tokyo)
- Reporter: `30 QA・性能・レビュー`
- QA branch: `codex/phase2-slice2a-correction-qa`
- Correction order commit: `295549373fbb3b39deb6079172783ce62c7da532`
- Correction implementation commit: `5261a73707daca03cb160e03a12247886d3f5cce`
- QA start／gameplay handoff HEAD: `0727fe562c20fcb781eb9b1d63b260eb9a94f333`
- QA tests／report content commit: `547554183187c24fd8e0ced33a4c381aaf3c4366`
- Corrected release SHA-256: `28543cb1e45f1e4dd380654200e9336b9e95d8a6e699b4cc5ce0bae26ababb39`
- Slice 2-A correction recommendation: **Fail**
- Gate 2: **Locked / not evaluated**

## 1. Outcome

`MFO-P2-2A-QA-001`の限定修正は、fresh automation上では意図どおり機能した。Phase 1は`36 / 36`、既存の
Slice 2-A suiteはbyte-for-byte不変のまま`120 / 120`、additive correction suiteは`39 / 39`で、すべて
exit `0`だった。exact zeroのaim fallback、small `+X / -X / +Y / -Y`のmove優先、small diagonalの正規化、
actor直接guardのzero reject／small-nonzero acceptを確認した。距離、時間、tick境界、bufferなし、collision、
bounds、resetを含む既存挙動にも回帰はなかった。import、main smoke、release export、export済みEXE smokeも
exit `0`だった。

一方、AC Online／Best performanceで実施したarena-idle 600-sampleは、frame P95がfresh runで
`33.4643 ms`、確認runで`20.0000 ms`となり、既存基準`<= 16.67 ms`を2回とも超えた。また、修正版releaseの
KBM checklistは外部ユーザー入力検知とwindow取得失敗により中断し、`Blocked / Not completed`で全項目のPass
証拠を作れなかった。

したがって`30 QA`の最終勧告は**Fail**である。Fail根拠は2 valid runの性能基準超過である。KBMは機能Failと
判定せず、独立した`Blocked / Not completed`としてPassを阻む。これはGate 2判定でもSlice 2-B着手許可でもない。
性能原因は未分離であり、攻撃値、移動値、step値、画質設定、仕様をQA側で変更していない。

## 2. Scope, ancestry, and integrity

Ancestryは次の直列で一致した。

```text
295549373fbb3b39deb6079172783ce62c7da532
  -> 5261a73707daca03cb160e03a12247886d3f5cce
  -> 0727fe562c20fcb781eb9b1d63b260eb9a94f333
```

`2955493..0727fe56`の変更は、work orderが許可した4 pathだけだった。

- `material-frontier-online/prototype/scripts/simulation/local_authority_simulation.gd`
- `material-frontier-online/prototype/scripts/simulation/player_actor.gd`
- `material-frontier-online/implementation/2026-07-14-phase2-slice2a-nonzero-direction-correction.md`
- `docs/handoffs/gameplay.md`

code差分は2 insertions／2 deletionsで、authority fallback条件とactor start guardをexact
`Vector2.ZERO`判定へ変更した2箇所だけだった。共有epsilon、deadzone、距離、時間、reuse、move speed、bounds、
aim update、reset、event、scene、project設定は変更されていない。`git diff --check`はexit `0`。

既存[`run_slice2a_tests.gd`](../../material-frontier-online/prototype/tests/run_slice2a_tests.gd)は最初のfull
再検証前後とも次のSHA-256で、旧正式QA commit `daf6162`との差分もexit `0`だった。

```text
03ecfbd34bfb98333d9bdeff5c6ef90cb477090101ea6e4435511509c1e6e91a
```

旧Fail report、旧test hash、`stage-b-20260714-92f71d7/` evidenceは変更もfresh流用もしていない。QAが追加した
gameplay関連fileはadditive testと`.uid`だけで、ゲーム本体code変更は0件である。

## 3. Fresh automated results

| Check | Fresh result | Exit | Raw evidence | Disposition |
|---|---:|---:|---|---|
| Phase 1 regression | `36 / 36` | `0` | `phase1-regression-*` | Pass |
| Existing Slice 2-A suite | `120 / 120` | `0` | `slice2a-unchanged-*` | Pass |
| Additive correction suite | `39 / 39` | `0` | `slice2a-correction-additive-*` | Pass |
| Import／parse | completed | `0` | `import-parse-*` | Pass with isolated editor warning |
| Main-scene headless smoke | definitions OK / RHL violations `0` | `0` | `main-headless-smoke-*` | Pass |
| Windows release export | completed | `0` | `windows-release-export-*` | Pass |
| Exported-EXE headless smoke | definitions OK / RHL violations `0` | `0` | `exported-exe-headless-smoke-*` | Pass |

importとexport時にeditorが`Could not create ObjectDB Snapshots directory: user://`を出力したが、file scan、parse、
packは完了しexit `0`だった。runtime smokeとdeterministic suiteには同警告がなく、gameplay failureとは分離する。

### Required behavior matrix

| Required observation | Result | Fresh evidence summary |
|---|---|---|
| exact-zero movementのaim fallback | Pass | active stateがaim方向を即時latchし、その方向へmotion |
| deadzone直上small nonzero | Pass | InputAdapter経路で約`0.005`を保持し、authorityがmoveを優先 |
| small `+X / -X / +Y / -Y` | Pass | 各`0.005`が反対向きaimより優先され、正規化方向でactive |
| small diagonal | Pass | `(0.005, -0.005)`を受理し、同じ正規化方向でmotion |
| actor exact-zero guard | Pass | `begin_authority_evade(Vector2.ZERO)`はfalse、inactive維持 |
| actor small-nonzero guard | Pass | small diagonalをtrueで受理し、方向をnormalize |
| step中のaim変更 | Pass | player aimは更新、latched step方向は不変 |
| `140 px / 0.20 s` | Pass | tolerance `<= 0.1 px`、time tolerance `<= 0.00001 s` |
| 12 active ticks | Pass | nominal tick 11までactive、tick 12で終了 |
| start tick N+26 reject／N+27 accept | Pass | N+26以前はreject、N+27 fresh requestのみaccept |
| active／cooldown rejectとbufferなし | Pass | reject後のready tickに自動発動なし |
| 通常移動のstep距離への非加算 | Pass | opposite movement中もstep距離`140 px`、終了後に通常移動再開 |
| collision | Pass | QA fixtureのplayer mask `4`／obstacle layer `4`を明示し、非貫通 |
| bounds | Pass | configured edgeへ到達するが越境せず、12 ticksで終了 |
| mid-step reset | Pass | start position、initial aim、zero velocity、active／progress／reuseを即時復元 |
| mid-cooldown reset | Pass | residual reuseをzeroへ戻し、fresh requestを即時受理可能 |
| repeated reset | Pass | position／aimとも冪等 |
| unknown actor command／reset | Pass | configured actor不変、ID／sequence／tickを監査可能 |
| InputAdapter aim cache非拡張 | Pass by scope | authority actor resetだけで、adapter変更なし |
| Phase 1 query／hit回帰 | Pass | capacity `1`、resolution後active query `0`、hit／non-hit維持 |

## 4. Release and environment

- Godot: `4.7.stable.official.5b4e0cb0f`
- OS: Windows 11 Home `10.0.26200` build `26200`
- CPU: Intel Core 7 150U、12 logical processors
- RAM: `16,849,256,448` bytes
- GPU: Intel Graphics、driver `32.0.101.7077`、date `2025-09-16`
- Physical display mode: `1920x1200 @ 60 Hz`
- Windows logical desktop bounds: `1280x800`
- Project viewport: `1920x1080`
- Renderer／quality: GL Compatibility／standard
- Active power plan: バランス／`381b4222-f694-41f0-9685-ff5bb260df2e`
- AC user power mode: Best performance／`ded574b5-45a0-4f42-8737-46345c09c238`
- DC user power mode: Best Power Efficiency／`961cc777-2547-4f9d-8174-7d86181b8a7a`
- Release EXE: `109,099,880` bytes、SHA-256 `28543cb1e45f1e4dd380654200e9336b9e95d8a6e699b4cc5ce0bae26ababb39`

`PowerLineStatus`は実行前、run 1後、confirmation 2後のすべてで`Online`、batteryはcharging、AC mode読出し
return codeは`0`だった。したがって今回の性能結果はAC条件で有効であり、Gate 1旧値の代用ではない。

## 5. Performance

ScopeはSlice 2-A arena-idle regressionであり、stress、Gate 7、製品最低環境の合否ではない。

| Run | Warmup / samples | Average | P50 | P95 | P99 | Maximum | FPS from average | Result |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| Fresh run 1 | 120 / 600 | 20.9436 ms | 16.6667 ms | **33.4643 ms** | 100.0000 ms | 147.1060 ms | 47.7472 | **Fail** |
| Fresh confirmation 2 | 120 / 600 | 17.3041 ms | 16.6667 ms | **20.0000 ms** | 30.8941 ms | 66.5020 ms | 57.7898 | **Fail** |

両runともexit `0`、scenario `arena`、warmup `120`、sample `600`、GL Compatibility、window `1920x1080`。
capture HUDはそれぞれ`33.46 ms`と`20.00 ms`を表示し、JSONのP95丸めと一致した。途中で終了しexit `-1`に
なった別confirmation attemptはJSON／PNG未生成で、`Invalid / Not used`としてraw outputだけを保存した。

歴史参照のGate 1 arena P95 `16.6667 ms`は今回のfresh Pass証拠へ流用していない。今回の2 valid runがともに
現行基準`<= 16.67 ms`を満たさないことだけをFail根拠にする。

### MFO-P2-2A-QA-002 — arena-idle frame-time regression

- Classification: confirmed acceptance failure; causality not isolated
- Reproduction: valid AC／Best performance run 2回でP95超過
- Runtime impact: frame pacing degradation; severityの製品全体評価はこのslice evidenceから拡張しない
- Balance／spec impact: なし。威力、距離、時間、reuse、画質をQA側で変更しない

修正された2条件はevade request処理上にあり、idle時性能悪化の因果をこの結果だけでは確定できない。原因候補は
current desktop load／window compositing／background contention、またはbaseline以降の別要因である。`00統括`へは
次の限定経路を提案する。

- A: Gate 1 baseline EXEとcorrection EXEを同一current sessionでback-to-back比較する。
- B: 既存600-frame recorderと同時にOS process／GPU loadを採取する。
- C: controlled desktop sessionでcorrection EXEを再実行し、今回のFail証拠は保持する。

GPU timingはGL Compatibilityで取得不可。JSONの`static_memory_bytes = 0`はunavailableであり、memory Passとは
扱わない。

## 6. Manual KBM, user feel, and gamepad

| Evidence class | Result | Note |
|---|---|---|
| QA corrected-release KBM function | **Blocked / Not completed** | D方向のpartial movement後、external user input検知とwindow取得失敗で入力停止 |
| User feel | Not run | 修正版releaseに対するuser評価が明示されていないため推測しない |
| Physical gamepad | Not run / Deferred | approved deferralを維持。mapping automationをhardware Passにしない |

通常起動の同一EXEで初期HUD position `(620.0, 540.0)`を確認し、D batch後のraw logはX-onlyで
`(1310.666, 540.0)`までの移動を記録した。ただし途中で`user input was detected in this window`が返り、fresh
snapshotも`foreground window did not report a process id`で失敗したため、W／A／S、mouse aim、Space、
move-priority、neutral fallback、boundary、repeated-input rejectionのmanual Passは主張しない。interleaved inputの
attack eventsも入力源を一意にできず、QA mouse evidenceへ流用しない。

精密なSpace／方向／boundary／buffer項目はautomationではPassしているが、manual KBM結果と混合しない。

## 7. Other QA-owned checks

| Area | Result | Note |
|---|---|---|
| Attack query count／release | Pass | capacity `1`、resolution後active `0` |
| Breakable part count | Not applicable | Slice 2-Aにpart definitionなし、RHL-001 N/A |
| Stage regulation | Pass by scope and smoke | scene／presentation変更なし、RHL violation `0` |
| Minimum-quality readability | Not run | 今回はstandard quality。presentation変更なしを最低画質Passへ拡張しない |
| Static memory sample | Unavailable | recorder値`0`を実測Passにしない |
| GPU frame timing | Unavailable | GL Compatibilityの既存制約 |

## 8. Evidence and hashes

Fresh formal evidence directory:
[`evidence/phase2-slice2a/correction-001/validation-20260714-0727fe56/`](evidence/phase2-slice2a/correction-001/validation-20260714-0727fe56/)

| Artifact | SHA-256 |
|---|---|
| Existing `run_slice2a_tests.gd` | `03ecfbd34bfb98333d9bdeff5c6ef90cb477090101ea6e4435511509c1e6e91a` |
| Additive `run_slice2a_correction_tests.gd` | `f19656a92b4d8016edeb5acf96c39e1c8ac6aeb69901ac25dfb50cca04583128` |
| Additive test `.uid` | `91bf836be6bdc9dbd6cf69ffae324a409c16f6e4df3ca8a0f2aaaa2ebe0e3068` |
| Corrected release EXE | `28543cb1e45f1e4dd380654200e9336b9e95d8a6e699b4cc5ce0bae26ababb39` |
| Interrupted KBM raw log | `a768f0788b78bfd004176c082876f9f71ba35f3953fa1e43cbaaa6e4d76759c3` |
| `SHA256SUMS.txt` | `d1c2c827d37519c4ace69eb4209fc09f3be903379b9c038bfbc822d2f652d31c` |

Exact commands and exit codes are in `commands.md`; machine／power data are in `environment.json` plus pre／post raw
JSON. All raw logs, stdout, exit-code files, performance JSON, screenshots, and authored observations are hashed by
`SHA256SUMS.txt`. Evidence is new under`correction-001/`;旧Fail archiveを上書きしていない。

## 9. Issues, questions, and recommendation

- `KI-009`: original direction defectのfunctional correction evidenceはPass。正式closeは`00統括`だけが行う。
- New QA finding: `MFO-P2-2A-QA-002`をperformance acceptance failureとして`00統括`へ返す。
- Open questions added: 0。
- `OQ-005`: unchanged。retry binding、defeat、scene reloadを要求していない。
- QA gameplay code changes: 0。

最終勧告：**Fail**。

Fail根拠は、AC条件を満たした2 valid runでframe P95基準を超過したことである。corrected-release KBMは
`Blocked / Not completed`であり、機能Failとは判定しないが、独立してPass条件を満たしていない。`00統括`が
bounded performance／manual再検証経路を決めるまで、Gate 2はLockedのまま、Slice 2-Bは未許可である。
