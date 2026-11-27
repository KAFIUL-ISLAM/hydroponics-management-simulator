extends Node

const UI = preload("res://scenes/coffee_dashboard.tscn")
const E = preload("res://scripts/hydroponic_equipment.gd")
var checks := 0
var failures := 0

func _ready() -> void:
	await _layout(Vector2i(1280, 720), true)
	await _layout(Vector2i(1920, 1080), true)
	await _layout(Vector2i(1024, 576), false)
	_state_bindings()
	_inventory_discard()
	print("PRESENTATION_TEST_RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _layout(dimensions: Vector2i, required: bool) -> void:
	var viewport := SubViewport.new()
	viewport.size = dimensions
	add_child(viewport)
	var ui = UI.instantiate()
	viewport.add_child(ui)
	await get_tree().process_frame
	await get_tree().process_frame
	var bounds := Rect2(Vector2.ZERO, Vector2(dimensions))
	var fits := true
	var widgets: Array[Control] = [ui.next_night_button, ui.contextual_action, ui.crop_menu, ui.stored_items, ui.growth_meter, ui.dna_status_label,
		ui.actions["plant"], ui.actions["run"], ui.actions["water"], ui.actions["energy"], ui.actions["tablet"],
		ui.actions["harvest"], ui.actions["discard"], ui.actions["drain"], ui.actions["seed_supply"],
		ui.actions["genetics"], ui.actions["analysis"], ui.actions["equipment"]]
	for widget: Control in widgets:
		fits = fits and bounds.encloses(widget.get_global_rect())
		if required:
			_check(bounds.encloses(widget.get_global_rect()), "visible control bounds %s %s" % [dimensions, widget.text if widget is Button else widget.name])
	if required:
		var overlaps := false
		for first in widgets.size():
			for second in range(first + 1, widgets.size()):
				if widgets[first].get_window() == ui.get_window() and widgets[second].get_window() == ui.get_window():
					overlaps = overlaps or widgets[first].get_global_rect().intersects(widgets[second].get_global_rect())
		_check(not overlaps, "essential dashboard controls do not overlap")
		_check(ui.next_night_button.focus_mode == Control.FOCUS_ALL and ui.next_night_button.text.contains("Next Night"), "focus and bilingual primary control")
	print("PRESENTATION_LAYOUT %s fits=%s" % [dimensions, fits])
	viewport.free()

func _state_bindings() -> void:
	var ui = UI.instantiate()
	add_child(ui)
	var farm = ui.farm
	_check(farm.select_machine(E.Machine.USED), "switch fixture")
	ui._render()
	_check(ui.machine_name_label.text.contains("Used") and ui.machine_state_label.text.contains("stopped") and ui.status_label.text.contains("System"), "installed machine and system state")
	var chosen = farm.beans[1]
	ui.stored_items.select(1)
	ui._render()
	_check(ui.stored_items.get_selected_metadata() == chosen, "inventory selection follows object identity")
	ui.actions["discard"].pressed.emit()
	ui.stored_items.select(0)
	ui._render()
	ui.confirm_action.confirmed.emit()
	_check(not farm.beans.has(chosen) and farm.beans.size() == 2, "confirmation retains original target")
	var planted = farm.beans[0]
	_check(farm.select_seed(planted.get_instance_id()), "select seed fixture")
	ui.contextual_action.pressed.emit()
	_check(farm.plant != null and farm.plant.seed_item == planted, "contextual plant consumes selected seed")
	var edit_target = farm.beans.back()
	_check(farm.begin_edit(edit_target, "Fast Growth"), "start editor fixture")
	var nested := [false]
	ui.game_state.night_processing_started.connect(func(_day: int) -> void:
		nested[0] = not ui.game_state.start_night()
	)
	var day: int = ui.game_state.current_day
	ui.next_night_button.pressed.emit()
	_check(nested[0] and ui.game_state.current_day == day + 1, "rapid reentrant night rejected")
	_check(ui.dna_status_label.text.contains("10/20") and not ui.dna_dialog.visible, "editor progress on dashboard")
	ui.free()

func _inventory_discard() -> void:
	var ui = UI.instantiate()
	var farm = ui.get_node("CoffeeFarm")
	farm.starter_beans = 2
	farm.starter_nutrition_seeds = 1
	farm.starter_kotton_seeds = 0
	farm.initial_minerals_ul = 60000
	farm.reproduction_rng.seed = 42
	add_child(ui)
	farm.select_species(1)
	farm.plant_bean()
	farm.toggle_running()
	ui.next_night_button.pressed.emit()
	ui.next_night_button.pressed.emit()
	ui.actions["harvest"].pressed.emit()
	_check(farm.beans.size() == 2 and farm.products.size() == 1 and ui.stored_items.item_count == 3, "harvest creates mixed inventory")
	var product_key: String = farm.products.keys().front()
	var first_seed = farm.beans.front()
	ui.stored_items.select(1)
	ui.actions["discard"].pressed.emit()
	ui.confirm_action.canceled.emit()
	ui.confirm_action.hide()
	ui.confirm_action.confirmed.emit()
	_check(farm.beans.size() == 2 and ui.stored_items.selected == 1, "discard cancellation keeps selection and seed")
	_confirm_discard(ui)
	_check(farm.beans.size() == 1 and is_same(ui.stored_items.get_selected_metadata(), first_seed), "removed seed falls back to remaining seed")
	_confirm_discard(ui)
	_check(farm.beans.is_empty() and is_same(ui.stored_items.get_selected_metadata(), product_key), "last seed falls back to harvested product")
	_check(not ui.actions["discard"].disabled and ui.actions["discard"].icon == ui.art.texture("nutrition"), "product icon and action after final seed")
	_confirm_discard(ui)
	_check(farm.products.get(product_key) == 6 and is_same(ui.stored_items.get_selected_metadata(), product_key), "partially discarded product stays selected")
	for count in 6:
		_confirm_discard(ui)
	_check(farm.occupied_slots() == 0 and ui.stored_items.item_count == 0 and ui.stored_items.selected == -1, "all items removed and selection cleared")
	_check(ui.actions["discard"].disabled and ui.actions["discard"].icon == null and ui.actions["plant"].disabled, "empty inventory clears icon and actions")
	ui.actions["seed_supply"].pressed.emit()
	_check(ui.stored_items.selected == 0 and not ui.actions["discard"].disabled and ui.actions["discard"].icon == ui.art.texture("nutrition_seed"), "replenished inventory selects Nutrition Fruit seed and restores actions")
	ui.free()

func _confirm_discard(ui: Control) -> void:
	ui.actions["discard"].pressed.emit()
	ui.confirm_action.confirmed.emit()
	ui.confirm_action.hide()

func _check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("PRESENTATION_CHECK_FAILED: " + label)
