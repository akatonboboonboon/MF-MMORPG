# MFO-WO-P2-2B-010 requirement-to-test matrix

| Requirement group | Direct QA coverage in frozen runner |
|---|---|
| 4.1 package and exact bindings | `_test_resources_and_registry`, `_test_literal_vocabulary_and_source_isolation` |
| 4.1 isolation and active-only 48 px intent | `_test_literal_vocabulary_and_source_isolation`, `_test_heavy_runtime_contract` |
| 4.2 resources, exact ordered form/actions/effects | `_test_resources_and_registry` |
| 4.2 legacy and open vocabulary | `_test_runtime_configuration_and_rejection`; inherited Stage A `71 / 71` identity binding |
| 4.2 duplicate, missing, extra, cross-wired, reordered registries | `_test_registry_rejects_invalid_variants`, `_test_complete_registry_negatives` |
| 4.2 empty IDs/registries, unknown refs, isolated invalid values | `_test_complete_registry_negatives` |
| 4.3 config and pre-accept rejection | `_test_runtime_configuration_and_rejection`, `_test_release_reset_and_clear_contract` |
| 4.3 hit/miss/rejected/malformed/invalidated callback outcomes | `_test_quick_runtime_contract`, `_test_heavy_runtime_contract`, `_test_complete_callback_and_boundary_contract` |
| 4.3 reset/clear, boundaries, multi-boundary and callback cardinality | `_test_release_reset_and_clear_contract`, `_test_complete_callback_and_boundary_contract` |
| 4.3 request and debug immutable records/final idle | `_test_quick_runtime_contract`, `_test_heavy_runtime_contract`, `_test_complete_debug_record_contract` |

Inherited -009 regressions and main smoke are bound by their frozen manifest only; they are not re-executed by -010.
