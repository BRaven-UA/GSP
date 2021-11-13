# Синглтон для управления событиями в игре

extends Node

var _events := [] # список всех событий в игре
var _tracked_events := [] # список событий, для которых нужно отслеживать расстояние
var _last_event: GameEvent # ссылка на последнее игровое событие

signal new_events # Новые события доступны для выбора
signal tracking_changed # для обновления GUI

func _ready() -> void:
	# создаем экземпляры всех возможных событий
	for name in Resources.get_resource_list():
		if name.begins_with("GameEvent"):
			_events.append(Resources.get_resource(name).new())
	
	Game.connect("new_character", self, "_on_new_character")

func get_event(name: String) -> GameEvent: # поиск события по имени
	for event in _events:
		if event.name == name:
			return event
	return null

func remove_event(event: GameEvent): # удаляет событие из игры
	untrack_event(event)
	_events.erase(event)

func update_events(): # формирует новый список событий для выбора
	var _available_events := [] # список событий, доступных для выбора игроком
	var events_pool := [] # временный список доступных для выбора событий
	var total_probability := 0.0 # суммарная вероятность доступных событий
	
	for event in _events: # формируем предварительный список событий, соответствующих требованиям
		if event.is_available(): # у события могут быть условия его доступности для выбора
			events_pool.append(event)
			total_probability += event.probability
	
	events_pool.shuffle() # меняем порядок на случайный
	
	var event_quantity := 3 + int(E.player.find_entity(E.NAME, "Широкий кругозор", true) != null) # количество собыйти для выбора
	for i in event_quantity:
		var cut_off = randf() * total_probability # отсечка на шкале суммарной вероятности
		var accumulated_probability := 0.0 # накопительная вероятность перебранных событий
		for event in events_pool: # перебираем события
			accumulated_probability += event.probability # добавляем текущую вероятность
			if cut_off <= accumulated_probability: # накопленная вероятность превысила отсечку, событие выбрано
				var event_data := {"Event":event, "TrackingData":[]}
				
				for tracker in _tracked_events:
					if tracker != event: # не отслеживаем сами себя
						var travel_distance := -15 + randi() % 41 # на сколько приближаемся/удаляемся от события
						var tracking_text = tracker.get_tracking_text(travel_distance)
						if tracking_text: # если условия отслеживания не соблюдены, будет пустая строка
							var tracking_data := {"Tracker":tracker, "Distance":travel_distance, "Text":tracking_text}
							event_data.TrackingData.append(tracking_data)
				
				_available_events.append(event_data)
				events_pool.erase(event) # исключаем повторный выбор
				total_probability -= event.probability
				break
	
	emit_signal("new_events", _available_events) # на сигнал должен реагировать интерфейс EventList

func track_event(event: GameEvent):
	if not _tracked_events.has(event):
		_tracked_events.append(event)
		Logger.info("Начато отслеживание %s" % event.name)
		Logger.tip(Logger.TIP_TRACKING)

func untrack_event(event: GameEvent):
	if _tracked_events.has(event):
		_tracked_events.erase(event)
		Logger.info("Отслеживание %s прекращено" % event.name)

func toggle_tracking(event: GameEvent):
	if _tracked_events.has(event):
		untrack_event(event)
	else:
		track_event(event)
	emit_signal("tracking_changed", _tracked_events)

func set_current_event(event_data: Dictionary): # получены данные о текущем событии
	Game.state = Game.STATE_EVENT
	_last_event = event_data.Event
	
	for data in event_data.TrackingData: # обновление отслеживаемых событий при выборе текущего события
		var tracker = data.Tracker
		var distance = data.Distance
		tracker.distance = abs(tracker.distance + distance) # при отрицательных значениях расстояние все равно положительное
		if tracker.distance < 10:
			tracker.probability = 2.0 # шанс выпадения в 2 раза больше обычных событий

func get_new_character_data() -> Dictionary: # возвращает данные о новом игровом персонаже в случае смерти текущего
	if _last_event:
		return _last_event.new_character_data
	return {}

func _on_new_character(entity: GameEntity):
	_tracked_events.clear()
