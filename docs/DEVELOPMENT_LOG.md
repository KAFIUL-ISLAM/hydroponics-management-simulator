# Development Log

## 1. Research and planning

The project began as a Godot 4 study of hydroponic resource management inspired by *Probably Stolen*. Initial work established a three-crop scope, typed crop data, pure-water and mineral modelling, pollution boundaries, genetics and nightly settlement.

The implementation and its local simplifications are documented in [GDD.md](GDD.md), [FORMULAS.md](FORMULAS.md), [RESEARCH_NOTES.md](RESEARCH_NOTES.md), [CALCULATION_CONTRACT.md](CALCULATION_CONTRACT.md) and [EMPLOYER_REQUIREMENTS.md](EMPLOYER_REQUIREMENTS.md).

## 2. Core simulation

The simulation progressed through resource state, growth and health, water and mineral consumption, pollution, harvest and seed production. The four original crop assertion groups remain part of the regression baseline.

The architecture separates static crop resources from mutable plant and seed state. Liquid composition, mineral bands, full-transaction resource handling and deterministic fixtures are documented in [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md).

## 3. Equipment and genetics

Equipment, vessels, modules and DNA editing were added as separate presentation and domain concerns. Supported trait applications use finite disc charges and shared power through the normal nightly settlement path.

The legacy dashboard remains a compatibility entry point, while `scenes/workshop.tscn` became the normal visual and interaction entry point.

## 4. Workshop transformation

The interface evolved into an icon-based orbital workshop with drag-and-drop planting and resource installation, chamber feedback, individual output collection, environmental disposal, inventory and output capacity, and dedicated manual and analysis tools.

Visual and interaction decisions were coordinated with the existing crop art and workshop assets. Layout, screenshots and visual conventions are recorded in [VISUAL_DEVELOPMENT_PLAN.md](VISUAL_DEVELOPMENT_PLAN.md) and [VISUAL_STYLE_GUIDE.md](VISUAL_STYLE_GUIDE.md).

## 5. Interaction and accessibility

Later refinement distinguished hover, selection and keyboard focus. Tab navigation excludes drop-only slots; modal tools restore focus and retain inventory selection. Persistent blocker feedback was improved while temporary status feedback remained optional and non-blocking.

The interface preserves mouse-first drag-and-drop and Reduced Motion behavior. Holding Enter on Next Night and keyboard-visible states were included in developer manual acceptance.

## 6. Audio integration

The final audio integration added sixteen procedurally synthesized one-shot workshop effects. Master volume, SFX volume and mute are exposed through a bilingual settings console. Continuous ambience was removed. Audio observes existing workshop events and does not modify cultivation calculations.

Asset provenance and licensing status are recorded in [CREDITS_AND_LICENSES.md](CREDITS_AND_LICENSES.md) and [assets/audio/MANIFEST.md](../assets/audio/MANIFEST.md).

## 7. Verification and release status

The M12 source candidate is based on the published v0.7.0 baseline plus the accepted implementation and test changes. Automated source regression was reported as 20 suites and 1,749 explicit checks, including 461 workshop GUI checks and 72 audio checks. The GUI and audio checks are subsets of the 1,749 total.

The developer separately completed 29/29 standalone manual checks on each Windows build. The clean runtime-only build passed at both supported resolutions with no issues reported. These results are separate evidence sources. The controlled Kotton comparison remains 52% versus 100% health and 12 versus 13 fiber across the 1% and 3% concentration cases.

v1.0.0 is the completed Technical Assessment Edition prepared for GitHub publication. It has not been represented as published until remote release verification succeeds. The permanent clean EXE/PCK hashes were checked without substituting or modifying the accepted binaries. No project-wide software license or complete target-hardware compatibility claim has been established.

See [TESTING_REPORT.md](TESTING_REPORT.md), [M12 design analysis](HYDROPONICS_DESIGN_ANALYSIS_ZH.md) and [PROJECT_STATUS.md](PROJECT_STATUS.md).
