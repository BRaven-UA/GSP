# Окно для отображения списка доступных игроку событий. Список отображается и обновляется по сигналу new_events от Game

extends MarginContainer

onready var _event_container: HBoxContainer = find_node("EventContainer") # в этот контейнер добавляются все доступные события
onready var _frames := [] # пул рамок для отображения событий. Для экономии ресурсов отработанные рамки не удаляются, а помещаются сюда для повторного использования


func _ready() -> void:
	Global.game.connect("new_events", self, "update_frames")

func update_frames(events: Array) -> void: # заполняет рамки из пула данными из списка доступных событий. Вызывается по событию new_events от Game
	_clear()
	
	for event in events:
		var frame = _get_frame() # получаем ссылку на пустую рамку
		frame.init(event)
		frame.visible = true
	
	visible = true

func _clear(exception: MarginContainer = null) -> void: # очищает все рамки (кроме exception) событий для повторного использования
	visible = false
	
	for frame in _frames:
		if frame != exception:
			frame.clear()
	
	set_anchors_and_margins_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE) # восстанавливаем исходный размер и позицию

func _get_frame() -> Button: # ищет в пуле незанятую рамку или создает новую
	for frame in _frames:
		if not frame.visible:
			return frame
	
	var frame = Resources.get_resource("Event_Frame").instance() as MarginContainer
	frame.name += str(_frames.size()) # прибавляем к имени индекс в массиве
	frame.connect("pressed", self, "_on_frame_pressed", [frame]) # передает ссылку на рамку в качестве аргумента
	frame.connect("action_pressed", self, "_clear") # скрыть это окно после выбора действия
	_event_container.add_child(frame)
	_frames.append(frame)
	return frame

func _on_frame_pressed(selected_frame: MarginContainer) -> void: # обработка нажатия на рамку события
	_clear(selected_frame) # очищаем все кроме выбранной рамки
	
	selected_frame.show_actions() # добавляем список действий
	
	visible = true
