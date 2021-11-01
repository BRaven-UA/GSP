# Синглтон для управления событиями в игре

extends Node

var _events := [] # список всех событий в игре
var _tracked_events := [] # список событий, для которых нужно отслеживать расстояние

signal new_events # Новые события доступны для выбора

func _ready() -> void:
	# создаем экземпляры всех возможных событий
	for name in Resources.get_resource_list():
		if name.begins_with("GameEvent"):
			_events.append(Resources.get_resource(name).new())

func update_events(): # формирует новый список событий для выбора
	var _available_events := [] # список событий, доступных для выбора игроком
	var events_pool := [] # временный список доступных для выбора событий
	
	for event in _events: # формируем предварительный список событий, соответствующих требованиям
		if event.is_available(): # у события могут быть условия его доступности для выбора
			events_pool.append(event)
	
	events_pool.shuffle() # меняем порядок на случайный
	
	var event_quantity := 3 + int(Game.has_perk("Широкий кругозор"))
	for i in event_quantity:
		var cut_off = randf() # определяем "редкость" события
		for event in events_pool:
			if cut_off <= event.probability: # у событий есть вероятность возникновения
				var event_data := {"Event":event, "TrackingData":[]}
				
				for tracker in _tracked_events:
					if tracker != event: # не отслеживаем сами себя
						var travel_distance := -20 + randi() % 41 # на сколько приближаемся/удаляемся от события
						var tracking_text = tracker.get_tracking_text(travel_distance)
						if tracking_text: # если условия отслеживания не соблюдены, будет пустая строка
							var tracking_data := {"Tracker":tracker, "Distance":travel_distance, "Text":tracking_text}
							event_data.TrackingData.append(tracking_data)
				
				_available_events.append(event_data)
				events_pool.erase(event) # исключаем повторный выбор
				break
	
	emit_signal("new_events", _available_events) # на сигнал должен реагировать интерфейс EventList

func track_event(event: GameEvent):
	if not _tracked_events.has(event):
		_tracked_events.append(event)

func untrack_event(event: GameEvent):
	if _tracked_events.has(event):
		_tracked_events.erase(event)

func update_trackers(tracking_data: Array): # обновление отслеживаемых событий при выборе текущего события
	for data in tracking_data:
		var tracker = data.Tracker
		var distance = data.Distance
		tracker.distance = abs(tracker.distance + distance) # при отрицательных значениях расстояние все равно положительное
		if tracker.distance < 10:
			tracker.probability = 1.0 # шанс выпадения максимальный
