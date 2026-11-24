# 水培农业模拟系统

# Hydroponics Management Simulator

**游戏设计文档 / Game Design Document**

| 项目 | 内容 |
| --- | --- |
| 项目名称 | 水培农业模拟系统 |
| 英文名称 | Hydroponics Management Simulator |
| 文档版本 | v0.2 |
| 项目类型 | 2D 模拟经营 / 资源管理 |
| 游戏引擎 | Godot 4 |
| 开发语言 | GDScript |
| 目标平台 | PC（Windows） |
| 开发周期 | 10天原型开发 |
| 当前状态 | 设计与研究阶段 |

---

# 第一部分：简体中文

## 1. 游戏概述

### 1.1 游戏简介

《水培农业模拟系统》是一款以水培农业为核心的 2D 模拟与资源管理游戏原型。

玩家将操作一台水培设备，通过管理纯水、矿物质养分、电力和种子，完成作物的种植、生长和收获。

游戏将重点模拟不同作物的生长需求、矿物质消耗、环境污染、植物健康度以及种子遗传特性。玩家需要根据作物需求调整设备参数和资源配置，在有限的资源条件下实现稳定生产。

本项目参考《深空当铺》（Probably Stolen）中的水培农业系统，但不会完整复制原游戏，而是提取其中具有代表性的模拟机制，进行独立设计和原型实现。

### 1.2 设计目标

本项目主要展示以下能力：

- 游戏机制分析与系统拆解。
- 数学公式建模与数值计算。
- 面向对象程序设计。
- 游戏资源管理与数据驱动设计。
- 用户界面与交互设计。
- 功能测试与问题排查。

## 2. 核心设计理念

### 2.1 资源管理

玩家需要同时关注水、矿物质和电力等资源。不同作物具有不同的消耗需求，因此资源配置会影响生产效率。

### 2.2 模拟与计算

作物的生长、矿物质消耗和健康度变化将通过明确的计算规则实现，而不是完全依赖随机数。

### 2.3 策略选择

不同作物具有不同的生长周期、资源需求和收获价值。玩家需要根据当前资源状况选择合适的种植方案。

### 2.4 可扩展性

系统采用模块化设计，方便未来增加作物、遗传特性、设备模组和环境因素。

## 3. 核心游戏循环

游戏采用以夜间结算为核心的生产循环。

**基本流程：**

1. 选择作物和种子。
2. 检查水、矿物质和电力储备。
3. 配置水培设备及其模组。
4. 调整矿物质浓度和其他环境条件。
5. 启动设备。
6. 进入夜间结算。
7. 计算作物生长、资源消耗和健康度变化。
8. 检查作物是否达到收获条件。
9. 收获作物并查看结果。
10. 根据结果调整下一轮种植计划。

### 3.1 核心循环示意

```text
选择种子
   ↓
准备资源
   ↓
配置水培设备
   ↓
启动种植
   ↓
夜间结算
   ↓
计算生长与资源消耗
   ↓
检查健康度与生长进度
   ↓
是否成熟？
   ├── 否 → 继续下一晚
   └── 是 → 收获作物
                ↓
           查看收获结果
                ↓
           开始下一轮
```

## 4. 游戏资源系统

### 4.1 纯水（Pure Water）

纯水是作物生长所需的基础资源。

设计内容：

- 记录当前纯水储量。
- 根据作物需求计算每晚水资源消耗。
- 资源不足时限制或影响生产。
- 为未来的水质和污染系统预留扩展接口。

### 4.2 矿物质养分（Mineral Nutrients）

矿物质用于维持作物正常生长。

设计内容：

- 记录矿物质储量。
- 计算当前矿物质浓度。
- 允许玩家补充矿物质养分。
- 根据作物的需求范围判断矿物质是否充足。
- 将矿物质不足或过量与植物健康度关联。

具体计算公式将在 `FORMULAS.md` 中单独记录，并在实现前完成来源核对。

### 4.3 电力（Electricity）

水培设备运行需要消耗电力。

设计内容：

- 显示当前可用电力。
- 计算每晚设备运行的电力消耗。
- 根据设备效率调整能耗。
- 电力不足时无法正常启动或运行设备。

