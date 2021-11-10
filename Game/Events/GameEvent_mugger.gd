extends GameEvent

var mugger: GameEntity

func _init() -> void:
	name = "Грабитель"
	description = "Этот тип собирается забрать ваше имущество, не считаясь с вашим мнением"
	new_character_data = {"Text":"А этот тип оказался не из пугливых, не захотел\nдобровольно расставаться со своим барахлом.\nПришлось с ним повозиться", "Heir":mugger, "Remains":[E.REMAINS.NO_PETS]}

func setup():
	mugger = E.create_person([{"Нож":1}, {"Топор":0.75}, {"Пистолет":0.5}, {"Охотничья винтовка":0.25}])
	_target_bonus_info(mugger)

func _define_actions():
	_add_hostile_actions(mugger)
	_add_action("Не сопротивляться", "_dont_resist")
	_add_action("Попытаться убежать", "_escape")

func _duel(defender: GameEntity, attacker: GameEntity = E.player) -> String:
	var result_text := "Вы решили, что лучшая защита - это нападение и\n"
	result_text += "сами напали на мерзавца.\n" if attacker == E.player else "натравили %s на мерзавца, в надежде выиграть\nвремя для бегства.\n" % attacker.get_attribute(E.NAME)
	result_text += ._duel(defender, attacker)
	
	if mugger.get_attribute(E.HEALTH).x < 1: # грабитель убит
		var possible_loot := [{"Хлеб":1}, {"Хлеб":1}, {"Динамит":0.1}, {"Тушенка":0.75}]
		var loot = E.create_entity(E.randw(possible_loot))
		
		mugger.remove_entity(mugger.find_entity(E.NAME, "Удар"))
		E.player.add_entities(mugger.get_entities())
		E.player.add_entity(loot)
		mugger = null
		
		result_text += "Это было его последнее ограбление. Вы обыскиваете\nтело и забираете скудные пожитки."
		
	elif attacker != E.player: # грабитель победил, сражался не игрок
		result_text += "Когда все закончилось вы были уже далеко."
	
	return result_text

func _dont_resist(): # позволить себя ограбить
	return "Вы покорно отдали все свои вещи, а заодно выслушали\nмножество унижений в свой адрес." + _loss_items()

func _loss_items() -> String:
	var items := []
	for entity in E.player.get_entities():
		if entity.get_attribute(E.CLASS) == E.CLASSES.ITEM and entity != E.notebook: # забирает только предметы, кроме записной книжки
			items.append(entity)
	
	E.player.remove_entities(items) # для "тихого" удаления
	
	return "\nДальнейшее путешествие вы продолжаете налегке."

func _escape() -> String:
	var result_text := "Не придумав ничего лучше, вы пустились наутек.\n"
	
	if randf() < 0.25: # смогли убежать
		result_text += "Грабитель оказался не настолько быстрым чтобы догнать вас.\n"
		
		for entity in mugger.get_entities(false, true): # список активных сущностей
			var weapon_name = entity.get_attribute(E.NAME)
			if weapon_name in ["Дробовик", "Пистолет", "Охотничья винтовка", "Автоматическая винтовка"]:
				var damage = entity.get_attribute(E.CHANGE_HEALTH, false)
				result_text += "А вот пуле это не составило труда. Выстрел из %s\nнанес вам %d урона.\n" % [weapon_name, damage]
				E.player.change_attribute(E.HEALTH, damage)
		
		if randf() < 0.5: # потеряли предмет
			var items: = []
			for entity in E.player.get_entities():
				if entity.get_attribute(E.CLASS) == E.CLASSES.ITEM:
					items.append(entity)
			
			if items:
				var lost_item: GameEntity = items[1 + randi() % (items.size() - 1)]
				result_text += "При бегстве вы потеряли %s." % lost_item.get_text()
				E.player.remove_entity(lost_item)
	
	else: # грабитель вас догнал, избил и ограбил
		result_text += "Идея была так себе. Мерзавец все равно вас догнал\n"
		
		var health = E.player.get_attribute(E.HEALTH)
		var min_health = min(5, health.x)
		var max_health = health.x * 0.75
		
		if min_health < max_health:
			var new_health = rand_range(min_health, max_health)
			E.player.set_attribute(E.HEALTH, new_health)
			result_text += ", избил (-%d здоровья)" % (health.x - new_health)
		
		result_text += " и отобрал все ценное." + _loss_items()
	
	return result_text


"""" 
- ?? убедить / запугать

"""
