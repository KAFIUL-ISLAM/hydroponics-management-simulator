# M01-T03 — Configure the default main scene

**Date** 2026-11-26 (Asia/Shanghai) · **Baseline** `7b282e24dfff65957f8d181126c67da5498b7e2d` (`resources and simulator added`) plus the M01-T03 working-tree change · **Engine** Godot `4.7.2.stable.official.ed1daf0bf` on Windows

## Objective and exact change

Make normal Godot project launch open the existing hydroponics dashboard. Added one line under `[application]` in `project.godot`, immediately after `config/name`.

```diff
+run/main_scene="uid://lm4cvp2hfxau"
```

The UID matches the serialized UID on the first line of `scenes/main.tscn`. The project name, renderer, viewport, stretch settings, scene, and gameplay scripts were preserved. [Project config](../project.godot#L14) · [Dashboard scene UID](../scenes/main.tscn#L1)

## User manual verification of M01-T02

The user ran the dashboard in Godot at 1280 × 720 and provided before-and-after screenshots. They observed Day 1 and Growth 0 at startup and Day 2 and Growth 1 after one physical Next Night click. Lettuce remained selected, resources stayed at 1000 ml water, 50 ml minerals, and 100 kWh, and final status was `READY`. The user reported no errors during the session and verified rendering and interaction. Repository paths for the supplied screenshots have not been verified. These observations are separate from the M01-T02 automated diagnostics, which were preserved. [Testing report](TESTING_REPORT.md#8-2026-11-26--user-manual-verification-of-the-m01-t02-baseline) · [M01-T02 automated diagnostics](M01_T02_REPORT.md#diagnostics)

## Commands executed

`git ls-files` supplied 49 tracked file paths. I copied the files from the working tree into a new temporary `project` directory. This included the modified `project.godot`, whose copy matched the workspace file hash before import. The copy initially had no `.godot/` directory or project-local editor metadata. The original project's cache was left in place.

The first import command's PowerShell wrapper stopped on Godot's certificate-store stderr. I repeated the import from a new cache-free copy with stderr captured as diagnostic output. The following commands show the completed run, using portable paths for the executable and temporary copy.

```powershell
$engine = '<path to the Godot 4.7.2 executable>'
$reviewTemp = Join-Path ([IO.Path]::GetTempPath()) 'hydroponics-m01-t03'
$reviewProject = Join-Path $reviewTemp 'project'

git --no-optional-locks status --short --branch --untracked-files=all
git rev-parse HEAD
git --no-optional-locks ls-files
& $engine --version
& $engine --help

& $engine --headless --path $reviewProject --log-file (Join-Path $reviewTemp 'import.log') --editor --import
& $engine --headless --path $reviewProject --log-file (Join-Path $reviewTemp 'default-launch.log') --debug --verbose --quit-after 60
& $engine --headless --path $reviewProject --log-file (Join-Path $reviewTemp 'configured-probe.log') --debug --quit-after 60 --script (Join-Path $reviewTemp 'configured_dashboard_probe.gd')
& $engine --headless --path $reviewProject --log-file (Join-Path $reviewTemp 'previous-probe.log') --debug --quit-after 60 --script (Join-Path $reviewTemp 'dashboard_probe.gd')
& $engine --headless --path $reviewProject --log-file (Join-Path $reviewTemp 'crop-test.log') --debug --quit-after 60 'res://tetst/test_crop_resource.tscn'

git --no-optional-locks diff --name-status HEAD
git --no-optional-locks diff --check
git --no-optional-locks status --short --branch --untracked-files=all
```

The temporary `dashboard_probe.gd` is the exact probe from M01-T02. The companion probe uses the same snapshot and signal test, reads `application/run/main_scene` through `ProjectSettings`, loads that reference, and checks the resource path before instantiation. Both probes were outside the project copy. [Previous probe source](M01_T02_REPORT.md#temporary-dashboard-probe-source)

## Clean-context launch and runtime results

| Check | Expected | Observed | Result |
|---|---|---|---|
| Fresh project import | A project with no copied cache imports normally. | Started with no `.godot/`. Godot registered the project classes, imported assets, and exited 0. Global editor-settings diagnostics are listed below. | PASS |
| Normal launch after import | The engine loads the dashboard with no scene or script argument. | `Completed load for: 'res://scenes/main.tscn' remapped 'res://scenes/main.tscn' at thread -1`. Exit 0. The earlier missing-main-scene error did not recur. | PASS |
| Inspect configured scene | The configured UID resolves to `res://scenes/main.tscn`. | The companion probe printed `CONFIGURED_MAIN=uid://lm4cvp2hfxau` and `RESOLVED_MAIN=res://scenes/main.tscn`. Exit 0. | PASS |
| Initial dashboard state | Day 1, Growth 0, Lettuce, 1000 ml water, 50 ml minerals, 100 kWh, `READY`. | Both probes observed those exact values. The dashboard label strings agreed with the model. | PASS |
| One-night regression | Day 2, Growth 1, Lettuce, 1000 ml water, 50 ml minerals, 100 kWh, final `READY`. | Both probes emitted the connected Next Night button signal once and observed all expected values. Each printed `DEBUG_BUILD=true` and `BASELINE_MATCH=true`. | PASS |

The normal launch result comes from the separate Engine invocation without a scene or script argument. The probes provided the runtime snapshots by instantiating either the configured scene or the explicit baseline scene. The result demonstrates that the working-tree configuration works after a fresh Godot import without the workspace's project cache or editor metadata.

## Crop resource regression

The unchanged `res://tetst/test_crop_resource.tscn` ran in debug mode. The process exited 0 at the 60-iteration bound. [Checked-in test](../tetst/test_crop_resource.gd#L6)

| Group | Captured output | Result |
|---|---|---|
| 1 · Resource type | `TEST 1 PASSED: CropData resource loaded` | PASS |
| 2 · Identity | `TEST 2 PASSED: Crop identity verified` | PASS |
| 3 · Selected defaults | `TEST 3 PASSED: Default values verified` | PASS |
| 4 · Empty traits | `TEST 4 PASSED: Genetic traits initialized` | PASS |

The scene printed `========== ALL TESTS PASSED ==========`. No assertion failure or manual termination was observed.

## Errors and warnings

- Godot reported `Failed to read the root certificate store.` on import and runtime runs. This also occurred during M01-T02. The completed import and runtime checks exited 0.
- During clean import, Godot reported `Cannot save file` and `Error saving editor settings` for `%APPDATA%/Godot/editor_settings-4.7.tres`. This was a global editor-settings write diagnostic. Fresh project import and subsequent launch completed.
- The dashboard emitted the existing unused `crop` parameter warning. The crop test emitted seven existing redundant-assertion warnings at lines 10, 14–16 and 20–22. [Dashboard source](../scripts/main.gd#L96) · [Test source](../tetst/test_crop_resource.gd#L10)
- No scene-load error, GDScript parse error, missing resource, broken node reference, or assertion failure was observed on the completed runs.

## Manual verification required

The user already verified desktop rendering and the physical click on the unchanged dashboard. A desktop run through the **new default entry** was **NOT RUN** in M01-T03. To verify that path visually, open the project in Godot and press **F5** (**Run Project**). Confirm that the dashboard opens directly at Day 1 and Growth 0 without a main-scene selection prompt. Click **开始夜间结算** once and check Day 2, Growth 1, the unchanged crop and reserves, and final ready status. Use **F8** to stop.

## Changed files and Git diff

| File | M01-T03 change |
|---|---|
| [project.godot](../project.godot#L14) | Added the default main scene UID. |
| [docs/TESTING_REPORT.md](TESTING_REPORT.md) | Appended the user manual verification and this task's automated results. |
| [docs/PROJECT_STATUS.md](PROJECT_STATUS.md) | Recorded the resolved launch issue, verification status, and proposed next task. |
| [docs/DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md) | Appended the dated M01-T03 development entry. |
| [docs/M01_T03_REPORT.md](M01_T03_REPORT.md) | Added this report. |

The tracked diff from `HEAD` contains `project.godot`, `docs/DEVELOPMENT_LOG.md`, and `docs/TESTING_REPORT.md`. The testing report also contains the prior uncommitted M01-T02 appendix. The status document was already untracked, and this report is new and untracked. Pre-existing untracked files remain. `main` is still at `7b282e2`, at zero divergence from the locally recorded `origin/main`. No commits or pushes were made.

**Suggested commit message** `fix(project): set the dashboard as the main scene`

**Recommended next task** M01-T04, validate resource input types and amounts while preserving valid zero and exact-balance behavior. Wait for review before starting. [Foundation plan](FOUNDATION_STABILIZATION_PLAN.md#m01-t04--validate-resource-inputs)
