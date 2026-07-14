# Phase 1 Gate 1 Manual Validation Report

- Work order: [`MFO-WO-P1-G1-001`](../work-orders/phase1-gate1-manual-validation.md)
- Report date: 2026-07-14 (Asia/Tokyo)
- Reporter: `30 QA・性能・レビュー`（user経由の事前確認報告）
- Report state: Preliminary / Blocked before manual input checks
- Gate 1 recommendation: **Blocked / remain Pending**
- Game code changes by QA: 0
- Work order changes by QA: 0

## 1. Artifact precheck

| Check | Expected | Actual | Result |
|---|---|---|---|
| Phase 1 ZIP SHA-256 | `88d21f91d547de8c8bdc766c144777872f000a3fe356fb26ade8717fe010e983` | Match reported | Pass |
| Packaged EXE SHA-256 | `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` | Match reported | Pass |
| Git LFS materialization | Real artifact required | 実体を確認 | Pass |

## 2. Environment precheck

| Field | Recorded value | Result / note |
|---|---|---|
| OS | Windows 11 Home `10.0.26200` | Recorded |
| Windows power plan display name | `バランス` | Recorded, but performance-priority compliance is not established |
| Windows power mode display name | Not reported | Required before Gate 1 decision |
| GPU driver | Not reported | Required before Gate 1 decision |
| Gamepad detection | Windows上で検出できず | Blocker |
| Gamepad manufacturer / model | Not available | Await connection |
| Connection method | Not available | Await connection |

承認済みOD-004は基準端末を「性能優先」とする。現在報告された`バランス`はpower plan名であり、Windowsのpower modeが別に`最適なパフォーマンス`等へ設定されているかは不明である。推測で合格扱いにせず、実表示を追加記録する。

## 3. Manual input checks

gamepadがWindows上で検出されていないため、次は未実施。

| Area | Status |
|---|---|
| Left stick 8-direction movement / diagonal speed / neutral stop | Not run |
| Right stick independent aim / neutral retention / mouse handoff | Not run |
| X provisional attack / aim direction / target hit / latency | Not run |
| Human movement / aim / attack feel | Not run |

## 4. Evidence

現時点ではuser経由のQAテキスト報告のみ。Controller画面、実行画面、manual checklistのartifactは未提出。

## 5. Blocking conditions

1. Windowsがgamepadを検出していない。
2. Gamepad manufacturer・modelと有線／無線が未記録。
3. Windows power modeの実表示が未記録で、承認済み「性能優先」との一致を確認できない。
4. GPU driverが未記録。
5. Phase 1工数15%以下の証跡が未提出。

## 6. Next action

1. userがgamepadを接続し、Windows controller一覧で認識を確認する。
2. manufacturer・model、有線／無線、Windows controller名を`30 QA`へ伝える。
3. Windows設定のpower mode実表示とGPU driverを記録する。
4. `30 QA`がwork order §5のLS／RS／Xを順番に案内し、user回答と証拠を本reportへ追記する。
5. 全結果とhuman feelが揃うまでGate 1をPendingに保つ。
