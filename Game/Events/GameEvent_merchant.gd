extends GameEvent

var merchant: GameEntity
var names := ["Обмен без обмана", "Лавка на колесах", "Наномаркет"] # количество торговцев
var name_index: int

func _init() -> void:
	name = "Странствующий торговец"
	_set_merchant()

func _set_merchant():
	probability = names.size() / 3.0 # шанс появления зависит от количества живых торговцев
	if probability:
		name_index = randi() % names.size()
		description = "Бронированный фургон с надписью '%s'. За рулем вооруженный охранник, а сбоку от него в кузове проделана прорезь для обмена товарами" % names[name_index]

func setup():
	merchant = E.create_entity("Человек")
	
	var possible_goods := [{"Хлеб":1}, {"Мясо":1}, {"Тушенка":1}, {"Нож":1}, {"Топор":0.75}, {"Бензопила":0.25}, {"Канистра с бензином":1}, {"Дробовик":0.2}, {"Патрон для дробовика":1}, {"Пистолет":0.75}, {"Патрон 9 мм":1}, {"Охотничья винтовка":0.5}, {"Патрон 7.62 мм":1}, {"Автоматическая винтовка":0.15}, {"Патрон 5.56 мм (х3)":1}, {"Радиоприемник":0.5}, {"Аккумулятор":1}, {"Динамит":0.1}] # расходники так же могут появиться в списке товаров, несмотря на наличие в нем использующей их сущности
	
	var quantity = 5 + randi() % 6 # даем торговцу от 5 до 10 случайных сущностей
	for i in quantity:
		var name = E.randw(possible_goods)
		var data = E.get_base_entity(name)
		
		if name in ["Хлеб", "Мясо", "Тушенка"]:
			data[E.QUANTITY] = 1 + randi() % 3
		
		if name.begins_with("Патрон"):
			data[E.QUANTITY] = 5 + randi() % 30
		
		var consumable_name = data.get(E.CONSUMABLES)
		if consumable_name: # если у сущности есть расходники, добавляем их
			var consumable_data = E.get_base_entity(consumable_name)
			
			if consumable_data.has(E.QUANTITY):
				consumable_data[E.QUANTITY] = 5 + randi() % 30
			else:
				consumable_data[E.CAPACITY].x = consumable_data[E.CAPACITY].y
		
			merchant.add_entity(E.create_entity(consumable_data))
		
		merchant.add_entity(E.create_entity(data))

func _define_actions():
	_add_action("Торговать", "_trade")
	
	var explosive = E.player.find_entity(E.NAME, "Динамит")
	if explosive:
		_add_action("Подорвать фургон торговца", "_blow_up", [explosive])

func _trade() -> String:
	GUI.show_trade_panel(merchant)
	_set_merchant() # меняем следующего торговца
	return ""

func _blow_up(entity: GameEntity):
	entity.change_attribute(E.QUANTITY)
	
	var weapon = E.create_entity(E.randw([{"Пистолет":1}, {"Дробовик":0.75}, {"Автоматическая винтовка":0.5}])) # оружие охранника
	weapon.set_attribute(E.CAPACITY, 1000) # максимальный заряд (лишнее отсечется)
	E.player.add_entity(weapon)
	
	for entity in merchant.get_entities():
		if entity.get_attribute(E.CLASS) == E.CLASSES.ITEM:
			E.player.add_entity(entity)
	
	names.remove(name_index) # удаляем из списка торговцев
	_set_merchant() # меняем следующего торговца
	
	return "Подкравшись к фургону так, чтобы вас не заметил\nохранник, вы подложили под днище динамит и бросились\nв укрытие. Охранник вас заметил, но ничего не успел\nсделать - фургон взлетел на воздух и приземлился на\nбок. Вы без проблем расправились с контуженным\nохранником, после чего проникли в кузов через\nразвороченное дно фургона, добили торговца и забрали\nвсе ценное."
