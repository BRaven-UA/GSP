extends GameEvent

var merchant: GameEntity

func _init() -> void:
	name = "Ветряная электростанция"
	description = "Перед вами огороженный участок равнины с несколькими ветрогенераторами. На входе вооруженная охрана и зарядная станция"
	probability = 0.1
	distance = 100 + randi() % 51

func setup():
	bonus_info = ""
	merchant = E.create_entity("Человек")
	var goods =[E.create_entity("Аккумулятор", {E.CAPACITY:Vector2(10, 100)}), E.create_entity("Аккумулятор", {E.CAPACITY:Vector2(50, 100)}), E.create_entity("Аккумулятор", {E.CAPACITY:Vector2(100, 100)})]
	merchant.add_entities(goods)
	_target_bonus_info(merchant)

func _define_actions():
	_add_action("Торговать", "_trade")

func _trade() -> String:
	Game.state = Game.STATE_TRADE
	GUI.show_trade_panel(merchant, 1000)
	return ""



"""
? можно отслеживать
"""
