extends "res://scripts/main.gd"

const Farm = preload("res://scripts/coffee_farm.gd")
const LIQ = preload("res://scripts/liquid_composition.gd")
const Pollution = preload("res://scripts/pollution_analysis.gd")
const Genetics = preload("res://scripts/crop_genetics.gd")
const Equipment = preload("res://scripts/hydroponic_equipment.gd")
const DNA = preload("res://scripts/dna_editor.gd")
const Art = preload("res://scripts/orbital_art.gd")
const ChamberArt = preload("res://scripts/cultivation_art.gd")
const Workstation = preload("res://scripts/workstation_view.gd")
const InventoryGrid = preload("res://scripts/inventory_grid.gd")
const Workshop = preload("res://scripts/workshop_view.gd")
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
var equipment_pages: TabContainer
var equipment_notice: Label
var equipment_machine_display: RichTextLabel
var equipment_effects_display: RichTextLabel
var equipment_module_display: RichTextLabel
var equipment_slot_grid: GridContainer
var equipment_lock_status: Label
var machine_choice: OptionButton
var vessel_choice: OptionButton
var module_choice: OptionButton
var dna_dialog: AcceptDialog
var dna_seed: OptionButton
var dna_trait: OptionButton
var dna_readout: Label
var dna_pages: TabContainer
var genes_pages: TabContainer
var liquid_pages: TabContainer
var dna_start: Button
var machine_name_label: Label
var machine_state_label: Label
var dna_status_label: Label
var growth_meter: ProgressBar
var contextual_action: Button
var contextual_action_key: String
var art: Art
var cultivation_art: ChamberArt
var cultivation_dialog: AcceptDialog
var inventory_tiles: InventoryGrid
var inventory_caption: Label
var inventory_seed_choice: Farm.Seed
var seed_aliases: Dictionary[int, int] = {}
var health_meter: ProgressBar
var solution_meter: ProgressBar
var crop_icon: TextureRect
var hotspots: Dictionary[String, Button] = {}
var workstation_dialogs: Array[AcceptDialog] = []
var return_focus: Control
var workstation_shade: ColorRect
var liquid_summary: Label
var liquid_capacity: ProgressBar
var liquid_range: ProgressBar
var liquid_band: Label
var optimal_segment: ColorRect
var equipment_slots: Label
var genes_readout: Label
var genes_portrait: TextureRect
var dna_progress: ProgressBar
@export var workshop_enabled := false
var workshop: Workshop

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
	art = Art.new()
	_build_actions()
	_prepare_workstations()
	if workshop_enabled:
		workshop = Workshop.new()
		add_child(workshop)
		workshop.setup(self)
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
	var supply_row := GridContainer.new()
	supply_row.columns = 2
	machine.add_child(supplies)
	machine.add_child(supply_row)
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
		_present(equipment_dialog)
	)
	crop_menu = OptionButton.new()
	crop_menu.fit_to_longest_item = false
	crop_menu.clip_text = true
	crop_menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for definition in farm.catalog:
		crop_menu.add_item("%s / %s" % [definition.name_zh, definition.name_en] if definition != null else "无效 / Invalid")
	var crop_row := HBoxContainer.new()
	machine.add_child(crop_row)
	crop_row.add_child(crop_menu)
	var genes := Button.new()
	genes.text = "基因 / Genes"
	genes.add_theme_font_size_override("font_size", 13)
	supply_row.add_child(genes)
	actions["genetics"] = genes
	genes.pressed.connect(_show_genetics)
	genetics_dialog = AcceptDialog.new()
	genetics_dialog.title = "种子分析 / Seed analysis"
	add_child(genetics_dialog)
	var genes_body := Workstation.fixed_body(genetics_dialog, "标本扫描仪 / Botanical scanner", art.texture("seed"),
		Color("#424a30"), Color("#132a24"), Color("#c8dd9b"))
	genes_portrait = Art.decoration(null)
	genes_portrait.custom_minimum_size.y = 52
	genes_body.add_child(genes_portrait)
	genes_pages = Workstation.fixed_tabs(genes_body)
	genes_readout = Workstation.readout(genes_body)
	genes_readout.hide()
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
	_action(grid, "tablet", "营养片 / Tablet", farm.add_tablet)
	_action(grid, "energy", "充电 / Add energy", farm.add_energy)
	_action(grid, "harvest", "收获 / Collect", farm.collect)
	_action(grid, "seed_supply", "演示补种 / Demo seed", farm.supply_demo_seed)
	_action(grid, "drain", "排液 / Drain", _confirm_drain)
	cultivation_dialog = AcceptDialog.new()
	cultivation_dialog.title = "培育操作 / Cultivation controls"
	add_child(cultivation_dialog)
	var cultivation_row := HBoxContainer.new()
	cultivation_dialog.add_child(cultivation_row)
	for key: String in ["plant", "run", "harvest"]:
		actions[key].reparent(cultivation_row, false)
		actions[key].pressed.connect(cultivation_dialog.hide)
	var cultivation := Button.new()
	cultivation.text = "培育 / Grow"
	supply_row.add_child(cultivation)
	supply_row.move_child(cultivation, 0)
	cultivation.pressed.connect(_open_cultivation)
	var demo_caption := _section("演示 / Demo")
	machine.add_child(demo_caption)
	actions["seed_supply"].reparent(machine, false)
	var inventory_row := HBoxContainer.new()
	var layout := $SafeArea/MainLayout as VBoxContainer
	var inventory_panel := PanelContainer.new()
	layout.add_child(inventory_panel)
	layout.move_child(inventory_panel, next_night_button.get_parent().get_parent().get_index())
	var inventory_content := VBoxContainer.new()
	inventory_panel.add_child(inventory_content)
	inventory_content.add_child(inventory_row)
	inventory_caption = _section("库存 / Inventory")
	inventory_caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_row.add_child(inventory_caption)
	stored_items = OptionButton.new()
	stored_items.fit_to_longest_item = false
	stored_items.clip_text = true
	stored_items.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_row.add_child(stored_items)
	stored_items.hide()
	var discard := Button.new()
	discard.text = "丢弃一件 / Discard one"
	inventory_row.add_child(discard)
	actions["discard"] = discard
	discard.pressed.connect(_confirm_discard)
	inventory_tiles = InventoryGrid.new()
	inventory_tiles.custom_minimum_size.y = 74
	inventory_tiles.icon_mode = ItemList.ICON_MODE_TOP
	inventory_tiles.fixed_icon_size = Vector2i(29, 29)
	inventory_tiles.fixed_column_width = 43
	inventory_tiles.max_columns = 0
	inventory_tiles.same_column_width = true
	inventory_content.add_child(inventory_tiles)
	inventory_tiles.item_selected.connect(_select_inventory_slot)
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
	var editor_shortcut := Button.new()
	editor_shortcut.text = "DNA 编辑 / DNA"
	editor_shortcut.add_theme_font_size_override("font_size", 13)
	_set_icon(editor_shortcut, "station")
	supply_row.add_child(editor_shortcut)
	editor_shortcut.pressed.connect(_open_dna)

