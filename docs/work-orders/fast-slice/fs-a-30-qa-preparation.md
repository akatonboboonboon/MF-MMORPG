# MFO-WO-FS-A-30-001 — FS-A QA Preparation

- Status: Issued
- Owner: 30 QA・性能・レビュー
- Starting ref: `prototype/fast-vertical-slice` issuance commit
- Branch: `codex/fast-slice-fs-a-qa-prep`
- Worktree: `C:\tmp\mf-fs-a-30`
- Contract: `docs/FAST_SLICE_CONTRACT.md`
- Milestone: `FS-A`
- Authorized scope: QA-owned matrix, small additive runner skeleton, checklist, report／evidence templates
- Forbidden scope: candidate implementation／values, legacy tests／evidence rewrite, maximum-load or large harness, Gate action
- Report path: `docs/test-reports/fast-slice/fs-a-qa-preparation.md`

## Objective

gameplay／presentationと並行して、小さく保守可能なFS-A validation packageを準備する。candidate codeや値は変更しない。

## Writable paths

- `material-frontier-online/prototype/tests/fast_slice/**`
- `docs/test-reports/fast-slice/**`
- `docs/test-reports/evidence/fast-slice/**`
- `docs/handoffs/fast-slice/qa.md`
- 対応する`.uid`

## Deliverables

- contract requirement-to-test matrix
- public snapshot／loop seam向けadditive headless runner skeleton
- one-loop／rematch reset test cases
- manual KBM play checklist
- branch scope audit
- technical resultとuser-feel resultの短いtemplate

## Constraints

- gameplay／presentation implementationを変更しない。
- exact assertion総数をacceptance条件にしない。
- 最大負荷、P95、long-run、large evidence harnessを追加しない。
- integrated candidateがない項目はNot runとして保持する。
- QA-owned runner／launcher defectはQA branch内でbounded repairできるが、candidateの結果に見せかけない。

## Acceptance

- test source import／parse、またはcandidate非依存fixture
- requirement mappingの抜け確認
- owned-path scope audit
- `git diff --check`

## Return

QA-prep commitとhandoff commitをbranchへpushし、実行済み／Not runを分離して返す。candidate validationやGate判定へ自動移行しない。
