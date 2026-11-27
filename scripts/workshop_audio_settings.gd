extends AcceptDialog

const Workstation = preload("res://scripts/workstation_view.gd")
const Audio = preload("res://scripts/workshop_audio.gd")

var levels: Dictionary[String, HSlider] = {}
var values: Dictionary[String, Label] = {}
var mute: CheckButton
var reset_button: Button

func setup(audio: Audio) -> void:
	title = "音频设置 / Audio settings"
	size = Vector2i(460, 270)
	transient = true
	exclusive = true
	get_ok_button().text = "关闭 / Close"
	var housing := PanelContainer.new()
	housing.custom_minimum_size.x = 430
	housing.add_theme_stylebox_override("panel", Workstation.frame(Color("#414943"), Color("#8e7d55"), 11))
	add_child(housing)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 9)
	housing.add_child(column)
	var header := Workstation.section(column, "◉  音频控制台 / Audio console")
	header.add_theme_color_override("font_color", Color("#e6cf9d"))
	header.add_theme_font_size_override("font_size", 19)
	var display := PanelContainer.new()
	display.add_theme_stylebox_override("panel", Workstation.frame(Color("#192a29"), Color("#64746a"), 10))
	column.add_child(display)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("v_separation", 10)
	grid.add_theme_constant_override("h_separation", 10)
	display.add_child(grid)
	var captions := {"master": "总音量 / Master", "sfx": "音效 / Effects"}
	for key: String in captions:
		Workstation.section(grid, captions[key])
		var slider := HSlider.new()
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.custom_minimum_size.y = 22
		slider.max_value = 1.0
		slider.step = 0.01
		slider.tooltip_text = captions[key]
		slider.value_changed.connect(func(value: float) -> void: audio.set_level(key, value))
		grid.add_child(slider)
		levels[key] = slider
		values[key] = Workstation.section(grid, "")
		values[key].custom_minimum_size.x = 45
	var actions := HBoxContainer.new()
	column.add_child(actions)
	mute = CheckButton.new()
	mute.text = "全部静音 / Mute all"
	mute.toggled.connect(audio.set_muted)
	actions.add_child(mute)
	reset_button = Button.new()
	reset_button.text = "恢复默认 / Reset defaults"
	reset_button.pressed.connect(audio.reset)
	reset_button.pressed.connect(func() -> void: audio.play(&"ui_click"))
	actions.add_child(reset_button)
	audio.preferences_changed.connect(_sync.bind(audio))
	_sync(audio)
	Workstation.bind_escape(self, hide)

func _sync(audio: Audio) -> void:
	for key: String in levels:
		var value: float = audio.preferences[key]
		levels[key].set_value_no_signal(value)
		values[key].text = "%d%%" % roundi(value * 100.0)
	mute.set_pressed_no_signal(audio.preferences.mute)
