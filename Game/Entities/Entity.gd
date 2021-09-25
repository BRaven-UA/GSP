# Базовый класс для всех игровых сущностей

extends Resource

class_name GameEntity

var name: String
var description: String

var _owner: GameEntity # ссылка на владельца (если есть) данной сущности
var _entities: Array # список собственных сущностей
var _active_entities: Array # список активных сущностей (влияющих на данную сущность)

signal entities_changed # Количество собственных сущностей изменилось
signal delete_request # данная сущность должна быть удалена


func _init(data: Dictionary):
	name = data[Database.KEYS.NAME]
	description = data.get(Database.KEYS.DESCRIPTION, "")

func add_entity(entity: GameEntity):
	_entities.append(entity)
	emit_signal("entities_changed")

func remove_entity(entity: GameEntity):
	_entities.erase(entity)
	emit_signal("entities_changed")

func activate_entity(entity: GameEntity): # делает указаную сущность активной (влияющей на данную сущность)
	if entity in _active_entities:
		push_warning("Сущность [%s] уже была активирована!" % entity.name)
		print_stack()
		return
		
	if entity in _entities:
		_active_entities.append(entity)
	else:
		push_warning("Сущность [%s] не пренадлежит [%s]!" % [entity.name, name])
		print_stack()

func clamp_int(value: int, min_value: int, max_value: int) -> int: # вариант clamp() для целых чисел
	if value > max_value: return max_value
	if value < min_value: return min_value
	return value
