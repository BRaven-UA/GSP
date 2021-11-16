extends GameEvent

var ambush: bool # наличие засады на дороге

func _init() -> void:
	name = "Пустая дорога"
	description = "Ничего необычного, пустая дорога и больше ничего"

func setup():
	ambush = randf() < 0.1
	bonus_info = "Впереди засада!" if ambush else "Все чисто"

func _define_actions():
	_add_action("Пройти по дороге", "_go_along")
	
	var dog = E.player.find_entity(E.NAME, "Собака")
	if dog:
		_add_action("Послать вперед собаку", "_send_scout", [dog])
	
	if E.player.find_entity(E.NAME, "Зоолог", true):
		_add_action("Охотиться", "_hunt")

func _go_along() -> String:
	var result_text := "Пройдя по дороге вы не встретили ничего необычного"
	
	if ambush:
		result_text = "Проходя мимо густых кустарников у края дороги, вы\nуслышали хруст и внезапно обнаружили что из них\nвыскочило несколько оборванцев с холодным оружием.\n"
		
		if randf() < 0.35: # смогли убежать
			var items: = []
			for entity in E.player.get_entities():
				if entity.get_attribute(E.CLASS) == E.CLASSES.ITEM and entity != E.notebook:
					items.append(entity)
			
			if items:
				items.shuffle()
				var lost_item: GameEntity = items[0]
				result_text += "Каким-то чудом вам удалось увернуться от нескольких\nударов и убежать от нападающих. Но, к сожалению, при\nбегстве вы потеряли " + lost_item.get_text()
				
				E.player.remove_entity(lost_item)
		
		else: # получили повреждения
			result_text += "Не успев вовремя сориентироваться, вы пропустили\nнесколько ударов"
			
			var lost_health: int = 10 + randi() % 11
			var result_health = E.player.get_attribute(E.HEALTH).x - lost_health
			
			if result_health < 1:
				result_text += " и упали без сознания, истекая кровью"
			else:
				result_text += ", но смогли устоять на ногах и\nпустились наутек. Вам удалось убежать, но в стычке\n вы потеряли %d здоровья" % lost_health
			
			E.player.set_attribute(E.HEALTH, result_health)
	
	return result_text

func _send_scout(scout: GameEntity) -> String:
	var result_text = "На всякий случай вы посылаете вперед собаку.\n"
	
	if ambush:
		result_text += "Побежав по дороге, вскоре она остановилась и начала\nрычать в сторону группы густых кустарников у края\nдороги. Решив не испытывать судьбу, вы подозвали собаку\nи, сделав большой крюк, обошли подозрительное место"
	else:
		result_text += "Та с радостью помчалась по своим собачьим делам, пугая\nптиц и обнюхивая все что попадалось ей на пути. "
		
		if randf() < 0.1: # собака поймала кролика
			result_text += "Возле\nодного из кустов она на мгновение замерла и тут же\nрванула в сторону, преследуя что-то маленькое и быстрое.\nКак оказалось это был кролик. И для него это был\nне лучший день ..."
			E.player.add_entity(E.create_entity("Мясо"))
		else:
			result_text += "В итоге\nничего интересного ни она, ни вы так и не обнаружили"
	
	return result_text

func _hunt():
	var result_text := "Пользуясь своими познаниями в зоологии, вы сооружаете\nнесколько ловушек из подручных материалов.\n"
	
	var result = randi() % 4
	if result:
		E.player.add_entity(E.create_entity("Мясо", {E.QUANTITY:result}))
		result_text += "Полученные знания принесли пользу: "
		if result > 1:
			result_text += "несколько зайцев\nпопало в ваши ловушки"
		else:
			result_text += "заяц попал в\nодну из ваших ловушек"
	else:
		result_text += "К сожалению, в этот раз охота не удалась"
	
	return result_text




