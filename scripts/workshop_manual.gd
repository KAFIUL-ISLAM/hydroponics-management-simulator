extends AcceptDialog

const Workstation = preload("res://scripts/workstation_view.gd")
const Art = preload("res://scripts/orbital_art.gd")
signal tool_requested(tool: String)

func setup(art: Art) -> void:
	title = "种植手册 / Farming manual"
	ok_button_text = "关闭 / Close"
	var content := Workstation.fixed_body(self, title, art.texture("seed"), Color("#343e2e"), Color("#eee3c6"), Color("#dce3b6"))
	var spread := HBoxContainer.new()
	content.add_child(spread)
	var binding := VBoxContainer.new()
	binding.custom_minimum_size.x = 34
	binding.alignment = BoxContainer.ALIGNMENT_CENTER
	binding.add_theme_constant_override("separation", 17)
	spread.add_child(binding)
	for index in 7:
		var ring := Workstation.section(binding, "⟜")
		ring.add_theme_font_size_override("font_size", 22)
		ring.add_theme_color_override("font_color", Color("#545a43"))
	var pages := Workstation.fixed_tabs(spread)
	pages.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pages.add_theme_stylebox_override("panel", Workstation.frame(Color("#f6eed8"), Color("#baae8c"), 5))
	var quick := Workstation.fixed_page(pages, "快速开始 / Quick start")
	quick.add_theme_constant_override("separation", 5)
	_note(quick, art.texture("coffee"), "播种 / Plant", "悬停识别种子。双击培养舱，将种子拖入种子槽。", "Hover to identify seeds. Double-click the chamber and drop a seed into its slot.")
	_note(quick, art.texture("water"), "培养 / Cultivate", "设备自动启动。检查水、矿物质和电力，点击「下一夜」。", "The machine starts automatically. Check water, minerals and power, then press Next Night.")
	_note(quick, art.texture("seed"), "收获与再种 / Harvest and replant", "点击产出逐件领取。咖啡可再种。果实与纤维为收获品，返种单独显示。", "Click outputs one at a time. Replant Coffee. Fruit and fiber are produce; offspring seeds appear separately.")
	_note(quick, null, "提示 / Tip", "库存满时产出留舱。电话下的垃圾桶可腾出库存。", "Full inventory leaves output in the chamber. Use the dustbin below the telephone to free a slot.")
	var advanced := Workstation.fixed_page(pages, "进阶 / Advanced")
	advanced.add_theme_constant_override("separation", 5)
	_note(advanced, art.texture("tank"), "水质和矿物质 / Water and minerals", "液体分析显示污染与作物适宜浓度。纯水稀释，营养片补矿。", "Liquid Analysis shows pollution and the crop’s preferred range. Water dilutes; tablets add minerals.")
	_note(advanced, art.texture("module"), "补给与设备 / Supplies and equipment", "水和电池拖入对应槽。补给有限；模组可选，停机可拆回。", "Drop water or energy into its slot. Refills are finite. Modules are optional and removable while stopped.")
	_note(advanced, art.texture("dna"), "种子与基因 / Seeds and DNA", "拖种子至档案或编辑器。编辑消耗电力和演示数据盘，逐夜推进。", "Drop a seed on Seed Profile or DNA Editor. Editing uses power and demo disc charges over nights.")
	_note(advanced, null, "阻塞与演示 / Blockers and demonstrations", "悬停高亮槽位并按原因恢复。标有「演示」的补给仅用于演示。", "Hover over highlighted slots for recovery. Actions marked Demo are demonstration aids.")
	var shortcuts := HBoxContainer.new()
	advanced.add_child(shortcuts)
	_shortcut(shortcuts, "设备 / Equipment", "equipment")
	_shortcut(shortcuts, "液体分析 / Liquid analysis", "liquid")
	_shortcut(shortcuts, "DNA 编辑器 / DNA editor", "dna")
	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(footer)
	var previous := Button.new()
	previous.text = "‹"
	previous.tooltip_text = "上一页 / Previous page"
	footer.add_child(previous)
	var number := Workstation.section(footer, "")
	number.add_theme_color_override("font_color", Color("#344025"))
	var next := Button.new()
	next.text = "›"
	next.tooltip_text = "下一页 / Next page"
	footer.add_child(next)
	var refresh := func(page: int) -> void:
		number.text = "页 / Page %d / 2" % [page + 1]
		previous.disabled = page == 0
		next.disabled = page == 1
	pages.tab_changed.connect(refresh)
	previous.pressed.connect(func() -> void:
		pages.current_tab = 0
		pages.get_tab_bar().grab_focus()
	)
	next.pressed.connect(func() -> void:
		pages.current_tab = 1
		pages.get_tab_bar().grab_focus()
	)
	refresh.call(0)
	Workstation.bind_escape(self, hide)

func _note(page: Container, icon: Texture2D, heading: String, chinese: String, english: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	page.add_child(row)
	var image := Art.decoration(icon)
	image.custom_minimum_size = Vector2(35, 32)
	row.add_child(image)
	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_box)
	var title_label := Workstation.section(text_box, heading)
	title_label.add_theme_color_override("font_color", Color("#3b552a"))
	var copy := Workstation.fixed_readout(text_box, chinese + "\n" + english, 64)
	copy.add_theme_color_override("default_color", Color("#302e25"))

func _shortcut(parent: Container, caption: String, tool: String) -> void:
	var button := Button.new()
	button.text = caption
	parent.add_child(button)
	button.pressed.connect(func() -> void: tool_requested.emit(tool))
