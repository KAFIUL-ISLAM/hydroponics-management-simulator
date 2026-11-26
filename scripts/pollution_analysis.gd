extends RefCounted

const L = preload("res://scripts/liquid_composition.gd")
const HARMFUL: Array[int] = [L.Component.HEAVY_METALS, L.Component.CHEMICALS,
	L.Component.MICROBES, L.Component.ORGANIC_WASTE, L.Component.ACID, L.Component.ALKALI]
const UPPER: Array[int] = [10, 15, 20, 25, 30, 40, 60, 100, 200]
const BASE: Array[int] = [0, 15, 20, 30, 40, 60, 80, 160, 320, 640]

class ComponentDamage:
	var component: int
	var volume_ul: int
	var concentration: Variant = null
	var exposure: Variant = null
	var tier: int = -1
	var base_per_point: int
	var nightly_damage: float

class Result:
	var defined: bool
	var water_ul: int
	var harmful_ul: int
	var physical_ul: int
	var inert_ul: int
	var sensitivity: float
	var damage_factor: float
	var components: Array[ComponentDamage] = []
	var raw_nightly_damage: float
	# Saturating at the integer limit preserves safe health clamping in the farm.
	func rounded_damage() -> int:
		if raw_nightly_damage >= float(L.MAX_UL):
			return L.MAX_UL
		return roundi(raw_nightly_damage)

static func analyze(snapshot: Dictionary[int, int], sensitivity: float, factor: float, points: int) -> Result:
	var result := Result.new()
	result.water_ul = snapshot.get(L.Component.WATER, 0)
	result.physical_ul = snapshot.get(L.Component.PHYSICAL_POLLUTION, 0)
	result.inert_ul = snapshot.get(L.Component.INERT, 0)
	result.sensitivity = sensitivity
	result.damage_factor = factor
	result.defined = result.water_ul > 0 and is_finite(sensitivity) and sensitivity >= 0.0 and is_finite(factor) and factor >= 0.0 and points >= 0
	for id: int in HARMFUL:
		var part := ComponentDamage.new()
		part.component = id
		part.volume_ul = snapshot.get(id, 0)
		result.harmful_ul += part.volume_ul
		if result.defined:
			part.concentration = 10000.0 * float(part.volume_ul) / float(result.water_ul)
			part.exposure = float(part.concentration) * sensitivity
			if not is_finite(part.exposure):
				result.defined = false
				result.components.append(part)
				continue
			part.tier = _tier(part.exposure)
			part.base_per_point = BASE[part.tier]
			part.nightly_damage = float(part.base_per_point) * factor * float(points)
			result.raw_nightly_damage += part.nightly_damage
		result.components.append(part)
	result.defined = result.defined and is_finite(result.raw_nightly_damage)
	return result

static func _tier(exposure: float) -> int:
	for index: int in UPPER.size():
		if exposure <= UPPER[index]:
			return index
	return UPPER.size()
