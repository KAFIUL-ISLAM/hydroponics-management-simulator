extends Node

const P = preload("res://scripts/pollution_analysis.gd")
const L = preload("res://scripts/liquid_composition.gd")
const UI = preload("res://scenes/coffee_dashboard.tscn")
const W = L.Component.WATER
const M = L.Component.MINERALS
const HM = L.Component.HEAVY_METALS
var checks := 0
var failures := 0

func _ready() -> void:
	var sample: Dictionary[int, int] = {W: 1000000, M: 20000}
	_check(P.analyze(sample, 1.0, 1.0, 8).rounded_damage() == 0, "clean")
	for component: int in P.HARMFUL:
		sample[component] = 2000
		var result := P.analyze(sample, 1.0, 1.0, 8)
		_check(result.harmful_ul == 2000 and result.rounded_damage() == 160, "independent component")
		var part := result.components[P.HARMFUL.find(component)]
		_check(part.concentration == 20.0 and part.exposure == 20.0 and part.volume_ul == 2000, "pure-water denominator")
		sample.erase(component)
	for row: Array in [[10,0,15],[15,15,20],[20,20,30],[25,30,40],[30,40,60],
		[40,60,80],[60,80,160],[100,160,320],[200,320,640]]:
		for offset: int in [-1, 0, 1]:
			sample[HM] = row[0] * 100 + offset
			_check(P.analyze(sample, 1.0, 1.0, 1).rounded_damage() == (row[2] if offset > 0 else row[1]), "tier boundary")
	sample[HM] = 2000
	_check(P.analyze(sample, 0.70, 1.0, 8).rounded_damage() == 120, "Nutrition sensitivity")
	_check(P.analyze(sample, 1.0, 1.01, 8).rounded_damage() == 162, "Coffee resistance")
	_check(P.analyze(sample, 1.50454, 1.26, 8).rounded_damage() == 605, "Kotton native exposure")
	var kotton_example := P.analyze(sample, 1.0, 1.26, 8)
	_check(is_equal_approx(kotton_example.raw_nightly_damage, 201.6) and kotton_example.rounded_damage() == 202, "tier 20 Kotton discriminator")
	sample[L.Component.ACID] = 2000
	sample[L.Component.PHYSICAL_POLLUTION] = 122
	sample[L.Component.INERT] = 123
	var mixed := P.analyze(sample, 1.0, 1.01, 8)
	_check(mixed.rounded_damage() == 323 and mixed.physical_ul == 122 and mixed.inert_ul == 123, "summed before rounding")
	sample.erase(W)
	var undefined := P.analyze(sample, 1.0, 1.0, 8)
	_check(not undefined.defined and undefined.components[0].concentration == null, "zero water")
	var vessel := L.new(1000000)
	vessel.replenish({W: 800000, HM: 200000})
	_check(vessel.insert_tablet_with_displacement() == L.Status.OK and vessel.snapshot_ul()[HM] == 197000, "tablet removes proportional pollution")
	var dilute := L.new(2000000)
	dilute.replenish({W: 1000000, HM: 2000})
	dilute.add_pure_water(1000000 - 2000)
	_check(P.analyze(dilute.snapshot_ul(), 1.0, 1.0, 1).rounded_damage() == 15, "dilution near boundary")
	await _integration()
	print("POLLUTION_TEST_RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _integration() -> void:
	var ui = UI.instantiate()
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.gui_embed_subwindows = true
	add_child(viewport)
	viewport.add_child(ui)
	var farm = ui.farm
	ui.actions["analysis"].pressed.emit()
	_check(ui.analysis_text.text.contains("Heavy metals") and ui.scenario_menu.item_count == 5, "analysis action")
	var original: Dictionary = farm.vessel.snapshot_ul()
	_check(not farm.load_demo_solution(-1) and farm.vessel.snapshot_ul() == original, "invalid scenario is atomic")
	for scenario: Array in [[0,0,0],[1,10000,0],[2,25000,0],[3,0,25000]]:
		ui.scenario_menu.select(scenario[0])
		ui.actions["replace_solution"].pressed.emit()
		ui.confirm_action.confirmed.emit()
		ui.confirm_action.hide()
		var result: P.Result = farm.pollution_analysis(farm.vessel.snapshot_ul())
		_check(result.harmful_ul == scenario[1] and result.physical_ul == scenario[2], "demo component volumes")
	ui.scenario_menu.select(4)
	ui.actions["replace_solution"].pressed.emit()
	_check(not farm.vessel.snapshot_ul().has(HM), "replacement awaits confirmation")
	ui.confirm_action.confirmed.emit()
	_check(farm.vessel.snapshot_ul().get(HM) == 200000, "high demo solution")
	ui.actions["plant"].pressed.emit()
	var before: Dictionary = farm.vessel.snapshot_ul()
	ui.next_night_button.pressed.emit()
	_check(farm.plant.health == 10000 and before == farm.vessel.snapshot_ul(), "stopped night")
	ui.actions["run"].pressed.emit()
	farm.energy_kj = 0
	ui.next_night_button.pressed.emit()
	_check(farm.plant.health == 10000 and before == farm.vessel.snapshot_ul(), "blocked night")
	farm.energy_kj = 100
	var contaminated := L.new(6000000)
	contaminated.replenish({W: 5000000, M: 50000, HM: 200000, L.Component.ACID: 200000})
	farm.vessel = contaminated
	var observed := [false]
	ui.game_state.night_processing_finished.connect(func(_day: int, _next_day: int, outcome: GameState.NightOutcome) -> void:
		if outcome.status == GameState.NightStatus.GROWN and farm.plant.growth == 8:
			observed[0] = ui.game_state.is_ready() and farm.plant.health == 0 and farm.energy_kj == 92 and farm.vessel.snapshot_ul().get(HM) == 196330
	)
	ui.next_night_button.pressed.emit()
	_check(ui.last_night.mineral_damage == 800 and ui.last_night.pollution_damage == 10342, "combined damage")
	_check(farm.plant.health == 0 and ui.last_night.health_loss == 10000 and farm.plant.growth == 8, "health clamping")
	_check(farm.vessel.snapshot_ul().get(HM) == 196330 and farm.energy_kj == 92, "atomic proportional consumption")
	_check(observed[0], "coherent completion observer")
	ui.next_night_button.pressed.emit()
	ui.next_night_button.pressed.emit()
	_check(farm.plant.pending == 4 and farm.plant.health == 0, "damaged harvest")
	ui.confirm_action.hide()
	ui.actions["analysis"].pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	_check(ui.analysis_text.text.contains("Last running night damage"), "settled pollutant breakdown")
	_check(Rect2(0, 0, 1280, 720).encloses(ui.next_night_button.get_global_rect()), "settlement layout")
	var dialog_bounds := Rect2i(ui.liquid_dialog.position, ui.liquid_dialog.size)
	_check(Rect2i(0, 0, 1280, 720).encloses(dialog_bounds), "analysis layout %s" % dialog_bounds)

func _check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("POLLUTION_CHECK_FAILED: " + label)
