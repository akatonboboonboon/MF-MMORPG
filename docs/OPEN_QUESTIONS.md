# Material Frontier Online — Open Questions

- Updated: 2026-08-15
- Owner: `00統括（監督）`
- P0 unresolved: **0**
- Rule: 未決事項を推測実装しない。担当者は質問を追加できるが、解決・削除・Approved化は監督だけが行う。

## Gate and deferred evidence records

| ID | Priority | Needed before | Question / required record | Owner | Status |
|---|---|---|---|---|---|
| GQ-001 | Closed Gate 1 record | Gate 1 | 基準端末で実際に選択されているWindows電源設定の表示名は何か | `30 QA` | Closed: AC Best performanceで再計測Pass。plan=`バランス`は別field |
| GQ-002 | Closed Gate 1 record | Gate 1 | GPU driver versionと標準画質／release相当の再現条件は何か | QA | Closed: driver `32.0.101.7077`、standard、release-equivalent、1920×1080を記録 |
| GQ-003 | Closed Gate 1 record | Gate 1 | Phase 1実績または再見積りは、同じ単位の試作全体見積りに対して15%以下か | Supervisor | Closed: approved re-estimate `13.83%`。actual timeではない |
| GQ-004 | Playability blocker | Gate Playability | 実ゲームパッドLS/RS/主要アクションは成立し、人間のgamepad操作感評価は合格か | User + `30 QA` | Deferred: gamepad未所持。KBM Passでは代替しない |

## P1 decisions

| ID | Needed before | Question | Approved facts that must remain | Status |
|---|---|---|---|---|
| OD-020 | Phase 2 | 回避無敵、スタミナ、入力キャンセル、部位ロック、自動接近をどうするか | 地上ステップ、独立照準 | Closed / Approved for Phase 2: `140 px / 0.20 s` step、reuse `0.45 s`、無敵／stamina／buffer／target-selection lock-onなし。敗北中のabstract `lock_on` retryは`OD-021-INPUT`の限定例外 |
| OD-021 | Phase 2 retry | 敗北後をリトライ画面、即時初期化、チェックポイントのどれにするか | 敗北はcore `Integrity == 0`、Deformation単独敗北なし | Closed / Approved: same-arena authority reset、checkpoint／専用画面なし。bindingは`OD-021-INPUT`（敗北中`lock_on` `LB`／`Q` fresh press） |
| OD-022 | Phase 4 | バーストボアのAI数値、予兆、フェーズ、部位破壊後変化、標的規則 | 3攻撃と5部位の承認内容 | Open |
| OD-023 | Phase 4 | 部位ダメージを本体へ伝達するか、弱点化だけにするか | 本体coreは6番目の部位ではない | Open |
| OD-024 | Phase 4 | 剥ぎ取り回数、時間、固定／抽選、破壊部位の影響 | 用途器官と内容物サンプル | Open |
| OD-025 | Phase 3 | 電荷、cooldown、共通ゲージ、素材別危険ゲージ等、魔法資源をどうするか | 3魔法は共通効果から構成 | Open |
| OD-026 | Persistent HUD implementation | `Integrity`、`Deformation`、温度、電荷の何を常時表示するか | 表示はread-only、最小UI要件を削らない | Closed / Approved: Integrity＋Deformation常時、temperature実装後、charge Phase 3以降 |
| OD-027 | Phase 2 | 変形ペナルティの対象、閾値、効果量は何か | ペナルティは1種類、値はデータ、Deformation 0～100 | Closed / Approved: `>= 60`で通常移動`-15%` |
| OD-030 | Phase 3 material rules | 現実物性とゲーム上の例外をどの基準で扱い、どう表示するか | 承認済み素材役割とOD-031を維持 | Open |
| OD-033 | SUS430 implementation | 廉価下位職か、磁性等の別役割か | MVP3素材には含まれない | Open |
| OD-040 | Production art | ピクセル、手描き、ベクター、2D骨格等の美術スタイル | 2D、可読性規約 | Open |
| OD-041-P2 | Phase 2 camera | Phase 2基準cameraをどうするか | 1920×1080、斜め俯瞰、固定方角 | Closed / Approved: zoom 1.0、現一画面固定camera |
| OD-041-POST | Before boss/stage camera integration | dynamic zoom、正式画面内人数、boss最大表示寸法、boss／stage framingをどうするか | OD-041-P2をPhase 2基準として維持 | Deferred / Open |
| OD-042 | Audio role activation | 無音、最小SE、仮BGMのどこまでを試作へ含めるか | 本番音響量産は未承認 | Open |
| OD-043-P2 | Phase 2 readability | Phase 2最低可読性をどうするか | ST必須規約、最低画質でも情報維持 | Closed / Approved: 色以外を併用、player／target outline、1080p 24px以上、shakeなし |
| OD-043-POST | Before production presentation | 具体的な色覚補助、予告pattern、他解像度scale、Phase 2後のshake、production文字階層をどうするか | OD-043-P2とST必須規約を維持 | Deferred / Open |
| OD-044 | Phase 7 | 8人・2ボス・30小型敵を何種類の代理で再現するか | 全PST条件を欠落させない | Open |

