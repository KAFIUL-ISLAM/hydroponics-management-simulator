extends Node

const STARTING_BALANCES: Array[float] = [10.5, 20.25, 30.75]

var _changes: Array[Array] = []
var _shortages: Array[Array] = []
var _checks: int = 0
var _failures: int = 0


func _ready() -> void:
	_check(OS.is_debug_build(), "Run this test in a debug build")
	_test_valid_operations(ResourceManager.ResourceType.WATER)
	_test_valid_operations(ResourceManager.ResourceType.MINERALS)
	_test_valid_operations(ResourceManager.ResourceType.ELECTRICITY)
	_test_exact_balance()
	_test_insufficient_balance()
	_test_zero_operations()
	_test_rejected_inputs()
	_test_overflow()
	_test_invalid_stored_balances()
	_test_reset(false)
	_test_reset(true)
	_test_batch_success()
	_test_batch_rejections()
	_test_rejected_night_batches()
	print("RESOURCE_MANAGER_TEST_RESULT checks=%d failures=%d" % [_checks, _failures])
	get_tree().quit(0 if _failures == 0 else 1)


func _test_valid_operations(resource_type: ResourceManager.ResourceType) -> void:
	var manager := _new_manager()
	var expected := STARTING_BALANCES.duplicate()
	var label := ResourceManager.ResourceType.keys()[resource_type] as String
	_check(manager.get_amount(resource_type) == expected[resource_type], label + " initial lookup")

	_check(manager.add_resource(resource_type, 2.25), label + " valid credit returns true")
	expected[resource_type] += 2.25
	_check(_balances(manager) == expected, label + " credit changes only the selected balance")
	_check(_changes == [expected], label + " credit emits one complete snapshot")

	_check(manager.can_consume(resource_type, 1.5), label + " valid debit is affordable")
	_check(_changes == [expected] and _shortages.is_empty(), label + " affordability emits no signals")
	var after_credit := expected.duplicate()
	_check(manager.try_consume(resource_type, 1.5), label + " valid debit returns true")
	expected[resource_type] -= 1.5
	_check(_balances(manager) == expected, label + " debit changes only the selected balance")
	_check(_changes == [after_credit, expected], label + " debit emits one complete snapshot")
	_check(_shortages.is_empty(), label + " successful operations do not emit shortage")


func _test_exact_balance() -> void:
	var manager := _new_manager()
	var water := ResourceManager.ResourceType.WATER
	_check(manager.can_consume(water, 10.5), "exact balance is affordable")
	_check(manager.try_consume(water, 10.5), "exact balance debit returns true")
	var expected := [0.0, 20.25, 30.75]
	_check(_balances(manager) == expected, "exact balance debit leaves zero")
	_check(_changes == [expected] and _shortages.is_empty(), "exact debit emits one change")


func _test_insufficient_balance() -> void:
	var manager := _new_manager()
	var mineral := ResourceManager.ResourceType.MINERALS
	_check(not manager.can_consume(mineral, 20.5), "above available balance is unaffordable")
	_check(_shortages.is_empty(), "affordability query does not emit shortage")
	_check(not manager.try_consume(mineral, 20.5), "insufficient debit returns false")
	_check(_balances(manager) == STARTING_BALANCES, "insufficient debit preserves all balances")
	_check(_changes.is_empty(), "insufficient debit emits no successful change")
	_check(_shortages == [["Minerals", 20.5, 20.25]], "insufficient debit emits one shortage with amounts")


func _test_zero_operations() -> void:
	var manager := _new_manager()
	manager.electricity_kwh = 0.0
	var expected := _balances(manager)
	var electricity := ResourceManager.ResourceType.ELECTRICITY
	_check(manager.can_consume(electricity, 0.0), "zero is affordable at an empty balance")
	_check(manager.try_consume(electricity, 0.0), "zero debit returns true")
	_check(manager.add_resource(electricity, 0.0), "zero credit returns true")
	_check(_balances(manager) == expected, "zero operations preserve every balance")
	_check(_changes == [expected, expected], "each successful zero operation still emits one change")
	_check(_shortages.is_empty(), "successful zero operations emit no shortage")


