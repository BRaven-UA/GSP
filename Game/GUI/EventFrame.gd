# Окно для отображения игрового события. Создается процедурно из EventList

extends MarginContainer

onready var _button: Button = find_node("Button") # кнопка отвечает за подсветку и выбор события
onready var _scroll_container: ScrollContainer = find_node("ScrollContainer") # для ограничения слишком длинных списков действий
onready var _action_container: VBoxContainer = _scroll_container.get_node("ActionContainer") # контейнер для полей события
onready var _caption: Label = find_node("Caption") # заголовок события
onready var _separator: TextureRect = find_node("Separator") # визуальный разграничитель
onready var _description: Label = find_node("Description") # описание события (скрывается при выборе события)
onready var _bonus_info: Label = find_node("BonusInfo") # дополнительная информация, доступная только с перком "Зоркость"
onready var _tracker: Label = find_node("Tracker") # для отслеживания расстояния до событий из списка в Game
onready var _action_buttons := [] # пул кнопок для отображения доступных действий. Для экономии ресурсов отработанные кнопки не удаляются, а помещаются сюда для повторного использования
var event_data: Dictionary # ссылка на данные о событии

signal pressed # для дублирования сигнала с кнопки
signal action_pressed # пользователь выбрал действие


func _ready() -> void:
	_button.connect("pressed", self, "_on_pressed") # дублируем сигнал с кнопки
	EventManager.connect("tracking_changed", self, "_on_tracking_changed") # на случай изменений уже после формирования по данным события

func init(data: Dictionary) -> void: # формирование окна события для выбора из списка других событий
	event_data = data
	var event = event_data.Event
	_caption.text = event.name
	_description.text = event.description
	
	for tracking_data in event_data.TrackingData:
		if _tracker.text:
			_tracker.text += "\n"
		_tracker.text += tracking_data.Text
		_tracker.visible = true
	

func show_actions(setup := false) -> void: # формирование списка возможных действий для события
	var event = event_data.Event
	if setup: # первичная настрока события
		event.setup()
	event.update_actions() # обновление доспутных действий
	
	_caption.text = event.name
	_description.text = event.description
	_bonus_info.text = event.bonus_info
	_bonus_info.visible = E.player.find_entity(E.NAME, "Зоркость", true) != null
	_separator.visible = false
	_tracker.visible = false
	_button.mouse_filter = Control.MOUSE_FILTER_IGNORE # чтобы нельзя было триггерить кнопку
	
	for action in event.actions:
		var button = _get_button() # получаем ссылку на пустую кнопку
		button.get_node("Button").text = action.Text
		button.visible = true
	
	_action_container.rect_size = Vector2.ZERO
	_scroll_container.rect_min_size.x = clamp(_action_container.rect_size.x, 200, 400) + 13
	_scroll_container.rect_min_size.y = clamp(_action_container.rect_size.y, 50, 230) + 13
	_scroll_container.visible = true
	visible = true

func clear() -> void: # очистка окна
	visible = false # по этому значению EventList будет определять что окно очищено
	_button.pressed = false # возвращаем в не нажатое состояние
	_button.mouse_filter = Control.MOUSE_FILTER_STOP # возвращаем способность реагировать на мышь
	
	_caption.text = ""
	_description.text = ""
	_description.visible = true
	_bonus_info.text = ""
	_separator.visible = true
	_tracker.text = ""
	_tracker.visible = false
	_scroll_container.visible = false
#	_scroll_container.rect_min_size = Vector2(200, 50) # для формы выбора событий
	
	for button in _action_buttons:
		button.visible = false

func _get_button() -> Button: # ищет в пуле незанятую кнопку или создает новую
	for button in _action_buttons:
		if not button.visible:
			return button
	
	var button = Resources.get_resource("Action").instance() as MarginContainer
	button.name += str(_action_buttons.size()) # прибавляем к имени индекс в массиве
	button.get_node("Button").connect("pressed", self, "_on_action_button_pressed", [button]) # передает ссылку на себя в качестве аргумента
	_action_container.add_child(button)
	_action_buttons.append(button)
	return button

func _on_tracking_changed(events: Array):
	_tracker.visible = not events.empty()

func _on_pressed(): # нажатие на дочернюю кнопку, обозначающее выбор этого события
	emit_signal("pressed")

func _on_action_button_pressed(button: MarginContainer) -> void: # вызывается при нажатии на любую кнопку действия
	emit_signal("action_pressed", event_data, _action_buttons.find(button)) # для EventList
#	event_data.apply_action(_action_buttons.find(button))
