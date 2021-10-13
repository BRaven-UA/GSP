# Класс для управления игрой: старт новой игры, выбор доступных событий, завершение игры

extends Node

enum {PERK_NAME, PERK_DESCRIPTION}
const PERKS := [{PERK_NAME:"Зоркость", PERK_DESCRIPTION:"Дает больше информации об окружающем мире"}]

var _events := [] # список всех событий в игре
var _experience : int # накопленный игровой опыт (не зависит от сущности игрока)
var _active_perks := [] # список активных перков (уникальных способностей) текущей сущности игрока
var _fail := false # флаг завершения текущей попытки

signal new_events # Новые события доступны для выбора
signal perks_changed # состав активных перков изменился
signal exp_changed # изменился игровой опыт


func _ready():
	randomize()
	
	for name in Resources.get_resource_list():
		if name.begins_with("GameEvent"):
			_events.append(Resources.get_resource(name).new())
	
	GUI.connect("results_confirmed", self, "_on_GUI_results")
	GUI.connect("trade_complete", self, "_on_GUI_trade")

func new_attempt():
	var player = E.create_entity("Игрок")
	player.add_entity(E.create_entity("Нож"))
	player.add_entity(E.create_entity("Хлеб"))
	player.add_entity(E.create_entity("Собака"))
	player.add_entity(E.create_entity("Дробовик"))
	player.add_entity(E.create_entity("Патрон для дробовика", {E.QUANTITY:3}))
	player.add_entity(E.create_entity("Радиоприемник"))
	player.add_entity(E.create_entity("Аккумулятор", {E.CAPACITY:Vector2(10, 100)}))
	emit_signal("exp_changed", _experience) # для первичного заполнения индикатора опыта
	_active_perks = []
	add_perk("Зоркость")
	update_events()

func increase_exp(value: int): # увеличивает накопленный опыт на указанную величину
	if not _fail: # события, приведшие к смерти, не увеличивают опыт
		Logger.info("Получено %d опыта" % value)
		var prev_exp = _experience
		_experience += value
# warning-ignore:integer_division
		if prev_exp / 100 != _experience / 100:
			print("новый уровень")
		emit_signal("exp_changed", _experience)

func _next_step(): # следующий игровой цикл
	if not _fail:
		E.time_effects()
		update_events()

func update_events(): # формирует новый список событий для выбора
	var _available_events := [] # список событий, доступных для выбора игроком
	var events_pool := [] # временный список доступных для выбора событий
	
	for event in _events: # формируем предварительный список событий, соответствующих требованиям
#		var passed := true
#		for key in event.requirements:
#			if E.player.get_attribute(key, false) != event.requirements[key]:
#				passed = false
#				break # одно из условий не выполнено, завершаем проверку
#		if passed:
#			events_pool.append(event)
		if event.is_available():
			events_pool.append(event)
	
	events_pool.shuffle() # меняем порядок на случайный
	
	for i in 3: # выбираем N случайных события из списка доступных
		var cut_off = randf() # определяем "редкость" события
		for event in events_pool:
			if cut_off <= event.probability:
				_available_events.append(event)
				events_pool.erase(event) # исключаем повторный выбор
				break
	
	emit_signal("new_events", _available_events) # на сигнал должен реагировать интерфейс EventList

func fail() -> void:
	print("!!  Ваш текущий игровой персонаж умер. Начните снова  !!")
	_fail = true

func add_perk(name: String):
	for perk in PERKS:
		if perk[PERK_NAME] == name:
			_active_perks.append(perk)
			emit_signal("perks_changed", _active_perks)
			return

func remove_perk(name: String):
	for perk in _active_perks:
		if perk[PERK_NAME] == name:
			_active_perks.erase(perk)
			emit_signal("perks_changed", _active_perks)
			return

func has_perk(name: String) -> bool:
	for perk in _active_perks:
		if perk[PERK_NAME] == name:
			return true
	return false

func _on_GUI_results():
	_next_step()

func _on_GUI_trade():
	_next_step()
