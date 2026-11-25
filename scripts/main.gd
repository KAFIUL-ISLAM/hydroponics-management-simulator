extends Control

@onready var resource_manager: ResourceManager = $ResourceManager
@onready var hydroponics_simulator: HydroponicsSimulator = $HydroponicsSimulator
@onready var water_value_label: Label = $SafeArea/MainLayout/ResourceRow/WaterCard/WaterContent/WaterValue
@onready var mineral_value_label: Label = $SafeArea/MainLayout/ResourceRow/MineralCard/MineralContent/MineralValue
@onready var electricity_value_label: Label = $SafeArea/MainLayout/ResourceRow/PowerCard/PowerContent/PowerValue
@onready var game_state: GameState = $GameState
@onready var day_label: Label = $SafeArea/MainLayout/Header/HeaderContent/HeaderInfo/DayLabel
@onready var status_label: Label = $SafeArea/MainLayout/Header/HeaderContent/HeaderInfo/StatusLabel
@onready var crop_empty_title: Label = $SafeArea/MainLayout/MainPanels/CropPanel/CropContent/CropEmptyState/CropEmptyContent/CropEmptyTitle
@onready var crop_empty_description: Label = $SafeArea/MainLayout/MainPanels/CropPanel/CropContent/CropEmptyState/CropEmptyContent/CropEmptyDescription
@onready var crop_growth_label: Label = $SafeArea/MainLayout/MainPanels/CropPanel/CropContent/CropEmptyState/CropEmptyContent/CropGrowthLabel

func _ready() -> void:
	resource_manager.resources_changed.connect(_on_resources_changed)

	# The ResourceManager may emit its initial signal before this parent is ready.
	# Read its current values once to initialize the dashboard.
	
	_on_resources_changed(
		resource_manager.water_ml,
		resource_manager.minerals_ml,
		resource_manager.electricity_kwh
	)
	game_state.day_changed.connect(_on_day_changed)
	game_state.status_changed.connect(_on_status_changed)
	game_state.crop_selected.connect(_on_crop_selected)
	
	# Initialize header with current game state
	_on_day_changed(game_state.current_day)
	_on_status_changed(game_state.status)
	
	# Initialize crop panel with the current selection.
	if game_state.selected_crop != null:
		_on_crop_selected(game_state.selected_crop)
	hydroponics_simulator.crop_growth_changed.connect(_on_crop_growth_changed)


func _on_resources_changed(
	water_ml: float,
	minerals_ml: float,
	electricity_kwh: float
) -> void:
	water_value_label.text = "%s ml" % _format_amount(water_ml)
	mineral_value_label.text = "%s ml" % _format_amount(minerals_ml)
	electricity_value_label.text = "%s kWh" % _format_amount(electricity_kwh)


func _format_amount(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(int(roundf(value)))

	return str(snappedf(value, 0.01))

func _on_day_changed(new_day: int) -> void:
	day_label.text = "第 %d 天" % new_day


func _on_status_changed(new_status: int) -> void:
	match new_status:
		GameState.SimulationStatus.READY:
			status_label.text = "● 运行正常"
			status_label.add_theme_color_override(
				"font_color", Color("#65D6A0")
			)

		GameState.SimulationStatus.PROCESSING:
			status_label.text = "● 夜间结算中"
			status_label.add_theme_color_override(
				"font_color", Color("#E8C66B")
			)

		GameState.SimulationStatus.PAUSED:
			status_label.text = "● 已暂停"
			status_label.add_theme_color_override(
				"font_color", Color("#E8C66B")
			)
			

func _on_crop_selected(crop: CropData) -> void:
	if crop == null:
		return

	crop_empty_title.text = "%s / %s" % [
		crop.display_name_zh,
		crop.display_name_en
	]

	crop_empty_description.text = crop.description


func _on_next_night_button_pressed() -> void:
	game_state.start_night() 

func _on_crop_growth_changed(crop: CropData, growth: int) -> void:
	crop_growth_label.text = "生长进度 / Growth: %d" % growth
