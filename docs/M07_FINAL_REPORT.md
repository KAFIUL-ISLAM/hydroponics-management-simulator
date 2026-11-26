# M07 · Advanced farming mechanics checkpoint

2026-11-26 · Godot 4.7.2 · Previous published baseline `v0.2.0` / `08606099404c99cbe1bd28b03573f8a11a9ab0ce`

## Delivered scope

| Milestone | Implemented scope and evidence |
| --- | --- |
| M05 | POL-01 and the implemented POL-02 scope. Six harmful pollutants, pure-water concentration, crop sensitivity and resistance, combined nightly health, analysis and scenarios. [M05 report](M05_REPORT.md) |
| M06 | GEN-01–04 across the supported trait catalog and three-crop reproduction rules. Effective properties are frozen at planting, seed returns resolve once at maturity, and offspring own their traits and start at zero heat. Individual seed selection and the validated Coffee demo support repeatable gameplay. [Genetics](M06_PACKAGE_A_REPORT.md) · [Reproduction](M06_PACKAGE_B_REPORT.md) |
| M07 | EQP-01/02 and supported EQP-03/04 functionality. Three machines, five modules, two vessels and atomic equipment changes. F-GEN-06 supports plain-editor trait application with previews, locking, nightly costs and outcome tracking. [Equipment](M07_PACKAGE_A_REPORT.md) · [DNA editor](M07_PACKAGE_B_REPORT.md) |

The shared farm stages liquid and growth using a detached snapshot and commits before completing the GameState night. An available seed can be reserved by the separate DNA editor model, which advances once per accepted day after cultivation and owns independent RNG. Equipment resolves independently of plant genetics. The dashboard reads typed settlement and preview results. The legacy Lettuce scene remains available directly.

F-POL-01–03 define pure-water pollutant indices and per-point combined damage. F-GEN-01–06 define the supported trait calculations, seed returns, heat and editor risk. F-EQP-01–03 define aggregate module points, truncation and full-night power. See the contract for point-of-use source references and open questions. [Calculation contract](CALCULATION_CONTRACT.md) · [Requirements traceability](REQUIREMENTS.md) · [Agriculture](https://wiki.biligame.com/probablystolen/水培农业) · [Plant genetics](https://wiki.biligame.com/probablystolen/植物基因) · [Hydroponic equipment](https://wiki.biligame.com/probablystolen/水培系统) · [DNA editor](https://wiki.biligame.com/probablystolen/DNA编辑器)

## Fresh release regression

All 13 suites passed, with 932 explicit checks and four original crop assertion groups. The runner checked completion markers, exit codes and script errors. The default launch loaded the playable dashboard with exit 0. The archived Lettuce probe returned `BASELINE_MATCH=true` with exit 0. The Windows certificate-store diagnostic was present.

| Native crop | Final growth | Energy (kJ) | Draw (µL) | Uptake (µL) | Mineral loss (µL) | Pollution loss at raw index 20 / 8 points |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Nutrition Fruit | 16 | 16 | 200,000 | 800 | 3,148 | 120 |
| Coffee Beans | 24 | 24 | 300,000 | 720 | 9,430 | 162 |
| Kotton | 48 | 48 | 1,500,000 | 3,600 | 46,639 | 605 |

| Advanced fixture | Verified result |
| --- | --- |
| Modified Coffee | 15 target points, 12 healthy beans, 75,000 µL/night, 0.70 sensitivity, complexity +25 |
| Reproduction | Sterile X sequence `[1,0,0]` for the specified rolls, Fertile I sequence `[2,1]`, healthy Kotton 2 offspring, Coffee no separate grant, zero offspring heat |
| Equipment | Standard 8/8, used 9/11, worn 6/3 points/kJ per night. Weaving 6/16, dual Nutrition Fruit modules 7/9 plus 2 fruit, 3 L vessel rejects excess solution |
| DNA editing | Native Coffee Fast Growth I takes 20 points, 2 nights and 24 kJ with 95% success. Success consumes one disc use and adds 6 heat. Failure retains ranks and disc and also adds 6 heat. Edited cultivation, inheritance and seed locking passed |

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\run-tests.ps1 -GodotPath $GodotPath -Import
```

## Desktop evidence

- User-confirmed manual gameplay covers M05 acceptance, both M06 packages, the M07-A equipment checklist, and M07-B preview cancellation, two-night editing, heat and disc accounting, and planting and harvesting the edited seed.
- The repository screenshots verify presentation of the liquid analysis and equipment dialogs. The separate physical-pollution screenshot supplied in conversation is recorded in the M05 report. Headless tests separately verify dialog bindings and bounds. [Analysis screenshot](../screenshots/pollution_analysis.png) · [Equipment screenshot](../screenshots/equipment_management.png) · [Physical-pollution evidence](M05_REPORT.md)

## Partial and deferred requirements

- DNA extraction and rank reduction, editor cooling and modules, reference disc acquisition, and active beta cancellation remain deferred. Disc supplies are finite demo stock. Cultivation has priority on the shared project battery.
- Reference module shapes and grid expansion, nonneutral quality-to-quantity mapping, and textile grading remain open. Demo slots are abstract, and the used machines model fixed locked configurations.
- Persistent readable seed IDs and warehouse overflow remain open. The current inventory keeps a complete harvest pending if it cannot fit.
- Fractional pollution boundaries and final rounding, proportional tablet displacement for mixed solutions, and the Nutrition Fruit fractional size gap use documented project policies. Kotton raw draw and several other reference edge cases remain unresolved.

Recommended M08 scope is to reconcile perennial mother retention, regrowth targets, product-state rules and overflow behavior before implementation. Prioritize reproducible acceptance evidence against the December 1 delivery deadline. M08 remains pending.
