# Phase 2 Slice 2-A Performance Diagnostic Report

- Work order: [`MFO-WO-P2-2A-003`](../work-orders/phase2-slice2a-performance-diagnostic.md)
- Report date: 2026-07-14 (Asia/Tokyo)
- Reporter: `30 QA・性能・レビュー`
- Supervisor order / QA start SHA: `f3450df07f84144ce10dba2584c74a0f3a5b585b`
- QA branch: `codex/phase2-slice2a-diagnostic-qa`
- QA evidence/report content commit: `a3920f8419419357698c0db47f8aa35b3fd6ba34`
- Final recommendation: **Blocked**
- Gate 2: **Locked / not evaluated**

## 1. Outcome

指定されたA／B／Cの実体とsource差分は一致し、BとCのrelease exportも同一Godot・同一presetで成功した。
ACはOnline、user AC modeはBest performanceだった。一方、固定matrixではA1の最初のcontrol attemptがQA監視器の
終了時window-handle処理でinvalidとなり、許可されたA1 replacementでは外部入力を検出した。自動controllerが
停止要求より先に完了したB1／C1でも同じ入力変化を記録し、C2はcontroller停止前にJSON／captureだけを生成したが
exit・power・OS sampleが完成しなかった。B2／A2は、汚染条件下で都合のよい値が出るまで続けないため実行しなかった。

したがって有効なacceptance runは`0`件である。生成済み4 JSONのP95はいずれも`16.67 ms`を超えたが、invalid runを
性能Failへ変換していない。A controlの安定性と比較因果を確立できないためperformance componentは**Blocked / causality
not isolated**とする。

修正版Cの通常起動KBMも別sessionで一度だけ開始したが、最初のW入力で`user input was detected in this window`が再発した。
中断後の受動観察では別アプリがforegroundで、fresh Godot logにはQAが発行していないmovementとAttack Aが既に残っていた。
部分sessionを結合せず、KBM componentも**Blocked**とする。再現可能なgameplay defectは確認していない。

componentにconfirmed Failはなくmandatory Blockedがあるため、work orderの優先規則に従う最終勧告は**Blocked**である。
ゲーム値、仕様、test、recorder、scene、project設定、画質、閾値は変更していない。

## 2. Source and executable integrity

| Variant | Source | Executable | Size | SHA-256 | Result |
|---|---|---|---:|---|---|
| A | `a13505e8fbf82962e049b9101a87593a6692d2c7` | packaged Gate 1 EXE | 109,075,560 | `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` | LFS materialized / `MZ` |
| B | `295549373fbb3b39deb6079172783ce62c7da532` | clean detached export | 109,095,104 | `3c15c254fbb8025d88c5636f2175a35f6e325b5368c8098e78b16181090dd4ef` | exit `0` / `MZ` |
| C | `5261a73707daca03cb160e03a12247886d3f5cce` | clean detached export | 109,095,120 | `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47` | exit `0` / `MZ` |

BはCの直接親であり、B→Cのruntime差分は次の2条件、各1行だけだった。

- `local_authority_simulation.gd`: direction fallbackをexact zero判定へ変更
- `player_actor.gd`: actor direct guardをexact zero判定へ変更

A／B／Cで`project.godot`、`export_presets.cfg`、arena、debug HUD、performance recorderは同一blobである。
Godotは`4.7.stable.official.5b4e0cb0f`、console SHA-256は
`d8055fb8c7e7f5010d7439ec69be051554055dae55a265f8647bd7301c34161c`、release template SHA-256は
`c42eb5d17f683eb8bcd52c19a9f36ebf811b1788623878d5276a7d9ffc09f95c`だった。

Bの最初のexportはfresh output親directoryが存在せずexit `1`となった。このpreflight手順エラーは上書きせず
`export-b-2955493-*`として保持した。親directoryを作成後のB attempt 2とC attempt 1はexit `0`で、EXE hashも異なるため
stale pathではない。performance runは両exportとhash固定後にのみ開始した。

## 3. Environment and fixed procedure

