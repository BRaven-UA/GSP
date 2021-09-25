# класс для представления способностей

extends GameEntity

class_name GameAbility

var change_health: int


func _init(data: Dictionary).(data):
	change_health = data[Database.KEYS.CHANGE_HEALTH]
