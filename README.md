# 轨道水培实验室 | Orbital Hydroponics

**基于 Godot 4 开发的水培农业管理模拟项目**

**v0.4.0 · M08 视觉改造。** 支持 1280 × 720 和 1920 × 1080。使用 Godot 4.7.2 打开 `project.godot`，按 **F5** 启动。 [里程碑报告](docs/M08_FINAL_REPORT.md)

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

当前演示可种植营养果、咖啡豆和韧棉。实验室热点、可视库存和专用工作台连接到现有的水培模拟。

| 功能模块 | 功能说明 |
| --- | --- |
| 作物管理 | 选择、种植和收获不同作物 |
| 水资源管理 | 管理纯水储量及消耗 |
| 矿物质系统 | 计算矿物质浓度与消耗 |
| 生长系统 | 模拟作物生长进度 |
| 健康度系统 | 根据环境条件计算作物健康状态 |
| 污染系统 | 模拟污染物对作物的影响 |
| 遗传系统 | 通过种子特性影响作物表现 |
| 设备系统 | 更换设备及容器，安装已支持的模组并查看生长速度、耗电和修正值 |
| 收获系统 | 根据作物状态计算收获结果 |
| DNA 编辑 | 预览兼容性状、确认应用并通过夜间结算推进 |

![1280 × 720 实验室演示](screenshots/m08c-environment-1280.png)

[1920 × 1080 实验室](screenshots/m08c-environment-1920.png) · [液体分析](screenshots/m08d-liquid-1280.png) · [DNA 工作台](screenshots/m08d-dna-1280.png) · [素材来源](docs/ASSET_MANIFEST.md)

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

M01–M07 实现了可玩的三作物种植循环和进阶系统。M08 已完成视觉改造，17 组自动化测试通过 1,142 项显式检查及四组原始断言。M09 尚未开始。 [验收与剩余范围](docs/M08_FINAL_REPORT.md)

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

The playable build includes three crops, state-driven artwork, a visual inventory, laboratory hotspots and specialized workstations.

| Feature | Description |
| --- | --- |
| Crop Management | Select, cultivate, and harvest different crops |
| Water Management | Manage pure water storage and consumption |
| Mineral System | Calculate mineral concentration and consumption |
| Growth System | Simulate crop growth progress |
| Health System | Calculate crop health based on environmental conditions |
| Pollution System | Simulate the effects of pollutants on crops |
| Genetics System | Apply seed traits to crop behavior |
| Equipment System | Switch machines and vessels, install supported modules and inspect speed, power and modifiers |
| Harvest System | Calculate harvest results based on crop conditions |
| DNA Editor | Preview and apply supported traits through nightly settlement |

## 4. Initial Crop Selection

The initial prototype will prioritize three crops:

| Crop | Primary Research Focus |
| --- | --- |
| Nutrition Fruit | Basic cultivation and resource management |
| Coffee Beans | Growth and harvesting mechanics |
| Kotton | Longer growth cycles and resource consumption |

The current simulation scope is frozen to these three crops. The legacy Lettuce scene remains available as a separate test fixture.

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
├── tests/                # Test scripts
├── screenshots/          # Development screenshots and evidence
│
├── project.godot
├── README.md
└── .gitignore
```

### Play the three-crop farming loop

Open `project.godot` in **Godot 4.7.2** and press **F5** to launch Orbital Hydroponics. The v0.4.0 build supports **1280 × 720** and **1920 × 1080**. Use the workstation buttons or chamber hotspots to inspect cultivation, liquid and equipment. Select individual seeds or stored products from the inventory strip. [M08 release notes](docs/M08_FINAL_REPORT.md) · [Laboratory at 1920 × 1080](screenshots/m08c-environment-1920.png) · [Gear](screenshots/m08d-equipment-1280.png) · [DNA](screenshots/m08d-dna-1920.png)

Run the project with **F5**. Select Nutrition Fruit, Coffee Beans, or Kotton, plant a seed, start the machine, and use **Next Night** until the harvest is ready. Healthy cycles take two, three, and six running nights respectively. The initial 3% solution is suitable for Coffee Beans and Kotton. For Nutrition Fruit on a fresh run, confirm **Drain solution**, add water ten times, and add four tablets to reach 5,000 mL pure water and 60 mL minerals. Draining discards the solution. Refills use finite supplies.

Collect the harvest before switching crops. Coffee Beans can be replanted directly. **Demo seed** adds one seed of the selected crop as a project testing aid. If collection exceeds capacity, select stored items and confirm **Discard one** until enough room is available. For the legacy Lettuce fixture, open `scenes/main.tscn` and press **F6**. [M04 verification and manual walkthrough](docs/M04_REPORT.md)

### Run the automated tests on Windows

From the repository root, replace `<Godot executable path>` with the path to the Godot 4.7.2 executable.

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\tests\run-tests.ps1 -GodotPath "<Godot executable path>" -Import
```

The runner checks all 17 suites for completion markers, exit codes and unexpected errors. Use `-Import` on the first run or after moving project files. A missing Godot cache triggers import automatically. [Current testing evidence](docs/M08_FINAL_REPORT.md#verification)

Open **DNA edit** from **Genes** to preview a trait application for an available seed. Confirm the application, close the dialog and settle nights to advance it. Applications use shared power and finite project demo disc charges. Reopen the dialog to inspect progress or the result.

Open **Gear** while the machine is stopped to inspect demo equipment, switch machines and vessels, or install and remove modules. Running-night growth and power costs update with the configuration. The default machine and vessel remain available.

Open **Genes** to inspect the selected seed or the planted crop. Use **Next seed** to cycle the selected crop’s stock. **Demo Coffee** supplies a validated modified seed when Coffee Beans is selected and inventory has room. For Nutrition Fruit and Kotton, the Genes dialog shows pending offspring at maturity. **Collect** transfers the harvest and offspring together when inventory has room.

Open **Liquid** or click the tank to inspect raw pollutant indices, crop exposure, predicted damage and actual prior-night damage. The demo section offers clean, single-pollutant, mixed, physical-only and high-pollution solutions. Confirming replacement discards the current mixture and uses the separate demo supply.

## 7. Development Roadmap

M01–M07 delivered the three-crop farming loop and advanced mechanics. M08 completed the visual transformation in v0.4.0. M09 remains pending. [Current project status](docs/PROJECT_STATUS.md) · [Visual plan](docs/VISUAL_DEVELOPMENT_PLAN.md)

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