## Additional P1 contract questions discovered during handoff

| ID | Needed before | Question | Why blocked | Status |
|---|---|---|---|---|
| OQ-001 | Production event integration | 正式`DomainEvent` payloadの位置、部位、素材、channel、数値、IDの必須項目は何か | Phase 1 payloadはdebug schemaで、本番契約ではない | Open |
| OQ-002 | Heavy cleave implementation | 重断の「大きな自己負荷」をどう表すか | Gate 0記録がP1調整として保留 | Closed / Approved for Slice 2-B: `0.50 s` recoveryのみ。Deformation／別self effectなし |
| OQ-003 | Magic/gimmick integration | 濡れ床の電気強化を範囲／効率のどちらで表し、抵抗加熱がどの耐性を下げるか | Gate 0記録がP1調整として保留 | Open |
| OQ-004 | Hit presentation | VFX、素材別接触SE、ヒットストップ、camera shakeのどれを要求し、誰が時間を所有するか | Phase 2 shakeなしだけが承認済み。production art／audio／readability詳細とtiming ownershipは未決定 | Open |
| OQ-005 | Before Slice 2-C defeated-input integration | 敗北中のretry操作をどのabstract actionへ割り当て、press／release／heldのどのedgeを使い、trigger command上の他actionを消費するか | OD-021はretry結果だけを承認。保持aimやneutral commandで自動retryさせない | Closed / Approved by user 2026-08-15 — Option A。command開始時点で`Integrity == 0`かつauthority敗北latch中の場合だけ既存abstract `lock_on`（`LB`／`Q`）のfresh press／`just_pressed`をretry要求として受理する。alive開始command内でfatal latchした同edgeはretryへ使わず繰り越さない。accepted trigger command上のmove／aim／evade／`physical_light`／`physical_heavy`／interactは全消費する。retry-owned configured round stateを初期化するが、current round index／rematch counterは保持して増減させず、rematch eventを生成しない。alive、held／release、neutral／retained aimはretryせず、`E`はinteract／harvest／rematchのまま。新phase／snapshot field／event／signal／UI／自動retryなし。物理gamepadは`Not run / Deferred` |

### OQ-00-20260804-001

- Raised by: FS-A integration（00）
- Date: 2026-08-04
- Priority: P1 / FS-A integration blocker
- Needed before: `MFO-WO-FS-A-00-001` issuance and `fs_a_main.tscn`／snapshot adapter implementation
- Blocked files or feature: `material-frontier-online/prototype/scenes/fast_slice/fs_a_main.tscn`; `material-frontier-online/prototype/scripts/fast_slice/integration/**`; 10 integration-only work-order activation
- Question: Gameplayの`telegraph.active == false`かつ`telegraph.shape == ""`であるinitial／cooldown／stopped snapshotを、`line|sector`だけを受理するPresentation shellへどう渡すか。inactive shapeのcanonical表現とnormalization ownerはどこか。
- Known approved constraints: Gameplayだけがtelegraph意味を決定する。Presentationはread-only。activeな2種は`telegraph_line`／`telegraph_sector`。candidate owned fileをintegration側で手修正しない。Presentation無効時にGameplay結果を変えない。
- Options considered (no default selection): (A) integration adapterがinactive empty shapeだけをPresentation用copyの非表示placeholderへ正規化し、`active == false`を保持する。(B) 20 ownerの新candidateでPresentation schemaがinactive empty shapeを受理する。(C) 10 ownerの新candidateでGameplayがinactive時もcanonical shapeを返す。各案はowner／evidence／再review範囲が異なる。
- Relevant spec / decision: `docs/FAST_SLICE_CONTRACT.md` Sections 4, 6, 7; Gameplay source tip`17773c5f186dfbbd1a1e52a304df123b76d9ad35`; Presentation source tip`04893d6d304e0d23a68df0bd1afc2fa8e71cc461`
- Status: Closed / Approved by user 2026-08-14 — Option A。integration adapterがinactive empty shapeだけをPresentation用deep copyの非表示`line`へ正規化し、`active == false`を保持する。source snapshotは不変。active empty／unknown shapeはfail closed。

