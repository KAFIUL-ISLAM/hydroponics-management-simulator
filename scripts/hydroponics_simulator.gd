extends Node
class_name HydroponicsSimulator

signal crop_growth_changed(crop: CropData, growth: int)
signal crop_growth_blocked(reason: String)

@export var game_state: GameState
@export var resource_manager: ResourceManager

var current_crop: CropData:
	get:
		return game_state.selected_crop if is_instance_valid(game_state) else null

var current_growth: int:
	get:
		return _current_growth

var _current_growth: int = 0


func _ready() -> void:
	if game_state == null:
		return

	if not game_state._register_night_simulation(process_crop_night):
		push_warning("HydroponicsSimulator: could not register the night simulation.")
		return

	game_state.crop_selected.connect(_on_crop_selected)
	if current_crop != null:
		_on_crop_selected(current_crop)


func _on_crop_selected(crop: CropData) -> void:
	_current_growth = 0
	crop_growth_changed.emit(crop, current_growth)


## Only GameState can authorize this call, once per accepted night.
func process_crop_night(permit: RefCounted = null) -> GameState.NightOutcome:
	if not is_inside_tree() or not is_instance_valid(game_state) or not game_state._claim_settlement(process_crop_night, permit):
		return GameState.NightOutcome.new(GameState.NightStatus.CONFIGURATION_ERROR, "Unauthorized settlement")

	if not is_instance_valid(resource_manager):
		var reason := "HydroponicsSimulator: ResourceManager is not assigned."
		push_warning(reason)
		return GameState.NightOutcome.new(GameState.NightStatus.CONFIGURATION_ERROR, reason)

	var crop := current_crop
	if crop == null:
		return GameState.NightOutcome.new(GameState.NightStatus.NO_CROP)

	var result := resource_manager.try_consume_batch({
		ResourceManager.ResourceType.WATER: crop.water_per_night_ml,
		ResourceManager.ResourceType.MINERALS: crop.minerals_per_night_ml,
	})
	if result.status == ResourceManager.ConsumptionStatus.INVALID_INPUT:
		var reason := "Invalid resource configuration"
		crop_growth_blocked.emit(reason)
		return GameState.NightOutcome.new(GameState.NightStatus.CONFIGURATION_ERROR, reason, result)

	if result.status == ResourceManager.ConsumptionStatus.INSUFFICIENT_RESOURCES:
		var reason := "Insufficient water" if result.resource_type == ResourceManager.ResourceType.WATER else "Insufficient minerals"
		crop_growth_blocked.emit(reason)
		return GameState.NightOutcome.new(GameState.NightStatus.SHORTAGE, reason, result)

	_current_growth += 1
	crop_growth_changed.emit(crop, current_growth)
	return GameState.NightOutcome.new(GameState.NightStatus.GROWN, "", result)
