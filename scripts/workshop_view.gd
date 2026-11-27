extends Control
## Projects the existing farm stores and pending harvest into physical interactions.

const Art = preload("res://scripts/orbital_art.gd")
const Farm = preload("res://scripts/coffee_farm.gd")
const Equipment = preload("res://scripts/hydroponic_equipment.gd")
const Slot = preload("res://scripts/workshop_slot.gd")
const InventoryGrid = preload("res://scripts/inventory_grid.gd")
const ChamberArt = preload("res://scripts/workshop_chamber_art.gd")
const NightFeedback = preload("res://scripts/workshop_night_feedback.gd")
const Manual = preload("res://scripts/workshop_manual.gd")
const WATER := "supply:water"
const ENERGY := "supply:energy"
const TABLET := "supply:tablet"
const MODULE := "module:"
const MACHINE := "machine:"
const ANALYSER := "device:analyse"
const GENETICS := "device:genes"
const DNA := "device:dna"
const SIZE := Vector2(52, 48)
const OUTPUT_COLUMNS := 5
const MOTION_SETTINGS := "user://workshop_presentation.cfg"
# Bounds of the exposed dustbin lid in the source image.
const BIN_UV := Rect2(0.201, 0.635, 0.100, 0.080)

var dashboard
var farm: Farm
var art: Art
var day: Label
var message: Label
var message_chip: PanelContainer
var status_chip: PanelContainer
var status_text: Label
var status_icon: TextureRect
var manual: Manual
var manual_button: Button
var machine: Button
var machine_panel: PanelContainer
var slots: Dictionary[String, Slot] = {}
var crop_art: TextureRect
var chamber_art: ChamberArt
var water_level: ProgressBar
var power_level: ProgressBar
var output_slots: Array[Slot] = []
var output_grid: GridContainer
var visible_output_keys: Array[String] = []
var empty_slot_style: StyleBoxFlat
var collecting := false
var charge_reference := 1
var night_fade: ColorRect
var output_drag: Dictionary = {}
var transition: Tween
var message_tween: Tween
var machine_drag_source: Slot
var supply_tray: InventoryGrid
var backdrop: TextureRect
var dustbin: Slot
var tools: Dictionary[String, Slot] = {}
var drop_targets: Array[Slot] = []
var night_feedback: NightFeedback
var reduced_motion := false
var motion_button: Button
var growth_pulse: Tween
var before_crop_texture: Texture2D
var blocker_slot := ""
var blocker_detail := ""
var blocker_context: Array = []
var blocker_style: StyleBoxFlat

func setup(ui: Control) -> void:
	dashboard = ui
	farm = ui.farm
	charge_reference = maxi(1, farm.energy_kj)
	art = ui.art
	var preferences := ConfigFile.new()
	if preferences.load(MOTION_SETTINGS) == OK:
		reduced_motion = preferences.get_value("accessibility", "reduced_motion", false) == true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.move_child(self, ui.workstation_shade.get_index())
	ui.get_node("SafeArea").hide()
	backdrop = Art.decoration(art.texture("laboratory"))
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	chamber_art = ChamberArt.new(self, backdrop, art)
	crop_art = chamber_art.sprite
	machine = Button.new()
	machine.flat = true
	machine.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_child(machine)
	_place(machine, Vector2(0.32, 0.12), Vector2(0.66, 0.70))
	machine.gui_input.connect(_machine_input)
	_build_dustbin()
	day = Label.new()
	add_child(day)
	day.position = Vector2(18, 14)
	day.add_theme_font_size_override("font_size", 21)
	day.add_theme_color_override("font_shadow_color", Color.BLACK)
	day.add_theme_constant_override("shadow_offset_x", 2)
	day.add_theme_constant_override("shadow_offset_y", 2)
	_build_inventory()
	_build_machine()
	_build_tool_dock()
	_build_status_chips()
	night_feedback = NightFeedback.new()
	add_child(night_feedback)
	_place(night_feedback, Vector2(0.04, 0.18), Vector2(0.68, 0.24))
	night_feedback.setup(art)
	ui.game_state.night_processing_started.connect(_night_started)
	night_fade = ColorRect.new()
	night_fade.color = Color("#090f24")
	night_fade.modulate.a = 0.0
	night_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(night_fade)
	night_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _place(control: Control, start: Vector2, end: Vector2) -> void:
	control.set_anchor(SIDE_LEFT, start.x)
	control.set_anchor(SIDE_TOP, start.y)
	control.set_anchor(SIDE_RIGHT, end.x)
	control.set_anchor(SIDE_BOTTOM, end.y)
	control.offset_left = 0
	control.offset_top = 0
	control.offset_right = 0
	control.offset_bottom = 0

