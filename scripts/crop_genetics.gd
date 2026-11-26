extends RefCounted

enum Property { GROWTH, YIELD, DRAW, SENSITIVITY, METADATA }
const MIN_FACTOR := 0.0001000166
# The levels here are the supported project range. The reference table reaches XX.
const MAX_LEVEL := 20
const SOURCE := "F-GEN-01/02/04 · BWIKI 植物基因"

class Trait:
	var id: String
	var name_zh: String
	var property: Property
	var coefficient: float
	var complexity_cost: int
	var opposite: String
	var max_level: int
	var description: String
	var source: String = SOURCE

	func _init(row: Array) -> void:
		id = row[0]
		name_zh = row[1]
		property = row[2]
		coefficient = row[3]
		complexity_cost = row[4]
		opposite = row[5]
		max_level = row[6]
		description = row[7]

class Effective:
	var crop: ReferenceCrop
	var traits: Dictionary[String, int] = {}
	var modifiers: Dictionary[String, float] = {}
	var complexity: int
	var heat: int
	var native: bool
	var sterile_rank: int
	var caffeine_ul: int = -1
	var coffee_paste_ul: int = -1
	var error: String

	func valid() -> bool:
		return error.is_empty()

const ROWS := [
	["Fast Growth", "生长迅速", Property.GROWTH, 0.25, 4, "Slow Growth", MAX_LEVEL, "Growth speed"],
	["Slow Growth", "生长缓慢", Property.GROWTH, -0.25, -3, "Fast Growth", MAX_LEVEL, "Growth speed"],
	["High Yield", "高产", Property.YIELD, 0.20, 4, "Low Yield", MAX_LEVEL, "Harvest quantity"],
	["Low Yield", "低产", Property.YIELD, -0.20, -3, "High Yield", MAX_LEVEL, "Harvest quantity"],
	["Drought Resistant", "耐旱", Property.DRAW, -0.25, 2, "High Water Use", MAX_LEVEL, "Mixed-liquid draw"],
	["High Water Use", "耗水量大", Property.DRAW, 0.25, -1, "Drought Resistant", MAX_LEVEL, "Mixed-liquid draw"],
	["Hardy", "生命力顽强", Property.SENSITIVITY, -0.30, 3, "Fragile", MAX_LEVEL, "Pollution sensitivity"],
	["Fragile", "脆弱", Property.SENSITIVITY, 0.30, -2, "Hardy", MAX_LEVEL, "Pollution sensitivity"],
	["Complex Genome", "复杂基因组", Property.METADATA, 0.0, 0, "", 2, "Locked complexity offset"],
	["Nutritious", "营养丰富", Property.METADATA, 0.25, 3, "", MAX_LEVEL, "Calories"],
	["Sterile", "不育", Property.METADATA, -0.25, -1, "Fertile", MAX_LEVEL, "Seed return"],
	["Fertile", "繁殖力强", Property.METADATA, 0.25, 2, "Sterile", MAX_LEVEL, "Seed return"],
	["Caffeine Output", "产出咖啡因", Property.METADATA, 0.0, 3, "", MAX_LEVEL, "Caffeine composition"],
	["Coffee Paste Output", "产出咖啡豆糊", Property.METADATA, 0.0, 2, "", MAX_LEVEL, "Coffee paste composition"],
	["Potent", "效力强", Property.METADATA, 0.25, 3, "Weak Potency", MAX_LEVEL, "Active composition"],
	["Weak Potency", "效力弱", Property.METADATA, -0.25, -2, "Potent", MAX_LEVEL, "Active composition"],
]

static func definition(id: String) -> Trait:
	for row: Array in ROWS:
		if row[0] == id:
			return Trait.new(row)
	return null

static func heat_increment(entry: Trait) -> int:
	return 2 + absi(entry.complexity_cost)

