# Элемент GUI для отображения списка сущностей игрока

extends ItemList

enum MENU_ITEMS {USE, DELETE} # перечень возможных ID для меню

onready var _menu := $"PopupMenu" # контекстное меню (одно на все сущности, обновляется под выбранную сущность)


func _ready() -> void:
	clear()
	
	E.connect("player_entities_changed", self, "_on_player_entities_changed") # обновляем список при любом изменении сущностей игрока
	connect("item_rmb_selected", self, "_on_item_rmb_selected")
	_menu.connect("id_pressed", self, "_on_menu_item_pressed")

func _on_player_entities_changed(entities: Array) -> void: # сюда передается управление по сигналу от player
	clear()
	
	for entity in E.player.get_entities():
		if entity.get_attribute(E.CLASS) != E.CLASSES.ABILITY:
			_add_item(entity)
	
	set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	visible = get_item_count() as bool # скрываем если пусто

func _add_item(entity: GameEntity) -> void:
	add_item(entity.get_text())
	
	var tooltip_text := ""
	var player_attributes: Dictionary = entity.get_attributes()
	for attribute in player_attributes.keys():
		tooltip_text += "%s: %s\n" % [attribute, player_attributes[attribute]]
	
	var index = get_item_count()
	set_item_tooltip(index - 1, tooltip_text)
	set_item_metadata(index - 1, entity) # сохраняем ссылку на сущность

func _on_item_rmb_selected(index: int, position: Vector2) -> void: # формирование меню по индексу сущности
	_menu.rect_position = rect_position + position + Vector2(10, 0) # устанавливаем позицию меню чуть правее от места клика
	
	_menu.clear()
	
	var entity: GameEntity = get_item_metadata(index)
	
	if entity.get_attribute(E.QUANTITY):
		var submenu_index := 0 # какая же убогая эта система индексов у элементов меню ...
		
		var change_health = entity.get_attribute(E.CHANGE_HEALTH, false, 0)
		if change_health > 0: # если сущность может восстанавливать здоровье
			var restore_menu = _get_submenu("RestoreMenu")
			_menu.add_submenu_item("Восстановить %d здоровья ..." % change_health, "RestoreMenu", -2)
			
			for target in E.player.get_entities(true): # включая самого игрока
				var health = target.get_attribute(E.HEALTH)
				if health and target.get_attribute(E.TYPE) == E.TYPES.BIOLOGICAL: # находим все биологические объекты
					restore_menu.add_item(target.get_text(), submenu_index)
					restore_menu.set_item_metadata(submenu_index, target) # сохраняем ссылку на целевую сущность
					submenu_index += 1
		
		var load_menu = _get_submenu("LoadMenu")
		for target in E.player.get_entities():
			if target.get_attribute(E.CONSUMABLES) == entity.get_attribute(E.NAME): # ищем, является ли данная сущность расходником к другим
				var target_capacity: Vector2 = target.get_attribute(E.CAPACITY)
				if target_capacity.x < target_capacity.y: # если возможно пополнение
					load_menu.add_item(target.get_text(), submenu_index)
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
	var entity: GameEntity = _menu.get_meta("entity")
		
	match index:
		MENU_ITEMS.DELETE:
			E.player.remove_entity(entity)

func _on_submenu_item_pressed(index: int, submenu: PopupMenu):
	var entity: GameEntity = _menu.get_meta("entity")
	var target: GameEntity = submenu.get_item_metadata(index)
	
	match submenu.name:
		"RestoreMenu":
			target.change_attribute(E.HEALTH, entity.get_attribute(E.CHANGE_HEALTH, false))
			entity.change_attribute(E.QUANTITY, -1)
		
		"LoadMenu":
			var surplus = target.change_attribute(E.CAPACITY, entity.get_attribute(E.QUANTITY))
			entity.set_attribute(E.QUANTITY, surplus)