func _open_cultivation() -> void:
	_present(cultivation_dialog)

func _present(dialog: AcceptDialog) -> void:
	var current := get_viewport().gui_get_focus_owner()
	if current != null and current.get_window() == get_window():
		return_focus = current
	if dialog.has_meta("fixed_instrument"):
		dialog.popup_centered(Workstation.FIXED_SIZE)
	else:
		dialog.popup_centered()
	if dialog == confirm_action:
		confirm_action.get_cancel_button().grab_focus.call_deferred()

func _restore_workstation_focus() -> void:
	for dialog: AcceptDialog in workstation_dialogs:
		if dialog.visible:
			return
	if is_instance_valid(return_focus) and return_focus.is_visible_in_tree():
		if return_focus is BaseButton and return_focus.disabled:
			if workshop != null:
				workshop.machine.grab_focus()
		else:
			return_focus.grab_focus()
	return_focus = null

func _sync_workstation_layer() -> void:
	for dialog: AcceptDialog in workstation_dialogs:
		if dialog.visible:
			if get_viewport().gui_is_dragging():
				get_viewport().gui_cancel_drag()
			workstation_shade.show()
			return
	workstation_shade.hide()
	_restore_workstation_focus.call_deferred()

func _inventory_key(item: Variant) -> String:
	if item is Farm.Seed:
		return "seed:%d" % item.get_instance_id()
	return "product:" + item if item is String else ""

func _select_inventory_slot(slot: int) -> void:
	var key := inventory_tiles.slots[slot]
	var entry: Dictionary = inventory_tiles.rows.get(key, {})
	for index in stored_items.item_count:
		var item: Variant = stored_items.get_item_metadata(index)
		if _inventory_key(item) == key or (entry.has("item") and is_same(entry.item, item)):
			_select_inventory_item(index)
			return
	# Supply and equipment tiles do not participate in seed/product discard.
	if workshop != null:
		stored_items.select(-1)
		inventory_seed_choice = null
		_update_inventory_icon()

func _select_inventory_item(index: int) -> void:
	stored_items.select(index)
	var item: Variant = stored_items.get_item_metadata(index)
	inventory_seed_choice = item if item is Farm.Seed else null
	if item is Farm.Seed and farm.plant == null and farm.can_act():
		if farm.crop == item.definition or farm.select_species(farm.catalog.find(item.definition)):
			farm.select_seed(item.get_instance_id())
	_render()

func _inventory_tile_label(item: Variant) -> String:
	if item is Farm.Seed:
		var id: int = item.get_instance_id()
		if not seed_aliases.has(id):
			seed_aliases[id] = seed_aliases.size() + 1
		return "%s #%02d\n种子 / Seed" % [item.definition.name_zh, seed_aliases[id]]
	var product: String = item
	return "%s ×%d\n收获物 / Harvest" % [product.get_slice(" / ", 0), farm.products[product]]

func _inventory_tooltip(item: Variant, label: String) -> String:
	if item is String:
		return "%s\n收获物 / Harvested product · 库存 / In stock: %d" % [item, farm.products[item]]
	var seed_item := item as Farm.Seed
	var effective := seed_item.analyze()
	var info := label + "\n种子 / Seed"
	if farm.seed_edit_locked(seed_item):
		info += " · DNA 编辑锁定 / Locked for DNA editing"
	if not effective.valid():
		return info + "\n配置无效 / Invalid configuration: " + effective.error
	var crop := effective.crop
	info += "\n生长目标 / Growth target: %d · 健康产量 / Healthy output: %d" % [crop.target, crop.healthy_output]
	info += "\n耗液 / Solution draw: %d µL/night · 复杂度 / Complexity: %d · 热度 / Heat: %d" % [
		crop.draw_ul, effective.complexity, effective.heat]
	var traits := PackedStringArray()
	for id: String in effective.traits:
		traits.append("%s %d" % [id, effective.traits[id]])
	if not traits.is_empty():
		info += "\n性状 / Traits: " + ", ".join(traits)
	return info

func _section(caption: String) -> Label:
	var label := Label.new()
	label.text = caption
	label.add_theme_font_size_override("font_size", 15)
	return label

