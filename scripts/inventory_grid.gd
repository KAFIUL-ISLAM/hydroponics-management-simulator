extends ItemList
## Positions are presentation-only. The farm still owns every seed and product stack.

const VALID_COLOR := Color(0.12, 0.43, 0.33, 1.0)
const INVALID_COLOR := Color(0.48, 0.19, 0.21, 1.0)

var slots: Array[String] = []
var rows: Dictionary = {}
var selected_key := ""
var placement_enabled := false
var placement_allowed: Callable
var external_can_drop: Callable
var external_drop: Callable
var _active_drag: Dictionary = {}
var _pressed_key := ""
var _highlight := -1
var _empty_icon: Texture2D
var arriving_key := ""

func sync(entries: Dictionary, capacity: int, selection: String, enabled: bool) -> void:
	var slot_count := maxi(capacity, entries.size())
	selected_key = selection
	placement_enabled = enabled
	if entries == rows and slot_count == slots.size():
		_sync_selection()
		return
	rows = entries
	if not _active_drag.is_empty() and not rows.has(_active_drag.key):
		_active_drag = {}
	for slot in slots.size():
		if not rows.has(slots[slot]):
			slots[slot] = ""
	slots.resize(slot_count)
	for key: String in rows:
		if not slots.has(key):
			slots[slots.find("")] = key
	_draw_slots()

func _draw_slots() -> void:
	if _empty_icon == null:
		var cell := Image.create_empty(29, 29, false, Image.FORMAT_RGBA8)
		cell.fill_rect(Rect2i(2, 2, 25, 25), Color("#344b5e"))
		cell.fill_rect(Rect2i(3, 3, 23, 23), Color("#182734"))
		_empty_icon = ImageTexture.create_from_image(cell)
	clear()
	_highlight = -1
	for key in slots:
		if key.is_empty():
			var slot := add_item("", _empty_icon)
			set_item_selectable(slot, false)
			set_item_tooltip_enabled(slot, false)
		else:
			var row: Dictionary = rows[key]
			var slot := add_item("", row.icon)
			set_item_tooltip(slot, row.tooltip)
			if key == arriving_key:
				set_item_icon_modulate(slot, Color.TRANSPARENT)
	_sync_selection()

func reveal_arrival() -> void:
	var slot := slots.find(arriving_key)
	if not arriving_key.is_empty() and slot >= 0:
		set_item_icon_modulate(slot, Color.WHITE)
	arriving_key = ""

func _sync_selection() -> void:
	var slot := slots.find(selected_key) if not selected_key.is_empty() else -1
	if slot >= 0:
		select(slot)
	else:
		deselect_all()

func _get_drag_data(at_position: Vector2) -> Variant:
	var slot := slots.find(_pressed_key) if not _pressed_key.is_empty() else get_item_at_position(at_position, true)
	if not _placement_allowed() or slot < 0 or slots[slot].is_empty() or slots[slot] == arriving_key:
		return null
	_active_drag = {"key": slots[slot]}
	var preview := TextureRect.new()
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.texture = get_item_icon(slot)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.size = Vector2(32, 32)
	set_drag_preview(preview)
	return _active_drag

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var slot := get_item_at_position(event.position, true) if event.pressed else -1
		_pressed_key = slots[slot] if slot >= 0 else ""

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var slot := get_item_at_position(at_position, true)
	var own_drag := not drag_key(data).is_empty()
	var valid: bool = _can_place(slot, data) if own_drag else (
		slot >= 0 and external_can_drop.is_valid() and external_can_drop.call(data))
	_clear_highlight()
	if slot >= 0 and (own_drag or valid):
		_highlight = slot
		set_item_custom_bg_color(slot, VALID_COLOR if valid else INVALID_COLOR)
	return valid

func _can_place(slot: int, data: Variant) -> bool:
	return _placement_allowed() and slot >= 0 and slot < slots.size() \
		and not drag_key(data).is_empty() and slots[slot] != _active_drag.key \
		and (arriving_key.is_empty() or slots[slot] != arriving_key)

func _placement_allowed() -> bool:
	return placement_allowed.call() if placement_allowed.is_valid() else placement_enabled

func drag_key(data: Variant) -> String:
	if not _active_drag.is_empty() and is_same(data, _active_drag) and rows.has(_active_drag.key):
		return _active_drag.key
	return ""

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var target := get_item_at_position(at_position, true)
	if not _can_place(target, data):
		if target >= 0 and external_can_drop.is_valid() and external_can_drop.call(data):
			external_drop.call(data)
		return
	var source := slots.find(_active_drag.key)
	slots[source] = slots[target]
	slots[target] = _active_drag.key
	_active_drag = {}
	_draw_slots()

func _clear_highlight() -> void:
	if _highlight >= 0:
		set_item_custom_bg_color(_highlight, Color.TRANSPARENT)
		_highlight = -1

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END or what == NOTIFICATION_MOUSE_EXIT:
		_clear_highlight()
	if what == NOTIFICATION_DRAG_END:
		_active_drag = {}
		_pressed_key = ""