### OQ-00-20260815-001

- Raised by: FS-A integration（00）
- Date: 2026-08-15
- Priority: P1 / FS-A promotion blocker
- Needed before: Presentation spatial-parity rework work order、review済みrework candidateの統合、manual KBM再検証
- Blocked files or feature: `material-frontier-online/prototype/scripts/fast_slice/presentation/**`; FS-Aのmove／aim／evade、attack reach、telegraph／hit領域、harvest位置のuser-visible parity
- Question: authority actorを非表示にしてpure Presentation shellだけを表示するFS-Aで、既存Gameplay snapshotの`player_position`、`player_aim`、`boss_position`、`parts[*].position`、`harvest_points[*].position`、`telegraph.origin`／`direction`／`range`／`half_width`／`half_angle`を、20が必ずread-only描画へ使う共有spatial seamとして承認するか。
- Known approved constraints: Gameplay snapshotだけがauthority。Presentationはread-onlyでwrite-backしない。move／aim／evadeは既存挙動を維持し、light／heavy、予兆、hit、wreck、harvestをuserが同じarena座標で観察できなければならない。`fs_provisional`値、hit／damage／result meaningは変更しない。
- Options considered (no default selection): (A) 上記の既存additive fieldをFS-A required spatial seamへ昇格し、20が同一座標系で描画する。(B) integration adapterが別のPresentation座標へ変換する新mappingを追加する。(C) authority actorを可視化してpure shellの固定proxyを併存または除去する。現候補の固定proxyをmanual acceptanceとして維持する案はContract Section 10を満たさない。
- Relevant spec / decision: `docs/FAST_SLICE_CONTRACT.md` Sections 3, 6, 7, 10; `docs/MASTER_SPEC.md`; manual-002 finding 2026-08-15; frozen candidate `867899c7ccb9380b4bb6e4be5c51da4223532230`
- Status: Closed / Approved by user 2026-08-15 — Option A。列挙済みの既存fieldをFS-A required spatial seamとし、20がauthority arenaと同一座標系でread-only描画する。Gameplay/source meaning、write-back、integrationの別座標mapping、`fs_provisional`、hit／damage／result meaningは変更しない。

### OQ-00-20260815-002

