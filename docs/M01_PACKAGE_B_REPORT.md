# M01 Package B — Resource and settlement stabilization

**Date** 2026-11-26 (Asia/Shanghai) · **Revision** `7b282e24dfff65957f8d181126c67da5498b7e2d` (`resources and simulator added`) plus working-tree changes · **Engine** Godot `4.7.2.stable.official.ed1daf0bf`, Windows

The approved M01-T04 tests and API were the starting point. T05, T06, and T07 were applied and verified in sequence. All three tasks passed their acceptance checks. The dashboard, crop formulas, and provisional Lettuce baseline were preserved.

## Individual acceptance results

| Task | Acceptance checks | Result |
|---|---|---|
| M01-T05 · Configured reset | Capture before the first ready notification. Restore 1000 ml / 50 ml / 100 kWh defaults or overrides of 125.5 ml / 7.25 ml / 16.75 kWh after credits and debits. Verify one coherent snapshot per reset, including repeated reset. Early reset changes and emits nothing. Reentry with `request_ready()` preserves the original capture. | **PASS.** Focused resource run reported 136 checks and zero failures. |
| M01-T06 · Atomic consumption | Validate malformed keys, nonnumeric and non-finite quantities, negative amounts and invalid affected balances. Validate the entire request before deciding affordability. Verify water and mineral shortages, shortage payload, exact balance, zero and empty batches, an observer reading committed balances, and unchanged growth and balances on rejected nights. | **PASS.** Focused resource run reported 189 checks and zero failures. Three final checks also verified that a successful zero-cost night grows once without emitting a resource signal, bringing the final resource suite to 192 checks. |
| M01-T07 · Settlement transitions | Verify successful, short, idle and configuration-error nights. Check guards from start, resource and finish callbacks. Reject direct execution and external completion. Verify typed outcomes, event order, terminal state, recovery after replenishment or restored configuration, and crop selection after the night returns. | **PASS.** Night-state suite reported 133 checks and zero failures. |

## Resource transaction contract

`ResourceManager` captures its starting values at first `_ready()`, before the startup snapshot. `reset_resources()` restores those three values together and emits one snapshot per initialized call. A pre-initialization reset warns and leaves the node unchanged. The capture is per instance and survives removal and readiness on tree reentry.

`try_consume_batch(costs)` accepts a dictionary keyed by integer `ResourceType` values with integer or float costs in the existing units. It validates every cost and affected balance, then determines affordability before writing. It returns a typed `ConsumptionResult`:

| Status | Contract |
|---|---|
| `SUCCESS` | Applies all debits together. Emits exactly one `resources_changed` snapshot when any balance changes. Zero or empty batches succeed without emitting. |
| `INVALID_INPUT` | An unknown or malformed key, invalid amount, or invalid affected balance rejects the entire batch. A malformed entry takes precedence over a shortage elsewhere in the same request. |
| `INSUFFICIENT_RESOURCES` | A valid but unaffordable request rejects the entire batch. The returned result identifies the first shortage in request order and carries its requested and available amounts. |

