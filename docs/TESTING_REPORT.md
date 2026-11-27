# 测试报告

## M11 · 2026-11-27

**Codex automated evidence:** The supplied M11 handover reports 19 suites passed, 1,480 explicit checks including 264 workshop GUI checks, and four original crop assertion groups. Default launch, legacy Lettuce, and the deterministic Kotton comparison passed; renderer captures were checked at 1280 × 720 and 1920 × 1080. Kotton remained at 52% versus 100% health and 12 versus 13 fiber. The M11 GUI change adds 40 checks across the two viewports. These results are attributed to Codex and were not rerun by Copilot during release documentation.

Automated coverage should not be overstated: the Enter-echo test injects an echo without first simulating an initial press and repeats; the suite does not independently prove the full held-key sequence. Nor does it establish Reduced Motion collection coverage or keyboard-focus styling on manual tabs.

**Developer manual acceptance:** On 2026-11-27, the developer reported passing all 30 checks: visual and interaction states (5/5), keyboard navigation (5/5), manual and analysis tools (9/9), gameplay regression (6/6), and resolution/Reduced Motion (5/5). Manual acceptance explicitly covered holding Enter on Next Night, collection with Reduced Motion, and visible keyboard focus while navigating. These checks are separate from the automated totals.

**Performance evidence:** The Codex handover reports graphical Godot 4.7.2 debug profiling on Windows build 26340, Ryzen 5 5500U, integrated Radeon, 7.88 GB RAM, OpenGL 3.3 Compatibility. It reports 314 rendered-frame samples per resolution across roughly 10 seconds after warm-up, but does not state whether those samples are per scenario or shared across interactions. The Next Night synchronous median uses three samples per resolution. Full numbers, limitations, and temporary capture paths are recorded in [M11_FINAL_REPORT.md](M11_FINAL_REPORT.md#performance-observations). No repeatable speedup or bottleneck was established.

Protected simulation and crop data, numerical expectations, scenes, and artwork were unchanged. The five M11 implementation/test files are [`orbital_theme.tres`](../resources/orbital_theme.tres), [`coffee_dashboard.gd`](../scripts/coffee_dashboard.gd), [`workshop_manual.gd`](../scripts/workshop_manual.gd), [`workshop_view.gd`](../scripts/workshop_view.gd), and [`test_workshop_ui.gd`](../tests/test_workshop_ui.gd). [M11 milestone report](M11_FINAL_REPORT.md)

## M10 · 2026-11-27

**Evidence source:** Codex's M10 handover reports 19 regression suites passed, with 1,440 explicit automated checks including 224 workshop GUI checks, plus the four original crop assertion groups. The default launch and legacy Lettuce baseline passed. Renderer captures were checked at 1280 × 720 and 1920 × 1080. The suite count includes the M10 nutrient-comparison fixture; workshop GUI checks exercise the immediate post-depletion battery drag, exact one-refill transfer, water/seed/module drags, bilingual persistent status, temporary-message expiry, pointer transparency, manual access/navigation, inventory selection retention, and Coffee collection/replanting. These results were executed by Codex; Copilot did not independently rerun the regression suite for this documentation task.

Separately, on 2026-11-27 the developer reported passing all **19 manual acceptance items**: 5 battery-recovery checks, 4 machine-status checks, 5 farming-manual/navigation checks, and 5 gameplay/presentation checks. This is manual acceptance, not part of Codex's automated totals. M10 is complete and developer-accepted; its intended release version is v0.6.0. The Codex handover's older closing sentence that desktop acceptance was pending is superseded by this dated acceptance record; the complete checklist is in [`M10_FINAL_REPORT.md`](M10_FINAL_REPORT.md).

The deterministic comparison is implemented by `tests/test_m10_nutrient_demo.gd` and launched by `tests/test_m10_nutrient_demo.tscn`. The six-night runs use native Kotton, 5,000 mL pure water, 100 kJ, the standard machine, no modules, no added pollution, and RNG seed 42; only initial minerals differ (50 mL versus 150 mL). Both reach growth 48, draw 1,500 mL mixed solution, and spend 48 kJ. The below-range case ends at 0.917%, 52% health and 12 Regular fiber; the suitable-range case ends at 2.917%, 100% health and 13 Large fiber. Each produces two offspring seeds. The measured result is limited to this fixture. Run it with:

```text
Godot --headless --debug --path . res://tests/test_m10_nutrient_demo.tscn
```

The battery fix addresses drag eligibility during settlement-lock refreshes; it does not change energy cost or settlement formulas. See the [M10 milestone report](M10_FINAL_REPORT.md) for reproduction, correction, usability changes and file traceability.

## M09 · 2026-11-27

These are historical M09 results for published commit `6ff68084beb6449060db3a1c6fdd0eb613bc62f9`, not a new test execution for this documentation update. Godot 4.7.2 passed all 18 suites, 1,362 explicit checks including 184 workshop checks, and four original crop assertion groups after a fresh isolated import. The default workshop launched successfully. The rendered workshop tests covered both supported viewport sizes, matched actual night deltas in both motion modes, and verified reentrant input, blocker recovery, transient feedback, production and collection. After removal of a presentation-script type warning, the focused 184-check suite passed again. Finalization matched the tested sources and reused those results.

At M09 acceptance, the developer identified two follow-up issues: status contrast and the first replacement-battery drag after depletion. Both were addressed in M10; see the current M10 record above.

## v0.5.0 release gate · 2026-11-27

Fresh isolated Godot 4.7.2 regression passed all 18 suites, 1,327 explicit checks including 149 workshop GUI checks, and four original crop assertion groups. Default workshop launch and the archived one-night Lettuce probe passed. The known Windows certificate-store diagnostic appeared. Separately, the developer reported manual testing and approval of M08-A through M08-C.4. [Release report](M08_EXTENSION_FINAL_REPORT.md)

## M08-C.3 · 2026-11-27

Godot 4.7.2 passed 149 rendered workshop GUI checks and a fresh isolated regression of 18 suites, 1,327 explicit checks and four original assertion groups. Verified 24/24 inventory and discard, supply and module transfers, operation without modules, output counts 0/1/3/5/8/12, mixed-type overflow, and one-item collection. Default launch passed.

## M08-C.2 · 2026-11-27

The rendered Godot 4.7.2 workshop passed 126 GUI checks, including the Coffee, Fruit and Kotton loops, individual output and inventory cells, capacity rejection, mid-animation close and mixed-inventory disposal. On the first operating night, Coffee used 124 → 116 kJ with a refill applied before settlement. Fruit and Kotton each used 100 → 92 kJ. The meter showed the same balances, while solution decreased according to the existing settlement path.

Default launch passed. The isolated regression passed all 18 suites, 1,304 explicit checks, and four original crop assertion groups. Developer desktop retest is pending.

## M08-C.1 workshop interaction fixes · 2026-11-27

The rendered default game window at 1600 × 1000 reproduced eight failures with the old drag-origin lookup. The same input sequence passed after the correction. The final rendered run used Godot mouse events and passed 52 checks, and both supported viewport sizes passed 104 checks combined. The fresh isolated regression passed all 18 suites, 1,282 explicit checks and four original assertion groups. Empty startup and returning attached liquid or batteries remain blocked by the merged-balance model. Developer desktop retest is pending.

## M08-C workshop interactions · 2026-11-27

Before the fix, removing the final pointer motion from the integration test reproduced rejected power, water, tablet, module and seed drops at both supported resolutions. After the fix the workshop passed 74 checks, including rapid release, drop feedback, module return, real nightly power and liquid consumption, double-click protection, Coffee seed discard and cancellation, full-inventory rejection and single collection. Fresh isolated Godot 4.7.2 import, all 18 suites, 1,252 explicit checks, four original crop assertion groups and default launch passed. The Windows certificate-store diagnostic remains. [Loaded machine](../screenshots/m08c-loaded-machine.png) · [Completed production](../screenshots/m08c-completed-output.png)

## M08-B icon-based workshop · 2026-11-27

Godot 4.7.2 passed a fresh isolated import and all 18 suites, with 1,228 explicit checks and four original crop assertion groups. The workshop suite passed 50 checks using viewport mouse input at 1280 × 720 and 1920 × 1080. It covered machine opening, input validation, stock transfers, automatic planting and start, night advancement, output cancellation, capacity rejection and atomic collection. Default launch and the archived Lettuce baseline passed. Existing Windows certificate-store and isolated editor-settings diagnostics remain.

These 1280 × 720 renderer captures show the [default workshop](../screenshots/m08b-01-workshop.png), [loaded machine](../screenshots/m08b-02-loaded-machine.png), [growing crop](../screenshots/m08b-03-growing.png), and [collectible output](../screenshots/m08b-04-output.png). Owner desktop review remains pending.

## M08-A icon inventory redesign · 2026-11-27

Fresh isolated Godot 4.7.2 import and `tests/run-tests.ps1 -GodotPath <Godot executable> -Import` passed 17 suites, 1,178 explicit checks, and all four original crop assertion groups. The environment suite passed 104 checks, including mouse-driven moves, swaps, rejected drops, exact seed selection, stale removal, live counts and empty inventory at both supported resolutions. Default launch and the archived one-night Lettuce probe passed.

Godot reported a Windows certificate-store diagnostic and an editor-settings write failure during isolated import. Existing test warnings covered redundant assertions, missing simulator injection and intentionally invalid resource operations. The 1280 × 720 capture is renderer evidence. Owner desktop review remains pending. [Inventory capture](../screenshots/m08a-icon-inventory-1280.png)

## M08 final acceptance · 2026-11-26

Fresh isolated Godot 4.7.2 regression passed all 17 suites, 1,142 explicit checks and four original assertion groups, with zero failures. Default launch and the archived Lettuce probe passed. Separately, the owner reported ten M08-D desktop passes at the milestone review. Renderer captures remain a third evidence source. [Final test and desktop records](M08_FINAL_REPORT.md#verification)

## M08 Package D · 2026-11-26

Fresh isolated Godot 4.7.2 import passed all 17 suites with 1,142 explicit checks, four original crop assertion groups and zero failures. The new suite passed 38 checks across 1280 × 720 and 1920 × 1080. Default launch and the archived Lettuce probe passed. Separately, the owner reported all 11 M08-C desktop checks passed, including all three crop artworks and both resolutions. M08-D has renderer captures and automated modal checks. Its owner desktop acceptance remains pending. [M08-D evidence](M08_PACKAGE_D_REPORT.md)

## M08 Package C · 2026-11-26

Fresh isolated Godot 4.7.2 import and all 16 suites passed with 1,104 explicit checks and four original crop assertion groups. The new environment suite passed 68 checks at 1280 × 720 and 1920 × 1080. The existing overlap assertion now compares dashboard widgets in their shared coordinate space, and the new suite checks the moved cultivation controls inside their own visible dialog. Default launch and the archived Lettuce probe passed. Renderer captures and manual owner acceptance are separate evidence. [M08-C results](M08_PACKAGE_C_REPORT.md)

## Inventory discard hotfix · 2026-11-26

Direct equality between seed objects and product strings failed during selection restoration. Type-safe identity/value comparison now preserves valid selection, selects the first remaining item after removal, and clears selection when empty. The owner reported that all nine manual regression checks passed. The isolated M08 working tree passed 15 suites, 1,036 explicit checks and four original crop assertion groups, including nine presentation checks for cancellation, mixed inventory, depletion and replenishment.

The isolated v0.3.0 hotfix build passed its 13 existing suites, 932 explicit checks, four original assertion groups and a separate nine-check inventory probe. Fresh import and default launch passed on Godot 4.7.2. The existing Windows certificate-store diagnostic remained present.

## M08 Package B · 2026-11-26

Fresh Godot 4.7.2 isolated import passed 15 suites, 1,027 explicit checks and four original crop assertion groups, with no failures. The artwork suite passed 46 checks. All 14 earlier suites, the default launch and archived Lettuce probe passed. Godot renderer captures are distinct from the pending manual M08-B desktop walkthrough. [M08-B report](M08_PACKAGE_B_REPORT.md)

## M08 Package A · 2026-11-26

Fresh Godot 4.7.2 isolated import passed 14 suites, 981 explicit checks and four original assertion groups. All 13 existing suites and their numerical fixtures passed unchanged. The presentation suite passed 49 checks. The essential dashboard control set fit without overlap at 1280 × 720 and 1920 × 1080. The 1024 × 576 probe overflowed. Default launch and the legacy Lettuce probe passed. Desktop typography, keyboard traversal and visual acceptance remain pending. [M08-A report](M08_PACKAGE_A_REPORT.md)

## M07 checkpoint · 2026-11-26

Fresh isolated import, all 13 suites, default launch and the archived Lettuce probe passed. The user confirmed the M07-A equipment checklist and the M07-B DNA editor walkthrough, including preview cancellation, two-night editing, heat and disc accounting, and growing and harvesting an edited seed. The repository equipment screenshot is separate dialog evidence. [Checkpoint results](M07_FINAL_REPORT.md)

## M07 Package B · 2026-11-26

Fresh isolated Godot 4.7.2 import and all 13 suites passed with 932 explicit checks and four original assertion groups. The DNA editor suite passed 30 checks. Default launch, legacy Lettuce and all neutral cultivation, pollution, genetics, reproduction and equipment fixtures passed. The user confirmed the M06-B desktop checklist and supplied M07-A Equipment dialog evidence. M07-B desktop verification is pending. [M07-B evidence](M07_PACKAGE_B_REPORT.md)

## M07 Package A · 2026-11-26

Fresh isolated Godot 4.7.2 import and all 12 suites passed with 900 explicit checks and four original crop assertion groups. The equipment suite passed 27 checks. Native cultivation, pollution, modified Coffee genetics and reproduction, default launch and legacy Lettuce passed. User-confirmed desktop acceptance applies to M06-A. M06-B reproduction and M07-A equipment desktop walkthroughs remain pending. [M07-A evidence](M07_PACKAGE_A_REPORT.md)

## M06 Package B · 2026-11-26

Fresh isolated Godot 4.7.2 import and all eleven suites passed with 863 explicit checks and four original crop assertion groups. All three clean cultivation and pollution fixtures, normal launch and the archived Lettuce probe passed. The reproduction suite includes headless Genes dialog bindings and bounds. The user confirmed the M05 desktop checklist and supplied separate physical-pollution screenshot evidence. [M06-B verification](M06_PACKAGE_B_REPORT.md)

## M06 Package A · 2026-11-26

Fresh Godot 4.7.2 import and all ten suites passed with 837 explicit checks and four original crop assertion groups. All clean cultivation and pollution regression values matched. Default launch and the archived Lettuce probe passed. The genetics dialog and dashboard passed headless bounds checks at 1280 × 720. [M06-A verification](M06_PACKAGE_A_REPORT.md)

## M05 verification · 2026-11-26

Godot 4.7.2 passed a fresh isolated import, all nine suites (789 explicit checks and four original crop assertion groups), default launch, and the archived Lettuce probe. The three clean cultivation fixtures again matched mineral losses of 3,148, 9,430 and 46,639 µL. The new pollution suite passed 66 checks covering numerical and settlement behavior, all five demo solutions, and headless dashboard and dialog bounds. Desktop smoke testing remains pending. [M05 results and commands](M05_REPORT.md)

## M04 verification · 2026-11-26

Tested the M04 workspace on Git base `2c56490` with Godot `4.7.2.stable.official.ed1daf0bf`. Fresh import, eight suites, normal launch, and the archived Lettuce probe passed. The runner verified 719 explicit checks and four original crop assertion groups. All three mineral-loss fixtures matched their exact targets. Dashboard layout and button signal bindings were checked headlessly at 1280 × 720. Three-crop desktop verification is pending. [Commands, totals and diagnostics](M04_REPORT.md#verification)

## 1. 测试概况

**项目名称：** 水培管理模拟器（Hydroponics Management Simulator）  
**测试日期：** 2026-11-25  
**测试阶段：** 原型开发阶段  
**测试范围：** CropData 资源基础验证及其在主仪表盘中的显示

本报告记录截至目前开发过程中已执行并确认的测试。尚未实现或尚未测试的功能不视为通过。

## 2. 测试环境

- **游戏引擎：** Godot 4.7.2
- **运行环境：** Windows
- **测试方式：** Godot 调试运行、脚本测试及界面人工检查

## 3. 测试记录

### 3.1 CropData 资源测试

**测试对象：** `CropData` 资源  
**测试方式：** 运行 Crop Resource Test 脚本

| 编号 | 测试内容 | 预期结果 | 实际结果 | 状态 |
|---|---|---|---|---|
| CT-001 | 加载 CropData 资源 | 资源成功加载 | CropData 资源成功加载 | 通过 |
| CT-002 | 验证作物身份信息 | 作物身份信息正确 | 作物身份信息验证通过 | 通过 |
| CT-003 | 验证默认值 | 默认值符合当前资源定义 | 默认值验证通过 | 通过 |
| CT-004 | 初始化遗传特征 | 遗传特征成功初始化 | 遗传特征初始化成功 | 通过 |

**测试结果：** 4 项通过，0 项失败。  
**备注：** 以上结果依据 Godot 输出面板中的测试记录。

### 3.2 CropData 主界面显示检查

**测试对象：** 主仪表盘中的作物状态区域  
**测试方式：** 启动游戏并人工检查界面

| 编号 | 检查内容 | 预期结果 | 实际结果 | 状态 |
|---|---|---|---|---|
| UI-001 | 主界面启动 | 主仪表盘正常显示 | 主仪表盘成功显示 | 通过 |
| UI-002 | 显示 CropData 作物信息 | 作物信息显示在作物状态区域 | 区域成功显示生菜（Lettuce）信息 | 通过 |

**检查结果：** 2 项通过。  
**备注：** 本次检查确认资源能够加载并显示；生长、收获及其他实际玩法数值尚未验证。

## 4. 当前测试结论

截至 2026-11-25，已确认：

- CropData 资源的加载、身份信息、默认值及遗传特征初始化测试全部通过。
- CropData 资源已成功显示在主仪表盘的作物状态区域。
- 当前测试仅覆盖资源基础功能及界面显示，不代表完整游戏流程已通过测试。

## 5. 测试证据

- Crop Resource Test 输出截图：`screenshots/crop-resource-test-passed.png`
- 主仪表盘显示 CropData 截图：`screenshots/cropdata-dashboard.png`

请将截图保存到上述路径；如果实际文件名不同，请同步修改本节路径。

## 6. 后续测试计划

- 验证作物生长状态及相关数据更新。
- 验证水培设备与作物状态之间的交互。
- 实现并测试夜间结算流程。
- 根据后续功能补充测试用例、测试结果及截图证据。

## 7. 2026-11-26 — M01-T02 runtime baseline

**Revision** `7b282e24dfff65957f8d181126c67da5498b7e2d` on `main` · **Environment** Windows, Godot `4.7.2.stable.official.ed1daf0bf`, headless debug.

These are fresh results from this revision. Earlier screenshots and test records above remain historical evidence. [Commands, local log paths, and probe source](M01_T02_REPORT.md)

| Check | Result | Runtime evidence |
|---|---|---|
| Verify engine and inspect project configuration | PASS | `--version` returned `4.7.2.stable.official.ed1daf0bf`. Source inspection found no `run/main_scene`. |
| Launch `res://scenes/main.tscn` directly | PASS | Exit 0 at the 60-iteration limit. No scene-loading errors, GDScript parse errors, missing resources, or invalid node references were observed. |
| Initial live state and label text | PASS | Day 1, `lettuce_prototype` (Lettuce), Growth 0, 1000 ml water, 50 ml minerals, 100 kWh, and `READY`. The label strings agreed with state. |
| Settle one night through the connected button signal | PASS | An automated probe emitted `NextNightButton.pressed` once. Day advanced to 2, growth to 1, status returned to `READY`, and all three balances stayed unchanged. The label strings updated to match. No physical click was performed. |
| Crop resource group 1 · Resource loads as `CropData` | PASS | `TEST 1 PASSED: CropData resource loaded` |
| Crop resource group 2 · Identity | PASS | `TEST 2 PASSED: Crop identity verified` |
| Crop resource group 3 · Defaults | PASS | `TEST 3 PASSED: Default values verified` |
| Crop resource group 4 · Initial traits | PASS | `TEST 4 PASSED: Genetic traits initialized` |
| Crop test overall | PASS | `ALL TESTS PASSED`, no assertion failure, and exit 0 at the 60-iteration limit. No manual termination was required for this test scene. |
| Default project launch | FAIL | Godot reported `Can't run project: no main scene defined in the project.` The process was stopped after capturing the error. |
| Visual render and physical Next Night click | NOT RUN | Headless execution verified node and label state. Desktop rendering, layout, and physical input still require the editor check in the task report. |
| Export | NOT RUN | Outside the M01-T02 baseline. |

Godot reported a Windows root certificate store read error on the dashboard, probe, and crop-test runs. Those checks completed. The dashboard script generated an unused `crop` parameter warning at line 96. The crop test generated redundant-assertion warnings at lines 10, 14–16, and 20–22. An initial invocation also generated a log-target error for `NUL`; the recorded baseline used ordinary temporary log files. [Diagnostics and manual steps](M01_T02_REPORT.md#diagnostics)

## 8. 2026-11-26 — User manual verification of the M01-T02 baseline

**Baseline revision** `7b282e24dfff65957f8d181126c67da5498b7e2d` · **Viewport** 1280 × 720 · **Evidence** user-reported Godot session and before-and-after screenshots.

| Check | Result | User observation |
|---|---|---|
| Desktop dashboard rendering and physical Next Night click | PASS | The dashboard rendered at 1280 × 720 and responded to one click. |
| Day and growth | PASS | Day 1 and Growth 0 before the click, Day 2 and Growth 1 after it. |
| Crop, reserves and final status | PASS | Lettuce remained selected. Reserves stayed at 1000 ml water, 50 ml minerals, and 100 kWh. Final status was `READY`. |
| Errors during manual play | PASS | The user reported no errors during the session. |

The screenshots were provided by the user. No repository paths have been verified for that pair. This manual follow-up is separate from the automated diagnostics captured in [M01_T02_REPORT.md](M01_T02_REPORT.md#diagnostics).

## 9. 2026-11-26 — M01-T03 default main scene and regression checks

**Baseline revision** `7b282e24dfff65957f8d181126c67da5498b7e2d` plus the M01-T03 `project.godot` change · **Environment** Windows, Godot `4.7.2.stable.official.ed1daf0bf`, headless.

| Check | Result | Evidence |
|---|---|---|
| Clean project import | PASS | Copied the 49 tracked working-tree files into a temporary project that started without `.godot/` or project editor metadata. The copied configuration matched the workspace file. The import generated fresh project data and exited 0. |
| Normal project launch | PASS | No scene or script argument. Verbose output confirmed `res://scenes/main.tscn` completed loading. Exit 0. The missing-main-scene error from M01-T02 did not recur. |
| Configured dashboard initial state | PASS | The probe resolved `uid://lm4cvp2hfxau` to `res://scenes/main.tscn`. It observed Day 1, Growth 0, Lettuce, `READY`, 1000 ml water, 50 ml minerals, and 100 kWh. |
| Existing one-night probe | PASS | Day 1 → 2 and Growth 0 → 1 after one button-signal emission. Lettuce, reserves, and final `READY` status matched M01-T02. |
| Existing crop resource test | PASS | All four debug groups passed: resource type, identity, selected defaults, and empty traits. The run printed `ALL TESTS PASSED` and exited 0 at the iteration limit. |
| Desktop launch after the configuration change | NOT RUN | The user verified the dashboard and physical input in the M01-T02 follow-up above. This task verified default launch headlessly. |

The Windows certificate-store error, the unused dashboard parameter warning, and the seven redundant crop-test assertion warnings recurred. The editor import also reported that it could not save global editor settings. The project import and runtime runs completed. [Commands and diagnostic details](M01_T03_REPORT.md)

## 10. 2026-11-26 — M01-T04 resource input validation

**Baseline revision** `7b282e24dfff65957f8d181126c67da5498b7e2d` plus the M01-T03 and M01-T04 working-tree changes · **Environment** Windows, Godot `4.7.2.stable.official.ed1daf0bf`, headless debug.

The M01-T03 acceptance logs confirmed default launch, UID resolution, initial state, the one-night regression, and all four crop-test groups. The user separately confirmed normal desktop launch and gameplay after M01-T03.

| Check | Result | Evidence |
|---|---|---|
| ResourceManager validation | PASS | `RESOURCE_MANAGER_TEST_RESULT checks=118 failures=0`, exit 0. Coverage includes valid operations for all three balances, exact and zero amounts, valid shortages, invalid types and amounts, overflowing additions, directly corrupted selected balances, and return values and signal payloads. |
| Test failure detection | PASS | A deliberately incorrect lookup expectation in a temporary project reported the named failed check, `checks=118 failures=1`, and exit 1 as expected. |
| Existing crop resource test | PASS | All four existing groups passed and the bounded run exited 0. |
| Dashboard baseline probe | PASS | Day 1 → 2, Growth 0 → 1, Lettuce remained selected, reserves stayed at 1000 ml / 50 ml / 100 kWh, and status was `READY`. |
| Normal project launch | PASS | No scene argument. Godot loaded `res://scenes/main.tscn` and exited 0. |
| Desktop checks for the M01-T04 changes | NOT RUN | This task ran headless. The existing dashboard and scene were preserved. |

The resource suite intentionally triggered 20 invalid-request warnings and one overflow warning. The existing Windows certificate-store error, dashboard unused-parameter warning, and crop-test redundant-assertion warnings recurred. The negative-control copy also reported the existing global editor-settings write errors during import. [Commands, expected results, and full diagnostics](M01_T04_REPORT.md)

## 11. 2026-11-26 — M01 Package B resource and settlement stabilization

**Baseline revision** `7b282e24dfff65957f8d181126c67da5498b7e2d` plus working-tree changes · **Environment** Windows, Godot `4.7.2.stable.official.ed1daf0bf`, headless debug.

| Check | Result | Evidence |
|---|---|---|
| M01-T05 focused reset | PASS | 136 resource checks, zero failures. Default and overridden starts, early reset, repeated reset, and reset after tree reentry passed. |
| M01-T06 focused batch | PASS | 189 resource checks, zero failures. Covered exact debits, zero and empty costs, invalid input, shortages, and coherent observers. |
| ResourceManager final | PASS | `RESOURCE_MANAGER_TEST_RESULT checks=192 failures=0`, exit 0. Includes the original 118 checks and the successful zero-cost night alongside reset and batch checks. |
| M01-T07 nightly state | PASS | `NIGHT_STATE_TEST_RESULT checks=133 failures=0`, exit 0. Covered successful, blocked, idle, and configuration-error nights, guarded callbacks, and recovery. |
| Failure detection | PASS | Both temporary negative controls reported a named failure, one failure in their completion record, and exit 1. |
| Crop resource regression | PASS | All four historical groups printed their pass markers, then `ALL TESTS PASSED`. Bounded exit 0. |
| Default launch and Lettuce probe | PASS | Godot loaded the dashboard without a scene argument. The unchanged probe observed Day 1 → 2, Growth 0 → 1, Lettuce, reserves 1000 ml / 50 ml / 100 kWh, and final `READY`. |
| Package B desktop or export checks | NOT RUN | This verification used headless runs. |

Expected fixture warnings and the existing Windows certificate-store, global settings, dashboard, and crop-test diagnostics are recorded in the [Package B report](M01_PACKAGE_B_REPORT.md).

## 12. 2026-11-26 — M01 Package C dashboard and test migration

**Revision** `7b282e24dfff65957f8d181126c67da5498b7e2d` plus working-tree changes. **Environment** Windows, Godot `4.7.2.stable.official.ed1daf0bf`, headless debug.

M01-T11 moved the active suites to `tests/`. Commands and links above and in earlier reports reflect the paths used for those runs. For current testing, [run the complete suite](../README.md#run-the-automated-tests-on-windows).

| Check | Result | Evidence |
|---|---|---|
| M01-T08 startup | PASS | Focused run passed 21 checks. Default and configured values, child growth before parent readiness, empty crop, and Next Night availability were verified. |
| M01-T09 outcome feedback | PASS | Expanded startup and feedback suite passed 31 checks. Settlement outcome text is distinct from lifecycle state. |
| M01-T10 integration | PASS | 97 checks passed through the scene's existing button signal. Exact debits, both shortages, no partial consumption or growth, visible feedback, recovery, configuration failure, idle night, and final lifecycle were verified. The feedback label fit the 1280 × 720 layout headlessly. |
| M01-T11 clean import and consolidated runner | PASS | Fresh temporary copy imported with no prior cache. All five suites passed: four crop groups, 192 resource checks, 133 night-state checks, 31 startup/feedback checks, and 97 integration checks. The original scene UID and all five test script UIDs resolved to their new paths. |
| Runner negative controls | PASS | A startup expectation failure and an integration engine error with a success marker and exit 0 both failed the runner. It printed `3/5 suites passed` and exited 1. |
| Normal launch and original dashboard probe | PASS | Default launch loaded the dashboard. The original probe matched Day 1 → 2 and Growth 0 → 1, Lettuce, unchanged 1000 ml / 50 ml / 100 kWh reserves, and final `READY`. |
| Package C desktop interaction and export | NOT RUN | Runtime state, the connected signal and layout were checked headlessly. |

The known Windows certificate-store and temporary import settings diagnostics recurred. The crop assertions and validation fixtures retain their existing warnings. The unused dashboard crop parameter warning is absent. [Package C details](M01_PACKAGE_C_REPORT.md)

## 13. 2026-11-26 — Final M01 regression gate

**Source** `7b282e24dfff65957f8d181126c67da5498b7e2d` plus the reviewed M01 working tree · **Engine** Godot `4.7.2.stable.official.ed1daf0bf`

| Check | Result | Evidence |
|---|---|---|
| Fresh import and automated suites | PASS | The consolidated runner exited 0 with `5/5 suites passed`. Resource manager 192, night state 133, dashboard startup 31, and nightly integration 97 totaled 453 explicit checks. The four original crop groups and their final marker passed. |
| Default launch | PASS | Godot loaded `res://scenes/main.tscn` without a scene argument and exited 0. |
| Original dashboard probe | PASS | `BASELINE_MATCH=true`, exit 0. Day 1 → 2, Growth 0 → 1, Lettuce, 1000 ml water, 50 ml minerals, 100 kWh, and final `READY`. |
| Final desktop smoke check | PASS, user-reported | The user confirmed successful completion. Earlier baseline images are separately archived and do not depict the final dashboard. [Day 1](../screenshots/m01-t02-baseline-day1.png) · [Day 2](../screenshots/m01-t02-baseline-day2.png) |

The existing Windows certificate-store and import settings diagnostics and expected fixture warnings did not affect the gate. [Final report and reproduction commands](M01_FINAL_REPORT.md)

## M03 Package A — Liquid domain verification

The consolidated runner passed all six suites. The new suite passed 77 checks with zero failures, including strict decimal precision, signed integer overflow, capacity, conservation, remainder ties, inclusive mineral bands and atomic rejection. Exact expected and actual mineral loss matched for Nutrition Fruit (3,148 µL), Coffee Beans (9,430 µL) and Kotton (46,639 µL). The isolated M01 dashboard probe returned `BASELINE_MATCH=true`. [Package A report](M03_PACKAGE_A_REPORT.md)

## M03 Package B — Playable Coffee Beans verification

Fresh import and all seven suites passed. The Coffee suite reported 88 checks and zero failures, for 618 explicit checks plus the four original crop groups. The healthy fixture drew 300,000 µL, took up 720 µL, lost 9,430 µL total mineral, used 24 kJ and produced eight pending beans. Default Coffee launch and the separate unchanged Lettuce probe passed. [Package B report](M03_PACKAGE_B_REPORT.md)
