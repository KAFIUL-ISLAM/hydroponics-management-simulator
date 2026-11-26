extends Node

const LETTUCE = preload("res://resources/lettuce_prototype.tres")


func _ready() -> void:
	print("========== CROP RESOURCE TEST ==========")

	# Test 1: Resource loaded
	assert(LETTUCE is CropData)
	print("TEST 1 PASSED: CropData resource loaded")

	# Test 2: Identity
	assert(LETTUCE.crop_id == &"lettuce_prototype")
	assert(LETTUCE.display_name_en == "Lettuce")
	assert(LETTUCE.display_name_zh == "生菜")
	print("TEST 2 PASSED: Crop identity verified")

	# Test 3: Default gameplay values
	assert(LETTUCE.base_growth_requirement == 0)
	assert(LETTUCE.water_per_night_ml == 0.0)
	assert(LETTUCE.base_harvest_quantity == 0)
	print("TEST 3 PASSED: Default values verified")

	# Test 4: Genetic traits
	assert(LETTUCE.genetic_traits.is_empty())
	print("TEST 4 PASSED: Genetic traits initialized")

	print("========== ALL TESTS PASSED ==========")
