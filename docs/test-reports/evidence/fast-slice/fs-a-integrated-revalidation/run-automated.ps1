Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$IssuedSha = '29c22763c41abaace46430395dd1bdfd14caaf66'
$CandidateSha = 'f03a43d2339e9772a15db1c591a31f5e4f92cca2'
$ReviewSha = 'ba688730e57564bbb883035972bba9ff2224cd50'
$ExpectedPrototypeTree = '2a66e4c06308a47678e8888a739b87ffd33d1ee8'
$StageRoot = 'C:\tmp\mf-fs-a-reval-auto-20260815-001'
$ArchivePath = 'C:\tmp\mf-fs-a-reval-auto-20260815-001.tar'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8Text {
    param([string]$LiteralPath, [string]$Text)
    [System.IO.File]::WriteAllText($LiteralPath, $Text, $Utf8NoBom)
}

function Write-Utf8Json {
    param([string]$LiteralPath, [object]$Value, [int]$Depth = 8)
    $json = $Value | ConvertTo-Json -Depth $Depth
    Write-Utf8Text -LiteralPath $LiteralPath -Text ($json + "`r`n")
}

function Quote-CommandArgument {
    param([string]$Value)
    if ($Value -notmatch '[\s"]') {
        return $Value
    }
    return '"' + ($Value -replace '"', '\"') + '"'
}

function New-PayloadManifest {
    param([string]$Root, [string]$OutputPath)
    $rootItem = Get-Item -LiteralPath $Root
    $lines = New-Object System.Collections.Generic.List[string]
    $files = @(Get-ChildItem -LiteralPath $Root -Recurse -File -Force | Sort-Object FullName)
    foreach ($file in $files) {
        $relative = $file.FullName.Substring($rootItem.FullName.Length).TrimStart('\') -replace '\\', '/'
        $sha = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        $lines.Add(($relative + "`t" + $file.Length + "`t" + $sha))
    }
    Write-Utf8Text -LiteralPath $OutputPath -Text (($lines -join "`r`n") + "`r`n")
    return [ordered]@{
        file_count = $files.Count
        total_bytes = [long](($files | Measure-Object -Property Length -Sum).Sum)
        manifest_path = $OutputPath
        manifest_bytes = (Get-Item -LiteralPath $OutputPath).Length
        manifest_sha256 = (Get-FileHash -LiteralPath $OutputPath -Algorithm SHA256).Hash.ToLowerInvariant()
    }
}

$EvidenceRoot = $PSScriptRoot
$RepositoryRoot = (Resolve-Path -LiteralPath (Join-Path $EvidenceRoot '..\..\..\..\..')).Path
$GitCommonDirText = (& git -C $RepositoryRoot rev-parse --git-common-dir).Trim()
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to resolve the Git common directory.'
}
if (-not [System.IO.Path]::IsPathRooted($GitCommonDirText)) {
    $GitCommonDirText = Join-Path $RepositoryRoot $GitCommonDirText
}
$GitCommonDir = (Resolve-Path -LiteralPath $GitCommonDirText).Path
$PrimaryRepositoryRoot = (Get-Item -LiteralPath (Split-Path -Parent $GitCommonDir)).FullName
$Godot = Join-Path $PrimaryRepositoryRoot 'material-frontier-online\.tools\godot-4.7-stable\editor\Godot_v4.7-stable_win64_console.exe'
$CommandsRoot = Join-Path $EvidenceRoot 'commands'
$ExitsRoot = Join-Path $EvidenceRoot 'exits'
$LogsRoot = Join-Path $EvidenceRoot 'logs'
$MetadataRoot = Join-Path $EvidenceRoot 'command-metadata'
foreach ($directory in @($CommandsRoot, $ExitsRoot, $LogsRoot, $MetadataRoot)) {
    if (-not (Test-Path -LiteralPath $directory)) {
        [void](New-Item -ItemType Directory -Path $directory)
    }
}

if ((Test-Path -LiteralPath $StageRoot) -or (Test-Path -LiteralPath $ArchivePath)) {
    throw 'Automated fresh stage or archive path already exists; choose a new unique identity.'
}
if (-not (Test-Path -LiteralPath $Godot -PathType Leaf)) {
    throw 'Godot executable is missing.'
}

$head = (& git -C $RepositoryRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $head -ne $IssuedSha) {
    throw "Repository HEAD does not match issued source: $head"
}

& git -C $RepositoryRoot archive --format=tar --output=$ArchivePath $IssuedSha
if ($LASTEXITCODE -ne 0) {
    throw 'git archive failed.'
}
[void](New-Item -ItemType Directory -Path $StageRoot)
$resolvedStage = (Resolve-Path -LiteralPath $StageRoot).Path
if ($resolvedStage -ne $StageRoot) {
    throw "Resolved stage path mismatch: $resolvedStage"
}
& tar.exe -xf $ArchivePath -C $StageRoot
if ($LASTEXITCODE -ne 0) {
    throw 'tar extraction failed.'
}

