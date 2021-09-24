# База данных игры. Содержит в себе перечень возможных ключей аттрибутов и другие перечисления, сведения о всех игровых сущностях, а также методы для работы с ними
# Аттрибуты типа Vector2 содержат данные о текущем значении аттрибута (свойство x) и о его максимальном значении (свойство y)

extends Node

enum KEYS {NAME, DESCRIPTION, HEALTH, TYPE, RESTOREHEALTH, DAMAGE, USES, CONSUMABLES, CAPACITY} # перечень атрибутов
enum TYPES {BIOLOGICAL, MECHANICAL, DIGITAL, MENTAL} # перечень типов для атрибута TYPE

const ENTITIES := [
	{KEYS.NAME:"Игрок", KEYS.DESCRIPTION:"Персонаж за которого вы играете", KEYS.TYPE:TYPES.BIOLOGICAL, KEYS.HEALTH:Vector2(100, 100), KEYS.DAMAGE:5},
	{KEYS.NAME:"Собака", KEYS.DESCRIPTION:"Живая собака, друг человека", KEYS.TYPE:TYPES.BIOLOGICAL, KEYS.HEALTH:Vector2(20, 20), KEYS.DAMAGE:10},
	{KEYS.NAME:"Хлеб", KEYS.DESCRIPTION:"Кусок хлеба", KEYS.RESTOREHEALTH:10, KEYS.USES:1},
	{KEYS.NAME:"Тушенка", KEYS.DESCRIPTION:"Банка тушенки, срок годности не указан", KEYS.RESTOREHEALTH:20, KEYS.USES:1},
	{KEYS.NAME:"Нож", KEYS.DESCRIPTION:"Обычный бытовой нож", KEYS.DAMAGE:10},
	{KEYS.NAME:"Дробовик", KEYS.DESCRIPTION:"Грозное оружие на небольших дистанциях", KEYS.DAMAGE:100, KEYS.CAPACITY:Vector2(0, 6), KEYS.CONSUMABLES:"Патрон для дробовика"},
	{KEYS.NAME:"Патрон для дробовика", KEYS.DESCRIPTION:"Подходит только к дробовикам", KEYS.USES:1},
	]


func create_entity(name: String) -> Dictionary:
	if name:
		for entity in ENTITIES:
			if entity[KEYS.NAME] == name:
				return entity.duplicate()
	push_warning("Предмета с именем [%s] нет в базе данных!" % name)
	print_stack()
	return {}

func fix_value(entity: Dictionary, key: int, value): # приводит значение ключа к правильному типу и допустимому значению
	if key in [KEYS.HEALTH, KEYS.CAPACITY]: # тип значений Vector2
		if not (value is Vector2):
			value = Vector2(value, entity[key].y) # обычно передается только текущее значение
		value.x = clamp(value.x, 0.0, entity[key].y) # усекаем значение до интервала от нуля до максимального
	
	return value
