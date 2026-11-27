# Requirements traceability

## Original employer requirements

| Requirement | Source | Priority | Status | Implementation and evidence | Remaining limitation and submission risk |
| --- | --- | --- | --- | --- | --- |
| Demo hydroponics or chemical pharmaceutical production using Unity or Godot | [Employer brief](EMPLOYER_REQUIREMENTS.md) | Explicit | Complete | Owner selected Godot hydroponics; default launch, playable loop and desktop evidence at v0.3.0. | Low for the implementation; verify the chosen delivery artifact. |
| Independently break down the gameplay and numerical design, and implement the chosen mechanic as closely as practical | [Employer brief](EMPLOYER_REQUIREMENTS.md) | Explicit | Complete for evidenced project slice | Research, calculation contract, 13 passing suites and manual walkthroughs. | Employer assessment remains pending. Explain tradeoffs and scope through the proposed Chinese analysis. |
| Ten-day time limit | [Employer brief](EMPLOYER_REQUIREMENTS.md) | Explicit | Unverified | The brief does not establish an exact start or end timestamp. | Evaluate the time-limit interpretation separately from implementation evidence. |
| Handoff format, target OS, export, recording and delivery channel | Unspecified in the supplied wording | Delivery decision | Unverified | Editor launch and Windows desktop evidence exist. No checked-in export preset was located. | Confirm the artifact and verify it on a clean target machine. |

**Mandatory deferred technical features.** The brief specifies no individual deferred feature. Internally marked Must rows below govern project scope only. Technical scope is frozen at v0.3.0. Perennials, warehouse routing, full DNA editing, quality mapping, grid geometry, more species and economy remain outside the proposed visual work.

## Internal requirements

The exact requirement, source section and priority are retained under each ID in [REQUIREMENTS.md](REQUIREMENTS.md). The table summarizes every ID and replaces its historical planning status for audit purposes. Complete means the named project slice has implementation and relevant evidence. Partial means a material criterion remains open. Deferred means deliberately outside approved implementation. Missing means no corresponding implementation in the assessed scope. Unverified means evidence is insufficient. Risk refers to presenting the current build, with employer priority still unknown.

**Implementation keys.** Dashboard = [default scene](../scenes/coffee_dashboard.tscn) and [dashboard script](../scripts/coffee_dashboard.gd). Farm = [farm runtime](../scripts/coffee_farm.gd). State = [GameState](../scripts/game_state.gd). Liquid = [composition](../scripts/liquid_composition.gd). Genes = [resolver](../scripts/crop_genetics.gd). Repro = [reproduction](../scripts/seed_reproduction.gd). Gear = [equipment](../scripts/hydroponic_equipment.gd). DNA = [editor](../scripts/dna_editor.gd). Legacy = [Lettuce scene](../scenes/main.tscn) and [simulator](../scripts/hydroponics_simulator.gd). Tests below name the matching `tests/test_<name>.gd` fixture. Manual evidence is reported separately in [TESTING_REPORT.md](TESTING_REPORT.md). A dash in the manual column indicates no separate desktop check recorded for that criterion.

