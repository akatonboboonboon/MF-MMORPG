# FS-A KBM Play Checklist

Use only after a FS-A integration candidate is explicitly issued for validation. Record `Pass`, `Fail`, `Blocked`, or `Not run` per line; do not infer player feel from automation.

| Check | Result | Evidence / note |
| --- | --- | --- |
| Arena starts and focus remains usable | Not run | |
| Keyboard move directions remain responsive | Not run | |
| Mouse aim remains responsive while moving | Not run | |
| Evade is usable and remains legible | Not run | |
| Light and heavy use distinct inputs and timings | Not run | |
| One light or heavy attack does not damage the same target twice | Not run | Technical trace is also required; do not infer exact-once only from visuals |
| Enemy durability decreases after a valid hit | Not run | User wording is “enemy Integrity”; contract observation is currently `boss_hp`, pending frozen-candidate mapping |
| `telegraph_line` is recognizable without color alone | Not run | |
| `telegraph_sector` is recognizable without color alone | Not run | |
| Integrity and Deformation changes are readable | Not run | |
| One part break is recognizable | Not run | |
| Boss defeat stops hostile behavior | Not run | |
| Wreck appears once and three harvest points are usable once each | Not run | |
| A second collection attempt on the same point grants nothing | Not run | Technical state evidence is also required |
| Result appears only after the third collection | Not run | |
| Rematch restores a playable second loop | Not run | |
| Overall player feel (free text, actual user/playtester only) | Not run | |

Gamepad, performance/P95, maximum load, and strict Gate evidence are outside this checklist.
