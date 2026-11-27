# Artwork manifest

All originals are the project owner's draft ChatGPT-generated pack in [assets/orbital_assets](../assets/orbital_assets/). The [pack README](../assets/orbital_assets/README.md) records the origin and identifies the plants as extracts from a combined sheet. No reference-game imagery or additional generated imagery was added. Originals remain intact. Runtime copies live under `assets/orbital_assets/runtime/`.

| Original PNG | Original px · bytes | Alpha | Processed px · bytes | State and use |
| --- | --- | --- | --- | --- |
| laboratory_background.png | 1672 × 941 · 2,204,982 | Opaque RGB | Source unchanged; 900 × 660 runtime atlas region | Active; chamber and room |
| chamber.png | 411 × 319 · 203,169 | Transparent RGBA | — | Unused; duplicates the baked chamber |
| liquid_tank.png | 152 × 304 · 70,299 | Transparent RGBA | — | Active; Analysis button |
| dna_station.png | 172 × 228 · 68,372 | Transparent RGBA | — | Active; DNA editor button |
| terminal.png | 218 × 228 · 67,028 | Transparent RGBA | — | Active; Gear button |
| seedling_shared.png | 152 × 120 · 26,667 | Transparent RGBA | 512 × 512 · 121,374 | Active, temporary shared seedling |
| growing_shared.png | 157 × 155 · 44,624 | Transparent RGBA | 512 × 512 · 202,176 | Active, temporary shared growing crop |
| coffee_mature.png | 167 × 160 · 50,817 | Transparent RGBA | 512 × 512 · 232,743 | Active mature Coffee Beans |
| nutrition_mature.png | 172 × 160 · 50,374 | Transparent RGBA | 512 × 512 · 231,029 | Active mature Nutrition Fruit |
| kotton_mature.png | 162 × 160 · 46,890 | Transparent RGBA | 512 × 512 · 212,236 | Active mature Kotton |
| coffee_icon.png | 122 × 119 · 21,385 | Transparent RGBA | — | Active mapping for Coffee produce; the current bean harvest is plantable and uses the seed icon |
| nutrition_icon.png | 117 × 119 · 18,939 | Transparent RGBA | — | Active Nutrition Fruit produce mapping |
| kotton_icon.png | 131 × 119 · 21,590 | Transparent RGBA | — | Active Kotton fiber mapping; unrecognized product variants keep text only |
| water_icon.png | 122 × 129 · 19,944 | Transparent RGBA | — | Active water card |
| energy_icon.png | 81 × 106 · 10,605 | Transparent RGBA | 81 × 106 · 11,052 | Active power card |
| dna_icon.png | 86 × 106 · 14,131 | Transparent RGBA | — | Active Genes button |
| module_icon.png | 106 × 106 · 18,543 | Transparent RGBA | — | Active module installation control |
| seed_packet.png | 97 × 106 · 17,037 | Transparent RGBA | — | Active demo and seed identity cues |

The inventory inspected a contact sheet against a dark surround and counted transparent, partial and fully opaque pixels. Seventeen originals contain transparent pixels and antialiased edges. The opaque laboratory image is intentional. Detached remnants were easiest to see near Nutrition Fruit and the energy icon. Preparation retained the largest contiguous nonzero-alpha object for each plant and the energy icon, preserving color and soft edges. Removed detached pixels by file: seedling 22, growing 60, Coffee 150, Nutrition Fruit 34, Kotton 16 and energy 149. No color-based removal was used. Plants use uniform 2× resampling of the retained bounding box on a transparent canvas at horizontal center and common baseline y=480. The circular bases are part of the original crops.

The chamber backdrop preserves the native region's aspect ratio. Foreground and effects layers are reserved. Small source plants remain visibly illustrative when enlarged. No flat rectangular background appeared in the inspected Coffee render. The remaining per-species desktop edge and alignment review is part of the handoff. Missing textures retain text or the shared growing sprite.
