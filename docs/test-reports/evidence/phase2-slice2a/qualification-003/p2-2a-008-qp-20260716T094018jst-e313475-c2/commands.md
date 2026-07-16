# Exact invocation and command record

All harness invocations are fixed in [`exact-invocations.json`](exact-invocations.json). That record contains the full
command lines extracted without normalization from the final manifest and durable pending observations, plus the exact
LIVE child argument arrays and their source journal record hashes.

## Stage QP

| Mode | Exact command property | Command SHA-256 | Native exit / result |
|---|---|---|---|
| `QP_DRYRUN` | `seal/qualification-manifest.json: invocations.qp_dryrun_runner_exact` | `cb80500296452e8dc6b45a4c621fd8b6de5870d58bdb4083f464dc0f3894e52a` | `0 / Pass` |
| `QP_SELFTEST` | `seal/qualification-manifest.json: invocations.qp_selftest_runner_exact` | `df81d5bbfea2de94187ba7959453b045ead98baeac0946e07e345887f326acd1` | `0 / Pass` |
| `QP_POWER_INPUT_SMOKE` | `seal/qualification-manifest.json: invocations.qp_power_input_smoke_runner_exact` | `416632c2307e766c34ab7b079deececcd4907db03fea7658e610008e15114b65` | `0 / Pass` |
| `QP_PREACK_CONTRACT_SELFTEST` | `seal/qualification-manifest.json: invocations.qp_preack_contract_selftest_runner_exact` | `475de2f3294d2a76182d1a17eba973888877e17651d318bcc9731c492caf77d4` | `0 / Pass` |

## PREACK and LIVE

| Role | Exact command source | UTF-8 command SHA-256 | Native exit / self-result |
|---|---|---|---|
| PREACK runner | `runs/preack-001/runner-preack-pending.json: invocation_capture.value.command_line` | `1fc160ed5abd55e1110a5f2f8881c0682d9290b19b6b17e76289dac0dad5ce4d` | `0 / Pass` |
| PREACK launcher | `runs/preack-001/launcher/preack-record.json: invocation_capture.value.command_line` | `bac50ee9e1e952559f02b814eee126462e06e92324d6a85aa7c96e3f5fc00bce` | `0 / Pass` |
| LIVE runner | `runs/live-001/live-activation-pending.json: invocation_capture.value.command_line` | `3978d8900a9619e701bfc60247feb2418c627c15ce35ecabc6730ac77b613530` | `0 / Pass` |
| LIVE launcher | `runs/live-001/launcher/launcher-live-pending.json: invocation_capture.value.command_line` | `81099667b18381aeae3afed9b9faed00b6ac356f98be11f90babd4484f8e7110` | `0 / Pass` |
| LIVE controller | `runs/live-001/evidence.journal.jsonl: owned_child_started sequence 8` | exact argument array and record hash in `exact-invocations.json` | `0 / Pass` |
| LIVE sentinel | `runs/live-001/evidence.journal.jsonl: owned_child_started sequence 10` | exact argument array and record hash in `exact-invocations.json` | internal exit `23`, exact tokens |

The PREACK launcher was the only PREACK child and did not start the controller. LIVE started only the launcher,
controller, and sentinel. A／B／C and a performance slot were not launched.

## Closure-only commands

After the qualification window ended and the terminal defect audit began, no harness component was executed again.
Closure used only read-only enumeration, hashing, journal verification, source inspection, and Git scope checks:

```powershell
Get-ChildItem -LiteralPath <stage-or-run-root> -Recurse -File
Get-FileHash -Algorithm SHA256 -LiteralPath <payload>
Get-Content -Encoding utf8 -LiteralPath <journal-or-source>
Select-String -Encoding utf8 -LiteralPath <source> -Pattern <contract-pattern>
git status -sb
git diff --check
```
