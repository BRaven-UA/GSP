# класс для представления игровых предметов

extends GameEntity

class_name GameItem

var quantity: int setget _set_quantity
var capacity: int setget _set_capacity

var _capacity_data := {Base = 0, Maximum = 0}

func _init(data: Dictionary).(data):
	quantity = data[Database.KEYS.QUANTITY]
	
	_capacity_data.Base = data[Database.KEYS.CAPACITY].x
	_capacity_data.Maximum = data[Database.KEYS.CAPACITY].y
	capacity = _capacity_data.Base

func _set_quantity(new_value):
	quantity = new_value
	
	if quantity < 1:
		emit_signal("delete_request")

func _set_capacity(new_value) -> int: # возвращает неиспользованный остаток
	capacity = clamp_int(new_value, 0, _capacity_data.Maximum)
	return new_value - capacity

func change_quantity(value: int = -1): # изменить количество на указанную величину (по умолчанию уменьшить на единицу)
	_set_quantity(quantity + value)

func change_capacity(value) -> int: # изменить вместимость на указанную величину, возвращает неиспользованный остаток
	return _set_capacity(capacity + value)
