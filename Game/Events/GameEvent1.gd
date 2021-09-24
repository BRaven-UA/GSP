extends GameEvent


func _init() -> void:
	name = "Пустая дорога"
	description = "Ничего необычного, пустая дорога и больше ничего"

func _define_actions():
	var random := randf()
	var ambush: bool = random < 0.1 # вероятность засады на дороге
	
	var result_text := "Пройдя по дороге вы не встретили ничего необычного"
	var changes := []
	if ambush:
		result_text = "Проходя мимо густых кустарников у края дороги, вы\nуслышали хруст и внезапно обнаружили что из них\nвыскочило несколько оборванцев с холодным оружием.\n"
		
		if random < 0.035 and _player_entities.size() > 1: # потеряли предмет
			var lost_entity: Dictionary = _player_entities[1 + randi() % (_player_entities.size() - 1)]
			result_text += "Каким-то чудом вам удалось увернуться от нескольких\nударов и убежать от нападающих. Но, к сожалению, при\nбегстве вы потеряли " + lost_entity[DB.KEYS.NAME]
			
			changes.append(_get_change(lost_entity, DB.KEYS.USES, 0))
		
		else: # получили повреждения
			result_text += "Не успев вовремя сориентироваться, вы пропустили\nнесколько ударов"
			
			var lost_health: int = 10 + randi() % 11
			var result_health = _player[DB.KEYS.HEALTH].x - lost_health
			
			if result_health < 1:
				result_text += " и упали без сознания, истекая кровью"
			else:
				result_text += ", но смогли устоять на ногах и\nпустились наутек. Вам удалось убежать, но в стычке\n вы потеряли %s здоровья" % str(lost_health)
			
			changes.append(_get_change(_player, DB.KEYS.HEALTH, result_health))
	
	_add_action("Пройти по дороге", result_text, changes)
	
	for entity in _player_entities:
		if entity[DB.KEYS.NAME] == "Собака":
			result_text = "На всякий случай вы посылаете вперед собаку.\n"
			if ambush:
				result_text += "Побежав по дороге, вскоре она остановилась и начала\nрычать в сторону группы густых кустарников у края\nдороги. Решив не испытывать судьбу, вы подозвали собаку\nи, сделав большой крюк, обошли подозрительное место"
			else:
				result_text += "Та с радостью помчалась по своим собачьим делам, пугая\nптиц и обнюхивая все что попадалось ей на пути. В итоге\nничего интересного ни она, ни вы так и не обнаружили"
			
			_add_action("Послать вперед собаку", result_text)
