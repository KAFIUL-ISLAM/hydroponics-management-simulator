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
	for name: String in expected:
		var hotspot: Button = ui.hotspots[name]
		var rectangle := hotspot.get_global_rect()
		var center := (rectangle.get_center() - scene_rect.position) / scene_rect.size
		_check(scene_rect.encloses(rectangle) and center.distance_to(expected[name]) < 0.015, "hotspot alignment")
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
	_check(ui.inventory_tiles.item_count == ui.stored_items.item_count and ui.inventory_tiles.get_item_text(0) != ui.inventory_tiles.get_item_text(3), "distinct genetic seed tiles")
	ui.inventory_tiles.item_selected.emit(3)
	_check(is_same(farm.selected_seed(), modified_seed), "tile selects actual modified seed")
	ui.actions["genetics"].pressed.emit()
	_check(ui.genetics_dialog.dialog_text.contains("Fast Growth 2") and ui.genetics_dialog.dialog_text.contains(str(modified_seed.get_instance_id())), "Genes inspects exact tile identity")
	ui.genetics_dialog.hide()
	ui.actions["dna"].pressed.emit()
	_check(is_same(ui.dna_seed.get_selected_metadata(), modified_seed), "DNA inspects exact tile identity")
	ui.dna_dialog.hide()
	ui.inventory_tiles.item_selected.emit(0)
	ui.actions["discard"].pressed.emit()
	ui.inventory_tiles.item_selected.emit(3)
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
	viewport.free()

func _check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("ENVIRONMENT_UI_CHECK_FAILED: " + message)
