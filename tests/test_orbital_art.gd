extends Node

const UI = preload("res://scenes/coffee_dashboard.tscn")
const Chamber = preload("res://scripts/cultivation_art.gd")
var checks := 0
var failures := 0

func _ready() -> void:
	await _fixture(Vector2i(1280, 720))
	await _fixture(Vector2i(1920, 1080))
	print("ORBITAL_ART_TEST_RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _fixture(dimensions: Vector2i) -> void:
	var viewport := SubViewport.new()
	viewport.size = dimensions
	add_child(viewport)
	var ui = UI.instantiate()
	viewport.add_child(ui)
	var art: Chamber = ui.cultivation_art
	_check(art.scene.texture != null and art.stage == Chamber.Stage.EMPTY and not art.crop_sprite.visible, "empty with laboratory art")
	var species_keys := ["coffee", "nutrition", "kotton"]
	for index: int in species_keys.size():
		ui.farm.select_species(index)
		if index == 0:
			ui.farm.supply_modified_coffee()
		ui.actions["plant"].pressed.emit()
		_check(art.stage == Chamber.Stage.SEEDLING and art.crop_sprite.texture == ui.art.texture("seedling"), "planted seedling")
		var plant = ui.farm.plant
		if index == 0:
			_check(plant.target == 15, "genetic fixture target")
			plant.growth = 5
		else:
			plant.growth = ceili(plant.target * 0.33)
		ui._render()
		_check(art.stage == Chamber.Stage.GROWING and art.crop_sprite.texture == ui.art.texture("growing"), "growth uses actual target")
		plant.stage = plant.Stage.MATURE
		ui._render()
		var key: String = species_keys[index] + "_mature"
		_check(art.crop_sprite.texture == ui.art.texture(key) and art.stage_label.text.contains("Harvest pending"), "species mature pending")
		var selected_texture: Texture2D = ui.art.textures[key]
		ui.art.textures.erase(key)
		ui._render()
		_check(art.crop_sprite.texture == ui.art.texture("growing"), "missing mature uses fallback")
		ui.art.textures[key] = selected_texture
		ui.actions["harvest"].pressed.emit()
		_check(art.stage == Chamber.Stage.EMPTY and not art.crop_sprite.visible and ui.control_hint.text.contains("Harvest collected"), "collected clears sprite")
	await get_tree().process_frame
	await get_tree().process_frame
	var pane := art.scene.get_global_rect()
	_check(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(pane) and pane.size.x > 0 and pane.size.y > 0, "art within dashboard")
	_check(absf(pane.size.x / pane.size.y - 900.0 / 660.0) < 0.02, "art aspect preserved")
	_check(pane.encloses(art.crop_sprite.get_global_rect()), "crop placement inside artwork")
	_check(art.scene.mouse_filter == Control.MOUSE_FILTER_IGNORE and art.crop_sprite.mouse_filter == Control.MOUSE_FILTER_IGNORE, "decorative textures ignore input")
	_check(ui.actions["analysis"].icon != null and ui.actions["equipment"].icon != null and ui.actions["install_module"].icon != null, "equipment icons present")
	_check(ui.inventory_icon_key("unknown") == "" and ui.inventory_icon_key(ui.farm.beans.front()) == "seed", "inventory icon fallback")
	viewport.free()

func _check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("ORBITAL_ART_CHECK_FAILED: " + label)
