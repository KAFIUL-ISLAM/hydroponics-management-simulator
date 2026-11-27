extends Node

const WorkshopScene = preload("res://scenes/workshop.tscn")
const CropArt = preload("res://scripts/orbital_art.gd")
const View = preload("res://scripts/workshop_view.gd")
var checks := 0
var failures := 0

func _ready() -> void:
	# Keep a wall-clock animation test within the runner's frame budget on headless hosts.
	Engine.max_fps = 60
	await _play(Vector2i(1280, 720))
	await _play(Vector2i(1920, 1080))
	await _play_produce(1)
	await _play_produce(2)
	await _check_output_counts()
	var animated := await _check_night_feedback(Vector2i(1280, 720), false)
	var reduced := await _check_night_feedback(Vector2i(1920, 1080), true)
	_check(animated == reduced, "both motion modes report identical night results")
	print("WORKSHOP_UI_TEST_RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _play(dimensions: Vector2i) -> void:
	var viewport := SubViewport.new()
	viewport.size = dimensions
	viewport.gui_embed_subwindows = true
	add_child(viewport)
	var ui = WorkshopScene.instantiate()
	viewport.add_child(ui)
	await get_tree().process_frame
	await get_tree().process_frame
	var view: View = ui.workshop
	view.set_reduced_motion(false)
	var grid: ItemList = ui.inventory_tiles
	var tray: ItemList = view.supply_tray
	var farm = ui.farm
	_check(view.slots["seed"].icon == null and view.water_level.value == float(farm.vessel.total_ul()) and view.power_level.value == float(farm.energy_kj), "new machine has loaded water and power with empty seed slot")
	_check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/workshop.tscn", "workshop is the normal launch")
	_check(not ui.get_node("SafeArea").visible and ui.next_night_button.is_visible_in_tree(), "old dashboard hidden and night button visible")
	_check(grid.get_item_rect(0).position.y < grid.get_item_rect(grid.item_count - 1).position.y, "inventory wraps into multiple rows")
	_check(grid.item_count == 24 and grid.max_columns == 12 and grid.get_item_rect(11).position.y == grid.get_item_rect(0).position.y and grid.get_item_rect(12).position.y > grid.get_item_rect(0).position.y, "24 inventory slots arranged in two rows of 12")
	_check(grid.slots.count("") == farm.inventory_capacity - farm.occupied_slots() and not grid.slots.has(View.WATER), "supplies and equipment are separate from counted inventory")
	var icons: Array[Texture2D] = []
	for definition in farm.catalog:
		var crop_seed = farm.seed_stock(definition).front()
		var i: int = grid.slots.find(ui._inventory_key(crop_seed))
		var texture := grid.get_item_icon(i)
		_check(not icons.has(texture) and texture != null and grid.get_item_text(i).is_empty(), "distinct crop icon without permanent text")
		icons.append(texture)
	_check(CropArt.crop_key("lettuce_prototype") == "seedling", "legacy lettuce has a plant icon mapping")
	_check(tray.get_item_tooltip(tray.slots.find(View.WATER)).contains("500.000 ml per refill"), "water supply projects current canister volume")
	_click(viewport, _cell(tray, View.ENERGY))
	_check(not ui.actions["discard"].is_visible_in_tree(), "workshop hides the old discard button")
	_check(not grid.slots.has(View.DNA) and not grid.slots.has(View.GENETICS) and not grid.slots.has(View.ANALYSER), "tools live outside inventory")

	var center := view.machine.get_global_rect().get_center()
	_click(viewport, center)
	_check(not view.machine_panel.visible, "single click does not open machine")
	_click(viewport, center, true)
	await get_tree().process_frame
	_check(view.machine_panel.visible and grid.is_visible_in_tree(), "double click opens machine with inventory visible")
	_check(view.slots["seed"].icon == null and view.slots["modules"].icon == null and view.slots["seed"].get_theme_stylebox("normal") == view.slots["modules"].get_theme_stylebox("normal"), "empty compartments share style without full-color icons")
	_check(view.slots["seed"].tooltip_text.contains("requires a compatible seed") and view.slots["modules"].tooltip_text.contains("operate without modules"), "machine slot tooltips explain seed requirement and optional modules")
	var bounds := Rect2(Vector2.ZERO, Vector2(dimensions))
	_check(bounds.encloses(view.machine_panel.get_global_rect()) and not view.machine_panel.get_global_rect().intersects(grid.get_global_rect()), "machine and inventory fit without overlap")
	for tool_id in [View.DNA, View.GENETICS, View.ANALYSER]:
		var tool: Button = view.tools[tool_id]
		_check(bounds.encloses(tool.get_global_rect()) and not tool.get_global_rect().intersects(view.machine_panel.get_global_rect()), "tool dock fits above machine")
		_click(viewport, tool.get_global_rect().get_center())
		var dialog: AcceptDialog = {View.DNA: ui.dna_dialog, View.GENETICS: ui.genetics_dialog, View.ANALYSER: ui.liquid_dialog}[tool_id]
		_check(dialog.visible, "tool opens its existing interface")
		dialog.hide()
		await get_tree().process_frame

	var item = farm.beans.front()
	var item_key: String = ui._inventory_key(item)
	var initial_stock: int = farm.occupied_slots()
	var dna_target: Vector2 = view.tools[View.DNA].get_global_rect().get_center()
	_drag(viewport, _cell(grid, item_key), dna_target)
	_check(ui.dna_dialog.visible and is_same(ui.dna_seed.get_selected_metadata(), item), "seed drop opens DNA on exact seed without moving it")
	ui.dna_dialog.hide()
	await get_tree().process_frame
	_drag(viewport, _cell(grid, item_key), view.tools[View.GENETICS].get_global_rect().get_center())
	_check(ui.genetics_dialog.visible and ui.genetics_dialog.dialog_text.contains(str(item.get_instance_id())), "seed drop opens profile on exact seed")
	ui.genetics_dialog.hide()
	await get_tree().process_frame
	var water_before: int = farm.water_supply_ul
	var energy_before: int = farm.energy_kj
	var tablets_before: int = farm.tablets
	var modules_before: int = farm.installed_modules.size()
	_drag(viewport, _cell(grid, item_key), view.slots["power"].get_global_rect().get_center(), view.slots["power"], false)
	_check(farm.occupied_slots() == initial_stock and farm.beans.has(item) and farm.energy_kj == energy_before, "wrong slot preserves seed and power")
	_drag(viewport, _cell(tray, View.WATER), view.slots["water"].get_global_rect().get_center(), view.slots["water"], true)
	await get_tree().process_frame
	_check(farm.water_supply_ul == water_before - farm.refill_water_ul and view.slots["water"].tooltip_text.contains("5500.000"), "water transfer uses existing debit and live slot values")
	_drag(viewport, _cell(tray, View.ENERGY), view.slots["power"].get_global_rect().get_center(), null, false, true)
	await get_tree().process_frame
	_check(farm.energy_kj == energy_before + farm.refill_energy_kj, "power transfer applies one existing refill")
	_check(view.power_level.value > 0.0 and view.water_level.value == float(farm.vessel.total_ul()), "meters reflect authoritative loaded contents")
	_drag(viewport, _cell(tray, View.TABLET), view.slots["water"].get_global_rect().get_center())
	await get_tree().process_frame
	_check(farm.tablets == tablets_before - 1, "tablet uses existing nutrient method")
	var module_key := View.MODULE + str(farm.demo_modules.front())
	_drag(viewport, _cell(tray, module_key), view.slots["modules"].get_global_rect().get_center())
	await get_tree().process_frame
	_check(farm.installed_modules.size() == modules_before + 1, "module reaches existing equipment API")
	_drag(viewport, view.slots["modules"].get_global_rect().get_center(), _cell(tray, module_key))
	await get_tree().process_frame
	_check(farm.installed_modules.size() == modules_before and grid.item_count == 24 and farm.occupied_slots() == initial_stock, "module return changes equipment stock without using crop capacity")
	_drag(viewport, _cell(tray, module_key), view.slots["modules"].get_global_rect().get_center())
	await get_tree().process_frame
	_drag(viewport, _cell(grid, item_key), view.slots["seed"].get_global_rect().get_center())
	await get_tree().process_frame
	_check(farm.plant != null and is_same(farm.plant.seed_item, item) and farm.running, "drag plants exact seed and starts machine")
	_check(farm.occupied_slots() == initial_stock - 1 and not farm.beans.has(item), "planting withdraws precisely one seed")
	if farm.plant == null:
		viewport.free()
		return
	var next := ui.next_night_button.get_global_rect().get_center() as Vector2
	var energy_at_start: int = farm.energy_kj
	var liquid_at_start: int = farm.vessel.total_ul()
	_click(viewport, next)
	await get_tree().process_frame
	_check(ui.game_state.current_day == 2 and farm.plant.growth > 0 and view.crop_art.texture != null, "night button advances exactly one night and displays growth")
	_check(farm.energy_kj == energy_at_start - farm.effective_equipment().energy_kj and farm.vessel.total_ul() < liquid_at_start, "night debits real power and liquid")
	_check(view.power_level.max_value == float(energy_at_start) and view.power_level.value == float(farm.energy_kj), "battery displays the actual overnight drop against a stable charge maximum")
	_click(viewport, next, true)
	_check(ui.game_state.current_day == 2, "double click does not advance an extra night")
	for index in 8:
		if view._has_output():
			break
		_click(viewport, next)
		await get_tree().process_frame
	_check(view._has_output() and not farm.running and not view.output_slots[0].disabled, "maturity shows output and stops machine")
	_check(view.slots["seed"].icon == null and initial_stock - 1 == farm.occupied_slots(), "maturity clears seed display without consuming another seed")
	if not view._has_output():
		viewport.free()
		return
	var pending: int = farm.plant.pending + farm.plant.offspring.size()
	var remaining_coffee: int = farm.beans.size()
	var output: Vector2 = view.output_slots[0].get_global_rect().get_center()
	var capacity: int = farm.inventory_capacity
	farm.inventory_capacity = farm.occupied_slots()
	ui._render()
	_check(grid.item_count == farm.inventory_capacity and not grid.slots.has(""), "full inventory renders exactly its revised capacity with no empty slots")
	_click(viewport, output)
	_check(view._has_output() and farm.occupied_slots() == initial_stock - 1, "capacity rejection preserves pending harvest")
	farm.inventory_capacity = capacity
	ui._render()
	_click(viewport, output)
	_click(viewport, output)
	_check(farm.plant.pending + farm.plant.offspring.size() == pending - 1 and farm.occupied_slots() == initial_stock, "only one Coffee unit collects per click animation")
	_check(farm.beans.size() == remaining_coffee + 1 and not farm.beans.has(item), "Coffee output remains a fresh seed per existing crop definition")
	await _wait_for_arrival(view)
	var mixed_fixture: String = farm.catalog[1].product_name + " · Test"
	farm.products[mixed_fixture] = 2
	ui._render()
	await get_tree().process_frame
	var discarded = farm.beans.back()
	var bin: Rect2 = view.dustbin.get_global_rect()
	var bin_center := bin.get_center()
	_check(bin_center.x / dimensions.x > 0.20 and bin_center.x / dimensions.x < 0.30 and bin_center.y / dimensions.y > 0.63 and bin_center.y / dimensions.y < 0.72, "dustbin tracks the painted lid")
	var energy_supply: int = farm.energy_supply_kj
	_drag(viewport, _cell(tray, View.ENERGY), bin_center, view.dustbin, false)
	_check(farm.energy_supply_kj == energy_supply and farm.beans.has(discarded), "dustbin rejects protected supplies")
	_drag(viewport, view.tools[View.DNA].get_global_rect().get_center(), bin_center, null, false, true)
	_check(view.tools[View.DNA].is_visible_in_tree() and farm.beans.has(discarded), "tool dock items cannot be dragged into the dustbin")
	_drag(viewport, _cell(grid, ui._inventory_key(discarded)), bin_center, view.dustbin, true)
	_check(not farm.beans.has(discarded) and not grid.slots.has(ui._inventory_key(discarded)) and farm.products.get(mixed_fixture) == 2 and grid.slots.count("") == farm.inventory_capacity - farm.occupied_slots(), "discarding one seed frees exactly one usable slot")
	await get_tree().process_frame
	_drag(viewport, _cell(grid, ui._inventory_key(mixed_fixture)), bin_center)
	_check(farm.products.get(mixed_fixture) == 1 and farm.occupied_slots() == initial_stock, "dustbin removes one harvested product and preserves capacity accounting")
	viewport.free()

func _play_produce(catalog_index: int) -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	add_child(viewport)
	var ui = WorkshopScene.instantiate()
	var farm = ui.get_node("CoffeeFarm")
	# Start in the native concentration band, then use the normal nightly path.
	farm.initial_minerals_ul = 75000 if catalog_index == 1 else 150000
	farm.reproduction_rng.seed = 42
	viewport.add_child(ui)
	await get_tree().process_frame
	await get_tree().process_frame
	var view: View = ui.workshop
	view.set_reduced_motion(false)
	var grid: ItemList = ui.inventory_tiles
	var definition = farm.catalog[catalog_index]
	var seed_item = farm.seed_stock(definition).front()
	var seed_key: String = ui._inventory_key(seed_item)
	var seed_icon := grid.get_item_icon(grid.slots.find(seed_key))
	_click(viewport, view.machine.get_global_rect().get_center(), true)
	await get_tree().process_frame
	_drag(viewport, _cell(grid, seed_key), view.slots["seed"].get_global_rect().get_center())
	_check(farm.plant != null and farm.running and view.slots["seed"].icon == seed_icon, "Fruit/Kotton shows the actual installed seed art")
	if farm.plant == null:
		viewport.free()
		return
	var next: Vector2 = ui.next_night_button.get_global_rect().get_center()
	var energy_before: int = farm.energy_kj
	var water_before: int = farm.vessel.total_ul()
	_click(viewport, next)
	_check(farm.energy_kj == energy_before - farm.effective_equipment().energy_kj and view.power_level.value == float(farm.energy_kj) and farm.vessel.total_ul() < water_before, "Fruit/Kotton settles power and liquid overnight")
	for night in 7:
		if view._has_output():
			break
		_click(viewport, next)
		await get_tree().process_frame
	if not view._has_output():
		_check(false, "Fruit/Kotton reaches maturity")
		viewport.free()
		return
	await get_tree().process_frame
	var output_key: String = view.visible_output_keys.front()
	var pending: int = farm.pending_output()[output_key]
	var stock: int = farm.occupied_slots()
	var output: Vector2 = view.output_slots[0].get_global_rect().get_center()
	_check(view.output_slots[0].icon != seed_icon and view.output_slots[0].tooltip_text.contains("Produce"), "Fruit/Kotton produce art and type differ from seed")
	_check(view.visible_output_keys.size() == mini(5, farm.plant.pending + farm.plant.offspring.size()) and farm.installed_modules.is_empty(), "machine produces with no optional modules and caps visible output")
	farm.inventory_capacity = stock + 1
	_click(viewport, output)
	_click(viewport, output)
	_check(view.collecting and farm.products.get(output_key) == 1 and farm.pending_output().get(output_key) == pending - 1, "one Fruit/Kotton product transferred and further clicks preserve pending units")
	var destination: int = grid.slots.find(ui.product_unit_key(output_key, 0))
	_check(destination >= 0 and grid.get_item_icon_modulate(destination) == Color.TRANSPARENT, "claimed slot hides its icon while the collection tween plays")
	view.machine_panel.hide()
	await _wait_for_arrival(view)
	_check(not view.collecting and farm.products.get(output_key) == 1 and grid.get_item_icon_modulate(destination) == Color.WHITE, "closing the panel mid-flight preserves and reveals the product")
	_click(viewport, view.machine.get_global_rect().get_center(), true)
	await get_tree().process_frame
	_click(viewport, output)
	_check(farm.products.get(output_key) == 1 and farm.occupied_slots() == stock + 1, "full inventory leaves remaining produce available")
	farm.inventory_capacity += 1
	ui._render()
	_click(viewport, output)
	_check(farm.products.get(output_key) == 2 and grid.slots.has(ui.product_unit_key(output_key, 0)) and grid.slots.has(ui.product_unit_key(output_key, 1)), "two collected products use two inventory slots")
	await _wait_for_arrival(view)
	farm.inventory_capacity = 24
	ui._render()
	if catalog_index == 1:
		var remaining: int = farm.plant.pending + farm.plant.offspring.size()
		for index in remaining:
			_click(viewport, output)
			await _wait_for_arrival(view)
		_click(viewport, output)
		_check(farm.plant == null and not view._has_output() and farm.products.get(output_key) == pending, "last Fruit click clears output and extra click cannot duplicate it")
	else:
		_check(farm.collect(), "legacy collection completes the remainder after partial clicks")
		ui._render()
	await get_tree().process_frame
	_drag(viewport, _cell(grid, ui.product_unit_key(output_key, 1)), view.slots["seed"].get_global_rect().get_center())
	_check(farm.plant == null and farm.products.get(output_key) == pending, "harvested product cannot be planted even with an empty seed slot")
	viewport.free()

func _wait_for_arrival(view: View) -> void:
	var deadline := Time.get_ticks_msec() + 1500
	while view.collecting and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame

func _check_night_feedback(dimensions: Vector2i, reduce: bool) -> Dictionary:
	var viewport := SubViewport.new()
	viewport.size = dimensions
	add_child(viewport)
	var ui = WorkshopScene.instantiate()
	var farm: View.Farm = ui.get_node("CoffeeFarm")
	farm.initial_minerals_ul = 350000
	viewport.add_child(ui)
	await get_tree().process_frame
	await get_tree().process_frame
	var view: View = ui.workshop
	view.set_reduced_motion(reduce)
	var next: Vector2 = ui.next_night_button.get_global_rect().get_center()
	_check(view.blocker_slot.is_empty(), "intentional idle starts without a warning")
	_click(viewport, next)
	_check(view.blocker_slot == "seed" and view.slots["seed"].tooltip_text.contains("No seed planted") and view.night_feedback.metrics.is_empty(), "advancing without a seed gives contextual feedback without zero-value changes")
	view.message_tween.custom_step(2.2)
	_check(view.blocker_slot.is_empty(), "idle seed hint expires with its message")
	var seed_item := farm.selected_seed()
	_click(viewport, view.machine.get_global_rect().get_center(), true)
	await get_tree().process_frame
	_drag(viewport, _cell(ui.inventory_tiles, ui._inventory_key(seed_item)), view.slots["seed"].get_global_rect().get_center())
	_check(farm.running and farm.installed_modules.is_empty(), "night feedback works with no optional modules")
	var before := farm.vessel.snapshot_ul()
	var initial_power := farm.energy_kj
	var initial_health := farm.plant.health
	var start_day: int = ui.game_state.current_day
	var signals := [0, 0]
	ui.game_state.night_processing_started.connect(func(_day: int) -> void:
		signals[0] += 1
		ui.next_night_button.pressed.emit()
	)
	ui.game_state.night_processing_finished.connect(func(_day: int, _next: int, _outcome: GameState.NightOutcome) -> void:
		signals[1] += 1
	)
	_click(viewport, next)
	_click(viewport, next, true)
	_check(signals == [1, 1] and ui.game_state.current_day == start_day + 1, "reentrant input and double click settle exactly once")
	var after := farm.vessel.snapshot_ul()
	var reported := view.night_feedback.metrics.duplicate()
	_check(reported == {
		"energy": farm.energy_kj - initial_power,
		"water": after[View.Farm.W] - before[View.Farm.W],
		"minerals": after[View.Farm.M] - before[View.Farm.M],
		"growth": farm.plant.growth,
		"health": farm.plant.health - initial_health,
	}, "feedback matches authoritative balances and crop progress")
	_check(view.night_feedback.visible and view.message.text.contains("New growth stage") and view.night_fade.mouse_filter == Control.MOUSE_FILTER_IGNORE, "growth stage feedback is visible and the fade ignores input")
	_check(is_zero_approx(view.night_fade.modulate.a) == reduce, "reduced motion suppresses the fade while preserving results")
	var timer := view.night_feedback.expiry
	var remaining := timer.time_left
	view.machine_panel.hide()
	view.machine_panel.show()
	_check(view.night_feedback.metrics == reported and timer.time_left <= remaining, "reopening machine does not replay night results")
	await get_tree().process_frame
	_check(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(view.night_feedback.row.get_global_rect()) and view.night_feedback.mouse_filter == Control.MOUSE_FILTER_IGNORE, "resource feedback fits and does not capture input")
	timer.start(0.02)
	await timer.timeout
	_check(view.night_feedback.metrics.is_empty() and not view.night_feedback.visible, "transient metrics clear automatically")
	var charged := farm.energy_kj
	farm.energy_kj = 0
	_click(viewport, next)
	_check(view.blocker_slot == "power" and view.slots["power"].tooltip_text.contains("Energy shortage") and view.night_feedback.metrics.is_empty(), "true energy blocker highlights power without repeating stale deltas")
	farm.energy_kj = charged
	ui._render()
	_check(view.blocker_slot.is_empty(), "changing blocker conditions clears the old highlight")
	var normal_vessel := farm.vessel
	farm.vessel = View.Farm.Liquid.new(normal_vessel.capacity_ul())
	farm.vessel.replenish({View.Farm.W: 1000, View.Farm.M: 30})
	_click(viewport, next)
	_check(view.blocker_slot == "water" and view.slots["water"].tooltip_text.contains("Mixed liquid shortage"), "true solution blocker highlights water")
	farm.vessel = View.Farm.Liquid.new(normal_vessel.capacity_ul())
	_click(viewport, next)
	_check(view.blocker_slot == "chassis" and view.slots["chassis"].tooltip_text.contains("Invalid liquid"), "configuration messages use the authoritative outcome")
	farm.vessel = normal_vessel
	for index in 4:
		if view._has_output():
			break
		_click(viewport, next)
	var pending: int = view.night_feedback.metrics.get("output", 0)
	_check(view._has_output() and pending > 0 and pending == farm.plant.pending + farm.plant.offspring.size() and view.message.text.contains("Output ready"), "completion reports actual new output")
	await get_tree().process_frame
	var count := farm.occupied_slots()
	var output := view.output_slots[0].get_global_rect().get_center()
	_click(viewport, output)
	_click(viewport, output)
	_check(farm.occupied_slots() == count + 1 and (ui.inventory_tiles.arriving_key.is_empty() == reduce), "reduced motion preserves collection and the rapid-click guard")
	await _wait_for_arrival(view)
	viewport.free()
	return reported

func _check_output_counts() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	add_child(viewport)
	var ui = WorkshopScene.instantiate()
	viewport.add_child(ui)
	await get_tree().process_frame
	var farm = ui.farm
	var view: View = ui.workshop
	var seed_item = farm.seed_stock(farm.catalog[1]).front()
	farm.plant = View.Farm.Plant.new(seed_item, seed_item.analyze())
	farm.plant.stage = View.Farm.Plant.Stage.MATURE
	for count: int in [0, 1, 3, 5, 8, 12]:
		farm.plant.pending = count
		farm.plant.sizes.clear()
		if count > 0:
			farm.plant.sizes["Small"] = mini(5, count)
		if count > 5:
			farm.plant.sizes["Large"] = count - 5
		ui._render()
		var shown := 0
		for slot in view.output_slots:
			if slot.visible:
				shown += 1
		_check(view.output_grid.visible == (count > 0) and shown == mini(count, 5), "output shows the expected slot count for %d units" % count)
		if count > 5:
			var last = view.output_slots[4]
			_check(last.text == "+%d" % (count - 5) and last.tooltip_text.contains("Small · 收获物 / Produce × 5") and last.tooltip_text.contains("Large · 收获物 / Produce × %d" % (count - 5)), "overflow discloses both actual grades and their quantities")
		elif count > 0:
			_check(view.output_slots[shown - 1].text.is_empty(), "no overflow when all units fit")
	_click(viewport, view.machine.get_global_rect().get_center(), true)
	await get_tree().process_frame
	_click(viewport, view.output_slots[4].get_global_rect().get_center())
	_check(view.output_slots[4].text == "+6" and farm.plant.pending == 11 and farm.products.get(farm.plant.genetics.crop.product_name + " · Small") == 1, "overflow click collects its pictured product once and recalculates the badge")
	await _wait_for_arrival(view)
	var grid: ItemList = ui.inventory_tiles
	var fill_key: String = farm.plant.genetics.crop.product_name + " · Storage fixture"
	farm.products[fill_key] = 24 - farm.occupied_slots()
	ui._render()
	_check(grid.item_count == 24 and grid.slots.count("") == 0 and farm.occupied_slots() == 24, "24/24 has no spare visual or usable inventory cells")
	_click(viewport, view.output_slots[4].get_global_rect().get_center())
	_check(farm.plant.pending == 11, "full inventory keeps the entire pending output")
	await get_tree().process_frame
	_drag(viewport, _cell(grid, ui.product_unit_key(fill_key, 0)), view.dustbin.get_global_rect().get_center())
	_check(grid.item_count == 24 and grid.slots.count("") == 1 and farm.occupied_slots() == 23, "discard from 24/24 opens exactly one slot")
	viewport.free()

func _cell(grid, key: String) -> Vector2:
	return grid.get_global_rect().position + grid.get_item_rect(grid.slots.find(key)).get_center()

func _click(viewport: SubViewport, point: Vector2, double := false) -> void:
	_mouse_motion(viewport, point, Vector2.ZERO)
	_button(viewport, point, true, double)
	_button(viewport, point, false)

func _drag(viewport: SubViewport, from: Vector2, to: Vector2, highlight: Control = null, valid := false, coalesced := false) -> void:
	_mouse_motion(viewport, from, Vector2.ZERO)
	_button(viewport, from, true)
	if coalesced:
		# The stretched window reproduction had a first motion whose reconstructed origin missed the tile.
		_mouse_motion(viewport, to, (to - from) * 0.8, MOUSE_BUTTON_MASK_LEFT)
	else:
		_mouse_motion(viewport, from + Vector2(22, 0), Vector2(22, 0), MOUSE_BUTTON_MASK_LEFT)
	# A quick release may arrive without a preceding motion at the drop target.
	if highlight != null:
		_mouse_motion(viewport, to, to - from, MOUSE_BUTTON_MASK_LEFT)
		var expected := Color("#8cffce") if valid else Color("#ff8c8c")
		_check(highlight.self_modulate == expected, "slot highlights match transaction compatibility")
		if highlight.drop_glow != null:
			_check(highlight.drop_glow.visible == valid, "dustbin only glows for valid disposal")
	_button(viewport, to, false)

func _button(viewport: SubViewport, point: Vector2, pressed: bool, double := false) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.double_click = double
	viewport.push_input(event, true)

func _mouse_motion(viewport: SubViewport, point: Vector2, movement: Vector2, mask := 0) -> void:
	var event := InputEventMouseMotion.new()
	event.position = point
	event.relative = movement
	event.button_mask = mask
	viewport.push_input(event, true)

func _check(ok: bool, detail: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("WORKSHOP_UI_CHECK_FAILED: " + detail)
