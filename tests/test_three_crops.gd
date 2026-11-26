extends Node

const UI = preload("res://scenes/coffee_dashboard.tscn")
const Farm = preload("res://scripts/coffee_farm.gd")
const L = preload("res://scripts/liquid_composition.gd")
const W = L.Component.WATER
const M = L.Component.MINERALS
var checks := 0
var failures := 0

func _ready() -> void:
	_cycle(1, 60000, 2, 16, 200000, 800, 3148, 7, "巨型 / Giant")
	_cycle(2, 150000, 6, 48, 1500000, 3600, 46639, 13, "大型 / Large")
	_displacement()
	for pair: Array in [[1500,6],[1501,8],[3000,8],[3001,10],[5000,10],[5001,12],[7000,12],[7001,13]]:
		_check(Farm.crop_yield(Farm.KOTTON, pair[0]) == pair[1], "Kotton threshold")
	for profile: int in [1, 2]:
		for health: int in [0, 1500, 1501, 3000, 3001, 5000, 5001, 7000, 7001, 8000, 8001, 9000, 9001, 9500, 9599, 9600, 9999, 10000]:
			var sizes := Farm.size_distribution(profile, health, 7)
			var count := 0
			for amount: int in sizes.values():
				count += amount
			_check(count == 7, "size conservation")
	_check(Farm.size_distribution(1, 9599, 7) == {"大型 / Large":7}, "provisional gap")
	_check(Farm.size_distribution(1, 9600, 7) == {"大型 / Large":3,"巨型 / Giant":4}, "floor and remainder")
	_check(Farm.crop_yield(Farm.NUTRITION, 0) == 7, "Nutrition count independent of health")
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280,720)
	add_child(viewport)
	var ui = UI.instantiate()
	viewport.add_child(ui)
	_select(ui, 1)
	ui.actions["plant"].pressed.emit()
	ui.actions["run"].pressed.emit()
	ui.next_night_button.pressed.emit()
	_check(ui.farm.plant.health == 9600, "Nutrition uses own excessive band")
	ui.actions["drain"].pressed.emit()
	_check(ui.farm.vessel.total_ul() > 0, "drain awaits confirmation")
	ui.confirm_action.confirmed.emit()
	_check(ui.farm.vessel.total_ul() == 0 and ui.farm.water_supply_ul == 5000000, "drain gives no refund")
	await get_tree().process_frame
	await get_tree().process_frame
	for control: Control in ui.actions.values() + [ui.crop_menu, ui.stored_items, ui.next_night_button, ui.crop_growth_label]:
		_check(Rect2(0,0,1280,720).encloses(control.get_global_rect()), "layout inside target")
	print("THREE_CROP_TEST_RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _cycle(species: int, minerals: int, nights: int, final_growth: int, draw: int, uptake: int, loss: int, count: int, size: String) -> void:
	var ui = UI.instantiate()
	var farm: Farm = ui.get_node("CoffeeFarm")
	farm.initial_minerals_ul = minerals
	add_child(ui)
	_select(ui, species)
	var definition := farm.crop
	var stock: int = farm.seed_count(definition)
	_check(farm.seed_stock(definition)[0] != farm.seed_stock(definition)[1], "independent starters")
	ui.actions["seed_supply"].pressed.emit()
	_check(farm.seed_count(definition) == stock + 1, "demo supply")
	ui.actions["plant"].pressed.emit()
	_check(farm.seed_count(definition) == stock and ui.crop_menu.disabled, "plant consumes one and locks crop")
	_check(not farm.select_species(0) and farm.crop == definition, "active crop rejects replacement")
	ui.actions["run"].pressed.emit()
	var totals := [0,0,0,0]
	ui.game_state.night_processing_finished.connect(func(_day: int, _next: int, outcome: GameState.NightOutcome) -> void:
		if outcome.status == GameState.NightStatus.GROWN:
			totals[0] += outcome.draw_ul
			totals[1] += outcome.liquid.actual_uptake_ul
			totals[2] += outcome.liquid.total_mineral_loss_ul()
			totals[3] += outcome.energy_kj
	)
	for night: int in nights:
		ui.next_night_button.pressed.emit()
		_check(farm.plant.growth == (night + 1) * 8 and farm.plant.health == 10000, "healthy full night")
	_check(farm.plant.growth == final_growth and farm.plant.pending == count and farm.plant.sizes == {size:count}, "maturity and sizes")
	_check(not farm.select_species(0), "pending harvest rejects replacement")
	_check(totals == [draw,uptake,loss,8*nights] and farm.energy_kj == 100-8*nights, "exact cycle totals")
	print("CROP_FIXTURE %s nights=%d points=%d draw=%d uptake=%d mineral_loss=%d energy=%d output=%d" % [definition.name_en,nights,farm.plant.growth,totals[0],totals[1],totals[2],totals[3],farm.plant.pending])
	var before := farm.vessel.snapshot_ul()
	farm.inventory_capacity = farm.occupied_slots() + count - 1
	ui.actions["harvest"].pressed.emit()
	_check(farm.plant != null and farm.products.is_empty(), "full harvest remains pending")
	ui.actions["discard"].pressed.emit()
	_check(farm.occupied_slots() == farm.inventory_capacity - count + 1, "discard waits for confirmation")
	ui.confirm_action.confirmed.emit()
	ui.actions["harvest"].pressed.emit()
	_check(farm.plant == null and farm.products.get("%s · %s" % [definition.product_name,size]) == count, "confirmed discard unlocks collection")
	_check(farm.seed_count(definition) == stock and not farm.collect(), "no duplicate seeds or output")
	_select(ui, 0)
	_check(farm.crop != definition and farm.vessel.snapshot_ul() == before and farm.energy_kj == 100-8*nights, "switch preserves stores")
	ui.free()

func _select(ui, index: int) -> void:
	ui.crop_menu.select(index)
	ui.crop_menu.item_selected.emit(index)

func _displacement() -> void:
	var vessel := L.new(1000000)
	vessel.replenish({W:1000000})
	_check(vessel.insert_tablet_with_displacement() == L.Status.OK and vessel.snapshot_ul() == {W:985000,M:15000}, "full water displacement")
	vessel = L.new(1000000)
	vessel.replenish({W:800000,M:200000})
	_check(vessel.insert_tablet_with_displacement() == L.Status.OK and vessel.snapshot_ul() == {W:788000,M:212000}, "proportional mixed displacement")
	vessel = L.new(14999)
	vessel.add_pure_water(14999)
	_check(vessel.insert_tablet_with_displacement() == L.Status.CAPACITY_EXCEEDED and vessel.snapshot_ul() == {W:14999}, "small vessel rejection atomic")

func _check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("THREE_CROP_CHECK_FAILED: " + label)
