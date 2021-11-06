extends ColorRect

onready var _player := $AnimationPlayer

func _ready() -> void:
	_player.connect("animation_finished", self, "_on_animation_finished")
	_player.play("Appear")

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton: # скрываем по нажатию любой клавиши
		set_process_input(false) # исключаем повторные срабатывания
		_player.play("Fade")

func _on_animation_finished(name: String):
	if name == "Fade":
		Game.new_character()
