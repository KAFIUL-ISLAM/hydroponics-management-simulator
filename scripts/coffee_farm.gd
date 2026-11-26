extends Node

const Liquid = preload("res://scripts/liquid_composition.gd")
const Pollution = preload("res://scripts/pollution_analysis.gd")
const Genetics = preload("res://scripts/crop_genetics.gd")
const Reproduction = preload("res://scripts/seed_reproduction.gd")
const Equipment = preload("res://scripts/hydroponic_equipment.gd")
const Editor = preload("res://scripts/dna_editor.gd")
const W = Liquid.Component.WATER
const M = Liquid.Component.MINERALS

class Seed extends RefCounted:
	var definition: ReferenceCrop
	var traits: Dictionary[String, int]
	var heat: int = 0

	func _init(crop: ReferenceCrop) -> void:
		definition = crop
		traits = crop.native_traits.duplicate()

	func analyze() -> Genetics.Effective:
		return Genetics.resolve(definition, traits, heat)

class Plant:
	enum Stage { PLANTED, MATURE }
	var seed_item: Seed
	var genetics: Genetics.Effective
	var target: int
	var growth: int = 0
	var health: int = 10000
	var stage := Stage.PLANTED
	var pending: int = 0
	var offspring: Array[Seed] = []
	var reproduction: Reproduction.Result
	var replacement_product: String
	var sizes: Dictionary[String, int] = {}

	func _init(source: Seed, properties: Genetics.Effective) -> void:
		seed_item = source
		genetics = properties
		target = properties.crop.target

	func score() -> float:
		return health / 100.0

class FarmOutcome extends GameState.NightOutcome:
	var liquid: Liquid.Consumption
	var pollution: Pollution.Result
	var draw_ul: int
	var energy_kj: int
	var health_loss: int
	var mineral_damage: int
	var pollution_damage: int
	var growth_gained: int
	var resulting_health: int

@export var crop: ReferenceCrop = preload("res://resources/coffee_beans.tres")
@export var capacity_ul: int = 6000000
@export var initial_water_ul: int = 5000000
@export var initial_minerals_ul: int = 150000
@export var energy_kj: int = 100
@export var starter_beans: int = 3
@export var inventory_capacity: int = 24
@export var starter_nutrition_seeds: int = 2
@export var starter_kotton_seeds: int = 2
@export var tablets: int = 10
@export var water_supply_ul: int = 5000000
@export var energy_supply_kj: int = 100
@export var refill_water_ul: int = 500000
@export var refill_energy_kj: int = 24
@export var demo_module_slots: int = 3
@export var demo_disc_uses_per_trait: int = 3
var dna_editor := Editor.new()
var disc_uses: Dictionary[String, int] = {}
var _editor_seed: Seed
@export var demo_machines: Array[int] = [Equipment.Machine.STANDARD, Equipment.Machine.USED, Equipment.Machine.WORN]
@export var demo_modules: Array[int] = [Equipment.Module.NUTRITION, Equipment.Module.NUTRITION,
	Equipment.Module.WEAVING, Equipment.Module.PERFORMANCE, Equipment.Module.EFFICIENCY, Equipment.Module.ECO]
var installed_modules: Array[int] = []
var machine_id: int = Equipment.Machine.STANDARD
var vessel_id: int = Equipment.Vessel.DEMO
var equipment_error: String

var state: GameState
var vessel: LiquidComposition
var beans: Array[Seed] = []
const NUTRITION = preload("res://resources/nutrition_fruit.tres")
const KOTTON = preload("res://resources/kotton.tres")
var catalog: Array[ReferenceCrop] = []
var other_seeds: Dictionary[ReferenceCrop, Array] = {}
var products: Dictionary[String, int] = {}
var plant: Plant
var running := false
var configured := false
var selected_seed_id: int
var reproduction_rng := RandomNumberGenerator.new()