### 4.4 种子（Seeds）

种子决定作物类型和基础属性。

不同种子可能具有：

- 不同生长周期。
- 不同矿物质需求。
- 不同水资源需求。
- 不同收获数量。
- 不同遗传特性。

## 5. 作物系统

### 5.1 初始作物

原型阶段优先实现以下三种作物：

| 作物 | 英文名称 | 参考生长周期 | 参考收获数量 |
| --- | --- | ---: | ---: |
| 营养果 | Nutrition Fruit | 2晚 | 7 |
| 咖啡豆 | Coffee Beans | 3晚 | 8 |
| 韧棉 | Kotton | 6晚 | 13 |

注：以上周期和数量来自参考攻略所描述的特定条件，不应直接视为所有种子、设备和模组配置下的固定结果。实际实现时需要进一步核对完整机制，并明确原型采用的基础条件。

### 5.2 作物数据

每种作物应具有独立的数据配置：

| 属性 | 说明 |
| --- | --- |
| Crop ID | 作物唯一标识 |
| Crop Name | 作物名称 |
| Growth Duration | 基础生长周期 |
| Water Consumption | 水资源需求 |
| Mineral Requirement | 矿物质需求范围 |
| Mineral Consumption | 矿物质消耗参数 |
| Base Harvest | 基础收获数量 |
| Pollution Resistance | 污染抗性 |
| Available Traits | 可适用的遗传特性 |

部分数值将在研究阶段确认后填写。

### 5.3 生长机制

每次夜间结算时，系统根据作物和设备属性计算生长进度。

影响生长的因素包括：

- 基础生长速度。
- 设备性能。
- 种子遗传特性。
- 水资源是否充足。
- 矿物质条件。
- 其他已实现的环境因素。

达到成熟条件后，作物进入可收获状态。

## 6. 植物健康度系统

植物健康度用于反映作物在生长期间受到的环境影响。

### 6.1 主要影响因素

- 矿物质浓度过低。
- 矿物质浓度过高。
- 污染物影响。
- 其他未来扩展的环境因素。

### 6.2 设计目标

- 显示植物当前健康度。
- 记录每晚的健康度变化。
- 将健康度与最终收获品质或数量关联。
- 为玩家提供明确的状态反馈。

具体损伤公式和数值需要在研究和测试后确定。

## 7. 污染系统

污染系统用于模拟污染环境对作物生长的影响。

初步设计包括：

- 不同污染物类型。
- 污染物浓度。
- 作物污染敏感度。
- 作物污染抗性。
- 污染造成的健康度损失。

原型阶段优先实现可配置的污染损伤计算模块，而不是完整的复杂化学模拟。

## 8. 遗传与种子特性系统

遗传系统用于增加作物之间的差异性和策略深度。

原型阶段优先考虑以下特性：

| 特性 | 英文名称 | 设计效果 |
| --- | --- | --- |
| 快速生长 | Fast Growth | 提高生长速度 |
| 高产 | High Yield | 提高收获数量 |
| 耐旱 | Drought Resistant | 降低水资源需求 |
| 耐污染 | Hardy | 降低污染造成的影响 |

以上为原型中的特性设计方向。具体效果、等级和计算方式需要根据研究资料确认。

完整 DNA 编辑器和复杂的基因继承系统不属于本次原型的必要范围。

## 9. 水培设备系统

设备负责执行作物种植和资源消耗过程。

### 9.1 设备属性

初步设计包含：

- 性能（Performance）：影响作物生长速度。
- 效率（Efficiency）：影响设备电力消耗。
- 品质（Quality）：影响最终产品品质或相关结果。

属性与实际效果之间的计算关系需要在公式研究阶段确认。

### 9.2 设备模组

模组用于调整设备属性或增加特殊效果。

原型阶段将优先实现少量可配置模组，以验证设备属性和作物系统之间的交互。

## 10. 用户界面设计

游戏采用 2D 管理界面。

### 10.1 主界面

显示：

- 游戏名称。
- 当前游戏日期或夜晚编号。
- 当前资源概况。
- 水培设备状态。
- 主要操作入口。

### 10.2 设备管理界面

显示：

- 当前设备。
- 已安装模组。
- 设备性能。
- 设备效率。
- 设备品质。
- 启动与停止操作。

