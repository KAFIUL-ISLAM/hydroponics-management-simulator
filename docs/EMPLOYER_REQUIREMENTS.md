# Employer assessment requirements

Source: Original Chinese instructions supplied by the project owner on 2026-11-26. The source text below is preserved verbatim.

## Original Chinese instructions

> 题目就是希望您做一个水培系统或者化学制药系统的demo
>
> 不需要一比一还原，但是需要您自己拆分这个玩法所需要考虑到的一些游戏设计以及数值设计，当然一比一复刻也没问题
>
> 用unity或者godot都行，时限是十天
>
> 要求就是尽可能的复现深空当铺中该玩法系统，这需要您自己去拆解该玩法的设计以及数值
>
> 这会比较贴近于入职之后独立游戏开发工作的实际情况
>
> 您不仅仅是要编写代码，还要对游戏玩法有自己的理解，以及对抽象任务需求进行实现的能力

## English translation

1. The assignment is to make a demo of either a hydroponics system or a chemical pharmaceutical production system.
2. An exact one-to-one recreation is optional. You are expected to break down for yourself the gameplay design and numerical design considerations involved in the chosen mechanic.
3. Either Unity or Godot is acceptable. The time limit is ten days.
4. The aim is to reproduce the chosen gameplay system from *Probably Stolen* (深空当铺) as closely as you can. You will need to analyze its design and numerical behavior yourself.
5. This is intended to resemble the work of developing an indie game after joining the team.
6. In addition to writing code, you are expected to develop your own understanding of the gameplay and show that you can turn abstract task requirements into a working implementation.

## Reconciliation with v0.3.0

| Explicit instruction | Evidence and assessment |
| --- | --- |
| Demo one of the two systems | The owner chose hydroponics. The Godot dashboard supports selecting, cultivating, harvesting and replanting crops. Pollution, inheritance, equipment and trait application extend that playable loop. Prior desktop walkthroughs cover these systems. [Milestone evidence](M07_FINAL_REPORT.md) |
| Use Unity or Godot | The owner chose Godot. The baseline loads in Godot 4.7.2. [Project configuration](../project.godot) · [Fresh audit](PRE_M08_AUDIT.md#performance-and-regression) |
| Independently decompose gameplay and numbers | The project records gameplay rules, numerical contracts, source provenance, provisional decisions and deterministic fixtures. A concise Chinese analysis would make that work easier for the evaluator to follow. [GDD](GDD.md) · [Research notes](RESEARCH_NOTES.md) · [Calculation contract](CALCULATION_CONTRACT.md) |
| Reproduce the chosen system as closely as practical | The supported implementation has published reference-derived fixtures and documented local policies. The audit confirmed 13 suites, 932 explicit checks and four original assertion groups. This supports the documented slice. Broader fidelity is outside the claim. [Traceability](REQUIREMENTS_TRACEABILITY_MATRIX.md) |
| Show gameplay understanding and implementation of an abstract task | The player can manage resource constraints, inspect outcomes and compare equipment or seed configurations. The design analysis can connect those decisions to observable results and tests. This is evidence of the process. Employer judgment is pending. |
| Ten-day limit | Explicit. The owner’s delivery target is December 1, 2026. The original message supplies a duration without an exact start or cutoff timestamp, so delivery timing remains for the owner to confirm. |

The [internal GDD and traceability matrix](REQUIREMENTS_TRACEABILITY_MATRIX.md) define project priorities. The employer wording supplies no scoring rubric, mandatory feature-by-feature checklist, target OS, export requirement, recording requirement or delivery channel. Clarity, usability and professional presentation are proposed ways to demonstrate the work. They carry no stated employer scoring weight.

## Submission readiness and technical freeze

No current simulation omission is established as a submission blocker by the supplied wording. Submission logistics remain open: confirm the exact cutoff and channel, the artifact the evaluator should receive, and their target environment. The chosen artifact must launch from a clean copy. An executable export is a conditional verification task if selected for delivery. The current editor launch and regression evidence do not verify an export. A recording and a Chinese write-up are recommended evidence rather than explicit deliverables.

Technical scope is frozen at **v0.3.0**, commit **74a3e440f81ba440219ca86ec052e61937c5f5c5**. Perennials, warehouse overflow, persistent seed identifiers, wider DNA editing, module geometry, full quality mapping, textile grading, economic systems and other open technical work remain deferred. The brief’s fidelity request makes it worthwhile to disclose material differences, such as provisional pollution rounding and demo supplies. It provides no basis for requiring those deferred systems before delivery. Historical milestone records remain in place.

## Presenting the existing game

Lead with one clean Coffee Beans cycle from crop selection to replanting. Show the selected seed, start control, remaining growth, projected full-night cost and the settlement result together. Use a simple comparison, such as the same raw pollutant index producing different crop damage or the same crop advancing at a different speed with a module, to explain why a player would change the setup. Show inheritance, equipment and DNA editing as short optional demonstrations. Clearly label demo supplies and scenarios. Each example should link one player decision to its numerical effect and visible outcome.

## 中文玩法拆解与设计分析提纲

1. **选题与范围**。解释选择水培与 Godot 的原因，列出 v0.3.0 支持的内容和暂缓范围。
2. **核心循环与玩家决策**。说明选种、播种、启动、夜间结算、收获和留种。用咖啡豆的一轮种植说明资源不足后如何恢复。
3. **数值模型和结算顺序**。列出生长点数、耗电、混合液消耗、矿物吸收和健康损伤的单位、计算顺序及取整规则。给出三种作物的基准结果和测试出处。
4. **系统联动与策略**。解释矿物浓度区间、污染敏感度、设备取舍、种子性状、遗传和热度如何影响决策。挑选一组污染对比和一组设备对比即可。
5. **取舍与证据**。区分参考资料、项目约定、尚未核实的边界和演示设置。说明为何保留这些取舍，以及用哪些自动化检查和人工流程验证。
6. **演示路线与操作入口**。给出启动方式、核心循环和可选进阶演示。图片、视频和导出包按确认后的交付方式准备。

M08 remains unauthorized. This reconciliation prepares documentation and demonstration planning only.
