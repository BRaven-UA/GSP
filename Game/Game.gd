# Класс для управления игрой: старт новой игры, создание событий, завершение игры

extends Node

class_name Game

var _event_scripts := [] # список скриптов для всех событий в игре
var _available_events := [] # список событий, доступных для выбора игроком

signal new_events(events) # Новые события доступны для выбора, передаем ссылку на массив событий

func _enter_tree() -> void:
	Global.game = self
	randomize()

func _ready():
	for name in Resources.get_resource_list():
		if name.begins_with("GameEvent"):
			_event_scripts.append(Resources.get_resource(name))

func test_start(): # настройка игры для нужд тестирования
	Global.player.test_start()
	update_events()

func update_events(): # формирует новый список событий для выбора
	_available_events.clear()
	
	for script in _event_scripts:
		_available_events.append(script.new())
	
	emit_signal("new_events", _available_events) # на сигнал должен реагировать интерфейс EventList

func game_over() -> void:
	pass
