# Класс для управления игрой: старт новой игры, перки, завершение игры

extends Node

enum {STATE_IDLE, STATE_EVENT, STATE_TRADE} # игровые состояния
enum {PERK_NAME, PERK_DESCRIPTION}
const PERKS := [
	{PERK_NAME:"Зоркость", PERK_DESCRIPTION:"Дает больше информации об окружающем мире"},
	{PERK_NAME:"Широкий кругозор", PERK_DESCRIPTION:"Увеличивает на 1 количество событий для выбора"}]

var _experience : int # накопленный игровой опыт (не зависит от сущности игрока)
var _active_perks := [] # список активных перков (уникальных способностей) текущей сущности игрока
var perk_points := 0 # количество доступных перков
var _fail := false # флаг завершения текущей попытки
#var fail_data := {"Text":"", "Heir":null, "Remains":[]} # данные для нового персонажа
var state: int # текущее состояние игры

signal new_character # Игра за нового персонажа
signal perks_changed # состав активных перков изменился
signal exp_changed # изменился игровой опыт


func _ready():
	randomize()
	
	GUI.connect("results_confirmed", self, "_on_GUI_results")
	GUI.connect("trade_complete", self, "_on_GUI_trade")

func new_character(): # создание нового персонажа или игра за существующего
	_fail = false
	_active_perks = []
	emit_signal("perks_changed", _active_perks)
	_experience = 0
	emit_signal("exp_changed", _experience) # для первичного заполнения индикатора опыта

	var new_character_data: Dictionary # данные для нового персонажа
	if state == STATE_EVENT: # некоторые данные могут меняться событиями
		new_character_data = EventManager.get_new_character_data()
	state = STATE_IDLE
	
	var character: GameEntity = new_character_data.get("Entity")
	if not character: # если персонажа еще нет в игре, создаем нового
		character = E.create_entity("Человек", {E.HEALTH:Vector2(80 + randi() % 21, 100)})
		var random_entity = E.randw([{"Ничего":1}, {"Собака":0.2}, {"Хлеб":0.5}, {"Нож":0.1}])
		if random_entity != "Ничего":
			character.add_entity(E.create_entity(random_entity), false, false, true)
	
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
		
		var prev_exp = _experience
		_experience += value
# warning-ignore:integer_division
		if prev_exp / 100 != _experience / 100:
			Logger.info("Получен новый уровень!", Logger.INGAME_EXP)
			perk_points += 1
			emit_signal("perks_changed", _active_perks) # для обновления списка перков и появления опции выбора новго перка
		
		emit_signal("exp_changed", _experience)

func _next_step(): # следующий игровой цикл
	if _fail:
		GUI.show_continue()
	else:
		if state != STATE_IDLE:
			E.time_effects()
			state = STATE_IDLE
		EventManager.update_events()

func fail() -> void:
	Logger.info("Текущий персонаж умер!", Logger.INGAME_DAMAGE)
	Logger.tip(Logger.TIP_DEATH)
	_fail = true

func add_perk(name: String):
	if perk_points:
		for perk in PERKS:
			if perk[PERK_NAME] == name:
				_active_perks.append(perk)
				perk_points -= 1
				emit_signal("perks_changed", _active_perks)
				return

func remove_perk(name: String):
	for perk in _active_perks:
		if perk[PERK_NAME] == name:
			_active_perks.erase(perk)
			perk_points += 1
			emit_signal("perks_changed", _active_perks)
			return

func has_perk(name: String) -> bool:
	for perk in _active_perks:
		if perk[PERK_NAME] == name:
			return true
	return false

func get_perks_to_select(): # возвращает массив перков для выбора игроком
	var result := PERKS.duplicate() # все возможные перки
	
	for perk in _active_perks: # убираем уже выбранные
		result.erase(perk)
	result.shuffle() # перемешиваем
	if result.size() > 3: # обрезаем до максимум трех на выбор
		result.resize(3)
	
	return result

func _on_GUI_results():
	_next_step()

func _on_GUI_trade():
	_next_step()
