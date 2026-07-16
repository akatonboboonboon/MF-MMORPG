param(
    [Parameter(Mandatory = $true)]
    [string] $Stage,

    [Parameter(Mandatory = $true)]
    [string] $StageId,

    [Parameter(Mandatory = $true)]
    [string] $SupervisorCommit,

    [Parameter(Mandatory = $true)]
    [string] $RequiredBranch,

    [Parameter(Mandatory = $true)]
    [string] $RequiredHead
)

$ErrorActionPreference = 'Stop'

function Get-DirectoryPrefix {
    param([string] $Path)
    return [IO.Path]::GetFullPath($Path).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
}

function Assert-FreshExternalStagePath {
    param([string] $Path, [string] $ExpectedStageId)
    $full = [IO.Path]::GetFullPath($Path)
    if (-not (Test-Path -LiteralPath $full -PathType Container)) { throw 'Stage does not exist' }
    if ([IO.Path]::GetFileName($full) -cne $ExpectedStageId) { throw 'Stage ID/path disagreement' }
    if (-not $ExpectedStageId.StartsWith('p2-2a-009-qp-', [StringComparison]::Ordinal)) { throw 'Fresh -009 stage ID prefix is required' }

    $fullPrefix = Get-DirectoryPrefix $full
    $allowedRoot = $null
    foreach ($candidate in @([IO.Path]::GetTempPath(), [Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData))) {
        $candidatePrefix = Get-DirectoryPrefix $candidate
        if ($fullPrefix.StartsWith($candidatePrefix, [StringComparison]::OrdinalIgnoreCase)) {
            $allowedRoot = $candidatePrefix
            break
        }
    }
    if ($null -eq $allowedRoot) { throw 'Qualification stage is outside LocalAppData/TEMP' }

    $knownOneDriveRootCount = 0
    foreach ($oneDriveRoot in @($env:OneDrive, $env:OneDriveConsumer, $env:OneDriveCommercial)) {
        if ([String]::IsNullOrWhiteSpace($oneDriveRoot)) { continue }
        $knownOneDriveRootCount++
        if ($fullPrefix.StartsWith((Get-DirectoryPrefix $oneDriveRoot), [StringComparison]::OrdinalIgnoreCase)) {
            throw 'Qualification stage is inside a known OneDrive root'
        }
    }
    if ($fullPrefix.IndexOf('OneDrive', [StringComparison]::OrdinalIgnoreCase) -ge 0) { throw 'Qualification stage is inside OneDrive' }

    $root = [IO.Path]::GetPathRoot($full)
    $cursor = $root
    $parts = $full.Substring($root.Length).Split(
        [char[]] @([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar),
        [StringSplitOptions]::RemoveEmptyEntries)
    foreach ($part in $parts) {
        $cursor = Join-Path $cursor $part
        $item = Get-Item -LiteralPath $cursor -Force
        if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Qualification stage path traverses a reparse point: $cursor"
        }
    }

    return [pscustomobject] @{
        allowed_root = $allowedRoot.TrimEnd([IO.Path]::DirectorySeparatorChar)
        known_onedrive_environment_root_count = $knownOneDriveRootCount
        reparse_component_count = 0
    }
}