### 10.3 作物管理界面

显示：

- 当前种植作物。
- 作物生长进度。
- 当前健康度。
- 矿物质需求。
- 预计成熟状态。

### 10.4 资源管理界面

显示：

- 纯水储量。
- 矿物质储量。
- 当前矿物质浓度。
- 电力储量。
- 每晚预计资源消耗。

### 10.5 收获结果界面

显示：

- 作物名称。
- 收获数量。
- 作物品质或等级（如已实现）。
- 种子返还情况（如已实现）。
- 本轮资源消耗摘要。

## 11. 技术架构

采用模块化、数据驱动的设计方式。

| 模块 | 职责 |
| --- | --- |
| GameManager | 管理游戏状态与整体流程 |
| ResourceManager | 管理水、矿物质和电力 |
| HydroponicMachine | 管理水培设备及模组 |
| CropData | 存储作物基础数据 |
| SeedData | 存储种子及遗传特性 |
| GrowthCalculator | 计算作物生长进度 |
| MineralCalculator | 计算矿物质浓度与消耗 |
| PollutionCalculator | 计算污染影响 |
| HealthCalculator | 计算植物健康度 |
| HarvestCalculator | 计算最终收获结果 |
| UIController | 更新界面与处理用户交互 |

具体脚本划分可以随着开发进度调整，避免过早设计不必要的复杂架构。

## 12. 开发范围与优先级

### 12.1 Must Have（必须实现）

- 基础游戏主界面。
- 三种初始作物。
- 基础资源管理。
- 水培设备基本操作。
- 作物生长机制。
- 矿物质浓度与消耗。
- 植物健康度。
- 基础收获机制。
- 夜间结算流程。

### 12.2 Should Have（尽量实现）

- 污染损伤系统。
- 种子遗传特性。
- 设备模组。
- 详细资源消耗记录。
- 收获品质差异。
- 基础测试用例。

### 12.3 Could Have（时间允许时实现）

- 更多作物。
- 更丰富的遗传特性。
- 更多设备模组。
- 商品销售与简单经济系统。
- 设备升级。
- 更完善的视觉效果与动画。

### 12.4 Out of Scope（本次不实现）

- 完整复刻原游戏。
- 完整商店经营系统。
- NPC 和复杂顾客 AI。
- 多人游戏。
- 完整 DNA 编辑器。
- 复杂的 3D 场景。
- 原游戏全部经济与交易系统。

## 13. 测试与验收标准

原型至少需要验证以下情况：

| 测试场景 | 预期结果 |
| --- | --- |
| 正常资源条件 | 作物正常生长 |
| 水资源不足 | 正确触发资源不足处理 |
| 电力不足 | 设备无法正常运行 |
| 矿物质浓度过低 | 正确计算相应影响 |
| 矿物质浓度过高 | 正确计算相应影响 |
| 存在污染物 | 正确计算污染影响 |
| 不同作物 | 使用各自的生长和消耗参数 |
| 不同种子特性 | 产生对应的属性变化 |
| 作物成熟 | 进入收获状态 |
| 收获计算 | 输出符合公式的收获结果 |

具体预期数值将在 `TESTING_REPORT.md` 中记录。

## 14. 项目研究来源

1. 《深空当铺》水培农业 Wiki  
   <https://wiki.biligame.com/probablystolen/水培农业>

2. GameWith.ai — 水培农场主攻略  
   <https://gamewith.ai/probably-stolen/zh-hans/specializations/hydroponic-farmer>

研究资料用于分析参考游戏机制。所有尚未确认的数值和公式均应标记为待验证，不应直接当作最终实现依据。

---

# Part Two: English

## 1. Game Overview

### 1.1 Description

Hydroponics Management Simulator is a 2D simulation and resource management prototype focused on hydroponic farming.

Players operate a hydroponic machine and manage pure water, mineral nutrients, electricity, and seeds to cultivate and harvest crops.

The simulation focuses on crop growth, mineral consumption, environmental pollution, plant health, and seed genetics.

The project is inspired by the hydroponics system in *Probably Stolen (深空当铺)*. Rather than recreating the original game, it independently analyzes selected mechanics and implements them in a simplified prototype.

