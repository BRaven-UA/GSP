# Синглтон для записи игровых событий, системной отладочной информации

extends Node

enum {SYSTEM, INGAME} # ?? добавить еще get_stack() ??
var _records: Array # список всех сохраненных записей
var debug_mode := true # режим отладки (все записи дублируются в консоль редактора)

signal new_log_record # сигнла для игрового GUI


func _add_record(text: String, category: int = INGAME) -> String: # регистрирует новое событие и возвращает его текстовый вариант
	var os_time = OS.get_time()
	var time := "%02d:%02d:%02d" % [os_time.hour, os_time.minute, os_time.second]
	var new_log_record = {Time = time, Category = category, Text = text}
	_records.append(new_log_record)
	var as_text = _get_as_text(new_log_record)
	return as_text

func info(text: String): # добавление записи по игровому событию (отображается в GUI)
	var message = _add_record(text)
	emit_signal("new_log_record", message)

func debug(text: String): # добавление отладочной информации
	var message = _add_record(text, SYSTEM)
	if debug_mode:
		print(message)

func _get_as_text(record: Dictionary) -> String: # возвращает запись в виде строки
	return "[{Time}] {Text}".format(record)

func _notification(what: int) -> void: # сохраняем на диск при закрытии приложения
	if what == NOTIFICATION_WM_QUIT_REQUEST:
		var file = File.new()
		var error = file.open("res://Log.txt", File.WRITE)
		if not error:
			file.store_string(to_json(_records))
			file.close()
