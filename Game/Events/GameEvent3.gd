extends GameEvent


func _init() -> void:
	name = "Заброшенный дом"
	description = "Двухэтажный жилой дом выглядит заброшенным: газон давно не стригли, где-то выбито оконное стекло, входная дверь слегка приоткрыта"

func _define_actions():
	var action_text = ""
	var result_text = ""
	var changes = []
	
	action_text = "Обыскать дом"