### 1.2 Design Objectives

The project aims to demonstrate:

- Game mechanics analysis and system decomposition.
- Mathematical modeling and numerical calculations.
- Object-oriented programming.
- Resource management and data-driven design.
- User interface and interaction design.
- Functional testing and debugging.

## 2. Core Design Principles

**Resource Management:** Players must balance water, minerals, and electricity.

**Simulation and Calculation:** Crop growth, mineral consumption, and health changes are determined by explicit rules rather than relying entirely on random outcomes.

**Strategic Choices:** Different crops have different growth durations, resource requirements, and harvest characteristics.

**Extensibility:** The system is designed to support additional crops, genetic traits, equipment modules, and environmental factors.

## 3. Core Gameplay Loop

The game follows a production cycle centered on nightly processing.

1. Select a crop and seed.
2. Check water, mineral, and electricity supplies.
3. Configure the hydroponic machine and its modules.
4. Adjust mineral concentration and environmental conditions.
5. Start cultivation.
6. Advance to nightly processing.
7. Calculate crop growth, resource consumption, and health changes.
8. Check whether the crop is ready for harvest.
9. Harvest and review the results.
10. Adjust the next cultivation cycle.

## 4. Resource Systems

### 4.1 Pure Water

Pure water is a fundamental resource for crop cultivation.

Planned functionality:

- Track available water.
- Calculate nightly water consumption.
- Handle insufficient water conditions.
- Provide an extension point for water quality and pollution mechanics.

### 4.2 Mineral Nutrients

Minerals support normal crop growth.

Planned functionality:

- Track mineral reserves.
- Calculate mineral concentration.
- Allow players to replenish nutrients.
- Compare concentration against crop-specific requirements.
- Connect mineral imbalance to plant health.

Exact formulas will be documented in `FORMULAS.md` and verified before implementation.

### 4.3 Electricity

Hydroponic machines consume electricity during operation.

Planned functionality:

- Display available electricity.
- Calculate nightly energy consumption.
- Apply equipment efficiency modifiers.
- Handle insufficient electricity.

### 4.4 Seeds

Seeds determine crop type and base properties.

Different seeds may have different:

- Growth durations.
- Mineral requirements.
- Water requirements.
- Harvest quantities.
- Genetic traits.

## 5. Crop System

### 5.1 Initial Crops

The prototype will initially prioritize three crops:

| Crop | Reference Growth Duration | Reference Harvest Quantity |
| --- | ---: | ---: |
| Nutrition Fruit | 2 nights | 7 |
| Coffee Beans | 3 nights | 8 |
| Kotton | 6 nights | 13 |

These values are reported under particular reference-game conditions. They are not guaranteed to apply to every seed, equipment, or module configuration. The prototype's baseline conditions must be verified and documented before final implementation.

### 5.2 Crop Data

Each crop will have an independent data definition containing:

- Crop ID and name.
- Base growth duration.
- Water consumption.
- Mineral requirement range.
- Mineral consumption parameters.
- Base harvest quantity.
- Pollution resistance.
- Available genetic traits.

Some numerical values remain subject to research.

### 5.3 Growth Mechanics

During each nightly processing cycle, the system calculates growth progress using crop and equipment properties.

Potential factors include:

- Base growth speed.
- Equipment performance.
- Seed genetic traits.
- Water availability.
- Mineral conditions.
- Other implemented environmental factors.

Once the maturity condition is reached, the crop becomes available for harvest.

## 6. Plant Health System

Plant health represents the environmental condition of a growing crop.

Potential influencing factors:

- Mineral concentration below the required range.
- Mineral concentration above the required range.
- Pollutant exposure.
- Additional environmental factors in future expansions.

The system will display health, record nightly changes, and connect plant health to harvest quality or quantity.

Exact damage formulas and values must be verified through research and testing.

## 7. Pollution System

The pollution system simulates environmental damage to crops.

Planned components:

- Pollutant types.
- Pollutant concentration.
- Crop pollution sensitivity.
- Crop pollution resistance.
- Health reduction caused by pollution.

The prototype will prioritize a configurable pollution damage calculator rather than a complete chemical simulation.

