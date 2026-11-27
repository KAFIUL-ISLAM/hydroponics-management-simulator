# Workshop demonstration guide

This route is designed for an evaluator using the supplied Windows standalone package. For source-based testing, use the Godot project and the reproducibility command at the end. The package's EXE and PCK must remain together.

## Core cultivation loop

1. Launch `Game/Orbital Hydroponics.exe`.
2. Open the Farming Manual with the **?** button or **F1**. The **Quick Start** tab introduces Coffee cultivation; **Advanced** links to the existing analysis and workstation tools. Close and reopen it without changing the selected inventory item.
3. Hover inventory icons to identify seeds and supplies. Double-click the cultivation chamber, then drag a Coffee Beans seed into its seed slot. The machine starts automatically.
4. Inspect the water, mineral concentration, and energy state. Press **Next Night** to advance the simulation. Continue until the crop is mature.
5. Click output icons to collect items individually. Coffee Beans output is plantable; collect it and drag a seed back to replant. Nutrition Fruit and Kotton produce are not planting seeds; offspring seeds appear as separate output.
6. If the machine is blocked, inspect the highlighted slot and its explanation. Recover power by dragging an energy cell to the power slot; recover solution by using available water or a mineral tablet. Supplies are finite and modules are optional.

## Optional technical demonstrations

- **Liquid Analysis:** compare the current mineral concentration with the crop's preferred range and inspect pollution.
- **Equipment:** inspect machine and vessel settings, module costs, growth and energy modifiers. Equipment changes are restricted while the machine is running.
- **Seed Analysis:** inspect the selected seed or the planted crop and compare its effective traits.
- **DNA Editor:** preview a compatible trait application, then explain its power and finite demonstration-disc costs before starting.
- **Audio Settings:** adjust master and SFX levels or mute all effects. The settings are bilingual and saved locally. The candidate uses one-shot effects, not continuous machinery ambience.
- **Reduced Motion:** repeat collection and tool navigation with the option enabled; verify that feedback remains readable and cultivation results are unchanged.

## Deterministic Kotton comparison

The comparison uses native Kotton, 5,000 mL pure water, 100 kJ, the Standard machine, no optional modules, no added pollution, and RNG seed 42. The initial mineral volume (50 mL versus 150 mL) is the only changed input. It measures 52% versus 100% final health and 12 versus 13 fiber, with six nights and 48 kJ in both runs. These results belong to this controlled fixture and are not universal crop predictions.

To reproduce it, use the source project with Godot 4.7.2; the Windows standalone package does not expose this command:

```text
Godot --headless --debug --path . res://tests/test_m10_nutrient_demo.tscn
```

Full results and the calculation steps are in the [Chinese technical analysis](HYDROPONICS_DESIGN_ANALYSIS_ZH.md). The measured fixture output and test evidence are in the [testing report](TESTING_REPORT.md).
