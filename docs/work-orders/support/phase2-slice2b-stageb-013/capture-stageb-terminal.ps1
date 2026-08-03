param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('QUALIFY_STREAMS', 'QUALIFY_EMPTY', 'QUALIFY_GODOT_VERSION', 'PARSER', 'FORMAL')]
    [string]$Mode
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

$project = 'C:\tmp\q2b-stageb\material-frontier-online\prototype'
$runner = Join-Path $project 'tests\run_slice2b_stageb_action_kernel_tests.gd'
$runnerUid = Join-Path $project 'tests\run_slice2b_stageb_action_kernel_tests.gd.uid'
$consolePathBytes = [Convert]::FromBase64String('QzpcVXNlcnNcb3NhdG9cT25lRHJpdmVc44OJ44Kt44Ol44Oh44Oz44OIXE1GXG1hdGVyaWFsLWZyb250aWVyLW9ubGluZVwudG9vbHNcZ29kb3QtNC43LXN0YWJsZVxlZGl0b3JcR29kb3RfdjQuNy1zdGFibGVfd2luNjRfY29uc29sZS5leGU=')
$console = [Text.Encoding]::UTF8.GetString($consolePathBytes)
$powerShell = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
$streamCanarySource = '$o=[Text.Encoding]::ASCII.GetBytes(''MFO_CAPTURE_STDOUT_V1'');[Console]::OpenStandardOutput().Write($o,0,$o.Length);$e=[Text.Encoding]::ASCII.GetBytes(''MFO_CAPTURE_STDERR_V1'');[Console]::OpenStandardError().Write($e,0,$e.Length);exit 23'
$emptyCanarySource = 'exit 29'
$expectedRunnerCanonicalSha256 = 'f48266b43a3f3b572d2a5747807efa8bc4bbc6150e3481473d8b9d0272c3ba22'
$expectedUidCanonicalSha256 = '7615a8f1d1edf4d59e5a4eb25996acd008a05a53921e4f293ea5765da4d67096'
$expectedConsoleSha256 = 'd8055fb8c7e7f5010d7439ec69be051554055dae55a265f8647bd7301c34161c'
$emptySha256 = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
$repoRoot = Split-Path -Parent (Split-Path -Parent $project)
$supportLauncher = Join-Path $repoRoot 'docs\work-orders\support\phase2-slice2b-stageb-013\capture-stageb-terminal.ps1'
$expectedEvidenceRoot = Join-Path $repoRoot 'docs\test-reports\evidence\phase2-slice2b\stageb-kernel-006'
$expectedLauncherPath = Join-Path $expectedEvidenceRoot 'capture-stageb-terminal.ps1'

function Get-BytesSha256 {
    param([Parameter(Mandatory = $true)][AllowEmptyCollection()][byte[]]$Bytes)
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function Get-FileSha256 {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Get-Utf8Sha256 {
    param([Parameter(Mandatory = $true)][string]$Text)
    return Get-BytesSha256 -Bytes ([Text.Encoding]::UTF8.GetBytes($Text))
}

function Get-CanonicalLfSha256 {
    param([Parameter(Mandatory = $true)][string]$Path)
    $strictUtf8 = New-Object Text.UTF8Encoding($false, $true)
    $text = [IO.File]::ReadAllText($Path, $strictUtf8)
    $canonical = $text.Replace("`r`n", "`n").Replace("`r", "`n")
    return Get-BytesSha256 -Bytes ([Text.Encoding]::UTF8.GetBytes($canonical))
}

function Write-BytesAtomic {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][byte[]]$Bytes
    )
    if (Test-Path -LiteralPath $Path) { throw "destination exists: $Path" }
    $temp = [string]::Concat($Path, '.', [Guid]::NewGuid().ToString('N'), '.tmp')
    $stream = New-Object IO.FileStream($temp, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    try {
        if ($Bytes.Length -gt 0) { $stream.Write($Bytes, 0, $Bytes.Length) }
        $stream.Flush($true)
    }
    finally {
        $stream.Dispose()
    }
    if (Test-Path -LiteralPath $Path) { throw "destination appeared: $Path" }
    [IO.File]::Move($temp, $Path)
}

function Write-JsonAtomic {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][object]$Value
    )
    $json = $Value | ConvertTo-Json -Depth 12
    Write-BytesAtomic -Path $Path -Bytes ([Text.UTF8Encoding]::new($false).GetBytes($json))
}

function ConvertTo-EncodedArguments {
    param([Parameter(Mandatory = $true)][string]$Source)
    if ([string]::IsNullOrEmpty($Source)) { throw 'encoded source is empty' }
    foreach ($character in $Source.ToCharArray()) {
        if ([int][char]$character -gt 127) { throw 'encoded source is not 7-bit ASCII' }
    }
    [byte[]]$utf16 = [Text.Encoding]::Unicode.GetBytes($Source)
    $encoded = [Convert]::ToBase64String($utf16)
    $decoded = [Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($encoded))
    if (-not [string]::Equals($decoded, $Source, [StringComparison]::Ordinal)) {
        throw 'encoded source round-trip mismatch'
    }
    return [string]::Concat('-NoLogo -NoProfile -NonInteractive -EncodedCommand ', $encoded)
}

