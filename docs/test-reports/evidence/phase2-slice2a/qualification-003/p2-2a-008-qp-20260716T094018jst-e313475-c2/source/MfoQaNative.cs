using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Web.Script.Serialization;

namespace MfoQaQualification
{
    public static class Contract
    {
        public const string WorkOrder = "MFO-WO-P2-2A-008";
        public const string ManifestSchema = "mfo.qa.qualification.manifest.v1";
        public const string ReceiptSchema = "mfo.qa.qualification.preparation-receipt.v1";
        public const string PreparationAuditSchema = "mfo.qa.qualification.preparation-audit.v1";
        public const string PreackPendingSchema = "mfo.qa.preack.pending.v2";
        public const string PreackEvaluationSchema = "mfo.qa.preack.evaluation.v2";
        public const string ActivationPendingSchema = "mfo.qa.live.activation.pending.v1";
        public const string ActivationEvaluationSchema = "mfo.qa.live.activation.evaluation.v1";
        public const int Pass = 0;
        public const int Blocked = 20;
        public const int HarnessFail = 30;
        public const int TimeoutFail = 31;
        public const int SentinelExpected = 23;
        public const ulong LiveDeadlineMilliseconds = 600000UL;
        public const ulong OuterTimeoutMilliseconds = 240000UL;
        public const ulong InnerTimeoutMilliseconds = 180000UL;
        public const ulong SentinelTimeoutMilliseconds = 15000UL;
        public const ulong CleanupTimeoutMilliseconds = 10000UL;
        public const ulong JournalMutexTimeoutMilliseconds = 10000UL;
        public const string BestPerformanceGuid = "ded574b5-45a0-4f42-8737-46345c09c238";
        public const string SentinelReady = "MFO-QA-SENTINEL-READY";
        public const string SentinelStdout = "MFO-QA-SENTINEL-STDOUT";
        public const string SentinelStderr = "MFO-QA-SENTINEL-STDERR";
    }

    public sealed class ExpectedTerminalException : Exception
    {
        public readonly int Code;
        public ExpectedTerminalException(int code, string message) : base(message) { Code = code; }
    }

    public sealed class HarnessException : Exception
    {
        public HarnessException(string message) : base(message) { }
        public HarnessException(string message, Exception inner) : base(message, inner) { }
    }

    public static class NativeApi
    {
        [StructLayout(LayoutKind.Sequential)]
        public struct SystemPowerStatus
        {
            public byte ACLineStatus;
            public byte BatteryFlag;
            public byte BatteryLifePercent;
            public byte SystemStatusFlag;
            public uint BatteryLifeTime;
            public uint BatteryFullLifeTime;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct LastInputInfo
        {
            public uint cbSize;
            public uint dwTime;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct FileTime
        {
            public uint Low;
            public uint High;
            public ulong Value { get { return ((ulong)High << 32) | Low; } }
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct ProcessEntry32
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

        [StructLayout(LayoutKind.Sequential)]
        private struct IoCounters
        {
            public ulong ReadOperationCount;
            public ulong WriteOperationCount;
            public ulong OtherOperationCount;
            public ulong ReadTransferCount;
            public ulong WriteTransferCount;
            public ulong OtherTransferCount;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct JobObjectBasicAccountingInformation
        {
            public long TotalUserTime;
            public long TotalKernelTime;
            public long ThisPeriodTotalUserTime;
            public long ThisPeriodTotalKernelTime;
            public uint TotalPageFaultCount;
            public uint TotalProcesses;
            public uint ActiveProcesses;
            public uint TotalTerminatedProcesses;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct JobObjectBasicLimitInformation
        {
            public long PerProcessUserTimeLimit;
            public long PerJobUserTimeLimit;
            public uint LimitFlags;
            public UIntPtr MinimumWorkingSetSize;
            public UIntPtr MaximumWorkingSetSize;
            public uint ActiveProcessLimit;
            public UIntPtr Affinity;
            public uint PriorityClass;
            public uint SchedulingClass;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct JobObjectExtendedLimitInformation
        {
            public JobObjectBasicLimitInformation BasicLimitInformation;
            public IoCounters IoInfo;
            public UIntPtr ProcessMemoryLimit;
            public UIntPtr JobMemoryLimit;
            public UIntPtr PeakProcessMemoryUsed;
            public UIntPtr PeakJobMemoryUsed;
        }

        internal enum JobObjectInfoType
        {
            BasicAccountingInformation = 1,
            BasicProcessIdList = 3,
            ExtendedLimitInformation = 9
        }

        private const uint JobObjectLimitKillOnJobClose = 0x00002000;

        [DllImport("kernel32.dll")]
        public static extern ulong GetTickCount64();

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool GetSystemPowerStatus(out SystemPowerStatus status);

        [DllImport("powrprof.dll")]
        private static extern uint PowerGetEffectiveOverlayScheme(out Guid effectivePowerModeGuid);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern bool GetLastInputInfo(ref LastInputInfo inputInfo);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool GetProcessTimes(IntPtr process, out FileTime creation, out FileTime exit, out FileTime kernel, out FileTime user);

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool QueryFullProcessImageName(IntPtr process, uint flags, StringBuilder imagePath, ref uint size);

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        internal static extern IntPtr CreateJobObject(IntPtr attributes, string name);

        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool SetInformationJobObject(IntPtr job, JobObjectInfoType infoType, IntPtr info, uint length);

        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool AssignProcessToJobObject(IntPtr job, IntPtr process);

        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool QueryInformationJobObject(IntPtr job, JobObjectInfoType infoType, IntPtr info, uint length, IntPtr returnedLength);

        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool TerminateJobObject(IntPtr job, uint exitCode);

        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool CloseHandle(IntPtr handle);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr CreateToolhelp32Snapshot(uint flags, uint processId);

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool Process32FirstW(IntPtr snapshot, ref ProcessEntry32 entry);

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool Process32NextW(IntPtr snapshot, ref ProcessEntry32 entry);

        public static string EffectiveOverlayGuid(out bool success, out uint nativeStatus)
        {
            Guid effectivePowerModeGuid;
            nativeStatus = PowerGetEffectiveOverlayScheme(out effectivePowerModeGuid);
            success = nativeStatus == 0;
            if (!success) return String.Empty;
            return effectivePowerModeGuid.ToString().ToLowerInvariant();
        }

        public static uint ReadLastInput(out bool success, out int nativeError)
        {
            LastInputInfo info = new LastInputInfo();
            info.cbSize = (uint)Marshal.SizeOf(typeof(LastInputInfo));
            success = GetLastInputInfo(ref info);
            nativeError = success ? 0 : Marshal.GetLastWin32Error();
            return info.dwTime;
        }

        public static ProcessIdentity ReadIdentity(Process process)
        {
            FileTime creation, exit, kernel, user;
            if (!GetProcessTimes(process.Handle, out creation, out exit, out kernel, out user))
                throw new HarnessException("GetProcessTimes failed: " + Marshal.GetLastWin32Error().ToString(CultureInfo.InvariantCulture));
            StringBuilder path = new StringBuilder(32768);
            uint length = (uint)path.Capacity;
            if (!QueryFullProcessImageName(process.Handle, 0, path, ref length))
                throw new HarnessException("QueryFullProcessImageName failed: " + Marshal.GetLastWin32Error().ToString(CultureInfo.InvariantCulture));
            return new ProcessIdentity(process.Id, creation.Value, path.ToString());
        }

        internal static void ConfigureKillOnClose(IntPtr job)
        {
            ConfigureKillOnClose(job, true);
        }

        internal static void ConfigureKillOnClose(IntPtr job, bool enabled)
        {
            JobObjectExtendedLimitInformation info = new JobObjectExtendedLimitInformation();
            info.BasicLimitInformation.LimitFlags = enabled ? JobObjectLimitKillOnJobClose : 0U;
            int size = Marshal.SizeOf(typeof(JobObjectExtendedLimitInformation));
            IntPtr buffer = Marshal.AllocHGlobal(size);
            try
            {
                Marshal.StructureToPtr(info, buffer, false);
                if (!SetInformationJobObject(job, JobObjectInfoType.ExtendedLimitInformation, buffer, (uint)size))
                    throw new HarnessException("SetInformationJobObject failed: " + Marshal.GetLastWin32Error().ToString(CultureInfo.InvariantCulture));
            }
            finally { Marshal.FreeHGlobal(buffer); }
        }

        internal static uint ActiveJobProcesses(IntPtr job)
        {
            int size = Marshal.SizeOf(typeof(JobObjectBasicAccountingInformation));
            IntPtr buffer = Marshal.AllocHGlobal(size);
            try
            {
                if (!QueryInformationJobObject(job, JobObjectInfoType.BasicAccountingInformation, buffer, (uint)size, IntPtr.Zero))
                    throw new HarnessException("QueryInformationJobObject failed: " + Marshal.GetLastWin32Error().ToString(CultureInfo.InvariantCulture));
                JobObjectBasicAccountingInformation info = (JobObjectBasicAccountingInformation)Marshal.PtrToStructure(buffer, typeof(JobObjectBasicAccountingInformation));
                return info.ActiveProcesses;
            }
            finally { Marshal.FreeHGlobal(buffer); }
        }

        internal static List<int> ActiveJobProcessIds(IntPtr job)
        {
            int capacity = 1024;
            int size = 8 + (IntPtr.Size * capacity);
            IntPtr buffer = Marshal.AllocHGlobal(size);
            try
            {
                if (!QueryInformationJobObject(job, JobObjectInfoType.BasicProcessIdList, buffer, (uint)size, IntPtr.Zero))
                    throw new HarnessException("QueryInformationJobObject process list failed: " + Marshal.GetLastWin32Error().ToString(CultureInfo.InvariantCulture));
                uint count = (uint)Marshal.ReadInt32(buffer, 4);
                if (count > capacity) throw new HarnessException("Job process list exceeded sealed capacity");
                List<int> result = new List<int>();
                for (uint i = 0; i < count; i++)
                {
                    long value = IntPtr.Size == 8 ? Marshal.ReadInt64(buffer, 8 + ((int)i * IntPtr.Size)) : Marshal.ReadInt32(buffer, 8 + ((int)i * IntPtr.Size));
                    result.Add(checked((int)value));
                }
                return result;
            }
            finally { Marshal.FreeHGlobal(buffer); }
        }

        internal static List<Dictionary<string, object>> ProcessTreeSnapshot()
        {
            const uint snapProcess = 0x00000002;
            IntPtr snapshot = CreateToolhelp32Snapshot(snapProcess, 0);
            if (snapshot == new IntPtr(-1)) throw new HarnessException("CreateToolhelp32Snapshot failed: " + Marshal.GetLastWin32Error().ToString(CultureInfo.InvariantCulture));
            try
            {
                List<Dictionary<string, object>> result = new List<Dictionary<string, object>>();
                ProcessEntry32 entry = new ProcessEntry32();
                entry.dwSize = (uint)Marshal.SizeOf(typeof(ProcessEntry32));
                if (!Process32FirstW(snapshot, ref entry)) throw new HarnessException("Process32First failed: " + Marshal.GetLastWin32Error().ToString(CultureInfo.InvariantCulture));
                do
                {
                    result.Add(Record.Map("pid", checked((int)entry.th32ProcessID), "parent_pid", checked((int)entry.th32ParentProcessID), "name", entry.szExeFile));
                    entry.dwSize = (uint)Marshal.SizeOf(typeof(ProcessEntry32));
                }
                while (Process32NextW(snapshot, ref entry));
                return result;
            }
            finally { CloseHandle(snapshot); }
        }
    }

    public sealed class ProcessIdentity
    {
        public readonly int Pid;
        public readonly ulong CreationFileTime;
        public readonly string ImagePath;

        public ProcessIdentity(int pid, ulong creationFileTime, string imagePath)
        {
            Pid = pid;
            CreationFileTime = creationFileTime;
            ImagePath = Path.GetFullPath(imagePath);
        }

        public Dictionary<string, object> ToRecord()
        {
            return Record.Map("pid", Pid, "creation_filetime_utc", CreationFileTime.ToString(CultureInfo.InvariantCulture), "image_path", ImagePath);
        }

        public bool MatchesCurrent()
        {
            try
            {
                using (Process p = Process.GetProcessById(Pid))
                {
                    ProcessIdentity current = NativeApi.ReadIdentity(p);
                    return current.CreationFileTime == CreationFileTime && String.Equals(current.ImagePath, ImagePath, StringComparison.OrdinalIgnoreCase);
                }
            }
            catch { return false; }
        }
    }

    public static class Record
    {
        public static Dictionary<string, object> Map(params object[] pairs)
        {
            Dictionary<string, object> map = new Dictionary<string, object>(StringComparer.Ordinal);
            if (pairs.Length % 2 != 0) throw new ArgumentException("pairs");
            for (int i = 0; i < pairs.Length; i += 2) map[(string)pairs[i]] = pairs[i + 1];
            return map;
        }

        public static string Json(object value)
        {
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            serializer.MaxJsonLength = Int32.MaxValue;
            return serializer.Serialize(value);
        }

        public static object Parse(string json)
        {
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            serializer.MaxJsonLength = Int32.MaxValue;
            return serializer.DeserializeObject(json);
        }

        public static Dictionary<string, object> AsMap(object value)
        {
            Dictionary<string, object> map = value as Dictionary<string, object>;
            if (map == null) throw new HarnessException("JSON object required");
            return map;
        }

        public static string Text(Dictionary<string, object> map, string key)
        {
            object value;
            if (!map.TryGetValue(key, out value) || value == null) throw new HarnessException("Missing field: " + key);
            return Convert.ToString(value, CultureInfo.InvariantCulture);
        }

        public static int Integer(Dictionary<string, object> map, string key)
        {
            return Convert.ToInt32(Text(map, key), CultureInfo.InvariantCulture);
        }
    }

    public static class EvidenceIo
    {
        public static byte[] Utf8(string text) { return new UTF8Encoding(false).GetBytes(text); }

        public static string Sha256Bytes(byte[] bytes)
        {
            using (SHA256 sha = SHA256.Create()) return Hex(sha.ComputeHash(bytes));
        }

        public static string Sha256File(string path)
        {
            using (FileStream stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read))
            using (SHA256 sha = SHA256.Create()) return Hex(sha.ComputeHash(stream));
        }

        private static string Hex(byte[] bytes)
        {
            StringBuilder result = new StringBuilder(bytes.Length * 2);
            for (int i = 0; i < bytes.Length; i++) result.Append(bytes[i].ToString("x2", CultureInfo.InvariantCulture));
            return result.ToString();
        }

        public static void WriteNewBytes(string path, byte[] bytes)
        {
            string full = Path.GetFullPath(path);
            Directory.CreateDirectory(Path.GetDirectoryName(full));
            if (File.Exists(full)) throw new HarnessException("Refusing to overwrite evidence: " + full);
            using (FileStream stream = new FileStream(full, FileMode.CreateNew, FileAccess.Write, FileShare.Read, 4096, FileOptions.WriteThrough))
            {
                stream.Write(bytes, 0, bytes.Length);
                stream.Flush(true);
            }
            byte[] readback = File.ReadAllBytes(full);
            if (!ByteEqual(bytes, readback)) throw new HarnessException("Evidence readback mismatch: " + full);
        }

        public static void WriteNewJson(string path, object value)
        {
            WriteNewBytes(path, Utf8(Record.Json(value) + "\r\n"));
        }

        public static bool ByteEqual(byte[] a, byte[] b)
        {
            if (a.Length != b.Length) return false;
            for (int i = 0; i < a.Length; i++) if (a[i] != b[i]) return false;
            return true;
        }

        public static Dictionary<string, object> ReadMap(string path)
        {
            return Record.AsMap(Record.Parse(File.ReadAllText(path, Encoding.UTF8)));
        }

        public static Dictionary<string, object> FileIdentity(string path, string relative)
        {
            FileInfo file = new FileInfo(path);
            byte[] first = new byte[2];
            using (FileStream stream = file.OpenRead())
            {
                int count = stream.Read(first, 0, 2);
                if (count != 2) { first[0] = 0; first[1] = 0; }
            }
            return Record.Map(
                "relative_path", relative.Replace('\\', '/'),
                "absolute_path", file.FullName,
                "sha256", Sha256File(file.FullName),
                "byte_size", file.Length,
                "mz_hex", first[0].ToString("X2", CultureInfo.InvariantCulture) + first[1].ToString("X2", CultureInfo.InvariantCulture),
                "last_write_utc", file.LastWriteTimeUtc.ToString("o", CultureInfo.InvariantCulture));
        }
    }

    public sealed class EvidenceJournal
    {
        private readonly string path;
        private readonly string mutexName;

        public EvidenceJournal(string journalPath)
        {
            path = Path.GetFullPath(journalPath);
            Directory.CreateDirectory(Path.GetDirectoryName(path));
            mutexName = "Local\\MFO_QA_JOURNAL_" + EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(path.ToLowerInvariant())).Substring(0, 24);
        }

        public string Append(string kind, Dictionary<string, object> payload)
        {
            using (Mutex mutex = new Mutex(false, mutexName))
            {
                bool acquired = false;
                ulong acquisitionDeadline = checked(NativeApi.GetTickCount64() + Contract.JournalMutexTimeoutMilliseconds);
                while (!acquired)
                {
                    try { acquired = mutex.WaitOne(0); }
                    catch (AbandonedMutexException) { acquired = true; }
                    if (!acquired)
                    {
                        if (NativeApi.GetTickCount64() >= acquisitionDeadline) throw new HarnessException("Journal mutex native-tick acquisition timeout: " + kind);
                        Thread.Sleep(2);
                    }
                }
                try
                {
                    int sequence = 1;
                    string previous = new string('0', 64);
                    if (File.Exists(path))
                    {
                        string[] lines = File.ReadAllLines(path, Encoding.UTF8);
                        if (lines.Length > 0)
                        {
                            Dictionary<string, object> last = Record.AsMap(Record.Parse(lines[lines.Length - 1]));
                            sequence = Record.Integer(last, "sequence") + 1;
                            previous = Record.Text(last, "record_sha256");
                        }
                    }
                    Dictionary<string, object> core = Record.Map(
                        "sequence", sequence,
                        "kind", kind,
                        "native_tick", NativeApi.GetTickCount64().ToString(CultureInfo.InvariantCulture),
                        "payload", payload,
                        "previous_sha256", previous);
                    string digest = EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(Record.Json(core)));
                    core["record_sha256"] = digest;
                    string line = Record.Json(core);
                    byte[] bytes = EvidenceIo.Utf8(line + "\r\n");
                    using (FileStream stream = new FileStream(path, FileMode.Append, FileAccess.Write, FileShare.Read, 4096, FileOptions.WriteThrough))
                    {
                        stream.Write(bytes, 0, bytes.Length);
                        stream.Flush(true);
                    }
                    string[] verify = File.ReadAllLines(path, Encoding.UTF8);
                    if (verify.Length == 0 || verify[verify.Length - 1] != line) throw new HarnessException("Journal readback mismatch");
                    VerifyFile(path);
                    return digest;
                }
                finally { if (acquired) mutex.ReleaseMutex(); }
            }
        }

        public static Dictionary<string, object> VerifyFile(string journalPath)
        {
            string[] lines = File.ReadAllLines(Path.GetFullPath(journalPath), Encoding.UTF8);
            string previous = new string('0', 64);
            for (int i = 0; i < lines.Length; i++)
            {
                Dictionary<string, object> entry = Record.AsMap(Record.Parse(lines[i]));
                int sequence = Record.Integer(entry, "sequence");
                if (sequence != i + 1) throw new HarnessException("Journal sequence mismatch at line " + (i + 1).ToString(CultureInfo.InvariantCulture));
                string observedPrevious = Record.Text(entry, "previous_sha256");
                if (!String.Equals(observedPrevious, previous, StringComparison.Ordinal)) throw new HarnessException("Journal previous hash mismatch at line " + (i + 1).ToString(CultureInfo.InvariantCulture));
                Dictionary<string, object> core = Record.Map(
                    "sequence", sequence,
                    "kind", Record.Text(entry, "kind"),
                    "native_tick", Record.Text(entry, "native_tick"),
                    "payload", entry["payload"],
                    "previous_sha256", observedPrevious);
                string expected = EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(Record.Json(core)));
                string observed = Record.Text(entry, "record_sha256");
                if (!String.Equals(expected, observed, StringComparison.Ordinal)) throw new HarnessException("Journal record hash mismatch at line " + (i + 1).ToString(CultureInfo.InvariantCulture));
                previous = observed;
            }
            return Record.Map("record_count", lines.Length, "last_record_sha256", previous, "sequence_contiguous", true, "hash_chain_valid", true, "readback_valid", true);
        }
    }

    public sealed class JobScope : IDisposable
    {
        private IntPtr handle;
        public JobScope(string label)
        {
            handle = NativeApi.CreateJobObject(IntPtr.Zero, "Local\\MFO_QA_JOB_" + label + "_" + Process.GetCurrentProcess().Id.ToString(CultureInfo.InvariantCulture) + "_" + NativeApi.GetTickCount64().ToString(CultureInfo.InvariantCulture));
            if (handle == IntPtr.Zero) throw new HarnessException("CreateJobObject failed: " + Marshal.GetLastWin32Error().ToString(CultureInfo.InvariantCulture));
            NativeApi.ConfigureKillOnClose(handle);
        }

        public void Assign(Process process)
        {
            if (!NativeApi.AssignProcessToJobObject(handle, process.Handle))
                throw new HarnessException("AssignProcessToJobObject failed: " + Marshal.GetLastWin32Error().ToString(CultureInfo.InvariantCulture));
        }

        public bool IsClosed { get { return handle == IntPtr.Zero; } }
        public uint ActiveProcesses { get { return handle == IntPtr.Zero ? 0U : NativeApi.ActiveJobProcesses(handle); } }
        public List<ProcessIdentity> ActiveIdentities()
        {
            List<ProcessIdentity> result = new List<ProcessIdentity>();
            if (handle == IntPtr.Zero) return result;
            foreach (int pid in NativeApi.ActiveJobProcessIds(handle))
            {
                using (Process process = Process.GetProcessById(pid)) result.Add(NativeApi.ReadIdentity(process));
            }
            return result;
        }
        public void Terminate() { if (!NativeApi.TerminateJobObject(handle, 31)) throw new HarnessException("TerminateJobObject failed"); }
        public void CloseForRecordedKillOnClose()
        {
            if (handle == IntPtr.Zero) return;
            IntPtr closing = handle;
            handle = IntPtr.Zero;
            if (!NativeApi.CloseHandle(closing)) throw new HarnessException("CloseHandle for recorded kill-on-close failed");
        }
        public void DisarmAndCloseWithoutTermination()
        {
            if (handle == IntPtr.Zero) return;
            NativeApi.ConfigureKillOnClose(handle, false);
            IntPtr closing = handle;
            handle = IntPtr.Zero;
            if (!NativeApi.CloseHandle(closing)) throw new HarnessException("CloseHandle for disarmed job failed");
        }
        public void Dispose()
        {
            if (handle == IntPtr.Zero) return;
            IntPtr closing = handle;
            handle = IntPtr.Zero;
            try { NativeApi.ConfigureKillOnClose(closing, false); }
            finally { NativeApi.CloseHandle(closing); }
        }
    }

    public sealed class OwnedChild : IDisposable
    {
        private readonly Process process;
        private readonly ProcessIdentity identity;
        private readonly EventWaitHandle startGate;
        private readonly FileStream stdoutFile;
        private readonly FileStream stderrFile;
        private readonly string stdoutPath;
        private readonly string stderrPath;
        private readonly Task stdoutCopy;
        private readonly Task stderrCopy;
        private readonly EvidenceJournal journal;
        private readonly string label;
        private bool completed;
        private bool observedExitCodeAvailable;
        private int observedExitCode;

        private OwnedChild(Process p, ProcessIdentity id, EventWaitHandle gate, FileStream stdout, FileStream stderr, string stdoutEvidencePath, string stderrEvidencePath, Task outCopy, Task errCopy, EvidenceJournal log, string childLabel)
        {
            process = p; identity = id; startGate = gate; stdoutFile = stdout; stderrFile = stderr;
            stdoutPath = Path.GetFullPath(stdoutEvidencePath); stderrPath = Path.GetFullPath(stderrEvidencePath);
            stdoutCopy = outCopy; stderrCopy = errCopy; journal = log; label = childLabel;
        }

        public ProcessIdentity Identity { get { return identity; } }
        public bool HasExited { get { try { return process.HasExited; } catch { return true; } } }
        public bool HasObservedExitCode { get { return observedExitCodeAvailable; } }
        public int ObservedExitCode
        {
            get
            {
                if (!observedExitCodeAvailable) throw new HarnessException("Owned child exit code has not been observed: " + label);
                return observedExitCode;
            }
        }
        public string StdoutEvidencePath { get { return stdoutPath; } }
        public string StderrEvidencePath { get { return stderrPath; } }
        public bool RawStreamsCompleted { get { return completed; } }
        public Dictionary<string, object> StdoutEvidence() { return StreamEvidence(stdoutPath, "stdout"); }
        public Dictionary<string, object> StderrEvidence() { return StreamEvidence(stderrPath, "stderr"); }

        public static OwnedChild Start(string executable, string arguments, IDictionary<string, string> environment, JobScope job, string stdoutPath, string stderrPath, EvidenceJournal journal, string label, ulong ownershipDeadline)
        {
            if (NativeApi.GetTickCount64() >= ownershipDeadline) throw new ExpectedTerminalException(Contract.TimeoutFail, "Owned child start deadline expired before launch: " + label);
            string gateSeed = Path.GetFullPath(executable).ToLowerInvariant();
            string gateName = "Local\\MFO_QA_GATE_" + EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(gateSeed)).Substring(0, 24);
            EventWaitHandle gate = new EventWaitHandle(false, EventResetMode.ManualReset, gateName);
            string childArguments = (arguments == null ? String.Empty : arguments).Trim();
            if (childArguments.Length != 0) childArguments += " ";
            childArguments += "--start-gate " + HarnessOps.Quote(gateName);
            ProcessStartInfo info = new ProcessStartInfo(Path.GetFullPath(executable), childArguments);
            info.UseShellExecute = false;
            info.CreateNoWindow = true;
            info.RedirectStandardOutput = true;
            info.RedirectStandardError = true;
            info.WorkingDirectory = Path.GetDirectoryName(Path.GetFullPath(executable));
            if (environment != null && environment.Count != 0) throw new HarnessException("Child environment mutation is not permitted by the sealed invocation contract");
            Process p = new Process();
            p.StartInfo = info;
            FileStream stdout = new FileStream(stdoutPath, FileMode.CreateNew, FileAccess.Write, FileShare.Read, 4096, FileOptions.WriteThrough);
            FileStream stderr = new FileStream(stderrPath, FileMode.CreateNew, FileAccess.Write, FileShare.Read, 4096, FileOptions.WriteThrough);
            Task outCopy = null;
            Task errCopy = null;
            ProcessIdentity id = null;
            bool started = false;
            bool assigned = false;
            try
            {
                if (!p.Start()) throw new HarnessException("Child start failed: " + label);
                started = true;
                try { id = NativeApi.ReadIdentity(p); }
                catch (Exception identityFailure)
                {
                    try { job.Assign(p); assigned = true; }
                    catch (Exception containmentFailure) { throw new HarnessException("Child identity and containment both failed: " + identityFailure.Message + "; " + containmentFailure.Message, identityFailure); }
                    throw;
                }
                job.Assign(p);
                assigned = true;
                if (NativeApi.GetTickCount64() >= ownershipDeadline) throw new ExpectedTerminalException(Contract.TimeoutFail, "Owned child containment deadline expired: " + label);
                outCopy = p.StandardOutput.BaseStream.CopyToAsync(stdout);
                errCopy = p.StandardError.BaseStream.CopyToAsync(stderr);
                journal.Append("owned_child_started", Record.Map("label", label, "identity", id.ToRecord(), "arguments", childArguments, "start_gate", gateName, "job_assigned_before_gate", true));
                OwnedChild child = new OwnedChild(p, id, gate, stdout, stderr, stdoutPath, stderrPath, outCopy, errCopy, journal, label);
                gate.Set();
                return child;
            }
            catch (Exception startFailure)
            {
                bool cleanupFailed = false;
                string cleanupFailureText = null;
                bool originalTimeout = startFailure is ExpectedTerminalException && ((ExpectedTerminalException)startFailure).Code == Contract.TimeoutFail;
                bool cleanupAuthorizedByTimeout = originalTimeout;
                bool terminationInvoked = false;
                try
                {
                    string identityReadError = null;
                    if (started && id == null)
                    {
                        for (int retry = 0; retry < 3 && id == null; retry++)
                        {
                            try { id = NativeApi.ReadIdentity(p); identityReadError = null; }
                            catch (Exception identityFailure) { identityReadError = identityFailure.GetType().FullName + ": " + identityFailure.Message; Thread.Sleep(5); }
                        }
                    }
                    journal.Append("owned_child_start_failure", Record.Map("label", label, "started", started, "identity", id == null ? null : (object)id.ToRecord(), "identity_read_error", identityReadError, "job_assigned", assigned, "failure", startFailure.GetType().FullName + ": " + startFailure.Message, "original_timeout", originalTimeout, "ownership_deadline", ownershipDeadline.ToString(CultureInfo.InvariantCulture), "termination_deferred_until_native_timeout", started && !originalTimeout));

                    if (started && !p.HasExited && !cleanupAuthorizedByTimeout)
                    {
                        while (!p.HasExited && NativeApi.GetTickCount64() < ownershipDeadline) Thread.Sleep(10);
                        if (!p.HasExited) cleanupAuthorizedByTimeout = true;
                    }

                    List<ProcessIdentity> targets = new List<ProcessIdentity>();
                    string targetInventoryError = null;
                    if (assigned && started && !p.HasExited && cleanupAuthorizedByTimeout)
                    {
                        for (int retry = 0; retry < 3 && targets.Count == 0; retry++)
                        {
                            try { targets = job.ActiveIdentities(); targetInventoryError = null; }
                            catch (Exception inventoryFailure) { targetInventoryError = inventoryFailure.GetType().FullName + ": " + inventoryFailure.Message; }
                            if (targets.Count == 0) Thread.Sleep(5);
                        }
                        if (id == null)
                        {
                            foreach (ProcessIdentity target in targets) if (target.Pid == p.Id) { id = target; break; }
                        }
                    }
                    List<Dictionary<string, object>> targetRecords = new List<Dictionary<string, object>>();
                    foreach (ProcessIdentity target in targets) targetRecords.Add(Record.Map("identity", target.ToRecord(), "identity_match_at_cleanup", target.MatchesCurrent()));

                    ulong cleanupDeadline = checked(NativeApi.GetTickCount64() + Contract.CleanupTimeoutMilliseconds);
                    if (started && !p.HasExited && cleanupAuthorizedByTimeout)
                    {
                        bool exactTop = id != null && id.Pid == p.Id && id.MatchesCurrent();
                        bool topVerifiedInJob = false;
                        foreach (ProcessIdentity target in targets)
                        {
                            if (id != null && target.Pid == id.Pid && target.CreationFileTime == id.CreationFileTime && String.Equals(target.ImagePath, id.ImagePath, StringComparison.OrdinalIgnoreCase)) { topVerifiedInJob = true; break; }
                        }
                        if (assigned && targetInventoryError == null && targets.Count != 0 && topVerifiedInJob)
                        {
                            journal.Append("owned_child_start_timeout_termination_authorized", Record.Map("label", label, "native_now", NativeApi.GetTickCount64().ToString(CultureInfo.InvariantCulture), "ownership_deadline", ownershipDeadline.ToString(CultureInfo.InvariantCulture), "verified_job_targets", targetRecords));
                            try { job.Terminate(); terminationInvoked = true; }
                            catch (Exception terminationFailure)
                            {
                                job.CloseForRecordedKillOnClose();
                                terminationInvoked = true;
                                journal.Append("owned_child_start_recorded_kill_on_close", Record.Map("label", label, "failure", terminationFailure.GetType().FullName + ": " + terminationFailure.Message, "verified_job_targets", targetRecords, "close_completed", true));
                            }
                        }
                        else if (exactTop)
                        {
                            p.Kill();
                            terminationInvoked = true;
                            if (assigned && !job.IsClosed) job.DisarmAndCloseWithoutTermination();
                            journal.Append("owned_child_start_direct_termination", Record.Map("label", label, "identity", id.ToRecord(), "identity_match", true, "native_now", NativeApi.GetTickCount64().ToString(CultureInfo.InvariantCulture), "ownership_deadline", ownershipDeadline.ToString(CultureInfo.InvariantCulture), "target_inventory_error", targetInventoryError, "job_disarmed", assigned));
                        }
                        else
                        {
                            if (assigned && !job.IsClosed) job.DisarmAndCloseWithoutTermination();
                            journal.Append("owned_child_start_termination_refused", Record.Map("label", label, "reason", "exact_pid_creation_image_identity_unavailable", "pid", p.Id, "identity", id == null ? null : (object)id.ToRecord(), "target_inventory_error", targetInventoryError, "job_disarmed", assigned));
                            throw new ExpectedTerminalException(Contract.TimeoutFail, "Exact start-failure termination identity unavailable");
                        }
                        while (!p.HasExited && NativeApi.GetTickCount64() < cleanupDeadline) Thread.Sleep(5);
                        if (!p.HasExited && assigned && !job.IsClosed && targetInventoryError == null && targets.Count != 0)
                        {
                            job.CloseForRecordedKillOnClose();
                            terminationInvoked = true;
                            journal.Append("owned_child_start_recorded_kill_on_close", Record.Map("label", label, "verified_job_targets", targetRecords, "reason", "primary_start_cleanup_incomplete", "close_completed", true));
                            while (!p.HasExited && NativeApi.GetTickCount64() < cleanupDeadline) Thread.Sleep(5);
                        }
                        if (!p.HasExited) throw new ExpectedTerminalException(Contract.TimeoutFail, "Failed child start cleanup incomplete");
                    }

                    while ((outCopy != null && !outCopy.IsCompleted) || (errCopy != null && !errCopy.IsCompleted))
                    {
                        if (NativeApi.GetTickCount64() >= cleanupDeadline) throw new ExpectedTerminalException(Contract.TimeoutFail, "Failed child start stream cleanup incomplete");
                        Thread.Sleep(5);
                    }
                    if (outCopy != null) outCopy.Wait();
                    if (errCopy != null) errCopy.Wait();
                    stdout.Flush(true);
                    stderr.Flush(true);
                    uint remaining = assigned ? job.ActiveProcesses : 0U;
                    if (remaining != 0) throw new ExpectedTerminalException(Contract.TimeoutFail, "Failed child start job cleanup count nonzero");
                    journal.Append("owned_child_start_failure_cleanup", Record.Map("label", label, "cleanup_complete", true, "started", started, "terminated_exit_code", started && p.HasExited ? (object)p.ExitCode : null, "stdout", HarnessOps.SafeFileEvidence(stdoutPath, true), "stderr", HarnessOps.SafeFileEvidence(stderrPath, true), "remaining_job_processes", remaining, "original_timeout", originalTimeout, "cleanup_authorized_by_timeout", cleanupAuthorizedByTimeout, "termination_invoked", terminationInvoked));
                }
                catch (Exception cleanupFailure)
                {
                    cleanupFailed = true;
                    cleanupFailureText = cleanupFailure.GetType().FullName + ": " + cleanupFailure.Message;
                    try
                    {
                        if (started && !p.HasExited && !cleanupAuthorizedByTimeout)
                        {
                            while (!p.HasExited && NativeApi.GetTickCount64() < ownershipDeadline) Thread.Sleep(10);
                            if (!p.HasExited) cleanupAuthorizedByTimeout = true;
                        }
                        if (started && !p.HasExited)
                        {
                            if (cleanupAuthorizedByTimeout && id != null && id.MatchesCurrent())
                            {
                                p.Kill();
                                terminationInvoked = true;
                                if (assigned && !job.IsClosed) job.DisarmAndCloseWithoutTermination();
                                journal.Append("owned_child_start_direct_termination", Record.Map("label", label, "identity", id.ToRecord(), "identity_match", true, "reason", "terminal_start_cleanup_fallback_after_native_timeout", "cleanup_failure", cleanupFailureText, "job_disarmed", assigned));
                            }
                            else
                            {
                                if (assigned && !job.IsClosed) job.DisarmAndCloseWithoutTermination();
                                journal.Append("owned_child_start_termination_refused", Record.Map("label", label, "reason", cleanupAuthorizedByTimeout ? "exact_identity_unavailable" : "native_timeout_not_reached", "pid", p.Id, "identity", id == null ? null : (object)id.ToRecord(), "cleanup_failure", cleanupFailureText, "job_disarmed", assigned));
                            }
                            ulong fallbackDeadline = checked(NativeApi.GetTickCount64() + Contract.CleanupTimeoutMilliseconds);
                            while (!p.HasExited && NativeApi.GetTickCount64() < fallbackDeadline) Thread.Sleep(5);
                        }
                        journal.Append("owned_child_start_cleanup_terminal_failure", Record.Map("label", label, "cleanup_failure", cleanupFailureText, "process_exited", !started || p.HasExited, "remaining_job_processes", assigned ? job.ActiveProcesses : 0U, "stdout", HarnessOps.SafeFileEvidence(stdoutPath, false), "stderr", HarnessOps.SafeFileEvidence(stderrPath, false)));
                    }
                    catch { }
                }
                finally
                {
                    try { stdout.Dispose(); } catch { }
                    try { stderr.Dispose(); } catch { }
                    try { gate.Dispose(); } catch { }
                    try { p.Dispose(); } catch { }
                }
                if (cleanupFailed || cleanupAuthorizedByTimeout) throw new ExpectedTerminalException(Contract.TimeoutFail, "Owned child start/containment timeout cleanup: " + label + (cleanupFailureText == null ? String.Empty : ": " + cleanupFailureText));
                throw new HarnessException("Owned child start failed after complete cleanup: " + label + ": " + startFailure.Message, startFailure);
            }
        }

