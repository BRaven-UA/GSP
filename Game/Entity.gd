# Базовый класс для всех игровых сущностей

extends Resource

class_name GameEntity

var owner: GameEntity # ссылка на владельца (если есть) данной сущности
var _attributes: Dictionary
var _entities: Array # список собственных сущностей
var _active_entities: Array # список активных сущностей (влияющих на данную сущность)

signal entity_changed # Состояние данной сушности изменилось
signal delete_request # данная сущность должна быть удалена


func _init(data: Dictionary):
	_attributes = data

func get_attribute_owner(name: int) -> GameEntity: # возвращает ссылку на владельца атрибута
	var result = null
	
	for entity in _active_entities:
		result = entity.get_attribute_owner(name) # рекурсивный поиск
		if result:
			return result
	
	if _attributes.has(name):
		result = self
	
	return result

func find_entity(name: int, value, active := false) -> GameEntity: # возвращает ссылку на сущность, которой принадлежит атрибут с указанным значением (опционально поиск только по активным сущностям)
	if _attributes.has(name):
		if value == null or _attributes[name] == value: # значение не задано или совпадает со значением атрибута
			return self
	
	var source = _active_entities if active else _entities
	for entity in source:
		var result = entity.find_entity(name, value) # рекурсивный поиск
		if result:
			return result
	
	return null

func get_attribute(name: int, directly := true, default = null): # по умолчанию поиск атрибута с учетом активных сущностей не проводится
	if not directly:
		var _owner = get_attribute_owner(name)
		if _owner:
			return _owner.get_attribute(name, true, default)
	
	return _attributes.get(name, default)

func get_attributes() -> Dictionary:
	return _attributes

func set_attribute(name: int, new_value, directly := true) -> int: # и возвращает лишнее количество 
	var surplus := 0 # лишнее количество
	var to_delete := false # флаг на удаление сущности
	
	if directly: # работаем с атрибутами данной сущности
		var current_value = get_attribute(name)
		if current_value == null:
			return surplus
		var info = get_attribute(E.NAME)
		
		if name in [E.CAPACITY, E.HEALTH]: # значение должно иметь тип Vector2
			if not new_value is Vector2: # обычно передается только текущее значение вместо вектора
				new_value = Vector2(new_value, current_value.y)
			var correct_value = round(clamp(new_value.x, 0.0, new_value.y)) # усекаем значение до интервала от нуля до максимального и округляем чтобы гарантировать срабатывание условий типа if value.x:
			surplus = new_value.x - correct_value
			new_value.x = correct_value
		
		match name:
			E.CAPACITY:
				info += ": потрачено " if new_value.x < current_value.x else ": получено "
				info += str(abs(new_value.x - current_value.x)) + " зарядов"
				if new_value.x < 1: # кончились заряды
					owner.deactivate_entity(self)
					if _attributes.has(E.ACTIVE):
						info += " (деактивировано)"
					Logger.debug("Кончились заряды у {%s}" % get_text())
				Logger.info(info)
			
			E.HEALTH:
				var log_category = Logger.INGAME_DAMAGE
				if new_value.x < current_value.x:
					info += ": потеряно "
				else:
					log_category = Logger.INGAME_HEAL
					info += ": восстановлено "
				info += str(abs(new_value.x - current_value.x)) + " здоровья"
				if new_value.x < 1:
					surplus = -1 # условный признак смерти
					info += " (смерть)"
					to_delete = true
				Logger.info(info, log_category)
			
			E.QUANTITY:
				if new_value < 1:
					to_delete = true
		
		_attributes[name] = new_value
		Logger.debug("Изменение атрибута %s с %s на %s в { %s }" % [name, current_value, new_value, get_text()])
		if to_delete:
			emit_signal("delete_request")
#		else:
#			emit_signal("entity_changed")
		emit_signal("entity_changed")
		
	else: # передаем управление на другую сущность
		var _owner = get_attribute_owner(name)
		surplus = _owner.set_attribute(name, new_value)
	
	return surplus

func change_attribute(name: int, value = -1, directly := true) -> int:
	var current_value = get_attribute(name, directly, null)
	
	if current_value == null:
		return 0
	
	if current_value is Vector2 and not value is Vector2: # корректируем для значений типа Vector2
		value = Vector2(value, 0)
	
	if current_value is bool:
		set_attribute(name, not current_value, directly)
		return 0
	
	var surplus = set_attribute(name, current_value + value, directly)
	return surplus

func add_entity(entity: GameEntity, activate := false, merge := true, silent := false): # добавляет сущность к собственным, опционально активирует ее, опционально объединяет с подобными
	Logger.debug("{%s} добавлено в {%s}" % [entity.get_text(), get_text()])
	
	if self == E.player:
		Logger.info("Добавлено: " + entity.get_text(), Logger.INGAME_TAKE)
		
		if entity.get_attribute(E.GROUP) == E.GROUPS.NOTES:
			E.notebook.add_entity(entity) # записки сразу добавляем в записную книжку
			E.emit_signal("notebook_updated", entity)
			Logger.tip(Logger.TIP_NOTE)
			return
		
		if entity.get_attribute(E.KNOWLEDGE):
			Logger.tip(Logger.TIP_STUDY)
	
	var merged = merge_entity(entity) if merge else null # объединение сущностей (если нужно)
	if merged:
		entity = merged # заменяем исходную сущность на итоговую
	else:
		_entities.append(entity)
		entity.owner = self
	
	if activate:
		activate_entity(entity)
	
	if not silent: # "тихое" добавление используется при пакетном добавлении чтобы не "флудить" сигналом
		emit_signal("entity_changed")

