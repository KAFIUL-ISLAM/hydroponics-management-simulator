extends "res://scripts/main.gd"

const Farm = preload("res://scripts/coffee_farm.gd")
const LIQ = preload("res://scripts/liquid_composition.gd")
const Pollution = preload("res://scripts/pollution_analysis.gd")
const Genetics = preload("res://scripts/crop_genetics.gd")
const Equipment = preload("res://scripts/hydroponic_equipment.gd")
const DNA = preload("res://scripts/dna_editor.gd")
const POLLUTANT_NAMES := ["重金属 / Heavy metals", "化学污染物 / Chemicals", "微生物 / Microbes",
	"有机废物 / Organic waste", "酸 / Acid", "碱 / Alkali"]

@onready var farm: Farm = $CoffeeFarm
var actions: Dictionary[String, Button] = {}
var supplies: Label
var crop_menu: OptionButton
var stored_items: OptionButton
var confirm_action: ConfirmationDialog
var pending_action: Callable
var liquid_dialog: AcceptDialog
var scenario_menu: OptionButton
var analysis_text: Label
var last_night: Farm.FarmOutcome
var genetics_dialog: AcceptDialog
var next_seed_button: Button
var demo_genes_button: Button
var equipment_dialog: AcceptDialog
var equipment_readout: Label
var machine_choice: OptionButton
var vessel_choice: OptionButton
var module_choice: OptionButton
var dna_dialog: AcceptDialog
var dna_seed: OptionButton
var dna_trait: OptionButton
var dna_readout: Label
var dna_start: Button

func _enter_tree() -> void:
	$GameState.starting_crop = null
	$HydroponicsSimulator.game_state = null

func _ready() -> void:
	farm.state = game_state
	game_state._register_night_simulation(farm.settle)
	game_state.day_changed.connect(_on_day_changed)
	game_state.status_changed.connect(_on_status_changed)
	game_state.night_processing_finished.connect(_on_coffee_finished)
	_on_day_changed(game_state.current_day)
	_on_status_changed(game_state.status)
	_build_actions()
	_render()
	control_hint.text = "播种后启动机器 / Plant a seed and start the machine"

func _build_actions() -> void:
	var machine := $SafeArea/MainLayout/MainPanels/MachinePanel/MachineContent
	machine.add_theme_constant_override("separation", 4)
	machine.get_node("MachineStats").hide()
	var bar := next_night_button.get_parent()
	bar.get_node("ManageButton").hide()
	bar.get_node("EquipmentButton").hide()
	supplies = Label.new()
	supplies.add_theme_font_size_override("font_size", 13)
	var supply_row := HBoxContainer.new()
	machine.add_child(supply_row)
	supplies.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	supply_row.add_child(supplies)
	var analysis := Button.new()
	analysis.add_theme_font_size_override("font_size", 13)
	supply_row.add_child(analysis)
	actions["analysis"] = analysis
	analysis.pressed.connect(_show_analysis)
	var equipment_button := Button.new()
	equipment_button.text = "设备 / Gear"
	equipment_button.add_theme_font_size_override("font_size", 13)
	supply_row.add_child(equipment_button)
	actions["equipment"] = equipment_button
	equipment_button.pressed.connect(func() -> void:
		_refresh_equipment()
		equipment_dialog.popup_centered()
	)
	crop_menu = OptionButton.new()
	crop_menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for definition in farm.catalog:
		crop_menu.add_item("%s / %s" % [definition.name_zh, definition.name_en] if definition != null else "无效 / Invalid")
	var crop_row := HBoxContainer.new()
	machine.add_child(crop_row)
	crop_row.add_child(crop_menu)
	var genes := Button.new()
	genes.text = "基因 / Genes"
	genes.add_theme_font_size_override("font_size", 13)
	crop_row.add_child(genes)
	actions["genetics"] = genes
	genes.pressed.connect(_show_genetics)
	genetics_dialog = AcceptDialog.new()
	genetics_dialog.title = "种子分析 / Seed analysis"
	add_child(genetics_dialog)
	next_seed_button = genetics_dialog.add_button("下一个种子 / Next seed", true)
	next_seed_button.pressed.connect(_next_seed)
	demo_genes_button = genetics_dialog.add_button("演示 / Demo Coffee", false)
	demo_genes_button.pressed.connect(func() -> void:
		if farm.supply_modified_coffee():
			_render()
			_show_genetics()
	)
	crop_menu.item_selected.connect(func(index: int) -> void:
		farm.select_species(index)
		_render()
	)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("v_separation", 2)
	grid.add_theme_font_size_override("font_size", 13)
	machine.add_child(grid)
	_action(grid, "plant", "播种 / Plant", farm.plant_bean)
	_action(grid, "run", "启动 / Start", farm.toggle_running)
	_action(grid, "water", "加水 / Add water", farm.add_water)
	_action(grid, "tablet", "加营养片 / Add tablet", farm.add_tablet)
	_action(grid, "energy", "充电 / Add energy", farm.add_energy)
	_action(grid, "harvest", "收获 / Collect", farm.collect)
	_action(grid, "seed_supply", "演示补种 / Demo seed", farm.supply_demo_seed)
	_action(grid, "drain", "排液 / Drain solution", _confirm_drain)
	var inventory_row := HBoxContainer.new()
	machine.add_child(inventory_row)
	stored_items = OptionButton.new()
	stored_items.fit_to_longest_item = false
	stored_items.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_row.add_child(stored_items)
	var discard := Button.new()
	discard.text = "丢弃一件 / Discard one"
	inventory_row.add_child(discard)
	actions["discard"] = discard
	discard.pressed.connect(_confirm_discard)
	confirm_action = ConfirmationDialog.new()
	add_child(confirm_action)
	confirm_action.canceled.connect(func() -> void: pending_action = Callable())
	confirm_action.confirmed.connect(func() -> void:
		var command := pending_action
		pending_action = Callable()
		if not command.is_valid():
			return
		var accepted: bool = command.call()
		_render()
		control_hint.text = "操作完成 / Action complete" if accepted else "操作被拒绝 / Action rejected"
	)
	_build_analysis()
	_build_equipment()
	_build_dna()