- OS: Microsoft Windows 11 Home `10.0.26200` build `26200`
- CPU: Intel Core 7 150U / 12 logical processors
- RAM: `16,849,256,448` bytes
- GPU: Intel Graphics / driver `32.0.101.7077`
- Physical display: `1920x1200 @ 60 Hz`; Windows logical desktop: `1280x800`
- Project / renderer / quality: `1920x1080`, GL Compatibility, standard; no quality override
- Active plan: Balanced / `381b4222-f694-41f0-9685-ff5bb260df2e`
- Power: AC Online; Best performance / `ded574b5-45a0-4f42-8737-46345c09c238`
- Fixed preparation: executable SHA-256／`MZ`再確認後、各run前に5,000 ms idle
- Recorder: unchanged arena, 120 warmup frames, 600 samples
- Planned order: `A1 → B1 → C1 → C2 → B2 → A2`; each slot uses a new process

Windowsのlogical client observationは各completed runで`1280x720`、recorderのproject windowは`(1920, 1080)`だった。
これは同一150% DPI環境で一貫しており、A／B／C間の設定差ではない。GPU-engine utilization counterは取得できたが、
recorderのportable per-frame GPU timingは引き続きunavailableである。JSONの`static_memory_bytes = 0`もmemory Passには使わない。

## 4. Scheduled six-slot results

数値は生成済みJSONからのdiagnostic observationである。`Invalid`行の閾値分類はacceptanceへ使用しない。

| Order | Variant | Average | P50 | P95 | P99 | Maximum | Exit | Integrity / disposition |
|---:|---|---:|---:|---:|---:|---:|---:|---|
| 1 | A1 replacement | 16.9752 | 16.9490 | 18.0556 | 18.0556 | 28.8579 | `0` | **Invalid**: confirmed external input; A1 replacement consumed |
| 2 | B1 | 17.1366 | 16.6667 | 19.0880 | 26.9370 | 29.5390 | `0` | **Invalid**: confirmed external input; post-stop-condition data only |
| 3 | C1 | 17.0741 | 16.6667 | 18.3333 | 25.3713 | 32.5027 | `0` | **Invalid**: confirmed external input; post-stop-condition data only |
| 4 | C2 | 16.9172 | 16.6667 | 18.3333 | 24.3673 | 32.5830 | unknown | **Invalid**: report/capture only; controller evidence incomplete |
| 5 | B2 | N/A | N/A | N/A | N/A | N/A | N/A | **Not run**: stopped after repeated interference |
| 6 | A2 | N/A | N/A | N/A | N/A | N/A | N/A | **Not run**: stopped after repeated interference |

A1にはこの表の前に、QA監視器がprocess終了直後のnull window handleを参照して停止したcontrol attemptが1件ある。
そのattemptにはperformance JSON／captureがなく、`a1-invalid-control-001/`へ保存した。閾値を読む前にintegrity failureと判断し、
work orderが許すA1 replacementを1回だけ使用した。replacementも外部入力によりinvalidとなったため追加A1は行っていない。

## 5. Load and interference observations

| Run | OS samples | System CPU avg / max | OneDrive CPU delta | GPU-engine avg / max | Game WS max | Foreground / input |
|---|---:|---:|---:|---:|---:|---|
| A1 | 22 | 80.070% / 92.163% | +24.500 s | 14.1581% / 16.6333% | 281,554,944 B | non-game全sample; input tick changed |
| B1 | 22 | 72.838% / 90.229% | +25.969 s | 14.6303% / 17.1238% | 280,522,752 B | non-game全sample; input tick changed |
| C1 | 21 | 87.620% / 100.000% | +23.359 s | 14.3904% / 16.9551% | 283,750,400 B | game 2 sample後にnon-game; input tick changed |

OneDriveのcumulative CPUは各約14秒run中に約23〜26 CPU-seconds増え、system CPUも高かった。さらに全completed metadata runで
`GetLastInputInfo` tickが変化した。A controlを含めてforeground／external loadの影響を排除できず、run-orderやB→Cの2行差分へ
P95差を帰属できない。よって参考P95が全て閾値超過でも、今回の証拠からcorrection codeへperformance Failを帰属しない。

