# Синглтон менеджер сущностей. Все операции с сущностями должны проходить через этот синглтон

extends Node

enum {NAME, CLASS, DESCRIPTION, HEALTH, TYPE, GROUP, CHANGE_HEALTH, CONSUMABLES, CAPACITY, QUANTITY, COST, ACTIVE, ATTACHMENT} # перечень атрибутов
const ATTRIBUTES := ["NAME", "CLASS", "DESCRIPTION", "HEALTH", "TYPE", "GROUP", "CHANGE_HEALTH", "CONSUMABLES", "CAPACITY", "QUANTITY", "COST", "ACTIVE", "ATTACHMENT"] # не хочу давать имя enum, так как в коде плохо читается 
enum TYPES {BIOLOGICAL, MECHANICAL, DIGITAL, MENTAL} # перечень типов для атрибута TYPE
enum GROUPS {FOOD} # перечень групп, для объединения разных типов сущностей
enum CLASSES {CREATURE, ITEM, ABILITY}
#enum OPERATIONS {EQUAL, LESS, GREATER} # перечень допустимых операций при поиске аттрибутов

var player: GameEntity # ссылка на сущность игрока

signal player_entities_changed

const ENTITIES := [
	{NAME:"Игрок", CLASS:CLASSES.CREATURE, DESCRIPTION:"Персонаж за которого вы играете", TYPE:TYPES.BIOLOGICAL, HEALTH:Vector2(100, 100), ATTACHMENT:["Удар"]},
	{NAME:"Человек", CLASS:CLASSES.CREATURE, DESCRIPTION:"Неигровой персонаж", TYPE:TYPES.BIOLOGICAL, HEALTH:Vector2(100, 100), ATTACHMENT:["Удар"]},
	{NAME:"Удар", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-5},
	{NAME:"Собака", CLASS:CLASSES.CREATURE, DESCRIPTION:"Живая собака, друг человека", TYPE:TYPES.BIOLOGICAL, HEALTH:Vector2(30, 30), COST:10, ATTACHMENT:["Укус"]},
	{NAME:"Укус", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-10},
	{NAME:"Хлеб", CLASS:CLASSES.ITEM, DESCRIPTION:"Кусок хлеба", GROUP:GROUPS.FOOD, QUANTITY:1, COST:5, ATTACHMENT:["Съесть хлеб"]},
	{NAME:"Съесть хлеб", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:5},
	{NAME:"Мясо", CLASS:CLASSES.ITEM, DESCRIPTION:"Кусок мяса", GROUP:GROUPS.FOOD, QUANTITY:1, COST:10, ATTACHMENT:["Съесть мясо"]},
	{NAME:"Съесть мясо", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:10},
	{NAME:"Тушенка", CLASS:CLASSES.ITEM, DESCRIPTION:"Банка тушенки, срок годности не указан", GROUP:GROUPS.FOOD, QUANTITY:1, COST:10, ATTACHMENT:["Съесть тушенку"]},
	{NAME:"Съесть тушенку", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:10},
	{NAME:"Нож", CLASS:CLASSES.ITEM, DESCRIPTION:"Обычный бытовой нож", COST:30, ATTACHMENT:["Удар ножом"]},
	{NAME:"Удар ножом", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-10},
	{NAME:"Топор", CLASS:CLASSES.ITEM, DESCRIPTION:"Топор дровосека", COST:50, ATTACHMENT:["Удар топором"]},
	{NAME:"Удар топором", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-20},
	{NAME:"Бензопила", CLASS:CLASSES.ITEM, DESCRIPTION:"Для работы нужен бензин", CAPACITY:Vector2(0, 1), CONSUMABLES:"Канистра с бензином", COST:150, ATTACHMENT:["Распил бензопилой"]},
	{NAME:"Распил бензопилой", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-50},
	{NAME:"Канистра с бензином", CLASS:CLASSES.ITEM, DESCRIPTION:"Используется только для хранения бензина", CAPACITY:Vector2(0, 10), COST:10},
	{NAME:"Дробовик", CLASS:CLASSES.ITEM, DESCRIPTION:"Грозное оружие на небольших дистанциях", CAPACITY:Vector2(0, 6), CONSUMABLES:"Патрон для дробовика", COST:250, ATTACHMENT:["Выстрел из дробовика"]},
	{NAME:"Выстрел из дробовика", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-100},
	{NAME:"Патрон для дробовика", CLASS:CLASSES.ITEM, DESCRIPTION:"Подходит только к дробовикам", QUANTITY:1, COST:5},
	{NAME:"Пистолет", CLASS:CLASSES.ITEM, DESCRIPTION:"Стреляет одиночными выстрелами", CAPACITY:Vector2(0, 9), CONSUMABLES:"Патрон 9 мм", COST:150, ATTACHMENT:["Выстрел из пистолета"]},
	{NAME:"Выстрел из пистолета", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-30},
	{NAME:"Патрон 9 мм", CLASS:CLASSES.ITEM, DESCRIPTION:"Подходит для пистолетов и пистолетов-пулеметов", QUANTITY:1, COST:5},
	{NAME:"Охотничья винтовка", CLASS:CLASSES.ITEM, DESCRIPTION:"Двухзарядная охотничья винтовка", CAPACITY:Vector2(0, 2), CONSUMABLES:"Патрон 7.62 мм", COST:190, ATTACHMENT:["Выстрел из винтовки"]},
	{NAME:"Выстрел из винтовки", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-40},
	{NAME:"Патрон 7.62 мм", CLASS:CLASSES.ITEM, DESCRIPTION:"Подходит для винтовок", QUANTITY:1, COST:5},
	{NAME:"Автоматическая винтовка", CLASS:CLASSES.ITEM, DESCRIPTION:"Стреляет очередью", CAPACITY:Vector2(0, 10), CONSUMABLES:"Патрон 5.56 мм (х3)", COST:320, ATTACHMENT:["Очередь из винтовки"]},
	{NAME:"Очередь из винтовки", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-120},
	{NAME:"Патрон 5.56 мм (х3)", CLASS:CLASSES.ITEM, DESCRIPTION:"Подходит для автоматических винтовок", QUANTITY:1, COST:15},
	{NAME:"Радиоприемник", CLASS:CLASSES.ITEM, DESCRIPTION:"В активированном состоянии позволяет слушать радиоэфир", CAPACITY:Vector2(0, 10), CONSUMABLES:"Аккумулятор", COST:60, ACTIVE:false, ATTACHMENT:["Прослушка радиоэфира"]},
	{NAME:"Прослушка радиоэфира", CLASS:CLASSES.ABILITY},
	{NAME:"Аккумулятор", CLASS:CLASSES.ITEM, DESCRIPTION:"Хранит электроэнергию. Можно заряжать", CAPACITY:Vector2(0, 100), COST:50},
	{NAME:"Текст радиосигнала", CLASS:CLASSES.ITEM, DESCRIPTION:"Семья не может открыть входной люк в персональном подземном бункере"},
	{NAME:"Динамит", CLASS:CLASSES.ITEM, DESCRIPTION:"Обладает большой разрушительной силой", QUANTITY:1, COST:300, ATTACHMENT:["Взрыв динамита"]},
	{NAME:"Взрыв динамита", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-300}
	]


