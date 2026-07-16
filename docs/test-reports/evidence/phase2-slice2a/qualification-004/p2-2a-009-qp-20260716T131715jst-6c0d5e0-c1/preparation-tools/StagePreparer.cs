using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using MfoQaQualification;

public static class StagePreparer
{
    private const string WorkOrder = "MFO-WO-P2-2A-009";
    private const string StagePrefix = "p2-2a-009-qp-";
    private const string RequiredSupervisorCommit = "6c0d5e04c1c70692c57f18f98416b7ebff324706";
    private const string RequiredSupervisorClarificationCommit = "45374c3545204279ae733df0e7c3d9871954fb08";
    private const string RequiredQaReceiptCommit = "f4986e7fdd7bfbbb5983e98c1dfb2129ebab08a4";
    private const string RequiredBranch = "codex/phase2-slice2a-harness-live-evidence-requalification-qa";
    private const string Frozen008NativeSourceSha256 = "01ed440a0973471ab78c057910f91101e22e04620bd33c49d52259d9cb72e810";

    private static readonly string[] ComponentSources = new string[]
    {
        "MfoQaNative.cs", "MfoQaRunner.cs", "MfoQaLauncher.cs", "MfoQaController.cs", "MfoQaSentinel.cs"
    };

    private static readonly string[] ComponentBinaries = new string[]
    {
        "MfoQaNative.dll", "MfoQaRunner.exe", "MfoQaLauncher.exe", "MfoQaController.exe", "MfoQaSentinel.exe"
    };

    public static int Main(string[] args)
    {
        try
        {
            Arguments parsed = Arguments.Parse(args);
            string mode = parsed.Required("mode").ToUpperInvariant();
            string stage = Path.GetFullPath(parsed.Required("stage"));
            HarnessOps.EnsureAllowedStagePath(stage);
            if (mode == "INIT") Init(parsed, stage);
            else if (mode == "CONTRACT") ContractFile(parsed, stage);
            else if (mode == "SEAL") Seal(parsed, stage);
            else throw new HarnessException("Unsupported preparation mode");
            return 0;
        }
        catch (Exception failure)
        {
            Console.Error.WriteLine(failure.ToString());
            return 30;
        }
    }

    private static void Init(Arguments args, string stage)
    {
        if (Directory.Exists(stage) || File.Exists(stage)) throw new HarnessException("Candidate already exists and cannot be reused: " + stage);
        string parent = Path.GetDirectoryName(stage);
        Directory.CreateDirectory(parent);
        int existingCandidates = Directory.GetDirectories(parent).Length;
        if (existingCandidates >= 3) throw new HarnessException("Candidate limit reached");
        string sourceRoot = Path.GetFullPath(args.Required("source-root"));
        RequireFreshCandidateSourceRoot(sourceRoot);
        string supervisorCommit = args.Required("supervisor-commit");
        string stageId = args.Required("stage-id");
        if (!String.Equals(supervisorCommit, RequiredSupervisorCommit, StringComparison.Ordinal)) throw new HarnessException("Supervisor commit differs from MFO-WO-P2-2A-009");
        if (!String.Equals(Path.GetFileName(stage), stageId, StringComparison.Ordinal)) throw new HarnessException("Stage ID/path disagreement");
        if (!stageId.StartsWith(StagePrefix, StringComparison.Ordinal)) throw new HarnessException("Fresh -009 stage ID prefix is required");

        Directory.CreateDirectory(Path.Combine(stage, "source"));
        Directory.CreateDirectory(Path.Combine(stage, "bin"));
        Directory.CreateDirectory(Path.Combine(stage, "config"));
        Directory.CreateDirectory(Path.Combine(stage, "preparation"));
        Directory.CreateDirectory(Path.Combine(stage, "seal"));

        List<Dictionary<string, object>> copiedSources = new List<Dictionary<string, object>>();
        foreach (string name in ComponentSources)
        {
            string from = Path.Combine(sourceRoot, name);
            string to = Path.Combine(stage, "source", name);
            CopyNew(from, to);
            copiedSources.Add(Record.Map("source_path", from, "staged_path", to, "sha256", EvidenceIo.Sha256File(to), "byte_size", new FileInfo(to).Length));
        }

        Dictionary<string, object> materialization = Record.Map(
            "schema", "mfo.qa.qualification.materialization.v1",
            "stage_id", stageId,
            "stage_path", stage,
            "supervisor_commit", supervisorCommit,
            "candidate_number", existingCandidates + 1,
            "candidate_limit", 3,
            "source_files", copiedSources,
            "bin_directory_initially_empty", Directory.GetFiles(Path.Combine(stage, "bin"), "*", SearchOption.AllDirectories).Length == 0,
            "game_executable_copy_count", 0,
            "old_005_stage_reused", false,
            "old_006_stage_reused", false,
            "old_007_stage_reused", false,
            "old_008_stage_reused", false,
            "performance_slot_launch_count", 0,
            "p95_produced", false,
            "kbm_performed", false,
            "abc_launched", false,
            "abc_launch_count", 0);
        EvidenceIo.WriteNewJson(Path.Combine(stage, "preparation", "materialization.json"), materialization);
    }

