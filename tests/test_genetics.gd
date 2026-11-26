extends Node

const G = preload("res://scripts/crop_genetics.gd")
const UI = preload("res://scenes/coffee_dashboard.tscn")
const COFFEE = preload("res://resources/coffee_beans.tres")
const FRUIT = preload("res://resources/nutrition_fruit.tres")
const KOTTON = preload("res://resources/kotton.tres")
var checks := 0
var failures := 0

func _ready() -> void:
	for fixture: Array in [[FRUIT,16,7,100000,50,0.50,2.50,0.70,1.00,8],
		[COFFEE,21,8,100000,30,1.75,3.25,1.00,1.01,0], [KOTTON,43,13,250000,75,2.00,5.00,1.50454,1.26,0]]:
		var base: ReferenceCrop = fixture[0]
		var resolved := G.resolve(base, base.native_traits, 0)
		_check(resolved.valid() and resolved.native and resolved.crop != base, "native snapshot")
		var crop := resolved.crop
		_check([crop.target,crop.healthy_output,crop.draw_ul,crop.uptake_ul_per_point,crop.mineral_low_pct,
			crop.mineral_high_pct,crop.native_pollution_sensitivity,crop.pollution_damage_factor,resolved.complexity] == fixture.slice(1), "native properties")
		for id: String in base.native_traits:
			_check(G.definition(id) != null, "native metadata")
	var ranks: Dictionary[String, int] = COFFEE.native_traits.duplicate()
	ranks.merge({"Fast Growth": 2,"High Yield": 3,"Drought Resistant": 1,"Hardy": 1})
	var modified := G.resolve(COFFEE, ranks, 6)
	_check(modified.valid() and not modified.native and modified.complexity == 25 and modified.heat == 6, "positive complexity")
	_check(modified.crop.target == 15 and modified.crop.healthy_output == 12 and modified.crop.draw_ul == 75000, "positive modifiers")
	_check(modified.crop.native_pollution_sensitivity == 0.70 and modified.crop.pollution_damage_factor == 1.01, "separate pollution factors")
	_check(G.heat_increment(G.definition("Fast Growth")) == 6 and G.heat_increment(G.definition("Slow Growth")) == 5, "heat increment")
	_check(modified.caffeine_ul == 8000 and modified.coffee_paste_ul == 44800, "native Coffee active composition")
	ranks["Slow Growth"] = 1
	_check(not G.resolve(COFFEE, ranks, 0).valid(), "opposing traits")
	for invalid: Dictionary[String, int] in [
		_dict("Unknown", 1), _dict("Fast Growth", 0), _dict("Fast Growth", 21),
		_dict("Sterile", 1), _dict("Complex Genome", 2), _dict("Potent", 1)]:
		_check(not G.resolve(COFFEE, invalid, 0).valid(), "invalid trait")
	_check(not G.resolve(COFFEE, COFFEE.native_traits, -1).valid(), "invalid heat")
	var negative: Dictionary[String, int] = {"Slow Growth": 1, "Low Yield": 1, "Fragile": 2}
	var slow := G.resolve(COFFEE, negative, 0)
	_check(slow.crop.target == 28 and slow.crop.healthy_output == 6 and is_equal_approx(slow.crop.native_pollution_sensitivity, 1.504537849), "negative modifiers")
	_check(slow.complexity == -2, "removed native and added negative complexity")
	var kotton_ranks: Dictionary[String, int] = KOTTON.native_traits.duplicate()
	kotton_ranks.erase("High Water Use")
	_check(not G.resolve(KOTTON, kotton_ranks, 0).valid(), "unresolved raw Kotton draw")
	var synthetic := COFFEE.duplicate() as ReferenceCrop
	synthetic.raw_target = 10
	synthetic.raw_base_output = 5
	var rounding: Dictionary[String, int] = {"Fast Growth": 1, "High Yield": 1}
	_check(G.resolve(synthetic, rounding, 0).crop.target == 8, "growth rounds after division")
	synthetic.raw_target = 17
	rounding = {"Slow Growth": 4}
	_check(G.resolve(synthetic, rounding, 0).crop.target == 58, "rank exponent then rounding")
	_check(G._half_even(6.5) == 6 and G._half_even(7.5) == 8, "growth ties round to even")
	await _integration()
	print("GENETICS_TEST_RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _dict(id: String, rank: int) -> Dictionary[String, int]:
	return {id: rank}

func _integration() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.gui_embed_subwindows = true
	add_child(viewport)
	var ui = UI.instantiate()
	viewport.add_child(ui)
	var seed = ui.farm.beans.back()
	_check(seed.get_instance_id() != ui.farm.beans.front().get_instance_id(), "independent identity")
	seed.traits["Fast Growth"] = 2
	seed.traits["Drought Resistant"] = 1
	_check(not ui.farm.beans.front().traits.has("Fast Growth") and not COFFEE.native_traits.has("Fast Growth"), "independent traits")
	ui.actions["genetics"].pressed.emit()
	_check(ui.genetics_dialog.dialog_text.contains("Modified") and ui.genetics_dialog.dialog_text.contains("Fast Growth 2"), "stock dialog binding")
	ui.genetics_dialog.hide()
	ui.actions["plant"].pressed.emit()
	seed.traits["Fast Growth"] = 1
	_check(ui.farm.plant.target == 15 and ui.farm.plant.genetics.traits["Fast Growth"] == 2, "plant freezes seed properties")
	ui.actions["genetics"].pressed.emit()
	_check(ui.genetics_dialog.dialog_text.contains("Fast Growth 2"), "planted dialog binding")
	ui.genetics_dialog.hide()
	ui.actions["run"].pressed.emit()
	ui.next_night_button.pressed.emit()
	_check(ui.last_night.draw_ul == 75000 and ui.farm.plant.growth == 8 and ui.farm.energy_kj == 92, "night uses planted effective draw")
	ui.actions["genetics"].pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	_check(Rect2i(0,0,1280,720).encloses(Rect2i(ui.genetics_dialog.position, ui.genetics_dialog.size)), "dialog bounds")
	_check(Rect2(0,0,1280,720).encloses(ui.next_night_button.get_global_rect()), "dashboard bounds")

func _check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("GENETICS_CHECK_FAILED: " + label)