func _ready() -> void:
	for id: String in Editor.SUPPORTED:
		disc_uses[id] = maxi(0, demo_disc_uses_per_trait)
	vessel = Liquid.new(capacity_ul)
	catalog.assign([crop, NUTRITION, KOTTON])
	other_seeds = {NUTRITION: [], KOTTON: []}
	configured = crop != null and starter_beans >= 0 and inventory_capacity >= 0 and starter_beans <= inventory_capacity
	configured = configured and starter_nutrition_seeds >= 0 and starter_nutrition_seeds <= inventory_capacity - starter_beans
	configured = configured and starter_kotton_seeds >= 0 and starter_kotton_seeds <= inventory_capacity - starter_beans - starter_nutrition_seeds
	configured = configured and energy_kj >= 0 and water_supply_ul >= 0 and energy_supply_kj >= 0 and tablets >= 0
	configured = configured and refill_water_ul > 0 and refill_energy_kj > 0
	var supplied := vessel.replenish({W: initial_water_ul, M: initial_minerals_ul})
	configured = configured and supplied == Liquid.Status.OK
	if configured:
		for index in starter_beans:
			beans.append(Seed.new(crop))
		for index in starter_nutrition_seeds:
			other_seeds[NUTRITION].append(Seed.new(NUTRITION))
		for index in starter_kotton_seeds:
			other_seeds[KOTTON].append(Seed.new(KOTTON))

func can_act() -> bool:
	return configured and is_instance_valid(state) and state.is_ready() and not state.is_night_active()

func plant_bean() -> bool:
	if not can_act() or plant != null or crop == null or crop.target <= 0:
		return false
	var stock := seed_stock(crop)
	if stock.is_empty():
		return false
	var planted_seed := selected_seed()
	if planted_seed == null or planted_seed == _editor_seed:
		return false
	var properties := planted_seed.analyze()
	if not properties.valid():
		return false
	stock.erase(planted_seed)
	selected_seed_id = 0
	plant = Plant.new(planted_seed, properties)
	return true

func select_species(index: int) -> bool:
	if not can_act() or plant != null or index < 0 or index >= catalog.size():
		return false
	crop = catalog[index]
	selected_seed_id = 0
	return true

func selected_seed() -> Seed:
	var stock := seed_stock(crop)
	if selected_seed_id == 0:
		return stock.back() if not stock.is_empty() else null
	for item: Seed in stock:
		if item.get_instance_id() == selected_seed_id:
			return item
	return null

func select_seed(id: int) -> bool:
	if not can_act() or plant != null:
		return false
	for item: Seed in seed_stock(crop):
		if item.get_instance_id() == id:
			selected_seed_id = id
			return true
	return false

func seed_count(definition: ReferenceCrop) -> int:
	return seed_stock(definition).size()

func seed_stock(definition: ReferenceCrop) -> Array:
	if not catalog.is_empty() and definition != null and definition == catalog[0]:
		return beans
	return other_seeds.get(definition, [])

func remaining_nights() -> int:
	if plant == null:
		return 0
	var remaining := maxi(0, plant.target - plant.growth)
	var speed := effective_equipment().growth
	if speed <= 0:
		return 0
	@warning_ignore("integer_division")
	return remaining / speed + int(remaining % speed != 0)

func effective_equipment() -> Equipment.Effective:
	var definition := plant.genetics.crop if plant != null else crop
	return Equipment.resolve(machine_id, installed_modules, demo_module_slots, vessel.capacity_ul(),
		definition.species if definition != null else ReferenceCrop.Species.UNKNOWN)

func _equipment_access() -> bool:
	equipment_error = ""
	if not can_act() or running:
		equipment_error = "先停止设备 / Stop the machine first"
		return false
	return true

func select_machine(id: int) -> bool:
	if not _equipment_access():
		return false
	var choice := Equipment.machine_definition(id)
	if choice == null or id not in demo_machines:
		equipment_error = "设备不可用 / Machine unavailable"
		return false
	if not choice.supports_modules and not installed_modules.is_empty():
		equipment_error = "先移除模组 / Remove modules before switching"
		return false
	machine_id = id
	return true