| ID and requirement | Internal source · priority | Status | Implementation | Automated evidence | Manual | Remaining limit · submission risk |
| --- | --- | --- | --- | --- | --- | --- |
| LIQ-01 Mixed solution with integer volumes | GDD §4, F-LIQ-01 · Must | Complete | Liquid, Farm | liquid_composition, pollution | M04/M05 | Reference edge policies disclosed · Low |
| LIQ-02 Refill, swap and retain solution | GDD §§3–4,10, F-LIQ-01 · Must | Complete | Farm, Liquid, Dash | three_crops, equipment | M04/M07 | Two container choices; oversized swap rejects · Low |
| LIQ-03 Proportional mixed draw | GDD §4, F-LIQ-02 · Must | Complete | Liquid, Farm | liquid_composition, pollution | — | Stable provisional tie order · Low |
| LIQ-04 Reject liquid shortage atomically | GDD §§3–4, LIQ-03 · Must | Complete | Farm, Liquid | liquid_composition, coffee_farm | M04 loop | Shortage wording could be clearer · Medium |
| LIQ-05 Refillable container and displacement | BW/EQ, F-LIQ-03 · Ref | Partial | Liquid, Farm, Gear | three_crops, pollution, equipment | M04/M07 | Mixed reference overflow order unresolved · Low |
| MIN-01 Mineral concentration and band | GDD §§4–5,10, F-MIN-01 · Must | Partial | Liquid, Dash | liquid_composition, coffee_farm, three_crops | M04 | Values show, explicit low/optimal/high interpretation is absent · Medium |
| MIN-02 Per-point uptake plus mixed loss | GDD §§4–5, F-MIN-02/03 · Must | Complete | Liquid, Farm | three_crops, equipment, liquid_composition | — | Raw precision and prototype edge policy documented · Low |
| MIN-03 Whole nutrient tablets | GDD §§3–4, F-LIQ-03 · Must | Complete | Liquid, Farm | liquid_composition, three_crops, pollution | M04 | Provisional displacement under LIQ-05 · Low |
| GRW-01 Three data-driven crop definitions | GDD §§5,12, F-GRW-01/02 · Must | Complete | resources, Farm, Genes | three_crops, coffee_farm, genetics | M04 | Raw Kotton draw unresolved; native value verified · Low |
| GRW-02 Full funded growth and ETA | GDD §5.3, F-GRW-01–03 · Must | Complete | Farm, Gear, Dash | three_crops, coffee_farm, equipment | M04/M07 | ETA assumes future funded running nights · Low |
| GRW-03 Plant one available seed | GDD §§3–5, F-HLT-01 · Must | Complete | Farm, Dash | coffee_farm, seed_reproduction, dna_editor | M04/M06/M07 | Seed selection is hidden in Genes · Medium |
| GRW-04 Mature once, collect and replant | GDD §§3,5,10,13, F-GRW-03 · Must | Complete | Farm, Dash | coffee_farm, three_crops, seed_reproduction | M04/M06 | Plant state readout is text-only · Low |
| GRW-05 Perennial retention and regrowth | BW, F-GRW-01/HRV-04 · Ref | Deferred | Annual farm only | — | — | Scope frozen · Low unless mandated |
| GRW-06 Blockers and destructive plant removal | BW, F-GRW-02 · Ref | Partial | Farm, Dash | coffee_farm, equipment | M04/M07 | No destructive plant removal · Low unless mandated |
| NGT-01 Atomic night and typed outcomes | GDD §§3,12, F-M01-01 · Must | Complete | State, Farm, DNA | night_state, nightly_integration, pollution, dna_editor | M01/M07 | Shared battery priority is project policy · Low |
| NGT-02 Legacy Lettuce baseline | M01, F-M01-01 · Ref | Complete | Legacy | nightly_integration, archived probe | M01 | Separate entry scene · Low |
| HLT-01 Health and score | GDD §§6,10, F-HLT-01 · Must | Complete | Farm, Dash | coffee_farm, pollution | M04/M05 | Dense raw score text · Medium |
| HLT-02 Mineral damage before draw | GDD §§6,13, F-HLT-02 · Must | Complete | Farm, Liquid | coffee_farm, three_crops, pollution | M05 display | Exact numeric fixtures retained · Low |
| HLT-03 Harvest effect and player feedback | GDD §§6,10,13, F-HRV-02/03 · Must | Complete | Farm, Dash | three_crops, coffee_farm, pollution | M04/M05 | Provisional Fruit fractional size boundary · Low |
| POL-01 Analyze pollutant components | GDD §7, F-POL-01 · Should | Complete | pollution_analysis.gd, Liquid, Dash | pollution | M05 | Text-heavy readout · Medium |
| POL-02 Crop sensitivity, tiers and damage | GDD §§7,13, F-POL-02/03 · Should | Partial | pollution_analysis.gd, Farm | pollution | M05 | Fractional tiers and nightly rounding are provisional · Low |
| POL-03 Purification and fouling | BW/GN, F-POL-04/05 · Ref | Deferred | — | — | — | Scope frozen · Low unless mandated |
| EQP-01 Operable machine and supplies | GDD §§3,9,10,12, F-EQP-01/02 · Must | Complete | Gear, Farm, Dash | equipment, coffee_farm | M07-A | Simplified battery and vessels · Low |
| EQP-02 Full-night energy debit | GDD §§4,9,13, F-EQP-01/02 · Must | Complete | Gear, Farm | equipment, coffee_farm | M07-A | kJ is project label · Low |
| EQP-03 Stack module and targeted effects | GDD §§9,12, F-EQP-01–03/HRV-01 · Should | Partial | Gear, Farm | equipment | M07-A | Neutral quality only, limited module catalog · Low |
| EQP-04 Equipment and seed locks | BW/EQ · Ref | Complete | Farm, DNA, State | equipment, seed_reproduction, dna_editor | M07 | Stopped-machine policy · Low |
| EQP-05 Upgrades and additional modules | GDD §12.3, F-EQP-04 · Could | Partial | Gear, Farm | equipment | M07-A | Grid, expansion and alternate providers absent · Low |
| GEN-01 Distinct seed and trait ownership | GDD §§4–5, F-GEN-01/04 · Must | Complete | Farm, Genes | genetics, seed_reproduction | M06 | Engine IDs are session-only · Medium |
| GEN-02 Genetic modifiers and compatibility | GDD §§8,13, F-GEN-01/02 · Should | Partial | Genes, Farm, DNA | genetics, dna_editor | M06/M07-B | Catalog scope, raw Kotton water and exact rank cap · Low |
| GEN-03 Seed trait, complexity and heat analysis | RN §8, F-GEN-04–06 · Ref | Complete | Genes, DNA, Dash | genetics, dna_editor | M06/M07-B | Dense dialog; current and proposed values compete · Medium |
| GEN-04 Seed inheritance, returns and heat reset | RN §8, F-GEN-03/04 · Ref | Complete | Repro, Farm | seed_reproduction, dna_editor | M06-B/M07-B | Plain-machine reference scope; external storage absent · Low |
| GEN-05 Specialty traits and outputs | GDD §12.3, F-GEN-05/POL-04/05 · Could | Partial | Genes, Gear | genetics, equipment | M06/M07 | Coffee composition readout and woven variant only · Low |
| HRV-01 One-time harvest transfer | GDD §§3,5,10,13, F-GRW-03 · Must | Complete | Farm, Dash | three_crops, seed_reproduction | M04/M06-B | Requires freeing space on capacity block · Medium |
| HRV-02 Counts and health reductions | GDD §§5–6,13, F-HRV-01/02 · Must | Complete | Farm, Genes | three_crops, coffee_farm | M04 | Neutral quality only · Low |
| HRV-03 Size, quality and product state | GDD §§10,12, F-HRV-01/03/04 · Should | Partial | Farm, Gear, Dash | three_crops, equipment | M04/M07 | Nonneutral quality, textile grading and further states · Low |
| INV-01 Inventory and replenishment loop | GDD §§3–4,10, F-LIQ-01/03 · Must | Complete | Farm, Dash | three_crops, seed_reproduction, dna_editor | M04/M06/M07 | Finite demo supply and selection resets · Medium |
| INV-02 Capacity and overflow preservation | BW/EQ · Ref | Partial | Farm | three_crops, seed_reproduction | M04/M06-B | Atomic pending retention, warehouse absent · Medium |
| UI-01 Launch dashboard with live state | GDD §§10,12, M01 · Must | Complete | Dash, Legacy, project.godot | main_dashboard, three_crops, fresh launch | M01/M04 | 1280 × 720 is evidenced, other sizes open · Medium |
| UI-02 Actionable controls and analyzers | GDD §§3,10, F-MIN-01/GRW-02/HLT-01 · Must | Partial | Dash, Farm | three_crops, pollution, equipment, genetics, dna_editor | M04–M07 | Eligibility cues and shortage recovery need polish · High |
| UI-03 Night/harvest feedback and history | GDD §§6,10,12, F-MIN-03/HLT-02/HRV-02 · Should | Partial | Dash, Farm | three_crops, pollution, nightly_integration | M05 | Last running-night summary only, no persistent history · Medium |
| TST-01 Repeatable automated and desktop checks | GDD §§12.2,13, M01 · Should | Complete | tests/run-tests.ps1 | 13 suites and legacy probe | M01/M04–M07 | Export validation remains a separate high-risk gate |
| OPT-01 Additional species | GDD §12.3, F-HRV-04 · Could | Deferred | — | — | — | Scope frozen · Low |
| OPT-02 Selling and economy | GDD §12.3, F-LOCAL-01 · Could | Deferred | — | — | — | Scope frozen · Low |
| OPT-03 Visual and animation improvement | GDD §12.3 · Could | Deferred | Existing functional dashboard and theme | Current bounds only | Current desktop baseline | Owner priority for proposed M08–M11, approval pending · High |
| OOS-01 Exclusions | GDD §§8,12.4, F-GEN-06 · Out | Deferred | Partial editor only by later milestone scope | dna_editor | M07-B | Full replication, economy, multiplayer and complex 3D stay outside scope · Low |
