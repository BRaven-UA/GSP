# Окно для отображения игрового события. Создается процедурно из EventList

extends MarginContainer

onready var _button: Button = find_node("Button") # кнопка отвечает за подсветку и выбор события
onready var _container: VBoxContainer = find_node("Container") # контейнер для полей события
onready var _caption: Label = find_node("Caption") # заголовок события
onready var _separator: TextureRect = find_node("Separator") # визуальный разграничитель
onready var _description: Label = find_node("Description") # описание события (скрывается при выборе события)
onready var _buttons := [] # пул кнопок для отображения доступных действий. Для экономии ресурсов отработанные кнопки не удаляются, а помещаются сюда для повторного использования
var _event: GameEvent # ссылка на событие

signal pressed # для дублирования сигнала с кнопки
signal action_pressed(action_index) # передает индекс нажатого действия


func _ready() -> void:
	_button.connect("pressed", self, "emit_signal", ["pressed"]) # дублируем сигнал с кнопки

func init(event: GameEvent) -> void: # формирование окна события для выбора из списка других событий
	_event = event
	_caption.text = _event.name
	_description.text = _event.description

func show_actions() -> void: # формирование списка возможных действий для события
	_description.visible = false # детальное описание и разграничитель на этом этапе не нужны
	_separator.visible = false
	_button.mouse_filter = Control.MOUSE_FILTER_IGNORE # чтобы нельзя было триггерить кнопку
	
	for action in _event.actions:
		var button = _get_button() # получаем ссылку на пустую кнопку
		button.get_node("Button").text = action
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
	
	for button in _buttons:
		button.visible = false

func _get_button() -> Button: # ищет в пуле незанятую кнопку или создает новую
	for button in _buttons:
		if not button.visible:
			return button
	
	var button = Resources.get_resource("Action").instance() as MarginContainer
	button.name += str(_buttons.size()) # прибавляем к имени индекс в массиве
	button.get_node("Button").connect("pressed", self, "_on_button_pressed", [button]) # передает ссылку на себя в качестве аргумента
	_container.add_child(button)
	_buttons.append(button)
	return button

func _on_button_pressed(button: MarginContainer) -> void: # вызывается при нажатии на любую кнопку действия
	emit_signal("action_pressed", _buttons.find(button))
