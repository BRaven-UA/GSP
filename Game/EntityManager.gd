# Синглтон менеджер сущностей. Все операции с сущностями должны проходить через этот синглтон

extends Node

enum {NAME, CLASS, DESCRIPTION, HEALTH, TYPE, GROUP, CHANGE_HEALTH, QUANTITY, CONSUMABLES, CAPACITY, ATTACHMENT} # перечень атрибутов
enum TYPES {BIOLOGICAL, MECHANICAL, DIGITAL, MENTAL} # перечень типов для атрибута TYPE
enum GROUPS {FOOD} # перечень групп, для объединения разных типов сущностей
enum CLASSES {CREATURE, ITEM, ABILITY}

var player: GameEntity # ссылка на сущность игрока

signal player_entities_changed

const ENTITIES := [
	{NAME:"Игрок", CLASS:CLASSES.CREATURE, DESCRIPTION:"Персонаж за которого вы играете", TYPE:TYPES.BIOLOGICAL, HEALTH:Vector2(100, 100), ATTACHMENT:["Удар"]},
	{NAME:"Удар", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-5},
	{NAME:"Собака", CLASS:CLASSES.CREATURE, DESCRIPTION:"Живая собака, друг человека", TYPE:TYPES.BIOLOGICAL, HEALTH:Vector2(30, 30), ATTACHMENT:["Укус"]},
	{NAME:"Укус", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-10},
	{NAME:"Хлеб", CLASS:CLASSES.ITEM, DESCRIPTION:"Кусок хлеба", GROUP:GROUPS.FOOD, QUANTITY:1, ATTACHMENT:["Съесть хлеб"]},
	{NAME:"Съесть хлеб", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:5},
	{NAME:"Мясо", CLASS:CLASSES.ITEM, DESCRIPTION:"Кусок мяса", GROUP:GROUPS.FOOD, QUANTITY:1, ATTACHMENT:["Съесть мясо"]},
	{NAME:"Съесть мясо", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:10},
	{NAME:"Тушенка", CLASS:CLASSES.ITEM, DESCRIPTION:"Банка тушенки, срок годности не указан", GROUP:GROUPS.FOOD, QUANTITY:1, ATTACHMENT:["Съесть тушенку"]},
	{NAME:"Съесть тушенку", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:10},
	{NAME:"Нож", CLASS:CLASSES.ITEM, DESCRIPTION:"Обычный бытовой нож", ATTACHMENT:["Удар ножом"]},
	{NAME:"Удар ножом", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-10},
	{NAME:"Дробовик", CLASS:CLASSES.ITEM, DESCRIPTION:"Грозное оружие на небольших дистанциях", CAPACITY:Vector2(0, 6), CONSUMABLES:"Патрон для дробовика", ATTACHMENT:["Выстрел из дробовика"]},
	{NAME:"Выстрел из дробовика", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-100},
	{NAME:"Патрон для дробовика", CLASS:CLASSES.ITEM, DESCRIPTION:"Подходит только к дробовикам", QUANTITY:1},
	{NAME:"Радиоприемник", CLASS:CLASSES.ITEM, DESCRIPTION:"Работает в широком диапазоне радиочастот", ATTACHMENT:["Прослушка радиоэфира"]},
	{NAME:"Прослушка радиоэфира", CLASS:CLASSES.ABILITY}
	]


func create_entity(name: String, custom_attributes := {}) -> GameEntity: # создает новый экземпляр класса
	if name:
		for entity_data in ENTITIES:
			if entity_data[NAME] == name:
				var copy: Dictionary = entity_data.duplicate() # иначе будет все изменения будут происходить с дефолтными данными
				
				for key in custom_attributes: # добавляем/заменяем нестандартные атрибуты
					copy[key] = custom_attributes[key]
				
				var new_entity = GameEntity.new(copy)
				
				for attachment_name in copy.get(ATTACHMENT, []): # добавляем вложенные сущности
					new_entity.add_entity(create_entity(attachment_name), true) # плюс автоматически активируем
				copy.erase(ATTACHMENT) # эти данные нужны только для инициализации
				
				new_entity.connect("delete_request", self, "_on_entity_delete", [new_entity])
				
				if name == "Игрок":
					player = new_entity
					new_entity.connect("entities_changed", self, "_on_player_entities_changed")
				
				return new_entity
	push_warning("Сущности с именем [%s] нет в базе данных!" % name)
	print_stack()
	return null

func _on_player_entities_changed(entities):
	emit_signal("player_entities_changed", entities)

func _on_entity_delete(entity: GameEntity):
#	entity.disconnect("delete_request", self, "_on_entity_delete")
	if entity == E.player:
#		entity.disconnect("player_entities_changed", self, "_on_player_entities_changed")
		Game.game_over()
	if entity.owner:
		entity.owner.remove_entity(entity)

func duel(defender: GameEntity, attacker: GameEntity = E.player): # нападающий указан последним т.к. опционален
	Logger.info("Начинается поединок %s с %s" % [attacker.get_text(), defender.get_text()])
	var participants := [attacker, defender]
	var current := 0 # индекс в массиве для текущего участника
	
	for i in 100: # ограничиваем количество ударов чтобы не использовать бесконечный while true
		var damage: int = participants[current].get_attribute(E.CHANGE_HEALTH, false)
		participants[current].change_attribute(E.CAPACITY, -1, false) # расходуем заряд (если можно)
		var surplus = participants[current^1].change_attribute(E.HEALTH, damage, false) # меняем здоровье второго участника
		if surplus: return # любое ненулевое значение остатка означает смерть участника

		current = current^1 # меняем атакующего
	assert(true, "Количество обменов ударами в дуэли превысило допустимое значение!")

func time_effects(): # потребление различных ресурсов игрока в результате проведения события
	for entity in E.player.get_entities(true): # для всех сущностей игрока, влючая его самого
		if entity.get_attribute(E.TYPE) == E.TYPES.BIOLOGICAL:
			entity.change_attribute(E.HEALTH, -1) # снижение "сытости" для биологических сущностей

func clamp_int(value: int, min_value: int, max_value: int) -> int: # вариант clamp() для целых чисел
	if value > max_value: return max_value
	if value < min_value: return min_value
	return value