function Test-ByteArrayEqual {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][byte[]]$Actual,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][byte[]]$Expected
    )
    if ($Actual.Length -ne $Expected.Length) { return $false }
    for ($index = 0; $index -lt $Actual.Length; $index++) {
        if ($Actual[$index] -ne $Expected[$index]) { return $false }
    }
    return $true
}

function Get-Identity {
    param([Parameter(Mandatory = $true)][string]$Path)
    $item = Get-Item -LiteralPath $Path
    return [ordered]@{
        path = $item.FullName
        byte_size = [int64]$item.Length
        sha256 = Get-FileSha256 -Path $item.FullName
    }
}

function Write-AttemptManifest {
    param([Parameter(Mandatory = $true)][string]$AttemptDirectory)
    $payload = @()
    foreach ($name in @('planned.json', 'stdout.bin', 'stderr.bin', 'result.json')) {
        $path = Join-Path $AttemptDirectory $name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "attempt payload absent: $name" }
        $item = Get-Item -LiteralPath $path
        $payload += [ordered]@{ relative_path = $name; byte_size = [int64]$item.Length; sha256 = Get-FileSha256 -Path $path }
    }
    Write-JsonAtomic -Path (Join-Path $AttemptDirectory 'manifest.json') -Value ([ordered]@{ schema = 'mfo.qa.stageb013.capture-attempt-manifest.v1'; payload = $payload })
}

