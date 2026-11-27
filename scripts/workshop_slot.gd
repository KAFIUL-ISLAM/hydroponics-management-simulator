extends Button
## A contextual slot delegates all validation and mutation to the workshop.

var accepts: Callable
var receive: Callable
var produce: Callable
var drop_glow: ColorRect

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
	return data

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT or what == NOTIFICATION_DRAG_END:
		self_modulate = Color.WHITE
		if drop_glow != null:
			drop_glow.hide()