func _prepare_workstations() -> void:
	var layout := $SafeArea/MainLayout
	var panels := layout.get_node("MainPanels") as HBoxContainer
	var machine := panels.get_node("MachinePanel/MachineContent") as VBoxContainer
	var chamber := machine.get_node("MachineStatus") as PanelContainer
	var chamber_content := chamber.get_node("MachineStatusContent") as VBoxContainer
	machine_name_label = chamber_content.get_node("MachineName")
	machine_state_label = chamber_content.get_node("MachineDescription")
	chamber.reparent(panels)
	panels.move_child(chamber, 1)
	chamber.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chamber.size_flags_stretch_ratio = 2.9
	(machine.get_parent() as Control).size_flags_stretch_ratio = 0.75
	(panels.get_node("CropPanel") as Control).size_flags_stretch_ratio = 1.1
	chamber_content.get_node("MachineIcon").hide()
	var heading := _section("培育舱 / Cultivation chamber")
	var chamber_header := HBoxContainer.new()
	chamber_content.add_child(chamber_header)
	chamber_content.move_child(chamber_header, 0)
	chamber_header.add_child(heading)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	machine_name_label.reparent(chamber_header, false)
	machine_state_label.hide()
	var artwork := Control.new()
	artwork.name = "ArtworkLayers"
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	artwork.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chamber_content.add_child(artwork)
	cultivation_art = ChamberArt.new(artwork, art)
	hotspots["cultivation"] = cultivation_art.add_hotspot("培育 / Grow", "培育操作 / Open cultivation controls",
		Rect2(0.36, 0.08, 0.29, 0.095), _open_cultivation)
	hotspots["analysis"] = cultivation_art.add_hotspot("液 / Tank", "液体分析 / Open liquid analysis",
		Rect2(0.08, 0.56, 0.24, 0.095), actions["analysis"].pressed.emit)
	hotspots["equipment"] = cultivation_art.add_hotspot("机 / Gear", "设备管理 / Open equipment management",
		Rect2(0.78, 0.63, 0.22, 0.095), actions["equipment"].pressed.emit)
	var chamber_footer := HBoxContainer.new()
	chamber_content.add_child(chamber_footer)
	cultivation_art.stage_label.reparent(chamber_footer, false)
	cultivation_art.stage_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dna_status_label = _section("")
	dna_status_label.add_theme_font_size_override("font_size", 12)
	dna_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dna_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chamber_footer.add_child(dna_status_label)
	var crop_content := panels.get_node("CropPanel/CropContent") as VBoxContainer
	var crop_readout := crop_content.get_node("CropEmptyState/CropEmptyContent") as VBoxContainer
	crop_readout.get_node("CropIcon").hide()
	crop_readout.alignment = BoxContainer.ALIGNMENT_BEGIN
	crop_readout.add_theme_constant_override("separation", 4)
	crop_growth_label.add_theme_font_size_override("font_size", 14)
	crop_icon = Art.decoration(null)
	crop_icon.custom_minimum_size.y = 30
	crop_readout.add_child(crop_icon)
	crop_readout.move_child(crop_icon, 1)
	growth_meter = _meter(crop_readout, "生长 / Growth")
	health_meter = _meter(crop_readout, "健康 / Health")
	solution_meter = _meter(crop_readout, "溶液 / Solution")
	layout.get_node("Header/HeaderContent/TitleGroup/GameTitle").text = "轨道水培实验室"
	layout.get_node("Header/HeaderContent/TitleGroup/GameSubtitle").text = "ORBITAL HYDROPONICS"
	layout.get_node("FooterLabel").hide()
	(layout.get_node("Header") as Control).custom_minimum_size.y = 54
	layout.add_theme_constant_override("separation", 8)
	panels.add_theme_constant_override("separation", 8)
	$Background.color = Color("#101820")
	for panel: PanelContainer in [layout.get_node("Header"), layout.get_node("ControlBar"), panels.get_node("MachinePanel"), panels.get_node("CropPanel"), chamber]:
		panel.remove_theme_stylebox_override("panel")
	for card: PanelContainer in layout.get_node("ResourceRow").get_children():
		card.remove_theme_stylebox_override("panel")
		var content := card.get_child(0) as VBoxContainer
		content.add_theme_constant_override("separation", 2)
		content.get_child(2).hide()
	water_value_label.add_theme_color_override("font_color", Color("#58BCEB"))
	electricity_value_label.add_theme_color_override("font_color", Color("#E9B65A"))
	_add_resource_icon(water_value_label, "water")
	_add_resource_icon(electricity_value_label, "energy")
	_set_icon(actions["analysis"], "tank")
	actions["analysis"].add_theme_constant_override("icon_max_width", 13)
	_set_icon(actions["equipment"], "terminal")
	_set_icon(actions["genetics"], "dna")
	_set_icon(actions["install_module"], "module")
	_set_icon(actions["seed_supply"], "seed")
	stored_items.item_selected.connect(_select_inventory_item)
	machine.get_node("MachineHeading").text = "操作台 / Workstations"
	next_night_button.text = "下一夜 / Next Night"
	next_night_button.remove_theme_stylebox_override("normal")
	next_night_button.theme_type_variation = &"PrimaryAction"
	contextual_action = Button.new()
	contextual_action.add_theme_font_size_override("font_size", 13)
	contextual_action.theme_type_variation = &"PrimaryAction"
	var controls := next_night_button.get_parent()
	controls.add_child(contextual_action)
	controls.move_child(contextual_action, next_night_button.get_index())
	contextual_action.pressed.connect(func() -> void:
		var action := actions[contextual_action_key]
		if not action.disabled:
			action.pressed.emit()
	)
	actions["seed_supply"].modulate = Color("#AE91ED")
	control_hint.add_theme_font_size_override("font_size", 14)
	control_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	control_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	workstation_dialogs.assign([genetics_dialog, dna_dialog, liquid_dialog, equipment_dialog, confirm_action, cultivation_dialog])
	workstation_shade = ColorRect.new()
	workstation_shade.color = Color("#081017a8")
	workstation_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	workstation_shade.hide()
	add_child(workstation_shade)
	workstation_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for modal: AcceptDialog in workstation_dialogs:
		modal.theme = theme
		modal.transient = true
		modal.exclusive = true
		modal.ok_button_text = "关闭 / Close"
		modal.visibility_changed.connect(_sync_workstation_layer)
		Workstation.bind_escape(modal, func() -> void:
			if modal == confirm_action:
				pending_action = Callable()
			modal.hide()
		)
	confirm_action.title = "确认操作 / Confirm action"
	confirm_action.ok_button_text = "确认 / Confirm"
	confirm_action.cancel_button_text = "取消 / Cancel"

func _meter(parent: VBoxContainer, caption: String) -> ProgressBar:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := _section(caption)
	label.add_theme_font_size_override("font_size", 11)
	label.custom_minimum_size.x = 90
	row.add_child(label)
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size.y = 7
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(bar)
	return bar

func _set_icon(button: Button, key: String) -> void:
	button.icon = art.texture(key)
	button.add_theme_constant_override("icon_max_width", 17)
	button.expand_icon = false

func _add_resource_icon(label: Label, key: String) -> void:
	var sprite := Art.decoration(art.texture(key))
	label.add_child(sprite)
	sprite.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	sprite.offset_left = -42
	sprite.offset_right = -3
	sprite.offset_top = -18
	sprite.offset_bottom = 18

func inventory_icon_key(item: Variant) -> String:
	if item is Farm.Seed:
		var key := Art.crop_key(item.definition.resource_path.get_file().get_basename())
		return key + "_seed" if key in ["nutrition", "kotton"] else key
	if item is String:
		for definition: ReferenceCrop in farm.catalog:
			if definition != null and item.begins_with(definition.product_name + " · "):
				return Art.species_key(definition.species)
		if item == Equipment.module_definition(Equipment.Module.WEAVING).replacement:
			return Art.crop_key("kotton")
		if item.to_lower().contains("lettuce"):
			return Art.crop_key("lettuce_prototype")
	return ""

func product_unit_key(product: String, index: int) -> String:
	return _inventory_key(product) if index == 0 else "unit:%d:%s" % [index, product]

func _update_inventory_icon() -> void:
	var item: Variant = stored_items.get_selected_metadata() if stored_items.selected >= 0 else null
	_set_icon(actions["discard"], inventory_icon_key(item))
	actions["discard"].disabled = not farm.configured or not (item is Farm.Seed or item is String)

func _on_status_changed(status: GameState.SimulationStatus) -> void:
	super._on_status_changed(status)
	status_label.text = "全局 / System · " + status_label.text
	match status:
		GameState.SimulationStatus.PROCESSING:
			next_night_button.tooltip_text = "正在结算 / Night settlement in progress"
		GameState.SimulationStatus.PAUSED:
			next_night_button.tooltip_text = "模拟已暂停 / Simulation paused"
		_:
			next_night_button.tooltip_text = "推进一天 / Advance one day"