func get_base_entity(name: String) -> Dictionary: # возвращает копию словаря с базовыми данными сущности
	for entity_data in ENTITIES:
		if entity_data[NAME] == name:
			return entity_data.duplicate() # иначе будет все изменения будут происходить с дефолтными данными
	return {}

func create_entity(data, custom_attributes := {}) -> GameEntity: # создает новую сущность по имени или по словарю данных
	if data is String:
		data = get_base_entity(data)
	
	for key in custom_attributes: # добавляем/заменяем нестандартные атрибуты
		data[key] = custom_attributes[key]
	
	var new_entity = GameEntity.new(data)
	
	for attachment_name in data.get(ATTACHMENT, []): # добавляем вложенные сущности
		new_entity.add_entity(create_entity(attachment_name), true) # плюс автоматически активируем
	data.erase(ATTACHMENT) # эти данные нужны только для инициализации
	
	new_entity.connect("delete_request", self, "_on_entity_delete", [new_entity])
	new_entity.connect("entity_changed", self, "_on_entity_changed", [new_entity])
	
	if data[NAME] == "Игрок":
		player = new_entity
	
	return new_entity

func create_person(possible_weapons := [], health := 0) -> GameEntity: # создает сущность человека с заданным здоровьем и оружием
	if not health:
		health = 1 + randi() % 100 # здоровье от 1 до 100
	if not possible_weapons:
		possible_weapons = [{"Ничего":1}, {"Нож":0.6}, {"Топор":0.4}, {"Пистолет":0.3}, {"Охотничья винтовка":0.2}]
	
	var person = create_entity("Человек", {HEALTH:Vector2(health, 100)})
	var weapon_name = randw(possible_weapons)
	
	if weapon_name != "Ничего":
		var weapon_data = get_base_entity(weapon_name)
		
		var capacity = weapon_data.get(CAPACITY)
		if capacity:
			weapon_data[CAPACITY].x = 1 + randi() % int(capacity.y) # случайное количество зарядов
		
		person.add_entity(create_entity(weapon_data), true) # сразу активируем
	
	return person

