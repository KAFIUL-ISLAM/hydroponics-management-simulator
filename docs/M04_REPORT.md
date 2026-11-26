# M04 · Three-crop playable farming simulation

2026-11-26 · Git base `2c56490` · Godot `4.7.2.stable.official.ed1daf0bf`

## Implementation and traceability

The existing `CoffeeFarm` and `CoffeeDashboard` scripts keep their paths and UIDs. Three static `ReferenceCrop` resources feed one runtime. Starter and supplied seeds have independent trait dictionaries. Each planting creates a mutable plant that owns its progress, health, maturity and pending output. The existing GameState settlement guard admits one transaction per night. The farm stages uptake and mixed-liquid draw in a detached vessel, then publishes the outcome after committing energy, liquid and plant updates. The dashboard reads this state and binds inventory and cultivation actions.

| Evidence | Requirements and formula coverage |
| --- | --- |
| Three data-driven native profiles and complete annual cycles | GRW-01–04, GEN-01 runtime identity, F-GRW-01–03, F-GEN-01 native metadata |
| Shared pure-water mineral denominator, band, uptake and health | LIQ-01/03/04, MIN-01/02, HLT-01–03, F-LIQ-01/02, F-MIN-01/02, F-HLT-01/02 |
| Whole tablets, capacity checks, finite refill and confirmed drain | MIN-03, LIQ-02/05 partial, F-LIQ-03 with provisional mixed displacement |
| Fixed plain-machine cost and guarded settlement | EQP-01/02 plain-machine path, NGT-01/02 |
| Quantity and size at neutral equipment quality, collect once | HRV-01/02, HRV-03 size portion, F-HRV-01–03 |
| Selection, seed and product separation, recovered blocked output and bilingual feedback | INV-01/02 and UI-02/03 single-machine portions |

| Crop | Raw → effective target / output | Nightly draw / uptake | Mineral band | Pollution factor / native sensitivity |
| --- | --- | --- | --- | --- |
| 营养果 · Nutrition Fruit | 23 → 16 points / 5 → 7 fruit | 100,000 µL / 50 µL per point | 0.50–2.50% | 1.00 / 0.70 |
| 咖啡豆 · Coffee Beans | 21 → 21 points / 8 → 8 plantable beans | 100,000 µL / 30 µL per point | 1.75–3.25% | 1.01 / existing behavior |
| 韧棉 · Kotton | 32 → 43 points / 9 → 13 fiber | 250,000 µL / 75 µL per point | 2.00–5.00% | 1.26 / approximately 1.50454 |

Nutrition Fruit records Complex Genome II, Fast Growth II, Nutritious I, High Yield II, Hardy I and Sterile X, with complexity +8. Kotton records High Yield III, High Water Use II, Fragile II and Slow Growth I, with complexity 0. Both definitions use their effective parameters directly. Stored fruit and fiber retain their individual size buckets. Coffee Beans continue to be plantable.

## Verification

Each cell below gives expected and observed values, which matched exactly. Initial water was 5,000,000 µL for every fixture. The plain machine spent 8 kJ for each full running night, including the night that reached or exceeded the target.

| Crop | Initial minerals (µL) | Nights | Growth sequence | Energy (kJ) | Mixed draw (µL) | Uptake (µL) | Total mineral loss (µL) | Harvest |
| --- | ---: | ---: | --- | ---: | ---: | ---: | ---: | --- |
| Nutrition Fruit | 60,000 | 2 | 0 → 8 → 16 | 16 | 200,000 | 800 | 3,148 | 7 giant fruit |
| Coffee Beans | 150,000 | 3 | 0 → 8 → 16 → 24 | 24 | 300,000 | 720 | 9,430 | 8 plantable beans |
| Kotton | 150,000 | 6 | 0 → 8 → 16 → 24 → 32 → 40 → 48 | 48 | 1,500,000 | 3,600 | 46,639 | 13 large fiber |

| Suite | Result |
| --- | --- |
| Crop resource | PASS · 4 assertion groups |
| Resource Manager | PASS · 192 checks |
| Night state | PASS · 133 checks |
| Dashboard startup | PASS · 31 checks |
| Three crop farming | PASS · 98 checks |
| Coffee farming | PASS · 91 checks |
| Liquid composition | PASS · 77 checks |
| Nightly integration | PASS · 97 checks |

