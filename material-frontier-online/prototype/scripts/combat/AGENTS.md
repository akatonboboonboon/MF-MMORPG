# Combat implementation instructions

このディレクトリでは、ルート `AGENTS.md` に加えて次を守る。

- `ActionDefinition` と `EffectDefinition` の共通処理を使い、快斬、重断、素材、魔法ごとの専用ダメージコードを作らない。
- `PrototypeStressTarget` の50判定を固定ハード上限や「51個目を不発にする」分岐へ変換しない。
- 受理済みのプレイヤー重要判定は、予約容量不足を理由に不発にしない。
- 判定は取得後に必ず返却し、リトライ後に残留させない。
- 視覚弾、火花、破片、VFXはゲームプレイ判定プールを使用しない。
- 新しいアクション、効果、予約区分、判定形状が必要になった場合、既存決定で一意に定まらなければ実装前に `docs/OPEN_QUESTIONS.md` へ戻す。
- イベント境界を変更するときは、先に `docs/ASSET_CONTRACTS.md` の変更案を監督へ提出する。

最低検証: Phase 1 headless tests、定義検証、判定取得・返却、命中／非命中、未知ID拒否。
