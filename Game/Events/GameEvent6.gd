extends GameEvent

#var merchant: GameEntity

func _init() -> void:
	name = "Странствующий торговец"
	description = "Бронированный фургон с надписью 'Обмен без обмана'. За рулем вооруженный охранник, а сбоку от него в кузове проделана прорезь для обмена товарами"

func _define_actions():
	_add_action("Торговать", "_trade")

func _trade() -> String:
	var merchant = E.create_entity("Человек")
	
	var possible_goods := [{"Хлеб":1}, {"Мясо":1}, {"Тушенка":1}, {"Нож":1}, {"Топор":0.75}, {"Бензопила":0.25}, {"Канистра с бензином":1}, {"Дробовик":0.2}, {"Патрон для дробовика":1}, {"Пистолет":0.75}, {"Патрон 9 мм":1}, {"Охотничья винтовка":0.5}, {"Патрон 7.62 мм":1}, {"Автоматическая винтовка":0.15}, {"Патрон 5.56 мм (х3)":1}, {"Радиоприемник":0.5}, {"Аккумулятор":1}, {"Динамит":0.1}] # расходники так же могут появиться в списке товаров, несмотря на наличие в нем использующей их сущности
	
	var quantity = 3 + randi() % 7 # даем торговцу от 3 до 7 случайных сущностей
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
	
	GUI.show_trade_panel(merchant)
	
	return ""


# торговая наценка, сортировка товаров у торговца
