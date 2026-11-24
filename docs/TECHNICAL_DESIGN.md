## 1. 主界面技术设计 | Main Interface Architecture

### 1.1 技术环境

| 项目 | 配置 |
| --- | --- |
| 游戏引擎 | Godot 4.7.2 |
| 编程语言 | GDScript（后续实现） |
| 场景文件 | scenes/main.tscn |
| 根节点 | Control |
| 目标分辨率 | 1280 × 720 |
| UI 架构 | Godot Native Control Nodes |

### 1.2 场景节点结构

```text
Main (Control)
├── Background (ColorRect)
└── SafeArea (MarginContainer)
    └── MainLayout (VBoxContainer)
        ├── Header (PanelContainer)
        │   └── HeaderContent (HBoxContainer)
        │       ├── TitleGroup (VBoxContainer)
        │       │   ├── GameTitle (Label)
        │       │   └── GameSubtitle (Label)
        │       ├── HeaderSpacer (Control)
        │       └── HeaderInfo (VBoxContainer)
        │           ├── DayLabel (Label)
        │           └── StatusLabel (Label)
        ├── ResourceRow (HBoxContainer)
        │   ├── WaterCard (PanelContainer)
        │   ├── MineralCard (PanelContainer)
        │   └── PowerCard (PanelContainer)
        ├── MainPanels (HBoxContainer)
        │   ├── MachinePanel (PanelContainer)
        │   └── CropPanel (PanelContainer)
        ├── ControlBar (PanelContainer)
        └── FooterLabel (Label)
```

### 1.3 UI 布局设计

采用容器驱动的布局方式，避免依赖固定坐标进行 UI 定位。

主要容器职责：

- MarginContainer：管理界面边距。
- VBoxContainer：管理垂直排列的主要界面区域。
- HBoxContainer：管理水平排列的组件。
- GridContainer：管理网格形式的数据展示。
- PanelContainer：提供统一的面板背景和样式。

### 1.4 视觉设计规范

| 属性 | 配置 |
| --- | --- |
| 背景色 | #101923 |
| 面板色 | #1B2A38 |
| 主文字色 | #EAF2F8 |
| 次要文字色 | #8FA4B5 |
| 强调色 | #65D6A0 |
| 水资源颜色 | #55B9EE |
| 电力颜色 | #E8C66B |

整体采用工业科技风格，强调资源状态的可读性。

### 1.5 当前模块职责

**Header**
显示游戏名称、当前日期和系统运行状态。

**ResourceRow**
展示纯水、矿物质和电力储备。

**MachinePanel**
展示水培设备及其性能、效率和品质属性。

**CropPanel**
展示当前种植作物、生长状态和健康状态。

**ControlBar**
提供资源管理、设备配置和夜间结算入口。

### 1.6 当前架构限制

当前场景主要负责 UI 展示，尚未建立独立的游戏数据层和模拟逻辑层。

后续计划：

1. 建立 ResourceManager。
2. 建立 GameState。
3. 建立 CropData 数据结构。
4. 建立 HydroponicsSimulator。
5. 通过信号机制更新 UI。
6. 将游戏计算与界面展示分离。

### 1.7 验证结果

- 场景成功运行。
- 主要 UI 组件正常显示。
- 已完成目标分辨率下的运行验证。
- 已观察窗口尺寸调整时的布局适应情况。

状态：首版 UI 原型完成。
