# v0.6.0 — Orbital Hydroponics: Guided Cultivation

**Milestone:** M10 complete; developer-accepted on 2026-11-27; released as v0.6.0

**Date:** 2026-11-27

**Scope:** documentation and milestone finalization; Codex implementation preserved

## Outcome

M10 addresses the workshop battery-recovery issue, improves machine-state readability, adds optional onboarding, and supplies a deterministic nutrient comparison for the employer-facing design analysis. The normal gameplay entry point remains [`scenes/workshop.tscn`](../scenes/workshop.tscn). Simulation formulas, crop resources, and balance were not changed by the M10 interaction fix.

## Release notes

### Gameplay and usability

- Corrected live drag eligibility so a replacement battery can be dragged immediately after depletion; one refill transfers without selecting another item.
- Improved bilingual machine-status readability with a dark translucent background, persistent blocker feedback, and expiring temporary messages.
- Added an optional Quick Start / Advanced farming manual, accessible from `?` and F1, with navigation to existing tools and inventory selection preservation.

### Technical demonstration

- Added a deterministic native-Kotton nutrient comparison, with the tested conditions and reproducibility command documented below.
- Prepared the [Chinese technical design analysis](HYDROPONICS_DESIGN_ANALYSIS_ZH.md) and [workshop demonstration guide](DEMONSTRATION_GUIDE.md).

### Verification and known limits

- Codex reported the automated M10 results below; the developer separately accepted all 19 manual checks.
- Protected simulation calculations, crop resources, and existing balance expectations were not changed.
- Fractional pollution tiers/rounding, nonneutral equipment quality, raw Kotton water before traits, advanced RNG, and perennial output remain documented research or scope limitations. No performance measurements are claimed.

### Battery drag recovery

The developer-reported failure was reproduced before the fix. At night completion, the workshop refreshed its grids while `GameState` still held the settlement lock. That refresh cached drag eligibility as false; selecting another inventory item caused a later refresh after the lock cleared. Both workshop grids now query `farm.can_act()` when a drag starts or a drop is evaluated. The first replacement battery drag after depletion succeeds without an intervening inventory interaction and transfers exactly one refill. Water, seed, and module drags also passed. This is an interaction-state correction, not a change to energy calculations.

### Status feedback and onboarding

The workshop status chip has a padded, dark translucent background, bilingual warning text, existing warning icons and colors, persistent blocker visibility, and pointer-transparent controls. Temporary feedback expires while an unresolved blocker remains visible. The optional farming manual provides Quick Start and Advanced tabs, opens from the `?` button and F1, links to existing Equipment, Liquid Analysis, and DNA Editor tools, and retains inventory selection. GUI verification completed the Coffee planting, cultivation, collection, and replanting loop.

Implementation evidence is in [`scripts/inventory_grid.gd`](../scripts/inventory_grid.gd), [`scripts/workshop_view.gd`](../scripts/workshop_view.gd), and [`scripts/workshop_manual.gd`](../scripts/workshop_manual.gd); focused coverage is in [`tests/test_workshop_ui.gd`](../tests/test_workshop_ui.gd).

## Deterministic nutrient comparison

The M10 fixture uses native Kotton, 5,000 mL pure water, 100 kJ, the standard machine, no modules, no added pollution, and RNG seed 42. Only initial mineral volume changes. The test creates isolated instances of the normal workshop and emits the measured state; the results below are the Codex handover results, not a new Copilot test run.

| Metric | Below range | Suitable range |
| --- | ---: | ---: |
| Starting minerals / concentration | 50 mL / 1.000% | 150 mL / 3.000% |
| Final concentration | 0.917% | 2.917% |
| Nights / final growth | 6 / 48 | 6 / 48 |
| Mixed solution drawn | 1,500 mL | 1,500 mL |
| Pure water consumed | 1,485.826 mL | 1,456.961 mL |
| Total mineral loss | 17.774 mL | 46.639 mL |
| Energy consumed | 48 kJ | 48 kJ |
| Final health | 52% | 100% |
| Harvest | 12 Regular fiber | 13 Large fiber |
| Offspring | 2 seeds | 2 seeds |

