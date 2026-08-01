$ErrorActionPreference = 'Stop'

$root = 'C:\tmp\q2b\docs\test-reports\evidence\phase2-slice2b\foundation-005'
$exe = 'C:\tmp\q2b\material-frontier-online\prototype\build\windows\MFO-Phase1.exe'
$arguments = '--headless --log-file C:\tmp\q2b\docs\test-reports\evidence\phase2-slice2b\foundation-005\exported-smoke.log --quit-after 5'
$stdoutPath = Join-Path $root 'exported-smoke.stdout.txt'
$stderrPath = Join-Path $root 'exported-smoke.stderr.txt'
$resultPath = Join-Path $root 'exported-smoke.result.json'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $exe
$startInfo.Arguments = $arguments
$startInfo.WorkingDirectory = 'C:\tmp\q2b\material-frontier-online\prototype'
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $startInfo
$startedAt = [DateTime]::UtcNow.ToString('o')
$started = $process.Start()
if (-not $started) {
    throw 'Process.Start returned false.'
}
$stdoutTask = $process.StandardOutput.ReadToEndAsync()
$stderrTask = $process.StandardError.ReadToEndAsync()
$waitSucceeded = $process.WaitForExit(120000)
$timedOut = -not $waitSucceeded
if ($timedOut) {
    $process.Kill()
    $process.WaitForExit()
}
$stdout = $stdoutTask.GetAwaiter().GetResult()
$stderr = $stderrTask.GetAwaiter().GetResult()
$endedAt = [DateTime]::UtcNow.ToString('o')
[System.IO.File]::WriteAllText($stdoutPath, $stdout, $utf8NoBom)
[System.IO.File]::WriteAllText($stderrPath, $stderr, $utf8NoBom)
$result = [ordered]@{
    schema = 'mfo.p2.2b.006.exported-smoke-result.v1'
    process_id = $process.Id
    started_at_utc = $startedAt
    ended_at_utc = $endedAt
    timeout = $timedOut
    numeric_exit_code = $process.ExitCode
    executable = $exe
    arguments = $arguments
    working_directory = $startInfo.WorkingDirectory
    stdout_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $stdoutPath).Hash.ToLowerInvariant()
    stderr_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $stderrPath).Hash.ToLowerInvariant()
}
[System.IO.File]::WriteAllText($resultPath, ($result | ConvertTo-Json -Depth 4), $utf8NoBom)
$result | ConvertTo-Json -Compress
exit $process.ExitCode
