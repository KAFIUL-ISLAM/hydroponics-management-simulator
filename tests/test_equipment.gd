extends Node

const E = preload("res://scripts/hydroponic_equipment.gd")
const UI = preload("res://scenes/coffee_dashboard.tscn")
var checks := 0
var failures := 0

func _ready() -> void:
	_fixture([], 8, 8, 0)
	_fixture([E.Module.NUTRITION], 7, 8, 1)
	_fixture([E.Module.NUTRITION, E.Module.NUTRITION], 7, 9, 2)
	_fixture([E.Module.WEAVING], 6, 16, 0)
	_fixture([E.Module.EFFICIENCY], 8, 7, 0)
	_fixture([E.Module.PERFORMANCE, E.Module.PERFORMANCE], 9, 8, 0)
	_fixture([E.Module.ECO], 7, 6, 0)
	_check(E.resolve(E.Machine.USED, [], 3, 6000000, 0).growth == 9 and E.resolve(E.Machine.USED, [], 3, 6000000, 0).energy_kj == 11, "used configuration")
	_check(E.resolve(E.Machine.WORN, [], 3, 6000000, 0).growth == 6 and E.resolve(E.Machine.WORN, [], 3, 6000000, 0).energy_kj == 3, "worn configuration")
	_check(not E.resolve(-1, [], 3, 6000000, 1).valid and not E.resolve(0, [-1], 3, 6000000, 1).valid, "invalid identifiers")
	_check(not E.resolve(E.Machine.WORN, [E.Module.ECO], 3, 6000000, 1).valid, "locked module bay")
	_check(not E.resolve(0, [E.Module.ECO], 0, 6000000, 1).valid, "slots")
	_check(not E.resolve(0, [1,1,1,1], 4, 6000000, 1).valid, "zero speed")
	var textile := E.resolve(0, [E.Module.WEAVING], 3, 6000000, 2)
	_check(textile.replacement.contains("Kotton textile") and textile.reproduction_multiplier == 1.0 and textile.adjusted_quality == 0, "verified conversion and neutral modifiers")
	_check(E.resolve(0, [E.Module.WEAVING], 3, 6000000, 1).replacement.is_empty(), "off-crop conversion omitted")
	await _integration()
	print("EQUIPMENT_TEST_RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _fixture(modules: Array[int], growth: int, energy: int, extras: int) -> void:
	var config := E.resolve(E.Machine.STANDARD, modules, 3, 6000000, 1)
	_check(config.valid and config.growth == growth and config.energy_kj == energy and config.extra_output == extras, "independent module fixture")

func _integration() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280,720)
	viewport.gui_embed_subwindows = true
	add_child(viewport)
	var ui = UI.instantiate()
	viewport.add_child(ui)
	var farm = ui.farm
	var before: Dictionary = farm.vessel.snapshot_ul()
	ui.actions["equipment"].pressed.emit()
	ui.vessel_choice.select(1)
	ui.actions["switch_vessel"].pressed.emit()
	_check(farm.vessel.snapshot_ul() == before and farm.vessel.capacity_ul() == 6000000 and not farm.equipment_error.is_empty(), "atomic capacity rejection")
	ui.module_choice.select(ui.module_choice.get_item_index(E.Module.WEAVING))
	ui.actions["install_module"].pressed.emit()
	_check(farm.available_modules(E.Module.WEAVING) == 0 and not farm.install_module(E.Module.WEAVING), "exclusive module ownership")
	_check(not farm.select_machine(E.Machine.USED), "cannot switch with incompatible module")
	await get_tree().process_frame
	await get_tree().process_frame
	_check(Rect2i(0,0,1280,720).encloses(Rect2i(ui.equipment_dialog.position, ui.equipment_dialog.size)), "equipment dialog bounds")
	ui.equipment_dialog.hide()
	farm.select_species(2)
	farm.plant_bean()
	farm.toggle_running()
	farm.plant.growth = 42
	_check(not farm.remove_module(E.Module.WEAVING), "running lock")
	var blocked := [false]
	ui.game_state.status_changed.connect(func(_status) -> void:
		if ui.game_state.is_night_active():
			blocked[0] = not farm.install_module(E.Module.ECO)
	)
	ui.next_night_button.pressed.emit()
	_check(blocked[0] and farm.plant.growth == 48 and farm.energy_kj == 84, "settlement lock and full final night")
	_check(ui.last_night.draw_ul == 250000 and ui.last_night.liquid.actual_uptake_ul == 450, "draw fixed and uptake from actual points")
	_check(farm.plant.pending == 13 and farm.plant.offspring.size() == 2, "equipment preserves Kotton return")
	ui.actions["remove_module"].pressed.emit()
	_check(farm.available_modules(E.Module.WEAVING) == 1 and farm.collect() and farm.products.get("韧棉织物 / Kotton textile") == 13, "remove returns ownership and pending product frozen")
	_check(farm.drain_solution() and farm.select_vessel(E.Vessel.CAN) and farm.vessel.capacity_ul() == 3000000, "safe smaller vessel")
	ui.free()
	ui = UI.instantiate()
	viewport.add_child(ui)
	farm = ui.farm
	farm.select_species(1)
	farm.load_demo_solution(0)
	var selected_seed = farm.selected_seed()
	selected_seed.traits["High Yield"] = 3
	_check(farm.install_module(E.Module.NUTRITION) and farm.install_module(E.Module.NUTRITION), "stacked crop modules")
	farm.plant_bean()
	farm.toggle_running()
	for night in 3:
		ui.next_night_button.pressed.emit()
	_check(farm.plant.pending == 9 and farm.plant.growth == 21 and farm.energy_kj == 73, "genetic count rounds before flat bonuses")

func _check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("EQUIPMENT_CHECK_FAILED: " + label)
