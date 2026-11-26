extends RefCounted

const Art = preload("res://scripts/orbital_art.gd")

class EscapeInput extends Node:
	var close: Callable

	func _input(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			close.call()

static func bind_escape(dialog: AcceptDialog, close: Callable) -> void:
	var input := EscapeInput.new()
	input.close = close
	dialog.add_child(input)

static func body(dialog: AcceptDialog, title: String, artwork: Texture2D, accent: Color) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(680, 445)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	dialog.add_child(scroll)
	var padding := MarginContainer.new()
	padding.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side: String in ["top", "bottom", "left", "right"]:
		padding.add_theme_constant_override("margin_" + side, 14)
	scroll.add_child(padding)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	padding.add_child(content)
	var banner := HBoxContainer.new()
	content.add_child(banner)
	var image := Art.decoration(artwork)
	image.custom_minimum_size = Vector2(48, 54)
	banner.add_child(image)
	var title_label := section(banner, title)
	title_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_label.add_theme_font_size_override("font_size", 19)
	title_label.add_theme_color_override("font_color", accent)
	content.add_child(HSeparator.new())
	return content

static func section(parent: Container, value: String) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color("#b1cbd6"))
	parent.add_child(label)
	return label

static func readout(parent: Container) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 14)
	parent.add_child(label)
	return label

static func meter(parent: Container) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.step = 0
	bar.custom_minimum_size.y = 11
	parent.add_child(bar)
	return bar

static func row(parent: Container) -> VBoxContainer:
	var panel := PanelContainer.new()
	parent.add_child(panel)
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 4)
	panel.add_child(inner)
	return inner
