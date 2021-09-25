# Персонаж игрока. Представлен в виде набора сущностей. Каждая сущность состоит из атрибутов (название, здоровье, урон, и т.д.)
# Находясь в одном списке сущности могут влиять друг на друга
# Базовая сущность игрока называется "Игрок", остальные сущности в списке принадлежат игроку, но могут быть использованы по отдельности
# При изменении сущностей генерируется сигнал entities_changed

extends Node

#class_name GamePlayer

var entities := [] # Сущности игрока (setget на массивах не работает, поэтому доступ должен быть ТОЛЬКО через соотв. методы)
var _player: Dictionary # ссылка на сущность игрока для повышения читабельности кода

signal entities_changed # Количество сущностей изменилось


func _enter_tree() -> void:
	Global.player = self

func test_start():
	entities = []
	add_entity(DB.create_entity("Игрок"))
	add_entity(DB.create_entity("Нож"))
	add_entity(DB.create_entity("Хлеб"))
	add_entity(DB.create_entity("Собака"))
	add_entity(DB.create_entity("Дробовик"))
	var shotgun_ammo = DB.create_entity("Патрон для дробовика")
	add_entity(shotgun_ammo)
	change_attribute(shotgun_ammo, DB.KEYS.USES, 10)
	_player = entities[0]

func change_attribute(entity: Dictionary, key: int, new_value) -> void:
	new_value = DB.fix_value(entity, key, new_value)
	if entity[key] == new_value: return # не тратим время на то же самое значение аттрибута
	
	match key:
		DB.KEYS.HEALTH:
			if new_value.x < 1:
				if entity == _player:
					Global.game.game_over()
				else:
					remove_entity(entity)
		
		DB.KEYS.USES:
			if new_value < 1:
				remove_entity(entity)
	
	entity[key] = new_value # TODO: проверить влияние изменения аттрибутов на удаленных сущностях и при "game over"
	emit_signal("entities_changed", entities)

func add_entity(entity: Dictionary) -> void:
	if entity:
		entities.append(entity)
		emit_signal("entities_changed", entities)
	else:
		push_warning("Попытка добавить пустой предмет игроку !")
		print_stack()

func remove_entity(entity: Dictionary) -> void:
	if entity:
		entities.erase(entity)
		emit_signal("entities_changed", entities)
	else:
		push_warning("Попытка удалить пустой предмет у игрока !")
		print_stack()

#func merge_entities(primary: Dictionary, secondary: Dictionary) -> Dictionary: # возвращает новую сущность, являющуюся слиянием двух других (например, игрок и предмет)
#	var result: Dictionary = primary.duplicate()
#	for key in secondary:
#		if key in [DB.KEYS.HEALTH, DB.KEYS.DAMAGE, DB.KEYS.CAPACITY]:
#			result[key] = secondary[key]
#	return result
