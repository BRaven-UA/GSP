# Класс для управления игрой: старт новой игры, перки, завершение игры

extends Node

enum {PERK_NAME, PERK_DESCRIPTION}
const PERKS := [
	{PERK_NAME:"Зоркость", PERK_DESCRIPTION:"Дает больше информации об окружающем мире"},
	{PERK_NAME:"Широкий кругозор", PERK_DESCRIPTION:"Увеличивает на 1 количество событий для выбора"}]

var _experience : int # накопленный игровой опыт (не зависит от сущности игрока)
var _active_perks := [] # список активных перков (уникальных способностей) текущей сущности игрока
var perk_points := 0 # количество доступных перков
var _fail := false # флаг завершения текущей попытки

signal new_attempt # Начало новой попытки
signal perks_changed # состав активных перков изменился
signal exp_changed # изменился игровой опыт


func _ready():
	randomize()
	
	GUI.connect("results_confirmed", self, "_on_GUI_results")
	GUI.connect("trade_complete", self, "_on_GUI_trade")

func new_attempt():
	_fail = false
	_active_perks = []
	emit_signal("perks_changed", _active_perks)
	emit_signal("new_attempt")
	Logger.tip(Logger.TIP_START)
	
	var player = E.create_entity("Игрок")
	player.add_entity(E.create_entity("Хлеб"))
#	player.add_entity(E.create_entity("Нож"))
#	player.add_entity(E.create_entity("Собака"))
#	player.add_entity(E.create_entity("Дробовик"))
#	player.add_entity(E.create_entity("Патрон для дробовика", {E.QUANTITY:3}))
#	player.add_entity(E.create_entity("Радиоприемник"))
#	player.add_entity(E.create_entity("Аккумулятор", {E.CAPACITY:Vector2(10, 100)}))
#	add_perk("Широкий кругозор")
	
	emit_signal("exp_changed", _experience) # для первичного заполнения индикатора опыта
	
	EventManager.update_events()

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
	if not _fail:
		E.time_effects()
		EventManager.update_events()

func fail() -> void:
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
