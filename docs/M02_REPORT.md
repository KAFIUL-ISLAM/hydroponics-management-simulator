# M02 — Research reconciliation and calculation contract

**Review date** 2026-11-26 (Asia/Shanghai) · **Baseline** `main`, `2c56490855d0da94eadce5f1c6bc093f5c797eae`, `v0.1.0` · **Status** Documentation complete, ready for review.

## Results

M02 maps **45 requirements** and **41 formula/decision entries**. All nine mandatory GDD categories and all ten GDD §13 acceptance cases are mapped. Production implementation and runtime behavior remain at the published M01 baseline.

| Requirement priority | Count |
|---|---:|
| Must | 23 |
| Should | 7 |
| Could | 5 |
| Supporting reference/project detail with no separate GDD priority | 9 |
| Explicit scope-exclusion group | 1 |
| **Total** | **45** |

| Formula/decision class | Count | Meaning |
|---|---:|---|
| Reference-supported entries | 29 | Relevant expressions, constants, or order were observed in the cited sources. Some have distinct unresolved integration boundaries. |
| Derived | 1 | Mixed-volume sum is a derived entry. Other derived consequences, including uptake ordering and maturity equality, are labeled within mixed-evidence rows. |
| Project engineering | 2 | Existing M01 fixture and presentation rules. New engineering proposals are explicitly labeled inside their relevant rows. |
| Local documentation only | 1 | General economy/market estimate has local intent and example evidence without a verified project formula. |
| Unresolved decision entries | 8 | Each identifies missing behavior, an example or discriminator, and its release gate. |

[Requirement matrix](REQUIREMENTS.md) · [Calculation contract and evidence keys](CALCULATION_CONTRACT.md) · [M03–M10 roadmap](GAMEPLAY_IMPLEMENTATION_PLAN.md)

## Reference access and original evidence

