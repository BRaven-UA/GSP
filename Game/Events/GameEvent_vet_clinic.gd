extends GameEvent

var entity: GameEntity

func _init() -> void:
	name = "Ветеринарная клиника"
	description = "Здание ветеринарной клиники. Внутри никого"
	probability = 0.001
	distance = 100 + randi() % 101

func get_tracking_text(delta: int) -> String:
	return _default_tracking_text(delta)

func _define_actions():
	_add_action("Обыскать", "_search")

func _search():
	E.player.add_entity(E.create_entity("Журнал ветеринара"))
	EventManager.remove_event(self)
	return "Обыскав все здание вы находите только\nлисток из журнала ветеринара"


"""
- хирургический набор для лечения травм?
"""
