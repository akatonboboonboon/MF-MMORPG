# MFO-WO-FS-A-00-001 — FS-A Integration

- Status: Draft / not issued
- Initial branch: `codex/fast-slice-fs-a-integration`
- Initial worktree: `C:\tmp\mf-fs-a-int`
- Owner: 00統括 for merge／promotion; 10ゲームプレイ for integration code only after issue
- Milestone: `FS-A`
- Authorized scope: reviewed role tips plus exact integration-only paths after issuance
- Forbidden scope: role-owned implementation rewrites, `project.godot`, strict-line changes, pre-issue execution
- Report path: `material-frontier-online/implementation/fast-slice/integration/fs-a-integration.md`
- Integration code owner when issued: 10ゲームプレイ・コア実装

## Issue condition

00が10と20のscope、changed paths、handoffをreviewし、採用tipを固定した後だけ発行する。

## Planned scope

- reviewed gameplay／presentation commitをintegration branchへ取り込む。
- 10をsingle ownerとして`scenes/fast_slice/fs_a_main.tscn`と`fast_slice/integration/**`だけでchild scenesを接続する。
- gameplay／presentation owner filesはintegration中に再編集しない。
- `project.godot`は変更せず、専用scene pathを明示起動する。
- integrated one-loop smokeまで行い、validation candidate SHAをfreezeする。

## Acceptance

- 10／20 reviewed tipsとQA-prep tipがexact SHAで記録される。
- integration変更はintegration-only owned pathsに限定される。
- dedicated FS-A sceneがimport／parse／one-loop smokeをPassする。
- validation candidate SHAがfreezeされ、QA Failはそのpromotionだけを止める。