static func resolve(base: ReferenceCrop, ranks: Dictionary[String, int], heat: int) -> Effective:
	var result := Effective.new()
	result.traits.assign(ranks)
	result.heat = heat
	result.native = ranks == base.native_traits
	result.complexity = base.native_complexity
	result.sterile_rank = ranks.get("Sterile", 0)
	if heat < 0 or ranks.get("Complex Genome", 0) != base.native_traits.get("Complex Genome", 0):
		result.error = "Invalid heat or locked genome rank"
		return result
	var factors := [1.0, 1.0, 1.0, 1.0]
	var changed := [false, false, false, false]
	for row: Array in ROWS:
		var entry := Trait.new(row)
		var native_rank: int = base.native_traits.get(entry.id, 0)
		var rank: int = ranks.get(entry.id, 0)
		if ranks.has(entry.id) and (rank < 1 or rank > entry.max_level or not _compatible(base, ranks, entry)):
			result.error = "Invalid or incompatible trait: " + entry.id
			return result
		var delta := rank - native_rank
		result.complexity += delta * entry.complexity_cost if delta >= 0 else -delta * absi(entry.complexity_cost)
		if entry.property != Property.METADATA:
			var factor := maxf(MIN_FACTOR, 1.0 + entry.coefficient * pow(rank, 0.75))
			factors[entry.property] *= factor
			changed[entry.property] = changed[entry.property] or delta != 0
			if rank > 0:
				result.modifiers[entry.id] = factor
	for id: String in ranks:
		if definition(id) == null:
			result.error = "Unknown trait: " + id
			return result
	if changed[Property.DRAW] and base.raw_draw_ul <= 0:
		result.error = "Raw mixed-liquid draw is unresolved"
		return result
	var crop := base.duplicate(true) as ReferenceCrop
	if changed[Property.GROWTH]:
		crop.target = maxi(1, _half_even(base.raw_target / factors[Property.GROWTH]))
	if changed[Property.YIELD]:
		crop.healthy_output = roundi(base.raw_base_output * factors[Property.YIELD])
	if changed[Property.DRAW]:
		var scaled: float = base.raw_draw_ul * factors[Property.DRAW]
		if fposmod(scaled, 1.0) == 0.5:
			result.error = "Mixed-liquid draw rounding tie is unresolved"
			return result
		crop.draw_ul = roundi(scaled)
	if changed[Property.SENSITIVITY]:
		crop.native_pollution_sensitivity = factors[Property.SENSITIVITY]
	var potency := _product_multiplier(ranks)
	result.caffeine_ul = _active_volume(base.raw_caffeine_ul, 2000, ranks.get("Caffeine Output", 0), potency)
	result.coffee_paste_ul = _active_volume(base.raw_coffee_paste_ul, 10000, ranks.get("Coffee Paste Output", 0), potency)
	result.crop = crop
	return result

static func _product_multiplier(ranks: Dictionary[String, int]) -> float:
	return maxf(MIN_FACTOR, 1.0 + 0.25 * pow(ranks.get("Potent", 0), 0.75)
		- 0.25 * pow(ranks.get("Weak Potency", 0), 0.75))

static func _active_volume(raw_ul: int, addition_ul: int, rank: int, potency: float) -> int:
	if raw_ul < 0:
		return -1
	return _half_even((raw_ul + addition_ul * pow(rank, 0.75)) * potency)

static func _half_even(value: float) -> int:
	var whole := floori(value)
	if value - whole == 0.5:
		return whole + (whole % 2)
	return roundi(value)

static func _compatible(base: ReferenceCrop, ranks: Dictionary[String, int], entry: Trait) -> bool:
	if ranks.has(entry.opposite):
		return false
	match entry.id:
		"Nutritious": return base.native_traits.has("Nutritious")
		"Sterile", "Fertile": return not base.output_is_seed
		"Potent", "Weak Potency": return ranks.has("Caffeine Output") or ranks.has("Coffee Paste Output")
	return true