func _build_status_chips() -> void:
	var positioner := CenterContainer.new()
	positioner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(positioner)
	_place(positioner, Vector2(0.04, 0.075), Vector2(0.76, 0.165))
	var stack := VBoxContainer.new()
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	positioner.add_child(stack)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#101927e8")
	style.border_color = Color("#70889ba6")
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	status_chip = _make_status_chip(stack, style)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_chip.add_child(row)
	status_icon = Art.decoration(null)
	status_icon.custom_minimum_size = Vector2(20, 20)
	row.add_child(status_icon)
	status_text = _make_status_label(row)
	message_chip = _make_status_chip(stack, style)
	message = _make_status_label(message_chip)

func _make_status_chip(stack: VBoxContainer, style: StyleBoxFlat) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	chip.add_theme_stylebox_override("panel", style)
	stack.add_child(chip)
	chip.hide()
	return chip

func _make_status_label(parent: Container) -> Label:
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 15)
	parent.add_child(label)
	return label

func _build_inventory() -> void:
	var dock := PanelContainer.new()
	add_child(dock)
	_place(dock, Vector2(0.14, 1), Vector2(0.86, 1))
	dock.offset_top = -184
	dock.offset_bottom = -12
	var column := VBoxContainer.new()
	dock.add_child(column)
	var bar := HBoxContainer.new()
	column.add_child(bar)
	dashboard.inventory_caption.reparent(bar, false)
	dashboard.next_night_button.reparent(bar, false)
	dashboard.next_night_button.text = "☾  下一夜 / Next night"
	var compartments := HBoxContainer.new()
	compartments.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(compartments)
	var grid = dashboard.inventory_tiles
	grid.reparent(compartments, false)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.fixed_icon_size = Vector2i(32, 32)
	grid.fixed_column_width = 43
	grid.max_columns = 12
	grid.placement_allowed = farm.can_act
	grid.custom_minimum_size.x = 595
	grid.external_can_drop = _can_return_to_inventory
	grid.external_drop = _return_to_inventory
	var tray_column := VBoxContainer.new()
	tray_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tray_column.custom_minimum_size.x = 280
	compartments.add_child(tray_column)
	var title := Label.new()
	title.text = "补给与设备 / Supplies & equipment"
	title.add_theme_font_size_override("font_size", 12)
	tray_column.add_child(title)
	supply_tray = InventoryGrid.new()
	supply_tray.icon_mode = ItemList.ICON_MODE_TOP
	supply_tray.fixed_icon_size = Vector2i(27, 27)
	supply_tray.fixed_column_width = 37
	supply_tray.same_column_width = true
	supply_tray.max_columns = 6
	supply_tray.placement_allowed = farm.can_act
	supply_tray.size_flags_vertical = Control.SIZE_EXPAND_FILL
	supply_tray.external_can_drop = _can_return_to_inventory
	supply_tray.external_drop = _return_to_inventory
	tray_column.add_child(supply_tray)

func _build_machine() -> void:
	empty_slot_style = StyleBoxFlat.new()
	empty_slot_style.bg_color = Color("#101b25")
	empty_slot_style.border_color = Color("#314454")
	empty_slot_style.set_border_width_all(1)
	empty_slot_style.set_corner_radius_all(5)
	blocker_style = empty_slot_style.duplicate() as StyleBoxFlat
	blocker_style.border_color = Color("#ffbd78")
	blocker_style.set_border_width_all(2)
	machine_panel = PanelContainer.new()
	add_child(machine_panel)
	_place(machine_panel, Vector2(1, 0.12), Vector2(1, 0.12))
	machine_panel.offset_left = -398
	machine_panel.offset_right = -18
	var column := VBoxContainer.new()
	machine_panel.add_child(column)
	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_END
	column.add_child(header)
	var info := Button.new()
	info.text = "ⓘ"
	info.tooltip_text = "液体与污染 / Liquid and pollution"
	info.pressed.connect(dashboard._show_analysis)
	header.add_child(info)
	motion_button = Button.new()
	motion_button.toggle_mode = true
	motion_button.button_pressed = reduced_motion
	motion_button.text = "◐"
	motion_button.toggled.connect(_save_motion_preference)
	header.add_child(motion_button)
	_update_motion_hint()
	var close := Button.new()
	close.text = "×"
	close.tooltip_text = "关闭 / Close"
	close.pressed.connect(machine_panel.hide)
	header.add_child(close)
	var inputs := HBoxContainer.new()
	column.add_child(inputs)
	for kind: String in ["power", "water", "seed", "modules", "chassis"]:
		_make_slot(inputs, kind)
	slots["modules"].produce = _begin_module_drag
	slots["chassis"].pressed.connect(func() -> void: dashboard._present(dashboard.equipment_dialog))
	var level_row := HBoxContainer.new()
	column.add_child(level_row)
	power_level = _level(level_row, Color("#ffd062"))
	water_level = _level(level_row, Color("#52cfff"))
	output_grid = GridContainer.new()
	output_grid.columns = OUTPUT_COLUMNS
	column.add_child(output_grid)
	machine_panel.hide()