func _build_dna() -> void:
	var open := genetics_dialog.add_button("DNA 编辑 / DNA edit", true)
	open.pressed.connect(_open_dna)
	actions["dna"] = open
	dna_dialog = AcceptDialog.new()
	dna_dialog.title = "DNA 编辑器 / DNA editor"
	add_child(dna_dialog)
	var content := Workstation.fixed_body(dna_dialog, "基因工程终端 / Genetic terminal", art.texture("station"),
		Color("#404b55"), Color("#132b34"), Color("#c8b9f1"))
	var selector_row := HBoxContainer.new()
	content.add_child(selector_row)
	var selectors := Workstation.row(selector_row)
	selectors.get_parent().size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Workstation.section(selectors, "选定种子 / Selected seed")
	dna_seed = OptionButton.new()
	dna_seed.fit_to_longest_item = false
	dna_seed.clip_text = true
	selectors.add_child(dna_seed)
	selectors = Workstation.row(selector_row)
	selectors.get_parent().size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Workstation.section(selectors, "性状数据盘 / Trait disc")
	dna_trait = OptionButton.new()
	selectors.add_child(dna_trait)
	for id: String in DNA.SUPPORTED:
		var entry := Genetics.definition(id)
		dna_trait.add_item("%s / %s" % [entry.name_zh, id])
	dna_seed.item_selected.connect(func(_index: int) -> void: _refresh_dna())
	dna_trait.item_selected.connect(func(_index: int) -> void: _refresh_dna())
	var operation := Workstation.row(content)
	Workstation.section(operation, "操作状态与结果 / Operation status and result")
	dna_progress = Workstation.meter(operation)
	dna_readout = Workstation.readout(operation)
	dna_readout.hide()
	dna_pages = Workstation.fixed_tabs(content)
	dna_start = dna_dialog.add_button("确认应用 / Confirm application", false)
	dna_start.theme_type_variation = &"PrimaryAction"
	dna_start.pressed.connect(func() -> void:
		if not dna_start.disabled and dna_seed.selected >= 0:
			dna_start.disabled = true
			farm.begin_edit(dna_seed.get_selected_metadata(), DNA.SUPPORTED[dna_trait.selected])
			_render()
			_refresh_dna()
	)

func _open_dna(requested_seed: Farm.Seed = null) -> void:
	genetics_dialog.hide()
	dna_seed.clear()
	var chosen := farm.selected_seed()
	if inventory_seed_choice != null and is_same(stored_items.get_selected_metadata(), inventory_seed_choice):
		chosen = inventory_seed_choice
	if requested_seed != null:
		chosen = requested_seed
	for definition: ReferenceCrop in farm.catalog:
		for item: Farm.Seed in farm.seed_stock(definition):
			dna_seed.add_item("%s / %s" % [_inventory_tile_label(item).get_slice("\n", 0), definition.name_en])
			dna_seed.set_item_metadata(dna_seed.item_count - 1, item)
			if item == chosen:
				dna_seed.select(dna_seed.item_count - 1)
	_refresh_dna()
	_present(dna_dialog)

func _refresh_dna() -> void:
	_compose_dna_readout()
	var page := dna_pages.current_tab
	Workstation.clear_pages(dna_pages)
	var text := dna_readout.text
	var preview_title := "应用预览 / Proposed application"
	var trait_title := "当前特性 / Current traits"
	var preview := text.split(preview_title, true, 1)
	var traits := preview[0].split(trait_title, true, 1)
	Workstation.append_reading_pages(dna_pages, "状态 / Status", traits[0])
	if traits.size() > 1:
		Workstation.append_reading_pages(dna_pages, "性状 / Traits", trait_title + traits[1])
	if preview.size() > 1:
		Workstation.append_reading_pages(dna_pages, "预览 / Preview", preview_title + preview[1])
	dna_pages.current_tab = clampi(page, 0, dna_pages.get_tab_count() - 1)

func _compose_dna_readout() -> void:
	var editor := farm.dna_editor
	dna_start.disabled = true
	dna_start.tooltip_text = "选择可用种子与性状 / Select an available seed and trait"
	dna_seed.disabled = editor.stage == DNA.Stage.RUNNING
	dna_trait.disabled = dna_seed.disabled
	var locked_hint := "DNA 编辑进行中 / An edit is in progress" if dna_seed.disabled else ""
	dna_seed.tooltip_text = locked_hint
	dna_trait.tooltip_text = locked_hint
	dna_progress.max_value = editor.operation.required_points if editor.operation != null else 1
	dna_progress.value = editor.progress
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
			dna_start.tooltip_text = locked_hint
			dna_readout.text += "关闭窗口并结算下一晚 / Close the dialog and settle the next night"
			return
		var final_traits: Dictionary[String, int] = editor.operation.after.traits if editor.stage == DNA.Stage.SUCCEEDED else editor.operation.before.traits
		dna_readout.text += "结果 / Result: 等级 / Rank %d · 热度 / Heat %d\n" % [
			final_traits.get(editor.operation.trait_id, 0), editor.operation.after.heat]
	if dna_seed.selected < 0:
		dna_start.tooltip_text = "无可用种子 / No available seed"
		dna_readout.text += "无可用种子 / No available seed"
		return
	var id: String = DNA.SUPPORTED[dna_trait.selected]
	var item: Farm.Seed = dna_seed.get_selected_metadata()
	var plan := farm.preview_edit(item, id)
	dna_readout.text += "\n技术标识 / Seed ID: #%d · 可用次数 / Disc uses: %d\n" % [item.get_instance_id(), farm.disc_uses[id]]
	if plan.valid():
		dna_readout.text += "成功率 / Chance: %d%% · %d 夜 / nights · %d kJ (%d/night)\n" % [
			plan.success_pct, plan.nights, plan.total_energy_kj, DNA.ENERGY_PER_NIGHT_KJ]
	var names := PackedStringArray()
	for trait_id: String in item.traits:
		var entry := Genetics.definition(trait_id)
		names.append("%s %d" % [trait_id if entry == null else entry.name_zh + " / " + trait_id, item.traits[trait_id]])
	dna_readout.text += "当前特性 / Current traits\n"
	for index: int in range(0, names.size(), 3):
		dna_readout.text += ", ".join(names.slice(index, index + 3)) + "\n"
	if not plan.valid():
		dna_start.tooltip_text = plan.error
		dna_readout.text += "\n不可用 / Unavailable · " + plan.error
		return
	dna_start.disabled = false
	dna_start.tooltip_text = "预览确认 / Review and confirm the application"
	dna_readout.text += "\n应用预览 / Proposed application\n"
	dna_readout.text += "等级 / Rank: %d → %d · 可用次数 / Disc uses: %d\n" % [
		plan.before.traits.get(id, 0), plan.after.traits[id], farm.disc_uses[id]]
	dna_readout.text += "复杂度 / Complexity: %d → %d · 热度 / Heat: %d → %d\n" % [
		plan.before.complexity, plan.after.complexity, plan.before.heat, plan.after.heat]
	dna_readout.text += "目标 / Target: %d → %d · 产量 / Yield: %d → %d\n" % [
		plan.before.crop.target, plan.after.crop.target, plan.before.crop.healthy_output, plan.after.crop.healthy_output]
	dna_readout.text += "耗液 / Draw: %d → %d µL · 敏感度 / Sensitivity: %.3f → %.3f\n" % [
		plan.before.crop.draw_ul, plan.after.crop.draw_ul, plan.before.crop.native_pollution_sensitivity, plan.after.crop.native_pollution_sensitivity]

