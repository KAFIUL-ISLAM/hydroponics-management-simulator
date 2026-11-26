# M04 · Core farming milestone checkpoint

2026-11-26 · Baseline `v0.1.0` · `2c56490855d0da94eadce5f1c6bc093f5c797eae`

## Milestone scope

- M02 reconciled the assessment requirements with the reference research, recorded calculation units and operation order, and separated sourced rules from provisional policies and unresolved questions. [Research reconciliation](M02_REPORT.md) · [Calculation contract](CALCULATION_CONTRACT.md) · [Requirements](REQUIREMENTS.md)
- M03 implemented integer-microlitre liquid composition, proportional draw, mineral uptake, and the atomic Coffee Beans loop from seed through harvest and replanting. [Liquid composition](M03_PACKAGE_A_REPORT.md) · [Coffee Beans](M03_PACKAGE_B_REPORT.md)
- M04 added Nutrition Fruit and Kotton to the shared simulation. The dashboard supports crop selection, seed and product stocks, size-based harvests, capacity recovery through confirmed discards, and solution management. [Implementation and walkthrough](M04_REPORT.md)

## Release regression

Fresh import and all eight suites passed under Godot `4.7.2.stable.official.ed1daf0bf` in an isolated copy. The run verified **719 explicit checks and four original crop assertion groups**, with zero failures. The default launch loaded `res://scenes/coffee_dashboard.tscn` and exited successfully. The archived Lettuce probe returned `BASELINE_MATCH=true`. Day 1 advanced to Day 2 and growth 0 to 1, with Lettuce, 1,000 mL water, 50 mL minerals, 100 kWh and READY preserved. The Windows certificate-store diagnostic also appeared during this run.

All expected fixture values below matched the observed results exactly. Each fixture started with 5,000,000 µL water.

| Crop | Initial minerals (µL) | Nights | Final growth | Energy (kJ) | Draw (µL) | Uptake (µL) | Mineral loss (µL) | Output |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Nutrition Fruit | 60,000 | 2 | 16 | 16 | 200,000 | 800 | 3,148 | 7 giant fruit |
| Coffee Beans | 150,000 | 3 | 24 | 24 | 300,000 | 720 | 9,430 | 8 plantable beans |
| Kotton | 150,000 | 6 | 48 | 48 | 1,500,000 | 3,600 | 46,639 | 13 large fiber |

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\run-tests.ps1 -GodotPath $GodotPath -Import
```

## Desktop evidence

The user confirmed successful desktop checks at 1280 × 720 for planting, running and collecting all three crops, switching crops, inventory discard confirmation and cancellation, and solution drain. The user previously supplied a desktop screenshot showing a mature healthy Coffee Beans crop in M03. Separately, M04 headless integration verified scene bounds and exercised the dashboard bindings.

## Open work

Proportional tablet displacement, the fractional Nutrition Fruit size gap, confirmed no-refund draining, and demonstration seed supply are documented project policies. Kotton's raw draw remains unresolved. Pollution damage, advanced genetics, equipment quality and modules, and seed reproduction remain open. M05 will reconcile pollutant tier boundaries and rounding, then implement per-component analysis and damage with clean-solution regression coverage.

The obsolete root `crop_resource_test.tscn` still points to `tetst/` and is excluded from the checkpoint. Local `.godot/` and `docs.zip` are also excluded.