func available_modules(id: int) -> int:
	return demo_modules.count(id) - installed_modules.count(id)

func install_module(id: int) -> bool:
	if not _equipment_access():
		return false
	if Equipment.module_definition(id) == null or available_modules(id) <= 0:
		equipment_error = "模组不可用 / Module unavailable"
		return false
	var pending_modules := installed_modules.duplicate()
	pending_modules.append(id)
	if not Equipment.resolve(machine_id, pending_modules, demo_module_slots, vessel.capacity_ul(), -1).valid:
		equipment_error = "插槽不足、设备锁定或速度无效 / No slot, locked machine or invalid speed"
		return false
	installed_modules = pending_modules
	return true

func remove_module(id: int) -> bool:
	if not _equipment_access():
		return false
	if id not in installed_modules:
		equipment_error = "模组未安装 / Module not installed"
		return false
	var remaining := installed_modules.duplicate()
	remaining.erase(id)
	if not Equipment.resolve(machine_id, remaining, demo_module_slots, vessel.capacity_ul(), -1).valid:
		equipment_error = "速度无效 / Invalid remaining speed"
		return false
	installed_modules = remaining
	return true

func select_vessel(id: int) -> bool:
	if not _equipment_access():
		return false
	if id not in Equipment.Vessel.values():
		equipment_error = "容器不可用 / Vessel unavailable"
		return false
	var staged := Liquid.new(capacity_ul if id == Equipment.Vessel.DEMO else 3000000)
	if staged.replenish(vessel.snapshot_ul()) != Liquid.Status.OK:
		equipment_error = "现有液体超过容积 / Existing solution exceeds capacity"
		return false
	vessel = staged
	vessel_id = id
	return true

func occupied_slots() -> int:
	var count := beans.size() + other_seeds[NUTRITION].size() + other_seeds[KOTTON].size()
	for amount: int in products.values():
		count += amount
	return count

func supply_demo_seed() -> bool:
	if not can_act() or occupied_slots() >= inventory_capacity:
		return false
	seed_stock(crop).append(Seed.new(crop))
	return true

func supply_modified_coffee() -> bool:
	if not can_act() or plant != null or crop != catalog[0] or occupied_slots() >= inventory_capacity:
		return false
	var item := Seed.new(crop)
	item.traits.merge({"Fast Growth": 2, "High Yield": 3, "Drought Resistant": 1, "Hardy": 1})
	if not item.analyze().valid():
		return false
	beans.append(item)
	selected_seed_id = item.get_instance_id()
	return true

func discard_seed_instance(item: Seed) -> bool:
	if not can_act() or item == null or item == _editor_seed or not seed_stock(item.definition).has(item):
		return false
	seed_stock(item.definition).erase(item)
	if selected_seed_id == item.get_instance_id():
		selected_seed_id = 0
	return true

func discard_seed(definition: ReferenceCrop) -> bool:
	if not can_act() or definition not in catalog or seed_stock(definition).is_empty():
		return false
	return discard_seed_instance(seed_stock(definition).back())

func discard_product(key: String) -> bool:
	if not can_act() or not products.has(key):
		return false
	products[key] -= 1
	if products[key] == 0:
		products.erase(key)
	return true

func drain_solution() -> bool:
	return can_act() and vessel.total_ul() > 0 and vessel.draw_mixed(vessel.total_ul()).status == Liquid.Status.OK

enum DemoSolution { CLEAN, SINGLE, MULTIPLE, PHYSICAL, HIGH }

