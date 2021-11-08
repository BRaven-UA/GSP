# Синглтон для записи игровых событий, системной отладочной информации

extends Node

enum {SYSTEM, INGAME, INGAME_DAMAGE, INGAME_HEAL, INGAME_EXP, INGAME_TAKE, INGAME_LOSS, TIP} # ?? добавить еще get_stack() ??
enum {TIP_START, TIP_NOTEBOOK, TIP_NOTE, TIP_META, TIP_TIME, TIP_ACTIVE, TIP_WEAPON, TIP_RESTORE, TIP_LOAD, TIP_TRADE, TIP_TRACKING, TIP_LEVEL, TIP_DEATH}
const TIPS := {
	TIP_START:"Вы управляете игровым персонажем в этом мире. Выберите игровое событие из предложенных.\nУбрать отображение подсказок можно в контекстном меню этого лога.",
	TIP_NOTEBOOK:"Вы нашли чью-то записную книжку. Из нее вырвали большое количество листов, но еще остались читые листы, в которых ваш ерсонаж может делать записи. Также в эту книжку будут попадать найденные во время игры заметки. Открыть/закрыть книжку можно нажатием на нее.",
	TIP_NOTE:"Вы нашли записку. Вся важная для сюжета информация будет автоматически добавляться в вашу записную книжку. О новых записях в книжке можно узнать по изменившейся иконке книжки.",
	TIP_META:"В тексте некоторых записок могут встречаться важные ссылки. Нажатие на них приводит к определенным действиям",
	TIP_TIME:"После каждого события здоровье уменьшается на единицу",
	TIP_ACTIVE:"Некоторые предметы можно активировать по желанию. В активном состоянии они будут потреблять расходники после каждого события",
	TIP_WEAPON:"Урон противникам можно наносить как врукопашную, так и с помощью разного оружия и устройств",
	TIP_RESTORE:"Восполнять потерянное здоровье можно с помощью еды",
	TIP_LOAD:"Некоторые предметы используют расходные материалы. Такие предметы нужно зарядить перед использованием",
	TIP_TRADE:"Торговля в игре представлена только бартером (валюта в этом мире потеряла всякую ценность). У каждого товара есть условная ценность, торговцы завышают ценность своих товаров. Выбрать несколько предметов можно с помощью клавиш CTRL или SHIFT",
	TIP_TRACKING:"Расстояние до некоторых мест в игре можно отслеживать. При этом на всех событиях будет указано насколько изменится расстояние до места при выборе этого события",
	TIP_LEVEL:"Каждый новый уровень дает возможность выбрать случайную способность для вашего героя",
	TIP_DEATH:"Ваш текущий персонаж умер, но игровой мир остался прежним. Доспутен другой персонаж"}

var _show_tips := true # флаг показа подсказок
var _shown_tips := {} # перечень уже показанных подсказок
var _records: Array # список всех сохраненных записей
var debug_mode := true # режим отладки (все записи дублируются в консоль редактора)

signal new_log_record # сигнла для игрового GUI


func _add_record(text: String, category: int = INGAME) -> Dictionary: # регистрирует новое событие и возвращает его текстовый вариант
	var os_time = OS.get_time()
	var time := "%02d:%02d:%02d" % [os_time.hour, os_time.minute, os_time.second]
	var new_log_record = {Time = time, Category = category, Text = text}
	_records.append(new_log_record)
	return new_log_record

func info(text: String, category: int = INGAME): # добавление записи по игровому событию (отображается в GUI)
	var new_record = _add_record(text, category)
	emit_signal("new_log_record", new_record)

func tip(index: int): # добавление записи об игровой подсказке
	if _show_tips and not _shown_tips.get(index):
		info(TIPS[index], TIP)
		_shown_tips[index] = true

func debug(text: String): # добавление отладочной информации
	var message = _add_record(text, SYSTEM)
	if debug_mode:
		print(message)

func _as_text(record: Dictionary) -> String: # возвращает запись в виде строки
	return "[{Time}] {Text}".format(record)

#func _notification(what: int) -> void: # сохраняем на диск при закрытии приложения
#	if what == NOTIFICATION_WM_QUIT_REQUEST:
#		var file = File.new()
#		var error = file.open("res://Game/Log.txt", File.WRITE)
#		if not error:
#			file.store_string(to_json(_records))
#			file.close()
