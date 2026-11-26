extends Node

const Dashboard = preload("res://scenes/coffee_dashboard.tscn")
const Farm = preload("res://scripts/coffee_farm.gd")
const L = preload("res://scripts/liquid_composition.gd")
var checks := 0
var failures := 0

func _ready() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	add_child(viewport)
	var ui = Dashboard.instantiate()
	viewport.add_child(ui)
	var farm: Farm = ui.farm
	_check(farm.crop.raw_target == 21 and farm.crop.target == 21 and farm.crop.healthy_output == 8, "crop points and output")
	_check(farm.crop.draw_ul == 100000 and farm.crop.uptake_ul_per_point == 30 and farm.crop.pollution_damage_factor == 1.01, "crop draw uptake and factor")
	_check(farm.beans[0] != farm.beans[1] and farm.beans[0].traits == farm.crop.native_traits, "independent native seeds")
	farm.beans[0].traits["Potent"] = 2
	_check(farm.beans[1].traits["Potent"] == 1 and farm.crop.native_traits["Potent"] == 1, "traits are detached")
	_check(ui.electricity_value_label.text == "100 kJ" and ui.actions["harvest"].disabled, "units and early harvest disabled")
	_press(ui, "plant")
	_check(farm.beans.size() == 2 and farm.plant.health == 10000 and farm.plant.growth == 0, "planting debits one bean")
	_check(ui.actions["plant"].disabled and not farm.plant_bean() and farm.beans.size() == 2 and not farm.collect(), "reject second plant and early harvest")
	ui.next_night_button.pressed.emit()
	_check(farm.plant.growth == 0 and farm.energy_kj == 100 and ui.game_state.current_day == 2, "stopped night only advances day")
	_press(ui, "run")
	_press(ui, "run")
	_check(not farm.running, "stop action")
	_press(ui, "run")
	var totals := [0, 0, 0, 0]
	ui.game_state.night_processing_finished.connect(func(_day: int, _next: int, outcome: GameState.NightOutcome) -> void:
		if outcome.status == GameState.NightStatus.GROWN:
			totals[0] += outcome.draw_ul
			totals[1] += outcome.liquid.actual_uptake_ul
			totals[2] += outcome.liquid.total_mineral_loss_ul()
			totals[3] += outcome.energy_kj
			_check(farm.energy_kj == 100 - totals[3] and farm.vessel.total_ul() == 5150000 - totals[0] - totals[1], "coherent resource observer")
			_check(farm.plant.growth == totals[3] and ui.game_state.is_ready(), "coherent plant observer")
	)
	for growth: int in [8, 16, 24]:
		ui.next_night_button.pressed.emit()
		_check(farm.plant.growth == growth and farm.plant.health == 10000, "healthy full night")
	_check(totals == [300000, 720, 9430, 24] and farm.energy_kj == 76, "exact cycle totals")
	_check(farm.plant.pending == 8 and not ui.actions["harvest"].disabled and ui.control_hint.text.contains("Health loss: 0"), "ready to collect")
	ui.next_night_button.pressed.emit()
	_check(farm.plant.pending == 8 and farm.plant.growth == 24 and farm.energy_kj == 76, "pending stops production")
	farm.inventory_capacity = 9
	_press(ui, "harvest")
	_check(farm.plant.pending == 8 and farm.beans.size() == 2, "inventory full retains harvest")
	farm.inventory_capacity = 16
	_press(ui, "harvest")
	_check(farm.plant == null and farm.beans.size() == 10 and not farm.collect(), "collect exactly once")
	_press(ui, "plant")
	_check(farm.beans.size() == 9 and farm.plant.growth == 0, "replant harvested bean")
	_press(ui, "water")
	_press(ui, "tablet")
	_press(ui, "energy")
	_check(farm.water_supply_ul == 4500000 and farm.tablets == 9 and farm.energy_supply_kj == 76 and farm.energy_kj == 100, "supply stock conservation")
	await get_tree().process_frame
	await get_tree().process_frame
	for button: Button in ui.actions.values():
		_check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(button.get_global_rect()), "action inside target viewport")
	_check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(ui.next_night_button.get_global_rect()), "night button inside target viewport")
	_test_bounds()
	for pair: Array in [[0,4],[1500,4],[1501,5],[3000,5],[3001,6],[5000,6],[5001,6],[7000,6],[7001,8]]:
		_check(Farm.harvest_quantity(8, pair[0]) == pair[1], "health threshold %d" % pair[0])
	_check(Farm.round_tenths_half_even(65) == 6 and Farm.round_tenths_half_even(75) == 8, "half-even ties")
	print("COFFEE_FIXTURE draw=%d uptake=%d mineral_loss=%d kJ=%d" % totals)
	print("COFFEE_TEST_RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _test_bounds() -> void:
	for sample: Array in [[1000000,17499,100,9200],[1000000,17500,100,10000],[1000000,32500,100,10000],[1000000,32501,100,9600],[1000000,0,100,0],[99900,100,100,-1],[90000,0,100,-1],[0,150000,100,-2],[1000000,30000,7,-1]]:
		var ui = Dashboard.instantiate()
		var farm: Farm = ui.get_node("CoffeeFarm")
		farm.initial_water_ul = sample[0]
		farm.initial_minerals_ul = sample[1]
		farm.energy_kj = sample[2]
		add_child(ui)
		_press(ui, "plant")
		_press(ui, "run")
		var before := farm.vessel.snapshot_ul()
		if sample[3] == 0:
			farm.plant.health = 1
			farm.plant.growth = 16
		ui.next_night_button.pressed.emit()
		if sample[3] >= 0:
			_check(farm.plant.health == sample[3] and farm.energy_kj == sample[2] - 8, "health and energy at band")
			if sample[3] == 0:
				_check(farm.plant.growth == 24 and farm.plant.pending == 4, "zero-health maturity")
		else:
			_check(farm.plant.growth == 0 and farm.plant.health == 10000 and farm.beans.size() == 2 and farm.energy_kj == sample[2] and farm.vessel.snapshot_ul() == before, "atomic rejection")
			_check(ui.game_state.current_day == (1 if sample[3] == -2 else 2), "day on failure")
			if sample[2] == 7:
				_press(ui, "energy")
				ui.next_night_button.pressed.emit()
				_check(farm.plant.growth == 8 and farm.energy_kj == 23, "energy recovery")
			elif sample[0] == 90000:
				_press(ui, "water")
				ui.next_night_button.pressed.emit()
				_check(farm.plant.growth == 8 and farm.water_supply_ul == 4500000, "liquid recovery")
		ui.free()

func _press(ui, action: String) -> void:
	_check(not ui.actions[action].disabled, "%s available" % action)
	ui.actions[action].pressed.emit()

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("COFFEE_CHECK_FAILED: " + label)
