# Phase 2 Slice 2-A Stage B Validation Report

- Work order: [`MFO-WO-P2-2A-001`](../work-orders/phase2-slice2a-basic-operation.md)
- Report date: 2026-07-14 (Asia/Tokyo)
- Reporter: `30 QA・性能・レビュー`
- QA branch: `codex/phase2-slice2a-qa`
- QA start HEAD: `92f71d7c3e55108a2faecaa6fbf1e1055b0d0b9f`
- Implementation source commit: `bd01fdf3d048accaa7f5be93afe3be5cfa138201`
- Comparison baseline: `afcd20cd4a02d618a5d7e0e4bc7555a64fa90740`
- QA tests／report commit: `TO_BE_RECORDED_AFTER_QA_CONTENT_COMMIT`
- Slice 2-A recommendation: **Fail**
- Gate 2: **Locked / not evaluated**

## 1. Outcome

Stage Bをfreshに実行した。Phase 1回帰、通常の回避方向、距離、時間、reuse境界、bufferなし、collision、
bounds、reset残留、unknown actor、import、export、smokeは合格した。一方、作業票が要求する
「accepted evadeは全てのnonzero movement inputをaim fallbackより優先する」に再現可能な差分が1件ある。

したがって`30 QA`はSlice 2-Aを**Fail**として`00統括`へ返す。これはGate 2判定でもSlice 2-B着手許可でもない。

## 2. Scope and provenance

`afcd20c..bd01fdf`の実装差分は次の許可済み4ファイルだけであり、`git diff --check`はexit `0`だった。

- `prototype/scripts/input/input_adapter.gd`
- `prototype/scripts/simulation/input_command.gd`
- `prototype/scripts/simulation/local_authority_simulation.gd`
- `prototype/scripts/simulation/player_actor.gd`

handoff HEAD `92f71d7`は上記実装に実装報告とgameplay handoffだけを追加している。`.tscn`、`project.godot`、
camera、presentation、combat definition、production event payload、build設定、既存Phase 1 testの変更はない。
retry binding、defeat、`Integrity`、damage、HUD、VFX、lock-on挙動、network、persistenceも追加されていない。
OQ-005は未解決のままで、QAはretry入力を要求していない。

実装担当が報告した36/36および25/25は補助情報に留め、この報告の合否には使用していない。

## 3. Fresh automated results

| Check | Fresh result | Exit | Evidence | Disposition |
|---|---:|---:|---|---|
| Import／parse | completed | `0` | `import-parse-*` | Pass |
| Existing Phase 1 regression | `36 / 36` | `0` | `phase1-regression-*` | Pass |
| Slice 2-A deterministic suite | `119 / 120` | `1` | `slice2a-tests-*` | **Fail** |
| Main-scene headless smoke | completed / RHL violation `0` | `0` | `main-scene-headless-*` | Pass |
| Windows release export | completed | `0` | `release-export-*` | Pass |
| Exported-EXE headless smoke | completed / RHL violation `0` | `0` | `release-headless-smoke-*` | Pass |

`import／parse`にはsandbox-localな`user://` ObjectDB snapshot directory警告があるが、終了code `0`でfile scanと
parseは完了した。gameplay failureとは分類しない。

### Required behavior matrix

| Required observation | Result | Fresh evidence summary |
|---|---|---|
| Space／gamepad Aの同一abstract action、fresh pressのみ | Pass | mapping、idempotence、held non-repeat |
| 8方向等速移動と独立aim | Pass | 8方向ごとにdistance、direction、independent aimを確認 |
| move方向優先 | **Fail at edge** | 通常／斜めはPass。deadzone直上の小さいnonzeroだけaimへfallback |
| neutral時aim fallback | Pass | neutral commandでaim方向へ`140 px` |
| 斜め正規化 | Pass | 軸方向と同じ総距離、X／Y成分対称 |
| 12 active ticks、`140 px / 0.20 s` | Pass | tolerance `<= 0.1 px`、time tolerance `<= 0.00001 s` |
| step中のaim変更でstep方向不変 | Pass | aimは更新、latched step方向は不変 |
| 通常移動をstep距離へ加算しない | Pass | active中の逆入力でもstepは`140 px`、終了後に通常移動再開 |
| start tick N+26 reject／N+27 accept | Pass | N+26までreject、N+27 fresh request accept |
| active／cooldown要求のbufferなし | Pass | ready tickにrequestなしで自動発動なし |
| collision非貫通 | Pass | QA fixtureでplayer mask `4`／obstacle layer `4`を明示、swept contact位置一致 |
| bounds非貫通 | Pass | configured edgeへ到達し越境なし、12tickで終了 |
| mid-step reset | Pass | position、initial aim、velocity、active progress、reuseを即時初期化 |
| mid-cooldown reset | Pass | 残留reuse `> 0`からreset後`0`、直後accept可能 |
| 連続reset | Pass | position／aimを含め冪等 |
| unknown actor command／reset | Pass | configured actor不変、ID／sequence／tick監査可能 |
| InputAdapter aim cacheをreset対象へ拡張しない | Pass by scope | reset seamはauthority actor stateだけ。adapter変更追加なし |

## 4. Confirmed defect

### MFO-P2-2A-QA-001 — small nonzero move is treated as neutral

