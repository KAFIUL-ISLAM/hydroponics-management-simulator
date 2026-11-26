# M01-T02 — Runtime baseline report

**Date** 2026-11-26 (Asia/Shanghai) · **Revision** `7b282e24dfff65957f8d181126c67da5498b7e2d` (`resources and simulator added`) · **Platform** Windows · **Godot** `4.7.2.stable.official.ed1daf0bf`

The dashboard loaded by explicit scene path, the initial and one-night runtime states matched the baseline, and all four checked-in crop test groups passed. Default project launch failed because no main scene is configured. The dashboard checks used headless debug execution.

## Git and environment

At task start, `main` was zero commits ahead of and behind the locally recorded `origin/main`. There were no tracked changes. `AGENTS.md`, `docs.zip`, `docs/FOUNDATION_STABILIZATION_PLAN.md`, `docs/M01_T01_REPORT.md`, `docs/PROJECT_AUDIT.md`, and `docs/PROJECT_STATUS.md` were already untracked. The run used the existing local checkout and its existing Godot import cache.

The installed executable returned the version above from `--version`. `project.godot` declares the 4.7 feature level and GL Compatibility. Static inspection found no `run/main_scene` in `[application]`. [Project settings](../project.godot#L11)

## Commands executed

The recorded arguments are shown with portable paths. The script and logs were written under the Windows temporary directory, outside the checkout.

```powershell
$godotPath = '<path to the Godot 4.7.2 executable>'
$projectPath = (Get-Location).Path
$baselineTemp = Join-Path ([IO.Path]::GetTempPath()) 'hydroponics-m01-t02'
New-Item -ItemType Directory -Path $baselineTemp -Force | Out-Null

git --no-optional-locks status --short --branch --untracked-files=all
git rev-parse HEAD
git rev-list --left-right --count 'HEAD...@{upstream}'
& $godotPath --version
& $godotPath --help

& $godotPath --headless --debug --path $projectPath --quit-after 60 --log-file NUL 'res://scenes/main.tscn'
& $godotPath --headless --debug --path $projectPath --quit-after 60 --log-file (Join-Path $baselineTemp 'dashboard.log') 'res://scenes/main.tscn'
& $godotPath --headless --debug --path $projectPath --quit-after 60 --log-file (Join-Path $baselineTemp 'probe.log') --script (Join-Path $baselineTemp 'dashboard_probe.gd')
& $godotPath --headless --debug --path $projectPath --quit-after 60 --log-file (Join-Path $baselineTemp 'crop-test.log') 'res://tetst/test_crop_resource.tscn'
& $godotPath --headless --debug --path $projectPath --quit-after 60 --log-file (Join-Path $baselineTemp 'default-launch.log')

git --no-optional-locks diff --name-status HEAD
git --no-optional-locks status --short --branch --untracked-files=all
```

The launch without a scene reported its error and remained open. I identified and stopped the verification process (PID `13412`) after capturing the error. PowerShell reported `-1` after termination. The explicit dashboard and crop-test invocations reached the iteration limit and exited with `0`. The probe also exited with `0` after its comparison.

## Dashboard runtime evidence

| Check | Result | Observation |
|---|---|---|
| Executable version and launch setting inspection | PASS | `--version` returned the recorded version, and `[application]` has no default scene. |
| Explicit scene loading | PASS | `res://scenes/main.tscn` loaded. No scene-load, GDScript parse, missing-resource, or invalid-node-reference errors appeared. |
| Initial game state and labels | PASS | The probe instantiated the dashboard and read its live nodes and text. |
| One night through the actual button connection | PASS | The probe confirmed the connection to `_on_next_night_button_pressed`, emitted `NextNightButton.pressed` once, and read the resulting state and text. |
| Default project launch | FAIL | Godot reported `Error: Can't run project: no main scene defined in the project.` |
| Visible desktop rendering, layout and physical click | NOT RUN | Headless execution exercised the signal and checked label strings. No window was visually inspected and no physical button click was performed. |
| Export | NOT RUN | Outside this baseline. |

The expected values are from source analysis. The actual values below are observations from this run. The probe printed `DEBUG_BUILD=true` and `BASELINE_MATCH=true`. [Scene wiring](../scenes/main.tscn#L419) · [Dashboard action](../scripts/main.gd#L93) · [Night simulation](../scripts/hydroponics_simulator.gd#L29)

| Field | Expected before | Actual before | Expected after one night | Actual after one night |
|---|---|---|---|---|
| Day | 1 | 1 | 2 | 2 |
| Crop | Lettuce prototype | Lettuce (`lettuce_prototype`) | Lettuce prototype | Lettuce (`lettuce_prototype`) |
| Growth | 0 | 0 | 1 | 1 |
| Water | 1000 ml | 1000 ml | 1000 ml | 1000 ml |
| Minerals | 50 ml | 50 ml | 50 ml | 50 ml |
| Electricity | 100 kWh | 100 kWh | 100 kWh | 100 kWh |
| Status | `READY` | `READY` | `READY` | `READY` |

The observed day label changed from `第 1 天` to `第 2 天`, and the growth label changed from `生长进度 / Growth: 0` to `生长进度 / Growth: 1`. The other sampled labels stayed at `● 运行正常`, `生菜 / Lettuce`, `1000 ml`, `50 ml`, and `100 kWh`. Unchanged reserves match the provisional zero-cost lettuce and the current settlement path, which has no electricity debit. [Lettuce data](../resources/lettuce_prototype.tres#L5) · [Cost defaults](../scripts/crop_data.gd#L37) · [Current debits](../scripts/hydroponics_simulator.gd#L42)

## Existing crop resource test

Ran `res://tetst/test_crop_resource.tscn` with the installed debug-capable executable and `--debug`. The scene's four groups printed the following results. [Existing test script](../tetst/test_crop_resource.gd#L6)

| Group | Result | Captured output |
|---|---|---|
| 1 · Preloaded resource type | PASS | `TEST 1 PASSED: CropData resource loaded` |
| 2 · Crop ID and names | PASS | `TEST 2 PASSED: Crop identity verified` |
| 3 · Selected default values | PASS | `TEST 3 PASSED: Default values verified` |
| 4 · Empty traits dictionary | PASS | `TEST 4 PASSED: Genetic traits initialized` |

**Overall PASS.** The scene printed `========== ALL TESTS PASSED ==========` with no assertion failures. The 60-iteration bound stopped the process automatically. No manual termination or changes to the test were required. This verifies the four groups in the checked-in scene. The prior screenshots of other checks remain historical evidence. [Testing report](TESTING_REPORT.md)

## Diagnostics

| Diagnostic | Where it appeared | Effect |
|---|---|---|
| `ERROR: Failed to read the root certificate store.` | Dashboard, probe and crop-test runs. The source location was `get_system_ca_certificates` at `platform/windows/os_windows.cpp:2582`. | Windows engine diagnostic. The three checks completed. Its underlying cause was not established. |
| `WARNING: The parameter "crop" is never used in the function "_on_crop_growth_changed()".` | Dashboard and probe. [main.gd](../scripts/main.gd#L96) | GDScript reload warning. Scene and state checks passed. |
| `WARNING: Assert statement is redundant because the expression is always true.` | Seven occurrences in the crop test at lines 10, 14–16, and 20–22. [Test script](../tetst/test_crop_resource.gd#L10) | GDScript reload warnings. All four groups reached their pass messages. |
| Reserved Windows pipe warning and `ERROR: Failed to open log file for writing: NUL` | First explicit dashboard invocation. | Logging setup diagnostic. The subsequent recorded run used an ordinary temporary log file. |
| `Error: Can't run project: no main scene defined in the project.` | Default launch with no explicit scene. | Default launch failed before reaching the dashboard. |

## Manual verification still required

1. Open `project.godot` in the Godot 4.7.2 editor. In the FileSystem panel, open `res://scenes/main.tscn` and use **F6** (**Run Current Scene**) while that scene is active.
2. In the running game window or embedded game view, inspect the dashboard. Verify that the day reads 1, the crop is `生菜 / Lettuce`, growth is 0, the status reads `● 运行正常`, and the resource cards show 1000 ml, 50 ml, and 100 kWh. Check that the labels are readable at the target viewport.
3. Click **开始夜间结算** once. Verify Day 2 and Growth 1, the same crop and reserves, and the final ready status. Check the editor Output and Debugger panels. Use **F8** to stop.

## Changes and recommendation

| Changed file | Change |
|---|---|
| [docs/TESTING_REPORT.md](TESTING_REPORT.md) | Appended dated results and diagnostics. Historical entries were preserved. |
| [docs/PROJECT_STATUS.md](PROJECT_STATUS.md) | Recorded the verified runtime baseline, default launch failure, outstanding manual checks, and next task. |
| [docs/M01_T02_REPORT.md](M01_T02_REPORT.md) | Added this standalone report and reproduced the temporary probe below. |

At handoff, the tracked diff contains only `docs/TESTING_REPORT.md`. `docs/PROJECT_STATUS.md` was already untracked and was updated in place. This report is new and untracked. The other pre-existing untracked files remain present. The revision and locally recorded upstream divergence are unchanged. No commits or pushes were made.

**Recommend M01-T03 after review.** Configure `scenes/main.tscn` as the main scene in `project.godot`, then verify normal launch without an explicit scene and rerun the existing crop test. Use the initial values above as the comparison baseline. [Foundation plan](FOUNDATION_STABILIZATION_PLAN.md#m01-t03--configure-the-default-main-scene)

## Temporary dashboard probe source

Save this as `dashboard_probe.gd` in a temporary directory to reproduce the signal-path observation with the invocation above. This script was not added to the project's test suite.

```gdscript
extends SceneTree

func _initialize() -> void:
	call_deferred("_check_dashboard")

func _check_dashboard() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		push_error("Baseline probe could not load the dashboard scene.")
		quit(1)
		return
	var dashboard = packed.instantiate()
	root.add_child(dashboard)

	var night_button := dashboard.get_node_or_null(
		"SafeArea/MainLayout/ControlBar/ControlContent/NextNightButton"
	) as Button
	if night_button == null or not night_button.pressed.is_connected(
		dashboard._on_next_night_button_pressed
	):
		push_error("The dashboard's Next Night connection is absent.")
		quit(1)
		return

	print("DEBUG_BUILD=", OS.is_debug_build())
	var before := _snapshot(dashboard)
	print("BEFORE=", JSON.stringify(before))
	night_button.pressed.emit()
	var after := _snapshot(dashboard)
	print("AFTER=", JSON.stringify(after))
	var state_ok := _matches(before, 1, 0) and _matches(after, 2, 1)
	print("BASELINE_MATCH=", state_ok)
	quit(0 if state_ok else 1)

func _snapshot(dashboard: Control) -> Dictionary:
	var game_state = dashboard.game_state
	var simulator = dashboard.hydroponics_simulator
	var manager = dashboard.resource_manager
	var crop = game_state.selected_crop
	return {
		"day": game_state.current_day,
		"status": game_state.SimulationStatus.keys()[game_state.status],
		"crop_id": String(crop.crop_id),
		"crop_name": crop.display_name_en,
		"growth": simulator.current_growth,
		"water_ml": manager.water_ml,
		"minerals_ml": manager.minerals_ml,
		"electricity_kwh": manager.electricity_kwh,
		"labels": [
			dashboard.day_label.text,
			dashboard.status_label.text,
			dashboard.crop_empty_title.text,
			dashboard.crop_growth_label.text,
			dashboard.water_value_label.text,
			dashboard.mineral_value_label.text,
			dashboard.electricity_value_label.text,
		],
	}

func _matches(snapshot: Dictionary, day: int, growth: int) -> bool:
	return snapshot.day == day and snapshot.growth == growth \
		and snapshot.status == "READY" and snapshot.crop_id == "lettuce_prototype" \
		and snapshot.water_ml == 1000.0 and snapshot.minerals_ml == 50.0 \
		and snapshot.electricity_kwh == 100.0
```