func _build_dna() -> void:
	var open := genetics_dialog.add_button("DNA 编辑 / DNA edit", true)
	open.pressed.connect(_open_dna)
	actions["dna"] = open
	dna_dialog = AcceptDialog.new()
	dna_dialog.title = "DNA 编辑器 / DNA editor"
	add_child(dna_dialog)
	var content := VBoxContainer.new()
	dna_dialog.add_child(content)
	dna_seed = OptionButton.new()
	content.add_child(dna_seed)
	dna_trait = OptionButton.new()
	content.add_child(dna_trait)
	for id: String in DNA.SUPPORTED:
		var entry := Genetics.definition(id)
		dna_trait.add_item("%s / %s" % [entry.name_zh, id])
	dna_seed.item_selected.connect(func(_index: int) -> void: _refresh_dna())
	dna_trait.item_selected.connect(func(_index: int) -> void: _refresh_dna())
	dna_readout = Label.new()
	content.add_child(dna_readout)
	dna_start = Button.new()
	dna_start.text = "确认应用 / Confirm application"
	content.add_child(dna_start)
	dna_start.pressed.connect(func() -> void:
		if dna_seed.selected >= 0:
			farm.begin_edit(dna_seed.get_selected_metadata(), DNA.SUPPORTED[dna_trait.selected])
			_render()
			_refresh_dna()
	)

func _open_dna() -> void:
	genetics_dialog.hide()
	dna_seed.clear()
	var chosen := farm.selected_seed()
	for definition: ReferenceCrop in farm.catalog:
		for item: Farm.Seed in farm.seed_stock(definition):
			dna_seed.add_item("%s / %s · #%d" % [definition.name_zh, definition.name_en, item.get_instance_id()])
			dna_seed.set_item_metadata(dna_seed.item_count - 1, item)
			if item == chosen:
				dna_seed.select(dna_seed.item_count - 1)
	_refresh_dna()
	dna_dialog.popup_centered()