$issuedSupervisor = '6c0d5e04c1c70692c57f18f98416b7ebff324706'
$issuedClarification = '45374c3545204279ae733df0e7c3d9871954fb08'
$issuedBranch = 'codex/phase2-slice2a-harness-live-evidence-requalification-qa'
$issuedReceipt = 'f4986e7fdd7bfbbb5983e98c1dfb2129ebab08a4'
if ($SupervisorCommit -cne $issuedSupervisor) { throw 'Supervisor commit does not match MFO-WO-P2-2A-009' }
if ($RequiredBranch -cne $issuedBranch) { throw 'Required branch does not match MFO-WO-P2-2A-009' }
if ($RequiredHead -cne $issuedReceipt) { throw 'QA receipt HEAD does not match the accepted -009 handoff receipt' }
$stagePath = [IO.Path]::GetFullPath($Stage)
$stagePathAudit = Assert-FreshExternalStagePath $stagePath $StageId
$externalRunRoot = [IO.Path]::GetFullPath((Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)) ('Temp\MFO-P2-2A-009-Runs\' + $StageId)))
if ((Test-Path -LiteralPath (Join-Path $stagePath 'runs')) -or (Test-Path -LiteralPath $externalRunRoot)) { throw 'Runtime evidence exists before PREPARED' }
$branch = [string] (git branch --show-current)
if ($LASTEXITCODE -ne 0) { throw 'git branch failed' }
$head = [string] (git rev-parse HEAD)
if ($LASTEXITCODE -ne 0) { throw 'git HEAD failed' }
$originRef = 'origin/' + $RequiredBranch
$originHead = [string] (git rev-parse $originRef)
if ($LASTEXITCODE -ne 0) { throw 'git origin branch failed' }
$parentHead = [string] (git rev-parse ($head + '^'))
if ($LASTEXITCODE -ne 0) { throw 'git receipt parent lookup failed' }
$receiptPaths = @(git -c core.longpaths=true -c core.quotePath=false diff-tree --no-commit-id --name-only -r $head)
if ($LASTEXITCODE -ne 0) { throw 'git receipt path audit failed' }
$statusLines = @(git -c core.longpaths=true status --porcelain=v1 --untracked-files=all)
if ($LASTEXITCODE -ne 0) { throw 'git status failed' }
git merge-base --is-ancestor $SupervisorCommit $head
$supervisorIsAncestor = $LASTEXITCODE -eq 0

if ($branch -cne $RequiredBranch) { throw "QA branch mismatch: $branch" }
if ($head -cne $RequiredHead) { throw "QA HEAD mismatch: $head" }
if ($originHead -cne $RequiredHead) { throw "Origin QA HEAD mismatch: $originHead" }
if ($parentHead -cne $issuedClarification) { throw "QA clarification receipt parent mismatch: $parentHead" }
if ($receiptPaths.Count -ne 1 -or $receiptPaths[0] -cne 'docs/handoffs/qa.md') { throw 'QA receipt changed-path audit failed' }
if ($statusLines.Count -ne 0) { throw 'Tracked/untracked repository state is not clean' }
if (-not $supervisorIsAncestor) { throw 'Supervisor starting commit is not an ancestor of QA HEAD' }

$record = [ordered] @{
    schema = 'mfo.qa.qualification.repository-state.v1'
    work_order = 'MFO-WO-P2-2A-009'
    stage_id = $StageId
    stage_path = $stagePath
    stage_path_allowed_root = $stagePathAudit.allowed_root
    stage_path_known_onedrive_environment_root_count = $stagePathAudit.known_onedrive_environment_root_count
    stage_path_reparse_component_count = $stagePathAudit.reparse_component_count
    supervisor_starting_commit = $SupervisorCommit
    required_qa_branch = $RequiredBranch
    observed_qa_branch = $branch
    qa_receipt_head = $head
    qa_receipt_commit = $RequiredHead
    qa_receipt_parent = $parentHead
    qa_receipt_changed_paths = $receiptPaths
    qa_receipt_changed_path_count = $receiptPaths.Count
    origin_qa_ref = $originRef
    origin_qa_head = $originHead
    supervisor_is_ancestor = $supervisorIsAncestor
    status_porcelain_count = $statusLines.Count
    status_porcelain_lines = $statusLines
    clean = $true
    stage_runs_absent = $true
    external_run_evidence_root = $externalRunRoot
    external_run_evidence_root_absent = $true
    performance_slot_launch_count = 0
    launch_count_evidence_scope = 'pre-PREPARED repository-state boundary; preparation result and post-seal audits provide executable launch-count proof'
    p95_produced = $false
    kbm_performed = $false
    abc_launched = $false
    abc_launch_count = 0
    commands = [ordered] @{
        branch = 'git branch --show-current'
        head = 'git rev-parse HEAD'
        origin = 'git rev-parse ' + $originRef
        receipt_parent = 'git rev-parse ' + $head + '^'
        receipt_paths = 'git -c core.longpaths=true -c core.quotePath=false diff-tree --no-commit-id --name-only -r ' + $head
        status = 'git -c core.longpaths=true status --porcelain=v1 --untracked-files=all'
        ancestry = 'git merge-base --is-ancestor ' + $SupervisorCommit + ' ' + $head
    }
    command_exit_codes = [ordered] @{
        branch = 0
        head = 0
        origin = 0
        receipt_parent = 0
        receipt_paths = 0
        status = 0
        ancestry = 0
    }
    recorded_utc = [DateTime]::UtcNow.ToString('o')
}

$path = Join-Path $stagePath 'preparation\repository-state-evidence.json'
if (Test-Path -LiteralPath $path) { throw "Repository-state evidence already exists: $path" }
$json = $record | ConvertTo-Json -Depth 8 -Compress
$bytes = (New-Object Text.UTF8Encoding($false)).GetBytes($json + "`r`n")
$stream = New-Object IO.FileStream($path, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::Read, 4096, [IO.FileOptions]::WriteThrough)
try {
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Flush($true)
}
finally {
    $stream.Dispose()
}
$readback = [IO.File]::ReadAllBytes($path)
if ($bytes.Length -ne $readback.Length) { throw 'Repository-state evidence readback length mismatch' }
for ($index = 0; $index -lt $bytes.Length; $index++) {
    if ($bytes[$index] -ne $readback[$index]) { throw 'Repository-state evidence readback byte mismatch' }
}
Write-Output ("REPOSITORY_STATE_PATH=$path")
Write-Output ("REPOSITORY_STATE_SHA256=$((Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant())")
Write-Output ("QA_BRANCH=$branch")
Write-Output ("QA_HEAD=$head")
Write-Output ("ORIGIN_HEAD=$originHead")
Write-Output 'CLEAN=True'
