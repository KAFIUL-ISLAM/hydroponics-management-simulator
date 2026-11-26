# M01 final acceptance — Hydroponics simulation foundation

**Date** 2026-11-26 (Asia/Shanghai) · **Branch** `main` · **Pre-checkpoint base** `7b282e24dfff65957f8d181126c67da5498b7e2d` · **Engine** Godot `4.7.2.stable.official.ed1daf0bf`, Windows

The user reviewed and approved Packages A, B, and C and reported a successful final desktop smoke check. The publication candidate passed the automated regression gate. The pre-commit fetch found local and remote `main` aligned at the base above. `v0.1.0` was absent from both tag lists at the preflight check.

## Accepted scope

| Area | Accepted result |
|---|---|
| Package A · Baseline and startup | Documented and reproduced the baseline, configured default dashboard launch, and validated single-resource input and arithmetic. |
| Package B · Resource and settlement | Reset restores configured starting balances. Nightly water and mineral costs settle atomically. A shortage advances time without spending resources or growing the crop. A configuration failure preserves the day. `GameState` publishes a typed terminal outcome after finalizing the lifecycle state. |
| Package C · Dashboard and tests | Dashboard startup reads live state. Bilingual feedback distinguishes growth, shortage, configuration error, and an idle night. Tests run from `tests/` using a consolidated PowerShell runner. |

See the [foundation acceptance plan](FOUNDATION_STABILIZATION_PLAN.md), [Package B evidence](M01_PACKAGE_B_REPORT.md), and [Package C evidence](M01_PACKAGE_C_REPORT.md).

## Final regression evidence

The publication candidate was copied into a temporary project without an existing Godot cache and imported with the consolidated runner. The original dashboard probe was extracted from the M01-T02 report and run unchanged.

| Check | Result |
|---|---|
| Crop resource | Four original debug assertion groups and final completion marker passed. |
| Resource manager | 192 checks, zero failures. |
| Night state | 133 checks, zero failures. |
| Dashboard startup and feedback | 31 checks, zero failures. |
| Nightly dashboard integration | 97 checks, zero failures. |
| Final runner result | **PASS.** Five of five suites, 453 explicit checks plus the four original crop groups. Exit 0. Prior Package C controls verified that the runner rejects a failed expectation and rejects an unexpected engine error even with a success marker and exit 0. |
| Default project launch | **PASS.** Godot loaded `res://scenes/main.tscn` without a scene argument. Exit 0. |
| Original one-night probe | **PASS.** `BASELINE_MATCH=true`, exit 0. Day 1 → 2, Growth 0 → 1. Lettuce, 1000 ml water, 50 ml minerals, and 100 kWh remained unchanged. Final status `READY`. |
| Final desktop smoke check | **PASS, user-reported.** The earlier 1280 × 720 Day 1 and Day 2 images document the M01-T02 baseline. [Day 1](../screenshots/m01-t02-baseline-day1.png) · [Day 2](../screenshots/m01-t02-baseline-day2.png) |

The Windows certificate-store diagnostic recurred. Fresh editor import reported its known global settings write diagnostic. The original crop assertions and fixture warnings remain documented. The final automated gate and both smoke commands completed successfully. [Testing log](TESTING_REPORT.md#13-2026-11-26--final-m01-regression-gate)

### Reproduce the gate

From the project root, provide the actual executable path.

```powershell
$godot = '<path to the Godot 4.7.2 executable>'
$project = (Get-Location).Path
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\tests\run-tests.ps1 -GodotPath $godot -Import
if ($LASTEXITCODE -ne 0) { throw 'The M01 suite failed.' }
& $godot --headless --debug --path $project --quit-after 90 --verbose
```

For the one-night probe, save the [archived GDScript](M01_T02_REPORT.md#temporary-dashboard-probe-source) to a temporary `dashboard_probe.gd` and run the following. Confirm `BASELINE_MATCH=true` and exit 0.

```powershell
$probe = Join-Path ([IO.Path]::GetTempPath()) 'dashboard_probe.gd'
& $godot --headless --debug --path $project --quit-after 90 --script $probe
```

## Publication review

The reviewed milestone includes the Godot project and scene, production code and crop resource, required UID files, test scenes and PowerShell runner, documentation and baseline screenshots. Public command examples use repository-relative paths, executable placeholders and temporary-directory variables. Historical invocations retain their engine arguments and recorded outcomes.

The `.godot/` cache, local `docs.zip`, temporary logs, and editor-generated working files are outside the publication candidate. The local root-level `crop_resource_test.tscn` is a duplicate harness that refers to the former test path. The active harness lives under `tests/`.

## Known limitations and next milestone

Lettuce still uses provisional values, including zero nightly water and mineral costs. M01 provides lifecycle and resources infrastructure. Planting and harvesting, crop-instance state, concentration, health, pollution, power consumption, and verified crop tuning remain future work. The approved shortage and configuration-error behavior is an engineering policy. Export and narrow-window layout remain unverified.

**M02 recommendation.** Choose the first playable crop and agree on its source-backed data, units, rounding, and acceptance cases. Then build one complete planting-to-harvest loop on the existing dashboard and ledger. The five-suite runner remains the foundation regression gate. [Project status](PROJECT_STATUS.md#next-recommended-task)
