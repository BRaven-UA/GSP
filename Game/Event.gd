# Базовый класс для событий в игре. Классы-наследники сохраняются в отдельных файлах и переопределяют виртуальные методы или добавляют новые методы, в которых реализуют свою уникальную логику

extends Resource

class_name GameEvent

var name: String # заголовок события
var description: String # описание события до того как игрок получит перечень возможных действий
var bonus_info: String # дополнительная информация, доступная только с перком "Зоркость"
var probability := 1.0 # вероятность появления события в списке доступных (может быть больше 1, если событие важное)
var distance := 0 # расстояние до игрока в процентах (0 - 100)
var new_character_data: Dictionary # можно задать данные о новом персонаже, если событие приведет к смерти текущего
var actions: Array # список действий для данного события
var _action_exp := {} # количество опыта по завершению события (для разных действий отельно)

func is_available() -> bool: # если событие содержит условия возникновения, переопределить этот виртуальный метод и вернуть булево значение выполнены требования или нет
	return true

func get_tracking_text(delta: int) -> String: # если событие можно отслеживать, переопределить этот виртуальный метод и вернуть текст для отображения игроку
	return ""

func _default_tracking_text(delta: int) -> String:
	var text := "%s: " % name
	var result_distance = distance + delta
	
	if result_distance < 10:
		text += "где-то рядом"
	else:
		text += "расстояние %d" % result_distance
	
	return text

func setup(): # первичная настройка события при выборе его игроком из списка доступных событий (виртуальный метод для переопределения в классах-наследниках)
	pass

func reset_exp():
	_action_exp.clear()

func update_actions(): # формирует список возможных действий, исходя из атрибутов игрока и его предметов
	actions.clear()
	_define_actions()

func _define_actions(): # сформировать список возможных действий (виртуальный метод для переопределения в классах-наследниках)
	pass

func _add_action(action_text: String, method: String, arguments := [], activate_entity: GameEntity = null): # добавление нового действия в список
	var new_action = {Text = action_text, Method = method, Arguments = arguments, Entity = activate_entity}
	actions.append(new_action)

func apply_action(index: int) -> void: # применить указанное действие
	var action = actions[index]
	
	var entity = action.Entity
	if entity:
		E.player.activate_entity(entity)
	var result_text = callv(action.Method, action.Arguments)
	if entity:
		E.player.deactivate_entity(entity)
	
	var has_perk = E.player.find_entity(E.NAME, "Вундеркинд", true)
	var exp_gain: int = _action_exp.get(action.Method, 13 if has_perk else 10)
# warning-ignore:integer_division
	_action_exp[action.Method] = int((exp_gain + 3) / 2.1) if has_perk else (exp_gain + 1) / 2 # последующие действия данного события будут приносить все меньше опыта (но не меньше 1)
	Game.increase_exp(exp_gain)
	
	GUI.show_accept_dialog(result_text)

func _target_bonus_info(target: GameEntity): # формирует бонусную информацию о заданной цели
	for entity in target.get_entities(false, true): # активные сущности
		var change_health = entity.get_attribute(E.CHANGE_HEALTH, false, 0)
		if change_health < 0:
			if bonus_info:
				bonus_info += "\n"
			bonus_info += "%s, оружие: %s (урон %d)" % [target.get_text(), entity.get_text(), -change_health]
			return

func _add_hostile_actions(target: GameEntity, text := "Напасть"): # стандартная наборка из всех возможных вариантов нападения на цель
	for entity in E.player.get_entities():
		var change_health = entity.get_attribute(E.CHANGE_HEALTH, false, 0)
		if change_health < 0: # отнимает здоровье
			var charges = entity.get_attribute(E.CAPACITY, true, Vector2(1, 1)) # один заряд для проверки на заряды
			if charges.x: # есть заряды
				var entity_text = ", используя " + entity.get_text()
				var action_text = "%s%s (урон %d)" % [text, entity_text, abs(change_health)]
				var attacker = entity if entity.get_attribute(E.HEALTH) else E.player
				
				var unique_action := true # проверяем на дублирование
				for action in actions:
					if action.Text == action_text:
						unique_action = false
						break
				if unique_action:
					_add_action(action_text, "_duel", [target, attacker], entity if entity.get_attribute(E.CLASS) != E.CLASSES.ABILITY else null)
				
				Logger.tip(Logger.TIP_WEAPON)
			else:
				Logger.tip(Logger.TIP_LOAD)

func _duel(defender: GameEntity, attacker: GameEntity = E.player) -> String: # нападающий указан последним т.к. опционален
	var result_text := "\n%s нападает на %s" % [attacker.get_text(), defender.get_text()]
	var attacker_start_health = attacker.get_attribute(E.HEALTH).x
	var defender_start_health = defender.get_attribute(E.HEALTH).x
	
	E.duel(defender, attacker)
	
	result_text += ".\nРезультаты поединка:"
	var attacker_health = attacker.get_attribute(E.HEALTH).x
	result_text += "\n- %s: потеряно %d здоровья" % [attacker.get_attribute(E.NAME), attacker_start_health - attacker_health]
	if not attacker_health:
		result_text += " (смерть)"
	
	var defender_health = defender.get_attribute(E.HEALTH).x
	result_text += "\n- %s: потеряно %d здоровья" % [defender.get_attribute(E.NAME), defender_start_health - defender_health]
	if not defender_health:
		result_text += " (смерть)"
	
	result_text += "\n\n"
	
	return result_text