func add_entities(entities: Array, activate := false, merge := true):
	for entity in entities:
		add_entity(entity, activate, merge, true) # используем "тихое" добавление
	emit_signal("entity_changed")

func merge_entity(entity: GameEntity, target: GameEntity = null) -> GameEntity: # Объединяет сущности, возвращает ссылку на итоговую сущность
	if not target:
		target = find_entity(E.NAME, entity.get_attribute(E.NAME))
	var quantity = entity.get_attribute(E.QUANTITY)
	
	if target and quantity:
		target.change_attribute(E.QUANTITY, quantity)
		entity.set_attribute(E.QUANTITY, 0)
		return target
	
	return null

func remove_entity(entity: GameEntity, silent := false):
	_entities.erase(entity)
	_active_entities.erase(entity)
	entity.owner = null
	
	if self == E.player:
		Logger.info("Удалено: " + entity.get_text(), Logger.INGAME_LOSS)
	Logger.debug("{%s} удалено из {%s}" % [entity.get_text(), get_text()])
	
	if not silent: # "тихое" удаление используется при пакетном удалении чтобы не "флудить" сигналом
		emit_signal("entity_changed")

func remove_entities(entities: Array):
	for entity in entities:
		remove_entity(entity, true) # используем "тихое" удаление
	emit_signal("entity_changed")

func activate_entity(entity: GameEntity): # делает указаную сущность активной (влияющей на данную сущность)
	if entity in _active_entities:
		return
	if entity.owner == self:
		_active_entities.push_front(entity)
		entity.set_attribute(E.ACTIVE, true)
	else:
		push_warning("Сущность [%s] не пренадлежит [%s]!" % [entity.get_attribute(E.NAME), get_attribute(E.NAME)])
		print_stack()

func deactivate_entity(entity: GameEntity):
#	if entity in _active_entities: # защита от бесконечной деактивации
	_active_entities.erase(entity)
	entity.set_attribute(E.ACTIVE, false)

func get_entities(include_self := false, active := false) -> Array:
	var entities = _active_entities if active else _entities
	
	if include_self:
		var result = [self]
		result.append_array(entities)
		return result
	else:
		return entities

func get_text() -> String: # возвращает сокращенное текстовое представление сущности
	var text: String = get_attribute(E.NAME)
	
	var health = get_attribute(E.HEALTH)
	if health: # здоровье (тек./макс.)
		text += " (%d/%d)" % [health.x, health.y]
	
	var capacity = get_attribute(E.CAPACITY)
	if capacity: # заряды [тек./макс.]
		text += " [%d/%d]" % [capacity.x, capacity.y]
	
	var quantity = get_attribute(E.QUANTITY)
	if quantity: # [кол. использований]
		text += " [%d]" % quantity
	
	var knowledge = get_attribute(E.KNOWLEDGE)
	if knowledge: # прогресс изучения (тек./макс.)
		var progress = E.get_study_progress(knowledge)
		text += " (%d/%d)" % [progress, E.MAX_STUDY] if progress < E.MAX_STUDY else " (изучено)"
	
	return text

func get_full_info(indent := "") -> String: # полное описание сущности с учетом активных сущностей
	var result := ""
	
	for key in _attributes.keys():
		var value = _attributes[key]
		match key:
			E.TYPE:
				value = E.TYPES.keys()[value]
			E.GROUP:
				value = E.GROUPS.keys()[value]
			E.CLASS:
				value = E.CLASSES.keys()[value]
		
		result += "%s%s: %s\n" % [indent, E.ATTRIBUTES[key], value]
	
	for entity in _active_entities:
		result += entity.get_full_info("%s %s " % [indent, char(9492)])
	
	return result

func get_cost() -> int: # расчет суммаронй стоимости
	var result: int = _attributes.get(E.COST, 0)
	
	if result: # без атрибута стоимости сущность не продается
		result += int(_attributes.get(E.HEALTH, Vector2.ZERO).x) # +1 за каждую единицу текущего здоровья
		
		var capacity = _attributes.get(E.CAPACITY)
		if capacity: # прибавляем стоимость расходников
			var cost := 2 # предполагаем что расходники виртуальные (не имеют собственной сущности)
			
			var consumables = _attributes.get(E.CONSUMABLES)
			if consumables: # расходники не виртуальные
				var data = E.get_base_entity(consumables)
				cost = data[E.COST] if data.has(E.QUANTITY) else 2 # для виртуальных расходников берем стоимость 2 ед.
			
			result += int(cost * capacity.x) # общая стоимость расходников
		
#		for entity in _entities:
#			result += entity.get_cost()
		
		result *= _attributes.get(E.QUANTITY, 1)
	
	return result