func _make_slot(parent: Container, kind: String) -> Slot:
	var slot := Slot.new()
	slot.custom_minimum_size = SIZE
	slot.expand_icon = true
	slot.add_theme_constant_override("icon_max_width", 35)
	parent.add_child(slot)
	slots[kind] = slot
	if not kind.begins_with("output"):
		slot.accepts = _accepts.bind(kind)
		slot.receive = _receive.bind(kind)
		drop_targets.append(slot)
	return slot

func _level(parent: Container, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 6)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	bar.add_theme_stylebox_override("fill", fill)
	parent.add_child(bar)
	return bar

func _machine_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and event.double_click:
		machine_panel.show()
		accept_event()
	elif event.is_action_pressed("ui_accept") and event is InputEventKey:
		machine_panel.show()
		accept_event()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F1:
		_open_manual()
		get_viewport().set_input_as_handled()
		return
	if machine_panel.visible and event.is_action_pressed("ui_cancel"):
		machine_panel.hide()
		get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	var viewport := get_viewport()
	if event.pressed:
		if event.double_click and dashboard != null and _contains_pointer(dashboard.next_night_button, event.position):
			viewport.set_input_as_handled()
		return
	if not viewport.gui_is_dragging():
		return
	var data: Variant = viewport.gui_get_drag_data()
	var grid: InventoryGrid = _drag_source(data)
	var key: String = grid.drag_key(data)
	var over_source := _contains_pointer(grid, event.position)
	if not key.is_empty() and not over_source:
		# Release can arrive before the last motion. Use its position, not the cached hover.
		var index: int = grid.slots.find(key)
		var icon := grid.get_item_icon(index)
		var source := grid.get_global_transform_with_canvas() * grid.get_item_rect(index).get_center()
		var accepted := false
		for target: Slot in drop_targets:
			if _contains_pointer(target, event.position):
				accepted = target.try_transfer(data)
				break
		if not accepted:
			_animate_return(icon, event.position, source)
		viewport.set_input_as_handled()
		viewport.gui_cancel_drag()
	elif not output_drag.is_empty() and is_same(data, output_drag):
		var icon := machine_drag_source.icon
		var source := machine_drag_source.get_global_transform_with_canvas() * (machine_drag_source.size * 0.5)
		var over_inventory := _contains_pointer(dashboard.inventory_tiles, event.position) or _contains_pointer(supply_tray, event.position)
		if not over_inventory or not _return_to_inventory(data):
			_animate_return(icon, event.position, source)
		viewport.set_input_as_handled()
		viewport.gui_cancel_drag()

func _contains_pointer(control: Control, viewport_position: Vector2) -> bool:
	var local_point := control.get_global_transform_with_canvas().affine_inverse() * viewport_position
	return control.is_visible_in_tree() and Rect2(Vector2.ZERO, control.size).has_point(local_point)

func _animate_return(icon: Texture2D, release: Vector2, source: Vector2) -> void:
	if icon == null or reduced_motion:
		return
	var ghost := Art.decoration(icon)
	ghost.size = Vector2(32, 32)
	add_child(ghost)
	var local_canvas := get_global_transform_with_canvas().affine_inverse()
	ghost.position = local_canvas * release - ghost.size * 0.5
	var settle := create_tween().set_parallel()
	settle.tween_property(ghost, "position", local_canvas * source - ghost.size * 0.5, 0.20)
	settle.tween_property(ghost, "modulate:a", 0.0, 0.20)
	settle.chain().tween_callback(ghost.queue_free)

func _drag_source(data: Variant) -> InventoryGrid:
	return supply_tray if not supply_tray.drag_key(data).is_empty() else dashboard.inventory_tiles

func _refresh_supply_tray() -> void:
	var entries := {}
	if farm.water_supply_ul >= farm.refill_water_ul and farm.refill_water_ul > 0:
		_row(entries, WATER, "water", "纯水容器 / Water canister · Supply\n%.3f ml per refill · %.3f ml remaining" % [
			farm.refill_water_ul / 1000.0, farm.water_supply_ul / 1000.0])
	if farm.energy_supply_kj >= farm.refill_energy_kj and farm.refill_energy_kj > 0:
		_row(entries, ENERGY, "energy", "电池 / Energy cell · Supply\n%d kJ per charge · %d kJ remaining" % [
			farm.refill_energy_kj, farm.energy_supply_kj])
	if farm.tablets > 0:
		_row(entries, TABLET, "tablet", "营养片 / Mineral tablet · Supply\n%d remaining · Drop on the water slot" % farm.tablets)
	for id in farm.demo_modules:
		if farm.available_modules(id) > 0:
			var module := Equipment.module_definition(id)
			if module != null:
				_row(entries, MODULE + str(id), "module", "%s · Module\n%s\n%d available" % [
					module.label, module.description, farm.available_modules(id)])
	for id in farm.demo_machines:
		if id != farm.machine_id:
			var item := Equipment.machine_definition(id)
			if item != null:
				_row(entries, MACHINE + str(id), "machine", "%s · Machine\n%d growth/night · %d kJ/night" % [
					item.label, item.growth, item.energy_kj])
	supply_tray.sync(entries, entries.size(), "", farm.can_act())

