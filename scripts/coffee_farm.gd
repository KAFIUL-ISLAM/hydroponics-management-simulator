extends Node

const Liquid = preload("res://scripts/liquid_composition.gd")
const W = Liquid.Component.WATER
const M = Liquid.Component.MINERALS

class Seed:
	var definition: ReferenceCrop
	var traits: Dictionary[String, int]
	var complexity: int
	var heat: int = 0

	func _init(crop: ReferenceCrop) -> void:
		definition = crop
		traits = crop.native_traits.duplicate()
		complexity = crop.native_complexity

class Plant:
	enum Stage { PLANTED, MATURE }
	var seed_item: Seed
	var target: int
	var growth: int = 0
	var health: int = 10000
	var stage := Stage.PLANTED
	var pending: int = 0
	var sizes: Dictionary[String, int] = {}

	func _init(source: Seed, goal: int) -> void:
		seed_item = source
		target = goal

	func score() -> float:
		return health / 100.0

class FarmOutcome extends GameState.NightOutcome:
	var liquid: Liquid.Consumption
	var draw_ul: int
	var energy_kj: int
	var health_loss: int

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
const SPEED: int = 8
const NIGHT_KJ: int = 8

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

func _ready() -> void:
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
	var planted_seed: Seed = stock.pop_back()
	plant = Plant.new(planted_seed, planted_seed.definition.target)
	return true

func select_species(index: int) -> bool:
	if not can_act() or plant != null or index < 0 or index >= catalog.size():
		return false
	crop = catalog[index]
	return true

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
	@warning_ignore("integer_division")
	return remaining / SPEED + int(remaining % SPEED != 0)

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

func discard_seed(definition: ReferenceCrop) -> bool:
	if not can_act() or definition not in catalog or seed_stock(definition).is_empty():
		return false
	seed_stock(definition).pop_back()
	return true

func discard_product(key: String) -> bool:
	if not can_act() or not products.has(key):
		return false
	products[key] -= 1
	if products[key] == 0:
		products.erase(key)
	return true

func drain_solution() -> bool:
	return can_act() and vessel.total_ul() > 0 and vessel.draw_mixed(vessel.total_ul()).status == Liquid.Status.OK

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
	if not can_act() or plant == null or plant.stage != Plant.Stage.MATURE or plant.pending > inventory_capacity - occupied_slots():
		return false
	if plant.seed_item.definition.output_is_seed:
		for index in plant.pending:
			var child := Seed.new(plant.seed_item.definition)
			child.traits = plant.seed_item.traits.duplicate()
			child.complexity = plant.seed_item.complexity
			seed_stock(child.definition).append(child)
	else:
		for size: String in plant.sizes:
			var key := "%s · %s" % [plant.seed_item.definition.product_name, size]
			products[key] = int(products.get(key, 0)) + plant.sizes[size]
	plant = null
	return true

func settle(permit: RefCounted) -> GameState.NightOutcome:
	if not state._claim_settlement(settle, permit) or not configured:
		return FarmOutcome.new(GameState.NightStatus.CONFIGURATION_ERROR, "配置无效 / Invalid farm configuration")
	if plant == null or plant.stage == Plant.Stage.MATURE or not running:
		var reason := "机器已停止 / Machine stopped"
		if plant == null:
			reason = "尚未播种 / No seed planted"
		elif plant.stage == Plant.Stage.MATURE:
			reason = "等待收获 / Harvest pending"
		return FarmOutcome.new(GameState.NightStatus.NO_CROP, reason)
	var definition := plant.seed_item.definition
	var concentration: Variant = vessel.mineral_concentration_pct()
	var band := Liquid.classify_mineral_band(concentration, definition.mineral_low_pct, definition.mineral_high_pct)
	@warning_ignore("integer_division")
	if band == Liquid.Band.UNDEFINED or band == Liquid.Band.INVALID or definition.draw_ul <= 0 or definition.uptake_ul_per_point < 0 or definition.healthy_output <= 0 or definition.healthy_output > Liquid.MAX_UL / 100 or plant.growth > Liquid.MAX_UL - SPEED or not definition.annual or not _valid_yields(definition):
		return FarmOutcome.new(GameState.NightStatus.CONFIGURATION_ERROR, "液体、浓度或作物配置无效 / Invalid liquid, concentration or crop")
	if energy_kj < NIGHT_KJ:
		return FarmOutcome.new(GameState.NightStatus.SHORTAGE, "电力不足 / Energy shortage: %d / %d kJ" % [energy_kj, NIGHT_KJ])
	# Only the detached vessel is mutated while staging the night.
	var staged := Liquid.new(vessel.capacity_ul())
	if staged.replenish(vessel.snapshot_ul()) != Liquid.Status.OK:
		return FarmOutcome.new(GameState.NightStatus.CONFIGURATION_ERROR, "液体配置无效 / Invalid vessel")
	var debit := staged.consume_night(definition.draw_ul, SPEED, definition.uptake_ul_per_point)
	if debit.status == Liquid.Status.INSUFFICIENT_LIQUID:
		var available := vessel.total_ul() - mini(debit.requested_uptake_ul, vessel.snapshot_ul().get(M, 0))
		return FarmOutcome.new(GameState.NightStatus.SHORTAGE,
			"营养液不足 / Mixed liquid shortage: %d / %d µL after uptake" % [available, definition.draw_ul])
	if debit.status != Liquid.Status.OK:
		return FarmOutcome.new(GameState.NightStatus.CONFIGURATION_ERROR, "液体计算错误 / Invalid liquid calculation")
	var per_point := 100 if band == Liquid.Band.BELOW else (50 if band == Liquid.Band.ABOVE else 0)
	var next_health := maxi(0, plant.health - SPEED * per_point)
	var next_growth := plant.growth + SPEED
	var mature := next_growth >= plant.target
	var pending := crop_yield(definition, next_health) if mature else 0
	var sizes: Dictionary[String, int] = {}
	if mature:
		sizes = size_distribution(definition.size_profile, next_health, pending)
	var outcome := FarmOutcome.new(GameState.NightStatus.GROWN)
	outcome.liquid = debit
	outcome.draw_ul = definition.draw_ul
	outcome.energy_kj = NIGHT_KJ
	outcome.health_loss = plant.health - next_health
	# No signals until GameState publishes the completed transaction.
	vessel = staged
	energy_kj -= NIGHT_KJ
	plant.health = next_health
	plant.growth = next_growth
	if mature:
		plant.stage = Plant.Stage.MATURE
		plant.pending = pending
		plant.sizes.assign(sizes)
		running = false
	return outcome

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
