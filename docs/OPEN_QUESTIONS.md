# Material Frontier Online — Open Questions

- Updated: 2026-07-14
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
| OD-020 | Phase 2 | 回避無敵、スタミナ、入力キャンセル、部位ロック、自動接近をどうするか | 地上ステップ、独立照準 | Closed / Approved for Phase 2: `140 px / 0.20 s` step、reuse `0.45 s`、無敵／stamina／buffer／lock-on等なし |
| OD-021 | Phase 2 retry | 敗北後をリトライ画面、即時初期化、チェックポイントのどれにするか | 敗北はcore `Integrity == 0`、Deformation単独敗北なし | Closed / Approved: same-arena authority reset、checkpoint／専用画面なし。bindingはOQ-005 |
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
| OQ-002 | Heavy cleave implementation | 重断の「大きな自己負荷」を後隙、Deformation補正、別作用のどれで表すか | Gate 0記録がP1調整として保留 | Open |
| OQ-003 | Magic/gimmick integration | 濡れ床の電気強化を範囲／効率のどちらで表し、抵抗加熱がどの耐性を下げるか | Gate 0記録がP1調整として保留 | Open |
| OQ-004 | Hit presentation | VFX、素材別接触SE、ヒットストップ、camera shakeのどれを要求し、誰が時間を所有するか | Phase 2 shakeなしだけが承認済み。production art／audio／readability詳細とtiming ownershipは未決定 | Open |
| OQ-005 | Before Slice 2-C defeated-input integration | 敗北中のretry操作をどのabstract actionへ割り当て、press／release／heldのどのedgeを使い、trigger command上の他actionを消費するか | OD-021はretry結果だけを承認。保持aimやneutral commandで自動retryさせない | Open |

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
