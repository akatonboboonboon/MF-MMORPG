param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('DryRun', 'Run')]
    [string]$Mode,

    [Parameter(Mandatory = $true)]
    [string]$StagePath
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false)
$requiredPowerGuid = 'ded574b5-45a0-4f42-8737-46345c09c238'
$stopwatchFrequency = [double][Diagnostics.Stopwatch]::Frequency
$controllerSchema = 'mfo.phase2.slice2a.performance-only.controller.v1'
$manifestSchema = 'mfo.phase2.slice2a.performance-only.preparation-manifest.v1'
$runInvocationLocal = $null
$runInvocationStopwatchTick = $null
$runInvocationSystemTick = $null
if ($Mode -eq 'Run') {
    # This is the controller's first timed action and the only global-deadline origin.
    $runInvocationLocal = [DateTimeOffset]::Now
    $runInvocationStopwatchTick = [Diagnostics.Stopwatch]::GetTimestamp()
    $runInvocationSystemTick = [Environment]::TickCount64
}

if (-not ('MfoP005Native' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class MfoP005Native
{
    [StructLayout(LayoutKind.Sequential)]
    public struct FILETIME { public uint Low; public uint High; }

    [StructLayout(LayoutKind.Sequential)]
    public struct LASTINPUTINFO { public uint cbSize; public uint dwTime; }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
    public struct PROCESSENTRY32
    {
        public uint dwSize;
        public uint cntUsage;
        public uint th32ProcessID;
        public IntPtr th32DefaultHeapID;
        public uint th32ModuleID;
        public uint cntThreads;
        public uint th32ParentProcessID;
        public int pcPriClassBase;
        public uint dwFlags;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
        public string szExeFile;
    }

    [DllImport("powrprof.dll")]
    public static extern uint PowerGetUserConfiguredACPowerMode(out Guid PowerModeGuid);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool GetSystemTimes(out FILETIME Idle, out FILETIME Kernel, out FILETIME User);

    [DllImport("kernel32.dll")]
    public static extern ulong GetTickCount64();

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr CreateToolhelp32Snapshot(uint flags, uint processId);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern bool Process32First(IntPtr snapshot, ref PROCESSENTRY32 entry);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern bool Process32Next(IntPtr snapshot, ref PROCESSENTRY32 entry);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool CloseHandle(IntPtr handle);

    [DllImport("user32.dll")]
    public static extern bool GetLastInputInfo(ref LASTINPUTINFO LastInputInfo);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr Window, out uint ProcessId);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr Window);

    public static Dictionary<int, List<int>> ParentChildMap()
    {
        const uint TH32CS_SNAPPROCESS = 0x00000002;
        IntPtr snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
        if (snapshot == new IntPtr(-1)) throw new InvalidOperationException("CreateToolhelp32Snapshot failed.");
        try
        {
            var result = new Dictionary<int, List<int>>();
            PROCESSENTRY32 entry = new PROCESSENTRY32();
            entry.dwSize = (uint)Marshal.SizeOf(typeof(PROCESSENTRY32));
            if (!Process32First(snapshot, ref entry)) throw new InvalidOperationException("Process32First failed.");
            do
            {
                int parent = unchecked((int)entry.th32ParentProcessID);
                int child = unchecked((int)entry.th32ProcessID);
                if (!result.ContainsKey(parent)) result[parent] = new List<int>();
                result[parent].Add(child);
                entry.dwSize = (uint)Marshal.SizeOf(typeof(PROCESSENTRY32));
            }
            while (Process32Next(snapshot, ref entry));
            return result;
        }
        finally { CloseHandle(snapshot); }
    }
}
'@
}

Add-Type -AssemblyName System.Windows.Forms

