extends Node
## Reproducible comparison using isolated instances of the normal workshop.

const WorkshopScene = preload("res://scenes/workshop.tscn")
const Farm = preload("res://scripts/coffee_farm.gd")
var checks := 0
var failures := 0

func _ready() -> void:
	var below := _cycle(50_000)
	var suitable := _cycle(150_000)
	print("M10_NUTRIENT_DEMO below=", JSON.stringify(below))
	print("M10_NUTRIENT_DEMO suitable=", JSON.stringify(suitable))
	_check(below == _cycle(50_000) and suitable == _cycle(150_000), "repeatable comparison and offspring")
	_check(below.growth_by_night == [8, 16, 24, 32, 40, 48] and below.growth_by_night == suitable.growth_by_night, "the same six operating nights reach maturity")
	_check(below.final_health == 5200 and suitable.final_health == 10000, "mineral band changes health")
	_check(below.yield_count == 12 and suitable.yield_count == 13, "calculated fiber yields differ")
	_check(below.energy_used_kj == 48 and suitable.energy_used_kj == 48 and below.solution_draw_ul == 1_500_000 and suitable.solution_draw_ul == 1_500_000, "operating debit and mixed draw are equal")
	_check(below.mineral_uptake_ul == 3600 and suitable.mineral_uptake_ul == 3600, "targeted mineral uptake is equal")
	print("M10_NUTRIENT_DEMO_RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _cycle(minerals_ul: int) -> Dictionary:
	var ui = WorkshopScene.instantiate()
	var farm: Farm = ui.get_node("CoffeeFarm")
	farm.initial_minerals_ul = minerals_ul
	farm.reproduction_rng.seed = 42
	add_child(ui)
	_check(farm.select_species(2) and farm.plant_bean() and farm.toggle_running(), "plant native Kotton and use standard machine")
	var start := farm.vessel.snapshot_ul()
	var concentration: float = farm.vessel.mineral_concentration_pct()
	var power := farm.energy_kj
	var traces := {"draw": 0, "uptake": 0}
	ui.game_state.night_processing_finished.connect(func(_day: int, _next: int, outcome: GameState.NightOutcome) -> void:
		if outcome.status == GameState.NightStatus.GROWN:
			var completed := outcome as Farm.FarmOutcome
			traces.draw += completed.draw_ul
			traces.uptake += completed.liquid.actual_uptake_ul
	)
	var growth: Array[int] = []
	for night in 6:
		_check(ui.game_state.start_night(), "accepted operating night")
		growth.append(farm.plant.growth if farm.plant != null else 0)
	_check(farm.plant != null and farm.plant.stage == Farm.Plant.Stage.MATURE, "actual mature crop")
	var last := farm.vessel.snapshot_ul()
	var result := {
		"initial_water_ul": start[Farm.W],
		"initial_minerals_ul": start[Farm.M],
		"initial_energy_kj": power,
		"initial_concentration_pct": concentration,
		"final_concentration_pct": farm.vessel.mineral_concentration_pct(),
		"growth_by_night": growth,
		"solution_draw_ul": traces.draw,
		"pure_water_used_ul": start[Farm.W] - last[Farm.W],
		"mineral_uptake_ul": traces.uptake,
		"total_mineral_loss_ul": start[Farm.M] - last[Farm.M],
		"energy_used_kj": power - farm.energy_kj,
		"final_health": farm.plant.health,
		"yield_count": farm.plant.pending,
		"grades": farm.plant.sizes,
		"offspring": farm.plant.offspring.size(),
	}
	ui.free()
	return result

func _check(ok: bool, detail: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("M10_NUTRIENT_DEMO_CHECK_FAILED: " + detail)
