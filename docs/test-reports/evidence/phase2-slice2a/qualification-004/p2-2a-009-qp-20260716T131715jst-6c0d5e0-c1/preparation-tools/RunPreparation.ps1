param(
    [Parameter(Mandatory = $true)]
    [string] $Stage,

    [Parameter(Mandatory = $true)]
    [ValidateSet('qp_dryrun_runner_exact', 'qp_selftest_runner_exact', 'qp_power_input_smoke_runner_exact', 'qp_preack_contract_selftest_runner_exact', 'qp_live_evidence_contract_selftest_runner_exact')]
    [string] $InvocationKey,

    [Parameter(Mandatory = $true)]
    [string] $OutputRelative
)

$ErrorActionPreference = 'Stop'
$issuedWorkOrder = 'MFO-WO-P2-2A-009'
$stageIdPrefix = 'p2-2a-009-qp-'

function Assert-JsonProperty {
    param([object] $Object, [string] $Name, [string] $Label)
    if ($null -eq $Object -or -not ($Object.PSObject.Properties.Name -ccontains $Name)) {
        throw "$Label is missing required property: $Name"
    }
}

function Get-Utf8Sha256 {
    param([string] $Text)
    $encoding = New-Object Text.UTF8Encoding($false)
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString($sha.ComputeHash($encoding.GetBytes($Text)))).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

