# M07 Package A · Hydroponic equipment and modules

2026-11-26 · Godot 4.7.2 · Published baseline `v0.2.0` / `08606099404c99cbe1bd28b03573f8a11a9ab0ce`. The tested working tree includes M05 and M06.

## Reference reconciliation

The machine reference gives a standard operating rate of 8 growth points and 8 energy units per night. Its two starter configurations run at 9/11 and 6/3 with locked modules. It ties capacity to the inserted container and locks the seed and modules during work. The reference module grid has 26 cells, expandable to 31 and 35. This implementation uses a configurable demo limit of three module items with no shape or upgrade simulation. The GameWith guide corroborates the container, battery and full-night workflow. [Hydroponic system](https://wiki.biligame.com/probablystolen/水培系统) · [GameWith guide](https://gamewith.ai/probably-stolen/zh-hans/specializations/hydroponic-farmer)

| Machine option | Growth points/night | Energy (project kJ/night) | Module behavior |
| --- | ---: | ---: | --- |
| Standard | 8 | 8 | Configurable demo slots |
| Used starter | 9 | 11 | Documented locked configuration |
| Worn starter | 6 | 3 | Documented locked configuration |

The project uses its existing kJ label for the verified numeric energy rates. The default demo vessel remains 6,000 mL. The alternate 3,000 mL water can uses its documented capacity. A vessel switch preserves the whole mixture, including pollutants. It rejects the change if the mixture exceeds the new volume. [Water can](https://wiki.biligame.com/probablystolen/水罐) · [F-OPEN-05 and equipment contract](CALCULATION_CONTRACT.md)

| Supported module | Performance / efficiency / quality, percentage points | Crop-specific effect |
| --- | --- | --- |
| Nutrition Fruit | −10 / −10 / 0 | +1 fruit per installed copy |
| Kotton Automatic Weaving | −50 / −100 / 0 | Equal-count textile instead of fiber, single conversion |
| Performance | +16 / 0 / 0 | General operating effect |
| Efficiency | 0 / +16 / 0 | General operating effect |
| Eco | −16 / +32 / 0 | General operating effect |

The generic modules use fixed source configurations. Random shapes and affixes, stuck-module extraction, expanded grids and the additional crop-specific modules remain deferred. Off-crop modules still contribute their operating modifiers. [Machine modules](https://wiki.biligame.com/probablystolen/机器模组) · [Agriculture module effects](https://wiki.biligame.com/probablystolen/水培农业#水培专用模组) · [Kotton weaving](https://wiki.biligame.com/probablystolen/韧棉种子#模组)

## Calculation and ownership

1. Resolve and freeze genetic properties at planting. The installed equipment is evaluated separately.
2. Sum installed P, E and Q. For the standard unit, F-EQP-01 uses `trunc(8 + trunc(8 × P / 2) / 100)`, F-EQP-02 uses `max(1, 8 − trunc(8 × E / 100))`, and F-EQP-03 uses `trunc(Q / 2)`. A nonpositive growth configuration is rejected. The two used configurations take their documented fixed operating rates.
3. Validate the whole-night energy and solution. Apply the configured crop's fixed mixed draw, mineral uptake per actual growth point, and pre-consumption pollution and mineral damage. Full growth points apply on the final night.
4. Resolve the existing genetically adjusted and health-adjusted quantity. Under neutral equipment quality, Nutrition Fruit adds its flat bonus to the rounded genetic count, which has no health quantity adjustment. Weaving changes the product ID while preserving count and the seed-return schedule. Textile grading remains unresolved.
5. Commit the nightly transaction before notification. Freeze counts, product variant and reproduction at maturity so later equipment changes leave pending results intact.

The typed resolver in `hydroponic_equipment.gd` separates definition data from installed state in the farm. Each installed copy consumes one unit of configurable demo ownership, and removal returns that unit. The farm rejects equipment changes during an active settlement or while the machine runs. The dashboard displays rejection reasons and selected-module details.

The exact positive/negative quality-to-quantity mapping remains open under F-OPEN-06. All supported installed modules are therefore neutral quality and retain existing size thresholds except for the textile variant, which is collected by count. The source documents seed-return suppression for a filler-grass module outside current species. The supported equipment leaves reproduction and fixed draw at ×1. EQP-01/02 cover this package's battery-style path. EQP-03/04, EQP-05 and HRV-03 remain partial for broader reference interactions. [Requirements](REQUIREMENTS.md)

## Verification

| Equipment case | Expected and observed |
| --- | --- |
| Single Nutrition Fruit module | 7 points, 8 kJ, +1 fruit |
| Two Nutrition Fruit modules | 7 points, 9 kJ, +2 fruit |
| Two Performance modules | 9 points, 8 kJ |
| Efficiency module | 8 points, 7 kJ |
| Eco module | 7 points, 6 kJ |
| Kotton Weaving | 6 points, 16 kJ, 250,000 µL fixed draw and 450 µL uptake for the last night |
| Healthy woven Kotton harvest | 13 textiles and 2 offspring, still pending after module removal until collected |
| Modified Nutrition Fruit with two fruit modules | 7 genetically adjusted + 2 equipment = 9 fruit, 21 final points and 27 kJ total |
| Vessel reduction with default solution | Rejected atomically, then succeeds at 3,000 mL after drain |

Fresh isolated import and all 12 suites passed. Results were 900 explicit checks and four original crop assertion groups, zero failures. The equipment suite passed 27 checks. Normal launch loaded the playable dashboard with exit 0, and the legacy Lettuce probe reported `BASELINE_MATCH=true`. The Windows certificate-store diagnostic remains present.

| Neutral fixture | Final growth | Energy (kJ) | Mineral loss (µL) | Pollution at raw index 20 and 8 points |
| --- | ---: | ---: | ---: | ---: |
| Nutrition Fruit | 16 | 16 | 3,148 | 120 |
| Coffee Beans | 24 | 24 | 9,430 | 162 |
| Kotton | 48 | 48 | 46,639 | 605 |

Modified Coffee genetics, reproduction, product/seed capacity and dashboard regression suites passed. M06-A desktop acceptance is user-confirmed. M06-B reproduction and M07-A equipment desktop walkthroughs remain pending.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\run-tests.ps1 -GodotPath $GodotPath -Import
& $GodotPath --headless --path . --verbose --quit-after 10 --log-file "$env:TEMP/m07a-launch.log"
```

## Desktop walkthrough

1. Launch with F5 at 1280 × 720. Open **Gear**. Confirm standard values and inspect the machine, vessel and module selectors. Try switching to the 3 L can before draining and verify the rejection.
2. Install Automatic Weaving, select Kotton, plant and run with sufficient energy. Check the displayed 6 points and 16 kJ per night and the running lock. From the default 100 kJ, replenish energy during the eight-night cycle. At maturity, remove the module and confirm the pending harvest still collects as textile with ordinary seed returns.
3. On a fresh run, choose Nutrition Fruit in a suitable solution and install two Fruit modules. Verify the 7-point, 9-kJ rate and the two extra fruit. Open **Genes** and **Analysis** and check that both dialogs remain readable.

## Changed files and M07-B

- Production · `scripts/hydroponic_equipment.gd` and UID, `scripts/coffee_farm.gd`, `scripts/coffee_dashboard.gd`, `scripts/reference_crop.gd`, and the three reference crop resources.
- Tests · `tests/test_equipment.gd` and UID, `tests/test_equipment.tscn`, and `tests/run-tests.ps1`.
- Documentation · README, calculation contract, requirements, project status, testing report, development log and this report.

For M07-B, use the sourced DNA-editor operation cost, progress, heat and failure rules first. Validate edits against the existing seed resolver before charging resources. Keep editor operation state and RNG separate from farm reproduction, and verify heat and inventory transactions under both success and failure.