func _row(entries: Dictionary, key: String, icon_key: String, tooltip: String) -> void:
	entries[key] = {"icon": art.texture(icon_key, "module"), "tooltip": tooltip}

func _open_tool(tool_id: String) -> void:
	match tool_id:
		ANALYSER: dashboard._show_analysis()
		GENETICS: dashboard._show_genetics()
		DNA: dashboard._open_dna()

func _build_tool_dock() -> void:
	var dock := PanelContainer.new()
	add_child(dock)
	_place(dock, Vector2(1, 0), Vector2(1, 0))
	dock.offset_left = -249
	dock.offset_right = -18
	dock.offset_top = 10
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	dock.add_child(row)
	_make_tool(row, GENETICS, "dna", "种子分析仪 / Seed profile\nInspect genetics and effective crop properties")
	_make_tool(row, DNA, "station", "DNA 编辑器 / DNA editor\nPreview modification of a selected seed")
	_make_tool(row, ANALYSER, "analyser", "液体分析仪 / Liquid analyser\nInspect machine concentration and pollution")
	manual_button = Button.new()
	manual_button.text = "?"
	manual_button.tooltip_text = "种植手册 / Farming manual · F1"
	manual_button.pressed.connect(_open_manual)
	row.add_child(manual_button)
	manual = Manual.new()
	dashboard.add_child(manual)
	manual.setup(art.texture("seed"))
	manual.tool_requested.connect(_open_manual_tool)
	dashboard.workstation_dialogs.append(manual)
	manual.visibility_changed.connect(dashboard._sync_workstation_layer)

func _open_manual() -> void:
	if not get_viewport().gui_is_dragging():
		dashboard._present(manual)

func _open_manual_tool(tool: String) -> void:
	var previous_focus: Control = dashboard.return_focus
	manual.hide()
	match tool:
		"equipment": dashboard._present(dashboard.equipment_dialog)
		"liquid": _open_tool(ANALYSER)
		"dna": _open_tool(DNA)
	dashboard.return_focus = previous_focus

func _make_tool(row: HBoxContainer, tool_id: String, icon_key: String, hint: String) -> void:
	var tool := Slot.new()
	tool.custom_minimum_size = Vector2(58, 58)
	tool.expand_icon = true
	tool.add_theme_constant_override("icon_max_width", 52)
	tool.icon = art.texture(icon_key)
	tool.tooltip_text = hint
	row.add_child(tool)
	tools[tool_id] = tool
	tool.pressed.connect(_open_tool.bind(tool_id))
	if tool_id != ANALYSER:
		tool.accepts = _accepts_tool_seed
		tool.receive = _inspect_seed.bind(tool_id)
		drop_targets.append(tool)

func _accepts_tool_seed(data: Variant) -> bool:
	return _find_seed(dashboard.inventory_tiles.drag_key(data)) != null

func _inspect_seed(data: Variant, tool_id: String) -> bool:
	var item := _find_seed(dashboard.inventory_tiles.drag_key(data))
	if item == null:
		return false
	if tool_id == GENETICS:
		dashboard._show_genetics(item)
	else:
		dashboard._open_dna(item)
	return true

func _build_dustbin() -> void:
	dustbin = Slot.new()
	dustbin.focus_mode = Control.FOCUS_NONE
	dustbin.tooltip_text = "垃圾箱 / Dustbin\nDrop a seed or harvested item to discard one"
	for style: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		dustbin.add_theme_stylebox_override(style, StyleBoxEmpty.new())
	add_child(dustbin)
	var glow := ColorRect.new()
	glow.color = Color(0.45, 1.0, 0.76, 0.31)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dustbin.add_child(glow)
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow.hide()
	dustbin.drop_glow = glow
	dustbin.accepts = _can_discard
	dustbin.receive = _discard
	drop_targets.append(dustbin)
	backdrop.resized.connect(_align_dustbin)
	_align_dustbin()

func _align_dustbin() -> void:
	if backdrop.texture == null:
		dustbin.hide()
		return
	var image := backdrop.texture.get_size()
	var factor := maxf(backdrop.size.x / image.x, backdrop.size.y / image.y)
	var image_size := image * factor
	dustbin.position = (backdrop.size - image_size) * 0.5 + BIN_UV.position * image_size
	dustbin.size = BIN_UV.size * image_size