func _build_equipment() -> void:
	equipment_dialog = AcceptDialog.new()
	equipment_dialog.title = "设备管理 / Equipment"
	add_child(equipment_dialog)
	var shell := Workstation.fixed_body(equipment_dialog, "设备维护台 / Equipment service console", art.texture("terminal"),
		Color("#454942"), Color("#192a29"), Color("#e6cf9d"))
	equipment_pages = Workstation.fixed_tabs(shell)
	equipment_notice = Workstation.section(shell, "")
	equipment_notice.hide()
	var content := Workstation.fixed_page(equipment_pages, "设备与容器 / Machine and vessel")
	var icons := HBoxContainer.new()
	content.add_child(icons)
	for key in ["machine", "tank"]:
		var illustration := Art.decoration(art.texture(key))
		illustration.custom_minimum_size = Vector2(56, 48)
		icons.add_child(illustration)
	equipment_machine_display = Workstation.fixed_readout(Workstation.row(content), "", 145)
	equipment_readout = Workstation.readout(shell)
	equipment_readout.hide()
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
	content = Workstation.fixed_page(equipment_pages, "模组 / Modules")
	var module_header := HBoxContainer.new()
	content.add_child(module_header)
	var module_icon := Art.decoration(art.texture("module"))
	module_icon.custom_minimum_size = Vector2(25, 25)
	module_header.add_child(module_icon)
	Workstation.section(module_header, "模组插槽与库存 / Module slots and stock")
	equipment_slots = Workstation.readout(shell)
	equipment_slots.hide()
	equipment_lock_status = Workstation.section(content, "")
	equipment_slot_grid = GridContainer.new()
	equipment_slot_grid.columns = 8
	content.add_child(equipment_slot_grid)
	module_choice = OptionButton.new()
	var module_row := _equipment_row(content, module_choice, "安装 / Install", "install_module", func() -> bool:
		return farm.install_module(module_choice.get_selected_id()))
	_equipment_control(module_row, "移除 / Remove", "remove_module", func() -> bool:
		return farm.remove_module(module_choice.get_selected_id()))
	equipment_module_display = Workstation.fixed_readout(Workstation.row(content), "", 140)
	module_choice.item_selected.connect(func(_index: int) -> void: _refresh_equipment())
	content = Workstation.fixed_page(equipment_pages, "效果 / Effects")
	equipment_effects_display = Workstation.fixed_readout(Workstation.row(content), "", 285)

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
	var slot_count: int = farm.demo_module_slots if effective.machine.supports_modules else 0
	equipment_readout.text = "%s · %s\n" % [effective.machine.label,
		"水罐 / 3 L water can" if farm.vessel_id == Equipment.Vessel.CAN else "演示容器 / Demo vessel"]
	equipment_readout.text += "基础 → 生效 / Base → effective: %d → %d pts/night · %d → %d kJ/night\n" % [
		effective.machine.growth, effective.growth, effective.machine.energy_kj, effective.energy_kj]
	equipment_readout.text += "容积 / Capacity: %.0f mL · 性能 / P: %+d · 效率 / E: %+d\n" % [
		effective.capacity_ul / 1000.0, effective.performance, effective.efficiency]
	equipment_readout.text += "质量 / Quality: %+d · 返种 / Seed return: ×%.2f · 产量 / Output: +%d\n" % [
		effective.adjusted_quality, effective.reproduction_multiplier, effective.extra_output]
	if not effective.replacement.is_empty():
		equipment_readout.text += effective.replacement + "\n"
	equipment_machine_display.text = equipment_readout.text
	equipment_slots.text = "%s   %d/%d · 演示库存 / Demo stock\n" % [
		"■ ".repeat(mini(16, farm.installed_modules.size())) + "□ ".repeat(clampi(slot_count - farm.installed_modules.size(), 0, 16)),
		farm.installed_modules.size(), slot_count]
	for id: int in farm.installed_modules:
		equipment_slots.text += Equipment.module_definition(id).label + "\n"
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
	equipment_module_display.text = ""
	if selected_module != null and module_choice.item_count > 0:
		var module_details := "%s\n性能 / P: %+d · 效率 / E: %+d · 质量 / Q: %+d\n%s\n" % [
			selected_module.label, selected_module.performance, selected_module.efficiency, selected_module.quality, selected_module.description]
		equipment_module_display.text = module_details
		equipment_readout.text += module_details
	if not farm.equipment_error.is_empty():
		equipment_readout.text += "\n未应用 / Rejected · " + farm.equipment_error
	var locked := farm.running or not farm.can_act()
	var locked_hint := ""
	if locked:
		locked_hint = "设备运行中 / Stop the machine to change equipment" if farm.running else "暂不可操作 / Equipment is currently unavailable"
		equipment_readout.text += "\n" + locked_hint
	equipment_lock_status.text = "%d / %d · 演示库存 / Demo stock" % [farm.installed_modules.size(), slot_count]
	if not locked_hint.is_empty():
		equipment_lock_status.text += " · " + locked_hint
	equipment_notice.text = locked_hint
	if not farm.equipment_error.is_empty():
		equipment_notice.text = "未应用 / Rejected · " + farm.equipment_error
	equipment_notice.visible = not equipment_notice.text.is_empty()
	equipment_effects_display.text = equipment_readout.text
	_render_equipment_slots(slot_count, locked)
	for key in ["switch_machine", "switch_vessel", "install_module", "remove_module"]:
		actions[key].disabled = locked
		actions[key].tooltip_text = locked_hint

