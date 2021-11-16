extends GameEvent

var merchant: GameEntity

func _init() -> void:
	name = "АЗС"
	description = "Автозаправочная станция переоборудована в химлабораторию. Тут продают низкокачественный бензин"
	probability = 0.1

func get_tracking_text(delta: int) -> String:
	return _default_tracking_text(delta)

func setup():
	merchant = E.create_entity("Человек")
	var goods =[E.create_entity("Канистра с бензином", {E.CAPACITY:Vector2(2, 10)}), E.create_entity("Канистра с бензином", {E.CAPACITY:Vector2(5, 10)}), E.create_entity("Канистра с бензином", {E.CAPACITY:Vector2(10, 10)})]
	merchant.add_entities(goods)

func _define_actions():
	_add_action("Торговать", "_trade")

func _trade() -> String:
	if E.player.find_entity(E.NAME, "Координаты АЗС") == null:
		E.player.add_entity(E.create_entity("Координаты АЗС"))
	Game.state = Game.STATE_TRADE
	GUI.show_trade_panel(merchant, 0, 100)
	return ""



"""
? можно отслеживать
"""
