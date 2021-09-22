extends GameEvent


func _init() -> void:
	name = "Пустая дорога"
	description = "Ничего необычного, дорога и больше ничего"

func _define_actions():
	actions.append("Пройти по дороге")
	
	for entity in _player_entities:
		if entity[DB.KEYS.NAME] == "Собака":
			actions.append("Послать вперед собаку")
			return
