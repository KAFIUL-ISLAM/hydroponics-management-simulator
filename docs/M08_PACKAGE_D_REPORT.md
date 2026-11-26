# M08 Package D · Specialized workstations

2026-11-26 · Godot 4.7.2 · frozen simulation baseline v0.3.0

**Finalization update.** The owner accepted M08-D and reported all ten desktop checks passed. The full dated checklist and fresh final regression are recorded separately from this package's renderer captures. [M08 final verification](M08_FINAL_REPORT.md#verification)

## Design and ownership

The existing modal entry points, buttons and seed targets are retained. [WorkstationView](../scripts/workstation_view.gd) provides bounded scroll bodies, artwork and accent banners, sections, readout panels and reusable meters. The [theme](../resources/orbital_theme.tres) gives embedded windows dark frames and visible focus. The dashboard owns the shared shade, event blocking, Escape cancellation and restoration of dashboard focus. Destructive confirmations initially focus Cancel. Accepting a confirmation consumes the existing pending callable once. The inventory strip gains larger icons and text plus a scroll hint. No simulation, artwork or calculation inputs were changed.

| Workstation | Presentation decisions |
| --- | --- |
| Liquid analysis | Tank artwork, exact µL capacity/water/mineral readouts and capacity meter. The mineral gauge shows composition with an amber optimal-range marker. Text distinguishes healthy, warning and unavailable states. All six harmful components remain visible in the scrollable breakdown alongside physical and inert material. Predicted damage and actual prior running-night damage are labeled separately. Scenario replacement has a dedicated demo section and still requires confirmation. |
| Equipment | Terminal and module artwork, current machine and vessel, base → effective growth and power, capacity, modifiers, slot symbols and module inventory. Switching, installing and removing still call the same handlers and show their existing rejection reasons. |
| Seed analysis | Crop portrait, presentation alias, native/modified status, complexity, heat and sterile rank. The panel lists base and effective growth/yield, consumption, mineral band and uptake, pollution and composition. A technical section preserves the raw instance ID. Trait ranks and pending offspring remain available. |
| DNA | Station artwork and violet accent. Seed and disc selectors, disc stock, current traits, authoritative projected statistics, complexity/heat changes and operation progress. Chance, nights and energy appear early in the preview. The persistent footer puts Confirm beside Close. Confirm disables immediately and continues through the existing editor validation. Extraction remains unavailable. |
| Cultivation and confirmations | Shared dark frame and modal input treatment. Cultivation opens without running an action. Confirmation retains its captured item across refreshes. Escape cancels the current window and restores focus after the last dialog closes. |

## Render evidence

The available before captures show [M08-C dashboard](../screenshots/m08c-environment-1280.png), [earlier liquid analysis](../screenshots/pollution_analysis.png) and [earlier equipment dialog](../screenshots/equipment_management.png). Standalone before captures for the other dialog interiors were unavailable.

| After | Godot renderer capture |
| --- | --- |
| Liquid analysis | [1280 × 720](../screenshots/m08d-liquid-1280.png) |
| Equipment | [1280 × 720](../screenshots/m08d-equipment-1280.png) |
| Seed analysis | [1280 × 720](../screenshots/m08d-genes-1280.png) |
| DNA | [1280 × 720](../screenshots/m08d-dna-1280.png) · [1920 × 1080](../screenshots/m08d-dna-1920.png) |
| Cultivation and confirmation | [Cultivation](../screenshots/m08d-cultivation-1280.png) · [Discard confirmation](../screenshots/m08d-confirmation-1280.png) |

These captures are Godot Compatibility renders. They are distinct from manual owner verification. Long pollutant and trait details, module slots and the demo replacement controls use scrolling. The crop artwork, anchor and hotspot placement remain as established in M08-C. Platform-specific native window treatment, keyboard traversal in dropdowns and subjective readability still warrant desktop review.

## Automated verification

Fresh isolated import passed all **17 suites, 1,142 explicit checks and four original crop assertion groups**, with zero failures. The 38 workstation checks cover both 1280 × 720 and 1920 × 1080. They exercise route and bounds, close and focus restoration, a real viewport click blocked behind the modal, empty liquid without a crop, liquid and equipment numbers, seed identity, DNA preview and duplicate confirmation, cultivation availability, fixed discard targets, Cancel and Escape. The previous 16 suites and their existing assertions remain intact. Native mineral losses stayed 3,148 / 9,430 / 46,639 µL. Default launch exited 0 and the archived Lettuce probe returned BASELINE_MATCH=true. The known Windows certificate-store diagnostic remained present.

```powershell
$isolated = Join-Path $env:TEMP ("orbital-regression-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $isolated | Out-Null
Copy-Item project.godot,icon.svg,icon.svg.import,scripts,scenes,resources,tests,assets -Recurse -Destination $isolated
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $isolated 'tests/run-tests.ps1') -GodotPath $GodotPath -Import
& $GodotPath --headless --path $isolated --verbose --quit-after 10 --log-file (Join-Path $isolated 'default.log')
# Save the archived script from M01_T02_REPORT.md as legacy_probe.gd in the isolated directory.
& $GodotPath --headless --debug --path $isolated --quit-after 90 --script (Join-Path $isolated 'legacy_probe.gd') --log-file (Join-Path $isolated 'legacy.log')
```

## Owner review and milestone readiness

The owner reported **PASS for all 11 M08-C desktop items**, including all three crop artworks and both supported resolutions. At the package handoff, M08-D had renderer and automated evidence. The subsequent M08-D desktop acceptance is recorded in the final report.

1. Use 1280 × 720, then 1920 × 1080. Open each workstation by both available routes, scroll to the final section, close with Escape and confirm focus returns.
2. In Analysis, check the capacity and band indicators in clean and polluted liquid, advance a running night, and verify predicted versus applied damage. Cancel a demo replacement and verify it leaves the solution intact.
3. In Gear, install/remove and try an unavailable change. In Genes and DNA, inspect the same seed, compare the preview, and confirm once. Check that the disabled state and progress update.
4. Open Cultivation and Discard. Verify opening alone changes no gameplay, the background cannot advance a night, and Escape leaves the target in inventory.

After owner acceptance and separate publication authorization, the proposed **v0.4.0** summary is “Orbital Hydroponics visual milestone: shared laboratory theme, state-driven crop artwork, interactive workstations, visual inventory and specialized terminals, with the published simulation preserved.” M08 has passed the automated gate. This package remains uncommitted.

## Changed files

- Presentation · scripts/workstation_view.gd and UID, scripts/coffee_dashboard.gd, resources/orbital_theme.tres.
- Tests · tests/test_workstations.gd, UID and scene, plus tests/run-tests.ps1.
- Evidence · the seven m08d PNGs linked above.
- Documentation · docs/PROJECT_STATUS.md, docs/DEVELOPMENT_LOG.md, docs/TESTING_REPORT.md, docs/VISUAL_DEVELOPMENT_PLAN.md and this report.
