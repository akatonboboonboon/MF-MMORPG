# Exported smoke post-return readback

The required exported-smoke invocation returned control to PowerShell without setting `$LASTEXITCODE`.
Immediately after return, the required log was absent. A later read-only observation found the log created
asynchronously at the required absolute path.

- Log size: `572` bytes
- Log SHA-256: `60d35ec29b0fad2f63df0f0a991e5d7e82fc1ae35e68544fe3ca54505641ade2`
- Log content: Godot engine banner, `DefinitionsValidated` event, and a RuntimeHardLimit record with
  `violation_count: 0`.
- Relevant residual process count at readback: `0`
- Exported EXE SHA-256 after invocation: `c2ec5f79c2f5302715cf27ebcac881329852ec78651d627c46fba91ba3378c1f`

This readback does not supply the missing numeric exit code and does not constitute a second smoke invocation.