func _test_rejected_inputs() -> void:
	var manager := _new_manager()
	var unknown := ResourceManager.ResourceType.size() as ResourceManager.ResourceType
	var water := ResourceManager.ResourceType.WATER
	_check(manager.get_amount(unknown) == 0.0, "unknown resource lookup uses the documented fallback")
	_expect_invalid_request(manager, unknown, 0.0, "unknown resource with zero amount")
	_expect_invalid_request(manager, unknown, 1.0, "unknown resource with positive amount")
	_expect_invalid_request(manager, water, -1.0, "negative amount")
	_expect_invalid_request(manager, water, NAN, "NaN amount")
	_expect_invalid_request(manager, water, INF, "positive infinity amount")
	_expect_invalid_request(manager, water, -INF, "negative infinity amount")


func _expect_invalid_request(
	manager: ResourceManager,
	resource_type: ResourceManager.ResourceType,
	amount: float,
	label: String
) -> void:
	_check(not manager.can_consume(resource_type, amount), label + " fails affordability")
	_check(not manager.try_consume(resource_type, amount), label + " debit returns false")
	_check(_balances(manager) == STARTING_BALANCES, label + " debit preserves all balances")
	_check(not manager.add_resource(resource_type, amount), label + " credit returns false")
	_check(_balances(manager) == STARTING_BALANCES, label + " credit preserves all balances")
	_check(_changes.is_empty(), label + " emits no successful change")
	_check(_shortages.is_empty(), label + " emits no shortage")


func _test_overflow() -> void:
	var manager := _new_manager()
	var water := ResourceManager.ResourceType.WATER
	var finite_amount: float = 1.0e308
	manager.water_ml = finite_amount
	var expected := _balances(manager)
	_check(is_finite(finite_amount) and is_inf(finite_amount + finite_amount), "overflow fixture is valid")
	_check(not manager.add_resource(water, finite_amount), "overflowing credit returns false")
	_check(_balances(manager) == expected, "overflow preserves all balances")
	_check(_changes.is_empty() and _shortages.is_empty(), "overflow emits neither signal")


func _test_invalid_stored_balances() -> void:
	var water := ResourceManager.ResourceType.WATER
	for invalid_balance: float in [-1.0, NAN, INF, -INF]:
		var manager := _new_manager()
		manager.water_ml = invalid_balance
		var label := "directly assigned %s balance" % invalid_balance
		_check(not manager.can_consume(water, 0.0), label + " fails affordability")
		_check(not manager.try_consume(water, 0.0), label + " debit returns false")
		_check(not manager.add_resource(water, 1.0), label + " credit returns false")
		var actual := manager.get_amount(water)
		var balance_preserved := is_nan(actual) if is_nan(invalid_balance) else actual == invalid_balance
		_check(balance_preserved, label + " is preserved")
		_check(manager.minerals_ml == 20.25 and manager.electricity_kwh == 30.75, label + " leaves other balances intact")
		_check(_changes.is_empty() and _shortages.is_empty(), label + " emits neither signal")


