# управляет теми частями интерфейса, для которых нет отдельного скрипта или необходимо внешнее управление

extends Control

class_name GameGUI

onready var _event_results: AcceptDialog = get_node("EventResults")


func _enter_tree() -> void:
	Global.gui = self

func _ready() -> void:
	var ok_button = _event_results.get_ok()
	ok_button.rect_min_size = Vector2(100, 0) #  делаем шире для красоты
	
	var label = _event_results.get_label()
	label.valign = Label.VALIGN_CENTER

func show_event_results(text: String) -> void: # отображение окна с результатами закончившегося события
	_event_results.dialog_text = text
	_event_results.popup_centered_clamped()
	
	var ok_button = _event_results.get_ok()
	ok_button.release_focus() # не смотрится когда сразу подсвечено
