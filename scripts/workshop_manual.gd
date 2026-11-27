extends AcceptDialog

const Workstation = preload("res://scripts/workstation_view.gd")
signal tool_requested(tool: String)

func setup(icon: Texture2D) -> void:
	title = "种植手册 / Farming manual"
	ok_button_text = "关闭 / Close"
	var content := Workstation.body(self, title, icon, Color("#8fe8cb"))
	var tabs := TabContainer.new()
	content.add_child(tabs)
	var quick := _page(tabs, "快速开始 / Quick start")
	Workstation.readout(quick).text = (
		"1. 悬停库存图标查看种子。双击培养舱，将咖啡豆种子拖入种子槽。\n"
		+ "Hover over inventory icons to identify seeds. Double-click the chamber and drag a Coffee Beans seed into the seed slot.\n\n"
		+ "2. 设备自动启动。查看水、矿物质和电力，点击「下一夜」。\n"
		+ "The machine starts automatically. Check water, minerals, and energy, then press Next Night.\n\n"
		+ "3. 点击产出图标逐个领取。收完后再播种。咖啡豆可重新种植，营养果和韧棉的收获品不能当种子；返种单独显示。\n"
		+ "Click each output to collect it, then replant. Coffee Beans output is plantable. Fruit and Kotton produce cannot be planted, and their offspring appear as separate seeds.\n\n"
		+ "库存满时，产出会留在设备中。可把种子或收获品拖到电话下方的垃圾桶腾出空间。\n"
		+ "When inventory is full, output stays in the machine. Drag a seed or product to the dustbin under the telephone to free a slot.")
	var advanced := _page(tabs, "进阶 / Advanced")
	Workstation.readout(advanced).text = (
		"浓度与水质：液体分析显示作物适宜范围和污染。纯水稀释溶液；营养片补充矿物质。\n"
		+ "Concentration and water quality: Liquid Analysis shows the crop’s preferred range and pollution. Pure water dilutes the solution. Tablets add minerals.\n\n"
		+ "补给与设备：将水或电池拖到相应槽位。补给有限，合并到设备储量。模组可选，停止设备后可拆回。\n"
		+ "Supplies and equipment: Drag water or an energy cell to its slot. Refills are finite and merge into machine reserves. Modules are optional and can be returned while the machine is stopped.\n\n"
		+ "种子与基因：把种子拖到种子档案或 DNA 编辑器，可查看该种子。编辑消耗电力及演示数据盘，并随夜间结算推进。\n"
		+ "Seeds and DNA: Drop a seed onto Seed Profile or DNA Editor to inspect that instance. Editing uses power and demo disc charges and progresses overnight.\n\n"
		+ "遇到阻塞时，悬停高亮槽位查看原因，再补给或调整设置。标为「演示」的替换溶液和种子操作用于演示。\n"
		+ "When blocked, hover over the highlighted slot for the cause, then refill or adjust the setup. Actions marked Demo are demonstration aids, including solution replacement and demo seeds.")
	var shortcuts := HBoxContainer.new()
	advanced.add_child(shortcuts)
	_shortcut(shortcuts, "设备 / Equipment", "equipment")
	_shortcut(shortcuts, "液体分析 / Liquid analysis", "liquid")
	_shortcut(shortcuts, "DNA 编辑器 / DNA editor", "dna")
	Workstation.bind_escape(self, hide)

func _page(tabs: TabContainer, heading: String) -> VBoxContainer:
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	tabs.add_child(margin)
	tabs.set_tab_title(tabs.get_tab_count() - 1, heading)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 10)
	margin.add_child(page)
	return page

func _shortcut(parent: Container, caption: String, tool: String) -> void:
	var button := Button.new()
	button.text = caption
	parent.add_child(button)
	button.pressed.connect(func() -> void: tool_requested.emit(tool))
