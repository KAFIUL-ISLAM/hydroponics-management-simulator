extends Node
class_name GameState

## Owns the prototype's day counter and synchronous settlement lifecycle.

signal day_changed(new_day: int)
signal status_changed(new_status: SimulationStatus)
signal night_processing_started(day_being_processed: int)
signal night_processing_finished(completed_day: int, next_day: int, outcome: NightOutcome)
signal crop_selected(crop: CropData)

enum SimulationStatus {
	READY,
	PROCESSING,
	PAUSED
}

enum NightStatus {
	GROWN,
	NO_CROP,
	SHORTAGE,
	CONFIGURATION_ERROR
}

class NightOutcome:
	var status: NightStatus
	var detail: String
	var consumption: ResourceManager.ConsumptionResult

	func _init(
		result_status: NightStatus,
		result_detail: String = "",
		result_consumption: ResourceManager.ConsumptionResult = null
	) -> void:
		status = result_status
		detail = result_detail
		consumption = result_consumption

@export var starting_crop: CropData

@export_range(1, 100000, 1) var current_day: int = 1:
	get:
		return _current_day
	set(value):
		if not _night_active:
			_current_day = value

var selected_crop: CropData:
	get:
		return _selected_crop

var status: SimulationStatus:
	get:
		return _status

var _current_day: int = 1
var _selected_crop: CropData
var _status: SimulationStatus = SimulationStatus.READY
var _night_active: bool = false
var _night_simulation: Callable
var _settlement_permit: RefCounted


func _ready() -> void:
	if starting_crop != null:
		select_crop(starting_crop)

	day_changed.emit(current_day)
	status_changed.emit(status)


## Accepts one synchronous night. The finished signal reports its outcome and
## final state. True means accepted, including a night with a configuration error.
func start_night() -> bool:
	if _night_active or status != SimulationStatus.READY:
		return false

	_night_active = true
	var completed_day := current_day
	_status = SimulationStatus.PROCESSING
	status_changed.emit(status)
	night_processing_started.emit(completed_day)

	var outcome := _run_night_simulation()
	if outcome.status != NightStatus.CONFIGURATION_ERROR:
		_current_day += 1

	_status = SimulationStatus.READY
	status_changed.emit(status)
	if current_day != completed_day:
		day_changed.emit(current_day)
	night_processing_finished.emit(completed_day, current_day, outcome)
	_night_active = false
	return true


## The active synchronous settlement cannot be paused, including from callbacks.
func pause_simulation() -> bool:
	if _night_active or status != SimulationStatus.PROCESSING:
		return false

	_status = SimulationStatus.PAUSED
	status_changed.emit(status)
	return true


func resume_simulation() -> bool:
	if _night_active or status != SimulationStatus.PAUSED:
		return false

	_status = SimulationStatus.PROCESSING
	status_changed.emit(status)
	return true


func is_ready() -> bool:
	return status == SimulationStatus.READY


func is_night_active() -> bool:
	return _night_active


func select_crop(crop: CropData) -> bool:
	if _night_active or crop == null:
		return false

	_selected_crop = crop
	crop_selected.emit(selected_crop)
	return true


func has_selected_crop() -> bool:
	return selected_crop != null


func _register_night_simulation(simulation: Callable) -> bool:
	if _night_active or _night_simulation.is_valid() or not simulation.is_valid():
		return false
	_night_simulation = simulation
	return true


## The permit is issued after start notifications and claimed before any mutation.
func _claim_settlement(simulation: Callable, permit: RefCounted) -> bool:
	if not _night_active or permit == null or permit != _settlement_permit or simulation != _night_simulation:
		return false
	_settlement_permit = null
	return true


func _run_night_simulation() -> NightOutcome:
	if not _night_simulation.is_valid():
		return NightOutcome.new(NightStatus.CONFIGURATION_ERROR, "Missing hydroponics simulator")

	_settlement_permit = RefCounted.new()
	var outcome: NightOutcome = _night_simulation.call(_settlement_permit)
	_settlement_permit = null
	if outcome == null:
		return NightOutcome.new(NightStatus.CONFIGURATION_ERROR, "Missing settlement result")
	return outcome