func _discard_item(data: Variant) -> Variant:
	var key: String = dashboard.inventory_tiles.drag_key(data)
	var entry: Dictionary = dashboard.inventory_tiles.rows.get(key, {})
	if entry.has("item"):
		return entry.item
	if key.begins_with("product:"):
		var product := key.substr("product:".length())
		if farm.products.has(product):
			return product
		return null
	return _find_seed(key)

func _can_discard(data: Variant) -> bool:
	if not farm.can_act():
		return false
	var item: Variant = _discard_item(data)
	return item is String or (item is Farm.Seed and not farm.seed_edit_locked(item))

func _discard(data: Variant) -> bool:
	var item: Variant = _discard_item(data)
	var removed := farm.discard_seed_instance(item) if item is Farm.Seed else farm.discard_product(item)
	if removed:
		dashboard._render()
		_show_message("已丢弃一件 / One item discarded")
	return removed

func _accepts(data: Variant, kind: String) -> bool:
	if not farm.can_act():
		return false
	var key: String = _drag_source(data).drag_key(data)
	match kind:
		"water":
			return key == TABLET or (key == WATER and farm.vessel.capacity_ul() - farm.vessel.total_ul() >= farm.refill_water_ul)
		"power": return key == ENERGY
		"seed":
			var item := _find_seed(key)
			return farm.plant == null and item != null and not farm.seed_edit_locked(item) and item.analyze().valid()
		"modules":
			return key.begins_with(MODULE) and Equipment.resolve(farm.machine_id,
				_modules_with(key.get_slice(":", 1).to_int()), farm.demo_module_slots,
				farm.vessel.capacity_ul(), ReferenceCrop.Species.UNKNOWN).valid and not farm.running
		"chassis":
			if not key.begins_with(MACHINE) or farm.running:
				return false
			var model := Equipment.machine_definition(key.get_slice(":", 1).to_int())
			return model != null and (model.supports_modules or farm.installed_modules.is_empty())
	return false

func _modules_with(id: int) -> Array[int]:
	var result := farm.installed_modules.duplicate()
	result.append(id)
	return result

func _find_seed(key: String) -> Farm.Seed:
	if key.begins_with("seed:"):
		for definition in farm.catalog:
			for item: Farm.Seed in farm.seed_stock(definition):
				if dashboard._inventory_key(item) == key:
					return item
	return null

func _receive(data: Variant, kind: String) -> bool:
	var key: String = _drag_source(data).drag_key(data)
	var accepted := false
	match kind:
		"water": accepted = farm.add_tablet() if key == TABLET else farm.add_water()
		"power":
			accepted = farm.add_energy()
			if accepted:
				charge_reference = maxi(charge_reference, farm.energy_kj)
		"modules": accepted = farm.install_module(key.get_slice(":", 1).to_int())
		"chassis": accepted = farm.select_machine(key.get_slice(":", 1).to_int())
		"seed":
			var item := _find_seed(key)
			if item != null and (farm.crop == item.definition or farm.select_species(farm.catalog.find(item.definition))):
				accepted = farm.select_seed(item.get_instance_id()) and farm.plant_bean()
	if accepted:
		if farm.plant != null and not farm.running and farm.plant.stage != Farm.Plant.Stage.MATURE:
			farm.toggle_running()
	else:
		_show_message("无法转移 / Transfer rejected")
	dashboard._render()
	return accepted

func _begin_module_drag() -> Variant:
	if not farm.can_act() or farm.running or farm.installed_modules.is_empty():
		return null
	machine_drag_source = slots["modules"]
	output_drag = {"module": farm.installed_modules.back()}
	return output_drag

func _has_output() -> bool:
	return farm.plant != null and farm.plant.stage == Farm.Plant.Stage.MATURE

func _can_return_to_inventory(data: Variant) -> bool:
	if not farm.can_act() or output_drag.is_empty() or not is_same(data, output_drag):
		return false
	var remaining := farm.installed_modules.duplicate()
	remaining.erase(output_drag.module)
	return not farm.running and output_drag.module in farm.installed_modules and Equipment.resolve(
		farm.machine_id, remaining, farm.demo_module_slots, farm.vessel.capacity_ul(),
		ReferenceCrop.Species.UNKNOWN).valid

func _return_to_inventory(data: Variant) -> bool:
	if not _can_return_to_inventory(data):
		return false
	var accepted := farm.remove_module(output_drag.module)
	if accepted:
		output_drag = {}
		_show_message("模组已归还 / Module returned")
		dashboard._render()
	return accepted

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		output_drag = {}
		machine_drag_source = null

