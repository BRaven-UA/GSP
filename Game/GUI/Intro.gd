extends ColorRect

onready var _player := $AnimationPlayer

func _ready() -> void:
	_player.play("Appear")

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton: # скрываем по нажатию любой клавиши
		_player.play("Fade")
		set_process_input(false) # исключаем повторные срабатывания
		yield(_player, "animation_finished")
		Game.new_character()
