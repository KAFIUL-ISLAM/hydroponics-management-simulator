# 开发日志 | Development Log

## 2026-11-27 · M11 developer acceptance · v0.7.0

The developer reports all 30 M11 manual acceptance checks passed: visual/interaction states (5), keyboard navigation (5), manual and analysis tools (9), gameplay regression (6), and resolution/Reduced Motion (5). Manual testing included holding Enter on Next Night, collection with Reduced Motion, and visible focus during navigation. Codex separately reports 19 suites, 1,480 explicit checks including 264 workshop GUI checks, four original crop assertion groups, successful default launch and legacy Lettuce baseline, deterministic Kotton comparison, and renderer captures at both supported resolutions. These automated results are not developer manual checks and were not rerun by Copilot for documentation.

The supplied performance report records 314 rendered-frame samples per resolution over roughly ten seconds after warm-up; it does not specify how samples are apportioned among scenarios. Next Night synchronous timing is a three-sample median per resolution. No bottleneck or repeatable speedup was established, so no performance refactor was made. Exact measurements, coverage limitations, and temporary renderer evidence locations are documented in [M11_FINAL_REPORT.md](M11_FINAL_REPORT.md). M11 is developer-accepted as v0.7.0. M12 remains pending.

## 2026-11-27 · M10 completed · v0.6.0 release

Codex completed the M10 workshop interaction, onboarding, and nutrient-comparison implementation. On 2026-11-27, the developer reported passing all 19 manual acceptance items: battery recovery (5), machine status (4), manual and navigation (5), and gameplay/presentation (5). M10 is complete and developer-accepted; it was released as v0.6.0. The M09 battery-recovery report was traced to grid refresh during the `GameState` settlement lock, which cached drag eligibility as false. Both workshop grids now check `farm.can_act()` at drag start or drop evaluation. The first battery refill succeeds immediately after depletion, with water, seed, and module drag recovery also covered. This changes interaction eligibility, not energy calculation. The manual, status treatment, and deterministic Kotton comparison are documented in the [M10 report](M10_FINAL_REPORT.md), [design analysis](HYDROPONICS_DESIGN_ANALYSIS_ZH.md), and [demonstration guide](DEMONSTRATION_GUIDE.md).

