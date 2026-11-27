extends CenterContainer
## Displays settled differences. The farm remains the source of every value.

const Farm = preload("res://scripts/coffee_farm.gd")
const Art = preload("res://scripts/orbital_art.gd")
const METRICS := [
	["energy", "energy", "电力 / Power", " kJ"],
	["water", "water", "纯水 / Water", " ml"],
	["minerals", "tablet", "矿物 / Minerals", " ml"],
	["growth", "seedling", "生长 / Growth", ""],
	["health", "", "健康 / HP", ""],
	["output", "", "产出 / Output", ""],
]

var art: Art
var metrics: Dictionary[String, int] = {}
var before: Dictionary[String, int] = {}
var row: HBoxContainer
var expiry: Timer

func setup(artwork: Art) -> void:
	art = artwork
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	row = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 14)
	panel.add_child(row)
	expiry = Timer.new()
	expiry.one_shot = true
	expiry.timeout.connect(clear)
	add_child(expiry)
	hide()

func capture(farm: Farm) -> void:
	before = _snapshot(farm)

func publish(farm: Farm, crop_icon: String) -> void:
	clear()
	var after := _snapshot(farm)
	for metric: Array in METRICS:
		var key: String = metric[0]
		var change: int = after[key] - before.get(key, after[key])
		if change == 0:
			continue
		metrics[key] = change
		var icon_key: String = crop_icon if key == "output" else metric[1]
		_add_result(art.texture(icon_key), metric[2], _format(key, change) + metric[3])
	before.clear()
	if not metrics.is_empty():
		show()
		expiry.start(2.3)

func clear() -> void:
	hide()
	expiry.stop()
	metrics.clear()
	for child in row.get_children():
		row.remove_child(child)
		child.queue_free()

func _snapshot(farm: Farm) -> Dictionary[String, int]:
	var liquid := farm.vessel.snapshot_ul()
	var output := 0
	for count: int in farm.pending_output().values():
		output += count
	return {
		"energy": farm.energy_kj,
		"water": liquid.get(Farm.W, 0),
		"minerals": liquid.get(Farm.M, 0),
		"growth": farm.plant.growth if farm.plant != null else 0,
		"health": farm.plant.health if farm.plant != null else 0,
		"output": output,
	}

func _format(key: String, change: int) -> String:
	if key == "water" or key == "minerals":
		return "%+.3f" % (change / 1000.0)
	return "%+d" % change

func _add_result(icon: Texture2D, caption: String, value: String) -> void:
	var cell := HBoxContainer.new()
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(cell)
	if icon != null:
		var image := Art.decoration(icon)
		image.custom_minimum_size = Vector2(19, 19)
		cell.add_child(image)
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = "%s %s" % [caption, value]
	label.add_theme_font_size_override("font_size", 13)
	cell.add_child(label)