function Invoke-CapturedChild {
    param(
        [Parameter(Mandatory = $true)][string]$Executable,
        [Parameter(Mandatory = $true)][string]$ArgumentString,
        [Parameter(Mandatory = $true)][string]$AttemptName,
        [Parameter(Mandatory = $true)][string]$AttemptMode,
        [Parameter(Mandatory = $true)][int]$TimeoutMilliseconds,
        [AllowNull()][string]$EncodedSource
    )
    if ([string]::IsNullOrEmpty($ArgumentString)) { throw 'argument string is empty' }
    $attemptDirectory = Join-Path $PSScriptRoot $AttemptName
    if (Test-Path -LiteralPath $attemptDirectory) { throw "attempt directory exists: $AttemptName" }
    [IO.Directory]::CreateDirectory($attemptDirectory) | Out-Null

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Executable
    $psi.WorkingDirectory = $project
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.Arguments = $ArgumentString
    if ([string]::IsNullOrEmpty($psi.Arguments)) { throw 'assigned arguments are empty' }
    if (-not [string]::Equals($psi.Arguments, $ArgumentString, [StringComparison]::Ordinal)) { throw 'assigned arguments differ' }

    $planned = [ordered]@{
        schema = 'mfo.qa.stageb013.capture-planned.v1'
        mode = $AttemptMode
        attempt_identity = $AttemptName
        executable = $Executable
        assigned_executable = $psi.FileName
        arguments = $ArgumentString
        assigned_arguments = $psi.Arguments
        argument_character_count = $ArgumentString.Length
        argument_utf8_sha256 = Get-Utf8Sha256 -Text $ArgumentString
        working_directory = $project
        assigned_working_directory = $psi.WorkingDirectory
        use_shell_execute = $psi.UseShellExecute
        create_no_window = $psi.CreateNoWindow
        redirect_stdout = $psi.RedirectStandardOutput
        redirect_stderr = $psi.RedirectStandardError
        launcher = Get-Identity -Path $PSCommandPath
        launcher_source = Get-Identity -Path $supportLauncher
        launcher_source_copy_equal = Test-ByteArrayEqual -Actual ([IO.File]::ReadAllBytes($PSCommandPath)) -Expected ([IO.File]::ReadAllBytes($supportLauncher))
        launcher_copy_read_only = [bool]((Get-Item -LiteralPath $PSCommandPath).Attributes -band [IO.FileAttributes]::ReadOnly)
        evidence_root = $PSScriptRoot
        launcher_canonical_lf_sha256 = Get-CanonicalLfSha256 -Path $PSCommandPath
        runner = Get-Identity -Path $runner
        runner_canonical_lf_sha256 = Get-CanonicalLfSha256 -Path $runner
        runner_uid = Get-Identity -Path $runnerUid
        runner_uid_canonical_lf_sha256 = Get-CanonicalLfSha256 -Path $runnerUid
        encoded_source = if ([string]::IsNullOrEmpty($EncodedSource)) { $null } else { $EncodedSource }
        encoded_source_utf8_sha256 = if ([string]::IsNullOrEmpty($EncodedSource)) { $null } else { Get-Utf8Sha256 -Text $EncodedSource }
    }
    $plannedPath = Join-Path $attemptDirectory 'planned.json'
    Write-JsonAtomic -Path $plannedPath -Value $planned
    $plannedReadback = Get-Content -LiteralPath $plannedPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not [string]::Equals([string]$plannedReadback.assigned_arguments, $psi.Arguments, [StringComparison]::Ordinal)) {
        throw 'planned argument readback differs'
    }
    if (-not [string]::Equals([string]$plannedReadback.executable, $Executable, [StringComparison]::Ordinal) -or
        -not [string]::Equals([string]$plannedReadback.assigned_executable, $Executable, [StringComparison]::Ordinal)) {
        throw 'planned executable readback differs'
    }
    if (-not [string]::Equals([string]$plannedReadback.working_directory, $project, [StringComparison]::OrdinalIgnoreCase) -or
        -not [string]::Equals([string]$plannedReadback.assigned_working_directory, $project, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'planned working-directory readback differs'
    }
    if ($plannedReadback.use_shell_execute -ne $false -or $plannedReadback.create_no_window -ne $true -or
        $plannedReadback.redirect_stdout -ne $true -or $plannedReadback.redirect_stderr -ne $true) {
        throw 'planned process flags mismatch'
    }
    if ($plannedReadback.launcher_source_copy_equal -ne $true -or $plannedReadback.launcher_copy_read_only -ne $true) {
        throw 'planned launcher binding mismatch'
    }

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    $startedUtc = [DateTime]::UtcNow.ToString('o')
    try {
        [void]$process.Start()
    }
    catch {
        Write-JsonAtomic -Path (Join-Path $attemptDirectory 'launch-failure.json') -Value ([ordered]@{
            schema = 'mfo.qa.stageb013.capture-launch-failure.v1'
            mode = $AttemptMode
            attempt_identity = $AttemptName
            started_utc = $startedUtc
            exception_type = $_.Exception.GetType().FullName
            message = $_.Exception.Message
        })
        throw
    }
    $pidValue = $process.Id
    $stdoutMemory = New-Object IO.MemoryStream
    $stderrMemory = New-Object IO.MemoryStream
    $stdoutTask = $process.StandardOutput.BaseStream.CopyToAsync($stdoutMemory)
    $stderrTask = $process.StandardError.BaseStream.CopyToAsync($stderrMemory)
    $processCompleted = $process.WaitForExit($TimeoutMilliseconds)
    $timedOut = -not $processCompleted
    $killAttempted = $false
    if (-not $processCompleted) {
        $killAttempted = $true
        try { $process.Kill() } catch {}
        $processCompleted = $process.WaitForExit(5000)
    }
    $streamsCompleted = [Threading.Tasks.Task]::WaitAll([Threading.Tasks.Task[]]@($stdoutTask, $stderrTask), 5000)
    [byte[]]$stdoutBytes = $stdoutMemory.ToArray()
    [byte[]]$stderrBytes = $stderrMemory.ToArray()
    $stdoutMemory.Dispose()
    $stderrMemory.Dispose()
    Write-BytesAtomic -Path (Join-Path $attemptDirectory 'stdout.bin') -Bytes $stdoutBytes
    Write-BytesAtomic -Path (Join-Path $attemptDirectory 'stderr.bin') -Bytes $stderrBytes
    $hasExited = $process.HasExited
    $numericExit = if ($processCompleted -and $hasExited) { [int]$process.ExitCode } else { $null }
    $result = [ordered]@{
        schema = 'mfo.qa.stageb013.capture-result.v1'
        mode = $AttemptMode
        attempt_identity = $AttemptName
        pid = $pidValue
        started_utc = $startedUtc
        ended_utc = [DateTime]::UtcNow.ToString('o')
        process_completed = $processCompleted
        timed_out = $timedOut
        streams_completed = $streamsCompleted
        kill_attempted = $killAttempted
        has_exited = $hasExited
        numeric_exit = $numericExit
        stdout_bytes = $stdoutBytes.Length
        stdout_sha256 = Get-BytesSha256 -Bytes $stdoutBytes
        stderr_bytes = $stderrBytes.Length
        stderr_sha256 = Get-BytesSha256 -Bytes $stderrBytes
        assigned_executable = $psi.FileName
        assigned_arguments = $psi.Arguments
        argument_character_count = $psi.Arguments.Length
        argument_utf8_sha256 = Get-Utf8Sha256 -Text $psi.Arguments
        runner_canonical_lf_sha256 = Get-CanonicalLfSha256 -Path $runner
        runner_uid_sha256 = Get-FileSha256 -Path $runnerUid
        runner_uid_canonical_lf_sha256 = Get-CanonicalLfSha256 -Path $runnerUid
    }
    Write-JsonAtomic -Path (Join-Path $attemptDirectory 'result.json') -Value $result
    Write-AttemptManifest -AttemptDirectory $attemptDirectory
    return [pscustomobject]@{ Result = $result; Stdout = $stdoutBytes; Stderr = $stderrBytes; AttemptDirectory = $attemptDirectory }
}

