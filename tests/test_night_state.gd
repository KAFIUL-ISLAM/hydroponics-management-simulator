extends Node

class NightFixture:
	var state := GameState.new()
	var manager := ResourceManager.new()
	var simulator: HydroponicsSimulator
	var crop: CropData
	var events: Array[String] = []
	var completed_days: Array[int] = []
	var completion_state: Array = []
	var outcome: GameState.NightOutcome

var _checks: int = 0
var _failures: int = 0


func _ready() -> void:
	_check(OS.is_debug_build(), "Run this test in a debug build")
	_test_success_and_reentry()
	_test_shortage_and_recovery()
	_test_configuration_errors()
	_test_idle_night()
	print("NIGHT_STATE_TEST_RESULT checks=%d failures=%d" % [_checks, _failures])
	get_tree().quit(0 if _failures == 0 else 1)


func _test_success_and_reentry() -> void:
	var fixture := _new_fixture()
	var replacement := CropData.new()

	_check(not fixture.state.has_method("complete_night"), "completion has no external entry point")
	_check(fixture.simulator.process_crop_night().status == GameState.NightStatus.CONFIGURATION_ERROR, "direct settlement is unauthorized")
	_expect_state(fixture, 1, 0, [10.0, 4.0, 100.0], "direct call leaves the initial state")
	_check(fixture.events.is_empty(), "direct call emits no settlement events")

	fixture.state.night_processing_started.connect(func(_day: int) -> void:
		_expect_settlement_locked(fixture, replacement, "start callback")
	)
	fixture.manager.resources_changed.connect(func(_water: float, _minerals: float, _electricity: float) -> void:
		_expect_settlement_locked(fixture, replacement, "resource callback")
	)
	fixture.state.night_processing_finished.connect(func(_from: int, _to: int, _outcome: GameState.NightOutcome) -> void:
		_expect_settlement_locked(fixture, replacement, "completion callback")
	)

	_check(fixture.state.start_night(), "normal entry accepts a valid night")
	_expect_terminal(fixture, GameState.NightStatus.GROWN, [1, 2], 1, [7.0, 2.0, 100.0], "successful night")
	_check(fixture.events == ["PROCESSING", "started", "resources", "growth", "READY", "day", "finished"], "successful signal order")

	fixture.events.clear()
	_check(fixture.state.start_night(), "a later night is legal after completion returns")
	_expect_terminal(fixture, GameState.NightStatus.GROWN, [2, 3], 2, [4.0, 0.0, 100.0], "later night")
	_check(fixture.events == ["PROCESSING", "started", "resources", "growth", "READY", "day", "finished"], "later night settles once")
	_check(fixture.state.select_crop(replacement), "crop selection works again after settlement")
	_check(fixture.simulator.current_crop == replacement and fixture.simulator.current_growth == 0, "later crop selection resets growth")


func _expect_settlement_locked(fixture: NightFixture, replacement: CropData, phase: String) -> void:
	var day := fixture.state.current_day
	_check(fixture.state.is_night_active(), phase + " has an active settlement")
	_check(not fixture.state.start_night(), phase + " cannot start a duplicate night")
	_check(not fixture.state.pause_simulation(), phase + " cannot pause")
	_check(not fixture.state.resume_simulation(), phase + " cannot resume")
	_check(not fixture.state.select_crop(replacement), phase + " cannot change crops")
	_check(fixture.state.selected_crop == fixture.crop, phase + " keeps the selected crop")
	_check(fixture.simulator.process_crop_night(RefCounted.new()).status == GameState.NightStatus.CONFIGURATION_ERROR, phase + " cannot run without the active permit")
	fixture.state.current_day = 99
	_check(fixture.state.current_day == day, phase + " cannot overwrite the active day")


func _test_shortage_and_recovery() -> void:
	for resource_type: ResourceManager.ResourceType in [ResourceManager.ResourceType.WATER, ResourceManager.ResourceType.MINERALS]:
		var fixture := _new_fixture()
		if resource_type == ResourceManager.ResourceType.WATER:
			fixture.manager.water_ml = 2.0
		else:
			fixture.manager.minerals_ml = 1.0
		var before := _balances(fixture)
		var requested := 3.0 if resource_type == ResourceManager.ResourceType.WATER else 2.0
		var available := fixture.manager.get_amount(resource_type)

		_check(fixture.state.start_night(), "short night is accepted")
		_expect_terminal(fixture, GameState.NightStatus.SHORTAGE, [1, 2], 0, before, "short night")
		if fixture.outcome != null and fixture.outcome.consumption != null:
			var result := fixture.outcome.consumption
			_check(result.resource_type == resource_type and result.requested == requested and result.available == available, "shortage exposes the correct resource quantities")
		else:
			_check(false, "shortage supplies a consumption result")
		_check(fixture.events == ["PROCESSING", "started", "blocked", "READY", "day", "finished"], "shortage emits no resource or growth signal")

		_check(fixture.manager.add_resource(resource_type, 1.0), "refill succeeds")
		fixture.events.clear()
		_check(fixture.state.start_night(), "next night starts after replenishment")
		var expected := [0.0, 2.0, 100.0] if resource_type == ResourceManager.ResourceType.WATER else [7.0, 0.0, 100.0]
		_expect_terminal(fixture, GameState.NightStatus.GROWN, [2, 3], 1, expected, "replenished night")


