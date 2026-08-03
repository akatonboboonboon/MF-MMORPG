# MFO-WO-P2-2B-016 — Slice 2-B Stage B LF-preserving helper materialization and verification

- Issuer: `00統括（監督）`
- Issued: 2026-08-03 (Asia/Tokyo)
- Assignee: `10ゲームプレイ・コア実装`
- Status: **Authorized / exact ignored-helper byte materialization and remaining implementation verification only**
- Milestone: M2 / Slice 2-B
- Required starting point: the supervisor commit containing this order; its exact hash is supplied in the direct START notice
- Required branch: `codex/phase2-slice2b-stageb-initial-state-correction-gameplay`
- Required workspace: the stopped worktree `C:\tmp\m2b-stageb-fix`
- Predecessor order: [`MFO-WO-P2-2B-015`](phase2-slice2b-stageb-initial-state-verification-continuation.md)
- Validation owner: `30 QA・性能・レビュー` only after a separate supervisor order
- Integration authority: **None**
- Gate effect: **None** — Gate 2 remains Locked

## 1. Accepted stop and objective

`MFO-WO-P2-2B-015` preserved the exact `-014` source correction and performed its one authorized ignored-helper
whole-file replacement. Because the stopped worktree inherits `core.autocrlf=true`, `git apply` materialized the
canonical `46` LF lines as `46` CRLF pairs. The resulting helper is `1692` bytes with SHA-256
`d45767878f5cadd9333f4fc0c3d3e02ee1ac39e93ceb144b53ed6bebbc29d17a`, CR count `46`, and LF count `46`.
Removing only those `46` CR bytes in memory yields the already authorized canonical helper exactly: `1646` bytes,
SHA-256 `eedc6ee73ad5a5c376eb38be55140a9006840aaf1d4cd5c84a9a6712eba2ac73`, CR count `0`, LF count
`46`, no BOM, no tab byte, and no literal `\t` pair.

This is an ignored implementation-helper materialization defect, not a candidate game-code or Approved-data failure.
The targeted behavior remains unevaluated. The sole objective of this continuation is to bypass Git clean/smudge
filters, write the verified LF-only canonical bytes exactly once, and, only if the targeted check Passes, finish the
remaining `-014` implementation verification.

## 2. Exact starting state

Before any write or process launch, confirm all of the following:

1. the existing worktree is on `codex/phase2-slice2b-stageb-initial-state-correction-gameplay`;
2. before synchronizing this order, its HEAD is `5d25792422f9c28ffe6a5513b5986f652c5e98dc` and the only tracked
   change is `material-frontier-online/prototype/scripts/combat/action_runtime.gd`;
3. that tracked diff is exactly one deletion / one insertion, its corrected Git blob is
   `5e764ed21b0210c2db5dd40aefa2451efe242557`, its worktree SHA-256 is
   `a366845ea803efcf0edb96d6e63a27ab022d16adb23277722abf2ae2e3d7aa43`, and `git diff --check` Passes;
4. staged changes and nonignored untracked paths are both `0`;
5. the ignored helper is exactly `1692` bytes, SHA-256
   `d45767878f5cadd9333f4fc0c3d3e02ee1ac39e93ceb144b53ed6bebbc29d17a`, `46` lines, CR `46`, LF
   `46`, every CR is the first byte of CRLF, BOM absent, literal `\t` count `0`, and tab-byte count `0`;
6. the inherited ignored sidecar `build/verification/run_slice2b_stageb_initial_state_check.gd.uid` is exactly `20`
   bytes, SHA-256 `7c1fdc8408e0b3bf39df45c85d1d6e16bf20d3d3f9c46226d2a64c294a5c43d1`, and contains
   `uid://cttqwhr3fgqtx` plus LF;
7. the original `build/verification/logs/p2-2b-014-targeted.log` remains `409` bytes with SHA-256
   `f6a4749c097247999c45f465ee8d8e5fe5a96de468f001f63f12ed2786650ca3`, and the fresh
   `p2-2b-016-targeted.log` is absent;
8. the `-015` whole-file replacement count is consumed at `1`, while targeted retry, Stage B runner, regressions,
   main smoke, report/handoff edits, commit, and push remain `0`.

Fast-forward the existing branch to the supervisor commit supplied in the START notice without resetting, stashing,
rewriting, or discarding the exact tracked source diff or any ignored artifact. Reconfirm items 1 through 8 after the
fast-forward. If any precondition differs, stop and return to `00統括`.

## 3. Authorized byte materialization

The only tracked paths that may differ from the original `-014` starting point remain:

1. `material-frontier-online/prototype/scripts/combat/action_runtime.gd`
2. `material-frontier-online/implementation/2026-08-03-phase2-slice2b-stageb-initial-state-correction.md`
3. `docs/handoffs/gameplay.md`

