using System;
using System.Threading;
using MfoQaQualification;

public static class MfoQaSentinel
{
    public static int Main(string[] args)
    {
        RoleGate.AwaitIfPresent(args);
        Arguments parsed = Arguments.Parse(args);
        parsed.RequireOnly("ready-event", "release-event", "start-gate");
        string readyName = parsed.Required("ready-event");
        string releaseName = parsed.Required("release-event");
        if (String.IsNullOrEmpty(readyName) || String.IsNullOrEmpty(releaseName)) return Contract.HarnessFail;
        using (EventWaitHandle ready = EventWaitHandle.OpenExisting(readyName))
        using (EventWaitHandle release = EventWaitHandle.OpenExisting(releaseName))
        {
            Console.Out.WriteLine(Contract.SentinelReady);
            Console.Out.Flush();
            ready.Set();
            release.WaitOne();
            Console.Out.WriteLine(Contract.SentinelStdout);
            Console.Out.Flush();
            Console.Error.WriteLine(Contract.SentinelStderr);
            Console.Error.Flush();
            return Contract.SentinelExpected;
        }
    }
}