func _render_equipment_slots(slot_count: int, locked: bool) -> void:
	for child in equipment_slot_grid.get_children():
		equipment_slot_grid.remove_child(child)
		child.queue_free()
	if slot_count <= 0:
		Workstation.section(equipment_slot_grid, "锁定 · 无模组槽 / Locked · No module slots")
		return
	for index in slot_count:
		var tile := PanelContainer.new()
		tile.custom_minimum_size = Vector2(56, 54)
		equipment_slot_grid.add_child(tile)
		var installed := index < farm.installed_modules.size()
		var line := VBoxContainer.new()
		tile.add_child(line)
		if installed:
			var icon := Art.decoration(art.texture("module"))
			icon.custom_minimum_size = Vector2(32, 31)
			line.add_child(icon)
			tile.tooltip_text = Equipment.module_definition(farm.installed_modules[index]).label
		else:
			var marker := Workstation.section(line, "—" if locked else "+")
			marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			tile.tooltip_text = "空槽 / Empty slot"
		var identifier := Workstation.section(line, str(index + 1))
		identifier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if locked:
			tile.tooltip_text += "\n槽位锁定 / Slot locked"

func _build_analysis() -> void:
	liquid_dialog = AcceptDialog.new()
	liquid_dialog.title = "液体分析 / Liquid analysis"
	add_child(liquid_dialog)
	var body := Workstation.fixed_body(liquid_dialog, "化学分析仪 / Chemical analyzer", art.texture("tank"),
		Color("#315560"), Color("#102b34"), Color("#97e0ec"))
	liquid_pages = Workstation.fixed_tabs(body)
	var content := Workstation.fixed_page(liquid_pages, "成分 / Composition")
	var summary := Workstation.row(content)
	Workstation.section(summary, "容器与矿物 / Vessel and minerals")
	liquid_summary = Workstation.readout(summary)
	liquid_summary.autowrap_mode = TextServer.AUTOWRAP_OFF
	liquid_summary.custom_minimum_size.x = 680
	liquid_capacity = Workstation.meter(summary)
	liquid_band = Workstation.readout(summary)
	liquid_band.autowrap_mode = TextServer.AUTOWRAP_OFF
	liquid_band.custom_minimum_size.x = 680
	liquid_range = Workstation.meter(summary)
	optimal_segment = ColorRect.new()
	optimal_segment.color = Color("#E9B65A")
	optimal_segment.mouse_filter = Control.MOUSE_FILTER_IGNORE
	liquid_range.add_child(optimal_segment)
	optimal_segment.offset_bottom = 3
	analysis_text = Workstation.readout(body)
	analysis_text.hide()
	Workstation.section(content, "演示溶液 / Demo solution replacement")
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
	_present(confirm_action)

func _show_analysis() -> void:
	var snapshot := farm.vessel.snapshot_ul()
	var result := farm.pollution_analysis(snapshot)
	var mineral_pct: Variant = farm.vessel.mineral_concentration_pct()
	var mineral_label := "未定义 / undefined" if mineral_pct == null else "%.3f%%" % mineral_pct
	liquid_summary.text = "纯水 / Water: %d µL\n矿物 / Minerals: %d µL (%s)\n" % [
		result.water_ul, snapshot.get(LIQ.Component.MINERALS, 0), mineral_label]
	liquid_summary.text += "溶液 / Solution: %d / %d µL" % [farm.vessel.total_ul(), farm.vessel.capacity_ul()]
	liquid_capacity.max_value = maxi(1, farm.vessel.capacity_ul())
	liquid_capacity.value = farm.vessel.total_ul()
	var definition := farm.plant.genetics.crop if farm.plant != null else farm.crop
	liquid_band.text = "危急 · 无法判断 / Critical · Mineral band unavailable"
	liquid_range.visible = mineral_pct != null and definition != null
	if definition != null:
		var band := LIQ.classify_mineral_band(mineral_pct, definition.mineral_low_pct, definition.mineral_high_pct)
		match band:
			LIQ.Band.IN_RANGE: liquid_band.text = "适宜 / Healthy"
			LIQ.Band.BELOW: liquid_band.text = "偏低 / Warning · Low"
			LIQ.Band.ABOVE: liquid_band.text = "偏高 / Warning · High"
		liquid_band.text += " · 适宜区间 / Optimal: %.2f–%.2f%%" % [definition.mineral_low_pct, definition.mineral_high_pct]
		liquid_range.max_value = maxf(1.0, definition.mineral_high_pct * 1.25)
		liquid_range.value = 0.0 if mineral_pct == null else float(mineral_pct)
		optimal_segment.anchor_left = definition.mineral_low_pct / liquid_range.max_value
		optimal_segment.anchor_right = definition.mineral_high_pct / liquid_range.max_value
	analysis_text.text = "预测每夜污染损伤 / Predicted nightly pollution damage: %s\n\n" % (
		str(result.rounded_damage()) if result.defined else "未定义 / undefined")
	analysis_text.text += "物理 / Physical: %d µL   惰性 / Inert: %d µL\n" % [result.physical_ul, result.inert_ul]
	analysis_text.text += "有害污染 / Harmful: %d µL · 敏感度 / Sensitivity: %.5f · 系数 / Factor: %.2f\n" % [
		result.harmful_ul, result.sensitivity, result.damage_factor]
	analysis_text.text += "污染物 / Pollutant · µL · 原指数 / Raw index → 作物暴露 / Crop exposure\n"
	for index: int in result.components.size():
		var part := result.components[index]
		var exposure := "%.4f → %.4f" % [part.concentration, part.exposure] if part.exposure != null else "未定义 / undefined"
		analysis_text.text += "%s: %d µL · %s\n" % [POLLUTANT_NAMES[index], part.volume_ul, exposure]
	if last_night != null:
		analysis_text.text += "\n\n上次运行夜损伤 / Last running night damage (health units) · %d" % last_night.pollution_damage
		for index: int in last_night.pollution.components.size():
			analysis_text.text += "\n%s: %.2f" % [POLLUTANT_NAMES[index], last_night.pollution.components[index].nightly_damage]
	var selected_page := liquid_pages.current_tab
	Workstation.clear_pages(liquid_pages, 1)
	var history_title := "上次运行夜损伤 / Last running night damage"
	var readings := analysis_text.text.split(history_title, true, 1)
	Workstation.append_reading_pages(liquid_pages, "污染 / Pollution", readings[0], 13)
	if readings.size() > 1:
		Workstation.append_reading_pages(liquid_pages, "上夜 / Last night", history_title + readings[1])
	liquid_pages.current_tab = clampi(selected_page, 0, liquid_pages.get_tab_count() - 1)
	_present(liquid_dialog)