The 719 explicit checks and four original assertion groups passed in a fresh isolated project copy. The runner checked completion markers, process status and unexpected script errors. A failing layout check was detected during development. The final headless layout test covered button and readout bounds at 1280 × 720. The tablet fixtures matched 985,000 µL water + 15,000 µL minerals for the full pure-water example and 788,000 µL water + 212,000 µL minerals for an initially full 80/20 mix. A vessel below 15,000 µL rejected the operation and preserved its contents.

Default launch loaded `res://scenes/coffee_dashboard.tscn` and exited 0. The archived Lettuce probe printed `BASELINE_MATCH=true` and exited 0. Day 1 advanced to 2 and growth 0 advanced to 1 with Lettuce, 1,000 mL water, 50 mL minerals, 100 kWh, and READY unchanged. Godot reported the existing certificate-store diagnostic and restricted editor settings write. The older validation suites emitted their expected fixture warnings, including deliberately invalid resource operations, an unassigned ResourceManager and redundant assertions in the original crop test.

From the project directory, supply your Godot executable as `$GodotPath` and save the GDScript probe from [M01-T02](M01_T02_REPORT.md) to a temporary file for the third command.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\run-tests.ps1 -GodotPath $GodotPath -Import
& $GodotPath --headless --path . --verbose --quit-after 10 --log-file "$env:TEMP/m04-launch.log"
& $GodotPath --headless --debug --path . --quit-after 90 --script "$env:TEMP/legacy_probe.gd" --log-file "$env:TEMP/m04-legacy.log"
```

## Provisional decisions and limitations

- Nutrition Fruit scores above 95 and below 96 yield all large fruit. At neutral quality 96 to below 100 uses the 50% large split with the remainder giant. At 100 the crop yields all giant. No score rounding is used to resolve the gap.
- Overflow displaces the minimum needed volume of the original mixture by the existing proportional allocator. Drain discards the whole solution after confirmation and subsequent refills use finite stock.
- Demo supply grants one selected seed per action, limited by inventory capacity. The default capacity is 24 items. A custom capacity below a single harvest can leave that harvest pending even with an empty inventory.
- Kotton raw draw, reference mixed displacement, and reference handling for fractional Nutrition Fruit score edges remain unresolved. Pollution damage, nonneutral equipment quality, genetics evaluation, seed reproduction, vessel swapping and broader storage remain open.

## Desktop walkthrough

1. Launch with F5 at 1280 × 720. On a fresh default run, select Coffee Beans or Kotton, plant, start and use **Next Night** three or six times. Check the score, pending output and the collect action.
2. For Nutrition Fruit, start a fresh run. Confirm **Drain solution**, use **Add water** ten times and **Add tablet** four times. Select Nutrition Fruit, plant and start. Use **Next Night** twice and collect seven giant fruit.
3. After collecting, switch crops and inspect the retained solution and energy. Fill inventory with **Demo seed** to exercise a capacity-blocked harvest, then free slots using **Discard one** and its confirmation. Confirm that cancellation preserves the item and draining warns about the discarded volume.

Desktop walkthrough is pending for M04. Headless checks exercised the actual scene and signal bindings.

## Changed files and next milestone

- Data and runtime · `resources/coffee_beans.tres`, `resources/nutrition_fruit.tres`, `resources/kotton.tres`, `scripts/reference_crop.gd`, `scripts/liquid_composition.gd`, `scripts/coffee_farm.gd`, `scripts/coffee_dashboard.gd`
- Tests · `tests/test_three_crops.gd`, `tests/test_three_crops.gd.uid`, `tests/test_three_crops.tscn`, `tests/run-tests.ps1`
- Documentation · `README.md`, `docs/REQUIREMENTS.md`, `docs/CALCULATION_CONTRACT.md`, `docs/PROJECT_STATUS.md`, `docs/TESTING_REPORT.md`, `docs/DEVELOPMENT_LOG.md`, `docs/M04_REPORT.md`

Earlier M02/M03 workspace changes remain in place. The milestone remains uncommitted.

For M05, resolve the pollution tier boundaries and rounding in F-OPEN-04, add pure pollutant analysis and per-component fixtures, and then integrate staged damage and its dashboard breakdown. Retain the clean-solution and mineral-only regressions.
