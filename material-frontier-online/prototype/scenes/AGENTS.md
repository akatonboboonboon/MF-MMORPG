# Scene and stage instructions

このディレクトリでは、ルート`AGENTS.md`に加えて次を守る。

- collisionはapproved GameplayGeometryまたはInteractiveGimmickだけが持つ。
- background、foreground、decoration、decal、visual equipmentへcollision／physicsを付けない。
- 例外collisionはgameplay意味、owner、test、decision sourceを契約化してから追加する。
- 試作の一画面gimmickは最大2、大型可動背景は最大2。
- foregroundでplayerを完全に隠さず、主経路を二値silhouetteでも認識可能にする。
- warning、part、gimmick、player outlineを最低画質で維持する。
- shared `.tscn` は作業前にhandoffへ予定fileと単一ownerを記録する。
