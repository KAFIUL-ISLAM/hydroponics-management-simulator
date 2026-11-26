extends RefCounted
class_name LiquidComposition

enum Component { WATER, MINERALS, HEAVY_METALS, CHEMICALS, MICROBES, ORGANIC_WASTE, ACID, ALKALI, PHYSICAL_POLLUTION, INERT }
enum Status { OK, INVALID_INPUT, CAPACITY_EXCEEDED, INSUFFICIENT_LIQUID, UNDEFINED_CONCENTRATION, OVERFLOW }
enum Band { BELOW, IN_RANGE, ABOVE, UNDEFINED, INVALID }

const MAX_UL: int = 9223372036854775807
const TABLET_UL: int = 15000

class Consumption:
	var status: Status
	var original_concentration_pct: Variant = null
	var requested_uptake_ul: int
	var actual_uptake_ul: int
	var draw_losses_ul: Dictionary[int, int] = {}
	var final_ul: Dictionary[int, int] = {}

	func _init(result_status: Status) -> void:
		status = result_status

	func mineral_draw_loss_ul() -> int:
		return draw_losses_ul.get(Component.MINERALS, 0)

	func total_mineral_loss_ul() -> int:
		return actual_uptake_ul + mineral_draw_loss_ul()

	func pure_water_loss_ul() -> int:
		return draw_losses_ul.get(Component.WATER, 0)

var _capacity_ul: int
var _components: Dictionary[int, int] = {}

## A negative capacity creates an invalid vessel. Operations reject it.
func _init(configured_capacity_ul: Variant) -> void:
	_capacity_ul = int(configured_capacity_ul) if typeof(configured_capacity_ul) == TYPE_INT else -1

func capacity_ul() -> int:
	return _capacity_ul

func snapshot_ul() -> Dictionary[int, int]:
	return _components.duplicate()

func total_ul() -> int:
	return _sum(_components)

func add_pure_water(amount_ul: Variant) -> Status:
	return replenish({Component.WATER: amount_ul})

func add_mineral_tablet() -> Status:
	return replenish({Component.MINERALS: TABLET_UL})

## Displace the minimum amount of the original mixture and insert the whole tablet.
func insert_tablet_with_displacement() -> Status:
	if _capacity_ul < TABLET_UL:
		return Status.CAPACITY_EXCEEDED
	var displacement := maxi(0, TABLET_UL - (_capacity_ul - total_ul()))
	var plan := _plan_draw(snapshot_ul(), displacement)
	if plan.status != Status.OK:
		return plan.status
	plan.final_ul[Component.MINERALS] = int(plan.final_ul.get(Component.MINERALS, 0)) + TABLET_UL
	_components = plan.final_ul
	return Status.OK

## Validate the full supply transfer before writing any component.
func replenish(amounts_ul: Dictionary) -> Status:
	if _capacity_ul < 0:
		return Status.INVALID_INPUT
	var remaining := _capacity_ul - total_ul()
	for key: Variant in amounts_ul:
		var amount: Variant = amounts_ul[key]
		if typeof(key) != TYPE_INT or not Component.values().has(key):
			return Status.INVALID_INPUT
		if typeof(amount) != TYPE_INT or amount < 0:
			return Status.INVALID_INPUT
		if amount > remaining:
			return Status.CAPACITY_EXCEEDED
		remaining -= int(amount)
	for key: int in amounts_ul:
		if amounts_ul[key] > 0:
			_components[key] = _components.get(key, 0) + amounts_ul[key]
	return Status.OK

## Parse decimal mL exactly. -1 denotes invalid input, excess precision, or overflow.
static func parse_ml_to_ul(value: String) -> int:
	var parts := value.split(".")
	if parts.size() > 2 or parts[0].is_empty():
		return -1
	if parts.size() == 2 and (parts[1].is_empty() or parts[1].length() > 3):
		return -1
	var digits := parts[0] + (parts[1].rpad(3, "0") if parts.size() == 2 else "000")
	var result: int = 0
	for index in digits.length():
		var digit := digits.unicode_at(index) - 48
		@warning_ignore("integer_division")
		if digit < 0 or digit > 9 or result > (MAX_UL - digit) / 10:
			return -1
		result = result * 10 + digit
	return result

## Returns null when the pure-water denominator is zero.
func mineral_concentration_pct() -> Variant:
	var water: int = _components.get(Component.WATER, 0)
	if water == 0:
		return null
	return 100.0 * float(_components.get(Component.MINERALS, 0)) / float(water)

