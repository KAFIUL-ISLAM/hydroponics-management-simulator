extends Node
class_name GameState

## Controls the prototype's day counter and high-level simulation state.
## Actual crop/resource calculations will be handled by HydroponicsSimulator later.

signal day_changed(new_day: int)
signal status_changed(new_status: SimulationStatus)
signal night_processing_started(day_being_processed: int)
signal night_processing_finished(completed_day: int, next_day: int)
signal crop_selected(crop: CropData)

@export var starting_crop: CropData

var selected_crop: CropData = null

enum SimulationStatus {
	READY,
	PROCESSING,
	PAUSED
}

@export_range(1, 100000, 1) var current_day: int = 1

var status: SimulationStatus = SimulationStatus.READY


func _ready() -> void:
	if starting_crop != null:
		select_crop(starting_crop)

	day_changed.emit(current_day)
	status_changed.emit(status)

## Begins processing the current day's night.
## Returns false if the simulation is not currently ready.
func start_night() -> bool:
	if status != SimulationStatus.READY:
		return false

	status = SimulationStatus.PROCESSING
	status_changed.emit(status)
	night_processing_started.emit(current_day)
	return true


## Completes the current night and advances to the next day.
## The simulation system will call this after its calculations are complete.
func complete_night() -> bool:
	if status != SimulationStatus.PROCESSING:
		return false

	var completed_day: int = current_day
	current_day += 1

	night_processing_finished.emit(completed_day, current_day)
	day_changed.emit(current_day)

	status = SimulationStatus.READY
	status_changed.emit(status)
	return true


func pause_simulation() -> bool:
	if status != SimulationStatus.PROCESSING:
		return false

	status = SimulationStatus.PAUSED
	status_changed.emit(status)
	return true


func resume_simulation() -> bool:
	if status != SimulationStatus.PAUSED:
		return false

	status = SimulationStatus.PROCESSING
	status_changed.emit(status)
	return true


func is_ready() -> bool:
	return status == SimulationStatus.READY
func select_crop(crop: CropData) -> bool:
	if crop == null:
		return false

	selected_crop = crop
	crop_selected.emit(selected_crop)
	return true


func has_selected_crop() -> bool:
	return selected_crop != null
