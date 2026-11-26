extends Node

const UI = preload("res://scenes/coffee_dashboard.tscn")
const E = preload("res://scripts/hydroponic_equipment.gd")
var checks := 0
var failures := 0

func _ready() -> void:
	await _check_workstations(Vector2i(1280, 720))
	await _check_workstations(Vector2i(1920, 1080))
	print("WORKSTATIONS_TEST_RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(0 if failures == 0 else 1)

func _check_workstations(dimensions: Vector2i) -> void:
	var viewport := SubViewport.new()
	viewport.size = dimensions
	viewport.gui_embed_subwindows = true
	add_child(viewport)
	var ui = UI.instantiate()
	viewport.add_child(ui)
	var farm = ui.farm
	await _settle_layout()
	var analysis_button: Button = ui.actions["analysis"]
	analysis_button.grab_focus()
	analysis_button.pressed.emit()
	await _settle_layout()
	_check(_fits(ui.liquid_dialog, dimensions), "liquid bounds and exclusive window")
	_check(ui.liquid_capacity.value == farm.vessel.total_ul() and ui.liquid_capacity.max_value == farm.vessel.capacity_ul(), "exact liquid capacity")
	_check(ui.liquid_range.value == farm.vessel.mineral_concentration_pct() and ui.liquid_band.text.contains("Healthy"), "authoritative mineral gauge")
	_check(ui.analysis_text.text.contains("Predicted nightly pollution damage: 0"), "authoritative pollution projection")
	var day: int = ui.game_state.current_day
	_click(viewport, ui.next_night_button.get_global_rect().get_center())
	_check(ui.game_state.current_day == day and ui.liquid_dialog.visible, "modal blocks underlying night button")
	ui.liquid_dialog.get_ok_button().pressed.emit()
	await _settle_layout()
	_check(not ui.liquid_dialog.visible and analysis_button.has_focus(), "close restores invoking focus")
	ui.actions["equipment"].pressed.emit()
	await _settle_layout()
	_check(_fits(ui.equipment_dialog, dimensions), "equipment bounds")
	ui.module_choice.select(ui.module_choice.get_item_index(E.Module.WEAVING))
	ui.actions["install_module"].pressed.emit()
	var effective = farm.effective_equipment()
	_check(ui.equipment_readout.text.contains("%d → %d pts/night" % [effective.machine.growth, effective.growth])
		and ui.equipment_readout.text.contains("%d → %d kJ/night" % [effective.machine.energy_kj, effective.energy_kj])
		and ui.equipment_slots.text.contains("1/3"), "equipment metrics and installed slot")
	ui.equipment_dialog.get_ok_button().pressed.emit()
	ui.inventory_tiles.item_selected.emit(0)
	var selected_seed = farm.selected_seed()
	ui.actions["genetics"].pressed.emit()
	await _settle_layout()
	_check(_fits(ui.genetics_dialog, dimensions) and ui.genes_portrait.texture != null, "seed bounds and portrait")
	_check(ui.genes_readout.text.contains(str(selected_seed.get_instance_id())) and ui.genes_readout.text.contains("21 → 21"), "seed identity and stats")
	ui.actions["dna"].pressed.emit()
	await _settle_layout()
	var plan = farm.preview_edit(selected_seed, "Fast Growth")
	_check(_fits(ui.dna_dialog, dimensions) and not ui.genetics_dialog.visible, "nested handoff and DNA bounds")
	_check(ui.dna_readout.text.contains("%d%%" % plan.success_pct) and ui.dna_readout.text.contains("%d kJ" % plan.total_energy_kj), "authoritative DNA preview")
	ui.dna_start.pressed.emit()
	var operation = farm.dna_editor.operation
	ui.dna_start.pressed.emit()
	_check(ui.dna_start.disabled and is_same(farm.dna_editor.operation, operation) and ui.dna_progress.max_value == operation.required_points, "duplicate confirm blocked and progress displayed")
	ui.dna_dialog.get_ok_button().pressed.emit()
	ui.hotspots["cultivation"].pressed.emit()
	await _settle_layout()
	_check(_fits(ui.cultivation_dialog, dimensions) and ui.actions["run"].disabled and farm.plant == null, "cultivation open and unavailable action")
	ui.cultivation_dialog.get_ok_button().pressed.emit()
	ui.inventory_tiles.item_selected.emit(1)
	var discard_target = ui.stored_items.get_selected_metadata()
	ui.actions["discard"].pressed.emit()
	await _settle_layout()
	_check(_fits(ui.confirm_action, dimensions), "confirmation bounds")
	ui.inventory_tiles.item_selected.emit(2)
	ui.confirm_action.get_ok_button().pressed.emit()
	_check(not farm.beans.has(discard_target) and farm.beans.size() == 2, "confirmation keeps original target")
	ui.actions["discard"].pressed.emit()
	ui.confirm_action.get_cancel_button().pressed.emit()
	await _settle_layout()
	_check(farm.beans.size() == 2 and not ui.confirm_action.visible, "cancel leaves inventory")
	ui.actions["discard"].pressed.emit()
	await _settle_layout()
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	ui.confirm_action.push_input(escape, true)
	await _settle_layout()
	_check(farm.beans.size() == 2 and not ui.confirm_action.visible and not ui.pending_action.is_valid(), "Escape cancels without discarding")
	farm.drain_solution()
	farm.crop = null
	ui.actions["analysis"].pressed.emit()
	_check(ui.liquid_capacity.value == 0 and not ui.liquid_range.visible and ui.liquid_band.text.contains("unavailable"), "empty vessel without crop context")
	viewport.free()

func _click(viewport: SubViewport, position: Vector2) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = position
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		viewport.push_input(event, true)

func _settle_layout() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func _fits(dialog: AcceptDialog, dimensions: Vector2i) -> bool:
	return dialog.visible and dialog.exclusive and Rect2i(Vector2i.ZERO, dimensions).encloses(Rect2i(dialog.position, dialog.size))

func _check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("WORKSTATIONS_CHECK_FAILED: " + label)