非ゲームwindow titleは個人の閲覧・会話情報を含み得るため、Git管理版ではPID、時刻、game／non-game区分、原題SHA-256を残して
title本文をredactした。未redact原本はignored `.build`内にのみ保持し、GitHubへ送信しない。処理記録は
`privacy-redaction.json`にある。

Performance component disposition: **Blocked / causality not isolated**.

## 6. Corrected C KBM, user feel, and gamepad

修正版C hash `308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47`を通常起動し、同一processで
checklistを開始した。初期HUD positionは`(620.0, 540.0)`でaim lineを確認したが、最初のW入力時にWindows automationが
`user input was detected in this window`を返した。QAは以後のgame inputを送らず、部分結果を自動testや旧sessionと合成していない。

fresh session logには`MovementApplied` 9件と`AttackRequested` 8件があった。QAはviewport clickもAttack A入力も行っておらず、
別アプリforegroundも受動snapshotで確認したため、session contaminationと判断した。private conversationが映ったsnapshot自体は
repositoryへ保存していない。raw game logは`kbm/kbm-interrupted-godot.log`、SHA-256は
`07fa61a93c1e9e9a65663c3cbd9020bd41190fe1f22182512149552d9403f4d6`である。

| Checklist | Result |
|---|---|
| W / A / S / D movement | Blocked; first W interrupted, remaining directions not run |
| Independent mouse aim | Blocked; initial aim line only, controlled sequence not run |
| Space ground-step evade | Blocked / Not run |
| Movement direction priority | Blocked / Not run |
| Neutral aim fallback | Blocked / Not run |
| Arena boundary non-crossing | Blocked / Not run |
| Active / reuse rejection | Blocked / Not run |
| Rejected request not buffered | Blocked / Not run |

- QA KBM functionality: **Blocked**; no gameplay Fail claim
- User feel: **Not run**; userによるこのwork order向けの操作評価なし
- Physical gamepad: **Not run / Deferred**

## 7. Commands and raw evidence

Exports used the following command shape; exact expanded absolute commands, timestamps, stdout, stderr, exit codes, and hashes are in
`exports/export-*-metadata.json`.

```powershell
Godot_v4.7-stable_win64_console.exe --headless --path <detached-project> `
  --export-release "Windows Desktop" <fresh-output.exe>
```

Each completed performance slot used this unchanged command shape. Exact A1／B1／C1 commands are in each
`run-metadata.json`; C2 retains its Godot log, JSON, and capture but lacks final controller metadata.

```powershell
<A-or-B-or-C.exe> --log-file <slot>/godot.log -- --phase1-measure `
  --phase1-report=<slot>/performance.json --phase1-capture=<slot>/capture.png
```

Evidence root:
[`evidence/phase2-slice2a/diagnostic-001/session-20260714-f3450df/`](evidence/phase2-slice2a/diagnostic-001/session-20260714-f3450df/)

Primary derived record: `matrix/observed-summary.json`. The first derived summary incorrectly counted a top-level sample array as one value;
it is retained as `matrix/observed-summary-generation1-invalid.json` and is not used. Raw run evidence was not altered by that correction.

Evidence manifest: `SHA256SUMS.txt`; SHA-256 `7a651e2a7e321cc1fa3f93390c9c563d52a86776ae0179331726112c0884fbfe`.

## 8. Changed-path audit and routing

Tracked changes are restricted to:

- this new diagnostic report;
- new evidence under `docs/test-reports/evidence/phase2-slice2a/diagnostic-001/`;
- `docs/handoffs/qa.md`.

Gameplay code、tests、recorder、scene、project settings、quality、threshold、既存report／evidenceは変更していない。
Temporary detached worktrees、exports、controller、unredacted private copiesはignored
`material-frontier-online/.build/diagnostic-001/`だけに置き、commitしない。`main`へpushしない。

最終勧告: **Blocked**.

`30 QA`はGate 2、Slice 2-A acceptance、Slice 2-B着手を承認しない。`00統括`にはgameplay codeを`10`へ戻さず、
exclusive foreground／入力なし／background contentionを統制できる条件と新規evidence rootを定めたbounded再測定を判断してもらう。