Total mineral loss includes crop uptake and minerals carried out with the mixed-liquid draw; the fixture checks 3.6 mL uptake in each case.

In this controlled run, suitable concentration raises final health by 48 percentage points, increases harvest quantity from 12 to 13 (about 8.33% relative to 12), and changes the grade from Regular to Large. Maturity time, mixed draw, and energy use remain unchanged. The suitable setup spends more minerals; the outcome therefore illustrates a resource-allocation choice rather than a free yield bonus. These results do not establish outcomes for other crops or setups. Full conditions, formulas, and interpretation are in the [Chinese design analysis](HYDROPONICS_DESIGN_ANALYSIS_ZH.md).

Reproduce the fixture with:

```text
Godot --headless --debug --path . res://tests/test_m10_nutrient_demo.tscn
```

The test and runner entries are [`tests/test_m10_nutrient_demo.gd`](../tests/test_m10_nutrient_demo.gd), [`tests/test_m10_nutrient_demo.tscn`](../tests/test_m10_nutrient_demo.tscn), and [`tests/run-tests.ps1`](../tests/run-tests.ps1).

## Verification and acceptance

Codex reports that all **19 regression suites** passed, with **1,440 explicit automated checks**, including **224 workshop GUI checks**, plus **four original crop assertion groups**. The default launch and legacy Lettuce baseline passed. Renderer captures were checked at 1280 × 720 and 1920 × 1080. The test and launch evidence is recorded in [`TESTING_REPORT.md`](TESTING_REPORT.md#m10--2026-11-27). Copilot did not rerun the full suite for this documentation-only task.

For this release preparation, Godot was unavailable on Copilot's PATH, so Copilot did not independently rerun the nutrient test scene. The analysis's Mermaid fences and basic diagram structure were checked, but no independent Mermaid parser was used. These are documentation-verification limitations, not replacements for Codex's recorded M10 test evidence.

### Developer manual acceptance · 2026-11-27

The developer reports all **19 manual acceptance checklist items passed**. This is separate from Codex's automated verification.

**Battery recovery — 5/5**

1. Installed battery depletion.
2. Insufficient-energy warning.
3. Immediate replacement-battery drag without selecting another item.
4. Exactly one refill transferred.
5. Warning clears after recovery.

**Machine status — 4/4**

6. Warning text is clearly readable.
7. Warning background fits the workshop design.
8. Status overlays do not block drag-and-drop.
9. Temporary feedback expires correctly.

**Farming manual — 5/5**

10. Manual opens using the `?` icon.
11. Manual closes and reopens with F1.
12. Quick Start and Advanced tabs function.
13. Links to existing analysis tools work.
14. Inventory selection is preserved.

**Gameplay and presentation — 5/5**

15. Complete Coffee cultivation cycle.
16. Product collection and replanting.
17. Reduced Motion behavior.
18. Layout at 1280 × 720.
19. Layout at 1920 × 1080.

The supplied Codex handover's closing sentence says desktop acceptance is pending. This dated developer acceptance record supersedes that stale sentence. M10 is complete, developer-accepted, and was released as v0.6.0.

## M10 files and remaining work

Codex implementation and test files preserved:

- `scripts/inventory_grid.gd`
- `scripts/workshop_view.gd`
- `scripts/workshop_manual.gd` and `scripts/workshop_manual.gd.uid`
- `tests/test_workshop_ui.gd`
- `tests/run-tests.ps1`
- `tests/test_m10_nutrient_demo.gd`, its UID, and `tests/test_m10_nutrient_demo.tscn`

Copilot's contribution to this assignment is documentation only. M11 interaction polish, representative performance profiling, and optional approved audio remain; M12 final regression, clean-target launch, and submission preparation remain.