$FreshProject = Join-Path $StageRoot 'material-frontier-online\prototype'
$GodotCache = Join-Path $FreshProject '.godot'
$GlobalClassCache = Join-Path $GodotCache 'global_script_class_cache.cfg'
if (-not (Test-Path -LiteralPath $FreshProject -PathType Container)) {
    throw 'Fresh project was not extracted.'
}
$PreImportGodotExists = Test-Path -LiteralPath $GodotCache
if ($PreImportGodotExists) {
    throw 'Fresh project unexpectedly contains .godot before import.'
}

$SourcePayloadManifest = Join-Path $EvidenceRoot 'source-payload-manifest.tsv'
$PrototypePayloadManifest = Join-Path $EvidenceRoot 'prototype-payload-manifest.tsv'
$sourcePayload = New-PayloadManifest -Root $StageRoot -OutputPath $SourcePayloadManifest
$prototypePayload = New-PayloadManifest -Root $FreshProject -OutputPath $PrototypePayloadManifest
$archiveItem = Get-Item -LiteralPath $ArchivePath
$godotItem = Get-Item -LiteralPath $Godot

$Invocations = @(
    [ordered]@{ id = 'godot-version'; args = @('--version') },
    [ordered]@{ id = 'fresh-editor-import'; args = @('--headless', '--editor', '--path', $FreshProject, '--quit') },
    [ordered]@{ id = 'integration-root-parse'; args = @('--headless', '--path', $FreshProject, '--check-only', '--script', 'res://scripts/fast_slice/integration/fs_a_integration_root.gd') },
    [ordered]@{ id = 'integration-self-check-parse'; args = @('--headless', '--path', $FreshProject, '--check-only', '--script', 'res://scripts/fast_slice/integration/fs_a_integration_self_check.gd') },
    [ordered]@{ id = 'gameplay-loop-parse'; args = @('--headless', '--path', $FreshProject, '--check-only', '--script', 'res://scripts/fast_slice/gameplay/fs_a_gameplay_loop.gd') },
    [ordered]@{ id = 'gameplay-arena-script-parse'; args = @('--headless', '--path', $FreshProject, '--check-only', '--script', 'res://scripts/fast_slice/gameplay/fs_a_gameplay_arena.gd') },
    [ordered]@{ id = 'gameplay-self-check-parse'; args = @('--headless', '--path', $FreshProject, '--check-only', '--script', 'res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd') },
    [ordered]@{ id = 'presentation-shell-parse'; args = @('--headless', '--path', $FreshProject, '--check-only', '--script', 'res://scripts/fast_slice/presentation/fs_a_presentation_shell.gd') },
    [ordered]@{ id = 'presentation-preview-parse'; args = @('--headless', '--path', $FreshProject, '--check-only', '--script', 'res://scripts/fast_slice/presentation/fs_a_presentation_preview.gd') },
    [ordered]@{ id = 'presentation-preview-stub-parse'; args = @('--headless', '--path', $FreshProject, '--check-only', '--script', 'res://scripts/fast_slice/presentation/fs_a_preview_stub.gd') },
    [ordered]@{ id = 'integration-self-check'; args = @('--headless', '--path', $FreshProject, '--script', 'res://scripts/fast_slice/integration/fs_a_integration_self_check.gd') },
    [ordered]@{ id = 'fs-a-main-launch'; args = @('--headless', '--path', $FreshProject, '--scene', 'res://scenes/fast_slice/fs_a_main.tscn', '--quit-after', '120') },
    [ordered]@{ id = 'gameplay-self-check'; args = @('--headless', '--path', $FreshProject, '--script', 'res://scripts/fast_slice/gameplay/fs_a_gameplay_self_check.gd') },
    [ordered]@{ id = 'gameplay-arena-scene'; args = @('--headless', '--path', $FreshProject, '--scene', 'res://scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn', '--quit-after', '120') },
    [ordered]@{ id = 'presentation-self-check'; args = @('--headless', '--path', $FreshProject, '--scene', 'res://scenes/fast_slice/presentation/fs_a_presentation_preview.tscn', '--', '--fs-a-self-check') },
    [ordered]@{ id = 'presentation-pure-shell'; args = @('--headless', '--path', $FreshProject, '--scene', 'res://scenes/fast_slice/presentation/fs_a_presentation_shell.tscn', '--quit-after', '5') },
    [ordered]@{ id = 'presentation-preview-smoke'; args = @('--headless', '--path', $FreshProject, '--scene', 'res://scenes/fast_slice/presentation/fs_a_presentation_preview.tscn', '--quit-after', '5') },
    [ordered]@{ id = 'qa-contract-skeleton'; args = @('--headless', '--path', $FreshProject, '--script', 'res://tests/fast_slice/run_fs_a_contract_skeleton.gd') },
    [ordered]@{ id = 'project-main-smoke'; args = @('--headless', '--path', $FreshProject, '--quit-after', '120') },
    [ordered]@{ id = 'phase1-regression'; args = @('--headless', '--path', $FreshProject, '--script', 'res://tests/run_phase1_tests.gd') },
    [ordered]@{ id = 'slice2a-120'; args = @('--headless', '--path', $FreshProject, '--script', 'res://tests/run_slice2a_tests.gd') },
    [ordered]@{ id = 'slice2a-correction-39'; args = @('--headless', '--path', $FreshProject, '--script', 'res://tests/run_slice2a_correction_tests.gd') }
)