- Classification: confirmed specification defect
- Runtime impact: narrow／Low（主にgamepad deadzone直上）
- Acceptance impact: blocking（作業票§4およびacceptance item 3の明示条件に不一致）
- Reproduction: deterministic, fresh, repeated

Steps:

1. `InputMap.action_get_deadzone(move_right)`からdeadzone直上で、post-deadzone magnitudeが約`0.005`となる
   strengthを生成する。
2. `InputAdapter.capture_command()`が`0 < |move_vector| <= 0.01`を返すことを確認する。
3. `move = Vector2(0.005, 0)`, `aim = Vector2.UP`, `evade = true`をLocal Authorityへ渡す。
4. accepted evadeのlatched directionを確認する。

Expected: nonzero moveをnormalizeした`Vector2.RIGHT`。

Actual: [`local_authority_simulation.gd`](../../material-frontier-online/prototype/scripts/simulation/local_authority_simulation.gd)
の`length_squared() <= 0.0001`判定によりneutral扱いされ、`Vector2.UP`へaim fallbackする。
`player_actor.gd`のaccept guardも同じthresholdを持つため、authority側だけの変更では小入力がrejectされ得る。

限定修正提案:

- A（推奨）: input deadzone適用後のexact zeroだけをneutralとし、authority direction selectionとactor accept guardの
  両方で全nonzero vectorをnormalizeする。距離、duration、reuse、deadzone値は変更しない。
- B: epsilonを仕様上のneutralとしたい場合は、実装で先行せず`00統括`が決定overlayを承認するまで停止する。

作業票はnonzeroを明示しており現在は曖昧性ではないため、QAはAのbounded follow-upを勧告する。QA自身はgameplay
codeを変更していない。

## 5. Manual, user feel, and gamepad

| Evidence class | Result | Note |
|---|---|---|
| QA release-build KBM function | Not run | confirmed defectのbounded correction後に同一checklistを再実行する |
| User feel | Not run | failing candidateについて推測・繰越をしない |
| Physical gamepad | Not run / Deferred | Approved deferral。mapping automationをhardware Passにしない |

KBM checklistはWASD、mouse aim、Space、move-direction、neutral／aim fallback、boundary、repeated-input rejectionを
個別に残す。authority resetはwork orderどおりautomationで十分とし、defeat／retry bindingは要求しない。

## 6. Performance and other QA-owned checks

| Area | Result | Note |
|---|---|---|
| 600-sample arena-idle frame time | Blocked / Not run | `PowerLineStatus = Offline`; AC設定GUIDだけを稼働中AC証拠に流用しない |
| Fresh memory sample | Not run | performance run未成立。過去値をPassに流用しない |
| Attack query count／release | Pass | fresh Phase 1 suiteでcapacity `1`、resolution後active `0`を維持 |
| Breakable part count | Not applicable | Phase 1／Slice 2-Aにpart definitionなし、RHL-001 N/A |
| Stage／presentation regulation | Pass by scope and smoke | scene／presentation差分なし、RHL violation `0` |
| Minimum-quality readability | Not applicable to this slice | presentation変更なし。work orderのmanual対象はstandard quality |

端末はAC用Best performance GUID
`ded574b5-45a0-4f42-8737-46345c09c238`を保持しているが、測定時点はbattery稼働だった。Gate 1の旧性能値は
今回のfresh証拠へ流用していない。修正版の再検証時、AC Onlineを読み戻したうえで120 warmup＋600 samplesを行う。

## 7. Evidence and hashes

Formal evidence directory:
[`evidence/phase2-slice2a/stage-b-20260714-92f71d7/`](evidence/phase2-slice2a/stage-b-20260714-92f71d7/)

| Artifact | SHA-256 |
|---|---|
| Formal QA test source | `03ecfbd34bfb98333d9bdeff5c6ef90cb477090101ea6e4435511509c1e6e91a` |
| Release EXE | `0f4533d6ac4246844f9e0097e8f46e91abaa519164ccc957c7d23d62024cb640` |
| `SHA256SUMS.txt` | `8bc2dcc3a7687e9fae1e0cad7bd7052fa73d07889ce9853fab95e294749c652d` |

全formal evidenceのhashは同directoryの`SHA256SUMS.txt`へ記録する。正式commandは`commands.md`、環境と電源条件は
`environment.json`を参照。formal raw log／stdout／exit evidenceは同directoryの`.gitattributes`でbinary扱いとし、
hash対象byteを保持する。Stage B承認前に実行したQAドラフト証拠は別directoryに保持し、この合否へ流用していない。

## 8. Recommendation and next route

Slice 2-A recommendation: **Fail**。

`00統括`がMFO-P2-2A-QA-001だけを対象とするbounded follow-up orderを発行し、`10`がnonzero判定だけを修正した
commitをhandoffする経路を勧告する。その後`30`は少なくとも次をfreshに再実行する。

1. full Phase 1 regression;
2. full Slice 2-A suite（今回の120 assertionsを弱めない）;
3. import／main smoke／release export／exported smoke;
4. AC Online条件のarena-idle performance regression;
5. release buildのKBM function、user feel、gamepad Deferredを分離した記録。

Gate 2はLockedのままとし、Slice 2-B以降の着手判断は`00統括`へ返す。
