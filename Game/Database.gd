# База данных игры. Содержит в себе перечень возможных ключей аттрибутов и другие перечисления, сведения о всех игровых сущностях, а также методы для работы с ними
# Аттрибуты типа Vector2 содержат данные о текущем значении аттрибута (свойство x) и о его максимальном значении (свойство y)

extends Node

enum KEYS {CLASS, NAME, DESCRIPTION, HEALTH, TYPE, CHANGE_HEALTH, QUANTITY, CONSUMABLES, CAPACITY, ENTITIES} # перечень атрибутов
enum TYPES {BIOLOGICAL, MECHANICAL, DIGITAL, MENTAL} # перечень типов для атрибута TYPE
enum CLASSES {CREATURE, ITEM, ABILITY}

const ENTITIES := [
	{KEYS.NAME:"Игрок", KEYS.CLASS:CLASSES.CREATURE, KEYS.DESCRIPTION:"Персонаж за которого вы играете", KEYS.TYPE:TYPES.BIOLOGICAL, KEYS.HEALTH:Vector2(100, 100), KEYS.ENTITIES:["Удар человека"]},
	{KEYS.NAME:"Удар человека", KEYS.CLASS:CLASSES.ABILITY, KEYS.CHANGE_HEALTH:-5},
	{KEYS.NAME:"Собака", KEYS.CLASS:CLASSES.CREATURE, KEYS.DESCRIPTION:"Живая собака, друг человека", KEYS.TYPE:TYPES.BIOLOGICAL, KEYS.HEALTH:Vector2(20, 20), KEYS.ENTITIES:["Укус собаки"]},
	{KEYS.NAME:"Укус собаки", KEYS.CLASS:CLASSES.ABILITY, KEYS.CHANGE_HEALTH:-10},
	{KEYS.NAME:"Хлеб", KEYS.CLASS:CLASSES.ITEM, KEYS.DESCRIPTION:"Кусок хлеба", KEYS.QUANTITY:1, KEYS.ENTITIES:["Съесть хлеб"]},
	{KEYS.NAME:"Съесть хлеб", KEYS.CLASS:CLASSES.ABILITY, KEYS.CHANGE_HEALTH:10},
	{KEYS.NAME:"Тушенка", KEYS.CLASS:CLASSES.ITEM, KEYS.DESCRIPTION:"Банка тушенки, срок годности не указан", KEYS.QUANTITY:1, KEYS.ENTITIES:["Съесть тушенку"]},
	{KEYS.NAME:"Съесть тушенку", KEYS.CLASS:CLASSES.ABILITY, KEYS.CHANGE_HEALTH:20},
	{KEYS.NAME:"Нож", KEYS.CLASS:CLASSES.ITEM, KEYS.DESCRIPTION:"Обычный бытовой нож", KEYS.ENTITIES:["Удар ножом"]},
	{KEYS.NAME:"Удар ножом", KEYS.CLASS:CLASSES.ABILITY, KEYS.CHANGE_HEALTH:-10},
	{KEYS.NAME:"Дробовик", KEYS.CLASS:CLASSES.ITEM, KEYS.DESCRIPTION:"Грозное оружие на небольших дистанциях", KEYS.CAPACITY:Vector2(0, 6), KEYS.CONSUMABLES:"Патрон для дробовика", KEYS.ENTITIES:["Выстрел дробовика"]},
	{KEYS.NAME:"Выстрел дробовика", KEYS.CLASS:CLASSES.ABILITY, KEYS.CHANGE_HEALTH:-100},
	{KEYS.NAME:"Патрон дробовика", KEYS.CLASS:CLASSES.ITEM, KEYS.DESCRIPTION:"Подходит только к дробовикам", KEYS.QUANTITY:1},
	]