Both requested pages were accessible. The Bilibili agriculture revision **11463** supplies the plain-machine crop table, planting/locking, full-night damage and uptake, mixed liquid allocation, nutrient-tablet displacement, and harvest routing. The GameWith guide independently supplies practical startup/replenishment context and cross-checks the healthy 2/3/6-night schedule and 7/8/13 output quantities. The equipment and genetics pages provide speed/power/quality stages and raw versus native-adjusted crop values. The crop pages provide harvest and inheritance details. Both requested sites are guides. “Reference-supported” records a page check, not a test of the reference game or its binaries. [Bilibili agriculture revision](https://wiki.biligame.com/probablystolen/index.php?title=%E6%B0%B4%E5%9F%B9%E5%86%9C%E4%B8%9A&oldid=11463) · [GameWith guide](https://gamewith.ai/probably-stolen/zh-hans/specializations/hydroponic-farmer) · [Equipment revision](https://wiki.biligame.com/probablystolen/index.php?title=%E6%B0%B4%E5%9F%B9%E7%B3%BB%E7%BB%9F&oldid=11302) · [Plant genetics](https://wiki.biligame.com/probablystolen/%E6%A4%8D%E7%89%A9%E5%9F%BA%E5%9B%A0)

Reviewed the bilingual GDD, original formula notes, research notes, technical design, project audit, project status and M01 final report. The original research files and historical evidence were preserved. [GDD](GDD.md) · [Formula notes](FORMULAS.md) · [Research notes](RESEARCH_NOTES.md) · [Historical technical design](TECHNICAL_DESIGN.md) · [Audit](PROJECT_AUDIT.md) · [M01 handoff](M01_FINAL_REPORT.md)

## Implementation gap and reconciliation

| Area | M01 code | Contract implication |
|---|---|---|
| Liquid and power | `ResourceManager` is a validated atomic ledger for water/minerals in mL and power in kWh. Direct writes remain possible. The simulator spends fixed water/mineral costs and does not debit energy. | Introduce a component mixture and full power gating in the new crop mode. Adapt the atomic seam after defining energy units and boundary behavior. Preserve legacy Lettuce. [ResourceManager](../scripts/resource_manager.gd#L92) · [Simulator](../scripts/hydroponics_simulator.gd#L40) |
| Progress and health | Simulator adds one point per successful night; no maturity, plant health, planting action, or separate seed state. `CropData` exposes placeholder growth, consumption and output values. | Model points, actual full-night work, one plant instance, mineral and pollutant effects, maturity and pending harvest. Distinguish score from points. [CropData](../scripts/crop_data.gd#L37) · [Simulator](../scripts/hydroponics_simulator.gd#L40) |
| Equipment and genetics | Equipment values are presentation placeholders. Trait APIs constrain rank to I–IV and mutate shared crop data; no applied effects, locking across cultivation, seed inheritance or heat behavior. | Native Sterile X and modified ranks require compatible seed-instance validation. Evaluate real equipment and perform mutations on the appropriate instances. [Scene equipment panel](../scenes/main.tscn#L228) · [CropData](../scripts/crop_data.gd#L52) |
| Settlement and UI | `GameState` guards a synchronous night and reports a typed result; the dashboard handles ready, success and blockers. There is no complete ledger/plant/output commit, resource-analysis action, stock, or harvest. | Preserve the stable lifecycle, extend the commit and outcome data, and wire staged presentation and actions without duplicating calculations. [GameState](../scripts/game_state.gd#L74) · [Dashboard](../scripts/main.gd#L97) |

### Conflicts and superseded assumptions

1. **Nights vs points.** GDD and the early formula table give effective 2/3/6 running nights and 7/8/13 yields. The genetics page gives raw targets 23/21/32 and raw counts 5/8/9. Those describe different stages. Using native adjustments gives 16/21/43 target points and the published effective outputs. M01's one point/night remains fixture behavior. The reference also describes both reaching and exceeding the target. Nutrition Fruit's 16 points in two 8-point nights, and the equipment ceiling formula, support equality as the working interpretation. [Calculation and crop mapping](CALCULATION_CONTRACT.md#reference-crop-definitions)
2. **Water vs solution.** Early documents discuss nightly water consumption as a scalar and leave exact allocation open. The new source uses total mixture for affordability, pure water in denominators, and a µL component split for consumption. Reconstruction matches the three mineral-loss examples only when uptake occurs before draw under the tested assumptions. The final equal-volume tie and capacity/underflow edges remain explicit decisions. [Liquid and mineral contract](CALCULATION_CONTRACT.md#core-formulas)
3. **Growth blockers vs damage.** Low or excess mineral concentration changes health. Inadequate liquid or power pauses growth without damage. A plant at zero health can still mature. Mineral quantity underflow and an undefined denominator still need separate rules. [Open and provisional contracts](CALCULATION_CONTRACT.md#open-and-provisional-contracts)
4. **Unit and modifier mismatch.** BW labels base nightly energy as 8 kJ, EQ uses 8 on its battery scale, and the prototype dashboard uses kWh. The simulator spends no power yet. EQ specifies staged P/E/Q truncation; it does not by itself resolve transformation of adjusted quality into every harvest multiplier. Keep health, size, quantity and quality separate. [Equipment formulas](CALCULATION_CONTRACT.md#core-formulas)
5. **Harvest action vs automatic output.** GDD expects a harvest action/result. The reference creates output at maturity and sends overflow to a secondary inventory. M03's one-time pending collection is a project proposal, with preserve-on-full behavior requiring approval. [Settlement pipeline](CALCULATION_CONTRACT.md#settlement-sequence-and-transaction-boundary)
6. **Trait scope.** The local I–IV cap is a prototype restriction. The cited native profiles include Sterile X and traits that can exceed IV or are explicitly single-rank. Full DNA editing remains out of scope. Locked genome offsets, edit heat, potency, and nutrition are distinct. [Genetics matrix](REQUIREMENTS.md#genetics-harvest-and-inventory)

## Blockers for the first release and deferrable work

| Before first playable release | Can defer with a stated scope |
|---|---|
| Approve zero-water, partial uptake, pre/post-uptake affordability and final allocation tie. | Full mixed tablet-overflow parity and additional liquids beyond the clean core fixtures. |
| Approve equality maturity and a precise health/score boundary policy. | Fractional pollutant tiers and multiplier rounding for M05. |
| Agree on an energy representation and UI label compatible with the current ledger. | Nonneutral equipment quality and special modifier placement for M07. |
| Decide start/stop and one-time collection semantics, output-full behavior and clearly labeled starter stock. | Rare seed RNG parity, raw Kotton modifier input, perennial base target, advanced output routing, economy and optional crop effects. |

**Recommended first package:** M03 with Coffee Beans (咖啡豆). One unmodified machine, a clean solution, one explicit resource supply path, three healthy running nights, eight harvestable/replantable beans, and a repeatable shortage/recovery test. This targets a playable core by November 29 while keeping Nutrition Fruit and Kotton mandatory for M04. [Implementation plan](GAMEPLAY_IMPLEMENTATION_PLAN.md#m03--one-complete-production-loop-first-demo-gate)

## Validation and changed files

Validated unique requirement/formula IDs, formula cross-references, the nine-category GDD crosswalk, and the eight numbered packages. Independent arithmetic reproduced mineral losses of **3,148 / 9,430 / 46,639 µL** from the published fixtures. These are specification checks. The previously accepted M01 run remains the runtime evidence, with five suites, 453 explicit checks and four original crop groups. Godot was not rerun for this documentation task.

Created `docs/REQUIREMENTS.md`, `docs/CALCULATION_CONTRACT.md`, `docs/GAMEPLAY_IMPLEMENTATION_PLAN.md`, and `docs/M02_REPORT.md`. Updated `docs/PROJECT_STATUS.md` and appended to `docs/DEVELOPMENT_LOG.md`. Production code, scenes, resources, test files and original research remain at the checkpoint. The pre-existing untracked `crop_resource_test.tscn` was left in place. No commits or pushes. M03 awaits review.