static func classify_mineral_band(concentration_pct: Variant, lower_pct: float, upper_pct: float) -> Band:
	if not is_finite(lower_pct) or not is_finite(upper_pct) or lower_pct < 0.0 or upper_pct < lower_pct:
		return Band.INVALID
	if concentration_pct == null:
		return Band.UNDEFINED
	if typeof(concentration_pct) != TYPE_FLOAT and typeof(concentration_pct) != TYPE_INT:
		return Band.INVALID
	var value := float(concentration_pct)
	if not is_finite(value) or value < 0.0:
		return Band.INVALID
	if value < lower_pct:
		return Band.BELOW
	if value > upper_pct:
		return Band.ABOVE
	return Band.IN_RANGE

func draw_mixed(draw_ul: Variant) -> Consumption:
	if typeof(draw_ul) != TYPE_INT:
		return Consumption.new(Status.INVALID_INPUT)
	var result := _plan_draw(snapshot_ul(), int(draw_ul))
	if result.status == Status.OK:
		_components = result.final_ul.duplicate()
	return result

## Calculate full uptake and draw against a detached snapshot. No mutation.
func plan_night(draw_ul: Variant, growth_points: Variant, uptake_ul_per_point: Variant) -> Consumption:
	if typeof(draw_ul) != TYPE_INT or typeof(growth_points) != TYPE_INT or typeof(uptake_ul_per_point) != TYPE_INT:
		return Consumption.new(Status.INVALID_INPUT)
	if _capacity_ul < 0 or draw_ul < 0 or growth_points < 0 or uptake_ul_per_point < 0:
		return Consumption.new(Status.INVALID_INPUT)
	var concentration: Variant = mineral_concentration_pct()
	if concentration == null:
		return Consumption.new(Status.UNDEFINED_CONCENTRATION)
	if _product_overflows(int(growth_points), int(uptake_ul_per_point)):
		return Consumption.new(Status.OVERFLOW)
	var requested := int(growth_points) * int(uptake_ul_per_point)
	var staged := snapshot_ul()
	var actual := mini(requested, staged.get(Component.MINERALS, 0))
	if actual > 0:
		staged[Component.MINERALS] -= actual
		if staged[Component.MINERALS] == 0:
			staged.erase(Component.MINERALS)
	var result := _plan_draw(staged, int(draw_ul))
	result.original_concentration_pct = concentration
	result.requested_uptake_ul = requested
	if result.status == Status.OK:
		result.actual_uptake_ul = actual
	return result

func consume_night(draw_ul: Variant, growth_points: Variant, uptake_ul_per_point: Variant) -> Consumption:
	var result := plan_night(draw_ul, growth_points, uptake_ul_per_point)
	if result.status == Status.OK:
		_components = result.final_ul.duplicate()
	return result

func _plan_draw(staged: Dictionary[int, int], draw_ul: int) -> Consumption:
	if _capacity_ul < 0 or draw_ul < 0:
		return Consumption.new(Status.INVALID_INPUT)
	var total := _sum(staged)
	if draw_ul > total:
		return Consumption.new(Status.INSUFFICIENT_LIQUID)
	var result := Consumption.new(Status.OK)
	result.final_ul = staged.duplicate()
	if draw_ul == 0:
		return result
	if draw_ul == total:
		result.draw_losses_ul = staged.duplicate()
		result.final_ul.clear()
		return result

	var remainders: Dictionary[int, int] = {}
	var order: Array[int] = []
	var unallocated := draw_ul
	for key: int in staged:
		if _product_overflows(draw_ul, staged[key]):
			return Consumption.new(Status.OVERFLOW)
		var product := draw_ul * staged[key]
		@warning_ignore("integer_division")
		var quota := product / total
		result.draw_losses_ul[key] = quota
		remainders[key] = product % total
		order.append(key)
		unallocated -= quota

	order.sort_custom(func(a: int, b: int) -> bool:
		if remainders[a] != remainders[b]:
			return remainders[a] > remainders[b]
		if staged[a] != staged[b]:
			return staged[a] > staged[b]
		return a < b
	)
	for index in unallocated:
		result.draw_losses_ul[order[index]] += 1
	for key: int in staged:
		var loss := result.draw_losses_ul[key]
		if loss == 0:
			result.draw_losses_ul.erase(key)
		elif loss == staged[key]:
			result.final_ul.erase(key)
		else:
			result.final_ul[key] -= loss
	return result

static func _sum(components: Dictionary[int, int]) -> int:
	var total: int = 0
	for amount: int in components.values():
		total += amount
	return total

static func _product_overflows(a: int, b: int) -> bool:
	@warning_ignore("integer_division")
	return b != 0 and a > MAX_UL / b
