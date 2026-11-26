# M08 Package C · Environment-centered interface

2026-11-26 · Godot 4.7.2 · frozen technical baseline v0.3.0

## Layout and interaction

The M08-B layout had side-by-side action, chamber and crop cards with inventory nested in the workstation column. M08-C uses a compact header and resource row, narrow navigation, a wider laboratory panel, a compact crop status panel and a full-width inventory strip. The center panel occupies approximately 55% of available content width in the 1280 × 720 capture. The actual 900 × 660 artwork fits by height, so its image is narrower than the panel at that resolution. The larger viewport gives the chamber more vertical and horizontal room. The region, aspect ratio, plant anchor and visual-state rules remain the M08-B values.

| Hotspot | Artwork placement and existing action |
| --- | --- |
| 培育 / Grow | Upper chamber frame → cultivation dialog exposing existing Plant, Start/Stop and Collect buttons. Opening the dialog has no gameplay side effects. |
| 液 / Tank | Lower face of the visible left tank → existing liquid analysis. |
| 机 / Gear | Right-hand terminal → existing equipment dialog. |
| DNA editor | Labeled workstation button. No suitable standalone DNA workstation appears in the chamber composition. |

Hotspots use normalized placement inside the aspect-fit artwork coordinate space, with hover, pressed and keyboard focus treatments and bilingual tooltips. Decorative textures ignore input. Workstation alternatives stay visible. The bottom contextual action calls one existing action according to state, with Next Night always alongside it. Refill, tablet, energy and drain remain on the left, demo seed has its own labeled group, and discard remains in inventory. Contextual feedback reports completed actions and current blockers.

## Inventory and data display

The strip uses one tile per seed and a quantity tile per stored harvest key. Bilingual role labels distinguish plantable seeds from harvest. Capacity is displayed as occupied/total, with a compact dropdown retained as an alternative for selection. Selecting an available seed with an empty planting slot uses the existing species and seed selection APIs. The detail dialogs and confirmation retain actual identity. Presentation-only numbers distinguish individual seeds within the session. Genes and DNA show raw IDs. Neither alias nor tile position is used as a simulation identifier. Selection restoration and discard continue to use typed metadata.

The crop panel shows exact growth points with visual progress clamped to target, numerical health percentage, a health meter, solution volume and capacity, a solution meter, mineral concentration and optimal bounds, machine state, remaining nights and pending harvest. The main volume readout uses one decimal mL and whole-mL capacity, with three decimal percentage places for concentration. Detailed analysis and nightly settlement retain their previous precision and inputs. A mineral condition label reads healthy, warning or critical and reinforces it with color.

## Verification and captures

| Evidence | 1280 × 720 | 1920 × 1080 |
| --- | --- | --- |
| M08-B before | [Render](../screenshots/m08b-chamber-1280.png) | [Render](../screenshots/m08b-chamber-1920.png) |
| M08-C after | [Render](../screenshots/m08c-environment-1280.png) | [Render](../screenshots/m08c-environment-1920.png) |

Godot Compatibility renderer captures show mature Coffee Beans after three actual settlements. These are renderer inspection, not a manual walkthrough. The 1024 × 576 probe still overflows and remains outside support. At 1280 × 720 the side gutters around the art are visible because preserving the crop and aspect ratio makes the image height-limited. Inventory tiles remain small and require scrolling when stock exceeds a row. Specialized dialog styling and a full desktop keyboard/hover pass remain review items.

Fresh isolated import passed **16 suites, 1,104 explicit checks and four original crop assertion groups**, with zero failures. The new 68-check environment suite covers normalized hotspot alignment and routing, available modal controls, distinct genetically modified seed tiles, exact inspection and planting identity, confirmation targets, contextual actions, authoritative meters, maturity, bounds and reentrant settlement rejection. The earlier overlap check now compares controls within the shared dashboard coordinate space. The moved cultivation controls are tested in the visible dialog for bounds, focus and mutual overlap. All 15 existing suites passed. Native mineral losses remained 3,148 / 9,430 / 46,639 µL. Default launch exited 0, and the legacy Lettuce probe reported BASELINE_MATCH=true. The Windows certificate-store diagnostic remained present.

```powershell
$isolated = Join-Path $env:TEMP ("orbital-regression-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $isolated | Out-Null
Copy-Item project.godot,icon.svg,icon.svg.import,scripts,scenes,resources,tests,assets -Recurse -Destination $isolated
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $isolated 'tests/run-tests.ps1') -GodotPath $GodotPath -Import
& $GodotPath --headless --path $isolated --verbose --quit-after 10 --log-file (Join-Path $isolated 'default.log')
# Save the archived script from M01_T02_REPORT.md as legacy_probe.gd in the isolated directory.
& $GodotPath --headless --debug --path $isolated --quit-after 90 --script (Join-Path $isolated 'legacy_probe.gd') --log-file (Join-Path $isolated 'legacy.log')
```

## Manual review and handoff

1. Run at both supported sizes. Tab across the artwork hotspots, open each with mouse and keyboard, and verify that focus and tooltip placement are clear. Confirm no action runs when a workstation opens.
2. Select two Coffee seed tiles with different traits, compare Genes and DNA, and plant the intended seed. Cancel a discard, then confirm a discard after changing selection and ensure the original target is removed.
3. Follow the bottom action through Plant, Start, Stop and Collect. Confirm that meters and feedback update as nights resolve and that all support actions are accessible.

The owner reported completing the M08-B artwork integration review. The separate M08-B per-species desktop checklist remains unconfirmed. M08-C desktop acceptance remains pending. For M08-D, prioritize dialog layout, explicit focus return and smaller inventory/dialog ergonomics while preserving the present art mapping and domain interfaces.

## Changed files

- Presentation · scripts/coffee_dashboard.gd, scripts/cultivation_art.gd, resources/orbital_theme.tres.
- Tests · tests/test_environment_ui.gd, its UID and scene, tests/test_presentation.gd and tests/run-tests.ps1.
- Evidence · screenshots/m08c-environment-1280.png and screenshots/m08c-environment-1920.png.
- Documentation · docs/PROJECT_STATUS.md, docs/DEVELOPMENT_LOG.md, docs/TESTING_REPORT.md, docs/VISUAL_DEVELOPMENT_PLAN.md and this report.

M08-D awaits owner approval.
