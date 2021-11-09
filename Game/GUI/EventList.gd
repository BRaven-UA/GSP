# Окно для отображения списка доступных игроку событий. Список отображается и обновляется по сигналу new_events от Game

extends MarginContainer

onready var _event_container: GridContainer = find_node("EventContainer") # в этот контейнер добавляются все доступные события
onready var _frames := [] # пул рамок для отображения событий. Для экономии ресурсов отработанные рамки не удаляются, а помещаются сюда для повторного использования


func _ready() -> void:
	EventManager.connect("new_events", self, "_on_new_events")

func _on_new_events(events: Array) -> void: # заполняет рамки из пула данными из списка доступных событий. Вызывается по событию new_events от Game
	_clear()
	
	for event_data in events:
		var frame = _get_frame() # получаем ссылку на пустую рамку
		frame.init(event_data)
		frame.visible = true
	
	visible = true

func _clear(exception: MarginContainer = null) -> void: # очищает все рамки (кроме exception) событий для повторного использования
	visible = false
	
	for frame in _frames:
		if frame != exception:
			frame.clear()
	
#	set_anchors_and_margins_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE) # восстанавливаем исходный размер и позицию
#	set_anchor(MARGIN_TOP, 0.2, true) # немного отодвигаем до верхнего края

func _get_frame() -> Button: # ищет в пуле незанятую рамку или создает новую
	for frame in _frames:
		if not frame.visible:
			return frame
	
	var frame = Resources.get_resource("Event_Frame").instance() as MarginContainer
	frame.name += str(_frames.size()) # прибавляем к имени индекс в массиве
	frame.connect("pressed", self, "_on_frame_pressed", [frame]) # передает ссылку на рамку в качестве аргумента
	frame.connect("action_pressed", self, "_on_action_pressed") 
	_event_container.add_child(frame)
	_frames.append(frame)
	return frame

func _on_frame_pressed(selected_frame: MarginContainer) -> void: # обработка нажатия на рамку события
	GUI.input_delay()
	EventManager.set_current_event(selected_frame.event_data)
	
	_clear(selected_frame) # очищаем все кроме выбранной рамки
	selected_frame.show_actions(true) # добавляем список действий с первичной настройкой события
	E.connect("player_entities_changed", self, "_on_player_entities_changed", [selected_frame])
	visible = true

func _on_player_entities_changed(entities: Array, active_frame: MarginContainer): # обновляем список действий активной рамки, если сущности изменились в момент выбора действий
	_clear() # очищаем все
	active_frame.show_actions() # добавляем новый список действий
	visible = true

func _on_action_pressed(event_data: Dictionary, action_index: int): # выбор одного из действий активной рамки события
	GUI.input_delay()
	E.disconnect("player_entities_changed", self, "_on_player_entities_changed")
	_clear() # скрыть это окно после выбора действия
	event_data.Event.apply_action(action_index)
