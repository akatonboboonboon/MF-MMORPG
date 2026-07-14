# Work Order — Phase 1 Gate 1 Manual Validation

- Work order ID: `MFO-WO-P1-G1-001`
- Issued by: `00統括（監督）`
- Issued: 2026-07-14 (Asia/Tokyo)
- Assigned to: `30 QA・性能・レビュー` + user
- Status: Deferred to Gate Playability / physical validation not passed
- Milestone: M1 / Gate 1
- Code changes authorized: **No**

## 1. Objective

実ゲームパッドでPhase 1の左stick移動、右stick照準、X仮攻撃、標的命中を確認し、
人間による操作感を証拠付きで記録する。

2026-07-14 supervisor disposition: ユーザーが現在gamepadを所持していないため、
`GATE-1-INPUT-EVIDENCE`により本票の実行時期をGate Playability承認前へ延期した。checklistは将来の
物理実機確認手順として維持し、KBM結果でPassへ置き換えない。

このwork orderは当初からGateを自動的にPassへしない。2026-07-14の延期後、`30`は将来の結果を
Pass／Fail／Blockedで`00`へ報告し、Gate Playabilityの証拠として扱う。Gate 1へ遡及適用しない。

## 2. Validation target

| Field | Required value |
|---|---|
| Source code baseline | `a13505e8fbf82962e049b9101a87593a6692d2c7` |
| Package | `material-frontier-online/deliverables/phase1/MFO-Phase1-Windows-x86_64.zip` |
| Package SHA-256 | `88d21f91d547de8c8bdc766c144777872f000a3fe356fb26ade8717fe010e983` |
| Packaged EXE SHA-256 | `13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199` |
| Engine | Godot `4.7.stable.official.5b4e0cb0f` |
| Launch mode | ZIPを新規フォルダーへ展開し、EXEを通常起動 |

`--phase1-measure`、`--headless`、自動入力は使用しない。idle性能測定と手動操作確認を混ぜない。

## 3. Roles

- User: 実ゲームパッドを操作し、体感と現象を回答する。
- `30 QA`: controller／環境を記録し、checklist、証拠、Pass／Failをまとめる。
- `00統括`: 報告と残るGate条件を確認し、Gate 1を判定する。
- `10コア`: Fail時に`00`から限定修正票が発行された場合だけ、指定defectを修正する。
- `20表現`: 本work orderではcode／assetを変更しない。

## 4. Before launch

次を記録する。

```text
Test date/time:
Tester:
Commit / package hash verified:
Gamepad manufacturer and model:
Connection: wired / wireless
Windows controller name:
OS build:
GPU driver:
Display resolution / refresh:
Windows power mode display name:
Build and quality setting:
Evidence folder:
```

package／EXE hashが一致しない、LFS pointerしかない、controllerがWindowsで認識されない場合は
操作試験へ進まず`Blocked`として記録する。

## 5. Manual checklist

### Left stick — movement

| Check | Pass criterion | Result | Notes / evidence |
|---|---|---|---|
| 上／下／左／右 | 4方向へ意図どおり移動できる | Pending | |
| 4斜め方向 | 斜めを含む8方向へ移動できる | Pending | |
| 斜め速度 | 縦横より極端に速くならない | Pending | |
| neutral stop | stickを離すと滑り続けず停止する | Pending | |
| snag / jitter | 通常移動に異常な引っ掛かりや振動がない | Pending | |

### Right stick — aim

| Check | Pass criterion | Result | Notes / evidence |
|---|---|---|---|
| independent aim | 移動方向と独立して全方向を照準できる | Pending | |
| neutral retention | stickを離しても照準が暴れたり流れ続けたりしない | Pending | |
| move + aim | 移動しながら別方向を照準できる | Pending | |
| mouse handoff | 実mouse移動後の切替が破綻せず、stickへ戻せる | Pending | |
| snag / jitter | 照準に異常な引っ掛かりや震えがない | Pending | |

### X button — provisional attack A

| Check | Pass criterion | Result | Notes / evidence |
|---|---|---|---|
| activation | Xを1回押すと仮攻撃Aが1回発動する | Pending | |
| aim direction | 現在の照準方向へ攻撃する | Pending | |
| target hit | 射程・方向が正しければ標的へ命中し、hit countが増える | Pending | |
| no false hit | 標的と逆方向では命中しない | Pending | |
| latency | 入力後に人間が異常と感じる遅延がない | Pending | |
| repeat behavior | 1回入力で異常な多重発動をしない | Pending | |

## 6. Human feel record

数値測定ではなく、tester本人の評価として記録する。

```text
Movement feel: Pass / Fail
Aim feel: Pass / Fail
Attack response: Pass / Fail
Input delay: none / noticeable but acceptable / unacceptable
Snagging or drift: none / present (describe)
Mouse ↔ gamepad switching: natural / acceptable / unacceptable
Overall Phase 1 feel: Pass / Fail
Free-form observations:
```

## 7. Evidence

最低限:

- controller名と接続方式の記録
- checklist各項目の結果
- arenaが起動し、target hit countを確認できるscreenshot
- drift、遅延、引っ掛かりがある場合は短いvideoまたは再現手順
- testerの所感

証拠を新規作成する場合は `docs/test-reports/evidence/phase1-gate1/` または
QAが指定したartifact場所へ保存し、reportから相対linkする。個人情報、token、不要なdesktop全体を写さない。

## 8. Required report

`30 QA`は次のpathへ報告を作成する。

```text
docs/test-reports/phase1-gate1-manual-validation.md
```

報告には次を含める。

```text
Work order ID:
Commit and artifact hashes:
Environment and gamepad:
Checklist results:
Human feel result:
Evidence links:
Defects found:
Gate 1 recommendation: Pass / Fail / Blocked
Reasons:
```

## 9. Failure routing

Failを見つけた場合:

1. `30`が現象、再現手順、期待結果、実際の結果、証拠、重大度を記録する。
2. `00`がPhase 1 defectか仕様質問かを判定する。
3. defectの場合だけ、`00`が`10`へその1件に限定した修正work orderを発行する。
4. `10`はPhase 2機能を同時実装しない。
5. 修正後、`30`＋userが同じchecklistを再実施する。

## 10. Completion and Gate rule

このwork orderの完了条件:

- 全checklistにPass／Fail／Blockedが記録されている。
- userの操作感評価が記録されている。
- evidence linkと`30`のGate勧告がある。

完了してもGate Playabilityは自動Passにならない。`00`が他のPlayability条件と合わせて正式判定する。
