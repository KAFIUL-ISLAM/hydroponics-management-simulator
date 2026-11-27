# Project Status

## v1.0.0 release preparation

The completed project is prepared as v1.0.0 — Orbital Hydroponics: Technical Assessment Edition. The release is awaiting final GitHub publication. The latest published release remains v0.7.0 until remote verification succeeds.

The permanent clean Windows delivery pair is separate from the untracked workspace executable and PCK. Its accepted binaries have been hash-checked and preserved byte-for-byte.

## Implemented scope

- Three-crop cultivation for Coffee Beans, Nutrition Fruit and Kotton.
- Water, mineral, energy, pollution and inventory management.
- Growth, health, harvest, offspring and supported genetics.
- Equipment, vessels and compatible modules.
- Orbital workshop presentation and dedicated analysis tools.
- Mouse-first drag-and-drop and keyboard navigation.
- Bilingual presentation and Reduced Motion.
- Procedural one-shot audio controls.

The normal gameplay entry point is `scenes/workshop.tscn`. `scenes/main.tscn` and `scenes/coffee_dashboard.tscn` remain legacy compatibility entry points.

## Verification

The supplied M12 source handover reports 20/20 suites passed, 1,749 explicit automated checks, and four original crop assertion groups. The 461 workshop GUI, 72 audio and 38 Kotton checks are subsets of that total. The developer separately passed 29/29 manual checks on the original Windows build and 29/29 on the clean runtime-only build, with no issues reported for the clean build.

The protected simulation, crop resources and numerical expectations remain unchanged. No complete source regression was rerun for documentation-only changes.

M12 added no performance profile. M11 performance sampling remains historical and does not establish a bottleneck or repeatable speedup.

## Remaining limitations

- Independent target-hardware compatibility remains unverified.
- The project-wide software license remains unset.
- Artwork redistribution has been explicitly authorized by the developer.
- Some reference-derived boundaries and prototype policies remain unresolved.
- The all-resources PCK contains historical test scenes and screenshots.

See [Testing Report](TESTING_REPORT.md), [Development Log](DEVELOPMENT_LOG.md), [Chinese Technical Analysis](HYDROPONICS_DESIGN_ANALYSIS_ZH.md) and [Credits and Licenses](CREDITS_AND_LICENSES.md).