func _refresh_dna() -> void:
	var editor := farm.dna_editor
	dna_start.disabled = true
	dna_seed.disabled = editor.stage == DNA.Stage.RUNNING
	dna_trait.disabled = dna_seed.disabled
	dna_readout.text = "演示数据盘 / Demo trait discs · 提取未开放 / Extraction unavailable\n"
	if editor.stage != DNA.Stage.IDLE:
		var state_text := "进行中或缺电暂停 / Running or waiting for energy"
		if editor.stage == DNA.Stage.SUCCEEDED:
			state_text = "成功 / Succeeded"
		elif editor.stage == DNA.Stage.FAILED:
			state_text = "失败，保留数据盘 / Failed, disc retained"
		dna_readout.text += "#%d · %s · %d/%d · %s\n" % [editor.operation.target_id, editor.operation.trait_id,
			editor.progress, editor.operation.required_points, state_text]
		if editor.stage == DNA.Stage.RUNNING:
			dna_readout.text += "关闭窗口并结算下一晚 / Close the dialog and settle the next night"
			return
		var final_traits: Dictionary[String, int] = editor.operation.after.traits if editor.stage == DNA.Stage.SUCCEEDED else editor.operation.before.traits
		dna_readout.text += "结果 / Result: 等级 / Rank %d · 热度 / Heat %d\n" % [
			final_traits.get(editor.operation.trait_id, 0), editor.operation.after.heat]
	if dna_seed.selected < 0:
		dna_readout.text += "无可用种子 / No available seed"
		return
	var id: String = DNA.SUPPORTED[dna_trait.selected]
	var item: Farm.Seed = dna_seed.get_selected_metadata()
	var plan := farm.preview_edit(item, id)
	var names := PackedStringArray()
	for trait_id: String in item.traits:
		var entry := Genetics.definition(trait_id)
		names.append("%s %d" % [trait_id if entry == null else entry.name_zh + " / " + trait_id, item.traits[trait_id]])
	dna_readout.text += "当前特性 / Current traits\n"
	for index: int in range(0, names.size(), 3):
		dna_readout.text += ", ".join(names.slice(index, index + 3)) + "\n"
	if not plan.valid():
		dna_readout.text += plan.error
		return
	dna_start.disabled = false
	dna_readout.text += "等级 / Rank: %d → %d · 可用次数 / Disc uses: %d\n" % [
		plan.before.traits.get(id, 0), plan.after.traits[id], farm.disc_uses[id]]
	dna_readout.text += "复杂度 / Complexity: %d → %d · 热度 / Heat: %d → %d\n" % [
		plan.before.complexity, plan.after.complexity, plan.before.heat, plan.after.heat]
	dna_readout.text += "目标 / Target: %d → %d · 产量 / Yield: %d → %d\n" % [
		plan.before.crop.target, plan.after.crop.target, plan.before.crop.healthy_output, plan.after.crop.healthy_output]
	dna_readout.text += "耗液 / Draw: %d → %d µL · 敏感度 / Sensitivity: %.3f → %.3f\n" % [
		plan.before.crop.draw_ul, plan.after.crop.draw_ul, plan.before.crop.native_pollution_sensitivity, plan.after.crop.native_pollution_sensitivity]
	dna_readout.text += "成功率 / Chance: %d%% · %d 夜 / nights · %d kJ (%d/night)" % [
		plan.success_pct, plan.nights, plan.total_energy_kj, DNA.ENERGY_PER_NIGHT_KJ]

func _build_equipment() -> void:
	equipment_dialog = AcceptDialog.new()
	equipment_dialog.title = "设备管理 / Equipment"
	add_child(equipment_dialog)
	var content := VBoxContainer.new()
	equipment_dialog.add_child(content)
	equipment_readout = Label.new()
	content.add_child(equipment_readout)
	machine_choice = OptionButton.new()
	for id: int in farm.demo_machines:
		var entry := Equipment.machine_definition(id)
		if entry != null and machine_choice.get_item_index(id) == -1:
			machine_choice.add_item(entry.label, id)
	_equipment_row(content, machine_choice, "换设备 / Switch machine", "switch_machine", func() -> bool:
		return farm.select_machine(machine_choice.get_selected_id()))
	vessel_choice = OptionButton.new()
	vessel_choice.add_item("演示容器 / Demo vessel", Equipment.Vessel.DEMO)
	vessel_choice.add_item("水罐 / 3 L water can", Equipment.Vessel.CAN)
	_equipment_row(content, vessel_choice, "换容器 / Switch vessel", "switch_vessel", func() -> bool:
		return farm.select_vessel(vessel_choice.get_selected_id()))
	module_choice = OptionButton.new()
	var module_row := _equipment_row(content, module_choice, "安装 / Install", "install_module", func() -> bool:
		return farm.install_module(module_choice.get_selected_id()))
	_equipment_control(module_row, "移除 / Remove", "remove_module", func() -> bool:
		return farm.remove_module(module_choice.get_selected_id()))
	module_choice.item_selected.connect(func(_index: int) -> void: _refresh_equipment())

