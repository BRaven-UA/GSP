# Класс для управления игрой: старт новой игры, выбор доступных событий, завершение игры

extends Node

var _events := [] # список всех событий в игре
var _available_events := [] # список событий, доступных для выбора игроком
var _events_quantity := 2 # количество событий для выбора
var _game_over := false # флаг окончания игры

signal new_events # Новые события доступны для выбора


func _ready():
	randomize()
	
	for name in Resources.get_resource_list():
		if name.begins_with("GameEvent"):
			_events.append(Resources.get_resource(name).new())

func test_start(): # настройка игры для нужд тестирования
	var player = E.create_entity("Игрок")
	player.add_entity(E.create_entity("Нож"))
	player.add_entity(E.create_entity("Хлеб"))
	player.add_entity(E.create_entity("Собака"))
	player.add_entity(E.create_entity("Дробовик"))
	player.add_entity(E.create_entity("Патрон для дробовика", {E.QUANTITY:3}))
	game_loop()

func game_loop(): # основной игровой цикл
	while not _game_over:
		update_events()
		yield(GUI, "results_confirmed")
		E.time_effects()

func update_events(): # формирует новый список событий для выбора
	_available_events.clear()
	var events_pool := [] # временный список доступных для выбора событий
	
	for event in _events: # формируем предварительный список событий, соответствующих требованиям
		var passed := true
		for key in event.requirements:
			if E.player.get_attribute(key, false) != event.requirements[key]:
				passed = false
				break # одно из условий не выполнено, завершаем проверку
		if passed:
			events_pool.append(event)
	
	events_pool.shuffle() # меняем порядок на случайный
	
	for i in _events_quantity: # выбираем N случайных события из списка доступных
		var cut_off = randf() # определяем "редкость" события
		for event in events_pool:
			if cut_off <= event.probability:
				_available_events.append(event)
				events_pool.erase(event) # исключаем повторный выбор
				break
	
	emit_signal("new_events", _available_events) # на сигнал должен реагировать интерфейс EventList

func game_over() -> void:
	push_warning("Game over")
	_game_over = true