## 8. Genetics and Seed Traits

The genetics system introduces variation and strategic depth.

Initial prototype traits:

| Trait | Intended Effect |
| --- | --- |
| Fast Growth | Increases growth speed |
| High Yield | Increases harvest quantity |
| Drought Resistant | Reduces water requirements |
| Hardy | Reduces pollution impact |

These are prototype design directions. Exact effects, levels, and calculation methods require further verification.

A complete DNA editor and complex inheritance system are outside the essential scope of this prototype.

## 9. Hydroponic Equipment System

Equipment manages cultivation and resource consumption.

Initial attributes:

- **Performance:** Influences crop growth speed.
- **Efficiency:** Influences electricity consumption.
- **Quality:** Influences product quality or related outcomes.

The exact relationships between these attributes and their effects must be verified during formula research.

Equipment modules will modify machine attributes or provide special effects. The prototype will implement a limited number of configurable modules.

## 10. User Interface Design

The game will use a 2D management interface.

### Main Interface

- Game title.
- Current day or night number.
- Resource overview.
- Hydroponic machine status.
- Main navigation controls.

### Equipment Management

- Current machine.
- Installed modules.
- Performance.
- Efficiency.
- Quality.
- Start and stop controls.

### Crop Management

- Current crop.
- Growth progress.
- Plant health.
- Mineral requirements.
- Maturity status.

### Resource Management

- Pure water reserves.
- Mineral reserves.
- Mineral concentration.
- Electricity reserves.
- Estimated nightly consumption.

### Harvest Results

- Crop name.
- Harvest quantity.
- Crop quality or grade, if implemented.
- Seed return, if implemented.
- Resource consumption summary.

## 11. Technical Architecture

The prototype will use a modular, data-driven architecture.

| Module | Responsibility |
| --- | --- |
| GameManager | Overall game state and flow |
| ResourceManager | Water, minerals, and electricity |
| HydroponicMachine | Machine attributes and modules |
| CropData | Base crop definitions |
| SeedData | Seed properties and genetic traits |
| GrowthCalculator | Crop growth calculations |
| MineralCalculator | Mineral concentration and consumption |
| PollutionCalculator | Pollution impact |
| HealthCalculator | Plant health calculations |
| HarvestCalculator | Harvest result calculations |
| UIController | Interface updates and user interaction |

Script responsibilities may be adjusted during development to avoid unnecessary complexity.

## 12. Development Scope and Priorities

**Must Have**

- Main game interface.
- Three initial crops.
- Basic resource management.
- Basic machine operation.
- Crop growth.
- Mineral concentration and consumption.
- Plant health.
- Basic harvesting.
- Nightly processing.

**Should Have**

- Pollution damage.
- Seed genetic traits.
- Equipment modules.
- Resource consumption logs.
- Harvest quality differences.
- Basic test cases.

**Could Have**

- Additional crops.
- More genetic traits.
- Additional equipment modules.
- Basic selling and economic systems.
- Equipment upgrades.
- Improved visuals and animations.

**Out of Scope**

- Full recreation of the reference game.
- Complete shop management.
- NPCs and complex customer AI.
- Multiplayer.
- Full DNA editor.
- Complex 3D environments.
- Complete original-game economy and trading systems.

## 13. Testing and Acceptance Criteria

The prototype should validate:

- Normal resource conditions.
- Insufficient water.
- Insufficient electricity.
- Mineral concentration below the required range.
- Mineral concentration above the required range.
- Pollutant exposure.
- Different crop parameters.
- Different seed traits.
- Crop maturity.
- Harvest calculations.

Expected numerical results will be recorded in `TESTING_REPORT.md`.

## 14. Research References

1. *Probably Stolen* — Hydroponics Wiki  
   <https://wiki.biligame.com/probablystolen/水培农业>

2. GameWith.ai — Hydroponic Farmer Guide  
   <https://gamewith.ai/probably-stolen/zh-hans/specializations/hydroponic-farmer>

Reference materials are used to analyze the original mechanics. Unverified values and formulas must remain marked as provisional until confirmed.

---

**Document Status:** Draft v0.2  
**Project Status:** In Development  
**Engine:** Godot 4  
**Programming Language:** GDScript
