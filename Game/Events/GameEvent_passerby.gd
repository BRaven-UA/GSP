extends GameEvent

var passerby: GameEntity
var note: GameEntity

func _init() -> void:
	name = "Прохожий"
	description = "Такой же странник, как и вы. Не проявляет агрессии"
	probability = 1.0
	new_character_data = {"Text":"Мне до него дела не было, он сам первым начал.\nЯ не могу позволить каждому встречному обобрать\nсебя до нитки. А его вещи теперь послужат мне.", "Remains":[E.REMAINS.NO_PETS]}

func setup():
	note = null
	var loot := []
	var possible_loot := [{"Записка":0.02}, {"Хлеб":1}, {"Тушенка":0.5}, {"Радиоприемник":0.1}]
	var quantity = 1 + randi() % 3
	for i in quantity: # от 1 до 3 предметов
		var item_name = E.randw(possible_loot)
		if item_name == "Записка":
			var missed_notes = _missed_notes()
			item_name = missed_notes[randi() % missed_notes.size()]
			note = E.create_entity(item_name)
			loot.append(note)
		else:
			loot.append(E.create_entity(item_name))
			
	
	passerby = E.create_person([{"Нож":1}, {"Топор":0.75}, {"Пистолет":0.5}, {"Охотничья винтовка":0.25}])
	passerby.add_entities(loot)
	
	bonus_info = ""
	_target_bonus_info(passerby)
	new_character_data.Heir = passerby

func _define_actions():
	_add_action("Беседовать", "_talk")
	_add_action("Торговать", "_trade")
	_add_hostile_actions(passerby)

func _missed_notes() -> Array:
	var result := []
	for i in 19: # составляем список всех записок
		result.append("Записка %d" % (i + 1))
	
	for _note in E.notebook.get_entities():
		var _name = _note.get_attribute(E.NAME)
		if _name in result: # убираем из списка уже имеющиеся записки
			result.erase(_name)
	
	return result

func _talk():
	var result_text := "Вы подошли к незнакомцу и завели разговор на разные\nжитейские темы. "
	
	if note:
		passerby.remove_entity(note)
		E.player.add_entity(note)
		return "Во время общения собеседник заметил\nу вас записную книгу и вспомнил что уже видел ее у\nодного торговца. Тот использовал чистые листы из нее\nдля долговых расписок, а уже исписанные предыдущим\nвладельцем листы вырывал и заворачивал в них некоторые\nсвои товары. Как раз один из таких листков и сохранился\nу вашего собеседника. Он любезно отдал этот листок вам"
	else:
		result_text += "Вы поговорили о том, о сём. В итоге\nвы узнали что-то новое об этом мире и получили новый\nопыт"
		if randf() < 0.2:
			var locations := ["Координаты АЗС", "Координаты ВЭС"]
			var _name = locations[randi() % locations.size()]
			if E.player.find_entity(E.NAME, _name) == null:
				E.player.add_entity(E.create_entity(_name))
				result_text += ". Также от собеседника вы узнали где находится\n%s и добавили координаты в записную книгу" % _name
	return result_text

func _duel(defender: GameEntity, attacker: GameEntity = E.player) -> String:
	var result_text = ._duel(defender, attacker)
	
	if defender.get_attribute(E.HEALTH).x < 1:
		defender.remove_entity(defender.find_entity(E.NAME, "Удар"))
		E.player.add_entities(defender.get_entities())
		passerby = null
	
	return result_text

func _trade():
	Game.state = Game.STATE_TRADE
	GUI.show_trade_panel(passerby)
	return ""
