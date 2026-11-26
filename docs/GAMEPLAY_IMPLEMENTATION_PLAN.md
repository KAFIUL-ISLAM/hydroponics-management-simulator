# M03–M10 gameplay implementation plan

**Status** Proposed after M02. M02 creates this plan only. The delivery goal is a playable core by **November 29, 2026 (Asia/Shanghai)**. Prioritize the mandatory loop, then the remaining mandatory crop data and accuracy, then researched extensions. The M01 checkpoint remains the known-good regression baseline.

## First playable slice

**Recommend Coffee Beans (咖啡豆)** on one ordinary unmodified machine. The reference gives a 21-point base target, 8 points per running night, 100 mL mixed draw, 30 µL mineral uptake per point and a healthy output of eight plantable beans. Its native traits do not alter baseline speed, water, or yield. The final night delivers all eight points, which exercises overshoot without waiting six nights. Coffee avoids Nutrition Fruit's very rare native seed return and Kotton's unresolved raw draw multiplier, while exercising health-dependent quantity. This recommendation selects a fixture. Stock, inventory capacity and interaction choices still need project approval. [Reference crop matrix](CALCULATION_CONTRACT.md#reference-crop-definitions) · [Coffee Beans source](https://wiki.biligame.com/probablystolen/index.php?title=%E5%92%96%E5%95%A1%E8%B1%86&oldid=10718)

Make the first demonstration repeatable using the normal UI: plant a bean, add liquid and power, set a usable concentration, run nights, collect, and replant one of the resulting beans. Keep the old zero-cost Lettuce setup accessible to existing fixtures. Do not use healthy-only demo behavior to claim that mineral imbalance, low power, or output failure are verified.

## Gate decisions before gameplay implementation

| Decision | Minimum needed for the first demo | Follow-up |
|---|---|---|
| Energy F-OPEN-05 | Approve internal integer storage and one displayed unit for the base battery at 8 reference units/night. If adopting literal kJ, document conversion explicitly. | Additional providers and optional billing can wait. |
| Liquid F-OPEN-01/02 | Approve undefined concentration, partial mineral uptake, pre- vs post-uptake affordability and last tie. Required test includes exactly-full draw with positive uptake. | Mixed-tablet overflow and arbitrary refill precision may be restricted in the first slice, with visible preconditions. |
| Growth and health F-OPEN-03/04 | Approve equality maturity, full last-night effects, numerical score/clamp for mineral-only Coffee Beans, and bracket comparisons. | Pollution tier fractions and nonneutral quality can wait. |
| Collection F-OPEN-07/08 | Approve staged one-time collection, annual clearing, and pending output on capacity failure. Confirm simple starter stock and supply controls. | Match reference automatic routing and layout only when deliberately advancing that requirement. |
| Scope and schedule | Decide if Windows export is expected. Treat November 29 as the playable-core target; preserve three-crop mandatory coverage and distinguish it from the first demonstration. | Optional packages start only when the mandatory regression gate is green. |

## Dependency order and delivery checkpoints

- **November 26–27:** close the four release-blocking boundaries and review M02. Once approved, start M03 with deterministic Coffee Beans calculators and a single data fixture.
- **November 27–29:** connect M03 to the existing dashboard and demonstrate the full Coffee Beans loop with success, resource interruptions, low/high mineral damage and replay. Start M04 only after the first end-to-end fixture is green.
- **After the first playable loop:** finish M04's reference crop trio and remaining mandatory behaviors first. Use the remaining delivery time for M05 and M09 evidence as capacity permits. M06–M08 are staged after their needed inputs; M10 stays conditional. Do not claim all GDD §12.1 complete until M04's three-crop acceptance passes.

### M03 — One complete production loop (first demo gate)

| Item | Plan |
|---|---|
| Scope | GRW-02/03/04, MIN-01/02 and a tablet with available capacity, HLT-01/02, HRV-01/02 for Coffee Beans, LIQ-01–04, EQP-01/02, NGT-01/02, GEN-01, INV-01 and a pending-output guard. UI-02 shows actionable shortages, progress and health. Work in three reviewable slices: pure calculation + fixtures, transaction and plant lifecycle, then UI + end-to-end demonstration. |
| Dependencies | Published M01, M02 review, decisions listed above. Neutral machine quality, no modules, clean solution domain, approved integer representation. |
| Affected files | Existing `scripts/crop_data.gd`, `scripts/resource_manager.gd`, `scripts/hydroponics_simulator.gd`, `scripts/game_state.gd`, `scripts/main.gd` and `scenes/main.tscn` as needed. Proposed `resources/coffee_beans.tres`, small typed seed/plant state, solution/harvest helpers only where logic is reused, and `tests/`. |
| Acceptance | A player uses the dashboard to plant, replenish, run three healthy nights, collect eight beans exactly once and replant. A resource block preserves plant and ledger, mineral imbalance affects health, and last-night overshoot still consumes full costs. Existing Lettuce mode works as before. |
| Tests | Exact power and near misses, total vs pure-water gate, no mutation on rejected transaction, F-MIN-03 Coffee Beans golden fixture, zero/mineral boundaries under the approved policy, target minus/equal/plus, output-full retry, health-dependent counts and fixture preservation, runner plus desktop loop. |

### M04 — Complete the three mandatory crop profiles

| Item | Plan |
|---|---|
| Scope | Close GRW-01, HLT-03 and common HRV-02 across Nutrition Fruit, Coffee Beans and Kotton. Add native trait evidence separately from resolved balance. Complete capacity and refill UI appropriate for the mandatory loop, including tablet-with-space and reviewed full-vessel behavior. Support sourced size cases and clearly mark unresolved edge sizes if deferred. |
| Dependencies | M03 calculation and state seams. Native crop data and referenced golden vectors. |
| Affected files | Proposed `resources/nutrition_fruit.tres`, `resources/kotton.tres`, existing crop/config files, solution/harvest helpers, dashboard panels and tests. |
| Acceptance | Every required crop can be planted and harvested without setup via the editor. Healthy baseline yields 7/8/13 after 2/3/6 running nights, with mode-specific costs and promised outputs. Low-health count and size semantics remain separate. |
| Tests | All three exact mineral-loss totals, repeated replenishment, pure-water denominator, 1 L tablet fixture, Kotton half-even at 6.5, Nutrition Fruit count invariant, display/progress across each crop. |

### M05 — Pollutant analysis and damage

| Item | Plan |
|---|---|
| Scope | POL-01/02 and analysis fields. Supported harmful components, inert constituents, native sensitivity and damage factors, per-pollutant breakdown. Keep purifier/fouling and chemical production out of this package. |
| Dependencies | M03/M04 liquid and health seams, F-OPEN-04 closed for tier/rounding behavior. |
| Affected files | Solution state, damage calculator, simulator, output breakdown/UI and tests. |
| Acceptance | Two different contaminants can coexist. Contribution order and totals can be explained. Healthy/zero-index, clean and mineral-only regressions remain stable. |
| Tests | Six components, tier boundaries and fractional discriminator, native Hardy/Fragile, mix additive behavior, inert effects on draw, full-night vs blocked outcomes. |

### M06 — Seed traits, inheritance and analyzer

| Item | Plan |
|---|---|
| Scope | GEN-02/03/04. Support the GDD trait subset, compatibility and native trait ranks, separate seed instances, parent/offspring heat, reproduction scheduling, and a read-only analyzer. Full DNA editor stays outside the GDD scope. |
| Dependencies | M04 crop trio, M05 for Hardy verification, raw draw/rounding decisions for dynamic Drought Resistant. |
| Affected files | Seed instance and crop definitions, trait evaluator, harvest result calculator, analyzer UI and tests. |
| Acceptance | Supported trait changes modify only the relevant seed/crop computation. Descendants inherit current traits with heat zero, Coffee Beans output is granted once, and conflicting/unavailable traits are rejected. |
| Tests | Four GDD modifiers, native Sterile X, compatibility/ranks, mocked seeded rolls with fractional returns, Kotton branches, sibling isolation and replay. |

### M07 — Equipment modifiers and crop-specific modules

| Item | Plan |
|---|---|
| Scope | EQP-03/04 and HRV-03 quality path. Device slots, start/stop, installed module aggregation, optionally one supported fruit and one weaving example, seed/module locks. |
| Dependencies | M04 base machine and crops, F-OPEN-06 quality resolved for chosen subset. Can be scheduled independently of M06 where it has no trait input changes; preserves prior trait order. |
| Affected files | Machine configuration and evaluator, simulator, equipment panel, harvest variant data, tests. |
| Acceptance | UI surfaces actual attributes, locked slots, and costs. Sum modifiers before truncation. Off-crop equipment deltas still apply, crop-specific outputs do only when eligible. |
| Tests | Plain 8/8, a signed or stacked P/E/Q case, nonpositive speed, lock across days, neutral/nonneutral yield order, same-count weaving variant. |

### M08 — Perennial regrowth, output routing and advanced liquid effects

| Item | Plan |
|---|---|
| Scope | GRW-05/06, INV-02 parity work, POL-03 if documented boundaries are approved, and crop-specific regrowth/product-state fixtures. Prioritize output safety above extra crops. |
| Dependencies | M04 lifecycle, M05 pollution, M06 seed identity. M07 only if demonstrating crop module interactions. Resolve regrowth target and overflow policy first. |
| Affected files | Plant cycle data, output inventory, solution helpers, optional perennial crop resource, dashboard result panel, tests. |
| Acceptance | Perennial mother persists, health resets once and seed heat remains. Unsupported output remains pending without losses or duplicate grants. If enabled, purification conserves volume and cannot restore health already lost that night. |
| Tests | First vs subsequent cycle, same mother identity, removal with no seed, output and warehouse full, residue floor, seeded product-state distribution. |

### M09 — Acceptance evidence and delivery hardening

| Item | Plan |
|---|---|
| Scope | Complete UI-03 and TST-01, cross-check required dashboard views, consumption and harvest logs, regression suite, documentation and Windows handoff. |
| Dependencies | At least M04. Include M05–M08 only where accepted; the core QA and evidence work may begin once M03 is green. |
| Affected files | Dashboard/log view, `tests/run-tests.ps1` and registered tests, status and testing docs, export config only if approved. |
| Acceptance | Every delivered requirement has a traceable test and desktop walkthrough. Historical evidence remains intact. An approved package can run from a clean import or required export. |
| Tests | Fresh import, full suite, all GDD §13 mapped cases or explicitly deferred entries, desktop 1280 × 720, narrow-window/export if required, no partial commit on runtime errors. |

### M10 — Optional extensions after the core gate

| Item | Plan |
|---|---|
| Scope | EQP-05, GEN-05 and OPT-01/02/03 only when time and scope permit. Favor one measurable improvement over multiple partially implemented features. |
| Dependencies | M09 core gate and explicit optional scope approval. Reference formulas or project policies for every chosen mechanic. |
| Affected files | Only chosen data, UI and simulation modules, accompanied by targeted tests and scope evidence. |
| Acceptance | Additional crop, module, upgrade, sale or polish is separately reviewable and cannot change the documented core baseline unintentionally. |
| Tests | New feature boundaries plus entire M09 gate. Reject data or actions out of the approved domain. |

## Implementation discipline

Keep `GameState` as lifecycle owner, `HydroponicsSimulator` as settlement orchestrator, `ResourceManager` as commit seam, and the dashboard as action/result adapter. Add focused state types and pure calculation helpers as needed, without a new top-level framework. Defer compatibility migrations and numerical decisions until their requirements demand them. Keep proposed file names and policy details subject to review. Tag or publish an implementation milestone only with authorization and a passing gate.
