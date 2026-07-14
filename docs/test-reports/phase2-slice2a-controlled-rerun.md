# Phase 2 Slice 2-A Controlled Rerun Report

- Work order: [`MFO-WO-P2-2A-004`](../work-orders/phase2-slice2a-controlled-rerun.md)
- Report date: 2026-07-15 (Asia/Tokyo)
- Reporter: `30 QA・性能・レビュー`
- Supervisor order／QA start SHA: `67ba7f34b6e0ee93ca454a6da8d354b0c2e79ebc`
- QA branch: `codex/phase2-slice2a-controlled-rerun-qa`
- QA evidence／report content commit: `PENDING-CONTENT-COMMIT`
- Corrected C source: `5261a73707daca03cb160e03a12247886d3f5cce`
- Final recommendation: **Blocked**
- Gate 2: **Locked / not evaluated**

## 1. Outcome

ユーザーから`MFO-WO-P2-2A-004 QUIET WINDOW READY`を受領し、OneDrive clientをpause／exit済み、AC接続、
重い処理停止、性能中は入力しないというcontrol contractで開始した。A／B／Cはnon-OneDrive stagingへコピー後も
size、SHA-256、`MZ`が指定値と一致した。AC Online、Best performance、最後の10秒の入力静止、owned runtime不在もPassした。

一方、15秒preflightのOneDrive-family CPU差分は`32.15625 CPU-seconds`で上限`0.25`を超え、system CPUは
平均`38.2502%`、最大`46.0123%`でそれぞれ上限`20%`／`40%`を超えた。preflightはFailであり、固定matrixは
`A1`を含めて1 slotも開始していない。P95を生成・解釈せず、performance componentを
**Blocked / matrix not started**とする。

修正版Cのユーザー操作KBMは、foreground lossとなった2つのpartial sessionを結合せず保持した。3回目の独立sessionは
foreground lossなしで、W／A／S／D、独立mouse、neutral Space、move＋Space、2秒超のboundary移動、短間隔Space、
最後の5秒idleを受動記録した。ユーザーは全入力を意図したものと確認し、6項目すべてについて「すべて問題ないです」と回答した。
したがってKBM componentは**Pass**である。

confirmed Failはないがmandatory performance Blockedがあるため、work orderの優先規則による総合勧告は**Blocked**である。
game code、tests、recorder、scene、project設定、画質、閾値、既存report／evidenceは変更していない。

## 2. Activation and deadline

- Quiet-window local receipt／QA acknowledgement: `2026-07-15T00:01:08.0043338+09:00`
- Absolute performance deadline: `2026-07-15T00:11:08.0043338+09:00`
- User-reported preparation: OneDrive pause／exit、AC接続、重いapp／download／export停止、入力停止
- QA action on OneDrive: none。終了、再設定、quota整理、resumeは行っていない
- Staging: `%TEMP%\MFO-P2-2A-004\controlled-20260715-000108-67ba7f3-attempt2`
- Repository evidence: compact non-executable files only

最初のcontroller setupは`Get-CimInstance Win32_OperatingSystem`が`Access denied`となりexit `1`で、preflight前に停止した。
このsetup failureはperformance slotではなく、A1は未開始である。失敗controller sourceを上書きせず保存し、権限不要の
`Environment`／registry取得へ限定修正したcontrollerを新しいstaging directoryで実行した。最初の15秒preflight終了後、
残りdeadlineではcontrollerが次attemptを安全に開始できるbudgetを満たさなかったため追加preflightは行っていない。

## 3. Source and executable integrity

| Variant | Source | Size (bytes) | Required／actual SHA-256 | Source／staging `MZ` | Result |
|---|---|---:|---|---|---|
| A | `a13505e8fbf82962e049b9101a87593a6692d2c7` | 109,075,560 | `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` | `4D5A`／`4D5A` | Pass |
| B | `295549373fbb3b39deb6079172783ce62c7da532` | 109,095,104 | `3c15c254fbb8025d88c5636f2175a35f6e325b5368c8098e78b16181090dd4ef` | `4D5A`／`4D5A` | Pass |
| C | `5261a73707daca03cb160e03a12247886d3f5cce` | 109,095,120 | `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47` | `4D5A`／`4D5A` | Pass |

sourceとstagingのsize／hashは全て一致した。A／B／C EXE、export pack、duplicate binaryはtracked evidenceへコピーしていない。

## 4. Environment and controller

- OS: Microsoft Windows NT `10.0.26200.0`
- CPU: Intel64 Family 6 Model 186 Stepping 3、12 logical processors
- GPU: Intel Graphics、driver `32.0.101.7077`、driver date `2025-09-16`
- Active power plan: Balanced／`381b4222-f694-41f0-9685-ff5bb260df2e`
- AC power mode: Best performance／`ded574b5-45a0-4f42-8737-46345c09c238`
- Renderer／project／quality requirement: unchanged GL Compatibility、`1920×1080`、standard
- Executed matrix controller SHA-256: `fae29f8da114cbdbe3611e8e015485e1eb7ef5072f68ef8cf26d7203754a96e5`
- Setup-failure controller SHA-256: `4b4c71a076282bfa16eed3754edf6e2bbd7a2860ef041689032d21b27726dac4`

