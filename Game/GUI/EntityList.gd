# Элемент GUI для отображения списка сущностей игрока

extends ItemList

enum MENU_ITEMS {USE, DELETE} # перечень возможных ID для меню

onready var _menu := $"PopupMenu" # контекстное меню (одно на все сущности, обновляется под выбранную сущность)


func _ready() -> void:
	clear()
	
	Global.player.connect("entities_changed", self, "_update_list") # обновляем список при любом изменении сущностей игрока
	connect("item_rmb_selected", self, "_show_menu")
	_menu.connect("id_pressed", self, "_on_menu_item_pressed")

func _update_list(entities: Array) -> void: # сюда передается управление по сигналу от player
	clear()
	
	for i in range(0, entities.size()): # в целях отладки игрока включаем в список
#	for i in range(1, entities.size()): # сущность с нулевым индексом - это игрок, его не добавляем в список
		_add_item(entities[i])
	
	visible = get_item_count() as bool

func _add_item(entity: Dictionary) -> void:
	if entity:
		var item_text: String = entity[DB.KEYS.NAME]
		if DB.KEYS.HEALTH in entity: # здоровье (тек./макс.)
			item_text += " (%s/%s)" % [str(entity[DB.KEYS.HEALTH].x), str(entity[DB.KEYS.HEALTH].y)]
		if DB.KEYS.USES in entity: # [кол. использований]
			item_text += " [%s]" % str(entity[DB.KEYS.USES])
		add_item(item_text)
		
		var tooltip_text := ""
		var db_keys = DB.KEYS.keys()
		for key in entity.keys():
			tooltip_text += "%s: %s\n" % [db_keys[key], entity[key]]
		
		var index = get_item_count()
		set_item_tooltip(index - 1, tooltip_text)
		set_item_metadata(index - 1, entity) # сохраняем ссылку на сущность
	else:
		push_warning("Попытка добавить пустую сущность в EntityList !")
		print_stack()

func _show_menu(index: int, position: Vector2) -> void: # формирование меню по индексу сущности
	_menu.rect_position = rect_position + position + Vector2(10, 0) # устанавливаем позицию меню чуть правее от места клика
	
	_menu.clear()
	
	var entity = get_item_metadata(index)
	
	if DB.KEYS.USES in entity:
		_menu.add_item("Использовать", MENU_ITEMS.USE)
	_menu.add_item("Удалить", MENU_ITEMS.DELETE)
	
	_menu.set_meta("entity", entity) # сохраняем ссылку на сущность
	
	_menu.rect_size = Vector2.ZERO # корректируем размер (Годо без багов не бывает)
	_menu.popup()

func _on_menu_item_pressed(index: int) -> void: # обработка нажатий на пункты контекстного меню
	var entity = _menu.get_meta("entity")
		
	match index:
		MENU_ITEMS.USE:
			pass
		MENU_ITEMS.DELETE:
			Global.player.remove_entity(entity)
