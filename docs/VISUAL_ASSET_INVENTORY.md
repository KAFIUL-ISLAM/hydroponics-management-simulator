# Visual asset inventory

| Asset class | Path and format | Runtime use / condition | Rights and gap |
| --- | --- | --- | --- |
| Project icon | [icon.svg](../icon.svg), SVG, 128 × 128; `icon.svg.import` is import metadata | Application icon configured in [project.godot](../project.godot). Standard Godot-style mark. | File contains no license declaration. Confirm attribution if reused. Custom submission icon absent. |
| Crops | `resources/{nutrition_fruit,coffee_beans,kotton,lettuce_prototype}.tres`, Godot data resources | Definitions only. Shared placeholder glyph in [main.tscn](../scenes/main.tscn#L351). | No crop silhouettes, sprites, textures or stage artwork in workspace. No reference artwork is approved for reuse. |
| Equipment and supplies | [main.tscn](../scenes/main.tscn#L228), label glyphs and flat panels | Placeholder group and resource glyphs. Machine variants and modules are text in Gear. | No machine or module artwork, water gauge artwork or inventory icon set. |
| Background and panel styling | [main.tscn](../scenes/main.tscn#L9), inline `StyleBoxFlat` and `ColorRect` | Header/card/inner/button boxes with local colors, padding and rounding. | No separate theme resource, background image or external material. |
| Fonts | No font files located | Godot default font and fallback chain. Chinese displays in known screenshots. Per-label overrides range 9–34 px in the scene. | Export CJK coverage and cross-machine typography remain unverified. Record font license when a font is approved. |
| Materials, shaders, particles | No corresponding standalone or scene-embedded assets located | Flat stock controls and backgrounds. | None required for baseline; proposed use requires design approval and profiling. |
| Animation | No `AnimationPlayer`, animation library or scripted tween identified in production | State updates snap on signals and actions. | Motion directions and reduced-motion support remain proposals. |
| SFX/music | No audio files or production audio players located | Silent baseline. | Audio pack or original source and licenses remain pending. |

## Development screenshots

All files below are PNGs in [screenshots](../screenshots/), with matching Godot import sidecars. Dimensions are file dimensions, including any editor chrome. Screenshots are evidence and no runtime artwork references were found. They are existing project captures. No separate screenshot licensing declaration was located.

| Repository path | Pixels | Evidence |
| --- | --- | --- |
| `screenshots/crop-resource-test-passed.png` | 1257 × 592 | Original crop assertions |
| `screenshots/crop_data_test.png` | 1266 × 622 | Crop-data test history |
| `screenshots/cropdata-dashboard.png` | 1286 × 811 | Crop-data dashboard history |
| `screenshots/dashboard-game-state.png` | 1352 × 1052 | Game-state presentation |
| `screenshots/dashboard-resource-integration.png` | 1917 × 1077 | Legacy resource integration |
| `screenshots/dashboard-v1-editor.png` | 1917 × 1077 | Legacy scene in editor |
| `screenshots/dashboard-v1-runtime.png` | 1297 × 820 | Legacy runtime presentation |
| `screenshots/equipment_management.png` | 1287 × 812 | Equipment dialog and neutral machine |
| `screenshots/game-state-test.png` | 1332 × 395 | Game-state testing |
| `screenshots/m01-t02-baseline-day1.png` | 1302 × 816 | Legacy Day 1 |
| `screenshots/m01-t02-baseline-day2.png` | 1297 × 822 | Legacy Day 2 |
| `screenshots/pollution_analysis.png` | 1297 × 817 | Clean liquid analysis and scenario menu |
| `screenshots/project-structure.png` | 363 × 496 | Early project tree |
| `screenshots/resource-manager-test.png` | 1287 × 805 | Resource testing |

The physical-pollution desktop screenshot supplied during historical development is separate from the repository PNG.

## Proposed asset priorities

1. Approve a visual direction, then define a compact crop-stage set, one equipment illustration and a consistent resource/action icon set.
2. Choose the default language strategy and verify bilingual glyph coverage before committing to a type family. Log authorship, source, license and redistribution terms for every approved asset.
3. Add subtle motion and short feedback sounds after presentation states are stable. Reserve music, particles and background art for budget permitting.

Asset work remains unstarted.