func refresh() -> void:
	_refresh_supply_tray()
	_refresh_blocker()
	day.text = "第 %d 天 / Day %d" % [dashboard.game_state.current_day, dashboard.game_state.current_day]
	var equipment := farm.effective_equipment()
	var total_ml := farm.vessel.total_ul() / 1000.0
	var water_ml := float(farm.vessel.snapshot_ul().get(Farm.W, 0)) / 1000.0
	var planted := farm.plant
	var progress := "空舱 / Empty chamber"
	var crop_key := "seed"
	if planted != null:
		crop_key = Art.crop_key(planted.seed_item.definition.resource_path.get_file().get_basename())
		progress = "%s · %d/%d · HP %.2f%%" % [planted.genetics.crop.name_en, planted.growth, planted.target, planted.score()]
		var stage_key := crop_key + "_mature" if _has_output() else ("growing" if planted.growth > 0 else "seedling")
		chamber_art.render(stage_key)
	else:
		chamber_art.render("")
	var state := "运行 / Running" if farm.running else ("可收获 / Output ready" if _has_output() else "待机 / Idle")
	machine.tooltip_text = "%s · 水培机 / Hydroponic machine\n%s · %s\n%d kJ stored / %d kJ per night · %d growth/night\n效率 / Efficiency: %d · 双击 / Double-click" % [
		equipment.machine.label, state, progress, farm.energy_kj, equipment.energy_kj, equipment.growth, equipment.efficiency]
	_slot_view("power", "energy", "电力 / Power · %d kJ stored\nDrop an energy cell" % farm.energy_kj, farm.energy_kj > 0)
	_slot_view("water", "water", "水槽 / Water · %.3f ml pure / %.3f ml solution\nDrop a canister or mineral tablet" % [
		water_ml, total_ml], total_ml > 0)
	var seed_inserted := planted != null and not _has_output()
	var seed_icon: String = dashboard.inventory_icon_key(planted.seed_item) if seed_inserted else ""
	_slot_view("seed", seed_icon,
		"种子 / Seed · %s\n生产需要兼容种子 / Crop production requires a compatible seed" % (progress if seed_inserted else "空 / Empty"),
		seed_inserted)
	var chips := PackedStringArray()
	for id in farm.installed_modules:
		chips.append(Equipment.module_definition(id).label)
	_slot_view("modules", "module",
		"模组 / Modules · %d installed\n可选 / Optional. The machine can operate without modules.\n%s" % [
			chips.size(), "\n".join(chips)], not chips.is_empty())
	if not chips.is_empty():
		slots["modules"].tooltip_text += "\n拖回库存 / Drag to return: " + chips[-1]
	_slot_view("chassis", "machine", machine.tooltip_text + "\n点击查看设备 / Click for equipment controls")
	_refresh_output(crop_key)
	_refresh_machine_status()
	power_level.max_value = charge_reference
	power_level.value = farm.energy_kj
	power_level.tooltip_text = slots["power"].tooltip_text
	water_level.max_value = maxi(1, farm.vessel.capacity_ul())
	water_level.value = farm.vessel.total_ul()
	water_level.tooltip_text = slots["water"].tooltip_text

func _refresh_output(crop_key: String) -> void:
	var pending := farm.pending_output()
	var inventory_full := farm.occupied_slots() >= farm.inventory_capacity
	visible_output_keys.clear()
	var counts := PackedStringArray()
	var total := 0
	for key: String in pending:
		total += pending[key]
		counts.append("%s × %d" % [_output_name(key), pending[key]])
		for unit in mini(pending[key], OUTPUT_COLUMNS - visible_output_keys.size()):
			visible_output_keys.append(key)
	output_grid.visible = total > 0
	while output_slots.size() < visible_output_keys.size():
		var index := output_slots.size()
		var slot := _make_slot(output_grid, "output%d" % index)
		slot.pressed.connect(_collect_from_slot.bind(index))
		output_slots.append(slot)
	for index in output_slots.size():
		var slot := output_slots[index]
		var populated := index < visible_output_keys.size()
		slot.visible = populated
		slot.disabled = not populated
		slot.icon = null
		slot.tooltip_text = "输出槽 / Output slot · Empty"
		if populated:
			var key := visible_output_keys[index]
			var seed_output := key in [Farm.OUTPUT_SEED, Farm.OUTPUT_OFFSPRING]
			var icon_key: String = dashboard.inventory_icon_key(farm.plant.seed_item) if seed_output else crop_key
			slot.icon = art.texture(icon_key, crop_key)
			slot.text = ""
			slot.tooltip_text = _output_name(key) + "\n点击领取 / Click to collect one"
			if inventory_full:
				slot.add_theme_stylebox_override("normal", blocker_style)
				slot.tooltip_text += "\n库存已满 / Inventory full"
			else:
				slot.remove_theme_stylebox_override("normal")
			if index == visible_output_keys.size() - 1 and total > visible_output_keys.size():
				var extra := total - visible_output_keys.size()
				slot.text = "+%d" % extra
				slot.tooltip_text += "\n另有 %d 件 / %d additional outputs\n%s" % [extra, extra, "\n".join(counts)]

