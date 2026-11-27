# v0.7.0 — Orbital Hydroponics: Refined Workshop

**Milestone:** M11 complete and developer-accepted on 2026-11-27

**Release version:** v0.7.0

## Outcome

M11 refines keyboard navigation, focus feedback, disabled-action explanations, and manual spacing while preserving the approved artwork, mouse-first drag-and-drop, and pointer-transparent status overlays. Audio remains deferred. No simulation formulas, crop resources, numerical expectations, scenes, or artwork were changed.

The approved implementation scope is limited to:

- [`resources/orbital_theme.tres`](../resources/orbital_theme.tres) — hover, selection, focus, disabled-icon, and tab styling.
- [`scripts/workshop_view.gd`](../scripts/workshop_view.gd) — focus order, chamber focus restoration, and retained supply selection.
- [`scripts/coffee_dashboard.gd`](../scripts/coffee_dashboard.gd) — disabled reasons and modal focus recovery.
- [`scripts/workshop_manual.gd`](../scripts/workshop_manual.gd) — manual tab spacing.
- [`tests/test_workshop_ui.gd`](../tests/test_workshop_ui.gd) — 40 additional GUI checks across the two supported resolutions. No new UID metadata was required.

## Verification

### Codex automated results

The supplied Codex handover reports **19 suites passed**, with **1,480 explicit checks**, including **264 workshop GUI checks**, plus **four original crop assertion groups**. It also reports successful default launch, legacy Lettuce baseline, and deterministic Kotton comparison, with renderer captures visually checked at 1280 × 720 and 1920 × 1080. The comparison remained at 52% versus 100% health and 12 versus 13 fiber.

These are Codex-reported automated results, not a new Copilot run. The automated Enter-echo test injects an echo event without first simulating an initial Enter press followed by repeats; it does not independently prove the complete held-key sequence. The tests also do not establish Reduced Motion collection coverage or keyboard-focus styling on manual tabs. Those cases were covered in the developer's manual acceptance below.

### Developer manual acceptance · 2026-11-27

The developer reports **all 30 manual checks passed**:

| Category | Result |
| --- | ---: |
| Visual and interaction states | 5/5 |
| Keyboard navigation | 5/5 |
| Manual and analysis tools | 9/9 |
| Gameplay regression | 6/6 |
| Resolution and Reduced Motion | 5/5 |

Manual verification explicitly included holding Enter on Next Night, Reduced Motion collection, and visible keyboard focus during navigation. This evidence is separate from the automated suite totals.

`git diff --check` was reported as passing in the supplied handover. M11 has no implementation changes beyond the five approved files listed above; the full regression suite was not rerun during documentation and release finalization.

## Performance observations

The supplied Codex handover reports profiling graphical Godot 4.7.2 debug builds on Windows build 26340 with an AMD Ryzen 5 5500U, integrated Radeon graphics, 7.88 GB RAM, and OpenGL 3.3 Compatibility. The same scripted interactions were measured before and after, using **314 rendered-frame samples per resolution over roughly 10 seconds after warm-up**.

Rendered-frame p95 values, milliseconds:

| Interaction | 1280 × 720 before → after | 1920 × 1080 before → after |
| --- | ---: | ---: |
| Idle | 32.34 → 32.36 | 32.26 → 32.35 |
| Inventory selection | 32.35 → 32.12 | 32.53 → 32.22 |
| Supply drag | 32.63 → 32.37 | 32.35 → 32.59 |
| Seed drag and planting | 32.28 → 32.51 | 32.53 → 32.95 |
| Night advancement | 36.66 → 35.95 | 34.11 → 33.87 |
| Collection | 33.29 → 33.18 | 32.68 → 33.22 |
| Manual navigation | 34.70 → 34.37 | 35.31 → 34.72 |
| Liquid Analysis navigation | 38.52 → 33.96 | 34.66 → 34.01 |

The handover does not specify whether the 314 samples per resolution are divided among the listed interactions or represent samples for each interaction. This ambiguity is retained; no sample distribution is inferred.

Median synchronous Next Night click time was **16.45 → 14.78 ms** at 1280 × 720 and **13.15 → 14.15 ms** at 1920 × 1080, based on **three samples per resolution**. Each run added five nodes over the fixture and about 0.9–1.1 MB of Godot-tracked static memory. Occasional modal spikes remained. These short, frame-paced measurements establish neither a bottleneck nor a repeatable speedup; no performance refactor was made and no generalized performance claim is made.

### Renderer evidence locations

The supplied handover identifies these temporary paths:

- Before, 1280 × 720 manual: `C:/Users/malka/AppData/Local/Temp/orbital-m10-4f4bc46cda384971b8b49e3f7111ddb8/1280-manual.png`
- After, 1280 × 720 manual: `C:/Users/malka/AppData/Local/Temp/orbital-m11-baseline-54a3de7b19fa45de8762bb0a954c9068/after-1280-manual.png`
- After, 1920 × 1080 tool views: `C:/Users/malka/AppData/Local/Temp/orbital-m11-baseline-54a3de7b19fa45de8762bb0a954c9068/after-1920-sheets.png`

These are recorded evidence locations, not durable repository artifacts.

## Remaining scope

M11 is developer-accepted. M12 remains final regression, clean-target launch, confirmation of delivery format and cutoff, and verification of any agreed export or capture, credits, and submission package. No M12 work is included in this release.
