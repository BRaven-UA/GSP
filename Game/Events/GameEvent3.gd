extends GameEvent

var occupant: GameEntity # жилец
var aggressive: bool # жилец агрессивный

func _init() -> void:
	name = "Заброшенный дом"
	description = "Двухэтажный жилой дом выглядит заброшенным: газон давно не стригли, где-то выбито оконное стекло, входная дверь слегка приоткрыта"
	probability = 0.33

func _define_actions():
	if randf() < 0.5: # создаем жильца и даем ему оружие
		aggressive = randf() < 0.5
		
		var health = round(1.0 + randf() * 99.0) # здоровье от 1 до 100
		occupant = E.create_entity("Человек", {E.HEALTH:Vector2(health, 100)})
		
		var weapon = E.randw([{"Ничего":1}, {"Нож":0.6}, {"Топор":0.3}, {"Охотничья винтовка":0.4}]) # возможное оружие жильца и шансы его выпадения (65%? 20%, 6%, 10%)
		
		if weapon != "Ничего": # чаще всего жилец будет безоружен
			var custom_attribute: Dictionary
			
			if weapon == "Охотничья винтовка":
				custom_attribute = {E.CAPACITY:Vector2(2, 2)} # винтовка будет заряжена
				occupant.add_entity(E.create_entity("Патрон 7.62 мм", {E.QUANTITY:10})) # дополнительные патроны
			
			occupant.add_entity(E.create_entity(weapon, custom_attribute), true)
	
	_add_action("Пройти мимо", "_pass_by")
	
	_add_hostile_actions(occupant, "Проверить")

func _pass_by() -> String:
	var result_text := "Вы решили что заходить внутрь слишком рисковано и\nпрошли мимо дома"
	
	if occupant:
		if aggressive and occupant.find_entity(E.NAME, "Охотничья винтовка"):
			return result_text + ". Однако не успели далеко отойти\nкак раздался выстрел и вас пронзила жгучая боль.\nСтреляли из окна дома. К счастью, стрелок был не очень\nметким, и вы легко отделались. Не став дожидаться\nвторого выстрела, вы бегом покинули место нападения"
	
	return result_text 

func _duel(defender: GameEntity, actor: GameEntity = E.player) -> String:
	var result_text := "В поисках чего-нибудь полезного вы "
	result_text += "вошли в дом." if actor == E.player else "послали\nв дом %s." % actor.get_attribute(E.NAME)
	
	var loot := []
	var possible_loot := [{"Хлеб":1}, {"Тушенка":0.9}, {"Нож":0.8}, {"Топор":0.5}, {"Бензопила":0.3}, {"Радиоприемник":0.5}, {"Аккумулятор":0.5}]
	var quantity = 1 + randi() % 3
	for i in quantity: # от 1 до 3 предметов
		var item_name = E.randw(possible_loot)
		loot.append(E.create_entity(item_name))
	
	if defender:
		result_text += "\nКак оказалось в доме кто-то жил. "
		if aggressive:
			result_text += "И ему явно\nне понравились непрошенные гости.\n"
			result_text += ._duel(defender, actor)
			
			if defender.get_attribute(E.HEALTH).x < 1: # жилец мертв
				result_text += "\nХозяин больше не помеха и вы забираете себе его вещи,\nа также несколько полезных вещей из дома."
				
				defender.remove_entity(defender.find_entity(E.NAME, "Удар"))
				E.player.add_entities(defender.get_entities())
				E.player.add_entities(loot)
				
				occupant = null
			else:
				if actor != E.player:
					result_text += "\nА ведь на месте собаки могли быть вы. Чтобы этого\nизбежать вы спешно удаляетесь от дома"
		else:
			result_text += "Хозяин не был расположен\nк приему гостей и попросил вас покинуть дом"
	else:
		result_text += "\nДом и правда был брошен хозяевами и вам удалось\nнайти в нем несколько полезных вещей"
		E.player.add_entities(loot)
	
	return result_text 
