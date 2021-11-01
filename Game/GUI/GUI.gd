# управляет теми частями интерфейса, для которых нет отдельного скрипта или необходимо внешнее управление

extends Node

onready var _root: Control = get_node("/root/MainControl")
onready var _accept_dialog: AcceptDialog = _root.get_node("AcceptDialog")
onready var _trade_panel: Panel = _root.get_node("TradePanel")
#onready var _log_frame: RichTextLabel = _root.find_node("Log")
onready var _entity_list: ItemList = _root.find_node("EntityList")
#onready var _perk_list: ItemList = _root.find_node("PerkList")
onready var _health_bar: ProgressBar = _root.find_node("HealthBar")
onready var _health_bar_label: Label = _health_bar.get_node("Label")
onready var _exp_bar: ProgressBar = _root.find_node("ExpBar")

signal results_confirmed # сообщает что пользователь закрыл окно с результатами события
signal trade_complete # сообщает о закрытии окна торговли

func _ready() -> void:
	_root.find_node("NewGame").connect("pressed", Game, "new_attempt") # только для тестирования
	
	E.connect("player_entities_changed", self, "_on_player_entities_changed")
	Game.connect("exp_changed", self, "_on_exp_changed")
	_trade_panel.player_item_list = _entity_list
	_accept_dialog.connect("confirmed", self, "_on_accept_dialog_confirmed")
	
	var ok_button = _accept_dialog.get_ok()
	ok_button.rect_min_size = Vector2(100, 0) #  делаем шире для красоты
	
	var label = _accept_dialog.get_label()
	label.valign = Label.VALIGN_CENTER

func _on_exp_changed(value: int):
# warning-ignore:integer_division
	_exp_bar.min_value = value / 100 * 100
	_exp_bar.max_value = _exp_bar.min_value + 100
	_exp_bar.value = value
	_exp_bar.hint_tooltip = "текущий опыт %d/%d" % [value, _exp_bar.max_value]

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

func _on_accept_dialog_confirmed(): # пользователь закрыл окно с результатами события
	emit_signal("results_confirmed")

func _on_player_entities_changed(entities: Array): # для обновления полоски здоровья
	var player_health = E.player.get_attribute(E.HEALTH)
	_health_bar.max_value = player_health.y
	_health_bar.value = player_health.x
	_health_bar_label.text = "%d/%d" % [player_health.x, player_health.y]
	if player_health.x < player_health.y * 0.95:
		Logger.tip(Logger.TIP_RESTORE)
