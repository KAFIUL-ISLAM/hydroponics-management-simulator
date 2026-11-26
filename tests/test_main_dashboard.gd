extends Node

const DASHBOARD = preload("res://scenes/main.tscn")

var _checks: int = 0
var _failures: int = 0


func _ready() -> void:
	var dashboard = DASHBOARD.instantiate()
	add_child(dashboard)
	_check(dashboard.day_label.text == "第 1 天", "default day")
	_check(dashboard.status_label.text.contains("Ready"), "default lifecycle status")
	_check(dashboard.crop_empty_title.text == "生菜 / Lettuce", "default crop")
	_check(dashboard.crop_growth_label.text.ends_with(": 0"), "default growth")
	_check(_resource_labels(dashboard) == ["1000 ml", "50 ml", "100 kWh"], "default reserves")
	_check(not dashboard.next_night_button.disabled, "default Next Night is enabled")

	var configured = DASHBOARD.instantiate()
	var state := configured.get_node("GameState") as GameState
	var manager := configured.get_node("ResourceManager") as ResourceManager
	var simulator := configured.get_node("HydroponicsSimulator") as HydroponicsSimulator
	var crop := CropData.new()
	crop.display_name_zh = "测试"
	crop.display_name_en = "Test Crop"
	crop.description = "Fixture crop description"
	state.starting_crop = crop
	state.current_day = 9
	manager.water_ml = 75.25
	manager.minerals_ml = 9.5
	manager.electricity_kwh = 2.25
	simulator.ready.connect(func() -> void:
		_check(state.start_night(), "fixture grows before dashboard readiness")
	)
	add_child(configured)
	_check(configured.day_label.text == "第 10 天", "startup synchronizes the non-default day")
	_check(configured.status_label.text.contains("Ready"), "startup reads finalized lifecycle state")
	_check(configured.crop_empty_title.text == "测试 / Test Crop", "startup renders configured crop identity")
	_check(configured.crop_empty_description.text == crop.description, "startup renders configured crop description")
	_check(configured.crop_growth_label.text.ends_with(": 1"), "startup reads growth emitted before parent readiness")
	_check(_resource_labels(configured) == ["75.25 ml", "9.5 ml", "2.25 kWh"], "startup renders configured reserves")
	state.night_processing_started.connect(func(_day: int) -> void:
		_check(configured.next_night_button.disabled, "Next Night is disabled during settlement")
	)
	configured.next_night_button.pressed.emit()
	_check(configured.day_label.text == "第 11 天", "subsequent night updates the day label")
	_check(configured.crop_growth_label.text.ends_with(": 2"), "subsequent night updates the growth label")
	_check(not configured.next_night_button.disabled, "Next Night re-enables after settlement")

	var empty = DASHBOARD.instantiate()
	(empty.get_node("GameState") as GameState).starting_crop = null
	add_child(empty)
	_check(empty.crop_empty_title.text.contains("No crop selected"), "empty crop title")
	_check(empty.crop_empty_description.text.is_empty(), "empty crop description clears stale text")
	_check(empty.crop_growth_label.text.ends_with(": 0"), "empty crop growth is zero")
	_check(not empty.next_night_button.disabled, "idle day advancement remains available")

	empty.next_night_button.pressed.emit()
	_check(empty.control_hint.text.contains("No crop selected. Day advanced."), "idle outcome is visible")
	crop.water_per_night_ml = 100.0
	configured.next_night_button.pressed.emit()
	_check(configured.control_hint.text.contains("Water shortage: need 100.0 ml, have 75.25 ml. No crop growth."), "shortage names the resource and amounts")
	_check(configured.status_label.text.contains("Ready"), "shortage leaves the lifecycle ready")
	manager.add_resource(ResourceManager.ResourceType.WATER, 24.75)
	configured.next_night_button.pressed.emit()
	_check(configured.control_hint.text.contains("The crop grew.") and not configured.control_hint.text.contains("shortage"), "success replaces the stale shortage")
	crop.minerals_per_night_ml = -1.0
	configured.next_night_button.pressed.emit()
	_check(configured.control_hint.text.contains("Configuration error. Day and growth unchanged."), "configuration errors have distinct feedback")
	_check(not configured.control_hint.tooltip_text.is_empty(), "configuration outcome preserves diagnostic detail")
	state.select_crop(CropData.new())
	_check(configured.control_hint.tooltip_text.is_empty(), "crop selection clears stale diagnostic detail")

	print("DASHBOARD_STARTUP_TEST_RESULT checks=%d failures=%d" % [_checks, _failures])
	get_tree().quit(0 if _failures == 0 else 1)


func _resource_labels(dashboard) -> Array[String]:
	return [dashboard.water_value_label.text, dashboard.mineral_value_label.text, dashboard.electricity_value_label.text]


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("DASHBOARD_STARTUP_CHECK_FAILED: " + description)
