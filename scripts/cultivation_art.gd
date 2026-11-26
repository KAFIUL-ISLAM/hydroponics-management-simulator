extends RefCounted

const Art = preload("res://scripts/orbital_art.gd")
enum Stage { EMPTY, SEEDLING, GROWING, MATURE }

var art: Art
var scene: TextureRect
var crop_sprite: TextureRect
var stage_label: Label
var fallback_label: Label
var stage := Stage.EMPTY
var hotspot_layer: Control

func _init(layers: Control, assets: Art) -> void:
	art = assets
	var fit := AspectRatioContainer.new()
	fit.ratio = 900.0 / 660.0
	fit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layers.add_child(fit)
	fit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var canvas := Control.new()
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.clip_contents = true
	fit.add_child(canvas)
	for layer_name: String in ["ChamberBackdrop", "MachineOverlay", "CropStage", "Foreground", "Effects"]:
		var layer := Control.new()
		layer.name = layer_name
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		canvas.add_child(layer)
		layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var source := art.texture("laboratory")
	var cropped: AtlasTexture
	if source != null:
		cropped = AtlasTexture.new()
		cropped.atlas = source
		cropped.region = Rect2(400, 10, 900, 660)
		cropped.filter_clip = true
	scene = Art.decoration(cropped)
	canvas.get_node("ChamberBackdrop").add_child(scene)
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	crop_sprite = Art.decoration(null)
	canvas.get_node("CropStage").add_child(crop_sprite)
	crop_sprite.set_anchor(SIDE_LEFT, 0.335)
	crop_sprite.set_anchor(SIDE_RIGHT, 0.665)
	crop_sprite.set_anchor(SIDE_TOP, 0.22)
	crop_sprite.set_anchor(SIDE_BOTTOM, 0.71)
	fallback_label = Label.new()
	fallback_label.text = "美术暂缺 / Artwork unavailable"
	fallback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fallback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fallback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fallback_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.get_node("Effects").add_child(fallback_label)
	fallback_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hotspot_layer = Control.new()
	hotspot_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(hotspot_layer)
	hotspot_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage_label = Label.new()
	stage_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layers.add_child(stage_label)

func add_hotspot(label: String, hint: String, region: Rect2, action: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.tooltip_text = hint
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 12)
	button.clip_text = true
	hotspot_layer.add_child(button)
	button.set_anchor(SIDE_LEFT, region.position.x)
	button.set_anchor(SIDE_RIGHT, region.end.x)
	button.set_anchor(SIDE_TOP, region.position.y)
	button.set_anchor(SIDE_BOTTOM, region.end.y)
	button.add_theme_stylebox_override("normal", _hotspot_style(Color("#101820d9"), Color("#58BCEB")))
	button.add_theme_stylebox_override("hover", _hotspot_style(Color("#304653"), Color("#59D9B0")))
	button.add_theme_stylebox_override("pressed", _hotspot_style(Color("#1C2B36"), Color("#59D9B0")))
	button.pressed.connect(action)
	return button

func _hotspot_style(fill: Color, edge: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	return style

func render(has_plant: bool, species: int, growth: int, target: int, mature: bool, running: bool) -> void:
	var key := ""
	stage = Stage.EMPTY
	stage_label.text = "空舱 / Empty chamber"
	if has_plant:
		if mature:
			stage = Stage.MATURE
			key = Art.species_key(species) + "_mature"
			stage_label.text = "等待收获 / Harvest pending"
		elif target > 0 and float(growth) / float(target) >= 0.33:
			stage = Stage.GROWING
			key = "growing"
			stage_label.text = "生长阶段 / Growing stage"
		else:
			stage = Stage.SEEDLING
			key = "seedling"
			stage_label.text = "幼苗阶段 / Seedling"
	var image := art.texture(key, "growing" if mature else "")
	crop_sprite.texture = image
	crop_sprite.visible = has_plant and image != null
	fallback_label.visible = scene.texture == null or (has_plant and image == null)
	scene.modulate = Color.WHITE if running or mature else Color("#b4c2ca")
