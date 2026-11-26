extends Node
class_name ResourceManager

## Prototype resource storage for the hydroponics simulator.
## These starting values are UI/demo values, not verified reference-game balance values.

signal resources_changed(water_ml: float, minerals_ml: float, electricity_kwh: float)
signal resource_insufficient(resource_name: String, requested: float, available: float)

enum ResourceType {
	WATER,
	MINERALS,
	ELECTRICITY
}

enum ConsumptionStatus {
	SUCCESS,
	INVALID_INPUT,
	INSUFFICIENT_RESOURCES
}

class ConsumptionResult:
	var status: ConsumptionStatus
	## Resource and amounts identify the first shortage, when status is INSUFFICIENT_RESOURCES.
	var resource_type: ResourceType
	var requested: float
	var available: float

	func _init(
		result_status: ConsumptionStatus,
		short_resource: ResourceType = ResourceType.WATER,
		short_requested: float = 0.0,
		short_available: float = 0.0
	) -> void:
		status = result_status
		resource_type = short_resource
		requested = short_requested
		available = short_available

@export_group("Prototype Starting Resources")
@export_range(0.0, 1000000.0, 1.0) var water_ml: float = 1000.0
@export_range(0.0, 1000000.0, 1.0) var minerals_ml: float = 50.0
@export_range(0.0, 1000000.0, 1.0) var electricity_kwh: float = 100.0

var _starting_balances: Array[float] = []


func _ready() -> void:
	if _starting_balances.is_empty():
		_starting_balances.assign([water_ml, minerals_ml, electricity_kwh])
	_emit_resources_changed()


## Returns the stored balance, or 0.0 for an unknown type. That fallback is also
## a valid empty balance, so use a known ResourceType for resource lookups.
func get_amount(resource_type: ResourceType) -> float:
	match resource_type:
		ResourceType.WATER:
			return water_ml
		ResourceType.MINERALS:
			return minerals_ml
		ResourceType.ELECTRICITY:
			return electricity_kwh
	return 0.0


## Checks affordability without emitting signals. Invalid requests return false.
func can_consume(resource_type: ResourceType, amount: float) -> bool:
	var available := get_amount(resource_type)
	return _is_valid_request(resource_type, amount, available) and available >= amount


## Consumes a resource. Only a valid request that exceeds the available balance
## emits resource_insufficient. Invalid requests log a warning and return false.
func try_consume(resource_type: ResourceType, amount: float) -> bool:
	var available := get_amount(resource_type)
	if not _is_valid_request(resource_type, amount, available):
		push_warning("ResourceManager: invalid consumption request or current balance.")
		return false

	if available < amount:
		resource_insufficient.emit(_get_resource_name(resource_type), amount, available)
		return false

	_set_amount(resource_type, available - amount)
	_emit_resources_changed()
	return true


## Debits resource-enum keys with numeric costs as one transaction. Rejections
## are returned as results, and a batch that changes balances emits one snapshot.
func try_consume_batch(costs: Dictionary) -> ConsumptionResult:
	var remaining_balances: Dictionary[ResourceType, float] = {}
	for key: Variant in costs:
		var cost: Variant = costs[key]
		if typeof(key) != TYPE_INT or (typeof(cost) != TYPE_INT and typeof(cost) != TYPE_FLOAT):
			return ConsumptionResult.new(ConsumptionStatus.INVALID_INPUT)

		var resource_type := int(key) as ResourceType
		var available := get_amount(resource_type)
		var requested := float(cost)
		if not _is_valid_request(resource_type, requested, available):
			return ConsumptionResult.new(ConsumptionStatus.INVALID_INPUT)
		remaining_balances[resource_type] = available - requested

	for resource_type: ResourceType in remaining_balances:
		if remaining_balances[resource_type] < 0.0:
			return ConsumptionResult.new(
				ConsumptionStatus.INSUFFICIENT_RESOURCES,
				resource_type,
				float(costs[resource_type]),
				get_amount(resource_type)
			)

	var balances_changed := false
	for resource_type: ResourceType in remaining_balances:
		var remaining := remaining_balances[resource_type]
		if remaining != get_amount(resource_type):
			_set_amount(resource_type, remaining)
			balances_changed = true

	if balances_changed:
		_emit_resources_changed()
	return ConsumptionResult.new(ConsumptionStatus.SUCCESS)


## Adds a finite, non-negative amount if the resulting balance is finite.
func add_resource(resource_type: ResourceType, amount: float) -> bool:
	var available := get_amount(resource_type)
	if not _is_valid_request(resource_type, amount, available):
		push_warning("ResourceManager: invalid addition request or current balance.")
		return false

	var updated_amount := available + amount
	if not is_finite(updated_amount):
		push_warning("ResourceManager: addition would produce a non-finite balance.")
		return false

	_set_amount(resource_type, updated_amount)
	_emit_resources_changed()
	return true


## Restores the balances captured on first readiness. Before that, reset is a no-op.
func reset_resources() -> void:
	if _starting_balances.is_empty():
		push_warning("ResourceManager: reset requested before initialization.")
		return

	water_ml = _starting_balances[0]
	minerals_ml = _starting_balances[1]
	electricity_kwh = _starting_balances[2]
	_emit_resources_changed()


func _is_valid_request(resource_type: ResourceType, amount: float, available: float) -> bool:
	return (
		ResourceType.values().has(resource_type)
		and is_finite(amount) and amount >= 0.0
		and is_finite(available) and available >= 0.0
	)


func _set_amount(resource_type: ResourceType, amount: float) -> void:
	match resource_type:
		ResourceType.WATER:
			water_ml = amount
		ResourceType.MINERALS:
			minerals_ml = amount
		ResourceType.ELECTRICITY:
			electricity_kwh = amount


func _get_resource_name(resource_type: ResourceType) -> String:
	match resource_type:
		ResourceType.WATER:
			return "Water"
		ResourceType.MINERALS:
			return "Minerals"
		ResourceType.ELECTRICITY:
			return "Electricity"
	return "Unknown"


func _emit_resources_changed() -> void:
	resources_changed.emit(water_ml, minerals_ml, electricity_kwh)
