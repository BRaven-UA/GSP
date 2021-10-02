# Базовый класс для всех игровых сущностей

extends Resource

class_name GameEntity

var owner: GameEntity # ссылка на владельца (если есть) данной сущности
var _attributes: Dictionary
var _entities: Array # список собственных сущностей
var _active_entities: Array # список активных сущностей (влияющих на данную сущность)

signal entities_changed # Количество собственных сущностей изменилось
signal delete_request # данная сущность должна быть удалена


func _init(data: Dictionary):
	_attributes = data

func get_attribute_owner(name: int) -> GameEntity: # возвращает ссылку на владельца атрибута
#	if name in [E.CAPACITY, E.CHANGE_HEALTH, E.CONSUMABLES, E.HEALTH, E.QUANTITY, E.TYPE]: # для этих атрибутов значение берется прежде всего из активных сущностей
	var result = null
	
	for entity in _active_entities:
		result = entity.get_attribute_owner(name) # рекурсивный поиск
		if result:
			return result
	
	if _attributes.has(name):
		result = self
	
	return result

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
		if not current_value:
			return surplus
		var info = get_attribute(E.NAME)
		
		if name in [E.CAPACITY, E.HEALTH]: # значение должно иметь тип Vector2
			if not new_value is Vector2: # обычно передается только текущее значение вместо вектора
				new_value = Vector2(new_value, current_value.y)
			var correct_value = round(clamp(new_value.x, 0.0, new_value.y)) # усекаем значение до интервала от нуля до максимального и округляем чтобы гарантировать срабатывание условий типа if value.x:
			surplus = new_value.x - correct_value
			new_value.x = correct_value
		
		if name == E.CAPACITY:
			if new_value.x < 1: # кончились заряды
				owner.deactivate_entity(self)
				Logger.debug("Кончились заряды у {%s}" % get_text())
		
		if name == E.HEALTH:
			info += ": потеряно " if new_value.x < current_value.x else ": восстановлено "
			info += str(abs(new_value.x - current_value.x)) + " здоровья"
			if new_value.x < 1:
				surplus = -1 # условный признак смерти
				info += " (смерть)"
				to_delete = true
			Logger.info(info)
		
		if name == E.QUANTITY:
			if new_value < 1:
				to_delete = true
		
		_attributes[name] = new_value
		Logger.debug("Изменение атрибута %s с %s на %s в { %s }" % [name, current_value, new_value, get_text()])
		if to_delete:
			emit_signal("delete_request")
		else:
			emit_signal("entities_changed", _entities)
		
	else: # передаем управление на другую сущность
		var _owner = get_attribute_owner(name)
		surplus = _owner.set_attribute(name, new_value)
	
	return surplus

func change_attribute(name: int, value, directly := true) -> int:
	var current_value = get_attribute(name, directly)
	if not current_value:
		return 0
	if current_value is Vector2 and not value is Vector2: # корректируем для значений типа Vector2
		value = Vector2(value, 0)
	
	var surplus = set_attribute(name, current_value + value, directly)
	return surplus

func add_entity(entity: GameEntity, activate := false):
	_entities.append(entity)
	entity.owner = self
	
	if self == E.player:
		Logger.info("Добавлено: " + entity.get_text())
	Logger.debug("{%s} добавлено в {%s}" % [entity.get_text(), get_text()])
	
	if activate:
		activate_entity(entity)
	
	emit_signal("entities_changed", _entities)

func remove_entity(entity: GameEntity):
	_entities.erase(entity)
	_active_entities.erase(entity)
	entity.owner = null
	
	if self == E.player:
		Logger.info("Удалено: " + entity.get_text())
	Logger.debug("{%s} удалено из {%s}" % [entity.get_text(), get_text()])
	
	emit_signal("entities_changed", _entities)

func activate_entity(entity: GameEntity): # делает указаную сущность активной (влияющей на данную сущность)
	if entity in _active_entities:
		return
	if entity.owner == self:
		_active_entities.push_front(entity)
	else:
		push_warning("Сущность [%s] не пренадлежит [%s]!" % [entity.get_attribute(E.NAME), get_attribute(E.NAME)])
		print_stack()

func deactivate_entity(entity: GameEntity):
	_active_entities.erase(entity)

func get_entities(include_self := false) -> Array:
	if include_self:
		var result = [self]
		result.append_array(_entities)
		return result
	else:
		return _entities

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
	
	return text
