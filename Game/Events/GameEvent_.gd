extends GameEvent

var entity: GameEntity

func _init() -> void:
	name = ""
	description = ""
	probability = 1.0

func is_available() -> bool:
	return E.player.find_entity(E.NAME, "", true) != null

func setup():
	entity = E.create_entity("Человек")
	_target_bonus_info(entity)

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



"""" 



"""
