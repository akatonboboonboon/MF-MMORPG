# MFO-WO-P2-2B-013 supervisor prequalification

This record documents read-only/pre-child supervisor qualification. It is not QA FORMAL evidence and does not
attribute candidate behavior.

- Corrected runner canonical SHA-256: `f48266b43a3f3b572d2a5747807efa8bc4bbc6150e3481473d8b9d0272c3ba22`
- Runner parser-only with Godot `4.7.stable.official.5b4e0cb0f`: exit `0`
- Candidate/FORMAL invocation count: `0`
- Launcher source canonical SHA-256: `671c8018e5b295bf83d7d228f41adec5802570b63d6a569939539df54d04736f`
- Launcher Windows PowerShell 5 parser errors: `0`
- Fresh `c5` used an isolated mock-repository layout with support source and evidence copy byte-identical, the copy
  ReadOnly, and a junction to the corrected supervisor project. Its only source variation was the fixed project path
  being changed from `C:\tmp\q2b-stageb\material-frontier-online\prototype` to the mock-repository project path.
- The resulting mock source/copy SHA-256 was
  `88e674bb9ed159b7dbe0dfeaca46d3038ba15a9ff6e739dafe0a21dc8bb9b867`.

Fresh preflight `c5` results:

| Mode | Numeric exit | stdout bytes | stderr bytes | Completed | Timed out | Streams completed | Kill attempted |
|---|---:|---:|---:|---|---|---|---|
| `QUALIFY_STREAMS` | 23 | 21 | 21 | true | false | true | false |
| `QUALIFY_EMPTY` | 29 | 0 | 0 | true | false | true | false |
| `QUALIFY_GODOT_VERSION` | 0 | 31 | 0 | true | false | true | false |
| `PARSER` | 0 | 73 | 0 | true | false | true | false |

Every completed mode matched an independent mode-specific executable, argument string, argument length, and argument
UTF-8 SHA-256; raw output was re-read from disk against the mode-specific acceptance rule. Each mode wrote an atomic
`pass-verdict.json` and transitive `pass-manifest.json`. The qualification manifest schema was
`mfo.qa.stageb013.capture-qualification-manifest.v2`, with `3 / 3` payloads; its scratch SHA-256 was
`c23aac75e565a906e8b7e3af763208667915794dbf24a638ca875736193051a7`. FORMAL remained absent.

Earlier supervisor scratch attempts `c1` through `c4` were authoring and pre-final hardening checks. They exposed raw
UID line-ending sensitivity, null optional-source binding, strict predecessor-state requirements, timeout evidence,
and independent mode-argument binding. All were superseded before fresh `c5`; none executed FORMAL or the candidate.
