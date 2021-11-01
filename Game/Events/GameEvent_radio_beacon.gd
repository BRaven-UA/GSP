extends GameEvent

var tracked := false # сигнал не отслеживается

func _init() -> void:
	name = "Радиомаяк"
	description = "В радиоэфире раздаются периодические сигналы радиомаяка. По мощности сигнала можно попытаться отследить его местоположение"
	probability = 0.25
	distance = 5 + randi() % 76 # от 5% до 80%

func is_available() -> bool:
	return E.player.find_entity(E.NAME, "Прослушка радиоэфира", true) != null

func get_tracking_text(delta: int) -> String:
	if E.player.find_entity(E.NAME, "Прослушка радиоэфира", true) == null:
		return ""
	
	var text := "Радиомаяк: "
	var result_distance = distance + delta
	
	if distance > 97:
		text += "нет сигнала"
	elif distance < 10:
		text += "где-то рядом"
	else:
		text += "%d%% мощность сигнала" % (100 - result_distance)
	
	return text

func _define_actions():
	if tracked:
		if E.player.find_entity(E.NAME, "Аккумулятор"):
			_add_action("Зарядить аккумуляторы", "_charge")
		
		if E.player.find_entity(E.NAME, "Канистра с бензином"):
			_add_action("Слить бензин", "_fuel")
		
		_add_action("Обыскать помещение", "_search")
		
		EventManager.untrack_event(self)
	else:
		_add_action("Отслеживать сигнал", "_track")
		
		EventManager.track_event(self)

func _track():
	tracked = true
	description = "Перед вами небольшая частная взлетно-посадочная полоса. На ней имеются несколько технических построек, в числе которых и работающий радиомаяк. В помещении маяка никого нет, зато имеется работающий электрогенератор" # меняем описание под обнаружение маяка
	probability = 0 # исключаем повторное возникновение события
	return "Вы сделали пометку на шкале радиоприемника и стали\nрегулярно проверять уровень сигнала от радиомаяка"

func _charge():
	for entity in E.player.get_entities():
		if entity.get_attribute(E.NAME) == "Аккумулятор":
			entity.set_attribute(E.CAPACITY, 1000)
	
	E.player.change_attribute(E.HEALTH, 5) # "заряд бодрости"
	probability = 0.05 # можно вернуться, но не скоро
	return "Вы решили вздремнуть, пока заряжаются аккумуляторы.\nПроснувшись, вы почувствовали заряд бодрости"

func _fuel():
	var fuel := 10
	
	for entity in E.player.get_entities():
		if entity.get_attribute(E.NAME) == "Канистра с бензином":
			fuel = entity.change_attribute(E.CAPACITY, fuel) # разливаем остаток по канистрам
	
	probability = 0.0 # сигнала больше нет
	return "Заглушив двигатель электрогенератора, вы сливаете оставшийся\nбензин. В радиоэфире на этой частоте теперь тишина"

func search():
	E.player.add_entity(E.create_entity("Тушенка"))
	return "Порывшись в столе, среди кучи бумаг и канцелярского\nхлама вы обнаружили старую банку тушенки"


""""
- забрать электрогенератор??
"""