$stagePath = [IO.Path]::GetFullPath($Stage)
$stageId = [IO.Path]::GetFileName($stagePath)
if (-not (Test-Path -LiteralPath $stagePath -PathType Container)) { throw 'Preparation stage does not exist.' }
if (-not $stageId.StartsWith($stageIdPrefix, [StringComparison]::Ordinal)) { throw 'Fresh -009 stage ID prefix is required.' }
$stagePrefixPath = $stagePath.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
$tempPrefix = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
$localPrefix = [IO.Path]::GetFullPath([Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (-not $stagePrefixPath.StartsWith($tempPrefix, [StringComparison]::OrdinalIgnoreCase) -and -not $stagePrefixPath.StartsWith($localPrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Preparation stage is outside LocalAppData/TEMP.'
}
foreach ($oneDriveRoot in @($env:OneDrive, $env:OneDriveConsumer, $env:OneDriveCommercial)) {
    if ([String]::IsNullOrWhiteSpace($oneDriveRoot)) { continue }
    $oneDrivePrefix = [IO.Path]::GetFullPath($oneDriveRoot).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    if ($stagePrefixPath.StartsWith($oneDrivePrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'Preparation stage is inside a known OneDrive root.' }
}
if ($stagePrefixPath.IndexOf('OneDrive', [StringComparison]::OrdinalIgnoreCase) -ge 0) { throw 'Preparation stage is inside OneDrive.' }
$expectedOutputs = @{
    qp_dryrun_runner_exact = 'preparation\dryrun-qualified'
    qp_selftest_runner_exact = 'preparation\selftest-qualified'
    qp_power_input_smoke_runner_exact = 'preparation\power-input-smoke-qualified'
    qp_preack_contract_selftest_runner_exact = 'preparation\preack-contract-selftest-qualified'
    qp_live_evidence_contract_selftest_runner_exact = 'preparation\live-evidence-contract-selftest-qualified'
}
$normalizedExpected = $expectedOutputs[$InvocationKey]
if ($OutputRelative -cne $normalizedExpected) {
    throw "OutputRelative does not match the sealed invocation key: $InvocationKey"
}
$contractPath = Join-Path $stagePath 'config\component-contract.json'
$contract = Get-Content -LiteralPath $contractPath -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($name in @('schema', 'work_order', 'stage_id', 'preparation_invocations', 'performance_slot_launch_count', 'abc_launch_count', 'abc_launch_authorized')) {
    Assert-JsonProperty $contract $name 'Component contract'
}
if ($contract.schema -cne 'mfo.qa.qualification.identity-contract.v1' -or
    $contract.work_order -cne $issuedWorkOrder -or
    $contract.stage_id -cne $stageId) {
    throw 'Component contract is not bound to the exact fresh -009 stage.'
}
if ([int] $contract.performance_slot_launch_count -ne 0 -or [int] $contract.abc_launch_count -ne 0 -or [bool] $contract.abc_launch_authorized) {
    throw 'Component contract violates the zero-launch boundary.'
}
$externalRunRoot = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)) ('Temp\MFO-P2-2A-009-Runs\' + $stageId)
if ((Test-Path -LiteralPath (Join-Path $stagePath 'runs')) -or (Test-Path -LiteralPath $externalRunRoot)) {
    throw 'PREACK/LIVE runtime evidence exists before preparation tests.'
}
$invocationShaKey = $InvocationKey + '_sha256'
Assert-JsonProperty $contract.preparation_invocations $InvocationKey 'Preparation invocation contract'
Assert-JsonProperty $contract.preparation_invocations $invocationShaKey 'Preparation invocation contract'
$runner = Join-Path $stagePath 'bin\MfoQaRunner.exe'
$exact = [string] $contract.preparation_invocations.$InvocationKey
$sealedInvocationSha = [string] $contract.preparation_invocations.($invocationShaKey)
if ([String]::IsNullOrEmpty($exact) -or $sealedInvocationSha -notmatch '\A[0-9a-f]{64}\z') {
    throw 'Preparation invocation or its sealed SHA-256 is malformed.'
}
$actualInvocationSha = Get-Utf8Sha256 $exact
if ($actualInvocationSha -cne $sealedInvocationSha) {
    throw 'Preparation invocation SHA-256 does not match its exact UTF-8 bytes.'
}
$prefix = '"' + $runner + '"'
if (-not $exact.StartsWith($prefix, [StringComparison]::Ordinal)) {
    throw 'Exact invocation prefix mismatch.'
}
if ($exact.Substring($prefix.Length, 2) -cne '  ') {
    throw 'Exact invocation does not contain the sealed cmd-normalized separator.'
}

$output = Join-Path $stagePath $OutputRelative
$output = [IO.Path]::GetFullPath($output)
$stagePrefix = $stagePath.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (-not $output.StartsWith($stagePrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Preparation output escaped the stage root.'
}
if (Test-Path -LiteralPath $output) {
    throw "Preparation output already exists: $output"
}
[void] (New-Item -ItemType Directory -Path $output)

$stdoutPath = Join-Path $output 'runner.stdout.raw'
$stderrPath = Join-Path $output 'runner.stderr.raw'
$psi = New-Object Diagnostics.ProcessStartInfo
$psi.FileName = $env:ComSpec
$launchInvocation = $exact.Remove($prefix.Length, 1)
$commandLine = $launchInvocation + '1>"' + $stdoutPath + '"2>"' + $stderrPath + '"'
$psi.Arguments = '/d /s /c "' + $commandLine + '"'
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
$psi.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
$process = New-Object Diagnostics.Process
$process.StartInfo = $psi
if (-not $process.Start()) {
    throw 'Preparation runner did not start.'
}
if (-not $process.WaitForExit(300000)) {
    try { $process.Kill() } catch { }
    $process.WaitForExit()
    throw "Preparation runner exceeded the 300000 ms bounded timeout: $InvocationKey"
}
$nativeExit = [int] $process.ExitCode
if (-not (Test-Path -LiteralPath $stdoutPath) -or -not (Test-Path -LiteralPath $stderrPath)) {
    throw 'Runner raw stream redirection did not create both files.'
}

$resultPath = Join-Path $output 'runner-result.json'
if (-not (Test-Path -LiteralPath $resultPath)) {
    throw "Structured result missing; native exit $($process.ExitCode)."
}
$result = Get-Content -LiteralPath $resultPath -Raw -Encoding UTF8 | ConvertFrom-Json
$expectedMode = $InvocationKey.Substring(0, $InvocationKey.Length - '_runner_exact'.Length).ToUpperInvariant()
foreach ($name in @('result_code', 'classification', 'role', 'mode', 'performance_slot_launch_count', 'details')) {
    Assert-JsonProperty $result $name 'Structured result'
}
$resultCode = [int] $result.result_code
$classificationByCode = @{ 0 = 'Pass'; 20 = 'Blocked'; 30 = 'Fail'; 31 = 'Fail' }
if (-not $classificationByCode.ContainsKey($resultCode)) { throw "Unexpected structured result code: $resultCode" }
if ($nativeExit -ne $resultCode) { throw "Native exit/result-code mismatch: $nativeExit/$resultCode" }
if ($result.role -cne 'runner' -or $result.mode -cne $expectedMode) { throw 'Structured result role/mode mismatch.' }
if ($result.classification -cne $classificationByCode[$resultCode]) { throw 'Structured result classification/code mismatch.' }
if ([int] $result.performance_slot_launch_count -ne 0) { throw 'Structured result root violated the zero-slot boundary.' }

if ($nativeExit -eq 0) {
    foreach ($name in @('performance_slot_launch_count', 'final_owned_runtime_count', 'abc_launch_count')) {
        Assert-JsonProperty $result.details $name 'Preparation Pass details'
    }
    if ($result.details.performance_slot_launch_count -ne 0 -or $result.details.final_owned_runtime_count -ne 0 -or $result.details.abc_launch_count -ne 0) {
        throw 'Preparation Pass result violated the zero-launch or cleanup boundary.'
    }
    if ($InvocationKey -ceq 'qp_live_evidence_contract_selftest_runner_exact') {
        Assert-JsonProperty $result.details 'controller_launch_count' 'LIVE-evidence self-test Pass details'
        if ([int] $result.details.controller_launch_count -ne 0) { throw 'LIVE-evidence self-test launched the controller.' }
    }
}
Write-Output ("INVOCATION_KEY=$InvocationKey")
Write-Output ("INVOCATION_SHA256=$actualInvocationSha")
Write-Output ("NATIVE_EXIT=$nativeExit")
Write-Output ("RESULT=$($result.result_code)/$($result.classification)")
Write-Output ("RESULT_SHA256=$((Get-FileHash -Algorithm SHA256 -LiteralPath $resultPath).Hash.ToLowerInvariant())")
Write-Output ("PERFORMANCE_SLOT_COUNT=$($result.details.performance_slot_launch_count)")
if ($null -ne $result.details.abc_launch_count) {
    Write-Output ("ABC_LAUNCH_COUNT=$($result.details.abc_launch_count)")
}
if ($null -ne $result.details.controller_launch_count) {
    Write-Output ("CONTROLLER_LAUNCH_COUNT=$($result.details.controller_launch_count)")
}
Write-Output ("FINAL_OWNED_RUNTIME=$($result.details.final_owned_runtime_count)")
Write-Output ("JOURNAL_SHA256=$((Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $output 'evidence.journal.jsonl')).Hash.ToLowerInvariant())")
Write-Output ("STDOUT_SHA256=$((Get-FileHash -Algorithm SHA256 -LiteralPath $stdoutPath).Hash.ToLowerInvariant())")
Write-Output ("STDERR_SHA256=$((Get-FileHash -Algorithm SHA256 -LiteralPath $stderrPath).Hash.ToLowerInvariant())")

if ($nativeExit -ne 0) {
    Write-Output (Get-Content -LiteralPath $stderrPath -Raw -Encoding UTF8)
    $process.Dispose()
    exit $nativeExit
}
$process.Dispose()
