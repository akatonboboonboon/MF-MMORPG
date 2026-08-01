# MFO-WO-P2-2B-004 runner correction audit

- Before SHA-256: `f9f5c2efbe89e3cc6c90ff30dd9f071c8215437f2f02e6bebe2477d540ff1be2`
- Before `^\s*_check\(` count: `70`
- Before `^func _check\(` count: `1`
- Correction write count: `1`
- Insert location: immediately after `52nd query follows configured capacity without a special 51st case`
- Inserted semantic lines: `large_pool.clear()` plus the single authorized active-count/capacity assertion
- After SHA-256: `5745d2ace2fab67aabd4b5761d5f7ce6339c8b15cbaad25a8c821b22f1a878a4`
- After `^\s*_check\(` count: `71`
- After `^func _check\(` count: `1`
- Corrected runtime total: `PASS: 71 assertions`, exit `0`