func _output_name(key: String) -> String:
	if key == Farm.OUTPUT_OFFSPRING:
		return farm.plant.genetics.crop.name_en + " · 繁殖种子 / Offspring seed"
	if key == Farm.OUTPUT_SEED:
		return farm.plant.genetics.crop.name_en + " · 种子 / Seed"
	return key + " · 收获物 / Produce"

func _collect_from_slot(index: int) -> void:
	if collecting or not farm.can_act() or index >= visible_output_keys.size():
		return
	var grid = dashboard.inventory_tiles
	var destination: int = grid.slots.find("")
	if destination < 0 or farm.occupied_slots() >= farm.inventory_capacity:
		_show_message("库存已满 / Inventory full")
		return
	var source := output_slots[index]
	var icon := source.icon
	var origin := source.get_global_rect().get_center()
	var item: Variant = farm.collect_one(visible_output_keys[index])
	if item == null:
		return
	var key: String = dashboard.product_unit_key(item, farm.products[item] - 1) if item is String else dashboard._inventory_key(item)
	grid.slots[destination] = key
	if reduced_motion:
		collecting = true
		dashboard._render()
		await get_tree().process_frame
		await get_tree().create_timer(0.25).timeout
		collecting = false
		return
	grid.arriving_key = key
	collecting = true
	dashboard._render()
	await get_tree().process_frame
	_animate_collection(icon, origin, destination)

func _animate_collection(icon: Texture2D, origin: Vector2, destination: int) -> void:
	var grid: ItemList = dashboard.inventory_tiles
	var ghost := Art.decoration(icon)
	ghost.size = Vector2(32, 32)
	add_child(ghost)
	var local := get_global_transform().affine_inverse()
	ghost.position = local * origin - ghost.size * 0.5
	var target := grid.get_global_transform() * grid.get_item_rect(destination).get_center()
	target = target.clamp(grid.get_global_rect().position, grid.get_global_rect().end)
	var motion := create_tween()
	motion.tween_property(ghost, "position", local * target - ghost.size * 0.5, 0.25)
	motion.tween_callback(func() -> void:
		ghost.queue_free()
		dashboard.inventory_tiles.reveal_arrival()
		collecting = false
	)

func _slot_view(kind: String, icon_key: String, hint: String, occupied := true) -> void:
	var slot := slots[kind]
	slot.icon = art.texture(icon_key) if occupied else null
	slot.tooltip_text = hint
	slot.text = "" if occupied else {"seed": "+", "modules": "◇", "power": "ϟ", "water": "◈"}.get(kind, "")
	if kind == blocker_slot:
		slot.add_theme_stylebox_override("normal", blocker_style)
		slot.tooltip_text += "\n" + blocker_detail
	elif occupied:
		slot.remove_theme_stylebox_override("normal")
	else:
		slot.add_theme_stylebox_override("normal", empty_slot_style)
	for color_name in ["font_color", "font_hover_color", "font_focus_color"]:
		slot.add_theme_color_override(color_name, Color("#7490a777"))

func _night_started(_day: int) -> void:
	night_feedback.capture(farm)
	before_crop_texture = crop_art.texture

func night_finished(outcome: GameState.NightOutcome) -> void:
	var crop_key := Art.species_key(farm.plant.genetics.crop.species) if farm.plant != null else "seed"
	night_feedback.publish(farm, crop_key)
	if _has_output() and farm.pending_output().is_empty() and farm.collect():
		dashboard._render()
	_apply_outcome_blocker(outcome)
	if transition != null:
		transition.kill()
	night_fade.modulate.a = 0.0
	if not reduced_motion:
		night_fade.modulate.a = 0.48
		transition = create_tween()
		transition.tween_property(night_fade, "modulate:a", 0.0, 0.42)
	_pulse_chamber()
	if not outcome.detail.is_empty():
		_show_message(outcome.detail if blocker_slot.is_empty() or blocker_slot == "seed" else "")
	elif night_feedback.metrics.has("output"):
		_show_message("生产完成 / Output ready")
	elif outcome.status == GameState.NightStatus.GROWN and _has_output():
		_show_message("生产完成，无产出 / Production finished with no output")
	elif before_crop_texture != crop_art.texture and night_feedback.metrics.has("growth"):
		_show_message("进入新生长阶段 / New growth stage")
	else:
		_show_message("")

func _blocker_context() -> Array:
	var context := [farm.plant, farm.running, farm.machine_id, farm.installed_modules.duplicate()]
	if blocker_slot != "water":
		context.append(farm.energy_kj)
	if blocker_slot != "power":
		context.append(farm.vessel.snapshot_ul())
	return context

