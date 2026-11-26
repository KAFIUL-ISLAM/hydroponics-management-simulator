# Orbital Hydroponics · 轨道水培实验室

Provisional title · M08-A · 2026-11-26

The visual direction is a stylized 2D orbital laboratory. Use dark metal, restrained edge lighting and readable scientific displays. Give the cultivation chamber the largest continuous surface. Keep ornament away from control labels and reserve saturation for working states and distinct resource families.

| Token | Value | Role |
| --- | --- | --- |
| Background | `#101820` | Window and recessed surrounds |
| Panel | `#1C2B36` | Cards, dialogs and grouped controls |
| Machinery | `#304653` | Equipment surfaces and neutral actions |
| Cultivation | `#59D9B0` | Growth and primary completion |
| Water | `#58BCEB` | Water and liquid readouts |
| Electricity | `#E9B65A` | Energy and high-visibility focus outline |
| Genetics | `#AE91ED` | Seed and editor accents |
| Danger | `#E16D6D` | Rejection and destructive action cues |
| Primary text | `#E4EDF2` | Essential labels, quantities and instructions |

Use Chinese first and place English on the same line when it fits or on a second line otherwise. Text and a shape or state label carry critical meaning alongside color. The playable theme uses a 15 px base, 13 px compact actions, 14 px detailed analysis and settlement text, 15–17 px headings, 24 px title and 25 px resource values. Prefer tabular-looking alignment and readable units. The current baseline retains engine/system fallback. A future bundled CJK family should cover Simplified Chinese, numerals and symbols such as µ and → and have verified redistribution terms. Verify glyphs in the target export before bundling.

Use a spacing scale of 4, 8, 12, 16 and 24 px for new layouts. Use tight spacing only inside a related control row. Keep clear space around dashboard sections and modal buttons. The shared theme and existing inherited container metrics coexist in M08-A. [Theme](../resources/orbital_theme.tres)

| State | Treatment |
| --- | --- |
| Primary | Cultivation accent, explicit action label, stable bottom placement |
| Default / hover / pressed | Machinery fill, brighter edge on hover, distinct pressed fill |
| Disabled | Recessed fill and muted text; expose the reason via context where available |
| Keyboard focus | Two-pixel amber ring independent of hover |
| System vs device | Separate global lifecycle and machine running text |
| Rejection / confirmation | Plain-language cause, clear affected target, explicit confirm/cancel |
| Demo actions | Always labeled as demo; distinct accent where practical |

Icons should use a consistent simple stroke and silhouette. Pair icons with labels for essential controls. Avoid embedded text, badges or status information inside artwork. Keep chamber art behind a separate UI layer with no input interception.

## Artwork specifications for proposed M08-B

Use straight-alpha PNG at native source sizes. Chamber layers share a **960 × 800 px** canvas, centered and aspect-preserving. Backdrop and foreground may be separate, with no text or controls baked into either. Keep important silhouettes inside an 864 × 720 px centered safe area. Supply a fully opaque backdrop and transparent machine overlay. Use **512 × 512 px** transparent crop PNGs for each of the three crops with shared bottom-center anchoring for seedling, growing and mature poses. Leave at least 32 px transparent padding around each crop and keep the anchor consistent across stages. Optional light overlays share the chamber canvas and must be transparent. Keep labels, progress, DNA state and touch targets separate from all images. Retain author/source/license metadata for approved assets.

M08-A ships empty named layer slots and a text placeholder. M08-B artwork remains pending.
