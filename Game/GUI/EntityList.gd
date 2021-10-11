# Элемент GUI для отображения списка сущностей игрока

extends ItemList

enum MENU_ITEMS {SWITCH = 100, SPLIT, DELETE, SORT} # перечень возможных ID для меню

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

func _add_item(entity: GameEntity) -> void:
	var index = get_item_count() # индекс для нового пункта
	add_item(entity.get_text())
	var activable = entity.get_attribute(E.ACTIVE) # может ли игрок активировать сущность вручную
	if activable != null:
		set_item_icon(index, Resources.get_resource("ON" if activable else "OFF"))
	set_item_tooltip(index, entity.get_full_info())
	set_item_metadata(index, entity) # сохраняем ссылку на сущность

func _on_item_rmb_selected(index: int, position: Vector2) -> void: # формирование меню по индексу сущности
	_menu.rect_position = rect_position + position + Vector2(10, 0) # устанавливаем позицию меню чуть правее от места клика
	_menu.clear()
	
	var entity: GameEntity = get_item_metadata(index)
	var quantity = entity.get_attribute(E.QUANTITY)
	var capacity = entity.get_attribute(E.CAPACITY, true, Vector2.ZERO)
	
	var activable = entity.get_attribute(E.ACTIVE)
	if activable != null:
		var turn_on_text = "Активировать"
		if not capacity.x:
			turn_on_text += " (нужна зарядка)"
		
		var menu_index = _menu.get_item_count() # индекс для нового пункта
		_menu.add_item("Деактивировать" if activable else turn_on_text, MENU_ITEMS.SWITCH)
		_menu.set_item_disabled(menu_index, not bool(capacity.x))
	
	if quantity or capacity:
		var change_health = entity.get_attribute(E.CHANGE_HEALTH, false, 0)
		if change_health > 0: # если сущность может восстанавливать здоровье
			var restore_menu = _init_submenu("RestoreMenu")
			_menu.add_submenu_item("Восстановить %d здоровья " % change_health, "RestoreMenu", -2)
			
			for target in E.player.get_entities(true): # включая самого игрока
				var health = target.get_attribute(E.HEALTH)
				if health and target.get_attribute(E.TYPE) == E.TYPES.BIOLOGICAL: # находим все биологические объекты
					_add_submenu_item(restore_menu, target)
		
		var load_menu = _init_submenu("LoadMenu")
		for target in E.player.get_entities():
			if target.get_attribute(E.CONSUMABLES) == entity.get_attribute(E.NAME): # ищем, является ли данная сущность расходником к другим
				var target_capacity: Vector2 = target.get_attribute(E.CAPACITY)
				if target_capacity.x < target_capacity.y: # если возможно пополнение
					_add_submenu_item(load_menu, target)
		
		if load_menu.get_item_count(): # если есть что пополнять
			_menu.add_submenu_item("Пополнить запас ", "LoadMenu", -2)
		
	if capacity.x: # имеются заряды для разрядки
		var unload_menu = _init_submenu("UnloadMenu")
		
		var consumable_name = entity.get_attribute(E.CONSUMABLES, true, entity.get_attribute(E.NAME)) # если не указан тип расходников, значит это виртуальный расходник, вместо него берем имя самой сущности
		
		var consumable_data = E.get_base_entity(consumable_name)
		if consumable_data.has(E.QUANTITY):
			consumable_data[E.QUANTITY] = capacity.x
			var consumable = E.create_entity(consumable_data)
			_add_submenu_item(unload_menu, consumable)
		
		for target in E.player.get_entities():
			if (target.get_attribute(E.CONSUMABLES) == consumable_name or target.get_attribute(E.NAME) == consumable_name) and target != entity: # если использует данный тип расходником или является им 
				var target_capacity: Vector2 = target.get_attribute(E.CAPACITY, true, Vector2(0, 1)) # Vector2(0, 1) - это заглушка для сущностей с количеством
				if target_capacity.x < target_capacity.y: # если возможно пополнение
					_add_submenu_item(unload_menu, target)
		
		_menu.add_submenu_item("Разрядить ", "UnloadMenu", -2)
	
	if quantity:
		var merge_menu = _init_submenu("MergeMenu")
		for target in E.player.get_entities():
			if target.get_attribute(E.NAME) == entity.get_attribute(E.NAME) and target != entity:
				_add_submenu_item(merge_menu, target)
		
		if merge_menu.get_item_count(): # если есть с чем объединять
			_menu.add_submenu_item("Объединить ", "MergeMenu", -2)
		
		if quantity > 1:
			var split_menu = _init_submenu("SplitMenu")
			split_menu.hide_on_item_selection = false # нажатия на элементы меню не скрывают меню
			
			split_menu.add_item("%s [1]" % entity.get_attribute(E.NAME), 0)
			split_menu.set_item_metadata(0, 1) # тут хранится текущее количество (по умолчанию 1)
			
			split_menu.add_item("Увеличить на 1", 1)
			if quantity == 2:
				split_menu.set_item_disabled(1, true) # сразу нельзя увеличить до максимума
			
			split_menu.add_item("Уменьшить на 1", 2)
			split_menu.set_item_disabled(2, true) # сразу нельзя уменьшить до нуля
			
			_menu.add_submenu_item("Разделить ", "SplitMenu", -2)
	
	_menu.add_item("Удалить", MENU_ITEMS.DELETE)
	_menu.add_item("Сортировать все", MENU_ITEMS.SORT)
	
	_menu.set_meta("entity", entity) # сохраняем ссылку на сущность
	
	_menu.rect_size = Vector2.ZERO # корректируем размер (Годо без багов не бывает)
	_menu.popup()

