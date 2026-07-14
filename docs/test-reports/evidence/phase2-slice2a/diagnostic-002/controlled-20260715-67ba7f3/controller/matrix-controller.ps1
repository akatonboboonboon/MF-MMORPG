param(
    [Parameter(Mandatory = $true)][string]$RepoRoot,
    [Parameter(Mandatory = $true)][string]$SessionRoot,
    [Parameter(Mandatory = $true)][string]$AcknowledgedLocal
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false)
$requiredPowerGuid = 'ded574b5-45a0-4f42-8737-46345c09c238'
$supervisorSha = '67ba7f34b6e0ee93ca454a6da8d354b0c2e79ebc'
$logicalProcessors = [Environment]::ProcessorCount
$acknowledgedAt = [DateTimeOffset]::Parse($AcknowledgedLocal)
$absoluteDeadline = $acknowledgedAt.AddMinutes(10)

function Write-Utf8 {
    param([string]$Path, [string]$Content)
    [IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Write-Json {
    param([string]$Path, $Value, [int]$Depth = 20)
    Write-Utf8 -Path $Path -Content (($Value | ConvertTo-Json -Depth $Depth) + "`n")
}

function Utc-Now { return [DateTimeOffset]::UtcNow }
function Deadline-RemainingSeconds { return ($absoluteDeadline - [DateTimeOffset]::Now).TotalSeconds }

if (-not ('MfoControlledNative' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class MfoControlledNative
{
    [StructLayout(LayoutKind.Sequential)]
    public struct FILETIME { public uint Low; public uint High; }

    [StructLayout(LayoutKind.Sequential)]
    public struct LASTINPUTINFO { public uint cbSize; public uint dwTime; }

    [DllImport("powrprof.dll")]
    public static extern uint PowerGetUserConfiguredACPowerMode(out Guid PowerModeGuid);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool GetSystemTimes(out FILETIME Idle, out FILETIME Kernel, out FILETIME User);

    [DllImport("user32.dll")]
    public static extern bool GetLastInputInfo(ref LASTINPUTINFO LastInputInfo);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr Window, out uint ProcessId);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr Window);

    [DllImport("user32.dll")]
    public static extern bool IsWindow(IntPtr Window);
}
'@
}

Add-Type -AssemblyName System.Windows.Forms

function Convert-FileTimeValue {
    param($Value)
    return ([uint64]$Value.High -shl 32) -bor [uint64]$Value.Low
}

function Get-SystemTimesSnapshot {
    $idle = New-Object MfoControlledNative+FILETIME
    $kernel = New-Object MfoControlledNative+FILETIME
    $user = New-Object MfoControlledNative+FILETIME
    if (-not [MfoControlledNative]::GetSystemTimes([ref]$idle, [ref]$kernel, [ref]$user)) {
        throw 'GetSystemTimes failed.'
    }
    return [pscustomobject]@{
        idle = Convert-FileTimeValue $idle
        kernel = Convert-FileTimeValue $kernel
        user = Convert-FileTimeValue $user
    }
}

function Get-SystemCpuPercent {
    param($Previous, $Current)
    $idleDelta = [double]($Current.idle - $Previous.idle)
    $kernelDelta = [double]($Current.kernel - $Previous.kernel)
    $userDelta = [double]($Current.user - $Previous.user)
    $total = $kernelDelta + $userDelta
    if ($idleDelta -lt 0 -or $kernelDelta -lt 0 -or $userDelta -lt 0 -or $total -le 0) { return $null }
    return [Math]::Max(0.0, [Math]::Min(100.0, (($total - $idleDelta) / $total) * 100.0))
}

function Get-LastInputTick {
    $info = New-Object MfoControlledNative+LASTINPUTINFO
    $info.cbSize = [Runtime.InteropServices.Marshal]::SizeOf($info)
    if (-not [MfoControlledNative]::GetLastInputInfo([ref]$info)) { return $null }
    return [uint32]$info.dwTime
}

function Get-ForegroundPid {
    $handle = [MfoControlledNative]::GetForegroundWindow()
    $pidValue = [uint32]0
    if ($handle -ne [IntPtr]::Zero) {
        [void][MfoControlledNative]::GetWindowThreadProcessId($handle, [ref]$pidValue)
    }
    return [pscustomobject]@{ hwnd = ('0x{0:X}' -f $handle.ToInt64()); pid = [int]$pidValue }
}

function Get-PowerSnapshot {
    $guid = [Guid]::Empty
    $rc = [MfoControlledNative]::PowerGetUserConfiguredACPowerMode([ref]$guid)
    $power = [Windows.Forms.SystemInformation]::PowerStatus
    return [pscustomobject]@{
        captured_at_utc = (Utc-Now).ToString('o')
        power_line_status = $power.PowerLineStatus.ToString()
        ac_mode_get_rc = [int]$rc
        ac_mode_guid = $guid.ToString()
        valid = ($power.PowerLineStatus.ToString() -eq 'Online' -and $rc -eq 0 -and $guid.ToString() -eq $requiredPowerGuid)
    }
}

function Get-Magic {
    param([string]$Path)
    $stream = [IO.File]::OpenRead($Path)
    try {
        $buffer = New-Object byte[] 2
        [void]$stream.Read($buffer, 0, 2)
        return ('{0:X2}{1:X2}' -f $buffer[0], $buffer[1])
    } finally { $stream.Dispose() }
}

function Get-CpuMap {
    param([scriptblock]$Predicate)
    $map = @{}
    foreach ($process in @(Get-Process -ErrorAction SilentlyContinue)) {
        try {
            if (& $Predicate $process) { $map[[string]$process.Id] = [double]$process.CPU }
        } catch {}
    }
    return $map
}

function Get-MapDelta {
    param($Previous, $Current)
    $delta = 0.0
    foreach ($key in $Current.Keys) {
        if ($Previous.ContainsKey($key)) {
            $part = [double]$Current[$key] - [double]$Previous[$key]
            if ($part -lt 0) { return $null }
            $delta += $part
        }
    }
    return $delta
}

function Assert-NoOwnedRuntime {
    $found = @()
    foreach ($process in @(Get-Process -ErrorAction SilentlyContinue)) {
        try {
            if ($process.ProcessName -eq 'MFO-Phase1' -or $process.ProcessName -like 'Godot*') {
                $found += [pscustomobject]@{ name = $process.ProcessName; pid = $process.Id; path = $process.Path }
            }
        } catch {}
    }
    if ($found.Count -gt 0) { throw ('Owned runtime remains: ' + ($found | ConvertTo-Json -Compress)) }
}

[IO.Directory]::CreateDirectory($SessionRoot) | Out-Null
$sessionRootFull = [IO.Path]::GetFullPath($SessionRoot)
$repoRootFull = [IO.Path]::GetFullPath($RepoRoot)
if ($sessionRootFull.StartsWith($repoRootFull, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Timed staging path is inside the repository/OneDrive workspace.'
}
$probe = Join-Path $SessionRoot 'write-probe.tmp'
Write-Utf8 -Path $probe -Content 'writable'
[IO.File]::Delete($probe)

$exeRoot = Join-Path $SessionRoot 'executables'
[IO.Directory]::CreateDirectory($exeRoot) | Out-Null
$sources = @(
    [pscustomobject]@{ variant = 'A'; commit = 'a13505e8fbf82962e049b9101a87593a6692d2c7'; source = (Join-Path $RepoRoot 'material-frontier-online\deliverables\phase1\MFO-Phase1-Windows-x86_64\MFO-Phase1.exe'); expected = '13fb5d904465d91383cc640e599f082ac4a0a1eb71c30585cbf733686daad199' },
    [pscustomobject]@{ variant = 'B'; commit = '295549373fbb3b39deb6079172783ce62c7da532'; source = (Join-Path $RepoRoot 'material-frontier-online\.build\diagnostic-001\worktree-b\material-frontier-online\prototype\build\windows\MFO-Phase1.exe'); expected = '3c15c254fbb8025d88c5636f2175a35f6e325b5368c8098e78b16181090dd4ef' },
    [pscustomobject]@{ variant = 'C'; commit = '5261a73707daca03cb160e03a12247886d3f5cce'; source = (Join-Path $RepoRoot 'material-frontier-online\.build\diagnostic-001\worktree-c\material-frontier-online\prototype\build\windows\MFO-Phase1.exe'); expected = '308c17594e204137cfb10fb47ca1cab03981e9b685df4732e7a6a4d0cec53e47' }
)
$executables = @{}
$exeEvidence = @()
foreach ($source in $sources) {
    if (-not (Test-Path -LiteralPath $source.source)) { throw "Missing source executable $($source.variant): $($source.source)" }
    $destination = Join-Path $exeRoot ("MFO-$($source.variant).exe")
    Copy-Item -LiteralPath $source.source -Destination $destination
    $sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $source.source).Hash.ToLowerInvariant()
    $destinationHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $destination).Hash.ToLowerInvariant()
    $sourceMagic = Get-Magic -Path $source.source
    $destinationMagic = Get-Magic -Path $destination
    if ($sourceHash -ne $source.expected -or $destinationHash -ne $source.expected -or $sourceMagic -ne '4D5A' -or $destinationMagic -ne '4D5A') {
        throw "Executable identity failed for $($source.variant)."
    }
    $executables[$source.variant] = $destination
    $exeEvidence += [pscustomobject]@{
        variant = $source.variant; source_commit = $source.commit
        source_path = $source.source; destination_path = $destination
        source_size_bytes = (Get-Item -LiteralPath $source.source).Length
        destination_size_bytes = (Get-Item -LiteralPath $destination).Length
        expected_sha256 = $source.expected; source_sha256 = $sourceHash; destination_sha256 = $destinationHash
        source_magic = $sourceMagic; destination_magic = $destinationMagic; identity_match = $true
    }
}

