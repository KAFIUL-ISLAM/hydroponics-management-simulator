# M06 Package B · Seed reproduction, inheritance and inventory

2026-11-26 · Godot 4.7.2 · Published baseline `v0.2.0` / `08606099404c99cbe1bd28b03573f8a11a9ab0ce`. The tested working tree includes M05 and M06-A.

## Reference reconciliation

| Species | Verified neutral-equipment schedule |
| --- | --- |
| Nutrition Fruit | Three attempts. Native Sterile X greatly reduces the chance of a seed per attempt. |
| Kotton | One attempt at health score ≤50%. At >50% and ≤80%, a 50% chance adds a second attempt. Above 80%, two attempts. |
| Coffee Beans | The health-adjusted harvest is already plantable. Fertile and Sterile are incompatible, so this path grants no separate reproduction attempts. |

The agriculture and crop-specific pages agree on the schedules. Their broader reference scope includes Dreamcap, filler grass and hydroponic reed as additional Fertile/Sterile-eligible crops. Glowberries retain their perennial mother with no seed returns. The agriculture page also describes an equipment exception for filler grass. Those species and equipment effects are outside the current three-crop, plain-machine runtime. [Agriculture, seed returns](https://wiki.biligame.com/probablystolen/水培农业#返种与留株) · [Kotton seed](https://wiki.biligame.com/probablystolen/韧棉种子) · [Nutrition Fruit seed](https://wiki.biligame.com/probablystolen/营养果种子) · [Coffee Beans](https://wiki.biligame.com/probablystolen/咖啡豆)

F-GEN-01/03 uses the rank intensity `rank^0.75`. Fertile adds `0.25 × intensity` to the base copy multiplier of 1. Sterile subtracts the same amount, subject to the published positive multiplier floor recorded in the contract (approximately 0.0001000166). Each attempt returns `floor(multiplier)` copies, plus one more with probability equal to the fractional part. Fertile I therefore gives one guaranteed copy and a 25% chance of a second. Sterile X gives no guaranteed copy and approximately 0.01000166% per attempt. Display rounding has no effect on outcomes. The calculator uses final integer health values of 5,000 and 8,000 as the Kotton boundaries. No independent complexity-to-probability adjustment is documented. [Plant genetics](https://wiki.biligame.com/probablystolen/植物基因) · [Calculation contract](CALCULATION_CONTRACT.md)

F-GEN-03/04 passes the mother’s current trait ranks to independent offspring and clears their heat. Complexity and effective properties are recomputed from inherited ranks and species data. This is deterministic inheritance from one parent. Reference RNG algorithm, precision and equality behavior are unverified. The project uses strict `roll < probability` and skips draws at deterministic endpoints.

## Runtime and inventory

- `seed_reproduction.gd` takes the species profile, final health, resolved parent configuration and an injected roll callable. Its typed result records eligibility, attempt count, extra attempt probability, per-attempt outcomes, multiplier, extra copy probability and offspring count.
- The farm uses a dedicated Godot RNG. Settlement reaches the reproduction stage after machine, liquid, energy and growth calculations succeed. Invalid reproduction restores the saved RNG state. A maturity event freezes the product and offspring results. UI refresh, blocked collection and extra nights while mature preserve those results.
- Each offspring stores its own rank dictionary and references the same static species definition. Coffee Beans stage the plantable product count and instantiate that many seeds only after collection passes the capacity check. This preserves the existing plantable output and avoids a second grant.
- Collection is all-or-nothing across products and seeds. Shortage of item slots leaves every item pending. This is the existing local capacity policy. Reference overflow-to-warehouse behavior is deferred.
- The **Genes** dialog cycles individual seeds by instance ID, shows properties of the seed that planting will consume, and shows pending offspring when available. Discard confirmation targets the specific stored item. Demo Coffee keeps the existing native Coffee traits and adds Fast Growth II, High Yield III, Drought Resistant I and Hardy I through the resolver.

## Regression evidence

Fresh isolated import passed. All eleven suites passed with **863 explicit checks and four original crop assertion groups**, zero failures. The suites were crop resource (four groups), Resource Manager (192), night state (133), dashboard startup (31), seed reproduction (26), genetics (46), pollution (66), three-crop farming (101), Coffee farming (94), liquid composition (77) and nightly integration (97).

| Fixture | Expected | Actual |
| --- | --- | --- |
| Sterile X, rolls 0, 0.0002, 1 | 3 attempts, [1, 0, 0] copies | 3, [1, 0, 0] |
| Kotton at 5,000 / 5,001 / 8,000 / 8,001 health | 1 / 2 / 1 / 2 attempts with 0.49 and 0.50 for the middle tests | 1 / 2 / 1 / 2 |
| Fertile I Kotton above 80%, rolls 0.249 and 0.25 | [2, 1] copies | [2, 1] |
| Modified Coffee properties | 15 points, 12 items, 75,000 µL/night, sensitivity 0.70, complexity +25 | matched across resolver and cultivation checks |
| Modified Coffee mature, collect and replant | 12 plantable outputs, no extra grant, child heat 0 and target 15 | matched |
| Kotton full inventory | 13 products and 2 seeds stay pending with 14 slots free | matched, successful transfer once with 15 slots |

The clean cultivation mineral losses matched **3,148 / 9,430 / 46,639 µL** for Nutrition Fruit, Coffee Beans and Kotton. The M05 raw-index-20, eight-point fixture still matches **120 / 162 / 605** health units. Default launch loaded the farming dashboard. The Lettuce probe printed `BASELINE_MATCH=true`. The Windows certificate-store diagnostic remained present.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\run-tests.ps1 -GodotPath $GodotPath -Import
& $GodotPath --headless --path . --quit-after 10 --log-file "$env:TEMP/m06b-launch.log"
```

The user confirmed completion of the M05 desktop acceptance checklist. The separately supplied screenshot shows the physical-pollution scenario at 1280 × 720. M06-B desktop smoke testing remains pending. [M05 evidence](M05_REPORT.md)

## Desktop walkthrough

1. Press F5 at 1280 × 720, select Coffee Beans and open **Genes**. Use **Next seed** to inspect different instance IDs. Choose **Demo Coffee** and check the four added ranks and effective values in the fixture above.
2. Close the dialog and plant the selected seed, then run two clean nights. Collect 12 beans, inspect a collected seed and replant it. Confirm that the collected seed inherits the ranks and shows heat zero.
3. On a fresh run, plant Kotton in the default solution and run six nights. Open **Genes** and check the two pending offspring. With limited free slots, collect should leave the output pending. Free enough slots using confirmed discards, then collect and replant a returned seed.

## Changed files and next package

- Production · `scripts/seed_reproduction.gd` and UID, `scripts/reference_crop.gd`, `scripts/coffee_farm.gd`, `scripts/coffee_dashboard.gd`, `resources/nutrition_fruit.tres`, `resources/kotton.tres`.
- Tests · `tests/test_seed_reproduction.gd` and UID, `tests/test_seed_reproduction.tscn`, `tests/test_three_crops.gd`, `tests/run-tests.ps1`.
- Documentation · README, calculation contract, requirements, project status, testing report, development log, M05 report, and this report.

For M07, reconcile equipment calculation order and DNA editor state transitions before integrating either system. Preserve the existing plain-machine fixtures and keep DNA editor heat and operation RNG separate from farming reproduction. Equipment reproduction interactions, perennial lifecycle, warehouse overflow and persistent seed IDs remain open.