Codex reports 19 regression suites, 1,440 explicit checks including 224 workshop GUI checks, four original crop assertion groups, successful default launch and legacy Lettuce baseline, and renderer captures at both supported resolutions. These are Codex results, not tests run by Copilot for this documentation update. The developer's 19-item manual acceptance is recorded separately in the [M10 report](M10_FINAL_REPORT.md). The handover's older “desktop acceptance is pending” sentence is superseded by the dated developer record. [Testing evidence](TESTING_REPORT.md#m10--2026-11-27)

## 2026-11-27 · M09 accepted

The developer accepted M09 after manual gameplay testing and identified two issues to address within M10. “Harvest pending” and similar machine messages were hard to read against the chamber. After the machine ran out of energy, a replacement battery could fail to start dragging until the player dragged another inventory item. The battery failure was developer-reported at this checkpoint; M10 later confirmed and corrected the interaction-state cause. M09 was published on `main` at `6ff68084beb6449060db3a1c6fdd0eb613bc62f9`; at this historical checkpoint, v0.5.0 was the latest release tag at `a73ed34d3c6aeda495e3c8cf46cd826d0420e24f`. [M10 report](M10_FINAL_REPORT.md)

## 2026-11-27 · M09 night and machine feedback

The workshop reuses its existing night and collection transitions. A transient strip shows actual night resource, growth, health and output changes, and the affected compartment exposes the existing shortage or configuration message. Reduced Motion is a saved local option in the machine header. Both modes use the same simulation signals and transactions. M10 was subsequently accepted and is intended for v0.6.0.

Older M08 checkpoint entries below retain the status recorded at those milestones; their “M09 pending/paused” wording predates M09 acceptance above.

## 2026-11-27 · v0.5.0 Interactive Hydroponics Workshop

The developer approved the M08 extension after manual gameplay testing. The release adds the default icon workshop, direct machine interaction, individual output collection, capacity-aware inventory, dedicated tools, the painted dustbin and crop alignment. M09 remains pending. [Release notes and verification](M08_EXTENSION_FINAL_REPORT.md)

## M08-C.4 · Chamber crop alignment

The workshop masks the platforms painted into the existing crop textures and aligns each stem to the chamber floor in background-image coordinates. The existing lower rim is drawn in front of the plant. [Before](../screenshots/m08c4-kotton-before.png) · [After](../screenshots/m08c4-kotton-after.png) · [Growth stages and resized views](../screenshots/m08c4-chamber-stages.png)

Visually checked empty, seedling, growing, mature Coffee, Fruit and Kotton, and live viewport changes to 1280 × 960 and 1720 × 720. All 18 Godot regression suites passed.

## M08-C.3 · Inventory capacity and machine compartments

The counted grid now renders the farm's seed and produce capacity. Refills, tablets, modules and spare chassis use their own tray because they are backed by separate farm stores. Empty compartments use the same muted style. The machine shows up to five individual output icons and reports the remaining quantity by output type in the overflow tooltip.

## M08-C.2 · Individual output collection

The workshop uses the existing farm yield, grade and offspring state to expose individual outputs. A click reserves a grid slot and `CoffeeFarm.collect_one()` commits one unit. The 0.25-second arrival animation controls presentation only. Fruit and Kotton use distinct seed packet variants and produce icons. The empty seed slot has no packet. The approved starting water and energy remain loaded, and the energy meter uses stored charge against its session full-charge reference.

## 2026-11-27 · M08-C.1 workshop drag sources, dustbin and tools

The scaled default window reproduced failed drops when Godot reconstructed the drag origin outside the pressed tile. The inventory now captures the pressed item key and checks that it still belongs to the live grid when drag starts. Preview and dustbin highlight controls ignore input. The painted dustbin accepts disposable seeds and products, and the three analysers/editor tools use a separate dock.

Empty resource compartments remain pending. The farm initializes with 5,000 ml pure water plus 150 ml minerals in its vessel and 100 kJ in its machine balance. The separate refill stores hold another 5,000 ml of pure water and 100 kJ. Refills merge into those machine balances, and no existing method can return a loaded battery or preserve a removed container's remaining mixture. The smallest compatible change is an explicit farm-level attach/detach contract for a vessel and battery, with exclusive ownership of the starter quantities and the existing settlement calculations operating on the installed contents.

## 2026-11-27 · M08-C workshop interaction stabilization

The owner accepted the workshop layout and reported that drops were failing. A quick release without a final pointer-motion event reproduced the failure at both resolutions. The workshop now hit-tests the actual release position for authenticated transfers, validates the source and recipient, and delegates to the existing farm operations. The seed slot clears visually at maturity. The farm still owns the pending result until atomic collection. Installed modules can be returned while stopped when allowed by equipment validation. Refilled power and liquid remain shared machine pools under the existing farm contract.

## 2026-11-27 · M08-B icon-based workshop

The default scene now opens the full-screen workshop. Double-click the chamber for its slots. The inventory projects the existing supplies and equipment as draggable icons, and compatible drops call the existing farm methods. A seed drop plants the exact selected instance and starts the machine through its existing toggle. Nightly settlement and capacity checks remain in the farm. Harvest results are displayed by output group and collected together as the existing atomic lot. The previous dashboard remains available as a separate scene for regression and developer controls. The three reference crops are playable in the workshop, while Lettuce remains a separate legacy fixture. M09 remains paused.

## 2026-11-27 · M08-A icon inventory redesign review

Branch `redesign/icon-inventory` starts from published v0.4.0. Inventory uses existing item art, live bilingual tooltips, and one-cell drag placement for individual seeds and product stacks. Grid positions are session-local UI state. Item ownership, stack sizes and capacity remain in `CoffeeFarm`. The renderer captured the 1280 × 720 inventory. M09 remains paused. [Inventory capture](../screenshots/m08a-icon-inventory-1280.png)

Machine slots, automatic planting and start, tablet drops and output collection remain outside this package. The current lifecycle plants and starts separately, and `CoffeeFarm.collect()` transfers the entire pending yield and offspring atomically before clearing the plant. Dragging individual outputs will require an explicit decision about that collection contract. Current items use one cell, so rotation is deferred until multi-cell footprints serve a gameplay purpose.

## 2026-11-26 · v0.4.0 Visual Transformation

The owner authorized publication of the accepted M08 visual milestone. The release includes the orbital laboratory, state-driven artwork, environment hotspots, individual inventory tiles and specialized workstations. M09 remains pending. [Release report](M08_FINAL_REPORT.md)

## 2026-11-26 · M08 final acceptance

Reviewed all four M08 packages and recorded the owner's ten M08-D desktop passes. A fresh 17-suite run and both launch paths passed. The frozen domain files match v0.3.0. The artwork and metadata inventory is ready for the proposed v0.4.0 checkpoint. M09 remains pending. [M08 final report](M08_FINAL_REPORT.md)

## 2026-11-26 · M08 Package D

Unified specialized workstation styling, added authoritative capacity, range and operation readouts, and verified modal isolation, Escape cancellation and focus restoration. The owner confirmed all 11 M08-C desktop checks before authorizing this package. [M08-D report](M08_PACKAGE_D_REPORT.md)

## 2026-11-26 · M08 Package C

Rebalanced the dashboard around the laboratory, aligned hotspots to the artwork canvas, and added a selectable inventory strip and compact authoritative crop meters. Moved cultivation actions into a dedicated panel and retained the contextual shortcut and Next Night. All changes are presentation-layer work. [M08-C report](M08_PACKAGE_C_REPORT.md)

## 2026-11-26 · Inventory discard stabilization

Fixed selection restoration after discard by comparing seed object identity and product string values safely. Removed items fall back to the first remaining row, and an empty inventory clears selection and disables discard. Cancelled confirmations cannot execute later. The owner confirmed all nine manual regression checks passed.

## 2026-11-26 · M08 Package B

Audited the owner-supplied artwork, prepared separate aligned transparent runtime crops, and integrated the laboratory chamber and workstation icons. Captured Godot renders at both supported resolutions and retained the frozen simulation baseline. [M08-B report](M08_PACKAGE_B_REPORT.md)

## 2026-11-26 · M08 Package A

Added the Orbital Hydroponics visual foundation, shared playable theme and three-column workspace. Bound installed-machine identity, seed/item selection, refill quantities and DNA operation progress to the current presentation. The legacy scene and simulation remain at the published technical baseline. [M08-A report](M08_PACKAGE_A_REPORT.md)

## 2026-11-26 · M05–M07 checkpoint acceptance

Fresh regression passed all 13 suites, 932 explicit checks and four original assertion groups. The user confirmed both M07 desktop walkthroughs and authorized the v0.3.0 checkpoint. [Milestone report](M07_FINAL_REPORT.md)

## 2026-11-26 · M07 Package B

Added a plain DNA editor with trait application previews, seed locking, atomic nightly progress, and deterministic outcome coverage. Preserved the farming and offspring regression fixtures. [M07-B report](M07_PACKAGE_B_REPORT.md)

## 2026-11-26 · M07 Package A

Added equipment definitions, a deterministic module resolver, atomic stopped-machine equipment changes, and a bilingual Equipment dialog. Full nightly debits now use resolved speed and energy while the neutral machine keeps its original fixtures. [M07-A report](M07_PACKAGE_A_REPORT.md)

## 2026-11-26 · M06 Package B

Added deterministic seed return calculation, independent inherited seeds, selection by identity, atomic capacity checks for combined harvests, and a modified Coffee Beans demo. [M06-B report](M06_PACKAGE_B_REPORT.md)

## 2026-11-26 · M06 Package A

Added a typed trait catalog and deterministic effective-property resolver. Integrated per-seed properties through a planting snapshot and added bilingual seed inspection. Confirmed native crop parity and preserved M05 behavior. [M06-A report](M06_PACKAGE_A_REPORT.md)

## 2026-11-26 · M05 pollution and combined plant health

Reconciled the published integer pollution tiers and documented provisional fractional classification and final nightly rounding. Added a typed per-component calculator, integrated combined health into the farm's atomic night, and exposed analysis and confirmed demo solutions in the existing dashboard. [M05 report](M05_REPORT.md)

## 2026-11-26 · M02–M04 checkpoint verification

Fresh import and all eight suites passed with 719 explicit checks and four original crop assertion groups. All three numerical cultivation fixtures, the default dashboard launch and the archived Lettuce probe passed. The user confirmed the three-crop desktop walkthrough at 1280 × 720. [Final checkpoint evidence](M04_FINAL_REPORT.md)

## 2026-11-26 · M04 three-crop farming

Extended the Coffee Beans simulation and dashboard to support Nutrition Fruit and Kotton. Added independent starter seeds, a capacity-limited demonstration seed action, crop-specific quantity and size rules, and inventory recovery through confirmed single-item discards. Added provisional proportional tablet displacement and confirmed draining. All eight suites and both launch paths passed, including the Lettuce one-night baseline. [M04 report](M04_REPORT.md)

项目：水培农业模拟系统  
Project: Hydroponics Management Simulator

---

## 2026-11-23 — 项目研究与方向确定

### 今日目标

分析技术评审任务，选择适合在规定时间内完成的游戏系统。

### 完成工作

- 阅读并分析技术评审任务要求。
- 对参考游戏《深空当铺》（Probably Stolen）进行初步研究。
- 比较水培农业系统与化学制药系统的开发范围。
- 最终选择水培农业系统作为本项目的开发方向。
- 确定使用 Godot 4 和 GDScript 进行原型开发。

### 技术与设计决策

- 项目采用 2D 模拟经营形式。
- 优先实现核心模拟机制，而不是完整复刻原游戏。
- 初始重点研究作物生长、矿物质消耗、污染损伤和遗传特性。

### 下一步

- 深入研究水培农业系统的数值机制。
- 整理游戏设计文档。
- 准备 Godot 开发环境。

---

## 2026-11-24 — 机制研究与开发环境搭建

### 今日目标

完成主要机制的初步研究，建立开发环境和项目文档结构。

### 完成工作

**1. 游戏机制研究**

- 研究水培农业基本流程。
- 研究作物生长与夜间结算机制。
- 研究矿物质浓度与消耗。
- 研究矿物质失衡造成的健康损伤。
- 研究污染物对作物的影响。
- 研究作物健康度与收获结果的关系。
- 初步研究设备属性、模组及遗传特性。

**2. 开发环境**

- 在 Windows 系统上安装并配置 Godot 4。
- 创建 Godot 项目。
- 建立基础项目目录。
- 安装并配置 Git。
- 创建 GitHub 远程仓库。
- 初始化本地 Git 仓库。
- 完成首次 Git 提交并推送至 GitHub。

**3. 项目文档**

- 创建双语 README。
- 创建 GDD v0.2。
- 建立 Research Notes、Formulas、Technical Design 和 Testing Report 等文档。
- 规划开发过程的截图和证据保存方式。

### 当前状态

- 开发环境：已完成。
- GitHub 仓库：已连接。
- 基础文档结构：已建立。
- 核心机制研究：初步完成，仍需进一步核对。
- 游戏功能实现：尚未开始。

### 当前问题与待办

- 进一步确认部分机制的准确计算顺序。
- 确定初始作物的数据配置。
- 设计主游戏界面。
- 开始 Godot 场景和脚本开发。

### 下一步

- 完善研究资料和公式文档。
- 设计主游戏界面。
- 建立基础场景和 UI 组件。

---

## 开发记录原则

每次开发工作结束后，记录：

1. 日期和开发目标。
2. 完成的工作。
3. 技术决策及其原因。
4. 遇到的问题。
5. 问题解决方法。
6. 截图或其他开发证据。
7. 下一步计划。

重要里程碑应创建 Git Commit，并保留对应的开发截图。

## 2026-11-24 — 首个完整仪表盘界面实现

### 今日目标

完成水培农业模拟系统的第一个完整 UI 场景，并验证运行效果。

### 已完成工作

1. 创建主场景 `main.tscn`，使用 Control 作为根节点。
2. 创建全屏深色工业风背景。
3. 配置 SafeArea 和 MainLayout 容器。
4. 实现系统标题、日期和运行状态栏。
5. 实现三种资源监控卡片：
   - 纯净水（Pure Water）
   - 矿物质（Minerals）
   - 电力（Electricity）
6. 实现水培设备状态面板。
7. 实现作物状态面板。
8. 实现资源管理、设备配置和夜间结算按钮。
9. 完成 1280 × 720 分辨率下的界面测试。
10. 测试不同窗口尺寸下的 UI 布局表现。

### 技术实现

- Engine：Godot 4.7.2
- Language：GDScript（本阶段尚未实现游戏逻辑）
- UI：Godot Native Control Nodes
- Layout：VBoxContainer、HBoxContainer、GridContainer、MarginContainer、PanelContainer
- Styling：StyleBoxFlat、Theme Overrides

### 测试结果

- 主场景可以正常运行。
- 所有主要 UI 区域正常显示。
- 窗口调整尺寸后，界面能够适应可用空间。
- 未发现阻止本阶段运行的错误。

### 当前限制

- 资源数值为演示数据。
- 按钮尚未连接实际功能。
- 水培设备尚未连接模拟系统。
- 作物生长和资源消耗尚未实现。

### 开发证据

- screenshots/dashboard-v1-editor.png
- screenshots/dashboard-v1-runtime.png

### 下一步

开始实现资源数据模型、资源管理逻辑和基础游戏状态管理。
## 2026-11-24 — 资源管理模块初步实现与验证

### 已完成工作
- 创建 ResourceManager.gd。
- 实现水、矿物质和电力的资源存储。
- 实现资源查询、消耗和补充功能。
- 实现资源不足检测。
- 添加 resources_changed 和 resource_insufficient 信号。
- 通过测试验证水资源从1000 ml减少至900 ml。
- 开始将资源管理模块连接到主界面。

### 测试结果
- ResourceManager 脚本正常加载。
- 资源消耗函数测试通过。
- 资源变化信号用于通知 UI 更新。
- 主界面资源数据显示集成待最终验证。
---

## 2026-11-25 — Crop Data 测试通过

### 今日工作
- 运行 `crop_data_test`。
- 完成全部 5 个测试用例。

### 测试结果
- **通过：** 5/5
- **失败：** 0/5
- `crop_data_test` 当前测试结果：全部通过。

### 记录说明
本次结果表明，当前版本的 Crop Data 测试用例均已通过。测试覆盖的具体内容及验证的属性，应以 `crop_data_test` 中实际定义的测试用例为准。

### 下一步
- 保存本次测试结果及相关截图。
- 如有需要，在 `TESTING_REPORT.md` 中记录 5 个测试用例的名称、预期结果和实际结果。
- 继续开发下一个功能模块，并在完成后运行相应测试。

---
## 开发日志：CropData 资源测试通过

**日期：** 2026-11-25

### 本次工作
运行 Crop Resource Test，验证 `CropData` 资源的基础功能与初始化状态。

### 测试结果
- 测试 1：CropData 资源成功加载
- 测试 2：作物身份信息验证通过
- 测试 3：默认值验证通过
- 测试 4：遗传特征初始化成功
- **结果：截图显示的 4 项测试全部通过**

### 证据
已保存测试通过的 Godot 输出面板截图，可作为本次测试记录的证据。

### 下一步
继续开发下一个模块，并在实现后补充对应测试与测试报告。

## 开发日志：CropData 资源在主界面成功显示

**日期：** 2026-11-25

### 本次工作
成功加载 `CropData` 资源，并在主仪表盘中显示作物信息。

### 完成情况
- 主界面成功运行并显示水培管理仪表盘。
- 作物状态区域成功显示生菜（Lettuce）信息。
- 当前显示内容用于验证资源加载与界面展示；实际玩法数值仍需后续验证。

### 证据
已保存主界面运行截图，记录 `CropData` 资源在仪表盘中的显示效果。

### 下一步
继续实现作物状态与水培设备之间的交互，并在完成后进行测试和记录。

## 2026-11-26 — M01-T03 default dashboard launch

- Recorded the user's M01-T02 desktop check at 1280 × 720. The dashboard rendered, the physical Next Night click advanced Day 1 to 2 and Growth 0 to 1, and the user reported no errors. [Manual verification](TESTING_REPORT.md#8-2026-11-26--user-manual-verification-of-the-m01-t02-baseline)
- Set `application/run/main_scene` to `uid://lm4cvp2hfxau`, the existing dashboard scene. This is the only project-setting change. [Project configuration](../project.godot#L14)
- Imported a temporary project from the tracked working-tree files and verified headless default launch without a scene argument. The original one-night probe and four crop-resource test groups passed. Existing diagnostics and the editor-settings save error are documented in the report. [M01-T03 results](M01_T03_REPORT.md)
- M01-T04 resource input validation is the next proposed task after review. [Foundation plan](FOUNDATION_STABILIZATION_PLAN.md#m01-t04--validate-resource-inputs)

## 2026-11-26 — M01-T04 resource input validation

- Verified the M01-T03 automated acceptance logs. The user confirmed normal desktop launch and manual gameplay after that task.
- Added shared validation for resource type, operation amount, the selected balance, and credit overflow. Invalid mutations return false without changing the ledger or emitting either resource signal. Valid shortages retain their signal. [ResourceManager](../scripts/resource_manager.gd#L39)
- Added the headless resource suite. All 118 checks passed. An intentionally failed expectation in a temporary copy produced the expected failure output and exit 1. The crop resource test, dashboard baseline probe, and normal launch passed. [Verification](M01_T04_REPORT.md)
- M01-T05 configured reset is the next proposed task. [Foundation plan](FOUNDATION_STABILIZATION_PLAN.md#m01-t05--reset-to-configured-starting-balances)

## 2026-11-26 — M01 Package B resource and settlement stabilization

- M01-T05 captures starting balances at first readiness and restores them together. Default, overridden, repeated, and pre-initialization cases passed.
- M01-T06 validates a batch before mutation, returns a structured result, and routes nightly water and mineral debits through it. A rejected batch leaves growth and balances unchanged.
- M01-T07 gives GameState ownership of settlement and passes a one-use authorization to the simulator. Shortage advances time, configuration failure leaves the day unchanged, and synchronous callbacks cannot start a duplicate night, pause, or change crops. These policies are provisional engineering decisions.
- Final checks passed for 192 resource checks, 133 night-state checks, both failure-detection controls, the four existing crop groups, normal launch, and the Lettuce baseline. [Package B results](M01_PACKAGE_B_REPORT.md)

## 2026-11-26 — M01 Package C dashboard and test migration

- M01-T08 connected dashboard signals before reading live child state. Startup and refresh cover configured balances, crop, growth, day, lifecycle status, and button availability.
- M01-T09 rendered bilingual settlement outcomes, including the required and available quantities for the affected resource. The existing dashboard layout and settlement calculations were preserved.
- M01-T10 added end-to-end checks using the real dashboard scene and test-only crop data. M01-T11 moved the test scenes and script UIDs into `tests/` and added the Windows runner.
- A fresh import, all five suites, test UID checks, default launch, and the original one-night probe passed. The runner rejected both temporary negative controls. [Package C results](M01_PACKAGE_C_REPORT.md)

## 2026-11-26 — M01 final review and GitHub checkpoint

- The user completed the final desktop smoke check and approved Packages A, B, and C for the milestone checkpoint.
- The publication candidate passed a fresh Godot import, all five automated suites, normal project launch, and the unchanged one-night Lettuce probe.
- Reviewed the project files, UID sidecars, and baseline screenshots. Published command examples use portable paths while retaining the recorded arguments, results, and diagnostics. Local archives, cache, and a duplicate crop-test scene were excluded from the publication candidate. [Final M01 report](M01_FINAL_REPORT.md)

## 2026-11-26 — M02 research reconciliation

- Reconfirmed the published M01 revision and tag. Reviewed the original research and current implementation, then checked the Bilibili reference and GameWith guide.
- Mapped 45 requirements and reconciled the three GDD crops, health and growth scales, mixed-liquid debits, equipment and harvest stages. Reproduced all three reported mineral-loss totals in a separate calculation check.
- Recorded the proposed settlement sequence, unresolved boundaries, and a dependency-ordered M03–M10 plan. Recommend Coffee Beans for the first playable loop by November 29 once the blocking decisions are approved. [M02 handoff](M02_REPORT.md)

## M03 Package A — Liquid domain

- Recorded the approved provisional policies and added a standalone integer µL vessel for later settlement integration.
- Verified supply validation, exact proportional allocation, and staged mineral uptake. All three reference fixtures matched and all six suites passed. The legacy Lettuce probe remained green. [Package A report](M03_PACKAGE_A_REPORT.md)

## M03 Package B — First playable Coffee Beans loop

- Added the native-effective Coffee Beans definition, independent seed and plant instances, and a one-slot farm with explicit controls, finite supplies and one-time collection.
- Staged liquid, energy and plant changes before the guarded GameState publishes its settled result. Normal launch now opens the inherited Coffee Beans dashboard. Lettuce remains an explicitly runnable fixture.
- Verified the full button-driven loop, numerical fixture and regressions after a fresh import. [Package B report](M03_PACKAGE_B_REPORT.md)
