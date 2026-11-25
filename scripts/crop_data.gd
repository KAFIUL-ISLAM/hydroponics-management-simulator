extends Resource
class_name CropData

## Reusable data definition for one crop species/variety.
## Values must be filled from verified research or explicitly marked prototype values.

const TRAIT_FAST_GROWTH := "fast_growth"
const TRAIT_SLOW_GROWTH := "slow_growth"
const TRAIT_HIGH_YIELD := "high_yield"
const TRAIT_LOW_YIELD := "low_yield"
const TRAIT_DROUGHT_RESISTANT := "drought_resistant"
const TRAIT_HIGH_WATER_USE := "high_water_use"
const TRAIT_HARDY := "hardy"
const TRAIT_FRAGILE := "fragile"
const TRAIT_FERTILE := "fertile"
const TRAIT_STERILE := "sterile"

const OPPOSING_TRAITS := {
	TRAIT_FAST_GROWTH: TRAIT_SLOW_GROWTH,
	TRAIT_SLOW_GROWTH: TRAIT_FAST_GROWTH,
	TRAIT_HIGH_YIELD: TRAIT_LOW_YIELD,
	TRAIT_LOW_YIELD: TRAIT_HIGH_YIELD,
	TRAIT_DROUGHT_RESISTANT: TRAIT_HIGH_WATER_USE,
	TRAIT_HIGH_WATER_USE: TRAIT_DROUGHT_RESISTANT,
	TRAIT_HARDY: TRAIT_FRAGILE,
	TRAIT_FRAGILE: TRAIT_HARDY,
	TRAIT_FERTILE: TRAIT_STERILE,
	TRAIT_STERILE: TRAIT_FERTILE
}

@export_group("Identity")
@export var crop_id: StringName
@export var display_name_zh: String = ""
@export var display_name_en: String = ""
@export_multiline var description: String = ""

@export_group("Base Growth and Resource Requirements")
## Base growth requirement from the reference research. Zero means not configured.
@export_range(0, 100000, 1) var base_growth_requirement: int = 0
## Water consumed per night, in ml. Zero means not configured.
@export_range(0.0, 1000000.0, 0.1) var water_per_night_ml: float = 0.0
## Mineral consumption per night, in ml. Confirm the unit/value before configuring.
@export_range(0.0, 1000000.0, 0.1) var minerals_per_night_ml: float = 0.0
## Harvest quantity and value are intentionally unset until verified.
@export_range(0, 100000, 1) var base_harvest_quantity: int = 0
@export_range(0.0, 1000000.0, 0.1) var base_market_value: float = 0.0

@export_group("Environmental Properties")
## Pollution sensitivity baseline; define its scale before using in calculations.
@export_range(0.0, 100.0, 0.1) var pollution_sensitivity: float = 0.0

@export_group("Genetics")
## Dictionary format: { "fast_growth": 2, "high_yield": 1 }.
## Trait levels are I-IV (1-4). Opposing traits must not coexist.
@export var genetic_traits: Dictionary = {}
## Genetic complexity and heat are tracked for scanner/editor systems.
@export_range(0, 100000, 1) var genetic_complexity: int = 0
@export_range(0.0, 1000000.0, 0.1) var genetic_heat: float = 0.0

@export_group("Seed and Special Product")
@export var can_produce_seeds: bool = true
@export var special_product_id: StringName


func has_trait(trait_id: String) -> bool:
	return genetic_traits.has(trait_id)


func get_trait_level(trait_id: String) -> int:
	return int(genetic_traits.get(trait_id, 0))


## Returns false for an unknown trait, invalid level, or an opposing trait already present.
func can_add_trait(trait_id: String, level: int) -> bool:
	if not OPPOSING_TRAITS.has(trait_id):
		return false
	if level < 1 or level > 4:
		return false

	var opposing_trait: String = OPPOSING_TRAITS[trait_id]
	return not genetic_traits.has(opposing_trait)


## Adds or updates a trait if it passes the validation rules.
func set_trait(trait_id: String, level: int) -> bool:
	if not can_add_trait(trait_id, level):
		return false

	genetic_traits[trait_id] = level
	return true


func remove_trait(trait_id: String) -> void:
	genetic_traits.erase(trait_id)