$controllerPath = $MyInvocation.MyCommand.Path
$controllerHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $controllerPath).Hash.ToLowerInvariant()
$environment = [ordered]@{
    schema = 'mfo.phase2.slice2a.controlled-rerun.environment.v1'
    work_order = 'MFO-WO-P2-2A-004'
    supervisor_order_sha = $supervisorSha
    qa_branch = 'codex/phase2-slice2a-controlled-rerun-qa'
    acknowledged_local = $acknowledgedAt.ToString('o')
    absolute_deadline_local = $absoluteDeadline.ToString('o')
    collected_at_utc = (Utc-Now).ToString('o')
    repo_root = $repoRootFull; staging_root = $sessionRootFull; paths_distinct = $true; staging_writable = $true
    controller_path = $controllerPath; controller_sha256 = $controllerHash
    invocation = $MyInvocation.Line
    logical_processors = $logicalProcessors
    os = [Environment]::OSVersion.VersionString
    cpu = $env:PROCESSOR_IDENTIFIER
    gpu = @(Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Video\*\0000' -ErrorAction SilentlyContinue | Where-Object { $null -ne $_.DriverDesc } | Select-Object DriverDesc, DriverVersion, DriverDate)
    active_power_plan = ((& powercfg.exe /getactivescheme 2>&1 | Out-String).Trim())
    executables = $exeEvidence
}
Write-Json -Path (Join-Path $SessionRoot 'environment.json') -Value $environment

Assert-NoOwnedRuntime

$preflightAttempts = @()
$preflightPassed = $false
$inputBaseline = $null
for ($attempt = 1; $attempt -le 3 -and -not $preflightPassed; $attempt++) {
    if ((Deadline-RemainingSeconds) -lt 180) { break }
    $samples = @()
    $previousSystem = Get-SystemTimesSnapshot
    $previousOd = Get-CpuMap { param($p) $p.ProcessName -like 'OneDrive*' }
    $initialInput = Get-LastInputTick
    $samples += [pscustomobject]@{ index = 0; captured_at_utc = (Utc-Now).ToString('o'); system_cpu_percent = $null; onedrive_cpu_delta_seconds = 0.0; last_input_tick = $initialInput; foreground = Get-ForegroundPid; power = Get-PowerSnapshot }
    for ($i = 1; $i -le 15; $i++) {
        Start-Sleep -Milliseconds 1000
        $currentSystem = Get-SystemTimesSnapshot
        $systemCpu = Get-SystemCpuPercent -Previous $previousSystem -Current $currentSystem
        $previousSystem = $currentSystem
        $currentOd = Get-CpuMap { param($p) $p.ProcessName -like 'OneDrive*' }
        $odDelta = Get-MapDelta -Previous $previousOd -Current $currentOd
        $previousOd = $currentOd
        $samples += [pscustomobject]@{ index = $i; captured_at_utc = (Utc-Now).ToString('o'); system_cpu_percent = $systemCpu; onedrive_cpu_delta_seconds = $odDelta; last_input_tick = Get-LastInputTick; foreground = Get-ForegroundPid; power = Get-PowerSnapshot }
    }
    $cpuValues = @($samples | Where-Object { $null -ne $_.system_cpu_percent } | ForEach-Object { [double]$_.system_cpu_percent })
    $odValues = @($samples | Where-Object { $null -ne $_.onedrive_cpu_delta_seconds } | ForEach-Object { [double]$_.onedrive_cpu_delta_seconds })
    $lastTenTicks = @($samples | Select-Object -Last 11 | ForEach-Object { $_.last_input_tick } | Sort-Object -Unique)
    $ownedRuntime = @()
    foreach ($process in @(Get-Process -ErrorAction SilentlyContinue)) {
        try { if ($process.ProcessName -eq 'MFO-Phase1' -or $process.ProcessName -like 'Godot*') { $ownedRuntime += [pscustomobject]@{ name=$process.ProcessName; pid=$process.Id; path=$process.Path } } } catch {}
    }
    $apiOk = ($null -ne (Get-LastInputTick) -and $null -ne (Get-ForegroundPid) -and $null -ne (Get-SystemTimesSnapshot))
    $powerOk = (@($samples | Where-Object { -not $_.power.valid }).Count -eq 0)
    $cpuAverage = $(if ($cpuValues.Count -gt 0) { ($cpuValues | Measure-Object -Average).Average } else { $null })
    $cpuMaximum = $(if ($cpuValues.Count -gt 0) { ($cpuValues | Measure-Object -Maximum).Maximum } else { $null })
    $odTotal = $(if ($odValues.Count -gt 0) { ($odValues | Measure-Object -Sum).Sum } else { $null })
    $checks = [ordered]@{
        power = $powerOk
        executable_identity = (@($exeEvidence | Where-Object { -not $_.identity_match }).Count -eq 0)
        no_owned_runtime = ($ownedRuntime.Count -eq 0)
        final_10_seconds_input_unchanged = ($lastTenTicks.Count -eq 1 -and $null -ne $lastTenTicks[0])
        onedrive_cpu_delta_le_0_25 = ($null -ne $odTotal -and $odTotal -le 0.25)
        system_cpu_average_le_20 = ($null -ne $cpuAverage -and $cpuAverage -le 20.0)
        system_cpu_sample_max_le_40 = ($null -ne $cpuMaximum -and $cpuMaximum -le 40.0)
        apis_loaded = $apiOk
        staging_writable_and_distinct = $true
    }
    $pass = (@($checks.Values | Where-Object { -not $_ }).Count -eq 0)
    $record = [ordered]@{ schema='mfo.phase2.slice2a.controlled-rerun.preflight.v1'; attempt=$attempt; started_after_ack=$true; samples=$samples; system_cpu_average_percent=$cpuAverage; system_cpu_maximum_percent=$cpuMaximum; onedrive_cpu_delta_seconds=$odTotal; last_10_seconds_unique_input_ticks=$lastTenTicks; owned_runtime=$ownedRuntime; checks=$checks; result=$(if($pass){'Pass'}else{'Fail'}) }
    Write-Json -Path (Join-Path $SessionRoot ("preflight-$attempt.json")) -Value $record
    $preflightAttempts += [pscustomobject]@{ attempt=$attempt; result=$record.result; system_cpu_average_percent=$cpuAverage; system_cpu_maximum_percent=$cpuMaximum; onedrive_cpu_delta_seconds=$odTotal; input_ticks=$lastTenTicks; checks=$checks }
    if ($pass) { $preflightPassed = $true; $inputBaseline = [uint32]$lastTenTicks[0]; break }
}

$sessionStatus = 'Blocked'
$terminalReason = $null
$runResults = @()
$segmentResults = @()
$monitorSamples = @()
$definitions = @(
    [pscustomobject]@{ label='A1'; variant='A'; commit='a13505e8fbf82962e049b9101a87593a6692d2c7' },
    [pscustomobject]@{ label='B1'; variant='B'; commit='295549373fbb3b39deb6079172783ce62c7da532' },
    [pscustomobject]@{ label='C1'; variant='C'; commit='5261a73707daca03cb160e03a12247886d3f5cce' },
    [pscustomobject]@{ label='C2'; variant='C'; commit='5261a73707daca03cb160e03a12247886d3f5cce' },
    [pscustomobject]@{ label='B2'; variant='B'; commit='295549373fbb3b39deb6079172783ce62c7da532' },
    [pscustomobject]@{ label='A2'; variant='A'; commit='a13505e8fbf82962e049b9101a87593a6692d2c7' }
)

if (-not $preflightPassed) {
    $terminalReason = 'No preflight attempt passed or insufficient deadline remained.'
} else {
    $script:previousSystem = Get-SystemTimesSnapshot
    $script:previousAt = Utc-Now
    $script:previousControllerCpu = (Get-Process -Id $PID).CPU
    $script:previousOd = Get-CpuMap { param($p) $p.ProcessName -like 'OneDrive*' }
    $script:previousGameCpu = $null
    $script:lastMonitorAt = Utc-Now

    function Capture-MonitorSample {
        param([string]$Segment, [Diagnostics.Process]$GameProcess, [bool]$RequireForeground, [bool]$GameExpected)
        $now = Utc-Now
        $wall = ($now - $script:previousAt).TotalSeconds
        $currentSystem = Get-SystemTimesSnapshot
        $systemCpu = Get-SystemCpuPercent -Previous $script:previousSystem -Current $currentSystem
        $script:previousSystem = $currentSystem
        $controllerCpu = (Get-Process -Id $PID).CPU
        $controllerDelta = [double]$controllerCpu - [double]$script:previousControllerCpu
        $script:previousControllerCpu = $controllerCpu
        $currentOd = Get-CpuMap { param($p) $p.ProcessName -like 'OneDrive*' }
        $odDelta = Get-MapDelta -Previous $script:previousOd -Current $currentOd
        $script:previousOd = $currentOd
        $gameAlive = $false
        $gameCpuDelta = 0.0
        $gamePid = $null
        if ($null -ne $GameProcess) {
            $gamePid = $GameProcess.Id
            try { $GameProcess.Refresh(); $gameAlive = -not $GameProcess.HasExited } catch { $gameAlive = $false }
            if ($gameAlive) {
                $currentGameCpu = [double]$GameProcess.CPU
                if ($null -ne $script:previousGameCpu) { $gameCpuDelta = $currentGameCpu - [double]$script:previousGameCpu }
                $script:previousGameCpu = $currentGameCpu
            }
        } else { $script:previousGameCpu = $null }
        $gamePct = $(if ($wall -gt 0 -and $gameCpuDelta -ge 0) { [Math]::Max(0.0,[Math]::Min(100.0,100.0*$gameCpuDelta/($wall*$logicalProcessors))) } else { $null })
        $backgroundPct = $(if ($null -ne $systemCpu -and $null -ne $gamePct) { [Math]::Max(0.0,[Math]::Min(100.0,[double]$systemCpu-[double]$gamePct)) } else { $null })
        $foreground = Get-ForegroundPid
        $power = Get-PowerSnapshot
        $inputTick = Get-LastInputTick
        $valid = ($wall -gt 0 -and $null -ne $systemCpu -and $controllerDelta -ge 0 -and $null -ne $odDelta -and $null -ne $gamePct -and $null -ne $backgroundPct -and $inputTick -eq $inputBaseline -and $power.valid)
        if ($GameExpected -and -not $gameAlive) { $valid = $false }
        if ($RequireForeground -and $foreground.pid -ne $gamePid) { $valid = $false }
        $sample = [pscustomobject]@{
            segment=$Segment; captured_at_utc=$now.ToString('o'); wall_seconds=$wall; logical_processors=$logicalProcessors
            system_cpu_percent=$systemCpu; game_cpu_delta_seconds=$gameCpuDelta; game_process_percent=$gamePct
            controller_cpu_delta_seconds=$controllerDelta; onedrive_cpu_delta_seconds=$odDelta; background_percent=$backgroundPct
            last_input_tick=$inputTick; input_matches_baseline=($inputTick -eq $inputBaseline); foreground=$foreground
            game_pid=$gamePid; game_alive=$gameAlive; require_foreground=$RequireForeground; power=$power; sample_valid=$valid
        }
        $script:monitorSamples += $sample
        $script:previousAt = $now
        $script:lastMonitorAt = $now
        return $sample
    }

    function Complete-Segment {
        param([string]$Name, [int]$StartIndex)
        $items = @($script:monitorSamples | Select-Object -Skip $StartIndex)
        $background = @($items | ForEach-Object { $_.background_percent })
        $od = @($items | ForEach-Object { $_.onedrive_cpu_delta_seconds })
        $avg = $(if($background.Count -gt 0){($background|Measure-Object -Average).Average}else{$null})
        $max = $(if($background.Count -gt 0){($background|Measure-Object -Maximum).Maximum}else{$null})
        $odTotal = $(if($od.Count -gt 0){($od|Measure-Object -Sum).Sum}else{$null})
        $valid = ($items.Count -gt 0 -and @($items|Where-Object{-not $_.sample_valid}).Count -eq 0 -and $null -ne $avg -and $avg -le 20.0 -and $null -ne $max -and $max -le 40.0 -and $null -ne $odTotal -and $odTotal -le 0.25)
        $result=[pscustomobject]@{ name=$Name; sample_count=$items.Count; background_average_percent=$avg; background_maximum_percent=$max; onedrive_cpu_delta_seconds=$odTotal; valid=$valid }
        $script:segmentResults += $result
        return $result
    }

    function Run-Idle {
        param([string]$Name)
        $startIndex=$script:monitorSamples.Count
        $until=(Utc-Now).AddSeconds(5)
        while((Utc-Now) -lt $until){
            if((Deadline-RemainingSeconds) -le 0){throw 'Absolute deadline expired during idle.'}
            $remaining=($script:lastMonitorAt.AddSeconds(1)-(Utc-Now)).TotalMilliseconds
            if($remaining -gt 0){Start-Sleep -Milliseconds ([Math]::Min(200,[int][Math]::Ceiling($remaining)))}
            if(((Utc-Now)-$script:lastMonitorAt).TotalMilliseconds -ge 950){[void](Capture-MonitorSample -Segment $Name -GameProcess $null -RequireForeground $false -GameExpected $false)}
        }
        $segment=Complete-Segment -Name $Name -StartIndex $startIndex
        if(-not $segment.valid){throw "Integrity failure in $Name idle."}
    }

    function Run-Slot {
        param($Definition)
        if((Deadline-RemainingSeconds) -lt 65){throw "Insufficient deadline before $($Definition.label)."}
        Assert-NoOwnedRuntime
        $slotRoot=Join-Path $SessionRoot ("matrix\"+$Definition.label.ToLowerInvariant())
        [IO.Directory]::CreateDirectory($slotRoot)|Out-Null
        $exe=$executables[$Definition.variant]
        $report=Join-Path $slotRoot 'performance.json'
        $capture=Join-Path $slotRoot 'capture.png'
        $godotLog=Join-Path $slotRoot 'godot.log'
        $stdout=Join-Path $slotRoot 'stdout.log'
        $stderr=Join-Path $slotRoot 'stderr.log'
        $metadataPath=Join-Path $slotRoot 'run-metadata.json'
        $arguments='--log-file "{0}" -- --phase1-measure --phase1-report="{1}" --phase1-capture="{2}"' -f $godotLog,$report,$capture
        $command='"{0}" {1}' -f $exe,$arguments
        $psi=New-Object Diagnostics.ProcessStartInfo
        $psi.FileName=$exe; $psi.Arguments=$arguments; $psi.WorkingDirectory=(Split-Path -Parent $exe)
        $psi.UseShellExecute=$false; $psi.RedirectStandardOutput=$true; $psi.RedirectStandardError=$true; $psi.CreateNoWindow=$false
        $psi.StandardOutputEncoding=[Text.Encoding]::UTF8; $psi.StandardErrorEncoding=[Text.Encoding]::UTF8
        $process=New-Object Diagnostics.Process; $process.StartInfo=$psi
        $started=Utc-Now; $acquisition=@(); $startupAt=$null; $foregroundAt=$null; $normalBoundaryAt=$null; $timedOut=$false; $killed=$false; $exitCode=$null
        $slotStartIndex=$script:monitorSamples.Count
        try {
            if(-not $process.Start()){throw "Failed to start $($Definition.label)."}
            $stdoutTask=$process.StandardOutput.ReadToEndAsync(); $stderrTask=$process.StandardError.ReadToEndAsync()
            $script:previousGameCpu=0.0
            while($null -eq $foregroundAt){
                Start-Sleep -Milliseconds 100
                $now=Utc-Now; $process.Refresh()
                if($process.HasExited){throw "Process exited during acquisition for $($Definition.label)."}
                $logText=$(if(Test-Path -LiteralPath $godotLog){Get-Content -Raw -LiteralPath $godotLog -ErrorAction SilentlyContinue}else{''})
                if($null -eq $startupAt -and $logText -match '\[MFO-P1-MEASURE\] scenario=arena warmup=120 sample=600'){ $startupAt=$now }
                $handle=$process.MainWindowHandle
                $before=Get-ForegroundPid; $setResult=$null
                if($handle -ne [IntPtr]::Zero -and $before.pid -ne $process.Id){$setResult=[MfoControlledNative]::SetForegroundWindow($handle)}
                $after=Get-ForegroundPid
                if($null -ne $startupAt -and $after.pid -eq $process.Id){$foregroundAt=$now}
                $acquisition += [pscustomobject]@{captured_at_utc=$now.ToString('o'); startup_seen=($null-ne $startupAt); hwnd=('0x{0:X}' -f $handle.ToInt64()); foreground_before=$before; set_foreground_result=$setResult; foreground_after=$after; last_input_tick=Get-LastInputTick; power=Get-PowerSnapshot}
                if($null -ne $startupAt -and ($now-$startupAt).TotalMilliseconds -gt 1000 -and $null -eq $foregroundAt){throw "Foreground not acquired within 1000 ms after startup for $($Definition.label)."}
                if(($now-$started).TotalSeconds -gt 60){throw "60-second timeout during acquisition for $($Definition.label)."}
                if((Deadline-RemainingSeconds) -le 0){throw 'Absolute deadline expired during acquisition.'}
                if(($now-$script:lastMonitorAt).TotalMilliseconds -ge 950){[void](Capture-MonitorSample -Segment $Definition.label -GameProcess $process -RequireForeground $false -GameExpected $true)}
            }
            if(@($acquisition|Where-Object{$_.last_input_tick -ne $inputBaseline -or -not $_.power.valid}).Count -gt 0){throw "Input or power changed during acquisition for $($Definition.label)."}
            while(-not $process.HasExited){
                Start-Sleep -Milliseconds 100
                $now=Utc-Now
                if($null -eq $normalBoundaryAt -and (Test-Path -LiteralPath $report) -and (Test-Path -LiteralPath $capture)){$normalBoundaryAt=$now}
                if(($now-$script:lastMonitorAt).TotalMilliseconds -ge 950){[void](Capture-MonitorSample -Segment $Definition.label -GameProcess $process -RequireForeground ($null-eq $normalBoundaryAt) -GameExpected ($null-eq $normalBoundaryAt))}
                if(($now-$started).TotalSeconds -gt 60){$timedOut=$true; throw "60-second timeout for $($Definition.label)."}
                if((Deadline-RemainingSeconds) -le 0){throw 'Absolute deadline expired during slot.'}
            }
            $process.WaitForExit()
            if($null -eq $normalBoundaryAt -and (Test-Path -LiteralPath $report) -and (Test-Path -LiteralPath $capture)){$normalBoundaryAt=Utc-Now}
            $exitCode=$process.ExitCode
            Write-Utf8 -Path $stdout -Content $stdoutTask.Result; Write-Utf8 -Path $stderr -Content $stderrTask.Result
        } catch {
            if($null -ne $process -and -not $process.HasExited){try{$process.Kill();$killed=$true;$process.WaitForExit()}catch{}}
            try{if($null-ne $stdoutTask){Write-Utf8 -Path $stdout -Content $stdoutTask.Result}}catch{}
            try{if($null-ne $stderrTask){Write-Utf8 -Path $stderr -Content $stderrTask.Result}}catch{}
            throw
        } finally {
            $ended=Utc-Now
            $segment=Complete-Segment -Name $Definition.label -StartIndex $slotStartIndex
            $metadata=[ordered]@{schema='mfo.phase2.slice2a.controlled-rerun.slot.v1';work_order='MFO-WO-P2-2A-004';label=$Definition.label;variant=$Definition.variant;source_commit=$Definition.commit;command=$command;pid=$(if($null-ne $process){$process.Id}else{$null});started_utc=$started.ToString('o');ended_utc=$ended.ToString('o');duration_seconds=($ended-$started).TotalSeconds;startup_seen_utc=$(if($null-ne $startupAt){$startupAt.ToString('o')}else{$null});foreground_acquired_utc=$(if($null-ne $foregroundAt){$foregroundAt.ToString('o')}else{$null});foreground_acquisition_ms=$(if($null-ne $foregroundAt-and$null-ne $startupAt){($foregroundAt-$startupAt).TotalMilliseconds}else{$null});normal_output_boundary_utc=$(if($null-ne $normalBoundaryAt){$normalBoundaryAt.ToString('o')}else{$null});exit_code=$exitCode;timed_out=$timedOut;killed=$killed;acquisition_polls=$acquisition;segment=$segment;report_exists=(Test-Path -LiteralPath $report);capture_exists=(Test-Path -LiteralPath $capture);godot_log_exists=(Test-Path -LiteralPath $godotLog)}
            Write-Json -Path $metadataPath -Value $metadata
        }
        if($exitCode -ne 0 -or $null-eq $normalBoundaryAt -or -not $segment.valid){throw "Completed-slot integrity failed for $($Definition.label)."}
        $json=Get-Content -Raw -LiteralPath $report|ConvertFrom-Json
        $semanticOk=($json.schema -eq 'mfo.phase1.performance.v1' -and $json.scenario -eq 'arena' -and [int]$json.warmup_frames -eq 120 -and [int]$json.sample_frames -eq 600 -and $json.renderer -eq 'gl_compatibility' -and $json.window_size -eq '(1920, 1080)' -and $json.engine.hash -eq '5b4e0cb0fd279832bbdd69fed5354d4e5ad26f88')
        if(-not $semanticOk){throw "Recorder semantic validation failed for $($Definition.label)."}
        return [pscustomobject]@{label=$Definition.label;variant=$Definition.variant;source_commit=$Definition.commit;pid=$process.Id;exit_code=$exitCode;p50_ms=[double]$json.frame_ms.p50;p95_ms=[double]$json.frame_ms.p95;p99_ms=[double]$json.frame_ms.p99;maximum_ms=[double]$json.frame_ms.maximum;average_ms=[double]$json.frame_ms.average;fps_from_average=[double]$json.fps_from_average_frame;threshold_ms=16.67;threshold_result=$(if([double]$json.frame_ms.p95-le16.67){'Pass'}else{'Fail'});report_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $report).Hash.ToLowerInvariant();capture_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $capture).Hash.ToLowerInvariant();stdout_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $stdout).Hash.ToLowerInvariant();stderr_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $stderr).Hash.ToLowerInvariant();godot_log_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $godotLog).Hash.ToLowerInvariant();segment=$segment}
    }

    try {
        for($index=0;$index-lt$definitions.Count;$index++){
            Run-Idle -Name $(if($index-eq0){'pre-A1-idle'}else{"inter-$($definitions[$index-1].label)-$($definitions[$index].label)"})
            $result=Run-Slot -Definition $definitions[$index]
            $runResults += $result
            Write-Output ('RUN_COMPLETE '+($result|ConvertTo-Json -Compress -Depth 8))
        }
        $sessionStatus='Complete'
    } catch {
        $terminalReason=$_.Exception.Message
        $sessionStatus='Blocked'
    }
}

Write-Json -Path (Join-Path $SessionRoot 'continuous-monitor.json') -Value @($monitorSamples)
Write-Json -Path (Join-Path $SessionRoot 'segment-summary.json') -Value @($segmentResults)
$summary=[ordered]@{schema='mfo.phase2.slice2a.controlled-rerun.session.v1';work_order='MFO-WO-P2-2A-004';supervisor_order_sha=$supervisorSha;acknowledged_local=$acknowledgedAt.ToString('o');absolute_deadline_local=$absoluteDeadline.ToString('o');finished_local=[DateTimeOffset]::Now.ToString('o');preflight_passed=$preflightPassed;input_baseline=$inputBaseline;preflight_attempts=$preflightAttempts;required_order=@('A1','B1','C1','C2','B2','A2');actual_order=@($runResults|ForEach-Object{$_.label});run_results=$runResults;status=$sessionStatus;terminal_reason=$terminalReason;controller_sha256=$controllerHash;staging_root=$sessionRootFull}
Write-Json -Path (Join-Path $SessionRoot 'session-summary.json') -Value $summary
$summary|ConvertTo-Json -Depth 20
if($sessionStatus -ne 'Complete'){exit 2}
