# MFO-WO-P2-2B-012 — Stage B capture-safe terminal revalidation

- QA start HEAD: `fda1008a4a6ef8f420ff9d5df2505d154a3b2a11`
- Candidate: `30b090481a9fffd123d5b16537886e5011fd7e51`
- Reviewed handoff: `bbed2fd98bf0435e456f9ad2bd7dba2b7a7cb0c6`
- Recommendation: **Blocked / validation infrastructure or evidence incomplete**

## Pre-child correction

The single permitted condition batch preserved executable `_check` call sites / helper declarations at `153 / 1`. Runner SHA-256 is `5bc45949cc21d29b0bcc160aafed46257aa572259c761de3b031778aa3f67556`; immutable UID SHA-256 is `7615a8f1d1edf4d59e5a4eb25996acd008a05a53921e4f293ea5765da4d67096`.

The corrected heavy condition expects approved geometry `150 / 88 / 0.25 / max 1`; it does not alter production data.

## First non-pass

The frozen ASCII/BOM-free launcher passed PowerShell parser preflight. Its first required child mode, `QUALIFY_STREAMS`, exited `1` with stdout `0` bytes and stderr `409` bytes. Captured stderr reports `The string is missing the terminator: '.` The required canary result (`exit 23` and exact stream bytes) was therefore not reached.

Per the fixed sequence, `QUALIFY_EMPTY`, `QUALIFY_GODOT_VERSION`, qualification manifest, PARSER, FORMAL, and candidate execution were not run. Residual relevant process count is `0`. This is a capture-launcher infrastructure failure, not a candidate implementation or Approved-data Fail.

## Scope

Only the authorized runner, this report, `stageb-kernel-005` evidence, and QA handoff are changed. Existing evidence, candidate/gameplay/data, runner UID, scenes, project configuration, and prior reports remain unchanged.
