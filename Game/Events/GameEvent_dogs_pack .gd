extends GameEvent

var pack_leader: GameEntity

func _init() -> void:
	name = "Свора собак"
	description = "Агрессивная свора собак во главе с матерым вожаком"
	probability = 0.5

func setup():
	var pack_leader_data = E.get_base_entity("Собака")
	pack_leader_data[E.HEALTH] *= Vector2(1.5, 1.5) # здоровее на 50%
	pack_leader = E.create_entity(pack_leader_data)
	pack_leader.change_attribute(E.CHANGE_HEALTH, -5, false) # сильнее на 50%
	
	_target_bonus_info(pack_leader)

func _define_actions():
	_add_hostile_actions(pack_leader, "Атаковать вожака")
	
	if Game.has_perk("Зоолог"):
		_add_action("Показать силу", "_dominate")
	
	for entity in E.player.get_entities():
		var consumables = entity.get_attribute(E.CONSUMABLES, true, "")
		if consumables.begins_with("Патрон") and entity.get_attribute(E.CAPACITY, true, Vector2.ZERO).x:
			_add_action("Выстрелить в воздух из %s" % entity.get_text(), "_air_shot", [entity])
		
		if entity.get_attribute(E.GROUP) == E.GROUPS.FOOD:
			_add_action("Бросить им %s [1]" % entity.get_attribute(E.NAME), "_escape", [entity])
		
		if entity.get_attribute(E.NAME) == "Динамит":
			_add_action("Бросить в них динамит [1]", "_blow_up", [entity])

func _duel(defender: GameEntity, attacker: GameEntity = E.player) -> String:
	var result_text := "Зная, что свора идет за вожаком, вы решили разделаться\nс ним, показывая остальным что с вами лучше не связываться.\n"
	
	result_text += ._duel(defender, attacker)
	
	if pack_leader.get_attribute(E.HEALTH).x < 1:
		E.player.add_entity(E.create_entity("Мясо", {E.QUANTITY:4}))
		pack_leader = null
		result_text += "Вожак убит, и свора разбегается кто куда."
	
	return result_text

func _dominate():
	return "Пользуясь своими познаниями в зоологии вы даете\nпонять вожаку своры что готовы бросить ему вызов.\nВожак какое-то время демонстрирует агрессивное\nповедение, но решив что с вами лучше не связываться,\nразворачивается и уводит свору прочь"

func _air_shot(entity: GameEntity):
	entity.change_attribute(E.CAPACITY)
	return "Вы делаете выстрел в воздух, от которого вся свора\nбросается в рассыпную, а вы продолжаете свой путь."

func _escape(entity: GameEntity):
	entity.change_attribute(E.QUANTITY)
	return "Вы отвлекаете свору едой, а сами тем временем спешно\nпокидаете это место."

func _blow_up(entity: GameEntity):
	entity.change_attribute(E.QUANTITY)
	var dogs_in_pack = 4 + randi() % 4 # количество собак в своре от 4 до 7
	E.player.add_entity(E.create_entity("Мясо", {E.QUANTITY:dogs_in_pack * 3 + 1})) # по 3 куска на собаку +1 с вожака
	return "Вы поджигаете фитиль, бросаете динамит в свору и\nпадаете на землю, закрыв руками уши. Оглушительный\nвзрыв разбросал ошметки собак по округе, а ваши запасы\nпродовольствия значительно пополнились."


"""" 
	- ?? приручить вожака
"""
