extends GameEvent

var entity: GameEntity

func _init() -> void:
	name = ""
	description = ""
	probability = 1.0
	distance = 5 + randi() % 76 # от 5% до 80%
	new_character_data = {"Text":"", "Heir":null, "Remains":[E.REMAINS.NO_PETS]}

func is_available() -> bool:
	return E.player.find_entity(E.NAME, "", true) != null

func get_tracking_text(delta: int) -> String:
	if not E.player.find_entity(E.NAME, "Текст радиосигнала"): # координаты пропали
		EventManager.untrack_event(self) # прекращаем отслеживание
		return ""
	
	var text := "Подземный бункер: "
	var result_distance = distance + delta
	
	if result_distance < 10:
		text += "где-то рядом"
	else:
		text += "расстояние %d" % result_distance
	
	return text

func setup():
	bonus_info = ""
	entity = E.create_person([{"Нож":1}, {"Топор":0.75}, {"Пистолет":0.5}, {"Охотничья винтовка":0.25}])
	_target_bonus_info(entity)
	new_character_data.Heir = entity

func _define_actions():
	_add_hostile_actions(entity)

func _duel(defender: GameEntity, attacker: GameEntity = E.player) -> String:
	var loot := []
	var possible_loot := [{"":1}, {"":1}, {"":1}, {"":1}, {"":1}]
	var quantity = 1 + randi() % 3
	for i in quantity: # от 1 до 3 предметов
		var item_name = E.randw(possible_loot)
		loot.append(E.create_entity(item_name))
	
	var result_text = ._duel(defender, attacker)
	
	if defender.get_attribute(E.HEALTH).x < 1:
		defender.remove_entity(defender.find_entity(E.NAME, "Удар"))
		E.player.add_entities(defender.get_entities())
		E.player.add_entities(loot)
		entity = null
	
	return result_text



""" 



- настроить повторяемость события
"""
