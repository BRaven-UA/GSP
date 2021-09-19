extends GameEvent

func _init() -> void:
	name = "Пустая дорога"
	description = "Ничего необычного, дорога и больше ничего"

func _define_actions(source_list: Array):
	actions.append("Пройти по дороге")
	
	for source in source_list:
		if source.get(DB.KEYS.NAME) == "Собака":
			actions.append("Послать вперед собаку")
			return
