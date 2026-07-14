# Material Frontier Online — Approved Decisions

- Updated: 2026-07-14
- Owner: `00統括（監督）`
- Rule: この文書には決定済み事項だけを記録する。未決事項は [`OPEN_QUESTIONS.md`](OPEN_QUESTIONS.md) へ置く。

`authority` は、提案を後から承認した `user_approved` と、ユーザーが直接指定した `user_explicit` を区別する。
`user_explicit` 項目の日付は、凍結仕様へ反映されたeffective baseline日を示す。

## Gate decisions

| ID | Decision | Status | Authority | Date | Impact | Source |
|---|---|---|---|---|---|---|
| GATE-0 | P0 13件を承認し、統合仕様書のPhase 1に限定して実装開始を許可する | Approved / Open | `user_approved` | 2026-07-13 | Phase 1のみ。MMO、課金、巨大基盤等は非承認 | [Gate 0 record](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md) |

## Approved OD decisions

| ID | Decision | Status | Authority | Date | Primary impact | Detail source |
|---|---|---|---|---|---|---|
| OD-001 | 斜め俯瞰2D、固定方角、8方向移動、独立全方向照準。回避は地上ステップ、本格Z軸・ジャンプなし | Approved | `user_approved` | 2026-07-13 | 入力、カメラ、ステージ、部位配置 | [Gate 0 §3](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#od-001--view-and-movement) |
| OD-002 | Windows x86_64 native portable。ZIP展開型、単体EXE | Approved | `user_approved` | 2026-07-13 | 配布、export、対象OS | [Gate 0 §3](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#od-002--od-003--platform-and-engine) |
| OD-003 | Godot Engine 4.7 stable通常版＋GDScript。.NET、開発版、RC版は使用しない | Approved | `user_approved` | 2026-07-13 | エンジン、言語、データ、build | [Gate 0 §3](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#od-002--od-003--platform-and-engine) |
| OD-004 | 開発PCを基準端末とし、1920×1080標準画質、性能優先、release相当、60fps／P95 16.67ms以下 | Approved | `user_approved` | 2026-07-13 | 性能測定、Gate 1/7 | [Gate 0 §3](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#od-004--reference-device) |
| OD-005 | プレイヤーを5層へ分離し、最小試作ではcore装備が損傷状態と素材・形状選択の権威元 | Approved | `user_explicit` | 2026-07-13 | データモデル、状態所有権 | [Open decisions §2](../material-frontier-online/specification/02-open-decisions.md#2-今回の改訂で解決済みとなった事項) |
| OD-006 | 1人だけ実装し、空間・データ境界のみ将来4人対応可能にする | Approved | `user_approved` | 2026-07-13 | Actor集合、target ID、HUD、アリーナ | [Gate 0 §3](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#od-006--four-player-ready-boundary) |
| OD-007 | 試作3素材はナイト系鉄鋼、アルミ、銅 | Approved | `user_approved` | 2026-07-13 | 素材定義、性能比較 | [Gate 0 §3](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#od-007--material-roles) |
| OD-008 | 物理攻撃は快斬と重断 | Approved | `user_approved` | 2026-07-13 | 入力、ActionDefinition、戦闘 | [Gate 0 §3](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#od-008--physical-actions) |
| OD-009 | 魔法は放電、抵抗加熱、磁気パルス | Approved | `user_approved` | 2026-07-13 | 共通効果、素材差、環境作用 | [Gate 0 §3](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#od-009--magic-actions) |
| OD-010 | 大型敵は炭酸圧獣《バーストボア》 | Approved | `user_approved` | 2026-07-13 | ボス、部位、攻撃、報酬 | [Gate 0 §3](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#od-010--boss) |
| OD-011 | ステージは飲料充填工場・炭酸ライン | Approved | `user_approved` | 2026-07-13 | ステージ、アート、経路 | [Gate 0 §3](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#od-011--od-012--stage-and-gimmicks) |
| OD-012 | ギミックは可逆コンベアとCIP洗浄水。圧力弁はボス頭部安全弁へ統合 | Approved | `user_approved` | 2026-07-13 | ステージ、電気、Heat | [Gate 0 §3](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#od-011--od-012--stage-and-gimmicks) |
| OD-013 | ゲームパッドを主入力とし、同じ抽象入力へKBMを対応 | Approved | `user_approved` | 2026-07-13 | InputMap、UI、操作試験 | [Gate 0 §3](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#od-013--abstract-input) |
| OD-014 | `Integrity`＋0～100の`Deformation`を必須とし、変形ペナルティは調整可能な1種類だけ | Approved | `user_explicit` | 2026-07-13 | 損傷、敗北、HUD | [Open decisions §2](../material-frontier-online/specification/02-open-decisions.md#2-今回の改訂で解決済みとなった事項) |
| OD-016 | 3素材共通の片手刃型`CombatForm`を1形態だけ実装 | Approved | `user_approved` | 2026-07-13 | CombatForm、アクション、素材比較 | [Gate 0 §3](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#od-016--combatform) |
| OD-031 | アルミ母材は導体。酸化皮膜由来の魔法耐性は独立静的パラメータ。動的皮膜処理はMVP外 | Approved | `user_approved` | 2026-07-13 | 素材定義、電気耐性 | [Gate 0 §4](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#4-additional-approved-decisions) |
| OD-032 | `Heat`と`BurnCurse`を完全に別チャンネルとし、耐性を自動共有しない | Approved | `user_explicit` | 2026-07-13 | 効果、状態、耐性 | [Open decisions §2](../material-frontier-online/specification/02-open-decisions.md#2-今回の改訂で解決済みとなった事項) |
| OD-034 | 戦闘・会話は世界内名、図鑑・詳細は実在材料名、内部IDは言語非依存 | Approved | `user_approved` | 2026-07-13 | UI、ローカライズ、ID | [Gate 0 §4](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#4-additional-approved-decisions) |
| OD-035 | 剥ぎ取り物は用途器官と内容物サンプル | Approved | `user_approved` | 2026-07-13 | 報酬、世界観、UI | [Gate 0 §4](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#4-additional-approved-decisions) |
| OD-036 | 疲労破壊で失うのは対象`EquipmentInstance`と個体加工・スキルツリー。`AvatarIdentity`は失わない | Approved | `user_explicit` | 2026-07-13 | 将来損失、永続データ | [Open decisions §2](../material-frontier-online/specification/02-open-decisions.md#2-今回の改訂で解決済みとなった事項) |
| OD-037 | `MFO`を正式略称とする | Approved | `user_approved` | 2026-07-13 | 文書、UI、名称 | [Gate 0 §4](../material-frontier-online/decisions/2026-07-13-gate-0-p0-approval.md#4-additional-approved-decisions) |

## Change procedure

1. 未決事項は `OPEN_QUESTIONS.md` に登録する。
2. 監督が根拠、影響、選択肢、再検討条件を整理する。
3. ユーザーの明示承認後にのみ、この文書へ追記する。
4. 同じ変更で `MASTER_SPEC.md`、必要な契約、状態、handoffを同期する。
5. 凍結仕様を無言で書き換えず、オーバーレイ決定として追跡する。
