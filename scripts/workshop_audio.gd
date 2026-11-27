extends Node
## Workshop-owned audio voices and preferences. Callers publish confirmed UI events.

signal cue_requested(cue: StringName)
signal preferences_changed

const SETTINGS_PATH := "user://workshop_presentation.cfg"
const DEFAULTS := {"master": 0.8, "sfx": 0.7, "mute": false}
const BUSES := {"master": &"Master", "sfx": &"SFX"}
const CUES := {
	&"ui_click": preload("res://assets/audio/ui_click.wav"),
	&"item_pickup": preload("res://assets/audio/item_pickup.wav"),
	&"item_place": preload("res://assets/audio/item_place.wav"),
	&"item_reject": preload("res://assets/audio/item_reject.wav"),
	&"popup_open": preload("res://assets/audio/popup_open.wav"),
	&"popup_close": preload("res://assets/audio/popup_close.wav"),
	&"page_turn": preload("res://assets/audio/page_turn.wav"),
	&"tab_switch": preload("res://assets/audio/tab_switch.wav"),
	&"machine_start": preload("res://assets/audio/machine_start.wav"),
	&"machine_stop": preload("res://assets/audio/machine_stop.wav"),
	&"night_transition": preload("res://assets/audio/night_transition.wav"),
	&"harvest_ready": preload("res://assets/audio/harvest_ready.wav"),
	&"item_collect": preload("res://assets/audio/item_collect.wav"),
	&"resource_warning": preload("res://assets/audio/resource_warning.wav"),
	&"dna_success": preload("res://assets/audio/dna_success.wav"),
	&"dna_failure": preload("res://assets/audio/dna_failure.wav"),
}
const VOICE_COUNT := 5
const COOLDOWN_MS := {&"ui_click": 65, &"item_reject": 120, &"tab_switch": 65}

var settings_path := SETTINGS_PATH
var preferences := DEFAULTS.duplicate()
var voices: Array[AudioStreamPlayer] = []
var _next_voice := 0
var _audible_backend := false
var _last_played_ms: Dictionary[StringName, int] = {}

func _ready() -> void:
	_audible_backend = DisplayServer.get_name() != "headless" and AudioServer.get_driver_name() != "Dummy"
	for index in VOICE_COUNT:
		var voice := _new_player(&"SFX")
		voice.volume_db = -8.0 # Keep peak headroom even with all voices at full volume.
		voices.append(voice)
	reload_preferences()

func _new_player(bus: StringName) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = bus
	add_child(player)
	return player

func play(cue: StringName) -> void:
	if not CUES.has(cue):
		return
	cue_requested.emit(cue)
	if not _audible_backend or preferences.mute or preferences.master == 0.0 or preferences.sfx == 0.0:
		return
	if COOLDOWN_MS.has(cue):
		var now := Time.get_ticks_msec()
		var cooldown: int = COOLDOWN_MS[cue]
		if now - _last_played_ms.get(cue, -cooldown) < cooldown:
			return
		_last_played_ms[cue] = now
	var player := voices[_next_voice]
	_next_voice = (_next_voice + 1) % voices.size()
	player.stop()
	player.stream = CUES[cue]
	player.play()

func reload_preferences() -> void:
	var file := ConfigFile.new()
	file.load(settings_path)
	for key: String in BUSES:
		var value: Variant = file.get_value("audio", key, DEFAULTS[key])
		preferences[key] = clampf(float(value), 0.0, 1.0) if ((value is float or value is int) and is_finite(float(value))) else DEFAULTS[key]
	preferences.mute = file.get_value("audio", "mute", false) == true
	_apply_preferences()

func set_level(key: String, level: float) -> void:
	if BUSES.has(key) and is_finite(level):
		preferences[key] = clampf(level, 0.0, 1.0)
		_save()

func set_muted(muted: bool) -> void:
	preferences.mute = muted
	_save()

func reset() -> void:
	preferences = DEFAULTS.duplicate()
	_save()

func _save() -> void:
	_apply_preferences()
	var file := ConfigFile.new()
	file.load(settings_path)
	for key: String in preferences:
		file.set_value("audio", key, preferences[key])
	if file.save(settings_path) != OK:
		push_warning("Workshop audio preferences could not be saved.")

func _apply_preferences() -> void:
	for key: String in BUSES:
		var bus := AudioServer.get_bus_index(BUSES[key])
		if bus < 0:
			continue
		var level: float = preferences[key]
		AudioServer.set_bus_volume_db(bus, linear_to_db(level) if level > 0.0 else -80.0)
		AudioServer.set_bus_mute(bus, level == 0.0 or (key == "master" and preferences.mute))
	preferences_changed.emit()
