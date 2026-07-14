# Material Frontier Online — Phase 1 Technical Baseline

- Date: 2026-07-14 (Asia/Tokyo)
- Scope: Gate 0承認済みPhase 1のみ
- Result: **自動技術ベースライン完了**
- Gate 0: **Open**
- Gate 1: **実ゲームパッドと人間による操作感確認待ち**

## 1. Authority and frozen baseline

- Gate 0 authority: [`../decisions/2026-07-13-gate-0-p0-approval.md`](../decisions/2026-07-13-gate-0-p0-approval.md)
- Frozen Word: [`../deliverables/Material-Frontier-Online-Integrated-Specification.docx`](../deliverables/Material-Frontier-Online-Integrated-Specification.docx)
- Frozen Word SHA-256: `66df0882ad4320b07850c745a0ac7cc5d8e091e0f4dd66a38e9d6237bb89babf`

Phase 1実装では10仕様書と統合Wordを変更していない。

## 2. Implemented vertical path

```text
InputAdapter
→ InputCommand (actor_entity_id / target_entity_id)
→ LocalAuthoritySimulation (one-entry Actor collection)
→ PlayerActor / provisional HitQuery
→ DomainEvent (command tick preserved)
→ DebugHUD / placeholder presentation
```

実装済み:

- Godot Engine 4.7 stable official / GDScript / GL Compatibility
- 1920×1080、固定方角の2D検証面
- キーボード・マウス／ゲームパッドの抽象入力
- 右スティック照準の所有権保持と、実マウス移動による切替
- 8方向移動、独立した全方向照準
- 1要素のActor集合、stable actor ID、optional target ID
- debug-only仮攻撃A、静的標的、一度だけの命中
- Action / Effectリソース定義
- player-critical判定予約、技別容量1、必ず行う返却
- DomainEvent、最小HUD、性能レコーダー
- RHL-001～003の起動時検証とN/A記録
- 真の空シーンとアリーナを切り替えるbootstrap
- Windows x86_64 release export

明示的な除外:

- 正式な快斬・重断
- MaterialJob、CombatForm、EquipmentInstance
- Integrity、Deformation、Heat、BurnCurse、疲労
- 魔法、ボス、破壊可能部位、飲料充填工場、ギミック、剥ぎ取り
- MMO通信、アカウント、課金、本番アート・音響

## 3. Engine reproducibility

| Item | Value |
|---|---|
| Engine | `4.7.stable.official.5b4e0cb0f` |
| Editor archive SHA-512 | `41645a908eb3181d6f2d1201ed7b6d6f095f6a23aaed8903d5d255277cc8d142814f3e6817f865b3cac142c39b8aff99280091d3bbdaa301517730b3ba0522b9` |
| Export templates SHA-512 | `1035dfde4edcc2472bb0c0b9610ce3ee9302642c2b9957e9066372f9f6bb759ab250c8887551a66f0bc5f51bbd9a58bb45e33a0f29844e97615a9b1138c1120e` |
| Renderer | `gl_compatibility` |
| Target | Windows x86_64 portable |

両アーカイブはGodot公式`SHA512-SUMS.txt`と一致した。

## 4. Automated verification

| Check | Result |
|---|---|
| Full project import / parse | Pass |
| Automated assertions | **36 / 36 Pass** |
| Main scene headless smoke | Pass |
| Windows release export | Pass |
| Exported EXE headless smoke | Pass |
| ZIP extraction + enclosed EXE headless smoke | Pass |
| RuntimeHardLimit startup records | RHL-001 N/A / RHL-002 Pass / RHL-003 N/A / 0 violations |

自動テストでは、定義検証、判定予約、InputMapの重複防止、KBM／ゲームパッド割当、照準所有権、Actor ID解決、未知Actor拒否、command tick保持、target ID、命中／非命中、RHL記録を検証した。テスト中はlive inputを停止し、注入コマンドだけを実行する。

## 5. Reference device and performance

| Field | Value |
|---|---|
| CPU | Intel(R) Core(TM) 7 150U |
| GPU | Intel(R) Graphics |
| RAM | 16 GB DDR5（P0記録値） |
| OS | Windows 11 Home / build `10.0.26200` |
| Window | 1920×1080 |
| Refresh | 60.0007 Hz |
| Warmup | 120 frames |
| Sample | 600 frames |

### Final measurements

| Scenario | Average | P50 | P95 | P99 | Maximum | FPS from average |
|---|---:|---:|---:|---:|---:|---:|
| Empty | 16.674 ms | 16.667 ms | **16.667 ms** | 16.667 ms | 19.959 ms | 59.972 |
| Arena idle baseline | 16.702 ms | 16.667 ms | **16.667 ms** | 18.056 ms | 21.506 ms | 59.874 |

判定:

- Gate 1の空シーン条件は、P95 16.67 ms以下を満たした。
- アリーナ静止ベースラインもP95 16.67 ms以下を満たした。
- HUDの`FRAME P95 (600)`とJSONは同一600サンプルを使用し、キャプチャ上も16.67 msで一致する。
- 画像保存は採取完了後に行い、サンプルへ混入しない。
- 計測中はlive inputを停止する。通常操作と性能ベースラインを混ぜないためである。

これは`PrototypeStressTarget`の8表示Actor、2大型敵、30小型敵、50判定を再現した試験ではない。正式性能合格、Gate 7合格、製品最低環境の保証を意味しない。Godot `TIME_PROCESS`モニターの更新特性と`static_memory_bytes = 0`のため、今回のCPU詳細値とメモリ値は受入判定に使用しない。GL CompatibilityでportableなGPU per-frame timingも取得できない。

## 6. Manual observation

Windows release EXEを通常起動し、KBM入力によるプレイヤー位置の変化、マウス照準、標的への命中数増加を実画面で確認した。実ゲームパッドの左スティック、右スティック、Xボタンと、操作の気持ちよさは未確認である。

したがって、**Gate 1判定は「manual validation pending」として保持**する。ゲームパッド実機確認と人間による操作感評価なしに、正式アクションやコンテンツ実装へ進めない。

## 7. Deliverables and hashes

| Artifact | SHA-256 |
|---|---|
| [`MFO-Phase1-Windows-x86_64.zip`](../deliverables/phase1/MFO-Phase1-Windows-x86_64.zip) | `88d21f91d547de8c8bdc766c144777872f000a3fe356fb26ade8717fe010e983` |
| Packaged `MFO-Phase1.exe` | `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` |
| [`phase1-arena-performance.json`](../deliverables/phase1/evidence/phase1-arena-performance.json) | `5bd703c3b1338b9e800dcc8e73f723ae4a8fcc227418e1b119e11c9f1dc8eefe` |
| [`phase1-empty-performance.json`](../deliverables/phase1/evidence/phase1-empty-performance.json) | `73902c7b9de22c2c5fa36fdec973badb081b4e6ddcc770348120525ecfcd3e33` |
| [`phase1-arena-capture.png`](../deliverables/phase1/evidence/phase1-arena-capture.png) | `7368fbfcde6c126b3d3c01bb80744f0bfc2052f02241d5166ec2873923b15884` |

ZIPにはEXE、起動説明、Godot Engine MITライセンスを同梱した。展開後のEXEをheadless起動してexit code 0を確認済み。

## 8. Next decision

1. 実ゲームパッドで左スティック移動、右スティック照準、X入力を確認する。
2. 移動、照準、仮攻撃の操作感を人間が評価する。
3. OD-041基準カメラ等、該当Phaseへ入る前のP1決定を行う。
4. Gate 1判定後にのみ、正式な2物理攻撃や次の実装フェーズへ進む。
