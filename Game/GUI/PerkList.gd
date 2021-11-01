extends ItemList

onready var _menu: PopupMenu = get_node("PopupMenu")

func _ready() -> void:
	Game.connect("perks_changed", self, "_on_perks_changed")
	connect("item_selected", self, "_on_item_selected")
	_menu.connect("index_pressed", self, "_on_menu_pressed")

func _on_perks_changed(active_perks: Array):
	clear()
	
	for perk in active_perks:
		var index = get_item_count()
		add_item(perk[Game.PERK_NAME])
		set_item_tooltip(index, perk[Game.PERK_DESCRIPTION])
		set_item_selectable(index, false)
	
	if Game.perk_points: # есть нераспределенные очки перков
		var new_perks = Game.get_perks_to_select()
		if new_perks: # есть перки для выбора
			Logger.tip(Logger.TIP_LEVEL)
			add_item("Выберите способность >", Resources.get_resource("INFO")) # клик на этом элементе вызывает контекстное меню с выбором нового перка
			
			_menu.clear()
			for perk in new_perks:
				var index = _menu.get_item_count()
				_menu.add_item(perk[Game.PERK_NAME])
				_menu.set_item_tooltip(index, perk[Game.PERK_DESCRIPTION])
	
	visible = get_item_count() as bool

func _on_item_selected(index: int):
	if is_selected(index): # сигнал реагирует даже на клики по элементам с selectable FALSE
		_menu.rect_position = rect_global_position + Vector2(rect_size.x, 0)
		_menu.popup()

func _on_menu_pressed(index: int):
	Game.add_perk(_menu.get_item_text(index))