func _on_entity_changed(entity: GameEntity):
	if entity == player or entity.owner == player:
		emit_signal("player_entities_changed", player.get_entities()) # сингла для элементов GUI

func _on_entity_delete(entity: GameEntity):
	if entity == player:
		Game.game_over()
	if entity.owner:
		entity.owner.remove_entity(entity)

func duel(defender: GameEntity, attacker: GameEntity = player): # нападающий указан последним т.к. опционален
	Logger.info("Начинается поединок %s с %s" % [attacker.get_text(), defender.get_text()])
	var participants := [attacker, defender]
	var current := 0 # индекс в массиве для текущего участника
	
	for i in 100: # ограничиваем количество ударов чтобы не использовать бесконечный while true
		var damage_source = participants[current].get_attribute_owner(CHANGE_HEALTH)
		var damage: int = damage_source.get_attribute(CHANGE_HEALTH)
		damage_source.owner.change_attribute(CAPACITY) # расходуем заряд (если можно)
		var surplus = participants[current^1].change_attribute(HEALTH, damage, false) # меняем здоровье второго участника
		if surplus: return # любое ненулевое значение остатка означает смерть участника

		current = current^1 # меняем атакующего
	assert(true, "Количество обменов ударами в дуэли превысило допустимое значение!")

func time_effects(): # потребление различных ресурсов игрока в результате проведения события
	for entity in player.get_entities(true): # для всех сущностей игрока, влючая его самого
		if entity.get_attribute(TYPE) == TYPES.BIOLOGICAL:
			entity.change_attribute(HEALTH) # снижение "сытости" для биологических сущностей
		
		if entity.get_attribute(ACTIVE):
			entity.change_attribute(CAPACITY) # потребление расходников активных сущностей

func clamp_int(value: int, min_value: int, max_value: int) -> int: # вариант clamp() для целых чисел
	if value > max_value: return max_value
	if value < min_value: return min_value
	return value

func randw(data: Array): # генератор взвешенных случайных чисел. Принимает массив словарей {ключ:вероятность}. Функция возвращает ключ выбранного случайного элемента. Пример использования: randw([{"Нож":0.25}, {"Топор":1.0}, {"Пистолет":0.5}]) вернет "Нож" с вероятностью 9%, "Топор" - 70% и "Пистолет" - 21% (в сумме 100%)
	var max_value := 0.0
	for element in data:
		max_value = max(max_value, element.values()[0]) # находим максимальную вероятность
	
	data.shuffle() # тасуем массив
	
	var cut_off = randf() * max_value # отсечка для элементов в диапазоне от 0 до максимальной вероятности
	
	for element in data:
		if cut_off <= element.values()[0]:
			return element.keys()[0] # возвращаем первый элемент с вероятностью выше отсечки

func _sort_entities(a: GameEntity, b: GameEntity) -> bool: # кастомная сортировка для массива сущностей
	return a.get_attribute(NAME) < b.get_attribute(NAME)