func _confirm_drain() -> bool:
	pending_action = farm.drain_solution
	confirm_action.dialog_text = "排出 %.3f ml，无退款。补液消耗储备。\nDiscard %.3f ml without refund. Refilling uses supply." % [
		farm.vessel.total_ul() / 1000.0, farm.vessel.total_ul() / 1000.0]
	_present(confirm_action)
	return true

func _show_genetics(requested_seed: Farm.Seed = null) -> void:
	var inspected_seed: Farm.Seed
	var result: Genetics.Effective
	next_seed_button.disabled = farm.plant != null or farm.seed_count(farm.crop) < 2
	demo_genes_button.disabled = farm.plant != null or farm.crop != farm.catalog[0] or farm.occupied_slots() >= farm.inventory_capacity
	if requested_seed != null:
		inspected_seed = requested_seed
		result = requested_seed.analyze()
	elif farm.plant != null:
		inspected_seed = farm.plant.seed_item
		result = farm.plant.genetics
	else:
		inspected_seed = farm.selected_seed()
		if inspected_seed == null:
			genes_portrait.texture = null
			_present_genetics("无可用种子 / No seed available")
			return
		result = inspected_seed.analyze()
	genes_portrait.texture = art.texture(Art.species_key(inspected_seed.definition.species), "seed")
	var text := "%s / Seed profile\n" % _inventory_tile_label(inspected_seed).get_slice("\n", 0)
	if farm.plant != null and farm.plant.reproduction != null and farm.plant.reproduction.eligible:
		var returned := farm.plant.reproduction
		text += "待领取种子 / Pending offspring: %d · 尝试 / Attempts: %d\n" % [returned.offspring_count, returned.attempts]
		text += "返种倍率 / Return: ×%.8f · 额外 / Extra: %.5f%%\n" % [returned.multiplier, returned.extra_copy_probability * 100.0]
	if not result.valid():
		_present_genetics(text + "配置无效 / Invalid configuration\n" + result.error)
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
	text += "\n性状 / Traits\n"
	for id: String in result.traits:
		var entry := Genetics.definition(id)
		var effect := "仅资料 / Metadata" if not result.modifiers.has(id) else "×%.5f" % result.modifiers[id]
		if result.caffeine_ul >= 0 and id in ["Caffeine Output", "Coffee Paste Output", "Potent", "Weak Potency"]:
			effect = "成分分析 / Composition analysis"
		elif id in ["Sterile", "Fertile"]:
			effect = "返种 / Seed return"
		text += "%s / %s %d · %s\n" % [entry.name_zh, id, result.traits[id], effect]
	text += "\n技术详情 / Technical details · Seed #%d" % inspected_seed.get_instance_id()
	_present_genetics(text)

func _present_genetics(text: String) -> void:
	genes_readout.text = text
	genetics_dialog.dialog_text = text
	genetics_dialog.get_label().hide()
	var page := genes_pages.current_tab
	Workstation.clear_pages(genes_pages)
	var traits_title := "性状 / Traits"
	var requirements_title := "基础 → 生效 / Raw → effective"
	var traits := text.split(traits_title, true, 1)
	var profile := traits[0].split(requirements_title, true, 1)
	Workstation.append_reading_pages(genes_pages, "档案 / Profile", profile[0])
	if profile.size() > 1:
		Workstation.append_reading_pages(genes_pages, "需求 / Requirements", requirements_title + profile[1], 9, true)
	if traits.size() > 1:
		Workstation.append_reading_pages(genes_pages, "性状 / Traits", traits_title + traits[1])
	genes_pages.current_tab = clampi(page, 0, genes_pages.get_tab_count() - 1)
	_present(genetics_dialog)

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
	_present(confirm_action)

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
		control_hint.text = _success_feedback(key) if accepted else _rejection(key)
	)

func _success_feedback(key: String) -> String:
	match key:
		"plant": return "已播种，启动设备以培育 / Seed planted. Start the machine to grow."
		"run": return "设备已启动 / Machine started" if farm.running else "设备已停止 / Machine stopped"
		"water": return "已补水 / Water added · %.3f ml" % (farm.refill_water_ul / 1000.0)
		"tablet": return "已加入营养片 / Nutrient tablet added"
		"energy": return "已充电 / Energy added · %d kJ" % farm.refill_energy_kj
		"harvest": return "已收获 / Harvest collected"
		"seed_supply": return "已补充演示种子 / Demo seed added"
	return "操作完成 / Action complete"

func _rejection(key: String) -> String:
	match key:
		"water": return "水源或容器空间不足 / Insufficient water supply or vessel space"
		"tablet": return "营养片或容器空间不足 / No tablet or insufficient vessel space"
		"energy": return "电力补给不足或超限 / Insufficient energy supply or capacity"
		"harvest": return "尚未成熟或库存空间不足 / Crop immature or inventory full"
		"plant":
			if farm.seed_edit_locked(farm.selected_seed()):
				return "种子正在编辑 / Seed locked by DNA editor"
			return "缺少种子或种植槽已占用 / No seed or slot occupied"
	return "机器不能启动或停止 / Machine cannot start or stop"

