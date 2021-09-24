# Базовый класс для событий в игре. Классы-наследники сохраняются в отдельных файлах и переопределяют виртуальные методы, в которых реализуют свою уникальную логику

extends Resource

class_name GameEvent

var name: String # заголовок события
var description: String # описание события до того как игрок получит перечень возможных действий
var entities: Array # прикрепленные к событию сущности (если есть)
var actions: Array # список действий для данного события
var _player_entities: Array = Global.player.entities # ссылка на все сущности игрока
var _player: Dictionary = _player_entities[0] # ссылка на сущность самого игрока


func update_actions(): # формирует список возможных действий, исходя из атрибутов игрока и его предметов
	actions.clear()
	_define_actions()

func _define_actions(): # сформировать список возможных действий (виртуальный метод для переопределения в классах-наследниках)
	pass

func _add_action(action_text := "", result_text := "", changes := []): # добавление нового действия в список
	var new_action = {}
	new_action.Action_text = action_text # текст для кнопки
	new_action.Result_text = result_text # текст для окна результатов события
	new_action.Changes = changes # список изменений по результатам события
	actions.append(new_action)

func apply_action(index: int) -> void: # применить указанное действие
	var action = actions[index]
	
	var dialog = Global.gui.show_accept_dialog(action.Result_text)
	yield(dialog, "confirmed")
	
	for change in action.Changes: # изменений может быть несколько
		if change.get(DB.KEYS.NAME): # передана сущность вместо словаря с изменением
			Global.player.add_entity(change)
		else:
			Global.player.change_attribute(change.Target, change.Key, change.Value)
	
	Global.game.update_events()

func _get_change(target: Dictionary, key: int, new_value) -> Dictionary: # функция-подсказка чтобы видеть состав словаря
	return {"Target":target, "Key":key, "Value":new_value}

func _duel(participants: Array) -> Array: # поединок двух сущностей, обмен ударами по очереди до смерти. Возвращает массив из двух значений здоровья каждого участника
	var healths := [int(participants[0].get(DB.KEYS.HEALTH).x), int(participants[1].get(DB.KEYS.HEALTH).x)] # начальные значения здоровья
	var attacker := 0 # индекс в массиве для атакующего
	
	for i in 100: # ограничиваем количество ударов чтобы не использовать бесконечный while true
		var damage: int = participants[attacker].get(DB.KEYS.DAMAGE) # урон атакующего
		healths[attacker^1] -= damage # уменьшаем здоровье второго участника
#		print(participants[attacker].get(DB.KEYS.NAME), " бьет ", participants[attacker^1].get(DB.KEYS.NAME), " на ", damage, " ед. урона   [", healths, "]")
		
		if healths[attacker^1] <= 0:
			healths[attacker^1] = 0
			return healths
		
		attacker = attacker^1 # меняем атакующего
	
	push_warning("Количество обменов ударами в дуэли превысило допустимое значение!")
	print_stack()
	return []
