extends RefCounted

const Art = preload("res://scripts/orbital_art.gd")
const FIXED_SIZE := Vector2i(840, 570)

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

static func fixed_body(dialog: AcceptDialog, title: String, artwork: Texture2D, housing: Color, display: Color, accent: Color) -> VBoxContainer:
	dialog.set_meta("fixed_instrument", true)
	dialog.size = FIXED_SIZE
	var shell := PanelContainer.new()
	shell.custom_minimum_size.x = 780
	shell.add_theme_stylebox_override("panel", frame(housing, accent.darkened(0.35), 15))
	dialog.add_child(shell)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 9)
	shell.add_child(body)
	var header := HBoxContainer.new()
	body.add_child(header)
	var bolt := section(header, "◉")
	bolt.add_theme_color_override("font_color", accent)
	var icon := Art.decoration(artwork)
	icon.custom_minimum_size = Vector2(39, 40)
	header.add_child(icon)
	var caption := section(header, title)
	caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	caption.add_theme_font_size_override("font_size", 20)
	caption.add_theme_color_override("font_color", accent)
	section(header, "◉")
	var screen := PanelContainer.new()
	screen.add_theme_stylebox_override("panel", frame(display, accent.darkened(0.58), 11))
	body.add_child(screen)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	screen.add_child(content)
	return content

static func frame(fill: Color, edge: Color, inset: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(2)
	style.set_corner_radius_all(9)
	for side: int in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_content_margin(side, inset)
	return style

static func fixed_tabs(parent: Container) -> TabContainer:
	var tabs := TabContainer.new()
	tabs.use_hidden_tabs_for_min_size = true
	tabs.get_tab_bar().scroll_to_selected = true
	parent.add_child(tabs)
	return tabs

static func fixed_page(tabs: TabContainer, title: String) -> VBoxContainer:
	var inset := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		inset.add_theme_constant_override("margin_" + side, 12)
	tabs.add_child(inset)
	tabs.set_tab_title(tabs.get_tab_count() - 1, title)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	inset.add_child(content)
	return content

static func append_reading_pages(tabs: TabContainer, title: String, text: String, lines_per_page := 9, columns := false) -> void:
	if text.strip_edges().is_empty():
		return
	var lines := text.strip_edges().split("\n")
	var count := ceili(float(lines.size()) / lines_per_page)
	for index in count:
		var name_text := title if count == 1 else "%s %d" % [title, index + 1]
		var page := fixed_page(tabs, name_text)
		var page_lines := lines.slice(index * lines_per_page, (index + 1) * lines_per_page)
		if not columns:
			fixed_readout(page, "\n".join(page_lines), 288)
			continue
		var grid := GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 16)
		grid.add_theme_constant_override("v_separation", 5)
		page.add_child(grid)
		for line: String in page_lines:
			var pair := line.split(": ", true, 1)
			var caption := fixed_readout(grid, pair[0], 33)
			caption.custom_minimum_size.x = 280
			var measurement := fixed_readout(grid, pair[1] if pair.size() > 1 else "", 33)
			measurement.custom_minimum_size.x = 365

static func fixed_readout(parent: Container, value: String, height: int) -> RichTextLabel:
	var reading := RichTextLabel.new()
	reading.fit_content = false
	reading.scroll_active = false
	reading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reading.custom_minimum_size.y = height
	reading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reading.add_theme_font_size_override("normal_font_size", 14)
	reading.text = value
	parent.add_child(reading)
	return reading

static func clear_pages(tabs: TabContainer, keep := 0) -> void:
	while tabs.get_child_count() > keep:
		var page := tabs.get_child(keep)
		tabs.remove_child(page)
		page.queue_free()

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
