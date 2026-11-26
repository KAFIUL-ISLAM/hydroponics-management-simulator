# Project status

**As of 2026-11-26** · **Completed milestone M01 — Foundation stabilization**

M01-T01 through M01-T07 established the project baseline and stabilized resource and settlement logic. Package C completed dashboard synchronization, settlement feedback, integration tests, and the migration to `tests/`. The user approved the foundation and reported a successful final desktop smoke check. The checkpoint regression rerun passed all five suites with 453 explicit checks and four original crop assertion groups. [Foundation plan](FOUNDATION_STABILIZATION_PLAN.md) · [Final M01 report](M01_FINAL_REPORT.md)

## Git baseline and evidence

- The M01 working changes were based on `7b282e24dfff65957f8d181126c67da5498b7e2d` (`resources and simulator added`). The final pre-commit fetch found `main` and `origin/main` aligned at that revision. `02f30ca` introduced the dashboard, and `1694ee5` added initial research and design documentation.
- The audit describes the earlier, clean audit snapshot. Package B started with the prior uncommitted main-scene, resource validation, and documentation changes, plus untracked tests, reports, and screenshots.
- The [project audit](PROJECT_AUDIT.md) is the implementation baseline. **Implemented** below means the behavior is present in source. M01-T02 verified the explicit scene and one night. The user independently verified rendering and the physical button click at 1280 × 720. M01-T03 added the dashboard as the default scene and verified it from a freshly imported temporary project. The existing one-night probe and four crop-resource test groups still pass. [M01-T02 results](M01_T02_REPORT.md) · [Manual evidence](TESTING_REPORT.md#8-2026-11-26--user-manual-verification-of-the-m01-t02-baseline) · [M01-T03 results](M01_T03_REPORT.md)

## Architecture

The project declares Godot 4.7 and GL Compatibility. M01-T02 verified `4.7.2.stable.official.ed1daf0bf` from the installed Windows executable. The existing dashboard is a native `Control` scene targeting 1280 × 720. There are no autoloads. The scene owns `GameState` for day/status and crop selection, `ResourceManager` for water and mineral reserves in ml and electricity in kWh, and `HydroponicsSimulator` for the nightly crop update. The dashboard controller sends the night action and renders signals. `CropData` is a shared crop resource definition. `lettuce_prototype.tres` is the only crop resource and its production values are provisional. [Project config](../project.godot#L11) · [Scene wiring](../scenes/main.tscn#L419) · [Dashboard controller](../scripts/main.gd#L15) · [Crop resource](../resources/lettuce_prototype.tres#L5)

## Feature status

| Status | Current scope |
|---|---|
| Implemented in source | Button-driven day progression, scalar resource balances with query/add/spend operations, crop definition and trait validation helpers, and dashboard bindings for day, status, reserves, and crop identity. [GameState](../scripts/game_state.gd#L35) · [ResourceManager](../scripts/resource_manager.gd#L26) · [CropData](../scripts/crop_data.gd#L65) · [Dashboard bindings](../scripts/main.gd#L15) |
| Partial | One preselected lettuce, a growth counter that increments by one on eligible nights, fixed water/mineral costs, electricity storage, and an equipment panel with static labels. Genetics exists as fields and validation on `CropData`. The default lettuce has zero nightly costs and no maturity check. Synchronous settlement rejects pause. [Night processing](../scripts/hydroponics_simulator.gd) · [Crop defaults](../scripts/crop_data.gd#L37) · [Equipment panel](../scenes/main.tscn#L228) |
| Missing | Player planting and replenishment, seed/plant instances, configured GDD crops, maturity and harvest, reproduction and trait effects, solution composition and mineral concentration, per-point uptake and liquid carry-off, plant health, pollution, power gating, functional equipment and modifiers, and item inventory. The GDD also proposes detailed resource records and optional economy and upgrades. [Crop requirements](GDD.md#L525) · [Prototype priorities](GDD.md#L692) |
| Verified in M01-T02 and M01-T03 | The dashboard loads by explicit scene path and now loads as the default scene. One night advances Day 1 → 2 and Growth 0 → 1, returns to `READY`, and leaves reserves at 1000 ml water, 50 ml minerals, and 100 kWh. The four checked-in crop test groups passed before and after the change. The user verified desktop rendering and physical input in the M01-T02 follow-up. [Testing report](TESTING_REPORT.md#8-2026-11-26--user-manual-verification-of-the-m01-t02-baseline) · [M01-T03 results](M01_T03_REPORT.md) |
| Verified in M01-T04 | The ResourceManager scene passed 118 checks, and a deliberate failed expectation in a temporary copy returned exit 1. The original crop test, one-night dashboard probe, and normal headless launch also passed. [M01-T04 results](M01_T04_REPORT.md) |
| Verified in Package B | Configured initial balances reset as a coherent snapshot. Nightly resource debits are atomic. Accepted nights publish a typed terminal outcome with stable state. The resource and night suites passed 192 and 133 checks, respectively. Both negative controls detected their forced failure. Default launch, all four crop groups, and the original Lettuce probe passed. [Package B results](M01_PACKAGE_B_REPORT.md) |
| Verified in Package C | Dashboard startup uses live state, including configured values and growth emitted before the UI connects. Bilingual outcomes distinguish growth, shortage, configuration error, and idle nights. The five suites passed after a fresh import from the migrated `tests/` paths, as did normal launch and the original Lettuce probe. [Package C results](M01_PACKAGE_C_REPORT.md) |
| User-verified at the M01 checkpoint | The user reported that the final desktop smoke check passed. The earlier Day 1 and Day 2 screenshots document the M01-T02 baseline. [Day 1](../screenshots/m01-t02-baseline-day1.png) · [Day 2](../screenshots/m01-t02-baseline-day2.png) |
| Unverified | Narrow-window layout, export, and later farming mechanics. The automated target-viewport layout check passed at 1280 × 720. [Final M01 report](M01_FINAL_REPORT.md) |

## Known defects and risks

| Evidence | Finding |
|---|---|
| Resolved in M01-T03 | Godot previously refused default launch. `run/main_scene` now references the dashboard UID and normal headless launch succeeds after a fresh import. [Project config](../project.godot#L14) · [Runtime report](M01_T03_REPORT.md) |
| Confirmed from source | The default lettuce grows without a resource debit and has no maturity cap. Electricity is outside settlement. [Crop defaults](../scripts/crop_data.gd#L37) · [Simulator](../scripts/hydroponics_simulator.gd#L34) |
| Resolved in M01-T08–T09 | The dashboard initializes from live state and uses the typed finished outcome for feedback. The machine stats remain placeholders. [Dashboard controller](../scripts/main.gd) |
| Resolved in M01-T04 | Resource operations reject unknown types, invalid amounts, invalid selected balances, and overflowing credits. A known, valid shortage has its own signal, and invalid lookups retain the documented `0.0` fallback. [ResourceManager](../scripts/resource_manager.gd#L26) · [Verification](M01_T04_REPORT.md) |
| Resolved in M01-T05 | Reset restores the balances captured at first readiness, including scene overrides. A pre-initialization reset leaves configuration intact. [ResourceManager](../scripts/resource_manager.gd) |
| Resolved in M01-T06 | Nightly water and minerals are debited as one transaction. Growth advances only on batch success, and a zero-cost batch emits no resource snapshot. [ResourceManager](../scripts/resource_manager.gd) · [Simulator](../scripts/hydroponics_simulator.gd) |
| Resolved in M01-T07 | A shortage advances the day without crop growth or debits. Configuration errors leave the day unchanged. GameState blocks reentry, crop changes, and pause during the synchronous night, and completion observers see finalized state. These are provisional engineering policies. [GameState](../scripts/game_state.gd) · [Package B results](M01_PACKAGE_B_REPORT.md) |
| Remaining risk | Runtime writes to exported balances can bypass validation and reach a snapshot or become the initial captured values. The batched API validates only the affected balances. [ResourceManager](../scripts/resource_manager.gd) |

## Documentation discrepancies

- Current test scenes and the Windows runner live in `tests/`. Archived reports retain the paths used when their commands were recorded. [README](../README.md#run-the-automated-tests-on-windows) · [Test runner](../tests/run-tests.ps1)
- The GDD header reflects the design/research phase and the technical design describes the data/simulation layer as future work. The current scene already has those nodes. The GDD's three priority crops remain planned, while the scene uses provisional lettuce. [GDD header](GDD.md#L7) · [Technical design](TECHNICAL_DESIGN.md#L84) · [Scene wiring](../scenes/main.tscn#L419)
- The development log's five historical trait checks and the testing report's four crop-resource checks are distinct runs. The current runner covers the checked-in crop, resource, night-state, dashboard startup, and nightly integration suites. [Development log](DEVELOPMENT_LOG.md#L178) · [Current testing evidence](TESTING_REPORT.md#12-2026-11-26--m01-package-c-dashboard-and-test-migration)

## Open research and scope decisions

- Choose the first playable crop after foundation stabilization. Decide whether to keep lettuce as a labeled demonstration crop or begin with a GDD crop, and confirm which crops and optional systems the assessment requires. [Crop scope](GDD.md#L525) · [Milestone priorities](GDD.md#L692)
- Confirm growth points per night, mineral concentration timing and zero-water behavior, the concentration health-versus-blocking rules, mixed-liquid allocation, and µL rounding before implementing those rules. [Mineral and health formulas](FORMULAS.md#L41) · [Liquid loss](FORMULAS.md#L215)
- Confirm pollutant tier boundaries and sensitivity units, equipment power and modifier formulas, trait multipliers, and crop-specific harvest and seed-return rules. Document which simplifications are acceptable for the submission. [Pollution formulas](FORMULAS.md#L144) · [Pending research](RESEARCH_NOTES.md#L241)
- Confirm the assessment delivery format and target engine build. A fresh end-to-end test run and, if required, a Windows export remain separate work. [GDD target platform](GDD.md#L7) · [Audit questions](PROJECT_AUDIT.md#h-questions-requiring-clarification)

## Next recommended task

For M02, choose the first playable crop and confirm its formula and unit contract before implementing the first complete production loop. The five-suite runner provides the foundation regression gate. [Open research and scope decisions](#open-research-and-scope-decisions) · [Test command](../README.md#run-the-automated-tests-on-windows)
