# Input instructions

このディレクトリでは、ルート`AGENTS.md`に加えて次を守る。

- device inputをapproved abstract actionへ変換するまでを責務とする。
- InputCommandは要求であり、action acceptance、cost、cooldown、hitを入力層で決定しない。
- gamepad主入力とKBM同等境界を維持し、同じactionをdevice別game ruleへ分岐しない。
- input mapping追加やchord解釈がapproved decisionから一意に定まらない場合、実装せず監督へ戻す。
- automated mapping testと実gamepad手動確認を区別する。
