# M03 Package A — Hydroponic liquid simulation

Package A implements F-LIQ-01/02, the free-space path of F-LIQ-03, and F-MIN-01/02/03. LIQ-01/02/03/04 and MIN-01/02/03 are partial until player actions and settlement use the domain API.

## Ownership and approved policy

`LiquidComposition` owns integer µL components and capacity. It supports pure water, minerals, six harmful pollutants, physical pollution and a generic inert component. External snapshots and consumption results are detached. `replenish()` validates the whole transfer, `plan_night()` is read-only, and `consume_night()` applies only a successful plan. Keep this vessel as the single owner of reference-mode liquid. The M01 ResourceManager and Lettuce scene retain their legacy behavior.

The [reviewed decisions](CALCULATION_CONTRACT.md#reviewed-package-a-project-decisions) are provisional project policy. Zero pure water rejects cultivation. Mineral uptake caps at stock, then the mixture must fund the entire draw. Allocation uses integer quotas, remainder, original volume and ascending stable component ID. Overflow rejects the plan. Tablets need full free capacity. Maturity equality, zero-clamped health, full-precision thresholds, kJ for the new machine, explicit start/stop and one-time collection with retained pending output are recorded for later integration.

## Verification

| Cycle fixture | Expected mineral loss (µL) | Observed (µL) |
|---|---:|---:|
| Nutrition Fruit | 3,148 | 3,148 |
| Coffee Beans | 9,430 | 9,430 |
| Kotton | 46,639 | 46,639 |

The liquid suite passed 77 checks with zero failures. All six suites passed, retaining the five M01 suites. The legacy headless probe reported `BASELINE_MATCH=true`: Day 1 → 2, Growth 0 → 1, Lettuce, 1000 mL water, 50 mL minerals, 100 kWh, final READY. Windows still reported the known certificate-store diagnostic. The separate clean-copy import also passed.

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\tests\run-tests.ps1 -GodotPath "<Godot executable path>" -Import
```

## Next integration and limitations

In M03-B, stage the liquid result with power, plant progress and health, then publish one coherent settlement. Do not independently mirror liquid balances in ResourceManager or commit the liquid before checking the other ledgers. Free-capacity replenishment and tablets are domain operations only. Mixed-vessel displacement is deferred to M04. Tablet stock, gameplay planting, Coffee Beans production, pollution damage, equipment effects, and UI are outside Package A.

Added `scripts/liquid_composition.gd` and its UID, `tests/test_liquid_composition.gd`, its UID and scene. Updated the runner, calculation contract, requirements, status, testing and development logs, and added this report. No commit or push.
