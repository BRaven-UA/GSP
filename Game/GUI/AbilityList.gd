extends ItemList

onready var _menu: PopupMenu = get_node("PopupMenu")

func _ready() -> void:
	E.connect("player_entities_changed", self, "_on_player_entities_changed")
	connect("item_selected", self, "_on_item_selected")
	_menu.connect("index_pressed", self, "_on_menu_pressed")

func _on_player_entities_changed(entities: Array):
	clear()
	
	for entity in entities:
		if entity.get_attribute(E.CLASS) == E.CLASSES.ABILITY:
			var name = entity.get_attribute(E.NAME)
			if name == "Новая способность": # сущность-заглушка для выбора способности
				name = "Выберите способность >"
				var new_perks = E.get_perks_to_select()
				if new_perks: # есть перки для выбора
					Logger.tip(Logger.TIP_LEVEL)
					add_item(name, Resources.get_resource("INFO")) # клик на этом элементе вызывает контекстное меню с выбором нового перка
					
					_menu.clear()
					for entity_data in new_perks:
						var index = _menu.get_item_count()
						_menu.add_item(entity_data[E.NAME])
						_menu.set_item_tooltip(index, entity_data[E.DESCRIPTION])
			else:
				var index = get_item_count()
				add_item(name)
				set_item_tooltip(index, entity.get_attribute(E.DESCRIPTION))
				set_item_selectable(index, false)

func _on_item_selected(index: int):
	if is_selected(index): # сигнал реагирует даже на клики по элементам с selectable FALSE
		_menu.set_global_position(get_global_mouse_position() + Vector2(10, 0))
		_menu.popup()

func _on_menu_pressed(index: int):
	var name = _menu.get_item_text(index)
	E.player.remove_entity(E.player.find_entity(E.NAME, "Новая способность"))
	E.study(name)
