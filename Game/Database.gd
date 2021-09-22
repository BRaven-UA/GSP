# База данных игры. Содержит в себе перечень возможных ключей аттрибутов и другие перечисления, сведения о всех игровых сущностях, а также методы для работы с ними
# Аттрибуты типа Vector2 содержат данные о текущем значении аттрибута (свойство x) и о его максимальном значении (свойство y)

extends Node

enum KEYS {NAME, DESCRIPTION, TYPE, HEALTH, DAMAGE, RESTOREHEALTH, USES} # перечень атрибутов
enum TYPES {BIOLOGICAL, MECHANICAL, DIGITAL, MENTAL} # перечень типов для атрибута TYPE

const ENTITIES := [
	{KEYS.NAME:"Игрок", KEYS.DESCRIPTION:"Персонаж за которого вы играете", KEYS.TYPE:TYPES.BIOLOGICAL, KEYS.HEALTH:Vector2(100, 100), KEYS.DAMAGE:5},
	{KEYS.NAME:"Собака", KEYS.DESCRIPTION:"Живая собака, друг человека", KEYS.TYPE:TYPES.BIOLOGICAL, KEYS.HEALTH:Vector2(20, 20), KEYS.DAMAGE:10},
	{KEYS.NAME:"Хлеб", KEYS.DESCRIPTION:"Кусок хлеба", KEYS.RESTOREHEALTH:5, KEYS.USES:1},
	{KEYS.NAME:"Нож", KEYS.DESCRIPTION:"Обычный бытовой нож", KEYS.DAMAGE:10}
	]


func create_entity(name: String) -> Dictionary:
	if name:
		for entity in ENTITIES:
			if entity[KEYS.NAME] == name:
				return entity.duplicate()
	push_warning("Предмета с именем [%s] нет в базе данных!" % name)
	print_stack()
	return {}