func load_demo_solution(scenario: int) -> bool:
	if not can_act() or not DemoSolution.values().has(scenario):
		return false
	var staged := Liquid.new(vessel.capacity_ul())
	var mixture := {W: 5000000, M: 100000}
	match scenario:
		DemoSolution.SINGLE: mixture[Liquid.Component.HEAVY_METALS] = 10000
		DemoSolution.MULTIPLE:
			mixture[Liquid.Component.HEAVY_METALS] = 10000
			mixture[Liquid.Component.CHEMICALS] = 15000
		DemoSolution.PHYSICAL: mixture[Liquid.Component.PHYSICAL_POLLUTION] = 25000
		DemoSolution.HIGH:
			mixture[Liquid.Component.HEAVY_METALS] = 200000
			mixture[Liquid.Component.ACID] = 200000
	if staged.replenish(mixture) != Liquid.Status.OK:
		return false
	vessel = staged
	return true

func pollution_analysis(snapshot: Dictionary[int, int]) -> Pollution.Result:
	var definition := plant.genetics.crop if plant != null else crop
	var points := maxi(0, effective_equipment().growth)
	if definition == null:
		return Pollution.analyze(snapshot, -1.0, 0.0, points)
	return Pollution.analyze(snapshot, definition.native_pollution_sensitivity, definition.pollution_damage_factor, points)

func toggle_running() -> bool:
	if not can_act() or plant == null or plant.stage == Plant.Stage.MATURE:
		return false
	running = not running
	return true

func add_water() -> bool:
	if not can_act() or water_supply_ul < refill_water_ul or vessel.add_pure_water(refill_water_ul) != Liquid.Status.OK:
		return false
	water_supply_ul -= refill_water_ul
	return true

func add_tablet() -> bool:
	if not can_act() or tablets <= 0 or vessel.insert_tablet_with_displacement() != Liquid.Status.OK:
		return false
	tablets -= 1
	return true

func add_energy() -> bool:
	if not can_act() or energy_supply_kj < refill_energy_kj or energy_kj > Liquid.MAX_UL - refill_energy_kj:
		return false
	energy_supply_kj -= refill_energy_kj
	energy_kj += refill_energy_kj
	return true

func collect() -> bool:
	if not can_act() or plant == null or plant.stage != Plant.Stage.MATURE:
		return false
	var required := plant.offspring.size() + plant.pending
	if required > inventory_capacity - occupied_slots():
		return false
	if plant.genetics.crop.output_is_seed:
		for index in plant.pending:
			seed_stock(plant.seed_item.definition).append(_offspring())
	elif not plant.replacement_product.is_empty() and plant.pending > 0:
		var key := plant.replacement_product
		products[key] = int(products.get(key, 0)) + plant.pending
	else:
		for size: String in plant.sizes:
			var key := "%s · %s" % [plant.genetics.crop.product_name, size]
			products[key] = int(products.get(key, 0)) + plant.sizes[size]
	seed_stock(plant.seed_item.definition).append_array(plant.offspring)
	plant = null
	return true

func preview_edit(item: Seed, trait_id: String) -> Editor.Preview:
	if not can_act() or item == null or not seed_stock(item.definition).has(item) or dna_editor.stage == Editor.Stage.RUNNING:
		var invalid := Editor.Preview.new()
		invalid.error = "种子或编辑器不可用 / Seed or editor unavailable"
		return invalid
	return Editor.preview(item.definition, item.traits, item.heat, item.get_instance_id(), trait_id,
		disc_uses.get(trait_id, 0), energy_kj)

func begin_edit(item: Seed, trait_id: String) -> bool:
	if not dna_editor.start(preview_edit(item, trait_id)):
		return false
	_editor_seed = item
	return true

func seed_edit_locked(item: Seed) -> bool:
	return item != null and item == _editor_seed

