extends Node

const Dashboard = preload("res://scenes/coffee_dashboard.tscn")
const Chamber = preload("res://scripts/cultivation_art.gd")
var checks := 0
var failures := 0

func _ready() -> void:
	await _check_view(Vector2i(1280, 720))
	await _check_view(Vector2i(1920, 1080))
	print("ENVIRONMENT_UI_TEST_RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _check_view(dimensions: Vector2i) -> void:
	var viewport := SubViewport.new()
	viewport.size = dimensions
	viewport.gui_embed_subwindows = true
	add_child(viewport)
	var ui = Dashboard.instantiate()
	viewport.add_child(ui)
	await get_tree().process_frame
	await get_tree().process_frame
	var bounds := Rect2(Vector2.ZERO, Vector2(dimensions))
	var scene_rect: Rect2 = ui.cultivation_art.scene.get_global_rect()
	var expected := {"cultivation": Vector2(0.505, 0.1275), "analysis": Vector2(0.20, 0.6075), "equipment": Vector2(0.89, 0.6775)}
	for hotspot_name: String in expected:
		var hotspot: Button = ui.hotspots[hotspot_name]
		var rectangle := hotspot.get_global_rect()
		var center := (rectangle.get_center() - scene_rect.position) / scene_rect.size
		_check(scene_rect.encloses(rectangle) and center.distance_to(expected[hotspot_name]) < 0.015, "hotspot alignment")
		_check(hotspot.focus_mode == Control.FOCUS_ALL and not hotspot.tooltip_text.is_empty(), "hotspot focus and tooltip")
	var farm = ui.farm
	ui.hotspots["analysis"].pressed.emit()
	_check(ui.liquid_dialog.visible and not ui.equipment_dialog.visible, "analysis routing")
	ui.liquid_dialog.hide()
	ui.hotspots["equipment"].pressed.emit()
	_check(ui.equipment_dialog.visible and not ui.liquid_dialog.visible, "gear routing")
	ui.equipment_dialog.hide()
	ui.hotspots["cultivation"].pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	var cultivation_bounds := Rect2i(ui.cultivation_dialog.position, ui.cultivation_dialog.size)
	_check(ui.cultivation_dialog.visible and farm.plant == null and ui.game_state.current_day == 1, "chamber hotspot has no gameplay side effect")
	var modal_rects: Array[Rect2] = []
	for key: String in ["plant", "run", "harvest"]:
		var button: Button = ui.actions[key]
		var rectangle := button.get_global_rect()
		_check(Rect2(Vector2.ZERO, Vector2(cultivation_bounds.size)).encloses(rectangle) and button.focus_mode == Control.FOCUS_ALL, "cultivation dialog controls reachable")
		for previous: Rect2 in modal_rects:
			_check(not previous.intersects(rectangle), "cultivation controls do not overlap")
		modal_rects.append(rectangle)
	_check(Rect2i(Vector2i.ZERO, dimensions).encloses(cultivation_bounds), "cultivation dialog bounds")
	ui.cultivation_dialog.hide()
	var native_seed = farm.beans.front()
	farm.supply_modified_coffee()
	var modified_seed = farm.beans.back()
	ui._render()
	var modified_slot: int = ui.inventory_tiles.slots.find(ui._inventory_key(modified_seed))
	_check(ui.inventory_tiles.rows.size() == ui.stored_items.item_count and ui.inventory_tiles.get_item_tooltip(0) != ui.inventory_tiles.get_item_tooltip(modified_slot), "distinct genetic seed tiles")
	ui.inventory_tiles.item_selected.emit(modified_slot)
	_check(is_same(farm.selected_seed(), modified_seed), "tile selects actual modified seed")
	ui.actions["genetics"].pressed.emit()
	_check(ui.genetics_dialog.dialog_text.contains("Fast Growth 2") and ui.genetics_dialog.dialog_text.contains(str(modified_seed.get_instance_id())), "Genes inspects exact tile identity")
	ui.genetics_dialog.hide()
	ui.actions["dna"].pressed.emit()
	_check(is_same(ui.dna_seed.get_selected_metadata(), modified_seed), "DNA inspects exact tile identity")
	ui.dna_dialog.hide()
	ui.inventory_tiles.item_selected.emit(0)
	ui.actions["discard"].pressed.emit()
	ui.inventory_tiles.item_selected.emit(modified_slot)
	ui.confirm_action.confirmed.emit()
	ui.confirm_action.hide()
	_check(not farm.beans.has(native_seed) and farm.beans.has(modified_seed), "refresh preserves confirmation target")
	_check(ui.contextual_action_key == "plant" and not ui.contextual_action.disabled, "plant enabled")
	ui.contextual_action.pressed.emit()
	_check(is_same(farm.plant.seed_item, modified_seed) and farm.plant.target == 15, "context plants selected seed")
	_check(ui.contextual_action_key == "run" and not ui.contextual_action.disabled, "start enabled")
	ui.contextual_action.pressed.emit()
	_check(ui.contextual_action.text.contains("Stop") and farm.running, "stop is shown when running")
	var calls := [0]
	ui.game_state.night_processing_started.connect(func(_day: int) -> void:
		calls[0] += 1
		ui.game_state.start_night()
	)
	ui.next_night_button.pressed.emit()
	_check(calls[0] == 1 and ui.game_state.current_day == 2, "one settlement despite reentry")
	_check(ui.growth_meter.max_value == 15 and ui.growth_meter.value == 8 and ui.health_meter.value == farm.plant.health and ui.solution_meter.value == farm.vessel.total_ul(), "authoritative progress")
	ui.next_night_button.pressed.emit()
	_check(ui.growth_meter.value == 15 and farm.plant.growth == 16 and ui.cultivation_art.stage == Chamber.Stage.MATURE, "visual clamp and mature mapping")
	_check(ui.contextual_action_key == "harvest" and not ui.contextual_action.disabled, "collect enabled")
	await get_tree().process_frame
	await get_tree().process_frame
	for control: Control in [ui.inventory_tiles, ui.health_meter, ui.solution_meter, ui.contextual_action, ui.next_night_button]:
		_check(bounds.encloses(control.get_global_rect()), "essential control remains in view")
	await _check_inventory(viewport, ui)
	viewport.free()

func _check_inventory(viewport: SubViewport, ui) -> void:
	var grid = ui.inventory_tiles
	var farm = ui.farm
	var seed_item = farm.beans.front()
	var seed_key: String = ui._inventory_key(seed_item)
	var product_key: String = farm.crop.product_name + " · Test grade"
	farm.products[product_key] = 2
	ui._render()
	await get_tree().process_frame
	var source: int = grid.slots.find(seed_key)
	var product_slot: int = grid.slots.find(ui._inventory_key(product_key))
	var empty: int = grid.slots.find("")
	_check(not ui.stored_items.visible and grid.get_item_text(source).is_empty() and grid.get_item_icon(source) != null, "icon-only inventory")
	_check(grid.get_item_tooltip(source).contains("Growth target") and grid.get_item_tooltip(source).contains("Seed"), "seed hover uses effective values")
	_check(grid.get_item_tooltip(product_slot).contains(product_key) and grid.get_item_tooltip(product_slot).ends_with("2"), "product hover uses live stack count")
	var origin: Vector2 = grid.get_global_rect().position
	var from: Vector2 = origin + _slot_point(grid, source)
	var target: Vector2 = origin + _slot_point(grid, empty)
	var original_count: int = farm.occupied_slots()
	_start_drag(viewport, from)
	_check(viewport.gui_is_dragging(), "mouse starts an actual inventory drag")
	_move_mouse(viewport, target, MOUSE_BUTTON_MASK_LEFT)
	_check(viewport.gui_is_dragging() and grid._highlight == empty and grid.get_item_custom_bg_color(empty) == grid.VALID_COLOR, "empty slot shows valid drop feedback")
	_mouse_button(viewport, target, false)
	_check(grid.slots[empty] == seed_key and grid.slots[source].is_empty(), "GUI drop moves tile into empty cell")
	_check(farm.beans.has(seed_item) and farm.products[product_key] == 2 and farm.occupied_slots() == original_count, "drop preserves original inventory and quantity")
	ui._render()
	await get_tree().process_frame
	_check(grid.slots[empty] == seed_key, "placement survives dashboard refresh")
	var swap_target: Vector2 = origin + _slot_point(grid, product_slot)
	_start_drag(viewport, target)
	_move_mouse(viewport, swap_target, MOUSE_BUTTON_MASK_LEFT)
	_mouse_button(viewport, swap_target, false)
	_check(grid.slots[product_slot] == seed_key and grid.slots[empty] == ui._inventory_key(product_key), "occupied slots swap by identity")
	_mouse_button(viewport, swap_target, true)
	_mouse_button(viewport, swap_target, false)
	_check(is_same(ui.stored_items.get_selected_metadata(), seed_item), "moved icon still selects its exact seed")
	await get_tree().process_frame
	_start_drag(viewport, target)
	_move_mouse(viewport, swap_target, MOUSE_BUTTON_MASK_LEFT)
	_move_mouse(viewport, target, MOUSE_BUTTON_MASK_LEFT)
	_check(grid._highlight == empty and grid.get_item_custom_bg_color(empty) == grid.INVALID_COLOR, "same-cell drop shows invalid feedback")
	var outside := Vector2(3, 3)
	_move_mouse(viewport, outside, MOUSE_BUTTON_MASK_LEFT)
	_mouse_button(viewport, outside, false)
	_check(grid.slots[product_slot] == seed_key and grid._highlight == -1 and farm.occupied_slots() == original_count, "outside drop leaves original ownership and placement")
	_check(not grid._can_drop_data(_slot_point(grid, source), {"key": seed_key}), "foreign or expired drag rejected")
	_start_drag(viewport, swap_target)
	_check(viewport.gui_is_dragging(), "seed drag starts before removal")
	_check(farm.discard_seed_instance(seed_item), "remove original seed during active drag")
	ui._render()
	await get_tree().process_frame
	var vacant: Vector2 = origin + _slot_point(grid, source)
	_move_mouse(viewport, vacant, MOUSE_BUTTON_MASK_LEFT)
	_mouse_button(viewport, vacant, false)
	_check(not grid.slots.has(seed_key) and not farm.beans.has(seed_item) and farm.occupied_slots() == original_count - 1, "stale drag cannot restore a removed seed")
	farm.discard_product(product_key)
	ui._render()
	_check(grid.get_item_tooltip(empty).ends_with("1"), "product tooltip refreshes after stock changes")
	farm.discard_product(product_key)
	for definition in farm.catalog:
		for owned_seed in farm.seed_stock(definition).duplicate():
			farm.discard_seed_instance(owned_seed)
	ui._render()
	_check(grid.rows.is_empty() and grid.get_selected_items().is_empty() and ui.actions["discard"].disabled, "empty inventory clears selection and disables discard")

func _slot_point(grid: ItemList, slot: int) -> Vector2:
	return grid.get_item_rect(slot).get_center()

func _start_drag(viewport: SubViewport, position: Vector2) -> void:
	_move_mouse(viewport, position, 0)
	_mouse_button(viewport, position, true)
	_move_mouse(viewport, position + Vector2(12, 0), MOUSE_BUTTON_MASK_LEFT)

func _move_mouse(viewport: SubViewport, position: Vector2, mask: int) -> void:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.relative = Vector2(12, 0)
	event.button_mask = mask
	viewport.push_input(event, true)

func _mouse_button(viewport: SubViewport, position: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.pressed = pressed
	viewport.push_input(event, true)

func _check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("ENVIRONMENT_UI_CHECK_FAILED: " + message)
