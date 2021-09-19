# Персонаж игрока. Содержит как собственный набор, так и список предметов со своими атрибутами
# При изменении количества предметов (но не их атрибутов) генерируется сигнал

extends Node

class_name GamePlayer

var _attributes := {DB.KEYS.TYPE: DB.TYPES.BIOLOGICAL, DB.KEYS.HEALTH: Vector2(100, 100), DB.KEYS.DAMAGE: 5} # Атрибуты игрока (дополняются в процессе игры)
var _items := [] # Предметы игрока (setget на массивах не работает, поэтому доступ должен быть ТОЛЬКО через соотв. методы)

signal items_changed(items) # Количество предметов изменилось, передаем массив предметов вместе с сигналом


func _enter_tree() -> void:
	Global.player = self

func test_start():
	_items = []
	add_item(DB.create_item("Нож"))
	add_item(DB.create_item("Хлеб"))
	add_item(DB.create_item("Собака"))

func get_source_list() -> Array:
	var source_list := [_attributes]
	source_list.append_array(_items)
	return source_list

func change_attribute(key: int, new_value) -> void:
	if _attributes[key] == new_value:
		return	# не тратим время на то же самое значение аттрибута
	
	match key:
		DB.KEYS.HEALTH:
			new_value = clamp(new_value, 0.0, _attributes[DB.KEYS.HEALTH].y) # усекаем новое значение до интервала от нуля до максимального
			if new_value == 0.0:
				Global.game.game_over()
	
	_attributes[key] = new_value

func add_item(item: Dictionary) -> void:
	if item:
		_items.append(item)
		emit_signal("items_changed", _items)
	else:
		push_warning("Попытка добавить пустой предмет игроку !")
		print_stack()

func remove_item(item: Dictionary) -> void:
	if item:
		_items.erase(item)
		emit_signal("items_changed", _items)
	else:
		push_warning("Попытка удалить пустой предмет у игрока !")
		print_stack()
