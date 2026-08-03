# MFO-WO-FS-A-20-001 — FS-A Presentation Shell

- Status: Issued
- Owner: 20ステージ・UI・グラフィック
- Starting ref: `prototype/fast-vertical-slice` issuance commit
- Branch: `codex/fast-slice-fs-a-presentation`
- Worktree: `C:\tmp\mf-fs-a-20`
- Contract: `docs/FAST_SLICE_CONTRACT.md`
- Milestone: `FS-A`
- Authorized scope: presentation-owned `fast_slice/**` placeholder shell and its report／handoff only
- Forbidden scope: gameplay authority, legacy scene／presentation, production asset batch, contract change, integration
- Report path: `material-frontier-online/implementation/fast-slice/presentation/fs-a-presentation-shell.md`

## Objective

gameplay stateを変更しない、primitive／placeholder中心のFS-A presentation child sceneを作る。gameplay branchとの接続前にpresentation-owned stub snapshotで独立previewできること。

## Writable paths

- `material-frontier-online/prototype/scripts/fast_slice/presentation/**`
- `material-frontier-online/prototype/scenes/fast_slice/presentation/**`
- `material-frontier-online/prototype/assets/fast_slice/**`
- `material-frontier-online/implementation/fast-slice/presentation/**`
- `docs/handoffs/fast-slice/presentation.md`
- 対応する`.uid`

他のtracked pathはread-only。gameplay state、existing presentation、shared scene、`project.godot`を変更しない。

## Deliverables

- Knight / Iron proxy
- large enemy proxyとbreakable part表示
- 色以外でも区別できるline／sector telegraph
- Integrity／Deformation／boss HP HUD
- broken、functional stop、wreckの表示
- harvest marker exact 3
- result／rematch overlay
- contract snapshotに一致するpresentation-owned preview stub

## Constraints

- hit、damage、HP、Deformation、defeat、harvest、resultを決定しない。
- production art、music、voice、large VFX batchを作らない。
- A/B/C複数variant競争を行わず、最初のusable placeholderを優先する。
- stubはpresentation preview専用であり、integration時に権威sourceへ置換する。

## Acceptance

- Godot import／parse
- presentation preview scene smoke
- normal／grayscaleでtelegraph 2種とHUDを識別できるstatic check
- gameplay-owned path diff 0
- `git diff --check`
- base..HEAD changed pathsがowned pathsだけ

## Return

implementation commitと別handoff commitをbranchへpushし、exact SHA、changed paths、captures、Not runを返す。integrationへ自動移行しない。
