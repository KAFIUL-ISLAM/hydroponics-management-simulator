extends RefCounted

const Genetics = preload("res://scripts/crop_genetics.gd")
const POINTS_PER_NIGHT := 10
const ENERGY_PER_NIGHT_KJ := 12
const SUPPORTED := ["Fast Growth", "Slow Growth", "High Yield", "Low Yield",
	"Drought Resistant", "High Water Use", "Hardy", "Fragile", "Fertile", "Sterile"]

enum Stage { IDLE, RUNNING, SUCCEEDED, FAILED }

class Preview:
	var before: Genetics.Effective
	var after: Genetics.Effective
	var target_id: int
	var trait_id: String
	var required_points: int
	var nights: int
	var total_energy_kj: int
	var success_pct: int
	var error: String
	func valid() -> bool:
		return error.is_empty()

class Night:
	var energy_kj: int
	var completed: bool
	var succeeded: bool
	var traits: Dictionary[String, int] = {}
	var heat: int

var stage := Stage.IDLE
var operation: Preview
var progress: int
var rng := RandomNumberGenerator.new()

static func preview(definition: ReferenceCrop, ranks: Dictionary[String, int], heat: int,
		id: int, trait_id: String, disc_uses: int, energy_kj: int) -> Preview:
	var plan := Preview.new()
	plan.target_id = id
	plan.trait_id = trait_id
	if trait_id not in SUPPORTED:
		plan.error = "当前仅支持应用指定特性 / Only listed trait applications are supported"
		return plan
	if heat < 0 or heat > (LiquidComposition.MAX_UL - 10000) / 12.0:
		plan.error = "热度超出范围 / Heat out of range"
		return plan
	plan.before = Genetics.resolve(definition, ranks, heat)
	if not plan.before.valid():
		plan.error = plan.before.error
		return plan
	var proposed := ranks.duplicate()
	proposed[trait_id] = int(proposed.get(trait_id, 0)) + 1
	plan.after = Genetics.resolve(definition, proposed, heat + Genetics.heat_increment(Genetics.definition(trait_id)))
	if not plan.after.valid():
		plan.error = plan.after.error
		return plan
	var complexity := maxi(0, plan.before.complexity + heat)
	plan.required_points = 20 + 4 * complexity
	@warning_ignore("integer_division")
	plan.nights = (plan.required_points + POINTS_PER_NIGHT - 1) / POINTS_PER_NIGHT
	plan.total_energy_kj = plan.nights * ENERGY_PER_NIGHT_KJ
	plan.success_pct = maxi(5, 95 - 5 * mini(complexity, 18))
	if disc_uses <= 0 or energy_kj < ENERGY_PER_NIGHT_KJ:
		plan.error = "需要数据盘和整夜电量 / Requires a disc use and a full night of energy"
	return plan

func start(plan: Preview) -> bool:
	if stage == Stage.RUNNING or plan == null or not plan.valid():
		return false
	operation = plan
	progress = 0
	stage = Stage.RUNNING
	return true

func advance(energy_kj: int, roll: Callable = Callable()) -> Night:
	var result := Night.new()
	if stage != Stage.RUNNING or energy_kj < ENERGY_PER_NIGHT_KJ:
		return result
	var next_progress := mini(operation.required_points, progress + POINTS_PER_NIGHT)
	if next_progress == operation.required_points:
		var saved := rng.state
		var sample: Variant = roll.call() if roll.is_valid() else rng.randf()
		if typeof(sample) != TYPE_FLOAT or not is_finite(sample) or sample < 0.0 or sample > 1.0:
			rng.state = saved
			return result
		result.completed = true
		result.succeeded = sample < operation.success_pct / 100.0
		result.traits = (operation.after.traits if result.succeeded else operation.before.traits).duplicate()
		result.heat = operation.after.heat
		stage = Stage.SUCCEEDED if result.succeeded else Stage.FAILED
	progress = next_progress
	result.energy_kj = ENERGY_PER_NIGHT_KJ
	return result
