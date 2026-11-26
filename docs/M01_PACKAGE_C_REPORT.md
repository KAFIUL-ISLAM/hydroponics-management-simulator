# M01 Package C — Foundation stabilization handoff

**Date** 2026-11-26 (Asia/Shanghai) · **Baseline** `7b282e24dfff65957f8d181126c67da5498b7e2d` plus working-tree changes · **Engine** Godot `4.7.2.stable.official.ed1daf0bf` on Windows

M01-T08 through M01-T11 passed their automated acceptance checks. The consolidated runner passed all five suites after a fresh import. Default launch and the original Lettuce probe passed from the same clean-context copy.

## Acceptance results

| Task | Evidence | Result |
|---|---|---|
| M01-T08 · Dashboard startup | The dashboard connects to child signals, then reads live day, lifecycle, crop, growth, and reserves. A test fixture advances a night before the parent is ready and checks that the initial panel reflects that growth. Other checks cover the default scene, non-default balances, an empty crop, and the Next Night button during and after settlement. | PASS, 21 focused checks. |
| M01-T09 · Settlement feedback | The typed night outcome renders bilingual growth, shortage, configuration-error, and no-crop messages. A shortage displays resource, requested and available quantities, and the unit. The separate header reports lifecycle `READY`. A new night or crop selection clears stale feedback, and success after replenishment replaces it. | PASS, 31 startup and feedback checks. |
| M01-T10 · Nightly integration | Test-only crop resources exercise the existing button signal, exact water/mineral debits, both shortages, unchanged balances and growth on rejection, day advancement, configuration error, an idle night, recovery, and final state. At 1280 × 720 the feedback and button bounds remain inside the viewport, and the label exposes all of its measured text lines. | PASS, 97 integration checks. Layout measured headlessly. |
| M01-T11 · Test migration | Moved all 13 then-existing files from `tetst/` and checked their hashes before updating the five scene script paths. The clean import resolved the original crop-test scene UID and all five test-script UIDs under `tests/`. New test scripts have Godot-generated UID sidecars. Historical reports still contain their original commands. | PASS, all five suites after import and six UID mappings verified. |
| Windows runner | Calls the verified Godot executable in headless debug mode, bounds suite execution by iterations, checks required markers and exit codes, and rejects unexpected errors. It reports one summary and keeps separate engine logs. | PASS, five of five suites on the positive run. The negative run detected both injected failures and exited 1. |

## Dashboard behavior

`main.gd` uses the same rendering functions for startup and subsequent signals. The Next Night button follows the lifecycle state and stays available for an idle day when there is no crop, consistent with Package B. The two existing placeholder controls retain their current behavior. `ControlHint` wraps bilingual outcomes while the header uses `就绪 / Ready` for the lifecycle. The feedback consumes the settlement result and performs no resource arithmetic. The configuration-error tooltip retains the underlying diagnostic and clears when feedback is replaced. The unused crop argument is now prefixed with an underscore. The simulation and production crop values were preserved. [Dashboard controller](../scripts/main.gd) · [Dashboard scene](../scenes/main.tscn)

## Final verification

| Suite or probe | Verified result |
|---|---|
| Crop resource | All four debug group markers and `ALL TESTS PASSED`, bounded exit 0. |
| Resource manager | `RESOURCE_MANAGER_TEST_RESULT checks=192 failures=0`, exit 0. |
| Night state | `NIGHT_STATE_TEST_RESULT checks=133 failures=0`, exit 0. |
| Dashboard startup | `DASHBOARD_STARTUP_TEST_RESULT checks=31 failures=0`, exit 0. |
| Nightly integration | `NIGHTLY_INTEGRATION_TEST_RESULT checks=97 failures=0`, exit 0. |
| Runner negative controls | In a separate temporary copy, a wrong initial day gave a named startup failure and suite exit 1. An injected engine error in integration was rejected even though that suite printed its success marker and exited 0. The runner exited 1 with `3/5 suites passed`. |
| Normal launch | Fresh project imported without its own pre-existing `.godot/`. Godot completed loading `res://scenes/main.tscn` without a scene argument and exited 0. |
| Original one-night probe | `BASELINE_MATCH=true`, exit 0. Day 1 → 2, Growth 0 → 1, Lettuce, water 1000 ml, minerals 50 ml, electricity 100 kWh, final `READY`. Both snapshots contained matching labels. |
| Desktop interaction, visual rendering and export | NOT RUN after Package C. The tests exercised the actual scene button signal and checked layout bounds headlessly. |

