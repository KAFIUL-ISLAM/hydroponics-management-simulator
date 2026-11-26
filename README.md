# 水培农业模拟系统 | Hydroponics Management Simulator

**基于 Godot 4 开发的水培农业管理模拟项目**

[简体中文](#简体中文) | [English](#english)

---

# 简体中文

## 1. 项目简介

水培农业模拟系统是一款基于 **Godot 4** 和 **GDScript** 开发的 2D 资源管理与模拟游戏原型。

本项目以水培农业系统为核心，研究并实现作物生长、矿物质消耗、污染损伤、遗传特性以及资源管理等机制。

项目参考了游戏《深空当铺》（Probably Stolen）中的水培农业系统，并在此基础上进行独立的机制分析、系统设计与原型开发。

本项目的目标不仅是实现一个可玩的模拟系统，还包括展示游戏机制分析、数学建模、程序设计和测试验证能力。

## 2. 项目目标

- 分析参考游戏中的水培农业机制。
- 建立作物生长与资源消耗的数学模型。
- 实现水分、矿物质和电力等资源管理系统。
- 设计作物健康度与污染损伤计算机制。
- 实现不同作物及种子特性的差异化表现。
- 构建具有基本交互功能的水培管理界面。
- 通过测试验证核心计算逻辑的正确性。

## 3. 核心功能

以下为项目计划实现的主要功能，具体完成情况以实际开发进度为准。

| 功能模块 | 功能说明 |
| --- | --- |
| 作物管理 | 选择、种植和收获不同作物 |
| 水资源管理 | 管理纯水储量及消耗 |
| 矿物质系统 | 计算矿物质浓度与消耗 |
| 生长系统 | 模拟作物生长进度 |
| 健康度系统 | 根据环境条件计算作物健康状态 |
| 污染系统 | 模拟污染物对作物的影响 |
| 遗传系统 | 通过种子特性影响作物表现 |
| 设备系统 | 管理水培设备性能、效率和品质 |
| 收获系统 | 根据作物状态计算收获结果 |

## 4. 初始作物范围

原型阶段计划优先实现以下三种作物：

| 作物名称 | 英文名称 | 主要研究方向 |
| --- | --- | --- |
| 营养果 | Nutrition Fruit | 基础种植与资源管理 |
| 咖啡豆 | Coffee Beans | 生长与收获机制 |
| 韧棉 | Kotton | 较长生长周期与资源消耗 |

后续将根据开发时间和系统复杂度决定是否扩展更多作物。

## 5. 技术栈

| 技术 | 用途 |
| --- | --- |
| Godot 4 | 游戏引擎 |
| GDScript | 游戏逻辑开发 |
| Git | 版本控制 |
| GitHub | 代码托管与开发记录 |
| Markdown | 项目文档 |

**开发环境：** Windows

**目标平台：** PC

**游戏类型：** 2D 模拟 / 资源管理

## 6. 项目结构

```text
hydroponics-management-simulator/
│
├── docs/                 # 项目文档
│   ├── GDD.md            # 游戏设计文档
│   ├── RESEARCH_NOTES.md # 参考游戏研究记录
│   ├── FORMULAS.md       # 核心机制与计算公式
│   ├── TECHNICAL_DESIGN.md
│   ├── DEVELOPMENT_LOG.md
│   ├── TESTING_REPORT.md
│   └── GLOSSARY.md       # 中英文术语表
│
├── scenes/               # 游戏场景
├── scripts/              # 游戏逻辑代码
├── resources/            # 作物、种子及设备数据
├── assets/               # 图片、字体及其他资源
├── ui/                   # 用户界面组件
├── tests/                # 测试代码
├── screenshots/          # 开发过程截图与演示证据
│
├── project.godot
├── README.md
└── .gitignore
```

### 运行自动化测试（Windows）

在项目根目录中运行以下命令，并将 `<Godot executable path>` 替换为 Godot 4.7.2 可执行文件的路径。第一次运行或移动测试文件后，使用 `-Import` 刷新 Godot 缓存。

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\tests\run-tests.ps1 -GodotPath "<Godot executable path>" -Import
```

## 7. 开发计划

M01 基础稳定化已完成。五组自动化测试共通过 453 项显式检查及原有四组作物断言。默认启动和生菜单夜结算基线已验证，用户报告最终桌面冒烟测试通过。下一里程碑将实现首个可玩作物的完整生产循环。 [M01 验收报告](docs/M01_FINAL_REPORT.md)

项目采用分阶段开发方式，优先保证核心模拟机制的正确性，再逐步完善界面和扩展功能。

- [x] 创建 Godot 项目
- [x] 初始化 Git 与 GitHub 仓库
- [x] 建立项目文档结构
- [ ] 完成核心机制研究与公式整理
- [x] 搭建主游戏场景
- [x] 实现基础资源管理
- [ ] 实现作物生长与矿物质消耗
- [ ] 实现健康度与污染损伤
- [ ] 实现种子特性与设备模块
- [ ] 实现收获系统
- [ ] 完成测试与问题修复
- [ ] 完成可运行原型与演示

## 8. 研究与参考资料

本项目的机制研究参考以下资料：

1. 《深空当铺》水培农业 Wiki  
   <https://wiki.biligame.com/probablystolen/%E6%B0%B4%E5%9F%B9%E5%86%9C%E4%B8%9A>

2. GameWith.ai — Hydroponic Farmer Guide  
   <https://gamewith.ai/probably-stolen/zh-hans/specializations/hydroponic-farmer>

参考资料用于理解和分析原游戏机制。具体实现将结合本项目的设计目标进行独立开发。

## 9. 版权与项目说明

本项目为独立开发的学习与技术展示原型。

《深空当铺》（Probably Stolen）及其相关游戏内容归原版权方所有。本项目不代表原游戏官方产品，也不声称拥有原游戏的设计或素材版权。

项目中的研究资料、原创代码、设计决策和测试记录将通过文档及 Git 版本历史进行记录。

---

# English

## 1. Project Overview

Hydroponics Management Simulator is a 2D resource management and simulation game prototype developed using **Godot 4** and **GDScript**.

The project focuses on researching and implementing hydroponic farming mechanics, including crop growth, mineral consumption, pollution damage, genetic traits, and resource management.

It is inspired by the hydroponics system in *Probably Stolen (深空当铺)*. The project independently analyzes these mechanics and develops a playable prototype based on its own system design.

The goal is not only to build a playable simulation but also to demonstrate game mechanics analysis, mathematical modeling, software engineering, and testing skills.

## 2. Project Objectives

- Analyze the hydroponics mechanics of the reference game.
- Develop mathematical models for crop growth and resource consumption.
- Implement water, mineral, and electricity management.
- Design crop health and pollution damage calculations.
- Introduce different crops and seed traits.
- Build an interactive hydroponics management interface.
- Validate core calculations through testing.

## 3. Core Features

The following features are planned for implementation. Their completion status will be updated throughout development.

| Feature | Description |
| --- | --- |
| Crop Management | Select, cultivate, and harvest different crops |
| Water Management | Manage pure water storage and consumption |
| Mineral System | Calculate mineral concentration and consumption |
| Growth System | Simulate crop growth progress |
| Health System | Calculate crop health based on environmental conditions |
| Pollution System | Simulate the effects of pollutants on crops |
| Genetics System | Apply seed traits to crop behavior |
| Equipment System | Manage machine performance, efficiency, and quality |
| Harvest System | Calculate harvest results based on crop conditions |

## 4. Initial Crop Selection

The initial prototype will prioritize three crops:

| Crop | Primary Research Focus |
| --- | --- |
| Nutrition Fruit | Basic cultivation and resource management |
| Coffee Beans | Growth and harvesting mechanics |
| Kotton | Longer growth cycles and resource consumption |

Additional crops may be introduced depending on development time and system complexity.

## 5. Technology Stack

| Technology | Purpose |
| --- | --- |
| Godot 4 | Game Engine |
| GDScript | Gameplay Programming |
| Git | Version Control |
| GitHub | Source Code Hosting and Development History |
| Markdown | Project Documentation |

**Development Environment:** Windows

**Target Platform:** PC

**Genre:** 2D Simulation / Resource Management

## 6. Project Structure

```text
hydroponics-management-simulator/
│
├── docs/                 # Project documentation
├── scenes/               # Game scenes
├── scripts/              # Gameplay scripts
├── resources/            # Crop, seed, and equipment data
├── assets/               # Visual and audio assets
├── ui/                   # User interface components
├── tests/                # Test scripts
├── screenshots/          # Development screenshots and evidence
│
├── project.godot
├── README.md
└── .gitignore
```

### Play the three-crop farming loop

Open `project.godot` in Godot 4.7 and press **F5** to launch the current farming dashboard. The advanced farming milestone adds solution analysis and pollution, inherited seed traits, machine and module management, and nightly DNA trait applications. [M07 checkpoint and scope](docs/M07_FINAL_REPORT.md)

The core farming checkpoint covers M02 research reconciliation, the M03 liquid and Coffee Beans loop, and the M04 three-crop dashboard. [Milestone evidence and open work](docs/M04_FINAL_REPORT.md)

Run the project with **F5**. Select Nutrition Fruit, Coffee Beans, or Kotton, plant a seed, start the machine, and use **Next Night** until the harvest is ready. Healthy cycles take two, three, and six running nights respectively. The initial 3% solution is suitable for Coffee Beans and Kotton. For Nutrition Fruit on a fresh run, confirm **Drain solution**, add water ten times, and add four tablets to reach 5,000 mL pure water and 60 mL minerals. Draining discards the solution. Refills use finite supplies.

Collect the harvest before switching crops. Coffee Beans can be replanted directly. **Demo seed** adds one seed of the selected crop as a project testing aid. If collection exceeds capacity, select stored items and confirm **Discard one** until enough room is available. For the legacy Lettuce fixture, open `scenes/main.tscn` and press **F6**. [M04 verification and manual walkthrough](docs/M04_REPORT.md)

### Run the automated tests on Windows

From the repository root, replace `<Godot executable path>` with the path to the Godot 4.7.2 executable.

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\tests\run-tests.ps1 -GodotPath "<Godot executable path>" -Import
```

The runner checks all thirteen suites for completion markers, exit codes, and unexpected errors. It prints a summary and the temporary log directory. Use `-Import` on the first run or after moving project files. A missing Godot cache also triggers an import automatically. The execution policy applies to that PowerShell process. [Current testing evidence](docs/M07_FINAL_REPORT.md)

Open **DNA edit** from **Genes** to preview a trait application for an available seed. Confirm the application, close the dialog and settle nights to advance it. Applications use shared power and finite project demo disc charges. Reopen the dialog to inspect progress or the result.

Open **Gear** while the machine is stopped to inspect demo equipment, switch machines and vessels, or install and remove modules. Running-night growth and power costs update with the configuration. The default machine and vessel remain available.

Open **Genes** to inspect the selected seed or the planted crop. Use **Next seed** to cycle the selected crop’s stock. **Demo Coffee** supplies a validated modified seed when Coffee Beans is selected and inventory has room. For Nutrition Fruit and Kotton, the Genes dialog shows pending offspring at maturity. **Collect** transfers the harvest and offspring together when inventory has room.

Open **Analysis** on the farming dashboard to inspect raw pollutant indices, crop exposures and predicted nightly damage. Choose a demonstration solution and confirm replacement to try clean, single-pollutant, mixed, physical-only or high-pollution scenarios. Replacing a solution discards the current mixture. The demo uses its own supply.

## 7. Development Roadmap

M01 foundation stabilization is complete. The five automated suites passed 453 explicit checks and the four original crop assertion groups. Default launch and the one-night Lettuce baseline passed, and the user reported a successful final desktop smoke check. The next milestone is a complete production loop for the first playable crop. [M01 acceptance report](docs/M01_FINAL_REPORT.md)

Development follows an incremental approach, prioritizing the correctness of core simulation mechanics before expanding the interface and additional features.

- [x] Create Godot project
- [x] Initialize Git and GitHub repository
- [x] Establish documentation structure
- [ ] Complete mechanics research and formula documentation
- [x] Build the main game scene
- [x] Implement basic resource management
- [ ] Implement crop growth and mineral consumption
- [ ] Implement health and pollution damage
- [ ] Implement seed traits and equipment modules
- [ ] Implement harvesting mechanics
- [ ] Complete testing and bug fixing
- [ ] Deliver a playable prototype and demonstration

## 8. Research References

The project uses the following references for mechanics research:

1. *Probably Stolen* — Hydroponics Wiki  
   <https://wiki.biligame.com/probablystolen/%E6%B0%B4%E5%9F%B9%E5%86%9C%E4%B8%9A>

2. GameWith.ai — Hydroponic Farmer Guide  
   <https://gamewith.ai/probably-stolen/zh-hans/specializations/hydroponic-farmer>

These resources are used to understand and analyze the reference game's mechanics. Implementation decisions are made independently according to this project's design goals.

## 9. Copyright and Project Disclaimer

This is an independently developed prototype for learning and technical demonstration purposes.

*Probably Stolen (深空当铺)* and its associated game content belong to their respective copyright holders. This project is not an official product and does not claim ownership of the original game's designs or assets.

Research materials, original code, design decisions, and testing records will be documented through project documentation and Git version history.

---

**Project Status:** In Development  
**Engine:** Godot 4  
**Language:** GDScript  
**Repository:** GitHub
