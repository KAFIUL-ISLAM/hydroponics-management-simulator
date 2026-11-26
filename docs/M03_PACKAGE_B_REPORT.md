# M03 Package B — First playable Coffee Beans loop

Normal project launch opens `res://scenes/coffee_dashboard.tscn`, which inherits the existing dashboard. The legacy Lettuce fixture remains directly runnable at `res://scenes/main.tscn`. The existing legacy tests and archived headless probe already select that scene.

## Implementation and ownership

`ReferenceCrop` is shared static data. Coffee Beans has raw/effective target 21, base output 8, draw 100,000 µL, uptake 30 µL/point, mineral band 1.75–3.25%, pollution factor 1.01, annual lifecycle, and three native rank-I traits with complexity zero. `CoffeeFarm` owns the inventory, mutable seed and plant instances, running state, energy and one current `LiquidComposition` vessel. Replanted outputs are independently allocated seeds. Advanced trait and pollution effects are deferred.

The published `GameState` still guards and authorizes nights. The Coffee Farm stages a detached vessel, post-uptake draw, 8 kJ spend, full eight growth points, pre-draw mineral damage, and maturity/output. No events fire during staging or commit. The typed outcome reaches observers after the vessel, energy and plant have all been updated. A shortage advances the day without changing farm state. Invalid concentration is a configuration error and leaves the day unchanged. Stopped or harvest-pending plants use an idle outcome. Pending output has one collection path, and an inventory-capacity failure leaves it intact.

Implemented F-GRW-03, F-HLT-01/02 and the Coffee Beans branch of F-HRV-02, using F-LIQ-01/02/03 and F-MIN-01/02/03 from Package A. The plain unit uses 8 points and 8 kJ per running night. GRW-02/03/04, EQP-01/02, HLT-01/02, HRV-01 and NGT-01 have Coffee-slice evidence. GRW-01 and all cross-crop claims remain partial. See the [requirements](REQUIREMENTS.md).

## Demonstration configuration

| Setting | Value |
|---|---:|
| Vessel capacity | 6,000 mL |
| Initial pure water / minerals | 5,000 / 150 mL |
| Initial battery / energy supply | 100 / 100 kJ |
| Initial beans / bean capacity | 3 / 16 |
| Tablet stock | 10 |
| Water supply | 5,000 mL |
| Water / energy per refill | 500 mL / 24 kJ |

These exported configurations are project demo values. Inventory capacity counts beans only. Supply actions transfer a fixed amount or reject the entire action. Tablets require 15 mL free space. Energy is labeled kJ in reference mode, and the legacy fixture retains kWh.

## Verification

| Healthy three-night reference fixture | Expected | Actual |
|---|---:|---:|
| Growth | 0 → 8 → 16 → 24 | 0 → 8 → 16 → 24 |
| Mixed liquid draw | 300,000 µL | 300,000 µL |
| Direct uptake | 720 µL | 720 µL |
| Total mineral loss | 9,430 µL | 9,430 µL |
| Energy debit | 24 kJ | 24 kJ |
| Pending output | 8 beans | 8 beans |

All seven suites passed after a fresh import, with 618 explicit checks and four original crop assertion groups. The Coffee suite passed 88 checks with zero failures. It drives actual dashboard buttons for planting, start and stop, nights, collecting and replanting. It also verifies atomic failures, health bands, zero-health maturity, capacity, half-even ties, recovery, observer coherence and control bounds at 1280 × 720. The legacy probe returned `BASELINE_MATCH=true` and normal launch loaded the Coffee dashboard. The existing Windows certificate-store diagnostic recurred.

## Manual Godot verification

Import the project with Godot 4.7.2 and press F5. On the bilingual dashboard, click **Plant**, then **Start**, then **Next Night** three times. Check 24/21 growth, 100% score, 76 kJ and eight pending beans. Click **Collect**, then **Plant** again. Water, tablet and energy buttons use the displayed refill quantities. To run the legacy fixture, open `scenes/main.tscn` and press F6. The automated layout check is headless; desktop visual review remains separate.

## Files and next package

Added `scripts/reference_crop.gd`, `scripts/coffee_farm.gd`, `scripts/coffee_dashboard.gd`, their UID files, `resources/coffee_beans.tres`, `scenes/coffee_dashboard.tscn`, and the Coffee test scene/script/UID. Updated `project.godot`, the runner, README and the five milestone documents. Existing M01 scripts and tests retain their legacy behavior.

Recommend M04 add Nutrition Fruit and Kotton with their own data, fixtures and output policies, and resolve mixed-vessel tablet displacement. Pollution, advanced genetics and equipment modifiers remain deferred. No commit or push.
