# M06 Package A · Seed genetics and effective crop properties

2026-11-26 · Godot 4.7.2 · Published baseline `08606099404c99cbe1bd28b03573f8a11a9ab0ce` / `v0.2.0`. The tested working tree includes M05.

## Research reconciliation

The genetics wiki documents the three native profiles, the rank exponent, opposing trait pairs, scope restrictions, and different rounding rules for growth and output. The DNA editor page provides the heat increment and treats heat and base complexity separately. The Coffee Beans page provides raw and effective active component volumes. The GameWith guide provides gameplay context. Numeric resolution uses the crop and mechanics tables. [Plant genetics](https://wiki.biligame.com/probablystolen/植物基因) · [DNA editor](https://wiki.biligame.com/probablystolen/DNA编辑器) · [Coffee Beans](https://wiki.biligame.com/probablystolen/咖啡豆#成分) · [Hydroponic farming](https://wiki.biligame.com/probablystolen/水培农业) · [GameWith guide](https://gamewith.ai/probably-stolen/zh-hans/specializations/hydroponic-farmer)

| Trait group and English IDs | Rank-I effect | Complexity per added rank | Supported level and scope |
| --- | --- | --- | --- |
| Fast Growth / Slow Growth | Speed +25% / −25% | +4 / −3 | I–XX, functional, mutually exclusive |
| High Yield / Low Yield | Quantity +20% / −20% | +4 / −3 | I–XX, functional, mutually exclusive |
| Drought Resistant / High Water Use | Draw −25% / +25% | +2 / −1 | I–XX, mutually exclusive, functional with known raw draw |
| Hardy / Fragile | Sensitivity −30% / +30% | +3 / −2 | I–XX, functional, mutually exclusive |
| Complex Genome | +4 complexity per level | Locked offset | II in native Nutrition Fruit. Locked at the species rank |
| Nutritious | Calories +25% | +3 | I–XX on native Nutrition Fruit in this project. Calorie effect is metadata |
| Sterile / Fertile | Seed return −25% / +25% | −1 / +2 | I–XX, mutually exclusive, restricted to eligible species. Seed return is metadata |
| Caffeine Output / Coffee Paste Output | +2,000 / +10,000 µL per item | +3 / +2 | I–XX. Coffee composition analysis functional. Other per-species composition remains metadata |
| Potent / Weak Potency | Active volumes +25% / −25% | +3 / −2 | I–XX, mutually exclusive, requires a modeled active output trait |

The supported editable range is the scope of this package. The reference maximum remains unverified. Reproduction traits are excluded for Coffee Beans. The wiki also restricts nutrition to edible products and disallows perennial plus sterile. Perennial, opposing nutrition traits, editing equipment and crops outside the current three are outside this catalog. No sourced traits in the supported set change mineral uptake, mineral band or the crop resistance factor.

## Resolver and ownership

`CropGenetics` returns a typed result with an independent crop snapshot, trait ranks, multipliers, complexity, heat, sterile rank and an explicit validation failure. Each seed is a separate reference-counted instance with an engine instance ID that remains stable for its lifetime. Species identity comes from its shared crop resource. Planting validates before removing the seed and freezes the resolved configuration for settlement, harvest and analysis. The existing Coffee Beans harvest and replant transfer remains in place.

F-GEN-01 computes `1 + coefficient × rank^0.75` and combines factors for each attribute. The published minimum positive factor protects the division. Growth divides raw points by growth factor, rounds half-even and clamps to at least one. Output multiplies raw count by the yield factor and rounds ties away from zero before health. F-GEN-02 uses raw draw times the water factor, rounded to integer µL. Exact draw half-ties are rejected pending reference evidence. F-GEN-04 starts with native complexity, adds signed cost for added ranks and absolute cost for removed native ranks. A heat increment is `2 + abs(cost)`. Heat is stored but this package has no editing action. F-GEN-05 adds active component volume before potency, then rounds half-even to µL per item.

| Crop | Raw → effective points / count | Native draw | Uptake / band | Sensitivity / resistance | Complexity |
| --- | --- | ---: | --- | --- | ---: |
| Nutrition Fruit | 23 → 16 / 5 → 7 | 100,000 µL | 50 µL/point, 0.50–2.50% | 0.70 / 1.00 | +8 |
| Coffee Beans | 21 → 21 / 8 → 8 | 100,000 µL | 30 µL/point, 1.75–3.25% | 1.00 / 1.01 | 0 |
| Kotton | 32 → 43 / 9 → 13 | 250,000 µL | 75 µL/point, 2.00–5.00% | ≈1.50454 / 1.26 | 0 |

Native traits come from the existing resources. Unchanged ranks preserve native-effective values per property and avoid modifier duplication. Changed ranks use raw inputs where available. Kotton's unresolved raw draw blocks its water-trait changes only. Coffee with Fast Growth II, High Yield III, Drought Resistant I and Hardy I resolves to 15 points, 12 healthy items, 75,000 µL per running night, 0.70 sensitivity and +25 complexity. Coffee's native component calculations yield 8,000 µL caffeine and 44,800 µL paste per item. These components are exposed in analysis only.

## Verification

| Suite | Result |
| --- | --- |
| Crop resource | PASS · four assertion groups |
| Resource Manager | PASS · 192 checks |
| Night state | PASS · 133 checks |
| Dashboard startup | PASS · 31 checks |
| Genetics | PASS · 46 checks |
| Pollution | PASS · 66 checks |
| Three crop farming | PASS · 101 checks |
| Coffee farming | PASS · 94 checks |
| Liquid composition | PASS · 77 checks |
| Nightly integration | PASS · 97 checks |

Fresh isolated import and all ten suites passed with **837 explicit checks** and zero failures. Clean crop mineral losses stayed at **3,148 / 9,430 / 46,639 µL** for Nutrition Fruit, Coffee Beans and Kotton. Raw index 20 and eight growth points still cause **120 / 162 / 605** health units of pollution damage respectively. The default playable dashboard launched, and the archived Lettuce probe exited 0 with `BASELINE_MATCH=true`. The existing Windows certificate-store diagnostic was observed.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\run-tests.ps1 -GodotPath $GodotPath -Import
& $GodotPath --headless --path . --quit-after 10 --log-file "$env:TEMP/m06a-launch.log"
```

The M05 desktop screenshot verifies the Physical pollution display at 1280 × 720, including 24,512 µL physical pollution and zero last-night pollution damage. Other M05 desktop scenarios remain unconfirmed. [M05 evidence](M05_REPORT.md)

## Desktop walkthrough

1. Press F5 and select each crop at 1280 × 720. Open **Genes** and compare the native raw and effective values above.
2. Plant a seed and reopen **Genes** to inspect the planted configuration. Verify that **Analysis** still opens and that **Next Night** remains visible.
3. For a modified configuration, the automated fixture injects traits before planting. The shipped interface is inspection-only.

M06-A bindings and bounds passed headlessly. Desktop acceptance remains pending.

## Changed files and M06-B

- Production · `scripts/crop_genetics.gd`, its UID, `scripts/reference_crop.gd`, `scripts/coffee_farm.gd`, `scripts/coffee_dashboard.gd`, `resources/coffee_beans.tres` and `resources/nutrition_fruit.tres`.
- Tests · `tests/test_genetics.gd`, its UID, `tests/test_genetics.tscn` and `tests/run-tests.ps1`.
- Documentation · README, calculation contract, requirements, project status, testing report, development log, M05 report and this report.

For M06-B, reconcile F-GEN-03 seed attempt counts, probability boundaries and insufficient-capacity handling before adding new seed returns. Use deterministic RNG fixtures and prove offspring independence and heat reset. Keep Coffee Beans' existing plantable output and ensure it receives no duplicate seed grant. Kotton raw draw, draw half-ties, the reference maximum rank and additional species composition remain open.