function Assert-PayloadManifest {
    param(
        [Parameter(Mandatory = $true)][string]$ManifestPath,
        [Parameter(Mandatory = $true)][string]$ExpectedSchema,
        [Parameter(Mandatory = $true)][string[]]$ExpectedNames,
        [Parameter(Mandatory = $true)][string]$PayloadRoot
    )
    if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) { throw "manifest absent: $ManifestPath" }
    $manifest = Get-Content -LiteralPath $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($manifest.schema -ne $ExpectedSchema) { throw "manifest schema mismatch: $ManifestPath" }
    $entries = @($manifest.payload)
    if ($entries.Count -ne $ExpectedNames.Count) { throw "manifest payload count mismatch: $ManifestPath" }
    for ($index = 0; $index -lt $ExpectedNames.Count; $index++) {
        $entry = $entries[$index]
        $expectedName = $ExpectedNames[$index]
        if (-not [string]::Equals([string]$entry.relative_path, $expectedName, [StringComparison]::Ordinal)) {
            throw "manifest payload order mismatch: $ManifestPath"
        }
        $entryPath = Join-Path $PayloadRoot $expectedName
        if (-not (Test-Path -LiteralPath $entryPath -PathType Leaf)) { throw "manifest payload absent: $entryPath" }
        if ((Get-Item -LiteralPath $entryPath).Length -ne [int64]$entry.byte_size) { throw "manifest payload size mismatch: $entryPath" }
        if ((Get-FileSha256 -Path $entryPath) -ne [string]$entry.sha256) { throw "manifest payload hash mismatch: $entryPath" }
    }
    return $manifest
}

