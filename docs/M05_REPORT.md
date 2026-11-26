# M05 · Pollution simulation and combined plant health

2026-11-26 · Git baseline `08606099404c99cbe1bd28b03573f8a11a9ab0ce` (`v0.2.0`) · Godot 4.7.2

## Reconciled contract

The agriculture wiki identifies six harmful components. The project uses stable local enum identifiers. Reference engine identifiers remain unverified. Physical pollution and inert constituents occupy volume and are drawn with the solution. The wiki limits direct crop damage to the six harmful components. The GameWith overview did not provide an independent damage table or settle rounding. [BWIKI agriculture, pollution damage](https://wiki.biligame.com/probablystolen/水培农业#污染损害) · [GameWith hydroponic farmer guide](https://gamewith.ai/probably-stolen/zh-hans/specializations/hydroponic-farmer)

| Component | Local identifier |
| --- | --- |
| 重金属 · Heavy metals | `HEAVY_METALS` |
| 化学污染物 · Chemical pollutants | `CHEMICALS` |
| 微生物 · Microbes | `MICROBES` |
| 有机废物 · Organic waste | `ORGANIC_WASTE` |
| 酸 · Acid | `ACID` |
| 碱 · Alkali | `ALKALI` |
| 物理污染 · Physical pollution | `PHYSICAL_POLLUTION` |
| 惰性 · Inert constituents | `INERT` |

| Published effective tier input | Base health units per growth point |
| --- | ---: |
| 0–10 | 0 |
| 11–15 | 15 |
| 16–20 | 20 |
| 21–25 | 30 |
| 26–30 | 40 |
| 31–40 | 60 |
| 41–60 | 80 |
| 61–100 | 160 |
| 101–200 | 320 |
| Above 200 | 640 |

F-POL-01 / POL-01 uses `10,000 × pollutant µL ÷ pure-water µL`. This is a dimensionless scaled index. Zero pure water yields undefined analysis. F-POL-02 scales the index by native sensitivity before tier lookup. F-POL-03 multiplies the tier damage by the crop resistance factor and growth points for each component, then sums. Factors come directly from the wiki. Native sensitivities are the existing project contract values, with Kotton stored to the recorded precision. [Calculation contract](CALCULATION_CONTRACT.md) · [Requirement traceability](REQUIREMENTS.md)

| Crop | Native sensitivity | Resistance factor | Effective exposure at raw index 20 | Nightly damage at 8 points |
| --- | ---: | ---: | ---: | ---: |
| Nutrition Fruit | 0.70 | 1.00 | 14 | 120 |
| Coffee Beans | 1.00 | 1.01 | 20 | 161.6 → 162 |
| Kotton | approximately 1.50454 | 1.26 | 30.0908 | 604.8 → 605 |

The published lookup gives 0 damage at tier 10 and 20 at tier 20. Contract-derived numerical checks give raw index 20 for 2,000 µL pollutant in 1,000,000 µL pure water, and raw nightly damage 201.6 for Kotton at an already-effective exposure of 20. An independent published worked example for final rounding was unavailable.

Under provisional F-OPEN-04 policy, fractional effective values use the next tier above each inclusive upper bound. Exposure 10.5 selects the 15-damage tier. Component values retain their fractional health units until the nightly sum is rounded once to the nearest unit, with half units rounded up. Native traits are already reflected in the stored sensitivity.

## Architecture and settlement

`PollutionAnalysis` reads a detached dictionary snapshot of `LiquidComposition`, the sole liquid ledger. Its typed result carries component volumes, raw and effective exposures, selected tier, base and final losses, and crop factors. The farm uses the pre-draw snapshot to calculate damage, stages uptake and proportional draw in a detached vessel, then commits liquid, energy, growth, clamped health and any mature harvest before GameState emits completion. Idle and rejected nights preserve liquid and health. The outcome distinguishes nominal mineral damage and rounded pollution damage from actual clamped health loss.

## Verification

| Suite | Result |
| --- | --- |
| Crop resource | PASS · 4 original assertion groups |
| Resource manager | PASS · 192 |
| Night state | PASS · 133 |
| Dashboard startup | PASS · 31 |
| Pollution | PASS · 66 |
| Three crop farming | PASS · 100 |
| Coffee farming | PASS · 93 |
| Liquid composition | PASS · 77 |
| Nightly integration | PASS · 97 |

All 789 explicit checks passed with zero failures. The two existing farming suites now include the extra dashboard buttons in their bounds checks. Default headless launch loaded the playable scene and exited 0. The archived Lettuce probe printed `BASELINE_MATCH=true` and exited 0. The established Windows certificate-store diagnostic was observed. The regression used a fresh isolated project copy.

| Clean crop fixture | Nights | Final growth | Energy (kJ) | Draw (µL) | Uptake (µL) | Mineral loss (µL) | Harvest |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Nutrition Fruit | 2 | 16 | 16 | 200,000 | 800 | 3,148 | 7 giant |
| Coffee Beans | 3 | 24 | 24 | 300,000 | 720 | 9,430 | 8 plantable |
| Kotton | 6 | 48 | 48 | 1,500,000 | 3,600 | 46,639 | 13 large |

The combined Coffee Beans fixture gives 800 mineral damage and 10,342 nominal pollution damage, with actual health loss clamped to 10,000. After one night the fixture retains 196,330 µL heavy metals and 92 kJ and gains eight growth points. After three running nights it yields four beans at zero health. The test observes the coherent state through the completion signal. Tablet displacement removed 3,000 µL of pollutant from a full vessel containing 800,000 µL water and 200,000 µL pollutant.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\run-tests.ps1 -GodotPath $GodotPath -Import
& $GodotPath --headless --path . --verbose --quit-after 10 --log-file "$env:TEMP/m05-launch.log"
```

## Desktop walkthrough

1. Run the project with F5 at 1280 × 720 and open **Analysis**. Inspect water, minerals, vessel capacity, raw indices and effective exposures.
2. Choose each demo in turn. All demos stage 5,000,000 µL water and 100,000 µL minerals. Single adds 10,000 µL heavy metals. Multiple also adds 15,000 µL chemicals. Physical adds 25,000 µL physical pollution. High adds 200,000 µL each of heavy metals and acid. These are project demo settings.
3. Cancel a replacement and confirm that the previous solution remains. Then confirm a polluted replacement, plant and run one night. Check growth, the separate damage values, health, score and the last-night breakdown in **Analysis**.

The user reported completing the M05 desktop acceptance checklist. A screenshot supplied in conversation at 1280 × 720 shows Coffee Beans on Day 4 and READY with 24,512 µL physical pollution, zero harmful pollutants and zero last-night pollution damage. The dashboard shows +8 growth, zero mineral damage and health loss, and resulting health 9,515 (95.15%). The separate repository screenshot shows the clean analysis and the scenario menu. Dialog geometry and bindings also passed headless tests. [Repository analysis screenshot](../screenshots/pollution_analysis.png)

## Changed files and next milestone

- Production · `scripts/pollution_analysis.gd`, `scripts/pollution_analysis.gd.uid`, `scripts/coffee_farm.gd`, `scripts/coffee_dashboard.gd`
- Tests · `tests/test_pollution.gd`, `tests/test_pollution.gd.uid`, `tests/test_pollution.tscn`, `tests/run-tests.ps1`
- Documentation · `README.md`, `docs/CALCULATION_CONTRACT.md`, `docs/REQUIREMENTS.md`, `docs/PROJECT_STATUS.md`, `docs/TESTING_REPORT.md`, `docs/DEVELOPMENT_LOG.md`, `docs/M05_REPORT.md`

Reference fractional classification and rounding remain open. Filtration, equipment, dynamic genetics and reproduction remain deferred. For M06, reconcile inheritance and seed-return rules, add deterministic trait and reproduction fixtures, and use M05's native-sensitivity comparisons as regression baselines. Preserve the existing Coffee Beans replant path.
