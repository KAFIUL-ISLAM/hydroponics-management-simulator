# M08 Package A · Visual foundation

2026-11-26 · Provisional title **Orbital Hydroponics / 轨道水培实验室** · Godot 4.7.2

## Layout and ownership

The playable scene applies one [shared theme](../resources/orbital_theme.tres). It defines panel, dialog, tooltip, dropdown, primary and secondary button, focus, hover, pressed, disabled and progress styles. The legacy scene keeps its existing native styles. The default scene still instances the legacy tree; the playable adapter uses its bound labels and repositions the inherited chamber after binding. Keeping presentation in the dashboard avoids moving simulation ownership or changing existing public actions.

- Top · Title, current day, labeled global lifecycle state and resource cards.
- Left · Workstation actions, crop and inventory controls, finite supply and refill quantities, direct DNA access, and deliberately named demo controls.
- Center · Chamber placeholder and separate full-area art layers, actual installed machine, running/stopped state and live DNA progress or outcome.
- Right · Selected crop, reusable themed progress meter, health and score, capacity, mineral concentration and range, and harvest details.
- Bottom · Larger wrapped feedback, a contextual Plant/Start/Stop/Collect shortcut and bilingual Next Night. The shortcut uses the existing action bindings.

Reused components include the inherited resource cards and inset status, the compact heading builder, one themed progress indicator, shared primary/secondary styles and the existing modal controls. Inventory selection survives refresh by exact seed object or product key. A confirmation retains the originally captured item across subsequent selection and refresh. The seed IDs and transaction logic are unchanged. [Visual style guide](VISUAL_STYLE_GUIDE.md)

## Verification

The fresh isolated import and all **14 suites** passed with **981 explicit checks and four original assertion groups**. The 49 new presentation checks cover machine sync, distinct status labels, inventory identity, confirmation target preservation, the contextual action target, DNA progress, availability, basic focus and reentrant night rejection. The 13 existing suites were retained without edits to their assertions.

| Check | Result |
| --- | --- |
| 1280 × 720 dashboard | Essential controls fit without overlap. Smallest verified usable baseline. |
| 1920 × 1080 dashboard | Essential controls fit without overlap. |
| 1024 × 576 exploratory probe | Overflow observed. Outside the supported baseline. |
| Legacy Lettuce | Archived probe matched the original baseline. |
| Default launch | Playable scene loaded successfully. |
| Native cultivation | Final growth 16/24/48, energy 16/24/48 kJ, mineral loss 3,148/9,430/46,639 µL. |
| Advanced regressions | Pollution 120/162/605; genetics, reproduction, equipment, DNA, inventory and lifecycle suites passed. |

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\run-tests.ps1 -GodotPath $GodotPath -Import
```

Headless bounds do not verify visible CJK glyphs, text clipping inside controls, full keyboard traversal or contrast on an actual display. The theme retains Godot/system fallback with no bundled fonts. Existing screenshots demonstrate Chinese glyphs in the previous desktop build. The current OS-dependent fallback, modal visuals and new captions still need desktop confirmation. The Windows certificate-store diagnostic remains an environment message observed during launch.

## Desktop review

1. Open project.godot in Godot 4.7.2 and press F5. Check 1280 × 720 and 1920 × 1080 for glyphs, all captions, chamber proportions and focus outlines. Tab through both dashboard and dialogs and check dismissal and focus recovery.
2. Switch machine while stopped, select an inventory item and perform an unrelated refresh. Confirm that the selected item and its discard target stay correct.
3. Run one night, check the independent system and machine states and inspect feedback. Queue a DNA operation and check the dashboard progress after each night without reopening the dialog.

Before examples are available in the [equipment screenshot](../screenshots/equipment_management.png) and [analysis screenshot](../screenshots/pollution_analysis.png). No new desktop screenshot was captured. The provisional title, smaller viewport overflow, fallback font behavior and subjective readability remain review items.

## Package B artwork handoff

Reserve a 960 × 800 opaque chamber backdrop and matching transparent machine/foreground and optional light overlays. For each crop, use 512 × 512 transparent seedling, growing and mature images with a common bottom-center anchor and a 32 px transparent border. Keep labels and interaction out of the art. The named layer slots are ChamberBackdrop, MachineOverlay, CropStage and Effects. [Artwork details](VISUAL_STYLE_GUIDE.md#artwork-specifications-for-proposed-m08-b)

## Changed files

- Presentation · scenes/coffee_dashboard.tscn, scripts/coffee_dashboard.gd, resources/orbital_theme.tres.
- Tests · tests/test_presentation.gd, tests/test_presentation.gd.uid, tests/test_presentation.tscn, tests/run-tests.ps1.
- Documentation · docs/VISUAL_STYLE_GUIDE.md, docs/VISUAL_DEVELOPMENT_PLAN.md, docs/PROJECT_STATUS.md, docs/DEVELOPMENT_LOG.md, docs/TESTING_REPORT.md and this report.

Production mechanics, legacy scene and Godot version remain at the frozen baseline. M08-B awaits approval.
