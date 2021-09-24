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
	
	
	set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	visible = get_item_count() as bool # скрываем если пусто

func _add_item(entity: Dictionary) -> void:
	if entity:
		var item_text: String = entity[DB.KEYS.NAME]
		if DB.KEYS.HEALTH in entity: # здоровье (тек./макс.)
			item_text += " (%d/%d)" % [entity[DB.KEYS.HEALTH].x, entity[DB.KEYS.HEALTH].y]
		if DB.KEYS.USES in entity: # [кол. использований]
			item_text += " [%d]" % entity[DB.KEYS.USES]
		if DB.KEYS.CAPACITY in entity: # заряды [тек./макс.]
			item_text += " [%d/%d]" % [entity[DB.KEYS.CAPACITY].x, entity[DB.KEYS.CAPACITY].y]
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
		var submenu_index := 0 # какая же убогая эта система индексов у элементов меню ...
		
		if DB.KEYS.RESTOREHEALTH in entity: # если сущность может восстанавливать здоровье
			var restore_menu = _get_submenu("RestoreMenu")
			_menu.add_submenu_item("Восстановить %d здоровья ..." % entity[DB.KEYS.RESTOREHEALTH], "RestoreMenu", -2)
			
			for target in Global.player.entities:
				if DB.KEYS.HEALTH in target and target[DB.KEYS.TYPE] == DB.TYPES.BIOLOGICAL: # находим все биологические объекты
					restore_menu.add_item("%s (%d/%d)" % [target[DB.KEYS.NAME], target[DB.KEYS.HEALTH].x, target[DB.KEYS.HEALTH].y], submenu_index)
					restore_menu.set_item_metadata(submenu_index, target) # сохраняем ссылку на целевую сущность
					submenu_index += 1
		var load_menu = _get_submenu("LoadMenu")
		for target in Global.player.entities:
			if target.get(DB.KEYS.CONSUMABLES) == entity[DB.KEYS.NAME]: # ищем, является ли данная сущность расходником к другим
				var target_capacity: Vector2 = target[DB.KEYS.CAPACITY]
				if target_capacity.x < target_capacity.y: # если возможно пополнение
					load_menu.add_item("%s [%d/%d]" % [target[DB.KEYS.NAME], target_capacity.x, target_capacity.y], submenu_index)
					load_menu.set_item_metadata(submenu_index, target) # сохраняем ссылку на целевую сущность
					submenu_index += 1
		
		if load_menu.get_item_count(): # если есть что пополнять
			_menu.add_submenu_item("Пополнить запас у ...", "LoadMenu", -2)
	
	_menu.add_item("Удалить", MENU_ITEMS.DELETE)
	
	_menu.set_meta("entity", entity) # сохраняем ссылку на сущность
	
	_menu.rect_size = Vector2.ZERO # корректируем размер (Годо без багов не бывает)
	_menu.popup()

func _get_submenu(name: String) -> PopupMenu: # ищем подменю с указанным именем, если такого нет, то создаем
	var submenu = _menu.get_node_or_null(name)
	if submenu:
		submenu.clear()
	else:
		submenu = PopupMenu.new()
		submenu.name = name
		_menu.add_child(submenu)
		submenu.connect("id_pressed", self, "_on_submenu_item_pressed", [submenu])
	return submenu

func _on_menu_item_pressed(index: int) -> void: # обработка нажатий на пункты контекстного меню
	var entity = _menu.get_meta("entity")
		
	match index:
		MENU_ITEMS.DELETE:
			Global.player.remove_entity(entity)

func _on_submenu_item_pressed(index: int, submenu: PopupMenu):
	var entity = _menu.get_meta("entity")
	var target = submenu.get_item_metadata(index)
	
	match submenu.name:
		"RestoreMenu":
			var new_health = target[DB.KEYS.HEALTH].x + entity[DB.KEYS.RESTOREHEALTH]
			Global.player.change_attribute(target, DB.KEYS.HEALTH, new_health)
			Global.player.change_attribute(entity, DB.KEYS.USES, entity[DB.KEYS.USES] - 1)
		
		"LoadMenu":
			var needed = target[DB.KEYS.CAPACITY].y - target[DB.KEYS.CAPACITY].x
			var can_give = min(needed, entity[DB.KEYS.USES])
			Global.player.change_attribute(target, DB.KEYS.CAPACITY, target[DB.KEYS.CAPACITY].x + can_give)
			Global.player.change_attribute(entity, DB.KEYS.USES, entity[DB.KEYS.USES] - can_give)
