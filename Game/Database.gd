# База данных игры. Содержит в себе перечень возможных ключей аттрибутов и другие перечисления, сведения о всех игровых предметах, а также методы для работы с ними
# Аттрибуты типа Vector2 содержат данные о текущем значении аттрибута (свойство x) и о его максимальном значении (свойство y)

extends Node

enum KEYS {NAME, DESCRIPTION, TYPE, HEALTH, DAMAGE, RESTOREHEALTH, USES}
enum TYPES {BIOLOGICAL, MECHANICAL, DIGITAL, MENTAL}

const ITEMS := [
	{KEYS.NAME: "Собака", KEYS.DESCRIPTION: "Живая собака, друг человека", KEYS.TYPE: TYPES.BIOLOGICAL, KEYS.HEALTH: Vector2(10, 10), KEYS.DAMAGE: 5},
	{KEYS.NAME:"Хлеб", KEYS.DESCRIPTION:"Кусок хлеба", KEYS.RESTOREHEALTH:5, KEYS.USES:1},
	{KEYS.NAME:"Нож", KEYS.DESCRIPTION:"Обычный бытовой нож", KEYS.DAMAGE:5}
	]


func create_item(name: String) -> Dictionary:
	if name:
		for item in ITEMS:
			if item[KEYS.NAME] == name:
				return item.duplicate()
	push_warning("Предмета с именем [%s] нет в базе данных!" % name)
	print_stack()
	return {}
