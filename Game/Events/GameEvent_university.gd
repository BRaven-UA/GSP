extends GameEvent

var guard: GameEntity

func _init() -> void:
	name = "Университет"
	description = "Здание университета было заброшено и разграблено. У входа караулит мускулистый головорез с дробовиком. Видимо теперь это штаб какой-то банды"
	probability = 0.0
	distance = 10#150 + randi() % 151 # от 150 до 300
	new_character_data = {"Text":"Проходя рядом со зданием бывшего университета, а ныне\nпритона отмороженных бандитов, в овраге у дороги вы\nзамечаете труп. Тело сильно изуродовано, видимо это\nбыла жертва банды, над которой они хорошенько\nпоиздевались. Решив, что ему уже все равно вы обыскиваете\nтруп, но не находите ничего кроме какой-то записной\nкнижки.", "Heir":null, "Remains":[E.REMAINS.ONLY_NOTEBOOK]}

func get_tracking_text(delta: int) -> String:
	var text := "Университет: "
	var result_distance = distance + delta
	if result_distance < 10:
		text += "где-то рядом"
	else:
		text += "расстояние %d" % result_distance
	return text

func setup():
	bonus_info = "Опытный противник, мало шансов прокрасться мимо, но можно попробовать его отвлечь"
	guard = E.create_person([{"Дробовик":1}], 120) # больше здоровья чем обычно
	_target_bonus_info(guard)

func _define_actions():
	_add_hostile_actions(guard)
	_add_action("Прокрасться мимо охранника", "_sneak")
	
	var dog = E.player.find_entity(E.NAME, "Собака")
	if dog:
		_add_action("Отвлечь с помощью собаки", "_divert_with_dog", [dog])
	var radio = E.player.find_entity(E.NAME, "Радиоприемник", true) # включенный радиоприемник
	if radio:
		_add_action("Отвлечь с помощью радиоприемника", "_divert_with_radio", [radio])
	
	_add_action("Отступить", "_retreat")

func _duel(defender: GameEntity, attacker: GameEntity = E.player) -> String:
	var result_text = ._duel(defender, attacker)
	
	if defender.get_attribute(E.HEALTH).x < 1:
		defender.remove_entity(defender.find_entity(E.NAME, "Удар"))
		E.player.add_entities(defender.get_entities())
		guard = null
		result_text += _success()
	
	return result_text

func _sneak():
	if randf() < 0.2: # удалось прокрасться
		return "Вам повезло: вскоре охранник отлучился отлить, и вы\nмигом прошмыгнули внутрь.\n" + _success()
	else:
		E.player.set_attribute(E.HEALTH, 0)
		return "Это с самого начала была глупая идея.\nКонечно же вам не удалось пробраться незамеченным\nмимо этого громилы. Вас схватили, долго мучали и\nизбивали на потеху всей банде.\nЭто была самая мучительная смерть из всех возможных ..."

func _divert_with_dog(dog: GameEntity):
	E.player.remove_entity(dog)
	return "Вы привязали собаку к столбу у дороги, а сами незаметно\nобошли к противоположной стороне входа. Через некоторое\nвремя собака устала ждать и начала лаять. Охранник\nпошел проверить что происходит, а вы в это время\nбыстро прошмыгнули внутрь.\n" + _success()

func _divert_with_radio(radio: GameEntity):
	E.player.remove_entity(radio)
	return "Прикинув примерное время на ходьбу от входа университета,\nвы подыскали подходящее место за углом и включили\nрадиоприемник. Шум радиопомех начал раздаваться по\nокруге, а вы бегом кинулись вокруг здания университета,\nчтобы успеть к противоположной стороне входа. Пока\nохранник ходил проверять что происходит, вы успели\nбыстро прошмыгнули внутрь.\n" + _success()

func _success() -> String:
	E.player.add_entity(E.create_entity("Документы из университета"))
	EventManager.remove_event(self)
	return "Попав в здание университета, вы аккуратно обходите\nобжитые бандитами помещения и поднимаетесь на второй\nэтаж к кабинетам преподавателей. Обыскав несколько\nкабинетов, вы наконец находите личные вещи нужного\nчеловека. Прихватив несколько бумаг, а также какие-то\nкниги, вы покидаете здание, стараясь не привлекать\nвнимания его обитателей"

func _retreat():
	return "Прикинув свои шансы на попадание внутрь вы решили\nпока отложить эту затею. Наверное, стоит вернуться\nсюда более подготовленным"



"""
- книги для изучения
"""
