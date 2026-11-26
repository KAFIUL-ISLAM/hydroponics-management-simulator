extends "res://scripts/main.gd"

const Farm = preload("res://scripts/coffee_farm.gd")
const LIQ = preload("res://scripts/liquid_composition.gd")

@onready var farm: Farm = $CoffeeFarm
var actions: Dictionary[String, Button] = {}
var supplies: Label
var crop_menu: OptionButton
var stored_items: OptionButton
var confirm_action: ConfirmationDialog
var pending_action: Callable

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
	machine.add_child(supplies)
	crop_menu = OptionButton.new()
	for definition in farm.catalog:
		crop_menu.add_item("%s / %s" % [definition.name_zh, definition.name_en] if definition != null else "无效 / Invalid")
	machine.add_child(crop_menu)
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
		var accepted: bool = pending_action.call()
		pending_action = Callable()
		_render()
		control_hint.text = "操作完成 / Action complete" if accepted else "操作被拒绝 / Action rejected"
	)

func _confirm_drain() -> bool:
	pending_action = farm.drain_solution
	confirm_action.dialog_text = "排出 %.3f ml，无退款。补液消耗储备。\nDiscard %.3f ml without refund. Refilling uses supply." % [
		farm.vessel.total_ul() / 1000.0, farm.vessel.total_ul() / 1000.0]
	confirm_action.popup_centered()
	return true

func _confirm_discard() -> void:
	if stored_items.selected < 0:
		return
	var item: Variant = stored_items.get_selected_metadata()
	pending_action = farm.discard_seed.bind(item) if item is ReferenceCrop else farm.discard_product.bind(item)
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
	stored_items.clear()
	for definition in farm.catalog:
		if definition != null and farm.seed_count(definition) > 0:
			stored_items.add_item("%s / %s · 种源 / Plantable: %d" % [definition.name_zh, definition.name_en, farm.seed_count(definition)])
			stored_items.set_item_metadata(stored_items.item_count - 1, definition)
	for key: String in farm.products:
		stored_items.add_item("%s × %d" % [key, farm.products[key]])
		stored_items.set_item_metadata(stored_items.item_count - 1, key)
	if stored_items.item_count > 0:
		stored_items.select(0)
	actions["discard"].disabled = not farm.configured or stored_items.item_count == 0
	actions["seed_supply"].disabled = not farm.configured or farm.occupied_slots() >= farm.inventory_capacity
	actions["drain"].disabled = not farm.configured or farm.vessel.total_ul() == 0
	var mature := farm.plant != null and farm.plant.stage == Farm.Plant.Stage.MATURE
	actions["plant"].disabled = not farm.configured or farm.plant != null or farm.seed_count(farm.crop) == 0
	actions["run"].disabled = not farm.configured or farm.plant == null or mature
	actions["run"].text = "停止 / Stop" if farm.running else "启动 / Start"
	actions["harvest"].disabled = not mature
	for action in ["water", "tablet", "energy"]:
		actions[action].disabled = not farm.configured
	if farm.crop == null:
		crop_empty_title.text = "配置无效 / Invalid configuration"
		return
	crop_empty_title.text = "%s / %s" % [farm.crop.name_zh, farm.crop.name_en]
	var concentration: Variant = farm.vessel.mineral_concentration_pct()
	var concentration_text := "未定义 / undefined" if concentration == null else ("%.3f%%" % concentration)
	crop_empty_description.text = (
		"混合液 / Solution: %.3f / %.3f ml\n" % [farm.vessel.total_ul() / 1000.0, farm.vessel.capacity_ul() / 1000.0]
		+ "矿物浓度 / Minerals: %s (%.2f–%.2f%%)\n" % [concentration_text, farm.crop.mineral_low_pct, farm.crop.mineral_high_pct]
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
	control_hint.text = (
		"结算完成 / Night settled · %.3f ml · %d kJ\n" % [completed.draw_ul / 1000.0, completed.energy_kj]
		+ "矿物损失 / Mineral loss: %d µL · 健康损失 / Health loss: %d" % [completed.liquid.total_mineral_loss_ul(), completed.health_loss]
	)