func settle(permit: RefCounted) -> GameState.NightOutcome:
	if not state._claim_settlement(settle, permit) or not configured:
		return FarmOutcome.new(GameState.NightStatus.CONFIGURATION_ERROR, "配置无效 / Invalid farm configuration")
	var outcome := _settle_farm()
	if outcome.status != GameState.NightStatus.CONFIGURATION_ERROR and _editor_seed != null:
		var edit := dna_editor.advance(energy_kj)
		energy_kj -= edit.energy_kj
		if edit.completed:
			_editor_seed.heat = edit.heat
			if edit.succeeded:
				_editor_seed.traits = edit.traits
				disc_uses[dna_editor.operation.trait_id] -= 1
			_editor_seed = null
	return outcome

func _settle_farm() -> GameState.NightOutcome:
	if plant == null or plant.stage == Plant.Stage.MATURE or not running:
		var reason := "机器已停止 / Machine stopped"
		if plant == null:
			reason = "尚未播种 / No seed planted"
		elif plant.stage == Plant.Stage.MATURE:
			reason = "等待收获 / Harvest pending"
		return FarmOutcome.new(GameState.NightStatus.NO_CROP, reason)
	var definition := plant.genetics.crop
	var equipment := effective_equipment()
	var points := equipment.growth
	var concentration: Variant = vessel.mineral_concentration_pct()
	var band := Liquid.classify_mineral_band(concentration, definition.mineral_low_pct, definition.mineral_high_pct)
	@warning_ignore("integer_division")
	if not equipment.valid or band == Liquid.Band.UNDEFINED or band == Liquid.Band.INVALID or definition.draw_ul <= 0 or definition.uptake_ul_per_point < 0 or definition.healthy_output < 0 or definition.healthy_output > Liquid.MAX_UL / 100 - equipment.extra_output or plant.growth > Liquid.MAX_UL - points or not definition.annual or not _valid_yields(definition):
		return FarmOutcome.new(GameState.NightStatus.CONFIGURATION_ERROR, "液体、浓度或作物配置无效 / Invalid liquid, concentration or crop")
	if energy_kj < equipment.energy_kj:
		return FarmOutcome.new(GameState.NightStatus.SHORTAGE, "电力不足 / Energy shortage: %d / %d kJ" % [energy_kj, equipment.energy_kj])
	# Only the detached vessel is mutated while staging the night.
	var snapshot := vessel.snapshot_ul()
	var pollution := pollution_analysis(snapshot)
	if not pollution.defined:
		return FarmOutcome.new(GameState.NightStatus.CONFIGURATION_ERROR, "污染配置无效 / Invalid pollution configuration")
	var staged := Liquid.new(vessel.capacity_ul())
	if staged.replenish(snapshot) != Liquid.Status.OK:
		return FarmOutcome.new(GameState.NightStatus.CONFIGURATION_ERROR, "液体配置无效 / Invalid vessel")
	var debit := staged.consume_night(definition.draw_ul, points, definition.uptake_ul_per_point)
	if debit.status == Liquid.Status.INSUFFICIENT_LIQUID:
		var available := vessel.total_ul() - mini(debit.requested_uptake_ul, snapshot.get(M, 0))
		return FarmOutcome.new(GameState.NightStatus.SHORTAGE,
			"营养液不足 / Mixed liquid shortage: %d / %d µL after uptake" % [available, definition.draw_ul])
	if debit.status != Liquid.Status.OK:
		return FarmOutcome.new(GameState.NightStatus.CONFIGURATION_ERROR, "液体计算错误 / Invalid liquid calculation")
	var per_point := 100 if band == Liquid.Band.BELOW else (50 if band == Liquid.Band.ABOVE else 0)
	var mineral_damage := points * per_point
	var pollution_damage := pollution.rounded_damage()
	var next_health := maxi(0, maxi(0, plant.health - mineral_damage) - pollution_damage)
	var next_growth := plant.growth + points
	var mature := next_growth >= plant.target
	var pending := crop_yield(definition, next_health) + equipment.extra_output if mature else 0
	var sizes: Dictionary[String, int] = {}
	var offspring: Array[Seed] = []
	var reproduction: Reproduction.Result
	if mature:
		sizes = size_distribution(definition.size_profile, next_health, pending)
		var rng_state := reproduction_rng.state
		reproduction = Reproduction.resolve(definition.reproduction_profile, next_health, plant.genetics, reproduction_rng.randf)
		if not reproduction.valid:
			reproduction_rng.state = rng_state
			return FarmOutcome.new(GameState.NightStatus.CONFIGURATION_ERROR, "返种配置无效 / Invalid reproduction configuration")
		for index in reproduction.offspring_count:
			offspring.append(_offspring())
	var outcome := FarmOutcome.new(GameState.NightStatus.GROWN)
	outcome.liquid = debit
	outcome.draw_ul = definition.draw_ul
	outcome.energy_kj = equipment.energy_kj
	outcome.health_loss = plant.health - next_health
	outcome.pollution = pollution
	outcome.pollution_damage = pollution_damage
	outcome.mineral_damage = mineral_damage
	outcome.growth_gained = points
	outcome.resulting_health = next_health
	# No signals until GameState publishes the completed transaction.
	vessel = staged
	energy_kj -= equipment.energy_kj
	plant.health = next_health
	plant.growth = next_growth
	if mature:
		plant.stage = Plant.Stage.MATURE
		plant.pending = pending
		plant.offspring = offspring
		plant.reproduction = reproduction
		plant.replacement_product = equipment.replacement
		plant.sizes.assign(sizes)
		running = false
	return outcome

