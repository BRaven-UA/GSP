extends GameEvent


func _init() -> void:
	name = "Бродячая собака"
	description = "Бездомная собака. Не проявляет агрессии и выглядит голодной"

func _define_actions(source_list: Array):
	actions.append("Пройти мимо")
	
	for source in source_list:
		if source.get(DB.KEYS.DAMAGE):
			var item_text = (", используя " + source.get(DB.KEYS.NAME)) if source.get(DB.KEYS.NAME) else ""
			actions.append("Напасть%s (урон %s)" % [item_text, source[DB.KEYS.DAMAGE]])
		if source.get(DB.KEYS.RESTOREHEALTH):
			actions.append("Накормить, используя %s (осталось: %s)" % [source[DB.KEYS.NAME], source[DB.KEYS.USES]])
