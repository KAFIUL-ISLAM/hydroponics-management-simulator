extends Node

const DASHBOARD = preload("res://scenes/main.tscn")

var _checks: int = 0
var _failures: int = 0


func _ready() -> void:
	_test_default_dashboard()
	_test_success()
	_test_shortage_and_recovery(ResourceManager.ResourceType.WATER)
	_test_shortage_and_recovery(ResourceManager.ResourceType.MINERALS)
	_test_configuration_error()
	_test_no_crop()
	await _test_feedback_layout()
	print("NIGHTLY_INTEGRATION_TEST_RESULT checks=%d failures=%d" % [_checks, _failures])
	get_tree().quit(0 if _failures == 0 else 1)


func _test_default_dashboard() -> void:
	var dashboard = DASHBOARD.instantiate()
	add_child(dashboard)
	_expect_snapshot(dashboard, 1, 0, [1000.0, 50.0, 100.0], ["1000 ml", "50 ml", "100 kWh"], "default dashboard")
	_check(dashboard.crop_empty_title.text == "生菜 / Lettuce", "default crop is rendered")
	_check(dashboard.next_night_button.pressed.is_connected(dashboard._on_next_night_button_pressed), "scene binds the real Next Night button")
	_press(dashboard)
	_expect_snapshot(dashboard, 2, 1, [1000.0, 50.0, 100.0], ["1000 ml", "50 ml", "100 kWh"], "default night")
	dashboard.free()


func _test_success() -> void:
	var dashboard = _fixture(8.5, 2.25)
	var outcomes: Array[GameState.NightStatus] = []
	var snapshots: Array[Array] = []
	_expect_snapshot(dashboard, 4, 0, [8.5, 2.25, 12.25], ["8.5 ml", "2.25 ml", "12.25 kWh"], "configured dashboard")
	_check(dashboard.crop_empty_title.text == "测试 / Fixture Crop", "configured crop is rendered")
	dashboard.resource_manager.resources_changed.connect(func(water: float, mineral: float, power: float) -> void:
		snapshots.append([water, mineral, power])
	)
	dashboard.game_state.night_processing_started.connect(func(_day: int) -> void:
		_check(dashboard.next_night_button.disabled and dashboard.status_label.text.contains("Settling"), "processing updates availability and status")
		_check(dashboard.control_hint.text.contains("Settling the night"), "processing replaces prior feedback")
	)
	dashboard.game_state.night_processing_finished.connect(func(day: int, next_day: int, outcome: GameState.NightOutcome) -> void:
		outcomes.append(outcome.status)
		_check(day == 4 and next_day == 5 and dashboard.game_state.is_ready(), "completion delivers the finalized day and status")
	)
	_press(dashboard)
	_expect_snapshot(dashboard, 5, 1, [0.0, 0.0, 12.25], ["0 ml", "0 ml", "12.25 kWh"], "exact-balance night")
	_check(outcomes == [GameState.NightStatus.GROWN], "one click produces one success outcome")
	_check(snapshots == [[0.0, 0.0, 12.25]], "success emits one complete ledger snapshot")
	_check(dashboard.control_hint.text.contains("作物已生长") and dashboard.control_hint.text.contains("The crop grew."), "success is bilingual")
	dashboard.free()


func _test_shortage_and_recovery(resource_type: ResourceManager.ResourceType) -> void:
	var water_short := resource_type == ResourceManager.ResourceType.WATER
	var available_water := 7.5 if water_short else 8.5
	var available_minerals := 2.25 if water_short else 1.25
	var dashboard = _fixture(available_water, available_minerals)
	var changes: Array[Array] = []
	dashboard.resource_manager.resources_changed.connect(func(water: float, mineral: float, power: float) -> void:
		changes.append([water, mineral, power])
	)
	_press(dashboard)
	var amounts := ["7.5 ml", "2.25 ml", "12.25 kWh"] if water_short else ["8.5 ml", "1.25 ml", "12.25 kWh"]
	_expect_snapshot(dashboard, 5, 0, [available_water, available_minerals, 12.25], amounts, "shortage")
	var expected_detail := "Water shortage: need 8.5 ml, have 7.5 ml." if water_short else "Minerals shortage: need 2.25 ml, have 1.25 ml."
	_check(dashboard.control_hint.text.contains(expected_detail), "shortage identifies the actual resource, quantities, and unit")
	_check(dashboard.control_hint.text.contains("作物未生长") and dashboard.control_hint.text.contains("No crop growth."), "shortage explains unchanged growth in both languages")
	_check(changes.is_empty(), "shortage emits no resource change")
	_check(dashboard.resource_manager.add_resource(resource_type, 1.0), "fixture replenishes through the resource API")
	_check(changes == [[8.5, 2.25, 12.25]], "top-up updates the ledger snapshot")
	_press(dashboard)
	_expect_snapshot(dashboard, 6, 1, [0.0, 0.0, 12.25], ["0 ml", "0 ml", "12.25 kWh"], "recovery")
	_check(dashboard.control_hint.text.contains("The crop grew.") and not dashboard.control_hint.text.contains("shortage"), "recovery replaces shortage feedback")
	dashboard.free()


