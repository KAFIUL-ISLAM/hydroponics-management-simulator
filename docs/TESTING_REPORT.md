# Testing Report

## Final automated regression

The M12 source candidate's supplied regression handover reports:

- 20/20 suites passed.
- 1,749 explicit automated checks passed.
- Four original crop assertion groups remained intact.
- 461 workshop GUI checks were included in the total.
- 72 audio checks were included in the total.
- 38 Kotton experiment checks were included in the total.
- Default launch and legacy Lettuce baseline passed.
- Standalone startup and normal exit were reported.
- Renderer captures were checked at 1280 × 720 and 1920 × 1080.

GUI, audio and Kotton checks are subsets of the 1,749 explicit checks, not additional totals. This evidence came from the supplied M12 handover and was not independently rerun against the current documentation-only checkout.

## Final manual acceptance

The developer reported **29/29 standalone manual checks passed** for the original Windows build and **29/29 passed** for the clean runtime-only build, with no clean-build issues reported. Clean acceptance covered both supported resolutions, all three crops, cultivation and collection, resource recovery, drag interactions, five instruments, audio, accessibility, exit, restart and preference persistence. These are separate from the automated source regression.

The mounted clean PCK had 142 entries, including all 69 required resource paths and their payloads. It excluded development tests, historical screenshots, documentation, reference assets and the audio generator. The clean runtime preserves legacy Lettuce compatibility and 16 original one-shot effects. The workshop has no continuous ambience.

Earlier milestone acceptance also remains historical evidence:

- M10: 19/19 developer checks.
- M11: 30/30 developer checks.
- M12 original Windows build: 29/29 developer checks.

Manual acceptance does not establish cross-hardware compatibility or replace source-regression evidence.

## Deterministic Kotton experiment

The deterministic fixture uses native Kotton, 5,000 mL pure water, 100 kJ, a standard machine, no modules, no extra pollution and RNG seed 42. Only starting mineral volume changes: 50 mL for 1% and 150 mL for 3%.

| Result | 1% case | 3% case |
| --- | ---: | ---: |
| Initial concentration | 1.000% | 3.000% |
| Final concentration | 0.917029% | 2.917298% |
| Maturity | Night 6 / growth 48 | Night 6 / growth 48 |
| Mixed solution consumption | 1,500 mL | 1,500 mL |
| Energy consumption | 48 kJ | 48 kJ |
| Mineral absorption | 3.6 mL | 3.6 mL |
| Final health | 52% | 100% |
| Harvest | 12 Regular fiber | 13 Large fiber |
| Offspring | 2 seeds | 2 seeds |

Initial concentration is calculated against pure water:

\[
 C = 100 \times \frac{M}{W}
\]

The implementation and fixture are in `scripts/liquid_composition.gd` and `tests/test_m10_nutrient_demo.gd`.

## Historical regression milestones

The project accumulated focused source suites as the implementation matured. Major historical totals were 1,104 checks in M07-era packages, 1,252 checks in M08-C.3, 1,362 checks in M09, 1,440 in M10, 1,480 in M11, and 1,749 in M12. Each historical result refers to its recorded checkout and runner; later totals include new suites and are not additive to earlier totals.

The final candidate retained the four original crop assertion groups used throughout the baseline.

## M11 test boundaries

The M11 handover reported 19 suites and 1,480 explicit checks, including 264 workshop GUI checks, plus four crop assertion groups. It also reported successful default launch, legacy Lettuce and Kotton fixtures, and renderer captures at both supported resolutions.

The automated Enter test does not independently prove a complete initial press followed by held-repeat event sequence. Reduced Motion collection and manual-tab keyboard-focus styling were developer-verified, not established solely by that suite.

The M11 performance handover reports graphical frame samples and three-sample settlement timing medians. The sample allocation is not fully specified, and the limited timing sample size does not establish a bottleneck or repeatable speedup.

## M12 audio and presentation

The M12 candidate reports 72 audio checks, including master/SFX/mute behavior, legacy preference handling and identical cultivation with mute on and off. Engine-side playback and settings layout were checked at both resolutions. Independent audible listening and target-hardware output quality were not established.

The all-resources PCK contains historical test scenes and screenshots according to the existing export preset. It does not establish a fresh clean-target application review.

## Reproduction

With a suitable Godot executable, the complete suite can be run from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\tests\run-tests.ps1 -GodotPath "<Godot executable path>" -Import
```

The deterministic Kotton fixture is:

```text
Godot --headless --debug --path . res://tests/test_m10_nutrient_demo.tscn
```

## Verification boundaries

- Godot was unavailable on the documentation tool's PATH during the final documentation corrections.
- The complete source suite and Kotton scene were not rerun for documentation-only changes.
- Independent package launch on target hardware was not established.
- Permanent delivery package hashes were checked separately against `BUILD_MANIFEST.md` and `SHA256SUMS.txt`.
- No performance improvement or cross-hardware result is claimed for M12.
