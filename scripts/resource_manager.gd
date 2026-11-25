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

@export_group("Prototype Starting Resources")
@export_range(0.0, 1000000.0, 1.0) var water_ml: float = 1000.0
@export_range(0.0, 1000000.0, 1.0) var minerals_ml: float = 50.0
@export_range(0.0, 1000000.0, 1.0) var electricity_kwh: float = 100.0


func _ready() -> void:
	_emit_resources_changed()


## Returns the current amount of the selected resource.
func get_amount(resource_type: ResourceType) -> float:
	match resource_type:
		ResourceType.WATER:
			return water_ml
		ResourceType.MINERALS:
			return minerals_ml
		ResourceType.ELECTRICITY:
			return electricity_kwh
	return 0.0


## Checks whether the selected resource can cover the requested amount.
func can_consume(resource_type: ResourceType, amount: float) -> bool:
	if amount < 0.0:
		return false
	return get_amount(resource_type) >= amount


## Consumes a resource. Returns false if the amount is invalid or insufficient.
func try_consume(resource_type: ResourceType, amount: float) -> bool:
	if amount < 0.0:
		push_warning("ResourceManager: cannot consume a negative amount.")
		return false

	var available: float = get_amount(resource_type)
	if available < amount:
		resource_insufficient.emit(_get_resource_name(resource_type), amount, available)
		return false

	_change_amount(resource_type, -amount)
	_emit_resources_changed()
	return true


## Adds a resource. Negative additions are rejected; use try_consume() to spend resources.
func add_resource(resource_type: ResourceType, amount: float) -> bool:
	if amount < 0.0:
		push_warning("ResourceManager: cannot add a negative amount.")
		return false

	_change_amount(resource_type, amount)
	_emit_resources_changed()
	return true


## Restores the prototype starting values.
func reset_resources() -> void:
	water_ml = 1000.0
	minerals_ml = 50.0
	electricity_kwh = 100.0
	_emit_resources_changed()


func _change_amount(resource_type: ResourceType, delta: float) -> void:
	match resource_type:
		ResourceType.WATER:
			water_ml = maxf(0.0, water_ml + delta)
		ResourceType.MINERALS:
			minerals_ml = maxf(0.0, minerals_ml + delta)
		ResourceType.ELECTRICITY:
			electricity_kwh = maxf(0.0, electricity_kwh + delta)


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