        public int Wait(ulong timeoutMilliseconds, JobScope job)
        {
            ulong origin = NativeApi.GetTickCount64();
            ulong deadline = checked(origin + timeoutMilliseconds);
            return WaitUntil(origin, deadline, job);
        }

        public int WaitUntil(ulong origin, ulong deadline, JobScope job)
        {
            return WaitUntil(origin, deadline, job, null);
        }

        public int WaitUntil(ulong origin, ulong deadline, JobScope job, Action<ulong> onExitObserved)
        {
            while (!HasExited)
            {
                ulong now = NativeApi.GetTickCount64();
                if (now >= deadline)
                {
                    if (HasExited) break;
                    AbortOwned(job, Contract.TimeoutFail, "Native-tick timeout: " + label + "; origin=" + origin.ToString(CultureInfo.InvariantCulture) + "; deadline=" + deadline.ToString(CultureInfo.InvariantCulture) + "; observed=" + now.ToString(CultureInfo.InvariantCulture));
                }
                Thread.Sleep(10);
            }
            ulong exitObservedTick = NativeApi.GetTickCount64();
            Exception exitObservedCallbackFailure = null;
            if (onExitObserved != null)
            {
                try { onExitObserved(exitObservedTick); }
                catch (Exception callbackFailure) { exitObservedCallbackFailure = callbackFailure; }
            }
            int exitCode = process.ExitCode;
            observedExitCode = exitCode;
            observedExitCodeAvailable = true;
            bool deadlineExpired = exitObservedTick >= deadline;
            if (deadlineExpired)
            {
                FinishStreamsAfterTimeout("Process exit observed at or after ownership deadline");
                RequireOwnedJobDrained(job, origin, deadline);
                journal.Append("owned_child_exit", Record.Map("label", label, "exit_code", exitCode, "exit_observed_tick", exitObservedTick.ToString(CultureInfo.InvariantCulture), "identity_captured_while_alive", identity.ToRecord(), "process_exited", true, "raw_streams_flushed", completed));
                if (exitObservedCallbackFailure != null) throw exitObservedCallbackFailure;
                throw new ExpectedTerminalException(Contract.TimeoutFail, "Native-tick timeout while finalizing exited child: " + label);
            }
            try
            {
                FinishStreams(deadline);
            }
            catch (ExpectedTerminalException timeout)
            {
                FinishStreamsAfterTimeout(timeout.Message);
                RequireOwnedJobDrained(job, origin, deadline);
                journal.Append("owned_child_stream_timeout_recovered", Record.Map("label", label, "origin", origin.ToString(CultureInfo.InvariantCulture), "deadline", deadline.ToString(CultureInfo.InvariantCulture), "exit_observed_tick", exitObservedTick.ToString(CultureInfo.InvariantCulture), "exit_code", exitCode, "raw_streams_completed", completed));
                journal.Append("owned_child_exit", Record.Map("label", label, "exit_code", exitCode, "exit_observed_tick", exitObservedTick.ToString(CultureInfo.InvariantCulture), "identity_captured_while_alive", identity.ToRecord(), "process_exited", true, "raw_streams_flushed", completed));
                throw;
            }
            catch (Exception streamFailure)
            {
                FinishStreamsAfterTimeout(streamFailure.GetType().FullName + ": " + streamFailure.Message);
                RequireOwnedJobDrained(job, origin, deadline);
                journal.Append("owned_child_stream_failure_recovered", Record.Map("label", label, "origin", origin.ToString(CultureInfo.InvariantCulture), "deadline", deadline.ToString(CultureInfo.InvariantCulture), "exit_observed_tick", exitObservedTick.ToString(CultureInfo.InvariantCulture), "exit_code", exitCode, "failure", streamFailure.GetType().FullName + ": " + streamFailure.Message, "raw_streams_completed", completed));
                journal.Append("owned_child_exit", Record.Map("label", label, "exit_code", exitCode, "exit_observed_tick", exitObservedTick.ToString(CultureInfo.InvariantCulture), "identity_captured_while_alive", identity.ToRecord(), "process_exited", true, "raw_streams_flushed", completed));
                throw new ExpectedTerminalException(Contract.TimeoutFail, "Raw-stream finalization failed: " + label);
            }
            RequireOwnedJobDrained(job, origin, deadline);
            journal.Append("owned_child_exit", Record.Map("label", label, "exit_code", exitCode, "exit_observed_tick", exitObservedTick.ToString(CultureInfo.InvariantCulture), "identity_captured_while_alive", identity.ToRecord(), "process_exited", true, "raw_streams_flushed", true));
            if (exitObservedCallbackFailure != null) throw exitObservedCallbackFailure;
            return exitCode;
        }

        private void RequireOwnedJobDrained(JobScope job, ulong origin, ulong deadline)
        {
            while (true)
            {
                uint active;
                try { active = job.ActiveProcesses; }
                catch (Exception inventoryFailure)
                {
                    if (!job.IsClosed) job.DisarmAndCloseWithoutTermination();
                    journal.Append("owned_job_drain_inventory_failure", Record.Map("label", label, "failure", inventoryFailure.GetType().FullName + ": " + inventoryFailure.Message, "job_disarmed", true, "origin", origin.ToString(CultureInfo.InvariantCulture), "deadline", deadline.ToString(CultureInfo.InvariantCulture)));
                    throw new ExpectedTerminalException(Contract.TimeoutFail, "Owned job drain inventory failed: " + label);
                }
                if (active == 0) return;
                ulong now = NativeApi.GetTickCount64();
                if (now >= deadline) AbortOwned(job, Contract.TimeoutFail, "Owned descendants remained after top-child exit: " + label + "; origin=" + origin.ToString(CultureInfo.InvariantCulture) + "; deadline=" + deadline.ToString(CultureInfo.InvariantCulture) + "; observed=" + now.ToString(CultureInfo.InvariantCulture));
                Thread.Sleep(10);
            }
        }

        public void AbortOwned(JobScope job, int terminalCode, string reason)
        {
            try
            {
                ulong cleanupDeadline = checked(NativeApi.GetTickCount64() + Contract.CleanupTimeoutMilliseconds);
                List<ProcessIdentity> targets = new List<ProcessIdentity>();
                string inventoryError = null;
                try { targets = job.ActiveIdentities(); }
                catch (Exception inventoryFailure) { inventoryError = inventoryFailure.GetType().FullName + ": " + inventoryFailure.Message; }
                if (inventoryError != null)
                {
                    for (int retry = 0; retry < 3 && inventoryError != null; retry++)
                    {
                        Thread.Sleep(5);
                        try { targets = job.ActiveIdentities(); inventoryError = null; }
                        catch (Exception retryFailure) { inventoryError = retryFailure.GetType().FullName + ": " + retryFailure.Message; }
                    }
                }
                List<Dictionary<string, object>> targetRecords = new List<Dictionary<string, object>>();
                bool topFound = false;
                foreach (ProcessIdentity target in targets)
                {
                    bool currentMatch = target.MatchesCurrent();
                    bool isTop = target.Pid == identity.Pid && target.CreationFileTime == identity.CreationFileTime && String.Equals(target.ImagePath, identity.ImagePath, StringComparison.OrdinalIgnoreCase);
                    if (isTop) topFound = true;
                    targetRecords.Add(Record.Map("identity", target.ToRecord(), "identity_match_at_cleanup", currentMatch, "already_exited", !currentMatch, "is_top_child", isTop));
                }
                bool topCurrent = identity.MatchesCurrent();
                bool topAlreadyExited = !topCurrent;

                string jobTerminationError = null;
                bool terminateJobAttempted = false;
                bool recordedKillOnClose = false;
                if (!job.IsClosed && targets.Count != 0 && inventoryError == null)
                {
                    terminateJobAttempted = true;
                    try { job.Terminate(); }
                    catch (Exception terminationFailure)
                    {
                        jobTerminationError = terminationFailure.GetType().FullName + ": " + terminationFailure.Message;
                        job.CloseForRecordedKillOnClose();
                        recordedKillOnClose = true;
                        journal.Append("owned_cleanup_termination_failed", Record.Map("label", label, "failure", jobTerminationError, "verified_targets", targetRecords, "reason", reason));
                        journal.Append("owned_cleanup_recorded_kill_on_close", Record.Map("label", label, "verified_targets", targetRecords, "target_inventory_error", inventoryError, "reason", reason, "close_completed", true));
                    }
                }
                if (topCurrent && !topFound)
                {
                    if (!identity.MatchesCurrent()) topCurrent = false;
                    else
                    {
                        process.Kill();
                        journal.Append("owned_cleanup_direct_top_termination", Record.Map("label", label, "identity", identity.ToRecord(), "identity_match", true, "reason", "top_not_observed_in_owned_job", "kill_invoked", true));
                    }
                }
                if (inventoryError != null && !job.IsClosed)
                {
                    while (identity.MatchesCurrent() && NativeApi.GetTickCount64() < cleanupDeadline) Thread.Sleep(10);
                    job.DisarmAndCloseWithoutTermination();
                    journal.Append("owned_cleanup_job_disarmed_without_unverified_termination", Record.Map("label", label, "target_inventory_error", inventoryError, "top_identity", identity.ToRecord(), "top_survived", identity.MatchesCurrent(), "reason", reason, "job_closed", true));
                    throw new ExpectedTerminalException(Contract.TimeoutFail, "Owned job identity inventory unavailable; unverified termination refused: " + label);
                }
                journal.Append("owned_cleanup_targets_verified", Record.Map("label", label, "targets", targetRecords, "target_inventory_error", inventoryError, "top_identity", identity.ToRecord(), "top_found_in_job", topFound, "top_current_before_termination", topCurrent, "top_already_exited", topAlreadyExited, "terminate_job_attempted", terminateJobAttempted, "recorded_kill_on_close", recordedKillOnClose, "cleanup_deadline", cleanupDeadline.ToString(CultureInfo.InvariantCulture), "reason", reason));

                while (NativeApi.GetTickCount64() < cleanupDeadline)
                {
                    bool survivor = identity.MatchesCurrent();
                    if (!survivor)
                    {
                        foreach (ProcessIdentity target in targets) if (target.MatchesCurrent()) { survivor = true; break; }
                    }
                    uint jobRemaining = job.ActiveProcesses;
                    if (!survivor && jobRemaining == 0) break;
                    Thread.Sleep(10);
                }

                bool topSurvived = identity.MatchesCurrent();
                List<Dictionary<string, object>> survivors = new List<Dictionary<string, object>>();
                foreach (ProcessIdentity target in targets) if (target.MatchesCurrent()) survivors.Add(target.ToRecord());
                uint remaining = job.ActiveProcesses;
                if ((topSurvived || survivors.Count != 0 || remaining != 0) && !job.IsClosed)
                {
                    job.CloseForRecordedKillOnClose();
                    recordedKillOnClose = true;
                    journal.Append("owned_cleanup_recorded_kill_on_close", Record.Map("label", label, "verified_targets", targetRecords, "survivors_before_close", survivors, "top_survived", topSurvived, "remaining_job_processes", remaining, "reason", "primary_cleanup_incomplete", "close_completed", true));
                    while (NativeApi.GetTickCount64() < cleanupDeadline)
                    {
                        topSurvived = identity.MatchesCurrent();
                        survivors.Clear();
                        foreach (ProcessIdentity target in targets) if (target.MatchesCurrent()) survivors.Add(target.ToRecord());
                        if (!topSurvived && survivors.Count == 0) break;
                        Thread.Sleep(10);
                    }
                    remaining = 0;
                }
                topSurvived = identity.MatchesCurrent();
                survivors.Clear();
                foreach (ProcessIdentity target in targets) if (target.MatchesCurrent()) survivors.Add(target.ToRecord());
                if (topSurvived || survivors.Count != 0 || remaining != 0)
                {
                    journal.Append("owned_cleanup_exit_incomplete", Record.Map("label", label, "deadline", cleanupDeadline.ToString(CultureInfo.InvariantCulture), "top_survived", topSurvived, "survivors", survivors, "remaining_job_processes", remaining, "recorded_kill_on_close", recordedKillOnClose, "reason", reason));
                    throw new ExpectedTerminalException(Contract.TimeoutFail, "Owned child cleanup incomplete: " + label);
                }

                int terminatedExit = process.ExitCode;
                observedExitCode = terminatedExit;
                observedExitCodeAvailable = true;
                FinishStreams(cleanupDeadline);
                remaining = job.ActiveProcesses;
                journal.Append("owned_cleanup_complete", Record.Map("label", label, "identity", identity.ToRecord(), "terminated_exit_code", terminatedExit, "stdout", StdoutEvidence(), "stderr", StderrEvidence(), "remaining_job_processes", remaining, "terminate_job_attempted", terminateJobAttempted, "job_termination_error", jobTerminationError, "recorded_kill_on_close", recordedKillOnClose, "target_inventory_error", inventoryError, "reason", reason));
                if (remaining != 0 || inventoryError != null) throw new ExpectedTerminalException(Contract.TimeoutFail, "Owned job cleanup evidence incomplete: " + label);
            }
            catch (ExpectedTerminalException failure)
            {
                AppendCleanupTerminalFailure(job, failure.Message);
                throw;
            }
            catch (Exception failure)
            {
                AppendCleanupTerminalFailure(job, failure.GetType().FullName + ": " + failure.Message);
                throw new ExpectedTerminalException(Contract.TimeoutFail, "Cleanup mechanism failed: " + failure.Message);
            }
            if (terminalCode == Contract.TimeoutFail) throw new ExpectedTerminalException(Contract.TimeoutFail, reason);
            throw new HarnessException(reason);
        }

        private void FinishStreamsAfterTimeout(string reason)
        {
            if (completed) return;
            ulong cleanupDeadline = checked(NativeApi.GetTickCount64() + Contract.CleanupTimeoutMilliseconds);
            try { FinishStreams(cleanupDeadline); }
            catch (Exception failure)
            {
                journal.Append("owned_stream_cleanup_terminal_failure", Record.Map("label", label, "reason", reason, "failure", failure.GetType().FullName + ": " + failure.Message, "cleanup_deadline", cleanupDeadline.ToString(CultureInfo.InvariantCulture), "stdout", StreamEvidence(stdoutPath, "stdout"), "stderr", StreamEvidence(stderrPath, "stderr")));
                throw new ExpectedTerminalException(Contract.TimeoutFail, "Raw-stream cleanup failed after timeout: " + label);
            }
        }

        private void AppendCleanupTerminalFailure(JobScope job, string failure)
        {
            object active = null;
            string activeError = null;
            try { active = job.ActiveProcesses; }
            catch (Exception inventoryFailure) { activeError = inventoryFailure.GetType().FullName + ": " + inventoryFailure.Message; }
            journal.Append("owned_cleanup_terminal_failure", Record.Map("label", label, "failure", failure, "identity", identity.ToRecord(), "observed_exit_available", observedExitCodeAvailable, "observed_exit_code", observedExitCodeAvailable ? (object)observedExitCode : null, "raw_streams_completed", completed, "stdout", StreamEvidence(stdoutPath, "stdout"), "stderr", StreamEvidence(stderrPath, "stderr"), "remaining_job_processes", active, "remaining_job_processes_error", activeError));
        }

        private Dictionary<string, object> StreamEvidence(string path, string stream)
        {
            Dictionary<string, object> result = Record.Map("stream", stream, "path", Path.GetFullPath(path), "exists", File.Exists(path), "stable", completed, "sha256", null, "byte_size", null, "capture_error", null);
            if (!completed) return result;
            try
            {
                FileInfo info = new FileInfo(path);
                result["exists"] = info.Exists;
                result["byte_size"] = info.Exists ? (object)info.Length : null;
                result["sha256"] = info.Exists ? EvidenceIo.Sha256File(path) : null;
            }
            catch (Exception failure) { result["capture_error"] = failure.GetType().FullName + ": " + failure.Message; }
            return result;
        }

        private void FinishStreams(ulong deadline)
        {
            if (completed) return;
            while (!stdoutCopy.IsCompleted || !stderrCopy.IsCompleted)
            {
                if (NativeApi.GetTickCount64() >= deadline) throw new ExpectedTerminalException(Contract.TimeoutFail, "Raw-stream completion timeout: " + label);
                Thread.Sleep(5);
            }
            stdoutCopy.Wait();
            stderrCopy.Wait();
            stdoutFile.Flush(true);
            stderrFile.Flush(true);
            stdoutFile.Dispose();
            stderrFile.Dispose();
            completed = true;
        }

        public void Dispose()
        {
            if (!completed && HasExited)
            {
                try { FinishStreams(checked(NativeApi.GetTickCount64() + Contract.CleanupTimeoutMilliseconds)); }
                catch (Exception failure)
                {
                    try { journal.Append("owned_dispose_stream_failure", Record.Map("label", label, "failure", failure.GetType().FullName + ": " + failure.Message, "stdout", StreamEvidence(stdoutPath, "stdout"), "stderr", StreamEvidence(stderrPath, "stderr"))); }
                    catch { }
                }
            }
            startGate.Dispose();
            process.Dispose();
        }
    }

    public sealed class Arguments
    {
        private readonly Dictionary<string, string> values = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        public static Arguments Parse(string[] args)
        {
            Arguments parsed = new Arguments();
            for (int i = 0; i < args.Length; i++)
            {
                if (!args[i].StartsWith("--", StringComparison.Ordinal)) throw new HarnessException("Unexpected argument: " + args[i]);
                string key = args[i].Substring(2);
                if (i + 1 >= args.Length || args[i + 1].StartsWith("--", StringComparison.Ordinal)) throw new HarnessException("Missing value for --" + key);
                if (parsed.values.ContainsKey(key)) throw new HarnessException("Duplicate argument: --" + key);
                parsed.values[key] = args[++i];
            }
            return parsed;
        }
        public string Required(string key) { string value; if (!values.TryGetValue(key, out value)) throw new HarnessException("Missing --" + key); return value; }
        public string Optional(string key, string fallback) { string value; return values.TryGetValue(key, out value) ? value : fallback; }
        public bool Has(string key) { return values.ContainsKey(key); }
        public void RequireOnly(params string[] allowed)
        {
            HashSet<string> set = new HashSet<string>(allowed, StringComparer.OrdinalIgnoreCase);
            foreach (string key in values.Keys) if (!set.Contains(key)) throw new HarnessException("Argument is not in sealed schema: --" + key);
        }
    }

    public static class RoleGate
    {
        public static void AwaitIfPresent(string[] args)
        {
            string name = null;
            for (int i = 0; i + 1 < args.Length; i++) if (String.Equals(args[i], "--start-gate", StringComparison.OrdinalIgnoreCase)) name = args[i + 1];
            if (String.IsNullOrEmpty(name)) return;
            using (EventWaitHandle gate = EventWaitHandle.OpenExisting(name))
            {
                gate.WaitOne();
            }
        }
    }

    public sealed class RoleContext
    {
        public readonly string Role;
        public readonly string Mode;
        public readonly string Stage;
        public readonly string Output;
        public readonly string JournalPath;
        public readonly string ResultPath;
        public readonly Arguments Args;
        public readonly EvidenceJournal Journal;
        public readonly Dictionary<string, object> CliContractCapture;
        private readonly Dictionary<string, object> durableEvidence = new Dictionary<string, object>(StringComparer.Ordinal);

        public RoleContext(string role, string[] args)
        {
            RoleGate.AwaitIfPresent(args);
            Role = role;
            Args = Arguments.Parse(args);
            Mode = Args.Required("mode").ToUpperInvariant();
            Stage = Path.GetFullPath(Args.Required("stage"));
            HarnessOps.EnsureAllowedStagePath(Stage);
            Output = Path.GetFullPath(Args.Required("out"));
            JournalPath = Path.GetFullPath(Args.Required("journal"));
            ResultPath = Path.GetFullPath(Args.Required("result"));
            string identity = Path.GetFullPath(Args.Required("identity"));
            if (Mode == "PREACK" || Mode == "LIVE")
            {
                HarnessOps.RequirePathUnder(Stage, identity, "identity");
                string basicRunRoot = Role == "runner" ? Output : (Role == "launcher" ? Path.GetFullPath(Path.Combine(Output, "..")) : Path.GetFullPath(Path.Combine(Output, "..", "..")));
                HarnessOps.EnsureAllowedRunEvidencePath(basicRunRoot, Stage);
                HarnessOps.RequirePathUnder(Output, ResultPath, "result");
                HarnessOps.RequirePathUnder(basicRunRoot, JournalPath, "journal");
                CliContractCapture = HarnessOps.SafeCapture("cli_contract", delegate
                {
                    HarnessOps.ValidateArgumentSchema(Role, Mode, Args);
                    HarnessOps.ValidateRolePaths(Role, Mode, Stage, identity, Output, JournalPath, ResultPath);
                    return (object)Record.Map("role", Role, "mode", Mode, "identity", identity, "out", Output, "journal", JournalPath, "result", ResultPath);
                });
            }
            else
            {
                HarnessOps.ValidateArgumentSchema(Role, Mode, Args);
                HarnessOps.ValidateRolePaths(Role, Mode, Stage, identity, Output, JournalPath, ResultPath);
                CliContractCapture = HarnessOps.SafeCapture("cli_contract", delegate { return (object)Record.Map("role", Role, "mode", Mode, "identity", identity, "out", Output, "journal", JournalPath, "result", ResultPath); });
            }
            Directory.CreateDirectory(Output);
            Journal = new EvidenceJournal(JournalPath);
        }

        public int Execute(Func<Dictionary<string, object>> body)
        {
            int code = Contract.HarnessFail;
            string reason = "unclassified";
            Dictionary<string, object> details = new Dictionary<string, object>();
            try
            {
                details = body();
                code = Contract.Pass;
                reason = "completed_pass_path";
            }
            catch (ExpectedTerminalException expected)
            {
                code = expected.Code;
                reason = expected.Message;
                details["expected_terminal"] = true;
            }
            catch (Exception failure)
            {
                code = Contract.HarnessFail;
                reason = failure.GetType().FullName + ": " + failure.Message;
                details["exception"] = failure.ToString();
            }
            if (durableEvidence.Count != 0) details["durable_evidence"] = durableEvidence;
            Dictionary<string, object> result = Record.Map(
                "schema", "mfo.qa.qualification.result.v1",
                "role", Role,
                "mode", Mode,
                "result_code", code,
                "classification", code == 0 ? "Pass" : (code == 20 ? "Blocked" : "Fail"),
                "reason", reason,
                "native_exit_tick", NativeApi.GetTickCount64().ToString(CultureInfo.InvariantCulture),
                "performance_slot_launch_count", 0,
                "details", details);
            try
            {
                Journal.Append("role_result", result);
                EvidenceIo.WriteNewJson(ResultPath, result);
            }
            catch (Exception writeFailure)
            {
                Console.Error.WriteLine(writeFailure.ToString());
                return Contract.HarnessFail;
            }
            return code;
        }

        public void PreserveDurableEvidence(string key, object value)
        {
            durableEvidence[key] = value;
        }
    }

    public static class HarnessOps
    {
        public static string Quote(string value) { return "\"" + value.Replace("\"", "\\\"") + "\""; }

