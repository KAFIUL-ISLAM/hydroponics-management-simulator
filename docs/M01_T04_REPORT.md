# M01-T04 — Validate resource inputs

**Date** 2026-11-26 (Asia/Shanghai) · **Baseline** `7b282e24dfff65957f8d181126c67da5498b7e2d` (`resources and simulator added`) plus prior working-tree changes · **Engine** Godot `4.7.2.stable.official.ed1daf0bf` on Windows

## Prerequisite and scope

Reviewed the M01-T03 report and checked its saved import, normal-launch, configured-scene, one-night, and crop-test logs. The logs corroborate the recorded passes, and `project.godot` still references the verified dashboard UID. The user confirmed normal desktop launch and gameplay after M01-T03. There was no blocking acceptance failure. M01-T04 changes the resource ledger and its test coverage. [M01-T03 acceptance results](M01_T03_REPORT.md#clean-context-launch-and-runtime-results)

## Problems found

- `get_amount()` returned `0.0` for both an unknown enum value and an empty resource. The old affordability and mutation paths could treat that fallback as a valid lookup. An unknown type could accept a zero debit or an addition, return success, and emit a change snapshot without writing a balance. A positive unknown debit could emit a false shortage called `Unknown`.
- Mutation methods rejected negative amounts but lacked checks for NaN, positive infinity, and credit overflow. In particular, NaN bypassed the `amount < 0.0` and `available < amount` checks, and an infinite sum could reach the stored balance. Negative infinity failed the negative check.
- Exported balances were directly writable. The old delta setter clamped the result instead of validating the selected stored balance. Inspector range annotations do not enforce the invariant on script writes.
- The simulator checks and debits water and minerals. The dashboard reads balances at startup and subscribes to `resources_changed`. No production script calls `add_resource()` or `reset_resources()`, and there is no production subscriber to `resource_insufficient`. [Simulator calls](../scripts/hydroponics_simulator.gd#L42) · [Dashboard bindings](../scripts/main.gd#L15)

## Implemented contract

| API | Behavior |
|---|---|
| `get_amount(type)` | Returns the stored value for a known type. Unknown types return `0.0`, with no signal. That fallback is also a valid empty balance. |
| `can_consume(type, amount)` | Returns `false` if the type is unknown, the amount or selected balance is negative or non-finite, or available resources are insufficient. The query emits no signals. |
| `try_consume(type, amount)` | Invalid inputs or a corrupted selected balance return `false`, log an invalid-request warning, and emit neither signal. A valid shortage returns `false` and emits `resource_insufficient` with the resource name, requested amount, and available amount. A successful debit emits one `resources_changed` snapshot. |
| `add_resource(type, amount)` | Applies the same request validation, then checks that the computed sum is finite before writing. Rejected credits return `false` and emit neither signal. A successful credit emits one `resources_changed` snapshot. |
| Valid zero and exact-balance cases | Zero credits and debits still return `true` and emit the existing success notification. An exact-balance debit succeeds and leaves zero. Subtraction of finite non-negative operands after checking affordability yields a finite non-negative result. |
| Representation | Water and minerals remain in ml, and electricity remains in kWh. There is no new rounding, tolerance, or storage cap. |

### Functions added or modified

- Updated `get_amount()` documentation to describe its fallback and retained its implementation and signature.
- Updated `can_consume()`, `try_consume()`, and `add_resource()` to share `_is_valid_request()`. The helper checks the `ResourceType` enum and the finiteness and sign of both amount and selected balance.
- Replaced `_change_amount()` with `_set_amount()`, which assigns the already computed balance. The credit path checks the sum before calling it. The debit path checks affordability before subtraction. Public signatures, the two signals, and `reset_resources()` retain their existing interfaces and behavior. [Source](../scripts/resource_manager.gd#L26)

## Expected and actual resource test results

The standalone test scene creates isolated `ResourceManager` instances with deterministic values and observes both signals. Explicit checks count failures and identify the failed expectation. The test exits 0 for success and 1 for failure. The verification command also checks the expected completion record and rejects script errors so an iteration-limit exit alone cannot pass. [Test runner](../tetst/test_resource_manager.gd#L11) · [Check implementation](../tetst/test_resource_manager.gd#L162)

| Coverage | Expected | Actual |
|---|---|---|
| Water, minerals, electricity | Valid addition and debit update only the selected balance. Each successful operation sends one full snapshot. The affordability query is silent. | PASS for all three resources. |
| Exact balance | Debit succeeds, leaves zero, sends one snapshot. | PASS. |
| Above available | The query and debit reject the request. The debit emits one shortage with the expected payload and changes no balances. | PASS. |
| Zero at an empty balance | Query, credit, and debit succeed. Both mutators emit one unchanged snapshot each. | PASS. |
| Unknown type | Lookup returns `0.0`. Zero and positive operations reject the request and emit neither signal. | PASS. |
| Negative, NaN, positive infinity, negative infinity | All operation checks reject. Every balance is preserved and neither signal is emitted. | PASS for all four invalid inputs. |
| Arithmetic overflow | A finite `1.0e308` credit against a finite `1.0e308` balance would produce infinity. Reject before applying it or emitting a signal. | PASS. |
| Directly corrupted selected balance | For negative, NaN, and either infinity, API calls reject without changing any balance or emitting either signal. | PASS. |
| Suite completion and failure detection | Unmodified scene exits 0 with zero failures. An intentionally wrong expectation prints its name and exits 1. | PASS. The workspace run reported `checks=118 failures=0`. A temporary copy that expected `1.0` from an unknown lookup reported the named failed check, `checks=118 failures=1`, and exit 1. |

## Commands and diagnostics

The recorded arguments are shown with portable paths. The dashboard probe was extracted unchanged from the fenced GDScript in the M01-T02 report. The negative-control project copied the tracked working-tree files and the two new test source files. The changed expectation existed only in that copy. Godot generated the new test script's UID there. [Dashboard probe source](M01_T02_REPORT.md#temporary-dashboard-probe-source)

```powershell
$engine = '<path to the Godot 4.7.2 executable>'
$projectPath = (Get-Location).Path
$caseLogs = Join-Path ([IO.Path]::GetTempPath()) 'hydroponics-m01-t04'
New-Item -ItemType Directory -Path $caseLogs -Force | Out-Null
$testCopy = Join-Path $caseLogs 'negative-control-project'
$probePath = Join-Path $caseLogs 'dashboard_probe.gd'

& $engine --headless --debug --path $projectPath --quit-after 60 --log-file (Join-Path $caseLogs 'resource-test.log') 'res://tetst/test_resource_manager.tscn'
& $engine --headless --debug --path $projectPath --quit-after 60 --log-file (Join-Path $caseLogs 'crop-test.log') 'res://tetst/test_crop_resource.tscn'
& $engine --headless --debug --path $projectPath --quit-after 60 --log-file (Join-Path $caseLogs 'dashboard-probe.log') --script $probePath
& $engine --headless --debug --path $projectPath --quit-after 60 --log-file (Join-Path $caseLogs 'default-launch.log') --verbose

& $engine --headless --path $testCopy --editor --import --log-file (Join-Path $caseLogs 'negative-control-import.log')
& $engine --headless --debug --path $testCopy --quit-after 60 --log-file (Join-Path $caseLogs 'resource-negative-control.log') 'res://tetst/test_resource_manager.tscn'
```

For a repeatable pass/fail check, verify the exit code immediately after a run of the unmodified ResourceManager scene, plus its log. The crop regression was checked for all four pass markers, the final `ALL TESTS PASSED` marker, exit 0, and no script error.

```powershell
& $engine --headless --debug --path $projectPath --quit-after 60 --log-file (Join-Path $caseLogs 'resource-test.log') 'res://tetst/test_resource_manager.tscn'
$resourceExit = $LASTEXITCODE
$resourceOutput = Get-Content -Raw -LiteralPath (Join-Path $caseLogs 'resource-test.log')
if ($resourceExit -ne 0 -or
    $resourceOutput -notmatch '(?m)^RESOURCE_MANAGER_TEST_RESULT checks=118 failures=0\s*$' -or
    $resourceOutput -match '(?m)^SCRIPT ERROR:|RESOURCE_MANAGER_CHECK_FAILED:') {
    throw 'The ResourceManager suite did not pass.'
}
```

- Expected resource warnings in the completed suite were ten invalid consumptions, ten invalid additions, and one overflow rejection. The negative control adds a deliberate `RESOURCE_MANAGER_CHECK_FAILED` error.
- The first resource test also warned about casting a constant `-1` to the enum. The final fixture derives an out-of-range enum value at runtime and exercises the same rejection without that compile warning.
- The Windows root certificate store error recurred on the verification runs. The temporary editor import also reported the existing inability to save global `editor_settings-4.7.tres`. It completed with exit 0.
- The dashboard still emits the unused `crop` warning at `main.gd:96`. The existing crop test still emits seven redundant assertion warnings at lines 10, 14–16, and 20–22. No unexpected GDScript errors or assertion failures appeared in the completed workspace runs. [Existing diagnostics](M01_T03_REPORT.md#errors-and-warnings)

## Regression results

| Check | Expected | Actual |
|---|---|---|
| Normal project launch | Load `res://scenes/main.tscn` without a scene argument. | PASS. Verbose log confirmed completion of the main-scene load, and the run exited 0. |
| Before a night | Day 1, Growth 0, Lettuce, 1000 ml water, 50 ml minerals, 100 kWh, `READY`. | PASS. The probe observed each value and the matching label text. |
| After one night | Day 2, Growth 1, Lettuce, same reserves, final `READY`. | PASS. One emission of the connected Next Night signal produced the expected state and labels. The probe printed `BASELINE_MATCH=true`, exit 0. |
| Existing debug crop test | Resource loads, identity, selected defaults, and empty traits all pass. | PASS. All four original groups completed at the 60-iteration limit without manual termination, exit 0. |
| Desktop interaction after M01-T04 | Separate graphical check. | NOT RUN. The user confirmed graphical launch and gameplay after M01-T03. |

## Remaining risks and next task

- `water_ml`, `minerals_ml`, and `electricity_kwh` remain publicly writable. A direct assignment can bypass validation, and `get_amount()` returns that stored value for known types. A successful operation on a different resource can still emit a snapshot that includes an invalid balance from a direct write. This task guards the targeted operation and leaves field ownership intact.
- Reset still restores the hardcoded prototype balances. Nightly water and mineral debits still occur separately, and the simulator's prechecks expose only a boolean. Configured reset is M01-T05. Atomic consumption and richer nightly outcomes are later tasks.
- Exact comparisons retain the existing float behavior. Any precision or rounding policy for fractional farming rules needs verified requirements.

## Changed files and Git summary

| File | M01-T04 change |
|---|---|
| [scripts/resource_manager.gd](../scripts/resource_manager.gd) | Validates requests and results before writing. |
| [tetst/test_resource_manager.gd](../tetst/test_resource_manager.gd) | Added deterministic checks and explicit test exits. |
| [tetst/test_resource_manager.tscn](../tetst/test_resource_manager.tscn) | Added the runnable test scene. |
| [tetst/test_resource_manager.gd.uid](../tetst/test_resource_manager.gd.uid) | Added the Godot-generated script UID. |
| [docs/PROJECT_STATUS.md](PROJECT_STATUS.md) | Updated verification, remaining risks, and the next task. |
| [docs/TESTING_REPORT.md](TESTING_REPORT.md) | Appended the dated test results. |
| [docs/DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md) | Appended the dated development entry. |
| [docs/M01_T04_REPORT.md](M01_T04_REPORT.md) | Added this report. |

The tracked diff from `HEAD` contains the ResourceManager and the two log documents, plus the pre-existing M01-T03 `project.godot` edit. The status document was already untracked. The new test files and this report are untracked. Prior reports, screenshots, and other untracked files were preserved. `main` remains at `7b282e2` with zero divergence from the locally recorded `origin/main`. Nothing was committed or pushed.

**Suggested commit message** `fix(resources): validate resource types and amounts`

**Recommended next task** M01-T05, capture the configured starting balances and test that reset restores them. Await review before starting. [Foundation plan](FOUNDATION_STABILIZATION_PLAN.md#m01-t05--reset-to-configured-starting-balances)
