# M07 Package B · DNA editor and genetic modification

2026-11-26 · Godot 4.7.2 · Published baseline `v0.2.0`, `08606099404c99cbe1bd28b03573f8a11a9ab0ce`

## Research and implemented scope

The plain editor applies one rank from a compatible trait disc. A successful application consumes one disc use. Failure preserves the disc and target ranks. Both outcomes add heat. The reference also describes extraction, where target survival depends on a stability module, and cancellation on its beta branch. This package implements application only. It uses the existing I–XX project scope where applicable. The game-wide editable cap remains unverified. Previously documented locked genome, opposing trait, sterility and species constraints remain in effect. [DNA editor revision 11303](https://wiki.biligame.com/probablystolen/index.php?title=DNA编辑器&oldid=11303) · [Plant genetics](https://wiki.biligame.com/probablystolen/植物基因) · [Agriculture](https://wiki.biligame.com/probablystolen/水培农业) · [GameWith guide](https://gamewith.ai/probably-stolen/zh-hans/specializations/hydroponic-farmer)

Supported disc applications are the positive and negative growth, yield, draw, pollution sensitivity and reproduction pairs. The preview rejects conflicting ranks, species-incompatible traits, Kotton water-trait changes with unknown raw draw, unavailable seeds and insufficient disc or first-night power. Static crop resources remain shared and immutable. Trait extraction, reduction, new cooling operations, editor modules and active beta cancellation remain unavailable. Offspring still inherit traits and reset heat under the farming rules.

## Calculation and transaction

1. Resolve the seed's current traits and pre-operation heat using `CropGenetics`. Preview the next rank and resulting effective properties without changing seed, charges or RNG.
2. For F-GEN-06, effective complexity is `E = current genetic complexity + current heat`. Required progress is `20 + 4 × max(0, E)`. At neutral editor quality the chance is `max(5, 95 − 5 × max(0, E))%`. The documented module-quality term, `trunc(Q / 2)`, is deferred. Heat has no additional lock threshold in the supported source.
3. Confirming a valid preview moves the editor to RUNNING, locks the exact owned seed and reserves the operation. Starting leaves seed ranks, heat, disc balance and power unchanged. Closing an unconfirmed preview cancels it.
4. Day-advancing settlement funds cultivation first, then funds at most one editor tick from the shared project battery. Each funded tick costs 12 kJ and advances up to 10 points, with full cost on the finishing night. Shortage pauses, without progress or a roll. A farm configuration error blocks the day and editor tick. This shared-battery priority is a project choice.
5. At the progress threshold, resolve a single roll with the editor's independent RNG. Tests inject deterministic samples. The project uses strict `roll < probability`. Success commits the added rank and spends one disc use. Failure preserves ranks and the charge. Apply `2 + abs(trait complexity cost)` heat to either result (F-GEN-04), release the seed before completion notification, and retain the outcome for inspection.

The domain model lives in `dna_editor.gd`. The farm keeps ownership of inventory and energy and runs the editor under the existing settlement permit. Its disc inventory starts with three configurable demo uses per supported trait. This is a project supply setting. Reference DNA disc acquisition, output tray mechanics and editor-exclusive battery slots are outside this slice. The editor refuses to start a second operation while RUNNING, and cultivation and confirmed discard both refuse its locked seed. The editor's RNG is separate from farming reproduction.

## Fixtures and regression results

| Fixture | Expected and observed |
| --- | --- |
| Native Coffee Beans, apply Fast Growth I | 20 points, 2 nights, 24 kJ, 95%; on success target 17, complexity +4, heat 6 |
| Native Nutrition Fruit, raise High Yield II to III | 52 points, 6 nights, 72 kJ, 55% |
| Native Coffee at heat 18 | 92 points and the 5% minimum chance |
| Forced Coffee completion sample 0.95 at 95% | Failure, native ranks retained, heat +6 |
| Forced sample 0.949 at 95% | Success, new rank and heat +6 |
| Successful edited Coffee replant path | Modified target used in cultivation and inherited by harvested beans with offspring heat zero |
| Runtime failure at 5% | Seed and disc retained, heat increased from 22 to 28 |

A fresh isolated import passed all **13 automated suites**, with **932 explicit checks and four original crop assertion groups**. The new editor suite passed 30 checks covering fixture costs, compatibility, locking, pause, invalid samples, RNG, successful and failed transactions, UI bindings and bounds. There were zero test failures.

| Neutral crop fixture | Final growth | Energy (kJ) | Mineral loss (µL) | Pollution loss at index 20 / 8 points |
| --- | ---: | ---: | ---: | ---: |
| Nutrition Fruit | 16 | 16 | 3,148 | 120 |
| Coffee Beans | 24 | 24 | 9,430 | 162 |
| Kotton | 48 | 48 | 46,639 | 605 |

The default dashboard loaded successfully and the archived Lettuce probe reported `BASELINE_MATCH=true`. The modified Coffee, reproduction and equipment suites passed. The known Windows certificate-store diagnostic was observed.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\run-tests.ps1 -GodotPath $GodotPath -Import
& $GodotPath --headless --path . --quit-after 10 --log-file "$env:TEMP/m07b-launch.log"
```

## Desktop walkthrough and checkpoint readiness

1. Launch at 1280 × 720. Open **Genes**, then **DNA edit**. Select a native Coffee seed and Fast Growth. Check 20 points, 24 kJ and 95%. Close before confirming and check that a seed is still available to plant.
2. Reopen and confirm. Close the dialog and settle two nights. Reopen to inspect progress and final outcome. Check that both outcomes apply heat and that the disc use is spent only on success.
3. After a successful edit, plant that same seed and complete cultivation. Inspect a collected bean to confirm inheritance and zero heat.

M06-B desktop acceptance is user-confirmed. The user supplied a screenshot of the M07-A equipment dialog. That is dialog evidence, and remaining equipment walkthrough checks still need confirmation. M07-B has headless UI verification and awaits desktop acceptance. The v0.3.0 checkpoint has passed the automated gate and awaits owner review, desktop evidence and separate publication authorization. [Equipment screenshot](../screenshots/equipment_management.png)

## Changed files

- Production · `scripts/dna_editor.gd` and UID, `scripts/coffee_farm.gd`, `scripts/coffee_dashboard.gd`.
- Tests · `tests/test_dna_editor.gd` and UID, `tests/test_dna_editor.tscn`, `tests/run-tests.ps1`.
- Documentation · README, calculation contract, requirements, status, testing report, development log and this report.
