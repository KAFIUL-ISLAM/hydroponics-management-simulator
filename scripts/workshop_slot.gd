extends Button
## A contextual slot delegates all validation and mutation to the workshop.

signal item_picked_up

var accepts: Callable
var receive: Callable
var produce: Callable
var drop_glow: ColorRect
var _drag_preview: TextureRect
var _drag_icon_hidden := false
const ICON_COLORS := [&"icon_normal_color", &"icon_hover_color", &"icon_pressed_color",
	&"icon_hover_pressed_color", &"icon_focus_color", &"icon_disabled_color"]

func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	var valid: bool = accepts.is_valid() and accepts.call(data)
	self_modulate = Color("#8cffce") if valid else Color("#ff8c8c")
	if drop_glow != null:
		drop_glow.visible = valid
	return valid

func _drop_data(_position: Vector2, data: Variant) -> void:
	try_transfer(data)

func try_transfer(data: Variant) -> bool:
	return accepts.is_valid() and accepts.call(data) and receive.call(data)

func _get_drag_data(_position: Vector2) -> Variant:
	if not produce.is_valid():
		return null
	var data: Variant = produce.call()
	if data != null:
		var preview := TextureRect.new()
		preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		preview.texture = icon
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.size = Vector2(40, 40)
		set_drag_preview(preview)
		_drag_preview = preview
		_drag_icon_hidden = true
		for key in ICON_COLORS:
			add_theme_color_override(key, Color.TRANSPARENT)
		item_picked_up.emit()
	return data

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and _drag_icon_hidden:
		for key in ICON_COLORS:
			remove_theme_color_override(key)
		_drag_preview = null
		_drag_icon_hidden = false
	if what == NOTIFICATION_MOUSE_EXIT or what == NOTIFICATION_DRAG_END:
		self_modulate = Color.WHITE
		if drop_glow != null:
			drop_glow.hide()
