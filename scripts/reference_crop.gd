extends Resource
class_name ReferenceCrop

enum Species { UNKNOWN, NUTRITION, KOTTON, COFFEE }

@export var species: Species = Species.UNKNOWN

@export var name_en: String
@export var name_zh: String
@export var raw_target: int
@export var raw_base_output: int
@export var target: int
@export var healthy_output: int
@export var draw_ul: int
@export var raw_draw_ul: int
@export var uptake_ul_per_point: int
@export var mineral_low_pct: float
@export var mineral_high_pct: float
@export var pollution_damage_factor: float
@export var native_pollution_sensitivity: float = 1.0
@export var product_name: String
@export var raw_caffeine_ul: int = -1
@export var raw_coffee_paste_ul: int = -1
@export var size_profile: int
@export var health_yield_pct: Array[int] = [50, 60, 70, 80, 100]
@export var annual: bool
@export var output_is_seed: bool
@export_enum("None", "Nutrition Fruit", "Kotton") var reproduction_profile: int
@export var native_traits: Dictionary[String, int]
@export var native_complexity: int
