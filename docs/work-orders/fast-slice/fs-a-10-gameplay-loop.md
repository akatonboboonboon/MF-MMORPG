# MFO-WO-FS-A-10-001 — FS-A Gameplay Loop

- Status: Issued
- Owner: 10ゲームプレイ・コア実装
- Starting ref: `prototype/fast-vertical-slice` issuance commit
- Branch: `codex/fast-slice-fs-a-gameplay`
- Worktree: `C:\tmp\mf-fs-a-10`
- Contract: `docs/FAST_SLICE_CONTRACT.md`
- Milestone: `FS-A`
- Authorized scope: gameplay-owned `fast_slice/**` loop implementation and its report／handoff only
- Forbidden scope: legacy code／data／scene, presentation, QA, online, persistence, lifecycle, production asset, integration
- Report path: `material-frontier-online/implementation/fast-slice/gameplay/fs-a-gameplay-loop.md`

## Objective

presentationなしでもheadlessに一周できる、FS-Aの権威gameplay child sceneを作る。

## Writable paths

- `material-frontier-online/prototype/scripts/fast_slice/gameplay/**`
- `material-frontier-online/prototype/data/fast_slice/**`
- `material-frontier-online/prototype/scenes/fast_slice/gameplay/**`
- `material-frontier-online/implementation/fast-slice/gameplay/**`
- `docs/handoffs/fast-slice/gameplay.md`
- 対応する`.uid`

他のtracked pathはread-only。特に既存input／simulation／combat／phase1、`project.godot`、tests、presentationを変更しない。

## Deliverables

- 既存move／aim／evadeをread-only依存としてcomposeするadapter
- Knight / Iron 1構成
- light／heavy action
- large enemy 1体、telegraph 2種
- player Integrity／Deformation
- breakable part 1個必須、2個目stretch
- boss HP 0、functional stop、wreck exact 1
- harvest point exact 3、重複回収拒否
- result／rematch／完全reset
- read-only snapshot seam
- `fs_provisional` tuning dataと短い調整履歴

## Constraints

- production damage、strict data、legacy sceneを変更しない。
- online、persistence、inventory、enhancement、lifecycle、magicを追加しない。
- presentation、audio、production artを作らない。
- generic frameworkを増設しない。
- contract fieldを変える必要がある場合、変更対象だけ止めて00へ返す。無関係なgameplay作業は続行してよい。

## Acceptance

- Godot version identity
- fresh import／parse
- additive gameplay-loop self-check
- 一周と二周目resetのdeterministic check
- existing move／evadeが利用可能であること
- `git diff --check`
- base..HEAD changed pathsがowned pathsだけ

## Return

implementation commitと別handoff commitをbranchへpushし、exact SHA、changed paths、commands、results、Not runを返す。integrationへ自動移行しない。
