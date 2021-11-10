extends GameEvent

var dog: GameEntity

func _init() -> void:
	name = "Бродячая собака"
	description = "Бездомная собака. Не проявляет агрессии и выглядит голодной"
	probability = 0.33

func setup():
	dog = E.create_entity("Собака", {E.HEALTH:Vector2(10 + randi() % 11, 30)}) # голодная собака
	_target_bonus_info(dog)

func _define_actions():
	_add_action("Пройти мимо", "_pass_by")
	_add_hostile_actions(dog)
	
	if Game.has_perk("Зоолог"):
		_add_action("Приручить", "_tame")
	else:
		for entity in E.player.get_entities():
			if entity.get_attribute(E.GROUP, false) == E.GROUPS.FOOD:
				var action_text = "Накормить, используя %s" % entity.get_text()
				_add_action(action_text, "_feed", [entity])

func _pass_by() -> String:
	return "Вы проходите мимо собаки, провожающей вас взглядом"

func _duel(defender: GameEntity, attacker: GameEntity = E.player) -> String: # переопределяем стандартный метод
	var result_text = ._duel(defender,attacker) # вызываем стандартный метод
	
	if dog.get_attribute(E.HEALTH).x < 1: # добавляем лут
		E.player.add_entity(E.create_entity("Мясо", {E.QUANTITY:3})) # мясо мертвой собаки
	return result_text

func _tame():
	E.player.add_entity(dog)
	return "Пользуясь своими познаниями в зоологии вы без труда\nвходите в доверие к животному и подчиняете своей воле"

func _feed(food: GameEntity) -> String:
	var result_text = "Вы решаете что собаку можно попытаться приручить\nи даете ей %s." % food.get_attribute(E.NAME)
	
	var random := randf()
	if random < 0.75: # попытка приручения удалась
		result_text += " Почуствовав запах пищи, собака\nпринялась спешно заглатывать угощение. После чего\nзавиляла хвостом и уткнулась мордой вам в руку,\nдавая понять что вы ей понравились"
		
		dog.change_attribute(E.HEALTH, food.get_attribute(E.CHANGE_HEALTH, false)) # кормим собаку
		food.change_attribute(E.QUANTITY, -1) # минус еда
		E.player.add_entity(dog) # плюс собака
	else: # попытка приручения провалилась
		result_text += " Обнюхав предложенное угощение,\nсобака опустила голову и молча побрела прочь.\nМожет в другой раз повезет больше"
	
	return result_text

