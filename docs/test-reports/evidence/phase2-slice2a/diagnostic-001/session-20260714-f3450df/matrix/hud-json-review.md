# HUD / JSON visual review

All four generated viewport captures are intact `1920x1080` PNG files. Their HUD P95 values match the associated
JSON values after the HUD's two-decimal rounding:

| Slot | JSON P95 (ms) | HUD P95 (ms) | Match |
|---|---:|---:|---|
| A1 | `18.0555555555556` | `18.06` | Yes |
| B1 | `19.088` | `19.09` | Yes |
| C1 | `18.3333333333333` | `18.33` | Yes |
| C2 | `18.3333333333333` | `18.33` | Yes |

Each capture also shows one visible player, active hit queries `0 / 1`, target hit count `0`, definitions `OK`, and
player position `(620.0, 540.0)`. This confirms recorder/HUD consistency only; it does not make an integrity-invalid
performance slot valid.