        public static void VerifyIdentityDocument(string documentPath, string stage)
        {
            EnsureAllowedStagePath(stage);
            Dictionary<string, object> root = EvidenceIo.ReadMap(documentPath);
            object stageIdValue;
            if (!root.TryGetValue("stage_id", out stageIdValue) || !String.Equals(Convert.ToString(stageIdValue, CultureInfo.InvariantCulture), Path.GetFileName(Path.GetFullPath(stage)), StringComparison.Ordinal))
                throw new HarnessException("Identity document stage ID mismatch");
            object stagePathValue;
            if (root.TryGetValue("stage_path", out stagePathValue) && !String.Equals(Path.GetFullPath(Convert.ToString(stagePathValue, CultureInfo.InvariantCulture)), Path.GetFullPath(stage), StringComparison.OrdinalIgnoreCase))
                throw new HarnessException("Identity document stage path mismatch");
            object raw;
            if (!root.TryGetValue("sealed_files", out raw)) throw new HarnessException("Identity document lacks sealed_files");
            object[] files = raw as object[];
            if (files == null) throw new HarnessException("sealed_files must be an array");
            foreach (object item in files)
            {
                Dictionary<string, object> entry = Record.AsMap(item);
                string relative = Record.Text(entry, "relative_path").Replace('/', Path.DirectorySeparatorChar);
                string expected = Record.Text(entry, "sha256");
                string path = Path.GetFullPath(Path.Combine(stage, relative));
                if (!File.Exists(path)) throw new HarnessException("Sealed file missing: " + relative);
                string actual = EvidenceIo.Sha256File(path);
                if (!String.Equals(expected, actual, StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Sealed hash mismatch: " + relative);
            }
        }

        public static void EnsureAllowedStagePath(string stage)
        {
            string full = Path.GetFullPath(stage).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            string temp = Path.GetFullPath(Path.GetTempPath()).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            string local = Path.GetFullPath(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData)).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!full.StartsWith(temp, StringComparison.OrdinalIgnoreCase) && !full.StartsWith(local, StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Stage is outside LocalAppData/TEMP");
            if (full.IndexOf("OneDrive", StringComparison.OrdinalIgnoreCase) >= 0) throw new HarnessException("Stage is inside OneDrive");
            if (full.IndexOf("MFO-P2-2A-005", StringComparison.OrdinalIgnoreCase) >= 0) throw new HarnessException("Frozen -005 stage is forbidden");
        }

        public static void RequirePathUnder(string parent, string child, string label)
        {
            string root = Path.GetFullPath(parent).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            string full = Path.GetFullPath(child);
            if (!full.StartsWith(root, StringComparison.OrdinalIgnoreCase)) throw new HarnessException(label + " is outside sealed stage/output root");
        }

        public static void ValidateRolePaths(string role, string mode, string stage, string identity, string output, string journal, string result)
        {
            string runRoot;
            if (mode == "QP_DRYRUN") runRoot = Path.Combine(stage, "preparation", "dryrun-qualified");
            else if (mode == "QP_SELFTEST") runRoot = Path.Combine(stage, "preparation", "selftest-qualified");
            else if (mode == "QP_POWER_INPUT_SMOKE") runRoot = Path.Combine(stage, "preparation", "power-input-smoke-qualified");
            else if (mode == "QP_PREACK_CONTRACT_SELFTEST") runRoot = Path.Combine(stage, "preparation", "preack-contract-selftest-qualified");
            else if (mode == "PREACK" || mode == "LIVE")
            {
                if (role == "runner") runRoot = Path.GetFullPath(output);
                else if (role == "launcher") runRoot = Path.GetFullPath(Path.Combine(output, ".."));
                else if (role == "controller") runRoot = Path.GetFullPath(Path.Combine(output, "..", ".."));
                else throw new HarnessException("Unknown role");
                EnsureAllowedRunEvidencePath(runRoot, stage);
            }
            else throw new HarnessException("Unknown sealed mode");
            string expectedIdentity = (mode == "QP_DRYRUN" || mode == "QP_SELFTEST" || mode == "QP_POWER_INPUT_SMOKE") ? Path.Combine(stage, "config", "component-contract.json") : Path.Combine(stage, "seal", "qualification-manifest.json");
            if (mode != "PREACK" && mode != "LIVE" && !String.Equals(Path.GetFullPath(identity), Path.GetFullPath(expectedIdentity), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Identity document path differs from sealed invocation");
            string expectedOutput = runRoot;
            if (role == "launcher") expectedOutput = Path.Combine(runRoot, "launcher");
            else if (role == "controller") expectedOutput = Path.Combine(runRoot, "launcher", "controller");
            else if (role != "runner") throw new HarnessException("Unknown role");
            if (!String.Equals(Path.GetFullPath(output), Path.GetFullPath(expectedOutput), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Role output path differs from sealed invocation");
            string expectedJournal = Path.Combine(runRoot, "evidence.journal.jsonl");
            if (!String.Equals(Path.GetFullPath(journal), Path.GetFullPath(expectedJournal), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Journal path differs from sealed invocation");
            string expectedResult = Path.Combine(expectedOutput, role + "-result.json");
            if (!String.Equals(Path.GetFullPath(result), Path.GetFullPath(expectedResult), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Result path differs from sealed invocation");
            if (mode == "PREACK" || mode == "LIVE")
            {
                if (role != "runner") RequirePathUnder(runRoot, output, "output");
            }
            else RequirePathUnder(stage, output, "output");
            RequirePathUnder(stage, identity, "identity");
        }

        public static void EnsureAllowedRunEvidencePath(string runRoot, string stage)
        {
            string full = Path.GetFullPath(runRoot).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            string temp = Path.GetFullPath(Path.GetTempPath()).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            string local = Path.GetFullPath(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData)).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            string sealedStage = Path.GetFullPath(stage).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!full.StartsWith(temp, StringComparison.OrdinalIgnoreCase) && !full.StartsWith(local, StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Run evidence root is outside LocalAppData/TEMP");
            if (full.StartsWith(sealedStage, StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Run evidence root is inside the sealed stage");
            if (full.IndexOf("OneDrive", StringComparison.OrdinalIgnoreCase) >= 0) throw new HarnessException("Run evidence root is inside OneDrive");
        }

        public static void ValidateArgumentSchema(string role, string mode, Arguments args)
        {
            List<string> allowed = new List<string>(new string[] { "mode", "stage", "identity", "out", "journal", "result" });
            if (role == "launcher" || role == "controller") allowed.Add("start-gate");
            if (role == "launcher" || role == "controller")
            {
                allowed.Add("runner-pid"); allowed.Add("runner-created"); allowed.Add("runner-image");
            }
            if (role == "controller")
            {
                allowed.Add("launcher-pid"); allowed.Add("launcher-created"); allowed.Add("launcher-image");
            }
            if (mode == "PREACK")
            {
                allowed.Add("stage-id"); allowed.Add("manifest-sha"); allowed.Add("receipt-sha"); allowed.Add("preparation-audit-sha");
            }
            else if (mode == "LIVE")
            {
                string[] live = new string[] { "stage-id", "manifest-sha", "receipt-sha", "preparation-audit-sha", "preack-record", "preack-sha", "preack-evaluation", "preack-evaluation-sha", "preack-tick", "activation", "activation-sha", "activation-evaluation", "activation-evaluation-sha", "baseline-input", "runner-receipt-tick", "launcher-receipt-tick" };
                foreach (string key in live)
                {
                    if (role == "runner" && (key == "activation-sha" || key == "activation-evaluation" || key == "activation-evaluation-sha" || key == "baseline-input" || key == "runner-receipt-tick" || key == "launcher-receipt-tick")) continue;
                    if (role == "launcher" && key == "launcher-receipt-tick") continue;
                    allowed.Add(key);
                }
            }
            args.RequireOnly(allowed.ToArray());
            if (mode == "PREACK" || mode == "LIVE")
            {
                RequireProtocolText(args, "stage-id");
                RequireDigestArgument(args, "manifest-sha");
                RequireDigestArgument(args, "receipt-sha");
                RequireDigestArgument(args, "preparation-audit-sha");
                if (role == "launcher" || role == "controller")
                {
                    RequirePositiveIntArgument(args, "runner-pid");
                    RequirePositiveUInt64Argument(args, "runner-created");
                    RequireProtocolText(args, "runner-image");
                    RequireProtocolText(args, "start-gate");
                }
                if (role == "controller")
                {
                    RequirePositiveIntArgument(args, "launcher-pid");
                    RequirePositiveUInt64Argument(args, "launcher-created");
                    RequireProtocolText(args, "launcher-image");
                }
            }
            if (mode == "LIVE")
            {
                RequireProtocolText(args, "preack-record");
                RequireDigestArgument(args, "preack-sha");
                RequireProtocolText(args, "preack-evaluation");
                RequireDigestArgument(args, "preack-evaluation-sha");
                RequireUInt64Argument(args, "preack-tick");
                RequireProtocolText(args, "activation");
                if (role == "launcher" || role == "controller")
                {
                    RequireDigestArgument(args, "activation-sha");
                    RequireProtocolText(args, "activation-evaluation");
                    RequireDigestArgument(args, "activation-evaluation-sha");
                    RequireUInt32Argument(args, "baseline-input");
                    RequireUInt64Argument(args, "runner-receipt-tick");
                }
                if (role == "controller") RequireUInt64Argument(args, "launcher-receipt-tick");
            }
        }

        private static string RequireProtocolText(Arguments args, string key)
        {
            string value = args.Required(key);
            if (String.IsNullOrEmpty(value) || !String.Equals(value, value.Trim(), StringComparison.Ordinal)) throw new HarnessException("Malformed protocol argument: --" + key);
            return value;
        }

        private static void RequireDigestArgument(Arguments args, string key)
        {
            string value = RequireProtocolText(args, key);
            if (!Regex.IsMatch(value, "\\A[0-9a-fA-F]{64}\\z", RegexOptions.CultureInvariant)) throw new HarnessException("Malformed SHA-256 protocol argument: --" + key);
        }

        private static void RequireUInt64Argument(Arguments args, string key)
        {
            string value = RequireProtocolText(args, key);
            ulong parsed;
            if (!UInt64.TryParse(value, NumberStyles.None, CultureInfo.InvariantCulture, out parsed) || !String.Equals(parsed.ToString(CultureInfo.InvariantCulture), value, StringComparison.Ordinal)) throw new HarnessException("Malformed UInt64 protocol argument: --" + key);
        }

        private static void RequirePositiveUInt64Argument(Arguments args, string key)
        {
            string value = RequireProtocolText(args, key);
            ulong parsed;
            if (!UInt64.TryParse(value, NumberStyles.None, CultureInfo.InvariantCulture, out parsed) || parsed == 0UL || !String.Equals(parsed.ToString(CultureInfo.InvariantCulture), value, StringComparison.Ordinal)) throw new HarnessException("Malformed positive UInt64 protocol argument: --" + key);
        }

        private static void RequireUInt32Argument(Arguments args, string key)
        {
            string value = RequireProtocolText(args, key);
            uint parsed;
            if (!UInt32.TryParse(value, NumberStyles.None, CultureInfo.InvariantCulture, out parsed) || !String.Equals(parsed.ToString(CultureInfo.InvariantCulture), value, StringComparison.Ordinal)) throw new HarnessException("Malformed UInt32 protocol argument: --" + key);
        }

        private static void RequirePositiveIntArgument(Arguments args, string key)
        {
            string value = RequireProtocolText(args, key);
            int parsed;
            if (!Int32.TryParse(value, NumberStyles.None, CultureInfo.InvariantCulture, out parsed) || parsed <= 0 || !String.Equals(parsed.ToString(CultureInfo.InvariantCulture), value, StringComparison.Ordinal)) throw new HarnessException("Malformed positive Int32 protocol argument: --" + key);
        }

        public static List<Dictionary<string, object>> OneDriveInventory()
        {
            List<Dictionary<string, object>> result = new List<Dictionary<string, object>>();
            foreach (Process process in Process.GetProcesses())
            {
                try
                {
                    string name = process.ProcessName;
                    if (name.StartsWith("OneDrive", StringComparison.OrdinalIgnoreCase)) result.Add(Record.Map("name", name + ".exe", "pid", process.Id));
                }
                catch { }
                finally { process.Dispose(); }
            }
            result.Sort(delegate(Dictionary<string, object> a, Dictionary<string, object> b) { return Record.Integer(a, "pid").CompareTo(Record.Integer(b, "pid")); });
            return result;
        }

        public static List<Dictionary<string, object>> ForbiddenRuntimeInventory(string stage)
        {
            List<Dictionary<string, object>> result = new List<Dictionary<string, object>>();
            string[] staged = new string[] { Path.Combine(stage, "executables", "MFO-A.exe"), Path.Combine(stage, "executables", "MFO-B.exe"), Path.Combine(stage, "executables", "MFO-C.exe") };
            foreach (Process process in Process.GetProcesses())
            {
                try
                {
                    string name = process.ProcessName;
                    bool forbiddenName = name.IndexOf("godot", StringComparison.OrdinalIgnoreCase) >= 0 ||
                        name.IndexOf("MaterialFrontier", StringComparison.OrdinalIgnoreCase) >= 0 ||
                        name.IndexOf("material-frontier", StringComparison.OrdinalIgnoreCase) >= 0 ||
                        name.Equals("MFO", StringComparison.OrdinalIgnoreCase) ||
                        name.StartsWith("MFO-A", StringComparison.OrdinalIgnoreCase) ||
                        name.StartsWith("MFO-B", StringComparison.OrdinalIgnoreCase) ||
                        name.StartsWith("MFO-C", StringComparison.OrdinalIgnoreCase) ||
                        name.IndexOf("arena", StringComparison.OrdinalIgnoreCase) >= 0;
                    string image = String.Empty;
                    try { image = NativeApi.ReadIdentity(process).ImagePath; } catch { }
                    bool stagedMatch = false;
                    for (int i = 0; i < staged.Length; i++) if (!String.IsNullOrEmpty(image) && String.Equals(Path.GetFullPath(staged[i]), image, StringComparison.OrdinalIgnoreCase)) stagedMatch = true;
                    if (forbiddenName || stagedMatch) result.Add(Record.Map("name", name, "pid", process.Id, "image_path", image));
                }
                catch { }
                finally { process.Dispose(); }
            }
            return result;
        }

        public static List<Dictionary<string, object>> QaOwnedInventory(string stage)
        {
            List<Dictionary<string, object>> result = new List<Dictionary<string, object>>();
            HashSet<string> roleImages = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            roleImages.Add(Path.GetFullPath(Bin(stage, "MfoQaRunner.exe")));
            roleImages.Add(Path.GetFullPath(Bin(stage, "MfoQaLauncher.exe")));
            roleImages.Add(Path.GetFullPath(Bin(stage, "MfoQaController.exe")));
            roleImages.Add(Path.GetFullPath(Bin(stage, "MfoQaSentinel.exe")));
            foreach (Process process in Process.GetProcesses())
            {
                try
                {
                    ProcessIdentity identity = NativeApi.ReadIdentity(process);
                    if (roleImages.Contains(identity.ImagePath)) result.Add(identity.ToRecord());
                }
                catch { }
                finally { process.Dispose(); }
            }
            result.Sort(delegate(Dictionary<string, object> a, Dictionary<string, object> b) { return Record.Integer(a, "pid").CompareTo(Record.Integer(b, "pid")); });
            return result;
        }

        public static List<Dictionary<string, object>> DescendantInventory(int rootPid)
        {
            List<Dictionary<string, object>> snapshot = NativeApi.ProcessTreeSnapshot();
            HashSet<int> family = new HashSet<int>();
            family.Add(rootPid);
            bool changed = true;
            while (changed)
            {
                changed = false;
                foreach (Dictionary<string, object> entry in snapshot)
                {
                    int pid = Record.Integer(entry, "pid");
                    int parent = Record.Integer(entry, "parent_pid");
                    if (!family.Contains(pid) && family.Contains(parent)) { family.Add(pid); changed = true; }
                }
            }
            List<Dictionary<string, object>> result = new List<Dictionary<string, object>>();
            foreach (Dictionary<string, object> entry in snapshot)
            {
                int pid = Record.Integer(entry, "pid");
                if (pid == rootPid || !family.Contains(pid)) continue;
                try
                {
                    using (Process process = Process.GetProcessById(pid))
                    {
                        ProcessIdentity identity = NativeApi.ReadIdentity(process);
                        Dictionary<string, object> record = identity.ToRecord();
                        record["parent_pid"] = Record.Integer(entry, "parent_pid");
                        record["name"] = Record.Text(entry, "name");
                        record["identity_success"] = true;
                        result.Add(record);
                    }
                }
                catch (Exception failure)
                {
                    result.Add(Record.Map("pid", pid, "parent_pid", Record.Integer(entry, "parent_pid"), "name", Record.Text(entry, "name"), "identity_success", false, "identity_error", failure.GetType().FullName + ": " + failure.Message));
                }
            }
            result.Sort(delegate(Dictionary<string, object> a, Dictionary<string, object> b) { return Record.Integer(a, "pid").CompareTo(Record.Integer(b, "pid")); });
            return result;
        }

        public static int RequireExactDescendantInventory(List<Dictionary<string, object>> inventory, params ProcessIdentity[] expected)
        {
            HashSet<int> expectedPids = new HashSet<int>();
            Dictionary<int, ProcessIdentity> expectedByPid = new Dictionary<int, ProcessIdentity>();
            foreach (ProcessIdentity identity in expected)
            {
                if (!expectedPids.Add(identity.Pid)) throw new HarnessException("Duplicate expected descendant PID");
                expectedByPid.Add(identity.Pid, identity);
            }

            string systemDirectory = Environment.GetFolderPath(Environment.SpecialFolder.System);
            if (String.IsNullOrEmpty(systemDirectory)) throw new HarnessException("Windows system directory unavailable for console-host validation");
            string systemConhost = Path.GetFullPath(Path.Combine(systemDirectory, "conhost.exe"));
            HashSet<int> observedPids = new HashSet<int>();
            HashSet<int> matchedExpectedPids = new HashSet<int>();
            HashSet<int> consoleHostParents = new HashSet<int>();
            foreach (Dictionary<string, object> record in inventory)
            {
                object success;
                if (!record.TryGetValue("identity_success", out success) || !Convert.ToBoolean(success, CultureInfo.InvariantCulture)) throw new HarnessException("Descendant identity capture failed");
                int pid = Record.Integer(record, "pid");
                if (pid <= 0 || !observedPids.Add(pid)) throw new HarnessException("Invalid or duplicate descendant PID");

                ProcessIdentity expectedIdentity;
                if (expectedByPid.TryGetValue(pid, out expectedIdentity))
                {
                    ulong creation = UInt64.Parse(Record.Text(record, "creation_filetime_utc"), CultureInfo.InvariantCulture);
                    string image = Record.Text(record, "image_path");
                    if (creation != expectedIdentity.CreationFileTime ||
                        !String.Equals(image, expectedIdentity.ImagePath, StringComparison.OrdinalIgnoreCase))
                        throw new HarnessException("Expected descendant identity mismatch: " + pid.ToString(CultureInfo.InvariantCulture));
                    matchedExpectedPids.Add(pid);
                    continue;
                }

                string name = Record.Text(record, "name");
                string observedImage = Record.Text(record, "image_path");
                int parentPid = Record.Integer(record, "parent_pid");
                ulong observedCreation = UInt64.Parse(Record.Text(record, "creation_filetime_utc"), CultureInfo.InvariantCulture);
                bool exactConsoleHost = observedCreation != 0 &&
                    String.Equals(name, "conhost.exe", StringComparison.OrdinalIgnoreCase) &&
                    String.Equals(observedImage, systemConhost, StringComparison.OrdinalIgnoreCase) &&
                    expectedPids.Contains(parentPid) &&
                    consoleHostParents.Add(parentPid);
                if (!exactConsoleHost)
                    throw new HarnessException("Unexpected descendant identity: " + pid.ToString(CultureInfo.InvariantCulture));
            }
            if (matchedExpectedPids.Count != expected.Length) throw new HarnessException("Expected descendant identity missing");
            return inventory.Count - expected.Length;
        }

        public static ProcessIdentity IdentityFromArgs(Arguments args, string prefix)
        {
            return new ProcessIdentity(
                Int32.Parse(args.Required(prefix + "-pid"), CultureInfo.InvariantCulture),
                UInt64.Parse(args.Required(prefix + "-created"), CultureInfo.InvariantCulture),
                args.Required(prefix + "-image"));
        }

        public static void RequireExactQaInventory(List<Dictionary<string, object>> inventory, params ProcessIdentity[] expected)
        {
            if (inventory.Count != expected.Length) throw new HarnessException("QA-owned process count mismatch");
            foreach (ProcessIdentity identity in expected)
            {
                bool found = false;
                foreach (Dictionary<string, object> observed in inventory)
                {
                    if (Record.Integer(observed, "pid") == identity.Pid &&
                        UInt64.Parse(Record.Text(observed, "creation_filetime_utc"), CultureInfo.InvariantCulture) == identity.CreationFileTime &&
                        String.Equals(Record.Text(observed, "image_path"), identity.ImagePath, StringComparison.OrdinalIgnoreCase)) found = true;
                }
                if (!found) throw new HarnessException("Expected QA-owned identity missing: " + identity.Pid.ToString(CultureInfo.InvariantCulture));
            }
        }

        public static Dictionary<string, object> PowerAndInput()
        {
            NativeApi.SystemPowerStatus power;
            bool powerOk = NativeApi.GetSystemPowerStatus(out power);
            bool overlayOk;
            uint overlayStatus;
            string overlay = NativeApi.EffectiveOverlayGuid(out overlayOk, out overlayStatus);
            bool inputOk;
            int inputError;
            uint lastInput = NativeApi.ReadLastInput(out inputOk, out inputError);
            return Record.Map(
                "power_api_success", powerOk,
                "ac_line_status", powerOk ? (int)power.ACLineStatus : -1,
                "overlay_api_success", overlayOk,
                "overlay_native_status", overlayStatus,
                "effective_overlay_guid", overlay,
                "last_input_api_success", inputOk,
                "last_input_native_error", inputError,
                "last_input_dwtime_uint32", lastInput.ToString(CultureInfo.InvariantCulture));
        }

        public static void PersistThenCheckDeadline(EvidenceJournal journal, ulong now, ulong deadline, string scenario)
        {
            bool expired = now >= deadline;
            if (expired)
            {
                journal.Append("deadline_check", Record.Map("scenario", scenario, "now", now.ToString(CultureInfo.InvariantCulture), "deadline", deadline.ToString(CultureInfo.InvariantCulture), "expired", true));
                throw new ExpectedTerminalException(Contract.TimeoutFail, "deadline_expired:" + scenario);
            }
        }

        public static void PersistThenCheckOneDrive(EvidenceJournal journal, List<Dictionary<string, object>> inventory, string scenario)
        {
            journal.Append("onedrive_prerequisite", Record.Map("scenario", scenario, "count", inventory.Count, "processes", inventory));
            if (inventory.Count != 0) throw new ExpectedTerminalException(Contract.Blocked, "onedrive_present:" + scenario);
        }

        public static void RequireResult(string resultPath, int processExit, string expectedRole, string expectedMode)
        {
            if (!File.Exists(resultPath)) throw new HarnessException("Missing structured result: " + resultPath);
            Dictionary<string, object> result = EvidenceIo.ReadMap(resultPath);
            int recorded = Record.Integer(result, "result_code");
            if (recorded != processExit) throw new HarnessException("Exit/result disagreement");
            if (recorded != 0 && recorded != 20 && recorded != 30 && recorded != 31) throw new HarnessException("Unknown shared result code");
            if (!String.Equals(Record.Text(result, "schema"), "mfo.qa.qualification.result.v1", StringComparison.Ordinal) ||
                !String.Equals(Record.Text(result, "role"), expectedRole, StringComparison.Ordinal) ||
                !String.Equals(Record.Text(result, "mode"), expectedMode, StringComparison.Ordinal)) throw new HarnessException("Structured result schema/role/mode mismatch");
            string expectedClass = recorded == 0 ? "Pass" : (recorded == 20 ? "Blocked" : "Fail");
            if (!String.Equals(Record.Text(result, "classification"), expectedClass, StringComparison.Ordinal)) throw new HarnessException("Structured result classification mismatch");
            if (Record.Integer(result, "performance_slot_launch_count") != 0) throw new HarnessException("Structured result performance slot count was nonzero");
        }

        public static Dictionary<string, object> SafeFileEvidence(string path, bool stable)
        {
            string fullPath = Path.GetFullPath(path);
            Dictionary<string, object> result = Record.Map("path", fullPath, "exists", File.Exists(fullPath), "stable", stable, "sha256", null, "byte_size", null, "capture_error", null);
            if (!stable) return result;
            try
            {
                FileInfo info = new FileInfo(fullPath);
                result["exists"] = info.Exists;
                result["byte_size"] = info.Exists ? (object)info.Length : null;
                result["sha256"] = info.Exists ? EvidenceIo.Sha256File(fullPath) : null;
            }
            catch (Exception failure) { result["capture_error"] = failure.GetType().FullName + ": " + failure.Message; }
            return result;
        }

        public static Dictionary<string, object> CaptureResultValidation(string resultPath, int processExit, string expectedRole, string expectedMode, bool validate)
        {
            Dictionary<string, object> file = SafeFileEvidence(resultPath, true);
            bool valid = false;
            string validationError = null;
            if (validate)
            {
                try { RequireResult(resultPath, processExit, expectedRole, expectedMode); valid = true; }
                catch (Exception failure) { validationError = failure.GetType().FullName + ": " + failure.Message; }
            }
            return Record.Map("file", file, "validation_required", validate, "valid", valid, "validation_error", validationError, "expected_role", expectedRole, "expected_mode", expectedMode, "expected_process_exit", processExit);
        }

        public static Dictionary<string, object> SafeCapture(string label, Func<object> capture)
        {
            try { return Record.Map("label", label, "success", true, "value", capture(), "error", null); }
            catch (Exception failure) { return Record.Map("label", label, "success", false, "value", null, "error", failure.GetType().FullName + ": " + failure.Message); }
        }

        public static bool CaptureSucceeded(Dictionary<string, object> capture)
        {
            return Convert.ToBoolean(capture["success"], CultureInfo.InvariantCulture);
        }

        public static Dictionary<string, object> CaptureJsonDocument(string label, string path)
        {
            return SafeCapture(label, delegate
            {
                string full = Path.GetFullPath(path);
                byte[] bytes = File.ReadAllBytes(full);
                Dictionary<string, object> document = Record.AsMap(Record.Parse(Encoding.UTF8.GetString(bytes)));
                return (object)Record.Map(
                    "path", full,
                    "exists", true,
                    "observed_sha256", EvidenceIo.Sha256Bytes(bytes),
                    "byte_size", bytes.Length,
                    "document", document);
            });
        }

        public static Dictionary<string, object> CapturePreackRuntime(string stage, Dictionary<string, object> runnerIdentityCapture, Dictionary<string, object> launcherIdentityCapture)
        {
            return SafeCapture("runtime_ownership_inventory", delegate
            {
                Dictionary<string, object> runner = CaptureValueMap(runnerIdentityCapture);
                int runnerPid = Record.Integer(runner, "pid");
                List<Dictionary<string, object>> forbidden = ForbiddenRuntimeInventory(stage);
                List<Dictionary<string, object>> qa = QaOwnedInventory(stage);
                List<Dictionary<string, object>> descendants = DescendantInventory(runnerPid);
                return (object)Record.Map(
                    "forbidden_runtime_count", forbidden.Count,
                    "forbidden_runtime_processes", forbidden,
                    "qa_owned_processes", qa,
                    "runner_descendant_inventory", descendants,
                    "owned_qa_role_count_excluding_runner_launcher", qa.Count - 2,
                    "runner_identity_capture", runnerIdentityCapture,
                    "launcher_identity_capture", launcherIdentityCapture);
            });
        }

        public static Dictionary<string, object> BuildPreackPendingObservation(
            string stage,
            string manifestPath,
            string suppliedStageId,
            string suppliedManifestSha,
            string suppliedReceiptSha,
            string suppliedPreparationAuditSha,
            string receiptPath,
            string preparationAuditPath,
            string pendingPath,
            string invocation,
            Dictionary<string, object> runnerIdentityCapture,
            Dictionary<string, object> launcherIdentityCapture,
            Dictionary<string, object> oneDriveCapture,
            Dictionary<string, object> powerInputCapture,
            Dictionary<string, object> runtimeCapture,
            Dictionary<string, object> nativeTickCapture,
            Dictionary<string, object> cliContractCapture)
        {
            if (oneDriveCapture == null)
            {
                oneDriveCapture = SafeCapture("onedrive_inventory", delegate
                {
                    List<Dictionary<string, object>> inventory = OneDriveInventory();
                    return (object)Record.Map("count", inventory.Count, "processes", inventory);
                });
            }
            if (powerInputCapture == null) powerInputCapture = SafeCapture("power_input", delegate { return (object)PowerAndInput(); });
            if (runtimeCapture == null) runtimeCapture = CapturePreackRuntime(stage, runnerIdentityCapture, launcherIdentityCapture);
            if (nativeTickCapture == null) nativeTickCapture = SafeCapture("native_tick", delegate { return (object)Record.Map("value", NativeApi.GetTickCount64().ToString(CultureInfo.InvariantCulture)); });
            Dictionary<string, object> invocationCapture = SafeCapture("sealed_invocation", delegate
            {
                return (object)Record.Map(
                    "mode", "PREACK",
                    "command_line", invocation,
                    "stage_path", Path.GetFullPath(stage),
                    "manifest_path", Path.GetFullPath(manifestPath),
                    "receipt_path", Path.GetFullPath(receiptPath),
                    "preparation_audit_path", Path.GetFullPath(preparationAuditPath),
                    "supplied_stage_id", suppliedStageId,
                    "supplied_manifest_sha256", suppliedManifestSha,
                    "supplied_receipt_sha256", suppliedReceiptSha,
                    "supplied_preparation_audit_sha256", suppliedPreparationAuditSha);
            });
            Dictionary<string, object> stageManifestCapture = SafeCapture("stage_manifest_component_source_invocation", delegate
            {
                Dictionary<string, object> file = CaptureValueMap(CaptureJsonDocument("manifest_document", manifestPath));
                return (object)Record.Map(
                    "stage_path", Path.GetFullPath(stage),
                    "observed_stage_id", Path.GetFileName(Path.GetFullPath(stage)),
                    "manifest_file", file);
            });
            return Record.Map(
                "schema", Contract.PreackPendingSchema,
                "evaluation", "pending",
                "work_order_protocol", Contract.WorkOrder,
                "pending_observation_path", Path.GetFullPath(pendingPath),
                "cli_contract_capture", cliContractCapture,
                "invocation_capture", invocationCapture,
                "stage_manifest_component_source_invocation_capture", stageManifestCapture,
                "preparation_receipt_capture", CaptureJsonDocument("preparation_receipt", receiptPath),
                "preparation_audit_capture", CaptureJsonDocument("preparation_audit", preparationAuditPath),
                "onedrive_capture", oneDriveCapture,
                "power_input_capture", powerInputCapture,
                "runtime_ownership_capture", runtimeCapture,
                "runner_identity_capture", runnerIdentityCapture,
                "launcher_identity_capture", launcherIdentityCapture,
                "native_tick_capture", nativeTickCapture,
                "performance_slot_capture", SafeCapture("performance_slot", delegate { return (object)Record.Map("performance_slot_launch_count", 0); }));
        }

        public static Dictionary<string, object> PersistCompletePendingObservation(EvidenceJournal journal, string pendingPath, Dictionary<string, object> pending)
        {
            return PersistCompleteObservation(journal, "preack_pending_observation", pendingPath, pending, new string[]
            {
                "schema", "evaluation", "work_order_protocol", "pending_observation_path", "cli_contract_capture", "invocation_capture",
                "stage_manifest_component_source_invocation_capture", "preparation_receipt_capture", "preparation_audit_capture",
                "onedrive_capture", "power_input_capture", "runtime_ownership_capture", "runner_identity_capture",
                "launcher_identity_capture", "native_tick_capture", "performance_slot_capture"
            }, Contract.PreackPendingSchema);
        }

        public static Dictionary<string, object> PersistCompleteObservation(EvidenceJournal journal, string journalKind, string observationPath, Dictionary<string, object> observation, string[] requiredFields, string requiredSchema)
        {
            string full = Path.GetFullPath(observationPath);
            journal.Append(journalKind, observation);
            EvidenceIo.WriteNewJson(full, observation);
            byte[] bytes = File.ReadAllBytes(full);
            Dictionary<string, object> readback = Record.AsMap(Record.Parse(Encoding.UTF8.GetString(bytes)));
            bool complete = true;
            for (int i = 0; i < requiredFields.Length; i++) if (!readback.ContainsKey(requiredFields[i]) || readback[requiredFields[i]] == null) complete = false;
            complete = complete && String.Equals(SafeText(readback, "schema"), requiredSchema, StringComparison.Ordinal) && String.Equals(SafeText(readback, "evaluation"), "pending", StringComparison.Ordinal);
            if (!complete) throw new HarnessException("Pending observation readback lacked the complete required field set");
            if (!String.Equals(Record.Json(observation), Record.Json(readback), StringComparison.Ordinal)) throw new HarnessException("Pending observation semantic readback mismatch");
            return Record.Map("pending_path", full, "pending_sha256", EvidenceIo.Sha256Bytes(bytes), "readback_success", true, "field_completeness_success", true);
        }

        public static bool HasCompletePendingFieldSet(Dictionary<string, object> pending)
        {
            string[] required = new string[]
            {
                "schema", "evaluation", "work_order_protocol", "pending_observation_path", "cli_contract_capture", "invocation_capture",
                "stage_manifest_component_source_invocation_capture", "preparation_receipt_capture", "preparation_audit_capture",
                "onedrive_capture", "power_input_capture", "runtime_ownership_capture", "runner_identity_capture",
                "launcher_identity_capture", "native_tick_capture", "performance_slot_capture"
            };
            for (int i = 0; i < required.Length; i++) if (!pending.ContainsKey(required[i]) || pending[required[i]] == null) return false;
            return String.Equals(SafeText(pending, "schema"), Contract.PreackPendingSchema, StringComparison.Ordinal) &&
                String.Equals(SafeText(pending, "evaluation"), "pending", StringComparison.Ordinal);
        }

        public static Dictionary<string, object> EvaluatePersistedPreackObservation(
            EvidenceJournal journal,
            string evaluationPath,
            Dictionary<string, object> persisted,
            string stage,
            string manifestPath,
            string expectedStageId,
            string expectedManifestSha,
            string expectedReceiptSha,
            string expectedPreparationAuditSha,
            string expectedReceiptPath,
            string expectedPreparationAuditPath,
            bool launcherExpected)
        {
            string pendingPath = Record.Text(persisted, "pending_path");
            string pendingSha = Record.Text(persisted, "pending_sha256");
            byte[] pendingBytes = File.ReadAllBytes(pendingPath);
            Dictionary<string, object> pending = Record.AsMap(Record.Parse(Encoding.UTF8.GetString(pendingBytes)));
            bool readback = EvidenceIo.Sha256Bytes(pendingBytes).Equals(pendingSha, StringComparison.OrdinalIgnoreCase);
            bool complete = HasCompletePendingFieldSet(pending);

            Dictionary<string, object> cliCapture = CaptureMap(pending, "cli_contract_capture");
            Dictionary<string, object> cli = CaptureValueMapOrEmpty(cliCapture);
            Dictionary<string, object> invocationCapture = CaptureMap(pending, "invocation_capture");
            Dictionary<string, object> invocation = CaptureValueMapOrEmpty(invocationCapture);
            Dictionary<string, object> stageCapture = CaptureMap(pending, "stage_manifest_component_source_invocation_capture");
            Dictionary<string, object> stageValue = CaptureValueMapOrEmpty(stageCapture);
            Dictionary<string, object> manifestFile = MapOrEmpty(stageValue, "manifest_file");
            Dictionary<string, object> manifestDocument = MapOrEmpty(manifestFile, "document");
            Dictionary<string, object> receiptCapture = CaptureMap(pending, "preparation_receipt_capture");
            Dictionary<string, object> receiptFile = CaptureValueMapOrEmpty(receiptCapture);
            Dictionary<string, object> receipt = MapOrEmpty(receiptFile, "document");
            Dictionary<string, object> auditCapture = CaptureMap(pending, "preparation_audit_capture");
            Dictionary<string, object> auditFile = CaptureValueMapOrEmpty(auditCapture);
            Dictionary<string, object> audit = MapOrEmpty(auditFile, "document");
            Dictionary<string, object> oneDriveCapture = CaptureMap(pending, "onedrive_capture");
            Dictionary<string, object> oneDrive = CaptureValueMapOrEmpty(oneDriveCapture);
            Dictionary<string, object> hostCapture = CaptureMap(pending, "power_input_capture");
            Dictionary<string, object> host = CaptureValueMapOrEmpty(hostCapture);
            Dictionary<string, object> runtimeCapture = CaptureMap(pending, "runtime_ownership_capture");
            Dictionary<string, object> runtime = CaptureValueMapOrEmpty(runtimeCapture);
            Dictionary<string, object> tickCapture = CaptureMap(pending, "native_tick_capture");
            Dictionary<string, object> tick = CaptureValueMapOrEmpty(tickCapture);
            Dictionary<string, object> slotCapture = CaptureMap(pending, "performance_slot_capture");
            Dictionary<string, object> slot = CaptureValueMapOrEmpty(slotCapture);

            string fixedReceiptPath = Path.GetFullPath(expectedReceiptPath);
            string fixedAuditPath = Path.GetFullPath(expectedPreparationAuditPath);
            bool stageMatch = String.Equals(SafeText(invocation, "supplied_stage_id"), expectedStageId, StringComparison.Ordinal) &&
                String.Equals(SafeText(stageValue, "observed_stage_id"), expectedStageId, StringComparison.Ordinal) &&
                String.Equals(SafeText(manifestDocument, "stage_id"), expectedStageId, StringComparison.Ordinal);
            bool manifestMatch = CaptureSucceededNoThrow(stageCapture) &&
                String.Equals(Path.GetFullPath(manifestPath), Path.GetFullPath(Path.Combine(stage, "seal", "qualification-manifest.json")), StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(manifestFile, "path"), Path.GetFullPath(manifestPath), StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(manifestFile, "observed_sha256"), expectedManifestSha, StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(invocation, "supplied_manifest_sha256"), expectedManifestSha, StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(manifestDocument, "schema"), Contract.ManifestSchema, StringComparison.Ordinal) &&
                String.Equals(SafeText(manifestDocument, "work_order"), Contract.WorkOrder, StringComparison.Ordinal) &&
                String.Equals(SafeText(manifestDocument, "stage_path"), Path.GetFullPath(stage), StringComparison.OrdinalIgnoreCase);
            bool receiptMatch = CaptureSucceededNoThrow(receiptCapture) &&
                String.Equals(SafeText(receiptFile, "path"), fixedReceiptPath, StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(invocation, "receipt_path"), fixedReceiptPath, StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(invocation, "supplied_receipt_sha256"), expectedReceiptSha, StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(receiptFile, "observed_sha256"), expectedReceiptSha, StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(receipt, "schema"), Contract.ReceiptSchema, StringComparison.Ordinal) &&
                String.Equals(SafeText(receipt, "work_order"), Contract.WorkOrder, StringComparison.Ordinal) &&
                String.Equals(SafeText(receipt, "stage_id"), expectedStageId, StringComparison.Ordinal) &&
                String.Equals(SafeText(receipt, "manifest_path"), Path.GetFullPath(manifestPath), StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(receipt, "manifest_sha256"), expectedManifestSha, StringComparison.OrdinalIgnoreCase) &&
                SafeBoolean(receipt, "sealed", false) && SafeInteger(receipt, "performance_slot_launch_count", -1) == 0 &&
                !SafeBoolean(receipt, "p95_produced", true) && !SafeBoolean(receipt, "kbm_performed", true) && !SafeBoolean(receipt, "abc_launched", true);
            bool auditMatch = CaptureSucceededNoThrow(auditCapture) &&
                String.Equals(SafeText(auditFile, "path"), fixedAuditPath, StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(invocation, "preparation_audit_path"), fixedAuditPath, StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(invocation, "supplied_preparation_audit_sha256"), expectedPreparationAuditSha, StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(auditFile, "observed_sha256"), expectedPreparationAuditSha, StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(audit, "schema"), Contract.PreparationAuditSchema, StringComparison.Ordinal) &&
                String.Equals(SafeText(audit, "work_order"), Contract.WorkOrder, StringComparison.Ordinal) &&
                String.Equals(SafeText(audit, "stage_id"), expectedStageId, StringComparison.Ordinal) &&
                String.Equals(SafeText(audit, "manifest_path"), Path.GetFullPath(manifestPath), StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(audit, "manifest_sha256"), expectedManifestSha, StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(audit, "receipt_path"), fixedReceiptPath, StringComparison.OrdinalIgnoreCase) &&
                String.Equals(SafeText(audit, "receipt_sha256"), expectedReceiptSha, StringComparison.OrdinalIgnoreCase) &&
                SafeBoolean(audit, "all_tests_passed", false) && SafeInteger(audit, "performance_slot_launch_count", -1) == 0 &&
                !SafeBoolean(audit, "p95_produced", true) && !SafeBoolean(audit, "kbm_performed", true) && !SafeBoolean(audit, "abc_launched", true);

            string cliRole = SafeText(cli, "role");
            string runEvidenceRoot = SafeText(manifestDocument, "run_evidence_root");
            bool cliPathMatch = CaptureSucceededNoThrow(cliCapture);
            if (String.Equals(cliRole, "runner", StringComparison.Ordinal) || String.Equals(cliRole, "launcher", StringComparison.Ordinal))
            {
                string preackRoot = String.IsNullOrEmpty(runEvidenceRoot) ? String.Empty : Path.GetFullPath(Path.Combine(runEvidenceRoot, "preack-001"));
                string expectedOutput = String.Equals(cliRole, "runner", StringComparison.Ordinal) ? preackRoot : Path.Combine(preackRoot, "launcher");
                cliPathMatch = cliPathMatch && !String.IsNullOrEmpty(preackRoot) &&
                    String.Equals(SafeText(cli, "identity"), Path.GetFullPath(Path.Combine(stage, "seal", "qualification-manifest.json")), StringComparison.OrdinalIgnoreCase) &&
                    String.Equals(SafeText(cli, "out"), Path.GetFullPath(expectedOutput), StringComparison.OrdinalIgnoreCase) &&
                    String.Equals(SafeText(cli, "journal"), Path.Combine(preackRoot, "evidence.journal.jsonl"), StringComparison.OrdinalIgnoreCase) &&
                    String.Equals(SafeText(cli, "result"), Path.Combine(expectedOutput, cliRole + "-result.json"), StringComparison.OrdinalIgnoreCase);
            }
            else if (!String.Equals(cliRole, "fixture", StringComparison.Ordinal)) cliPathMatch = false;

            Dictionary<string, object> fileAuditCapture = SafeCapture("post_pending_file_identity_audit", delegate { return (object)FileSetAudit(manifestPath, stage); });
            bool fileAuditMatch = CaptureSucceededNoThrow(fileAuditCapture) && String.Equals(SafeText(CaptureValueMapOrEmpty(fileAuditCapture), "identity_document_sha256"), expectedManifestSha, StringComparison.OrdinalIgnoreCase);
            bool runtimeMatch = EvaluateRawRuntimeAfterPending(runtime, CaptureMap(pending, "runner_identity_capture"), CaptureMap(pending, "launcher_identity_capture"), launcherExpected);
            bool tickMatch = CaptureSucceededNoThrow(tickCapture) && SafeUInt64(tick, "value", 0UL) != 0UL;
            bool slotMatch = CaptureSucceededNoThrow(slotCapture) && SafeInteger(slot, "performance_slot_launch_count", -1) == 0;
            bool oneDriveMatch = CaptureSucceededNoThrow(oneDriveCapture) && SafeInteger(oneDrive, "count", -1) == 0;
            bool hostApiMatch = CaptureSucceededNoThrow(hostCapture) && SafeBoolean(host, "power_api_success", false) && SafeBoolean(host, "overlay_api_success", false) && SafeBoolean(host, "last_input_api_success", false);
            bool hostValueMatch = hostApiMatch && SafeInteger(host, "ac_line_status", -1) == 1 && String.Equals(SafeText(host, "effective_overlay_guid"), Contract.BestPerformanceGuid, StringComparison.OrdinalIgnoreCase);
            bool captureMechanismMatch = readback && complete && cliPathMatch && CaptureSucceededNoThrow(invocationCapture) && CaptureSucceededNoThrow(stageCapture) && CaptureSucceededNoThrow(receiptCapture) && CaptureSucceededNoThrow(auditCapture) && CaptureSucceededNoThrow(runtimeCapture) && CaptureSucceededNoThrow(tickCapture) && CaptureSucceededNoThrow(slotCapture);
            bool mechanismPass = captureMechanismMatch && stageMatch && manifestMatch && receiptMatch && auditMatch && fileAuditMatch && runtimeMatch && tickMatch && slotMatch;
            int code = mechanismPass ? ((oneDriveMatch && hostValueMatch) ? Contract.Pass : Contract.Blocked) : Contract.HarnessFail;
            string reason = code == Contract.Pass ? "preack_contract_pass" : (code == Contract.Blocked ? "host_prerequisite_unavailable_after_durable_pending" : "preack_contract_identity_or_persistence_failure");
            Dictionary<string, object> matches = Record.Map(
                "stage", stageMatch,
                "cli_and_external_run_paths", cliPathMatch,
                "manifest", manifestMatch,
                "preparation_receipt", receiptMatch,
                "preparation_audit", auditMatch,
                "sealed_file_identity", fileAuditMatch,
                "runtime_ownership", runtimeMatch,
                "native_tick_nonzero", tickMatch,
                "performance_slot_zero", slotMatch,
                "onedrive_zero", oneDriveMatch,
                "host_api_success", hostApiMatch,
                "host_values", hostValueMatch);
            Dictionary<string, object> evaluation = Record.Map(
                "schema", Contract.PreackEvaluationSchema,
                "evaluation", "complete",
                "work_order", Contract.WorkOrder,
                "pending_observation_path", pendingPath,
                "pending_sha256", pendingSha,
                "pending_readback_success", readback,
                "pending_field_completeness_success", complete,
                "field_matches", matches,
                "post_pending_file_identity_audit_capture", fileAuditCapture,
                "classification", code == Contract.Pass ? "Pass" : (code == Contract.Blocked ? "Blocked" : "Fail"),
                "result_code", code,
                "terminal_reason", reason,
                "performance_slot_launch_count", 0);
            journal.Append("preack_evaluation", evaluation);
            EvidenceIo.WriteNewJson(evaluationPath, evaluation);
            return Record.Map(
                "evaluation_path", Path.GetFullPath(evaluationPath),
                "evaluation_sha256", EvidenceIo.Sha256File(evaluationPath),
                "result_code", code,
                "terminal_reason", reason,
                "field_matches", matches);
        }

        public static Dictionary<string, object> CaptureRawFile(string label, string path)
        {
            return SafeCapture(label, delegate
            {
                string full = Path.GetFullPath(path);
                byte[] bytes = File.ReadAllBytes(full);
                return (object)Record.Map("path", full, "exists", true, "observed_sha256", EvidenceIo.Sha256Bytes(bytes), "byte_size", bytes.Length, "utf8_text", Encoding.UTF8.GetString(bytes));
            });
        }

        public static Dictionary<string, object> BuildLiveActivationPendingObservation(
            string pendingPath,
            string stage,
            string manifestPath,
            string receiptPath,
            string preparationAuditPath,
            string preackPath,
            string preackEvaluationPath,
            string activationPath,
            string stageId,
            string manifestSha,
            string receiptSha,
            string preparationAuditSha,
            string preackSha,
            string preackEvaluationSha,
            string preackTick,
            string invocation,
            Dictionary<string, object> runnerIdentityCapture,
            Dictionary<string, object> runtimeCapture,
            Dictionary<string, object> oneDriveCapture,
            Dictionary<string, object> powerInputCapture,
            Dictionary<string, object> nativeTickCapture,
            Dictionary<string, object> cliContractCapture)
        {
            if (oneDriveCapture == null)
            {
                oneDriveCapture = SafeCapture("live_runner_onedrive", delegate
                {
                    List<Dictionary<string, object>> inventory = OneDriveInventory();
                    return (object)Record.Map("count", inventory.Count, "processes", inventory);
                });
            }
            if (powerInputCapture == null) powerInputCapture = SafeCapture("live_runner_power_input", delegate { return (object)PowerAndInput(); });
            if (nativeTickCapture == null) nativeTickCapture = SafeCapture("live_runner_receipt_tick", delegate { return (object)Record.Map("value", NativeApi.GetTickCount64().ToString(CultureInfo.InvariantCulture)); });
            if (runtimeCapture == null)
            {
                runtimeCapture = SafeCapture("live_runner_runtime", delegate
                {
                    Dictionary<string, object> runner = CaptureValueMap(runnerIdentityCapture);
                    int runnerPid = Record.Integer(runner, "pid");
                    List<Dictionary<string, object>> forbidden = ForbiddenRuntimeInventory(stage);
                    List<Dictionary<string, object>> qa = QaOwnedInventory(stage);
                    List<Dictionary<string, object>> descendants = DescendantInventory(runnerPid);
                    return (object)Record.Map("forbidden_runtime_count", forbidden.Count, "forbidden_runtime_processes", forbidden, "qa_owned_processes", qa, "runner_descendant_inventory", descendants, "owned_qa_role_count_excluding_runner", qa.Count - 1);
                });
            }
            return Record.Map(
                "schema", Contract.ActivationPendingSchema,
                "evaluation", "pending",
                "work_order_protocol", Contract.WorkOrder,
                "pending_observation_path", Path.GetFullPath(pendingPath),
                "cli_contract_capture", cliContractCapture,
                "invocation_capture", SuccessfulRawCapture("live_runner_invocation", Record.Map(
                    "command_line", invocation,
                    "stage_path", Path.GetFullPath(stage),
                    "manifest_path", Path.GetFullPath(manifestPath),
                    "receipt_path", Path.GetFullPath(receiptPath),
                    "preparation_audit_path", Path.GetFullPath(preparationAuditPath),
                    "preack_path_raw", preackPath,
                    "preack_path", SafeFullPathText(preackPath),
                    "preack_evaluation_path_raw", preackEvaluationPath,
                    "preack_evaluation_path", SafeFullPathText(preackEvaluationPath),
                    "activation_path_raw", activationPath,
                    "activation_path", SafeFullPathText(activationPath),
                    "supplied_stage_id", stageId,
                    "supplied_manifest_sha256", manifestSha,
                    "supplied_receipt_sha256", receiptSha,
                    "supplied_preparation_audit_sha256", preparationAuditSha,
                    "supplied_preack_sha256", preackSha,
                    "supplied_preack_evaluation_sha256", preackEvaluationSha,
                    "supplied_preack_tick", preackTick)),
                "manifest_capture", CaptureJsonDocument("live_manifest", manifestPath),
                "preparation_receipt_capture", CaptureJsonDocument("live_preparation_receipt", receiptPath),
                "preparation_audit_capture", CaptureJsonDocument("live_preparation_audit", preparationAuditPath),
                "preack_capture", CaptureJsonDocument("live_preack", preackPath),
                "preack_evaluation_capture", CaptureJsonDocument("live_preack_evaluation", preackEvaluationPath),
                "activation_capture", CaptureRawFile("live_activation", activationPath),
                "runner_identity_capture", runnerIdentityCapture,
                "runtime_ownership_capture", runtimeCapture,
                "onedrive_capture", oneDriveCapture,
                "power_input_capture", powerInputCapture,
                "native_tick_capture", nativeTickCapture,
                "performance_slot_capture", SuccessfulRawCapture("performance_slot", Record.Map("performance_slot_launch_count", 0)));
        }

        public static Dictionary<string, object> PersistCompleteActivationObservation(EvidenceJournal journal, string pendingPath, Dictionary<string, object> pending)
        {
            return PersistCompleteObservation(journal, "live_activation_pending_observation", pendingPath, pending, new string[]
            {
                "schema", "evaluation", "work_order_protocol", "pending_observation_path", "cli_contract_capture", "invocation_capture", "manifest_capture",
                "preparation_receipt_capture", "preparation_audit_capture", "preack_capture", "preack_evaluation_capture",
                "activation_capture", "runner_identity_capture", "runtime_ownership_capture", "onedrive_capture", "power_input_capture",
                "native_tick_capture", "performance_slot_capture"
            }, Contract.ActivationPendingSchema);
        }

        public static Dictionary<string, object> EvaluatePersistedActivationObservation(
            EvidenceJournal journal,
            string evaluationPath,
            Dictionary<string, object> persisted,
            string stage,
            string manifestPath,
            string receiptPath,
            string preparationAuditPath,
            string preackPath,
            string preackEvaluationPath,
            string activationPath,
            string stageId,
            string manifestSha,
            string receiptSha,
            string preparationAuditSha,
            string preackSha,
            string preackEvaluationSha,
            string preackTickText,
            bool validateBindings)
        {
            string pendingPath = Record.Text(persisted, "pending_path");
            string pendingSha = Record.Text(persisted, "pending_sha256");
            byte[] bytes = File.ReadAllBytes(pendingPath);
            Dictionary<string, object> pending = Record.AsMap(Record.Parse(Encoding.UTF8.GetString(bytes)));
            bool readback = String.Equals(EvidenceIo.Sha256Bytes(bytes), pendingSha, StringComparison.OrdinalIgnoreCase);
            Dictionary<string, object> cliCapture = CaptureMap(pending, "cli_contract_capture");
            Dictionary<string, object> cli = CaptureValueMapOrEmpty(cliCapture);
            Dictionary<string, object> activationCapture = CaptureMap(pending, "activation_capture");
            Dictionary<string, object> activationFile = CaptureValueMapOrEmpty(activationCapture);
            ulong preackTick;
            bool preackTickValid = UInt64.TryParse(preackTickText, NumberStyles.None, CultureInfo.InvariantCulture, out preackTick) && String.Equals(preackTick.ToString(CultureInfo.InvariantCulture), preackTickText, StringComparison.Ordinal);
            Dictionary<string, object> exactCapture = SafeCapture("exact_activation_validation_after_pending", delegate
            {
                if (!preackTickValid) throw new HarnessException("Malformed PREACK tick protocol field");
                return (object)RequireExactActivation(activationPath, stageId, manifestSha, receiptSha, preparationAuditSha, preackSha, preackEvaluationSha, preackTick);
            });
            bool activationPathMatch = !String.IsNullOrEmpty(SafeFullPathText(activationPath)) && String.Equals(SafeText(activationFile, "path"), SafeFullPathText(activationPath), StringComparison.OrdinalIgnoreCase);
            bool exactActivation = CaptureSucceededNoThrow(exactCapture);
            bool bindingMatch = true;
            Dictionary<string, object> fileAuditCapture = null;
            Dictionary<string, object> host = CaptureValueMapOrEmpty(CaptureMap(pending, "power_input_capture"));
            Dictionary<string, object> oneDrive = CaptureValueMapOrEmpty(CaptureMap(pending, "onedrive_capture"));
            Dictionary<string, object> tick = CaptureValueMapOrEmpty(CaptureMap(pending, "native_tick_capture"));
            ulong runnerTick = SafeUInt64(tick, "value", 0UL);
            bool hostMatch = CaptureSucceededNoThrow(CaptureMap(pending, "power_input_capture")) && SafeBoolean(host, "power_api_success", false) && SafeBoolean(host, "overlay_api_success", false) && SafeBoolean(host, "last_input_api_success", false) && SafeInteger(host, "ac_line_status", -1) == 1 && String.Equals(SafeText(host, "effective_overlay_guid"), Contract.BestPerformanceGuid, StringComparison.OrdinalIgnoreCase);
            bool oneDriveMatch = CaptureSucceededNoThrow(CaptureMap(pending, "onedrive_capture")) && SafeInteger(oneDrive, "count", -1) == 0;
            bool tickMatch = preackTickValid && runnerTick != 0UL && preackTick < runnerTick;
            bool slotMatch = SafeInteger(CaptureValueMapOrEmpty(CaptureMap(pending, "performance_slot_capture")), "performance_slot_launch_count", -1) == 0;
            bool runtimeMatch = EvaluateLiveRunnerRuntimeAfterPending(CaptureValueMapOrEmpty(CaptureMap(pending, "runtime_ownership_capture")), CaptureMap(pending, "runner_identity_capture"));
            bool cliPathMatch = CaptureSucceededNoThrow(cliCapture);
            if (validateBindings)
            {
                Dictionary<string, object> manifestFile = CaptureValueMapOrEmpty(CaptureMap(pending, "manifest_capture"));
                Dictionary<string, object> manifest = MapOrEmpty(manifestFile, "document");
                Dictionary<string, object> receiptFile = CaptureValueMapOrEmpty(CaptureMap(pending, "preparation_receipt_capture"));
                Dictionary<string, object> receipt = MapOrEmpty(receiptFile, "document");
                Dictionary<string, object> auditFile = CaptureValueMapOrEmpty(CaptureMap(pending, "preparation_audit_capture"));
                Dictionary<string, object> audit = MapOrEmpty(auditFile, "document");
                Dictionary<string, object> preackFile = CaptureValueMapOrEmpty(CaptureMap(pending, "preack_capture"));
                Dictionary<string, object> preackEvaluationFile = CaptureValueMapOrEmpty(CaptureMap(pending, "preack_evaluation_capture"));
                Dictionary<string, object> preackEvaluation = MapOrEmpty(preackEvaluationFile, "document");
                Dictionary<string, object> preack = MapOrEmpty(preackFile, "document");
                string observedPreackTick = SafeText(CaptureValueMapOrEmpty(CaptureMap(preack, "native_tick_capture")), "value");
                string runEvidenceRoot = SafeText(manifest, "run_evidence_root");
                string expectedLiveRoot = String.IsNullOrEmpty(runEvidenceRoot) ? String.Empty : Path.GetFullPath(Path.Combine(runEvidenceRoot, "live-001"));
                string expectedPreackRoot = String.IsNullOrEmpty(runEvidenceRoot) ? String.Empty : Path.GetFullPath(Path.Combine(runEvidenceRoot, "preack-001", "launcher"));
                cliPathMatch = cliPathMatch && String.Equals(SafeText(cli, "role"), "runner", StringComparison.Ordinal) && String.Equals(SafeText(cli, "mode"), "LIVE", StringComparison.Ordinal) &&
                    String.Equals(SafeText(cli, "identity"), Path.GetFullPath(Path.Combine(stage, "seal", "qualification-manifest.json")), StringComparison.OrdinalIgnoreCase) &&
                    String.Equals(SafeText(cli, "out"), expectedLiveRoot, StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(cli, "journal"), Path.Combine(expectedLiveRoot, "evidence.journal.jsonl"), StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(cli, "result"), Path.Combine(expectedLiveRoot, "runner-result.json"), StringComparison.OrdinalIgnoreCase);
                fileAuditCapture = SafeCapture("live_post_pending_file_identity_audit", delegate { return (object)FileSetAudit(manifestPath, stage); });
                bindingMatch = CaptureSucceededNoThrow(CaptureMap(pending, "manifest_capture")) && CaptureSucceededNoThrow(CaptureMap(pending, "preparation_receipt_capture")) && CaptureSucceededNoThrow(CaptureMap(pending, "preparation_audit_capture")) && CaptureSucceededNoThrow(CaptureMap(pending, "preack_capture")) && CaptureSucceededNoThrow(CaptureMap(pending, "preack_evaluation_capture")) &&
                    String.Equals(SafeText(manifestFile, "path"), Path.GetFullPath(Path.Combine(stage, "seal", "qualification-manifest.json")), StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(manifestFile, "observed_sha256"), manifestSha, StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(manifest, "schema"), Contract.ManifestSchema, StringComparison.Ordinal) && String.Equals(SafeText(manifest, "work_order"), Contract.WorkOrder, StringComparison.Ordinal) && String.Equals(SafeText(manifest, "stage_id"), stageId, StringComparison.Ordinal) &&
                    String.Equals(SafeFullPathText(activationPath), Path.Combine(expectedLiveRoot, "activation-token.txt"), StringComparison.OrdinalIgnoreCase) &&
                    String.Equals(SafeText(receiptFile, "path"), Path.GetFullPath(Path.Combine(stage, "seal", "preparation-receipt.json")), StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(receiptFile, "observed_sha256"), receiptSha, StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(receipt, "schema"), Contract.ReceiptSchema, StringComparison.Ordinal) && String.Equals(SafeText(receipt, "work_order"), Contract.WorkOrder, StringComparison.Ordinal) && String.Equals(SafeText(receipt, "stage_id"), stageId, StringComparison.Ordinal) && String.Equals(SafeText(receipt, "manifest_sha256"), manifestSha, StringComparison.OrdinalIgnoreCase) && SafeBoolean(receipt, "sealed", false) && SafeInteger(receipt, "performance_slot_launch_count", -1) == 0 && !SafeBoolean(receipt, "p95_produced", true) && !SafeBoolean(receipt, "kbm_performed", true) && !SafeBoolean(receipt, "abc_launched", true) &&
                    String.Equals(SafeText(auditFile, "path"), Path.GetFullPath(Path.Combine(stage, "seal", "preparation-audit.json")), StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(auditFile, "observed_sha256"), preparationAuditSha, StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(audit, "schema"), Contract.PreparationAuditSchema, StringComparison.Ordinal) && String.Equals(SafeText(audit, "work_order"), Contract.WorkOrder, StringComparison.Ordinal) && String.Equals(SafeText(audit, "stage_id"), stageId, StringComparison.Ordinal) && String.Equals(SafeText(audit, "manifest_sha256"), manifestSha, StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(audit, "receipt_sha256"), receiptSha, StringComparison.OrdinalIgnoreCase) &&
                    String.Equals(SafeText(preackFile, "path"), Path.Combine(expectedPreackRoot, "preack-record.json"), StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(preackFile, "observed_sha256"), preackSha, StringComparison.OrdinalIgnoreCase) && String.Equals(observedPreackTick, preackTickText, StringComparison.Ordinal) &&
                    String.Equals(SafeText(preackEvaluationFile, "path"), Path.Combine(expectedPreackRoot, "preack-evaluation.json"), StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(preackEvaluationFile, "observed_sha256"), preackEvaluationSha, StringComparison.OrdinalIgnoreCase) && SafeInteger(preackEvaluation, "result_code", -1) == Contract.Pass &&
                    CaptureSucceededNoThrow(fileAuditCapture);
            }
            bool mechanism = readback && preackTickValid && CaptureSucceededNoThrow(activationCapture) && activationPathMatch && slotMatch && bindingMatch && (cliPathMatch || !validateBindings) && (runtimeMatch || !validateBindings);
            int code = !mechanism ? Contract.HarnessFail : (!exactActivation ? Contract.Blocked : ((hostMatch && oneDriveMatch && tickMatch) || !validateBindings ? Contract.Pass : Contract.Blocked));
            string reason = code == Contract.Pass ? "live_activation_contract_pass" : (code == Contract.Blocked ? (exactActivation ? "host_or_ordering_prerequisite_changed_after_pending" : "invalid_user_activation_acknowledgement") : "live_activation_identity_or_persistence_failure");
            Dictionary<string, object> evaluation = Record.Map(
                "schema", Contract.ActivationEvaluationSchema,
                "evaluation", "complete",
                "work_order", Contract.WorkOrder,
                "pending_observation_path", pendingPath,
                "pending_sha256", pendingSha,
                "pending_readback_success", readback,
                "activation_path_match", activationPathMatch,
                "cli_and_external_run_paths_match", cliPathMatch,
                "exact_activation_match", exactActivation,
                "binding_match", bindingMatch,
                "host_match", hostMatch,
                "onedrive_zero", oneDriveMatch,
                "tick_order_match", tickMatch,
                "protocol_numeric_fields_valid", preackTickValid,
                "runtime_ownership_match", runtimeMatch,
                "performance_slot_zero", slotMatch,
                "exact_activation_capture", exactCapture,
                "post_pending_file_identity_audit_capture", fileAuditCapture,
                "runner_receipt_tick", runnerTick.ToString(CultureInfo.InvariantCulture),
                "baseline_input_dwtime_uint32", SafeText(host, "last_input_dwtime_uint32"),
                "activation_sha256", SafeText(activationFile, "observed_sha256"),
                "classification", code == Contract.Pass ? "Pass" : (code == Contract.Blocked ? "Blocked" : "Fail"),
                "result_code", code,
                "terminal_reason", reason,
                "performance_slot_launch_count", 0);
            journal.Append("live_activation_evaluation", evaluation);
            EvidenceIo.WriteNewJson(evaluationPath, evaluation);
            return Record.Map("evaluation_path", Path.GetFullPath(evaluationPath), "evaluation_sha256", EvidenceIo.Sha256File(evaluationPath), "result_code", code, "terminal_reason", reason, "runner_receipt_tick", evaluation["runner_receipt_tick"], "baseline_input_dwtime_uint32", evaluation["baseline_input_dwtime_uint32"], "activation_sha256", evaluation["activation_sha256"]);
        }

        public static Dictionary<string, object> BuildLauncherLivePendingObservation(
            RoleContext c,
            string manifestPath,
            string pendingPath,
            Dictionary<string, string> fields,
            Dictionary<string, object> runnerIdentityCapture,
            Dictionary<string, object> launcherIdentityCapture,
            Dictionary<string, object> runtimeCapture,
            Dictionary<string, object> nativeTickCapture,
            Dictionary<string, object> cliContractCapture)
        {
            if (runtimeCapture == null) runtimeCapture = CapturePreackRuntime(c.Stage, runnerIdentityCapture, launcherIdentityCapture);
            if (nativeTickCapture == null) nativeTickCapture = SafeCapture("launcher_live_receipt_tick", delegate { return (object)Record.Map("value", NativeApi.GetTickCount64().ToString(CultureInfo.InvariantCulture)); });
            string receiptPath = Path.Combine(c.Stage, "seal", "preparation-receipt.json");
            string auditPath = Path.Combine(c.Stage, "seal", "preparation-audit.json");
            return Record.Map(
                "schema", Contract.ActivationPendingSchema,
                "evaluation", "pending",
                "work_order_protocol", Contract.WorkOrder,
                "pending_observation_path", Path.GetFullPath(pendingPath),
                "cli_contract_capture", cliContractCapture,
                "invocation_capture", SuccessfulRawCapture("launcher_live_invocation", Record.Map(
                    "command_line", Environment.CommandLine,
                    "stage_path", c.Stage,
                    "manifest_path", Path.GetFullPath(manifestPath),
                    "output_path", c.Output,
                    "journal_path", c.JournalPath,
                    "result_path", c.ResultPath,
                    "supplied_fields", new Dictionary<string, string>(fields, StringComparer.Ordinal))),
                "manifest_capture", CaptureJsonDocument("launcher_live_manifest", manifestPath),
                "preparation_receipt_capture", CaptureJsonDocument("launcher_live_preparation_receipt", receiptPath),
                "preparation_audit_capture", CaptureJsonDocument("launcher_live_preparation_audit", auditPath),
                "preack_capture", CaptureJsonDocument("launcher_live_preack", fields["preack-record"]),
                "preack_evaluation_capture", CaptureJsonDocument("launcher_live_preack_evaluation", fields["preack-evaluation"]),
                "activation_capture", CaptureRawFile("launcher_live_activation", fields["activation"]),
                "activation_evaluation_capture", CaptureJsonDocument("launcher_live_activation_evaluation", fields["activation-evaluation"]),
                "runner_identity_capture", runnerIdentityCapture,
                "launcher_identity_capture", launcherIdentityCapture,
                "runtime_ownership_capture", runtimeCapture,
                "native_tick_capture", nativeTickCapture,
                "performance_slot_capture", SuccessfulRawCapture("performance_slot", Record.Map("performance_slot_launch_count", 0)));
        }

        public static Dictionary<string, object> PersistCompleteLauncherLiveObservation(EvidenceJournal journal, string pendingPath, Dictionary<string, object> pending)
        {
            return PersistCompleteObservation(journal, "launcher_live_pending_observation", pendingPath, pending, new string[]
            {
                "schema", "evaluation", "work_order_protocol", "pending_observation_path", "cli_contract_capture", "invocation_capture",
                "manifest_capture", "preparation_receipt_capture", "preparation_audit_capture", "preack_capture", "preack_evaluation_capture",
                "activation_capture", "activation_evaluation_capture", "runner_identity_capture", "launcher_identity_capture",
                "runtime_ownership_capture", "native_tick_capture", "performance_slot_capture"
            }, Contract.ActivationPendingSchema);
        }

        public static Dictionary<string, object> EvaluatePersistedLauncherLiveObservation(
            EvidenceJournal journal,
            string evaluationPath,
            Dictionary<string, object> persisted,
            RoleContext c,
            string manifestPath,
            Dictionary<string, string> fields,
            bool validateBindings)
        {
            string pendingPath = Record.Text(persisted, "pending_path");
            string pendingSha = Record.Text(persisted, "pending_sha256");
            byte[] pendingBytes = File.ReadAllBytes(pendingPath);
            Dictionary<string, object> pending = Record.AsMap(Record.Parse(Encoding.UTF8.GetString(pendingBytes)));
            bool readback = String.Equals(EvidenceIo.Sha256Bytes(pendingBytes), pendingSha, StringComparison.OrdinalIgnoreCase);
            Dictionary<string, object> cliCapture = CaptureMap(pending, "cli_contract_capture");
            Dictionary<string, object> cli = CaptureValueMapOrEmpty(cliCapture);
            Dictionary<string, object> manifestFile = CaptureValueMapOrEmpty(CaptureMap(pending, "manifest_capture"));
            Dictionary<string, object> manifest = MapOrEmpty(manifestFile, "document");
            Dictionary<string, object> receiptFile = CaptureValueMapOrEmpty(CaptureMap(pending, "preparation_receipt_capture"));
            Dictionary<string, object> receipt = MapOrEmpty(receiptFile, "document");
            Dictionary<string, object> auditFile = CaptureValueMapOrEmpty(CaptureMap(pending, "preparation_audit_capture"));
            Dictionary<string, object> audit = MapOrEmpty(auditFile, "document");
            Dictionary<string, object> preackFile = CaptureValueMapOrEmpty(CaptureMap(pending, "preack_capture"));
            Dictionary<string, object> preack = MapOrEmpty(preackFile, "document");
            Dictionary<string, object> preackEvaluationFile = CaptureValueMapOrEmpty(CaptureMap(pending, "preack_evaluation_capture"));
            Dictionary<string, object> preackEvaluation = MapOrEmpty(preackEvaluationFile, "document");
            Dictionary<string, object> activationFile = CaptureValueMapOrEmpty(CaptureMap(pending, "activation_capture"));
            Dictionary<string, object> activationEvaluationFile = CaptureValueMapOrEmpty(CaptureMap(pending, "activation_evaluation_capture"));
            Dictionary<string, object> activationEvaluation = MapOrEmpty(activationEvaluationFile, "document");
            Dictionary<string, object> runtime = CaptureValueMapOrEmpty(CaptureMap(pending, "runtime_ownership_capture"));
            Dictionary<string, object> tick = CaptureValueMapOrEmpty(CaptureMap(pending, "native_tick_capture"));
            ulong launcherTick = SafeUInt64(tick, "value", 0UL);
            ulong runnerTick;
            ulong preackTick;
            uint baselineInput;
            bool runnerTickValid = UInt64.TryParse(fields["runner-receipt-tick"], NumberStyles.None, CultureInfo.InvariantCulture, out runnerTick) && String.Equals(runnerTick.ToString(CultureInfo.InvariantCulture), fields["runner-receipt-tick"], StringComparison.Ordinal);
            bool preackTickValid = UInt64.TryParse(fields["preack-tick"], NumberStyles.None, CultureInfo.InvariantCulture, out preackTick) && String.Equals(preackTick.ToString(CultureInfo.InvariantCulture), fields["preack-tick"], StringComparison.Ordinal);
            bool baselineInputValid = UInt32.TryParse(fields["baseline-input"], NumberStyles.None, CultureInfo.InvariantCulture, out baselineInput) && String.Equals(baselineInput.ToString(CultureInfo.InvariantCulture), fields["baseline-input"], StringComparison.Ordinal);
            bool protocolNumericFieldsValid = runnerTickValid && preackTickValid && baselineInputValid;
            Dictionary<string, object> exactCapture = SafeCapture("launcher_exact_activation_after_pending", delegate
            {
                if (!preackTickValid) throw new HarnessException("Malformed PREACK tick protocol field");
                return (object)RequireExactActivation(fields["activation"], fields["stage-id"], fields["manifest-sha"], fields["receipt-sha"], fields["preparation-audit-sha"], fields["preack-sha"], fields["preack-evaluation-sha"], preackTick);
            });
            bool runtimeMatch = EvaluateRawRuntimeAfterPending(runtime, CaptureMap(pending, "runner_identity_capture"), CaptureMap(pending, "launcher_identity_capture"), true);
            bool tickMatch = protocolNumericFieldsValid && launcherTick != 0UL && runnerTick != 0UL && runnerTick <= launcherTick;
            bool slotMatch = SafeInteger(CaptureValueMapOrEmpty(CaptureMap(pending, "performance_slot_capture")), "performance_slot_launch_count", -1) == 0;
            bool bindingMatch = true;
            bool cliPathMatch = CaptureSucceededNoThrow(cliCapture);
            if (validateBindings)
            {
                string runRoot = SafeText(manifest, "run_evidence_root");
                string liveRoot = String.IsNullOrEmpty(runRoot) ? String.Empty : Path.GetFullPath(Path.Combine(runRoot, "live-001"));
                string launcherRoot = String.IsNullOrEmpty(liveRoot) ? String.Empty : Path.Combine(liveRoot, "launcher");
                string preackRoot = String.IsNullOrEmpty(runRoot) ? String.Empty : Path.GetFullPath(Path.Combine(runRoot, "preack-001", "launcher"));
                string receiptPath = Path.GetFullPath(Path.Combine(c.Stage, "seal", "preparation-receipt.json"));
                string auditPath = Path.GetFullPath(Path.Combine(c.Stage, "seal", "preparation-audit.json"));
                string observedPreackTick = SafeText(CaptureValueMapOrEmpty(CaptureMap(preack, "native_tick_capture")), "value");
                cliPathMatch = cliPathMatch && String.Equals(SafeText(cli, "role"), "launcher", StringComparison.Ordinal) && String.Equals(SafeText(cli, "mode"), "LIVE", StringComparison.Ordinal) &&
                    String.Equals(SafeText(cli, "identity"), Path.GetFullPath(Path.Combine(c.Stage, "seal", "qualification-manifest.json")), StringComparison.OrdinalIgnoreCase) &&
                    String.Equals(SafeText(cli, "out"), launcherRoot, StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(cli, "journal"), Path.Combine(liveRoot, "evidence.journal.jsonl"), StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(cli, "result"), Path.Combine(launcherRoot, "launcher-result.json"), StringComparison.OrdinalIgnoreCase);
                bindingMatch = CaptureSucceededNoThrow(CaptureMap(pending, "manifest_capture")) && CaptureSucceededNoThrow(CaptureMap(pending, "preparation_receipt_capture")) && CaptureSucceededNoThrow(CaptureMap(pending, "preparation_audit_capture")) && CaptureSucceededNoThrow(CaptureMap(pending, "preack_capture")) && CaptureSucceededNoThrow(CaptureMap(pending, "preack_evaluation_capture")) && CaptureSucceededNoThrow(CaptureMap(pending, "activation_capture")) && CaptureSucceededNoThrow(CaptureMap(pending, "activation_evaluation_capture")) &&
                    String.Equals(SafeText(manifestFile, "path"), Path.GetFullPath(Path.Combine(c.Stage, "seal", "qualification-manifest.json")), StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(manifestFile, "observed_sha256"), fields["manifest-sha"], StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(manifest, "schema"), Contract.ManifestSchema, StringComparison.Ordinal) && String.Equals(SafeText(manifest, "work_order"), Contract.WorkOrder, StringComparison.Ordinal) && String.Equals(SafeText(manifest, "stage_id"), fields["stage-id"], StringComparison.Ordinal) &&
                    String.Equals(SafeText(receiptFile, "path"), receiptPath, StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(receiptFile, "observed_sha256"), fields["receipt-sha"], StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(receipt, "schema"), Contract.ReceiptSchema, StringComparison.Ordinal) && String.Equals(SafeText(receipt, "work_order"), Contract.WorkOrder, StringComparison.Ordinal) && String.Equals(SafeText(receipt, "stage_id"), fields["stage-id"], StringComparison.Ordinal) && String.Equals(SafeText(receipt, "manifest_path"), Path.GetFullPath(manifestPath), StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(receipt, "manifest_sha256"), fields["manifest-sha"], StringComparison.OrdinalIgnoreCase) && SafeBoolean(receipt, "sealed", false) && SafeInteger(receipt, "performance_slot_launch_count", -1) == 0 && !SafeBoolean(receipt, "p95_produced", true) && !SafeBoolean(receipt, "kbm_performed", true) && !SafeBoolean(receipt, "abc_launched", true) &&
                    String.Equals(SafeText(auditFile, "path"), auditPath, StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(auditFile, "observed_sha256"), fields["preparation-audit-sha"], StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(audit, "schema"), Contract.PreparationAuditSchema, StringComparison.Ordinal) && String.Equals(SafeText(audit, "work_order"), Contract.WorkOrder, StringComparison.Ordinal) && String.Equals(SafeText(audit, "stage_id"), fields["stage-id"], StringComparison.Ordinal) && String.Equals(SafeText(audit, "manifest_path"), Path.GetFullPath(manifestPath), StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(audit, "manifest_sha256"), fields["manifest-sha"], StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(audit, "receipt_path"), receiptPath, StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(audit, "receipt_sha256"), fields["receipt-sha"], StringComparison.OrdinalIgnoreCase) &&
                    String.Equals(SafeText(preackFile, "path"), Path.Combine(preackRoot, "preack-record.json"), StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(preackFile, "observed_sha256"), fields["preack-sha"], StringComparison.OrdinalIgnoreCase) && String.Equals(observedPreackTick, fields["preack-tick"], StringComparison.Ordinal) &&
                    String.Equals(SafeText(preackEvaluationFile, "path"), Path.Combine(preackRoot, "preack-evaluation.json"), StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(preackEvaluationFile, "observed_sha256"), fields["preack-evaluation-sha"], StringComparison.OrdinalIgnoreCase) && SafeInteger(preackEvaluation, "result_code", -1) == Contract.Pass &&
                    String.Equals(SafeText(activationFile, "path"), Path.Combine(liveRoot, "activation-token.txt"), StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(activationFile, "observed_sha256"), fields["activation-sha"], StringComparison.OrdinalIgnoreCase) &&
                    String.Equals(SafeText(activationEvaluationFile, "path"), Path.Combine(liveRoot, "live-activation-evaluation.json"), StringComparison.OrdinalIgnoreCase) && String.Equals(SafeText(activationEvaluationFile, "observed_sha256"), fields["activation-evaluation-sha"], StringComparison.OrdinalIgnoreCase) && SafeInteger(activationEvaluation, "result_code", -1) == Contract.Pass && SafeBoolean(activationEvaluation, "exact_activation_match", false) && SafeBoolean(activationEvaluation, "binding_match", false);
            }
            bool cliProtocolValid = CaptureSucceededNoThrow(cliCapture) && protocolNumericFieldsValid;
            bool mechanism = readback && cliProtocolValid && CaptureSucceededNoThrow(exactCapture) && slotMatch && (runtimeMatch || !validateBindings) && (cliPathMatch || !validateBindings) && bindingMatch && (tickMatch || !validateBindings);
            int code = mechanism ? Contract.Pass : ((validateBindings && !cliProtocolValid) ? Contract.HarnessFail : (CaptureSucceededNoThrow(CaptureMap(pending, "activation_capture")) && !CaptureSucceededNoThrow(exactCapture) ? Contract.Blocked : Contract.HarnessFail));
            string reason = code == Contract.Pass ? "launcher_live_contract_pass" : (code == Contract.Blocked ? "invalid_user_activation_acknowledgement" : "launcher_live_identity_or_persistence_failure");
            Dictionary<string, object> evaluation = Record.Map(
                "schema", Contract.ActivationEvaluationSchema,
                "evaluation", "complete",
                "work_order", Contract.WorkOrder,
                "pending_observation_path", pendingPath,
                "pending_sha256", pendingSha,
                "pending_readback_success", readback,
                "cli_and_external_run_paths_match", cliPathMatch,
                "binding_match", bindingMatch,
                "runtime_ownership_match", runtimeMatch,
                "tick_order_match", tickMatch,
                "protocol_numeric_fields_valid", protocolNumericFieldsValid,
                "performance_slot_zero", slotMatch,
                "exact_activation_match", CaptureSucceededNoThrow(exactCapture),
                "exact_activation_capture", exactCapture,
                "launcher_receipt_tick", launcherTick.ToString(CultureInfo.InvariantCulture),
                "classification", code == Contract.Pass ? "Pass" : (code == Contract.Blocked ? "Blocked" : "Fail"),
                "result_code", code,
                "terminal_reason", reason,
                "performance_slot_launch_count", 0);
            journal.Append("launcher_live_evaluation", evaluation);
            EvidenceIo.WriteNewJson(evaluationPath, evaluation);
            return Record.Map("evaluation_path", Path.GetFullPath(evaluationPath), "evaluation_sha256", EvidenceIo.Sha256File(evaluationPath), "result_code", code, "terminal_reason", reason, "launcher_receipt_tick", evaluation["launcher_receipt_tick"]);
        }

        private static Dictionary<string, object> SuccessfulRawCapture(string label, object value)
        {
            return Record.Map("label", label, "success", true, "value", value, "error", null);
        }

        private static bool EvaluateLiveRunnerRuntimeAfterPending(Dictionary<string, object> runtime, Dictionary<string, object> runnerCapture)
        {
            try
            {
                if (!CaptureSucceededNoThrow(runnerCapture) || SafeInteger(runtime, "forbidden_runtime_count", -1) != 0 || SafeInteger(runtime, "owned_qa_role_count_excluding_runner", -1) != 0) return false;
                ProcessIdentity runner = IdentityFromRecord(CaptureValueMap(runnerCapture));
                object qaRaw, descendantsRaw;
                if (!runtime.TryGetValue("qa_owned_processes", out qaRaw) || !runtime.TryGetValue("runner_descendant_inventory", out descendantsRaw)) return false;
                RequireExactQaInventory(AsRecordList(qaRaw), runner);
                RequireExactDescendantInventory(AsRecordList(descendantsRaw));
                return true;
            }
            catch { return false; }
        }

        private static bool EvaluateRawRuntimeAfterPending(Dictionary<string, object> runtime, Dictionary<string, object> runnerCapture, Dictionary<string, object> launcherCapture, bool launcherExpected)
        {
            try
            {
                if (!CaptureSucceededNoThrow(runnerCapture) || !CaptureSucceededNoThrow(launcherCapture)) return false;
                ProcessIdentity runner = IdentityFromRecord(CaptureValueMap(runnerCapture));
                object qaRaw, descendantsRaw;
                if (!runtime.TryGetValue("qa_owned_processes", out qaRaw) || !runtime.TryGetValue("runner_descendant_inventory", out descendantsRaw)) return false;
                List<Dictionary<string, object>> qa = AsRecordList(qaRaw);
                List<Dictionary<string, object>> descendants = AsRecordList(descendantsRaw);
                if (SafeInteger(runtime, "forbidden_runtime_count", -1) != 0 || SafeInteger(runtime, "owned_qa_role_count_excluding_runner_launcher", -1) != 0) return false;
                if (launcherExpected)
                {
                    ProcessIdentity launcher = IdentityFromRecord(CaptureValueMap(launcherCapture));
                    RequireExactQaInventory(qa, runner, launcher);
                    RequireExactDescendantInventory(descendants, launcher);
                }
                else
                {
                    Dictionary<string, object> launcherState = CaptureValueMap(launcherCapture);
                    if (!SafeBoolean(launcherState, "not_started", false)) return false;
                    RequireExactQaInventory(qa, runner);
                    RequireExactDescendantInventory(descendants);
                }
                return true;
            }
            catch { return false; }
        }

        public static ProcessIdentity IdentityFromRecord(Dictionary<string, object> map)
        {
            return new ProcessIdentity(Record.Integer(map, "pid"), UInt64.Parse(Record.Text(map, "creation_filetime_utc"), CultureInfo.InvariantCulture), Record.Text(map, "image_path"));
        }

        public static List<Dictionary<string, object>> AsRecordList(object raw)
        {
            List<Dictionary<string, object>> result = raw as List<Dictionary<string, object>>;
            if (result != null) return result;
            object[] array = raw as object[];
            if (array == null) throw new HarnessException("Record array required");
            result = new List<Dictionary<string, object>>();
            for (int i = 0; i < array.Length; i++) result.Add(Record.AsMap(array[i]));
            return result;
        }

        public static Dictionary<string, object> CaptureMap(Dictionary<string, object> map, string key)
        {
            object value;
            if (map == null || !map.TryGetValue(key, out value)) return Record.Map("label", key, "success", false, "value", null, "error", "missing capture");
            Dictionary<string, object> result = value as Dictionary<string, object>;
            return result ?? Record.Map("label", key, "success", false, "value", null, "error", "capture was not an object");
        }

        public static Dictionary<string, object> CaptureValueMap(Dictionary<string, object> capture)
        {
            if (!CaptureSucceeded(capture)) throw new HarnessException("Capture did not succeed: " + SafeText(capture, "label"));
            object value;
            if (!capture.TryGetValue("value", out value)) throw new HarnessException("Capture value missing");
            return Record.AsMap(value);
        }

        public static Dictionary<string, object> CaptureValueMapOrEmpty(Dictionary<string, object> capture)
        {
            try { return CaptureValueMap(capture); }
            catch { return new Dictionary<string, object>(StringComparer.Ordinal); }
        }

        public static Dictionary<string, object> MapOrEmpty(Dictionary<string, object> map, string key)
        {
            object value;
            if (map != null && map.TryGetValue(key, out value))
            {
                Dictionary<string, object> result = value as Dictionary<string, object>;
                if (result != null) return result;
            }
            return new Dictionary<string, object>(StringComparer.Ordinal);
        }

        public static bool CaptureSucceededNoThrow(Dictionary<string, object> capture)
        {
            try { return capture != null && CaptureSucceeded(capture); }
            catch { return false; }
        }

        public static string SafeText(Dictionary<string, object> map, string key)
        {
            try { return Record.Text(map, key); }
            catch { return String.Empty; }
        }

        public static string SafeFullPathText(string path)
        {
            try { return String.IsNullOrEmpty(path) ? String.Empty : Path.GetFullPath(path); }
            catch { return String.Empty; }
        }

        public static bool SafeBoolean(Dictionary<string, object> map, string key, bool fallback)
        {
            try { object value; return map.TryGetValue(key, out value) && value != null ? Convert.ToBoolean(value, CultureInfo.InvariantCulture) : fallback; }
            catch { return fallback; }
        }

        public static int SafeInteger(Dictionary<string, object> map, string key, int fallback)
        {
            try { object value; return map.TryGetValue(key, out value) && value != null ? Convert.ToInt32(value, CultureInfo.InvariantCulture) : fallback; }
            catch { return fallback; }
        }

        public static ulong SafeUInt64(Dictionary<string, object> map, string key, ulong fallback)
        {
            try { return UInt64.Parse(Record.Text(map, key), CultureInfo.InvariantCulture); }
            catch { return fallback; }
        }

        public static void RequireCaptureSucceeded(Dictionary<string, object> capture)
        {
            if (!CaptureSucceeded(capture)) throw new HarnessException("Evidence capture failed: " + Convert.ToString(capture["label"], CultureInfo.InvariantCulture) + ": " + Convert.ToString(capture["error"], CultureInfo.InvariantCulture));
        }

        public static void RequireStableFileEvidence(Dictionary<string, object> evidence, string label)
        {
            bool exists = Convert.ToBoolean(evidence["exists"], CultureInfo.InvariantCulture);
            bool stable = Convert.ToBoolean(evidence["stable"], CultureInfo.InvariantCulture);
            string sha = evidence["sha256"] == null ? null : Convert.ToString(evidence["sha256"], CultureInfo.InvariantCulture);
            string error = evidence["capture_error"] == null ? null : Convert.ToString(evidence["capture_error"], CultureInfo.InvariantCulture);
            if (!exists || !stable || String.IsNullOrEmpty(sha) || sha.Length != 64 || !String.IsNullOrEmpty(error)) throw new HarnessException("Stable file evidence missing for " + label);
        }

        public static Dictionary<string, object> SelfIdentity()
        {
            using (Process process = Process.GetCurrentProcess()) return NativeApi.ReadIdentity(process).ToRecord();
        }

        public static string Bin(string stage, string name) { return Path.Combine(stage, "bin", name); }

        public static OwnedChild StartRole(string executable, string mode, string stage, string identityDoc, string output, string journalPath, string resultPath, IDictionary<string, string> extraArgs, JobScope job, EvidenceJournal journal, string label, ulong ownershipDeadline)
        {
            StringBuilder args = new StringBuilder();
            args.Append("--mode ").Append(Quote(mode));
            args.Append(" --stage ").Append(Quote(stage));
            args.Append(" --identity ").Append(Quote(identityDoc));
            args.Append(" --out ").Append(Quote(output));
            args.Append(" --journal ").Append(Quote(journalPath));
            args.Append(" --result ").Append(Quote(resultPath));
            if (extraArgs != null)
            {
                List<string> keys = new List<string>(extraArgs.Keys);
                keys.Sort(StringComparer.Ordinal);
                foreach (string key in keys) args.Append(" --").Append(key).Append(" ").Append(Quote(extraArgs[key]));
            }
            Directory.CreateDirectory(output);
            return OwnedChild.Start(executable, args.ToString(), null, job, Path.Combine(output, label + ".stdout.raw"), Path.Combine(output, label + ".stderr.raw"), journal, label, ownershipDeadline);
        }

        public static Dictionary<string, object> ReadPowerAndInputAndPersist(EvidenceJournal journal, string scenario)
        {
            Dictionary<string, object> record = PowerAndInput();
            record["scenario"] = scenario;
            journal.Append("power_input_prerequisite", record);
            return record;
        }

        public static void CheckHostPrerequisiteRecord(Dictionary<string, object> record, uint expectedInput, bool enforceInput, bool apiFailureIsHarnessDefect)
        {
            bool powerOk = Convert.ToBoolean(record["power_api_success"], CultureInfo.InvariantCulture);
            bool overlayOk = Convert.ToBoolean(record["overlay_api_success"], CultureInfo.InvariantCulture);
            bool inputOk = Convert.ToBoolean(record["last_input_api_success"], CultureInfo.InvariantCulture);
            int ac = Convert.ToInt32(record["ac_line_status"], CultureInfo.InvariantCulture);
            string overlay = Convert.ToString(record["effective_overlay_guid"], CultureInfo.InvariantCulture);
            uint input = UInt32.Parse(Convert.ToString(record["last_input_dwtime_uint32"], CultureInfo.InvariantCulture), CultureInfo.InvariantCulture);
            if (!powerOk || !overlayOk || !inputOk)
            {
                if (apiFailureIsHarnessDefect) throw new HarnessException("Native prerequisite API failed after valid pre-ack");
                throw new ExpectedTerminalException(Contract.Blocked, "host_prerequisite_api_unavailable");
            }
            if (ac != 1 || !String.Equals(overlay, Contract.BestPerformanceGuid, StringComparison.OrdinalIgnoreCase) || (enforceInput && input != expectedInput))
                throw new ExpectedTerminalException(Contract.Blocked, "host_prerequisite_changed");
        }

        public static Dictionary<string, object> FileSetAudit(string identityDoc, string stage)
        {
            VerifyIdentityDocument(identityDoc, stage);
            Dictionary<string, object> root = EvidenceIo.ReadMap(identityDoc);
            object[] files = root["sealed_files"] as object[];
            if (files == null) throw new HarnessException("sealed_files must be an array");
            List<Dictionary<string, object>> observed = new List<Dictionary<string, object>>();
            foreach (object item in files)
            {
                Dictionary<string, object> expected = Record.AsMap(item);
                string relative = Record.Text(expected, "relative_path").Replace('/', Path.DirectorySeparatorChar);
                string path = Path.GetFullPath(Path.Combine(stage, relative));
                Dictionary<string, object> actual = EvidenceIo.FileIdentity(path, Record.Text(expected, "relative_path"));
                bool hashMatch = String.Equals(Record.Text(expected, "sha256"), Record.Text(actual, "sha256"), StringComparison.OrdinalIgnoreCase);
                if (!hashMatch) throw new HarnessException("Fresh identity audit mismatch: " + relative);
                observed.Add(Record.Map("relative_path", Record.Text(expected, "relative_path"), "expected_sha256", Record.Text(expected, "sha256"), "actual", actual, "hash_match", hashMatch));
            }
            return Record.Map("identity_document", identityDoc, "identity_document_sha256", EvidenceIo.Sha256File(identityDoc), "file_count", observed.Count, "observed_file_identities", observed, "all_sealed_files_match", true);
        }

        public static string RequireExactActivation(string activationPath, string stageId, string manifestSha, string receiptSha, string preparationAuditSha, string preackSha, string preackEvaluationSha, ulong preackTick)
        {
            byte[] bytes = File.ReadAllBytes(Path.GetFullPath(activationPath));
            string text = Encoding.UTF8.GetString(bytes).TrimEnd('\r', '\n');
            string expected = Contract.WorkOrder + " START_ACK stage_id=" + stageId + " manifest_sha256=" + manifestSha.ToLowerInvariant() + " receipt_sha256=" + receiptSha.ToLowerInvariant() + " preparation_audit_sha256=" + preparationAuditSha.ToLowerInvariant() + " preack_sha256=" + preackSha.ToLowerInvariant() + " preack_evaluation_sha256=" + preackEvaluationSha.ToLowerInvariant() + " preack_tick=" + preackTick.ToString(CultureInfo.InvariantCulture);
            if (!String.Equals(text, expected, StringComparison.Ordinal)) throw new HarnessException("Activation token is not an exact START_ACK echo");
            return EvidenceIo.Sha256Bytes(bytes);
        }
    }

    public static class SentinelExercise
    {
        public static Dictionary<string, object> Run(RoleContext context, JobScope owner, string label, Action<ulong> onExitObserved)
        {
            string token = EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(Path.GetFullPath(context.Stage).ToLowerInvariant() + "|sentinel-handshake")).Substring(0, 24);
            string readyName = "Local\\MFO_QA_SENTINEL_READY_" + token;
            string releaseName = "Local\\MFO_QA_SENTINEL_RELEASE_" + token;
            using (EventWaitHandle ready = new EventWaitHandle(false, EventResetMode.ManualReset, readyName))
            using (EventWaitHandle release = new EventWaitHandle(false, EventResetMode.ManualReset, releaseName))
            {
                string sentinelOut = Path.Combine(context.Output, label + ".stdout.raw");
                string sentinelErr = Path.Combine(context.Output, label + ".stderr.raw");
                string sentinelArguments = "--ready-event " + HarnessOps.Quote(readyName) + " --release-event " + HarnessOps.Quote(releaseName);
                ulong origin = NativeApi.GetTickCount64();
                ulong deadline = checked(origin + Contract.SentinelTimeoutMilliseconds);
                using (OwnedChild child = OwnedChild.Start(HarnessOps.Bin(context.Stage, "MfoQaSentinel.exe"), sentinelArguments, null, owner, sentinelOut, sentinelErr, context.Journal, label, deadline))
                {
                    bool readyObserved = false;
                    Exception handshakeFailure = null;
                    while (!ready.WaitOne(0))
                    {
                        if (child.HasExited)
                        {
                            handshakeFailure = new HarnessException("Sentinel exited before READY");
                            break;
                        }
                        ulong now = NativeApi.GetTickCount64();
                        if (now >= deadline)
                        {
                            try { child.AbortOwned(owner, Contract.TimeoutFail, "Sentinel READY native-tick timeout; deadline=" + deadline.ToString(CultureInfo.InvariantCulture) + "; observed=" + now.ToString(CultureInfo.InvariantCulture)); }
                            catch (Exception failure) { handshakeFailure = failure; }
                            try { context.Journal.Append("deadline_check", Record.Map("scenario", label + "_ready_timeout", "now", now.ToString(CultureInfo.InvariantCulture), "deadline", deadline.ToString(CultureInfo.InvariantCulture), "expired", true)); }
                            catch (Exception journalFailure) { if (handshakeFailure == null) handshakeFailure = journalFailure; }
                            break;
                        }
                        Thread.Sleep(5);
                    }
                    if (handshakeFailure == null) readyObserved = true;
                    string preReleaseDefect = null;
                    if (readyObserved)
                    {
                        try
                        {
                            bool identityMatch = child.Identity.MatchesCurrent();
                            ProcessIdentity runner = HarnessOps.IdentityFromArgs(context.Args, "runner");
                            ProcessIdentity launcher = HarnessOps.IdentityFromArgs(context.Args, "launcher");
                            ProcessIdentity controller; using (Process current = Process.GetCurrentProcess()) controller = NativeApi.ReadIdentity(current);
                            List<Dictionary<string, object>> qaInventory = HarnessOps.QaOwnedInventory(context.Stage);
                            List<Dictionary<string, object>> descendants = HarnessOps.DescendantInventory(runner.Pid);
                            context.Journal.Append("sentinel_ready", Record.Map("label", label, "identity", child.Identity.ToRecord(), "identity_matches_while_alive", identityMatch, "qa_owned_processes_while_ready", qaInventory, "runner_descendants_while_ready", descendants, "handshake_origin", origin.ToString(CultureInfo.InvariantCulture), "handshake_deadline", deadline.ToString(CultureInfo.InvariantCulture)));
                            preReleaseDefect = identityMatch ? null : "Sentinel identity mismatch while READY";
                            if (preReleaseDefect == null)
                            {
                                try { HarnessOps.RequireExactQaInventory(qaInventory, runner, launcher, controller, child.Identity); }
                                catch (Exception failure) { preReleaseDefect = "Sentinel owned-process inventory mismatch: " + failure.Message; }
                            }
                            if (preReleaseDefect == null)
                            {
                                try { HarnessOps.RequireExactDescendantInventory(descendants, launcher, controller, child.Identity); }
                                catch (Exception failure) { preReleaseDefect = "Sentinel descendant inventory mismatch: " + failure.Message; }
                            }
                            if (preReleaseDefect != null) context.Journal.Append("sentinel_defect_natural_release_pending", Record.Map("reason", preReleaseDefect, "deadline", deadline.ToString(CultureInfo.InvariantCulture)));
                        }
                        catch (Exception failure) { handshakeFailure = failure; }
                        finally { if (!child.HasExited) release.Set(); }
                    }
                    int exit = Contract.TimeoutFail;
                    Exception waitFailure = null;
                    try { exit = child.WaitUntil(origin, deadline, owner, readyObserved ? onExitObserved : null); }
                    catch (Exception failure)
                    {
                        waitFailure = failure;
                        if (child.HasObservedExitCode) exit = child.ObservedExitCode;
                    }
                    string stdout = null;
                    string stderr = null;
                    string rawReadError = null;
                    if (child.RawStreamsCompleted)
                    {
                        try { stdout = File.ReadAllText(sentinelOut, Encoding.UTF8); stderr = File.ReadAllText(sentinelErr, Encoding.UTF8); }
                        catch (Exception readFailure) { rawReadError = readFailure.GetType().FullName + ": " + readFailure.Message; }
                    }
                    bool rawOk = rawReadError == null && stdout == Contract.SentinelReady + Environment.NewLine + Contract.SentinelStdout + Environment.NewLine && stderr == Contract.SentinelStderr + Environment.NewLine;
                    context.Journal.Append("sentinel_complete", Record.Map("label", label, "exit_code", exit, "stdout", child.StdoutEvidence(), "stderr", child.StderrEvidence(), "raw_tokens_exact", rawOk, "raw_read_error", rawReadError, "wait_failure", waitFailure == null ? null : waitFailure.GetType().FullName + ": " + waitFailure.Message));
                    if (waitFailure != null) throw waitFailure;
                    if (handshakeFailure != null) throw handshakeFailure;
                    if (exit != Contract.SentinelExpected || !rawOk) throw new HarnessException("Sentinel contract mismatch");
                    if (preReleaseDefect != null) throw new HarnessException(preReleaseDefect);
                    return Record.Map("identity", child.Identity.ToRecord(), "exit_code", exit, "raw_tokens_exact", rawOk, "stdout", sentinelOut, "stderr", sentinelErr);
                }
            }
        }
    }

    public static class RunnerRole
    {
        public static int Main(string[] args)
        {
            RoleContext context;
            try { context = new RoleContext("runner", args); }
            catch (Exception e) { Console.Error.WriteLine(e.ToString()); return Contract.HarnessFail; }
            return context.Execute(delegate { return Run(context); });
        }

        private static Dictionary<string, object> Run(RoleContext c)
        {
            string identity = Path.GetFullPath(c.Args.Required("identity"));
            if (c.Mode == "PREACK") return RunPreack(c, identity);
            if (c.Mode == "LIVE") return RunLive(c, identity);
            HarnessOps.VerifyIdentityDocument(identity, c.Stage);
            if (c.Mode == "QP_DRYRUN")
            {
                List<Dictionary<string, object>> before = HarnessOps.ForbiddenRuntimeInventory(c.Stage);
                ProcessIdentity self; using (Process current = Process.GetCurrentProcess()) self = NativeApi.ReadIdentity(current);
                List<Dictionary<string, object>> qaBefore = HarnessOps.QaOwnedInventory(c.Stage);
                List<Dictionary<string, object>> descendantsBefore = HarnessOps.DescendantInventory(self.Pid);
                c.Journal.Append("qp_dryrun_before_inventory", Record.Map("runner_identity", self.ToRecord(), "forbidden_runtime", before, "qa_owned_processes", qaBefore, "runner_descendants", descendantsBefore, "performance_slot_launch_count", 0));
                HarnessOps.RequireExactQaInventory(qaBefore, self);
                int allowedConsoleHostsBefore = HarnessOps.RequireExactDescendantInventory(descendantsBefore);
                if (before.Count != 0) throw new HarnessException("Forbidden runtime existed at QP dry-run start");
                List<Dictionary<string, object>> after = HarnessOps.ForbiddenRuntimeInventory(c.Stage);
                List<Dictionary<string, object>> qaAfter = HarnessOps.QaOwnedInventory(c.Stage);
                List<Dictionary<string, object>> descendantsAfter = HarnessOps.DescendantInventory(self.Pid);
                c.Journal.Append("qp_dryrun_after_inventory", Record.Map("runner_identity", self.ToRecord(), "forbidden_runtime", after, "qa_owned_processes", qaAfter, "runner_descendants", descendantsAfter, "performance_slot_launch_count", 0));
                HarnessOps.RequireExactQaInventory(qaAfter, self);
                int allowedConsoleHostsAfter = HarnessOps.RequireExactDescendantInventory(descendantsAfter);
                if (after.Count != 0) throw new HarnessException("Forbidden runtime existed at QP dry-run end");
                c.Journal.Append("qp_dryrun_complete", Record.Map("allowed_windows_console_host_count_before", allowedConsoleHostsBefore, "allowed_windows_console_host_count_after", allowedConsoleHostsAfter, "unexpected_descendant_count", 0, "performance_slot_launch_count", 0, "final_owned_runtime_count", 0));
                return Record.Map("dry_run", "pass", "forbidden_runtime_before_count", before.Count, "forbidden_runtime_after_count", after.Count, "qa_owned_before", qaBefore, "qa_owned_after", qaAfter, "runner_descendants_before", descendantsBefore, "runner_descendants_after", descendantsAfter, "allowed_windows_console_host_count_before", allowedConsoleHostsBefore, "allowed_windows_console_host_count_after", allowedConsoleHostsAfter, "unexpected_descendant_count", 0, "performance_slot_launch_count", 0, "final_owned_runtime_count", 0, "identity_audit", HarnessOps.FileSetAudit(identity, c.Stage));
            }
            if (c.Mode == "QP_POWER_INPUT_SMOKE") return RunPowerInputSmoke(c, identity);
            if (c.Mode == "QP_SELFTEST") return RunChild(c, identity, "QP_SELFTEST", null);
            if (c.Mode == "QP_PREACK_CONTRACT_SELFTEST") return RunPreackContractSelfTest(c, identity);
            throw new HarnessException("Unsupported runner mode: " + c.Mode);
        }

        private static Dictionary<string, object> RunPreack(RoleContext c, string identity)
        {
            string stageId = c.Args.Optional("stage-id", "");
            string manifestSha = c.Args.Optional("manifest-sha", "").ToLowerInvariant();
            string receiptSha = c.Args.Optional("receipt-sha", "").ToLowerInvariant();
            string auditSha = c.Args.Optional("preparation-audit-sha", "").ToLowerInvariant();
            string receiptPath = Path.Combine(c.Stage, "seal", "preparation-receipt.json");
            string auditPath = Path.Combine(c.Stage, "seal", "preparation-audit.json");
            string pendingPath = Path.Combine(c.Output, "runner-preack-pending.json");
            string evaluationPath = Path.Combine(c.Output, "runner-preack-evaluation.json");
            Dictionary<string, object> runnerIdentityCapture = HarnessOps.SafeCapture("runner_identity", delegate { return (object)HarnessOps.SelfIdentity(); });
            Dictionary<string, object> launcherNotStartedCapture = SuccessfulCapture("launcher_not_started", Record.Map("not_started", true));
            Dictionary<string, object> runnerRuntimeCapture = HarnessOps.SafeCapture("runner_preack_runtime", delegate
            {
                Dictionary<string, object> runner = HarnessOps.CaptureValueMap(runnerIdentityCapture);
                int runnerPid = Record.Integer(runner, "pid");
                List<Dictionary<string, object>> forbidden = HarnessOps.ForbiddenRuntimeInventory(c.Stage);
                List<Dictionary<string, object>> qa = HarnessOps.QaOwnedInventory(c.Stage);
                List<Dictionary<string, object>> descendants = HarnessOps.DescendantInventory(runnerPid);
                return (object)Record.Map(
                    "forbidden_runtime_count", forbidden.Count,
                    "forbidden_runtime_processes", forbidden,
                    "qa_owned_processes", qa,
                    "runner_descendant_inventory", descendants,
                    "owned_qa_role_count_excluding_runner_launcher", qa.Count - 1,
                    "runner_identity_capture", runnerIdentityCapture,
                    "launcher_identity_capture", launcherNotStartedCapture);
            });
            Dictionary<string, object> pending = HarnessOps.BuildPreackPendingObservation(
                c.Stage, identity, stageId, manifestSha, receiptSha, auditSha,
                receiptPath, auditPath, pendingPath, Environment.CommandLine,
                runnerIdentityCapture, launcherNotStartedCapture, null, null, runnerRuntimeCapture, null, c.CliContractCapture);
            Dictionary<string, object> persisted = HarnessOps.PersistCompletePendingObservation(c.Journal, pendingPath, pending);
            c.PreserveDurableEvidence("runner_preack_pending", Record.Map("path", persisted["pending_path"], "sha256", persisted["pending_sha256"]));
            Dictionary<string, object> evaluation = HarnessOps.EvaluatePersistedPreackObservation(
                c.Journal, evaluationPath, persisted, c.Stage, identity, stageId, manifestSha, receiptSha, auditSha, receiptPath, auditPath, false);
            c.PreserveDurableEvidence("runner_preack_evaluation", Record.Map("path", evaluation["evaluation_path"], "sha256", evaluation["evaluation_sha256"], "result_code", evaluation["result_code"], "terminal_reason", evaluation["terminal_reason"]));
            int code = Convert.ToInt32(evaluation["result_code"], CultureInfo.InvariantCulture);
            if (code != Contract.Pass) throw new ExpectedTerminalException(code, Convert.ToString(evaluation["terminal_reason"], CultureInfo.InvariantCulture));
            Dictionary<string, string> forwarded = new Dictionary<string, string>();
            forwarded["stage-id"] = stageId;
            forwarded["manifest-sha"] = manifestSha;
            forwarded["receipt-sha"] = receiptSha;
            forwarded["preparation-audit-sha"] = auditSha;
            Dictionary<string, object> child = RunChild(c, identity, "PREACK", forwarded);
            child["runner_preack_pending"] = Record.Map("path", persisted["pending_path"], "sha256", persisted["pending_sha256"]);
            child["runner_preack_evaluation"] = Record.Map("path", evaluation["evaluation_path"], "sha256", evaluation["evaluation_sha256"]);
            return child;
        }

        private static Dictionary<string, object> RunPowerInputSmoke(RoleContext c, string identity)
        {
            ProcessIdentity self;
            using (Process current = Process.GetCurrentProcess()) self = NativeApi.ReadIdentity(current);
            List<Dictionary<string, object>> forbiddenBefore = HarnessOps.ForbiddenRuntimeInventory(c.Stage);
            List<Dictionary<string, object>> qaBefore = HarnessOps.QaOwnedInventory(c.Stage);
            List<Dictionary<string, object>> descendantsBefore = HarnessOps.DescendantInventory(self.Pid);
            c.Journal.Append("qp_power_input_smoke_before", Record.Map("runner_identity", self.ToRecord(), "forbidden_runtime", forbiddenBefore, "qa_owned_processes", qaBefore, "runner_descendants", descendantsBefore, "performance_slot_launch_count", 0));
            if (forbiddenBefore.Count != 0) throw new HarnessException("Forbidden runtime existed at power/input smoke start");
            HarnessOps.RequireExactQaInventory(qaBefore, self);
            int allowedConsoleHostsBefore = HarnessOps.RequireExactDescendantInventory(descendantsBefore);

            Dictionary<string, object> captured = HarnessOps.ReadPowerAndInputAndPersist(c.Journal, "qp_power_input_smoke");
            string recordPath = Path.Combine(c.Output, "power-input-record.json");
            EvidenceIo.WriteNewJson(recordPath, captured);
            Dictionary<string, object> readback = EvidenceIo.ReadMap(recordPath);
            string[] fields = new string[] { "power_api_success", "ac_line_status", "overlay_api_success", "overlay_native_status", "effective_overlay_guid", "last_input_api_success", "last_input_native_error", "last_input_dwtime_uint32", "scenario" };
            for (int i = 0; i < fields.Length; i++)
            {
                if (!String.Equals(Record.Text(captured, fields[i]), Record.Text(readback, fields[i]), StringComparison.Ordinal)) throw new HarnessException("Power/input smoke readback mismatch: " + fields[i]);
            }
            if (!Convert.ToBoolean(readback["power_api_success"], CultureInfo.InvariantCulture) ||
                !Convert.ToBoolean(readback["overlay_api_success"], CultureInfo.InvariantCulture) ||
                !Convert.ToBoolean(readback["last_input_api_success"], CultureInfo.InvariantCulture)) throw new HarnessException("Power/input smoke native API failed");
            if (Convert.ToUInt32(readback["overlay_native_status"], CultureInfo.InvariantCulture) != 0U) throw new HarnessException("Power/input smoke overlay status was nonzero");
            string overlayText = Record.Text(readback, "effective_overlay_guid");
            Guid parsedOverlay = Guid.Parse(overlayText);
            if (!String.Equals(parsedOverlay.ToString().ToLowerInvariant(), overlayText.ToLowerInvariant(), StringComparison.Ordinal)) throw new HarnessException("Power/input smoke overlay GUID round-trip failed");
            string inputText = Record.Text(readback, "last_input_dwtime_uint32");
            uint parsedInput = UInt32.Parse(inputText, CultureInfo.InvariantCulture);
            if (!String.Equals(parsedInput.ToString(CultureInfo.InvariantCulture), inputText, StringComparison.Ordinal)) throw new HarnessException("Power/input smoke UInt32 round-trip failed");

            Dictionary<string, object> sourceIdentity = EvidenceIo.FileIdentity(Path.Combine(c.Stage, "source", "MfoQaNative.cs"), "source/MfoQaNative.cs");
            Dictionary<string, object> nativeIdentity = EvidenceIo.FileIdentity(Path.Combine(c.Stage, "bin", "MfoQaNative.dll"), "bin/MfoQaNative.dll");
            Dictionary<string, object> runnerIdentity = EvidenceIo.FileIdentity(Path.Combine(c.Stage, "bin", "MfoQaRunner.exe"), "bin/MfoQaRunner.exe");
            string exactInvocation = Environment.CommandLine;
            string exactInvocationSha = EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(exactInvocation));

            List<Dictionary<string, object>> forbiddenAfter = HarnessOps.ForbiddenRuntimeInventory(c.Stage);
            List<Dictionary<string, object>> qaAfter = HarnessOps.QaOwnedInventory(c.Stage);
            List<Dictionary<string, object>> descendantsAfter = HarnessOps.DescendantInventory(self.Pid);
            if (forbiddenAfter.Count != 0) throw new HarnessException("Forbidden runtime existed at power/input smoke end");
            HarnessOps.RequireExactQaInventory(qaAfter, self);
            int allowedConsoleHostsAfter = HarnessOps.RequireExactDescendantInventory(descendantsAfter);
            Dictionary<string, object> identityAudit = HarnessOps.FileSetAudit(identity, c.Stage);
            Dictionary<string, object> binding = Record.Map("source", sourceIdentity, "native_helper", nativeIdentity, "invoking_role", runnerIdentity, "identity_document_sha256", EvidenceIo.Sha256File(identity), "exact_invocation", exactInvocation, "exact_invocation_sha256", exactInvocationSha, "production_power_and_input_call_count", 1);
            c.Journal.Append("qp_power_input_smoke_complete", Record.Map("power_input_record", recordPath, "power_input_record_sha256", EvidenceIo.Sha256File(recordPath), "guid_parse_roundtrip", true, "uint32_roundtrip", true, "binding", binding, "forbidden_runtime", forbiddenAfter, "qa_owned_processes", qaAfter, "runner_descendants", descendantsAfter, "performance_slot_launch_count", 0, "final_owned_runtime_count", 0));
            return Record.Map("power_input_smoke", "pass", "power_input_record", recordPath, "power_input_record_sha256", EvidenceIo.Sha256File(recordPath), "host_record", readback, "guid_parse_roundtrip", true, "uint32_roundtrip", true, "binding", binding, "forbidden_runtime_before_count", forbiddenBefore.Count, "forbidden_runtime_after_count", forbiddenAfter.Count, "qa_owned_before", qaBefore, "qa_owned_after", qaAfter, "runner_descendants_before", descendantsBefore, "runner_descendants_after", descendantsAfter, "allowed_windows_console_host_count_before", allowedConsoleHostsBefore, "allowed_windows_console_host_count_after", allowedConsoleHostsAfter, "unexpected_descendant_count", 0, "performance_slot_launch_count", 0, "final_owned_runtime_count", 0, "identity_audit", identityAudit);
        }

        private static Dictionary<string, object> RunPreackContractSelfTest(RoleContext c, string identity)
        {
            Dictionary<string, object> manifest = EvidenceIo.ReadMap(identity);
            string stageId = Record.Text(manifest, "stage_id");
            string manifestSha = EvidenceIo.Sha256File(identity);
            string receiptPath = Path.Combine(c.Stage, "seal", "preparation-receipt.json");
            string receiptSha = EvidenceIo.Sha256File(receiptPath);
            Dictionary<string, object> receipt = EvidenceIo.ReadMap(receiptPath);
            string fixtureRoot = Path.Combine(c.Output, "fixtures");
            Directory.CreateDirectory(fixtureRoot);

            Dictionary<string, object> runnerIdentityCapture = HarnessOps.SafeCapture("runner_identity_fixture", delegate { return (object)HarnessOps.SelfIdentity(); });
            Dictionary<string, object> runnerIdentity = HarnessOps.CaptureValueMap(runnerIdentityCapture);
            Dictionary<string, object> launcherIdentity = Record.Map(
                "pid", checked(Record.Integer(runnerIdentity, "pid") + 100000),
                "creation_filetime_utc", (UInt64.Parse(Record.Text(runnerIdentity, "creation_filetime_utc"), CultureInfo.InvariantCulture) + 1UL).ToString(CultureInfo.InvariantCulture),
                "image_path", Path.Combine(c.Stage, "bin", "MfoQaLauncher.exe"));
            Dictionary<string, object> launcherIdentityCapture = SuccessfulCapture("launcher_identity_fixture", launcherIdentity);
            List<Dictionary<string, object>> qaFixture = new List<Dictionary<string, object>>();
            qaFixture.Add(runnerIdentity); qaFixture.Add(launcherIdentity);
            List<Dictionary<string, object>> descendantFixture = new List<Dictionary<string, object>>();
            descendantFixture.Add(Record.Map(
                "pid", Record.Integer(launcherIdentity, "pid"),
                "parent_pid", Record.Integer(runnerIdentity, "pid"),
                "name", "MfoQaLauncher.exe",
                "identity_success", true,
                "identity_error", null,
                "creation_filetime_utc", Record.Text(launcherIdentity, "creation_filetime_utc"),
                "image_path", Record.Text(launcherIdentity, "image_path")));
            Dictionary<string, object> runtimePositive = SuccessfulCapture("runtime_fixture", Record.Map(
                "forbidden_runtime_count", 0,
                "forbidden_runtime_processes", new object[0],
                "qa_owned_processes", qaFixture,
                "runner_descendant_inventory", descendantFixture,
                "owned_qa_role_count_excluding_runner_launcher", 0,
                "runner_identity_capture", runnerIdentityCapture,
                "launcher_identity_capture", launcherIdentityCapture));
            Dictionary<string, object> oneDriveZero = SuccessfulCapture("onedrive_fixture", Record.Map("count", 0, "processes", new object[0]));
            Dictionary<string, object> hostPositive = SuccessfulCapture("host_fixture", SyntheticHost(Contract.BestPerformanceGuid));
            Dictionary<string, object> tickPositive = SuccessfulCapture("tick_fixture", Record.Map("value", NativeApi.GetTickCount64().ToString(CultureInfo.InvariantCulture)));

            List<Dictionary<string, object>> negativeCases = new List<Dictionary<string, object>>();
            Dictionary<string, object> positive = RunPreackContractFixture(c, identity, stageId, manifestSha, "positive_actual_receipt", receiptPath, receiptPath, receiptSha, receiptSha, receiptSha, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive, Contract.Pass);

            string missingPath = Path.Combine(fixtureRoot, "missing-receipt.json");
            negativeCases.Add(RunPreackContractFixture(c, identity, stageId, manifestSha, "missing_receipt", missingPath, missingPath, new string('0', 64), new string('0', 64), new string('0', 64), runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive, Contract.HarnessFail));
            string unreadablePath = Path.Combine(fixtureRoot, "unreadable-receipt");
            Directory.CreateDirectory(unreadablePath);
            negativeCases.Add(RunPreackContractFixture(c, identity, stageId, manifestSha, "unreadable_receipt", unreadablePath, unreadablePath, new string('1', 64), new string('1', 64), new string('1', 64), runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive, Contract.HarnessFail));
            string malformedPath = Path.Combine(fixtureRoot, "malformed-receipt.json");
            EvidenceIo.WriteNewBytes(malformedPath, EvidenceIo.Utf8("{malformed-json"));
            string malformedSha = EvidenceIo.Sha256File(malformedPath);
            negativeCases.Add(RunPreackContractFixture(c, identity, stageId, manifestSha, "malformed_receipt", malformedPath, malformedPath, malformedSha, malformedSha, malformedSha, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive, Contract.HarnessFail));

            Dictionary<string, object> missingField = CloneMap(receipt); missingField.Remove("work_order");
            negativeCases.Add(RunReceiptMutationFixture(c, identity, stageId, manifestSha, "missing_required_field", missingField, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive));
            negativeCases.Add(RunPreackContractFixture(c, identity, stageId, manifestSha, "wrong_receipt_hash", receiptPath, receiptPath, new string('a', 64), new string('a', 64), receiptSha, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive, Contract.HarnessFail));
            Dictionary<string, object> wrongSchema = CloneMap(receipt); wrongSchema["schema"] = "mfo.qa.qualification.preparation-receipt.invalid";
            negativeCases.Add(RunReceiptMutationFixture(c, identity, stageId, manifestSha, "wrong_schema", wrongSchema, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive));
            Dictionary<string, object> wrongWorkOrder = CloneMap(receipt); wrongWorkOrder["work_order"] = "MFO-WO-P2-2A-" + "999";
            negativeCases.Add(RunReceiptMutationFixture(c, identity, stageId, manifestSha, "wrong_work_order", wrongWorkOrder, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive));
            Dictionary<string, object> wrongStage = CloneMap(receipt); wrongStage["stage_id"] = stageId + "-wrong";
            negativeCases.Add(RunReceiptMutationFixture(c, identity, stageId, manifestSha, "wrong_stage", wrongStage, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive));
            Dictionary<string, object> wrongManifestPath = CloneMap(receipt); wrongManifestPath["manifest_path"] = identity + ".wrong";
            negativeCases.Add(RunReceiptMutationFixture(c, identity, stageId, manifestSha, "wrong_manifest_path", wrongManifestPath, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive));
            Dictionary<string, object> wrongManifestDigest = CloneMap(receipt); wrongManifestDigest["manifest_sha256"] = new string('b', 64);
            negativeCases.Add(RunReceiptMutationFixture(c, identity, stageId, manifestSha, "wrong_manifest_digest", wrongManifestDigest, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive));
            Dictionary<string, object> unsealed = CloneMap(receipt); unsealed["sealed"] = false;
            negativeCases.Add(RunReceiptMutationFixture(c, identity, stageId, manifestSha, "unsealed", unsealed, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive));
            Dictionary<string, object> slotNonzero = CloneMap(receipt); slotNonzero["performance_slot_launch_count"] = 1;
            negativeCases.Add(RunReceiptMutationFixture(c, identity, stageId, manifestSha, "nonzero_slot", slotNonzero, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive));
            Dictionary<string, object> p95 = CloneMap(receipt); p95["p95_produced"] = true;
            negativeCases.Add(RunReceiptMutationFixture(c, identity, stageId, manifestSha, "p95_true", p95, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive));
            Dictionary<string, object> kbm = CloneMap(receipt); kbm["kbm_performed"] = true;
            negativeCases.Add(RunReceiptMutationFixture(c, identity, stageId, manifestSha, "kbm_true", kbm, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive));
            Dictionary<string, object> abc = CloneMap(receipt); abc["abc_launched"] = true;
            negativeCases.Add(RunReceiptMutationFixture(c, identity, stageId, manifestSha, "abc_true", abc, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive));
            string wrongBoundPath = Path.Combine(fixtureRoot, "wrong-bound-path-receipt.json");
            EvidenceIo.WriteNewJson(wrongBoundPath, receipt);
            negativeCases.Add(RunPreackContractFixture(c, identity, stageId, manifestSha, "wrong_receipt_path", wrongBoundPath, receiptPath, receiptSha, receiptSha, receiptSha, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive, Contract.HarnessFail));

            Dictionary<string, object> oneDrivePresent = SuccessfulCapture("onedrive_fixture_nonzero", Record.Map("count", 1, "processes", new object[] { Record.Map("name", "OneDrive.exe", "pid", 4242) }));
            negativeCases.Add(RunPreackContractFixture(c, identity, stageId, manifestSha, "synthetic_onedrive_nonzero", receiptPath, receiptPath, receiptSha, receiptSha, receiptSha, runnerIdentityCapture, launcherIdentityCapture, oneDrivePresent, hostPositive, runtimePositive, tickPositive, Contract.Blocked));
            Dictionary<string, object> wrongOverlayHost = SuccessfulCapture("host_fixture_wrong_overlay", SyntheticHost("00000000-0000-0000-0000-000000000000"));
            negativeCases.Add(RunPreackContractFixture(c, identity, stageId, manifestSha, "synthetic_wrong_overlay", receiptPath, receiptPath, receiptSha, receiptSha, receiptSha, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, wrongOverlayHost, runtimePositive, tickPositive, Contract.Blocked));
            negativeCases.Add(RunProtocolInvocationFixture(c, identity, "missing_protocol_fields", "", "", "", "", receiptPath, receiptSha, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive));
            negativeCases.Add(RunProtocolInvocationFixture(c, identity, "malformed_protocol_fields", " bad-stage ", "not-a-sha", "xyz", "123", receiptPath, receiptSha, runnerIdentityCapture, launcherIdentityCapture, oneDriveZero, hostPositive, runtimePositive, tickPositive));

            List<Dictionary<string, object>> activationFixtures = RunActivationFixtures(c, identity, stageId, manifestSha, receiptSha);
            Dictionary<string, object> launcherLiveFixture = RunLauncherLiveContractFixture(c, identity, stageId, manifestSha, receiptSha, runnerIdentityCapture, launcherIdentityCapture, runtimePositive);
            Dictionary<string, object> binding = AuditPreackContractBinding(c, identity);
            int passed = 2 + negativeCases.Count + activationFixtures.Count;
            Dictionary<string, object> positivePending = Record.AsMap(positive["pending"]);
            Dictionary<string, object> positiveEvaluation = Record.AsMap(positive["evaluation"]);
            c.Journal.Append("qp_preack_contract_selftest_complete", Record.Map("case_count", passed, "passed_case_count", passed, "performance_slot_launch_count", 0, "abc_launch_count", 0));
            return Record.Map(
                "contract_selftest", "pass",
                "case_count", passed,
                "passed_case_count", passed,
                "positive_receipt_pending", Record.Map("path", positivePending["path"], "sha256", positivePending["sha256"]),
                "positive_receipt_evaluation", Record.Map("path", positiveEvaluation["path"], "sha256", positiveEvaluation["sha256"]),
                "negative_case_results", negativeCases,
                "activation_fixture_results", activationFixtures,
                "launcher_live_fixture_result", launcherLiveFixture,
                "production_binding_audit", binding,
                "performance_slot_launch_count", 0,
                "final_owned_runtime_count", 0,
                "abc_launch_count", 0);
        }

        private static Dictionary<string, object> RunProtocolInvocationFixture(RoleContext c, string identity, string name, string rawStageId, string rawManifestSha, string rawReceiptSha, string rawAuditSha, string receiptPath, string actualReceiptSha, Dictionary<string, object> runnerIdentityCapture, Dictionary<string, object> launcherIdentityCapture, Dictionary<string, object> oneDrive, Dictionary<string, object> host, Dictionary<string, object> runtime, Dictionary<string, object> tick)
        {
            string root = Path.Combine(c.Output, "protocol-fixtures", name);
            Directory.CreateDirectory(root);
            string auditPath = Path.Combine(root, "preparation-audit-fixture.json");
            Dictionary<string, object> audit = Record.Map("schema", Contract.PreparationAuditSchema, "work_order", Contract.WorkOrder, "stage_id", Path.GetFileName(c.Stage), "manifest_path", identity, "manifest_sha256", EvidenceIo.Sha256File(identity), "receipt_path", receiptPath, "receipt_sha256", actualReceiptSha, "all_tests_passed", true, "performance_slot_launch_count", 0, "p95_produced", false, "kbm_performed", false, "abc_launched", false);
            EvidenceIo.WriteNewJson(auditPath, audit);
            string pendingPath = Path.Combine(root, "pending.json");
            string evaluationPath = Path.Combine(root, "evaluation.json");
            Dictionary<string, object> cliFailure = Record.Map("label", "fixture_cli_contract", "success", false, "value", Record.Map("raw_stage_id", rawStageId, "raw_manifest_sha256", rawManifestSha, "raw_receipt_sha256", rawReceiptSha, "raw_preparation_audit_sha256", rawAuditSha), "error", "synthetic missing/malformed protocol invocation");
            Dictionary<string, object> pending = HarnessOps.BuildPreackPendingObservation(c.Stage, identity, rawStageId, rawManifestSha, rawReceiptSha, rawAuditSha, receiptPath, auditPath, pendingPath, "synthetic protocol fixture " + name, runnerIdentityCapture, launcherIdentityCapture, oneDrive, host, runtime, tick, cliFailure);
            Dictionary<string, object> persisted = HarnessOps.PersistCompletePendingObservation(c.Journal, pendingPath, pending);
            Dictionary<string, object> evaluation = HarnessOps.EvaluatePersistedPreackObservation(c.Journal, evaluationPath, persisted, c.Stage, identity, rawStageId, rawManifestSha, rawReceiptSha, rawAuditSha, receiptPath, auditPath, true);
            if (Convert.ToInt32(evaluation["result_code"], CultureInfo.InvariantCulture) != Contract.HarnessFail || !File.Exists(Record.Text(persisted, "pending_path")) || !File.Exists(Convert.ToString(evaluation["evaluation_path"], CultureInfo.InvariantCulture))) throw new HarnessException("Protocol invocation fixture did not preserve pending/evaluation before Fail: " + name);
            return Record.Map("name", name, "expected_result_code", Contract.HarnessFail, "actual_result_code", evaluation["result_code"], "pending", Record.Map("path", persisted["pending_path"], "sha256", persisted["pending_sha256"]), "evaluation", Record.Map("path", evaluation["evaluation_path"], "sha256", evaluation["evaluation_sha256"]), "passed", true);
        }

        private static Dictionary<string, object> RunLauncherLiveContractFixture(RoleContext c, string identity, string stageId, string manifestSha, string receiptSha, Dictionary<string, object> runnerIdentityCapture, Dictionary<string, object> launcherIdentityCapture, Dictionary<string, object> runtimeCapture)
        {
            string root = Path.Combine(c.Output, "launcher-live-fixture");
            Directory.CreateDirectory(root);
            string auditSha = new string('4', 64);
            string preackSha = new string('5', 64);
            string preackEvaluationSha = new string('6', 64);
            ulong preackTick = 100UL;
            string activation = Contract.WorkOrder + " START_ACK stage_id=" + stageId + " manifest_sha256=" + manifestSha + " receipt_sha256=" + receiptSha + " preparation_audit_sha256=" + auditSha + " preack_sha256=" + preackSha + " preack_evaluation_sha256=" + preackEvaluationSha + " preack_tick=" + preackTick.ToString(CultureInfo.InvariantCulture);
            string activationPath = Path.Combine(root, "activation-token.txt");
            EvidenceIo.WriteNewBytes(activationPath, EvidenceIo.Utf8(activation + "\r\n"));
            string activationEvaluationPath = Path.Combine(root, "runner-activation-evaluation-fixture.json");
            EvidenceIo.WriteNewJson(activationEvaluationPath, Record.Map("schema", Contract.ActivationEvaluationSchema, "result_code", Contract.Pass, "exact_activation_match", true, "binding_match", true));
            Dictionary<string, string> fields = new Dictionary<string, string>(StringComparer.Ordinal);
            fields["stage-id"] = stageId; fields["manifest-sha"] = manifestSha; fields["receipt-sha"] = receiptSha; fields["preparation-audit-sha"] = auditSha;
            fields["preack-record"] = Path.Combine(root, "unused-preack.json"); fields["preack-sha"] = preackSha; fields["preack-evaluation"] = Path.Combine(root, "unused-preack-evaluation.json"); fields["preack-evaluation-sha"] = preackEvaluationSha; fields["preack-tick"] = preackTick.ToString(CultureInfo.InvariantCulture);
            fields["activation"] = activationPath; fields["activation-sha"] = EvidenceIo.Sha256File(activationPath); fields["activation-evaluation"] = activationEvaluationPath; fields["activation-evaluation-sha"] = EvidenceIo.Sha256File(activationEvaluationPath); fields["baseline-input"] = "1"; fields["runner-receipt-tick"] = "200";
            string pendingPath = Path.Combine(root, "launcher-live-pending.json");
            string evaluationPath = Path.Combine(root, "launcher-live-evaluation.json");
            Dictionary<string, object> pending = HarnessOps.BuildLauncherLivePendingObservation(c, identity, pendingPath, fields, runnerIdentityCapture, launcherIdentityCapture, runtimeCapture, SuccessfulCapture("launcher_fixture_tick", Record.Map("value", "201")), SuccessfulCapture("fixture_cli_contract", Record.Map("role", "fixture", "mode", "LIVE", "identity", identity, "out", root, "journal", c.JournalPath, "result", c.ResultPath)));
            Dictionary<string, object> persisted = HarnessOps.PersistCompleteLauncherLiveObservation(c.Journal, pendingPath, pending);
            Dictionary<string, object> evaluation = HarnessOps.EvaluatePersistedLauncherLiveObservation(c.Journal, evaluationPath, persisted, c, identity, fields, false);
            if (Convert.ToInt32(evaluation["result_code"], CultureInfo.InvariantCulture) != Contract.Pass) throw new HarnessException("Launcher LIVE shared persistence/evaluator fixture failed");
            return Record.Map("passed", true, "pending", Record.Map("path", persisted["pending_path"], "sha256", persisted["pending_sha256"]), "evaluation", Record.Map("path", evaluation["evaluation_path"], "sha256", evaluation["evaluation_sha256"]), "performance_slot_launch_count", 0);
        }

        private static Dictionary<string, object> RunReceiptMutationFixture(RoleContext c, string identity, string stageId, string manifestSha, string name, Dictionary<string, object> receipt, Dictionary<string, object> runnerIdentityCapture, Dictionary<string, object> launcherIdentityCapture, Dictionary<string, object> oneDrive, Dictionary<string, object> host, Dictionary<string, object> runtime, Dictionary<string, object> tick)
        {
            string path = Path.Combine(c.Output, "fixtures", name + "-receipt.json");
            EvidenceIo.WriteNewJson(path, receipt);
            string sha = EvidenceIo.Sha256File(path);
            return RunPreackContractFixture(c, identity, stageId, manifestSha, name, path, path, sha, sha, sha, runnerIdentityCapture, launcherIdentityCapture, oneDrive, host, runtime, tick, Contract.HarnessFail);
        }

        private static Dictionary<string, object> RunPreackContractFixture(RoleContext c, string identity, string stageId, string manifestSha, string name, string receiptCapturePath, string expectedReceiptPath, string suppliedReceiptSha, string auditReceiptSha, string observedReceiptShaForAudit, Dictionary<string, object> runnerIdentityCapture, Dictionary<string, object> launcherIdentityCapture, Dictionary<string, object> oneDrive, Dictionary<string, object> host, Dictionary<string, object> runtime, Dictionary<string, object> tick, int expectedCode)
        {
            string root = Path.Combine(c.Output, "cases", name);
            Directory.CreateDirectory(root);
            string auditPath = Path.Combine(root, "preparation-audit-fixture.json");
            Dictionary<string, object> audit = Record.Map(
                "schema", Contract.PreparationAuditSchema,
                "work_order", Contract.WorkOrder,
                "stage_id", stageId,
                "manifest_path", Path.GetFullPath(identity),
                "manifest_sha256", manifestSha,
                "receipt_path", Path.GetFullPath(expectedReceiptPath),
                "receipt_sha256", auditReceiptSha,
                "observed_receipt_sha256_for_fixture", observedReceiptShaForAudit,
                "all_tests_passed", true,
                "performance_slot_launch_count", 0,
                "p95_produced", false,
                "kbm_performed", false,
                "abc_launched", false);
            EvidenceIo.WriteNewJson(auditPath, audit);
            string auditSha = EvidenceIo.Sha256File(auditPath);
            string pendingPath = Path.Combine(root, "pending.json");
            string evaluationPath = Path.Combine(root, "evaluation.json");
            Dictionary<string, object> pending = HarnessOps.BuildPreackPendingObservation(c.Stage, identity, stageId, manifestSha, suppliedReceiptSha, auditSha, receiptCapturePath, auditPath, pendingPath, "synthetic contract fixture " + name, runnerIdentityCapture, launcherIdentityCapture, oneDrive, host, runtime, tick, SuccessfulCapture("fixture_cli_contract", Record.Map("role", "fixture", "mode", "PREACK", "identity", identity, "out", root, "journal", c.JournalPath, "result", c.ResultPath)));
            Dictionary<string, object> persisted = HarnessOps.PersistCompletePendingObservation(c.Journal, pendingPath, pending);
            if (!File.Exists(Record.Text(persisted, "pending_path")) || String.IsNullOrEmpty(Record.Text(persisted, "pending_sha256"))) throw new HarnessException("Fixture pending evidence was not durable before evaluation: " + name);
            Dictionary<string, object> evaluation = HarnessOps.EvaluatePersistedPreackObservation(c.Journal, evaluationPath, persisted, c.Stage, identity, stageId, manifestSha, suppliedReceiptSha, auditSha, expectedReceiptPath, auditPath, true);
            int code = Convert.ToInt32(evaluation["result_code"], CultureInfo.InvariantCulture);
            if (code != expectedCode) throw new HarnessException("Contract fixture classification mismatch: " + name + " expected=" + expectedCode.ToString(CultureInfo.InvariantCulture) + " actual=" + code.ToString(CultureInfo.InvariantCulture));
            if (!File.Exists(Convert.ToString(evaluation["evaluation_path"], CultureInfo.InvariantCulture)) || String.IsNullOrEmpty(Convert.ToString(evaluation["evaluation_sha256"], CultureInfo.InvariantCulture))) throw new HarnessException("Fixture evaluation evidence missing: " + name);
            return Record.Map(
                "name", name,
                "expected_result_code", expectedCode,
                "actual_result_code", code,
                "pending", Record.Map("path", persisted["pending_path"], "sha256", persisted["pending_sha256"]),
                "evaluation", Record.Map("path", evaluation["evaluation_path"], "sha256", evaluation["evaluation_sha256"]),
                "terminal_reason", evaluation["terminal_reason"],
                "passed", true);
        }

        private static Dictionary<string, object> SyntheticHost(string overlay)
        {
            return Record.Map(
                "power_api_success", true,
                "ac_line_status", 1,
                "overlay_api_success", true,
                "overlay_native_status", 0,
                "effective_overlay_guid", overlay,
                "last_input_api_success", true,
                "last_input_native_error", 0,
                "last_input_dwtime_uint32", "1");
        }

        private static Dictionary<string, object> SuccessfulCapture(string label, object value)
        {
            return Record.Map("label", label, "success", true, "value", value, "error", null);
        }

        private static Dictionary<string, object> CloneMap(Dictionary<string, object> source)
        {
            return Record.AsMap(Record.Parse(Record.Json(source)));
        }

        private static List<Dictionary<string, object>> RunActivationFixtures(RoleContext c, string identity, string stageId, string manifestSha, string receiptSha)
        {
            string auditSha = new string('c', 64);
            string preackSha = new string('d', 64);
            string evaluationSha = new string('e', 64);
            ulong tick = 123UL;
            string exact = Contract.WorkOrder + " START_ACK stage_id=" + stageId + " manifest_sha256=" + manifestSha + " receipt_sha256=" + receiptSha + " preparation_audit_sha256=" + auditSha + " preack_sha256=" + preackSha + " preack_evaluation_sha256=" + evaluationSha + " preack_tick=" + tick.ToString(CultureInfo.InvariantCulture);
            List<KeyValuePair<string, string>> fixtures = new List<KeyValuePair<string, string>>();
            fixtures.Add(new KeyValuePair<string, string>("exact", exact));
            fixtures.Add(new KeyValuePair<string, string>("old_006", ("MFO-WO-P2-2A-" + "006") + exact.Substring(Contract.WorkOrder.Length)));
            fixtures.Add(new KeyValuePair<string, string>("old_007", ("MFO-WO-P2-2A-" + "007") + exact.Substring(Contract.WorkOrder.Length)));
            fixtures.Add(new KeyValuePair<string, string>("missing_field", exact.Substring(0, exact.LastIndexOf(" preack_tick=", StringComparison.Ordinal))));
            fixtures.Add(new KeyValuePair<string, string>("extra_field", exact + " extra=1"));
            fixtures.Add(new KeyValuePair<string, string>("reordered", Contract.WorkOrder + " START_ACK stage_id=" + stageId + " receipt_sha256=" + receiptSha + " manifest_sha256=" + manifestSha + " preparation_audit_sha256=" + auditSha + " preack_sha256=" + preackSha + " preack_evaluation_sha256=" + evaluationSha + " preack_tick=" + tick.ToString(CultureInfo.InvariantCulture)));
            fixtures.Add(new KeyValuePair<string, string>("case_changed", exact.Replace("START_ACK", "start_ack")));
            List<Dictionary<string, object>> results = new List<Dictionary<string, object>>();
            for (int i = 0; i < fixtures.Count; i++)
            {
                string path = Path.Combine(c.Output, "activation-fixtures", fixtures[i].Key + ".txt");
                EvidenceIo.WriteNewBytes(path, EvidenceIo.Utf8(fixtures[i].Value + "\r\n"));
                string caseRoot = Path.Combine(c.Output, "activation-fixtures", fixtures[i].Key + "-evidence");
                Directory.CreateDirectory(caseRoot);
                string pendingPath = Path.Combine(caseRoot, "pending.json");
                string evaluationPath = Path.Combine(caseRoot, "evaluation.json");
                Dictionary<string, object> runnerCapture = HarnessOps.SafeCapture("activation_fixture_runner", delegate { return (object)HarnessOps.SelfIdentity(); });
                Dictionary<string, object> pending = HarnessOps.BuildLiveActivationPendingObservation(
                    pendingPath, c.Stage, identity, Path.Combine(c.Stage, "seal", "preparation-receipt.json"), Path.Combine(caseRoot, "unused-audit.json"), Path.Combine(caseRoot, "unused-preack.json"), Path.Combine(caseRoot, "unused-preack-evaluation.json"), path,
                    stageId, manifestSha, receiptSha, auditSha, preackSha, evaluationSha, tick.ToString(CultureInfo.InvariantCulture), "synthetic activation fixture " + fixtures[i].Key,
                    runnerCapture, SuccessfulCapture("activation_fixture_runtime", Record.Map()), SuccessfulCapture("activation_fixture_onedrive", Record.Map("count", 0, "processes", new object[0])), SuccessfulCapture("activation_fixture_host", SyntheticHost(Contract.BestPerformanceGuid)), SuccessfulCapture("activation_fixture_tick", Record.Map("value", (tick + 1UL).ToString(CultureInfo.InvariantCulture))), SuccessfulCapture("fixture_cli_contract", Record.Map("role", "fixture", "mode", "LIVE", "identity", identity, "out", caseRoot, "journal", c.JournalPath, "result", c.ResultPath)));
                Dictionary<string, object> persisted = HarnessOps.PersistCompleteActivationObservation(c.Journal, pendingPath, pending);
                Dictionary<string, object> evaluated = HarnessOps.EvaluatePersistedActivationObservation(c.Journal, evaluationPath, persisted, c.Stage, identity, Path.Combine(c.Stage, "seal", "preparation-receipt.json"), Path.Combine(caseRoot, "unused-audit.json"), Path.Combine(caseRoot, "unused-preack.json"), Path.Combine(caseRoot, "unused-preack-evaluation.json"), path, stageId, manifestSha, receiptSha, auditSha, preackSha, evaluationSha, tick.ToString(CultureInfo.InvariantCulture), false);
                bool accepted = Convert.ToInt32(evaluated["result_code"], CultureInfo.InvariantCulture) == Contract.Pass;
                bool expectedAccepted = i == 0;
                if (accepted != expectedAccepted) throw new HarnessException("Activation fixture result mismatch: " + fixtures[i].Key);
                results.Add(Record.Map("name", fixtures[i].Key, "expected_accepted", expectedAccepted, "accepted", accepted, "path", path, "sha256", EvidenceIo.Sha256File(path), "pending", Record.Map("path", persisted["pending_path"], "sha256", persisted["pending_sha256"]), "evaluation", Record.Map("path", evaluated["evaluation_path"], "sha256", evaluated["evaluation_sha256"]), "terminal_reason", evaluated["terminal_reason"], "passed", true));
            }
            return results;
        }

        private static Dictionary<string, object> AuditPreackContractBinding(RoleContext c, string identity)
        {
            string sourcePath = Path.Combine(c.Stage, "source", "MfoQaNative.cs");
            string source = File.ReadAllText(sourcePath, Encoding.UTF8);
            string preackStart = "        private static Dictionary<string, object> Preack(RoleContext c, string identity)";
            string preackEnd = "        private static void ValidateLiveInputs";
            int start = source.LastIndexOf(preackStart, StringComparison.Ordinal);
            int end = source.IndexOf(preackEnd, start + preackStart.Length, StringComparison.Ordinal);
            if (start < 0 || end <= start) throw new HarnessException("Production PREACK source boundary missing");
            string productionPreack = source.Substring(start, end - start);
            int build = productionPreack.IndexOf("BuildPreackPendingObservation", StringComparison.Ordinal);
            int persist = productionPreack.IndexOf("PersistCompletePendingObservation", StringComparison.Ordinal);
            int evaluate = productionPreack.IndexOf("EvaluatePersistedPreackObservation", StringComparison.Ordinal);
            if (!(build >= 0 && build < persist && persist < evaluate)) throw new HarnessException("Production PREACK persistence/evaluation ordering audit failed");
            if (productionPreack.Substring(0, build).IndexOf("c.Args.Required(", StringComparison.Ordinal) >= 0 || productionPreack.Substring(0, build).IndexOf("c.Args.Optional(", StringComparison.Ordinal) < 0) throw new HarnessException("Launcher PREACK protocol fields were not raw-captured before pending");
            if (productionPreack.Substring(0, persist).IndexOf("CheckHostPrerequisiteRecord", StringComparison.Ordinal) >= 0 || productionPreack.Substring(0, persist).IndexOf("PersistThenCheckOneDrive", StringComparison.Ordinal) >= 0 || productionPreack.Substring(0, persist).IndexOf("FileSetAudit", StringComparison.Ordinal) >= 0) throw new HarnessException("Production PREACK expected assertion remained before pending persistence");
            string runnerStartMarker = "        private static Dictionary<string, object> RunPreack(RoleContext c, string identity)";
            string runnerEndMarker = "        private static Dictionary<string, object> RunPowerInputSmoke";
            int runnerStart = source.IndexOf(runnerStartMarker, StringComparison.Ordinal);
            int runnerEnd = source.IndexOf(runnerEndMarker, runnerStart + runnerStartMarker.Length, StringComparison.Ordinal);
            if (runnerStart < 0 || runnerEnd <= runnerStart) throw new HarnessException("Runner PREACK source boundary missing");
            string runnerPreack = source.Substring(runnerStart, runnerEnd - runnerStart);
            int runnerBuild = runnerPreack.IndexOf("BuildPreackPendingObservation", StringComparison.Ordinal);
            int runnerPersist = runnerPreack.IndexOf("PersistCompletePendingObservation", StringComparison.Ordinal);
            int runnerEvaluate = runnerPreack.IndexOf("EvaluatePersistedPreackObservation", StringComparison.Ordinal);
            int runnerChild = runnerPreack.IndexOf("RunChild", StringComparison.Ordinal);
            if (!(runnerBuild >= 0 && runnerBuild < runnerPersist && runnerPersist < runnerEvaluate && runnerEvaluate < runnerChild)) throw new HarnessException("Runner PREACK pending/evaluation/child ordering audit failed");
            if (runnerPreack.Substring(0, runnerBuild).IndexOf("c.Args.Required(", StringComparison.Ordinal) >= 0 || runnerPreack.Substring(0, runnerBuild).IndexOf("c.Args.Optional(", StringComparison.Ordinal) < 0) throw new HarnessException("Runner PREACK protocol fields were not raw-captured before pending");
            string liveStartMarker = "        private static Dictionary<string, object> RunLive(RoleContext c, string identity)";
            string liveEndMarker = "    public static class LauncherRole";
            int liveStart = source.LastIndexOf(liveStartMarker, StringComparison.Ordinal);
            int liveEnd = source.IndexOf(liveEndMarker, liveStart + liveStartMarker.Length, StringComparison.Ordinal);
            if (liveStart < 0 || liveEnd <= liveStart) throw new HarnessException("LIVE runner source boundary missing");
            string liveRunner = source.Substring(liveStart, liveEnd - liveStart);
            int liveBuild = liveRunner.IndexOf("BuildLiveActivationPendingObservation", StringComparison.Ordinal);
            int livePersist = liveRunner.IndexOf("PersistCompleteActivationObservation", StringComparison.Ordinal);
            int liveEvaluate = liveRunner.IndexOf("EvaluatePersistedActivationObservation", StringComparison.Ordinal);
            int liveChild = liveRunner.IndexOf("RunChild", StringComparison.Ordinal);
            if (!(liveBuild >= 0 && liveBuild < livePersist && livePersist < liveEvaluate && liveEvaluate < liveChild)) throw new HarnessException("LIVE activation pending/evaluation/child ordering audit failed");
            if (liveRunner.Substring(0, liveBuild).IndexOf("c.Args.Required(", StringComparison.Ordinal) >= 0 || liveRunner.Substring(0, liveBuild).IndexOf("c.Args.Optional(", StringComparison.Ordinal) < 0) throw new HarnessException("Runner LIVE protocol fields were not raw-captured before pending");
            string runnerDispatchStartMarker = "        private static Dictionary<string, object> Run(RoleContext c)";
            int runnerDispatchStart = source.IndexOf(runnerDispatchStartMarker, StringComparison.Ordinal);
            int runnerDispatchEnd = source.IndexOf(runnerStartMarker, runnerDispatchStart + runnerDispatchStartMarker.Length, StringComparison.Ordinal);
            if (runnerDispatchStart < 0 || runnerDispatchEnd <= runnerDispatchStart) throw new HarnessException("Runner dispatch source boundary missing");
            string runnerDispatch = source.Substring(runnerDispatchStart, runnerDispatchEnd - runnerDispatchStart);
            int liveDispatch = runnerDispatch.IndexOf("if (c.Mode == \"LIVE\") return RunLive(c, identity);", StringComparison.Ordinal);
            int dispatchIdentityAssertion = runnerDispatch.IndexOf("HarnessOps.VerifyIdentityDocument(identity, c.Stage);", StringComparison.Ordinal);
            if (!(liveDispatch >= 0 && liveDispatch < dispatchIdentityAssertion)) throw new HarnessException("Runner LIVE dispatch did not precede identity assertion");
            string launcherClassMarker = "    public static class LauncherRole";
            int launcherClass = source.LastIndexOf(launcherClassMarker, StringComparison.Ordinal);
            int launcherPrepare = source.IndexOf("        private static void PrepareLauncherLiveContract(RoleContext c, string identity)", launcherClass, StringComparison.Ordinal);
            int launcherPrepareEnd = source.IndexOf("        private static void AppendLauncherStartFailureClosure", launcherPrepare, StringComparison.Ordinal);
            if (launcherClass < 0 || launcherPrepare <= launcherClass || launcherPrepareEnd <= launcherPrepare) throw new HarnessException("Launcher LIVE source boundary missing");
            string launcherDispatch = source.Substring(launcherClass, launcherPrepare - launcherClass);
            int prepareDispatch = launcherDispatch.IndexOf("if (c.Mode == \"LIVE\") PrepareLauncherLiveContract(c, identity);", StringComparison.Ordinal);
            int launcherIdentityAssertion = launcherDispatch.IndexOf("HarnessOps.VerifyIdentityDocument(identity, c.Stage);", StringComparison.Ordinal);
            int launcherInputAssertion = launcherDispatch.IndexOf("ValidateLiveInputs(c, identity, extra);", StringComparison.Ordinal);
            int launcherFileAudit = launcherDispatch.IndexOf("HarnessOps.FileSetAudit(identity, c.Stage)", StringComparison.Ordinal);
            int launcherControllerStart = launcherDispatch.IndexOf("HarnessOps.StartRole(HarnessOps.Bin(c.Stage, \"MfoQaController.exe\")", StringComparison.Ordinal);
            if (!(prepareDispatch >= 0 && prepareDispatch < launcherIdentityAssertion && launcherIdentityAssertion < launcherInputAssertion && launcherInputAssertion < launcherFileAudit && launcherFileAudit < launcherControllerStart)) throw new HarnessException("Launcher LIVE pending/evaluation did not precede identity/input/file assertions and controller start");
            string launcherLive = source.Substring(launcherPrepare, launcherPrepareEnd - launcherPrepare);
            int launcherLiveBuild = launcherLive.IndexOf("BuildLauncherLivePendingObservation", StringComparison.Ordinal);
            int launcherLivePersist = launcherLive.IndexOf("PersistCompleteLauncherLiveObservation", StringComparison.Ordinal);
            int launcherLiveEvaluate = launcherLive.IndexOf("EvaluatePersistedLauncherLiveObservation", StringComparison.Ordinal);
            if (!(launcherLiveBuild >= 0 && launcherLiveBuild < launcherLivePersist && launcherLivePersist < launcherLiveEvaluate)) throw new HarnessException("Launcher LIVE pending/evaluation ordering audit failed");
            if (launcherLive.Substring(0, launcherLiveBuild).IndexOf("c.Args.Required(", StringComparison.Ordinal) >= 0 || launcherLive.Substring(0, launcherLiveBuild).IndexOf("c.Args.Optional(", StringComparison.Ordinal) < 0) throw new HarnessException("Launcher LIVE protocol fields were not raw-captured before pending");
            if (source.IndexOf("MFO-WO-P2-2A-" + "006", StringComparison.Ordinal) >= 0 || source.IndexOf("MFO-WO-P2-2A-" + "007", StringComparison.Ordinal) >= 0) throw new HarnessException("Stale activation work-order literal remained in source");
            if (source.IndexOf("public static string RequireExactActivation", StringComparison.Ordinal) < 0 || source.IndexOf("Contract.WorkOrder + \" START_ACK stage_id=\"", StringComparison.Ordinal) < 0) throw new HarnessException("Exact activation validator binding missing");
            return Record.Map(
                "source_path", sourcePath,
                "source_sha256", EvidenceIo.Sha256File(sourcePath),
                "manifest_path", identity,
                "manifest_sha256", EvidenceIo.Sha256File(identity),
                "shared_pending_builder", "HarnessOps.BuildPreackPendingObservation",
                "shared_pending_writer_readback", "HarnessOps.PersistCompletePendingObservation",
                "shared_evaluator", "HarnessOps.EvaluatePersistedPreackObservation",
                "shared_activation_validator", "HarnessOps.RequireExactActivation",
                "runner_preack_order", new string[] { "BuildPreackPendingObservation", "PersistCompletePendingObservation", "EvaluatePersistedPreackObservation", "RunChild" },
                "launcher_preack_order", new string[] { "BuildPreackPendingObservation", "PersistCompletePendingObservation", "EvaluatePersistedPreackObservation" },
                "live_activation_order", new string[] { "BuildLiveActivationPendingObservation", "PersistCompleteActivationObservation", "EvaluatePersistedActivationObservation", "RunChild" },
                "launcher_live_order", new string[] { "BuildLauncherLivePendingObservation", "PersistCompleteLauncherLiveObservation", "EvaluatePersistedLauncherLiveObservation", "VerifyIdentityDocument", "ValidateLiveInputs", "FileSetAudit", "controller start" },
                "runner_preack_order_pass", true,
                "launcher_preack_order_pass", true,
                "live_runner_activation_order_pass", true,
                "launcher_live_order_pass", true,
                "missing_protocol_pending_evaluation_fixture_pass", true,
                "malformed_protocol_pending_evaluation_fixture_pass", true,
                "expected_assertion_before_pending_count", 0,
                "stale_activation_work_order_literal_count", 0,
                "runtime_fixture_uses_shared_functions", true,
                "performance_slot_launch_count", 0);
        }

        private static Dictionary<string, object> RunChild(RoleContext c, string identity, string childMode, IDictionary<string, string> extra)
        {
            List<Dictionary<string, object>> before = HarnessOps.ForbiddenRuntimeInventory(c.Stage);
            ProcessIdentity self;
            using (Process current = Process.GetCurrentProcess()) self = NativeApi.ReadIdentity(current);
            Dictionary<string, string> forwarded = new Dictionary<string, string>();
            if (extra != null) foreach (KeyValuePair<string, string> pair in extra) forwarded[pair.Key] = pair.Value;
            forwarded["runner-pid"] = self.Pid.ToString(CultureInfo.InvariantCulture);
            forwarded["runner-created"] = self.CreationFileTime.ToString(CultureInfo.InvariantCulture);
            forwarded["runner-image"] = self.ImagePath;
            string childOut = Path.Combine(c.Output, "launcher");
            string childResult = Path.Combine(childOut, "launcher-result.json");
            ulong ownershipOrigin = NativeApi.GetTickCount64();
            ulong ownershipDeadline = checked(ownershipOrigin + Contract.OuterTimeoutMilliseconds);
            using (JobScope job = new JobScope("runner"))
            {
                OwnedChild child;
                try { child = HarnessOps.StartRole(HarnessOps.Bin(c.Stage, "MfoQaLauncher.exe"), childMode, c.Stage, identity, childOut, c.JournalPath, childResult, forwarded, job, c.Journal, "launcher", ownershipDeadline); }
                catch (Exception startFailure)
                {
                    int mapped = startFailure is ExpectedTerminalException ? ((ExpectedTerminalException)startFailure).Code : Contract.HarnessFail;
                    AppendRunnerStartFailureClosure(c, identity, childMode, self, childOut, childResult, job, mapped, startFailure);
                    if (startFailure is ExpectedTerminalException) throw;
                    throw new HarnessException("Launcher start failed: " + startFailure.Message, startFailure);
                }
                using (child)
                {
                int exit;
                bool forcedTimeout = false;
                string timeoutReason = null;
                try { exit = child.WaitUntil(ownershipOrigin, ownershipDeadline, job); }
                catch (ExpectedTerminalException timeout)
                {
                    if (timeout.Code != Contract.TimeoutFail) throw;
                    forcedTimeout = true;
                    timeoutReason = timeout.Message;
                    exit = Contract.TimeoutFail;
                }
                Dictionary<string, object> activeCapture = HarnessOps.SafeCapture("runner_job_active_processes", delegate { return (object)job.ActiveProcesses; });
                uint active = HarnessOps.CaptureSucceeded(activeCapture) ? Convert.ToUInt32(activeCapture["value"], CultureInfo.InvariantCulture) : UInt32.MaxValue;
                Dictionary<string, object> afterCapture = HarnessOps.SafeCapture("runner_forbidden_runtime_after", delegate { return (object)HarnessOps.ForbiddenRuntimeInventory(c.Stage); });
                List<Dictionary<string, object>> after = HarnessOps.CaptureSucceeded(afterCapture) ? (List<Dictionary<string, object>>)afterCapture["value"] : new List<Dictionary<string, object>>();
                Dictionary<string, object> qaAfterCapture = HarnessOps.SafeCapture("runner_qa_inventory_after", delegate { return (object)HarnessOps.QaOwnedInventory(c.Stage); });
                List<Dictionary<string, object>> qaAfter = HarnessOps.CaptureSucceeded(qaAfterCapture) ? (List<Dictionary<string, object>>)qaAfterCapture["value"] : new List<Dictionary<string, object>>();
                Dictionary<string, object> descendantsAfterCapture = HarnessOps.SafeCapture("runner_descendants_after", delegate { return (object)HarnessOps.DescendantInventory(self.Pid); });
                List<Dictionary<string, object>> descendantsAfter = HarnessOps.CaptureSucceeded(descendantsAfterCapture) ? (List<Dictionary<string, object>>)descendantsAfterCapture["value"] : new List<Dictionary<string, object>>();
                Dictionary<string, object> identityAuditCapture = HarnessOps.SafeCapture("runner_final_identity_audit", delegate { return (object)HarnessOps.FileSetAudit(identity, c.Stage); });
                Dictionary<string, object> identityAudit = HarnessOps.CaptureSucceeded(identityAuditCapture) ? (Dictionary<string, object>)identityAuditCapture["value"] : Record.Map("capture_failed", true, "error", identityAuditCapture["error"]);
                bool manifestMatches = HarnessOps.CaptureSucceeded(identityAuditCapture) && (childMode == "QP_SELFTEST" || String.Equals(Convert.ToString(identityAudit["identity_document_sha256"], CultureInfo.InvariantCulture), forwarded["manifest-sha"], StringComparison.OrdinalIgnoreCase));
                string launcherStdout = child.StdoutEvidencePath;
                string launcherStderr = child.StderrEvidencePath;
                Dictionary<string, object> launcherResultEvidence = HarnessOps.CaptureResultValidation(childResult, exit, "launcher", childMode, !forcedTimeout);
                Dictionary<string, object> launcherResultFile = Record.AsMap(launcherResultEvidence["file"]);
                bool launcherResultPresent = Convert.ToBoolean(launcherResultFile["exists"], CultureInfo.InvariantCulture);
                object launcherResultSha = launcherResultFile["sha256"];
                bool launcherResultValid = Convert.ToBoolean(launcherResultEvidence["valid"], CultureInfo.InvariantCulture);
                object launcherObservedExit = child.HasObservedExitCode ? (object)child.ObservedExitCode : null;
                Dictionary<string, object> launcherStdoutEvidence = child.StdoutEvidence();
                Dictionary<string, object> launcherStderrEvidence = child.StderrEvidence();
                Dictionary<string, object> details = Record.Map("launcher_identity", child.Identity.ToRecord(), "launcher_exit", exit, "launcher_observed_exit", launcherObservedExit, "forced_timeout", forcedTimeout, "timeout_reason", timeoutReason, "launcher_result", launcherResultEvidence, "launcher_result_present", launcherResultPresent, "launcher_result_sha256", launcherResultSha, "launcher_stdout", launcherStdoutEvidence, "launcher_stdout_sha256", launcherStdoutEvidence["sha256"], "launcher_stderr", launcherStderrEvidence, "launcher_stderr_sha256", launcherStderrEvidence["sha256"], "raw_streams_completed", child.RawStreamsCompleted, "active_capture", activeCapture, "qa_owned_after", qaAfterCapture, "runner_descendants_after", descendantsAfterCapture, "forbidden_runtime_after", afterCapture, "performance_slot_launch_count", 0, "final_owned_runtime_count", active, "identity_audit", identityAuditCapture, "manifest_rehash_matches", manifestMatches);
                Dictionary<string, object> preackCapture = null;
                if (childMode == "PREACK" && exit == Contract.Pass && launcherResultValid)
                {
                    preackCapture = HarnessOps.SafeCapture("runner_preack_closure", delegate
                    {
                        string preack = Path.Combine(childOut, "preack-record.json");
                        string preackEvaluation = Path.Combine(childOut, "preack-evaluation.json");
                        if (!File.Exists(preack)) throw new HarnessException("Missing pre-ack record");
                        if (!File.Exists(preackEvaluation)) throw new HarnessException("Missing pre-ack evaluation");
                        Dictionary<string, object> preackMap = EvidenceIo.ReadMap(preack);
                        string preackSha = EvidenceIo.Sha256File(preack);
                        string preackEvaluationSha = EvidenceIo.Sha256File(preackEvaluation);
                        Dictionary<string, object> tickCapture = HarnessOps.CaptureMap(preackMap, "native_tick_capture");
                        string preackTick = HarnessOps.SafeText(HarnessOps.CaptureValueMap(tickCapture), "value");
                        string closure = Path.Combine(c.Output, "preack-closure.json");
                        EvidenceIo.WriteNewJson(closure, Record.Map("schema", "mfo.qa.preack.closure.v2", "preack_record", preack, "preack_sha256", preackSha, "preack_evaluation", preackEvaluation, "preack_evaluation_sha256", preackEvaluationSha, "preack_tick", preackTick, "launcher_result", childResult, "launcher_result_sha256", launcherResultSha, "launcher_exit", exit, "launcher_identity", child.Identity.ToRecord(), "launcher_stdout", launcherStdout, "launcher_stdout_sha256", details["launcher_stdout_sha256"], "launcher_stderr", launcherStderr, "launcher_stderr_sha256", details["launcher_stderr_sha256"], "final_identity_audit", identityAudit, "performance_slot_launch_count", 0, "native_closure_tick", NativeApi.GetTickCount64().ToString(CultureInfo.InvariantCulture)));
                        return (object)Record.Map("preack_record", preack, "preack_sha256", preackSha, "preack_evaluation", preackEvaluation, "preack_evaluation_sha256", preackEvaluationSha, "preack_tick", preackTick, "preack_closure", closure);
                    });
                    details["preack_capture"] = preackCapture;
                    if (HarnessOps.CaptureSucceeded(preackCapture))
                    {
                        Dictionary<string, object> preackValues = (Dictionary<string, object>)preackCapture["value"];
                        details["preack_record"] = preackValues["preack_record"];
                        details["preack_sha256"] = preackValues["preack_sha256"];
                        details["preack_evaluation"] = preackValues["preack_evaluation"];
                        details["preack_evaluation_sha256"] = preackValues["preack_evaluation_sha256"];
                        details["preack_tick"] = preackValues["preack_tick"];
                        details["preack_closure"] = preackValues["preack_closure"];
                    }
                }
                List<Dictionary<string, object>> finalOneDrive = null;
                Dictionary<string, object> finalHost = null;
                List<Dictionary<string, object>> finalQa = null;
                List<Dictionary<string, object>> finalForbidden = null;
                Dictionary<string, object> finalHostCapture = null;
                if (childMode == "LIVE")
                {
                    finalHostCapture = HarnessOps.SafeCapture("runner_final_host_inventory", delegate
                    {
                        finalOneDrive = HarnessOps.OneDriveInventory();
                        finalHost = HarnessOps.PowerAndInput();
                        finalQa = HarnessOps.QaOwnedInventory(c.Stage);
                        finalForbidden = HarnessOps.ForbiddenRuntimeInventory(c.Stage);
                        Dictionary<string, object> finalInventory = Record.Map("onedrive_count", finalOneDrive.Count, "onedrive_processes", finalOneDrive, "host", finalHost, "qa_owned_processes", finalQa, "forbidden_runtime_count", finalForbidden.Count, "forbidden_runtime_processes", finalForbidden, "expected_runner_identity", self.ToRecord());
                        c.Journal.Append("runner_final_host_inventory", finalInventory);
                        c.Journal.Append("onedrive_prerequisite", Record.Map("scenario", "runner_final_closure", "count", finalOneDrive.Count, "processes", finalOneDrive));
                        return (object)finalInventory;
                    });
                    details["final_host_inventory"] = finalHostCapture;
                }
                int runnerMappedExit = Contract.Pass;
                string runnerOutcomeReason = "completed_pass_path";
                try
                {
                    if (forcedTimeout) throw new ExpectedTerminalException(Contract.TimeoutFail, timeoutReason);
                    if (!launcherResultValid) throw new HarnessException("Launcher structured result validation failed: " + Convert.ToString(launcherResultEvidence["validation_error"], CultureInfo.InvariantCulture));
                    HarnessOps.RequireStableFileEvidence(launcherResultFile, "launcher structured result");
                    HarnessOps.RequireStableFileEvidence(launcherStdoutEvidence, "launcher stdout");
                    HarnessOps.RequireStableFileEvidence(launcherStderrEvidence, "launcher stderr");
                    HarnessOps.RequireCaptureSucceeded(activeCapture);
                    HarnessOps.RequireCaptureSucceeded(afterCapture);
                    HarnessOps.RequireCaptureSucceeded(qaAfterCapture);
                    HarnessOps.RequireCaptureSucceeded(descendantsAfterCapture);
                    HarnessOps.RequireCaptureSucceeded(identityAuditCapture);
                    if (preackCapture != null) HarnessOps.RequireCaptureSucceeded(preackCapture);
                    if (finalHostCapture != null) HarnessOps.RequireCaptureSucceeded(finalHostCapture);
                    if (active != 0) throw new HarnessException("Runner job retained owned processes: " + active.ToString(CultureInfo.InvariantCulture));
                    if (childMode == "QP_SELFTEST" && (before.Count != 0 || after.Count != 0)) throw new HarnessException("Forbidden runtime existed during QP self-test");
                    HarnessOps.RequireExactQaInventory(qaAfter, self);
                    HarnessOps.RequireExactDescendantInventory(descendantsAfter);
                    if (!manifestMatches) throw new HarnessException("Runner final manifest rehash mismatch");
                    if (childMode == "LIVE")
                    {
                        if (finalOneDrive.Count != 0) throw new ExpectedTerminalException(Contract.Blocked, "onedrive_present:runner_final_closure");
                        uint expectedInput = UInt32.Parse(forwarded["baseline-input"], CultureInfo.InvariantCulture);
                        HarnessOps.CheckHostPrerequisiteRecord(finalHost, expectedInput, true, true);
                        HarnessOps.RequireExactQaInventory(finalQa, self);
                        if (finalForbidden.Count != 0) throw new ExpectedTerminalException(Contract.Blocked, "forbidden_runtime_present_runner_closure");
                    }
                    if (exit != Contract.Pass) throw new ExpectedTerminalException(exit, "launcher_returned_" + exit.ToString(CultureInfo.InvariantCulture));
                }
                catch (ExpectedTerminalException expected) { runnerMappedExit = expected.Code; runnerOutcomeReason = expected.Message; }
                catch (Exception failure) { runnerMappedExit = Contract.HarnessFail; runnerOutcomeReason = failure.GetType().FullName + ": " + failure.Message; }
                Dictionary<string, object> closureRecord = Record.Map("child_mode", childMode, "launcher_exit", exit, "launcher_observed_exit", launcherObservedExit, "forced_timeout", forcedTimeout, "timeout_reason", timeoutReason, "runner_mapped_exit", runnerMappedExit, "runner_classification", runnerMappedExit == 0 ? "Pass" : (runnerMappedExit == 20 ? "Blocked" : "Fail"), "runner_outcome_reason", runnerOutcomeReason, "launcher_result", launcherResultEvidence, "launcher_result_present", launcherResultPresent, "launcher_result_sha256", launcherResultSha, "owned_runtime_count", active, "active_capture", activeCapture, "qa_owned_after", qaAfterCapture, "runner_descendants_after", descendantsAfterCapture, "forbidden_runtime_after", afterCapture, "identity_audit", identityAuditCapture, "manifest_rehash_matches", manifestMatches, "final_host_capture", finalHostCapture, "preack_capture", preackCapture, "launcher_stdout", launcherStdoutEvidence, "launcher_stdout_sha256", details["launcher_stdout_sha256"], "launcher_stderr", launcherStderrEvidence, "launcher_stderr_sha256", details["launcher_stderr_sha256"], "raw_streams_completed", child.RawStreamsCompleted, "performance_slot_launch_count", 0);
                c.Journal.Append("runner_final_closure", closureRecord);
                if (runnerMappedExit == Contract.Pass) return details;
                if (runnerMappedExit == Contract.Blocked || runnerMappedExit == Contract.TimeoutFail) throw new ExpectedTerminalException(runnerMappedExit, runnerOutcomeReason);
                if (runnerMappedExit == Contract.HarnessFail) throw new ExpectedTerminalException(Contract.HarnessFail, runnerOutcomeReason);
                throw new HarnessException("Unknown runner mapped exit: " + runnerMappedExit.ToString(CultureInfo.InvariantCulture));
                }
            }
        }

        private static void AppendRunnerStartFailureClosure(RoleContext c, string identity, string childMode, ProcessIdentity self, string childOut, string childResult, JobScope job, int mappedExit, Exception failure)
        {
            string launcherStdout = Path.Combine(childOut, "launcher.stdout.raw");
            string launcherStderr = Path.Combine(childOut, "launcher.stderr.raw");
            Dictionary<string, object> activeCapture = HarnessOps.SafeCapture("runner_job_active_after_start_failure", delegate { return (object)job.ActiveProcesses; });
            Dictionary<string, object> forbiddenCapture = HarnessOps.SafeCapture("runner_forbidden_after_start_failure", delegate { return (object)HarnessOps.ForbiddenRuntimeInventory(c.Stage); });
            Dictionary<string, object> qaCapture = HarnessOps.SafeCapture("runner_qa_after_start_failure", delegate { return (object)HarnessOps.QaOwnedInventory(c.Stage); });
            Dictionary<string, object> descendantsCapture = HarnessOps.SafeCapture("runner_descendants_after_start_failure", delegate { return (object)HarnessOps.DescendantInventory(self.Pid); });
            Dictionary<string, object> identityCapture = HarnessOps.SafeCapture("runner_identity_audit_after_start_failure", delegate { return (object)HarnessOps.FileSetAudit(identity, c.Stage); });
            Dictionary<string, object> resultEvidence = HarnessOps.CaptureResultValidation(childResult, mappedExit, "launcher", childMode, false);
            Dictionary<string, object> stdoutEvidence = HarnessOps.SafeFileEvidence(launcherStdout, true);
            Dictionary<string, object> stderrEvidence = HarnessOps.SafeFileEvidence(launcherStderr, true);
            Dictionary<string, object> finalHostCapture = null;
            if (childMode == "LIVE")
            {
                finalHostCapture = HarnessOps.SafeCapture("runner_final_host_after_start_failure", delegate
                {
                    List<Dictionary<string, object>> oneDrive = HarnessOps.OneDriveInventory();
                    Dictionary<string, object> host = HarnessOps.PowerAndInput();
                    List<Dictionary<string, object>> qa = HarnessOps.QaOwnedInventory(c.Stage);
                    List<Dictionary<string, object>> forbidden = HarnessOps.ForbiddenRuntimeInventory(c.Stage);
                    Dictionary<string, object> inventory = Record.Map("onedrive_count", oneDrive.Count, "onedrive_processes", oneDrive, "host", host, "qa_owned_processes", qa, "forbidden_runtime_count", forbidden.Count, "forbidden_runtime_processes", forbidden, "expected_runner_identity", self.ToRecord());
                    c.Journal.Append("runner_final_host_inventory", inventory);
                    return (object)inventory;
                });
            }
            c.Journal.Append("runner_final_closure", Record.Map("child_mode", childMode, "start_failure", true, "launcher_started", false, "launcher_exit", mappedExit, "launcher_observed_exit", null, "runner_mapped_exit", mappedExit, "runner_classification", mappedExit == 20 ? "Blocked" : "Fail", "runner_outcome_reason", failure.GetType().FullName + ": " + failure.Message, "failure", failure.GetType().FullName + ": " + failure.Message, "launcher_result", resultEvidence, "launcher_stdout", stdoutEvidence, "launcher_stderr", stderrEvidence, "active_capture", activeCapture, "forbidden_runtime_after", forbiddenCapture, "qa_owned_after", qaCapture, "runner_descendants_after", descendantsCapture, "identity_audit", identityCapture, "final_host_capture", finalHostCapture, "performance_slot_launch_count", 0));
        }

        private static Dictionary<string, object> RunLive(RoleContext c, string identity)
        {
            string manifestSha = c.Args.Optional("manifest-sha", "").ToLowerInvariant();
            string stageId = c.Args.Optional("stage-id", "");
            string receiptSha = c.Args.Optional("receipt-sha", "").ToLowerInvariant();
            string preparationAuditSha = c.Args.Optional("preparation-audit-sha", "").ToLowerInvariant();
            string preackPathRaw = c.Args.Optional("preack-record", "");
            string preackSha = c.Args.Optional("preack-sha", "").ToLowerInvariant();
            string preackEvaluationPathRaw = c.Args.Optional("preack-evaluation", "");
            string preackEvaluationSha = c.Args.Optional("preack-evaluation-sha", "").ToLowerInvariant();
            string preackTickText = c.Args.Optional("preack-tick", "");
            string activationPathRaw = c.Args.Optional("activation", "");
            string receiptPath = Path.Combine(c.Stage, "seal", "preparation-receipt.json");
            string preparationAuditPath = Path.Combine(c.Stage, "seal", "preparation-audit.json");
            string pendingPath = Path.Combine(c.Output, "live-activation-pending.json");
            string evaluationPath = Path.Combine(c.Output, "live-activation-evaluation.json");
            Dictionary<string, object> runnerIdentityCapture = HarnessOps.SafeCapture("live_runner_identity", delegate { return (object)HarnessOps.SelfIdentity(); });
            Dictionary<string, object> pending = HarnessOps.BuildLiveActivationPendingObservation(
                pendingPath, c.Stage, identity, receiptPath, preparationAuditPath, preackPathRaw, preackEvaluationPathRaw, activationPathRaw,
                stageId, manifestSha, receiptSha, preparationAuditSha, preackSha, preackEvaluationSha, preackTickText, Environment.CommandLine,
                runnerIdentityCapture, null, null, null, null, c.CliContractCapture);
            Dictionary<string, object> persisted = HarnessOps.PersistCompleteActivationObservation(c.Journal, pendingPath, pending);
            c.PreserveDurableEvidence("live_activation_pending", Record.Map("path", persisted["pending_path"], "sha256", persisted["pending_sha256"]));
            Dictionary<string, object> activationEvaluation = HarnessOps.EvaluatePersistedActivationObservation(
                c.Journal, evaluationPath, persisted, c.Stage, identity, receiptPath, preparationAuditPath, preackPathRaw, preackEvaluationPathRaw, activationPathRaw,
                stageId, manifestSha, receiptSha, preparationAuditSha, preackSha, preackEvaluationSha, preackTickText, true);
            c.PreserveDurableEvidence("live_activation_evaluation", Record.Map("path", activationEvaluation["evaluation_path"], "sha256", activationEvaluation["evaluation_sha256"], "result_code", activationEvaluation["result_code"], "terminal_reason", activationEvaluation["terminal_reason"]));
            int activationResult = Convert.ToInt32(activationEvaluation["result_code"], CultureInfo.InvariantCulture);
            if (activationResult != Contract.Pass) throw new ExpectedTerminalException(activationResult, Convert.ToString(activationEvaluation["terminal_reason"], CultureInfo.InvariantCulture));
            string preackPath = Path.GetFullPath(preackPathRaw);
            string preackEvaluationPath = Path.GetFullPath(preackEvaluationPathRaw);
            string activationPath = Path.GetFullPath(activationPathRaw);
            ulong preackTick = UInt64.Parse(preackTickText, CultureInfo.InvariantCulture);
            string activationSha = Convert.ToString(activationEvaluation["activation_sha256"], CultureInfo.InvariantCulture);
            uint baseline = UInt32.Parse(Convert.ToString(activationEvaluation["baseline_input_dwtime_uint32"], CultureInfo.InvariantCulture), CultureInfo.InvariantCulture);
            ulong receiptTick = UInt64.Parse(Convert.ToString(activationEvaluation["runner_receipt_tick"], CultureInfo.InvariantCulture), CultureInfo.InvariantCulture);
            Dictionary<string, object> runnerInitialIdentityAudit = HarnessOps.FileSetAudit(identity, c.Stage);
            Dictionary<string, object> runnerReceipt = Record.Map("schema", "mfo.qa.live.runner-receipt.v2", "stage_id", stageId, "manifest_sha256", manifestSha, "receipt_sha256", receiptSha, "preparation_audit_sha256", preparationAuditSha, "preack_sha256", preackSha, "preack_evaluation_sha256", preackEvaluationSha, "preack_tick", preackTick.ToString(CultureInfo.InvariantCulture), "activation_sha256", activationSha, "last_input_api_success", true, "last_input_native_error", 0, "last_input_dwtime_uint32", baseline.ToString(CultureInfo.InvariantCulture), "runner_receipt_tick", receiptTick.ToString(CultureInfo.InvariantCulture), "runner_identity", HarnessOps.CaptureValueMap(runnerIdentityCapture), "file_identity_audit", runnerInitialIdentityAudit, "activation_pending", persisted, "activation_evaluation", activationEvaluation);
            c.Journal.Append("live_runner_receipt", runnerReceipt);
            EvidenceIo.WriteNewJson(Path.Combine(c.Output, "runner-receipt.json"), runnerReceipt);
            Dictionary<string, string> extra = new Dictionary<string, string>();
            extra["stage-id"] = stageId; extra["manifest-sha"] = manifestSha; extra["receipt-sha"] = receiptSha; extra["preparation-audit-sha"] = preparationAuditSha; extra["preack-record"] = preackPath; extra["preack-sha"] = preackSha; extra["preack-evaluation"] = preackEvaluationPath; extra["preack-evaluation-sha"] = preackEvaluationSha;
            extra["preack-tick"] = preackTick.ToString(CultureInfo.InvariantCulture); extra["activation"] = activationPath; extra["activation-sha"] = activationSha; extra["activation-evaluation"] = Convert.ToString(activationEvaluation["evaluation_path"], CultureInfo.InvariantCulture); extra["activation-evaluation-sha"] = Convert.ToString(activationEvaluation["evaluation_sha256"], CultureInfo.InvariantCulture);
            extra["baseline-input"] = baseline.ToString(CultureInfo.InvariantCulture); extra["runner-receipt-tick"] = receiptTick.ToString(CultureInfo.InvariantCulture);
            return RunChild(c, identity, "LIVE", extra);
        }
    }

    public static class LauncherRole
    {
        public static int Main(string[] args)
        {
            RoleContext context;
            try { context = new RoleContext("launcher", args); }
            catch (Exception e) { Console.Error.WriteLine(e.ToString()); return Contract.HarnessFail; }
            return context.Execute(delegate { return Run(context); });
        }

        private static Dictionary<string, object> Run(RoleContext c)
        {
            string identity = Path.GetFullPath(c.Args.Required("identity"));
            if (c.Mode == "PREACK") return Preack(c, identity);
            if (c.Mode == "LIVE") PrepareLauncherLiveContract(c, identity);
            HarnessOps.VerifyIdentityDocument(identity, c.Stage);
            ProcessIdentity runnerIdentity = HarnessOps.IdentityFromArgs(c.Args, "runner");
            ProcessIdentity self;
            using (Process current = Process.GetCurrentProcess()) self = NativeApi.ReadIdentity(current);
            if (c.Mode != "QP_SELFTEST" && c.Mode != "LIVE") throw new HarnessException("Unsupported launcher mode: " + c.Mode);
            Dictionary<string, string> extra = new Dictionary<string, string>();
            extra["runner-pid"] = runnerIdentity.Pid.ToString(CultureInfo.InvariantCulture);
            extra["runner-created"] = runnerIdentity.CreationFileTime.ToString(CultureInfo.InvariantCulture);
            extra["runner-image"] = runnerIdentity.ImagePath;
            extra["launcher-pid"] = self.Pid.ToString(CultureInfo.InvariantCulture);
            extra["launcher-created"] = self.CreationFileTime.ToString(CultureInfo.InvariantCulture);
            extra["launcher-image"] = self.ImagePath;
            if (c.Mode == "LIVE")
            {
                string[] fields = new string[] { "stage-id", "manifest-sha", "receipt-sha", "preparation-audit-sha", "preack-record", "preack-sha", "preack-evaluation", "preack-evaluation-sha", "preack-tick", "activation", "activation-sha", "activation-evaluation", "activation-evaluation-sha", "baseline-input", "runner-receipt-tick" };
                for (int i = 0; i < fields.Length; i++) extra[fields[i]] = c.Args.Required(fields[i]);
                ValidateLiveInputs(c, identity, extra);
                Dictionary<string, object> launcherInitialIdentityAudit = HarnessOps.FileSetAudit(identity, c.Stage);
                if (!String.Equals(Convert.ToString(launcherInitialIdentityAudit["identity_document_sha256"], CultureInfo.InvariantCulture), extra["manifest-sha"], StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Launcher receipt manifest rehash mismatch");
                ulong receiptTick = NativeApi.GetTickCount64();
                ulong runnerTick = UInt64.Parse(extra["runner-receipt-tick"], CultureInfo.InvariantCulture);
                if (receiptTick < runnerTick) throw new HarnessException("Launcher receipt ordering failure");
                extra["launcher-receipt-tick"] = receiptTick.ToString(CultureInfo.InvariantCulture);
                Dictionary<string, object> receipt = Record.Map("schema", "mfo.qa.live.launcher-receipt.v2", "stage_id", extra["stage-id"], "manifest_sha256", extra["manifest-sha"], "receipt_sha256", extra["receipt-sha"], "preparation_audit_sha256", extra["preparation-audit-sha"], "preack_sha256", extra["preack-sha"], "preack_evaluation_sha256", extra["preack-evaluation-sha"], "preack_tick", extra["preack-tick"], "activation_sha256", extra["activation-sha"], "activation_evaluation_sha256", extra["activation-evaluation-sha"], "baseline_input_dwtime_uint32", extra["baseline-input"], "runner_receipt_tick", extra["runner-receipt-tick"], "runner_identity", runnerIdentity.ToRecord(), "launcher_receipt_tick", extra["launcher-receipt-tick"], "launcher_identity", self.ToRecord(), "file_identity_audit", launcherInitialIdentityAudit, "forwarded_fields_revalidated", true);
                c.Journal.Append("live_launcher_receipt", receipt);
                EvidenceIo.WriteNewJson(Path.Combine(c.Output, "launcher-receipt.json"), receipt);
            }
            string childOut = Path.Combine(c.Output, "controller");
            string childResult = Path.Combine(childOut, "controller-result.json");
            ulong ownershipOrigin = NativeApi.GetTickCount64();
            ulong ownershipDeadline = checked(ownershipOrigin + Contract.InnerTimeoutMilliseconds);
            using (JobScope job = new JobScope("launcher"))
            {
                OwnedChild child;
                try { child = HarnessOps.StartRole(HarnessOps.Bin(c.Stage, "MfoQaController.exe"), c.Mode, c.Stage, identity, childOut, c.JournalPath, childResult, extra, job, c.Journal, "controller", ownershipDeadline); }
                catch (Exception startFailure)
                {
                    int mapped = startFailure is ExpectedTerminalException ? ((ExpectedTerminalException)startFailure).Code : Contract.HarnessFail;
                    AppendLauncherStartFailureClosure(c, identity, runnerIdentity, self, childOut, childResult, job, mapped, startFailure);
                    if (startFailure is ExpectedTerminalException) throw;
                    throw new HarnessException("Controller start failed: " + startFailure.Message, startFailure);
                }
                using (child)
                {
                int exit;
                bool forcedTimeout = false;
                string timeoutReason = null;
                try { exit = child.WaitUntil(ownershipOrigin, ownershipDeadline, job); }
                catch (ExpectedTerminalException timeout)
                {
                    if (timeout.Code != Contract.TimeoutFail) throw;
                    forcedTimeout = true;
                    timeoutReason = timeout.Message;
                    exit = Contract.TimeoutFail;
                }
                Dictionary<string, object> activeCapture = HarnessOps.SafeCapture("launcher_job_active_processes", delegate { return (object)job.ActiveProcesses; });
                uint active = HarnessOps.CaptureSucceeded(activeCapture) ? Convert.ToUInt32(activeCapture["value"], CultureInfo.InvariantCulture) : UInt32.MaxValue;
                Dictionary<string, object> auditCapture = HarnessOps.SafeCapture("launcher_post_controller_identity_audit", delegate { return (object)HarnessOps.FileSetAudit(identity, c.Stage); });
                Dictionary<string, object> audit = HarnessOps.CaptureSucceeded(auditCapture) ? (Dictionary<string, object>)auditCapture["value"] : Record.Map("capture_failed", true, "error", auditCapture["error"]);
                bool manifestMatches = HarnessOps.CaptureSucceeded(auditCapture) && (c.Mode != "LIVE" || String.Equals(Convert.ToString(audit["identity_document_sha256"], CultureInfo.InvariantCulture), extra["manifest-sha"], StringComparison.OrdinalIgnoreCase));
                string controllerStdout = child.StdoutEvidencePath;
                string controllerStderr = child.StderrEvidencePath;
                Dictionary<string, object> controllerResultEvidence = HarnessOps.CaptureResultValidation(childResult, exit, "controller", c.Mode, !forcedTimeout);
                Dictionary<string, object> controllerResultFile = Record.AsMap(controllerResultEvidence["file"]);
                bool controllerResultPresent = Convert.ToBoolean(controllerResultFile["exists"], CultureInfo.InvariantCulture);
                object controllerResultSha = controllerResultFile["sha256"];
                bool controllerResultValid = Convert.ToBoolean(controllerResultEvidence["valid"], CultureInfo.InvariantCulture);
                object controllerObservedExit = child.HasObservedExitCode ? (object)child.ObservedExitCode : null;
                Dictionary<string, object> qaInventoryCapture = HarnessOps.SafeCapture("launcher_qa_inventory_after", delegate { return (object)HarnessOps.QaOwnedInventory(c.Stage); });
                List<Dictionary<string, object>> qaInventory = HarnessOps.CaptureSucceeded(qaInventoryCapture) ? (List<Dictionary<string, object>>)qaInventoryCapture["value"] : new List<Dictionary<string, object>>();
                Dictionary<string, object> descendantsCapture = HarnessOps.SafeCapture("launcher_runner_descendants_after", delegate { return (object)HarnessOps.DescendantInventory(runnerIdentity.Pid); });
                List<Dictionary<string, object>> descendants = HarnessOps.CaptureSucceeded(descendantsCapture) ? (List<Dictionary<string, object>>)descendantsCapture["value"] : new List<Dictionary<string, object>>();
                Dictionary<string, object> controllerStdoutEvidence = child.StdoutEvidence();
                Dictionary<string, object> controllerStderrEvidence = child.StderrEvidence();
                int launcherMappedExit = Contract.Pass;
                string launcherOutcomeReason = "completed_pass_path";
                try
                {
                    if (forcedTimeout) throw new ExpectedTerminalException(Contract.TimeoutFail, timeoutReason);
                    if (!controllerResultValid) throw new HarnessException("Controller structured result validation failed: " + Convert.ToString(controllerResultEvidence["validation_error"], CultureInfo.InvariantCulture));
                    HarnessOps.RequireStableFileEvidence(controllerResultFile, "controller structured result");
                    HarnessOps.RequireStableFileEvidence(controllerStdoutEvidence, "controller stdout");
                    HarnessOps.RequireStableFileEvidence(controllerStderrEvidence, "controller stderr");
                    HarnessOps.RequireCaptureSucceeded(activeCapture);
                    HarnessOps.RequireCaptureSucceeded(auditCapture);
                    HarnessOps.RequireCaptureSucceeded(qaInventoryCapture);
                    HarnessOps.RequireCaptureSucceeded(descendantsCapture);
                    if (active != 0) throw new HarnessException("Launcher job retained owned processes: " + active.ToString(CultureInfo.InvariantCulture));
                    if (!manifestMatches) throw new HarnessException("Launcher post-controller manifest rehash mismatch");
                    HarnessOps.RequireExactQaInventory(qaInventory, runnerIdentity, self);
                    HarnessOps.RequireExactDescendantInventory(descendants, self);
                    if (exit != Contract.Pass) throw new ExpectedTerminalException(exit, "controller_returned_" + exit.ToString(CultureInfo.InvariantCulture));
                }
                catch (ExpectedTerminalException expected) { launcherMappedExit = expected.Code; launcherOutcomeReason = expected.Message; }
                catch (Exception failure) { launcherMappedExit = Contract.HarnessFail; launcherOutcomeReason = failure.GetType().FullName + ": " + failure.Message; }
                Dictionary<string, object> post = Record.Map("controller_identity", child.Identity.ToRecord(), "controller_exit", exit, "controller_observed_exit", controllerObservedExit, "forced_timeout", forcedTimeout, "timeout_reason", timeoutReason, "launcher_mapped_exit", launcherMappedExit, "launcher_classification", launcherMappedExit == 0 ? "Pass" : (launcherMappedExit == 20 ? "Blocked" : "Fail"), "launcher_outcome_reason", launcherOutcomeReason, "controller_result", controllerResultEvidence, "controller_result_present", controllerResultPresent, "controller_result_sha256", controllerResultSha, "controller_stdout", controllerStdoutEvidence, "controller_stdout_sha256", controllerStdoutEvidence["sha256"], "controller_stderr", controllerStderrEvidence, "controller_stderr_sha256", controllerStderrEvidence["sha256"], "raw_streams_completed", child.RawStreamsCompleted, "owned_runtime_count", active, "active_capture", activeCapture, "qa_owned_processes", qaInventoryCapture, "runner_descendants", descendantsCapture, "identity_audit", auditCapture, "manifest_rehash_matches", manifestMatches, "performance_slot_launch_count", 0);
                c.Journal.Append("launcher_post_controller", post);
                if (launcherMappedExit == Contract.Pass) return Record.Map("controller_identity", child.Identity.ToRecord(), "controller_exit", exit, "controller_observed_exit", controllerObservedExit, "controller_result", childResult, "controller_result_sha256", controllerResultSha, "controller_stdout_sha256", post["controller_stdout_sha256"], "controller_stderr_sha256", post["controller_stderr_sha256"], "final_owned_runtime_count", active, "qa_owned_processes", qaInventory, "runner_descendants", descendants, "performance_slot_launch_count", 0, "identity_audit", audit);
                if (launcherMappedExit == Contract.Blocked || launcherMappedExit == Contract.HarnessFail || launcherMappedExit == Contract.TimeoutFail) throw new ExpectedTerminalException(launcherMappedExit, launcherOutcomeReason);
                throw new HarnessException("Unknown launcher mapped exit: " + launcherMappedExit.ToString(CultureInfo.InvariantCulture));
                }
            }
        }

        private static void PrepareLauncherLiveContract(RoleContext c, string identity)
        {
            string[] names = new string[] { "stage-id", "manifest-sha", "receipt-sha", "preparation-audit-sha", "preack-record", "preack-sha", "preack-evaluation", "preack-evaluation-sha", "preack-tick", "activation", "activation-sha", "activation-evaluation", "activation-evaluation-sha", "baseline-input", "runner-receipt-tick" };
            Dictionary<string, string> fields = new Dictionary<string, string>(StringComparer.Ordinal);
            for (int i = 0; i < names.Length; i++) fields[names[i]] = c.Args.Optional(names[i], "");
            string pendingPath = Path.Combine(c.Output, "launcher-live-pending.json");
            string evaluationPath = Path.Combine(c.Output, "launcher-live-evaluation.json");
            Dictionary<string, object> runnerIdentityCapture = HarnessOps.SafeCapture("launcher_live_runner_identity", delegate { return (object)HarnessOps.IdentityFromArgs(c.Args, "runner").ToRecord(); });
            Dictionary<string, object> launcherIdentityCapture = HarnessOps.SafeCapture("launcher_live_identity", delegate { return (object)HarnessOps.SelfIdentity(); });
            Dictionary<string, object> pending = HarnessOps.BuildLauncherLivePendingObservation(c, identity, pendingPath, fields, runnerIdentityCapture, launcherIdentityCapture, null, null, c.CliContractCapture);
            Dictionary<string, object> persisted = HarnessOps.PersistCompleteLauncherLiveObservation(c.Journal, pendingPath, pending);
            c.PreserveDurableEvidence("launcher_live_pending", Record.Map("path", persisted["pending_path"], "sha256", persisted["pending_sha256"]));
            Dictionary<string, object> evaluation = HarnessOps.EvaluatePersistedLauncherLiveObservation(c.Journal, evaluationPath, persisted, c, identity, fields, true);
            c.PreserveDurableEvidence("launcher_live_evaluation", Record.Map("path", evaluation["evaluation_path"], "sha256", evaluation["evaluation_sha256"], "result_code", evaluation["result_code"], "terminal_reason", evaluation["terminal_reason"]));
            int code = Convert.ToInt32(evaluation["result_code"], CultureInfo.InvariantCulture);
            if (code != Contract.Pass) throw new ExpectedTerminalException(code, Convert.ToString(evaluation["terminal_reason"], CultureInfo.InvariantCulture));
        }

        private static void AppendLauncherStartFailureClosure(RoleContext c, string identity, ProcessIdentity runnerIdentity, ProcessIdentity self, string childOut, string childResult, JobScope job, int mappedExit, Exception failure)
        {
            string controllerStdout = Path.Combine(childOut, "controller.stdout.raw");
            string controllerStderr = Path.Combine(childOut, "controller.stderr.raw");
            Dictionary<string, object> activeCapture = HarnessOps.SafeCapture("launcher_job_active_after_start_failure", delegate { return (object)job.ActiveProcesses; });
            Dictionary<string, object> qaCapture = HarnessOps.SafeCapture("launcher_qa_after_start_failure", delegate { return (object)HarnessOps.QaOwnedInventory(c.Stage); });
            Dictionary<string, object> descendantsCapture = HarnessOps.SafeCapture("launcher_descendants_after_start_failure", delegate { return (object)HarnessOps.DescendantInventory(runnerIdentity.Pid); });
            Dictionary<string, object> identityCapture = HarnessOps.SafeCapture("launcher_identity_audit_after_start_failure", delegate { return (object)HarnessOps.FileSetAudit(identity, c.Stage); });
            Dictionary<string, object> resultEvidence = HarnessOps.CaptureResultValidation(childResult, mappedExit, "controller", c.Mode, false);
            c.Journal.Append("launcher_post_controller", Record.Map("start_failure", true, "controller_started", false, "controller_exit", mappedExit, "controller_observed_exit", null, "launcher_mapped_exit", mappedExit, "launcher_classification", mappedExit == 20 ? "Blocked" : "Fail", "launcher_outcome_reason", failure.GetType().FullName + ": " + failure.Message, "failure", failure.GetType().FullName + ": " + failure.Message, "controller_result", resultEvidence, "controller_stdout", HarnessOps.SafeFileEvidence(controllerStdout, true), "controller_stderr", HarnessOps.SafeFileEvidence(controllerStderr, true), "active_capture", activeCapture, "qa_owned_processes", qaCapture, "runner_descendants", descendantsCapture, "identity_audit", identityCapture, "launcher_identity", self.ToRecord(), "performance_slot_launch_count", 0));
        }

        private static Dictionary<string, object> Preack(RoleContext c, string identity)
        {
            string stageId = c.Args.Optional("stage-id", "");
            string suppliedManifest = c.Args.Optional("manifest-sha", "").ToLowerInvariant();
            string suppliedReceipt = c.Args.Optional("receipt-sha", "").ToLowerInvariant();
            string suppliedAudit = c.Args.Optional("preparation-audit-sha", "").ToLowerInvariant();
            string receiptPath = Path.Combine(c.Stage, "seal", "preparation-receipt.json");
            string auditPath = Path.Combine(c.Stage, "seal", "preparation-audit.json");
            string pendingPath = Path.Combine(c.Output, "preack-record.json");
            string evaluationPath = Path.Combine(c.Output, "preack-evaluation.json");
            Dictionary<string, object> runnerIdentityCapture = HarnessOps.SafeCapture("runner_identity", delegate { return (object)HarnessOps.IdentityFromArgs(c.Args, "runner").ToRecord(); });
            Dictionary<string, object> launcherIdentityCapture = HarnessOps.SafeCapture("launcher_identity", delegate { return (object)HarnessOps.SelfIdentity(); });
            Dictionary<string, object> pending = HarnessOps.BuildPreackPendingObservation(
                c.Stage, identity, stageId, suppliedManifest, suppliedReceipt, suppliedAudit,
                receiptPath, auditPath, pendingPath, Environment.CommandLine,
                runnerIdentityCapture, launcherIdentityCapture, null, null, null, null, c.CliContractCapture);
            Dictionary<string, object> persisted = HarnessOps.PersistCompletePendingObservation(c.Journal, pendingPath, pending);
            c.PreserveDurableEvidence("launcher_preack_pending", Record.Map("path", persisted["pending_path"], "sha256", persisted["pending_sha256"]));
            Dictionary<string, object> evaluation = HarnessOps.EvaluatePersistedPreackObservation(
                c.Journal, evaluationPath, persisted, c.Stage, identity, stageId, suppliedManifest, suppliedReceipt, suppliedAudit, receiptPath, auditPath, true);
            c.PreserveDurableEvidence("launcher_preack_evaluation", Record.Map("path", evaluation["evaluation_path"], "sha256", evaluation["evaluation_sha256"], "result_code", evaluation["result_code"], "terminal_reason", evaluation["terminal_reason"]));
            int resultCode = Convert.ToInt32(evaluation["result_code"], CultureInfo.InvariantCulture);
            if (resultCode != Contract.Pass) throw new ExpectedTerminalException(resultCode, Convert.ToString(evaluation["terminal_reason"], CultureInfo.InvariantCulture));
            Dictionary<string, object> tickCapture = HarnessOps.CaptureMap(pending, "native_tick_capture");
            ulong tick = HarnessOps.SafeUInt64(HarnessOps.CaptureValueMap(tickCapture), "value", 0UL);
            return Record.Map(
                "preack_record", persisted["pending_path"],
                "preack_sha256", persisted["pending_sha256"],
                "preack_evaluation", evaluation["evaluation_path"],
                "preack_evaluation_sha256", evaluation["evaluation_sha256"],
                "preack_tick", tick.ToString(CultureInfo.InvariantCulture),
                "performance_slot_launch_count", 0);
        }

        private static void ValidateLiveInputs(RoleContext c, string identity, Dictionary<string, string> fields)
        {
            HarnessOps.RequireCaptureSucceeded(c.CliContractCapture);
            if (!String.Equals(fields["stage-id"], Path.GetFileName(c.Stage), StringComparison.Ordinal)) throw new HarnessException("Launcher LIVE stage ID mismatch");
            if (!String.Equals(fields["manifest-sha"], EvidenceIo.Sha256File(identity), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Launcher LIVE manifest mismatch");
            if (!String.Equals(fields["preack-sha"], EvidenceIo.Sha256File(fields["preack-record"]), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Launcher LIVE pre-ack hash mismatch");
            if (!String.Equals(fields["preack-evaluation-sha"], EvidenceIo.Sha256File(fields["preack-evaluation"]), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Launcher LIVE pre-ack evaluation hash mismatch");
            Dictionary<string, object> preack = EvidenceIo.ReadMap(fields["preack-record"]);
            if (!String.Equals(HarnessOps.SafeText(HarnessOps.CaptureValueMap(HarnessOps.CaptureMap(preack, "native_tick_capture")), "value"), fields["preack-tick"], StringComparison.Ordinal)) throw new HarnessException("Launcher LIVE pre-ack fields mismatch");
            if (!String.Equals(fields["activation-sha"], EvidenceIo.Sha256File(fields["activation"]), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Launcher LIVE activation hash mismatch");
            if (!String.Equals(fields["activation-evaluation-sha"], EvidenceIo.Sha256File(fields["activation-evaluation"]), StringComparison.OrdinalIgnoreCase) || HarnessOps.SafeInteger(EvidenceIo.ReadMap(fields["activation-evaluation"]), "result_code", -1) != Contract.Pass) throw new HarnessException("Launcher LIVE activation evaluation mismatch");
            ulong preackTick = UInt64.Parse(fields["preack-tick"], CultureInfo.InvariantCulture);
            string exactActivationSha = HarnessOps.RequireExactActivation(fields["activation"], fields["stage-id"], fields["manifest-sha"], fields["receipt-sha"], fields["preparation-audit-sha"], fields["preack-sha"], fields["preack-evaluation-sha"], preackTick);
            if (!String.Equals(exactActivationSha, fields["activation-sha"], StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Launcher LIVE exact activation digest mismatch");
        }
    }

    public static class ControllerRole
    {
        public static int Main(string[] args)
        {
            RoleContext context;
            try { context = new RoleContext("controller", args); }
            catch (Exception e) { Console.Error.WriteLine(e.ToString()); return Contract.HarnessFail; }
            ulong firstNativeTick = NativeApi.GetTickCount64();
            return context.Execute(delegate { return Run(context, firstNativeTick); });
        }

        private static Dictionary<string, object> Run(RoleContext c, ulong origin)
        {
            string identity = Path.GetFullPath(c.Args.Required("identity"));
            if (origin == 0) throw new HarnessException("Native controller origin was zero");
            ulong advance1 = AdvanceAfter(origin);
            ulong advance2 = AdvanceAfter(advance1);
            ulong deadline = checked(origin + Contract.LiveDeadlineMilliseconds);
            c.Journal.Append("controller_clock_origin", Record.Map("origin", origin.ToString(CultureInfo.InvariantCulture), "advance_1", advance1.ToString(CultureInfo.InvariantCulture), "advance_2", advance2.ToString(CultureInfo.InvariantCulture), "deadline", deadline.ToString(CultureInfo.InvariantCulture), "advancing", origin < advance1 && advance1 < advance2));
            HarnessOps.VerifyIdentityDocument(identity, c.Stage);
            if (c.Mode == "QP_SELFTEST") return SelfTest(c, origin, deadline);
            if (c.Mode == "LIVE") return Live(c, origin, deadline, identity);
            throw new HarnessException("Unsupported controller mode: " + c.Mode);
        }

        private static ulong AdvanceAfter(ulong prior)
        {
            ulong value = NativeApi.GetTickCount64();
            while (value <= prior) { Thread.Sleep(1); value = NativeApi.GetTickCount64(); }
            return value;
        }

        private static Dictionary<string, object> SelfTest(RoleContext c, ulong origin, ulong deadline)
        {
            bool expiryCaught = false;
            try { HarnessOps.PersistThenCheckDeadline(c.Journal, deadline, deadline, "synthetic_expiry"); }
            catch (ExpectedTerminalException expected) { if (expected.Code != Contract.TimeoutFail) throw; expiryCaught = true; }
            if (!expiryCaught) throw new HarnessException("Synthetic expiry did not terminate as expected");
            List<Dictionary<string, object>> fixture = new List<Dictionary<string, object>>();
            fixture.Add(Record.Map("name", "OneDrive.exe", "pid", 4242));
            bool inventoryCaught = false;
            try { HarnessOps.PersistThenCheckOneDrive(c.Journal, fixture, "synthetic_inventory_negative"); }
            catch (ExpectedTerminalException expected) { if (expected.Code != Contract.Blocked) throw; inventoryCaught = true; }
            if (!inventoryCaught) throw new HarnessException("Synthetic inventory test did not terminate as expected");
            Dictionary<string, object> sentinel;
            uint active;
            using (JobScope sentinelJob = new JobScope("sentinel-selftest"))
            {
                sentinel = SentinelExercise.Run(c, sentinelJob, "sentinel-selftest", null);
                active = sentinelJob.ActiveProcesses;
            }
            List<Dictionary<string, object>> forbidden = HarnessOps.ForbiddenRuntimeInventory(c.Stage);
            ProcessIdentity runner = HarnessOps.IdentityFromArgs(c.Args, "runner");
            ProcessIdentity launcher = HarnessOps.IdentityFromArgs(c.Args, "launcher");
            ProcessIdentity self; using (Process current = Process.GetCurrentProcess()) self = NativeApi.ReadIdentity(current);
            List<Dictionary<string, object>> qaInventory = HarnessOps.QaOwnedInventory(c.Stage);
            List<Dictionary<string, object>> descendants = HarnessOps.DescendantInventory(runner.Pid);
            c.Journal.Append("qp_selftest_observation", Record.Map("synthetic_expiry_persisted", expiryCaught, "synthetic_inventory_persisted", inventoryCaught, "sentinel", sentinel, "forbidden_runtime_count", forbidden.Count, "qa_owned_processes", qaInventory, "runner_descendants", descendants, "performance_slot_launch_count", 0, "final_owned_runtime_count", active));
            if (active != 0) throw new HarnessException("Sentinel self-test retained owned process");
            HarnessOps.RequireExactQaInventory(qaInventory, runner, launcher, self);
            int allowedWindowsConsoleHostCount = HarnessOps.RequireExactDescendantInventory(descendants, launcher, self);
            if (forbidden.Count != 0) throw new HarnessException("Forbidden runtime present after self-test");
            c.Journal.Append("qp_selftest_complete", Record.Map("allowed_windows_console_host_count", allowedWindowsConsoleHostCount, "unexpected_descendant_count", 0, "performance_slot_launch_count", 0, "final_owned_runtime_count", active));
            return Record.Map("native_origin", origin.ToString(CultureInfo.InvariantCulture), "deadline", deadline.ToString(CultureInfo.InvariantCulture), "synthetic_expiry", "pass", "synthetic_inventory_negative", "pass", "sentinel", sentinel, "qa_owned_processes", qaInventory, "runner_descendants", descendants, "allowed_windows_console_host_count", allowedWindowsConsoleHostCount, "unexpected_descendant_count", 0, "performance_slot_launch_count", 0, "final_owned_runtime_count", active);
        }

        private static Dictionary<string, object> Live(RoleContext c, ulong origin, ulong deadline, string identity)
        {
            HarnessOps.RequireCaptureSucceeded(c.CliContractCapture);
            string stageId = c.Args.Required("stage-id");
            string manifestSha = c.Args.Required("manifest-sha").ToLowerInvariant();
            string receiptSha = c.Args.Required("receipt-sha").ToLowerInvariant();
            string preparationAuditSha = c.Args.Required("preparation-audit-sha").ToLowerInvariant();
            string preackPath = c.Args.Required("preack-record");
            string preackSha = c.Args.Required("preack-sha").ToLowerInvariant();
            string preackEvaluationPath = c.Args.Required("preack-evaluation");
            string preackEvaluationSha = c.Args.Required("preack-evaluation-sha").ToLowerInvariant();
            string activationPath = c.Args.Required("activation");
            string activationSha = c.Args.Required("activation-sha").ToLowerInvariant();
            string activationEvaluationPath = c.Args.Required("activation-evaluation");
            string activationEvaluationSha = c.Args.Required("activation-evaluation-sha").ToLowerInvariant();
            ulong preackTick = UInt64.Parse(c.Args.Required("preack-tick"), CultureInfo.InvariantCulture);
            ulong runnerTick = UInt64.Parse(c.Args.Required("runner-receipt-tick"), CultureInfo.InvariantCulture);
            ulong launcherTick = UInt64.Parse(c.Args.Required("launcher-receipt-tick"), CultureInfo.InvariantCulture);
            uint baselineInput = UInt32.Parse(c.Args.Required("baseline-input"), CultureInfo.InvariantCulture);
            if (!String.Equals(stageId, Path.GetFileName(c.Stage), StringComparison.Ordinal) || !String.Equals(manifestSha, EvidenceIo.Sha256File(identity), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Controller LIVE stage/manifest mismatch");
            if (!String.Equals(preackSha, EvidenceIo.Sha256File(preackPath), StringComparison.OrdinalIgnoreCase) || !String.Equals(preackEvaluationSha, EvidenceIo.Sha256File(preackEvaluationPath), StringComparison.OrdinalIgnoreCase) || !String.Equals(activationSha, EvidenceIo.Sha256File(activationPath), StringComparison.OrdinalIgnoreCase) || !String.Equals(activationEvaluationSha, EvidenceIo.Sha256File(activationEvaluationPath), StringComparison.OrdinalIgnoreCase) || HarnessOps.SafeInteger(EvidenceIo.ReadMap(activationEvaluationPath), "result_code", -1) != Contract.Pass) throw new HarnessException("Controller LIVE pre-ack/evaluation/activation hash mismatch");
            string exactActivationSha = HarnessOps.RequireExactActivation(activationPath, stageId, manifestSha, receiptSha, preparationAuditSha, preackSha, preackEvaluationSha, preackTick);
            if (!String.Equals(exactActivationSha, activationSha, StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Controller LIVE exact activation digest mismatch");
            Dictionary<string, object> preack = EvidenceIo.ReadMap(preackPath);
            if (!String.Equals(HarnessOps.SafeText(HarnessOps.CaptureValueMap(HarnessOps.CaptureMap(preack, "native_tick_capture")), "value"), preackTick.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal)) throw new HarnessException("Controller LIVE pre-ack fields mismatch");
            if (!(preackTick < runnerTick && runnerTick <= launcherTick && launcherTick <= origin)) throw new HarnessException("Durable tick ordering relation failed");
            ProcessIdentity runnerIdentity = HarnessOps.IdentityFromArgs(c.Args, "runner");
            ProcessIdentity launcherIdentity = HarnessOps.IdentityFromArgs(c.Args, "launcher");
            ProcessIdentity selfIdentity; using (Process current = Process.GetCurrentProcess()) selfIdentity = NativeApi.ReadIdentity(current);
            Dictionary<string, object> sentinel;
            ulong settleOrigin = 0;
            ulong previous = 0;
            using (JobScope sentinelJob = new JobScope("sentinel-live"))
            {
                sentinel = SentinelExercise.Run(c, sentinelJob, "sentinel-live", delegate(ulong exitObservedTick)
                {
                    settleOrigin = NativeApi.GetTickCount64();
                    previous = CaptureLiveSample(c, 0, settleOrigin, deadline, baselineInput, 0, runnerIdentity, launcherIdentity, selfIdentity);
                    c.Journal.Append("settle_origin_after_sentinel_exit", Record.Map("sentinel_exit_observed_tick", exitObservedTick.ToString(CultureInfo.InvariantCulture), "settle_origin", settleOrigin.ToString(CultureInfo.InvariantCulture), "n0_actual_tick", previous.ToString(CultureInfo.InvariantCulture)));
                });
                if (sentinelJob.ActiveProcesses != 0) throw new HarnessException("Live sentinel cleanup incomplete");
            }
            if (settleOrigin == 0 || previous == 0) throw new HarnessException("Immediate post-sentinel n=0 sample was not recorded");
            for (int n = 1; n <= 60; n++)
            {
                ulong target = checked(settleOrigin + ((ulong)n * 1000UL));
                previous = CaptureLiveSample(c, n, target, deadline, baselineInput, previous, runnerIdentity, launcherIdentity, selfIdentity);
            }
            if (previous - settleOrigin < 60000UL) throw new HarnessException("Live sequence duration was short");
            Dictionary<string, object> audit = HarnessOps.FileSetAudit(identity, c.Stage);
            if (!String.Equals(Convert.ToString(audit["identity_document_sha256"], CultureInfo.InvariantCulture), manifestSha, StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Controller final manifest rehash mismatch");
            return Record.Map("origin", origin.ToString(CultureInfo.InvariantCulture), "deadline", deadline.ToString(CultureInfo.InvariantCulture), "settle_origin", settleOrigin.ToString(CultureInfo.InvariantCulture), "sample_count", 61, "final_duration_ms", (previous - settleOrigin).ToString(CultureInfo.InvariantCulture), "sentinel", sentinel, "identity_audit", audit, "performance_slot_launch_count", 0, "final_owned_runtime_count", 0);
        }

        private static ulong CaptureLiveSample(RoleContext c, int n, ulong target, ulong deadline, uint baselineInput, ulong previous, ProcessIdentity runnerIdentity, ProcessIdentity launcherIdentity, ProcessIdentity selfIdentity)
        {
            while (NativeApi.GetTickCount64() < target)
            {
                HarnessOps.PersistThenCheckDeadline(c.Journal, NativeApi.GetTickCount64(), deadline, "live_cadence_wait");
                Thread.Sleep(2);
            }
            ulong actual = NativeApi.GetTickCount64();
            HarnessOps.PersistThenCheckDeadline(c.Journal, actual, deadline, "live_sample");
            List<Dictionary<string, object>> oneDrive = HarnessOps.OneDriveInventory();
            Dictionary<string, object> host = HarnessOps.PowerAndInput();
            List<Dictionary<string, object>> forbidden = HarnessOps.ForbiddenRuntimeInventory(c.Stage);
            List<Dictionary<string, object>> qaInventory = HarnessOps.QaOwnedInventory(c.Stage);
            List<Dictionary<string, object>> descendants = HarnessOps.DescendantInventory(runnerIdentity.Pid);
            Dictionary<string, object> sample = Record.Map("schema", "mfo.qa.live.sample.v1", "n", n, "target_tick", target.ToString(CultureInfo.InvariantCulture), "actual_tick", actual.ToString(CultureInfo.InvariantCulture), "lateness_ms", (actual - target).ToString(CultureInfo.InvariantCulture), "onedrive_count", oneDrive.Count, "onedrive_processes", oneDrive, "host", host, "forbidden_runtime_count", forbidden.Count, "forbidden_runtime_processes", forbidden, "owned_process_inventory", qaInventory, "runner_descendant_inventory", descendants, "owned_allowed_roles", new string[] { "runner", "launcher", "controller" });
            c.Journal.Append("live_sample", sample);
            HarnessOps.PersistThenCheckOneDrive(c.Journal, oneDrive, "live_sample_" + n.ToString(CultureInfo.InvariantCulture));
            HarnessOps.CheckHostPrerequisiteRecord(host, baselineInput, true, true);
            if (forbidden.Count != 0) throw new ExpectedTerminalException(Contract.Blocked, "forbidden_runtime_present_live");
            HarnessOps.RequireExactQaInventory(qaInventory, runnerIdentity, launcherIdentity, selfIdentity);
            HarnessOps.RequireExactDescendantInventory(descendants, launcherIdentity, selfIdentity);
            if (n > 0 && (actual <= previous || actual > target + 250UL)) throw new HarnessException("Live cadence violation at sample " + n.ToString(CultureInfo.InvariantCulture));
            return actual;
        }
    }
}
