param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('QUALIFY_STREAMS', 'QUALIFY_EMPTY', 'QUALIFY_GODOT_VERSION', 'PARSER', 'FORMAL')]
    [string]$Mode
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$project = 'C:\tmp\q2b-stageb\material-frontier-online\prototype'
$consoleBytes = [Convert]::FromBase64String('QzpcVXNlcnNcb3NhdG9cT25lRHJpdmVc44OJ44Kt44Ol44Oh44Oz44OIXE1GXG1hdGVyaWFsLWZyb250aWVyLW9ubGluZVwudG9vbHNcZ29kb3QtNC43LXN0YWJsZVxlZGl0b3JcR29kb3RfdjQuNy1zdGFibGVfd2luNjRfY29uc29sZS5leGU=')
$console = [Text.Encoding]::UTF8.GetString($consoleBytes)
$powerShell = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
$streamCommand = '-NoLogo -NoProfile -NonInteractive -EncodedCommand JABvAD0AWwBUAGUAeAB0AC4ARQBuAGMAbwBkAGkAbgBnAF0AOgA6AEEAUwBDAEkASQAuAEcAZQB0AEIAeQB0AGUAcwAoACcATQBGAE8AXwBDAEEAUABUAFUAUgBFAF8AUwBURE9VVF9WMScpADsAWwBDAG8AbgBzAG8AbABlAF0AOgA6AE8AcABlAG4AUwB0AGEAbgBkAGEAcgBkAE8AdQB0AHAAdQB0ACgAKQAuAFcAcgBpAHQAZQAoACQAbwAsADAALAAkAG8ALgBMAGUAbgBnAHQAaAApADsAJABlAD0AWwBUAGUAeAB0AC4ARQBuAGMAbwBkAGkAbgBnAF0AOgA6AEEAUwBDAEkASQAuAEcAZQB0AEIAeQB0AGUAcwAoACcATQBGAE8AXwBDAEEAUABUAFUAUgBFAF8AUwBUREVSUl9WMScpADsAWwBDAG8AbgBzAG8AbABlAF0AOgA6AE8AcABlAG4AUwB0AGEAbgBkAGEAcgBkAEUAcgByAG8AcgAoACkALgBXAHIAaQB0AGUAKAAkAGUALAAwACwAJABlAC4ATABlAG4AZwB0aAApADsAZQB4AGkAdAAgADIAMwA='
$emptyCommand = '-NoLogo -NoProfile -NonInteractive -EncodedCommand ZQB4AGkAdAAgADIAOQA='

function Invoke-CapturedChild {
    param(
        [Parameter(Mandatory = $true)][string]$Executable,
        [Parameter(Mandatory = $true)][string]$ArgumentString,
        [Parameter(Mandatory = $true)][string]$WorkingDirectory,
        [Parameter(Mandatory = $true)][string]$AttemptDirectory,
        [Parameter(Mandatory = $true)][string]$AttemptMode
    )
    if ([string]::IsNullOrEmpty($ArgumentString)) { throw 'ArgumentString must be nonempty' }
    if (Test-Path -LiteralPath $AttemptDirectory) { throw 'attempt directory already exists' }
    [IO.Directory]::CreateDirectory($AttemptDirectory) | Out-Null
    $launcherHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $PSCommandPath).Hash.ToLowerInvariant()
    $planned = [ordered]@{ mode = $AttemptMode; executable = $Executable; arguments = $ArgumentString; working_directory = $WorkingDirectory; launcher_sha256 = $launcherHash; attempt_identity = (Split-Path -Leaf $AttemptDirectory) }
    [IO.File]::WriteAllText((Join-Path $AttemptDirectory 'planned.json'), ($planned | ConvertTo-Json -Depth 4), (New-Object Text.UTF8Encoding($false)))
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Executable
    $psi.Arguments = $ArgumentString
    $psi.WorkingDirectory = $WorkingDirectory
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    if ([string]::IsNullOrEmpty($psi.Arguments) -or -not [string]::Equals($psi.Arguments, $ArgumentString, [StringComparison]::Ordinal)) { throw 'arguments not exact' }
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    $start = [DateTime]::UtcNow.ToString('o')
    [void]$process.Start()
    $stdoutMemory = New-Object IO.MemoryStream
    $stderrMemory = New-Object IO.MemoryStream
    $stdoutTask = $process.StandardOutput.BaseStream.CopyToAsync($stdoutMemory)
    $stderrTask = $process.StandardError.BaseStream.CopyToAsync($stderrMemory)
    $timedOut = -not $process.WaitForExit(60000)
    if ($timedOut) { $process.Kill(); $process.WaitForExit() }
    [Threading.Tasks.Task]::WaitAll([Threading.Tasks.Task[]]@($stdoutTask, $stderrTask))
    $stdoutBytes = $stdoutMemory.ToArray()
    $stderrBytes = $stderrMemory.ToArray()
    [IO.File]::WriteAllBytes((Join-Path $AttemptDirectory 'stdout.bin'), $stdoutBytes)
    [IO.File]::WriteAllBytes((Join-Path $AttemptDirectory 'stderr.bin'), $stderrBytes)
    $result = [ordered]@{ mode = $AttemptMode; pid = $process.Id; started_utc = $start; ended_utc = [DateTime]::UtcNow.ToString('o'); timed_out = $timedOut; exit_code = $process.ExitCode; stdout_bytes = $stdoutBytes.Length; stderr_bytes = $stderrBytes.Length; stdout_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $AttemptDirectory 'stdout.bin')).Hash.ToLowerInvariant(); stderr_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $AttemptDirectory 'stderr.bin')).Hash.ToLowerInvariant() }
    $temp = Join-Path $AttemptDirectory 'result.tmp'
    [IO.File]::WriteAllText($temp, ($result | ConvertTo-Json -Depth 4), (New-Object Text.UTF8Encoding($false)))
    Move-Item -LiteralPath $temp -Destination (Join-Path $AttemptDirectory 'result.json')
    $result | ConvertTo-Json -Depth 4
}

if ((Get-Item -LiteralPath $console).Length -ne 198152) { throw 'console size mismatch' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $console).Hash -ne 'D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C') { throw 'console hash mismatch' }

switch ($Mode) {
    'QUALIFY_STREAMS' { Invoke-CapturedChild -Executable $powerShell -ArgumentString $streamCommand -WorkingDirectory $project -AttemptDirectory (Join-Path $PSScriptRoot 'qualify-streams-001') -AttemptMode $Mode }
    'QUALIFY_EMPTY' { Invoke-CapturedChild -Executable $powerShell -ArgumentString $emptyCommand -WorkingDirectory $project -AttemptDirectory (Join-Path $PSScriptRoot 'qualify-empty-001') -AttemptMode $Mode }
    'QUALIFY_GODOT_VERSION' { Invoke-CapturedChild -Executable $console -ArgumentString '--version' -WorkingDirectory $project -AttemptDirectory (Join-Path $PSScriptRoot 'qualify-version-001') -AttemptMode $Mode }
    'PARSER' { Invoke-CapturedChild -Executable $console -ArgumentString '--headless --path . --check-only --script res://tests/run_slice2b_stageb_action_kernel_tests.gd' -WorkingDirectory $project -AttemptDirectory (Join-Path $PSScriptRoot 'parser-001') -AttemptMode $Mode }
    'FORMAL' { Invoke-CapturedChild -Executable $console -ArgumentString '--headless --path . --script res://tests/run_slice2b_stageb_action_kernel_tests.gd' -WorkingDirectory $project -AttemptDirectory (Join-Path $PSScriptRoot 'formal-001') -AttemptMode $Mode }
}
