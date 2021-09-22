# Персонаж игрока. Представлен в виде набора сущностей. Каждая сущность состоит из атрибутов (название, здоровье, урон, и т.д.)
# Находясь в одном списке сущности могут влиять друг на друга
# Базовая сущность игрока называется "Игрок", остальные сущности в списке принадлежат игроку, но могут быть использованы по отдельности
# При изменении сущностей генерируется сигнал entities_changed

extends Node

class_name GamePlayer

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
	_player = entities[0]

func change_attribute(entity: Dictionary, key: int, new_value) -> void:
	if entity[key] == new_value: return # не тратим время на то же самое значение аттрибута
	
	match key:
		DB.KEYS.HEALTH:
			var current_value = entity[key]
			
#			if not (new_value is Vector2):
#				new_value = Vector2(new_value, current_value.y)
				
			new_value.x = clamp(new_value.x, 0.0, current_value.y) # усекаем новое значение до интервала от нуля до максимального
			
			if new_value.x == 0.0:
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