function Write-Utf8 {
    param([string]$Path, [string]$Content)
    [IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Write-Json {
    param([string]$Path, $Value, [int]$Depth = 24)
    Write-Utf8 -Path $Path -Content (($Value | ConvertTo-Json -Depth $Depth) + "`n")
}

function Get-Sha256 {
    param([string]$Path)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
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

function Get-FileTimeValue {
    param($Value)
    return ([uint64]$Value.High -shl 32) -bor [uint64]$Value.Low
}

function Get-SystemSnapshot {
    $idle = New-Object MfoP005Native+FILETIME
    $kernel = New-Object MfoP005Native+FILETIME
    $user = New-Object MfoP005Native+FILETIME
    if (-not [MfoP005Native]::GetSystemTimes([ref]$idle, [ref]$kernel, [ref]$user)) {
        throw 'GetSystemTimes failed.'
    }
    return [pscustomobject]@{
        captured_at_utc = [DateTimeOffset]::UtcNow.ToString('o')
        monotonic_tick = [Diagnostics.Stopwatch]::GetTimestamp()
        idle = Get-FileTimeValue $idle
        kernel = Get-FileTimeValue $kernel
        user = Get-FileTimeValue $user
    }
}

function Get-SystemCpuInterval {
    param($Previous, $Current)
    $idleDelta = [double]([uint64]$Current.idle - [uint64]$Previous.idle)
    $kernelDelta = [double]([uint64]$Current.kernel - [uint64]$Previous.kernel)
    $userDelta = [double]([uint64]$Current.user - [uint64]$Previous.user)
    $total = $kernelDelta + $userDelta
    if ($idleDelta -lt 0 -or $kernelDelta -lt 0 -or $userDelta -lt 0 -or $total -le 0) { return $null }
    return [pscustomobject]@{
        idle_delta = $idleDelta
        kernel_delta = $kernelDelta
        user_delta = $userDelta
        total_delta = $total
        cpu_percent = [Math]::Max(0.0, [Math]::Min(100.0, (($total - $idleDelta) / $total) * 100.0))
        wall_seconds = ([double]$Current.monotonic_tick - [double]$Previous.monotonic_tick) / $stopwatchFrequency
    }
}

function Get-LastInputTick {
    $info = New-Object MfoP005Native+LASTINPUTINFO
    $info.cbSize = [Runtime.InteropServices.Marshal]::SizeOf($info)
    if (-not [MfoP005Native]::GetLastInputInfo([ref]$info)) { throw 'GetLastInputInfo failed.' }
    return [uint32]$info.dwTime
}

function Get-ForegroundSnapshot {
    $handle = [MfoP005Native]::GetForegroundWindow()
    $pidValue = [uint32]0
    if ($handle -ne [IntPtr]::Zero) {
        [void][MfoP005Native]::GetWindowThreadProcessId($handle, [ref]$pidValue)
    }
    return [pscustomobject]@{ hwnd = ('0x{0:X}' -f $handle.ToInt64()); pid = [int]$pidValue }
}

function Get-PowerSnapshot {
    $guid = [Guid]::Empty
    $rc = [MfoP005Native]::PowerGetUserConfiguredACPowerMode([ref]$guid)
    $power = [Windows.Forms.SystemInformation]::PowerStatus
    return [pscustomobject]@{
        captured_at_utc = [DateTimeOffset]::UtcNow.ToString('o')
        power_line_status = $power.PowerLineStatus.ToString()
        ac_mode_get_rc = [int]$rc
        ac_mode_guid = $guid.ToString()
        valid = ($power.PowerLineStatus.ToString() -eq 'Online' -and $rc -eq 0 -and $guid.ToString() -eq $requiredPowerGuid)
    }
}

function Get-ProcessIdentity {
    param([Diagnostics.Process]$Process)
    $Process.Refresh()
    return [pscustomobject]@{
        process_name = $Process.ProcessName
        pid = [int]$Process.Id
        creation_time_utc = $Process.StartTime.ToUniversalTime().ToString('o')
        image_path = [IO.Path]::GetFullPath($Process.Path)
    }
}

function Test-IdentityMatch {
    param($Actual, $Expected)
    if ($null -eq $Actual -or $null -eq $Expected) { return $false }
    return (
        [int]$Actual.pid -eq [int]$Expected.pid -and
        [string]$Actual.creation_time_utc -eq [string]$Expected.creation_time_utc -and
        [string]::Equals([string]$Actual.image_path, [string]$Expected.image_path, [StringComparison]::OrdinalIgnoreCase)
    )
}

function Get-OneDriveInventory {
    $all = @(Get-Process -ErrorAction Stop)
    $result = @()
    foreach ($process in $all) {
        if ($process.ProcessName -like 'OneDrive*') {
            $result += [pscustomobject]@{ process_name = $process.ProcessName; pid = [int]$process.Id }
        }
    }
    return @($result | Sort-Object process_name, pid)
}

function Get-OwnedRuntimeInventory {
    $all = @(Get-Process -ErrorAction Stop)
    $result = @()
    foreach ($process in $all) {
        if ($process.ProcessName -eq 'MFO-A' -or $process.ProcessName -eq 'MFO-B' -or
            $process.ProcessName -eq 'MFO-C' -or $process.ProcessName -eq 'MFO-Phase1' -or
            $process.ProcessName -like 'Godot*') {
            $result += Get-ProcessIdentity -Process $process
        }
    }
    return @($result | Sort-Object process_name, pid)
}

function Get-ChildProcessIds {
    param([int]$RootPid)
    $map = [MfoP005Native]::ParentChildMap()
    $result = New-Object Collections.Generic.List[int]
    $queue = New-Object Collections.Generic.Queue[int]
    $queue.Enqueue($RootPid)
    while ($queue.Count -gt 0) {
        $parent = $queue.Dequeue()
        if ($map.ContainsKey($parent)) {
            foreach ($child in $map[$parent]) {
                if (-not $result.Contains($child)) {
                    $result.Add($child)
                    $queue.Enqueue($child)
                }
            }
        }
    }
    return @($result)
}

function Stop-OwnedTree {
    param($RootIdentity, [int]$MaximumSeconds = 5)
    $started = [Diagnostics.Stopwatch]::StartNew()
    $records = @()
    $rootProcess = Get-Process -Id ([int]$RootIdentity.pid) -ErrorAction SilentlyContinue
    if ($null -eq $rootProcess) {
        return [pscustomobject]@{ attempted = $false; root_already_absent = $true; records = @(); elapsed_seconds = 0.0; residue = @() }
    }
    $currentRoot = Get-ProcessIdentity -Process $rootProcess
    if (-not (Test-IdentityMatch -Actual $currentRoot -Expected $RootIdentity)) {
        throw 'Refused cleanup because root PID identity no longer matches.'
    }
    $childIds = @(Get-ChildProcessIds -RootPid ([int]$RootIdentity.pid))
    foreach ($childId in @($childIds | Sort-Object -Descending)) {
        $child = Get-Process -Id $childId -ErrorAction SilentlyContinue
        if ($null -ne $child) {
            try {
                $identity = Get-ProcessIdentity -Process $child
                $child.Kill()
                $records += [pscustomobject]@{ identity = $identity; action = 'kill-owned-descendant'; result = 'requested' }
            } catch {
                $records += [pscustomobject]@{ pid = $childId; action = 'kill-owned-descendant'; result = 'error'; error = $_.Exception.Message }
            }
        }
    }
    try { $rootProcess.Kill(); $records += [pscustomobject]@{ identity = $currentRoot; action = 'kill-owned-root'; result = 'requested' } } catch {
        $records += [pscustomobject]@{ identity = $currentRoot; action = 'kill-owned-root'; result = 'error'; error = $_.Exception.Message }
    }
    while ($started.Elapsed.TotalSeconds -lt $MaximumSeconds) {
        $remaining = @()
        foreach ($pidValue in @($childIds + @([int]$RootIdentity.pid))) {
            if ($null -ne (Get-Process -Id $pidValue -ErrorAction SilentlyContinue)) { $remaining += $pidValue }
        }
        if ($remaining.Count -eq 0) { break }
        Start-Sleep -Milliseconds 100
    }
    $residue = @()
    foreach ($pidValue in @($childIds + @([int]$RootIdentity.pid))) {
        $process = Get-Process -Id $pidValue -ErrorAction SilentlyContinue
        if ($null -ne $process) { $residue += Get-ProcessIdentity -Process $process }
    }
    return [pscustomobject]@{
        attempted = $true
        root_already_absent = $false
        records = $records
        elapsed_seconds = $started.Elapsed.TotalSeconds
        residue = $residue
    }
}

function Assert-PathUnderStage {
    param([string]$Path, [string]$StageRoot)
    $full = [IO.Path]::GetFullPath($Path)
    $prefix = $StageRoot.TrimEnd('\') + '\'
    if (-not $full.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path is outside sealed stage: $full"
    }
    return $full
}

function Wait-UntilMonotonic {
    param([long]$TargetTick, [scriptblock]$DeadlineCheck)
    while ([Diagnostics.Stopwatch]::GetTimestamp() -lt $TargetTick) {
        if ($null -ne $DeadlineCheck) { & $DeadlineCheck }
        $remainingMs = 1000.0 * ([double]$TargetTick - [double][Diagnostics.Stopwatch]::GetTimestamp()) / $stopwatchFrequency
        if ($remainingMs -gt 0) { Start-Sleep -Milliseconds ([Math]::Max(1, [Math]::Min(100, [int][Math]::Ceiling($remainingMs)))) }
    }
}

function Get-PreparationManifest {
    param([string]$StageRoot)
    $manifestPath = Join-Path $StageRoot 'seal\preparation-manifest.json'
    $digestPath = Join-Path $StageRoot 'seal\preparation-manifest.sha256'
    if (-not (Test-Path -LiteralPath $manifestPath) -or -not (Test-Path -LiteralPath $digestPath)) {
        throw 'Sealed preparation manifest or digest is missing.'
    }
    $expectedDigest = (Get-Content -Raw -Encoding UTF8 -LiteralPath $digestPath).Trim().ToLowerInvariant()
    if ($expectedDigest -notmatch '^[0-9a-f]{64}$') { throw 'Manifest digest file is invalid.' }
    $actualDigest = Get-Sha256 -Path $manifestPath
    if ($actualDigest -ne $expectedDigest) { throw 'Manifest digest mismatch.' }
    $manifest = Get-Content -Raw -Encoding UTF8 -LiteralPath $manifestPath | ConvertFrom-Json
    if ($manifest.schema -ne $manifestSchema) { throw 'Manifest schema mismatch.' }
    return [pscustomobject]@{ path = $manifestPath; digest_path = $digestPath; sha256 = $actualDigest; value = $manifest }
}

function Assert-SealedIdentity {
    param($ManifestRecord, [string]$StageRoot, [string]$ControllerPath, [bool]$FullHash)
    $manifest = $ManifestRecord.value
    if (-not [string]::Equals([IO.Path]::GetFullPath($manifest.stage_path), $StageRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Manifest stage path mismatch.'
    }
    if ($manifest.work_order -ne 'MFO-WO-P2-2A-005') { throw 'Manifest work order mismatch.' }
    if ($manifest.controller.schema -ne $controllerSchema) { throw 'Controller schema mismatch.' }
    if (-not [string]::Equals([IO.Path]::GetFullPath($manifest.controller.path), $ControllerPath, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Controller path mismatch.'
    }
    $controllerItem = Get-Item -LiteralPath $ControllerPath
    if ($controllerItem.Length -ne [int64]$manifest.controller.size_bytes -or
        $controllerItem.LastWriteTimeUtc.Ticks -ne [int64]$manifest.controller.last_write_utc_ticks) {
        throw 'Controller identity mismatch.'
    }
    if ($FullHash -and (Get-Sha256 -Path $ControllerPath) -ne [string]$manifest.controller.sha256) { throw 'Controller full hash mismatch.' }
    foreach ($entry in @($manifest.executables)) {
        $path = Assert-PathUnderStage -Path ([string]$entry.staged_path) -StageRoot $StageRoot
        $item = Get-Item -LiteralPath $path
        if ($item.Length -ne [int64]$entry.size_bytes -or $item.LastWriteTimeUtc.Ticks -ne [int64]$entry.last_write_utc_ticks -or (Get-Magic -Path $path) -ne '4D5A') {
            throw "Timed identity mismatch for executable $($entry.variant)."
        }
        if ($FullHash -and (Get-Sha256 -Path $path) -ne [string]$entry.sha256) {
            throw "Full hash mismatch for executable $($entry.variant)."
        }
    }
    $requiredOrder = @('A1', 'B1', 'C1', 'C2', 'B2', 'A2')
    if ((@($manifest.matrix.order) -join ',') -ne ($requiredOrder -join ',')) { throw 'Matrix order mismatch.' }
    foreach ($slot in @($manifest.matrix.slots)) {
        [void](Assert-PathUnderStage -Path ([string]$slot.executable_path) -StageRoot $StageRoot)
        [void](Assert-PathUnderStage -Path ([string]$slot.working_directory) -StageRoot $StageRoot)
        [void](Assert-PathUnderStage -Path ([string]$slot.outputs.directory) -StageRoot $StageRoot)
        [void](Assert-PathUnderStage -Path ([string]$slot.outputs.godot_log) -StageRoot $StageRoot)
        [void](Assert-PathUnderStage -Path ([string]$slot.outputs.performance_json) -StageRoot $StageRoot)
        [void](Assert-PathUnderStage -Path ([string]$slot.outputs.capture_png) -StageRoot $StageRoot)
        [void](Assert-PathUnderStage -Path ([string]$slot.outputs.stdout_log) -StageRoot $StageRoot)
        [void](Assert-PathUnderStage -Path ([string]$slot.outputs.stderr_log) -StageRoot $StageRoot)
    }
    return $true
}

function Assert-PreparationProcessesExited {
    param($Manifest)
    foreach ($identity in @($Manifest.preparation_owned_processes)) {
        $process = Get-Process -Id ([int]$identity.pid) -ErrorAction SilentlyContinue
        if ($null -ne $process) {
            $actual = Get-ProcessIdentity -Process $process
            if (Test-IdentityMatch -Actual $actual -Expected $identity) {
                throw "Preparation process remains alive: $($identity.pid)"
            }
        }
    }
}

function Get-IntegrityInventory {
    param([string]$Phase, [uint32]$InputBaseline, [bool]$RequireBaseline)
    $oneDrive = @(Get-OneDriveInventory)
    $runtime = @(Get-OwnedRuntimeInventory)
    $inputTick = Get-LastInputTick
    $power = Get-PowerSnapshot
    return [pscustomobject]@{
        phase = $Phase
        captured_at_utc = [DateTimeOffset]::UtcNow.ToString('o')
        monotonic_tick = [Diagnostics.Stopwatch]::GetTimestamp()
        system_tick_count64 = [MfoP005Native]::GetTickCount64()
        onedrive = $oneDrive
        onedrive_count = $oneDrive.Count
        onedrive_cpu_delta_seconds = 0.0
        owned_runtime = $runtime
        owned_runtime_count = $runtime.Count
        last_input_tick = $inputTick
        input_matches_baseline = $(if ($RequireBaseline) { $inputTick -eq $InputBaseline } else { $true })
        power = $power
    }
}

function Assert-InventoryBase {
    param($Inventory, [bool]$RequireNoRuntime)
    if ($Inventory.onedrive_count -ne 0) { throw "OneDrive-family process present during $($Inventory.phase)." }
    if (-not $Inventory.input_matches_baseline) { throw "Input changed during $($Inventory.phase)." }
    if (-not $Inventory.power.valid) { throw "Power invalid during $($Inventory.phase)." }
    if ($RequireNoRuntime -and $Inventory.owned_runtime_count -ne 0) { throw "Owned runtime present during $($Inventory.phase)." }
}

function Get-ProcessCpuSeconds {
    param([Diagnostics.Process]$Process)
    $Process.Refresh()
    return [double]$Process.TotalProcessorTime.TotalSeconds
}

function New-SegmentSummary {
    param([string]$Name, $Samples)
    $items = @($Samples)
    $weighted = 0.0
    $wallTotal = 0.0
    $maximum = $null
    foreach ($sample in $items) {
        if ($null -eq $sample.background_percent -or $null -eq $sample.wall_seconds -or [double]$sample.wall_seconds -le 0) {
            return [pscustomobject]@{ name = $Name; valid = $false; reason = 'missing-or-noncomparable-sample'; sample_count = $items.Count }
        }
        $weighted += [double]$sample.background_percent * [double]$sample.wall_seconds
        $wallTotal += [double]$sample.wall_seconds
        if ($null -eq $maximum -or [double]$sample.background_percent -gt [double]$maximum) { $maximum = [double]$sample.background_percent }
    }
    $average = $(if ($wallTotal -gt 0) { $weighted / $wallTotal } else { $null })
    $valid = ($items.Count -gt 0 -and $null -ne $average -and $average -le 20.0 -and $maximum -le 40.0 -and @($items | Where-Object { -not $_.integrity_valid }).Count -eq 0)
    return [pscustomobject]@{
        name = $Name
        valid = $valid
        sample_count = $items.Count
        wall_seconds = $wallTotal
        background_weighted_average_percent = $average
        background_maximum_percent = $maximum
        onedrive_cpu_delta_seconds = 0.0
        thresholds = [pscustomobject]@{ average_maximum_percent = 20.0; sample_maximum_percent = 40.0; onedrive_cpu_seconds_maximum = 0.25 }
    }
}

$stageRoot = [IO.Path]::GetFullPath($StagePath).TrimEnd('\')
if (-not (Test-Path -LiteralPath $stageRoot -PathType Container)) { throw 'Stage path does not exist.' }
if ($stageRoot -match '(?i)\\OneDrive(\\|$)') { throw 'Stage path is inside OneDrive.' }
$stageId = Split-Path -Leaf $stageRoot
$controllerPath = [IO.Path]::GetFullPath($MyInvocation.MyCommand.Path)
if (-not $controllerPath.StartsWith($stageRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Controller is not running from the sealed stage.' }
$selfProcess = Get-Process -Id $PID
$selfIdentity = Get-ProcessIdentity -Process $selfProcess
$controllerHash = Get-Sha256 -Path $controllerPath
$mutexName = 'Local\MFO_P2_2A_005_' + ($stageId -replace '[^A-Za-z0-9_\-]', '_')
$controlRoot = Join-Path $stageRoot 'control'
[IO.Directory]::CreateDirectory($controlRoot) | Out-Null
$lockPath = Join-Path $controlRoot 'controller.lock'
$mutex = $null
$ownsMutex = $false
$lockStream = $null
$resultExit = 2

try {
    $createdNew = $false
    $mutex = [Threading.Mutex]::new($false, $mutexName, [ref]$createdNew)
    $ownsMutex = $mutex.WaitOne(0)
    if (-not $ownsMutex) { throw 'Controller mutex is already owned.' }
    if (Test-Path -LiteralPath $lockPath) { throw 'Controller lock file already exists.' }
    $lockStream = [IO.File]::Open($lockPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
    $lockBytes = $utf8.GetBytes((([ordered]@{ stage_id = $stageId; mode = $Mode; self = $selfIdentity; controller_sha256 = $controllerHash; created_at_utc = [DateTimeOffset]::UtcNow.ToString('o') } | ConvertTo-Json -Depth 8) + "`n"))
    $lockStream.Write($lockBytes, 0, $lockBytes.Length)
    $lockStream.Flush()

    $manifestPath = Join-Path $stageRoot 'seal\preparation-manifest.json'
    $digestPath = Join-Path $stageRoot 'seal\preparation-manifest.sha256'
    if ($Mode -eq 'DryRun' -and (-not (Test-Path -LiteralPath $manifestPath) -or -not (Test-Path -LiteralPath $digestPath))) {
        $selfRecord = [ordered]@{
            schema = 'mfo.phase2.slice2a.performance-only.dry-run-self.v1'
            stage_id = $stageId
            mode = $Mode
            controller_path = $controllerPath
            controller_sha256 = $controllerHash
            mutex_name = $mutexName
            lock_path = $lockPath
            self = $selfIdentity
            recorded_at_utc = [DateTimeOffset]::UtcNow.ToString('o')
        }
        Write-Json -Path (Join-Path $controlRoot 'dry-run-self.json') -Value $selfRecord
        $goPath = Join-Path $controlRoot 'dry-run-go.signal'
        $waitUntil = [DateTimeOffset]::UtcNow.AddSeconds(45)
        while (-not (Test-Path -LiteralPath $goPath)) {
            if ([DateTimeOffset]::UtcNow -ge $waitUntil) { throw 'Timed out waiting for dry-run seal signal.' }
            Start-Sleep -Milliseconds 100
        }
    }

    $manifestRecord = Get-PreparationManifest -StageRoot $stageRoot
    $manifest = $manifestRecord.value
    if ($manifest.stage_id -ne $stageId) { throw 'Stage ID mismatch.' }
    if ($manifest.controller.mutex_name -ne $mutexName -or -not [string]::Equals([string]$manifest.controller.lock_path, $lockPath, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Sealed controller mutex or lock mismatch.'
    }
    [void](Assert-SealedIdentity -ManifestRecord $manifestRecord -StageRoot $stageRoot -ControllerPath $controllerPath -FullHash ($Mode -eq 'DryRun'))
    if (-not [string]::Equals([string]$selfIdentity.image_path, [string]$manifest.controller.allowed_self_image_path, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Controller self image path is not allowed.'
    }
    foreach ($prior in @($manifest.preparation_owned_processes)) {
        if ([int]$prior.pid -eq [int]$selfIdentity.pid -and [string]$prior.creation_time_utc -eq [string]$selfIdentity.creation_time_utc) {
            if ($Mode -ne 'DryRun' -or [string]$prior.role -ne 'dry-run-controller') { throw 'Prior preparation controller identity was reused.' }
        }
    }

    if ($Mode -eq 'DryRun') {
        $runtime = @(Get-OwnedRuntimeInventory)
        $oneDrive = @(Get-OneDriveInventory)
        $probePath = Join-Path $controlRoot 'dry-run-write-probe.tmp'
        Write-Utf8 -Path $probePath -Content 'dry-run-writable'
        [IO.File]::Delete($probePath)
        $dryResult = [ordered]@{
            schema = 'mfo.phase2.slice2a.performance-only.dry-run-result.v1'
            stage_id = $stageId
            manifest_sha256 = $manifestRecord.sha256
            controller_sha256 = $controllerHash
            controller_self = $selfIdentity
            APIs = [ordered]@{
                get_system_times = ($null -ne (Get-SystemSnapshot))
                get_last_input_info = ($null -ne (Get-LastInputTick))
                get_foreground_window = ($null -ne (Get-ForegroundSnapshot))
                power_mode = ($null -ne (Get-PowerSnapshot))
                process_snapshot = ($null -ne [MfoP005Native]::ParentChildMap())
            }
            sealed_slot_count = @($manifest.matrix.slots).Count
            sealed_order = @($manifest.matrix.order)
            runtime_processes = $runtime
            runtime_count = $runtime.Count
            onedrive_inventory_for_information_only = $oneDrive
            output_paths_writable = $true
            performance_slot_launch_count = 0
            timed_origin_created = $false
            result = $(if ($runtime.Count -eq 0 -and @($manifest.matrix.slots).Count -eq 6) { 'Pass' } else { 'Fail' })
            completed_at_utc = [DateTimeOffset]::UtcNow.ToString('o')
        }
        Write-Json -Path (Join-Path $controlRoot 'dry-run-result.json') -Value $dryResult
        if ($dryResult.result -ne 'Pass') { throw 'Dry-run checks failed.' }
        Write-Output ($dryResult | ConvertTo-Json -Depth 20)
        $resultExit = 0
    } else {
        Assert-PreparationProcessesExited -Manifest $manifest
        $initialRuntime = @(Get-OwnedRuntimeInventory)
        if ($initialRuntime.Count -ne 0) { throw 'Owned runtime exists at timed controller entry.' }

        $timedStartedLocal = $runInvocationLocal
        $timedOriginTick = [long]$runInvocationStopwatchTick
        $systemWideOriginTick = [long]$runInvocationSystemTick
        $deadlineTick = $timedOriginTick + [long](600.0 * $stopwatchFrequency)
        $runRoot = Join-Path $stageRoot 'run'
        if (Test-Path -LiteralPath $runRoot) { throw 'Sealed run output root already exists.' }
        [IO.Directory]::CreateDirectory($runRoot) | Out-Null
        Write-Json -Path (Join-Path $runRoot 'controller-origin.json') -Value ([ordered]@{
            schema = 'mfo.phase2.slice2a.performance-only.controller-origin.v1'
            stage_id = $stageId
            manifest_sha256 = $manifestRecord.sha256
            controller_self = $selfIdentity
            started_local = $timedStartedLocal.ToString('o')
            stopwatch_origin_tick = $timedOriginTick
            stopwatch_frequency = $stopwatchFrequency
            system_wide_tick_count64_origin = $systemWideOriginTick
            deadline_stopwatch_tick = $deadlineTick
        })

        $checkDeadline = { if ([Diagnostics.Stopwatch]::GetTimestamp() -ge $deadlineTick) { throw 'Global 10-minute deadline expired.' } }
        $settleSamples = @()
        $baseline = Get-LastInputTick
        $settleStart = [Diagnostics.Stopwatch]::GetTimestamp()
        for ($index = 0; $index -le 60; $index++) {
            $target = $settleStart + [long]($index * $stopwatchFrequency)
            Wait-UntilMonotonic -TargetTick $target -DeadlineCheck $checkDeadline
            $inventory = Get-IntegrityInventory -Phase 'settled-60s' -InputBaseline $baseline -RequireBaseline $true
            Assert-InventoryBase -Inventory $inventory -RequireNoRuntime $true
            $settleSamples += [pscustomobject]@{ index = $index; inventory = $inventory; system = Get-SystemSnapshot }
        }
        Write-Json -Path (Join-Path $runRoot 'settled-interval.json') -Value ([ordered]@{ requested_seconds = 60; actual_seconds = ([Diagnostics.Stopwatch]::GetTimestamp() - $settleStart) / $stopwatchFrequency; samples = $settleSamples })

        $preflightAttempts = @()
        $preflightPassed = $false
        for ($attempt = 1; $attempt -le 3 -and -not $preflightPassed; $attempt++) {
            if ($attempt -gt 1) {
                $retryStart = [Diagnostics.Stopwatch]::GetTimestamp()
                for ($idleIndex = 1; $idleIndex -le 15; $idleIndex++) {
                    Wait-UntilMonotonic -TargetTick ($retryStart + [long]($idleIndex * $stopwatchFrequency)) -DeadlineCheck $checkDeadline
                    $retryInventory = Get-IntegrityInventory -Phase "preflight-retry-idle-$attempt" -InputBaseline $baseline -RequireBaseline $true
                    Assert-InventoryBase -Inventory $retryInventory -RequireNoRuntime $true
                }
            }
            $attemptStart = [Diagnostics.Stopwatch]::GetTimestamp()
            $samples = @()
            $firstSystem = Get-SystemSnapshot
            $samples += [pscustomobject]@{ index = 0; inventory = (Get-IntegrityInventory -Phase "preflight-$attempt" -InputBaseline $baseline -RequireBaseline $true); system = $firstSystem; interval = $null }
            Assert-InventoryBase -Inventory $samples[0].inventory -RequireNoRuntime $true
            $previousSystem = $firstSystem
            for ($index = 1; $index -le 15; $index++) {
                Wait-UntilMonotonic -TargetTick ($attemptStart + [long]($index * $stopwatchFrequency)) -DeadlineCheck $checkDeadline
                $inventory = Get-IntegrityInventory -Phase "preflight-$attempt" -InputBaseline $baseline -RequireBaseline $true
                Assert-InventoryBase -Inventory $inventory -RequireNoRuntime $true
                $currentSystem = Get-SystemSnapshot
                $interval = Get-SystemCpuInterval -Previous $previousSystem -Current $currentSystem
                if ($null -eq $interval) { throw 'Preflight system CPU sample is not comparable.' }
                $samples += [pscustomobject]@{ index = $index; inventory = $inventory; system = $currentSystem; interval = $interval }
                $previousSystem = $currentSystem
            }
            $aggregate = Get-SystemCpuInterval -Previous $firstSystem -Current $previousSystem
            $maximum = (@($samples | Where-Object { $null -ne $_.interval } | ForEach-Object { [double]$_.interval.cpu_percent }) | Measure-Object -Maximum).Maximum
            $cpuPass = ($null -ne $aggregate -and [double]$aggregate.cpu_percent -le 20.0 -and [double]$maximum -le 40.0)
            $record = [ordered]@{
                attempt = $attempt
                actual_monotonic_duration_seconds = ([Diagnostics.Stopwatch]::GetTimestamp() - $attemptStart) / $stopwatchFrequency
                aggregate = $aggregate
                interval_maximum_percent = $maximum
                cpu_pass = $cpuPass
                samples = $samples
            }
            $preflightAttempts += $record
            Write-Json -Path (Join-Path $runRoot ("preflight-$attempt.json")) -Value $record
            if ($cpuPass) { $preflightPassed = $true }
        }
        if (-not $preflightPassed) { throw 'All allowed CPU preflight attempts failed.' }
        $remainingSeconds = ([double]$deadlineTick - [double][Diagnostics.Stopwatch]::GetTimestamp()) / $stopwatchFrequency
        if ($remainingSeconds -lt 420.0) { throw 'Less than 420 seconds remain before matrix.' }

        $logicalProcessors = [int]$manifest.host.logical_processors
        $matrixResults = @()
        $script:p005AllSamples = @()
        $script:p005SegmentResults = @()

        function Capture-MatrixSample {
            param([string]$Segment, $PreviousSystem, [Diagnostics.Process]$GameProcess, [double]$PreviousGameCpu, $ExpectedGameIdentity, [bool]$RequireGame, [bool]$RequireForeground)
            & $checkDeadline
            $inventory = Get-IntegrityInventory -Phase $Segment -InputBaseline $baseline -RequireBaseline $true
            if ($inventory.onedrive_count -ne 0 -or -not $inventory.input_matches_baseline -or -not $inventory.power.valid) { throw "Base integrity failed in $Segment." }
            $runtime = @($inventory.owned_runtime)
            if ($RequireGame) {
                if ($runtime.Count -ne 1 -or -not (Test-IdentityMatch -Actual $runtime[0] -Expected $ExpectedGameIdentity)) { throw "Runtime identity failed in $Segment." }
            } elseif ($runtime.Count -ne 0) { throw "Unexpected runtime in $Segment." }
            $currentSystem = Get-SystemSnapshot
            $systemInterval = Get-SystemCpuInterval -Previous $PreviousSystem -Current $currentSystem
            if ($null -eq $systemInterval -or [double]$systemInterval.wall_seconds -le 0) { throw "System sample is non-comparable in $Segment." }
            $gameCpu = 0.0
            $gameDelta = 0.0
            if ($RequireGame) {
                $gameCpu = Get-ProcessCpuSeconds -Process $GameProcess
                $gameDelta = $gameCpu - $PreviousGameCpu
                if ($gameDelta -lt 0) { throw "Negative game CPU delta in $Segment." }
            }
            $gamePct = $(if ($RequireGame) { [Math]::Max(0.0, [Math]::Min(100.0, 100.0 * $gameDelta / ([double]$systemInterval.wall_seconds * $logicalProcessors))) } else { 0.0 })
            $background = [Math]::Max(0.0, [Math]::Min(100.0, [double]$systemInterval.cpu_percent - $gamePct))
            $foreground = Get-ForegroundSnapshot
            $integrity = (-not $RequireForeground -or $foreground.pid -eq [int]$ExpectedGameIdentity.pid)
            if (-not $integrity) { throw "Foreground ownership failed in $Segment." }
            return [pscustomobject]@{
                sample = [pscustomobject]@{
                    segment = $Segment
                    captured_at_utc = [DateTimeOffset]::UtcNow.ToString('o')
                    system_previous = $PreviousSystem
                    system_current = $currentSystem
                    system_interval = $systemInterval
                    game_cpu_previous_seconds = $PreviousGameCpu
                    game_cpu_current_seconds = $gameCpu
                    game_cpu_delta_seconds = $gameDelta
                    logical_processors = $logicalProcessors
                    game_process_percent = $gamePct
                    background_percent = $background
                    inventory = $inventory
                    foreground = $foreground
                    integrity_valid = $integrity
                    wall_seconds = [double]$systemInterval.wall_seconds
                }
                current_system = $currentSystem
                current_game_cpu = $gameCpu
            }
        }

        function Run-IdleSegment {
            param([string]$Name)
            $samples = @()
            $previousSystem = Get-SystemSnapshot
            $started = [Diagnostics.Stopwatch]::GetTimestamp()
            for ($index = 1; $index -le 5; $index++) {
                Wait-UntilMonotonic -TargetTick ($started + [long]($index * $stopwatchFrequency)) -DeadlineCheck $checkDeadline
                $captured = Capture-MatrixSample -Segment $Name -PreviousSystem $previousSystem -GameProcess $null -PreviousGameCpu 0.0 -ExpectedGameIdentity $null -RequireGame $false -RequireForeground $false
                $samples += $captured.sample
                $previousSystem = $captured.current_system
            }
            $summary = New-SegmentSummary -Name $Name -Samples $samples
            $script:p005AllSamples += $samples
            $script:p005SegmentResults += $summary
            if (-not $summary.valid) { throw "Idle segment failed: $Name" }
        }

        function Run-Slot {
            param($Slot)
            $slotRoot = [string]$Slot.outputs.directory
            if (Test-Path -LiteralPath $slotRoot) { throw "Slot output already exists: $($Slot.label)" }
            [IO.Directory]::CreateDirectory($slotRoot) | Out-Null
            $psi = New-Object Diagnostics.ProcessStartInfo
            $psi.FileName = [string]$Slot.executable_path
            $psi.Arguments = [string]$Slot.arguments
            $psi.WorkingDirectory = [string]$Slot.working_directory
            $psi.UseShellExecute = $false
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError = $true
            $psi.CreateNoWindow = $false
            $psi.StandardOutputEncoding = [Text.Encoding]::UTF8
            $psi.StandardErrorEncoding = [Text.Encoding]::UTF8
            $psi.EnvironmentVariables.Clear()
            foreach ($property in @($manifest.launch_environment.PSObject.Properties)) { $psi.EnvironmentVariables[[string]$property.Name] = [string]$property.Value }
            $process = New-Object Diagnostics.Process
            $process.StartInfo = $psi
            $slotStarted = [Diagnostics.Stopwatch]::GetTimestamp()
            $slotStartedUtc = [DateTimeOffset]::UtcNow
            $identity = $null
            $stdoutTask = $null
            $stderrTask = $null
            $startupAt = $null
            $foregroundAt = $null
            $normalBoundaryAt = $null
            $exitCode = $null
            $cleanup = $null
            $samples = @()
            $previousSystem = Get-SystemSnapshot
            $previousGameCpu = 0.0
            $lastSampleTick = [Diagnostics.Stopwatch]::GetTimestamp()
            try {
                if (-not $process.Start()) { throw "Failed to start slot $($Slot.label)." }
                $identity = Get-ProcessIdentity -Process $process
                if (-not [string]::Equals([string]$identity.image_path, [IO.Path]::GetFullPath([string]$Slot.executable_path), [StringComparison]::OrdinalIgnoreCase)) { throw "Slot image path mismatch: $($Slot.label)" }
                $stdoutTask = $process.StandardOutput.ReadToEndAsync()
                $stderrTask = $process.StandardError.ReadToEndAsync()
                $previousGameCpu = Get-ProcessCpuSeconds -Process $process
                while (-not $process.HasExited) {
                    Start-Sleep -Milliseconds 100
                    $process.Refresh()
                    if ($process.HasExited) { break }
                    & $checkDeadline
                    $elapsedSlot = ([double][Diagnostics.Stopwatch]::GetTimestamp() - [double]$slotStarted) / $stopwatchFrequency
                    if ($elapsedSlot -ge 60.0) { throw "Slot 60-second budget expired: $($Slot.label)" }
                    $logText = $(if (Test-Path -LiteralPath ([string]$Slot.outputs.godot_log)) { Get-Content -Raw -Encoding UTF8 -LiteralPath ([string]$Slot.outputs.godot_log) -ErrorAction SilentlyContinue } else { '' })
                    $now = [DateTimeOffset]::UtcNow
                    if ($null -eq $startupAt -and $logText -match '\[MFO-P1-MEASURE\] scenario=arena warmup=120 sample=600') { $startupAt = $now }
                    $handle = $process.MainWindowHandle
                    if ($null -ne $startupAt -and $null -eq $foregroundAt -and $handle -ne [IntPtr]::Zero) {
                        $foreground = Get-ForegroundSnapshot
                        if ($foreground.pid -ne $process.Id) { [void][MfoP005Native]::SetForegroundWindow($handle); $foreground = Get-ForegroundSnapshot }
                        if ($foreground.pid -eq $process.Id) { $foregroundAt = $now }
                    }
                    if ($null -ne $startupAt -and $null -eq $foregroundAt -and ($now - $startupAt).TotalMilliseconds -gt 1000.0) { throw "Foreground acquisition exceeded 1000 ms: $($Slot.label)" }
                    if ($null -eq $normalBoundaryAt -and (Test-Path -LiteralPath ([string]$Slot.outputs.performance_json)) -and (Test-Path -LiteralPath ([string]$Slot.outputs.capture_png))) { $normalBoundaryAt = $now }
                    if (([Diagnostics.Stopwatch]::GetTimestamp() - $lastSampleTick) / $stopwatchFrequency -ge 0.95) {
                        $captured = Capture-MatrixSample -Segment ([string]$Slot.label) -PreviousSystem $previousSystem -GameProcess $process -PreviousGameCpu $previousGameCpu -ExpectedGameIdentity $identity -RequireGame $true -RequireForeground ($null -eq $normalBoundaryAt)
                        $samples += $captured.sample
                        $previousSystem = $captured.current_system
                        $previousGameCpu = $captured.current_game_cpu
                        $lastSampleTick = [Diagnostics.Stopwatch]::GetTimestamp()
                    }
                }
                $process.WaitForExit()
                if ($null -eq $normalBoundaryAt -and (Test-Path -LiteralPath ([string]$Slot.outputs.performance_json)) -and (Test-Path -LiteralPath ([string]$Slot.outputs.capture_png))) { $normalBoundaryAt = [DateTimeOffset]::UtcNow }
                $exitCode = $process.ExitCode
                Write-Utf8 -Path ([string]$Slot.outputs.stdout_log) -Content $stdoutTask.Result
                Write-Utf8 -Path ([string]$Slot.outputs.stderr_log) -Content $stderrTask.Result
                if ($exitCode -ne 0 -or $null -eq $startupAt -or $null -eq $foregroundAt -or $null -eq $normalBoundaryAt) { throw "Slot output or exit failed: $($Slot.label)" }
            } finally {
                if ($null -ne $identity -and $null -ne (Get-Process -Id ([int]$identity.pid) -ErrorAction SilentlyContinue)) { $cleanup = Stop-OwnedTree -RootIdentity $identity -MaximumSeconds 5 }
                if ($null -ne $cleanup -and @($cleanup.residue).Count -gt 0) { throw "Owned process residue after slot $($Slot.label)." }
                try { if ($null -ne $stdoutTask -and -not (Test-Path -LiteralPath ([string]$Slot.outputs.stdout_log))) { Write-Utf8 -Path ([string]$Slot.outputs.stdout_log) -Content $stdoutTask.Result } } catch {}
                try { if ($null -ne $stderrTask -and -not (Test-Path -LiteralPath ([string]$Slot.outputs.stderr_log))) { Write-Utf8 -Path ([string]$Slot.outputs.stderr_log) -Content $stderrTask.Result } } catch {}
                $metadata = [ordered]@{
                    schema = 'mfo.phase2.slice2a.performance-only.slot.v1'
                    label = $Slot.label
                    variant = $Slot.variant
                    command = $Slot.expanded_command
                    started_utc = $slotStartedUtc.ToString('o')
                    duration_seconds = ([double][Diagnostics.Stopwatch]::GetTimestamp() - [double]$slotStarted) / $stopwatchFrequency
                    identity = $identity
                    startup_utc = $(if ($null -ne $startupAt) { $startupAt.ToString('o') } else { $null })
                    foreground_acquired_utc = $(if ($null -ne $foregroundAt) { $foregroundAt.ToString('o') } else { $null })
                    normal_boundary_utc = $(if ($null -ne $normalBoundaryAt) { $normalBoundaryAt.ToString('o') } else { $null })
                    exit_code = $exitCode
                    cleanup = $cleanup
                }
                Write-Json -Path (Join-Path $slotRoot 'slot-metadata.json') -Value $metadata
            }
            $slotTotalSeconds = ([double][Diagnostics.Stopwatch]::GetTimestamp() - [double]$slotStarted) / $stopwatchFrequency
            if ($slotTotalSeconds -gt 60.0) { throw "Slot exceeded 60-second total budget: $($Slot.label)" }
            $summary = New-SegmentSummary -Name ([string]$Slot.label) -Samples $samples
            $script:p005AllSamples += $samples
            $script:p005SegmentResults += $summary
            if (-not $summary.valid) { throw "Slot segment integrity failed: $($Slot.label)" }
            $report = Get-Content -Raw -Encoding UTF8 -LiteralPath ([string]$Slot.outputs.performance_json) | ConvertFrom-Json
            $semantic = ($report.schema -eq 'mfo.phase1.performance.v1' -and $report.scenario -eq 'arena' -and [int]$report.warmup_frames -eq 120 -and [int]$report.sample_frames -eq 600 -and $report.renderer -eq 'gl_compatibility' -and $report.window_size -eq '(1920, 1080)' -and $report.engine.hash -eq '5b4e0cb0fd279832bbdd69fed5354d4e5ad26f88')
            if (-not $semantic) { throw "Recorder semantic mismatch: $($Slot.label)" }
            return [pscustomobject]@{
                label = $Slot.label
                variant = $Slot.variant
                source_commit = $Slot.source_commit
                identity = $identity
                exit_code = $exitCode
                p50_ms = [double]$report.frame_ms.p50
                p95_ms = [double]$report.frame_ms.p95
                p99_ms = [double]$report.frame_ms.p99
                maximum_ms = [double]$report.frame_ms.maximum
                average_ms = [double]$report.frame_ms.average
                fps_from_average = [double]$report.fps_from_average_frame
                threshold_ms = 16.67
                threshold_result = $(if ([double]$report.frame_ms.p95 -le 16.67) { 'Pass' } else { 'Fail' })
                segment = $summary
                performance_json_sha256 = Get-Sha256 -Path ([string]$Slot.outputs.performance_json)
                capture_sha256 = Get-Sha256 -Path ([string]$Slot.outputs.capture_png)
            }
        }

        for ($index = 0; $index -lt @($manifest.matrix.slots).Count; $index++) {
            $slot = @($manifest.matrix.slots)[$index]
            $idleName = $(if ($index -eq 0) { 'pre-A1-idle' } else { "inter-$(@($manifest.matrix.slots)[$index - 1].label)-$($slot.label)" })
            Run-IdleSegment -Name $idleName
            $matrixResults += Run-Slot -Slot $slot
        }

        $finalInventory = Get-IntegrityInventory -Phase 'controller-boundary' -InputBaseline $baseline -RequireBaseline $true
        Assert-InventoryBase -Inventory $finalInventory -RequireNoRuntime $true
        $a = @($matrixResults | Where-Object { $_.variant -eq 'A' })
        $b = @($matrixResults | Where-Object { $_.variant -eq 'B' })
        $c = @($matrixResults | Where-Object { $_.variant -eq 'C' })
        $aPass = (@($a | Where-Object { $_.threshold_result -ne 'Pass' }).Count -eq 0)
        $bPass = (@($b | Where-Object { $_.threshold_result -ne 'Pass' }).Count -eq 0)
        $cPass = (@($c | Where-Object { $_.threshold_result -ne 'Pass' }).Count -eq 0)
        if ($aPass -and $cPass) { $recommendation = 'Pass'; $reason = 'A and C each passed twice; B attribution-only.' }
        elseif (-not $aPass) { $recommendation = 'Blocked'; $reason = 'A control did not reproduce threshold.' }
        elseif ($bPass -and -not $cPass -and @($c | Where-Object { $_.threshold_result -eq 'Fail' }).Count -eq 2) { $recommendation = 'Fail'; $reason = 'Correction-delta correlation.' }
        elseif (-not $bPass -and -not $cPass -and @($b | Where-Object { $_.threshold_result -eq 'Fail' }).Count -eq 2 -and @($c | Where-Object { $_.threshold_result -eq 'Fail' }).Count -eq 2) { $recommendation = 'Fail'; $reason = 'Failure present before correction; relative magnitude un-attributed.' }
        else { $recommendation = 'Fail'; $reason = 'Current C candidate has at least one valid threshold failure; causality unisolated.' }
        $session = [ordered]@{
            schema = 'mfo.phase2.slice2a.performance-only.session.v1'
            stage_id = $stageId
            manifest_sha256 = $manifestRecord.sha256
            controller_sha256 = $controllerHash
            controller_origin_local = $timedStartedLocal.ToString('o')
            controller_origin_stopwatch_tick = $timedOriginTick
            controller_origin_system_tick_count64 = $systemWideOriginTick
            deadline_stopwatch_tick = $deadlineTick
            settled_sample_count = $settleSamples.Count
            preflight_attempts = $preflightAttempts
            matrix_order = @($matrixResults | ForEach-Object { $_.label })
            matrix_results = $matrixResults
            segment_results = $script:p005SegmentResults
            final_inventory = $finalInventory
            performance_recommendation = $recommendation
            disposition_reason = $reason
            completed_at_local = [DateTimeOffset]::Now.ToString('o')
        }
        Write-Json -Path (Join-Path $runRoot 'continuous-samples.json') -Value @($script:p005AllSamples)
        Write-Json -Path (Join-Path $runRoot 'session-summary.json') -Value $session
        Write-Output ($session | ConvertTo-Json -Depth 24)
        $resultExit = 0
    }
} catch {
    $errorRecord = [ordered]@{
        schema = 'mfo.phase2.slice2a.performance-only.controller-error.v1'
        stage_id = $stageId
        mode = $Mode
        controller_self = $selfIdentity
        captured_at_utc = [DateTimeOffset]::UtcNow.ToString('o')
        message = $_.Exception.Message
        type = $_.Exception.GetType().FullName
        script_stack = $_.ScriptStackTrace
    }
    try {
        $errorPath = $(if ($Mode -eq 'Run' -and (Test-Path -LiteralPath (Join-Path $stageRoot 'run'))) { Join-Path $stageRoot 'run\controller-error.json' } else { Join-Path $controlRoot 'controller-error.json' })
        Write-Json -Path $errorPath -Value $errorRecord
    } catch {}
    Write-Error $_.Exception.Message
    $resultExit = 2
} finally {
    if ($null -ne $lockStream) { try { $lockStream.Dispose() } catch {} }
    if (Test-Path -LiteralPath $lockPath) { try { [IO.File]::Delete($lockPath) } catch {} }
    if ($ownsMutex -and $null -ne $mutex) { try { $mutex.ReleaseMutex() } catch {} }
    if ($null -ne $mutex) { try { $mutex.Dispose() } catch {} }
}

exit $resultExit