func _test_reset(use_overrides: bool) -> void:
	_changes.clear()
	_shortages.clear()
	var manager := ResourceManager.new()
	var expected: Array[float] = [1000.0, 50.0, 100.0]
	if use_overrides:
		expected = [125.5, 7.25, 16.75]
		manager.water_ml = expected[0]
		manager.minerals_ml = expected[1]
		manager.electricity_kwh = expected[2]

	var observed_balances: Array[Array] = []
	manager.resources_changed.connect(_record_change)
	manager.resources_changed.connect(func(_water: float, _minerals: float, _electricity: float) -> void:
		observed_balances.append(_balances(manager))
	)
	manager.reset_resources()
	_check(_balances(manager) == expected and _changes.is_empty(), "pre-ready reset preserves configuration and is silent")
	add_child(manager)
	_check(_changes == [expected], "initial snapshot matches configured balances")
	_check(manager.add_resource(ResourceManager.ResourceType.WATER, 2.0), "credit before reset succeeds")
	_check(manager.try_consume(ResourceManager.ResourceType.MINERALS, 1.0), "debit before reset succeeds")
	_check(manager.try_consume(ResourceManager.ResourceType.ELECTRICITY, 1.0), "power usage before reset succeeds")
	_changes.clear()
	observed_balances.clear()
	manager.reset_resources()
	_check(_balances(manager) == expected and _changes == [expected], "reset restores all configured balances with one snapshot")
	_check(observed_balances == [expected], "reset observers see the restored balances together")
	manager.reset_resources()
	_check(_changes == [expected, expected], "repeated reset emits one snapshot per call")

	manager.water_ml = 1.0
	remove_child(manager)
	manager.request_ready()
	add_child(manager)
	manager.reset_resources()
	_check(_balances(manager) == expected and _changes.back() == expected, "re-entering the tree does not recapture the baseline")
	manager.free()


func _test_batch_success() -> void:
	var manager := _new_manager()
	var water := ResourceManager.ResourceType.WATER
	var minerals := ResourceManager.ResourceType.MINERALS
	var observed_balances: Array[Array] = []
	manager.resources_changed.connect(func(_water: float, _minerals: float, _electricity: float) -> void:
		observed_balances.append(_balances(manager))
	)

	var result := manager.try_consume_batch({water: 2, minerals: 0.25})
	var expected := [8.5, 20.0, 30.75]
	_check(result.status == ResourceManager.ConsumptionStatus.SUCCESS, "mixed integer and float batch succeeds")
	_check(_balances(manager) == expected, "batch debits both requested resources")
	_check(_changes == [expected] and observed_balances == [expected], "observer sees one complete committed snapshot")

	result = manager.try_consume_batch({water: 8.5, minerals: 20.0})
	expected = [0.0, 0.0, 30.75]
	_check(result.status == ResourceManager.ConsumptionStatus.SUCCESS, "exact balances are sufficient")
	_check(_balances(manager) == expected and _changes.size() == 2, "exact batch debits both balances to zero")
	_check(_changes.back() == expected and observed_balances.back() == expected, "exact batch notifies final balances")

	result = manager.try_consume_batch({water: 0.0, minerals: 0.0})
	_check(result.status == ResourceManager.ConsumptionStatus.SUCCESS, "zero batch succeeds even with empty balances")
	_check(manager.try_consume_batch({}).status == ResourceManager.ConsumptionStatus.SUCCESS, "empty batch succeeds")
	_check(_balances(manager) == expected and _changes.size() == 2, "zero and empty batches preserve balances and emit nothing")
	_check(_shortages.is_empty(), "successful batches emit no shortage")