- Raised by: FS-A integration（00）
- Date: 2026-08-15
- Priority: P1 / FS-A promotion blocker
- Needed before: player defeat Gameplay rework work order、manual KBM再検証
- Blocked files or feature: `material-frontier-online/prototype/scripts/fast_slice/gameplay/**`; player `Integrity == 0`後のauthority停止、enemy AI／telegraph／attack／pending hit
- Question: 既Approvedのcanonical条件`player_integrity == 0`によるFS-A敗北で、player move／evade／action／hit query／pending actionと、enemy AI／telegraph／attack／pending hitをそれぞれどこまで停止するか。新phase／snapshot field／eventは追加しないか。
- Known approved constraints: `Integrity == 0`はplayer敗北。retry結果はsame-arena authority resetだが、retry action／edge／同一commandの他action消費は`OQ-005`未決。`E` harvest／rematchをdefeat retryへ流用せず、保持aimやneutral commandで自動retryしない。`ActorDefeated` event payloadは`OQ-001`未決。
- Options considered (no default selection): (A) positive→0をexact once latchし、player機能とenemy AI／telegraph／attack／pending hitをresetまで停止する。boss HP／`boss_functional`／parts／wreck／resultは変更せず、retry binding／新field／event／phaseは追加しない。(B) player機能と追加damageだけを停止し、enemy telegraph／attack表示は継続する。(C) 明示的なdefeat phase／field／eventとretry入力を同時追加するが、これは`OQ-005`／`OQ-001`解決と広い再reviewを要する。
- Relevant spec / decision: `docs/MASTER_SPEC.md` lines 141, 148-150; `docs/DECISIONS.md` `OD-021`; `docs/OPEN_QUESTIONS.md` `OQ-001`／`OQ-005`; `docs/FAST_SLICE_CONTRACT.md` Sections 3, 7, 10; manual-002 finding 2026-08-15
- Status: Closed / Approved by user 2026-08-15 — Option A。`player_integrity` positive→0をexact once latchし、authority resetまでplayer move／evade／action／hit query／pending actionおよびenemy AI／telegraph／attack／pending hitを停止する。boss HP／`boss_functional`／parts／wreck／resultは不変。retry binding、新field／event／phase／UI、自動retryは追加しない。

### OQ-00-20260815-003

- Raised by: FS-A integration（00）
- Date: 2026-08-15
- Priority: P1 / FS-A promotion blocker
- Needed before: opening-pressure Gameplay rework work order、manual KBM／user feel再検証
- Blocked files or feature: `material-frontier-online/prototype/data/fast_slice/fs_a_provisional_tuning.tres`; fresh arena opening safety、defeat retry／rematch configured start
- Question: 現`player_start_position = Vector2(520, 540)`はbossから`830 px`で、初手line range `980 px`内にある。開始直後から静止playerへline attackが到達するnegative playability findingを、FS-A内でどう解消するか。
- Known approved constraints: 既存movement bounds、`player_start_aim`、boss／part／harvest位置、telegraph／attack geometry・timing・damage、enemy selection／cooldown、spatial snapshot seamを維持する。grace／invulnerability／新stateを追加せず、値をstable production balanceやGate証拠へ昇格しない。
- Options considered: (A) FS-A `fs_provisional`のplayer startだけを`Vector2(200, 540)`へ移し、現line／sector range外へ置く。(B) initial cooldownを延ばして初回被弾だけを遅らせる。(C) line rangeを短縮してencounter全体のgeometryを変更する。(D) 現状を既知制約として維持する。
- Relevant spec / decision: `docs/FAST_SLICE_CONTRACT.md` Sections 3, 4, 7, 10; `FS-A-OPENING-SPAWN`; manual-closure final `e261392dd0944d09d0ac6f3a6fef9b0346795c10`
- Status: Closed / Approved by user 2026-08-15 — Option A。FS-A `fs_provisional`の`player_start_position`だけを`Vector2(520, 540)`から`Vector2(200, 540)`へ変更する。initial aim、boss position、movement bounds、attack／telegraph geometry・timing・damage、enemy selection／cooldownは変更せず、production値／Gate証拠へ昇格しない。

## P2 backlog

- OD-015: 添付画像の差分確認。MVP決定根拠へ使う場合だけP0へ繰り上げる。
- 捕獲・封入と討伐の報酬差。
- 元素／材料／加工／組織／形状／用途ツリー、非金属材料、完全魔法体系、パーティーロール。
- 疲労破壊後の設計知識継承。
- キャラクタークリエイト、外装、仕上げ、紋章。
- 正式BGM／SE／voice制作方式、詳細アクセシビリティ、製品プラットフォーム順。
- MMOサーバー、アカウント、ロビー、ギルド、市場、課金。

## Question template

新規質問は、既存IDと重複しない `OQ-<role>-<date>-<number>` を使う。

```text
ID:
Raised by:
Date:
Priority: P0 / P1 / P2 / Gate blocker
Needed before:
Blocked files or feature:
Question:
Known approved constraints:
Options considered (no default selection):
Relevant spec / decision:
Status: Open
```

回答案をcode、test、asset、handoffだけへ埋め込まない。ユーザー承認後、監督が`DECISIONS.md`へ移し、
関連するMASTER_SPEC、契約、マイルストーンを同じ変更で同期する。
