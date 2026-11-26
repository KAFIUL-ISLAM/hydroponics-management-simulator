extends Node

const Liquid = preload("res://scripts/liquid_composition.gd")
const W = Liquid.Component.WATER
const M = Liquid.Component.MINERALS
const P = Liquid.Component.PHYSICAL_POLLUTION
var checks := 0
var failures := 0

func _ready() -> void:
	_supply_and_units()
	_draws()
	_nights()
	_cycle("Nutrition Fruit", 60000, 100000, 50, 2, 3148)
	_cycle("Coffee Beans", 150000, 100000, 30, 3, 9430)
	_cycle("Kotton", 150000, 250000, 75, 6, 46639)
	print("LIQUID_TEST_RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _supply_and_units() -> void:
	var vessel := Liquid.new(16000)
	_check(vessel.total_ul() == 0 and vessel.snapshot_ul().is_empty(), "empty vessel")
	_check(vessel.add_pure_water(1000) == Liquid.Status.OK, "add water")
	_check(vessel.add_mineral_tablet() == Liquid.Status.OK and vessel.total_ul() == 16000, "tablet at exact capacity")
	var before := vessel.snapshot_ul()
	_check(vessel.add_mineral_tablet() == Liquid.Status.CAPACITY_EXCEEDED, "full vessel rejects tablet")
	_check(vessel.replenish({W: 0, 999: 1}) == Liquid.Status.INVALID_INPUT, "unknown component")
	_check(vessel.replenish({"0": 1}) == Liquid.Status.INVALID_INPUT, "noninteger component ID")
	_check(vessel.replenish({W: -1}) == Liquid.Status.INVALID_INPUT, "negative supply")
	_check(vessel.replenish({W: 0.25}) == Liquid.Status.INVALID_INPUT, "fractional microliter")
	_check(vessel.add_pure_water(0.25) == Liquid.Status.INVALID_INPUT, "water action rejects fractions")
	_check(Liquid.new(1.5).replenish({W: 0}) == Liquid.Status.INVALID_INPUT, "capacity rejects fractions")
	_check(vessel.snapshot_ul() == before, "supply rejection atomic")
	before.clear()
	_check(vessel.total_ul() == 16000, "snapshot is detached")
	_check(Liquid.parse_ml_to_ul("1.005") == 1005 and Liquid.parse_ml_to_ul("0") == 0, "exact mL conversion")
	for bad: String in ["0.0001", "-1", "", "1.", "1e3", "1.a", "9223372036854775.808"]:
		_check(Liquid.parse_ml_to_ul(bad) == -1, "reject decimal input " + bad)
	_check(Liquid.parse_ml_to_ul("9223372036854775.807") == Liquid.MAX_UL, "maximum exact conversion")
	var large := Liquid.new(Liquid.MAX_UL)
	_check(large.add_pure_water(Liquid.MAX_UL) == Liquid.Status.OK, "maximum capacity")
	_check(large.replenish({M: 1}) == Liquid.Status.CAPACITY_EXCEEDED and large.total_ul() == Liquid.MAX_UL, "addition cannot overflow")
	_check(Liquid.new(-1).replenish({W: 0}) == Liquid.Status.INVALID_INPUT, "invalid capacity")
	var mixture := Liquid.new(10)
	var supply: Dictionary = {}
	for component: int in Liquid.Component.values():
		supply[component] = 1
	_check(mixture.replenish(supply) == Liquid.Status.OK and mixture.total_ul() == 10, "all ten components supported")

func _draws() -> void:
	var vessel := Liquid.new(10)
	_check(vessel.draw_mixed(0).status == Liquid.Status.OK, "empty zero draw")
	_check(vessel.draw_mixed(1).status == Liquid.Status.INSUFFICIENT_LIQUID, "empty positive draw")
	vessel.replenish({W: 5, M: 3, P: 2})
	var before := vessel.snapshot_ul()
	_check(vessel.draw_mixed(11).status == Liquid.Status.INSUFFICIENT_LIQUID and vessel.snapshot_ul() == before, "overdraw atomic")
	_check(vessel.draw_mixed(-1).status == Liquid.Status.INVALID_INPUT, "negative draw invalid")
	_check(vessel.draw_mixed(1.25).status == Liquid.Status.INVALID_INPUT, "fractional draw invalid")
	var result := vessel.draw_mixed(3)
	_check(result.status == Liquid.Status.OK and result.draw_losses_ul == {W: 1, M: 1, P: 1}, "exact quotas")
	_check(vessel.snapshot_ul() == {W: 4, M: 2, P: 1}, "components conserved")
	result.final_ul.clear()
	_check(vessel.total_ul() == 7, "result is detached")
	result = vessel.draw_mixed(7)
	_check(result.status == Liquid.Status.OK and result.draw_losses_ul == {W: 4, M: 2, P: 1} and vessel.total_ul() == 0, "complete draw")
	var tie := Liquid.new(4)
	tie.replenish({W: 1, M: 3})
	_check(tie.draw_mixed(2).draw_losses_ul == {M: 2}, "equal remainder prefers original volume")
	tie = Liquid.new(2)
	tie.replenish({M: 1, W: 1})
	_check(tie.draw_mixed(1).draw_losses_ul == {W: 1}, "stable ID wins complete tie")
	var huge := Liquid.new(Liquid.MAX_UL)
	huge.add_pure_water(Liquid.MAX_UL)
	_check(huge.draw_mixed(2).status == Liquid.Status.OVERFLOW and huge.total_ul() == Liquid.MAX_UL, "quota multiplication overflow atomic")

func _nights() -> void:
	var vessel := Liquid.new(100000)
	vessel.replenish({W: 99900, M: 100})
	var before := vessel.snapshot_ul()
	var rejected := vessel.consume_night(100000, 8, 30)
	_check(vessel.consume_night(1, 8.5, 30).status == Liquid.Status.INVALID_INPUT, "fractional growth invalid")
	_check(rejected.status == Liquid.Status.INSUFFICIENT_LIQUID and vessel.snapshot_ul() == before, "short after staged uptake leaves state intact")
	var result := vessel.plan_night(50, 8, 30)
	_check(result.requested_uptake_ul == 240 and result.actual_uptake_ul == 100, "uptake capped to stock")
	_check(result.total_mineral_loss_ul() == 100 and result.mineral_draw_loss_ul() == 0 and result.pure_water_loss_ul() == 50, "losses separated")
	_check(result.original_concentration_pct == 100.0 * 100.0 / 99900.0 and vessel.snapshot_ul() == before, "pre-loss concentration and pure plan")
	_check(vessel.consume_night(50, 8, 30).status == Liquid.Status.OK and vessel.total_ul() == 99850, "uptake and draw committed once")
	_check(vessel.mineral_concentration_pct() == 0.0 and vessel.consume_night(0, 8, 30).actual_uptake_ul == 0, "zero minerals valid")
	_check(vessel.consume_night(0, Liquid.MAX_UL, 2).status == Liquid.Status.OVERFLOW, "uptake overflow guard")
	vessel = Liquid.new(100)
	vessel.replenish({M: 100})
	_check(vessel.mineral_concentration_pct() == null and vessel.consume_night(1, 1, 1).status == Liquid.Status.UNDEFINED_CONCENTRATION and vessel.total_ul() == 100, "zero water atomic rejection")
	for edge: float in [1.75, 3.25]:
		_check(Liquid.classify_mineral_band(edge, 1.75, 3.25) == Liquid.Band.IN_RANGE, "inclusive mineral edge")
	_check(Liquid.classify_mineral_band(1.7499, 1.75, 3.25) == Liquid.Band.BELOW, "no display rounding below")
	_check(Liquid.classify_mineral_band(3.2501, 1.75, 3.25) == Liquid.Band.ABOVE, "no display rounding above")
	_check(Liquid.classify_mineral_band(null, 1.75, 3.25) == Liquid.Band.UNDEFINED, "undefined band")
	_check(Liquid.classify_mineral_band(2.0, 3.25, 1.75) == Liquid.Band.INVALID, "invalid band")

func _cycle(label: String, minerals: int, draw: int, rate: int, nights: int, expected: int) -> void:
	var vessel := Liquid.new(5000000 + minerals)
	vessel.replenish({W: 5000000, M: minerals})
	var losses := 0
	for night in nights:
		var before := vessel.total_ul()
		var result := vessel.consume_night(draw, 8, rate)
		_check(result.status == Liquid.Status.OK, label + " night success")
		_check(before - vessel.total_ul() == draw + result.actual_uptake_ul, label + " conservation")
		losses += result.total_mineral_loss_ul()
	var actual: int = minerals - vessel.snapshot_ul().get(M, 0)
	_check(actual == expected and losses == actual, label + " exact mineral loss")
	print("LIQUID_FIXTURE %s expected=%d actual=%d" % [label, expected, actual])

func _check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("LIQUID_CHECK_FAILED: " + description)