    private static void ContractFile(Arguments args, string stage)
    {
        string csc = Path.GetFullPath(args.Required("compiler"));
        string stageId = args.Required("stage-id");
        RequireStageId(stage, stageId);
        string supervisorCommit = args.Required("supervisor-commit");
        string qaReceiptCommit = args.Required("qa-receipt-commit");
        RequireIssuedIdentity(supervisorCommit, qaReceiptCommit);
        Dictionary<string, object> repositoryState = VerifyRepositoryState(stage, supervisorCommit, qaReceiptCommit);
        string baselineSourceRoot = Path.GetFullPath(args.Required("baseline-source-root"));
        string runEvidenceRoot = ExternalRunEvidenceRoot(stageId);
        bool preackOrLiveStarted = Directory.Exists(Path.Combine(stage, "runs")) || File.Exists(Path.Combine(stage, "runs")) || Directory.Exists(runEvidenceRoot) || File.Exists(runEvidenceRoot);
        if (preackOrLiveStarted) throw new HarnessException("Cannot create final contract after PREACK or LIVE started");
        List<Dictionary<string, object>> sourceAudit = SourceAudit(stage);
        Dictionary<string, object> sourceDiffAudit = SourceDiffAudit(stage, baselineSourceRoot);
        string sourceDiffAuditPath = Path.Combine(stage, "preparation", "source-diff-audit.json");
        EvidenceIo.WriteNewJson(sourceDiffAuditPath, sourceDiffAudit);
        Dictionary<string, object> compiler = EvidenceIo.FileIdentity(csc, "external/compiler/csc.exe");
        string nativeCompileInvocation = Quote(csc) + " /nologo /target:library /optimize+ /out:" + Quote(Path.Combine(stage, "bin", "MfoQaNative.dll")) + " /reference:System.Web.Extensions.dll " + Quote(Path.Combine(stage, "source", "MfoQaNative.cs"));
        string roleCompilePrefix = Quote(csc) + " /nologo /target:exe /platform:x64 /optimize+ ";
        string nativeReference = " /reference:" + Quote(Path.Combine(stage, "bin", "MfoQaNative.dll")) + " ";
        string runnerCompileInvocation = roleCompilePrefix + "/out:" + Quote(Path.Combine(stage, "bin", "MfoQaRunner.exe")) + nativeReference + Quote(Path.Combine(stage, "source", "MfoQaRunner.cs"));
        string launcherCompileInvocation = roleCompilePrefix + "/out:" + Quote(Path.Combine(stage, "bin", "MfoQaLauncher.exe")) + nativeReference + Quote(Path.Combine(stage, "source", "MfoQaLauncher.cs"));
        string controllerCompileInvocation = roleCompilePrefix + "/out:" + Quote(Path.Combine(stage, "bin", "MfoQaController.exe")) + nativeReference + Quote(Path.Combine(stage, "source", "MfoQaController.cs"));
        string sentinelCompileInvocation = roleCompilePrefix + "/out:" + Quote(Path.Combine(stage, "bin", "MfoQaSentinel.exe")) + nativeReference + Quote(Path.Combine(stage, "source", "MfoQaSentinel.cs"));
        List<Dictionary<string, object>> compileReceipts = VerifyFreshCompileReceipts(stage, stageId, csc, new string[]
        {
            "native", Path.Combine(stage, "source", "MfoQaNative.cs"), Path.Combine(stage, "bin", "MfoQaNative.dll"), nativeCompileInvocation,
            "runner", Path.Combine(stage, "source", "MfoQaRunner.cs"), Path.Combine(stage, "bin", "MfoQaRunner.exe"), runnerCompileInvocation,
            "launcher", Path.Combine(stage, "source", "MfoQaLauncher.cs"), Path.Combine(stage, "bin", "MfoQaLauncher.exe"), launcherCompileInvocation,
            "controller", Path.Combine(stage, "source", "MfoQaController.cs"), Path.Combine(stage, "bin", "MfoQaController.exe"), controllerCompileInvocation,
            "sentinel", Path.Combine(stage, "source", "MfoQaSentinel.cs"), Path.Combine(stage, "bin", "MfoQaSentinel.exe"), sentinelCompileInvocation
        });
        List<Dictionary<string, object>> files = ComponentFileIdentities(stage);
        Dictionary<string, object> compile = Record.Map(
            "schema", "mfo.qa.qualification.compile.v1",
            "compiler", compiler,
            "fresh_compile_receipts", compileReceipts,
            "fresh_compile_receipt_count", compileReceipts.Count,
            "all_components_compiled_fresh", true,
            "old_stage_component_reuse_count", 0,
            "native_helper_invocation", nativeCompileInvocation,
            "native_helper_invocation_sha256", EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(nativeCompileInvocation)),
            "native_helper_compile_exit_code", 0,
            "role_invocation_template", Quote(csc) + " /nologo /target:exe /platform:x64 /optimize+ /out:<stage-bin-role> /reference:" + Quote(Path.Combine(stage, "bin", "MfoQaNative.dll")) + " <stage-source-role>",
            "runner_invocation", runnerCompileInvocation,
            "runner_invocation_sha256", EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(runnerCompileInvocation)),
            "runner_compile_exit_code", 0,
            "launcher_invocation", launcherCompileInvocation,
            "launcher_invocation_sha256", EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(launcherCompileInvocation)),
            "launcher_compile_exit_code", 0,
            "controller_invocation", controllerCompileInvocation,
            "controller_invocation_sha256", EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(controllerCompileInvocation)),
            "controller_compile_exit_code", 0,
            "sentinel_invocation", sentinelCompileInvocation,
            "sentinel_invocation_sha256", EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(sentinelCompileInvocation)),
            "sentinel_compile_exit_code", 0,
            "preack_or_live_compile_allowed", false,
            "native_tick_comparison_sites", new string[] { "EvidenceJournal.Append bounded named-mutex acquisition", "OwnedChild.Start ownership deadline checkpoints", "OwnedChild.WaitUntil child/cleanup/raw-stream deadlines", "HarnessOps.PersistThenCheckDeadline shared synthetic/live expiry", "SentinelExercise.Run READY plus exit within one total handshake deadline", "ControllerRole.AdvanceAfter origin<advance1<advance2", "RunnerRole LIVE preack_tick<runner_receipt_tick", "LauncherRole LIVE runner_receipt_tick<=launcher_receipt_tick", "ControllerRole LIVE preack<runner<=launcher<=origin", "ControllerRole LIVE target<=actual<=target+250 and strict actual increase", "ControllerRole LIVE final_actual-settle_origin>=60000", "ControllerRole LIVE origin+600000 expiry" },
            "live_clock_injection_exposed", false,
            "source_use_audit", sourceAudit,
            "source_diff_audit", sourceDiffAudit,
            "source_diff_audit_sha256", EvidenceIo.Sha256File(sourceDiffAuditPath));
        EvidenceIo.WriteNewJson(Path.Combine(stage, "preparation", "compile-and-source-audit.json"), compile);

        string identityPath = Path.Combine(stage, "config", "component-contract.json");
        Dictionary<string, object> preparationInvocations = PreparationInvocations(stage, identityPath);
        Dictionary<string, object> identity = Record.Map(
            "schema", "mfo.qa.qualification.identity-contract.v1",
            "work_order", WorkOrder,
            "stage_id", stageId,
            "sealed_files", files,
            "preparation_invocations", preparationInvocations,
            "source_diff_audit_sha256", EvidenceIo.Sha256File(sourceDiffAuditPath),
            "performance_slot_launch_count", 0,
            "abc_launch_count", 0,
            "abc_launch_authorized", false);
        EvidenceIo.WriteNewJson(identityPath, identity);

        string materializationPath = Path.Combine(stage, "preparation", "materialization.json");
        Dictionary<string, object> rematerialization = Record.Map(
            "schema", "mfo.qa.qualification.final-rematerialization.v1",
            "stage_id", stageId,
            "candidate_remained_unsealed_during_repairs", true,
            "initial_materialization_record", materializationPath,
            "initial_materialization_sha256", EvidenceIo.Sha256File(materializationPath),
            "initial_source_entries_describe_initial_copy_only", true,
            "final_source_and_component_identities", files,
            "fresh_compile_receipts", compileReceipts,
            "game_executable_copy_count", 0,
            "source_diff_audit", sourceDiffAuditPath,
            "source_diff_audit_sha256", EvidenceIo.Sha256File(sourceDiffAuditPath),
            "preparation_invocations", preparationInvocations,
            "prior_attempts_retained_under_preparation_preseal", true,
            "performance_slot_launch_count", 0,
            "abc_launch_count", 0,
            "preack_or_live_started", preackOrLiveStarted);
        EvidenceIo.WriteNewJson(Path.Combine(stage, "preparation", "final-component-rematerialization-audit.json"), rematerialization);
        WriteRuntimeManifestAndReceipt(stage, stageId, supervisorCommit, qaReceiptCommit, repositoryState, files, identityPath, compile);
    }

    private static void WriteRuntimeManifestAndReceipt(
        string stage,
        string stageId,
        string supervisorCommit,
        string qaReceiptCommit,
        Dictionary<string, object> repositoryState,
        List<Dictionary<string, object>> componentFiles,
        string identityContract,
        Dictionary<string, object> compileAudit)
    {
        string manifestPath = Path.Combine(stage, "seal", "qualification-manifest.json");
        string receiptPath = Path.Combine(stage, "seal", "preparation-receipt.json");
        string preparationAuditPath = Path.Combine(stage, "seal", "preparation-audit.json");
        if (File.Exists(manifestPath) || File.Exists(receiptPath) || File.Exists(preparationAuditPath)) throw new HarnessException("Final contract bytes already exist");

        string runEvidenceRoot = ExternalRunEvidenceRoot(stageId);
        RequireAbsent(runEvidenceRoot, "External run-evidence root must be absent while preparing the final manifest");
        RequireAbsent(Path.Combine(stage, "runs"), "A stage-local runs directory is forbidden");

        string preackRoot = Path.Combine(runEvidenceRoot, "preack-001");
        string liveRoot = Path.Combine(runEvidenceRoot, "live-001");
        string preackPending = Path.Combine(preackRoot, "launcher", "preack-record.json");
        string preackEvaluation = Path.Combine(preackRoot, "launcher", "preack-evaluation.json");
        string runnerPreackPending = Path.Combine(preackRoot, "runner-preack-pending.json");
        string runnerPreackEvaluation = Path.Combine(preackRoot, "runner-preack-evaluation.json");
        string activationPath = Path.Combine(liveRoot, "activation-token.txt");
        string liveActivationPending = Path.Combine(liveRoot, "live-activation-pending.json");
        string liveActivationEvaluation = Path.Combine(liveRoot, "live-activation-evaluation.json");
        string launcherLivePending = Path.Combine(liveRoot, "launcher", "launcher-live-pending.json");
        string launcherLiveEvaluation = Path.Combine(liveRoot, "launcher", "launcher-live-evaluation.json");
        string runnerExe = Path.Combine(stage, "bin", "MfoQaRunner.exe");
        string launcherExe = Path.Combine(stage, "bin", "MfoQaLauncher.exe");
        string controllerExe = Path.Combine(stage, "bin", "MfoQaController.exe");
        string launcherGate = GateName(Path.Combine(stage, "bin", "MfoQaLauncher.exe"));
        string controllerGate = GateName(Path.Combine(stage, "bin", "MfoQaController.exe"));
        string sentinelGate = GateName(Path.Combine(stage, "bin", "MfoQaSentinel.exe"));
        string sentinelToken = EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(Path.GetFullPath(stage).ToLowerInvariant() + "|sentinel-handshake")).Substring(0, 24);
        string sentinelReady = "Local\\MFO_QA_SENTINEL_READY_" + sentinelToken;
        string sentinelRelease = "Local\\MFO_QA_SENTINEL_RELEASE_" + sentinelToken;
        Dictionary<string, string> qpLauncherExtra = TemplateFieldMap(
            "runner-created", "<runtime-runner-filetime>", "runner-image", runnerExe, "runner-pid", "<runtime-runner-pid>");
        Dictionary<string, string> qpControllerExtra = TemplateFieldMap(
            "launcher-created", "<runtime-launcher-filetime>", "launcher-image", launcherExe, "launcher-pid", "<runtime-launcher-pid>",
            "runner-created", "<runtime-runner-filetime>", "runner-image", runnerExe, "runner-pid", "<runtime-runner-pid>");
        Dictionary<string, string> preackRunnerExtra = TemplateFieldMap(
            "stage-id", stageId, "manifest-sha", "<manifest-sha256>", "receipt-sha", "<receipt-sha256>", "preparation-audit-sha", "<preparation-audit-sha256>");
        Dictionary<string, string> preackLauncherExtra = TemplateFieldMap(
            "stage-id", stageId, "manifest-sha", "<manifest-sha256>", "receipt-sha", "<receipt-sha256>", "preparation-audit-sha", "<preparation-audit-sha256>",
            "runner-created", "<runtime-runner-filetime>", "runner-image", runnerExe, "runner-pid", "<runtime-runner-pid>");
        Dictionary<string, string> liveRunnerExtra = TemplateFieldMap(
            "activation", activationPath, "manifest-sha", "<manifest-sha256>", "preack-evaluation", preackEvaluation, "preack-evaluation-sha", "<preack-evaluation-sha256>",
            "preack-record", preackPending, "preack-sha", "<preack-sha256>", "preack-tick", "<preack-native-uint64>", "preparation-audit-sha", "<preparation-audit-sha256>",
            "receipt-sha", "<receipt-sha256>", "stage-id", stageId);
        Dictionary<string, string> liveLauncherExtra = TemplateFieldMap(
            "activation", activationPath, "activation-evaluation", liveActivationEvaluation, "activation-evaluation-sha", "<activation-evaluation-sha256>", "activation-sha", "<activation-sha256>",
            "baseline-input", "<runner-uint32>", "manifest-sha", "<manifest-sha256>", "preack-evaluation", preackEvaluation, "preack-evaluation-sha", "<preack-evaluation-sha256>",
            "preack-record", preackPending, "preack-sha", "<preack-sha256>", "preack-tick", "<preack-native-uint64>", "preparation-audit-sha", "<preparation-audit-sha256>",
            "receipt-sha", "<receipt-sha256>", "runner-created", "<runtime-runner-filetime>", "runner-image", runnerExe, "runner-pid", "<runtime-runner-pid>",
            "runner-receipt-tick", "<runner-native-uint64>", "stage-id", stageId);
        Dictionary<string, string> liveControllerExtra = TemplateFieldMap(
            "activation", activationPath, "activation-evaluation", liveActivationEvaluation, "activation-evaluation-sha", "<activation-evaluation-sha256>", "activation-sha", "<activation-sha256>",
            "baseline-input", "<runner-uint32>", "launcher-created", "<runtime-launcher-filetime>", "launcher-image", launcherExe, "launcher-pid", "<runtime-launcher-pid>",
            "launcher-receipt-tick", "<launcher-native-uint64>", "manifest-sha", "<manifest-sha256>", "preack-evaluation", preackEvaluation, "preack-evaluation-sha", "<preack-evaluation-sha256>",
            "preack-record", preackPending, "preack-sha", "<preack-sha256>", "preack-tick", "<preack-native-uint64>", "preparation-audit-sha", "<preparation-audit-sha256>",
            "receipt-sha", "<receipt-sha256>", "runner-created", "<runtime-runner-filetime>", "runner-image", runnerExe, "runner-pid", "<runtime-runner-pid>",
            "runner-receipt-tick", "<runner-native-uint64>", "stage-id", stageId);
        Dictionary<string, object> preparationInvocations = PreparationInvocations(stage, identityContract);
        Dictionary<string, object> invocations = Record.Map(
            "qp_dryrun_runner_exact", preparationInvocations["qp_dryrun_runner_exact"],
            "qp_dryrun_runner_exact_sha256", preparationInvocations["qp_dryrun_runner_exact_sha256"],
            "qp_selftest_runner_exact", preparationInvocations["qp_selftest_runner_exact"],
            "qp_selftest_runner_exact_sha256", preparationInvocations["qp_selftest_runner_exact_sha256"],
            "qp_power_input_smoke_runner_exact", preparationInvocations["qp_power_input_smoke_runner_exact"],
            "qp_power_input_smoke_runner_exact_sha256", preparationInvocations["qp_power_input_smoke_runner_exact_sha256"],
            "qp_preack_contract_selftest_runner_exact", preparationInvocations["qp_preack_contract_selftest_runner_exact"],
            "qp_preack_contract_selftest_runner_exact_sha256", preparationInvocations["qp_preack_contract_selftest_runner_exact_sha256"],
            "qp_live_evidence_contract_selftest_runner_exact", preparationInvocations["qp_live_evidence_contract_selftest_runner_exact"],
            "qp_live_evidence_contract_selftest_runner_exact_sha256", preparationInvocations["qp_live_evidence_contract_selftest_runner_exact_sha256"],
            "qp_selftest_launcher_template", ChildBase(launcherExe, "QP_SELFTEST", stage, identityContract, Path.Combine(stage, "preparation", "selftest-qualified", "launcher"), Path.Combine(stage, "preparation", "selftest-qualified", "evidence.journal.jsonl"), "launcher") + TemplateExtraArgs(qpLauncherExtra) + " --start-gate " + Quote(launcherGate),
            "qp_selftest_launcher_extra_keys_ordinal", TemplateSortedKeys(qpLauncherExtra),
            "qp_selftest_controller_template", ChildBase(controllerExe, "QP_SELFTEST", stage, identityContract, Path.Combine(stage, "preparation", "selftest-qualified", "launcher", "controller"), Path.Combine(stage, "preparation", "selftest-qualified", "evidence.journal.jsonl"), "controller") + TemplateExtraArgs(qpControllerExtra) + " --start-gate " + Quote(controllerGate),
            "qp_selftest_controller_extra_keys_ordinal", TemplateSortedKeys(qpControllerExtra),
            "preack_runner_template", Quote(runnerExe) + BaseArgs("PREACK", stage, manifestPath, preackRoot) + TemplateExtraArgs(preackRunnerExtra),
            "preack_runner_extra_keys_ordinal", TemplateSortedKeys(preackRunnerExtra),
            "preack_runner_template_kind", "direct_invocation_grammar_with_named_placeholders",
            "preack_runner_direct_basic_args_exact", true,
            "live_runner_template", Quote(runnerExe) + BaseArgs("LIVE", stage, manifestPath, liveRoot) + TemplateExtraArgs(liveRunnerExtra),
            "live_runner_extra_keys_ordinal", TemplateSortedKeys(liveRunnerExtra),
            "live_runner_template_kind", "direct_invocation_grammar_with_named_placeholders",
            "live_runner_direct_basic_args_exact", true,
            "preack_launcher_template", ChildBase(launcherExe, "PREACK", stage, manifestPath, Path.Combine(preackRoot, "launcher"), Path.Combine(preackRoot, "evidence.journal.jsonl"), "launcher") + TemplateExtraArgs(preackLauncherExtra) + " --start-gate " + Quote(launcherGate),
            "preack_launcher_extra_keys_ordinal", TemplateSortedKeys(preackLauncherExtra),
            "live_launcher_template", ChildBase(launcherExe, "LIVE", stage, manifestPath, Path.Combine(liveRoot, "launcher"), Path.Combine(liveRoot, "evidence.journal.jsonl"), "launcher") + TemplateExtraArgs(liveLauncherExtra) + " --start-gate " + Quote(launcherGate),
            "live_launcher_extra_keys_ordinal", TemplateSortedKeys(liveLauncherExtra),
            "live_launcher_template_fixed_pending_observation", launcherLivePending,
            "live_launcher_template_fixed_evaluation", launcherLiveEvaluation,
            "live_controller_template", ChildBase(controllerExe, "LIVE", stage, manifestPath, Path.Combine(liveRoot, "launcher", "controller"), Path.Combine(liveRoot, "evidence.journal.jsonl"), "controller") + TemplateExtraArgs(liveControllerExtra) + " --start-gate " + Quote(controllerGate),
            "live_controller_extra_keys_ordinal", TemplateSortedKeys(liveControllerExtra),
            "child_role_template_kind", "runtime_exact_ordinal_extra_key_order_with_named_placeholders",
            "sentinel_selftest_and_live_exact", Quote(Path.Combine(stage, "bin", "MfoQaSentinel.exe")) + " --ready-event " + Quote(sentinelReady) + " --release-event " + Quote(sentinelRelease) + " --start-gate " + Quote(sentinelGate));

        List<Dictionary<string, object>> sealedFiles = new List<Dictionary<string, object>>(componentFiles);
        sealedFiles.Add(EvidenceIo.FileIdentity(identityContract, "config/component-contract.json"));
        Dictionary<string, object> manifest = Record.Map(
            "schema", "mfo.qa.qualification.manifest.v1",
            "work_order", WorkOrder,
            "stage_id", stageId,
            "stage_path", stage,
            "run_evidence_root", runEvidenceRoot,
            "preparation_receipt_path", receiptPath,
            "preparation_audit_path", preparationAuditPath,
            "supervisor_starting_commit", supervisorCommit,
            "qa_receipt_commit", qaReceiptCommit,
            "required_qa_branch", RequiredBranch,
            "repository_state", repositoryState,
            "sealed_files", sealedFiles,
            "component_compile", compileAudit,
            "evidence_schemas", Record.Map(
                "manifest", "mfo.qa.qualification.manifest.v1",
                "receipt", "mfo.qa.qualification.preparation-receipt.v1",
                "preparation_audit", "mfo.qa.qualification.preparation-audit.v1",
                "pending_preack", "mfo.qa.preack.pending.v2",
                "preack_evaluation", "mfo.qa.preack.evaluation.v2",
                "live_activation_pending", "mfo.qa.live.activation.pending.v1",
                "live_activation_evaluation", "mfo.qa.live.activation.evaluation.v1",
                "launcher_live_pending", "mfo.qa.live.activation.pending.v1",
                "launcher_live_evaluation", "mfo.qa.live.activation.evaluation.v1",
                "live_sample", "mfo.qa.live.sample.v1",
                "structured_result", "mfo.qa.qualification.result.v1",
                "journal", "mfo.qa.qualification.journal-record.v1"),
            "invocation_argument_contract", Record.Map(
                "named_digest_placeholders_only", true,
                "preparation_runner_invocations", "exact sealed strings and SHA-256",
                "runtime_runner_templates", "direct invocation grammar: exact executable/basic paths plus quoted named runtime placeholders",
                "child_role_templates", "HarnessOps.StartRole grammar: exact ChildBase then extra keys sorted StringComparer.Ordinal, every value quoted, start-gate appended last by OwnedChild.Start",
                "extra_key_order", "StringComparer.Ordinal",
                "extra_value_quoting", "HarnessOps.Quote for every literal and placeholder",
                "named_placeholders_are_quoted", true,
                "start_gate_after_sorted_extra_args", true,
                "manifest_digest_placeholder", "<manifest-sha256>",
                "receipt_digest_placeholder", "<receipt-sha256>",
                "preparation_audit_digest_placeholder", "<preparation-audit-sha256>",
                "preack_digest_placeholder", "<preack-sha256>",
                "preack_evaluation_digest_placeholder", "<preack-evaluation-sha256>",
                "required_preack_cli_fields", new string[] { "stage-id", "manifest-sha", "receipt-sha", "preparation-audit-sha" },
                "required_live_additional_cli_fields", new string[] { "preack-record", "preack-sha", "preack-evaluation", "preack-evaluation-sha", "preack-tick", "activation" },
                "required_live_child_evaluated_activation_fields", new string[] { "activation-sha", "activation-evaluation", "activation-evaluation-sha", "baseline-input", "runner-receipt-tick" },
                "launcher_injected_runner_identity_fields", new string[] { "runner-created", "runner-image", "runner-pid" },
                "controller_additional_launcher_fields", new string[] { "launcher-created", "launcher-image", "launcher-pid", "launcher-receipt-tick" }),
            "invocations", invocations,
            "output_paths", Record.Map(
                "external_root", runEvidenceRoot,
                "preack", Record.Map("root", preackRoot, "journal", Path.Combine(preackRoot, "evidence.journal.jsonl"), "runner_result", Path.Combine(preackRoot, "runner-result.json"), "runner_pending_observation", runnerPreackPending, "runner_evaluation", runnerPreackEvaluation, "launcher_result", Path.Combine(preackRoot, "launcher", "launcher-result.json"), "launcher_pending_observation", preackPending, "launcher_evaluation", preackEvaluation, "runner_closure", Path.Combine(preackRoot, "preack-closure.json"), "launcher_stdout", Path.Combine(preackRoot, "launcher", "launcher.stdout.raw"), "launcher_stderr", Path.Combine(preackRoot, "launcher", "launcher.stderr.raw")),
                "live", Record.Map("root", liveRoot, "activation_token", activationPath, "activation_pending_observation", liveActivationPending, "activation_evaluation", liveActivationEvaluation, "journal", Path.Combine(liveRoot, "evidence.journal.jsonl"), "runner_result", Path.Combine(liveRoot, "runner-result.json"), "launcher_result", Path.Combine(liveRoot, "launcher", "launcher-result.json"), "launcher_pending_observation", launcherLivePending, "launcher_evaluation", launcherLiveEvaluation, "launcher_fixed_output_contract", Record.Map("output_root", Path.Combine(liveRoot, "launcher"), "pending_filename", "launcher-live-pending.json", "evaluation_filename", "launcher-live-evaluation.json", "derived_from_sealed_live_launcher_template", true), "controller_result", Path.Combine(liveRoot, "launcher", "controller", "controller-result.json"), "launcher_stdout", Path.Combine(liveRoot, "launcher", "launcher.stdout.raw"), "launcher_stderr", Path.Combine(liveRoot, "launcher", "launcher.stderr.raw"), "controller_stdout", Path.Combine(liveRoot, "launcher", "controller", "controller.stdout.raw"), "controller_stderr", Path.Combine(liveRoot, "launcher", "controller", "controller.stderr.raw"))),
            "result_contract", Record.Map("0", "completed Pass path", "20", "persisted external-prerequisite Blocked", "30", "harness Fail", "31", "native-tick timeout/cleanup Fail", "sentinel_23", "expected internal sentinel exit only"),
            "pending_before_evaluation_contract", Record.Map("evaluation", "pending", "durable_write", "CreateNew + WriteThrough + Flush(true) + close", "readback", "exact bytes + complete required field set", "hash", "SHA-256 after readback", "expected_value_assertion_before_hash", false, "separate_evaluation_required", true),
            "live_evidence_contract", Record.Map(
                "every_live_sample_performance_slot_launch_count", 0,
                "sentinel_order", new string[] { "owned_child_exit", "sentinel_complete", "settle_origin_after_sentinel_exit", "live_sample n=0" },
                "runner_pending_readback_success_required", true,
                "runner_pending_field_completeness_success_required", true,
                "launcher_pending_readback_success_required", true,
                "launcher_pending_field_completeness_success_required", true,
                "precleanup_n0_callback_allowed", false),
            "exact_activation_prefix", WorkOrder + " START_ACK",
            "performance_slot_launch_count", 0,
            "performance_slot_authorized", false,
            "p95_produced", false,
            "kbm_performed", false,
            "abc_launched", false,
            "abc_launch_count", 0,
            "abc_launch_authorized", false,
            "old_005_stage_reused", false,
            "old_006_stage_reused", false,
            "old_007_stage_reused", false,
            "old_008_stage_reused", false);
        EvidenceIo.WriteNewJson(manifestPath, manifest);
        string manifestSha = EvidenceIo.Sha256File(manifestPath);
        Dictionary<string, object> receipt = Record.Map(
            "schema", "mfo.qa.qualification.preparation-receipt.v1",
            "work_order", WorkOrder,
            "stage_id", stageId,
            "manifest_path", manifestPath,
            "manifest_sha256", manifestSha,
            "sealed", true,
            "performance_slot_launch_count", 0,
            "p95_produced", false,
            "kbm_performed", false,
            "abc_launched", false,
            "abc_launch_count", 0,
            "old_005_stage_reused", false,
            "old_006_stage_reused", false,
            "old_007_stage_reused", false,
            "old_008_stage_reused", false);
        EvidenceIo.WriteNewJson(receiptPath, receipt);
    }

    private static void Seal(Arguments args, string stage)
    {
        string stageId = args.Required("stage-id");
        RequireStageId(stage, stageId);
        string supervisorCommit = args.Required("supervisor-commit");
        string qaReceiptCommit = args.Required("qa-receipt-commit");
        RequireIssuedIdentity(supervisorCommit, qaReceiptCommit);
        Dictionary<string, object> repositoryState = VerifyRepositoryState(stage, supervisorCommit, qaReceiptCommit);
        Dictionary<string, object> qpOnlyObservation = RequireQpOnlyPresealState(stage, supervisorCommit, qaReceiptCommit);
        qpOnlyObservation["repository_state"] = repositoryState;
        EvidenceIo.WriteNewJson(Path.Combine(stage, "preparation", "qp-only-preseal-observation.json"), qpOnlyObservation);

        string identityContract = Path.Combine(stage, "config", "component-contract.json");
        string manifestPath = Path.Combine(stage, "seal", "qualification-manifest.json");
        string receiptPath = Path.Combine(stage, "seal", "preparation-receipt.json");
        string preparationAuditPath = Path.Combine(stage, "seal", "preparation-audit.json");
        if (File.Exists(preparationAuditPath)) throw new HarnessException("Preparation audit already exists; a stage may be sealed only once");
        HarnessOps.VerifyIdentityDocument(identityContract, stage);
        Dictionary<string, object> manifest = VerifyFinalManifest(stage, stageId, supervisorCommit, qaReceiptCommit, manifestPath, receiptPath, preparationAuditPath);
        string manifestSha = EvidenceIo.Sha256File(manifestPath);
        Dictionary<string, object> receipt = VerifyPreparationReceipt(receiptPath, stageId, manifestPath, manifestSha);
        string receiptSha = EvidenceIo.Sha256File(receiptPath);
        HarnessOps.VerifyIdentityDocument(manifestPath, stage);

        string dryRoot = Path.Combine(stage, "preparation", "dryrun-qualified");
        string selfRoot = Path.Combine(stage, "preparation", "selftest-qualified");
        string smokeRoot = Path.Combine(stage, "preparation", "power-input-smoke-qualified");
        string contractRoot = Path.Combine(stage, "preparation", "preack-contract-selftest-qualified");
        string liveEvidenceContractRoot = Path.Combine(stage, "preparation", "live-evidence-contract-selftest-qualified");
        string dryResult = Path.Combine(dryRoot, "runner-result.json");
        string selfResult = Path.Combine(selfRoot, "runner-result.json");
        string launcherSelfResult = Path.Combine(selfRoot, "launcher", "launcher-result.json");
        string controllerSelfResult = Path.Combine(selfRoot, "launcher", "controller", "controller-result.json");
        string smokeResult = Path.Combine(smokeRoot, "runner-result.json");
        string contractResult = Path.Combine(contractRoot, "runner-result.json");
        string liveEvidenceContractResult = Path.Combine(liveEvidenceContractRoot, "runner-result.json");
        RequirePassResult(dryResult, "runner", "QP_DRYRUN");
        RequirePassResult(selfResult, "runner", "QP_SELFTEST");
        RequirePassResult(launcherSelfResult, "launcher", "QP_SELFTEST");
        RequirePassResult(controllerSelfResult, "controller", "QP_SELFTEST");
        RequirePassResult(smokeResult, "runner", "QP_POWER_INPUT_SMOKE");
        RequirePassResult(contractResult, "runner", "QP_PREACK_CONTRACT_SELFTEST");
        RequirePassResult(liveEvidenceContractResult, "runner", "QP_LIVE_EVIDENCE_CONTRACT_SELFTEST");

        Dictionary<string, object> dryJournal = EvidenceJournal.VerifyFile(Path.Combine(dryRoot, "evidence.journal.jsonl"));
        Dictionary<string, object> selfJournal = EvidenceJournal.VerifyFile(Path.Combine(selfRoot, "evidence.journal.jsonl"));
        Dictionary<string, object> smokeJournal = EvidenceJournal.VerifyFile(Path.Combine(smokeRoot, "evidence.journal.jsonl"));
        Dictionary<string, object> contractJournal = EvidenceJournal.VerifyFile(Path.Combine(contractRoot, "evidence.journal.jsonl"));
        Dictionary<string, object> liveEvidenceContractJournal = EvidenceJournal.VerifyFile(Path.Combine(liveEvidenceContractRoot, "evidence.journal.jsonl"));
        Dictionary<string, object> preparationInvocations = PreparationInvocations(stage, identityContract);
        VerifyManifestPreparationInvocations(manifest, preparationInvocations);
        Dictionary<string, object> smokeBinding = VerifySmokeBinding(stage, identityContract, smokeResult, preparationInvocations);
        Dictionary<string, object> contractSelfTest = VerifyContractSelfTest(contractResult);
        Dictionary<string, object> liveEvidenceContractSelfTest = VerifyLiveEvidenceContractSelfTest(liveEvidenceContractResult);
        Dictionary<string, object> rawStreams = VerifyPreparationRawStreams(stage);
        List<Dictionary<string, object>> sourceAudit = SourceAudit(stage);

        List<Dictionary<string, object>> runtimeIdentities = ComponentFileIdentities(stage);
        runtimeIdentities.Add(EvidenceIo.FileIdentity(identityContract, "config/component-contract.json"));
        runtimeIdentities.Add(EvidenceIo.FileIdentity(manifestPath, "seal/qualification-manifest.json"));
        runtimeIdentities.Add(EvidenceIo.FileIdentity(receiptPath, "seal/preparation-receipt.json"));
        List<Dictionary<string, object>> preparationEvidence = EnumeratePreparationEvidence(stage);
        Dictionary<string, object> testResults = Record.Map(
            "qp_dryrun", TestResultEvidence(dryResult, dryJournal),
            "qp_selftest", TestResultEvidence(selfResult, selfJournal),
            "qp_power_input_smoke", TestResultEvidence(smokeResult, smokeJournal),
            "qp_preack_contract_selftest", TestResultEvidence(contractResult, contractJournal),
            "qp_live_evidence_contract_selftest", TestResultEvidence(liveEvidenceContractResult, liveEvidenceContractJournal));
        Dictionary<string, object> audit = Record.Map(
            "schema", "mfo.qa.qualification.preparation-audit.v1",
            "work_order", WorkOrder,
            "stage_id", stageId,
            "manifest_path", manifestPath,
            "manifest_sha256", manifestSha,
            "receipt_path", receiptPath,
            "receipt_sha256", receiptSha,
            "all_tests_passed", true,
            "test_results", testResults,
            "preparation_mode_count", 5,
            "contract_selftest", contractSelfTest,
            "live_evidence_contract_selftest", liveEvidenceContractSelfTest,
            "smoke_binding", smokeBinding,
            "raw_streams", rawStreams,
            "source_audit", sourceAudit,
            "source_diff_audit_path", Path.Combine(stage, "preparation", "source-diff-audit.json"),
            "source_diff_audit_sha256", EvidenceIo.Sha256File(Path.Combine(stage, "preparation", "source-diff-audit.json")),
            "repository_state", repositoryState,
            "runtime_source_component_configuration_manifest_receipt_identities", runtimeIdentities,
            "preparation_test_evidence", preparationEvidence,
            "runtime_bytes_changed_after_tests", false,
            "pending_before_assert_contract_tested", Convert.ToBoolean(contractSelfTest["all_required_production_paths_pass"], CultureInfo.InvariantCulture),
            "verified_production_persistence_path_count", Record.Integer(contractSelfTest, "verified_production_persistence_path_count"),
            "exact_009_activation_contract_tested", true,
            "receipt_and_audit_binding_contract_tested", true,
            "live_sample_slot_field_contract_tested", true,
            "sentinel_cleanup_before_n0_contract_tested", true,
            "live_pending_completeness_contract_tested", true,
            "performance_slot_launch_count", 0,
            "p95_produced", false,
            "kbm_performed", false,
            "abc_launched", false,
            "abc_launch_count", 0);
        EvidenceIo.WriteNewJson(preparationAuditPath, audit);
        string preparationAuditSha = EvidenceIo.Sha256File(preparationAuditPath);
        VerifyPreparationAudit(preparationAuditPath, audit, manifestPath, manifestSha, receiptPath, receiptSha);

        RequireAbsent(Path.Combine(stage, "runs"), "A stage-local runs directory appeared before sealing");
        string runEvidenceRoot = Record.Text(manifest, "run_evidence_root");
        RequireAbsent(runEvidenceRoot, "External run-evidence root appeared before PREPARED");
        string postSealAuditPath = Path.Combine(stage, "seal", "post-seal-audit.json");
        Dictionary<string, object> postSealPlan = CreatePostSealAudit(stage, stageId, manifestPath, manifestSha, receiptPath, receiptSha, preparationAuditPath, preparationAuditSha, runEvidenceRoot, postSealAuditPath);
        string postSealAuditSha = EvidenceIo.Sha256File(postSealAuditPath);
        SetStageReadOnly(stage);
        Dictionary<string, object> postSeal = VerifyPostSealClosure(stage, postSealPlan, postSealAuditPath, postSealAuditSha, runEvidenceRoot);

        Console.Out.WriteLine("STAGE_ID=" + stageId);
        Console.Out.WriteLine("MANIFEST_SHA256=" + manifestSha);
        Console.Out.WriteLine("RECEIPT_SHA256=" + receiptSha);
        Console.Out.WriteLine("PREPARATION_AUDIT_SHA256=" + preparationAuditSha);
        Console.Out.WriteLine("POST_SEAL_AUDIT_SHA256=" + postSealAuditSha);
        Console.Out.WriteLine("POST_SEAL_FILE_COUNT=" + Record.Integer(postSeal, "stage_file_count").ToString(CultureInfo.InvariantCulture));
        Console.Out.WriteLine("POST_SEAL_READONLY_COUNT=" + Record.Integer(postSeal, "readonly_file_count").ToString(CultureInfo.InvariantCulture));
        Console.Out.WriteLine("PERFORMANCE_SLOT_LAUNCH_COUNT=0");
        Console.Out.WriteLine("ABC_LAUNCH_COUNT=0");
        Console.Out.WriteLine("EXTERNAL_RUN_EVIDENCE_ROOT_ABSENT=True");
    }

    private static void RequireIssuedIdentity(string supervisorCommit, string qaReceiptCommit)
    {
        if (!String.Equals(supervisorCommit, RequiredSupervisorCommit, StringComparison.Ordinal)) throw new HarnessException("Supervisor commit differs from MFO-WO-P2-2A-009");
        if (!String.Equals(qaReceiptCommit, RequiredQaReceiptCommit, StringComparison.Ordinal)) throw new HarnessException("QA receipt commit differs from the accepted -009 handoff receipt");
    }

    private static string ExternalRunEvidenceRoot(string stageId)
    {
        string local = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
        if (String.IsNullOrWhiteSpace(local)) throw new HarnessException("LOCALAPPDATA could not be resolved");
        string root = Path.GetFullPath(Path.Combine(local, "Temp", "MFO-P2-2A-009-Runs", stageId));
        if (root.IndexOf("OneDrive", StringComparison.OrdinalIgnoreCase) >= 0) throw new HarnessException("External run-evidence root resolved inside OneDrive");
        return root;
    }

    private static string GateName(string executable)
    {
        return "Local\\MFO_QA_GATE_" + EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(Path.GetFullPath(executable).ToLowerInvariant())).Substring(0, 24);
    }

    private static void RequireAbsent(string path, string message)
    {
        if (Directory.Exists(path) || File.Exists(path)) throw new HarnessException(message + ": " + path);
    }

    private static void RequireFreshCandidateSourceRoot(string sourceRoot)
    {
        string full = Path.GetFullPath(sourceRoot).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
        if (!Directory.Exists(full)) throw new HarnessException("Fresh candidate source root missing");
        if ((File.GetAttributes(full) & FileAttributes.ReparsePoint) != 0) throw new HarnessException("Candidate source root is a reparse point");
        if (full.IndexOf("OneDrive", StringComparison.OrdinalIgnoreCase) >= 0) throw new HarnessException("Candidate source is inside OneDrive");
        string[] oneDriveVariables = new string[] { "OneDrive", "OneDriveConsumer", "OneDriveCommercial" };
        foreach (string variable in oneDriveVariables)
        {
            string configured = Environment.GetEnvironmentVariable(variable);
            if (!String.IsNullOrWhiteSpace(configured) && IsSameOrChildPath(full, configured)) throw new HarnessException("Candidate source is inside " + variable);
        }
        string[] forbidden = new string[] { "MFO-P2-2A-005", "MFO-P2-2A-006", "MFO-P2-2A-007", "MFO-P2-2A-008", "harness-contract-requalification-008" };
        foreach (string token in forbidden) if (full.IndexOf(token, StringComparison.OrdinalIgnoreCase) >= 0) throw new HarnessException("Frozen source reuse: " + token);
        string[] actual = Directory.GetFiles(full, "*.cs", SearchOption.TopDirectoryOnly).Select(Path.GetFileName).OrderBy(delegate(string n) { return n; }, StringComparer.Ordinal).ToArray();
        string[] expected = ComponentSources.OrderBy(delegate(string n) { return n; }, StringComparer.Ordinal).ToArray();
        if (!actual.SequenceEqual(expected, StringComparer.Ordinal)) throw new HarnessException("Candidate must contain exactly five component sources");
        foreach (string name in ComponentSources)
        {
            string path = Path.Combine(full, name);
            if (new FileInfo(path).Length == 0 || (File.GetAttributes(path) & FileAttributes.ReparsePoint) != 0) throw new HarnessException("Invalid candidate source: " + name);
        }
        if (Directory.GetFiles(full, "*.exe", SearchOption.AllDirectories).Length != 0 || Directory.GetFiles(full, "*.dll", SearchOption.AllDirectories).Length != 0) throw new HarnessException("Candidate source contains compiled payloads");
    }

    private static bool IsSameOrChildPath(string candidate, string root)
    {
        string fullCandidate = Path.GetFullPath(candidate).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
        string fullRoot = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
        return String.Equals(fullCandidate, fullRoot, StringComparison.OrdinalIgnoreCase) || fullCandidate.StartsWith(fullRoot + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase);
    }

    private static List<Dictionary<string, object>> VerifyFreshCompileReceipts(string stage, string stageId, string compiler, string[] specs)
    {
        if (specs == null || specs.Length != 20) throw new HarnessException("Exactly five compile specifications required");
        string[] roles = new string[] { "native", "runner", "launcher", "controller", "sentinel" };
        string root = Path.Combine(stage, "preparation", "fresh-compile");
        RequireAbsent(root, "Fresh compile evidence already exists");
        foreach (string binary in ComponentBinaries) RequireAbsent(Path.Combine(stage, "bin", binary), "Component output already exists");
        Directory.CreateDirectory(root);
        Dictionary<string, object> compilerIdentity = EvidenceIo.FileIdentity(compiler, "external/compiler/csc.exe");
        List<Dictionary<string, object>> receipts = new List<Dictionary<string, object>>();
        for (int i = 0; i < roles.Length; i++)
        {
            int offset = i * 4;
            receipts.Add(CompileFreshComponent(stage, stageId, compiler, compilerIdentity, root, roles[i], ComponentSources[i], ComponentBinaries[i], specs[offset], specs[offset + 1], specs[offset + 2], specs[offset + 3]));
        }
        if (receipts.Count != 5) throw new HarnessException("Fresh compile receipt count mismatch");
        return receipts;
    }

    private static Dictionary<string, object> CompileFreshComponent(string stage, string stageId, string compiler, Dictionary<string, object> compilerIdentity, string root, string expectedRole, string expectedSourceName, string expectedBinaryName, string role, string rawSource, string rawOutput, string invocation)
    {
        string source = Path.GetFullPath(rawSource); string output = Path.GetFullPath(rawOutput);
        if (!String.Equals(role, expectedRole, StringComparison.Ordinal) || !String.Equals(source, Path.Combine(stage, "source", expectedSourceName), StringComparison.OrdinalIgnoreCase) || !String.Equals(output, Path.Combine(stage, "bin", expectedBinaryName), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Compile specification mismatch: " + role);
        if (File.Exists(output) || !File.Exists(source) || !invocation.StartsWith(Quote(Path.GetFullPath(compiler)) + " ", StringComparison.Ordinal) || invocation.IndexOf(Quote(source), StringComparison.Ordinal) < 0 || invocation.IndexOf(Quote(output), StringComparison.Ordinal) < 0) throw new HarnessException("Compile invocation mismatch: " + role);
        string roleRoot = Path.Combine(root, role); Directory.CreateDirectory(roleRoot);
        string invocationPath = Path.Combine(roleRoot, "compiler.invocation.txt"); string stdoutPath = Path.Combine(roleRoot, "compiler.stdout.raw"); string stderrPath = Path.Combine(roleRoot, "compiler.stderr.raw"); string receiptPath = Path.Combine(roleRoot, "compile-receipt.json");
        EvidenceIo.WriteNewBytes(invocationPath, EvidenceIo.Utf8(invocation));
        int exitCode = RunCompiler(invocation, stdoutPath, stderrPath, role);
        if (exitCode != 0 || !File.Exists(output) || !File.Exists(stdoutPath) || !File.Exists(stderrPath)) throw new HarnessException("Fresh compile failed: " + role + "/" + exitCode.ToString(CultureInfo.InvariantCulture));
        return WriteCompileReceipt(stage, stageId, compilerIdentity, role, source, output, invocation, invocationPath, stdoutPath, stderrPath, receiptPath, exitCode);
    }

    private static int RunCompiler(string invocation, string stdoutPath, string stderrPath, string role)
    {
        ProcessStartInfo start = new ProcessStartInfo();
        start.FileName = Environment.GetEnvironmentVariable("ComSpec") ?? "cmd.exe";
        string mark = ((char)34).ToString();
        start.Arguments = "/d /s /c " + mark + invocation + " 1>" + Quote(stdoutPath) + " 2>" + Quote(stderrPath) + mark;
        start.UseShellExecute = false; start.CreateNoWindow = true; start.WindowStyle = ProcessWindowStyle.Hidden;
        using (Process process = new Process())
        {
            process.StartInfo = start;
            if (!process.Start()) throw new HarnessException("Compiler did not start: " + role);
            if (!process.WaitForExit(120000)) { try { process.Kill(); } catch { } process.WaitForExit(); throw new HarnessException("Compiler timeout: " + role); }
            return process.ExitCode;
        }
    }

    private static Dictionary<string, object> WriteCompileReceipt(string stage, string stageId, Dictionary<string, object> compilerIdentity, string role, string source, string output, string invocation, string invocationPath, string stdoutPath, string stderrPath, string receiptPath, int exitCode)
    {
        Dictionary<string, object> outputIdentity = EvidenceIo.FileIdentity(output, "bin/" + Path.GetFileName(output));
        if (!String.Equals(Record.Text(outputIdentity, "mz_hex"), "4D5A", StringComparison.Ordinal)) throw new HarnessException("Output MZ mismatch: " + role);
        Dictionary<string, object> receipt = Record.Map(
            "schema", "mfo.qa.qualification.fresh-compile-receipt.v1",
            "work_order", WorkOrder,
            "stage_id", stageId,
            "role", role,
            "compiler", compilerIdentity,
            "source", EvidenceIo.FileIdentity(source, "source/" + Path.GetFileName(source)),
            "output", outputIdentity,
            "exact_invocation", invocation,
            "invocation_path", invocationPath,
            "invocation_sha256", EvidenceIo.Sha256File(invocationPath),
            "stdout", EvidenceIo.FileIdentity(stdoutPath, Relative(stage, stdoutPath)),
            "stderr", EvidenceIo.FileIdentity(stderrPath, Relative(stage, stderrPath)),
            "native_exit_code", exitCode,
            "output_created_fresh", true,
            "old_stage_component_reused", false,
            "performance_slot_launch_count", 0,
            "abc_launch_count", 0);
        EvidenceIo.WriteNewJson(receiptPath, receipt);
        Dictionary<string, object> readback = EvidenceIo.ReadMap(receiptPath);
        if (!String.Equals(Record.Text(readback, "work_order"), WorkOrder, StringComparison.Ordinal) || !String.Equals(Record.Text(readback, "stage_id"), stageId, StringComparison.Ordinal) || !String.Equals(Record.Text(readback, "role"), role, StringComparison.Ordinal) || Record.Integer(readback, "native_exit_code") != 0 || !Convert.ToBoolean(readback["output_created_fresh"], CultureInfo.InvariantCulture)) throw new HarnessException("Compile receipt readback mismatch: " + role);
        return Record.Map("role", role, "receipt_path", receiptPath, "receipt_sha256", EvidenceIo.Sha256File(receiptPath), "source", readback["source"], "output", readback["output"], "stdout", readback["stdout"], "stderr", readback["stderr"], "invocation_path", invocationPath, "invocation_sha256", EvidenceIo.Sha256File(invocationPath), "native_exit_code", 0, "output_created_fresh", true);
    }

    private static Dictionary<string, object> VerifyLiveEvidenceContractSelfTest(string resultPath)
    {
        Dictionary<string, object> result = EvidenceIo.ReadMap(resultPath);
        Dictionary<string, object> details = Record.AsMap(result["details"]);
        if (!String.Equals(Record.Text(details, "live_evidence_contract_selftest"), "pass", StringComparison.OrdinalIgnoreCase)) throw new HarnessException("LIVE evidence contract self-test did not report pass");
        int cases = Record.Integer(details, "case_count");
        if (cases != 20 || Record.Integer(details, "passed_case_count") != 20 || Record.Integer(details, "controller_launch_count") != 0 || Record.Integer(details, "performance_slot_launch_count") != 0 || Record.Integer(details, "abc_launch_count") != 0 || Record.Integer(details, "final_owned_runtime_count") != 0 || Convert.ToBoolean(details["p95_produced"], CultureInfo.InvariantCulture) || Convert.ToBoolean(details["kbm_performed"], CultureInfo.InvariantCulture)) throw new HarnessException("LIVE evidence contract self-test boundary mismatch");
        Dictionary<string, object> activation = VerifyByteExactActivationFixtureResults(details["activation_fixture_results"], "LIVE evidence contract");
        Dictionary<string, object> sample = VerifyLiveSampleFixtures(details);
        Dictionary<string, object> sentinel = VerifyLiveSentinelFixture(details);
        Dictionary<string, object> evaluations = VerifyLiveEvaluationFixtures(details);
        Dictionary<string, object> binding = VerifyLiveProductionBinding(details);
        return Record.Map("result_path", resultPath, "result_sha256", EvidenceIo.Sha256File(resultPath), "case_count", cases, "passed_case_count", cases, "activation_contract", activation, "sample_contract", sample, "sentinel_contract", sentinel, "evaluation_contract", evaluations, "production_binding_audit", binding, "controller_launch_count", 0, "performance_slot_launch_count", 0, "abc_launch_count", 0);
    }

    private static Dictionary<string, object> VerifyLiveSampleFixtures(Dictionary<string, object> details)
    {
        Dictionary<string, object> positive = Record.AsMap(details["positive_sample_persistence"]);
        Dictionary<string, object> payload = Record.AsMap(positive["payload_readback"]);
        if (!Convert.ToBoolean(positive["readback_success"], CultureInfo.InvariantCulture) || !Convert.ToBoolean(positive["hash_chain_valid"], CultureInfo.InvariantCulture) || Record.Integer(positive, "performance_slot_launch_count") != 0 || Record.Integer(payload, "performance_slot_launch_count") != 0 || Record.Integer(payload, "n") != 0 || Record.Text(positive, "record_sha256").Length != 64) throw new HarnessException("Positive LIVE sample persistence mismatch");
        string[] keys = new string[] { "missing_slot_fixture", "nonzero_slot_fixture" };
        foreach (string key in keys)
        {
            Dictionary<string, object> reference = Record.AsMap(details[key]);
            VerifyPathShaMap(reference, key);
            Dictionary<string, object> fixture = Record.AsMap(reference["result"]);
            if (!Convert.ToBoolean(fixture["passed"], CultureInfo.InvariantCulture) || !Convert.ToBoolean(fixture["rejected_after_durable_readback_and_hash"], CultureInfo.InvariantCulture)) throw new HarnessException("LIVE sample negative fixture mismatch: " + key);
        }
        return Record.Map("positive_sample_persistence", positive, "missing_slot_fixture", details["missing_slot_fixture"], "nonzero_slot_fixture", details["nonzero_slot_fixture"], "performance_slot_launch_count", 0);
    }

    private static Dictionary<string, object> VerifyLiveSentinelFixture(Dictionary<string, object> details)
    {
        Dictionary<string, object> order = Record.AsMap(details["sentinel_order"]);
        int owned = Record.Integer(order, "owned_child_exit_sequence"); int complete = Record.Integer(order, "sentinel_complete_sequence"); int settle = Record.Integer(order, "settle_origin_sequence"); int n0 = Record.Integer(order, "live_sample_n0_sequence");
        if (!(owned > 0 && complete == owned + 1 && settle == complete + 1 && n0 == settle + 1) || !Convert.ToBoolean(order["contiguous_exact_order"], CultureInfo.InvariantCulture) || !Convert.ToBoolean(order["owned_child_disposed"], CultureInfo.InvariantCulture) || Record.Integer(order, "remaining_job_processes") != 0 || Record.Integer(order, "performance_slot_launch_count") != 0) throw new HarnessException("Sentinel/sample order mismatch");
        Dictionary<string, object> sentinel = Record.AsMap(details["sentinel"]);
        if (Record.Integer(sentinel, "exit_code") != 23 || !Convert.ToBoolean(sentinel["raw_tokens_exact"], CultureInfo.InvariantCulture) || !Convert.ToBoolean(sentinel["owned_child_disposed"], CultureInfo.InvariantCulture) || Record.Integer(sentinel, "remaining_job_processes") != 0) throw new HarnessException("Sentinel fixture mismatch");
        return Record.Map("sentinel", sentinel, "sentinel_order", order, "controller_launch_count", 0, "performance_slot_launch_count", 0);
    }

    private static Dictionary<string, object> VerifyLiveEvaluationFixtures(Dictionary<string, object> details)
    {
        Dictionary<string, object> evaluations = Record.AsMap(details["live_evaluation_fixtures"]);
        string[] keys = new string[] { "runner_positive", "runner_missing_required_field", "launcher_positive", "launcher_missing_required_field" };
        foreach (string key in keys)
        {
            Dictionary<string, object> evidence = Record.AsMap(evaluations[key]); string path = Record.Text(evidence, "path"); bool expectedComplete = key.EndsWith("positive", StringComparison.Ordinal);
            if (!File.Exists(path) || !String.Equals(EvidenceIo.Sha256File(path), Record.Text(evidence, "sha256"), StringComparison.OrdinalIgnoreCase) || !Convert.ToBoolean(evidence["pending_readback_success"], CultureInfo.InvariantCulture) || !Convert.ToBoolean(evidence["passed"], CultureInfo.InvariantCulture) || Convert.ToBoolean(evidence["pending_field_completeness_success"], CultureInfo.InvariantCulture) != expectedComplete || Record.Integer(evidence, "actual_result_code") != (expectedComplete ? 0 : 30)) throw new HarnessException("LIVE evaluation fixture mismatch: " + key);
        }
        if (Record.Integer(evaluations, "positive_count") != 2 || Record.Integer(evaluations, "expected_rejection_count") != 2 || Record.Integer(evaluations, "passed_case_count") != 4 || Record.Integer(evaluations, "controller_launch_count") != 0 || Record.Integer(evaluations, "performance_slot_launch_count") != 0) throw new HarnessException("LIVE evaluation fixture totals mismatch");
        return evaluations;
    }

    private static Dictionary<string, object> VerifyLiveProductionBinding(Dictionary<string, object> details)
    {
        Dictionary<string, object> binding = Record.AsMap(details["production_binding_audit"]);
        string[] fields = new string[] { "sample_builder_binding_pass", "sentinel_order_binding_pass", "runner_evaluation_completeness_binding_pass", "launcher_evaluation_completeness_binding_pass", "runner_only_qp_no_child_start_pass", "exact_work_order_009_pass" };
        foreach (string field in fields) if (!Convert.ToBoolean(binding[field], CultureInfo.InvariantCulture)) throw new HarnessException("LIVE production binding failed: " + field);
        if (Record.Integer(binding, "legacy_production_literal_count") != 0 || Record.Integer(binding, "controller_launch_count") != 0 || Record.Integer(binding, "performance_slot_launch_count") != 0) throw new HarnessException("LIVE production binding zero boundary mismatch");
        return binding;
    }

    private static Dictionary<string, object> CreatePostSealAudit(string stage, string stageId, string manifestPath, string manifestSha, string receiptPath, string receiptSha, string preparationAuditPath, string preparationAuditSha, string runEvidenceRoot, string postSealAuditPath)
    {
        RequireAbsent(postSealAuditPath, "Post-seal audit already exists"); RequireAbsent(Path.Combine(stage, "runs"), "Stage-local runs appeared before post-seal audit"); RequireAbsent(runEvidenceRoot, "External run root appeared before post-seal audit");
        List<Dictionary<string, object>> files = new List<Dictionary<string, object>>();
        foreach (string path in Directory.GetFiles(stage, "*", SearchOption.AllDirectories).OrderBy(delegate(string p) { return p; }, StringComparer.OrdinalIgnoreCase)) files.Add(EvidenceIo.FileIdentity(path, Relative(stage, path)));
        Dictionary<string, object> audit = Record.Map(
            "schema", "mfo.qa.qualification.post-seal-audit.v1", "work_order", WorkOrder, "stage_id", stageId, "stage_path", stage,
            "manifest_path", manifestPath, "manifest_sha256", manifestSha, "receipt_path", receiptPath, "receipt_sha256", receiptSha,
            "preparation_audit_path", preparationAuditPath, "preparation_audit_sha256", preparationAuditSha,
            "post_seal_audit_path", postSealAuditPath, "self_digest_embedded", false,
            "enumerated_files_before_post_seal_audit", files, "enumerated_file_count_before_post_seal_audit", files.Count,
            "expected_final_stage_file_count", files.Count + 1, "stage_runs_absent", true,
            "external_run_evidence_root", runEvidenceRoot, "external_run_evidence_root_absent", true,
            "performance_slot_launch_count", 0, "abc_launch_count", 0, "p95_produced", false, "kbm_performed", false);
        EvidenceIo.WriteNewJson(postSealAuditPath, audit);
        Dictionary<string, object> readback = EvidenceIo.ReadMap(postSealAuditPath);
        if (readback.ContainsKey("post_seal_audit_sha256") || Convert.ToBoolean(readback["self_digest_embedded"], CultureInfo.InvariantCulture) || Record.Integer(readback, "expected_final_stage_file_count") != files.Count + 1) throw new HarnessException("Post-seal audit cycle/count mismatch");
        return audit;
    }

    private static Dictionary<string, object> VerifyPostSealClosure(string stage, Dictionary<string, object> plan, string postSealAuditPath, string postSealAuditSha, string runEvidenceRoot)
    {
        RequireAbsent(Path.Combine(stage, "runs"), "Stage-local runs appeared after seal"); RequireAbsent(runEvidenceRoot, "External run root appeared before PREACK");
        if (!File.Exists(postSealAuditPath) || !String.Equals(EvidenceIo.Sha256File(postSealAuditPath), postSealAuditSha, StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Post-seal audit digest mismatch");
        Dictionary<string, object> readback = EvidenceIo.ReadMap(postSealAuditPath);
        if (readback.ContainsKey("post_seal_audit_sha256") || Convert.ToBoolean(readback["self_digest_embedded"], CultureInfo.InvariantCulture) || !String.Equals(Record.Text(readback, "work_order"), WorkOrder, StringComparison.Ordinal) || !String.Equals(Record.Text(readback, "stage_id"), Record.Text(plan, "stage_id"), StringComparison.Ordinal)) throw new HarnessException("Post-seal audit readback mismatch");
        List<Dictionary<string, object>> identities = plan["enumerated_files_before_post_seal_audit"] as List<Dictionary<string, object>>;
        if (identities == null) throw new HarnessException("Post-seal identity plan missing");
        VerifyIdentityList(stage, identities);
        string[] files = Directory.GetFiles(stage, "*", SearchOption.AllDirectories); int expected = Record.Integer(plan, "expected_final_stage_file_count"); int readonlyFiles = files.Count(delegate(string p) { return (File.GetAttributes(p) & FileAttributes.ReadOnly) != 0; });
        if (files.Length != expected || readonlyFiles != files.Length) throw new HarnessException("Post-seal file closure mismatch");
        string[] directories = Directory.GetDirectories(stage, "*", SearchOption.AllDirectories).Concat(new string[] { stage }).ToArray(); int readonlyDirectories = directories.Count(delegate(string p) { return (File.GetAttributes(p) & FileAttributes.ReadOnly) != 0; });
        if (readonlyDirectories != directories.Length) throw new HarnessException("Post-seal directory closure mismatch");
        VerifyPostSealFinalContracts(plan);
        return Record.Map("schema", "mfo.qa.qualification.post-seal-closure.v1", "stage_path", stage, "stage_file_count", files.Length, "readonly_file_count", readonlyFiles, "stage_directory_count", directories.Length, "readonly_directory_count", readonlyDirectories, "all_stage_files_readonly", true, "all_stage_directories_readonly", true, "post_seal_audit_path", postSealAuditPath, "post_seal_audit_sha256", postSealAuditSha, "post_seal_audit_self_digest_embedded", false, "stage_runs_absent", true, "external_run_evidence_root", runEvidenceRoot, "external_run_evidence_root_absent", true, "performance_slot_launch_count", 0, "abc_launch_count", 0);
    }

    private static void VerifyPostSealFinalContracts(Dictionary<string, object> plan)
    {
        if (!String.Equals(EvidenceIo.Sha256File(Record.Text(plan, "manifest_path")), Record.Text(plan, "manifest_sha256"), StringComparison.OrdinalIgnoreCase) || !String.Equals(EvidenceIo.Sha256File(Record.Text(plan, "receipt_path")), Record.Text(plan, "receipt_sha256"), StringComparison.OrdinalIgnoreCase) || !String.Equals(EvidenceIo.Sha256File(Record.Text(plan, "preparation_audit_path")), Record.Text(plan, "preparation_audit_sha256"), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Post-seal final contract identity mismatch");
    }

    private static Dictionary<string, object> VerifyFinalManifest(string stage, string stageId, string supervisorCommit, string qaReceiptCommit, string manifestPath, string receiptPath, string preparationAuditPath)
    {
        Dictionary<string, object> manifest = EvidenceIo.ReadMap(manifestPath);
        string expectedRunRoot = ExternalRunEvidenceRoot(stageId);
        if (!String.Equals(Record.Text(manifest, "schema"), "mfo.qa.qualification.manifest.v1", StringComparison.Ordinal) ||
            !String.Equals(Record.Text(manifest, "work_order"), WorkOrder, StringComparison.Ordinal) ||
            !String.Equals(Record.Text(manifest, "stage_id"), stageId, StringComparison.Ordinal) ||
            !String.Equals(Path.GetFullPath(Record.Text(manifest, "stage_path")), Path.GetFullPath(stage), StringComparison.OrdinalIgnoreCase) ||
            !String.Equals(Path.GetFullPath(Record.Text(manifest, "run_evidence_root")), expectedRunRoot, StringComparison.OrdinalIgnoreCase) ||
            !String.Equals(Path.GetFullPath(Record.Text(manifest, "preparation_receipt_path")), Path.GetFullPath(receiptPath), StringComparison.OrdinalIgnoreCase) ||
            !String.Equals(Path.GetFullPath(Record.Text(manifest, "preparation_audit_path")), Path.GetFullPath(preparationAuditPath), StringComparison.OrdinalIgnoreCase) ||
            !String.Equals(Record.Text(manifest, "supervisor_starting_commit"), supervisorCommit, StringComparison.Ordinal) ||
            !String.Equals(Record.Text(manifest, "qa_receipt_commit"), qaReceiptCommit, StringComparison.Ordinal) ||
            !String.Equals(Record.Text(manifest, "required_qa_branch"), RequiredBranch, StringComparison.Ordinal) ||
            Record.Integer(manifest, "performance_slot_launch_count") != 0 ||
            Convert.ToBoolean(manifest["performance_slot_authorized"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(manifest["p95_produced"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(manifest["kbm_performed"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(manifest["abc_launched"], CultureInfo.InvariantCulture) ||
            Record.Integer(manifest, "abc_launch_count") != 0 ||
            Convert.ToBoolean(manifest["abc_launch_authorized"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(manifest["old_005_stage_reused"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(manifest["old_006_stage_reused"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(manifest["old_007_stage_reused"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(manifest["old_008_stage_reused"], CultureInfo.InvariantCulture)) throw new HarnessException("Final manifest does not match the -009 zero-slot/no-reuse contract");
        if (manifest.ContainsKey("manifest_sha256") || manifest.ContainsKey("receipt_sha256") || manifest.ContainsKey("preparation_audit_sha256")) throw new HarnessException("Final manifest embeds a circular final digest");
        Dictionary<string, object> liveEvidence = Record.AsMap(manifest["live_evidence_contract"]);
        if (Record.Integer(liveEvidence, "every_live_sample_performance_slot_launch_count") != 0 || !Convert.ToBoolean(liveEvidence["runner_pending_readback_success_required"], CultureInfo.InvariantCulture) || !Convert.ToBoolean(liveEvidence["runner_pending_field_completeness_success_required"], CultureInfo.InvariantCulture) || !Convert.ToBoolean(liveEvidence["launcher_pending_readback_success_required"], CultureInfo.InvariantCulture) || !Convert.ToBoolean(liveEvidence["launcher_pending_field_completeness_success_required"], CultureInfo.InvariantCulture) || Convert.ToBoolean(liveEvidence["precleanup_n0_callback_allowed"], CultureInfo.InvariantCulture)) throw new HarnessException("Final manifest LIVE-evidence correction contract mismatch");
        object[] sentinelOrder = liveEvidence["sentinel_order"] as object[];
        string[] expectedSentinelOrder = new string[] { "owned_child_exit", "sentinel_complete", "settle_origin_after_sentinel_exit", "live_sample n=0" };
        if (sentinelOrder == null || sentinelOrder.Length != expectedSentinelOrder.Length || !sentinelOrder.Select(delegate(object value) { return Convert.ToString(value, CultureInfo.InvariantCulture); }).SequenceEqual(expectedSentinelOrder, StringComparer.Ordinal)) throw new HarnessException("Final manifest sentinel durable order mismatch");
        Dictionary<string, object> schemas = Record.AsMap(manifest["evidence_schemas"]);
        if (!String.Equals(Record.Text(schemas, "pending_preack"), "mfo.qa.preack.pending.v2", StringComparison.Ordinal) ||
            !String.Equals(Record.Text(schemas, "preack_evaluation"), "mfo.qa.preack.evaluation.v2", StringComparison.Ordinal) ||
            !String.Equals(Record.Text(schemas, "live_activation_pending"), "mfo.qa.live.activation.pending.v1", StringComparison.Ordinal) ||
            !String.Equals(Record.Text(schemas, "live_activation_evaluation"), "mfo.qa.live.activation.evaluation.v1", StringComparison.Ordinal) ||
            !String.Equals(Record.Text(schemas, "launcher_live_pending"), "mfo.qa.live.activation.pending.v1", StringComparison.Ordinal) ||
            !String.Equals(Record.Text(schemas, "launcher_live_evaluation"), "mfo.qa.live.activation.evaluation.v1", StringComparison.Ordinal)) throw new HarnessException("Final manifest evidence schemas do not match the compiled -009 native contract");
        Dictionary<string, object> outputs = Record.AsMap(manifest["output_paths"]);
        Dictionary<string, object> live = Record.AsMap(outputs["live"]);
        if (!String.Equals(Path.GetFullPath(Record.Text(live, "launcher_pending_observation")), Path.Combine(expectedRunRoot, "live-001", "launcher", "launcher-live-pending.json"), StringComparison.OrdinalIgnoreCase) ||
            !String.Equals(Path.GetFullPath(Record.Text(live, "launcher_evaluation")), Path.Combine(expectedRunRoot, "live-001", "launcher", "launcher-live-evaluation.json"), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Final manifest launcher LIVE evidence paths are not fixed to the -009 contract");
        Dictionary<string, object> invocations = Record.AsMap(manifest["invocations"]);
        Dictionary<string, object> invocationContract = Record.AsMap(manifest["invocation_argument_contract"]);
        if (!String.Equals(Record.Text(invocationContract, "extra_key_order"), "StringComparer.Ordinal", StringComparison.Ordinal) ||
            !String.Equals(Record.Text(invocationContract, "extra_value_quoting"), "HarnessOps.Quote for every literal and placeholder", StringComparison.Ordinal) ||
            !Convert.ToBoolean(invocationContract["named_placeholders_are_quoted"], CultureInfo.InvariantCulture) ||
            !Convert.ToBoolean(invocationContract["start_gate_after_sorted_extra_args"], CultureInfo.InvariantCulture)) throw new HarnessException("Manifest invocation argument grammar does not bind StartRole ordering and quoting");
        VerifyTemplateContract(invocations, "qp_selftest_launcher_template", "qp_selftest_launcher_extra_keys_ordinal", true);
        VerifyTemplateContract(invocations, "qp_selftest_controller_template", "qp_selftest_controller_extra_keys_ordinal", true);
        VerifyTemplateContract(invocations, "preack_runner_template", "preack_runner_extra_keys_ordinal", false);
        VerifyTemplateContract(invocations, "live_runner_template", "live_runner_extra_keys_ordinal", false);
        VerifyTemplateContract(invocations, "preack_launcher_template", "preack_launcher_extra_keys_ordinal", true);
        VerifyTemplateContract(invocations, "live_launcher_template", "live_launcher_extra_keys_ordinal", true);
        VerifyTemplateContract(invocations, "live_controller_template", "live_controller_extra_keys_ordinal", true);
        if (!String.Equals(Record.Text(invocations, "preack_runner_template_kind"), "direct_invocation_grammar_with_named_placeholders", StringComparison.Ordinal) ||
            !String.Equals(Record.Text(invocations, "live_runner_template_kind"), "direct_invocation_grammar_with_named_placeholders", StringComparison.Ordinal) ||
            !Convert.ToBoolean(invocations["preack_runner_direct_basic_args_exact"], CultureInfo.InvariantCulture) ||
            !Convert.ToBoolean(invocations["live_runner_direct_basic_args_exact"], CultureInfo.InvariantCulture) ||
            !String.Equals(Record.Text(invocations, "child_role_template_kind"), "runtime_exact_ordinal_extra_key_order_with_named_placeholders", StringComparison.Ordinal)) throw new HarnessException("Runner direct grammar or child template contract kind is missing");
        string expectedLauncherRoot = Path.Combine(expectedRunRoot, "live-001", "launcher");
        if (Record.Text(invocations, "live_launcher_template").IndexOf(" --out " + Quote(expectedLauncherRoot), StringComparison.Ordinal) < 0 ||
            !String.Equals(Path.GetFullPath(Record.Text(invocations, "live_launcher_template_fixed_pending_observation")), Path.Combine(expectedLauncherRoot, "launcher-live-pending.json"), StringComparison.OrdinalIgnoreCase) ||
            !String.Equals(Path.GetFullPath(Record.Text(invocations, "live_launcher_template_fixed_evaluation")), Path.Combine(expectedLauncherRoot, "launcher-live-evaluation.json"), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Sealed LIVE launcher template does not bind its fixed pending/evaluation paths");
        RequireAbsent(expectedRunRoot, "External run-evidence root exists before PREPARED");
        RequireAbsent(Path.Combine(stage, "runs"), "Stage-local runs directory exists");
        return manifest;
    }

    private static void VerifyTemplateContract(Dictionary<string, object> invocations, string templateKey, string keysKey, bool startGateRequired)
    {
        string template = Record.Text(invocations, templateKey);
        object raw;
        if (!invocations.TryGetValue(keysKey, out raw)) throw new HarnessException("Template key-order evidence missing: " + keysKey);
        object[] values = raw as object[];
        if (values == null) throw new HarnessException("Template key-order evidence is not an array: " + keysKey);
        string[] keys = new string[values.Length];
        for (int i = 0; i < values.Length; i++) keys[i] = Convert.ToString(values[i], CultureInfo.InvariantCulture);
        string[] sorted = (string[])keys.Clone();
        Array.Sort(sorted, StringComparer.Ordinal);
        if (!keys.SequenceEqual(sorted, StringComparer.Ordinal)) throw new HarnessException("Template extra keys are not recorded in ordinal order: " + templateKey);
        int cursor = -1;
        for (int i = 0; i < keys.Length; i++)
        {
            string token = " --" + keys[i] + " \"";
            int at = template.IndexOf(token, cursor + 1, StringComparison.Ordinal);
            if (at <= cursor) throw new HarnessException("Template extra key is absent or out of ordinal order: " + templateKey + "/" + keys[i]);
            int valueEnd = template.IndexOf('"', at + token.Length);
            if (valueEnd < 0) throw new HarnessException("Template extra value is not closed by a quote: " + templateKey + "/" + keys[i]);
            cursor = valueEnd;
        }
        int gate = template.IndexOf(" --start-gate \"", StringComparison.Ordinal);
        if (startGateRequired && (gate <= cursor || template.IndexOf('"', gate + " --start-gate \"".Length) < 0)) throw new HarnessException("Child template start-gate is absent or not last: " + templateKey);
        if (!startGateRequired && gate >= 0) throw new HarnessException("Direct runner template unexpectedly includes an OwnedChild start-gate: " + templateKey);
        int expectedArgumentCount = 6 + keys.Length + (startGateRequired ? 1 : 0);
        if (Count(template, " --") != expectedArgumentCount) throw new HarnessException("Template contains an unrecorded or missing argument: " + templateKey);
        if (!AllNamedPlaceholdersQuoted(template)) throw new HarnessException("Template contains an unquoted named placeholder: " + templateKey);
    }

    private static bool AllNamedPlaceholdersQuoted(string template)
    {
        int cursor = 0;
        while ((cursor = template.IndexOf('<', cursor)) >= 0)
        {
            int end = template.IndexOf('>', cursor + 1);
            if (end < 0 || cursor == 0 || end + 1 >= template.Length || template[cursor - 1] != '"' || template[end + 1] != '"') return false;
            cursor = end + 1;
        }
        return true;
    }

    private static Dictionary<string, object> VerifyPreparationReceipt(string receiptPath, string stageId, string manifestPath, string manifestSha)
    {
        Dictionary<string, object> receipt = EvidenceIo.ReadMap(receiptPath);
        if (!String.Equals(Record.Text(receipt, "schema"), "mfo.qa.qualification.preparation-receipt.v1", StringComparison.Ordinal) ||
            !String.Equals(Record.Text(receipt, "work_order"), WorkOrder, StringComparison.Ordinal) ||
            !String.Equals(Record.Text(receipt, "stage_id"), stageId, StringComparison.Ordinal) ||
            !String.Equals(Path.GetFullPath(Record.Text(receipt, "manifest_path")), Path.GetFullPath(manifestPath), StringComparison.OrdinalIgnoreCase) ||
            !String.Equals(Record.Text(receipt, "manifest_sha256"), manifestSha, StringComparison.OrdinalIgnoreCase) ||
            !Convert.ToBoolean(receipt["sealed"], CultureInfo.InvariantCulture) ||
            Record.Integer(receipt, "performance_slot_launch_count") != 0 ||
            Convert.ToBoolean(receipt["p95_produced"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(receipt["kbm_performed"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(receipt["abc_launched"], CultureInfo.InvariantCulture) ||
            Record.Integer(receipt, "abc_launch_count") != 0 ||
            Convert.ToBoolean(receipt["old_005_stage_reused"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(receipt["old_006_stage_reused"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(receipt["old_007_stage_reused"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(receipt["old_008_stage_reused"], CultureInfo.InvariantCulture)) throw new HarnessException("Preparation receipt does not match the final -009 identity/no-reuse contract");
        if (receipt.ContainsKey("receipt_sha256") || receipt.ContainsKey("preparation_audit_sha256")) throw new HarnessException("Preparation receipt embeds a circular digest");
        return receipt;
    }

    private static void VerifyManifestPreparationInvocations(Dictionary<string, object> manifest, Dictionary<string, object> expected)
    {
        Dictionary<string, object> invocations = Record.AsMap(manifest["invocations"]);
        string[] keys = new string[]
        {
            "qp_dryrun_runner_exact", "qp_dryrun_runner_exact_sha256",
            "qp_selftest_runner_exact", "qp_selftest_runner_exact_sha256",
            "qp_power_input_smoke_runner_exact", "qp_power_input_smoke_runner_exact_sha256",
            "qp_preack_contract_selftest_runner_exact", "qp_preack_contract_selftest_runner_exact_sha256",
            "qp_live_evidence_contract_selftest_runner_exact", "qp_live_evidence_contract_selftest_runner_exact_sha256"
        };
        foreach (string key in keys)
        {
            if (!String.Equals(Record.Text(invocations, key), Record.Text(expected, key), StringComparison.Ordinal)) throw new HarnessException("Final manifest preparation invocation changed after testing contract creation: " + key);
        }
    }

    private static Dictionary<string, object> VerifyContractSelfTest(string resultPath)
    {
        Dictionary<string, object> result = EvidenceIo.ReadMap(resultPath);
        Dictionary<string, object> details = Record.AsMap(result["details"]);
        if (!String.Equals(Record.Text(details, "contract_selftest"), "pass", StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Contract self-test did not report pass");
        int count = Record.Integer(details, "case_count");
        int passed = Record.Integer(details, "passed_case_count");
        if (count != 33 || passed != 33) throw new HarnessException("Contract self-test case count mismatch");
        if (Record.Integer(details, "performance_slot_launch_count") != 0 || Record.Integer(details, "final_owned_runtime_count") != 0 || Record.Integer(details, "abc_launch_count") != 0) throw new HarnessException("Contract self-test violated the zero-launch boundary");
        Dictionary<string, object> pending = Record.AsMap(details["positive_receipt_pending"]);
        Dictionary<string, object> evaluation = Record.AsMap(details["positive_receipt_evaluation"]);
        VerifyPathShaMap(pending, "positive receipt pending observation");
        VerifyPathShaMap(evaluation, "positive receipt evaluation");
        object[] negative = details["negative_case_results"] as object[];
        object[] activations = details["activation_fixture_results"] as object[];
        if (negative == null || negative.Length != 20 || activations == null || activations.Length != 11) throw new HarnessException("Contract self-test fixture result arrays are incomplete");
        Dictionary<string, object> activation = VerifyByteExactActivationFixtureResults(activations, "PREACK contract");
        Dictionary<string, object> productionBinding = Record.AsMap(details["production_binding_audit"]);
        if (productionBinding.Count == 0) throw new HarnessException("Contract self-test production binding audit is empty");
        string[] productionOrderPassFields = new string[] { "runner_preack_order_pass", "launcher_preack_order_pass", "live_runner_activation_order_pass", "launcher_live_order_pass" };
        foreach (string field in productionOrderPassFields)
        {
            object raw;
            if (!productionBinding.TryGetValue(field, out raw) || !Convert.ToBoolean(raw, CultureInfo.InvariantCulture)) throw new HarnessException("Contract self-test did not prove persist-before-assert for production path: " + field);
        }
        productionBinding["verified_production_persistence_path_count"] = productionOrderPassFields.Length;
        productionBinding["all_required_production_paths_pass"] = true;
        return Record.Map(
            "result_path", resultPath,
            "result_sha256", EvidenceIo.Sha256File(resultPath),
            "case_count", count,
            "passed_case_count", passed,
            "positive_receipt_pending", pending,
            "positive_receipt_evaluation", evaluation,
            "negative_case_count", negative.Length,
            "activation_fixture_count", activations.Length,
            "activation_contract", activation,
            "production_binding_audit", productionBinding,
            "verified_production_persistence_path_count", productionOrderPassFields.Length,
            "all_required_production_paths_pass", true,
            "performance_slot_launch_count", 0,
            "abc_launch_count", 0);
    }

    private static Dictionary<string, object> VerifyByteExactActivationFixtureResults(object raw, string label)
    {
        object[] fixtures = raw as object[];
        string[] expectedNames = new string[]
        {
            "exact", "old_006", "old_007", "old_008", "missing_field", "extra_field",
            "reordered", "case_changed", "extra_cr", "extra_lf", "extra_crlf"
        };
        if (fixtures == null || fixtures.Length != expectedNames.Length) throw new HarnessException(label + " activation fixture count mismatch");
        Dictionary<string, Dictionary<string, object>> byName = new Dictionary<string, Dictionary<string, object>>(StringComparer.Ordinal);
        foreach (object rawFixture in fixtures)
        {
            Dictionary<string, object> fixture = Record.AsMap(rawFixture);
            string name = Record.Text(fixture, "name");
            if (String.IsNullOrEmpty(name) || byName.ContainsKey(name)) throw new HarnessException(label + " activation fixture name missing or duplicated");
            bool shouldAccept = String.Equals(name, "exact", StringComparison.Ordinal);
            if (!expectedNames.Contains(name, StringComparer.Ordinal) ||
                !Convert.ToBoolean(fixture["passed"], CultureInfo.InvariantCulture) ||
                Convert.ToBoolean(fixture["expected_accepted"], CultureInfo.InvariantCulture) != shouldAccept ||
                Convert.ToBoolean(fixture["accepted"], CultureInfo.InvariantCulture) != shouldAccept)
                throw new HarnessException(label + " activation fixture verdict mismatch: " + name);
            VerifyPathShaMap(fixture, label + " activation fixture " + name);
            VerifyPathShaMap(Record.AsMap(fixture["pending"]), label + " activation pending " + name);
            VerifyPathShaMap(Record.AsMap(fixture["evaluation"]), label + " activation evaluation " + name);
            byName.Add(name, fixture);
        }
        foreach (string name in expectedNames) if (!byName.ContainsKey(name)) throw new HarnessException(label + " activation fixture missing: " + name);

        byte[] exact = File.ReadAllBytes(Path.GetFullPath(Record.Text(byName["exact"], "path")));
        if (exact.Length == 0 || (exact.Length >= 3 && exact[0] == 0xEF && exact[1] == 0xBB && exact[2] == 0xBF)) throw new HarnessException(label + " exact activation fixture has an empty/BOM payload");
        foreach (byte value in exact) if (value == 0x0D || value == 0x0A) throw new HarnessException(label + " exact activation fixture contains CR/LF");
        if (!HasExactSuffix(File.ReadAllBytes(Path.GetFullPath(Record.Text(byName["extra_cr"], "path"))), exact, new byte[] { 0x0D }) ||
            !HasExactSuffix(File.ReadAllBytes(Path.GetFullPath(Record.Text(byName["extra_lf"], "path"))), exact, new byte[] { 0x0A }) ||
            !HasExactSuffix(File.ReadAllBytes(Path.GetFullPath(Record.Text(byName["extra_crlf"], "path"))), exact, new byte[] { 0x0D, 0x0A }))
            throw new HarnessException(label + " named CR/LF/CRLF fixture bytes mismatch");

        return Record.Map(
            "fixture_count", fixtures.Length,
            "unique_name_count", byName.Count,
            "exact_positive_no_bom_or_terminator", true,
            "extra_cr_rejected", true,
            "extra_lf_rejected", true,
            "extra_crlf_rejected", true,
            "exact_path", Record.Text(byName["exact"], "path"),
            "exact_sha256", Record.Text(byName["exact"], "sha256"),
            "fixture_results", fixtures);
    }

    private static bool HasExactSuffix(byte[] candidate, byte[] prefix, byte[] suffix)
    {
        if (candidate == null || prefix == null || suffix == null || candidate.Length != prefix.Length + suffix.Length) return false;
        for (int i = 0; i < prefix.Length; i++) if (candidate[i] != prefix[i]) return false;
        for (int i = 0; i < suffix.Length; i++) if (candidate[prefix.Length + i] != suffix[i]) return false;
        return true;
    }

    private static void VerifyPathShaMap(Dictionary<string, object> evidence, string label)
    {
        string path = Path.GetFullPath(Record.Text(evidence, "path"));
        string expected = Record.Text(evidence, "sha256");
        if (!File.Exists(path) || !String.Equals(EvidenceIo.Sha256File(path), expected, StringComparison.OrdinalIgnoreCase)) throw new HarnessException(label + " identity mismatch");
    }

    private static Dictionary<string, object> TestResultEvidence(string resultPath, Dictionary<string, object> journalVerification)
    {
        return Record.Map(
            "result", EvidenceIo.ReadMap(resultPath),
            "result_path", resultPath,
            "result_sha256", EvidenceIo.Sha256File(resultPath),
            "journal_verification", journalVerification,
            "pass", true,
            "native_exit_code", 0,
            "performance_slot_launch_count", 0,
            "abc_launch_count", 0);
    }

    private static List<Dictionary<string, object>> EnumeratePreparationEvidence(string stage)
    {
        List<Dictionary<string, object>> files = new List<Dictionary<string, object>>();
        foreach (string path in Directory.GetFiles(Path.Combine(stage, "preparation"), "*", SearchOption.AllDirectories).OrderBy(delegate(string p) { return p; }, StringComparer.OrdinalIgnoreCase))
        {
            files.Add(EvidenceIo.FileIdentity(path, Relative(stage, path)));
        }
        return files;
    }

    private static void VerifyPreparationAudit(string auditPath, Dictionary<string, object> audit, string manifestPath, string manifestSha, string receiptPath, string receiptSha)
    {
        Dictionary<string, object> readback = EvidenceIo.ReadMap(auditPath);
        if (!String.Equals(Record.Text(readback, "schema"), "mfo.qa.qualification.preparation-audit.v1", StringComparison.Ordinal) ||
            !String.Equals(Record.Text(readback, "work_order"), WorkOrder, StringComparison.Ordinal) ||
            !String.Equals(Record.Text(readback, "stage_id"), Record.Text(audit, "stage_id"), StringComparison.Ordinal) ||
            !String.Equals(Path.GetFullPath(Record.Text(readback, "manifest_path")), Path.GetFullPath(manifestPath), StringComparison.OrdinalIgnoreCase) ||
            !String.Equals(Record.Text(readback, "manifest_sha256"), manifestSha, StringComparison.OrdinalIgnoreCase) ||
            !String.Equals(Path.GetFullPath(Record.Text(readback, "receipt_path")), Path.GetFullPath(receiptPath), StringComparison.OrdinalIgnoreCase) ||
            !String.Equals(Record.Text(readback, "receipt_sha256"), receiptSha, StringComparison.OrdinalIgnoreCase) ||
            !Convert.ToBoolean(readback["all_tests_passed"], CultureInfo.InvariantCulture) ||
            Record.Integer(readback, "preparation_mode_count") != 5 ||
            !Convert.ToBoolean(readback["pending_before_assert_contract_tested"], CultureInfo.InvariantCulture) ||
            Record.Integer(readback, "verified_production_persistence_path_count") != 4 ||
            !Convert.ToBoolean(readback["exact_009_activation_contract_tested"], CultureInfo.InvariantCulture) ||
            !Convert.ToBoolean(readback["receipt_and_audit_binding_contract_tested"], CultureInfo.InvariantCulture) ||
            !Convert.ToBoolean(readback["live_sample_slot_field_contract_tested"], CultureInfo.InvariantCulture) ||
            !Convert.ToBoolean(readback["sentinel_cleanup_before_n0_contract_tested"], CultureInfo.InvariantCulture) ||
            !Convert.ToBoolean(readback["live_pending_completeness_contract_tested"], CultureInfo.InvariantCulture) ||
            Record.Integer(readback, "performance_slot_launch_count") != 0 ||
            Convert.ToBoolean(readback["p95_produced"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(readback["kbm_performed"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(readback["abc_launched"], CultureInfo.InvariantCulture) ||
            Record.Integer(readback, "abc_launch_count") != 0) throw new HarnessException("Final preparation-audit readback failed");
        if (readback.ContainsKey("preparation_audit_sha256")) throw new HarnessException("Preparation audit embeds its own circular digest");
    }

    private static void SetStageReadOnly(string stage)
    {
        foreach (string path in Directory.GetFiles(stage, "*", SearchOption.AllDirectories)) File.SetAttributes(path, File.GetAttributes(path) | FileAttributes.ReadOnly);
        string[] directories = Directory.GetDirectories(stage, "*", SearchOption.AllDirectories).OrderByDescending(delegate(string p) { return p.Length; }).ToArray();
        foreach (string directory in directories) File.SetAttributes(directory, File.GetAttributes(directory) | FileAttributes.ReadOnly);
        File.SetAttributes(stage, File.GetAttributes(stage) | FileAttributes.ReadOnly);
    }

    private static Dictionary<string, object> PostSealAudit(string stage, List<Dictionary<string, object>> runtimeIdentities, List<Dictionary<string, object>> preparationEvidence, string manifestPath, string manifestSha, string receiptPath, string receiptSha, string auditPath, string auditSha, string runEvidenceRoot)
    {
        RequireAbsent(Path.Combine(stage, "runs"), "Stage-local runs directory appeared after sealing");
        RequireAbsent(runEvidenceRoot, "External run-evidence root appeared before PREACK");
        VerifyIdentityList(stage, runtimeIdentities);
        VerifyIdentityList(stage, preparationEvidence);
        if (!String.Equals(EvidenceIo.Sha256File(manifestPath), manifestSha, StringComparison.OrdinalIgnoreCase) ||
            !String.Equals(EvidenceIo.Sha256File(receiptPath), receiptSha, StringComparison.OrdinalIgnoreCase) ||
            !String.Equals(EvidenceIo.Sha256File(auditPath), auditSha, StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Post-seal final contract digest mismatch");
        string[] files = Directory.GetFiles(stage, "*", SearchOption.AllDirectories);
        int readOnly = files.Count(delegate(string path) { return (File.GetAttributes(path) & FileAttributes.ReadOnly) != 0; });
        if (files.Length == 0 || readOnly != files.Length) throw new HarnessException("Not every stage file is ReadOnly after seal");
        return Record.Map(
            "stage_path", stage,
            "stage_file_count", files.Length,
            "readonly_file_count", readOnly,
            "all_stage_files_readonly", true,
            "manifest_sha256", manifestSha,
            "receipt_sha256", receiptSha,
            "preparation_audit_sha256", auditSha,
            "stage_runs_absent", true,
            "external_run_evidence_root", runEvidenceRoot,
            "external_run_evidence_root_absent", true,
            "performance_slot_launch_count", 0,
            "abc_launch_count", 0);
    }

    private static void VerifyIdentityList(string stage, List<Dictionary<string, object>> identities)
    {
        foreach (Dictionary<string, object> identity in identities)
        {
            string relative = Record.Text(identity, "relative_path");
            string path = Path.Combine(stage, relative.Replace('/', Path.DirectorySeparatorChar));
            if (!File.Exists(path) || !String.Equals(EvidenceIo.Sha256File(path), Record.Text(identity, "sha256"), StringComparison.OrdinalIgnoreCase) || new FileInfo(path).Length != Convert.ToInt64(identity["byte_size"], CultureInfo.InvariantCulture)) throw new HarnessException("Post-seal enumerated identity mismatch: " + relative);
        }
    }

    private static Dictionary<string, object> RequireQpOnlyPresealState(string stage, string supervisorCommit, string qaReceiptCommit)
    {
        string fullStage = Path.GetFullPath(stage);
        if (fullStage.IndexOf("OneDrive", StringComparison.OrdinalIgnoreCase) >= 0) throw new HarnessException("Qualification stage is inside OneDrive");
        if (fullStage.IndexOf("MFO-P2-2A-005", StringComparison.OrdinalIgnoreCase) >= 0) throw new HarnessException("Frozen -005 stage path is forbidden");
        if (fullStage.IndexOf("MFO-P2-2A-006", StringComparison.OrdinalIgnoreCase) >= 0) throw new HarnessException("Frozen -006 stage path is forbidden");
        if (fullStage.IndexOf("MFO-P2-2A-007", StringComparison.OrdinalIgnoreCase) >= 0) throw new HarnessException("Frozen -007 stage path is forbidden");
        if (fullStage.IndexOf("MFO-P2-2A-008", StringComparison.OrdinalIgnoreCase) >= 0) throw new HarnessException("Frozen -008 stage path is forbidden");
        if (!Path.GetFileName(fullStage).StartsWith(StagePrefix, StringComparison.Ordinal)) throw new HarnessException("Fresh -009 stage ID prefix is required");
        string stageRuns = Path.Combine(fullStage, "runs");
        string externalRoot = ExternalRunEvidenceRoot(Path.GetFileName(fullStage));
        if (Directory.Exists(stageRuns) || File.Exists(stageRuns)) throw new HarnessException("Stage-local runtime evidence exists before seal");
        if (Directory.Exists(externalRoot) || File.Exists(externalRoot)) throw new HarnessException("External runtime evidence exists before seal");

        List<string> forbiddenArtifacts = new List<string>();
        string contractFixtureRoot = Path.GetFullPath(Path.Combine(fullStage, "preparation", "preack-contract-selftest-qualified"));
        string liveContractFixtureRoot = Path.GetFullPath(Path.Combine(fullStage, "preparation", "live-evidence-contract-selftest-qualified"));
        foreach (string entry in Directory.GetFileSystemEntries(fullStage, "*", SearchOption.AllDirectories))
        {
            string leaf = Path.GetFileName(entry);
            string normalized = leaf.ToLowerInvariant();
            string fullEntry = Path.GetFullPath(entry);
            bool syntheticContractFixture = fullEntry.StartsWith(contractFixtureRoot + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase) || fullEntry.StartsWith(liveContractFixtureRoot + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase);
            if (!syntheticContractFixture && (normalized == "activation-token.txt" || normalized == "preack-record.json" || normalized.Contains("performance-slot") || normalized.Contains("performance_slot") || normalized.Contains("p95") || normalized.Contains("kbm"))) forbiddenArtifacts.Add(entry);
        }
        if (forbiddenArtifacts.Count != 0) throw new HarnessException("Forbidden non-QP artifact exists before seal: " + forbiddenArtifacts[0]);

        string materializationPath = Path.Combine(fullStage, "preparation", "materialization.json");
        Dictionary<string, object> materialization = EvidenceIo.ReadMap(materializationPath);
        if (!String.Equals(Record.Text(materialization, "supervisor_commit"), supervisorCommit, StringComparison.Ordinal)) throw new HarnessException("Materialization supervisor commit mismatch");
        object old005;
        if (!materialization.TryGetValue("old_005_stage_reused", out old005) || Convert.ToBoolean(old005, CultureInfo.InvariantCulture)) throw new HarnessException("Materialization does not prove old -005 exclusion");
        object old006;
        if (!materialization.TryGetValue("old_006_stage_reused", out old006) || Convert.ToBoolean(old006, CultureInfo.InvariantCulture)) throw new HarnessException("Materialization does not prove old -006 exclusion");
        object old007;
        if (!materialization.TryGetValue("old_007_stage_reused", out old007) || Convert.ToBoolean(old007, CultureInfo.InvariantCulture)) throw new HarnessException("Materialization does not prove old -007 exclusion");
        object old008;
        if (!materialization.TryGetValue("old_008_stage_reused", out old008) || Convert.ToBoolean(old008, CultureInfo.InvariantCulture)) throw new HarnessException("Materialization does not prove old -008 exclusion");
        if (Record.Integer(materialization, "game_executable_copy_count") != 0 || Record.Integer(materialization, "abc_launch_count") != 0 || Convert.ToBoolean(materialization["abc_launched"], CultureInfo.InvariantCulture)) throw new HarnessException("Materialization violated no-game/no-A-B-C scope");
        RequireAbsent(Path.Combine(fullStage, "executables"), "A/B/C executable directory is forbidden");
        string compileRoot = Path.Combine(fullStage, "preparation", "fresh-compile");
        if (!Directory.Exists(compileRoot) || Directory.GetFiles(compileRoot, "compile-receipt.json", SearchOption.AllDirectories).Length != 5) throw new HarnessException("Exactly five fresh compile receipts are required");
        return Record.Map(
            "schema", "mfo.qa.qualification.qp-only-preseal.v1",
            "stage_path", fullStage,
            "supervisor_commit", supervisorCommit,
            "qa_receipt_commit", qaReceiptCommit,
            "stage_runs_absent", true,
            "external_run_evidence_root", externalRoot,
            "external_run_evidence_root_absent", true,
            "activation_token_absent", true,
            "performance_slot_artifact_absent", true,
            "p95_artifact_absent", true,
            "kbm_artifact_absent", true,
            "old_005_stage_reused", false,
            "old_006_stage_reused", false,
            "old_007_stage_reused", false,
            "old_008_stage_reused", false,
            "game_executable_copy_count", 0,
            "fresh_component_compile_count", 5,
            "identity_only_executable_provenance", new object[0],
            "performance_slot_launch_count", 0);
    }

    private static Dictionary<string, object> VerifyRepositoryState(string stage, string supervisorCommit, string qaReceiptCommit)
    {
        string path = Path.Combine(stage, "preparation", "repository-state-evidence.json");
        if (!File.Exists(path)) throw new HarnessException("Repository-state evidence is missing before seal");
        Dictionary<string, object> state = EvidenceIo.ReadMap(path);
        if (!String.Equals(Record.Text(state, "schema"), "mfo.qa.qualification.repository-state.v1", StringComparison.Ordinal) ||
            !String.Equals(Record.Text(state, "work_order"), WorkOrder, StringComparison.Ordinal) ||
            !String.Equals(Record.Text(state, "stage_id"), Path.GetFileName(stage), StringComparison.Ordinal) ||
            !String.Equals(Record.Text(state, "supervisor_starting_commit"), supervisorCommit, StringComparison.Ordinal) ||
            !String.Equals(Record.Text(state, "required_qa_branch"), RequiredBranch, StringComparison.Ordinal) ||
            !String.Equals(Record.Text(state, "observed_qa_branch"), RequiredBranch, StringComparison.Ordinal) ||
            !String.Equals(Record.Text(state, "qa_receipt_head"), qaReceiptCommit, StringComparison.Ordinal) ||
            !String.Equals(Record.Text(state, "qa_receipt_commit"), qaReceiptCommit, StringComparison.Ordinal) ||
            !String.Equals(Record.Text(state, "qa_receipt_parent"), RequiredSupervisorClarificationCommit, StringComparison.Ordinal) ||
            !String.Equals(Record.Text(state, "origin_qa_ref"), "origin/" + RequiredBranch, StringComparison.Ordinal) ||
            !String.Equals(Record.Text(state, "origin_qa_head"), qaReceiptCommit, StringComparison.Ordinal) ||
            !Convert.ToBoolean(state["supervisor_is_ancestor"], CultureInfo.InvariantCulture) ||
            Record.Integer(state, "status_porcelain_count") != 0 ||
            !Convert.ToBoolean(state["stage_runs_absent"], CultureInfo.InvariantCulture) ||
            !Convert.ToBoolean(state["external_run_evidence_root_absent"], CultureInfo.InvariantCulture) ||
            Record.Integer(state, "performance_slot_launch_count") != 0 ||
            Convert.ToBoolean(state["p95_produced"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(state["kbm_performed"], CultureInfo.InvariantCulture) ||
            Convert.ToBoolean(state["abc_launched"], CultureInfo.InvariantCulture) ||
            !Convert.ToBoolean(state["clean"], CultureInfo.InvariantCulture)) throw new HarnessException("Repository-state evidence does not match the required clean QA branch");
        state["evidence_path"] = path;
        state["evidence_sha256"] = EvidenceIo.Sha256File(path);
        return state;
    }

    private static List<Dictionary<string, object>> ComponentFileIdentities(string stage)
    {
        List<Dictionary<string, object>> files = new List<Dictionary<string, object>>();
        foreach (string name in ComponentSources) files.Add(EvidenceIo.FileIdentity(Path.Combine(stage, "source", name), "source/" + name));
        foreach (string name in ComponentBinaries) files.Add(EvidenceIo.FileIdentity(Path.Combine(stage, "bin", name), "bin/" + name));
        return files;
    }

    private static Dictionary<string, object> PreparationInvocations(string stage, string identityContract)
    {
        string runner = Path.Combine(stage, "bin", "MfoQaRunner.exe");
        string manifest = Path.Combine(stage, "seal", "qualification-manifest.json");
        string dry = Quote(runner) + " " + BaseArgs("QP_DRYRUN", stage, identityContract, Path.Combine(stage, "preparation", "dryrun-qualified"));
        string self = Quote(runner) + " " + BaseArgs("QP_SELFTEST", stage, identityContract, Path.Combine(stage, "preparation", "selftest-qualified"));
        string smoke = Quote(runner) + " " + BaseArgs("QP_POWER_INPUT_SMOKE", stage, identityContract, Path.Combine(stage, "preparation", "power-input-smoke-qualified"));
        string contract = Quote(runner) + " " + BaseArgs("QP_PREACK_CONTRACT_SELFTEST", stage, manifest, Path.Combine(stage, "preparation", "preack-contract-selftest-qualified"));
        string liveEvidenceContract = Quote(runner) + " " + BaseArgs("QP_LIVE_EVIDENCE_CONTRACT_SELFTEST", stage, manifest, Path.Combine(stage, "preparation", "live-evidence-contract-selftest-qualified"));
        return Record.Map(
            "qp_dryrun_runner_exact", dry,
            "qp_dryrun_runner_exact_sha256", EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(dry)),
            "qp_selftest_runner_exact", self,
            "qp_selftest_runner_exact_sha256", EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(self)),
            "qp_power_input_smoke_runner_exact", smoke,
            "qp_power_input_smoke_runner_exact_sha256", EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(smoke)),
            "qp_preack_contract_selftest_runner_exact", contract,
            "qp_preack_contract_selftest_runner_exact_sha256", EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(contract)),
            "qp_live_evidence_contract_selftest_runner_exact", liveEvidenceContract,
            "qp_live_evidence_contract_selftest_runner_exact_sha256", EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(liveEvidenceContract)));
    }

    private static Dictionary<string, object> SourceDiffAudit(string stage, string baselineSourceRoot)
    {
        List<Dictionary<string, object>> sources = new List<Dictionary<string, object>>();
        foreach (string name in ComponentSources)
        {
            string baselinePath = Path.Combine(baselineSourceRoot, name);
            string candidatePath = Path.Combine(stage, "source", name);
            string baselineHash = EvidenceIo.Sha256File(baselinePath);
            string candidateHash = EvidenceIo.Sha256File(candidatePath);
            bool identical = String.Equals(baselineHash, candidateHash, StringComparison.OrdinalIgnoreCase);
            if (String.Equals(name, "MfoQaNative.cs", StringComparison.OrdinalIgnoreCase) && !String.Equals(baselineHash, Frozen008NativeSourceSha256, StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Frozen -008 native baseline SHA-256 mismatch");
            if (!String.Equals(name, "MfoQaNative.cs", StringComparison.OrdinalIgnoreCase) && !identical) throw new HarnessException("Non-native harness source changed outside the authorized -009 correction: " + name);
            sources.Add(Record.Map("source", name, "baseline_path", baselinePath, "baseline_sha256", baselineHash, "candidate_path", candidatePath, "candidate_sha256", candidateHash, "byte_identical", identical));
        }

        string baselineNativePath = Path.Combine(baselineSourceRoot, "MfoQaNative.cs");
        string candidateNativePath = Path.Combine(stage, "source", "MfoQaNative.cs");
        string baseline = File.ReadAllText(baselineNativePath, Encoding.UTF8);
        string candidate = File.ReadAllText(candidateNativePath, Encoding.UTF8);
        if (String.Equals(baseline, candidate, StringComparison.Ordinal)) throw new HarnessException("The -009 LIVE-evidence correction was not present in candidate source");

        string declaration = "        private static extern uint PowerGetEffectiveOverlayScheme(out Guid effectivePowerModeGuid);";
        if (Count(baseline, declaration) != 1 || Count(candidate, declaration) != 1) throw new HarnessException("Direct out Guid declaration changed outside the -009 correction boundary");
        string effectiveStart = "        public static string EffectiveOverlayGuid(out bool success, out uint nativeStatus)";
        string effectiveEnd = "        public static uint ReadLastInput(out bool success, out int nativeError)";
        string baselineEffective = ExtractBetween(baseline, effectiveStart, effectiveEnd);
        string candidateEffective = ExtractBetween(candidate, effectiveStart, effectiveEnd);
        if (!String.Equals(baselineEffective, candidateEffective, StringComparison.Ordinal)) throw new HarnessException("The already-correct direct-Guid production method changed from the -007 baseline");

        string activation = ExtractBetween(candidate, "        public static string RequireExactActivation(", "    public static class SentinelExercise");
        if (activation.IndexOf("MFO-WO-P2-2A-006", StringComparison.Ordinal) >= 0 || activation.IndexOf("MFO-WO-P2-2A-007", StringComparison.Ordinal) >= 0 || activation.IndexOf("MFO-WO-P2-2A-008", StringComparison.Ordinal) >= 0 || activation.IndexOf("receipt_sha256=", StringComparison.Ordinal) < 0 || activation.IndexOf("preparation_audit_sha256=", StringComparison.Ordinal) < 0 || activation.IndexOf("preack_evaluation_sha256=", StringComparison.Ordinal) < 0) throw new HarnessException("Production exact activation validator is not the isolated -009 contract");
        Dictionary<string, object> rawByteActivationBinding = VerifyRawByteActivationSourceBinding(candidate);
        string exactWorkOrderDeclaration = "public const string WorkOrder = " + ((char)34).ToString() + "MFO-WO-P2-2A-009" + ((char)34).ToString();
        if (Count(candidate, exactWorkOrderDeclaration) != 1) throw new HarnessException("Exact -009 production work-order constant is missing or duplicated");
        if (Count(candidate, "BuildPreackPendingObservation(") < 2 || Count(candidate, "PersistCompletePendingObservation(") < 2 || Count(candidate, "EvaluatePersistedPreackObservation(") < 2) throw new HarnessException("Production and contract self-test do not share the complete pending/evaluation functions");
        if (candidate.IndexOf("QP_PREACK_CONTRACT_SELFTEST", StringComparison.Ordinal) < 0 || candidate.IndexOf("QP_LIVE_EVIDENCE_CONTRACT_SELFTEST", StringComparison.Ordinal) < 0 || candidate.IndexOf("preparation-receipt.json", StringComparison.Ordinal) < 0 || candidate.IndexOf("preparation-audit.json", StringComparison.Ordinal) < 0) throw new HarnessException("Mandatory -009 contract self-tests or fixed preparation identities are absent");

        string[] baselineLines = baseline.Replace("\r\n", "\n").Split('\n');
        string[] candidateLines = candidate.Replace("\r\n", "\n").Split('\n');
        string baselineNewline = DetectNewlineStyle(baseline);
        string candidateNewline = DetectNewlineStyle(candidate);
        bool newlineStyleMatch = String.Equals(baselineNewline, candidateNewline, StringComparison.Ordinal);
        bool bomMatch = HasUtf8Bom(baselineNativePath) == HasUtf8Bom(candidateNativePath);
        List<Dictionary<string, object>> classRegionAudit = BuildClassRegionAudit(baselineLines, candidateLines);
        int unauthorizedChangedClassCount = classRegionAudit.Count(delegate(Dictionary<string, object> region) { return Convert.ToBoolean(region["changed"], CultureInfo.InvariantCulture) && !Convert.ToBoolean(region["authorized_change_region"], CultureInfo.InvariantCulture); });
        List<Dictionary<string, object>> changedHunks = BuildChangedLineHunks(baselineLines, candidateLines);
        List<Dictionary<string, object>> unauthorizedHunks = changedHunks.Where(delegate(Dictionary<string, object> h) { return !Convert.ToBoolean(h["authorized"], CultureInfo.InvariantCulture); }).ToList();
        if (changedHunks.Count == 0) throw new HarnessException("The candidate source had no changed hunks");
        if (unauthorizedHunks.Count != 0) throw new HarnessException("Native source contains a changed hunk outside the -009 authorized methods: " + Record.Json(unauthorizedHunks[0]));
        if (!newlineStyleMatch || !bomMatch || unauthorizedChangedClassCount != 0) throw new HarnessException("Native source bytes changed outside the authorized -009 class regions");
        return Record.Map(
            "schema", "mfo.qa.qualification.source-diff-audit.v2",
            "work_order", WorkOrder,
            "baseline_source_root", baselineSourceRoot,
            "candidate_source_root", Path.Combine(stage, "source"),
            "source_identities", sources,
            "non_native_sources_byte_identical", true,
            "native_source_changed", true,
            "baseline_native_line_count", baselineLines.Length,
            "candidate_native_line_count", candidateLines.Length,
            "frozen_008_native_sha256", Frozen008NativeSourceSha256,
            "frozen_008_native_sha256_match", true,
            "authorized_change_set", new string[] { "per-live-sample durable performance_slot_launch_count zero", "sentinel cleanup before settle origin and n0", "runner and launcher LIVE evaluation readback/completeness booleans", "mechanical exact -009 identity rollover", "QP_LIVE_EVIDENCE_CONTRACT_SELFTEST", "raw-byte exact -009 activation and named CR/LF/CRLF extra-byte fixtures" },
            "authorized_change_classes", new string[] { "Contract", "EvidenceJournal", "RoleContext", "HarnessOps", "SentinelExercise", "RunnerRole", "LauncherRole", "ControllerRole" },
            "class_region_audit", classRegionAudit,
            "unauthorized_changed_class_count", unauthorizedChangedClassCount,
            "changed_hunk_count", changedHunks.Count,
            "changed_hunks", changedHunks,
            "unauthorized_changed_hunk_count", unauthorizedHunks.Count,
            "baseline_newline_style", baselineNewline,
            "candidate_newline_style", candidateNewline,
            "newline_style_match", newlineStyleMatch,
            "utf8_bom_match", bomMatch,
            "outside_authorized_regions_byte_identical", unauthorizedChangedClassCount == 0 && newlineStyleMatch && bomMatch,
            "direct_out_guid_declaration_byte_preserved", true,
            "effective_overlay_method_byte_preserved", true,
            "receipt_binding_present", true,
            "preparation_audit_binding_present", true,
            "exact_009_activation_present", true,
            "raw_byte_activation_source_binding", rawByteActivationBinding,
            "raw_byte_exact_009_activation_present", true,
            "production_and_selftest_shared_pending_writer", true,
            "production_and_selftest_shared_evaluator", true,
            "unrelated_non_native_source_change_count", 0,
            "unrelated_harness_logic_change_count", unauthorizedHunks.Count,
            "performance_slot_evidence_change_authorized", true);
    }

    private static List<Dictionary<string, object>> BuildClassRegionAudit(string[] baseline, string[] candidate)
    {
        List<KeyValuePair<string, int>> baselineStarts = SourceClassStarts(baseline);
        List<KeyValuePair<string, int>> candidateStarts = SourceClassStarts(candidate);
        if (baselineStarts.Count != candidateStarts.Count) throw new HarnessException("Top-level source class count changed");
        List<Dictionary<string, object>> audit = new List<Dictionary<string, object>>();
        int baselinePreamble = baselineStarts.Count == 0 ? baseline.Length : baselineStarts[0].Value;
        int candidatePreamble = candidateStarts.Count == 0 ? candidate.Length : candidateStarts[0].Value;
        bool preambleIdentical = baseline.Take(baselinePreamble).SequenceEqual(candidate.Take(candidatePreamble), StringComparer.Ordinal);
        audit.Add(Record.Map("region", "<file-preamble>", "baseline_start_line", 1, "baseline_line_count", baselinePreamble, "candidate_start_line", 1, "candidate_line_count", candidatePreamble, "baseline_sha256", ChangedLinesSha(baseline, 0, baselinePreamble), "candidate_sha256", ChangedLinesSha(candidate, 0, candidatePreamble), "authorized_change_region", false, "changed", !preambleIdentical, "byte_identical", preambleIdentical));
        if (!preambleIdentical) throw new HarnessException("Source file preamble changed outside the -009 boundary");
        for (int i = 0; i < baselineStarts.Count; i++)
        {
            if (!String.Equals(baselineStarts[i].Key, candidateStarts[i].Key, StringComparison.Ordinal)) throw new HarnessException("Top-level source class order/name changed");
            int baselineStart = baselineStarts[i].Value;
            int baselineEnd = i + 1 < baselineStarts.Count ? baselineStarts[i + 1].Value : baseline.Length;
            int candidateStart = candidateStarts[i].Value;
            int candidateEnd = i + 1 < candidateStarts.Count ? candidateStarts[i + 1].Value : candidate.Length;
            bool identical = baseline.Skip(baselineStart).Take(baselineEnd - baselineStart).SequenceEqual(candidate.Skip(candidateStart).Take(candidateEnd - candidateStart), StringComparer.Ordinal);
            bool authorized = IsAuthorizedChangeClass(baselineStarts[i].Key);
            if (!authorized && !identical) throw new HarnessException("Top-level source class changed outside the -009 boundary: " + baselineStarts[i].Key);
            audit.Add(Record.Map(
                "region", baselineStarts[i].Key,
                "baseline_start_line", baselineStart + 1,
                "baseline_line_count", baselineEnd - baselineStart,
                "candidate_start_line", candidateStart + 1,
                "candidate_line_count", candidateEnd - candidateStart,
                "baseline_sha256", ChangedLinesSha(baseline, baselineStart, baselineEnd - baselineStart),
                "candidate_sha256", ChangedLinesSha(candidate, candidateStart, candidateEnd - candidateStart),
                "authorized_change_region", authorized,
                "changed", !identical,
                "byte_identical", identical));
        }
        return audit;
    }

    private static List<KeyValuePair<string, int>> SourceClassStarts(string[] lines)
    {
        List<KeyValuePair<string, int>> starts = new List<KeyValuePair<string, int>>();
        for (int i = 0; i < lines.Length; i++)
        {
            string trimmed = lines[i].Trim();
            if (!(trimmed.StartsWith("public ", StringComparison.Ordinal) || trimmed.StartsWith("internal ", StringComparison.Ordinal) || trimmed.StartsWith("private ", StringComparison.Ordinal))) continue;
            int marker = trimmed.IndexOf(" class ", StringComparison.Ordinal);
            if (marker < 0) continue;
            string tail = trimmed.Substring(marker + " class ".Length);
            int end = tail.IndexOfAny(new char[] { ' ', ':' });
            string name = end < 0 ? tail : tail.Substring(0, end);
            starts.Add(new KeyValuePair<string, int>(name, i));
        }
        return starts;
    }

    private static List<Dictionary<string, object>> BuildChangedLineHunks(string[] baseline, string[] candidate)
    {
        int[,] lcs = new int[baseline.Length + 1, candidate.Length + 1];
        for (int i = baseline.Length - 1; i >= 0; i--)
        {
            for (int j = candidate.Length - 1; j >= 0; j--)
            {
                lcs[i, j] = String.Equals(baseline[i], candidate[j], StringComparison.Ordinal) ? checked(lcs[i + 1, j + 1] + 1) : Math.Max(lcs[i + 1, j], lcs[i, j + 1]);
            }
        }
        List<Dictionary<string, object>> hunks = new List<Dictionary<string, object>>();
        int baselineIndex = 0;
        int candidateIndex = 0;
        while (baselineIndex < baseline.Length || candidateIndex < candidate.Length)
        {
            if (baselineIndex < baseline.Length && candidateIndex < candidate.Length && String.Equals(baseline[baselineIndex], candidate[candidateIndex], StringComparison.Ordinal))
            {
                baselineIndex++;
                candidateIndex++;
                continue;
            }
            int baselineStart = baselineIndex;
            int candidateStart = candidateIndex;
            while (baselineIndex < baseline.Length || candidateIndex < candidate.Length)
            {
                if (baselineIndex < baseline.Length && candidateIndex < candidate.Length && String.Equals(baseline[baselineIndex], candidate[candidateIndex], StringComparison.Ordinal)) break;
                if (candidateIndex >= candidate.Length || (baselineIndex < baseline.Length && lcs[baselineIndex + 1, candidateIndex] >= lcs[baselineIndex, candidateIndex + 1])) baselineIndex++;
                else candidateIndex++;
            }
            int baselineCount = baselineIndex - baselineStart;
            int candidateCount = candidateIndex - candidateStart;
            string baselineClass = SourceClassAt(baseline, baselineCount == 0 ? Math.Max(0, baselineStart - 1) : baselineStart);
            string candidateClass = SourceClassAt(candidate, candidateCount == 0 ? Math.Max(0, candidateStart - 1) : candidateStart);
            string baselineMethod = SourceMethodAt(baseline, baselineCount == 0 ? Math.Max(0, baselineStart - 1) : baselineStart);
            string candidateMethod = SourceMethodAt(candidate, candidateCount == 0 ? Math.Max(0, candidateStart - 1) : candidateStart);
            bool baselineAuthorized = baselineCount == 0 || IsAuthorizedChangeMethod(baselineClass, baselineMethod);
            bool candidateAuthorized = candidateCount == 0 || IsAuthorizedChangeMethod(candidateClass, candidateMethod);
            bool authorized = baselineAuthorized && candidateAuthorized;
            hunks.Add(Record.Map(
                "ordinal", hunks.Count + 1,
                "baseline_start_line", baselineStart + 1,
                "baseline_line_count", baselineCount,
                "baseline_region_class", baselineClass,
                "baseline_region_method", baselineMethod,
                "baseline_changed_lines_sha256", ChangedLinesSha(baseline, baselineStart, baselineCount),
                "candidate_start_line", candidateStart + 1,
                "candidate_line_count", candidateCount,
                "candidate_region_class", candidateClass,
                "candidate_region_method", candidateMethod,
                "candidate_changed_lines_sha256", ChangedLinesSha(candidate, candidateStart, candidateCount),
                "authorization_boundary", "exact approved class and method name",
                "authorized", authorized));
        }
        return hunks;
    }

    private static string SourceClassAt(string[] lines, int lineIndex)
    {
        string current = "<file-scope>";
        int limit = Math.Min(Math.Max(lineIndex, 0), lines.Length - 1);
        for (int i = 0; i <= limit; i++)
        {
            string trimmed = lines[i].Trim();
            if (!(trimmed.StartsWith("public ", StringComparison.Ordinal) || trimmed.StartsWith("internal ", StringComparison.Ordinal) || trimmed.StartsWith("private ", StringComparison.Ordinal))) continue;
            int marker = trimmed.IndexOf(" class ", StringComparison.Ordinal);
            if (marker < 0) continue;
            string tail = trimmed.Substring(marker + " class ".Length);
            int end = tail.IndexOfAny(new char[] { ' ', ':' });
            current = end < 0 ? tail : tail.Substring(0, end);
        }
        return current;
    }

    private static string SourceMethodAt(string[] lines, int lineIndex)
    {
        string className = SourceClassAt(lines, lineIndex);
        int limit = Math.Min(Math.Max(lineIndex, 0), lines.Length - 1);
        for (int i = limit; i >= 0; i--)
        {
            string trimmed = lines[i].Trim();
            if (trimmed.IndexOf(" class " + className, StringComparison.Ordinal) >= 0) break;
            int open = trimmed.IndexOf('(');
            if (open <= 0) continue;
            if (!(trimmed.StartsWith("public ", StringComparison.Ordinal) || trimmed.StartsWith("private ", StringComparison.Ordinal) || trimmed.StartsWith("internal ", StringComparison.Ordinal))) continue;
            string before = trimmed.Substring(0, open).TrimEnd();
            int space = before.LastIndexOf(' ');
            return space < 0 ? before : before.Substring(space + 1);
        }
        return "<class-scope>";
    }

    private static bool IsAuthorizedChangeClass(string name)
    {
        return String.Equals(name, "Contract", StringComparison.Ordinal) ||
            String.Equals(name, "EvidenceJournal", StringComparison.Ordinal) ||
            String.Equals(name, "RoleContext", StringComparison.Ordinal) ||
            String.Equals(name, "HarnessOps", StringComparison.Ordinal) ||
            String.Equals(name, "SentinelExercise", StringComparison.Ordinal) ||
            String.Equals(name, "RunnerRole", StringComparison.Ordinal) ||
            String.Equals(name, "LauncherRole", StringComparison.Ordinal) ||
            String.Equals(name, "ControllerRole", StringComparison.Ordinal);
    }

    private static bool IsAuthorizedChangeMethod(string className, string methodName)
    {
        if (!IsAuthorizedChangeClass(className)) return false;
        if (String.Equals(className, "Contract", StringComparison.Ordinal)) return String.Equals(methodName, "<class-scope>", StringComparison.Ordinal);
        if (String.Equals(className, "EvidenceJournal", StringComparison.Ordinal)) return String.Equals(methodName, "ReadRecordByDigest", StringComparison.Ordinal);
        if (String.Equals(className, "RoleContext", StringComparison.Ordinal)) return String.Equals(methodName, "Create", StringComparison.Ordinal);
        if (String.Equals(className, "SentinelExercise", StringComparison.Ordinal)) return String.Equals(methodName, "Run", StringComparison.Ordinal);
        if (String.Equals(className, "HarnessOps", StringComparison.Ordinal) && String.Equals(methodName, "RequireExactActivation", StringComparison.Ordinal)) return true;
        string[] allowed = new string[]
        {
            "<class-scope>", "ValidateRolePaths", "CaptureRawFile", "PersistCompleteObservation", "PersistObservationReadback", "HasCompleteObservationFieldSet",
            "HasCompleteLiveActivationPendingFieldSet", "HasCompleteLauncherLivePendingFieldSet", "PersistCompleteActivationObservation",
            "EvaluatePersistedActivationObservation", "PersistCompleteLauncherLiveObservation", "EvaluatePersistedLauncherLiveObservation",
            "BuildLiveSample", "PersistAndValidateLiveSample", "Run", "RunPowerInputSmoke", "RunLiveEvidenceContractSelfTest", "RunLiveSampleSlotNegativeFixture",
            "VerifySentinelSampleOrder", "RunLiveEvaluationCompletenessFixtures", "RequireLiveEvaluationCompleteness",
            "AuditLiveEvidenceContractBinding", "RunLauncherLiveContractFixture", "RunActivationFixtures", "AuditPreackContractBinding", "AuditRuntimeSource", "RunChild", "RunLive", "SelfTest", "Live", "CaptureLiveSample"
        };
        return allowed.Contains(methodName, StringComparer.Ordinal);
    }

    private static string ChangedLinesSha(string[] lines, int start, int count)
    {
        if (count == 0) return EvidenceIo.Sha256Bytes(new byte[0]);
        return EvidenceIo.Sha256Bytes(EvidenceIo.Utf8(String.Join("\n", lines.Skip(start).Take(count).ToArray())));
    }

    private static string DetectNewlineStyle(string text)
    {
        int crlf = Count(text, "\r\n");
        int lf = Count(text, "\n") - crlf;
        int cr = Count(text, "\r") - crlf;
        if (crlf > 0 && lf == 0 && cr == 0) return "CRLF";
        if (lf > 0 && crlf == 0 && cr == 0) return "LF";
        if (cr > 0 && crlf == 0 && lf == 0) return "CR";
        return "MIXED_OR_NONE";
    }

    private static bool HasUtf8Bom(string path)
    {
        byte[] bytes = File.ReadAllBytes(path);
        return bytes.Length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF;
    }

    private static string ReplaceExactOnce(string text, string oldValue, string newValue)
    {
        int first = text.IndexOf(oldValue, StringComparison.Ordinal);
        if (first < 0 || text.IndexOf(oldValue, first + oldValue.Length, StringComparison.Ordinal) >= 0) throw new HarnessException("Expected exact source fragment count was not one");
        return text.Substring(0, first) + newValue + text.Substring(first + oldValue.Length);
    }

    private static string ExtractBetween(string text, string startMarker, string endMarker)
    {
        int start = text.IndexOf(startMarker, StringComparison.Ordinal);
        if (start < 0) throw new HarnessException("Source audit start marker missing: " + startMarker);
        int end = text.IndexOf(endMarker, start + startMarker.Length, StringComparison.Ordinal);
        if (end <= start) throw new HarnessException("Source audit end marker missing: " + endMarker);
        return text.Substring(start, end - start);
    }

    private static string ExtractLastBetween(string text, string startMarker, string endMarker)
    {
        int start = text.LastIndexOf(startMarker, StringComparison.Ordinal);
        if (start < 0) throw new HarnessException("Source audit final start marker missing: " + startMarker);
        int end = text.IndexOf(endMarker, start + startMarker.Length, StringComparison.Ordinal);
        if (end <= start) throw new HarnessException("Source audit final end marker missing: " + endMarker);
        return text.Substring(start, end - start);
    }

    private static Dictionary<string, object> VerifySmokeBinding(string stage, string identityContract, string smokeResult, Dictionary<string, object> preparationInvocations)
    {
        Dictionary<string, object> result = EvidenceIo.ReadMap(smokeResult);
        Dictionary<string, object> details = Record.AsMap(result["details"]);
        if (!Convert.ToBoolean(details["guid_parse_roundtrip"], CultureInfo.InvariantCulture) || !Convert.ToBoolean(details["uint32_roundtrip"], CultureInfo.InvariantCulture)) throw new HarnessException("Smoke round-trip evidence was not true");
        Dictionary<string, object> host = Record.AsMap(details["host_record"]);
        string[] hostFields = new string[] { "power_api_success", "ac_line_status", "overlay_api_success", "overlay_native_status", "effective_overlay_guid", "last_input_api_success", "last_input_native_error", "last_input_dwtime_uint32" };
        foreach (string field in hostFields) Record.Text(host, field);
        if (!Convert.ToBoolean(host["power_api_success"], CultureInfo.InvariantCulture) || !Convert.ToBoolean(host["overlay_api_success"], CultureInfo.InvariantCulture) || !Convert.ToBoolean(host["last_input_api_success"], CultureInfo.InvariantCulture)) throw new HarnessException("Smoke native API result was not successful");
        Guid parsed = Guid.Parse(Record.Text(host, "effective_overlay_guid"));
        uint input = UInt32.Parse(Record.Text(host, "last_input_dwtime_uint32"), CultureInfo.InvariantCulture);
        if (!String.Equals(parsed.ToString().ToLowerInvariant(), Record.Text(host, "effective_overlay_guid").ToLowerInvariant(), StringComparison.Ordinal) || !String.Equals(input.ToString(CultureInfo.InvariantCulture), Record.Text(host, "last_input_dwtime_uint32"), StringComparison.Ordinal)) throw new HarnessException("Smoke field round-trip revalidation failed");
        string recordPath = Record.Text(details, "power_input_record");
        if (!String.Equals(EvidenceIo.Sha256File(recordPath), Record.Text(details, "power_input_record_sha256"), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Smoke record identity mismatch");
        Dictionary<string, object> binding = Record.AsMap(details["binding"]);
        if (Record.Integer(binding, "production_power_and_input_call_count") != 1) throw new HarnessException("Smoke production-call count was not one");
        string expectedInvocation = Record.Text(preparationInvocations, "qp_power_input_smoke_runner_exact");
        string expectedInvocationSha = Record.Text(preparationInvocations, "qp_power_input_smoke_runner_exact_sha256");
        if (!String.Equals(Record.Text(binding, "exact_invocation"), expectedInvocation, StringComparison.Ordinal) || !String.Equals(Record.Text(binding, "exact_invocation_sha256"), expectedInvocationSha, StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Smoke invocation binding mismatch");
        if (!String.Equals(Record.Text(binding, "identity_document_sha256"), EvidenceIo.Sha256File(identityContract), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Smoke identity-contract binding mismatch");
        Dictionary<string, object> source = Record.AsMap(binding["source"]);
        Dictionary<string, object> native = Record.AsMap(binding["native_helper"]);
        Dictionary<string, object> runner = Record.AsMap(binding["invoking_role"]);
        if (!String.Equals(Record.Text(source, "sha256"), EvidenceIo.Sha256File(Path.Combine(stage, "source", "MfoQaNative.cs")), StringComparison.OrdinalIgnoreCase) ||
            !String.Equals(Record.Text(native, "sha256"), EvidenceIo.Sha256File(Path.Combine(stage, "bin", "MfoQaNative.dll")), StringComparison.OrdinalIgnoreCase) ||
            !String.Equals(Record.Text(runner, "sha256"), EvidenceIo.Sha256File(Path.Combine(stage, "bin", "MfoQaRunner.exe")), StringComparison.OrdinalIgnoreCase)) throw new HarnessException("Smoke source/component binding mismatch");
        return Record.Map("validated", true, "binding", binding, "power_input_record", recordPath, "power_input_record_sha256", EvidenceIo.Sha256File(recordPath), "host_fields", hostFields, "guid_parse_roundtrip", true, "uint32_roundtrip", true);
    }

    private static Dictionary<string, object> VerifyPreparationRawStreams(string stage)
    {
        string prep = Path.Combine(stage, "preparation");
        string[] paths = new string[]
        {
            Path.Combine(prep, "dryrun-qualified", "runner.stdout.raw"),
            Path.Combine(prep, "dryrun-qualified", "runner.stderr.raw"),
            Path.Combine(prep, "selftest-qualified", "runner.stdout.raw"),
            Path.Combine(prep, "selftest-qualified", "runner.stderr.raw"),
            Path.Combine(prep, "selftest-qualified", "launcher", "launcher.stdout.raw"),
            Path.Combine(prep, "selftest-qualified", "launcher", "launcher.stderr.raw"),
            Path.Combine(prep, "selftest-qualified", "launcher", "controller", "controller.stdout.raw"),
            Path.Combine(prep, "selftest-qualified", "launcher", "controller", "controller.stderr.raw"),
            Path.Combine(prep, "selftest-qualified", "launcher", "controller", "sentinel-selftest.stdout.raw"),
            Path.Combine(prep, "selftest-qualified", "launcher", "controller", "sentinel-selftest.stderr.raw"),
            Path.Combine(prep, "power-input-smoke-qualified", "runner.stdout.raw"),
            Path.Combine(prep, "power-input-smoke-qualified", "runner.stderr.raw"),
            Path.Combine(prep, "preack-contract-selftest-qualified", "runner.stdout.raw"),
            Path.Combine(prep, "preack-contract-selftest-qualified", "runner.stderr.raw"),
            Path.Combine(prep, "live-evidence-contract-selftest-qualified", "runner.stdout.raw"),
            Path.Combine(prep, "live-evidence-contract-selftest-qualified", "runner.stderr.raw"),
            Path.Combine(prep, "live-evidence-contract-selftest-qualified", "sentinel-live-evidence-contract-selftest.stdout.raw"),
            Path.Combine(prep, "live-evidence-contract-selftest-qualified", "sentinel-live-evidence-contract-selftest.stderr.raw")
        };
        List<Dictionary<string, object>> files = new List<Dictionary<string, object>>();
        foreach (string path in paths)
        {
            if (!File.Exists(path)) throw new HarnessException("Required preparation raw stream missing: " + path);
            files.Add(EvidenceIo.FileIdentity(path, Relative(stage, path)));
        }
        return Record.Map("required_count", paths.Length, "verified_count", files.Count, "all_present", true, "files", files);
    }

    private static Dictionary<string, object> VerifyRawByteActivationSourceBinding(string source)
    {
        string validator = ExtractBetween(source,
            "        public static string RequireExactActivation(",
            "    public static class SentinelExercise");
        string activationFixtures = ExtractBetween(source,
            "        private static List<Dictionary<string, object>> RunActivationFixtures(",
            "        private static Dictionary<string, object> AuditPreackContractBinding(");
        string completenessFixtures = ExtractBetween(source,
            "        private static Dictionary<string, object> RunLiveEvaluationCompletenessFixtures(",
            "        private static Dictionary<string, object> AuditLiveEvidenceContractBinding(");
        string launcherFixture = ExtractBetween(source,
            "        private static Dictionary<string, object> RunLauncherLiveContractFixture(",
            "        private static List<Dictionary<string, object>> RunActivationFixtures(");
        string runnerEvaluator = ExtractBetween(source,
            "        public static Dictionary<string, object> EvaluatePersistedActivationObservation(",
            "        public static Dictionary<string, object> BuildLauncherLivePendingObservation(");
        string launcherEvaluator = ExtractBetween(source,
            "        public static Dictionary<string, object> EvaluatePersistedLauncherLiveObservation(",
            "        private static Dictionary<string, object> SuccessfulRawCapture(");

        string[] forbiddenValidatorTokens = new string[]
        {
            "Encoding.UTF8.GetString(", "Encoding.UTF8.GetBytes(", "ReadAllText(",
            "StreamReader", ".Trim", ".Replace(", ".Normalize(", "Regex.",
            "Char.IsWhiteSpace", "StringSplitOptions", ".Split(", "String.Join(",
            "Environment.NewLine", "String.Equals("
        };
        List<string> forbiddenHits = new List<string>();
        foreach (string token in forbiddenValidatorTokens)
            if (validator.IndexOf(token, StringComparison.Ordinal) >= 0) forbiddenHits.Add(token);

        int rawReadCount = Count(validator, "byte[] bytes = File.ReadAllBytes(Path.GetFullPath(activationPath));");
        int expectedUtf8Count = Count(validator, "byte[] expectedBytes = EvidenceIo.Utf8(expected);");
        int rawCompareCount = Count(validator, "if (!EvidenceIo.ByteEqual(bytes, expectedBytes))");
        int rawDigestCount = Count(validator, "return EvidenceIo.Sha256Bytes(bytes);");
        int bomlessUtf8HelperCount = Count(source, "public static byte[] Utf8(string text) { return new UTF8Encoding(false).GetBytes(text); }");
        if (forbiddenHits.Count != 0 || rawReadCount != 1 || expectedUtf8Count != 1 ||
            rawCompareCount != 1 || rawDigestCount != 1 || bomlessUtf8HelperCount != 1)
            throw new HarnessException("Production activation validator is not raw-byte exact: " + String.Join(",", forbiddenHits.ToArray()));

        string quote = ((char)34).ToString();
        string slash = ((char)92).ToString();
        int exactFixtureCount = Count(activationFixtures, "fixtures.Add(new KeyValuePair<string, string>(" + quote + "exact" + quote + ", exact));");
        int extraCrFixtureCount = Count(activationFixtures, "fixtures.Add(new KeyValuePair<string, string>(" + quote + "extra_cr" + quote + ", exact + " + quote + slash + "r" + quote + "));");
        int extraLfFixtureCount = Count(activationFixtures, "fixtures.Add(new KeyValuePair<string, string>(" + quote + "extra_lf" + quote + ", exact + " + quote + slash + "n" + quote + "));");
        int extraCrlfFixtureCount = Count(activationFixtures, "fixtures.Add(new KeyValuePair<string, string>(" + quote + "extra_crlf" + quote + ", exact + " + quote + slash + "r" + slash + "n" + quote + "));");
        int activationFixtureWriteCount = Count(activationFixtures, "EvidenceIo.WriteNewBytes(path, EvidenceIo.Utf8(fixtures[i].Value));");
        bool fixtureBytesPass = exactFixtureCount == 1 && extraCrFixtureCount == 1 && extraLfFixtureCount == 1 &&
            extraCrlfFixtureCount == 1 && activationFixtureWriteCount == 1 &&
            Count(activationFixtures, "fixtures[i].Value +") == 0 &&
            Count(completenessFixtures, "EvidenceIo.WriteNewBytes(activationPath, EvidenceIo.Utf8(activation));") == 1 &&
            Count(launcherFixture, "EvidenceIo.WriteNewBytes(activationPath, EvidenceIo.Utf8(activation));") == 1;
        if (!fixtureBytesPass) throw new HarnessException("Activation positive or named CR/LF/CRLF fixture byte contract mismatch");

        bool sameProductionValidatorBinding =
            Count(activationFixtures, "HarnessOps.EvaluatePersistedActivationObservation(") == 1 &&
            Count(completenessFixtures, "HarnessOps.EvaluatePersistedActivationObservation(") == 2 &&
            Count(completenessFixtures, "HarnessOps.EvaluatePersistedLauncherLiveObservation(") == 2 &&
            Count(launcherFixture, "HarnessOps.EvaluatePersistedLauncherLiveObservation(") == 1 &&
            Count(runnerEvaluator, "RequireExactActivation(") == 1 &&
            Count(launcherEvaluator, "RequireExactActivation(") == 1;
        if (!sameProductionValidatorBinding) throw new HarnessException("Activation fixtures are not bound to the production validator");

        return Record.Map(
            "production_validator", "HarnessOps.RequireExactActivation",
            "raw_file_read_count", rawReadCount,
            "expected_bomless_utf8_count", expectedUtf8Count,
            "raw_byte_compare_count", rawCompareCount,
            "raw_digest_count", rawDigestCount,
            "decode_or_normalization_reference_count", forbiddenHits.Count,
            "exact_positive_no_terminator", true,
            "extra_cr_fixture_count", extraCrFixtureCount,
            "extra_lf_fixture_count", extraLfFixtureCount,
            "extra_crlf_fixture_count", extraCrlfFixtureCount,
            "same_production_validator_binding", true);
    }

    private static List<Dictionary<string, object>> SourceAudit(string stage)
    {
        string[] forbidden = new string[]
        {
            "Environment" + "." + "TickCount64",
            "Stop" + "watch",
            "WaitFor" + "Exit",
            "power" + "cfg"
        };
        List<Dictionary<string, object>> result = new List<Dictionary<string, object>>();
        foreach (string name in ComponentSources)
        {
            string text = File.ReadAllText(Path.Combine(stage, "source", name), Encoding.UTF8);
            List<string> hits = new List<string>();
            foreach (string term in forbidden) if (text.IndexOf(term, StringComparison.OrdinalIgnoreCase) >= 0) hits.Add(term);
            if (hits.Count != 0) throw new HarnessException("Forbidden outcome source in " + name + ": " + String.Join(",", hits.ToArray()));
            Dictionary<string, object> audit = Record.Map("source", name, "forbidden_reference_count", 0, "native_get_tick_count_64_reference_count", Count(text, "GetTickCount64"));
            if (String.Equals(name, "MfoQaNative.cs", StringComparison.OrdinalIgnoreCase))
            {
                string effectiveStart = "        public static string EffectiveOverlayGuid(out bool success, out uint nativeStatus)";
                string effectiveEnd = "        public static uint ReadLastInput(out bool success, out int nativeError)";
                int start = text.IndexOf(effectiveStart, StringComparison.Ordinal);
                int end = text.IndexOf(effectiveEnd, start + effectiveStart.Length, StringComparison.Ordinal);
                if (start < 0 || end <= start) throw new HarnessException("Effective-overlay source audit boundary missing");
                string effectivePath = text.Substring(start, end - start);
                audit["effective_overlay_out_guid_declaration_count"] = Count(text, "PowerGetEffectiveOverlayScheme(out Guid effectivePowerModeGuid)");
                audit["effective_overlay_out_intptr_count"] = Count(text, "PowerGetEffectiveOverlayScheme(out IntPtr");
                audit["effective_overlay_path_ptr_to_structure_count"] = Count(effectivePath, "PtrToStructure");
                audit["effective_overlay_path_local_free_count"] = Count(effectivePath, "LocalFree");
                audit["whole_source_local_free_count"] = Count(text, "LocalFree");
                audit["whole_source_ptr_to_structure_count"] = Count(text, "PtrToStructure");
                audit["power_get_active_scheme_reference_count"] = Count(text, "PowerGetActiveScheme");
                audit["smoke_production_path_call_count"] = Count(text, "HarnessOps.ReadPowerAndInputAndPersist(c.Journal, \"qp_power_input_smoke\")");
                string activationPath = ExtractBetween(text, "        public static string RequireExactActivation(", "    public static class SentinelExercise");
                Dictionary<string, object> rawByteActivationBinding = VerifyRawByteActivationSourceBinding(text);
                audit["raw_byte_activation_source_binding"] = rawByteActivationBinding;
                string startRolePath = ExtractBetween(text, "        public static OwnedChild StartRole(", "        public static Dictionary<string, object> ReadPowerAndInputAndPersist(");
                string preackPath = ExtractLastBetween(text, "        private static Dictionary<string, object> Preack(RoleContext c, string identity)", "        private static void ValidateLiveInputs(");
                string launcherLivePath = ExtractLastBetween(text, "        private static void PrepareLauncherLiveContract(RoleContext c, string identity)", "        private static void AppendLauncherStartFailureClosure(");
                int buildIndex = preackPath.IndexOf("HarnessOps.BuildPreackPendingObservation(", StringComparison.Ordinal);
                int persistIndex = preackPath.IndexOf("HarnessOps.PersistCompletePendingObservation(", StringComparison.Ordinal);
                int evaluateIndex = preackPath.IndexOf("HarnessOps.EvaluatePersistedPreackObservation(", StringComparison.Ordinal);
                int launcherLiveBuildIndex = launcherLivePath.IndexOf("HarnessOps.BuildLauncherLivePendingObservation(", StringComparison.Ordinal);
                int launcherLivePersistIndex = launcherLivePath.IndexOf("HarnessOps.PersistCompleteLauncherLiveObservation(", StringComparison.Ordinal);
                int launcherLiveEvaluateIndex = launcherLivePath.IndexOf("HarnessOps.EvaluatePersistedLauncherLiveObservation(", StringComparison.Ordinal);
                int launcherLiveAssertIndex = launcherLivePath.IndexOf("if (code != Contract.Pass)", StringComparison.Ordinal);
                int launcherClassIndex = text.LastIndexOf("    public static class LauncherRole", StringComparison.Ordinal);
                int launcherPrepareIndex = text.LastIndexOf("        private static void PrepareLauncherLiveContract(RoleContext c, string identity)", StringComparison.Ordinal);
                if (launcherClassIndex < 0 || launcherPrepareIndex <= launcherClassIndex) throw new HarnessException("Launcher LIVE dispatch static source boundary missing");
                string launcherDispatchPath = text.Substring(launcherClassIndex, launcherPrepareIndex - launcherClassIndex);
                int launcherDispatchIndex = launcherDispatchPath.IndexOf("if (c.Mode == \"LIVE\") PrepareLauncherLiveContract(c, identity);", StringComparison.Ordinal);
                int launcherIdentityAssertIndex = launcherDispatchPath.IndexOf("HarnessOps.VerifyIdentityDocument(identity, c.Stage);", StringComparison.Ordinal);
                int launcherInputAssertIndex = launcherDispatchPath.IndexOf("ValidateLiveInputs(c, identity, extra);", StringComparison.Ordinal);
                int launcherFileAssertIndex = launcherDispatchPath.IndexOf("HarnessOps.FileSetAudit(identity, c.Stage)", StringComparison.Ordinal);
                int launcherControllerStartIndex = launcherDispatchPath.IndexOf("HarnessOps.StartRole(HarnessOps.Bin(c.Stage, \"MfoQaController.exe\")", StringComparison.Ordinal);
                int startRoleKeyCopyIndex = startRolePath.IndexOf("List<string> keys = new List<string>(extraArgs.Keys);", StringComparison.Ordinal);
                int startRoleSortIndex = startRolePath.IndexOf("keys.Sort(StringComparer.Ordinal);", StringComparison.Ordinal);
                int startRoleAppendIndex = startRolePath.IndexOf("foreach (string key in keys) args.Append(\" --\").Append(key).Append(\" \").Append(Quote(extraArgs[key]));", StringComparison.Ordinal);
                string workOrderDeclaration = "public const string WorkOrder = " + ((char)34).ToString() + "MFO-WO-P2-2A-009" + ((char)34).ToString();
                audit["work_order_009_constant_count"] = Count(text, workOrderDeclaration);
                audit["preack_pending_schema_constant_count"] = Count(text, "public const string PreackPendingSchema = \"mfo.qa.preack.pending.v2\"");
                audit["preack_evaluation_schema_constant_count"] = Count(text, "public const string PreackEvaluationSchema = \"mfo.qa.preack.evaluation.v2\"");
                audit["activation_pending_schema_constant_count"] = Count(text, "public const string ActivationPendingSchema = \"mfo.qa.live.activation.pending.v1\"");
                audit["activation_evaluation_schema_constant_count"] = Count(text, "public const string ActivationEvaluationSchema = \"mfo.qa.live.activation.evaluation.v1\"");
                audit["production_activation_uses_work_order_constant"] = activationPath.IndexOf("Contract.WorkOrder + \" START_ACK", StringComparison.Ordinal) >= 0;
                audit["production_activation_old_006_literal_count"] = Count(activationPath, "MFO-WO-P2-2A-006");
                audit["production_activation_old_007_literal_count"] = Count(activationPath, "MFO-WO-P2-2A-007");
                audit["production_activation_old_008_literal_count"] = Count(activationPath, "MFO-WO-P2-2A-008");
                audit["production_activation_receipt_field_count"] = Count(activationPath, " receipt_sha256=");
                audit["production_activation_preparation_audit_field_count"] = Count(activationPath, " preparation_audit_sha256=");
                audit["production_activation_preack_evaluation_field_count"] = Count(activationPath, " preack_evaluation_sha256=");
                audit["production_preack_build_before_persist_before_evaluate"] = buildIndex >= 0 && persistIndex > buildIndex && evaluateIndex > persistIndex;
                audit["launcher_live_build_before_persist_before_evaluate_before_assert"] = launcherLiveBuildIndex >= 0 && launcherLivePersistIndex > launcherLiveBuildIndex && launcherLiveEvaluateIndex > launcherLivePersistIndex && launcherLiveAssertIndex > launcherLiveEvaluateIndex;
                audit["launcher_live_persistence_before_identity_input_file_assertions_and_controller"] = launcherDispatchIndex >= 0 && launcherIdentityAssertIndex > launcherDispatchIndex && launcherInputAssertIndex > launcherIdentityAssertIndex && launcherFileAssertIndex > launcherInputAssertIndex && launcherControllerStartIndex > launcherFileAssertIndex;
                audit["launcher_live_pending_builder_reference_count"] = Count(text, "BuildLauncherLivePendingObservation(");
                audit["launcher_live_persistence_reference_count"] = Count(text, "PersistCompleteLauncherLiveObservation(");
                audit["launcher_live_evaluator_reference_count"] = Count(text, "EvaluatePersistedLauncherLiveObservation(");
                audit["launcher_live_contract_entry_reference_count"] = Count(text, "PrepareLauncherLiveContract(");
                audit["launcher_live_fixed_pending_path_count"] = Count(launcherLivePath, "Path.Combine(c.Output, \"launcher-live-pending.json\")");
                audit["launcher_live_fixed_evaluation_path_count"] = Count(launcherLivePath, "Path.Combine(c.Output, \"launcher-live-evaluation.json\")");
                audit["start_role_extra_keys_ordinal_sorted_then_all_values_quoted"] = startRoleKeyCopyIndex >= 0 && startRoleSortIndex > startRoleKeyCopyIndex && startRoleAppendIndex > startRoleSortIndex;
                audit["start_role_extra_value_quote_call_count"] = Count(startRolePath, "Quote(extraArgs[key])");
                audit["shared_pending_builder_reference_count"] = Count(text, "BuildPreackPendingObservation(");
                audit["shared_pending_persistence_reference_count"] = Count(text, "PersistCompletePendingObservation(");
                audit["shared_pending_evaluator_reference_count"] = Count(text, "EvaluatePersistedPreackObservation(");
                audit["contract_selftest_mode_reference_count"] = Count(text, "QP_PREACK_CONTRACT_SELFTEST");
                audit["live_evidence_contract_selftest_mode_reference_count"] = Count(text, "QP_LIVE_EVIDENCE_CONTRACT_SELFTEST");
                audit["live_sample_builder_reference_count"] = Count(text, "BuildLiveSample(");
                audit["live_sample_persistence_reference_count"] = Count(text, "PersistAndValidateLiveSample(");
                audit["live_pending_completeness_field_reference_count"] = Count(text, "pending_field_completeness_success");
                audit["precleanup_exit_callback_reference_count"] = Count(text, "delegate(ulong exitObservedTick)");
                audit["settle_origin_after_sentinel_exit_reference_count"] = Count(text, "settle_origin_after_sentinel_exit");
                if (Convert.ToInt32(audit["effective_overlay_out_guid_declaration_count"], CultureInfo.InvariantCulture) != 1 ||
                    Convert.ToInt32(audit["effective_overlay_out_intptr_count"], CultureInfo.InvariantCulture) != 0 ||
                    Convert.ToInt32(audit["effective_overlay_path_ptr_to_structure_count"], CultureInfo.InvariantCulture) != 0 ||
                    Convert.ToInt32(audit["effective_overlay_path_local_free_count"], CultureInfo.InvariantCulture) != 0 ||
                    Convert.ToInt32(audit["whole_source_local_free_count"], CultureInfo.InvariantCulture) != 0 ||
                    Convert.ToInt32(audit["power_get_active_scheme_reference_count"], CultureInfo.InvariantCulture) != 0 ||
                    Convert.ToInt32(audit["smoke_production_path_call_count"], CultureInfo.InvariantCulture) != 1 ||
                    Convert.ToInt32(audit["work_order_009_constant_count"], CultureInfo.InvariantCulture) != 1 ||
                    Convert.ToInt32(audit["preack_pending_schema_constant_count"], CultureInfo.InvariantCulture) != 1 ||
                    Convert.ToInt32(audit["preack_evaluation_schema_constant_count"], CultureInfo.InvariantCulture) != 1 ||
                    Convert.ToInt32(audit["activation_pending_schema_constant_count"], CultureInfo.InvariantCulture) != 1 ||
                    Convert.ToInt32(audit["activation_evaluation_schema_constant_count"], CultureInfo.InvariantCulture) != 1 ||
                    !Convert.ToBoolean(audit["production_activation_uses_work_order_constant"], CultureInfo.InvariantCulture) ||
                    Convert.ToInt32(audit["production_activation_old_006_literal_count"], CultureInfo.InvariantCulture) != 0 ||
                    Convert.ToInt32(audit["production_activation_old_007_literal_count"], CultureInfo.InvariantCulture) != 0 ||
                    Convert.ToInt32(audit["production_activation_old_008_literal_count"], CultureInfo.InvariantCulture) != 0 ||
                    Convert.ToInt32(audit["production_activation_receipt_field_count"], CultureInfo.InvariantCulture) != 1 ||
                    Convert.ToInt32(audit["production_activation_preparation_audit_field_count"], CultureInfo.InvariantCulture) != 1 ||
                    Convert.ToInt32(audit["production_activation_preack_evaluation_field_count"], CultureInfo.InvariantCulture) != 1 ||
                    !Convert.ToBoolean(audit["production_preack_build_before_persist_before_evaluate"], CultureInfo.InvariantCulture) ||
                    !Convert.ToBoolean(audit["launcher_live_build_before_persist_before_evaluate_before_assert"], CultureInfo.InvariantCulture) ||
                    !Convert.ToBoolean(audit["launcher_live_persistence_before_identity_input_file_assertions_and_controller"], CultureInfo.InvariantCulture) ||
                    Convert.ToInt32(audit["launcher_live_pending_builder_reference_count"], CultureInfo.InvariantCulture) < 3 ||
                    Convert.ToInt32(audit["launcher_live_persistence_reference_count"], CultureInfo.InvariantCulture) < 3 ||
                    Convert.ToInt32(audit["launcher_live_evaluator_reference_count"], CultureInfo.InvariantCulture) < 3 ||
                    Convert.ToInt32(audit["launcher_live_contract_entry_reference_count"], CultureInfo.InvariantCulture) < 3 ||
                    Convert.ToInt32(audit["launcher_live_fixed_pending_path_count"], CultureInfo.InvariantCulture) != 1 ||
                    Convert.ToInt32(audit["launcher_live_fixed_evaluation_path_count"], CultureInfo.InvariantCulture) != 1 ||
                    !Convert.ToBoolean(audit["start_role_extra_keys_ordinal_sorted_then_all_values_quoted"], CultureInfo.InvariantCulture) ||
                    Convert.ToInt32(audit["start_role_extra_value_quote_call_count"], CultureInfo.InvariantCulture) != 1 ||
                    Convert.ToInt32(audit["shared_pending_builder_reference_count"], CultureInfo.InvariantCulture) < 3 ||
                    Convert.ToInt32(audit["shared_pending_persistence_reference_count"], CultureInfo.InvariantCulture) < 3 ||
                    Convert.ToInt32(audit["shared_pending_evaluator_reference_count"], CultureInfo.InvariantCulture) < 3 ||
                    Convert.ToInt32(audit["contract_selftest_mode_reference_count"], CultureInfo.InvariantCulture) < 2 ||
                    Convert.ToInt32(audit["live_evidence_contract_selftest_mode_reference_count"], CultureInfo.InvariantCulture) < 2 ||
                    Convert.ToInt32(audit["live_sample_builder_reference_count"], CultureInfo.InvariantCulture) < 3 ||
                    Convert.ToInt32(audit["live_sample_persistence_reference_count"], CultureInfo.InvariantCulture) < 3 ||
                    Convert.ToInt32(audit["live_pending_completeness_field_reference_count"], CultureInfo.InvariantCulture) < 5 ||
                    Convert.ToInt32(audit["precleanup_exit_callback_reference_count"], CultureInfo.InvariantCulture) != 0 ||
                    Convert.ToInt32(audit["settle_origin_after_sentinel_exit_reference_count"], CultureInfo.InvariantCulture) < 2) throw new HarnessException("Effective-overlay, -009 LIVE-evidence contract, persistence-order, or smoke static source audit failed");
            }
            result.Add(audit);
        }
        return result;
    }

    private static int Count(string text, string token)
    {
        int count = 0, offset = 0;
        while ((offset = text.IndexOf(token, offset, StringComparison.Ordinal)) >= 0) { count++; offset += token.Length; }
        return count;
    }

    private static void RequirePassResult(string path, string role, string mode)
    {
        if (!File.Exists(path)) throw new HarnessException("Missing QP result: " + path);
        HarnessOps.RequireResult(path, 0, role, mode);
        Dictionary<string, object> result = EvidenceIo.ReadMap(path);
        if (Record.Integer(result, "result_code") != 0) throw new HarnessException("QP result did not pass: " + path);
        Dictionary<string, object> details = Record.AsMap(result["details"]);
        if (Convert.ToInt32(details["performance_slot_launch_count"], CultureInfo.InvariantCulture) != 0) throw new HarnessException("Performance slot count was not zero");
        if (Record.Integer(details, "abc_launch_count") != 0) throw new HarnessException("A/B/C launch count was not zero");
        if (Convert.ToInt32(details["final_owned_runtime_count"], CultureInfo.InvariantCulture) != 0) throw new HarnessException("Final owned runtime count was not zero");
    }

    private static string BaseArgs(string mode, string stage, string identity, string output)
    {
        return " --mode " + Quote(mode) + " --stage " + Quote(stage) + " --identity " + Quote(identity) + " --out " + Quote(output) + " --journal " + Quote(Path.Combine(output, "evidence.journal.jsonl")) + " --result " + Quote(Path.Combine(output, "runner-result.json"));
    }

    private static Dictionary<string, string> TemplateFieldMap(params string[] keyValues)
    {
        if (keyValues == null || keyValues.Length % 2 != 0) throw new HarnessException("Template field map requires key/value pairs");
        Dictionary<string, string> fields = new Dictionary<string, string>(StringComparer.Ordinal);
        for (int i = 0; i < keyValues.Length; i += 2)
        {
            if (String.IsNullOrEmpty(keyValues[i]) || fields.ContainsKey(keyValues[i])) throw new HarnessException("Template field key is empty or duplicated: " + keyValues[i]);
            fields.Add(keyValues[i], keyValues[i + 1]);
        }
        return fields;
    }

    private static string TemplateExtraArgs(IDictionary<string, string> fields)
    {
        if (fields == null || fields.Count == 0) return String.Empty;
        List<string> keys = new List<string>(fields.Keys);
        keys.Sort(StringComparer.Ordinal);
        StringBuilder result = new StringBuilder();
        foreach (string key in keys) result.Append(" --").Append(key).Append(" ").Append(Quote(fields[key]));
        return result.ToString();
    }

    private static string[] TemplateSortedKeys(IDictionary<string, string> fields)
    {
        List<string> keys = fields == null ? new List<string>() : new List<string>(fields.Keys);
        keys.Sort(StringComparer.Ordinal);
        return keys.ToArray();
    }

    private static string ChildBase(string executable, string mode, string stage, string identity, string output, string journal, string role)
    {
        return Quote(executable) + " --mode " + Quote(mode) + " --stage " + Quote(stage) + " --identity " + Quote(identity) + " --out " + Quote(output) + " --journal " + Quote(journal) + " --result " + Quote(Path.Combine(output, role + "-result.json"));
    }

    private static string Relative(string root, string path)
    {
        Uri rootUri = new Uri(Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar);
        Uri fileUri = new Uri(Path.GetFullPath(path));
        return Uri.UnescapeDataString(rootUri.MakeRelativeUri(fileUri).ToString()).Replace('/', Path.DirectorySeparatorChar);
    }

    private static string Quote(string value) { return "\"" + value.Replace("\"", "\\\"") + "\""; }

    private static void CopyNew(string source, string target)
    {
        if (!File.Exists(source)) throw new HarnessException("Source file missing: " + source);
        if (File.Exists(target)) throw new HarnessException("Target already exists: " + target);
        File.Copy(source, target, false);
    }

    private static void RequireStageId(string stage, string stageId)
    {
        if (!Directory.Exists(stage)) throw new HarnessException("Stage missing");
        if (!String.Equals(Path.GetFileName(stage), stageId, StringComparison.Ordinal)) throw new HarnessException("Stage ID/path disagreement");
        if (!stageId.StartsWith(StagePrefix, StringComparison.Ordinal)) throw new HarnessException("Fresh -009 stage ID prefix is required");
    }
}