func _clear_blocker() -> void:
	blocker_slot = ""
	blocker_detail = ""
	blocker_context.clear()

func _refresh_blocker() -> void:
	if blocker_slot.is_empty() or _blocker_context() == blocker_context:
		return
	if farm.plant == null or not farm.running:
		_clear_blocker()
		return
	match blocker_slot:
		"power":
			var required := farm.effective_equipment().energy_kj
			if farm.energy_kj >= required:
				_clear_blocker()
			else:
				blocker_detail = "电力不足 / Energy shortage: %d / %d kJ" % [farm.energy_kj, required]
		"water":
			var staged := Farm.Liquid.new(farm.vessel.capacity_ul())
			if staged.replenish(farm.vessel.snapshot_ul()) == Farm.Liquid.Status.OK:
				var crop := farm.plant.genetics.crop
				var outcome := staged.consume_night(crop.draw_ul, farm.effective_equipment().growth, crop.uptake_ul_per_point)
				if outcome.status == Farm.Liquid.Status.OK:
					_clear_blocker()
				else:
					blocker_detail = "营养液不足 / Mixed liquid shortage"
	if not blocker_slot.is_empty():
		blocker_context = _blocker_context()

func _refresh_machine_status() -> void:
	var label := ""
	var icon := ""
	var color := Color("#9cf1d3")
	if not blocker_slot.is_empty() and blocker_slot != "seed":
		label = blocker_detail
		icon = {"power": "energy", "water": "water", "chassis": "machine"}.get(blocker_slot, "")
		color = Color("#ffd2a1")
	elif _has_output():
		icon = Art.species_key(farm.plant.genetics.crop.species)
		if farm.occupied_slots() >= farm.inventory_capacity:
			label = "待收获，库存已满 / Harvest pending, inventory full"
			color = Color("#ffd2a1")
		else:
			label = "待收获，点击产出 / Harvest pending, click output"
	status_text.text = label
	status_text.add_theme_color_override("font_color", color)
	status_icon.texture = art.texture(icon)
	status_chip.visible = not label.is_empty()

func _apply_outcome_blocker(outcome: GameState.NightOutcome) -> void:
	var previous := blocker_slot
	_clear_blocker()
	match outcome.status:
		GameState.NightStatus.SHORTAGE:
			blocker_slot = "power" if farm.energy_kj < farm.effective_equipment().energy_kj else "water"
		GameState.NightStatus.CONFIGURATION_ERROR:
			blocker_slot = "chassis"
		GameState.NightStatus.NO_CROP:
			if farm.plant == null:
				blocker_slot = "seed"
	if not blocker_slot.is_empty():
		blocker_detail = outcome.detail
		blocker_context = _blocker_context()
	if not previous.is_empty() or not blocker_slot.is_empty():
		refresh()

func _pulse_chamber() -> void:
	if growth_pulse != null:
		growth_pulse.kill()
	crop_art.modulate = Color.WHITE
	output_grid.modulate = Color.WHITE
	if reduced_motion:
		return
	var target: Control = crop_art
	if night_feedback.metrics.has("output"):
		target = output_grid
	if target == crop_art and not night_feedback.metrics.has("growth"):
		return
	target.modulate = Color(0.76, 1.0, 0.82)
	growth_pulse = create_tween()
	growth_pulse.tween_property(target, "modulate", Color.WHITE, 0.48 if target == output_grid or crop_art.texture != before_crop_texture else 0.25)

func _save_motion_preference(enabled: bool) -> void:
	set_reduced_motion(enabled)
	var preferences := ConfigFile.new()
	preferences.load(MOTION_SETTINGS)
	preferences.set_value("accessibility", "reduced_motion", enabled)
	preferences.save(MOTION_SETTINGS)

func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	motion_button.set_pressed_no_signal(enabled)
	_update_motion_hint()
	if enabled:
		if transition != null:
			transition.kill()
		night_fade.modulate.a = 0.0
		_pulse_chamber()

func _update_motion_hint() -> void:
	motion_button.tooltip_text = "减少动态效果 / Reduced motion · " + ("开 / On" if reduced_motion else "关 / Off")

func _show_message(detail: String) -> void:
	if message_tween != null:
		message_tween.kill()
	message.text = detail
	message_chip.modulate.a = 1.0
	if detail.is_empty():
		message_chip.hide()
		_clear_idle_hint()
		return
	message_tween = create_tween()
	message_tween.tween_interval(1.8)
	if reduced_motion:
		message_tween.tween_callback(message_chip.hide)
	else:
		message_tween.tween_property(message_chip, "modulate:a", 0.0, 0.3)
		message_tween.tween_callback(message_chip.hide)
	message_tween.tween_callback(_clear_idle_hint)
	message_chip.show()

func _clear_idle_hint() -> void:
	if blocker_slot == "seed":
		_clear_blocker()
		refresh()
