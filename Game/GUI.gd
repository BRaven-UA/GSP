# управляет теми частями интерфейса, для которых нет отдельного скрипта или необходимо внешнее управление

extends Node

#class_name GameGUI

onready var _root: Control = get_node("/root/MainControl")
onready var _accept_dialog: AcceptDialog = _root.get_node("AcceptDialog")
onready var _log_frame: RichTextLabel = _root.get_node("Log")
onready var _health_bar: ProgressBar = _root.get_node("HealthBar")
onready var _health_bar_label: Label = _health_bar.get_node("Label")

signal results_confirmed # сообщает что пользователь закрыл окно с результатами события

func _ready() -> void:
	_root.get_node("TestButton").connect("pressed", Game, "test_start") # только для тестирования
	Logger.connect("new_log_record", self, "_on_new_log_record")
	E.connect("player_entities_changed", self, "_on_player_entities_changed")
	_accept_dialog.connect("confirmed", self, "_on_accept_dialog_confirmed")
	
	var ok_button = _accept_dialog.get_ok()
	ok_button.rect_min_size = Vector2(100, 0) #  делаем шире для красоты
	
	var label = _accept_dialog.get_label()
	label.valign = Label.VALIGN_CENTER

func show_accept_dialog(text: String): # отображение информационного окна с одной кнопкой "ОК"
	_accept_dialog.dialog_text = text
	_accept_dialog.set_as_minsize()
	_accept_dialog.popup_centered_clamped(Vector2(250, 200))
	
	var ok_button = _accept_dialog.get_ok()
	ok_button.release_focus() # не смотрится когда сразу подсвечено

func _on_accept_dialog_confirmed(): # пользователь закрыл окно с результатами события
	emit_signal("results_confirmed")

func _on_new_log_record(info: String): # обновляется по сигналу от синглтона Logger
	_log_frame.add_text(info)
	_log_frame.newline()

func _on_player_entities_changed(entities): # для обновления полоски здоровья
	var player_health = E.player.get_attribute(E.HEALTH)
	_health_bar.max_value = player_health.y
	_health_bar.value = player_health.x
	_health_bar_label.text = "%d/%d" % [player_health.x, player_health.y]
