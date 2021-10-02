# Окно для отображения игрового события. Создается процедурно из EventList

extends MarginContainer

onready var _button: Button = find_node("Button") # кнопка отвечает за подсветку и выбор события
onready var _container: VBoxContainer = find_node("Container") # контейнер для полей события
onready var _caption: Label = find_node("Caption") # заголовок события
onready var _separator: TextureRect = find_node("Separator") # визуальный разграничитель
onready var _description: Label = find_node("Description") # описание события (скрывается при выборе события)
onready var _action_buttons := [] # пул кнопок для отображения доступных действий. Для экономии ресурсов отработанные кнопки не удаляются, а помещаются сюда для повторного использования
var _event: GameEvent # ссылка на событие

signal pressed # для дублирования сигнала с кнопки
signal action_pressed # пользователь выбрал действие


func _ready() -> void:
	_button.connect("pressed", self, "_on_pressed") # дублируем сигнал с кнопки

func init(event: GameEvent) -> void: # формирование окна события для выбора из списка других событий
	_event = event
	_caption.text = _event.name
	_description.text = _event.description

func show_actions() -> void: # формирование списка возможных действий для события
	_caption.text = _event.name
	_description.visible = false # детальное описание и разграничитель на этом этапе не нужны
	_separator.visible = false
	_button.mouse_filter = Control.MOUSE_FILTER_IGNORE # чтобы нельзя было триггерить кнопку
	
	_event.update_actions()
	
	for action in _event.actions:
		var button = _get_button() # получаем ссылку на пустую кнопку
		button.get_node("Button").text = action.Text
		button.visible = true
	
	visible = true

func clear() -> void: # очистка окна
	visible = false # по этому значению EventList будет определять что окно очищено
	_button.pressed = false # возвращаем в не нажатое состояние
	_button.mouse_filter = Control.MOUSE_FILTER_STOP # возвращаем способность реагировать на мышь
	
	_caption.text = ""
	_description.text = ""
	_description.visible = true
	_separator.visible = true
	
	for button in _action_buttons:
		button.visible = false

func _get_button() -> Button: # ищет в пуле незанятую кнопку или создает новую
	for button in _action_buttons:
		if not button.visible:
			return button
	
	var button = Resources.get_resource("Action").instance() as MarginContainer
	button.name += str(_action_buttons.size()) # прибавляем к имени индекс в массиве
	button.get_node("Button").connect("pressed", self, "_on_action_button_pressed", [button]) # передает ссылку на себя в качестве аргумента
	_container.add_child(button)
	_action_buttons.append(button)
	return button

func _on_pressed(): # нажатие на дочернюю кнопку, обозначающее выбор этого события
	emit_signal("pressed")

func _on_action_button_pressed(button: MarginContainer) -> void: # вызывается при нажатии на любую кнопку действия
	emit_signal("action_pressed") # для EventList
	_event.apply_action(_action_buttons.find(button))