func _test_batch_rejections() -> void:
	var manager := _new_manager()
	var water := ResourceManager.ResourceType.WATER
	var minerals := ResourceManager.ResourceType.MINERALS
	var unknown := ResourceManager.ResourceType.size()
	var status := ResourceManager.ConsumptionStatus.INSUFFICIENT_RESOURCES
	for shortage: Array in [[{water: 11.0, minerals: 1.0}, water, 11.0, 10.5], [{water: 1.0, minerals: 21.0}, minerals, 21.0, 20.25]]:
		var result := manager.try_consume_batch(shortage[0])
		_check(result.status == status, "batch returns a shortage")
		_check(result.resource_type == shortage[1] and result.requested == shortage[2] and result.available == shortage[3], "batch shortage has the expected resource and amounts")
		_check(_balances(manager) == STARTING_BALANCES, "short batch preserves all balances")
		_check(_changes.is_empty() and _shortages.is_empty(), "batch reports shortage through its result only")

	var invalid_requests: Array[Dictionary] = [
		{water: 1.0, unknown: 1.0}, {water: 1.0, "minerals": 1.0},
		{water: 1.0, minerals: "1"}, {water: 1.0, minerals: true},
		{water: 1.0, minerals: -1.0}, {water: 1.0, minerals: NAN},
		{water: 1.0, minerals: INF}, {water: 1.0, minerals: -INF},
		{water: 11.0, minerals: -1.0},
	]
	for costs: Dictionary in invalid_requests:
		var result := manager.try_consume_batch(costs)
		_check(result.status == ResourceManager.ConsumptionStatus.INVALID_INPUT, "malformed batch returns invalid input")
		_check(_balances(manager) == STARTING_BALANCES, "malformed batch preserves all balances")
		_check(_changes.is_empty() and _shortages.is_empty(), "malformed batch emits neither signal")

	manager.minerals_ml = INF
	var invalid_balance_result := manager.try_consume_batch({water: 1.0, minerals: 0.0})
	_check(invalid_balance_result.status == ResourceManager.ConsumptionStatus.INVALID_INPUT, "batch rejects an invalid affected balance at zero cost")
	_check(_balances(manager) == [10.5, INF, 30.75], "batch preserves all balances after detecting invalid stored balance")
	_check(_changes.is_empty() and _shortages.is_empty(), "batch with invalid balance emits neither signal")


func _test_rejected_night_batches() -> void:
	var manager := _new_manager()
	var state := GameState.new()
	var simulator := HydroponicsSimulator.new()
	var crop := CropData.new()
	crop.water_per_night_ml = 1.0
	crop.minerals_per_night_ml = 21.0
	state.starting_crop = crop
	simulator.game_state = state
	simulator.resource_manager = manager
	add_child(state)
	add_child(simulator)

	_check(state.start_night(), "night with an unaffordable mineral cost is attempted")
	_check(simulator.current_growth == 0 and _balances(manager) == STARTING_BALANCES, "night shortage preserves growth and balances")
	crop.minerals_per_night_ml = -1.0
	_check(state.start_night(), "night with an invalid mineral cost is attempted")
	_check(simulator.current_growth == 0 and _balances(manager) == STARTING_BALANCES, "invalid nightly cost preserves growth and balances")
	_check(_changes.is_empty() and _shortages.is_empty(), "rejected nightly batches emit neither resource signal")

	crop.water_per_night_ml = 0.0
	crop.minerals_per_night_ml = 0.0
	_check(state.start_night(), "zero-cost night is attempted")
	_check(simulator.current_growth == 1 and _balances(manager) == STARTING_BALANCES, "zero-cost night grows without a debit")
	_check(_changes.is_empty() and _shortages.is_empty(), "zero-cost night emits neither resource signal")


func _new_manager() -> ResourceManager:
	_changes.clear()
	_shortages.clear()
	var manager := ResourceManager.new()
	manager.water_ml = STARTING_BALANCES[0]
	manager.minerals_ml = STARTING_BALANCES[1]
	manager.electricity_kwh = STARTING_BALANCES[2]
	add_child(manager)
	manager.resources_changed.connect(_record_change)
	manager.resource_insufficient.connect(_record_shortage)
	return manager


func _balances(manager: ResourceManager) -> Array[float]:
	return [manager.water_ml, manager.minerals_ml, manager.electricity_kwh]


func _record_change(water_ml: float, minerals_ml: float, electricity_kwh: float) -> void:
	_changes.append([water_ml, minerals_ml, electricity_kwh])


func _record_shortage(resource_name: String, requested: float, available: float) -> void:
	_shortages.append([resource_name, requested, available])


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("RESOURCE_MANAGER_CHECK_FAILED: " + description)
