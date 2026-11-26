# M08 final report

**v0.4.0 · Orbital Hydroponics — Visual Transformation**

2026-11-26 · Godot 4.7.2 · M08 accepted · publication authorized

## Objective and accepted scope

Turn the playable farming dashboard into a Chinese-first, bilingual orbital laboratory with clear gameplay state, readable workstations and visible crop progression. Keep the simulation frozen at [v0.3.0](M07_FINAL_REPORT.md). The published ref is `74a3e440f81ba440219ca86ec052e61937c5f5c5`; local `main` and its remote-tracking ref are at `8a91359b447b5d611e0c19966b4c0fa6d692d921`, the separately published inventory hotfix.

| Package | Accepted implementation |
| --- | --- |
| A · Visual foundation | Shared dark industrial theme, three-column layout, distinct simulation and machine status, contextual action, inventory selection continuity and live DNA progress. [Report](M08_PACKAGE_A_REPORT.md) |
| B · Artwork | One chamber from the supplied laboratory image, aligned crop artwork driven by existing growth state, and workstation/resource icons. [Report](M08_PACKAGE_B_REPORT.md) |
| C · Environment-centered interface | Chamber, tank and terminal hotspots with workstation alternatives; visual inventory with seed identity, compact crop meters and contextual actions. [Report](M08_PACKAGE_C_REPORT.md) |
| D · Specialized workstations | Consistent liquid, equipment, seed, DNA, cultivation and confirmation dialogs with scrollable readouts, isolated input, Escape cancellation and focus restoration. [Report](M08_PACKAGE_D_REPORT.md) |

The palette preserves dark metallic surfaces and uses semantic accents alongside text. The chamber keeps its aspect ratio and plant anchor. UI seed aliases preserve underlying seed objects and confirmation targets. Shared artwork is cached, and the chamber layer does not advance the simulation. [Style guide](VISUAL_STYLE_GUIDE.md)

## Before and after evidence

