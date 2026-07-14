# Simulation authority instructions

このディレクトリでは、ルート`AGENTS.md`に加えて次を守る。

- gameplay runtime stateの唯一の権威として動作し、UI、VFX、audioの実体を持たない。
- InputCommandを要求として検証し、発動、命中、damage、state transitionを決定する。
- stable entity/content IDとcommand tickを保持し、結果をDomainEvent／read-only stateで公開する。
- core EquipmentRuntimeStateだけがplayerの`Integrity`、`Deformation`、`temperature`を可変保持する。
- Actor側へ同じ損傷値や独立編集可能なMaterialJob／CombatFormを複製しない。
- HeatとBurnCurseを別channel／resistance／aggregationとして処理する。
- `EquipmentFatigueChanged`、`EquipmentDestroyed`をMVPで発行しない。
- 表現都合でsimulation resultを変更する要求は受け入れず、契約質問として監督へ戻す。
