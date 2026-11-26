extends RefCounted

const Genetics = preload("res://scripts/crop_genetics.gd")
enum Profile { NONE, NUTRITION, KOTTON }

class Result:
	var eligible: bool
	var valid: bool = true
	var attempts: int
	var extra_attempt_probability: float
	var base_copy_count: int = 1
	var multiplier: float = 1.0
	var extra_copy_probability: float
	var copies_by_attempt: Array[int] = []
	var offspring_count: int

static func resolve(profile: int, health: int, properties: Genetics.Effective, roll: Callable) -> Result:
	var result := Result.new()
	result.eligible = profile in [Profile.NUTRITION, Profile.KOTTON]
	result.valid = Profile.values().has(profile) and health >= 0 and health <= 10000 and properties != null and properties.valid()
	if not result.valid or not result.eligible:
		return result
	result.attempts = 3 if profile == Profile.NUTRITION else (2 if health > 8000 else 1)
	if profile == Profile.KOTTON and health > 5000 and health <= 8000:
		result.extra_attempt_probability = 0.5
		result.attempts += int(_chance(result, 0.5, roll))
		if not result.valid:
			return result
	var fertile: int = properties.traits.get("Fertile", 0)
	result.multiplier = maxf(Genetics.MIN_FACTOR, 1.0 + 0.25 * pow(fertile, 0.75)
		- 0.25 * pow(properties.sterile_rank, 0.75))
	var guaranteed := floori(result.multiplier)
	result.extra_copy_probability = result.multiplier - guaranteed
	for attempt in result.attempts:
		var copies := guaranteed + int(_chance(result, result.extra_copy_probability, roll))
		if not result.valid:
			return result
		result.copies_by_attempt.append(copies)
		result.offspring_count += copies
	return result

static func _chance(result: Result, probability: float, roll: Callable) -> bool:
	if probability <= 0.0:
		return false
	if probability >= 1.0:
		return true
	var sample: Variant = roll.call() if roll.is_valid() else null
	if typeof(sample) != TYPE_FLOAT or not is_finite(sample) or sample < 0.0 or sample > 1.0:
		result.valid = false
		return false
	return sample < probability
