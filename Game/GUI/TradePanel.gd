extends Panel

const ELECTRO_TEXT := "Электричество (%d)"
const FUEL_TEXT := "Бензин (%d)"
onready var _merchant_item_list: ItemList = find_node("ItemList")
onready var _menu: PopupMenu = _merchant_item_list.get_node("Menu")
onready var _label: Label = find_node("Cost")
onready var _refill_label: Label = find_node("RefillLabel")
onready var _refill_container: Container = find_node("RefillContainer")
onready var _electo_label: Label = find_node("ElectroLabel")
onready var _electo_slider: Slider = find_node("ElectroSlider")
onready var _fuel_label: Label = find_node("FuelLabel")
onready var _fuel_slider: Slider = find_node("FuelSlider")
onready var _confirm: Button = find_node("Confirm")
onready var _cancel: Button = find_node("Cancel")

var player_item_list: ItemList
var _player_selection: Array # эти два массива получают по ссылке от EntityManager и изменяют чтобы не передавать их по сигналу
var _merchant_selection: Array
var _player_item_cost: int # кэшируем обе суммы чтобы лишний раз не пересчитывать
var _merchant_item_cost: int
var _player_electro_consumables: Array # кэшируем список электро/бензиновых расходников игрока
var _player_fuel_consumables: Array
var _max_electro: int # максимальное количество электричества/бензина на продажу
var _max_fuel: int
var _player_max_electro: int # максимальное количество электричества/бензина нужное игроку
var _player_max_fuel: int
var _merchant_markup: float # наценка торговца


func _ready() -> void:
	_merchant_item_list.connect("multi_selected", self, "_on_item_list_multiselected", [_merchant_item_list])
	_merchant_item_list.connect("item_rmb_selected", self, "_on_item_list_rmb_selected")
	_merchant_item_list.connect("nothing_selected", self, "_on_item_list_nothing_selected", [_merchant_item_list])
	_menu.connect("id_pressed", self, "_on_menu_item_pressed")
	_electo_slider.connect("value_changed", self, "_on_refill_changed", [_electo_slider])
	_fuel_slider.connect("value_changed", self, "_on_refill_changed", [_fuel_slider])
	_confirm.connect("pressed", self, "_on_confirm_pressed")
	_cancel.connect("pressed", self, "_on_cancel_pressed")

func _clear():
	_player_selection.clear()
	_merchant_selection.clear()
	_player_electro_consumables.clear()
	_player_fuel_consumables.clear()
	_max_electro = 0
	_max_fuel = 0
	_player_max_electro = 0
	_player_max_fuel = 0
	_player_item_cost = 0
	_merchant_item_cost = 0
	
	if E.is_connected("player_entities_changed", self, "_on_player_entities_changed"):
		E.disconnect("player_entities_changed", self, "_on_player_entities_changed")
	player_item_list.select_mode = ItemList.SELECT_SINGLE
	player_item_list.disconnect("multi_selected", self, "_on_item_list_multiselected") # чтобы впустую не обрабатывать событие при скрытом окне торговли
	player_item_list.disconnect("nothing_selected", self, "_on_item_list_nothing_selected")
	
	visible = false
	_set_refill()
	_merchant_item_list.clear()
	_label.text = ""
	_confirm.disabled = true
	
	GUI.emit_signal("trade_complete")

func _set_refill():
	_refill_label.visible = bool(_max_electro + _max_fuel)
	_refill_container.visible = bool(_max_electro + _max_fuel)
	_electo_label.text = ELECTRO_TEXT % 0
	_electo_label.visible = bool(_max_electro)
	_electo_slider.visible = bool(_max_electro)
	_electo_slider.value = 0
	_electo_slider.max_value = _max_electro if _max_electro < _player_max_electro else _player_max_electro
	_fuel_label.text = FUEL_TEXT % 0
	_fuel_label.visible = bool(_max_fuel)
	_fuel_slider.visible = bool(_max_fuel)
	_fuel_slider.value = 0
	_fuel_slider.max_value = _max_fuel if _max_fuel < _player_max_fuel else _player_max_fuel

func show_panel(merchant: GameEntity, electro := 0, fuel := 0):
	_max_electro = electro
	_max_fuel = fuel
	_merchant_markup = 1.05 if E.player.find_entity(E.NAME, "Красноречие", true) else 1.2
	_update_consumables()
	_update_list(merchant)
	_set_refill()
	
	player_item_list.select_mode = ItemList.SELECT_MULTI
	player_item_list.connect("multi_selected", self, "_on_item_list_multiselected", [player_item_list])
	player_item_list.connect("nothing_selected", self, "_on_item_list_nothing_selected", [player_item_list])
	E.connect("player_entities_changed", self, "_on_player_entities_changed")
	
	visible = true

func _update_list(merchant: GameEntity): # заполняет заново список предметов торговца
	_merchant_item_list.clear()
	
	for entity in merchant.get_entities():
		if entity.get_attribute(E.CLASS) != E.CLASSES.ABILITY:
			var index = _merchant_item_list.get_item_count() # индекс для нового пункта
			_merchant_item_list.add_item(entity.get_text())
			_merchant_item_list.set_item_tooltip(index, entity.get_full_info())
			_merchant_item_list.set_item_metadata(index, entity) # сохраняем ссылку на сущность
	
	_merchant_item_list.sort_items_by_text()
	
	_update_offers(_merchant_item_list)