func _equipment_row(parent: VBoxContainer, choice: OptionButton, label: String, key: String, operation: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	parent.add_child(row)
	choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(choice)
	_equipment_control(row, label, key, operation)
	return row

func _equipment_control(row: HBoxContainer, label: String, key: String, operation: Callable) -> void:
	var button := Button.new()
	button.text = label
	row.add_child(button)
	actions[key] = button
	button.pressed.connect(func() -> void:
		operation.call()
		_render()
		_refresh_equipment()
	)

func _refresh_equipment() -> void:
	var effective := farm.effective_equipment()
	equipment_readout.text = "演示库存 / Demo equipment supply\n"
	equipment_readout.text += "%s · 插槽 / Slots: %d/%d\n" % [
		effective.machine.label, farm.installed_modules.size(), farm.demo_module_slots if effective.machine.supports_modules else 0]
	equipment_readout.text += "基础 → 生效 / Base → effective: %d → %d pts/night · %d → %d kJ/night\n" % [
		effective.machine.growth, effective.growth, effective.machine.energy_kj, effective.energy_kj]
	equipment_readout.text += "容积 / Capacity: %.0f mL · 性能 / P: %+d · 效率 / E: %+d\n" % [
		effective.capacity_ul / 1000.0, effective.performance, effective.efficiency]
	equipment_readout.text += "质量 / Quality: %+d · 返种 / Seed return: ×%.2f · 产量 / Output: +%d\n" % [
		effective.adjusted_quality, effective.reproduction_multiplier, effective.extra_output]
	if not effective.replacement.is_empty():
		equipment_readout.text += effective.replacement + "\n"
	var module_id := module_choice.get_selected_id()
	module_choice.clear()
	for id: int in Equipment.Module.values():
		var entry := Equipment.module_definition(id)
		var count: int = farm.installed_modules.count(id)
		var stock: int = farm.available_modules(id)
		if count + stock > 0:
			module_choice.add_item("%s · %d 安装 / installed · %d 库存 / free" % [entry.label, count, stock], id)
	if module_choice.get_item_index(module_id) >= 0:
		module_choice.select(module_choice.get_item_index(module_id))
	var selected_module := Equipment.module_definition(module_choice.get_selected_id())
	if selected_module != null and module_choice.item_count > 0:
		equipment_readout.text += "模组 / Module: P %+d · E %+d · Q %+d\n%s\n" % [
			selected_module.performance, selected_module.efficiency, selected_module.quality, selected_module.description]
	equipment_readout.text += farm.equipment_error

func _build_analysis() -> void:
	liquid_dialog = AcceptDialog.new()
	liquid_dialog.title = "液体分析 / Liquid analysis"
	add_child(liquid_dialog)
	var content := VBoxContainer.new()
	liquid_dialog.add_child(content)
	analysis_text = Label.new()
	analysis_text.add_theme_font_size_override("font_size", 14)
	content.add_child(analysis_text)
	var scenario_row := HBoxContainer.new()
	content.add_child(scenario_row)
	scenario_menu = OptionButton.new()
	for label: String in ["清洁 / Clean", "单一污染 / Single pollutant", "多种污染 / Multiple pollutants",
		"物理污染 / Physical pollution", "高污染 / High pollution"]:
		scenario_menu.add_item(label)
	scenario_row.add_child(scenario_menu)
	var replace := Button.new()
	replace.text = "更换演示溶液 / Replace with demo solution"
	scenario_row.add_child(replace)
	actions["replace_solution"] = replace
	replace.pressed.connect(_confirm_scenario)

func _confirm_scenario() -> void:
	liquid_dialog.hide()
	pending_action = farm.load_demo_solution.bind(scenario_menu.selected)
	confirm_action.dialog_text = "替换当前溶液，无退款？ / Replace current solution without refund?\n"
	confirm_action.dialog_text += "演示补给不计入储备 / Demo solution is supplied separately."
	confirm_action.popup_centered()

func _show_analysis() -> void:
	var snapshot := farm.vessel.snapshot_ul()
	var result := farm.pollution_analysis(snapshot)
	var mineral_pct: Variant = farm.vessel.mineral_concentration_pct()
	var mineral_label := "未定义 / undefined" if mineral_pct == null else "%.3f%%" % mineral_pct
	analysis_text.text = "纯水 / Water: %d µL   矿物 / Minerals: %d µL (%s)\n" % [
		result.water_ul, snapshot.get(LIQ.Component.MINERALS, 0), mineral_label]
	analysis_text.text += "溶液 / Solution: %d / %d µL\n" % [farm.vessel.total_ul(), farm.vessel.capacity_ul()]
	analysis_text.text += "物理 / Physical: %d µL   惰性 / Inert: %d µL\n" % [result.physical_ul, result.inert_ul]
	analysis_text.text += "有害污染 / Harmful: %d µL · 敏感度 / Sensitivity: %.5f · 系数 / Factor: %.2f\n" % [
		result.harmful_ul, result.sensitivity, result.damage_factor]
	analysis_text.text += "污染物 / Pollutant · µL · 原指数 / Raw index → 作物暴露 / Crop exposure\n"
	for index: int in result.components.size():
		var part := result.components[index]
		var exposure := "%.4f → %.4f" % [part.concentration, part.exposure] if part.exposure != null else "未定义 / undefined"
		analysis_text.text += "%s: %d µL · %s\n" % [POLLUTANT_NAMES[index], part.volume_ul, exposure]
	analysis_text.text += "预测每夜污染损伤 / Predicted nightly pollution damage: %s" % (
		str(result.rounded_damage()) if result.defined else "未定义 / undefined")
	if last_night != null:
		analysis_text.text += "\n上次运行夜损伤 / Last running night damage (health units)"
		for index: int in last_night.pollution.components.size():
			analysis_text.text += "\n%s: %.2f" % [POLLUTANT_NAMES[index], last_night.pollution.components[index].nightly_damage]
	liquid_dialog.popup_centered()

func _confirm_drain() -> bool:
	pending_action = farm.drain_solution
	confirm_action.dialog_text = "排出 %.3f ml，无退款。补液消耗储备。\nDiscard %.3f ml without refund. Refilling uses supply." % [
		farm.vessel.total_ul() / 1000.0, farm.vessel.total_ul() / 1000.0]
	confirm_action.popup_centered()
	return true

func _show_genetics() -> void:
	var inspected_seed: Farm.Seed
	var result: Genetics.Effective
	next_seed_button.disabled = farm.plant != null or farm.seed_count(farm.crop) < 2
	demo_genes_button.disabled = farm.plant != null or farm.crop != farm.catalog[0] or farm.occupied_slots() >= farm.inventory_capacity
	if farm.plant != null:
		inspected_seed = farm.plant.seed_item
		result = farm.plant.genetics
	else:
		inspected_seed = farm.selected_seed()
		if inspected_seed == null:
			genetics_dialog.dialog_text = "无可用种子 / No seed available"
			genetics_dialog.popup_centered()
			return
		result = inspected_seed.analyze()
	var text := "种子 / Seed #%d\n" % inspected_seed.get_instance_id()
	if farm.plant != null and farm.plant.reproduction != null and farm.plant.reproduction.eligible:
		var returned := farm.plant.reproduction
		text += "待领取种子 / Pending offspring: %d · 尝试 / Attempts: %d\n" % [returned.offspring_count, returned.attempts]
		text += "返种倍率 / Return: ×%.8f · 额外 / Extra: %.5f%%\n" % [returned.multiplier, returned.extra_copy_probability * 100.0]
	if not result.valid():
		genetics_dialog.dialog_text = text + "配置无效 / Invalid configuration\n" + result.error
		genetics_dialog.popup_centered()
		return
	var effective := result.crop
	text += "%s / %s · %s\n" % [effective.name_zh, effective.name_en,
		"原生 / Native" if result.native else "改良 / Modified"]
	text += "复杂度 / Complexity: %d · 热度 / Heat: %d · 不育等级 / Sterile rank: %d\n" % [
		result.complexity, result.heat, result.sterile_rank]
	text += "基础 → 生效 / Raw → effective\n"
	text += "生长 / Growth: %d → %d · 产量 / Output: %d → %d\n" % [
		effective.raw_target, effective.target, effective.raw_base_output, effective.healthy_output]
	var raw_draw := str(effective.raw_draw_ul) if effective.raw_draw_ul > 0 else "未知 / unknown"
	text += "耗液 / Draw: %s → %d µL/night\n" % [raw_draw, effective.draw_ul]
	text += "矿物 / Minerals: %d µL/point · %.2f–%.2f%%\n" % [
		effective.uptake_ul_per_point, effective.mineral_low_pct, effective.mineral_high_pct]
	text += "污染敏感度 / Sensitivity: %.5f · 系数 / Damage factor: %.2f\n" % [
		effective.native_pollution_sensitivity, effective.pollution_damage_factor]
	if result.caffeine_ul >= 0:
		text += "成分 / Per item: %d µL 咖啡因 / caffeine · %d µL 咖啡豆糊 / paste\n" % [
			result.caffeine_ul, result.coffee_paste_ul]
	for id: String in result.traits:
		var entry := Genetics.definition(id)
		var effect := "仅资料 / Metadata" if not result.modifiers.has(id) else "×%.5f" % result.modifiers[id]
		if result.caffeine_ul >= 0 and id in ["Caffeine Output", "Coffee Paste Output", "Potent", "Weak Potency"]:
			effect = "成分分析 / Composition analysis"
		elif id in ["Sterile", "Fertile"]:
			effect = "返种 / Seed return"
		text += "%s / %s %d · %s\n" % [entry.name_zh, id, result.traits[id], effect]
	genetics_dialog.dialog_text = text
	genetics_dialog.popup_centered()

func _next_seed() -> void:
	var stock := farm.seed_stock(farm.crop)
	if stock.is_empty():
		return
	var index := (stock.find(farm.selected_seed()) + 1) % stock.size()
	if farm.select_seed(stock[index].get_instance_id()):
		_show_genetics()

func _confirm_discard() -> void:
	if stored_items.selected < 0:
		return
	var item: Variant = stored_items.get_selected_metadata()
	if item is Farm.Seed:
		pending_action = farm.discard_seed_instance.bind(item)
	elif item is String:
		pending_action = farm.discard_product.bind(item)
	else:
		return
	confirm_action.dialog_text = "永久丢弃一件？ / Permanently discard one?\n" + stored_items.get_item_text(stored_items.selected)
	confirm_action.popup_centered()

func _action(grid: GridContainer, key: String, caption: String, command: Callable) -> void:
	var button := Button.new()
	button.text = caption
	button.add_theme_font_size_override("font_size", 13)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(button)
	actions[key] = button
	button.pressed.connect(func() -> void:
		var accepted: bool = command.call()
		if key == "drain":
			return
		_render()
		control_hint.text = "操作完成 / Action complete" if accepted else _rejection(key)
	)

func _rejection(key: String) -> String:
	match key:
		"water": return "水源或容器空间不足 / Insufficient water supply or vessel space"
		"tablet": return "营养片或容器空间不足 / No tablet or insufficient vessel space"
		"energy": return "电力补给不足或超限 / Insufficient energy supply or capacity"
		"harvest": return "尚未成熟或库存空间不足 / Crop immature or inventory full"
		"plant": return "缺少种子或种植槽已占用 / No seed or slot occupied"
	return "机器不能启动或停止 / Machine cannot start or stop"

func _render() -> void:
	var amounts := farm.vessel.snapshot_ul()
	var pollution := farm.pollution_analysis(amounts)
	actions["analysis"].text = "分析 / Analysis%s" % (" •" if pollution.harmful_ul > 0 or pollution.physical_ul > 0 else "")
	actions["analysis"].tooltip_text = "有害污染 / Harmful pollution: %d µL" % pollution.harmful_ul
	water_value_label.text = "%.3f ml" % (float(amounts.get(LIQ.Component.WATER, 0)) / 1000.0)
	mineral_value_label.text = "%.3f ml" % (float(amounts.get(LIQ.Component.MINERALS, 0)) / 1000.0)
	electricity_value_label.text = "%d kJ" % farm.energy_kj
	var description: Label = $SafeArea/MainLayout/MainPanels/MachinePanel/MachineContent/MachineStatus/MachineStatusContent/MachineDescription
	description.text = "运行中 / Running" if farm.running else "已停止 / Stopped"
	supplies.text = (
		"库存 / Items: %d / %d    营养片 / Tablets: %d\n" % [farm.occupied_slots(), farm.inventory_capacity, farm.tablets]
		+ "补给 / Supply: %.0f ml · %d kJ" % [farm.water_supply_ul / 1000.0, farm.energy_supply_kj]
	)
	actions["water"].tooltip_text = "每次 / Per refill: %.3f ml" % (farm.refill_water_ul / 1000.0)
	actions["energy"].tooltip_text = "每次 / Per refill: %d kJ" % farm.refill_energy_kj
	crop_menu.disabled = not farm.configured or farm.plant != null
	crop_menu.select(farm.catalog.find(farm.crop))
	var selected_item: Variant = stored_items.get_selected_metadata() if stored_items.selected >= 0 else null
	stored_items.clear()
	for definition in farm.catalog:
		for item: Farm.Seed in farm.seed_stock(definition):
			stored_items.add_item("%s / %s · #%d" % [definition.name_zh, definition.name_en, item.get_instance_id()])
			stored_items.set_item_metadata(stored_items.item_count - 1, item)
	for key: String in farm.products:
		stored_items.add_item("%s × %d" % [key, farm.products[key]])
		stored_items.set_item_metadata(stored_items.item_count - 1, key)
	var restored_index := 0 if stored_items.item_count > 0 else -1
	for index in stored_items.item_count:
		if is_same(stored_items.get_item_metadata(index), selected_item):
			restored_index = index
			break
	stored_items.select(restored_index)
	actions["discard"].disabled = not farm.configured or stored_items.selected < 0
	actions["seed_supply"].disabled = not farm.configured or farm.occupied_slots() >= farm.inventory_capacity
	actions["drain"].disabled = not farm.configured or farm.vessel.total_ul() == 0
	var mature := farm.plant != null and farm.plant.stage == Farm.Plant.Stage.MATURE
	actions["plant"].disabled = not farm.configured or farm.plant != null or farm.seed_count(farm.crop) == 0
	actions["plant"].disabled = actions["plant"].disabled or farm.seed_edit_locked(farm.selected_seed())
	actions["genetics"].disabled = not farm.configured
	actions["run"].disabled = not farm.configured or farm.plant == null or mature
	actions["run"].text = "停止 / Stop" if farm.running else "启动 / Start"
	actions["harvest"].disabled = not mature
	for action in ["water", "tablet", "energy"]:
		actions[action].disabled = not farm.configured
	if farm.crop == null:
		crop_empty_title.text = "配置无效 / Invalid configuration"
		return
	var displayed_crop := farm.plant.genetics.crop if farm.plant != null else farm.crop
	crop_empty_title.text = "%s / %s" % [displayed_crop.name_zh, displayed_crop.name_en]
	var concentration: Variant = farm.vessel.mineral_concentration_pct()
	var concentration_text := "未定义 / undefined" if concentration == null else ("%.3f%%" % concentration)
	crop_empty_description.text = (
		"混合液 / Solution: %.3f / %.3f ml\n" % [farm.vessel.total_ul() / 1000.0, farm.vessel.capacity_ul() / 1000.0]
		+ "矿物浓度 / Minerals: %s (%.2f–%.2f%%)\n" % [concentration_text, displayed_crop.mineral_low_pct, displayed_crop.mineral_high_pct]
	)
	if farm.plant == null:
		crop_growth_label.text = "尚未播种 / No plant · 种源 / Seeds: %d" % farm.seed_count(farm.crop)
		return
	crop_growth_label.text = (
		"生长 / Growth: %d / %d\n" % [farm.plant.growth, farm.plant.target]
		+ "健康 / Health: %d    评分 / Score: %.2f%%\n" % [farm.plant.health, farm.plant.score()]
		+ ("待收获 / Pending: %d" % farm.plant.pending if mature else "生长中 / Cultivating")
	)
	if mature:
		if not farm.plant.replacement_product.is_empty():
			crop_growth_label.text += "\n" + farm.plant.replacement_product
		else:
			for size_label: String in farm.plant.sizes:
				crop_growth_label.text += "\n%s × %d" % [size_label, farm.plant.sizes[size_label]]
	else:
		crop_growth_label.text += "\n剩余运行夜 / Running nights left: %d" % farm.remaining_nights()

func _on_coffee_finished(_day: int, _next_day: int, outcome: GameState.NightOutcome) -> void:
	_render()
	var completed := outcome as Farm.FarmOutcome
	if outcome.status != GameState.NightStatus.GROWN or completed == null:
		control_hint.text = outcome.detail
		return
	last_night = completed
	control_hint.text = (
		"生长 / Growth: +%d · 矿物损伤 / Mineral dmg: %d · 污染 / Pollution: %d\n" % [
			completed.growth_gained, completed.mineral_damage, completed.pollution_damage]
		+ "健康损失 / Health loss: %d · 健康 / Health: %d · 评分 / Score: %.2f%%" % [
			completed.health_loss, completed.resulting_health, completed.resulting_health / 100.0]
	)