Rejected batches leave all balances intact and emit neither resource signal. Batch shortage information is available through the return value. Existing single-resource `add_resource()`, `try_consume()`, and `can_consume()` retain their validation, return values and signal behavior, including successful zero operations and the single-debit shortage signal. No new rounding or conversion was added. [ResourceManager API](../scripts/resource_manager.gd#L92)

## Settlement lifecycle contract

These are approved **provisional engineering policies** for the foundation. They are separate from the reference-game research.

`GameState.start_night()` is the entry point. A return value of `true` means the request was accepted for evaluation, including when the resulting outcome is a configuration error. GameState locks the lifecycle, sets `PROCESSING`, emits the status/start notifications, then calls the registered simulator. A private one-use permit is issued after start notifications and consumed before the simulator can mutate anything. The simulator calculates the existing fixed costs, calls the atomic resource API, and increments growth only on success.

| Typed outcome | Day | Resources and crop growth |
|---|---|---|
| `GROWN` | Advances once | Valid costs commit together, and growth advances once. |
| `SHORTAGE` | Advances once | Balances and growth stay unchanged. The outcome carries the shortage resource and quantities. |
| `CONFIGURATION_ERROR` | Stays on the current day | Balances and growth stay unchanged. This covers missing wiring or manager, invalid costs or affected balance, and unauthorized execution. |
| `NO_CROP` | Advances once | Preserves the existing idle-night behavior with valid wiring. Balances and growth stay unchanged. |

GameState finalizes the day and sets `READY` before publishing the terminal notifications. It emits `status_changed(READY)`, then `day_changed` if the day advanced, then `night_processing_finished(completed_day, next_day, outcome)`. The lifecycle guard remains active through those callbacks, so they see finalized values but cannot start another night, pause, or change the crop. It unlocks when `start_night()` finishes. The former external `complete_night()` method was removed. The finished signal now carries the typed outcome as its third argument. There were no existing production subscribers to migrate. The dashboard continues to use its existing day, status, and growth bindings. [GameState lifecycle](../scripts/game_state.gd#L74) · [Simulator](../scripts/hydroponics_simulator.gd#L40)

## Final automated verification

| Check | Actual result |
|---|---|
| ResourceManager scene | **PASS.** `RESOURCE_MANAGER_TEST_RESULT checks=192 failures=0`, exit 0. This includes the original 118 validation checks. |
| Night-state scene | **PASS.** `NIGHT_STATE_TEST_RESULT checks=133 failures=0`, exit 0. |
| Resource failure detection | **PASS.** A temporary expected lookup value of `1.0` provoked the named failed check. Completion reported `checks=192 failures=1`, exit 1. |
| Night failure detection | **PASS.** Inverting the temporary debug-build expectation provoked the named failed check. Completion reported `checks=133 failures=1`, exit 1. |
| Existing crop resource scene | **PASS.** All four assertion group markers and `ALL TESTS PASSED`, bounded exit 0. |
| Normal launch | **PASS.** With no scene argument, Godot completed loading `res://scenes/main.tscn` and exited 0. |
| Unchanged M01-T02 dashboard probe | **PASS.** `BASELINE_MATCH=true`, exit 0. Actual Day 1 → 2 and Growth 0 → 1. Lettuce and balances of 1000 ml water, 50 ml minerals, and 100 kWh remained unchanged. Final status `READY`. |
| Desktop verification, physical click and export | **NOT RUN** during Package B. The existing probe emits the connected signal and inspects live state and labels. |

The bounded commands were checked for the expected exit, completion markers, and absence of `SCRIPT ERROR`. A zero exit from the iteration limit alone could not pass. Both negative controls ran in a freshly imported temporary project and changed only copies of the test scripts. [Recorded testing results](TESTING_REPORT.md#11-2026-11-26--m01-package-b-resource-and-settlement-stabilization)

## Reproducible commands

Run from the repository root. Use a writable temporary log directory. The archived probe was extracted unchanged from the M01-T02 report. [Probe source](M01_T02_REPORT.md#temporary-dashboard-probe-source)

```powershell
$engine = '<path to the Godot 4.7.2 executable>'
$projectPath = (Get-Location).Path
$caseLogs = Join-Path ([IO.Path]::GetTempPath()) 'hydroponics-m01-package-b'
New-Item -ItemType Directory -Path $caseLogs -Force | Out-Null
$probePath = Join-Path $caseLogs 'dashboard_probe.gd'
$probeSource = [regex]::Match(
    (Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $projectPath 'docs/M01_T02_REPORT.md')),
    '(?ms)^\x60{3}gdscript\r?\n(.*?)^\x60{3}'
)
if (-not $probeSource.Success) { throw 'Baseline probe not found' }
[IO.File]::WriteAllText($probePath, $probeSource.Groups[1].Value, [Text.UTF8Encoding]::new($false))
& $engine --version

function Test-GodotRun($name, [string[]]$runArgs, [string[]]$markers, [int]$expectedExit = 0, [string]$gamePath = $projectPath) {
    $lines = @(& $engine --headless --debug --path $gamePath --quit-after 60 --log-file (Join-Path $caseLogs "$name.log") @runArgs 2>&1 | ForEach-Object { "$_" })
    $actualExit = $LASTEXITCODE
    $outputText = $lines -join "`n"
    Write-Output "RUN=$name EXIT=$actualExit"
    if ($actualExit -ne $expectedExit -or $outputText -match '(?m)^SCRIPT ERROR:') {
        throw "Unexpected failure in $name"
    }
    foreach ($marker in $markers) {
        if ($outputText -notmatch $marker) { throw "$name missing expected output $marker" }
    }
}
Test-GodotRun 'final-resource' @('res://tetst/test_resource_manager.tscn') @('(?m)^RESOURCE_MANAGER_TEST_RESULT checks=192 failures=0\s*$')
Test-GodotRun 'final-night' @('res://tetst/test_night_state.tscn') @('(?m)^NIGHT_STATE_TEST_RESULT checks=133 failures=0\s*$')
Test-GodotRun 'final-crop' @('res://tetst/test_crop_resource.tscn') @('TEST 1 PASSED', 'TEST 2 PASSED', 'TEST 3 PASSED', 'TEST 4 PASSED', 'ALL TESTS PASSED')
Test-GodotRun 'final-launch' @('--verbose') @("Completed load for: 'res://scenes/main.tscn'")
Test-GodotRun 'final-dashboard' @('--script', $probePath) @('DEBUG_BUILD=true', 'BASELINE_MATCH=true')
```

The T05 and T06 focused runs invoked the same resource scene with `t05-resource.log` and `t06-resource.log`, respectively, against those intermediate working-tree versions. To repeat the failure controls, build a separate copy of the tracked working-tree files and the ResourceManager and night-state test files under `$caseLogs/negative-control-project`. Only in that copy, change the unknown lookup expectation from `0.0` to `1.0`, and invert `OS.is_debug_build()` in `_ready()` of the night-state test. Run the following against that copy.

```powershell
$testCopy = Join-Path $caseLogs 'negative-control-project'
& $engine --headless --path $testCopy --editor --import --log-file (Join-Path $caseLogs 'negative-control-import.log')
Test-GodotRun 'negative-resource' @('res://tetst/test_resource_manager.tscn') @('RESOURCE_MANAGER_TEST_RESULT checks=192 failures=1', 'RESOURCE_MANAGER_CHECK_FAILED: unknown resource lookup') 1 $testCopy
Test-GodotRun 'negative-night' @('res://tetst/test_night_state.tscn') @('NIGHT_STATE_TEST_RESULT checks=133 failures=1', 'NIGHT_STATE_CHECK_FAILED: Run this test in a debug build') 1 $testCopy
```

## Diagnostics and remaining risks

- Expected fixtures produced 20 invalid single-request warnings, one overflow warning, two early-reset warnings, and a missing-ResourceManager warning in the night suite. The negative controls produced the intended check errors.
- The Windows root certificate-store error recurred. The temporary import also reported a failure to save global Godot editor settings, then completed with exit 0. The existing unused dashboard `crop` parameter warning and seven redundant crop-test assertion warnings recurred. A temporary T06 test-variable shadowing warning was removed before the final runs. There were no unexpected GDScript errors or failed checks in the final suites.
- The exported resource fields remain directly writable. Initialization captures the configured values as supplied, and batch validation covers the requested balances. A direct write can therefore still bypass the ledger and affect snapshots or the captured baseline.
- The guard protects the supported lifecycle APIs. The night is synchronous and there is no resumable processing step. Existing editable crop configuration and resource properties still need owners to avoid direct mutations during callbacks.
- The dashboard still has no visible shortage result. No power gating, new formulas, or crop mechanics were introduced.

## Changed files and Git diff

| Files | Package B change |
|---|---|
| [scripts/resource_manager.gd](../scripts/resource_manager.gd) | Updated `_ready()` and `reset_resources()`. Added `ConsumptionStatus`, `ConsumptionResult`, and `try_consume_batch()`. |
| [scripts/game_state.gd](../scripts/game_state.gd) | Added `NightStatus`/`NightOutcome`, simulator registration and permit methods. Updated `start_night()`, completion signaling, state/crop access, and pause and selection guards. Removed `complete_night()`. |
| [scripts/hydroponics_simulator.gd](../scripts/hydroponics_simulator.gd) | Updated `_ready()`, `_on_crop_selected()`, and `process_crop_night()`. Replaced start-signal orchestration with the GameState-authorized call and atomic consumption. |
| [tetst/test_resource_manager.gd](../tetst/test_resource_manager.gd) | Extended the existing suite with reset, batch, and nightly batch checks. |
| [tetst/test_night_state.gd](../tetst/test_night_state.gd), [scene](../tetst/test_night_state.tscn), [script UID](../tetst/test_night_state.gd.uid) | Added the headless lifecycle suite and its Godot scene and UID. |
| [docs/PROJECT_STATUS.md](PROJECT_STATUS.md), [docs/TESTING_REPORT.md](TESTING_REPORT.md), [docs/DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md) | Updated current status and appended dated verification and development records. |
| [docs/M01_PACKAGE_B_REPORT.md](M01_PACKAGE_B_REPORT.md) | Added this consolidated handoff. |

`main` remains at `7b282e2`, with zero divergence from the locally recorded `origin/main`. The tracked diff from `HEAD` covers the three gameplay scripts and two tracked log documents, plus the pre-existing default main-scene change in `project.godot`. This package also updated the already-untracked resource test and status document and added the night suite and report. Existing untracked files were preserved. No commits or pushes were made.

**Suggested commit message** `fix(simulation): stabilize resource reset and nightly settlement`

**Recommended next package** M01-T08 through M01-T10. Synchronize the dashboard from live state, surface the typed shortage outcome, and add repeatable dashboard integration tests. Keep M01-T11 as the separate test-directory migration. [Foundation plan](FOUNDATION_STABILIZATION_PLAN.md#m01-t08--synchronize-the-dashboard-on-entry)
