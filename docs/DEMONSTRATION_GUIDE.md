# Workshop demonstration guide

The ordinary demo uses the normal workshop and its visible resources. Do not use the Remote Inspector or test scenes as shortcuts during normal play.

## Normal gameplay

1. Open the project in Godot 4.7.2 and press **F5**. The default scene is the orbital workshop.
2. Click the **?** button or press **F1** to open the optional farming manual. Review **Quick Start** for the Coffee Beans loop or **Advanced** for tools and blocker recovery. Dismiss it without changing the selected inventory item.
3. Hover inventory icons to identify seeds and supplies. Double-click the cultivation chamber, then drag a Coffee Beans seed into the seed slot. The machine starts automatically. Inspect the water, mineral concentration, and energy state before advancing with **Next Night**.
4. Continue advancing nights until the crop is ready. Click output icons to collect items individually. Coffee Beans output is plantable; collect it and drag a seed back to replant. Nutrition Fruit and Kotton produce are not planting seeds; offspring seeds appear as separate output.
5. If the machine is blocked, inspect the highlighted slot and its tooltip. A power shortage can be recovered by dragging an energy cell to the power slot; a solution shortage can be addressed with available water or a mineral tablet. Keep in mind that supplies are finite and modules are optional.

## Optional tool demonstrations

- **Liquid Analysis:** open the existing analysis tool from the workshop's analysis controls or the manual's Advanced tab. Compare the current mineral concentration with the crop range and inspect pollution.
- **Equipment:** open the machine chassis/equipment controls or use the manual shortcut. Show standard-machine costs and the optional module effects; changes are restricted while the machine is operating.
- **DNA Editor:** open the DNA tool from the manual or existing tool control, select a seed, and preview an eligible trait application. Explain the power and demo-disc costs before starting.

## Debug-only demonstrations

These are test aids, not normal gameplay instructions.

- To reproduce the battery recovery sequence in a running debug scene, set `CoffeeFarm.energy_kj` to `8` in Godot's **Remote Inspector** before the first operating night. Plant Coffee Beans, advance twice to reach the shortage, then drag one energy cell immediately after the warning. Confirm the warning clears and exactly one refill is transferred. Do not alter the energy value during the ordinary demo.
- To compare the two deterministic Kotton setups without interactive play, run this test scene from the project root:

  ```text
  Godot --headless --debug --path . res://tests/test_m10_nutrient_demo.tscn
  ```

  The fixture varies only starting minerals (50 mL versus 150 mL); its controlled conditions and measured results are documented in the [M10 report](M10_FINAL_REPORT.md) and [Chinese design analysis](HYDROPONICS_DESIGN_ANALYSIS_ZH.md).
