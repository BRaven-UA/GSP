extends Resource

class_name GameEvent

var name: String
var description: String

var actions: Array

signal event_completed


func updateactions(source_list: Array): # формирует список возможных действий, исходя из атрибутов игрока и его предметов
	actions.clear()
	_define_actions(source_list)

func _define_actions(source_list: Array): # виртуальный метод для переопределения в классах-наследниках
	pass

func apply_action(index: int) -> void: # применить действие с указанным индеком
	print(actions[index])
