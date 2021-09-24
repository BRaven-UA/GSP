extends GameEvent


func _init() -> void:
	name = "Бродячая собака"
	description = "Бездомная собака. Не проявляет агрессии и выглядит голодной"
	entities.append(DB.create_entity("Собака"))

func _define_actions():
	var the_dog = entities[0]
	var action_text = ""
	var result_text = ""
	var changes = []
	
	_add_action("Пройти мимо", "Вы проходите мимо собаки, провожающей вас взглядом")
	
	for entity in _player_entities:
		if DB.KEYS.DAMAGE in entity:
			var attacker = entity if DB.KEYS.HEALTH in entity else _player # если у данной сущности есть собственное здоровье, то она будет принимать участие в поединке вместо игрока. Иначе игрок сам участвует в поединке
			
			var entity_text = "" if entity == _player else ", используя " + entity[DB.KEYS.NAME]
			
			action_text = "Напасть%s (урон %s)" % [entity_text, entity[DB.KEYS.DAMAGE]]
			
			var player_damage = _player[DB.KEYS.DAMAGE]
			var healths = _duel([attacker, the_dog]) # моделируем поединок с собакой
			
			var the_dog_injury = "потеряно %s здоровья" % str(the_dog[DB.KEYS.HEALTH].x - healths[1]) if healths[1] > 0 else "смерть"
			var attacker_injury = "потеряно %s здоровья" % str(attacker[DB.KEYS.HEALTH].x - healths[0]) if healths[0] > 0 else "смерть"
			
			result_text = "Вы напали на бродячую собаку" + entity_text + "\n" + "Результаты поединка:\n- бродячая собака: " + the_dog_injury + "\n- " + attacker[DB.KEYS.NAME] + ": " + attacker_injury
			
#			var health_vec = Vector2(healths[0], attacker[DB.KEYS.HEALTH].y) # переводим в формат (текущее значение, максимальное значение)
			changes = [_get_change(attacker, DB.KEYS.HEALTH, healths[0])]
			
			_add_action(action_text, result_text, changes)
		
		if DB.KEYS.RESTOREHEALTH in entity:
			action_text = "Накормить, используя %s (осталось: %s)" % [entity[DB.KEYS.NAME], entity[DB.KEYS.USES]]
			result_text = "Вы решаете что собаку можно попытаться приручить\nи даете ей %s." % entity[DB.KEYS.NAME]
			
			var random := randf()
			if random < 0.75: # попытка приручения удалась
				result_text += " Почуствовав запах пищи, собака\nпринялась спешно заглатывать угощение. После чего\nзавиляла хвостом и уткнулась мордой вам в руку,\nдавая понять что вы ей понравились"
				changes.append(_get_change(entity, DB.KEYS.USES, entity[DB.KEYS.USES] - 1)) # минус еда
				changes.append(the_dog) # плюс собака
			else: # попытка приручения провалилась
				result_text += " Обнюхав предложенное угощение,\nсобака опустила голову и молча побрела прочь.\nМожет в другой раз повезет больше"
				changes.clear() # ничего не меняется, еда остается у игрока
			
			_add_action(action_text, result_text, changes)