The certificate-store error recurred in this Windows environment. The headless editor import also reported its existing global editor-settings write error and completed successfully. Known validation-fixture, missing-manager-fixture, and redundant crop assertion warnings remained. The unused dashboard crop parameter warning did not recur. The runner tolerates only the known certificate-store diagnostic and, during import, the known editor-settings write diagnostics. The first attempt to execute the runner hit the local Windows PowerShell script policy. The documented invocation uses process-scoped `RemoteSigned`. [Testing record](TESTING_REPORT.md#12-2026-11-26--m01-package-c-dashboard-and-test-migration)

## Repeat the checks

From the project root, supply the path to the installed Godot executable. Keep `-Import` for the first run or after path migrations. A missing class/UID cache also triggers an import.

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\tests\run-tests.ps1 -GodotPath "<Godot executable path>" -Import
```

The final positive run used an isolated project directory with spaces. It copied the active working-tree source and current tests and started without `.godot/`. The runner printed `5/5 suites passed` and created logs under the Windows temporary directory. The final smoke commands are shown below with portable paths.

```powershell
$engine = '<path to the Godot 4.7.2 executable>'
$logs = Join-Path ([IO.Path]::GetTempPath()) 'hydroponics-m01-package-c'
$copy = Join-Path $logs 'final fresh project'
& powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File (Join-Path $copy 'tests/run-tests.ps1') -GodotPath $engine -Import
& $engine --headless --debug --path $copy --quit-after 90 --log-file (Join-Path $logs 'final-launch.log') --verbose
& $engine --headless --debug --path $copy --quit-after 90 --log-file (Join-Path $logs 'final-dashboard-probe.log') --script (Join-Path $logs 'dashboard_probe.gd')
& $engine --headless --debug --path $copy --quit-after 90 --log-file (Join-Path $logs 'final-uids.log') --script (Join-Path $logs 'verify-test-uids.gd')
```

The dashboard script was extracted unchanged from the [M01-T02 probe source](M01_T02_REPORT.md#temporary-dashboard-probe-source). The UID probe checked `ResourceUID.get_id_path()` against the five script sidecars and the original crop-test scene header. Logs contained `TEST_UIDS_RESOLVED=6`. The pre-migration runs used the original test paths and their respective focused markers, with no production fixture edits.

## Changed files and Git summary

| Files | Change |
|---|---|
| [scripts/main.gd](../scripts/main.gd) and [scenes/main.tscn](../scenes/main.tscn) | Live initialization, button availability, and bilingual feedback. The label wraps and the header distinguishes `Ready` from the outcome. |
| [Dashboard startup suite](../tests/test_main_dashboard.gd) and [nightly integration suite](../tests/test_nightly_integration.gd) | Added two suites with `.tscn` entries and Godot-generated `.gd.uid` sidecars. |
| [tests/](../tests/) | Moved the original crop, resource-manager, and night-state scripts, scenes, and sidecars. Updated scene script paths. |
| [tests/run-tests.ps1](../tests/run-tests.ps1) | Added the five-suite Windows runner with optional refresh import, bounded runs, error detection, and logs. |
| [README.md](../README.md), [foundation plan](FOUNDATION_STABILIZATION_PLAN.md), and [project status](PROJECT_STATUS.md) | Documented the active test path and command, updated acceptance status, and recorded the remaining visual checks. |
| [Testing report](TESTING_REPORT.md), [development log](DEVELOPMENT_LOG.md), and this report | Added dated evidence and migration guidance. Historical reports and screenshots were preserved. |

`main` remains at `7b282e2`, with zero divergence from the locally recorded `origin/main`. The unstaged view lists the original three tracked crop-test paths as deleted and their preserved replacements under the untracked `tests/` directory. Earlier milestone changes and unrelated untracked files remain in the workspace. No staging, commit, or push was performed.

**Suggested commit message** `feat(ui): complete dashboard settlement feedback and foundation tests`

**Recommended next step** Review M01, then select the first playable crop and confirm the formula and unit contract for the gameplay milestone. A desktop smoke check should verify the new bilingual feedback at the target viewport. The five-suite runner is the foundation regression gate.
