extends Node

const Workshop = preload("res://scenes/workshop.tscn")
const Audio = preload("res://scripts/workshop_audio.gd")
const View = preload("res://scripts/workshop_view.gd")
const Editor = preload("res://scripts/dna_editor.gd")

var checks := 0
var failures := 0

func _ready() -> void:
	await _settings(Vector2i(1280, 720), true)
	await _settings(Vector2i(1920, 1080), false)
	var audible := await _cultivate(false)
	var muted := await _cultivate(true)
	_check(audible == muted, "mute preserves authoritative farm state and harvest")
	await _dna_result(true)
	await _dna_result(false)
	print("WORKSHOP_AUDIO_TEST_RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _fixture(dimensions := Vector2i(1280, 720)) -> SubViewport:
	var viewport := SubViewport.new()
	viewport.size = dimensions
	viewport.gui_embed_subwindows = true
	add_child(viewport)
	viewport.add_child(Workshop.instantiate())
	return viewport

func _settings(dimensions: Vector2i, inspect_assets: bool) -> void:
	var viewport := _fixture(dimensions)
	await get_tree().process_frame
	var view: View = viewport.get_child(0).workshop
	var audio := view.audio
	var path := OS.get_environment("TEMP").path_join("workshop-audio-%d.cfg" % OS.get_process_id())
	audio.settings_path = path
	audio.reload_preferences()
	if inspect_assets:
		for cue: StringName in Audio.CUES:
			var stream := Audio.CUES[cue] as AudioStreamWAV
			_check(stream != null and stream.mix_rate == 44100 and not stream.stereo and stream.format == AudioStreamWAV.FORMAT_16_BITS and stream.get_length() > 0.0, "imported mono PCM cue %s" % cue)
		var sfx_bus := AudioServer.get_bus_index(&"SFX")
		_check(Audio.CUES.size() == 16 and not ResourceLoader.exists("res://assets/audio/workshop_ambience.wav"), "only the 16 one-shot cue assets are available")
		_check(AudioServer.bus_count == 2 and sfx_bus > 0 and AudioServer.get_bus_send(sfx_bus) == &"Master", "SFX is the only bus routed to Master")
		_check(audio.voices.all(func(voice: AudioStreamPlayer) -> bool: return voice.bus == &"SFX" and voice.stream == null and not voice.playing), "all playback voices route through SFX and have no stream at idle launch")
	_check(audio.preferences == Audio.DEFAULTS, "default levels and mute")
	var cues: Array[StringName] = []
	audio.cue_requested.connect(func(cue: StringName) -> void: cues.append(cue))
	var button := view.audio_button
	button.grab_focus()
	_key(viewport, KEY_ENTER, true)
	_key(viewport, KEY_ENTER, false)
	await get_tree().process_frame
	var dialog := view.audio_settings
	_check(dialog.visible and dialog.exclusive and Rect2i(Vector2i.ZERO, dimensions).encloses(Rect2i(dialog.position, dialog.size)), "keyboard opens bounded exclusive audio settings")
	_check(dialog.find_children("*", "ScrollContainer", true, false).is_empty(), "fixed layout has no scrolling")
	_check(dialog.levels.keys() == ["master", "sfx"], "settings show only Master and SFX sliders")
	dialog.levels.master.grab_focus()
	_key(dialog, KEY_LEFT, true)
	_key(dialog, KEY_LEFT, false)
	_check(is_equal_approx(audio.preferences.master, 0.79) and dialog.values.master.text == "79%", "keyboard changes volume and readout")
	_check(is_equal_approx(AudioServer.get_bus_volume_db(0), linear_to_db(0.79)), "master applies in decibels")
	var sfx_index := AudioServer.get_bus_index(&"SFX")
	dialog.levels.sfx.value = 0.4
	_check(is_equal_approx(AudioServer.get_bus_volume_db(sfx_index), linear_to_db(0.4)) and is_equal_approx(AudioServer.get_bus_volume_db(0), linear_to_db(0.79)), "SFX volume applies independently of Master")
	dialog.levels.sfx.value = 0.0
	_check(AudioServer.is_bus_mute(sfx_index) and not AudioServer.is_bus_mute(0), "zero SFX applies safely")
	dialog.mute.button_pressed = true
	_check(AudioServer.is_bus_mute(0), "global mute applies")
	var settings := ConfigFile.new()
	_check(settings.load(path) == OK, "settings saved through existing ConfigFile format")
	settings.set_value("accessibility", "reduced_motion", true)
	settings.set_value("audio", "ambience", 0.4)
	settings.save(path)
	audio.reload_preferences()
	_check(is_equal_approx(audio.preferences.master, 0.79) and audio.preferences.sfx == 0.0 and audio.preferences.mute and not audio.preferences.has("ambience"), "legacy audio preferences load while ignoring the retired ambience key")
	dialog.reset_button.pressed.emit()
	settings.load(path)
	_check(audio.preferences == Audio.DEFAULTS and settings.get_value("accessibility", "reduced_motion") == true and is_equal_approx(settings.get_value("audio", "ambience"), 0.4), "reset leaves Reduced Motion and the inert legacy key intact")
	_key(dialog, KEY_ESCAPE, true)
	await get_tree().process_frame
	await get_tree().process_frame
	_check(not dialog.visible and button.has_focus(), "Escape restores focus to the speaker control")
	_check(cues.count(&"popup_open") == 1 and cues.count(&"popup_close") == 1, "one cue per actual popup visibility change")
	var initial_voices := audio.voices.duplicate()
	for repeat in 3:
		view.dashboard._open_dna()
		view.dashboard.dna_pages.current_tab = 1
		view.dashboard.dna_pages.current_tab = 1
		view.dashboard.dna_pages.current_tab = 0
		view.dashboard.dna_dialog.hide()
	for index in 30:
		audio.play(&"ui_click")
	_check(cues.count(&"tab_switch") == 6, "visible tabs cue only on actual page changes")
	view._open_manual()
	var pages := view.manual.find_children("*", "TabContainer", true, false)[0] as TabContainer
	pages.current_tab = 1
	pages.current_tab = 1
	view.manual.hide()
	_check(cues.count(&"page_turn") == 1, "manual emits only one cue for the changed page")
	_check(audio.get_child_count() == Audio.VOICE_COUNT and audio.voices == initial_voices, "headless navigation keeps exactly the same five effects voices")
	DirAccess.remove_absolute(path)
	viewport.free()

func _cultivate(muted: bool) -> Array:
	var viewport := _fixture()
	await get_tree().process_frame
	var ui = viewport.get_child(0)
	var view: View = ui.workshop
	view.set_reduced_motion(true)
	view.audio.preferences.mute = muted
	view.audio._apply_preferences()
	var cues: Array[StringName] = []
	view.audio.cue_requested.connect(func(cue: StringName) -> void: cues.append(cue))
	var farm: View.Farm = ui.farm
	farm.reproduction_rng.seed = 2026
	_check(farm.plant_bean() and farm.toggle_running(), "cultivation fixture starts")
	ui._render()
	ui._render()
	farm.toggle_running()
	ui._render()
	_check(cues.count(&"machine_start") == 1 and cues.count(&"machine_stop") == 1, "real machine start and stop cue once despite refreshes")
	farm.toggle_running()
	farm.energy_kj = 0
	ui._render()
	ui.game_state.start_night()
	ui._render()
	ui.game_state.start_night()
	_check(cues.count(&"resource_warning") == 1 and cues.count(&"night_transition") == 2, "persistent blocker warns once and each accepted night cues once")
	farm.energy_kj = 1000
	ui._render()
	var limit := farm.remaining_nights()
	for night in limit:
		ui.game_state.start_night()
		ui._render()
	_check(cues.count(&"harvest_ready") == 1 and cues.count(&"night_transition") == limit + 2, "production cues once with one cue per accepted night")
	var output := farm.pending_output().duplicate()
	_check(not output.is_empty(), "deterministic cultivation produces items")
	var result := [farm.energy_kj, farm.vessel.snapshot_ul(), farm.plant.growth, farm.plant.health, output]
	view._collect_from_slot(0)
	_check(cues.count(&"item_collect") == 1, "successful collection cues once")
	await get_tree().process_frame
	viewport.free()
	return result

func _dna_result(succeed: bool) -> void:
	var viewport := _fixture()
	await get_tree().process_frame
	var ui = viewport.get_child(0)
	var view: View = ui.workshop
	var farm: View.Farm = ui.farm
	var cues: Array[StringName] = []
	view.audio.cue_requested.connect(func(cue: StringName) -> void: cues.append(cue))
	var item := farm.selected_seed()
	var plan := farm.preview_edit(item, "Fast Growth")
	var probe := RandomNumberGenerator.new()
	for candidate in 1024:
		probe.seed = candidate
		if (probe.randf() < plan.success_pct / 100.0) == succeed:
			farm.dna_editor.rng.seed = candidate
			break
	_check(farm.begin_edit(item, "Fast Growth"), "DNA operation queued successfully")
	ui._render()
	_check(not cues.has(&"dna_success") and not cues.has(&"dna_failure"), "queued operation has no result cue")
	for night in plan.nights:
		ui.game_state.start_night()
		ui._render()
	_check(farm.dna_editor.stage == (Editor.Stage.SUCCEEDED if succeed else Editor.Stage.FAILED) and cues.count(&"dna_success") == int(succeed) and cues.count(&"dna_failure") == int(not succeed), "actual DNA outcome emits exactly one appropriate result cue")
	viewport.free()

func _key(target: Viewport, code: Key, down: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = down
	target.push_input(event, true)

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("WORKSHOP_AUDIO_CHECK_FAILED: " + label)
