# Продолжение цепочки событий "Неизвестный радиосигнал"

extends GameEvent

var secondary_condition := ["Топор", "Бензопила", "Динамит"]
var failed := false # попытка сдвинуть бревно неудалась, чтобы событие снова появилось в доступных нужно выполнить дополнительное требование

func _init() -> void:
	name = "Место, указанное в сигнале о помощи"
	description = "Прибыв на место вы обнаруживаете что входной люк привалило огромным деревом"

func is_available() -> bool:
	var primary: bool = E.player.find_entity(E.NAME, "Текст радиосигнала") != null
	
	if primary and failed:
		var secondary := false
		
		for value in secondary_condition:
			var entity = E.player.find_entity(E.NAME, value)
			if entity != null:
				var charges = entity.get_attribute(E.CAPACITY, true, Vector2(1, 1)) # один заряд для проверки на заряды
				if charges.x: # есть заряды
					secondary = true
					break # любой из вариантов подойдет
		
		return primary and secondary # нужны оба условия
	
	return primary

func _define_actions():
	_add_action("Сдвинуть дерево голыми руками", "_fail")
	
	for value in secondary_condition:
		var entity = E.player.find_entity(E.NAME, value)
		if entity != null:
			var charges = entity.get_attribute(E.CAPACITY, true, Vector2(1, 1)) # один заряд для проверки на заряды
			if charges.x: # есть заряды
				_add_action("Убрать дерево, используя %s" % value, "_success", [entity])

func _fail() -> String:
	failed = true
	
	var the_note: GameEntity = E.player.find_entity(E.NAME, "Текст радиосигнала")
	if the_note:
		the_note.set_attribute(E.DESCRIPTION, "Семья не может открыть входной люк в персональном подземном бункере.\nНеобходимо найти способ убрать дерево с люка")
	
	return "Непонятно на что вы рассчитывали, но сдвинуть такую\nмассу у вас никогда не получится. Вы решили что вернетесь\nсюда когда найдете способ убрать дерево с люка"

func _success(entity: GameEntity) -> String:
	var result_text := ""
	match entity.get_attribute(E.NAME):
		"Топор":
			result_text = "С помощью топора вы обрубили часть веток с одной\nстороны ствола чтобы не мешали. Используя одну из них\nкак рычаг, вы слегка перекатили дерево, освобождая\nвходной люк."
		"Бензопила":
			result_text = "Недолго думая, вы отпилили бензопилой часть ствола\nнад входным люком. Само дерево осталось на месте,\nдавая жителям бункера маскировку от любопытных глаз."
		"Динамит":
			result_text = "Вы долго выбирали место для установки динамита так,\nчтобы не повредить входной люк. Взрыв было слышно на\nмного километров вокруг, остатки дерева раскидало\nвокруг, а рядом с входным люком теперь красуется воронка."
	
	entity.change_attribute(E.CAPACITY if entity.get_attribute(E.CAPACITY) else E.QUANTITY) # расходуем заряд или предмет (если возможно)
	
	result_text += "\nВыбравшись на свободу, глава семейства благодарит\nвас за спасение и делится частью запасов из бункера"
	
	E.player.add_entity(E.create_entity("Хлеб", {E.QUANTITY:10}))
	E.player.add_entity(E.create_entity("Тушенка", {E.QUANTITY:10}))
	E.player.add_entity(E.create_entity("Дробовик", {E.CAPACITY:Vector2(6, 6)}))
	E.player.add_entity(E.create_entity("Патрон для дробовика", {E.QUANTITY:12}))
	E.player.add_entity(E.create_entity("Аккумулятор", {E.CAPACITY:Vector2(100, 100)}))
	E.player.add_entity(E.create_entity("Канистра с бензином", {E.CAPACITY:Vector2(10, 10)}))
	
	E.player.remove_entity(E.player.find_entity(E.NAME, "Текст радиосигнала"))
	
	return result_text


# !! добавить в награду какой-то важный предмет
