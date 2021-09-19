# Элемент GUI для отображения списка предметов игрока
# массив предметов передает player через сигнал (ОСТОРОЖНО! передается не дубликат массива, а ссылка на оригинал)

extends ItemList

enum MENU_ITEMS {USE, DELETE} # перечень возможных ID для меню предметов

onready var _menu := $"PopupMenu" # контекстное меню предметов (одно на все предметы, обновляется под выбранный предмет)


func _ready() -> void:
	clear()
	
	Global.player.connect("items_changed", self, "_update_list") # обновляем список при любом изменении предметов игрока
	connect("item_rmb_selected", self, "_show_menu")
	_menu.connect("id_pressed", self, "_on_menu_item_pressed")

func _add_item(item: Dictionary) -> void:
	if item:
		add_item(item[DB.KEYS.NAME])
		var index = get_item_count()
		set_item_tooltip(index - 1, item[DB.KEYS.DESCRIPTION])
		set_item_metadata(index - 1, item) # сохраняем ссылку на предмет
	else:
		push_warning("Попытка добавить пустой предмет в ItemList !")
		print_stack()

func _update_list(items: Array) -> void: # сюда передается управление по сигнлу от player
	clear()
	
	for item in items:
		_add_item(item)

func _show_menu(index: int, position: Vector2) -> void: # формирование меню по индексу предмета
	_menu.rect_position = rect_position + position + Vector2(10, 0) # устанавливаем позицию меню чуть правее от места клика
	
	_menu.clear()
	
	var item = get_item_metadata(index)
	
	if DB.KEYS.USES in item:
		_menu.add_item("Использовать", MENU_ITEMS.USE)
	_menu.add_item("Удалить", MENU_ITEMS.DELETE)
	
	_menu.set_meta("item", item) # сохраняем ссылку на предмет
	
	_menu.rect_size = Vector2.ZERO # корректируем размер (Годо без багов не бывает)
	_menu.popup()

func _on_menu_item_pressed(index: int) -> void: # обработка нажатий на пункты контекстного меню
	var item = _menu.get_meta("item")
		
	match index:
		MENU_ITEMS.USE:
			pass
		MENU_ITEMS.DELETE:
			Global.player.remove_item(item)
