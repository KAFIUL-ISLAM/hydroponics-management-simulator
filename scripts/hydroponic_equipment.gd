extends RefCounted

enum Machine { STANDARD, USED, WORN }
enum Module { NUTRITION, WEAVING, PERFORMANCE, EFFICIENCY, ECO }
enum Vessel { DEMO, CAN }
const SOURCE := "BWIKI 水培系统 / 机器模组 · F-EQP-01–03"

class MachineDefinition:
	var id: int
	var label: String
	var growth: int
	var energy_kj: int
	var supports_modules: bool
	var source := SOURCE
	func _init(key: int, name: String, points: int, energy: int, modular: bool) -> void:
		id = key
		label = name
		growth = points
		energy_kj = energy
		supports_modules = modular

class ModuleDefinition:
	var id: int
	var label: String
	var description: String
	var performance: int
	var efficiency: int
	var quality: int = 0
	var target_crop: int
	var extra_output: int
	var replacement: String
	var source := SOURCE
	func _init(key: int, row: Array) -> void:
		id = key
		label = row[0]
		description = row[1]
		performance = row[2]
		efficiency = row[3]
		target_crop = row[4]
		extra_output = row[5]
		replacement = row[6]

class Effective:
	var machine: MachineDefinition
	var valid: bool
	var growth: int
	var energy_kj: int
	var performance: int
	var efficiency: int
	var adjusted_quality: int
	var capacity_ul: int
	var extra_output: int
	var replacement: String
	var reproduction_multiplier: float = 1.0
	var draw_multiplier: float = 1.0

const MODULE_DATA := [
	["营养果模组 / Nutrition Fruit module", "营养果 +1 / +1 Nutrition Fruit", -10, -10, ReferenceCrop.Species.NUTRITION, 1, ""],
	["自动织造 / Automatic weaving", "纤维改为织物 / Converts fiber to textile", -50, -100, ReferenceCrop.Species.KOTTON, 0, "韧棉织物 / Kotton textile"],
	["性能模组 / Performance module", "提高性能 / Increases performance", 16, 0, -1, 0, ""],
	["效率模组 / Efficiency module", "提高效率 / Increases efficiency", 0, 16, -1, 0, ""],
	["环保模组 / Eco module", "降低性能并提高效率 / Trades performance for efficiency", -16, 32, -1, 0, ""],
]

static func machine_definition(id: int) -> MachineDefinition:
	match id:
		Machine.STANDARD: return MachineDefinition.new(id, "标准 / Standard", 8, 8, true)
		Machine.USED: return MachineDefinition.new(id, "旧设备 / Used (locked)", 9, 11, false)
		Machine.WORN: return MachineDefinition.new(id, "破旧设备 / Worn (locked)", 6, 3, false)
	return null

static func module_definition(id: int) -> ModuleDefinition:
	if id < 0 or id >= MODULE_DATA.size():
		return null
	return ModuleDefinition.new(id, MODULE_DATA[id])

static func resolve(machine_id: int, modules: Array[int], slots: int, capacity_ul: int, species: int) -> Effective:
	var result := Effective.new()
	result.machine = machine_definition(machine_id)
	result.capacity_ul = capacity_ul
	if result.machine == null or slots < 0 or capacity_ul < 0 or modules.size() > slots:
		return result
	if not result.machine.supports_modules and not modules.is_empty():
		return result
	var quality := 0
	for id: int in modules:
		var module := module_definition(id)
		if module == null:
			return result
		result.performance += module.performance
		result.efficiency += module.efficiency
		quality += module.quality
		if module.target_crop == species:
			result.extra_output += module.extra_output
			if not module.replacement.is_empty():
				result.replacement = module.replacement
	@warning_ignore("integer_division")
	var performance_delta := result.machine.growth * result.performance / 2
	result.growth = int(result.machine.growth + performance_delta / 100.0)
	@warning_ignore("integer_division")
	result.energy_kj = maxi(1, result.machine.energy_kj - result.machine.energy_kj * result.efficiency / 100)
	@warning_ignore("integer_division")
	result.adjusted_quality = quality / 2
	result.valid = result.growth > 0
	return result