function Assert-AttemptPass {
    param(
        [Parameter(Mandatory = $true)][string]$AttemptName,
        [Parameter(Mandatory = $true)][string]$ExpectedMode,
        [Parameter(Mandatory = $true)][int]$ExpectedExit
    )
    $attemptDirectory = Join-Path $PSScriptRoot $AttemptName
    $attemptNames = @('planned.json', 'stdout.bin', 'stderr.bin', 'result.json')
    $null = Assert-PayloadManifest -ManifestPath (Join-Path $attemptDirectory 'manifest.json') -ExpectedSchema 'mfo.qa.stageb013.capture-attempt-manifest.v1' -ExpectedNames $attemptNames -PayloadRoot $attemptDirectory
    $passNames = @('planned.json', 'stdout.bin', 'stderr.bin', 'result.json', 'manifest.json', 'pass-verdict.json')
    $null = Assert-PayloadManifest -ManifestPath (Join-Path $attemptDirectory 'pass-manifest.json') -ExpectedSchema 'mfo.qa.stageb013.capture-pass-manifest.v1' -ExpectedNames $passNames -PayloadRoot $attemptDirectory

    $planned = Get-Content -LiteralPath (Join-Path $attemptDirectory 'planned.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    $result = Get-Content -LiteralPath (Join-Path $attemptDirectory 'result.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    $verdict = Get-Content -LiteralPath (Join-Path $attemptDirectory 'pass-verdict.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    $expectedExecutable = $null
    $expectedArguments = $null
    switch ($ExpectedMode) {
        'QUALIFY_STREAMS' { $expectedExecutable = $powerShell; $expectedArguments = $streamArguments }
        'QUALIFY_EMPTY' { $expectedExecutable = $powerShell; $expectedArguments = $emptyArguments }
        'QUALIFY_GODOT_VERSION' { $expectedExecutable = $console; $expectedArguments = '--version' }
        'PARSER' { $expectedExecutable = $console; $expectedArguments = '--headless --path . --check-only --script res://tests/run_slice2b_stageb_action_kernel_tests.gd' }
        default { throw "unsupported attempt mode: $ExpectedMode" }
    }
    $expectedArgumentSha256 = Get-Utf8Sha256 -Text $expectedArguments
    if ($planned.schema -ne 'mfo.qa.stageb013.capture-planned.v1' -or $result.schema -ne 'mfo.qa.stageb013.capture-result.v1' -or
        $verdict.schema -ne 'mfo.qa.stageb013.capture-pass-verdict.v1') { throw "attempt schema mismatch: $AttemptName" }
    if ($planned.mode -ne $ExpectedMode -or $result.mode -ne $ExpectedMode -or $verdict.mode -ne $ExpectedMode -or
        $planned.attempt_identity -ne $AttemptName -or $result.attempt_identity -ne $AttemptName -or
        $verdict.attempt_identity -ne $AttemptName) { throw "attempt identity mismatch: $AttemptName" }
    if ($verdict.outcome -ne 'Pass') { throw "attempt verdict is not Pass: $AttemptName" }
    if ($result.numeric_exit -ne $ExpectedExit -or -not $result.process_completed -or $result.timed_out -ne $false -or -not $result.streams_completed -or
        $result.kill_attempted -or -not $result.has_exited) { throw "attempt process result mismatch: $AttemptName" }
    if (-not [string]::Equals([string]$planned.executable, $expectedExecutable, [StringComparison]::OrdinalIgnoreCase) -or
        -not [string]::Equals([string]$planned.assigned_executable, $expectedExecutable, [StringComparison]::OrdinalIgnoreCase) -or
        -not [string]::Equals([string]$result.assigned_executable, $expectedExecutable, [StringComparison]::OrdinalIgnoreCase)) {
        throw "attempt executable differs from mode-specific expectation: $AttemptName"
    }
    if (-not [string]::Equals([string]$planned.arguments, $expectedArguments, [StringComparison]::Ordinal) -or
        -not [string]::Equals([string]$planned.assigned_arguments, $expectedArguments, [StringComparison]::Ordinal) -or
        -not [string]::Equals([string]$result.assigned_arguments, $expectedArguments, [StringComparison]::Ordinal) -or
        [int]$planned.argument_character_count -ne $expectedArguments.Length -or
        [int]$result.argument_character_count -ne $expectedArguments.Length -or
        -not [string]::Equals([string]$planned.argument_utf8_sha256, $expectedArgumentSha256, [StringComparison]::Ordinal) -or
        -not [string]::Equals([string]$result.argument_utf8_sha256, $expectedArgumentSha256, [StringComparison]::Ordinal)) {
        throw "attempt arguments differ from mode-specific expectation: $AttemptName"
    }
    if ($planned.launcher_source_copy_equal -ne $true -or $planned.launcher_copy_read_only -ne $true) {
        throw "attempt launcher binding mismatch: $AttemptName"
    }
    if ($planned.runner_canonical_lf_sha256 -ne $expectedRunnerCanonicalSha256 -or
        $planned.runner_uid_canonical_lf_sha256 -ne $expectedUidCanonicalSha256 -or
        $result.runner_canonical_lf_sha256 -ne $expectedRunnerCanonicalSha256 -or
        $result.runner_uid_canonical_lf_sha256 -ne $expectedUidCanonicalSha256) {
        throw "attempt immutable identity mismatch: $AttemptName"
    }
    $stdoutPath = Join-Path $attemptDirectory 'stdout.bin'
    $stderrPath = Join-Path $attemptDirectory 'stderr.bin'
    if ((Get-Item -LiteralPath $stdoutPath).Length -ne [int64]$result.stdout_bytes -or
        (Get-FileSha256 -Path $stdoutPath) -ne [string]$result.stdout_sha256 -or
        (Get-Item -LiteralPath $stderrPath).Length -ne [int64]$result.stderr_bytes -or
        (Get-FileSha256 -Path $stderrPath) -ne [string]$result.stderr_sha256) {
        throw "attempt raw stream mismatch: $AttemptName"
    }
    [byte[]]$stdoutBytes = [IO.File]::ReadAllBytes($stdoutPath)
    [byte[]]$stderrBytes = [IO.File]::ReadAllBytes($stderrPath)
    switch ($ExpectedMode) {
        'QUALIFY_STREAMS' {
            if (-not (Test-ByteArrayEqual -Actual $stdoutBytes -Expected ([Text.Encoding]::ASCII.GetBytes('MFO_CAPTURE_STDOUT_V1'))) -or
                -not (Test-ByteArrayEqual -Actual $stderrBytes -Expected ([Text.Encoding]::ASCII.GetBytes('MFO_CAPTURE_STDERR_V1')))) {
                throw "attempt stream canary bytes mismatch: $AttemptName"
            }
        }
        'QUALIFY_EMPTY' {
            if ($stdoutBytes.Length -ne 0 -or $stderrBytes.Length -ne 0 -or
                [string]$result.stdout_sha256 -ne $emptySha256 -or [string]$result.stderr_sha256 -ne $emptySha256) {
                throw "attempt empty-stream canary mismatch: $AttemptName"
            }
        }
        'QUALIFY_GODOT_VERSION' {
            $strictUtf8 = New-Object Text.UTF8Encoding($false, $true)
            $versionText = $strictUtf8.GetString($stdoutBytes).TrimEnd([char[]]@(13, 10))
            if ($versionText.Contains([char]10) -or $versionText.Contains([char]13) -or
                $versionText -ne '4.7.stable.official.5b4e0cb0f' -or $stderrBytes.Length -ne 0) {
                throw "attempt Godot-version canary mismatch: $AttemptName"
            }
        }
        'PARSER' {
            $combined = [string]::Concat([Text.Encoding]::UTF8.GetString($stdoutBytes), [Text.Encoding]::UTF8.GetString($stderrBytes))
            if ($combined.Contains('SCRIPT ERROR') -or $combined.Contains('Parse Error')) {
                throw "attempt parser raw-stream mismatch: $AttemptName"
            }
        }
    }
    if ($verdict.result_sha256 -ne (Get-FileSha256 -Path (Join-Path $attemptDirectory 'result.json')) -or
        $verdict.attempt_manifest_sha256 -ne (Get-FileSha256 -Path (Join-Path $attemptDirectory 'manifest.json'))) {
        throw "attempt verdict binding mismatch: $AttemptName"
    }
}

function Write-PassVerdict {
    param(
        [Parameter(Mandatory = $true)][string]$AttemptDirectory,
        [Parameter(Mandatory = $true)][string]$AttemptName,
        [Parameter(Mandatory = $true)][string]$AttemptMode,
        [Parameter(Mandatory = $true)][int]$ExpectedExit
    )
    $verdictPath = Join-Path $AttemptDirectory 'pass-verdict.json'
    Write-JsonAtomic -Path $verdictPath -Value ([ordered]@{
        schema = 'mfo.qa.stageb013.capture-pass-verdict.v1'
        outcome = 'Pass'
        mode = $AttemptMode
        attempt_identity = $AttemptName
        expected_numeric_exit = $ExpectedExit
        result_sha256 = Get-FileSha256 -Path (Join-Path $AttemptDirectory 'result.json')
        attempt_manifest_sha256 = Get-FileSha256 -Path (Join-Path $AttemptDirectory 'manifest.json')
        launcher_canonical_lf_sha256 = Get-CanonicalLfSha256 -Path $PSCommandPath
        runner_canonical_lf_sha256 = Get-CanonicalLfSha256 -Path $runner
        runner_uid_canonical_lf_sha256 = Get-CanonicalLfSha256 -Path $runnerUid
    })
    $payload = @()
    foreach ($name in @('planned.json', 'stdout.bin', 'stderr.bin', 'result.json', 'manifest.json', 'pass-verdict.json')) {
        $path = Join-Path $AttemptDirectory $name
        $item = Get-Item -LiteralPath $path
        $payload += [ordered]@{ relative_path = $name; byte_size = [int64]$item.Length; sha256 = Get-FileSha256 -Path $path }
    }
    Write-JsonAtomic -Path (Join-Path $AttemptDirectory 'pass-manifest.json') -Value ([ordered]@{
        schema = 'mfo.qa.stageb013.capture-pass-manifest.v1'
        payload = $payload
    })
    Assert-AttemptPass -AttemptName $AttemptName -ExpectedMode $AttemptMode -ExpectedExit $ExpectedExit
}

function Write-QualificationManifest {
    $relativePaths = @(
        'qualify-streams-001\pass-manifest.json',
        'qualify-empty-001\pass-manifest.json',
        'qualify-godot-version-001\pass-manifest.json'
    )
    $payload = @()
    foreach ($relative in $relativePaths) {
        $path = Join-Path $PSScriptRoot $relative
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "qualification payload absent: $relative" }
        $item = Get-Item -LiteralPath $path
        $payload += [ordered]@{ relative_path = $relative; byte_size = [int64]$item.Length; sha256 = Get-FileSha256 -Path $path }
    }
    $value = [ordered]@{
        schema = 'mfo.qa.stageb013.capture-qualification-manifest.v2'
        launcher = Get-Identity -Path $PSCommandPath
        launcher_source = Get-Identity -Path $supportLauncher
        launcher_source_copy_equal = Test-ByteArrayEqual -Actual ([IO.File]::ReadAllBytes($PSCommandPath)) -Expected ([IO.File]::ReadAllBytes($supportLauncher))
        launcher_canonical_lf_sha256 = Get-CanonicalLfSha256 -Path $PSCommandPath
        runner_canonical_lf_sha256 = Get-CanonicalLfSha256 -Path $runner
        runner_uid_sha256 = Get-FileSha256 -Path $runnerUid
        runner_uid_canonical_lf_sha256 = Get-CanonicalLfSha256 -Path $runnerUid
        payload = $payload
    }
    Write-JsonAtomic -Path (Join-Path $PSScriptRoot 'qualification-manifest.json') -Value $value
}

function Assert-QualificationManifest {
    $relativePaths = @(
        'qualify-streams-001\pass-manifest.json',
        'qualify-empty-001\pass-manifest.json',
        'qualify-godot-version-001\pass-manifest.json'
    )
    $path = Join-Path $PSScriptRoot 'qualification-manifest.json'
    $manifest = Assert-PayloadManifest -ManifestPath $path -ExpectedSchema 'mfo.qa.stageb013.capture-qualification-manifest.v2' -ExpectedNames $relativePaths -PayloadRoot $PSScriptRoot
    if ($manifest.runner_canonical_lf_sha256 -ne $expectedRunnerCanonicalSha256 -or
        $manifest.runner_uid_canonical_lf_sha256 -ne $expectedUidCanonicalSha256 -or
        $manifest.launcher_source_copy_equal -ne $true) { throw 'qualification immutable identity mismatch' }
    Assert-AttemptPass -AttemptName 'qualify-streams-001' -ExpectedMode 'QUALIFY_STREAMS' -ExpectedExit 23
    Assert-AttemptPass -AttemptName 'qualify-empty-001' -ExpectedMode 'QUALIFY_EMPTY' -ExpectedExit 29
    Assert-AttemptPass -AttemptName 'qualify-godot-version-001' -ExpectedMode 'QUALIFY_GODOT_VERSION' -ExpectedExit 0
}

if (-not [string]::Equals([IO.Path]::GetFullPath($PSScriptRoot), [IO.Path]::GetFullPath($expectedEvidenceRoot), [StringComparison]::OrdinalIgnoreCase)) {
    throw 'launcher evidence root mismatch'
}
if (-not [string]::Equals([IO.Path]::GetFullPath($PSCommandPath), [IO.Path]::GetFullPath($expectedLauncherPath), [StringComparison]::OrdinalIgnoreCase)) {
    throw 'launcher destination mismatch'
}
if (-not (Test-Path -LiteralPath $supportLauncher -PathType Leaf)) { throw 'launcher source absent' }
if (-not (Test-ByteArrayEqual -Actual ([IO.File]::ReadAllBytes($PSCommandPath)) -Expected ([IO.File]::ReadAllBytes($supportLauncher)))) {
    throw 'launcher source/copy byte mismatch'
}
if (-not ((Get-Item -LiteralPath $PSCommandPath).Attributes -band [IO.FileAttributes]::ReadOnly)) {
    throw 'launcher copy is not ReadOnly'
}
if (-not (Test-Path -LiteralPath $project -PathType Container)) { throw 'project absent' }
if ((Get-CanonicalLfSha256 -Path $runner) -ne $expectedRunnerCanonicalSha256) { throw 'runner canonical identity mismatch' }
if ((Get-CanonicalLfSha256 -Path $runnerUid) -ne $expectedUidCanonicalSha256) { throw 'runner UID identity mismatch' }
if ((Get-Item -LiteralPath $console).Length -ne 198152) { throw 'console size mismatch' }
if ((Get-FileSha256 -Path $console) -ne $expectedConsoleSha256) { throw 'console hash mismatch' }
if ((Get-CanonicalLfSha256 -Path $supportLauncher) -ne (Get-CanonicalLfSha256 -Path $PSCommandPath)) {
    throw 'launcher canonical identity mismatch'
}

$streamArguments = ConvertTo-EncodedArguments -Source $streamCanarySource
$emptyArguments = ConvertTo-EncodedArguments -Source $emptyCanarySource

switch ($Mode) {
    'QUALIFY_STREAMS' {
        foreach ($forbidden in @('qualify-empty-001', 'qualify-godot-version-001', 'parser-001', 'formal-001', 'qualification-manifest.json')) {
            if (Test-Path -LiteralPath (Join-Path $PSScriptRoot $forbidden)) { throw 'qualification order is not fresh' }
        }
        $capture = Invoke-CapturedChild -Executable $powerShell -ArgumentString $streamArguments -AttemptName 'qualify-streams-001' -AttemptMode $Mode -TimeoutMilliseconds 60000 -EncodedSource $streamCanarySource
        $expectedStdout = [Text.Encoding]::ASCII.GetBytes('MFO_CAPTURE_STDOUT_V1')
        $expectedStderr = [Text.Encoding]::ASCII.GetBytes('MFO_CAPTURE_STDERR_V1')
        if (-not $capture.Result.process_completed -or -not $capture.Result.streams_completed -or $capture.Result.kill_attempted) { throw 'stream qualification capture incomplete' }
        if ($capture.Result.numeric_exit -ne 23) { throw 'stream qualification exit mismatch' }
        if (-not (Test-ByteArrayEqual -Actual $capture.Stdout -Expected $expectedStdout)) { throw 'stream qualification stdout mismatch' }
        if (-not (Test-ByteArrayEqual -Actual $capture.Stderr -Expected $expectedStderr)) { throw 'stream qualification stderr mismatch' }
        Write-PassVerdict -AttemptDirectory $capture.AttemptDirectory -AttemptName 'qualify-streams-001' -AttemptMode $Mode -ExpectedExit 23
    }
    'QUALIFY_EMPTY' {
        Assert-AttemptPass -AttemptName 'qualify-streams-001' -ExpectedMode 'QUALIFY_STREAMS' -ExpectedExit 23
        foreach ($forbidden in @('qualify-godot-version-001', 'parser-001', 'formal-001', 'qualification-manifest.json')) {
            if (Test-Path -LiteralPath (Join-Path $PSScriptRoot $forbidden)) { throw 'qualification order is not fresh' }
        }
        $capture = Invoke-CapturedChild -Executable $powerShell -ArgumentString $emptyArguments -AttemptName 'qualify-empty-001' -AttemptMode $Mode -TimeoutMilliseconds 60000 -EncodedSource $emptyCanarySource
        if (-not $capture.Result.process_completed -or -not $capture.Result.streams_completed -or $capture.Result.kill_attempted) { throw 'empty qualification capture incomplete' }
        if ($capture.Result.numeric_exit -ne 29) { throw 'empty qualification exit mismatch' }
        if ($capture.Result.stdout_bytes -ne 0 -or $capture.Result.stdout_sha256 -ne $emptySha256) { throw 'empty qualification stdout mismatch' }
        if ($capture.Result.stderr_bytes -ne 0 -or $capture.Result.stderr_sha256 -ne $emptySha256) { throw 'empty qualification stderr mismatch' }
        Write-PassVerdict -AttemptDirectory $capture.AttemptDirectory -AttemptName 'qualify-empty-001' -AttemptMode $Mode -ExpectedExit 29
    }
    'QUALIFY_GODOT_VERSION' {
        Assert-AttemptPass -AttemptName 'qualify-streams-001' -ExpectedMode 'QUALIFY_STREAMS' -ExpectedExit 23
        Assert-AttemptPass -AttemptName 'qualify-empty-001' -ExpectedMode 'QUALIFY_EMPTY' -ExpectedExit 29
        foreach ($forbidden in @('parser-001', 'formal-001', 'qualification-manifest.json')) {
            if (Test-Path -LiteralPath (Join-Path $PSScriptRoot $forbidden)) { throw 'qualification order is not fresh' }
        }
        $capture = Invoke-CapturedChild -Executable $console -ArgumentString '--version' -AttemptName 'qualify-godot-version-001' -AttemptMode $Mode -TimeoutMilliseconds 60000 -EncodedSource $null
        $strictUtf8 = New-Object Text.UTF8Encoding($false, $true)
        $stdoutText = $strictUtf8.GetString($capture.Stdout).TrimEnd([char[]]@(13, 10))
        if (-not $capture.Result.process_completed -or -not $capture.Result.streams_completed -or $capture.Result.kill_attempted) { throw 'version qualification capture incomplete' }
        if ($capture.Result.numeric_exit -ne 0 -or $stdoutText.Contains([char]10) -or $stdoutText.Contains([char]13) -or $stdoutText -ne '4.7.stable.official.5b4e0cb0f') { throw 'version qualification mismatch' }
        if ($capture.Result.stderr_bytes -ne 0 -or $capture.Result.stderr_sha256 -ne $emptySha256) { throw 'version qualification stderr mismatch' }
        Write-PassVerdict -AttemptDirectory $capture.AttemptDirectory -AttemptName 'qualify-godot-version-001' -AttemptMode $Mode -ExpectedExit 0
        Write-QualificationManifest
        Assert-QualificationManifest
    }
    'PARSER' {
        Assert-QualificationManifest
        if (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'formal-001')) { throw 'parser order is not fresh' }
        $capture = Invoke-CapturedChild -Executable $console -ArgumentString '--headless --path . --check-only --script res://tests/run_slice2b_stageb_action_kernel_tests.gd' -AttemptName 'parser-001' -AttemptMode $Mode -TimeoutMilliseconds 60000 -EncodedSource $null
        $combined = [string]::Concat([Text.Encoding]::UTF8.GetString($capture.Stdout), [Text.Encoding]::UTF8.GetString($capture.Stderr))
        if (-not $capture.Result.process_completed -or -not $capture.Result.streams_completed -or $capture.Result.kill_attempted) { throw 'parser capture incomplete' }
        if ($capture.Result.numeric_exit -ne 0 -or $combined.Contains('SCRIPT ERROR') -or $combined.Contains('Parse Error')) { throw 'parser non-pass' }
        Write-PassVerdict -AttemptDirectory $capture.AttemptDirectory -AttemptName 'parser-001' -AttemptMode $Mode -ExpectedExit 0
    }
    'FORMAL' {
        Assert-QualificationManifest
        Assert-AttemptPass -AttemptName 'parser-001' -ExpectedMode 'PARSER' -ExpectedExit 0
        $capture = Invoke-CapturedChild -Executable $console -ArgumentString '--headless --path . --script res://tests/run_slice2b_stageb_action_kernel_tests.gd' -AttemptName 'formal-001' -AttemptMode $Mode -TimeoutMilliseconds 120000 -EncodedSource $null
        if (-not $capture.Result.process_completed -or -not $capture.Result.streams_completed -or $capture.Result.kill_attempted) { throw 'formal capture incomplete' }
    }
}

[ordered]@{ mode = $Mode; outcome = 'capture-complete'; runner_canonical_lf_sha256 = Get-CanonicalLfSha256 -Path $runner; runner_uid_sha256 = Get-FileSha256 -Path $runnerUid; runner_uid_canonical_lf_sha256 = Get-CanonicalLfSha256 -Path $runnerUid } | ConvertTo-Json -Depth 4
exit 0
