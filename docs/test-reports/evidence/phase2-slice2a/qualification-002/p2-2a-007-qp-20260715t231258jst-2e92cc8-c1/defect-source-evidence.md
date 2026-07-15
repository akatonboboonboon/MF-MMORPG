# MFO-WO-P2-2A-007 sealed-source defect evidence

- Source: `source/MfoQaNative.cs`
- Source SHA-256: `d4739f380a6fd27ec9413849752078239574494bbbaa010644e979e5d02f0c1f`
- Manifest SHA-256: `e44acd54ba1b1f01e7628d9a3899242a43fa16164fa9c78bd4d355dff8314c67`
- Review method: read-only source inspection; no harness mode was invoked.

## Finding 1 — preparation receipt identity is absent from PREACK

The sealed source has zero occurrences of `preparation-receipt`, `preparation_receipt`, or `receipt_identity`.
The receipt exists at `seal/preparation-receipt.json` with SHA-256
`7c3c6dc7d2f015803446ce2db64e8fe2ef5acb25ef17c26bb9fbdaf104dbe6de`, but PREACK neither loads it nor records the
receipt path or receipt SHA-256, nor binds receipt-derived stage ID, manifest SHA-256, or slot count into the complete
prerequisite record.

Relevant sealed source:

```text
1837: if (c.Mode == "PREACK")
1839:     string stageId = c.Args.Required("stage-id");
1840:     string manifestSha = c.Args.Required("manifest-sha").ToLowerInvariant();
1841:     if (!String.Equals(stageId, Path.GetFileName(c.Stage), StringComparison.Ordinal)) throw ...;
1842:     if (!String.Equals(manifestSha, EvidenceIo.Sha256File(identity), StringComparison.Ordinal)) throw ...;
1843:     Dictionary<string, string> preack = new Dictionary<string, string>();
1844:     preack["stage-id"] = stageId;
1845:     preack["manifest-sha"] = manifestSha;
1846:     return RunChild(c, identity, "PREACK", preack);
```

The complete record constructed at line 2268 also has no preparation-receipt field.

## Finding 2 — exact activation still requires the old work-order ID

```text
1697: public static string RequireExactActivation(...)
1701: string expected = "MFO-WO-P2-2A-006 START_ACK stage_id=" + stageId + ...;
1702: if (!String.Equals(text, expected, StringComparison.Ordinal)) throw ...;
```

The sealed manifest identifies `MFO-WO-P2-2A-007`, while the exact activation parser requires `-006`. Therefore a
correct `MFO-WO-P2-2A-007 START_ACK ...` token cannot pass this code path.

## Finding 3 — prerequisite assertions precede the complete durable record

Observed order in sealed source:

```text
2250: assert forwarded stage and manifest identity
2253: persist and immediately evaluate OneDrive-only record
2254-2255: persist and immediately evaluate power/input-only record
2260-2265: persist and evaluate runtime/ownership-only records
2267: assert native tick is nonzero
2268: construct the first complete PREACK record
2270: append the complete record to the journal
2271: write the complete JSON record
2272: return the record hash and tick
```

Any earlier assertion can terminate before the record containing all required identity, OneDrive, power/input,
runtime/ownership, tick, receipt identity, and slot fields exists. The complete record also lacks receipt identity, so
even the nominal path cannot satisfy the work order.

## Terminal effect

These are structural failures in the exact sealed bytes. PREACK was not required to reproduce them and was prohibited
after the supervisor disposition. `PREACK`, `PREACK_READY`, `START_ACK`, `LIVE`, performance, P95, KBM, and A/B/C
launch remain Not run / Not produced; slot count remains `0`.
