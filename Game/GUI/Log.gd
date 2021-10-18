extends RichTextLabel

const COLORS := {Logger.INGAME:"ffffff", Logger.INGAME_DAMAGE:"ff5959", Logger.INGAME_HEAL:"59ff67", Logger.INGAME_EXP:"ffdd59", Logger.INGAME_TAKE:"59b1ff", Logger.INGAME_LOSS:"808080", Logger.TIP:"ffff00"}

onready var _menu: PopupMenu = $Menu

func _ready() -> void:
	Logger.connect("new_log_record", self, "_on_new_log_record")
	Game.connect("new_attempt", self, "_on_new_attempt")
	_menu.connect("id_pressed", self, "_on_menu_item_pressed")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and not event.pressed: # по отжатию правой кнопки мыши
			_menu.rect_position = rect_position + event.position + Vector2(10, 0) # устанавливаем позицию меню чуть правее от места клика
			_menu.rect_size = Vector2.ZERO # корректируем размер (Годо без багов не бывает)
			_menu.popup()

func _on_new_log_record(record: Dictionary): # обновляется по сигналу от синглтона Logger
	if _menu.is_item_checked(record.Category):
		if record.Category == Logger.TIP:
			newline()
			push_align(RichTextLabel.ALIGN_CENTER)
			add_image(Resources.get_resource("INFO"))
			newline()
			push_font(Resources.get_resource("Regular_Font"))
			_log_print(record.Text, record.Category)
			newline()
			add_image(Resources.get_resource("INFO"))
			newline()
			pop()
			pop()
		else:
			_log_print("[{Time}] {Text}".format(record), record.Category)

func _log_print(text: String, category: int = Logger.INGAME): # выводит текст в лог
	push_color(Color(COLORS[category]))
	add_text(text)
	pop()
	newline()

func _on_new_attempt():
	clear()

func _on_menu_item_pressed(id: int):
	var index = _menu.get_item_index(id)
	
	if _menu.is_item_checkable(index):
		_menu.toggle_item_checked(index)
	
	if id == 50:
		clear()
