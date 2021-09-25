# управляет теми частями интерфейса, для которых нет отдельного скрипта или необходимо внешнее управление

extends Node

class_name GameGUI

onready var _root: Control = get_node("/root/GUI")
onready var _accept_dialog: AcceptDialog = _root.get_node("AcceptDialog")


func _ready() -> void:
	var ok_button = _accept_dialog.get_ok()
	ok_button.rect_min_size = Vector2(100, 0) #  делаем шире для красоты
	
	var label = _accept_dialog.get_label()
	label.valign = Label.VALIGN_CENTER

func show_accept_dialog(text: String) -> AcceptDialog: # отображение информационного окна с одной кнопкой "ОК"
	_accept_dialog.dialog_text = text
	_accept_dialog.set_as_minsize()
	_accept_dialog.popup_centered_clamped(Vector2(250, 200))
	
	var ok_button = _accept_dialog.get_ok()
	ok_button.release_focus() # не смотрится когда сразу подсвечено
	
	return _accept_dialog
