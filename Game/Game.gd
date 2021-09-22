# Класс для управления игрой: старт новой игры, создание событий, завершение игры

extends Node

class_name Game

var _available_events := [] # список событий, доступных для выбора игроком

signal new_events(events) # Новые события доступны для выбора, передаем ссылку на иассив событий

func _enter_tree() -> void:
	Global.game = self

func test_start(): # настройка игры для нужд тестирования
	Global.player.test_start()
	
	_available_events = [preload("res://Game/Events/Event1.gd").new()]
	_available_events.append(preload("res://Game/Events/Event2.gd").new())
	
	emit_signal("new_events", _available_events) # на сигнал должен реагировать интерфейс EventList

func game_over() -> void:
	pass
