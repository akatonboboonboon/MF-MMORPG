# FS-A Option A KBM Revalidation Checklist

- Work order: `MFO-WO-FS-A-30-003`
- Branch: `codex/fast-slice-fs-a-revalidation`
- Candidate: `f03a43d2339e9772a15db1c591a31f5e4f92cca2`
- Issued/tested source: `29c22763c41abaace46430395dd1bdfd14caaf66`
- Prototype tree: `2a66e4c06308a47678e8888a739b87ffd33d1ee8`
- Manual project: `C:\tmp\mf-fs-a-reval-manual-20260815-001\material-frontier-online\prototype`
- Scene: `res://scenes/fast_slice/fs_a_main.tscn`; Presentation preview was not used.
- Controls: `WASD` move, mouse aim, left mouse button (`LMB`) light, right mouse button (`RMB`) heavy, `Space` evade, `E` harvest/rematch.

Fresh editor import exited `0`; `.godot\global_script_class_cache.cfg` exists. Session A, Session B, A-followup, and the positive-Integrity alive retry each exited `0`; warning/error/SCRIPT ERROR/terminal FAIL count was `0`. An exit `0` proves launch/normal close only, not behavior.

## Result

`3 Pass / 0 Fail / 0 Blocked / 18 Not run`.

| # | Session | Manual requirement | Result | Direct/manual basis and limitation |
|---:|---|---|---|---|
| 1 | A | Arena launch and focus | Pass | Real integrated scene accepted actual controls; session exit `0`. |
| 2 | A | WASD follows visible player | Pass | User: `問題なく移動…を確認しました。` |
| 3 | A | Mouse aim cue follows stationary/moving | Not run | No direct observation. |
| 4 | A | Evade usable and visible as position change | Not run | No direct observation. |
| 5 | A | Light/heavy use different inputs/timing | Not run | Generic attack worked after terminology clarification; both buttons/timing were not explicitly checked. |
| 6 | A | No-teleport approach, visible reach and damage | Not run | Movement/attack/outgoing damage were observed; no-teleport composite clause was not explicitly checked. |
| 7 | A | One attack does not double-damage target | Not run | Automated exact-once Pass is separate from manual observation. |
| 8 | A | Canonical `BOSS HP` decreases | Not run | Damage/defeat occurred, but the named HUD field was not explicitly read. |
| 9 | A | Line telegraph geometry/readability/evasion | Not run | No direct observation. |
| 10 | A | Sector telegraph geometry/readability/evasion | Not run | No direct observation. |
| 11 | A | Integrity/Deformation changes readable | Not run | Incoming damage was observed, not both named changes/readability. |
| 12 | B | Player Integrity zero stops move/evade/action/damage confirmation | Not run | `②確認できました。` supports the prompt-level visible player stop only; all subclauses were not manually enumerated. |
| 13 | B | Player defeat stops enemy telegraph/attack/additional damage and preserves boss-side state | Not run | Same reply supports the prompt-level visible enemy stop only; all stop/invariant clauses were not manually enumerated. |
| 14 | A | Part break recognizable with position | Not run | No direct observation. |
| 15 | A retry | Boss HP zero stops hostile behavior | Not run | Boss defeat to WRECK succeeded; hostile-stop was not explicitly observed. |
| 16 | A retry | Wreck position and exact-three marker spatial consistency | Not run | WRECK and A/B/C center use succeeded; full wreck-position consistency was not explicitly checked. |
| 17 | A retry | Each harvest once and duplicate grants nothing | Not run | A/B/C each collected once; no collected point was tapped again. |
| 18 | A retry | Result appears only after third collection | Not run | Three `COLLECTED` states followed by result; absence before third was not explicitly checked. |
| 19 | A retry | Complete rematch reset and round-two major actions | Not run | E rematch and round-two movement/attack succeeded; complete-reset clauses were not explicitly checked. |
| 20 | A | Target/HUD/result color-independent readability | Not run | No direct observation. |
| 21 | All | Actual playtester free-text feel | Pass | Positive movement/attack/damage report; LMB/RMB QA terminology question; initial non-qualifying E observation; later alive retry completed. |

## Verbatim observations and prompt boundary

- `問題なく移動、攻撃、被ダメージ与ダメージを確認しました。ただ、LMBとRMBってなんですか？それだけ気になります。`
- After QA expanded the acronyms: `理解です。攻撃できましたが、撃破後のアイテム回収ができていません。Eもまた未反応です`
- Prompt 1 asked about the yellow `SALVAGE A/B/C`, marker center, E, and `AVAILABLE -> COLLECTED`; Prompt 2 asked whether the player and enemy visibly stopped after Integrity zero. Reply: `➀なりませんでした` / `②確認できました。`
- QA then asked whether left `INTEGRITY` was greater than zero during that collection attempt. Reply: `いいえ`.
- That first attempt is retained as a non-qualifying precondition observation and is not a candidate Fail.
- The alive retry explicitly required positive Integrity, boss defeat, WRECK, A/B/C center positioning, E release/fresh tap, three `COLLECTED`, result, rematch, and round-two movement/attack. Reply: `全部できました`.
- The final reply is bound only to those listed steps. It does not prove duplicate rejection, result absence before the third collection, complete reset, hostile-stop, or unrelated readability items.

## Session evidence

| Session | Evidence | Exit | Behavioral scope |
|---|---|---:|---|
| Editor import | `manual/01-editor-import.*` | 0 | Import/cache preparation only |
| A | `manual/02-session-a.*` | 0 | Real scene launch/normal close; behavior from user text |
| B | `manual/03-session-b.*` | 0 | Fresh real scene relaunch; not retry acceptance |
| A follow-up | `manual/04-session-a-followup.*` | 0 | Terminology clarification follow-up |
| Alive retry | `manual/05-session-a-alive-harvest-retry.*` | 0 | Explicit positive-Integrity bounded sequence |

Automation separately supports every Contract Section 10 technical item (`15 / 15`) and all 22 required invocations exit `0`. It does not convert a composite manual row into Pass.

## Outcome and boundary

- Outcome: `Technical Pass / promotion pending manual KBM and/or user feel` (remaining manual KBM/readability is pending; actual free-text was captured).
- Candidate Fail: `0`.
- Shared contract change needed: `No`.
- Promotion/Gate action: not authorized and not performed.
- Physical gamepad: `Not run / Deferred`.
- Performance/P95/maximum load/long-run: `Not run / Deferred`.
- Optional export: `Not run`.
- Manual stage/archive remain retained for 00 cleanup after Return acceptance.

Durable detail: [`../evidence/fast-slice/fs-a-integrated-revalidation/manual-attempt-003.json`](../evidence/fast-slice/fs-a-integrated-revalidation/manual-attempt-003.json).
