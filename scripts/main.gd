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
@onready var next_night_button: Button = $SafeArea/MainLayout/ControlBar/ControlContent/NextNightButton
@onready var control_hint: Label = $SafeArea/MainLayout/ControlBar/ControlContent/ControlHint


func _ready() -> void:
	resource_manager.resources_changed.connect(_on_resources_changed)
	game_state.day_changed.connect(_on_day_changed)
	game_state.status_changed.connect(_on_status_changed)
	game_state.crop_selected.connect(_on_crop_selected)
	game_state.night_processing_finished.connect(_on_night_processing_finished)
	hydroponics_simulator.crop_growth_changed.connect(_on_crop_growth_changed)

	# Child nodes publish their initial state before this dashboard is ready.
	_on_resources_changed(
		resource_manager.water_ml,
		resource_manager.minerals_ml,
		resource_manager.electricity_kwh
	)
	_on_day_changed(game_state.current_day)
	_on_status_changed(game_state.status)
	_on_crop_selected(game_state.selected_crop)


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


func _on_status_changed(new_status: GameState.SimulationStatus) -> void:
	next_night_button.disabled = new_status != GameState.SimulationStatus.READY
	match new_status:
		GameState.SimulationStatus.READY:
			status_label.text = "● 就绪 / Ready"
			status_label.add_theme_color_override(
				"font_color", Color("#65D6A0")
			)

		GameState.SimulationStatus.PROCESSING:
			status_label.text = "● 夜间结算中 / Settling"
			_show_feedback("正在结算 / Settling the night")
			status_label.add_theme_color_override(
				"font_color", Color("#E8C66B")
			)

		GameState.SimulationStatus.PAUSED:
			status_label.text = "● 已暂停 / Paused"
			status_label.add_theme_color_override(
				"font_color", Color("#E8C66B")
			)

func _on_crop_selected(crop: CropData) -> void:
	_on_crop_growth_changed(crop, hydroponics_simulator.current_growth)
	if crop == null:
		crop_empty_title.text = "尚未种植作物 / No crop selected"
		crop_empty_description.text = ""
		_show_feedback("继续至下一天 / Advance to the next day")
		return

	crop_empty_title.text = "%s / %s" % [
		crop.display_name_zh,
		crop.display_name_en
	]

	crop_empty_description.text = crop.description
	_show_feedback("开始夜间结算以推进生长 / Start the night to advance crop growth")


func _on_night_processing_finished(
	_completed_day: int, _next_day: int, outcome: GameState.NightOutcome
) -> void:
	match outcome.status:
		GameState.NightStatus.GROWN:
			_show_feedback("夜间结算完成，作物已生长。\nNight settled. The crop grew.")
		GameState.NightStatus.SHORTAGE:
			_show_feedback(_format_shortage(outcome.consumption))
		GameState.NightStatus.CONFIGURATION_ERROR:
			_show_feedback(
				"配置错误，日期与生长进度未变。\nConfiguration error. Day and growth unchanged.",
				outcome.detail
			)
		GameState.NightStatus.NO_CROP:
			_show_feedback("未选择作物，日期已推进。\nNo crop selected. Day advanced.")


func _show_feedback(message: String, detail: String = "") -> void:
	control_hint.text = message
	control_hint.tooltip_text = detail


func _format_shortage(result: ResourceManager.ConsumptionResult) -> String:
	var resource_zh: String
	var resource_en: String
	var unit := "ml"
	match result.resource_type:
		ResourceManager.ResourceType.WATER:
			resource_zh = "纯净水"
			resource_en = "Water"
		ResourceManager.ResourceType.MINERALS:
			resource_zh = "矿物质"
			resource_en = "Minerals"
		ResourceManager.ResourceType.ELECTRICITY:
			resource_zh = "电力"
			resource_en = "Electricity"
			unit = "kWh"

	var required_amount := "%s %s" % [result.requested, unit]
	var available_amount := "%s %s" % [result.available, unit]
	return (
		"%s不足：需要 %s，现有 %s。作物未生长。\n" % [resource_zh, required_amount, available_amount]
		+ "%s shortage: need %s, have %s. No crop growth." % [resource_en, required_amount, available_amount]
	)


func _on_next_night_button_pressed() -> void:
	game_state.start_night()


func _on_crop_growth_changed(_crop: CropData, growth: int) -> void:
	crop_growth_label.text = "生长进度 / Growth: %d" % growth
