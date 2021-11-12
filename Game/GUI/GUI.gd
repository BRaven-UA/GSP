# управляет теми частями интерфейса, для которых нет отдельного скрипта или необходимо внешнее управление

extends Node

onready var _viewport: Viewport = get_viewport()
onready var _root: Control = get_node("/root/MainControl")
onready var _main_container: Control = _root.get_node("MainContainer")
onready var _accept_dialog: AcceptDialog = _root.get_node("AcceptDialog")
onready var _trade_panel: Panel = _root.get_node("TradePanel")
onready var _continue: Button = _root.find_node("Continue")
onready var _entity_list: ItemList = _root.find_node("EntityList")
onready var _notes: RichTextLabel = _root.find_node("Notes")
onready var _center_container: CenterContainer = _root.find_node("CenterContainer")
onready var _health_bar: ProgressBar = _root.find_node("HealthBar")
onready var _health_bar_label: Label = _health_bar.get_node("HealthValue")
onready var _exp_bar: ProgressBar = _root.find_node("ExpBar")
onready var _countdown: Label = _root.find_node("Countdown")
onready var _timer: Timer = _root.get_node("Timer")

signal results_confirmed # сообщает что пользователь закрыл окно с результатами события
signal trade_complete # сообщает о закрытии окна торговли

func _ready() -> void:
	E.connect("player_entities_changed", self, "_on_player_entities_changed")
	E.connect("notebook_updated", self, "_on_notebook_updated")
	Game.connect("exp_changed", self, "_on_exp_changed")
	Game.connect("new_character", self, "_on_new_character")
	Game.connect("countdown", self, "_on_countdown")
	_notes.connect("meta_clicked", self, "_on_meta_clicked")
	_notes.connect("meta_hover_started", self, "_on_meta_hover")
	_continue.connect("pressed", Game, "new_character")
	_trade_panel.player_item_list = _entity_list
	_accept_dialog.connect("confirmed", self, "_on_accept_dialog_confirmed")
	
	var ok_button = _accept_dialog.get_ok()
	ok_button.rect_min_size = Vector2(100, 0) #  делаем шире для красоты
	
	var label = _accept_dialog.get_label()
	label.valign = Label.VALIGN_CENTER
	
	if OS.is_debug_build():
		yield(get_tree().create_timer(0.2), "timeout")
		Game.new_character()
	else:
		var intro = Resources.get_resource("Intro").instance()
		_root.add_child(intro)

func input_delay(): # создает задержку ввода чтобы случано не срабатывало несколько событий воода продряд
	_viewport.gui_disable_input = true
	_timer.start()
	yield(_timer, "timeout")
	_viewport.gui_disable_input = false

func show_accept_dialog(text: String): # отображение информационного окна с одной кнопкой "ОК"
	if text:
		_accept_dialog.dialog_text = text
		_accept_dialog.set_as_minsize()
		_accept_dialog.popup_centered_clamped(Vector2(250, 200))
	
		var ok_button = _accept_dialog.get_ok()
		ok_button.release_focus() # не смотрится когда сразу подсвечено

func show_trade_panel(merchant: GameEntity): # отображение окна торговли с игровой сущностью
	Logger.tip(Logger.TIP_TRADE)
	_trade_panel.show_panel(merchant)

func show_continue():
	_continue.visible = true

func toggle_notes():
	_center_container.visible = not _center_container.visible
	_notes.visible = not _notes.visible

func _on_accept_dialog_confirmed(): # пользователь закрыл окно с результатами события
	input_delay()
	emit_signal("results_confirmed")

func _on_player_entities_changed(entities: Array): # для обновления полоски здоровья
	var player_health = E.player.get_attribute(E.HEALTH)
	_health_bar.max_value = player_health.y
	_health_bar.value = player_health.x
	_health_bar_label.text = "%d/%d" % [player_health.x, player_health.y]
	if player_health.x < player_health.y * 0.95:
		Logger.tip(Logger.TIP_RESTORE)

func _on_new_character(entity: GameEntity):
	_continue.visible = false

func _on_countdown(turns: int):
	_countdown.text = str(turns)

func _on_exp_changed(value: int):
# warning-ignore:integer_division
	_exp_bar.min_value = value / 100 * 100
	_exp_bar.max_value = _exp_bar.min_value + 100
	_exp_bar.value = value
	_exp_bar.hint_tooltip = "текущий опыт %d/%d" % [value, _exp_bar.max_value]

func _on_notebook_updated(new_note: GameEntity):
	var caption = new_note.get_attribute(E.NAME)
	var note_text = new_note.get_attribute(E.DESCRIPTION)
	var bbcode = "\n[center]%s[/center]\n\n" % caption
	if caption.begins_with("Записка "):
		bbcode += "[font=%s]%s[/font]" %[Resources.get_resource("Handwritten_font").resource_path, note_text]
	else:
		bbcode += note_text
	_notes.append_bbcode(bbcode + "\n\n")

func _on_meta_clicked(meta):
	var event = EventManager.get_event(meta)
	if event:
		EventManager.toggle_tracking(event)

func _on_meta_hover(meta):
	Logger.tip(Logger.TIP_META)
	_notes.disconnect("meta_hover_started", self, "_on_meta_hover")
