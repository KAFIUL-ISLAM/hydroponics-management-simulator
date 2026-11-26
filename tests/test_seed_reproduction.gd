extends Node

const R = preload("res://scripts/seed_reproduction.gd")
const G = preload("res://scripts/crop_genetics.gd")
const UI = preload("res://scenes/coffee_dashboard.tscn")
const FRUIT = preload("res://resources/nutrition_fruit.tres")
const KOTTON = preload("res://resources/kotton.tres")
var checks := 0
var failures := 0
var samples: Array[float] = []

func _ready() -> void:
	var fruit := G.resolve(FRUIT, FRUIT.native_traits, 12)
	var kotton := G.resolve(KOTTON, KOTTON.native_traits, 6)
	var no_roll := func() -> float:
		_check(false, "deterministic outcome makes no RNG call")
		return 0.5
	_check(not R.resolve(R.Profile.NONE, 10000, kotton, no_roll).eligible, "ineligible")
	_check(not R.resolve(-1, 10000, kotton, no_roll).valid, "unknown profile")
	_check(R.resolve(R.Profile.KOTTON, 5000, kotton, no_roll).offspring_count == 1, "50 exact")
	_check(R.resolve(R.Profile.KOTTON, 8001, kotton, no_roll).offspring_count == 2, "above 80")
	samples = [0.49, 0.50]
	_check(R.resolve(R.Profile.KOTTON, 5001, kotton, _roll).attempts == 2, "above 50 success")
	_check(R.resolve(R.Profile.KOTTON, 8000, kotton, _roll).attempts == 1, "80 exact failure")
	samples = [0.0, 0.0002, 1.0]
	var rare := R.resolve(R.Profile.NUTRITION, 10000, fruit, _roll)
	_check(rare.attempts == 3 and rare.copies_by_attempt == [1,0,0] and is_equal_approx(rare.multiplier, 0.0001000166), "Sterile X rare return")
	var ranks: Dictionary[String,int] = KOTTON.native_traits.duplicate()
	ranks["Fertile"] = 1
	var fertile := G.resolve(KOTTON, ranks, 7)
	samples = [0.249, 0.25]
	var returns := R.resolve(R.Profile.KOTTON, 10000, fertile, _roll)
	_check(returns.copies_by_attempt == [2,1] and returns.offspring_count == 3 and returns.extra_copy_probability == 0.25, "Fertile I boundaries")
	samples = [NAN]
	_check(not R.resolve(R.Profile.KOTTON, 6000, kotton, _roll).valid, "invalid sample")
	await _integration()
	print("REPRODUCTION_TEST_RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _integration() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280,720)
	viewport.gui_embed_subwindows = true
	add_child(viewport)
	var ui = UI.instantiate()
	viewport.add_child(ui)
	var farm = ui.farm
	ui.actions["genetics"].pressed.emit()
	var first = farm.selected_seed()
	ui.next_seed_button.pressed.emit()
	_check(farm.selected_seed() != first, "inventory selector binding")
	ui.demo_genes_button.pressed.emit()
	var parent = farm.selected_seed()
	parent.heat = 14
	_check(not farm.select_seed(-1) and farm.selected_seed() == parent, "invalid selection preserves selection")
	_check(ui.genetics_dialog.dialog_text.contains("Modified") and parent.analyze().complexity == 25, "validated demo binding")
	await get_tree().process_frame
	await get_tree().process_frame
	_check(Rect2i(0,0,1280,720).encloses(Rect2i(ui.genetics_dialog.position, ui.genetics_dialog.size)), "dialog bounds")
	ui.genetics_dialog.hide()
	_check(farm.plant_bean() and farm.plant.seed_item == parent and not farm.beans.has(parent), "actual selected seed")
	farm.toggle_running()
	var rng_state: int = farm.reproduction_rng.state
	ui.next_night_button.pressed.emit()
	_check(farm.plant.growth == 8 and ui.last_night.draw_ul == 75000, "modified night")
	ui.next_night_button.pressed.emit()
	_check(farm.plant.pending == 12 and not farm.plant.reproduction.eligible and farm.reproduction_rng.state == rng_state, "Coffee harvest without extra grant")
	_check(farm.collect() and farm.beans.size() == 15 and not farm.collect(), "Coffee collection once")
	var child = farm.beans.back()
	_check(child.heat == 0 and child.analyze().crop.target == 15 and parent.heat == 14, "Coffee inheritance")
	_check(farm.plant_bean() and farm.plant.seed_item == child, "replant modified Coffee")
	ui.free()
	ui = UI.instantiate()
	viewport.add_child(ui)
	farm = ui.farm
	farm.select_species(2)
	parent = farm.selected_seed()
	parent.heat = 9
	farm.plant_bean()
	farm.toggle_running()
	farm.plant.growth = 40
	farm.energy_kj = 0
	rng_state = farm.reproduction_rng.state
	ui.next_night_button.pressed.emit()
	_check(farm.plant.offspring.is_empty() and farm.reproduction_rng.state == rng_state and farm.plant.growth == 40, "rejected settlement atomic")
	farm.energy_kj = 100
	ui.next_night_button.pressed.emit()
	var children: Array = farm.plant.offspring.duplicate()
	_check(children.size() == 2 and children[0] != children[1], "Kotton siblings stage at maturity")
	ui.actions["genetics"].pressed.emit()
	_check(ui.genetics_dialog.dialog_text.contains("Pending offspring: 2"), "pending offspring analysis binding")
	ui.genetics_dialog.hide()
	farm.inventory_capacity = farm.occupied_slots()+14
	_check(not farm.collect() and farm.products.is_empty() and farm.plant.offspring == children, "combined capacity atomic")
	ui.next_night_button.pressed.emit()
	_check(farm.plant.offspring == children and farm.reproduction_rng.state == rng_state, "pending does not reroll")
	farm.inventory_capacity += 1
	_check(farm.collect() and not farm.collect() and farm.seed_count(KOTTON) == 3, "Kotton transfer once")
	children[0].traits["Hardy"] = 1
	_check(not children[1].traits.has("Hardy") and not parent.traits.has("Hardy") and children[1].heat == 0 and parent.heat == 9, "detached offspring")

func _roll() -> float:
	return samples.pop_front()

func _check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("REPRODUCTION_CHECK_FAILED: " + label)