func _update_consumables(): # обновление списков и общих вместимостей расходников игрока для пополнения
	if _max_electro + _max_fuel: # есть возможность пополнить что-либо
		for entity in E.player.get_entities():
			var _name = entity.get_attribute(E.NAME)
			var consumables = entity.get_attribute(E.CONSUMABLES)
			var capacity = entity.get_attribute(E.CAPACITY)
			
			if _name == "Аккумулятор" and _max_electro:
				_player_electro_consumables.push_front(entity) # виртуальные расходники ставим впереди чтобы потом при покупке они заполнялись первыми
				_player_max_electro += int(capacity.y - capacity.x)
			
			if consumables == "Аккумулятор" and _max_electro:
				_player_electro_consumables.push_back(entity)
				_player_max_electro += int(capacity.y - capacity.x)
			
			if _name == "Канистра с бензином" and _max_fuel:
				_player_fuel_consumables.push_front(entity) # виртуальные расходники ставим впереди чтобы потом при покупке они заполнялись первыми
				_player_max_fuel += int(capacity.y - capacity.x)
			
			if consumables == "Канистра с бензином" and _max_fuel:
				_player_fuel_consumables.push_back(entity)
				_player_max_fuel += int(capacity.y - capacity.x)

func _update_offers(item_list: ItemList = null): # обновляет данные о предложениях сторон
	if item_list: # нужно обновить стоимость товаров в списке
		var entities = _player_selection if item_list == player_item_list else _merchant_selection
		entities.clear()
		
		var item_cost := 0
		for index in item_list.get_selected_items():
			var entity = item_list.get_item_metadata(index)
			item_cost += entity.get_cost()
			entities.append(entity)
		
		if item_list == player_item_list:
			_player_item_cost = item_cost
		else:
			_merchant_item_cost = item_cost
	
	var merchant_total_cost := int((_merchant_item_cost + (_electo_slider.value + _fuel_slider.value) * E.DEF_CONS_COST) * _merchant_markup)
	
	_label.text = "%d\n%d" % [_player_item_cost, merchant_total_cost]
	_confirm.disabled = _player_item_cost < merchant_total_cost or _player_item_cost < 1

func _on_player_entities_changed(entities: Array):
	_player_selection.clear()
	_player_item_cost = 0
	_update_consumables()
	_update_offers(player_item_list)

func _on_item_list_multiselected(index: int, selected: bool, item_list: ItemList): # по сингналу от списков
	_update_offers(item_list)

func _on_item_list_rmb_selected(index: int, position: Vector2): # меню разделения предметов
	var entity: GameEntity = _merchant_item_list.get_item_metadata(index)
	var quantity = entity.get_attribute(E.QUANTITY, true, 0)
	
	if quantity > 1:
		_menu.set_meta("entity", entity)
		
		_menu.set_item_text(0, "Отделить 1 шт.")
		_menu.set_item_metadata(0, 1) # тут хранится текущее количество (по умолчанию 1)
		
		_menu.set_item_disabled(1, quantity == 2) # сразу нельзя увеличить до максимума
		_menu.set_item_disabled(2, true) # сразу нельзя уменьшить до нуля
		
		_menu.rect_position = rect_position + position + Vector2(10, 0) # устанавливаем позицию меню чуть правее от места клика
		_menu.rect_size = Vector2.ZERO # корректируем размер (Годо без багов не бывает)
		_menu.popup()

func _on_menu_item_pressed(index: int): # выбор пункта меню разделения предметов
	var entity: GameEntity = _menu.get_meta("entity")
	var quantity = _menu.get_item_metadata(0)
	
	match index:
		0: # подтверждение количества
			entity.change_attribute(E.QUANTITY, -quantity)
			var new_entity = E.create_entity(entity.get_attribute(E.NAME)) # TODO: сделать полноценное дублирование со свсем возможными нестандартными изменениями сущности
			new_entity.set_attribute(E.QUANTITY, quantity)
			
			var merchant = entity.owner
			merchant.add_entity(new_entity, false, false) # без автообъединения
			_update_list(merchant)
			
			_menu.hide()
		1: # +1
			quantity += 1
			_menu.set_item_disabled(2, false) # разблокируем обратное действие
			if quantity > entity.get_attribute(E.QUANTITY) - 2:
				_menu.set_item_disabled(1, true)
		2: # -1
			quantity -= 1
			_menu.set_item_disabled(1, false) # разблокируем обратное действие
			if quantity < 2:
				_menu.set_item_disabled(2, true)
	
	_menu.set_item_text(0, "Отделить %d шт." % quantity)
	_menu.set_item_metadata(0, quantity)

func _on_item_list_nothing_selected(item_list: ItemList):
	item_list.unselect_all()
	_on_item_list_multiselected(0, false, item_list)

func _on_refill_changed(value: float, slider: Slider):
	match slider:
		_electo_slider:
			_electo_label.text = ELECTRO_TEXT % value
		_fuel_slider:
			_fuel_label.text = FUEL_TEXT % value
	_update_offers()

func _on_confirm_pressed():
	GUI.input_delay()
	
	E.disconnect("player_entities_changed", self, "_on_player_entities_changed")
	E.player.remove_entities(_player_selection)
	E.player.add_entities(_merchant_selection)
	
	var electro = int(_electo_slider.value)
	for entity in _player_electro_consumables:
		if not electro:
			break
		electro = entity.change_attribute(E.CAPACITY, electro)
	
	var fuel = int(_fuel_slider.value)
	for entity in _player_fuel_consumables:
		if not fuel:
			break
		fuel = entity.change_attribute(E.CAPACITY, fuel)
	
	_clear()

func _on_cancel_pressed():
	GUI.input_delay()
	_clear()