func _test_configuration_errors() -> void:
	var missing_simulator := _new_fixture(false)
	_expect_configuration_error(missing_simulator, ["PROCESSING", "started", "READY", "finished"], "missing simulator")

	var missing_manager := _new_fixture()
	missing_manager.simulator.resource_manager = null
	_expect_configuration_error(missing_manager, ["PROCESSING", "started", "READY", "finished"], "missing resource manager")
	missing_manager.simulator.resource_manager = missing_manager.manager
	_check(missing_manager.state.start_night(), "night can retry after restoring configuration")
	_expect_terminal(missing_manager, GameState.NightStatus.GROWN, [1, 2], 1, [7.0, 2.0, 100.0], "configuration recovery")

	var invalid_cost := _new_fixture()
	invalid_cost.crop.water_per_night_ml = 100.0
	invalid_cost.crop.minerals_per_night_ml = NAN
	_expect_configuration_error(invalid_cost, ["PROCESSING", "started", "blocked", "READY", "finished"], "invalid cost takes precedence over shortage")


func _expect_configuration_error(fixture: NightFixture, expected_events: Array, description: String) -> void:
	_check(fixture.state.start_night(), description + " is accepted for evaluation")
	_expect_terminal(fixture, GameState.NightStatus.CONFIGURATION_ERROR, [1, 1], 0, [10.0, 4.0, 100.0], description)
	_check(fixture.events == expected_events, description + " emits only its expected lifecycle signals")


func _test_idle_night() -> void:
	var fixture := _new_fixture(true, false)
	_check(fixture.state.start_night(), "idle night is legal")
	_expect_terminal(fixture, GameState.NightStatus.NO_CROP, [1, 2], 0, [10.0, 4.0, 100.0], "idle night")
	_check(fixture.events == ["PROCESSING", "started", "READY", "day", "finished"], "idle night has no crop or resource notifications")


func _expect_terminal(
	fixture: NightFixture, expected_outcome: GameState.NightStatus, days: Array[int],
	growth: int, balances: Array, description: String
) -> void:
	_check(fixture.outcome != null and fixture.outcome.status == expected_outcome, description + " has the expected terminal outcome")
	_check(fixture.completed_days == days, description + " reports the correct day pair")
	_check(fixture.completion_state == [days[1], GameState.SimulationStatus.READY, growth, balances], description + " completion observer sees final state")
	_expect_state(fixture, days[1], growth, balances, description)
	_check(not fixture.state.is_night_active(), description + " releases the settlement guard")


func _expect_state(fixture: NightFixture, day: int, growth: int, balances: Array, description: String) -> void:
	_check(_snapshot(fixture) == [day, GameState.SimulationStatus.READY, growth, balances], description + " has the expected state")


func _new_fixture(with_simulator: bool = true, with_crop: bool = true) -> NightFixture:
	var fixture := NightFixture.new()
	fixture.manager.water_ml = 10.0
	fixture.manager.minerals_ml = 4.0
	if with_crop:
		fixture.crop = CropData.new()
		fixture.crop.water_per_night_ml = 3.0
		fixture.crop.minerals_per_night_ml = 2.0
		fixture.state.starting_crop = fixture.crop
	add_child(fixture.manager)
	add_child(fixture.state)

	if with_simulator:
		fixture.simulator = HydroponicsSimulator.new()
		fixture.simulator.game_state = fixture.state
		fixture.simulator.resource_manager = fixture.manager
		add_child(fixture.simulator)
		fixture.simulator.crop_growth_changed.connect(func(_crop: CropData, _growth: int) -> void:
			fixture.events.append("growth")
		)
		fixture.simulator.crop_growth_blocked.connect(func(_reason: String) -> void:
			fixture.events.append("blocked")
		)

	fixture.manager.resources_changed.connect(func(_water: float, _minerals: float, _electricity: float) -> void:
		fixture.events.append("resources")
	)
	fixture.state.status_changed.connect(func(new_status: GameState.SimulationStatus) -> void:
		fixture.events.append(GameState.SimulationStatus.keys()[new_status])
	)
	fixture.state.night_processing_started.connect(func(_day: int) -> void:
		fixture.events.append("started")
	)
	fixture.state.day_changed.connect(func(_day: int) -> void:
		fixture.events.append("day")
	)
	fixture.state.night_processing_finished.connect(func(from_day: int, to_day: int, outcome: GameState.NightOutcome) -> void:
		fixture.events.append("finished")
		fixture.completed_days.assign([from_day, to_day])
		fixture.outcome = outcome
		fixture.completion_state = _snapshot(fixture)
	)
	return fixture


func _snapshot(fixture: NightFixture) -> Array:
	var growth := fixture.simulator.current_growth if fixture.simulator != null else 0
	return [fixture.state.current_day, fixture.state.status, growth, _balances(fixture)]


func _balances(fixture: NightFixture) -> Array:
	return [fixture.manager.water_ml, fixture.manager.minerals_ml, fixture.manager.electricity_kwh]


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("NIGHT_STATE_CHECK_FAILED: " + description)
