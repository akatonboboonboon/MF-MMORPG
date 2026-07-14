# Work Order — Phase 1 Gate 1 Power Revalidation

- Work order ID: `MFO-WO-P1-G1-002`
- Issued by: `00統括（監督）`
- Issued: 2026-07-14 (Asia/Tokyo)
- Assigned to: `30 QA・性能・レビュー` + user
- Status: Active
- Milestone: M1 / Gate 1
- Code changes authorized: **No**
- Required report: `docs/test-reports/phase1-gate1-power-revalidation.md`

## 1. Objective

承認済みOD-004と異なる省電力優先状態を解消し、同じ基準端末・標準画質・release相当buildで
1920×1080／60fpsのGate 1性能証拠を取り直す。既存のKBM証拠とユーザー体感を事実どおり集約し、
gamepad未実施をKBM結果で代替しない。

## 2. Known precheck

| Field | Recorded value | Disposition |
|---|---|---|
| GPU | `Intel(R) Graphics` | Recorded |
| GPU driver | `32.0.101.7077` (`2025-09-16`) | Recorded |
| Windows power plan | `バランス` | Record separately from power mode |
| AC power mode GUID | `961cc777-2547-4f9d-8174-7d86181b8a7a` | Fail: Best Power Efficiency |
| DC power mode GUID | `961cc777-2547-4f9d-8174-7d86181b8a7a` | Recorded; AC test does not use this value |
| Gamepad | Not owned / Windows not detected | Deferred by `GATE-1-INPUT-EVIDENCE` |
| User KBM feel | `問題なし` | Overall KBM feel only; do not expand to itemized or gamepad Pass |

Microsoft Learn identifies `961cc777-2547-4f9d-8174-7d86181b8a7a` as
`GUID_POWER_MODE_BEST_EFFICIENCY` and `ded574b5-45a0-4f42-8737-46345c09c238` as
`GUID_POWER_MODE_BEST_PERFORMANCE`:

- [PowerGetUserConfiguredACPowerMode](https://learn.microsoft.com/ja-jp/windows/win32/api/powrprof/nf-powrprof-powergetuserconfiguredacpowermode)

## 3. Authorized procedure

1. userが基準端末をAC電源へ接続し、Windows power modeを`Best performance`相当へ変更する。
2. `30 QA`は変更後のAC power mode表示名とGUIDを取得する。期待GUIDは
   `ded574b5-45a0-4f42-8737-46345c09c238`。power plan名も別fieldとして残す。
3. package／EXE hash、OS、GPU、driver、1920×1080、標準画質、release相当buildを記録する。
4. `material-frontier-online/prototype/README.md`の既存手順でempty sceneとarena idleを再計測する。
5. 600 samples、HUDとJSONのP95一致、P95 `<= 16.67 ms`、screenshotを記録する。
6. raw command、stdout、exit code、JSON、screenshot、SHA-256を新規evidenceとして保存する。
7. ユーザーが希望する場合は計測後に元のpower modeへ戻し、その事実をreportへ記録する。

## 4. KBM and gamepad disposition

- 既存記録のKBM移動・照準・仮攻撃・命中はGate 1の入力機能証拠として参照してよい。
- ユーザーの`問題なし`は`Overall KBM feel: Pass`として原文の範囲だけ記録する。
- movement／aim／attack delay等の個別回答を推測でPassにしない。
- gamepad LS／RS／X、drift、多重入力、gamepad feelは`Not run / Deferred`のままにする。
- gamepadを所持していない間、manufacturer／model／接続方式を繰り返し質問しない。

## 5. Forbidden scope

- game code、scene、asset、test code、build設定の変更
- 性能値を通すための画質低下、window縮小、sample削減
- 旧evidenceの上書き
- KBM結果によるgamepad Passの推定
- Phase 2機能の実装

## 6. Acceptance and routing

`30 QA`は各項目をPass／Fail／Blocked／Not runに分け、Gate 1勧告をreportへ記録する。power modeが
Best performanceでない、再現条件が欠ける、またはP95が16.67msを超える場合はPassにしない。

Failを見つけた場合、`30`は再現条件と証拠を記録し、`00`へ戻す。`10`は個別修正票が出るまで変更しない。
このwork order完了だけではGate 1を自動承認しない。