func _offspring() -> Seed:
	var child := Seed.new(plant.seed_item.definition)
	child.traits = plant.genetics.traits.duplicate()
	return child

static func harvest_quantity(base: int, health: int) -> int:
	var tenths := 10
	if health <= 1500:
		tenths = 5
	elif health <= 3000:
		tenths = 6
	elif health <= 5000:
		tenths = 7
	elif health <= 7000:
		tenths = 8
	return round_tenths_half_even(base * tenths)

static func _valid_yields(definition: ReferenceCrop) -> bool:
	if definition.health_yield_pct.size() != 5:
		return false
	for percent: int in definition.health_yield_pct:
		if percent < 0 or percent > 100:
			return false
	return true

static func crop_yield(definition: ReferenceCrop, health: int) -> int:
	var tier := 4
	for index: int in 4:
		if health <= [1500, 3000, 5000, 7000][index]:
			tier = index
			break
	return _round_half_even(definition.healthy_output * definition.health_yield_pct[tier], 100)

static func size_distribution(profile: int, health: int, count: int) -> Dictionary[String, int]:
	const SMALL := "小型 / Small"
	const REGULAR := "普通 / Regular"
	const LARGE := "大型 / Large"
	const GIANT := "巨型 / Giant"
	if profile == 0 or count <= 0:
		return {}
	if health <= 1500:
		return {SMALL: count}
	if health <= 5000:
		return _split_sizes(count, 70 if health <= 3000 else 30, SMALL, REGULAR)
	if health <= 7000:
		return {REGULAR: count}
	if health <= 9000:
		return _split_sizes(count, 80 if health <= 8000 else 30, REGULAR, LARGE)
	if profile == 1 and health >= 10000:
		return {GIANT: count}
	if profile == 1 and health >= 9600:
		return _split_sizes(count, 50, LARGE, GIANT)
	return {LARGE: count}

static func _split_sizes(count: int, percent: int, first: String, second: String) -> Dictionary[String, int]:
	@warning_ignore("integer_division")
	var first_count := count * percent / 100
	var result: Dictionary[String, int] = {second: count - first_count}
	if first_count > 0:
		result[first] = first_count
	return result

static func round_tenths_half_even(value: int) -> int:
	return _round_half_even(value, 10)

static func _round_half_even(value: int, divisor: int) -> int:
	@warning_ignore("integer_division")
	var whole := value / divisor
	var doubled_remainder := (value % divisor) * 2
	return whole + int(doubled_remainder > divisor or (doubled_remainder == divisor and whole % 2 != 0))
