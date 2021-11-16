extends GameEvent

var merchant: GameEntity

func _init() -> void:
	name = "Ветряная электростанция"
	description = "Перед вами огороженный участок равнины с несколькими ветрогенераторами. На входе вооруженная охрана и зарядная станция"
	probability = 0.1

func get_tracking_text(delta: int) -> String:
	return _default_tracking_text(delta)

func setup():
	merchant = E.create_entity("Человек")
	var goods =[E.create_entity("Аккумулятор", {E.CAPACITY:Vector2(10, 100)}), E.create_entity("Аккумулятор", {E.CAPACITY:Vector2(50, 100)}), E.create_entity("Аккумулятор", {E.CAPACITY:Vector2(100, 100)})]
	merchant.add_entities(goods)

func _define_actions():
	_add_action("Торговать", "_trade")

func _trade() -> String:
	if E.player.find_entity(E.NAME, "Координаты ВЭС") == null:
		E.player.add_entity(E.create_entity("Координаты ВЭС"))
	Game.state = Game.STATE_TRADE
	GUI.show_trade_panel(merchant, 1000)
	return ""



"""
? можно отслеживать
"""
