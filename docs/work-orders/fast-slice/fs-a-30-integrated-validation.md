# MFO-WO-FS-A-30-002 — FS-A Integrated Validation

- Status: Draft / not issued
- Planned branch: `codex/fast-slice-fs-a-validation`
- Planned worktree: `C:\tmp\mf-fs-a-val`
- Owner: 30 QA・性能・レビュー
- Milestone: `FS-A`
- Authorized scope: frozen integration candidateのfocused technical／KBM validationとowned report／evidence only
- Forbidden scope: candidate repair, gameplay／presentation値変更, maximum-load／P95／large harness, strict Gate action
- Report path: `docs/test-reports/fast-slice/fs-a-integrated-validation.md`

## Issue condition

00がintegration candidate SHAをfreezeした後だけ発行する。

## Planned scope

- Godot import／parse
- additive automated one-loop validation
- dedicated scene headless smoke
- KBMで一周とrematch二周目
- move／aim／evade regression
- presentation無効時の結果不変
- excluded systems不在のscope audit
- 必要な場合だけ通常release export／smoke

最大負荷、P95、real A/B/C matrix、long-run harnessは実行しない。

## Acceptance

- frozen integration SHAとtest source identityを記録する。
- import／parse、automated one-loop、dedicated scene smokeをPassする。
- KBMで一周、result、rematch、二周目resetを確認する。
- presentation無効時のgameplay結果不変とexcluded systems不在を確認する。

## Recommendation

- `Pass`: integration candidateを`prototype/fast-vertical-slice`へpromotion可能
- `Fail`: candidate integrationだけ停止
- `Blocked`: QA infrastructureだけ停止し、無関係なrole branchは継続
