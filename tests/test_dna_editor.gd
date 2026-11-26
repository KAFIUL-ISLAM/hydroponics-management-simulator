extends Node

const D = preload("res://scripts/dna_editor.gd")
const UI = preload("res://scenes/coffee_dashboard.tscn")
const COFFEE = preload("res://resources/coffee_beans.tres")
const FRUIT = preload("res://resources/nutrition_fruit.tres")
const KOTTON = preload("res://resources/kotton.tres")
var checks := 0
var failures := 0

func _ready() -> void:
	var plan := D.preview(COFFEE, COFFEE.native_traits, 0, 1, "Fast Growth", 1, 24)
	_check(plan.valid() and plan.required_points == 20 and plan.nights == 2 and plan.total_energy_kj == 24 and plan.success_pct == 95, "native Coffee operation")
	_check(plan.after.crop.target == 17 and plan.after.complexity == 4 and plan.after.heat == 6 and not COFFEE.native_traits.has("Fast Growth"), "preview is detached")
	var fruit := D.preview(FRUIT, FRUIT.native_traits, 0, 2, "High Yield", 1, 100)
	_check(fruit.valid() and fruit.required_points == 52 and fruit.nights == 6 and fruit.total_energy_kj == 72 and fruit.success_pct == 55 and fruit.after.traits["High Yield"] == 3, "published Nutrition Fruit fixture and rank increase")
	var hot := D.preview(COFFEE, COFFEE.native_traits, 18, 1, "Fast Growth", 1, 100)
	_check(hot.required_points == 92 and hot.success_pct == 5, "chance clamp")
	_check(not D.preview(COFFEE, COFFEE.native_traits, 0, 1, "Fast Growth", 0, 24).valid(), "no disc")
	_check(not D.preview(COFFEE, COFFEE.native_traits, 0, 1, "Fast Growth", 1, 11).valid(), "unfunded")
	_check(not D.preview(COFFEE, COFFEE.native_traits, 0, 1, "Sterile", 1, 24).valid(), "species restricted")
	_check(not D.preview(FRUIT, FRUIT.native_traits, 0, 2, "Slow Growth", 1, 100).valid(), "opposing trait")
	_check(not D.preview(KOTTON, KOTTON.native_traits, 0, 2, "High Water Use", 1, 100).valid(), "unresolved draw")
	_check(not D.preview(FRUIT, FRUIT.native_traits, 0, 2, "remove", 1, 100).valid(), "unsupported operation")
	var model := D.new()
	var observed := [0]
	var boundary := func() -> float:
		observed[0] += 1
		return 0.95
	_check(model.start(plan) and not model.start(plan), "only one operation")
	var initial_rng := model.rng.state
	_check(model.advance(11, boundary).energy_kj == 0 and model.progress == 0 and model.rng.state == initial_rng, "paused without debit or RNG")
	_check(model.advance(12, boundary).energy_kj == 12 and model.progress == 10 and observed[0] == 0, "funded progress no early roll")
	_check(model.advance(12, func() -> float: return NAN).energy_kj == 0 and model.progress == 10, "invalid completion sample atomic")
	var result := model.advance(12, boundary)
	_check(result.completed and not result.succeeded and result.heat == 6 and result.traits == COFFEE.native_traits, "failure heats seed, retains ranks")
	_check(model.advance(12, boundary).energy_kj == 0 and observed[0] == 1, "no reroll")
	_check(model.start(plan), "can start new operation")
	model.advance(12)
	result = model.advance(12, func() -> float: return 0.949)
	_check(result.succeeded and result.traits["Fast Growth"] == 1 and result.heat == 6, "success just below boundary")
	await _integration()
	print("DNA_EDITOR_TEST_RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _integration() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.gui_embed_subwindows = true
	add_child(viewport)
	var ui = UI.instantiate()
	viewport.add_child(ui)
	var farm = ui.farm
	var parent = farm.selected_seed()
	var editor_rng: int = farm.dna_editor.rng.state
	var reproduction_rng: int = farm.reproduction_rng.state
	ui.actions["genetics"].pressed.emit()
	ui.actions["dna"].pressed.emit()
	_check(ui.dna_dialog.visible and ui.dna_readout.text.contains("95%"), "editor binding and preview")
	_check(editor_rng == farm.dna_editor.rng.state and farm.energy_kj == 100 and farm.disc_uses["Fast Growth"] == 3, "preview leaves resources and RNG untouched")
	await get_tree().process_frame
	await get_tree().process_frame
	_check(Rect2i(0,0,1280,720).encloses(Rect2i(ui.dna_dialog.position, ui.dna_dialog.size)), "dialog bounds")
	farm.dna_editor.rng.seed = 42
	ui.dna_start.pressed.emit()
	_check(farm.seed_edit_locked(parent) and not farm.discard_seed_instance(parent) and not farm.plant_bean() and not farm.begin_edit(parent, "Fast Growth"), "seed lock and duplicate prevention")
	_check(farm.beans.size() == 3 and farm.energy_kj == 100, "queue preserves inventory and energy")
	ui.dna_dialog.hide()
	ui.next_night_button.pressed.emit()
	_check(farm.energy_kj == 88 and farm.dna_editor.progress == 10, "one editor debit on day advance")
	ui.next_night_button.pressed.emit()
	_check(farm.energy_kj == 76 and farm.disc_uses["Fast Growth"] == 2 and parent.heat == 6 and farm.beans.size() == 3, "successful edit commits once")
	_check(farm.reproduction_rng.state == reproduction_rng and not farm.seed_edit_locked(parent), "independent RNG and release")
	_check(farm.plant_bean() and farm.plant.target == 17, "edited seed cultivates")
	farm.toggle_running()
	for night in 3:
		ui.next_night_button.pressed.emit()
	_check(farm.collect() and farm.beans.back().heat == 0 and farm.beans.back().traits.get("Fast Growth") == 1, "harvest inherits and resets heat")
	farm.dna_editor.rng.seed = 42
	var failure_target = farm.selected_seed()
	failure_target.heat = 22
	_check(farm.begin_edit(failure_target, "High Yield"), "hot seed remains editable")
	farm.energy_kj = 180
	for night in farm.dna_editor.operation.nights:
		ui.next_night_button.pressed.emit()
	_check(farm.dna_editor.stage == D.Stage.FAILED and failure_target.heat == 28 and not failure_target.traits.has("High Yield") and farm.disc_uses["High Yield"] == 3, "runtime failure preserves disc and increments heat")

func _check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("DNA_EDITOR_CHECK_FAILED: " + label)