controller source、preflight samples、environment、session summary、empty continuous-monitor／segment filesをそのまま保存した。
staging-to-repository copy verificationは全24 fileでsource／destination SHA-256一致を記録している。

## 5. Quiet-host preflight

| Check | Required | Actual | Result |
|---|---:|---:|---|
| AC／power mode | Online／Best performance | Online／`ded574b5-45a0-4f42-8737-46345c09c238` | Pass |
| A／B／C identity | specified hash／`MZ` | all exact | Pass |
| Owned runtime | none | none | Pass |
| Final 10 s input tick | unchanged | one value: `492292203` | Pass |
| OneDrive-family CPU delta | `<= 0.25 s` | `32.15625 s` | **Fail** |
| System CPU average | `<= 20%` | `38.250224%` | **Fail** |
| System CPU 1 Hz maximum | `<= 40%` | `46.012270%` | **Fail** |
| APIs | load successfully | loaded | Pass |
| Staging | writable、outside OneDrive | Pass | Pass |

user-reported pause／exit状態やred-Xの原因は、この結果から断定しない。run後の補助snapshotでは`OneDrive.exe` 2 processと
`OneDrive.Sync.Service.exe` 1 processが存在したが、timed preflightの代替値には使っていない。QAはそれらを終了していない。

Performance component disposition: **Blocked / matrix not started**.

## 6. Fixed matrix results

preflightがPassしなかったため、terminal integrity ruleに従ってslotを開始していない。

| Order | Slot | Result | P95 |
|---:|---|---|---|
| 1 | A1 | Not run | N/A |
| 2 | B1 | Not run | N/A |
| 3 | C1 | Not run | N/A |
| 4 | C2 | Not run | N/A |
| 5 | B2 | Not run | N/A |
| 6 | A2 | Not run | N/A |

Actual orderは空、valid acceptance runは`0`である。旧runのP95は流用していない。

## 7. Corrected-C user-operated KBM

全attemptはC SHA-256 `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47`を通常起動した。
QAはgame inputを送信せず、指定キー状態、cursor delta、foreground PID、game logだけを受動観察した。

| Attempt | Duration | Captured | Integrity／result |
|---|---:|---|---|
| 1 | 40.905 s | foreground取得 | foreground loss、partial／Blocked |
| 2 | 16.833 s | W／A／S／D、independent mouse | foreground loss、partial／Blocked |
| 3 | 27.973 s | 全指定stimulus＋5秒idle | foreground lossなし、capture Pass |

attempt 3ではW／A／S／D全て、independent mouse distance `2491.027 px`、neutral Space、move＋Space、
短間隔Space、最大directional hold `2.452 s`を記録した。game stdoutでもarena境界位置`y = 984.0`と`y = 96.0`で
outward movement中に位置が固定された記録がある。これらはstimulus／runtime補助証拠であり、各gameplay outcomeは
ユーザーのitem-by-item総括で確認した。

| Checklist | User result |
|---|---|
| W／A／S／D movement | Pass |
| Independent mouse aim | Pass |
| Neutral movement＋Space uses current aim | Pass |
| Held movement＋fresh Space prioritizes movement | Pass |
| Arena boundary is not crossed | Pass |
| Active／reuse Space reject、no delayed buffer | Pass |

- Intentional-input confirmation: `意図した入力です`
- User outcome／feel: `いいえ、すべて問題ないです`
- QA KBM component: **Pass**
- User feel: **Pass / no issue reported**
- Physical gamepad: **Not run / Deferred**

## 8. Commands, exit codes, and evidence

Controller command shape:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File <TEMP>/run_controlled_rerun.ps1 `
  -RepoRoot <repository> -SessionRoot <TEMP-session> `
  -AcknowledgedLocal 2026-07-15T00:01:08.0043338+09:00
```

- setup attempt 1: exit `1` before preflight (`Get-CimInstance` access denied)
- controlled attempt 2: exit `2` (`Blocked`; preflight Fail、matrix未開始)
- KBM attempt 1 observer: exit `2` (foreground loss)
- KBM attempt 2 observer: exit `2` (foreground loss)
- KBM attempt 3 observer: exit `0` (all planned stimuli＋five-second idle)
- game processのcapture後closeはQA-owned normal post-capture closeで、gameplay crashではない

Evidence root:
[`evidence/phase2-slice2a/diagnostic-002/controlled-20260715-67ba7f3/`](evidence/phase2-slice2a/diagnostic-002/controlled-20260715-67ba7f3/)

Evidence manifest: `SHA256SUMS.txt`; SHA-256 `f17de23065a66a982515b6d1030e926ad9d8e9c801d0e6a04950f3beb908ca03`.

## 9. Changed-path audit and routing

Tracked changes are restricted to:

- this new controlled-rerun report;
- new evidence under `docs/test-reports/evidence/phase2-slice2a/diagnostic-002/`;
- `docs/handoffs/qa.md`.

gameplay code、tests、recorder、scene、project settings、quality、threshold、既存report／evidenceの変更は`0`件である。
new known issue／open questionは追加していない。`OQ-005`とphysical gamepad Deferredは変更していない。

最終勧告: **Blocked**.

`30 QA`はSlice 2-Aをacceptせず、Gate 2を承認せず、Slice 2-Bをauthorizeしない。`00統括`がperformance Blocked、
KBM Pass、OneDrive-family processの継続負荷を確認し、次のbounded routeを決定する。