- Before · [Published equipment dialog](../screenshots/equipment_management.png), [published liquid analysis](../screenshots/pollution_analysis.png), and the [owner's M08-A foundation capture](../screenshots/new_theme.png).
- After · [Laboratory at 1280 × 720](../screenshots/m08c-environment-1280.png) and [1920 × 1080](../screenshots/m08c-environment-1920.png), [Liquid](../screenshots/m08d-liquid-1280.png), [Gear](../screenshots/m08d-equipment-1280.png), [Genes](../screenshots/m08d-genes-1280.png), [DNA at 1920 × 1080](../screenshots/m08d-dna-1920.png). The [package report](M08_PACKAGE_D_REPORT.md#render-evidence) links all seven final workstation captures.

These PNGs document visible presentation. Automated checks and owner gameplay confirmation are recorded separately below.

## Verification

**Fresh isolated regression.** All 17 suites passed with **1,142 explicit checks and four original crop assertion groups**, zero failures. Default launch loaded the playable scene and exited 0. The archived legacy Lettuce probe printed `BASELINE_MATCH=true` and exited 0. A second fresh import included the artwork and screenshot PNGs and exited 0. The Windows certificate-store diagnostic and restricted editor-settings write diagnostic remain environment messages.

| Suite | Explicit checks |
| --- | ---: |
| Resource manager | 192 |
| Night state | 133 |
| Dashboard startup | 31 |
| Workstations | 38 |
| Environment interface | 68 |
| Orbital artwork | 46 |
| Presentation | 58 |
| DNA editor | 30 |
| Equipment | 27 |
| Seed reproduction | 26 |
| Genetics | 46 |
| Pollution | 66 |
| Three-crop farming | 107 |
| Coffee farming | 100 |
| Liquid composition | 77 |
| Nightly integration | 97 |
| Original crop resource | Four assertion groups |

**Simulation audit.** Git comparison against v0.3.0 showed no changes to the domain scripts, all four crop resources, calculation contract, formulas, project configuration or legacy scene. The current dashboard changes affect presentation and interaction routing. Nature of the earlier hotfix was type-safe inventory metadata and confirmation handling. Neutral fixtures still produce 16/24/48 points, 16/24/48 kJ and mineral losses of 3,148/9,430/46,639 µL for Nutrition Fruit, Coffee Beans and Kotton. Pollution damage at raw index 20 and eight growth points remains 120/162/605. Genetics, reproduction, inventory conservation, equipment, DNA and atomic settlement suites passed their existing assertions.

**Manual acceptance, owner report, 2026-11-26.** The owner accepted Packages A–D. M08-C passed 11 desktop items, including all three crop artworks and both resolutions. For M08-D the owner explicitly reported PASS for each item below.

1. Liquid analysis is readable and visually organized.
2. Equipment management shows correct modules and modifiers.
3. Seed analysis displays the correct selected seed.
4. DNA editor shows accurate modification previews.
5. DNA operations execute correctly.
6. Confirmation dialogs target the intended items.
7. Escape and keyboard focus work correctly.
8. Inventory readability improved.
9. All dialogs fit both supported resolutions.
10. Existing gameplay remains functional without new errors.

Reproduce the automated test gate with a clean copy containing project.godot, icon.svg and its import metadata, scripts, scenes, resources, tests and assets.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\run-tests.ps1 -GodotPath $GodotPath -Import
& $GodotPath --headless --path . --verbose --quit-after 10 --log-file "$env:TEMP/m08-launch.log"
# Save the archived probe from M01_T02_REPORT.md as legacy_probe.gd in the isolated project.
& $GodotPath --headless --debug --path . --quit-after 90 --script legacy_probe.gd --log-file "$env:TEMP/m08-legacy.log"
```

## Provenance and publication files

The owner supplied the ChatGPT-generated artwork and its provenance README. Six separate runtime copies normalize the plant frames and clean isolated alpha fragments. Originals are retained. The baked laboratory chamber avoids duplicating the unused standalone chamber. The 17 texture map references resolve. Audited the 24 artwork PNGs, 12 M08 evidence PNGs, matching import metadata and script UID sidecars. Path and unique UID checks passed for the audited sets. [Asset manifest](ASSET_MANIFEST.md)

| Include in proposed delta from current main | Paths |
| --- | --- |
| Playable presentation | `scenes/coffee_dashboard.tscn`, `scripts/coffee_dashboard.gd`, `resources/orbital_theme.tres`; `scripts/{cultivation_art,orbital_art,workstation_view}.gd` and matching `.gd.uid` |
| Regression harness | `tests/run-tests.ps1`; `tests/test_{presentation,orbital_art,environment_ui,workstations}` with `.gd`, `.gd.uid` and `.tscn` |
| Art and provenance | `assets/orbital_assets/README.md`, 18 original PNGs, six `runtime/` PNGs, and their 24 matching `.png.import` sidecars |
| Evidence | `screenshots/new_theme.png`, two `m08b-*` captures, two `m08c-*` captures and seven `m08d-*` captures, with matching import sidecars |
| Documentation | `README.md`; `docs/PROJECT_STATUS.md`, `docs/DEVELOPMENT_LOG.md`, `docs/TESTING_REPORT.md`, `docs/VISUAL_DEVELOPMENT_PLAN.md`, `docs/VISUAL_STYLE_GUIDE.md`, `docs/ASSET_MANIFEST.md`, `docs/EMPLOYER_REQUIREMENTS.md`, `docs/PRE_M08_AUDIT.md`, `docs/REQUIREMENTS_TRACEABILITY_MATRIX.md`, `docs/VISUAL_ASSET_INVENTORY.md`, the four `docs/M08_PACKAGE_*_REPORT.md` files and this report |

Local `.godot/`, `docs.zip` and obsolete root `crop_resource_test.tscn` are excluded from the release.

## Limitations and next priorities

Supported resolutions are 1280 × 720 and 1920 × 1080. The earlier 1024 × 576 probe overflowed. The chamber can retain side gutters at baseline aspect, early plant sprites are shared, and long data sets use scrolling. CJK rendering uses engine/system fallback. The cross-platform export and clean target-machine handoff remain separate delivery checks. Deferred reproduction, genetics and equipment depth remain as documented in the frozen simulation scope.

M08 is complete. M09 remains pending for optional motion and feedback polish after owner approval. Prioritize agreed submission format and clean-target delivery verification before optional scope. The internal deadline remains December 1, 2026. The owner reports 59% weekly Codex allowance remaining.

## Release notes

**Orbital Hydroponics — Visual Transformation** adds a bilingual orbital laboratory, state-driven crop artwork, clickable workstations, a visual seed and harvest inventory, and integrated cultivation, analysis, equipment, Genes and DNA terminals. The milestone includes keyboard focus and confirmation improvements and preserves the published farming simulation.

Milestone commit message `feat(ui): complete orbital hydroponics visual transformation`. Annotated tag `v0.4.0`.