$Results = New-Object System.Collections.Generic.List[object]
for ($index = 0; $index -lt $Invocations.Count; $index++) {
    $ordinal = $index + 1
    $item = $Invocations[$index]
    $stem = ('{0:D2}-{1}' -f $ordinal, $item.id)
    $commandPath = Join-Path $CommandsRoot ($stem + '.command.txt')
    $exitPath = Join-Path $ExitsRoot ($stem + '.exit-code.txt')
    $stdoutPath = Join-Path $LogsRoot ($stem + '.stdout.log')
    $stderrPath = Join-Path $LogsRoot ($stem + '.stderr.log')
    $metadataPath = Join-Path $MetadataRoot ($stem + '.json')
    $arguments = [string[]]$item.args
    $rendered = ((Quote-CommandArgument -Value $Godot) + ' ' + (($arguments | ForEach-Object { Quote-CommandArgument -Value $_ }) -join ' '))
    Write-Utf8Text -LiteralPath $commandPath -Text ($rendered + "`r`n")
    $startedUtc = [DateTime]::UtcNow.ToString('o')
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $process = Start-Process -FilePath $Godot -ArgumentList $arguments -NoNewWindow -Wait -PassThru -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath
    $stopwatch.Stop()
    $endedUtc = [DateTime]::UtcNow.ToString('o')
    $exitCode = [int]$process.ExitCode
    if (-not (Test-Path -LiteralPath $stdoutPath)) { [System.IO.File]::WriteAllBytes($stdoutPath, [byte[]]@()) }
    if (-not (Test-Path -LiteralPath $stderrPath)) { [System.IO.File]::WriteAllBytes($stderrPath, [byte[]]@()) }
    Write-Utf8Text -LiteralPath $exitPath -Text (($exitCode.ToString()) + "`r`n")
    $metadata = [ordered]@{
        ordinal = $ordinal
        id = $item.id
        executable = $Godot
        arguments = $arguments
        rendered_command = $rendered
        project_path = if ($ordinal -eq 1) { $null } else { $FreshProject }
        started_utc = $startedUtc
        ended_utc = $endedUtc
        duration_ms = [long]$stopwatch.ElapsedMilliseconds
        exit_code = $exitCode
        stdout_path = $stdoutPath
        stderr_path = $stderrPath
    }
    Write-Utf8Json -LiteralPath $metadataPath -Value $metadata -Depth 6
    $Results.Add($metadata)
}

$Context = [ordered]@{
    schema = 'mfo.fs_a.integrated_revalidation.automated_run.v1'
    generated_utc = [DateTime]::UtcNow.ToString('o')
    issued_sha = $IssuedSha
    candidate_sha = $CandidateSha
    review_sha = $ReviewSha
    expected_prototype_tree = $ExpectedPrototypeTree
    repository_root = $RepositoryRoot
    evidence_root = $EvidenceRoot
    stage_root = $StageRoot
    archive_path = $ArchivePath
    archive_bytes = $archiveItem.Length
    archive_sha256 = (Get-FileHash -LiteralPath $ArchivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    pre_import_godot_exists = $PreImportGodotExists
    post_run_godot_exists = (Test-Path -LiteralPath $GodotCache)
    post_run_global_class_cache_exists = (Test-Path -LiteralPath $GlobalClassCache -PathType Leaf)
    godot_executable = $Godot
    godot_executable_bytes = $godotItem.Length
    godot_executable_sha256 = (Get-FileHash -LiteralPath $Godot -Algorithm SHA256).Hash.ToLowerInvariant()
    source_payload = $sourcePayload
    prototype_payload = $prototypePayload
    invocation_count = $Invocations.Count
    exits = @($Results | ForEach-Object { $_.exit_code })
    all_exit_zero = (@($Results | Where-Object { $_.exit_code -ne 0 }).Count -eq 0)
    cleanup_performed = $false
}
Write-Utf8Json -LiteralPath (Join-Path $EvidenceRoot 'automated-run-context.json') -Value $Context -Depth 10

if (-not $Context.all_exit_zero) {
    exit 1
}
exit 0
