# M08 Package B · Laboratory artwork integration

2026-11-26 · Godot 4.7.2 · Frozen technical baseline v0.3.0

The [asset manifest](ASSET_MANIFEST.md) enumerates all 18 supplied originals, their bytes, dimensions, transparency and runtime decisions. Originals remain in place. Five plant copies now use matching 512 × 512 canvases. The processed energy icon preserves its dimensions. Alpha-connected cleanup removed isolated fragments without treating dark colors as backgrounds.

## Presentation

The chamber shows a 900 × 660 region of the supplied laboratory art through an aspect-fit canvas. It uses the baked chamber and neighboring equipment as one environment. This keeps the frame, glass and bench coherent and avoids a second chamber. Plant textures share a center and base height over the baked platform. The backdrop, machine, crop, foreground and effects slots remain independent, with the latter optional slots empty where imagery is already baked in. Text and state labels sit outside the artwork. The full dashboard keeps the M08-A theme and the central panel gains proportionally more room. The narrow inventory picker can truncate long display IDs, while the existing item identity and confirmation remain intact.

| Authoritative condition | Artwork |
| --- | --- |
| No plant | Empty chamber |
| Planted or growth below 33% of the effective target | Shared seedling |
| Active plant at 33% or above, before maturity | Shared growing sprite |
| Mature with harvest pending | Species-specific mature sprite, held until collection |
| Collection succeeds | Crop disappears and collection feedback is shown |
| Stopped versus running | Existing text state and restrained chamber tint; pending harvest stays illuminated |
| Missing art | Text fallback, or shared growing art if a mature texture is missing |

There is no separate dead-crop simulation state. The visual threshold is a presentation decision; the component only reads growth, effective target and maturity. Artwork is cached when the dashboard initializes. The asset map supplies resource, workstation and inventory icons with text-only fallback. Buttons remain the existing interactive surfaces. Decorative TextureRects ignore input.

## Render inspection and regression

The assistant captured rendered Godot SubViewports at [1280 × 720](../screenshots/m08b-chamber-1280.png) and [1920 × 1080](../screenshots/m08b-chamber-1920.png) using a normal Compatibility renderer. Both show mature Coffee Beans following three actual settlements. The [owner's M08-A screenshot](../screenshots/new_theme.png) is previous presentation evidence. The captures show a single chamber, contained plant, unobstructed controls and readable bilingual text in the captured environment. They do not constitute owner desktop verification. Early sprites are still shared and slightly soft at larger display sizes. Full per-species desktop review, finer effects, hotspots and navigation styling remain later work.

Fresh isolated import passed **15 suites, 1,027 explicit checks, four original assertion groups and zero failures**. The 46 artwork checks cover three crop textures and growth transitions, genetically determined target, pending and collection, missing-asset fallback, input filtering and aspect/position at both sizes. Existing native mineral losses stayed at 3,148, 9,430 and 46,639 µL; pollution, equipment, genetics, reproduction, DNA editing, identity and settlement passed their earlier assertions. Default launch loaded the playable scene and the archived Lettuce probe returned BASELINE_MATCH=true. The Windows certificate-store diagnostic remained present.

```powershell
$isolated = Join-Path $env:TEMP ("orbital-regression-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $isolated | Out-Null
Copy-Item project.godot,icon.svg,icon.svg.import,scripts,scenes,resources,tests,assets -Recurse -Destination $isolated
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $isolated 'tests/run-tests.ps1') -GodotPath $GodotPath -Import
& $GodotPath --headless --path $isolated --verbose --quit-after 10 --log-file (Join-Path $isolated 'default.log')
# Save the archived script from M01_T02_REPORT.md as legacy_probe.gd in the isolated directory.
& $GodotPath --headless --debug --path $isolated --quit-after 90 --script (Join-Path $isolated 'legacy_probe.gd') --log-file (Join-Path $isolated 'legacy.log')
```

## Desktop handoff

1. Launch with F5 at 1280 × 720 and 1920 × 1080. Inspect the empty chamber and icons, then plant and advance Coffee Beans through maturity and collection.
2. Repeat for Nutrition Fruit and Kotton and inspect the mature silhouette, its base and the chamber edges. Confirm artwork never competes with focus or action labels.
3. Open Analysis, Gear and DNA editor through the existing controls. Check that popups operate the same way. Review whether the current panel balance and icons are ready for M08-C hotspots.

For M08-C, retain the art aspect and crop anchor, then refine workstation discoverability and clickable hotspot focus with the existing actions. Keep raw IDs and any readable alias redesign scoped to the later inventory package.

## Changed files

- Presentation · scripts/coffee_dashboard.gd, scripts/orbital_art.gd and UID, scripts/cultivation_art.gd and UID.
- Runtime preparation · Six PNGs under assets/orbital_assets/runtime/; supplied originals are untouched.
- Tests · tests/test_orbital_art.gd, its UID and scene, tests/run-tests.ps1.
- Evidence · screenshots/m08b-chamber-1280.png and screenshots/m08b-chamber-1920.png.
- Documentation · docs/ASSET_MANIFEST.md, docs/PROJECT_STATUS.md, docs/DEVELOPMENT_LOG.md, docs/TESTING_REPORT.md, docs/VISUAL_DEVELOPMENT_PLAN.md and this report.

M08-C awaits owner approval.