func _init_submenu(name: String) -> PopupMenu: # ищем подменю с указанным именем, если такого нет, то создаем
	var submenu = _menu.get_node_or_null(name)
	if submenu:
		submenu.clear()
	else:
		submenu = PopupMenu.new()
		submenu.name = name
		_menu.add_child(submenu)
		submenu.connect("id_pressed", self, "_on_submenu_item_pressed", [submenu])
	return submenu

func _add_submenu_item(submenu: PopupMenu, target: GameEntity):
	var index = submenu.get_item_count()
	submenu.add_item(target.get_text(), index)
	submenu.set_item_metadata(index, target)

func _on_menu_item_pressed(index: int) -> void: # обработка нажатий на пункты контекстного меню
	var entity: GameEntity = _menu.get_meta("entity")
		
	match index:
		MENU_ITEMS.SWITCH:
			if entity.get_attribute(E.ACTIVE):
				E.player.deactivate_entity(entity)
			else:
				E.player.activate_entity(entity)
		
		MENU_ITEMS.DELETE:
			E.player.remove_entity(entity)
		
		MENU_ITEMS.SORT:
			sort_items_by_text()

func _on_submenu_item_pressed(index: int, submenu: PopupMenu):
	var entity: GameEntity = _menu.get_meta("entity")
	var target = submenu.get_item_metadata(index)
	
	match submenu.name:
		"RestoreMenu":
			target.change_attribute(E.HEALTH, entity.get_attribute(E.CHANGE_HEALTH, false))
			entity.change_attribute(E.QUANTITY, -1)
		
		"LoadMenu":
			var capacity = entity.get_attribute(E.CAPACITY) # для случая перезаряжающихся расходников
			var loading = capacity.x if capacity else entity.get_attribute(E.QUANTITY) # у одноразовых расходников берем количество
			var surplus = target.change_attribute(E.CAPACITY, loading)
			entity.set_attribute(E.CAPACITY if capacity else E.QUANTITY, surplus)
		
		"UnloadMenu":
			var surplus := 0
			
			if target.owner:
				var loading = entity.get_attribute(E.CAPACITY).x
				var attribute = E.CAPACITY if target.get_attribute(E.CAPACITY) else E.QUANTITY
				surplus = target.change_attribute(attribute, loading)
			else: # добавляем созданный расходник без объединения с существующими
				E.player.add_entity(target, false, false)
			
			entity.set_attribute(E.CAPACITY, surplus)
		
		"MergeMenu":
			E.player.merge_entity(entity, target)
		
		"SplitMenu":
			var quantity = submenu.get_item_metadata(0)
			
			match index:
				0: # подтверждение количества
					entity.change_attribute(E.QUANTITY, -quantity)
					var new_entity = E.create_entity(entity.get_attribute(E.NAME)) # TODO: сделать полноценное дублирование со свсем возможными нестандартными изменениями сущности
					new_entity.set_attribute(E.QUANTITY, quantity)
					E.player.add_entity(new_entity, false, false) # без автообъединения
					
					_menu.hide()
				1: # +1
					quantity += 1
					submenu.set_item_disabled(2, false) # разблокируем обратное действие
					if quantity > entity.get_attribute(E.QUANTITY) - 2:
						submenu.set_item_disabled(1, true)
				2: # -1
					quantity -= 1
					submenu.set_item_disabled(1, false) # разблокируем обратное действие
					if quantity < 2:
						submenu.set_item_disabled(2, true)
			
			submenu.set_item_text(0, "%s [%d]" % [entity.get_attribute(E.NAME), quantity])
			submenu.set_item_metadata(0, quantity)
