# MFO Phase 1 Prototype

Gate 0で承認されたPhase 1だけを検証する独立Godotプロジェクトです。本番ゲーム基盤ではありません。

## Vertical path

```text
InputAdapter
→ InputCommand
→ LocalAuthoritySimulation
→ Actor collection / provisional HitQuery
→ DomainEvent
→ DebugHUD / placeholder presentation
```

## Included

- 1920×1080の固定方角2D検証面
- ゲームパッドとキーボード・マウスを同じ抽象入力へ変換
- 右スティック照準を、実際のマウス移動があるまで保持
- 独立した8方向移動と全方向照準
- stable entity IDを持つ1要素のActor集合とtarget ID境界
- debug-only仮攻撃A
- 静的ダミーへの一度だけの命中
- player-critical最小判定予約と必ず行う返却
- RHL-001～003の起動時検証（未実装範囲はN/Aを記録）
- FPS、P95 frame time、Actor数、active query数、命中結果のHUD／ログ
- 決定的headless tests（36 assertions）
- アリーナと真の空シーンを切り替える計測bootstrap
- Windows x86_64 portable export preset

## Explicitly excluded

正式な快斬・重断、素材、CombatForm、Integrity、Deformation、魔法、ボス、部位、工場、ギミック、剥ぎ取り、ネットワーク、アカウント、課金、本番アセットはPhase 1へ含めません。

## Controls

| Action | Gamepad | Keyboard / Mouse |
|---|---|---|
| Move | Left stick | WASD |
| Aim | Right stick | Mouse |
| Provisional attack A | X | Left click |

他の承認済み入力名はInputMapへ予約しますが、Phase 1ではゲーム結果を発生させません。

## Commands

```powershell
# Import and parse project
godot --headless --editor --path . --quit

# Tests
godot --headless --path . --script res://tests/run_phase1_tests.gd

# Release-equivalent Windows export
godot --headless --path . --export-release "Windows Desktop" build/windows/MFO-Phase1.exe

# Release build measurement and screenshot
build/windows/MFO-Phase1.exe -- --phase1-measure `
  --phase1-report=C:/absolute/path/phase1-arena-performance.json `
  --phase1-capture=C:/absolute/path/phase1-arena-capture.png

# Empty-scene measurement
build/windows/MFO-Phase1.exe -- --phase1-empty --phase1-measure `
  --phase1-report=C:/absolute/path/phase1-empty-performance.json
```

`--phase1-measure`中は外部入力を停止し、600フレームの静止ベースラインを再現可能にします。操作感の確認は通常起動で別に行います。画像保存は600フレーム採取後に行われるため、計測サンプルへ混入しません。

## Delivery

- [Phase 1 implementation report](../implementation/2026-07-14-phase1-technical-baseline.md)
- [Windows x86_64 portable ZIP](../deliverables/phase1/MFO-Phase1-Windows-x86_64.zip)
- [Measurement evidence](../deliverables/phase1/evidence/)