Do not perform another tracked source correction. The only newly authorized write before verification is **one**
invocation of `[System.IO.File]::WriteAllBytes` against the existing ignored helper. Use Windows PowerShell 5.1 and the
following exact algorithm in one invocation:

```powershell
$ErrorActionPreference = 'Stop'
$helperPath = 'C:\tmp\m2b-stageb-fix\material-frontier-online\prototype\build\verification\run_slice2b_stageb_initial_state_check.gd'
$expectedPreHash = 'd45767878f5cadd9333f4fc0c3d3e02ee1ac39e93ceb144b53ed6bebbc29d17a'
$expectedPostHash = 'eedc6ee73ad5a5c376eb38be55140a9006840aaf1d4cd5c84a9a6712eba2ac73'

function Get-LowerSha256([byte[]]$Bytes) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

[byte[]]$pre = [System.IO.File]::ReadAllBytes($helperPath)
if ($pre.Length -ne 1692 -or (Get-LowerSha256 $pre) -ne $expectedPreHash) { throw 'PREIMAGE_IDENTITY_MISMATCH' }

$bytes = New-Object 'System.Collections.Generic.List[byte]'
$crlfCount = 0
for ($i = 0; $i -lt $pre.Length; $i++) {
    if ($pre[$i] -eq 13) {
        if (($i + 1) -ge $pre.Length -or $pre[$i + 1] -ne 10) { throw 'NON_CRLF_CR_FOUND' }
        $crlfCount++
        continue
    }
    $bytes.Add($pre[$i])
}
[byte[]]$canonical = $bytes.ToArray()
if ($crlfCount -ne 46 -or $canonical.Length -ne 1646 -or (Get-LowerSha256 $canonical) -ne $expectedPostHash) {
    throw 'CANONICAL_PROJECTION_MISMATCH'
}

[System.IO.File]::WriteAllBytes($helperPath, $canonical)

[byte[]]$readback = [System.IO.File]::ReadAllBytes($helperPath)
if ($readback.Length -ne 1646 -or (Get-LowerSha256 $readback) -ne $expectedPostHash) {
    throw 'CANONICAL_READBACK_MISMATCH'
}
```

Before the single `WriteAllBytes` call, both preimage identity and in-memory canonical projection must Pass. After it,
readback must be `1646` bytes / SHA-256 `eedc6ee7...ac73`, `46` lines, CR `0`, LF `46`, BOM absent, literal `\t`
count `0`, and tab-byte count `0`.

`git apply`, `Set-Content`, `Out-File`, `WriteAllText`, `Copy-Item`, text writers, formatter use, Git checkout,
Git configuration changes, a second helper write, alternate materialization, helper redesign, source/data/test edits,
and worktree recreation are prohibited. Preserve the existing ignored UID byte-for-byte; do not delete, regenerate,
or commit it. Preserve the original failure log and use only the fresh `p2-2b-016-targeted.log` for the retry.

## 4. Fixed verification continuation

The predecessor's Godot version and headless import/parse Passes are inherited and must not be rerun. After the exact
helper readback is established, run in this order:

1. the same targeted self-check command exactly once as the single authorized retry, writing the fresh `-016` log, and
   require numeric exit `0` plus terminal `PASS: 8 assertions`;
2. only if it Passes, the frozen Stage B runner exactly once and require `184 / 184`;
3. corrected Stage A runner exactly once and require `71 / 71`;
4. Phase 1 runner exactly once and require `36 / 36`;
5. Slice 2-A runner exactly once and require `120 / 120`;
6. Slice 2-A correction runner exactly once and require `39 / 39`;
7. main-scene headless smoke exactly once with unchanged `DefinitionsValidated` and RHL success;
8. final `git diff --check`, exact three-path scope, exact one-line source diff, protected test/UID/data/evidence
   identity, nonignored-untracked `0`, and clean worktree after commits.

Stop at the first non-pass. There is no second byte materialization, second targeted retry, alternate command, source
repair, expectation change, cleanup of frozen artifacts, or partial success classification under this order.

## 5. Report, commit, return, and stop

On a full Pass only, update the existing correction report with the `-014` helper failure, `-015` CRLF identity stop,
the exact `-016` byte projection/write/readback, inherited and newly executed commands, numeric exits, assertion totals,
and Not run items. Then:

1. create one implementation commit containing only corrected `action_runtime.gd` and the implementation report;
2. create one gameplay-handoff-only commit;
3. push the required branch, prove local/origin equality and a clean worktree, and return to `00統括`;
4. stop.

On any non-pass, do not edit the tracked report or handoff and do not commit or push; return the exact frozen state.

Formal QA, another candidate correction, Stage C, input/authority/actor/target/scene/damage/state/event/presentation
integration, Slice 2-C/-D, PREACK/performance/real A/B/C, and Gate 2 remain unauthorized. A separate supervisor QA
order is required after a successful gameplay handoff.
