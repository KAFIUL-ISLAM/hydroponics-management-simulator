extends Node
class_name HydroponicsSimulator

signal crop_growth_changed(crop: CropData, growth: int)
signal crop_growth_blocked(reason: String)

@export var game_state: GameState
@export var resource_manager: ResourceManager

var current_crop: CropData = null
var current_growth: int = 0


func _ready() -> void:
	if game_state != null:
		game_state.crop_selected.connect(_on_crop_selected)
		game_state.night_processing_started.connect(_on_night_processing_started)

		if game_state.selected_crop != null:
			_on_crop_selected(game_state.selected_crop)


func _on_crop_selected(crop: CropData) -> void:
	current_crop = crop
	current_growth = 0
	crop_growth_changed.emit(current_crop, current_growth)


func _on_night_processing_started(_day: int) -> void:
	process_crop_night()
	game_state.complete_night()


func process_crop_night() -> void:
	if current_crop == null:
		return

	if resource_manager == null:
		push_warning("HydroponicsSimulator: ResourceManager is not assigned.")
		return

	if not resource_manager.can_consume(
		ResourceManager.ResourceType.WATER,
		current_crop.water_per_night_ml
	):
		crop_growth_blocked.emit("Insufficient water")
		return

	if not resource_manager.can_consume(
		ResourceManager.ResourceType.MINERALS,
		current_crop.minerals_per_night_ml
	):
		crop_growth_blocked.emit("Insufficient minerals")
		return

	resource_manager.try_consume(
		ResourceManager.ResourceType.WATER,
		current_crop.water_per_night_ml
	)

	resource_manager.try_consume(
		ResourceManager.ResourceType.MINERALS,
		current_crop.minerals_per_night_ml
	)

	current_growth += 1
	crop_growth_changed.emit(current_crop, current_growth)