func _render() -> void:
	var amounts := farm.vessel.snapshot_ul()
	var pollution := farm.pollution_analysis(amounts)
	actions["analysis"].text = "液体 / Liquid%s" % (" •" if pollution.harmful_ul > 0 or pollution.physical_ul > 0 else "")
	actions["analysis"].tooltip_text = "有害污染 / Harmful pollution: %d µL" % pollution.harmful_ul
	water_value_label.text = "%.3f ml" % (float(amounts.get(LIQ.Component.WATER, 0)) / 1000.0)
	mineral_value_label.text = "%.3f ml" % (float(amounts.get(LIQ.Component.MINERALS, 0)) / 1000.0)
	electricity_value_label.text = "%d kJ" % farm.energy_kj
	machine_name_label.text = farm.effective_equipment().machine.label
	machine_state_label.text = "设备运行中 / Machine running" if farm.running else "设备已停止 / Machine stopped"
	var editor := farm.dna_editor
	match editor.stage:
		DNA.Stage.IDLE: dna_status_label.text = "DNA 编辑器待机 / DNA editor idle"
		DNA.Stage.RUNNING:
			var mode := "进行中 / Running" if farm.energy_kj >= DNA.ENERGY_PER_NIGHT_KJ else "等待电力 / Waiting for power"
			dna_status_label.text = "DNA · %s · %d/%d" % [mode, editor.progress, editor.operation.required_points]
		DNA.Stage.SUCCEEDED: dna_status_label.text = "DNA 应用成功 / DNA application succeeded"
		DNA.Stage.FAILED: dna_status_label.text = "DNA 应用失败 / DNA application failed"
	supplies.text = (
		"补给 / Supply: %.0f ml · %d kJ · %d 片\n" % [farm.water_supply_ul / 1000.0, farm.energy_supply_kj, farm.tablets]
		+ "每次 / Refill: %.3f ml · %d kJ" % [farm.refill_water_ul / 1000.0, farm.refill_energy_kj]
	)
	actions["water"].tooltip_text = "每次 / Per refill: %.3f ml" % (farm.refill_water_ul / 1000.0)
	actions["energy"].tooltip_text = "每次 / Per refill: %d kJ" % farm.refill_energy_kj
	crop_menu.disabled = not farm.configured or farm.plant != null
	crop_menu.select(farm.catalog.find(farm.crop))
	var selected_item: Variant = stored_items.get_selected_metadata() if stored_items.selected >= 0 else null
	if inventory_seed_choice != null and not farm.seed_stock(inventory_seed_choice.definition).has(inventory_seed_choice):
		inventory_seed_choice = null
	stored_items.clear()
	for definition in farm.catalog:
		for item: Farm.Seed in farm.seed_stock(definition):
			stored_items.add_item("%s / %s" % [_inventory_tile_label(item).get_slice("\n", 0), definition.name_en])
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
	inventory_caption.text = "库存 / Inventory · %d / %d" % [farm.occupied_slots(), farm.inventory_capacity]
	var entries := {}
	for index in stored_items.item_count:
		var item: Variant = stored_items.get_item_metadata(index)
		if workshop != null and item is String:
			for unit in farm.products[item]:
				entries[product_unit_key(item, unit)] = {
					"item": item,
					"icon": art.texture(inventory_icon_key(item), "seed"),
					"tooltip": item + "\n收获物 / Produce · 1",
				}
			continue
		entries[_inventory_key(item)] = {
			"icon": art.texture(inventory_icon_key(item), "seed"),
			"tooltip": _inventory_tooltip(item, stored_items.get_item_text(index)),
		}
	var selected_key := _inventory_key(stored_items.get_selected_metadata()) if restored_index >= 0 else ""
	inventory_tiles.sync(entries, farm.inventory_capacity, selected_key, farm.can_act())
	if workshop != null:
		workshop.refresh()
	_update_inventory_icon()
	actions["seed_supply"].disabled = not farm.configured or farm.occupied_slots() >= farm.inventory_capacity
	actions["drain"].disabled = not farm.configured or farm.vessel.total_ul() == 0
	var mature := farm.plant != null and farm.plant.stage == Farm.Plant.Stage.MATURE
	var plant := farm.plant
	cultivation_art.render(plant != null, plant.genetics.crop.species if plant != null else ReferenceCrop.Species.UNKNOWN,
		plant.growth if plant != null else 0, plant.target if plant != null else 0, mature, farm.running)
	growth_meter.max_value = farm.plant.target if farm.plant != null else 1
	growth_meter.value = farm.plant.growth if farm.plant != null else 0
	health_meter.max_value = 10000
	health_meter.value = plant.health if plant != null else 0
	solution_meter.max_value = maxi(1, farm.vessel.capacity_ul())
	solution_meter.value = farm.vessel.total_ul()
	actions["plant"].disabled = not farm.configured or farm.plant != null or farm.seed_count(farm.crop) == 0
	actions["plant"].disabled = actions["plant"].disabled or farm.seed_edit_locked(farm.selected_seed())
	actions["genetics"].disabled = not farm.configured
	actions["run"].disabled = not farm.configured or farm.plant == null or mature
	actions["run"].text = "停止 / Stop" if farm.running else "启动 / Start"
	actions["harvest"].disabled = not mature
	contextual_action_key = "harvest" if mature else ("plant" if farm.plant == null else "run")
	var primary := actions[contextual_action_key]
	contextual_action.text = primary.text
	contextual_action.disabled = primary.disabled
	contextual_action.tooltip_text = _rejection(contextual_action_key) if primary.disabled else ""
	for action in ["water", "tablet", "energy"]:
		actions[action].disabled = not farm.configured
	if farm.crop == null:
		crop_empty_title.text = "配置无效 / Invalid configuration"
		return
	var displayed_crop := farm.plant.genetics.crop if farm.plant != null else farm.crop
	crop_menu.tooltip_text = "%s / %s" % [displayed_crop.name_zh, displayed_crop.name_en]
	crop_icon.texture = art.texture(Art.species_key(displayed_crop.species))
	crop_empty_title.text = "%s / %s" % [displayed_crop.name_zh, displayed_crop.name_en]
	var concentration: Variant = farm.vessel.mineral_concentration_pct()
	var concentration_text := "未定义 / undefined" if concentration == null else ("%.3f%%" % concentration)
	var band := LIQ.classify_mineral_band(concentration, displayed_crop.mineral_low_pct, displayed_crop.mineral_high_pct)
	var condition := "无法计算 / Critical: undefined"
	var condition_color := Color("#E16D6D")
	match band:
		LIQ.Band.IN_RANGE:
			condition = "适宜 / Healthy band"
			condition_color = Color("#E4EDF2")
		LIQ.Band.BELOW:
			condition = "偏低 / Warning: low minerals"
			condition_color = Color("#E9B65A")
		LIQ.Band.ABOVE:
			condition = "偏高 / Warning: high minerals"
			condition_color = Color("#E9B65A")
	crop_empty_description.add_theme_color_override("font_color", condition_color)
	crop_empty_description.text = (
		"混合液 / Solution: %.1f / %.0f ml\n" % [farm.vessel.total_ul() / 1000.0, farm.vessel.capacity_ul() / 1000.0]
		+ "矿物 / Minerals: %s (%.2f–%.2f%%)\n" % [concentration_text, displayed_crop.mineral_low_pct, displayed_crop.mineral_high_pct]
		+ condition + "\n" + machine_state_label.text
	)
	if farm.plant == null:
		crop_growth_label.text = "尚未播种 / No plant · 种源 / Seeds: %d" % farm.seed_count(farm.crop)
		return
	crop_growth_label.text = (
		"生长 / Growth: %d / %d\n" % [farm.plant.growth, farm.plant.target]
		+ "健康 / Health: %.2f%%\n" % farm.plant.score()
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
	if workshop != null:
		workshop.night_finished(outcome)
	var completed := outcome as Farm.FarmOutcome
	if outcome.status != GameState.NightStatus.GROWN or completed == null:
		control_hint.text = outcome.detail
		return
	last_night = completed
	control_hint.text = (
		"生长 / Growth +%d · 健康损失 / Health loss: %d · 评分 / Score %.2f%%\n" % [
			completed.growth_gained, completed.health_loss, completed.resulting_health / 100.0]
		+ "伤害 / Damage · 矿物 / Minerals %d · 污染 / Pollution %d" % [
			completed.mineral_damage, completed.pollution_damage]
	)
