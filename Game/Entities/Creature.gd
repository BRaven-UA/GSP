# класс для представления игровых существ

extends GameEntity

class_name GameCreature

var health: int setget _set_health
var type: int

var _health_data := {Base = 0, Maximum = 0}


func _init(data: Dictionary).(data):
	_health_data.Base = data[Database.KEYS.HEALTH].x
	_health_data.Maximum = data[Database.KEYS.HEALTH].y
	health = _health_data.Base
	
	type = data[Database.KEYS.TYPE]

func _set_health(new_value: int):
	health = clamp_int(new_value, 0, _health_data.Maximum)
	
	if not health:
		emit_signal("delete_request")

func change_health(value: int): # изменить здоровье на указанную величину
	_set_health(health + value)
