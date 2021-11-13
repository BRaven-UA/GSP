# Класс для управления игрой: старт новой игры, перки, завершение игры

extends Node

enum {STATE_IDLE, STATE_EVENT, STATE_TRADE} # игровые состояния

var _experience : int # накопленный игровой опыт
var _fail := false # флаг завершения текущей попытки
var state: int # текущее состояние игры
var turn: int # текущий ход
var _max_turns: int # максимальное количество ходов до завершения симуляции

signal exp_changed # изменился игровой опыт
signal new_character # Игра за нового персонажа
signal countdown

func _ready():
	randomize()
	_max_turns = 200 + randi() % 101
	
	GUI.connect("results_confirmed", self, "_on_GUI_results")
	GUI.connect("trade_complete", self, "_on_GUI_trade")

func new_character(): # создание нового персонажа или игра за существующего
	_fail = false
	_experience = 0
	emit_signal("exp_changed", _experience) # для первичного заполнения индикатора опыта

	var new_character_data: Dictionary # данные для нового персонажа
	if state == STATE_EVENT: # некоторые данные могут меняться событиями
		new_character_data = EventManager.get_new_character_data()
	state = STATE_IDLE
	
	var turns_passed = 1
	var character: GameEntity = new_character_data.get("Heir")
	if not character: # если персонажа еще нет в игре, создаем нового
		if turn: # для самого первого персонажа ничего не ищем
			turns_passed = 10 + randi() % 21 # время для поиска останков предыдущего персонажа
		character = E.create_entity("Человек", {E.HEALTH:Vector2(80 + randi() % 21, 100)})
		if OS.is_debug_build():
#			character.add_entity(E.create_entity("Бензопила"))
#			character.add_entity(E.create_entity("Аккумулятор"))
#			character.add_entity(E.create_entity("Канистра с бензином", {E.CAPACITY:Vector2(10, 10)}))
#			character.add_entity(E.create_entity("Красноречие"), true)
			pass
		var random_entity = E.randw([{"Ничего":1}, {"Собака":0.2}, {"Хлеб":0.5}, {"Нож":0.1}])
		if random_entity != "Ничего":
			character.add_entity(E.create_entity(random_entity), false, false, true)
	add_turns(turns_passed)
	
	# если это первый персонаж, создаем записную книгу, иначе передаем останки предыдущего персонажа
	var remains = E.player_remains(new_character_data.get("Remains", [E.REMAINS.ONLY_NOTEBOOK]))
	emit_signal("new_character", character) # останки должны браться до того как ссылка на игрока измениться, но перед обновлением интерфейса, чтобы в новом логе было видно добавленные предметы
	character.add_entities(remains)
	
	# если событием не указаны условия смерти предыдущего персонажа (или это первый персонаж) считаем что записную книгу выкинули за ненадобностью
	var default_text = "Копаясь в очередной куче мусора в поисках чего-нибудь\nполезного, вы находите потрепанную записную книжку.\nВы сунули ее в карман, решив, что почитаете на досуге,\nи продолжили копаться в мусоре"
	var text = new_character_data.get("Text", default_text)
	GUI.show_accept_dialog(text)
	
	Logger.tip(Logger.TIP_START)
	Logger.tip(Logger.TIP_NOTEBOOK)

func increase_exp(value: int): # увеличивает накопленный опыт на указанную величину
	if not _fail: # события, приведшие к смерти, не увеличивают опыт
		Logger.info("Получено %d опыта" % value, Logger.INGAME_EXP)
		Logger.tip(Logger.TIP_EXPERIENCE)
		
		var prev_exp = _experience
		_experience += value
# warning-ignore:integer_division
		if prev_exp / 100 != _experience / 100:
			Logger.info("Получен новый уровень!", Logger.INGAME_EXP)
			E.player.add_entity(E.create_entity("Новая способность"))
		
		emit_signal("exp_changed", _experience)

func _next_step(): # следующий игровой цикл
	if _fail:
		GUI.show_continue()
	elif state == STATE_IDLE:
		EventManager.update_events()
	else:
		time_effects()

func time_effects(): # потребление различных ресурсов игрока в результате проведения события
	for entity in E.player.get_entities(true): # для всех сущностей игрока, влючая его самого
		if entity.get_attribute(E.TYPE) == E.TYPES.BIOLOGICAL:
			entity.change_attribute(E.HEALTH) # снижение "сытости" для биологических сущностей
		
		if entity.get_attribute(E.ACTIVE):
			entity.change_attribute(E.CAPACITY) # потребление расходников активных сущностей
			
	var entity = E.current_study()
	if entity:
		var studied = E.study(entity.get_attribute(E.KNOWLEDGE), 1) # увеличиваем прогресс изучения
		if studied:
			E.player.deactivate_entity(entity) # если знание получено, деактивируем источник
	
	add_turns(1)
	Logger.tip(Logger.TIP_TIME)
	state = STATE_IDLE
	_next_step()

func add_turns(amount: int): # увеличивает счетчик ходов
	if amount:
		turn += amount
		if turn > _max_turns:
			shut_down()
#		emit_signal("countdown", E.clamp_int(_max_turns - turn, 0, _max_turns))

func fail():
	Logger.info("Текущий персонаж умер!", Logger.INGAME_DAMAGE)
	Logger.tip(Logger.TIP_DEATH)
	_fail = true

func shut_down(): # конец симуляции
	get_tree().quit()

func _on_GUI_results():
	_next_step()

func _on_GUI_trade():
	_next_step()