func _test_configuration_error() -> void:
	var dashboard = _fixture(8.5, 2.25)
	dashboard.game_state.selected_crop.minerals_per_night_ml = -1.0
	_press(dashboard)
	_expect_snapshot(dashboard, 4, 0, [8.5, 2.25, 12.25], ["8.5 ml", "2.25 ml", "12.25 kWh"], "invalid configuration")
	_check(dashboard.control_hint.text.contains("配置错误") and dashboard.control_hint.text.contains("Day and growth unchanged."), "configuration failure is distinct from READY")
	_check(dashboard.control_hint.tooltip_text == "Invalid resource configuration", "configuration diagnostic is retained")
	dashboard.free()


func _test_no_crop() -> void:
	var dashboard = _fixture(8.5, 2.25, false)
	_check(dashboard.crop_empty_title.text.contains("No crop selected"), "no-crop startup is rendered safely")
	_press(dashboard)
	_expect_snapshot(dashboard, 5, 0, [8.5, 2.25, 12.25], ["8.5 ml", "2.25 ml", "12.25 kWh"], "idle night")
	_check(dashboard.control_hint.text.contains("未选择作物") and dashboard.control_hint.text.contains("No crop selected. Day advanced."), "idle outcome explains the day advance")
	dashboard.free()


func _test_feedback_layout() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	add_child(viewport)
	var dashboard = _fixture(8.5, 1.25, true, viewport)
	_press(dashboard)
	await get_tree().process_frame
	await get_tree().process_frame
	var feedback: Label = dashboard.control_hint
	var button: Button = dashboard.next_night_button
	var bounds := Rect2(Vector2.ZERO, Vector2(viewport.size))
	_check(bounds.encloses(feedback.get_global_rect()) and bounds.encloses(button.get_global_rect()), "feedback and Next Night fit the target viewport")
	_check(feedback.get_global_rect().end.x <= button.get_global_rect().position.x, "feedback does not overlap Next Night")
	_check(feedback.get_visible_line_count() == feedback.get_line_count() and feedback.get_line_count() >= 2, "feedback exposes both translated lines at 1280 by 720")
	viewport.free()


func _fixture(water: float, minerals: float, with_crop: bool = true, parent: Node = null):
	var dashboard = DASHBOARD.instantiate()
	var state := dashboard.get_node("GameState") as GameState
	var manager := dashboard.get_node("ResourceManager") as ResourceManager
	state.current_day = 4
	state.starting_crop = null
	if with_crop:
		var crop := CropData.new()
		crop.display_name_zh = "测试"
		crop.display_name_en = "Fixture Crop"
		crop.water_per_night_ml = 8.5
		crop.minerals_per_night_ml = 2.25
		state.starting_crop = crop
	manager.water_ml = water
	manager.minerals_ml = minerals
	manager.electricity_kwh = 12.25
	var fixture_parent := parent if parent != null else self
	fixture_parent.add_child(dashboard)
	return dashboard


func _expect_snapshot(dashboard, day: int, growth: int, balances: Array, labels: Array, description: String) -> void:
	var manager: ResourceManager = dashboard.resource_manager
	_check(dashboard.game_state.current_day == day and dashboard.day_label.text == "第 %d 天" % day, description + " day and label")
	_check(dashboard.hydroponics_simulator.current_growth == growth and dashboard.crop_growth_label.text.ends_with(": %d" % growth), description + " growth and label")
	_check([manager.water_ml, manager.minerals_ml, manager.electricity_kwh] == balances, description + " ledger")
	_check([dashboard.water_value_label.text, dashboard.mineral_value_label.text, dashboard.electricity_value_label.text] == labels, description + " resource labels")
	_check(dashboard.game_state.is_ready() and not dashboard.game_state.is_night_active() and dashboard.status_label.text.contains("Ready"), description + " final lifecycle")
	_check(not dashboard.next_night_button.disabled, description + " Next Night availability")


func _press(dashboard) -> void:
	_check(not dashboard.next_night_button.disabled, "fixture presses the enabled button")
	dashboard.next_night_button.pressed.emit()


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("NIGHTLY_INTEGRATION_CHECK_FAILED: " + description)
